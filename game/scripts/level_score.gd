class_name LevelScore extends Resource

@export var score: int
@export var combo: int
@export var max_combo: int
@export var cumulative_accuracy: float
@export var accuracy: float
@export var judgments: Array[Judgment]

func _init() -> void:
	reset()

func count(result: HitResult.Enum) -> int:
	var ret: int = 0
	for judgment in judgments:
		if judgment.result == result:
			ret += 1
	return ret

func update(judgment: Judgment) -> void:
	judgments.append(judgment)
	
	score += int(judgment.get_score() * (1.0 + combo / 100.0))
	combo = judgment.get_combo(combo)
	max_combo = max(combo, max_combo)

	cumulative_accuracy += judgment.get_accuracy()
	accuracy = cumulative_accuracy / judgments.size()

func reset() -> void:
	score = 0
	combo = 0
	max_combo = 0
	cumulative_accuracy = 0.0
	accuracy = 0.0
	judgments.clear()
