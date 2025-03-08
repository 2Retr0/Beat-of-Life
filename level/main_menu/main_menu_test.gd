extends Control

const LOADING_SCREEN := preload('res://level/common/ui/loading_screens/columns/loading_screen_columns.tscn')

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	SceneManager.load_scene_async('res://level/demo/demo.tscn', LOADING_SCREEN)
