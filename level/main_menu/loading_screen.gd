extends Control

const delay_fraction := 0.7

signal finished

var is_finished := false

@export_enum('Start', 'End') var transition_stage := 0 :
	set(value):
		transition_stage = value
		_animate()
@export var subdivisions := 12
@export var duration := 0.5
@export var progress_value := 0.0 :
	set(value):
		progress_value = value
		if progress_bar: progress_bar.value = value
@export_color_no_alpha var color := Color(0.8, 0.6, 0.65) :
	set(value):
		color = value
		if columns: columns.modulate = value
@export var subdivision_scene: PackedScene

@onready var viewport := get_viewport()
@onready var columns := $Columns
@onready var progress_bar := $ProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in subdivisions:
		var subdivision := subdivision_scene.instantiate()
		subdivision.visible = false
		columns.add_child(subdivision_scene.instantiate())
	get_tree().process_frame.connect(_animate, CONNECT_ONE_SHOT)

func _animate() -> void:
	if not columns: return

	for i in columns.get_child_count():
		var subdivision := columns.get_child(i)
		subdivision.visible = true
		subdivision.position.y = -viewport.get_visible_rect().size.y if transition_stage == 0 else 0

		var tween := subdivision.create_tween()
		tween.tween_method(func(t: float):
				var height := viewport.get_visible_rect().size.y
				subdivision.position.y = -height*t + (height if transition_stage == 0 else 0), 0.0, 1.0, duration*(1.0 - delay_fraction)) \
			.set_delay(float(i)/subdivisions * duration*delay_fraction) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_SINE)

	for i in range(8):
		var t := i / 8.0
		var pitch_modifier := t*t if transition_stage == 0 else 1.0-t*t
		get_tree().create_timer(t*t * duration*delay_fraction).timeout.connect(func():
			$AudioStreamPlayer.pitch_scale = 1.0 + pitch_modifier*2
			$AudioStreamPlayer.volume_db = lerpf(5.0, 8.0, pitch_modifier)
			$AudioStreamPlayer.play())

	progress_bar.modulate = Color.WHITE_SMOKE
	progress_bar.modulate.a = 0.5
	progress_bar.visible = false
	$ProgressBarVisibilityTimer.start()

	match transition_stage:
		0: progress_value = 0.0
		1: create_tween().tween_property(progress_bar, ^'modulate:a', 0.0, duration*0.5).from_current()

	get_tree().create_timer(duration).timeout.connect(func():
		finished.emit()
		is_finished = true
		$ProgressBarVisibilityTimer.stop())

	is_finished = false


func _on_progress_bar_visibility_timer_timeout() -> void:
	progress_bar.visible = true
