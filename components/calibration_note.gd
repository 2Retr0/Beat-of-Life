class_name CalibrationNote extends VBoxContainer

const SPEED := 1.0

@export var audio_synchronizer : AudioSynchronizer
@export var hit_time : float

@onready var default_separation : float = get_theme_constant(&'separation')
@onready var separation : float = default_separation

## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not audio_synchronizer: return

	separation = lerpf(-10.0, default_separation, clampf((hit_time - audio_synchronizer.time) * SPEED, 0.0, 1.0))
	add_theme_constant_override(&'separation', int(separation))


func _physics_process(delta: float) -> void:
	if $DeletionTimer.is_stopped():
		# If the deletion timer has not yet started, fade in
		modulate.a = lerpf(1.0, 0.0, clampf(sqrt((separation + 10.0)/(default_separation + 10.0)), 0.0, 1.0))
		if separation <= -10.0: $DeletionTimer.start()
	else:
		# If the deletion timer has started, fade out.
		modulate.a = lerpf(modulate.a, 0.0, delta*10.0);


func _on_timer_timeout() -> void:
	queue_free()
