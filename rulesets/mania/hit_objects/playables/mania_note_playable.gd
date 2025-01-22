class_name ManiaNotePlayable extends Control

@export var player: ManiaPlayer

@export var note: ManiaNote

func _ready() -> void:
	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 100 * (note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.audio_controller.time - note.time) * player.playfield_center.position.y / player.scroll_time

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.audio_controller.time - note.time) * player.playfield_center.position.y / player.scroll_time
