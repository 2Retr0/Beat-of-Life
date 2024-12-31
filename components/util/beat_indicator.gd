extends Control

@onready var default_color : Color = self_modulate

func _physics_process(delta: float) -> void:
	# Smoothly transition back to the default color from current color.
	# If the current color is the default color, nothing will happen.
	self_modulate = self_modulate.lerp(default_color, delta*3.0)
