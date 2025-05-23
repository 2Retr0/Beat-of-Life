@tool
class_name LoadingScreen extends Control

const LOADING_BAR := preload('./loading_bar.tscn')

enum Stage { LOAD, UNLOAD }

signal stage_finished

var loading_bar: Control
var has_stage_finished := false

@export var stage := Stage.LOAD :
	set(value):
		stage = value
		_animate()
@export var duration := 0.5
## Loading bar value
@export var value: float :
	set(_value):
		value = _value
		if loading_bar: loading_bar.value = value

func _ready() -> void:
	get_tree().process_frame.connect(_animate, CONNECT_ONE_SHOT)

func _animate() -> void:
	if not is_node_ready: return
	has_stage_finished = false

	if not loading_bar:
		loading_bar = LOADING_BAR.instantiate()
		add_child(loading_bar)
		
	# FIXME: REMOVE THIS LATER
	loading_bar.visibility_timer.stop()

	match stage:
		Stage.LOAD: value = 0.0
		Stage.UNLOAD: create_tween().tween_property(loading_bar, ^'modulate:a', 0.0, 0.25).from(0.5)

	get_tree().create_timer(duration).timeout.connect(func():
		has_stage_finished = true
		# Prevent loading bar from appearing if we have loaded before it is shown.
		# Loading bar waits for a bit before showing for short transitions.
		if loading_bar: loading_bar.visibility_timer.stop()
		stage_finished.emit())
