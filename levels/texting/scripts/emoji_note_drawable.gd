class_name EmojiNoteDrawable extends Node3D

@export var player: TextingPlayer

@export var playable: EmojiNotePlayable

@onready var sprite: Sprite3D = $Sprite3D

func init(player: TextingPlayer, playable: EmojiNotePlayable):
	self.player = player
	self.playable = playable

func _process(delta: float) -> void:
	if playable.hit_object.lane < 4:
		if player.audio_controller.time >= playable.hit_object.time:
			sprite.modulate.a = 1
		else:
			sprite.modulate.a = 0
	else:
		if playable.is_judged():
			sprite.modulate.a = 1
		else:
			sprite.modulate.a = 0.5

func set_frame(frame: int) -> void:
	sprite.frame = min(frame % 4, sprite.hframes - 1)

func dispose() -> void:
	if player != null:
		player.dispose_playable(playable)
