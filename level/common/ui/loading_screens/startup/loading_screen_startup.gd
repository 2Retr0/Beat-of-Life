extends LoadingScreen

const delay_fraction := 0.7

@onready var viewport := get_viewport()
@onready var notes := $Control/HBoxContainer

var time := 0.0

func _animate() -> void:
	super._animate()

func _process(delta: float) -> void:
	time += delta
	var max_bounce_height := viewport.get_visible_rect().size.y * 0.05
	for i in notes.get_child_count():
		var note := notes.get_child(i)
		var bounce_time := (time - i*0.5)*0.35
		bounce_time = (bounce_time - floor(bounce_time)) * 25.0 # == fract(bounce_time)*25.0
		note.position.y = -exp(-1.15*floor(bounce_time/PI)) * abs(sin(bounce_time)) * max_bounce_height
