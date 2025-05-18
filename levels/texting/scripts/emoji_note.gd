class_name EmojiNote extends HitObject

@export var lane: int

func _init(time: float = 0, lane: int = 0) -> void:
	super(time)
	self.lane = lane

func create_playable(player: BeatmapPlayer) -> PlayableObject:
	return EmojiNotePlayable.new(player, self)
