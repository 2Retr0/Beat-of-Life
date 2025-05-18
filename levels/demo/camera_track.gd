extends Path3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property($Path, ^'progress_ratio', 1.0, 3.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
