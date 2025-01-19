class_name TimingPoint extends Resource

@export var time: float

@export var bpm: float
@export var beat_length : float

@export var meter: int

func _init(time: float, bpm: float, meter: int) -> void:
	self.time = time
	self.bpm = bpm
	self.beat_length = 60.0/bpm
	self.meter = meter
