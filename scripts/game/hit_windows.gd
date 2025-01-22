class_name HitWindows extends Resource

@export var hit_windows: Array[HitWindow]

func _init(hit_windows: Array[HitWindow] = []) -> void:
	self.hit_windows = hit_windows

func get_result(delta: float) -> HitResult.Enum:
	var result = HitResult.Enum.None
	var least_extent = INF
	for hit_window in hit_windows:
		if hit_window.extent < least_extent and hit_window.extent >= abs(delta):
			result = hit_window.result
			least_extent = hit_window.extent
	return result
