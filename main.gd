extends Control

var tick := 0

@onready var background_material : ShaderMaterial = $CanvasLayer/Background.material
@onready var synchronizer := $AudioSynchronizer
@onready var audio_scrubber := $CanvasLayer/MarginContainer/HBoxContainer/VBoxContainer/AudioScrubber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hack to loop track whenever the AudioStreamPlayer's `finished` signal is emitted...
	synchronizer.track.finished.connect(func():
		synchronizer.track.play(0.0)
		synchronizer.time = 0.0
		synchronizer.next_metronome_time = synchronizer.beatmap.start_offset)
	audio_scrubber.title = synchronizer.beatmap.title
	synchronizer.start()


func _on_audio_synchronizer_on_beat() -> void:
	tick += 1
	background_material.set_shader_parameter('tick', tick)
