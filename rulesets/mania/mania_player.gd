class_name ManiaPlayer extends BeatmapPlayer

@export_file('*.tscn') var note_scene_path: String

@export_file('*.tscn') var long_note_scene_path: String

@export var scroll_speed: float

@export var playfield_center: Node

@export var relevance_index: int

@export var playables: Dictionary

func play() -> void:
	super()

	relevance_index = 0

func _process(delta: float) -> void:
	#super(delta)
	for i in range(relevance_index, beatmap.hit_objects.size()):
		var hit_object = beatmap.hit_objects[i]
		if playables.has(hit_object) and not _is_relevant(hit_object):
			_dispose_playable(hit_object)
			relevance_index = i + 1
		elif not playables.has(hit_object):
			if _is_relevant(hit_object):
				_create_playable(hit_object)
			else:
				break

func _create_playable(hit_object: HitObject) -> void:
	if hit_object is ManiaNote:
		var note := hit_object as ManiaNote

		var scene = load(note_scene_path);
		var playable := scene.instantiate() as ManiaNotePlayable;
		playable.initialize(self, note)

		playfield_center.add_child(playable)
		playables[hit_object] = playable
	elif hit_object is ManiaLongNote:
		var long_note := hit_object as ManiaLongNote

		var scene = load(long_note_scene_path);
		var playable := scene.instantiate() as ManiaLongNotePlayable;
		playable.initialize(self, long_note)

		playfield_center.add_child(playable)
		playables[hit_object] = playable

func _dispose_playable(hit_object: HitObject) -> void:
	playables[hit_object].call_deferred('queue_free')
	playables.erase(hit_object)

func _start_time(hit_object: HitObject) -> float:
	return hit_object.time

func _end_time(hit_object: HitObject) -> float:
	if hit_object is ManiaLongNote:
		var long_note := hit_object as ManiaLongNote
		return long_note.time + long_note.duration
	return hit_object.time

func _is_relevant(hit_object: HitObject) -> bool:
	const relevance_leniency = 3
	return _start_time(hit_object) <= current_time + relevance_leniency and _end_time(hit_object) >= current_time - relevance_leniency
