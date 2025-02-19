class_name ManiaLongNote extends HitObject

@export var lane: int

@export var duration: float

func _init(time: float = 0, lane: int = 0, duration: float = 0) -> void:
	super(time)
	self.lane = lane
	self.duration = duration

func get_start_time() -> float:
	return self.time

func get_end_time() -> float:
	return self.time + self.duration

func get_release_result(time: float) -> HitResult.Enum:
	return get_hit_windows().get_result(time - get_end_time())

func create_state() -> HitObjectState:
	return ManiaLongNoteState.new(self)
