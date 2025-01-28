class_name ManiaNotePlayable extends HitObjectPlayable

@export var player: ManiaPlayer

func _ready() -> void:
	position = _get_position(player.audio_controller.time)
	modulate = Color.WHITE

func _process(delta: float) -> void:
	var time := player.audio_controller.time
	position.y = _get_position(time).y

	if time > hit_object.time and result == HitResult.Enum.None and hit_object.get_result(time) == HitResult.Enum.Miss:
		result = HitResult.Enum.Miss

func _on_perform_action(previous_value : HitObjectPlayable.ActionType, value : HitObjectPlayable.ActionType) -> void:
	match value:
		HitObjectPlayable.ActionType.PRESSED:
			result = hit_object.get_result(player.audio_controller.time)
			queue_free()
		_: pass

func _on_set_result(value: HitResult.Enum) -> void:
	match value:
		#HitResult.Enum.None:
			#modulate = Color.WHITE
		HitResult.Enum.Miss:
			actionable = false
			#modulate = Color.WHITE
			modulate.a = 0.25
		#HitResult.Enum.Good:
			#modulate = Color.YELLOW
		#HitResult.Enum.Perfect:
			#modulate = Color.GREEN_YELLOW

func _get_position(time : float) -> Vector2:
	# IMPLEMENTAITON NOTE: Returning a Vector2 allows more dynamic properties such as moving the lane
	#                      during gameplay.
	return Vector2(
		150 * (hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5),
		(time - hit_object.time) * player.playfield_center.position.y / player.scroll_time)
