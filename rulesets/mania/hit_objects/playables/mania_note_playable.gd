class_name ManiaNotePlayable extends PlayableObject

func _init(player: BeatmapPlayer, hit_object: HitObject) -> void:
	super(player, hit_object)

func process_tick() -> void:
	if !is_judged() and player.get_time() > hit_object.time + hit_object.get_hit_windows().get_max_extent():
		set_result(HitResult.Enum.Miss)

func perform_action(action: ActionType) -> void:
	match action:
		ActionType.PRESSED:
			set_result(hit_object.get_result(player.get_time()))
			player.play_sound()
