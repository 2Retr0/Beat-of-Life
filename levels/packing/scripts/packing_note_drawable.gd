class_name PackingNoteDrawable extends Node3D

@export var player: PackingPlayer

@export var playable: PackingNotePlayable

@export var sprite: Sprite3D

@export var textures: Array[Texture]

@export var time_alive: float

func init(player: PackingPlayer, playable: PackingNotePlayable):
	self.player = player
	self.playable = playable
	sprite.texture = textures[playable.hit_object.lane]
	time_alive = 0

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
	
	time_alive += delta
	rotation.z = time_alive * (5 + player.audio_controller.time * 0.5)
	scale = Vector3.ONE * (1 - 1 / (time_alive + 1))

func _get_position(time : float) -> Vector3:
	return Vector3(
		0.65 * (playable.hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5),
		(playable.hit_object.time - time) * 3 / player.scroll_time,
		0
	)

func _on_set_result(judgment: Judgment) -> void:
	player.dispose_playable(playable)
