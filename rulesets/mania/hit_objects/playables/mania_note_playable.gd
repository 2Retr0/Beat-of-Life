class_name ManiaNotePlayable extends Control

@export var player: ManiaPlayer

@export var note: ManiaNote

func _ready() -> void:
	var beatmap := player.beatmap as ManiaBeatmap
	position.x = 150 * (note.lane - beatmap.lane_count / 2.0 + 0.5)
	position.y = (player.audio_controller.time - note.time) * player.playfield_center.position.y / player.scroll_time

	modulate = Color.WHITE

func _process(delta: float) -> void:
	position.y = (player.audio_controller.time - note.time) * player.playfield_center.position.y / player.scroll_time

func update_result(hit_result: HitResult.Enum) -> void:
	if hit_result == HitResult.Enum.None:
		modulate = Color.WHITE
	elif hit_result == HitResult.Enum.Miss:
		modulate = Color.RED
	elif hit_result == HitResult.Enum.Good:
		modulate = Color.YELLOW
	elif hit_result == HitResult.Enum.Perfect:
		modulate = Color.GREEN_YELLOW
