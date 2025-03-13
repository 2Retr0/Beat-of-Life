class_name BirthdayNoteDrawable extends Node3D

@export var player: BirthdayPlayer

@export var playable: BirthdayNotePlayable

@onready var flame_sprite: AnimatedSprite3D = $FlameSprite

func init(player: BirthdayPlayer, playable: BirthdayNotePlayable):
	self.player = player
	self.playable = playable
	
func _ready() -> void:
	position = _get_position()
	playable.result_set.connect(_on_set_result)

func _process(delta: float) -> void:
	if flame_sprite.modulate.a == 0 and player.get_time() >= playable.hit_object.get_show_time(player):
		flame_sprite.modulate.a = 1
		flame_sprite.play()
	
func _get_position() -> Vector3:
	var lane = playable.hit_object.lane
	if lane == 0:
		return Vector3(-0.5, 1.323, 0)
	if lane == 1:
		return Vector3(-0.151, 1.323, 0)
	if lane == 2:
		return Vector3(0.132, 1.323, 0)
	if lane == 3:
		return Vector3(0.424, 1.323, 0)
	return Vector3(0, 0, 0)
	
func _on_set_result(judgment: Judgment) -> void:
	match judgment.result:
		HitResult.Enum.Miss:
			flame_sprite.modulate.a = 0.25
		_:
			player.dispose_playable(playable)
