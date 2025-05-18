@tool
extends LoadingScreen

@export_color_no_alpha var color := Color(0.8, 0.6, 0.65) :
	set(value):
		color = value
		modulate = value

@onready var viewport := get_viewport()

func _animate() -> void:
	if not is_node_ready(): return
	visible = true

	var tween := create_tween()
	var start_t := 0.0 if stage == Stage.LOAD else 1.0
	tween.tween_method(func(t: float):
			var s := viewport.get_visible_rect().size
			material.set_shader_parameter(&'viewport_aspect_ratio', s.y/s.x)
			material.set_shader_parameter(&'progress', t), start_t, start_t + 1.0, duration) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_SINE)

	for i in range(8):
		var t := i / 8.0
		var pitch_modifier := t*t if stage == Stage.LOAD else 1.0-t*t
		get_tree().create_timer(t*t * duration*0.5).timeout.connect(func():
			$AudioStreamPlayer.pitch_scale = 1.0 + pitch_modifier*2
			$AudioStreamPlayer.volume_db = lerpf(5.0, 8.0, pitch_modifier)
			$AudioStreamPlayer.play())

	super._animate()


func _on_stage_finished() -> void:
	if stage == Stage.UNLOAD: visible = false
