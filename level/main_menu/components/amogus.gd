extends Sprite3D

const LOADING_SCREEN_COLUMNS := preload('res://level/common/ui/loading_screens/columns/loading_screen_columns.tscn')
const LOADING_SCREEN_GRID := preload('res://level/common/ui/loading_screens/grid/loading_screen_grid.tscn')
const LOADING_SCREEN_STARTUP := preload('res://level/common/ui/loading_screens/startup/loading_screen_startup.tscn')

@onready var area: Area3D = $Area3D

@export_file("*.tscn") var level_path: String

func _ready() -> void:
	area.input_event.connect(_on_input)

func _on_input(camera: Node, event: InputEvent, event_pos: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
			SceneManager.load_scene_async(level_path, LOADING_SCREEN_COLUMNS.instantiate())
			area.input_event.disconnect(_on_input)
