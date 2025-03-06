# Responsible for controlling all the elements of a beatmap in play
class_name BeatmapPlayer extends Node

@export var beatmap: Beatmap

@export var judgments: Array[Judgment]

@onready var audio_controller: AudioController = $AudioController

signal finished

func initialize(beatmap: Beatmap) -> void:
	self.beatmap = beatmap
	
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

func create_playable(hit_object: HitObject) -> PlayableObject:
	return hit_object.create_playable(self)

func dispose_playable(playable: PlayableObject) -> void:
	pass

func report_judgment(judgment: Judgment) -> void:
	judgments.append(judgment)
