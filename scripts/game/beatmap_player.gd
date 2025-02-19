# Responsible for controlling all the elements of a beatmap in play
class_name BeatmapPlayer extends Node

@export var beatmap: Beatmap

@export var states: Array[HitObjectState]

@onready var audio_controller: AudioController = $AudioController

signal finished

func initialize(beatmap: Beatmap) -> void:
	self.beatmap = beatmap
	
	states.clear()
	for hit_object in beatmap.hit_objects:
		states.append(hit_object.create_state())
	
	if audio_controller == null:
		audio_controller = AudioController.new()
		add_child(audio_controller)
	
	audio_controller.initialize(self)

func play() -> void:
	audio_controller.play()

func seek(new_time: float) -> void:
	audio_controller.seek(new_time)

func get_time() -> float:
	return audio_controller.time
