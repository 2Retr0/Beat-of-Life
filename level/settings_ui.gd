class_name SettingsMenu
extends Control

@onready var exit_button = $"Settings Panel/HBoxContainer/MarginContainer/VBoxContainer/Exit Button" as Button

signal exit_settings

#emits a signal to exit back to main menu but not actually connected yet
func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	set_process(false)
	
func on_exit_pressed() -> void:
	exit_settings.emit()
	set_process(false)
