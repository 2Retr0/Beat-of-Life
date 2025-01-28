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

# Each array element represents a lane. Each dictionary element maps HitObject -> HitObjectPlayable.
var playables : Array[Dictionary]
var create_index: int = 0

func initialize(beatmap: Beatmap) -> void:
	assert(beatmap is ManiaBeatmap, 'Beatmap is not mania beatmap')
	super.initialize(beatmap)

	for lane in playables:
		for hit_object in lane:
			lane[hit_object].free()

	playables.clear()
	for i in range(beatmap.lane_count):
		playables.append({})

	if auto: set_process_input(false) # Disable input if auto mode is on

	audio_controller.seeked.connect(_on_audio_controller_seeked)


func _process(delta: float) -> void:
	var time := audio_controller.time
	for i in len(playables):
		var lane := playables[i]
		for hit_object in lane:
			var playable : HitObjectPlayable = lane[hit_object]
			if not _is_relevant(hit_object):
				# Free irrelevant playables
				lane[hit_object].queue_free()
			elif playable.is_actionable(time):
				if auto:
					_perform_auto_action(playable)
				elif Input.is_key_pressed(input_maps[beatmap.lane_count][i]):
					# Account for input holding
					# NOTE: HOLD STATE IS UNUSED ATM SINCE YOU CAN DETERMINE HOLD BY CHECKING
					#       IF AN INPUT THAT WAS PRESSED WAS LATER RELEASED!
					playable.perform_action(HitObjectPlayable.ActionType.HELD)
				break

	# Instantiate new relevant playables
	for i in range(create_index, len(beatmap.hit_objects)):
		var hit_object := beatmap.hit_objects[i]
		if _is_relevant(hit_object):
			_create_playable(hit_object)
			create_index = i + 1
		else:
			break


func _perform_auto_action(playable : HitObjectPlayable) -> void:
	var hit_object : HitObject = playable.hit_object
	var time := audio_controller.time
	if time <= hit_object.time: return

	var event := InputEventKey.new()
	event.keycode = input_maps[beatmap.lane_count][hit_object.lane]
	if playable.result == HitResult.Enum.None:
		event.pressed = true
		_input(event)
	elif hit_object is ManiaLongNote and time >= hit_object.get_end_time():
		event.pressed = false
		_input(event)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.is_echo():
		if event.is_pressed(): hit_audio_player.play()

		var input_map : Array = input_maps[beatmap.lane_count]
		var key_index := input_map.find(event.keycode)
		if key_index < 0: return

		# Find perform the relevant action on the first playable that can be hit.
		var lane := playables[key_index]
		for hit_object in lane:
			var playable : HitObjectPlayable = lane[hit_object]
			if not playable.is_actionable(audio_controller.time): continue

			if event.is_pressed():
				playable.perform_action(HitObjectPlayable.ActionType.PRESSED)
			elif event.is_released():
				playable.perform_action(HitObjectPlayable.ActionType.RELEASED)
			return

func _create_playable(hit_object: HitObject) -> void:
	var playable : Variant
	if hit_object is ManiaNote:
		playable = note_scene.instantiate()
	elif hit_object is ManiaLongNote:
		playable = long_note_scene.instantiate()
	playable.player = self
	playable.hit_object = hit_object

	playable.result_changed.connect(_record_result)
	playable.tree_exiting.connect(func(): playables[hit_object.lane].erase(hit_object))

	playfield_center.add_child(playable)
	playables[hit_object.lane][hit_object] = playable

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
			_create_playable(hit_object)
