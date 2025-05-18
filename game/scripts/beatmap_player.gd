# Responsible for controlling all the elements of a beatmap in play
class_name BeatmapPlayer extends Node

@export var beatmap: Beatmap

@export var score: LevelScore = LevelScore.new()

@export var audio_controller: AudioController

@export var score_display: ScoreDisplay

signal finished

func initialize(beatmap: Beatmap) -> void:
	self.beatmap = beatmap
	
	score.reset()
	score_display.visible = false

	if audio_controller == null:
		audio_controller = AudioController.new()
		add_child(audio_controller)

	audio_controller.initialize(self)
	audio_controller.finished.connect(display_score)

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
	score.update(judgment)

func display_score() -> void:
	score_display.set_score(score)
	score_display.visible = true
