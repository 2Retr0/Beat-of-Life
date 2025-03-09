@tool
extends LoadingScreen

const DELAY_FRACTION := 0.7

@export var subdivisions := 12
@export_color_no_alpha var color := Color(0.8, 0.6, 0.65) :
	set(value):
		color = value
		if columns: columns.modulate = value
@export var subdivision_scene: PackedScene

@onready var viewport := get_viewport()
@onready var columns := $Columns

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in subdivisions:
		columns.add_child(subdivision_scene.instantiate())

	super._ready()

func _animate() -> void:
	if not is_node_ready(): return

	for i in columns.get_child_count():
		var subdivision := columns.get_child(i)
		subdivision.position.y = -viewport.get_visible_rect().size.y if stage == Stage.LOAD else 0

		var tween := subdivision.create_tween()
		tween.tween_method(func(t: float):
				var height := viewport.get_visible_rect().size.y
				subdivision.position.y = -height*t + (height if stage == Stage.LOAD else 0), 0.0, 1.0, duration*(1.0 - DELAY_FRACTION)) \
			.set_delay(float(i)/subdivisions * duration*DELAY_FRACTION) \
			.set_ease(Tween.EASE_OUT) \
			.set_trans(Tween.TRANS_SINE)

	for i in range(8):
		var t := i / 8.0
		var pitch_modifier := t*t if stage == Stage.LOAD else 1.0-t*t
		get_tree().create_timer(t*t * duration*DELAY_FRACTION).timeout.connect(func():
			$AudioStreamPlayer.pitch_scale = 1.0 + pitch_modifier*2
			$AudioStreamPlayer.volume_db = lerpf(5.0, 8.0, pitch_modifier)
			$AudioStreamPlayer.play())

	super._animate()

	await get_tree().process_frame
	$Columns.modulate.a = 1.0


func _on_stage_finished() -> void:
	if stage == Stage.UNLOAD: $Columns.modulate.a = 0.0
