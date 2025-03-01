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
