extends Node

const WINDOW_SCALE = 0.6

func _init() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_size(DisplayServer.screen_get_size() * WINDOW_SCALE)
	DisplayServer.window_set_position(DisplayServer.screen_get_size() * (1.0 - WINDOW_SCALE) / 2.0) # Centered


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Need to wait for DebugMenu thread without blocking...
		# Source: https://github.com/godot-extended-libraries/godot-debug-menu/issues/22
		while DebugMenu.thread.is_alive():
			await get_tree().create_timer(0.25).timeout
		print_debug('Quitting!')
		get_tree().quit()
