class_name ManiaPlayer extends BeatmapPlayer

## TODO: SWITCH TO USING GODOT INPUT MAP AT SOME POINT!
const input_maps: Dictionary = {
	3: [KEY_F, KEY_SPACE, KEY_J],
	4: [KEY_D, KEY_F, KEY_J, KEY_K],
	5: [KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K],
	6: [KEY_S, KEY_D, KEY_F, KEY_J, KEY_K, KEY_L],
	7: [KEY_S, KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K, KEY_L],
	8: [KEY_A, KEY_S, KEY_D, KEY_F, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON],
	9: [KEY_A, KEY_S, KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON],
}

@export var note_scene : PackedScene

@export var long_note_scene : PackedScene

@export var playfield_center: Node

@export var hit_audio_player : AudioStreamPlayer

## Time (in seconds) for a hit object to travel to the playfield center
@export var scroll_time: float = 0.5

@export var auto: bool = false

# FIXME: This can later be used for replays maybe
var score_playback := TimeSeriesData.new()
var score := LevelScore.new()

var indices: Array[Array]
var playables : Array[Dictionary] # Hit object index -> playable
var create_index: int = 0

var last_key_states: Array[bool]

func initialize(beatmap: Beatmap) -> void:
	assert(beatmap is ManiaBeatmap, 'Beatmap is not mania beatmap')
	
	for state in states:
		state.action_handled.disconnect(_play_sound)
		state.result_changed.disconnect(_record_result)
	
	super.initialize(beatmap)
	
	for state in states:
		state.action_handled.connect(_play_sound)
		state.result_changed.connect(_record_result)

	indices.clear()
	for i in range(beatmap.lane_count):
		indices.append([])
	for i in range(beatmap.hit_objects.size()):
		indices[beatmap.hit_objects[i].lane].append(i)

	for lane_playables in playables:
		for index in lane_playables:
			lane_playables[index].free()
	playables.clear()
	for i in range(beatmap.lane_count):
		playables.append({})
	
	last_key_states.clear()
	for i in range(beatmap.lane_count):
		last_key_states.append(false)
	
	if auto: set_process_input(false) # Disable input if auto mode is on

	audio_controller.seeked.connect(_on_audio_controller_seeked)


func _process(delta: float) -> void:
	for lane in range(beatmap.lane_count):
		var lane_playables = playables[lane]
		for index in lane_playables:
			var state : HitObjectState = states[index]
			state.process_tick(self)

	var time := audio_controller.time
	for lane in range(beatmap.lane_count):
		var lane_playables = playables[lane]
		for index in lane_playables:
			var state : HitObjectState = states[index]
			if not _is_relevant(beatmap.hit_objects[index]):
				# Free irrelevant playables
				lane_playables[index].queue_free()
			elif state.can_perform_action(self):
				if auto:
					_perform_auto_action(state)
				else:
					var is_pressed : bool = Input.is_physical_key_pressed(input_maps[beatmap.lane_count][lane])
					var was_pressed : bool = last_key_states[lane]
					if is_pressed and was_pressed:
						state.perform_action(self, HitObjectState.ActionType.HELD)
					elif is_pressed and not was_pressed:
						state.perform_action(self, HitObjectState.ActionType.PRESSED)
					elif not is_pressed and was_pressed:
						state.perform_action(self, HitObjectState.ActionType.RELEASED)
					last_key_states[lane] = is_pressed
				break

	# Instantiate new relevant playables
	for i in range(create_index, len(beatmap.hit_objects)):
		var hit_object := beatmap.hit_objects[i]
		if _is_relevant(hit_object):
			_create_playable(create_index)
			create_index = i + 1
		else:
			break


func _perform_auto_action(state : HitObjectState) -> void:
	var hit_object : HitObject = state.hit_object
	var time := audio_controller.time
	if time < hit_object.time: return

	if hit_object is ManiaNote:
		if state.result == HitResult.Enum.None:
			state.perform_action(self, HitObjectState.ActionType.PRESSED)
	elif hit_object is ManiaLongNote:
		if state.press_result == HitResult.Enum.None:
			state.perform_action(self, HitObjectState.ActionType.PRESSED)
		elif state.release_result == HitResult.Enum.None:
			if time >= hit_object.get_end_time():
				state.perform_action(self, HitObjectState.ActionType.RELEASED)

func _create_playable(index: int) -> void:
	var hit_object : HitObject = beatmap.hit_objects[index]
	
	var playable : Variant
	if hit_object is ManiaNote:
		playable = note_scene.instantiate()
	elif hit_object is ManiaLongNote:
		playable = long_note_scene.instantiate()
	playable.player = self
	playable.state = states[index]

	playable.tree_exiting.connect(func(): playables[hit_object.lane].erase(index))

	playfield_center.add_child(playable)
	playables[hit_object.lane][index] = playable

#region --- OBJECT COLORS FOR FUN REMOVE LATER!!! ---
	if beatmap.lane_count % 2 == 1 and hit_object.lane == beatmap.lane_count / 2:
		playable.modulate = Color.CRIMSON
	else:
		playable.modulate = Color.STEEL_BLUE if hit_object.lane % 2 == 0 else Color.DARK_SEA_GREEN
#endregion

## Determines if the playable should be in the scene tree or not.
func _is_relevant(hit_object: HitObject) -> bool:
	var early_relevance_time = scroll_time*1.25
	var late_relevance_time = scroll_time*0.5
	return hit_object.get_start_time() - early_relevance_time <= audio_controller.time and \
		   hit_object.get_end_time() + late_relevance_time >= audio_controller.time

### NOTE: Caller is responsible for checking if result should be recorded or not!
func _record_result(result : HitResult.Enum) -> void:
	score.update(result)
	score_playback.record(score, audio_controller.time)

func _play_sound() -> void:
	hit_audio_player.play()

func _on_audio_controller_seeked(new_time: float) -> void:
	# Revert score to one stored in history
	score_playback.commit()
	score = score_playback.rollback(new_time)
	if not score:
		score = LevelScore.new()

	# Free all current playables
	for lane in playables:
		for hit_object in lane:
			lane[hit_object].queue_free()
		lane.clear()

	# Find the new create index and rebuild score by looping through all hit objects
	create_index = 0
	for i in len(beatmap.hit_objects):
		var hit_object := beatmap.hit_objects[i]
		if new_time < hit_object.get_start_time() - scroll_time:
			create_index = i
			break
		elif _is_relevant(hit_object):
			# Instantiate playables that are already relevant
			# (e.g., long notes that have started before the current time)
			_create_playable(i)
