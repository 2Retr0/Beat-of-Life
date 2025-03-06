extends Control

@onready var loading_screen: Variant = load('res://level/main_menu/loading_screen.tscn').instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	get_tree().root.add_child.call_deferred(loading_screen)
	ResourceLoader.load_threaded_request('res://level/demo/demo.tscn')

func _process(delta: float) -> void:
	var progress := []
	var loaded_status = ResourceLoader.load_threaded_get_status('res://level/demo/demo.tscn', progress)

	loading_screen.progress_value = lerpf(loading_screen.progress_value, progress[0], delta*10.0)

	if loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and loading_screen.is_finished:
		loading_screen.progress_value = 1
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get('res://level/demo/demo.tscn'))
		loading_screen.transition_stage = 1
