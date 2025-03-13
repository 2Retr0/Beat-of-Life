extends Node

@export var level: Level

@onready var beatmap_player: BirthdayPlayer = $BirthdayPlayer

@onready var audio_controller: AudioController = $BirthdayPlayer/AudioController

@onready var score_text = $ScoreText

@onready var combo_text = $ComboText

@onready var accuracy_text = $AccuracyText

@onready var metronome = $MetronomeAudioPlayer

@onready var scrubber = $AudioScrubber

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
				pause_tween.tween_property(effect, 'radius', 48.0, 0.05).from(0.0)
			else:
				pause_tween.kill()
				pause_tween = create_tween().set_ease(Tween.EASE_OUT)
				pause_tween.tween_property(effect, 'radius', 0.0, 0.035).from_current()
				await pause_tween.finished
				effect.enabled = false

func _process(delta: float) -> void:
	# NOTE: Some nice value smoothing courtesy of me :3
	score_text.text = '%d' % lerpf(int(score_text.text), beatmap_player.score.score, clampf(abs(int(score_text.text) - beatmap_player.score.score)*0.035*delta, 0.0, 1.0))
	combo_text.text = '%dx' % beatmap_player.score.combo
	accuracy_text.text = '%.2f%%' % (beatmap_player.score.accuracy * 100.0)

	#if audio_controller.timing != null:
		#$AudioScrubber.title = 'BPM: %d, T: %d, P#: %d, CI: %d, DI: %d' % [audio_controller.timing.bpm, audio_controller.time, len(beatmap_player.playables), beatmap_player.create_index, beatmap_player.dispose_index]

## ALERT: Remove this signal callback later
var tick := 0
func _on_audio_controller_beat_reached(new_beat: Beat) -> void:
	metronome.play()
	tick += 1
	$Geometry/FloorMesh.set_instance_shader_parameter('tick', tick)

## FIXME: Remove this signal callback later
func _on_audio_controller_timing_changed(new_timing_point: TimingPoint) -> void:
	if new_timing_point != null:
		scrubber.title = 'BPM: %d' % new_timing_point.bpm
#endregion
