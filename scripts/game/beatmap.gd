class_name Beatmap extends Resource

@export var title: StringName

@export var artist: StringName

@export var track: AudioStream

@export var difficulty_name: StringName

@export var difficulty_creator: StringName

## FIXME: assert that the hit time of all hit objects should be monotonically increasing!
##for i in range(len(beatmap.hit_objects) - 1):
##	assert(beatmap.hit_objects[i].time <= beatmap.hit_objects[i + 1].time)
@export var hit_objects: Array[HitObject]

## FIXME: assert that the start time of all timing points should be monotonically increasing!
##for i in range(len(beatmap.timing_points) - 1):
##	assert(beatmap.timing_points[i].time <= beatmap.timing_points[i + 1].time)
@export var timing_points: Array[TimingPoint]

func get_object_start() -> float:
	if len(hit_objects) == 0:
		return INF
	return hit_objects[0].time

func get_beat(time: float) -> Beat:
	var timing = get_current_timing(time)
	if timing == null:
		return null
	return Beat.new(timing, floor((time - timing.time) / timing.beat_length))

func get_timing_start() -> float:
	if len(timing_points) == 0:
		return INF
	return timing_points[0].time

func get_current_timing(time: float) -> TimingPoint:
	if time < get_timing_start():
		return null
	for i in range(len(timing_points)):
		if timing_points[i].time > time:
			return timing_points[i - 1]
	return timing_points[len(timing_points) - 1]

func get_next_timing(time: float) -> TimingPoint:
	for i in range(len(timing_points)):
		if timing_points[i].time > time:
			return timing_points[i]
	return null

func get_bpm(time: float) -> float:
	var timing = get_current_timing(time)
	return timing.bpm

func get_beat_length(time: float) -> float:
	var timing = get_current_timing(time)
	return timing.beat_length

func get_meter(time: float) -> int:
	var timing = get_current_timing(time)
	return timing.meter
