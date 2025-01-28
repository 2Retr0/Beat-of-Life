class_name HitObjectPlayable extends Control # FIXME: YEAH THIS IS NOT GREAT
## Similar to [HitObject], but contains information about state (e.g., long notes).

enum ActionType {
	PRESSED,
	HELD,
	RELEASED
}

signal result_changed(result: HitResult.Enum)

@export var hit_object: HitObject

var actionable := true

## FIXME: We probably don't even need this?
var result := HitResult.Enum.None :
	set(value):
		result = value
		_on_set_result(value)
		result_changed.emit(result)

var action : ActionType :
	set(value):
		var previous_value := action
		action = value
		_on_perform_action(previous_value, value)

func perform_action(value : ActionType) -> void:
	action = value

## Determines if the playable should accept actions.
func is_actionable(time: float) -> bool:
	var extent := hit_object.get_hit_windows().get_max_extent()
	return actionable and abs(time - hit_object.time) <= extent

func _on_perform_action(previous_value : ActionType, value : ActionType) -> void:
	pass

func _on_set_result(value : HitResult.Enum) -> void:
	pass
