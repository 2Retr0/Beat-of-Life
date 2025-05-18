# Represents a particular time in the song that coincides with a beat
class_name Beat extends Resource

# Time that the beat occurs at with reference to the start of the audio file
@export var time: float

# The timing point at which the index begins
@export var timing_point: TimingPoint

# Index of the beat with reference to the timing point
# An index of zero represents the same time as that of the timing point
@export var index: int

func _init(timing_point: TimingPoint, index: int) -> void:
	self.time = timing_point.time + timing_point.beat_length * index
	self.timing_point = timing_point
	self.index = index

func get_next() -> Beat:
	return Beat.new(timing_point, index + 1)
