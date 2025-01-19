class_name ManiaNotePlayable extends Control

@export var player: ManiaRuleset

@export var note: ManiaNote

func _ready() -> void:
	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 100 * (note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.current_time - note.time) * player.scroll_speed

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.current_time - note.time) * player.scroll_speed
