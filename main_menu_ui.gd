extends Control

@onready var play_button = $"VBoxContainer/play button"
@onready var options_button = $"VBoxContainer/options button"

@export_file("*.tscn") var play_scene_path
@export_file("*.tscn") var options_scene_path


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_play_button_pressed() -> void:
	var play_scene = load(play_scene_path).instantiate()
	var root = get_tree().get_root()
	root.add_child(play_scene)
	queue_free()


func _on_options_button_pressed() -> void:
	var options_scene = load(options_scene_path).instantiate()
	var root = get_tree().get_root()
	root.add_child(options_scene)
