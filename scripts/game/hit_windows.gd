# A series of hit windows that determines the result based on the player's hit error
class_name HitWindows extends Resource

@export var hit_windows: Array[HitWindow]

func _init(hit_windows: Array[HitWindow] = []) -> void:
	self.hit_windows = hit_windows

func get_max_extent() -> float:
	return hit_windows[len(hit_windows) - 1].extent

func get_result(delta: float) -> HitResult.Enum:
	for hit_window in hit_windows:
		if abs(delta) >= hit_window.extent: continue
		return hit_window.result
	return HitResult.Enum.Miss
