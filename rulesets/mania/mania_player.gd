class_name ManiaRuleset extends Ruleset

@export var note_scene : PackedScene
@export var long_note_scene : PackedScene

@export var scroll_speed: float

@export var playfield_center: Node

var playables: Dictionary
var relevance_index := 0

func play() -> void:
	pass
	#relevance_index = 0

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
	const relevance_leniency = 2
	return _start_time(hit_object) <= current_time + relevance_leniency and _end_time(hit_object) >= current_time - relevance_leniency
