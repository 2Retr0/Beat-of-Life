class_name HitWindows extends Resource

@export var hit_windows : Array[HitWindow]

func _init(hit_windows : Array[HitWindow] = []):
	self.hit_windows = hit_windows

func get_result(delta : float) -> HitResult.Enum:
	var result = HitResult.Enum.None
	var least_range = INF
	for hit_window in hit_windows:
		if hit_window.range < least_range and hit_window.range >= abs(delta):
			result = hit_window.result
			least_range = hit_window.range
	return result
