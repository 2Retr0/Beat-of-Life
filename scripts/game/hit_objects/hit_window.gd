class_name HitWindow extends Resource

@export var result: HitResult.Enum

@export var extent: float

func _init(result: HitResult.Enum = HitResult.Enum.None, extent: float = 0) -> void:
	self.result = result
	self.extent = extent
