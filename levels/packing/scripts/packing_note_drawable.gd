class_name PackingNoteDrawable extends Node3D

@export var player: PackingPlayer

@export var playable: PackingNotePlayable

@export var sprite_lane1 : Sprite3D
@export var sprite_lane2 : Sprite3D
@export var sprite_lane3 : Sprite3D
@export var sprite_lane4 : Sprite3D
var sprites : Array[Sprite3D] = [
	sprite_lane1, sprite_lane2, sprite_lane3, sprite_lane4
]

func init(player: PackingPlayer, playable: PackingNotePlayable):
	self.player = player
	self.playable = playable
	self._sprite = sprites[playable.hit_object.lane]

func _ready() -> void:
	if not player or not playable:
		return
	position = _get_position(player.audio_controller.time)
	#self._sprite.modulate.a = 1    
	playable.result_set.connect(_on_set_result)

func _process(delta: float) -> void:
	if not player or not playable:
		return
	var time := player.audio_controller.time
	position.y = _get_position(time).y
	if self._sprite.modulate.a == 0 and player.get_time() >= playable.hit_object.get_show_time(player):
		self._sprite.modulate.a = 1
		#self._sprite.play()

func _get_position(time : float) -> Vector3:
	return Vector3(
		0.65 * (playable.hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5),
		(playable.hit_object.time - time) * 3 / player.scroll_time,
		0
	)

func _on_set_result(judgment: Judgment) -> void:
	player.dispose_playable(playable)
