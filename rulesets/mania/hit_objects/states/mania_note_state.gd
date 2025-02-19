class_name ManiaNoteState extends HitObjectState

func _init(hit_object: HitObject) -> void:
	super(hit_object)

func process_tick(player: BeatmapPlayer) -> void:
	if result == HitResult.Enum.None and player.get_time() > hit_object.time + hit_object.get_hit_windows().get_max_extent():
		set_result(HitResult.Enum.Miss)

func process_action(player: BeatmapPlayer, action: ActionType) -> void:
	match action:
		ActionType.PRESSED:
			set_result(hit_object.get_result(player.get_time()))
			action_handled.emit()
