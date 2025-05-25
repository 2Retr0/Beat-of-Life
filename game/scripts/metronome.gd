extends AudioStreamPlayer

@export var audio_controller: AudioController

func _ready() -> void:
	audio_controller.beat_reached.connect(_play_beat)

func _play_beat(new_beat: Beat) -> void:
	play()
