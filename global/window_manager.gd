extends Node

const WINDOW_SCALE = 0.6

func _init() -> void:
	# Hack to visually hide window until size is changed to fit a percentage.
	# of the screen resolution.
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_size(DisplayServer.screen_get_size() * WINDOW_SCALE)
	DisplayServer.window_set_position(DisplayServer.screen_get_size() * (1.0 - WINDOW_SCALE) / 2.0) # Centered

## FIXME: This shouldn't be here...
#region shouldnt_be_here
var audio_stream_player := AudioStreamPlayer.new()

func _input(event: InputEvent) -> void:
	if event.is_pressed and not event.is_released() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		audio_stream_player.play()
		audio_stream_player.seek(0.05)

func _ready() -> void:
	audio_stream_player.stream = load('res://ui/audio/mouse_click.mp3')
	audio_stream_player.max_polyphony = 3
	audio_stream_player.volume_db = 20.0
	add_child(audio_stream_player)
#endregion

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST: # Quitting...
		# Need to wait for DebugMenu thread without blocking...
		# Source: https://github.com/godot-extended-libraries/godot-debug-menu/issues/22
		while DebugMenu.thread.is_alive():
			await get_tree().create_timer(0.25).timeout
		print_rich('[color=#DB3A10]Quitting![/color]') # Godot can print BBCode ???????!!!!
		get_tree().quit()
