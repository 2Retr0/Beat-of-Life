class_name PackingNote extends HitObject

@export var lane: int

static var packing_hit_windows: HitWindows = HitWindows.new([
	HitWindow.new(HitResult.Enum.Perfect, 0.075)
])

func _init(time: float = 0, lane: int = 0) -> void:
	super(time)
	self.lane = lane

func get_start_time() -> float:
	return self.time

func get_end_time() -> float:
	return self.time

func create_playable(player: BeatmapPlayer) -> PlayableObject:
	return PackingNotePlayable.new(player, self)

func get_hit_windows() -> HitWindows:
	return packing_hit_windows
