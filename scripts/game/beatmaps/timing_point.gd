class_name TimingPoint extends Resource

@export var time: float

@export var bpm: float

@export var meter: int

func _init(time: float = 0, bpm: float = 60, meter: int = 4) -> void:
	self.time = time
	self.bpm = bpm
	self.meter = meter
