class_name HitResult
enum Enum
{
	None,
	Miss,
	Good,
	Perfect
}

static func get_accuracy(result: Enum) -> float:
	match result:
		Enum.Good:
			return 1.0 / 3
		Enum.Perfect:
			return 1
		_:
			return 0

static func get_score(result: Enum) -> int:
	match result:
		Enum.Good:
			return 100
		Enum.Perfect:
			return 300
		_:
			return 0

static func get_combo(result: Enum, old_combo: int) -> int:
	match result:
		Enum.Miss:
			return 0
		Enum.Good:
			return old_combo + 1
		Enum.Perfect:
			return old_combo + 1
		_:
			return old_combo
