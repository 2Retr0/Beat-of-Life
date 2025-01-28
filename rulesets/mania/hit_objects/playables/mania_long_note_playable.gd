class_name ManiaLongNotePlayable extends HitObjectPlayable

@export var player: ManiaPlayer

@onready var body := $Body

func _ready() -> void:
	position = _get_position(player.audio_controller.time)
	modulate = Color.WHITE

	var scale_current : float = body.size.y
	var scale_modifier : float = hit_object.duration * player.playfield_center.position.y / player.scroll_time
	body.position.y = -(scale_modifier + scale_current*0.5)
	body.size.y = scale_modifier + scale_current

func _process(delta: float) -> void:
	var time := player.audio_controller.time
	position.y = _get_position(time).y

	if time > hit_object.time and result == HitResult.Enum.None and hit_object.get_result(time) == HitResult.Enum.Miss:
		result = HitResult.Enum.Miss

func _on_perform_action(previous_value : HitObjectPlayable.ActionType, value : HitObjectPlayable.ActionType) -> void:
	match value:
		HitObjectPlayable.ActionType.PRESSED:
			if result == HitResult.Enum.None:
				result = hit_object.get_result(player.audio_controller.time)
		HitObjectPlayable.ActionType.RELEASED:
			if previous_value == HitObjectPlayable.ActionType.HELD or \
			   previous_value == HitObjectPlayable.ActionType.PRESSED:
				var temp_result : HitResult.Enum = hit_object.get_result_release(player.audio_controller.time)
				if temp_result == HitResult.Enum.Miss:
					# Treat misses as 'good' so combo doesn't break, but visually consider it a miss
					result = HitResult.Enum.Good
					_on_set_result(HitResult.Enum.Miss)
				else:
					result = temp_result
					queue_free()

func _on_set_result(value: HitResult.Enum) -> void:
	match value:
		#HitResult.Enum.None:
			#modulate = Color.WHITE
		HitResult.Enum.Miss:
			body.material.set_shader_parameter('cutoff_strength', 0.0)
			#modulate = Color.WHITE
			modulate.a = 0.25
			actionable = false
		_:
			body.material.set_shader_parameter('cutoff_strength', 1.0)
			#modulate = Color.LIGHT_CYAN

func is_actionable(time: float) -> bool:
	var extent := hit_object.get_hit_windows().get_max_extent()
	return actionable and time - hit_object.get_start_time() >= -extent and time - hit_object.get_end_time() <= +extent

func _get_position(time : float) -> Vector2:
	# MOTIVATION: Returning a Vector2 allows more dynamic properties such as moving the lane during gameplay.
	return Vector2(
		150 * (hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5),
		(time - hit_object.time) * player.playfield_center.position.y / player.scroll_time)
