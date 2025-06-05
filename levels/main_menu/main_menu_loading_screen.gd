extends Node

const LOADING_SCREEN_STARTUP := preload('res://ui/loading/startup/loading_screen_startup.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.load_scene_async('res://levels/main_menu/main_menu_im_taking_over.tscn', LOADING_SCREEN_STARTUP.instantiate())
