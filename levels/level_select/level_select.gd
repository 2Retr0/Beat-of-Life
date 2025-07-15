@tool
extends Node3D

const LOADING_SCREEN_COLUMNS := preload('res://ui/loading/columns/loading_screen_columns.tscn')
const DURATION := 2.0
const SEGMENT := preload('./film_reel_segment.tscn')
const SEGMENT_SIZE := 0.707

## FIXME: This is not a great way to store this information
@export var levels: Array[GameLevel]
@export var previews: Array[Texture2D]
@export var beatmap_indices : Array[int]

var arrow_alpha = 0.0
var done_animating := false
var is_animating := false :
	set(value):
		if value == is_animating: return

		is_animating = value

		if not is_animating and is_node_ready():
			# Wait a bit to let motion blur settle
			await get_tree().create_timer(0.15).timeout
			if not $LevelSelectButton.is_connected(&'input_event', _on_level_select_button_input_event):
				$LevelSelectButton.connect(&'input_event', _on_level_select_button_input_event)
			var tween := create_tween().set_parallel(true)
			tween.tween_property(self, ^'arrow_alpha', 0.5, 1.0).from_current().set_ease(Tween.EASE_OUT).set_delay(0.5)
			# --- DISBLE MOTION BLUR ---
			for effect in compositor.compositor_effects: effect.enabled = false
			$GPUParticles3D.emitting = true

@onready var compositor: Compositor = $WorldEnvironment.compositor
@onready var segments: Node3D = $FilmReelSegments

## The offset of the film reel segments
var offset_y := 0.0
var offset_y_absolute := 8.0*SEGMENT_SIZE
var level_index := 0 :
	set(value):
		level_index = clampi(value, 0, len(levels) - 1)

var animate_tween: Tween

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if not done_animating:
			_skip_animation()
			await get_tree().create_timer(0.15).timeout
			# FIXME: There is a terrible input handling between level select mouse button and clicking to skip animation. And i've only made it worse...
			if not $LevelSelectButton.is_connected(&'input_event', _on_level_select_button_input_event):
				$LevelSelectButton.connect(&'input_event', _on_level_select_button_input_event)
		elif event.is_action_pressed(&'ui_down') or event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if level_index != len(levels) - 1: $AudioStreamPlayer.play()
			level_index += 1
		elif event.is_action_pressed(&'ui_up')  or event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if level_index != 0: $AudioStreamPlayer.play()
			level_index -= 1
		elif event.is_action_pressed(&'ui_accept'):
			_load_currently_selected_level()

func _ready() -> void:
	## Initialize segments
	for i in range(4):
		var child := SEGMENT.instantiate()
		child.position.y = (1 - i)*SEGMENT_SIZE
		segments.add_child(child)

	# I'm tired boss...
	$UI/ArrowDown.self_modulate.a = 0.0
	$UI/ArrowUp.self_modulate.a = 0.0

	await get_tree().create_timer(0.35).timeout
	animate()
	
var previous_index := 0

func _process(delta: float) -> void:
	# Logic for repositioning segments to match target level index.
	offset_y = lerpf(offset_y, level_index*SEGMENT_SIZE, delta*10.0)
	segments.global_position.y = fposmod(offset_y, SEGMENT_SIZE) + offset_y_absolute
	for segment in segments.get_children():
		var j := -roundi((segment.global_position.y - offset_y) / SEGMENT_SIZE)
		segment.preview = previews[j] if j >= 0 and j < len(previews) else null

	$UI/ArrowUp.self_modulate.a = arrow_alpha*(1.0 if level_index != 0 else 0.25)
	$UI/ArrowDown.self_modulate.a = arrow_alpha*(1.0 if level_index != len(levels) - 1 else 0.25)

func _physics_process(delta: float) -> void:
	if previous_index != int(offset_y/SEGMENT_SIZE):
		previous_index = int(offset_y/SEGMENT_SIZE)
		$AudioStreamPlayer2.play()
		$AudioStreamPlayer2.seek(0.05)

func animate() -> void:
	if is_animating or not is_node_ready(): return
	is_animating = true

	# NOTE: Particles with transparency mess with motion blur!
	$GPUParticles3D.emitting = false

	## --- ENABLE MOTION BLUR ---
	for effect in compositor.compositor_effects: effect.enabled = true

	## --- FILM REEL MOTION TWEENING ---
	animate_tween = create_tween()
	animate_tween.parallel().tween_property(self, ^'offset_y_absolute', 0.0, 0.4).from(SEGMENT_SIZE*8.0)
	animate_tween.parallel().tween_property(self, ^'offset_y', 0.0, DURATION).from(SEGMENT_SIZE*450.0) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	animate_tween.parallel().tween_method(func(t: float):
			segments.rotation.y = -sin(3.0*PI*DURATION*t) * PI/30.0, 0.0, 1.0, DURATION + 2.0) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_delay(0.5) # Don't wobble until a little bit later!
	get_tree().create_timer(DURATION*0.8).timeout.connect(func():
		done_animating = true
		is_animating = false)

func _skip_animation() -> void:
	if not is_animating: return
	done_animating = true
	if animate_tween: animate_tween.kill()
	offset_y_absolute = 0.0
	is_animating = false

	# Fake ending
	animate_tween = create_tween()
	animate_tween.parallel().tween_property(self, ^'offset_y', 0.0, 0.5).from(SEGMENT_SIZE*2.0) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_EXPO)
	animate_tween.parallel().tween_method(func(t: float):
			segments.rotation.y = cos(3.0/2.0*PI*t) * PI/30.0, 0.0, 1.0, 2.0) \
		.set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_BACK)

func _load_currently_selected_level() -> void:
	var level := levels[level_index]
	var beatmap := level.beatmaps[beatmap_indices[level_index]].get_beatmap()
	SceneManager.load_scene_async(level.player_scene_path, LOADING_SCREEN_COLUMNS.instantiate(), func(tree: SceneTree):
		for child in tree.root.get_children():
			if child is BeatmapPlayer:
				child.initialize(beatmap)
	)

func _on_level_select_button_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if not done_animating: return
	if event.is_pressed and not event.is_released() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		set_process_input(false)
		_load_currently_selected_level()


func _on_down_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_released() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if level_index != len(levels) - 1: $AudioStreamPlayer.play()
		level_index += 1


func _on_up_button_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_released() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if level_index != 0: $AudioStreamPlayer.play()
		level_index -= 1
