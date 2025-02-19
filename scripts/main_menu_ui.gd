class_name MainMenuUI extends Node

@onready var play_button = $VBoxContainer/PlayButton

@onready var quit_button = $VBoxContainer/QuitButton

@export_file('*.tscn') var scene_path : String

func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _process(delta: float) -> void:
	pass

func _on_play_button_pressed() -> void:
	var root = get_tree().root
	var scene = load(scene_path)
	var game = scene.instantiate()
	root.add_child(game)
	queue_free()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
