extends GeometryInstance3D

@export var audio_controller: AudioController

@export var beat: int = 0

func _ready() -> void:
	audio_controller.beat_reached.connect(_update_shader)

func _update_shader() -> void:
	beat += 1
	set_instance_shader_parameter('tick', beat)
