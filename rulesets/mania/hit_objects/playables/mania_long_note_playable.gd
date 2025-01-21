class_name ManiaLongNotePlayable extends Control

@export var player: ManiaRuleset

@export var long_note: ManiaLongNote

@onready var viewport := get_viewport()
@onready var body := $Body

func _ready() -> void:
	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 100 * (long_note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.audio_controller.time - long_note.time) * player.playfield_center.position.y / player.scroll_speed

	body.position.y = -long_note.duration * player.playfield_center.position.y / player.scroll_speed
	body.size.y = long_note.duration * player.playfield_center.position.y / player.scroll_speed

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.audio_controller.time - long_note.time) * player.playfield_center.position.y / player.scroll_speed
