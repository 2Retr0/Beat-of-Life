class_name ManiaLongNotePlayable extends Control

@export var player: ManiaPlayer

@export var state: HitObjectState

@onready var body := $Body

func _ready() -> void:
	position = _get_position(player.audio_controller.time)
	modulate = Color.WHITE

	var scale_current : float = body.size.y
	var scale_modifier : float = state.hit_object.duration * player.playfield_center.position.y / player.scroll_time
	body.position.y = -(scale_modifier + scale_current*0.5)
	body.size.y = scale_modifier + scale_current
	
	state.result_changed.connect(_on_set_result)

func _process(delta: float) -> void:
	var time := player.audio_controller.time
	position.y = _get_position(time).y

func _get_position(time : float) -> Vector2:
	# MOTIVATION: Returning a Vector2 allows more dynamic properties such as moving the lane during gameplay.
	return Vector2(
		150 * (state.hit_object.lane - player.beatmap.lane_count / 2.0 + 0.5),
		(time - state.hit_object.time) * player.playfield_center.position.y / player.scroll_time)

func _on_set_result(value: HitResult.Enum) -> void:
	match value:
		HitResult.Enum.Miss:
			body.material.set_shader_parameter('cutoff_strength', 0.0)
			modulate.a = 0.25
		_:
			body.material.set_shader_parameter('cutoff_strength', 1.0)
