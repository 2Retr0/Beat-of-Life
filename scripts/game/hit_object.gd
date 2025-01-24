class_name HitObject extends Resource

@export var time: float :
	get:
		return time + SettingsManager.settings.audio_offset

static var default_hit_windows: HitWindows = HitWindows.new([
	HitWindow.new(HitResult.Enum.Perfect, 0.05),
	HitWindow.new(HitResult.Enum.Good, 0.1),
	HitWindow.new(HitResult.Enum.Miss, 0.15)
])

func _init(time: float = 0) -> void:
	self.time = time

func get_default_hit_windows() -> HitWindows:
	return default_hit_windows
	

func is_capturable(time: float) -> bool:
	return abs(time - self.time) <= get_default_hit_windows().get_max_extent()

func get_result(time: float) -> HitResult.Enum:
	return get_default_hit_windows().get_result(time - self.time)
