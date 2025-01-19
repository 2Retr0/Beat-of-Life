class_name HitObject extends Resource

@export var time: float :
	get:
		return time + SettingsManager.settings.audio_offset

func _init(time: float = 0) -> void:
	self.time = time

func get_default_hit_windows() -> HitWindows:
	return HitWindows.new([
		HitWindow.new(HitResult.Enum.Perfect, 0.03),
		HitWindow.new(HitResult.Enum.Good, 0.09),
		HitWindow.new(HitResult.Enum.Miss, 0.15)
	])
