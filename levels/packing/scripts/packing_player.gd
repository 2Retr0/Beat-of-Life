class_name PackingPlayer extends BeatmapPlayer

const left_key = KEY_LEFT
const right_key = KEY_RIGHT

@export var note_scene : PackedScene

@export var playfield_center: Node

@export var hit_audio_player : AudioStreamPlayer

## Time (in seconds) for a hit object to travel to the playfield center
@export var scroll_time: float = 0.5

@export var auto: bool = false

@export var current_lane: int = 0

@export var box: Sprite3D

var create_index: int = 0

var playables: Array[Array] # Array[Array[PlayableObject]]
var drawables: Dictionary # Dictionary[PlayableObject, Node]

var was_left_clicked: bool
var was_right_clicked: bool

func initialize(beatmap: Beatmap) -> void:
	assert(beatmap is PackingBeatmap, 'Beatmap is not packing beatmap')

	super.initialize(beatmap)

	playables.resize(beatmap.lane_count)
	for i in range(beatmap.lane_count):
		playables[i] = []

	if auto:
		set_process_input(false) # Disable input if auto mode is on

	audio_controller.seeked.connect(_on_audio_controller_seeked)

func _process(delta: float) -> void:
	for lane_playables in playables:
		for playable in lane_playables:
			playable.process_tick()

	var lane_change = 1
	if Input.is_physical_key_pressed(KEY_CTRL):
		lane_change = 2
	if Input.is_physical_key_pressed(KEY_SHIFT):
		lane_change = 3
	
	var is_left_clicked = Input.is_physical_key_pressed(left_key)
	if is_left_clicked and not was_left_clicked:
		current_lane -= lane_change
	was_left_clicked = is_left_clicked
	
	var is_right_clicked = Input.is_physical_key_pressed(right_key)
	if is_right_clicked and not was_right_clicked:
		current_lane += lane_change
	was_right_clicked = is_right_clicked
	
	current_lane = clamp(current_lane, 0, beatmap.lane_count - 1)
	
	box.position = Vector3(0.65 * (current_lane - beatmap.lane_count / 2.0 + 0.5), 0, 0)

	for lane_playables in playables:
		for playable in lane_playables:
			if not _is_relevant(playable.hit_object):
				dispose_playable(playable)
			else:
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

	if hit_object is PackingNote:
		if !playable.is_judged():
			playable.perform_action(PlayableObject.ActionType.PRESSED)

func create_playable(hit_object: HitObject) -> PlayableObject:
	var playable: PlayableObject = super.create_playable(hit_object)
	playables[hit_object.lane].append(playable)

	var drawable: Variant
	if hit_object is PackingNote:
		drawable = note_scene.instantiate()
	drawable.init(self, playable)
	drawables[playable] = drawable

	playfield_center.add_child(drawable)

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
