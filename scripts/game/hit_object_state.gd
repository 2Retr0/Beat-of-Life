class_name HitObjectState extends Resource

enum ActionType {
	PRESSED,
	HELD,
	RELEASED
}

signal action_handled()

signal result_changed(result: HitResult.Enum)

@export var hit_object: HitObject

@export var result: HitResult.Enum = HitResult.Enum.None

func _init(hit_object: HitObject) -> void:
	self.hit_object = hit_object

func process_tick(player: BeatmapPlayer) -> void:
	pass

func can_perform_action(player: BeatmapPlayer) -> bool:
	return result == HitResult.Enum.None and abs(player.get_time() - hit_object.time) <= hit_object.get_hit_windows().get_max_extent()

func perform_action(player: BeatmapPlayer, action: ActionType) -> void:
	pass

func set_result(value : HitResult.Enum) -> void:
	result = value
	result_changed.emit(result)
