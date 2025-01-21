class_name ManiaRuleset extends Ruleset

@export var note_scene : PackedScene
@export var long_note_scene : PackedScene

## Time (in seconds) for a hit object to travel to the playfield center
@export var scroll_speed: float

@export var playfield_center: Node

@export var audio_controller : BeatmapAudioController

var playables: Dictionary
var relevance_index := 0

func play() -> void:
	# When seeked, fix relevance index
	audio_controller.seeked.connect(func(delta : float):
		await get_tree().process_frame

		for playable in playables.values():
			playable.free()
		playables.clear()

		relevance_index = 0
		#if audio_controller.time < 3.0:
			#return
#
		for i in len(beatmap.hit_objects):
			if _is_relevant(beatmap.hit_objects[i]):
				relevance_index = i
				break
		#for i in range(relevance_index, len(beatmap.hit_objects)):
			#var hit_object := beatmap.hit_objects[i]
			#if not playables.has(hit_object) and _is_relevant(hit_object):
				#_create_playable(hit_object)
			#else: break
		)

func _process(delta: float) -> void:
	#print(relevance_index, ' ', audio_controller.time)
	for i in range(relevance_index, beatmap.hit_objects.size()):
		var hit_object := beatmap.hit_objects[i]
		var is_relevant := _is_relevant(hit_object)
		var is_visible := playables.has(hit_object)

		if is_visible and not is_relevant:
			_dispose_playable(hit_object)
			relevance_index = i + 1
		elif not is_visible:
			if is_relevant:
				_create_playable(hit_object)
			else:
				break

func _create_playable(hit_object: HitObject) -> void:
	var playable : Variant
	if hit_object is ManiaNote:
		playable = note_scene.instantiate()
		playable.player = self
		playable.note = hit_object
	elif hit_object is ManiaLongNote:
		playable = long_note_scene.instantiate()
		playable.player = self
		playable.long_note = hit_object

	playfield_center.add_child(playable)
	playables[hit_object] = playable

func _dispose_playable(hit_object: HitObject) -> void:
	playables[hit_object].queue_free()
	playables.erase(hit_object)

func _start_time(hit_object: HitObject) -> float:
	return hit_object.time

func _end_time(hit_object: HitObject) -> float:
	if hit_object is ManiaLongNote:
		var long_note := hit_object as ManiaLongNote
		return long_note.time + long_note.duration
	return hit_object.time

func _is_relevant(hit_object: HitObject) -> bool:
	var early_relevance_time = scroll_speed
	var late_relevance_time = 0.5
	return _start_time(hit_object) - early_relevance_time <= audio_controller.time and \
			 _end_time(hit_object) + late_relevance_time >= audio_controller.time
