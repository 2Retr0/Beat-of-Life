class_name PlayableTime extends Resource

@export var hit_object: HitObject

@export var start_time: float

@export var end_time: float

static var start_time_offset = 5

static var end_time_offset = 2

func _init(hit_object: HitObject, start_time: float = hit_object.time - start_time_offset, end_time: float = hit_object.time + end_time_offset):
	self.hit_object = hit_object
	self.start_time = start_time
	self.end_time = end_time
