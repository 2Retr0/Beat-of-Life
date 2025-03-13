@tool
extends Node3D

const DURATION := 2.0

## For editor only
@export var run_animation := false :
	get: return is_animating
	set(value):
		if value: animate()

var is_animating := false :
	set(value):
		if value == is_animating: return
		
		is_animating = value
		
		if not is_animating and is_node_ready():
			# Wait a bit to let motion blur settle
			await get_tree().create_timer(0.15).timeout
			# --- DISBLE MOTION BLUR ---
			for effect in compositor.compositor_effects: effect.enabled = false
			$GPUParticles3D.emitting = true

@onready var compositor: Compositor = $WorldEnvironment.compositor
@onready var track: Path3D = $Path3D

func animate() -> void:
	if is_animating or not is_node_ready(): return
	is_animating = true
	
	# NOTE: Particles with transparency mess with motion blur!
	$GPUParticles3D.emitting = false

	# --- ENABLE MOTION BLUR ---
	for effect in compositor.compositor_effects: effect.enabled = true

	# --- FILM REEL MOTION TWEENING ---
	var tween: Tween = create_tween()
	track.global_position.z = -1
	tween.parallel().tween_property(track, ^'global_position:y', -310, DURATION).from(0.0) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	tween.parallel().tween_method(func(t: float):
			track.rotation.y = -sin(3.0*PI*DURATION*t)*PI/40.0 - PI*0.5, 0.0, 1.0, DURATION + 2.0) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_delay(0.5) # Don't wobble until a little bit later!
	tween.tween_callback(func(): is_animating = false)
