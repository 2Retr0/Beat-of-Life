extends Sprite3D

const LOADING_SCREEN_COLUMNS := preload('res://ui/loading/columns/loading_screen_columns.tscn')
const LOADING_SCREEN_GRID := preload('res://ui/loading/grid/loading_screen_grid.tscn')
const LOADING_SCREEN_STARTUP := preload('res://ui/loading/startup/loading_screen_startup.tscn')

@onready var area: Area3D = $Area3D

@export var level: Level

@export var beatmap_index: int

func _ready() -> void:
	area.input_event.connect(_on_input)

func _on_input(camera: Node, event: InputEvent, event_pos: Vector3, normal: Vector3, shape_idx: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed:
			var callback = func(tree, beatmap):
				for child in tree.root.get_children():
					if child is BeatmapPlayer:
						child.initialize(beatmap)
						child.play()
			callback = callback.bind(level.beatmaps[beatmap_index].get_beatmap())
			print(callback.get_object())
			SceneManager.load_scene_async(level.player_scene_path, LOADING_SCREEN_COLUMNS.instantiate(), callback)
			area.input_event.disconnect(_on_input)
