class_name Judgment extends Resource

@export var hit_object: HitObject

@export var time: float

@export var result: HitResult.Enum

func _init(hit_object: HitObject):
	self.hit_object = hit_object
	self.time = INF
	self.result = HitResult.Enum.None

func set_result(time: float, result: HitResult.Enum):
	self.time = time
	self.result = result

func get_accuracy() -> float:
	match result:
		HitResult.Enum.Good:
			return 1.0 / 3
		HitResult.Enum.Perfect:
			return 1
		_:
			return 0

func get_score() -> int:
	match result:
		HitResult.Enum.Good:
			return 100
		HitResult.Enum.Perfect:
			return 300
		_:
			return 0

func get_combo(old_combo: int) -> int:
	match result:
		HitResult.Enum.Miss:
			return 0
		HitResult.Enum.Good:
			return old_combo + 1
		HitResult.Enum.Perfect:
			return old_combo + 1
		_:
			return old_combo
