class_name HitWindow extends Resource

@export var result : HitResult.Enum

@export var range : float

func _init(result : HitResult.Enum = HitResult.Enum.None, range : float = 0):
	self.result = result
	self.range = range
