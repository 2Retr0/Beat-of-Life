class_name PackingNoteDrawable extends Node3D

@export var player: PackingPlayer

@export var playable: PackingNotePlayable

@export var sprite: Sprite3D

@export var textures: Array[Texture]

func init(player: PackingPlayer, playable: PackingNotePlayable):
	self.player = player
	self.playable = playable
	#sprite.texture = textures[playable.hit_object.lane]

func _ready() -> void:
	if not player or not playable:
		return
	position = _get_position(player.audio_controller.time)
	sprite.modulate = Color.WHITE
	playable.result_set.connect(_on_set_result)

func _process(delta: float) -> void:
	if not player or not playable:
		return
	var time := player.audio_controller.time
	position.y = _get_position(time).y

func _get_position(time : float) -> Vector3:
	return Vector3(
		0.65 * (playable.hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5),
		(playable.hit_object.time - time) * 3 / player.scroll_time,
		0
	)

func _on_set_result(judgment: Judgment) -> void:
	player.dispose_playable(playable)
