class_name ManiaLongNote extends HitObject

@export var lane: int

@export var duration: float

func _init(time: float = 0, lane: int = 0, duration: float = 0) -> void:
	super(time)
	self.lane = lane
	self.duration = duration
