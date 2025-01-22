class_name ManiaLongNotePlayable extends Control

@export var player: ManiaPlayer

@export var long_note: ManiaLongNote

@onready var body := $Body

func _ready() -> void:
	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 100 * (long_note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.audio_controller.time - long_note.time) * player.playfield_center.position.y / player.scroll_time

	body.position.y = -long_note.duration * player.playfield_center.position.y / player.scroll_time
	body.size.y = long_note.duration * player.playfield_center.position.y / player.scroll_time

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.audio_controller.time - long_note.time) * player.playfield_center.position.y / player.scroll_time
