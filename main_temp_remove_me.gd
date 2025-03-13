extends Node

const LOADING_SCREEN_STARTUP := preload('res://level/common/ui/loading_screens/startup/loading_screen_startup.tscn')


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SceneManager.load_scene_async('res://main_menu_ui.tscn', LOADING_SCREEN_STARTUP.instantiate())
