extends Node

@export var level: Level

@onready var beatmap_player: ManiaPlayer = $ManiaPlayer

@onready var audio_controller: AudioController = $ManiaPlayer/AudioController

func _ready() -> void:
	var beatmap = level.beatmaps[0].get_beatmap()
	beatmap_player.initialize(beatmap)
	beatmap_player.play()

#region --- SIGNALS FOR DEBUGGING REMOVE LATER!!! ---
var pause_tween : Tween
func _input(event: InputEvent) -> void:
	if event.is_action_released(&'ui_right'):
		beatmap_player.seek(audio_controller.time + 5.0)
	elif event.is_action_released(&'ui_left'):
		beatmap_player.seek(audio_controller.time - 5.0)
	elif event.is_action_released(&'ui_cancel'):
		beatmap_player.get_tree().paused = not audio_controller.get_tree().paused
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

func _process(delta: float) -> void:
	if audio_controller.timing != null:
		$AudioScrubber.title = 'BPM: %d, T: %d, P#: %d, CI: %d, DI: %d' % [audio_controller.timing.bpm, audio_controller.time, len(beatmap_player.playables), beatmap_player.create_index, beatmap_player.dispose_index]

## ALERT: Remove this signal callback later
var tick := 0
func _on_audio_controller_beat_reached(new_beat: Beat) -> void:
	$MetronomeAudioPlayer.play()
	tick += 1
	$Geometry/FloorMesh.set_instance_shader_parameter('tick', tick)

## FIXME: Remove this signal callback later
func _on_audio_controller_timing_changed(new_timing_point: TimingPoint) -> void:
	if new_timing_point != null:
		pass
		#$AudioScrubber.title = 'BPM: %d' % new_timing_point.bpm
#endregion
