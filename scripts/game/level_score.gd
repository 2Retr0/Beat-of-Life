class_name LevelScore extends Resource

var score : int
var combo : int
var max_combo : int
var accuracy : float
var cumulative_accuracy : float
var cumulative_accuracy_max : float

func _init() -> void:
	reset()

func update(result : HitResult.Enum) -> void:
	score += HitResult.get_score(result) * int(1.0 + combo / 100.0)
	combo = HitResult.get_combo(result, combo)
	max_combo = max(combo, max_combo)

	cumulative_accuracy += HitResult.get_accuracy(result)
	cumulative_accuracy_max += 1.0
	accuracy = cumulative_accuracy / cumulative_accuracy_max

func reset() -> void:
	score = 0
	combo = 0
	max_combo = 0
	accuracy = 0.0
	cumulative_accuracy = 0.0
	cumulative_accuracy_max = 0.0
