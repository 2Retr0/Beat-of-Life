extends ProgressBar

@onready var visibility_timer := $VisibilityTimer

func _on_visibility_timer_timeout() -> void:
	visible = true
