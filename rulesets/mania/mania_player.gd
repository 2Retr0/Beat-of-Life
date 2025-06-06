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

var create_index: int = 0

var playables: Array[Array] # Array[Array[PlayableObject]]
var drawables: Dictionary # Dictionary[PlayableObject, Node]

var last_key_states: Array[bool]

func initialize(beatmap: Beatmap) -> void:
	assert(beatmap is ManiaBeatmap, 'Beatmap is not mania beatmap')

	super.initialize(beatmap)

	playables.resize(beatmap.lane_count)
	for i in range(beatmap.lane_count):
		playables[i] = []

	last_key_states.resize(beatmap.lane_count)
	last_key_states.fill(false)

	if auto:
		set_process_input(false) # Disable input if auto mode is on

	audio_controller.seeked.connect(_on_audio_controller_seeked)

func _process(delta: float) -> void:
	for lane_playables in playables:
		for playable in lane_playables:
			playable.process_tick()

	var time := audio_controller.time
	for lane_playables in playables:
		for playable in lane_playables:
			if not _is_relevant(playable.hit_object):
				dispose_playable(playable)
			elif playable.can_perform_action():
				if auto:
					_perform_auto_action(playable)
				else:
					var lane = playable.hit_object.lane
					var is_pressed : bool = Input.is_physical_key_pressed(input_maps[beatmap.lane_count][lane])
					var was_pressed : bool = last_key_states[lane]
					if is_pressed and not was_pressed:
						playable.perform_action(PlayableObject.ActionType.PRESSED)
					elif not is_pressed and was_pressed:
						playable.perform_action(PlayableObject.ActionType.RELEASED)
					last_key_states[lane] = is_pressed
				break

	# Instantiate new relevant playables
	for i in range(create_index, len(beatmap.hit_objects)):
		var hit_object := beatmap.hit_objects[i]
		if _is_relevant(hit_object):
			create_playable(hit_object)
			create_index = i + 1
		else:
			break


func _perform_auto_action(playable: PlayableObject) -> void:
	var hit_object: HitObject = playable.hit_object
	var time := audio_controller.time
	if time < hit_object.time: return

	if hit_object is ManiaNote:
		if !playable.is_judged():
			playable.perform_action(PlayableObject.ActionType.PRESSED)
	elif hit_object is ManiaLongNote:
		if playable.press_result == HitResult.Enum.None:
			playable.perform_action(PlayableObject.ActionType.PRESSED)
		elif playable.release_result == HitResult.Enum.None:
			if time >= hit_object.get_end_time():
				playable.perform_action(PlayableObject.ActionType.RELEASED)

func create_playable(hit_object: HitObject) -> PlayableObject:
	var playable: PlayableObject = super.create_playable(hit_object)
	playables[hit_object.lane].append(playable)

	var drawable: Variant
	if hit_object is ManiaNote:
		drawable = note_scene.instantiate()
	elif hit_object is ManiaLongNote:
		drawable = long_note_scene.instantiate()
	drawable.init(self, playable)
	drawables[playable] = drawable

	playfield_center.add_child(drawable)

#region --- OBJECT COLORS FOR FUN REMOVE LATER!!! ---
	if beatmap.lane_count % 2 == 1 and hit_object.lane == beatmap.lane_count / 2:
		drawable.modulate = Color.CRIMSON
	else:
		drawable.modulate = Color.STEEL_BLUE if hit_object.lane % 2 == 0 else Color.DARK_SEA_GREEN
#endregion

	return playable

func dispose_playable(playable: PlayableObject) -> void:
	drawables[playable].queue_free()

	playables[playable.hit_object.lane].erase(playable)
	drawables.erase(playable)

## Determines if the playable should be in the scene tree or not.
func _is_relevant(hit_object: HitObject) -> bool:
	var early_relevance_time = scroll_time*1.25
	var late_relevance_time = scroll_time*0.5
	return hit_object.get_start_time() - early_relevance_time <= audio_controller.time and \
		   hit_object.get_end_time() + late_relevance_time >= audio_controller.time

func report_judgment(judgment: Judgment) -> void:
	super.report_judgment(judgment)

func play_sound() -> void:
	hit_audio_player.play()

func _on_audio_controller_seeked(new_time: float) -> void:
	# Revert score to one stored in history
	# TODO either fix or remove
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
			create_playable(hit_object)
