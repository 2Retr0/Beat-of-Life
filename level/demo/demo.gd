extends Level

@export_file('*.osu') var beatmap_file : String
@export var audio_stream : AudioStream

var player : BeatmapPlayer

func _ready() -> void:
	var beatmap = ManiaParser.load_beatmap(beatmap_file)
	beatmap.beatmap_set.track = audio_stream

	player = beatmap.ruleset.create_player(beatmap)
	add_child(player)
	player.play()

	$BeatmapPlayer2.beatmap = beatmap
	$BeatmapPlayer2.play()

	var tween := get_tree().create_tween()
	tween.tween_property($CameraTrack/Path, ^'progress_ratio', 1.0, 5.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

func _process(delta: float) -> void:
	player.current_time = $BeatmapPlayer2.time

var tick := 0
func _on_beatmap_player_2_on_beat() -> void:
	$MetronomeAudioPlayer.play()
	tick += 1
	$Geometry/FloorMesh.set_instance_shader_parameter('tick', tick)


func _on_beatmap_player_2_timing_changed(new_timing_point: TimingPoint) -> void:
	$AudioScrubber.title = 'BPM: %d' % new_timing_point.bpm
