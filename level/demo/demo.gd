extends Level

@export_file('*.osu') var beatmap_file : String
@export var audio_stream : AudioStream

#var player : BeatmapPlayer

func _ready() -> void:
	var beatmap = ManiaParser.load_beatmap(beatmap_file)
	beatmap.beatmap_set.track = audio_stream

	ruleset.beatmap = beatmap
	#player.beatmap = beatmap
	#player = create_player(beatmap)
	#add_child(player)
	#player.play()

	audio_controller.timing_points = beatmap.timing_points
	audio_controller.stream = audio_stream
	audio_controller.play(30.0)
	ruleset.play()

#region --- SIGNALS FOR DEBUGGING REMOVE LATER!!! ---
var pause_tween : Tween
func _input(event: InputEvent) -> void:
	if event.is_action_released(&'ui_right'):
		audio_controller.seek(audio_controller.time + 5.0)
	elif event.is_action_released(&'ui_left'):
		audio_controller.seek(audio_controller.time - 5.0)
	elif event.is_action_released(&'ui_cancel'):
		audio_controller.get_tree().paused = not audio_controller.get_tree().paused
		for effect in $WorldEnvironment.compositor.compositor_effects:
			if effect is not CompositorEffectGaussianBlur: continue
			if audio_controller.get_tree().paused:
				effect.enabled = true
				pause_tween = create_tween().set_ease(Tween.EASE_OUT)
				pause_tween.tween_property(effect, 'strength', 1.0, 0.04).from(0.0)
			else:
				pause_tween.kill()
				pause_tween = create_tween().set_ease(Tween.EASE_OUT)
				pause_tween.tween_property(effect, 'strength', 0.0, 0.1).from_current()
				await pause_tween.finished
				effect.enabled = false

## ALERT: Remove this signal callback later
var tick := 0
func _on_beatmap_audio_controller_beat() -> void:
	$MetronomeAudioPlayer.play()
	tick += 1
	$Geometry/FloorMesh.set_instance_shader_parameter('tick', tick)

## FIXME: Remove this signal callback later
func _on_beatmap_audio_controller_timing_changed(new_timing_point: TimingPoint) -> void:
	$AudioScrubber.title = 'BPM: %d' % new_timing_point.bpm
#endregion
