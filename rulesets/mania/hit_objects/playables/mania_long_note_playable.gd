class_name ManiaLongNotePlayable extends Control

@export var body: ColorRect

@export var player: ManiaRuleset

@export var long_note: ManiaLongNote

func _ready() -> void:
	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 100 * (long_note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.current_time - long_note.time) * player.scroll_speed

	body.position.y = -long_note.duration * player.scroll_speed
	body.size.y = long_note.duration * player.scroll_speed

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.current_time - long_note.time) * player.scroll_speed
