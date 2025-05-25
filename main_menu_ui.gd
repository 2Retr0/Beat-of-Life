extends Control

@onready var play_button = $"VBoxContainer/play button"
@onready var options_button = $"VBoxContainer/options button"

@export_file("*.tscn") var play_scene_path
@export_file("*.tscn") var options_scene_path

const LOADING_SCREEN_COLUMNS := preload('res://ui/loading/columns/loading_screen_columns.tscn')
const LOADING_SCREEN_GRID := preload('res://ui/loading/grid/loading_screen_grid.tscn')
const LOADING_SCREEN_STARTUP := preload('res://ui/loading/startup/loading_screen_startup.tscn')

func _ready() -> void:
	play_button.pressed.connect(_on_play)
	options_button.pressed.connect(_on_options)

func _on_play() -> void:
	#get_tree().change_scene_to_packed(load(play_scene_path))
	SceneManager.load_scene_async(play_scene_path, LOADING_SCREEN_GRID.instantiate())

func _on_options() -> void:
	SceneManager.load_scene_async(play_scene_path, LOADING_SCREEN_COLUMNS.instantiate())
