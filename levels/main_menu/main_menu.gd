extends Node

@export_file("*.tscn") var play_scene_path
@export_file("*.tscn") var options_scene_path

const LOADING_SCREEN_COLUMNS := preload('res://ui/loading/columns/loading_screen_columns.tscn')
const LOADING_SCREEN_GRID := preload('res://ui/loading/grid/loading_screen_grid.tscn')
const LOADING_SCREEN_STARTUP := preload('res://ui/loading/startup/loading_screen_startup.tscn')
const PARALLAX_STRENGTH := 1.025

var tween: Tween
var logo_done := false

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	$Logo.animate()
	var tween = create_tween()
	tween.tween_method(func(t: float):
		$GPUParticles2D.material.set_shader_parameter(&'alpha_factor', t), 0.0, 0.075, 1.0).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	# Parallax effect
	var uv := (get_viewport().get_mouse_position() / viewport_size - Vector2.ONE*0.5).clampf(-0.5, 0.5)
	$TextureRectParallax.size = $TextureRectAnchor.size*PARALLAX_STRENGTH
	$TextureRectParallax.position = $TextureRectAnchor.position*PARALLAX_STRENGTH - $TextureRectAnchor.size*(PARALLAX_STRENGTH - 1.0)*0.5*uv

	# Change particle spawn area and amount to be proportional to screen size
	var process_material: ParticleProcessMaterial = $GPUParticles2D.process_material
	var extent := maxi(viewport_size.x, viewport_size.y)
	process_material.emission_shape_offset.x = extent
	process_material.emission_box_extents.x = extent
	$GPUParticles2D.amount = ceili(extent * 0.01666)

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if $Logo.is_animating:
			$Logo.skip_animation()
		elif logo_done:
			set_process_input(false)
			SceneManager.load_scene_async(play_scene_path, LOADING_SCREEN_GRID.instantiate())


func _on_logo_finished() -> void:
	$GPUParticles2D.emitting = true
	logo_done = true
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_method(func(t: float):
		$GPUParticles2D.material.set_shader_parameter(&'alpha_factor', t), 0.6, 0.1, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
