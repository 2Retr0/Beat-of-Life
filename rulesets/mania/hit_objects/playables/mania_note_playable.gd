class_name ManiaNotePlayable extends Control

@export var player: ManiaPlayer

@export var note: ManiaNote

func initialize(player: ManiaPlayer, note: ManiaNote) -> void:
	self.player = player
	self.note = note

	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 100 * (note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.current_time - note.time) * player.scroll_speed

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.current_time - note.time) * player.scroll_speed
