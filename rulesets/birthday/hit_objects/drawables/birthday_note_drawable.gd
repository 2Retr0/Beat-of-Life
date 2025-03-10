class_name BirthdayNoteDrawable extends Control

@export var player: ManiaPlayer # !!! CHANGE TO BIRTHDAY PLAYER WHEN CREATED

@export var playable: BirthdayNotePlayable

@onready var flame_sprite: AnimatedSprite2D = $FlameSprite

func init(player: ManiaPlayer, playable: BirthdayNotePlayable):
	self.player = player
	self.playable = playable
	
func _ready() -> void:
	position = _get_position()
	flame_sprite.visible = false
	playable.result_set.connect(_on_set_result)
	
func _get_position() -> Vector2:
	return Vector2(
		100 * (playable.hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5), -50 #or wherever the candle will be
	)
	
func _on_set_result(judgment: Judgment) -> void:
	match judgment.result:
		HitResult.Enum.Miss:
			flame_sprite.modulate.a = 0.25
		_:
			player.dispose_playable(playable)
