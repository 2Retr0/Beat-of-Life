class_name ManiaLongNoteState extends HitObjectState

@export var press_result: HitResult.Enum = HitResult.Enum.None

@export var release_result: HitResult.Enum = HitResult.Enum.None

func _init(hit_object: HitObject) -> void:
	super(hit_object)

func process_tick(player: BeatmapPlayer) -> void:
	if press_result == HitResult.Enum.None:
		if player.get_time() > hit_object.time + hit_object.get_hit_windows().get_max_extent():
			press_result = HitResult.Enum.Miss
			release_result = HitResult.Enum.Miss
			set_result(HitResult.Enum.Miss)
	elif release_result == HitResult.Enum.None:
		if player.get_time() > (hit_object as ManiaLongNote).get_end_time() + hit_object.get_hit_windows().get_max_extent():
			release_result = HitResult.Enum.Miss
			set_result(HitResult.Enum.Good)

func can_perform_action(player: BeatmapPlayer) -> bool:
	var extent := hit_object.get_hit_windows().get_max_extent()
	return result == HitResult.Enum.None and player.get_time() - hit_object.get_start_time() >= -extent and player.get_time() - hit_object.get_end_time() <= +extent

func process_action(player: BeatmapPlayer, action: ActionType) -> void:
	match action:
		ActionType.PRESSED:
			if press_result == HitResult.Enum.None:
				press_result = hit_object.get_result(player.get_time())
				if press_result == HitResult.Enum.Miss:
					release_result = HitResult.Enum.Miss
					set_result(HitResult.Enum.Miss)
				action_handled.emit()
		ActionType.RELEASED:
			if press_result != HitResult.Enum.None:
				release_result = (hit_object as ManiaLongNote).get_release_result(player.get_time())
				if release_result == HitResult.Enum.Miss:
					# Treat misses as 'good' so combo doesn't break, but visually consider it a miss
					set_result(HitResult.Enum.Good)
				else:
					set_result(press_result)
				action_handled.emit()
