class_name ManiaNote extends HitObject

@export var lane: int

func _init(time: float = 0, lane: int = 0) -> void:
	super(time)
	self.lane = lane

func get_start_time() -> float:
	return self.time

func get_end_time() -> float:
	return self.time
