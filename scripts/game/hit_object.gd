# Represents a single object in a beatmap
class_name HitObject extends Resource

@export var time: float :
	get:
		return time + SettingsManager.settings.audio_offset

static var default_hit_windows: HitWindows = HitWindows.new([
	HitWindow.new(HitResult.Enum.Perfect, 0.0625),
	HitWindow.new(HitResult.Enum.Good, 0.125),
	HitWindow.new(HitResult.Enum.Miss, 0.2)
])

func _init(time: float) -> void:
	self.time = time

func get_playable_time() -> PlayableTime:
	return PlayableTime.new(self)

func get_hit_windows() -> HitWindows:
	return default_hit_windows

func get_result(time: float) -> HitResult.Enum:
	return get_hit_windows().get_result(time - self.time)

func create_playable(player: BeatmapPlayer) -> PlayableObject:
	return null
