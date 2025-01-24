class_name ManiaPlayer extends BeatmapPlayer

@export var note_scene : PackedScene

@export var long_note_scene : PackedScene

## Time (in seconds) for a hit object to travel to the playfield center
@export var scroll_time: float

@export var playfield_center: Node

@export var playables: Dictionary

@export var create_index: int = 0

@export var dispose_index: int = 0

@export var input_maps: Dictionary = {
	3: [KEY_F, KEY_SPACE, KEY_J],
	4: [KEY_D, KEY_F, KEY_J, KEY_K],
	5: [KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K],
	6: [KEY_S, KEY_D, KEY_F, KEY_J, KEY_K, KEY_L],
	7: [KEY_S, KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K, KEY_L],
	8: [KEY_A, KEY_S, KEY_D, KEY_F, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON],
	9: [KEY_A, KEY_S, KEY_D, KEY_F, KEY_SPACE, KEY_J, KEY_K, KEY_L, KEY_SEMICOLON],
}

# Hit objects currently capturing input from each lane/key
@export var capturing_objects: Array[HitObject]

# List of hit objects capable of capturing each lane/key
@export var lane_objects: Array[Array]

# Indices of first hit objects able to capture each lane/key
@export var lane_search_indices: Array[int]

# Hit results of all hit objects
@export var hit_results: Array[HitResult.Enum]

@onready var capture_dummy: HitObject = HitObject.new(-1)

@export var results: int

@export var cumulative_accuracy: float

@export var accuracy: float

@export var score: int

@export var combo: int

@export var auto: bool

@export var auto_index: int

func initialize(beatmap: Beatmap) -> void:
	assert(beatmap is ManiaBeatmap, 'Beatmap is not mania beatmap')
	
	super.initialize(beatmap)
	
	for playable in playables.values():
		playable.free()
	playables.clear()
	create_index = 0
	dispose_index = 0
	
	capturing_objects.clear()
	lane_objects.clear()
	lane_search_indices.clear()
	hit_results.clear()
	
	var lane_count = (beatmap as ManiaBeatmap).lane_count
	for i in range(lane_count):
		capturing_objects.append(null)
		lane_objects.append([])
		lane_search_indices.append(0)
	
	for i in range(len(beatmap.hit_objects)):
		hit_results.append(HitResult.Enum.None)
	
	for i in range(len(beatmap.hit_objects)):
		var hit_object: HitObject = beatmap.hit_objects[i]
		if hit_object is ManiaNote:
			var lane: int = (hit_object as ManiaNote).lane
			lane_objects[lane].append(i)
		elif hit_object is ManiaLongNote:
			var lane: int = (hit_object as ManiaLongNote).lane
			lane_objects[lane].append(i)
	
	results = 0
	cumulative_accuracy = 0
	accuracy = 1
	score = 0
	combo = 0
	
	auto_index = 0
	
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
	
	var mania_beatmap: ManiaBeatmap = beatmap as ManiaBeatmap
	var input_map = input_maps[mania_beatmap.lane_count]
	
	var audio_time = audio_controller.time
	for i in range(len(lane_search_indices)):
		var current_list = lane_objects[i]
		var current_index = lane_search_indices[i]
		while current_index < len(current_list):
			var master_index = current_list[current_index]
			var current_object: HitObject = beatmap.hit_objects[master_index]
			var object_time: float = current_object.time
			if object_time < audio_time and not current_object.is_capturable(audio_time):
				_record_result(master_index, HitResult.Enum.Miss)
				current_index += 1
			else:
				break
		lane_search_indices[i] = current_index
	
	for i in range(len(input_map)):
		var is_pressed = Input.is_key_pressed(input_map[i])
		var is_captured = capturing_objects[i] != null
		
		var current_list = lane_objects[i]
		var current_index = lane_search_indices[i]
		
		if is_pressed and not is_captured:
			if current_index < len(current_list):
				var master_index = current_list[current_index]
				var current_object: HitObject = beatmap.hit_objects[master_index]
				if current_object.is_capturable(audio_time):
					capturing_objects[i] = current_object
					_record_result(master_index, current_object.get_result(audio_time))
					lane_search_indices[i] = current_index + 1
				else:
					capturing_objects[i] = capture_dummy
		elif not is_pressed and is_captured:
			capturing_objects[i] = null
	
	if auto:
		for i in range(auto_index, len(beatmap.hit_objects)):
			if beatmap.hit_objects[i].time <= audio_controller.time:
				_record_result(i, HitResult.Enum.Perfect)
				auto_index += 1
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

func _record_result(index: int, result: HitResult.Enum):
	if hit_results[index] == HitResult.Enum.None and result != HitResult.Enum.None:
		hit_results[index] = result
		
		var hit_object: HitObject = beatmap.hit_objects[index]
		if playables.has(hit_object):
			playables[hit_object].update_result(result)
		
		results += 1
		
		cumulative_accuracy += HitResult.get_accuracy(result)
		accuracy = cumulative_accuracy / results
		
		score += HitResult.get_score(result) * (1 + combo / 100.0)
		combo = HitResult.get_combo(result, combo)
