# Responsible for controlling all the elements of a beatmap in play
class_name BeatmapPlayer extends Node

@export var beatmap: Beatmap

@export var score: LevelScore = LevelScore.new()

enum PlayState
{
	Instructions,
	Playing,
	Results
}

@export var play_state: PlayState = PlayState.Instructions

@export var audio_controller: AudioController

@export var instructions: Node

@export var score_display: ScoreDisplay

@export_file("*.tscn") var level_select_path

signal finished

const LOADING_SCREEN_GRID := preload('res://ui/loading/grid/loading_screen_grid.tscn')

func initialize(beatmap: Beatmap) -> void:
	self.beatmap = beatmap

	score.reset()
	score_display.visible = false

	if audio_controller == null:
		audio_controller = AudioController.new()
		add_child(audio_controller)

	audio_controller.initialize(self)
	audio_controller.finished.connect(display_score)
	
	if instructions == null:
		play()

func _input(event: InputEvent) -> void:
	if beatmap == null:
		return
	if event.is_pressed():
		if play_state == PlayState.Instructions:
			if instructions != null:
				instructions.queue_free()
			play()
		elif play_state == PlayState.Results:
			SceneManager.load_scene_async(level_select_path, LOADING_SCREEN_GRID.instantiate())

func play() -> void:
	audio_controller.play()
	play_state = PlayState.Playing

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
	play_state = PlayState.Results
