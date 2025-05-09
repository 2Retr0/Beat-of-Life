class_name EmojiNote extends HitObject

@export var lane: int
@export var show_offset: int = 2 #number of beats between showtime and hit

func _init(time: float = 0, lane: int = 0) -> void:
	super(time)
	self.lane = lane

func get_show_time(player: BeatmapPlayer) -> float:
	return time - show_offset * player.beatmap.get_beat_length(time)

func create_playable(player: BeatmapPlayer) -> PlayableObject:
	return EmojiNotePlayable.new(player, self)
