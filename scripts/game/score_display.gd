extends Control

@export var score_label: Label

@export var perfect_label: Label
@export var good_label: Label
@export var miss_label: Label

@export var accuracy_label: Label
@export var max_combo_label: Label

func set_score(score: LevelScore):
	score_label.text = "%d" % score.score
	
	perfect_label.text = "%d" % score.count(HitResult.Enum.Perfect)
	good_label.text = "%d" % score.count(HitResult.Enum.Good)
	miss_label.text = "%d" % score.count(HitResult.Enum.Miss)
	
	accuracy_label.text = "%d" % score.accuracy
	max_combo_label.text = "%d" % score.max_combo
