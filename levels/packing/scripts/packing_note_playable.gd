class_name PackingNotePlayable extends PlayableObject

func _init(player: BeatmapPlayer, hit_object: HitObject) -> void:
	super(player, hit_object)

func process_tick() -> void:
	if !is_judged():
		var delta = player.get_time() - hit_object.time
		if abs(delta) <= hit_object.get_hit_windows().get_max_extent() and player.current_lane == hit_object.lane:
			set_result(HitResult.Enum.Perfect)
			return
		if delta > hit_object.get_hit_windows().get_max_extent():
			set_result(HitResult.Enum.Miss)

func perform_action(action: ActionType) -> void:
	match action:
		ActionType.PRESSED:
			set_result(hit_object.get_result(player.get_time()))
			player.play_sound()
