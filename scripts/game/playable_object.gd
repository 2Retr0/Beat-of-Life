class_name PlayableObject extends Resource

enum ActionType {
	PRESSED,
	RELEASED
}

signal result_set(judgment: Judgment)

var player: BeatmapPlayer

@export var hit_object: HitObject

@export var judgment: Judgment

func _init(player: BeatmapPlayer, hit_object: HitObject) -> void:
	self.player = player
	self.hit_object = hit_object
	judgment = Judgment.new(hit_object)

func process_tick() -> void:
	pass

func can_perform_action() -> bool:
	return !is_judged() and abs(player.get_time() - hit_object.time) <= hit_object.get_hit_windows().get_max_extent()

func perform_action(action: ActionType) -> void:
	pass

func is_judged() -> bool:
	return judgment.result != HitResult.Enum.None

func set_result(result: HitResult.Enum) -> void:
	judgment.set_result(player.get_time(), result)
	player.report_judgment(judgment)
	result_set.emit(judgment)
