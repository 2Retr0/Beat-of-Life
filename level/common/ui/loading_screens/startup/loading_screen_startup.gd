@tool
extends LoadingScreen

const DELAY_FRACTION := 0.42
const G := 9.81
const V0 := sqrt(2.0*G) # Initial velocity (s.t. max bounce height = 1)
const H := G/(2.0*V0)

## Restitution
@export_range(0.0, 1.0) var bounciness := 0.5
@export var bounce_height := 40.0

@onready var viewport := get_viewport()
@onready var notes := $Control/HBoxContainer

var time := 0.0

func _animate() -> void:
	match stage:
		Stage.LOAD:
			for note in notes.get_children(): note.position.y = 0

			material.set_shader_parameter(&'progress', 0)
			$Control/HBoxContainer.position.y = -20.0
		Stage.UNLOAD:
			var tween := create_tween()
			tween.chain().tween_property($Control/HBoxContainer, ^'position:y', 100.0, 0.6) \
				.from_current() \
				.set_trans(Tween.TRANS_BACK)

			tween.chain().tween_method(func(t: float): material.set_shader_parameter(&'progress', t), 0.0, 1.0, 0.3) \
				.set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_SINE)

	super._animate()

func _process(delta: float) -> void:
	if stage == Stage.UNLOAD or has_stage_finished: return

	var a := (bounciness - 1.0)*H
	var b := -0.99/(a*(1.0  - DELAY_FRACTION*2.0))

	time += delta
	var num_children := notes.get_child_count()
	for i in num_children:
		var note := notes.get_child(i)
		# Make time loop from 0..duration
		var t := time/duration
		t = clampf(((t - floorf(t))*(1.0 - DELAY_FRACTION)*1.35 - DELAY_FRACTION/num_children*i)*b, 0.0, -1.0/a)

		# Analytical function for inelastic bounce
		var n := floorf(log(a*t + 1.0) / log(bounciness))
		var r_n := bounciness**n
		var t_n := t - (r_n - 1.0)/a
		note.position.y = -(r_n - H*t_n)*V0*t_n * bounce_height
