class_name Beat extends Resource

@export var time: float

@export var timing_point: TimingPoint

@export var index: int

func _init(timing_point: TimingPoint, index: int) -> void:
	self.time = timing_point.time + timing_point.beat_length * index
	self.timing_point = timing_point
	self.index = index

func get_next() -> Beat:
	return Beat.new(timing_point, index + 1)
