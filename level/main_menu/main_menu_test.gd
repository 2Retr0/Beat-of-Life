extends Control

const LOADING_SCREEN_COLUMNS := preload('res://level/common/ui/loading_screens/columns/loading_screen_columns.tscn')
const LOADING_SCREEN_GRID := preload('res://level/common/ui/loading_screens/grid/loading_screen_grid.tscn')
const LOADING_SCREEN_STARTUP := preload('res://level/common/ui/loading_screens/startup/loading_screen_startup.tscn')


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2).timeout
	SceneManager.load_scene_async('res://level/demo/demo.tscn', LOADING_SCREEN_COLUMNS.instantiate())
