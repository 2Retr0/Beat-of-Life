extends CanvasLayer

var load_scene_path: String
var loading_screen: LoadingScreen :
	set(value):
		loading_screen = value
		loading_screen.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
		loading_screen.z_as_relative = false
		add_child(loading_screen)
		visible = true

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	layer = 999
	process_mode = PROCESS_MODE_DISABLED
	visible = false

func load_scene_async(scene_path: String, loading_screen: LoadingScreen) -> void:
	if loading_screen and loading_screen.is_inside_tree():
		await loading_screen.tree_exiting

	self.loading_screen = loading_screen
	self.load_scene_path = scene_path
	ResourceLoader.load_threaded_request(scene_path)
	process_mode = PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var progress := []
	var loaded_status = ResourceLoader.load_threaded_get_status(load_scene_path, progress)

	if loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED and loading_screen.has_stage_finished:
		loading_screen.value = 1.0
		loading_screen.stage = LoadingScreen.Stage.UNLOAD
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(load_scene_path))
		await loading_screen.stage_finished
		process_mode = PROCESS_MODE_DISABLED
		self.loading_screen.queue_free()
	elif loaded_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		# Smooth interpolation for loading bar
		loading_screen.value = lerpf(loading_screen.value, progress[0], delta*10.0)
