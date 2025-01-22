class_name ManiaPlayer extends BeatmapPlayer

@export var note_scene : PackedScene

@export var long_note_scene : PackedScene

## Time (in seconds) for a hit object to travel to the playfield center
@export var scroll_time: float

@export var playfield_center: Node

@export var playables: Dictionary

@export var create_index: int = 0

@export var dispose_index: int = 0

func initialize(beatmap: Beatmap) -> void:
	assert(beatmap is ManiaBeatmap, 'Beatmap is not mania beatmap')
	
	super.initialize(beatmap)
	
	for playable in playables.values():
		playable.free()
	playables.clear()
	create_index = 0
	dispose_index = 0
	
	# When seeked, fix relevance index
	audio_controller.seeked.connect(func(new_time: float):
		await get_tree().process_frame
		
		for playable in playables.values():
			playable.free()
		playables.clear()
		
		for i in len(beatmap.hit_objects):
			if _is_relevant(beatmap.hit_objects[i]):
				create_index = i
				break
		dispose_index = create_index
	)

func _process(delta: float) -> void:
	for i in range(create_index, beatmap.hit_objects.size()):
		var hit_object: HitObject = beatmap.hit_objects[i]
		
		if _is_relevant(hit_object):
			_create_playable(hit_object)
			create_index = i + 1
		else:
			if hit_object.time < audio_controller.time:
				create_index = i + 1
			else:
				break
	
	var step_index: bool = true
	for i in range(dispose_index, create_index):
		var hit_object: HitObject = beatmap.hit_objects[i]
		
		if _is_relevant(hit_object):
			step_index = false
		else:
			_dispose_playable(hit_object)
			if step_index:
				dispose_index = i + 1

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
	if playables.has(hit_object):
		playables[hit_object].free()
		playables.erase(hit_object)

func _start_time(hit_object: HitObject) -> float:
	return hit_object.time

func _end_time(hit_object: HitObject) -> float:
	if hit_object is ManiaLongNote:
		var long_note := hit_object as ManiaLongNote
		return long_note.time + long_note.duration
	return hit_object.time

func _is_relevant(hit_object: HitObject) -> bool:
	var early_relevance_time = scroll_time
	var late_relevance_time = scroll_time / 2
	return _start_time(hit_object) - early_relevance_time <= audio_controller.time and \
			 _end_time(hit_object) + late_relevance_time >= audio_controller.time
