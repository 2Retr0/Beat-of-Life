extends Control

@export var beatmap_player: BeatmapPlayer

@export var score_text: Label

@export var combo_text: Label

@export var accuracy_text: Label

func _process(delta: float) -> void:
	score_text.text = '%d' % lerpf(int(score_text.text), beatmap_player.score.score, clampf(abs(int(score_text.text) - beatmap_player.score.score)*0.035*delta, 0.0, 1.0))
	combo_text.text = '%dx' % beatmap_player.score.combo
	accuracy_text.text = '%.2f%%' % (beatmap_player.score.accuracy * 100.0)
