class_name AudioController extends Node

@export var beatmap_player: BeatmapPlayer

@export var beatmap: Beatmap

@export var started: bool

@export var time: float

@export var timing: TimingPoint

@export var next_beat: Beat

@export var next_timing: TimingPoint

@onready var audio_player: AudioStreamPlayer = $AudioPlayer

signal beat_reached(new_beat: Beat)

signal timing_changed(new_timing_point: TimingPoint)

signal seeked(new_time: float)

signal finished

func initialize(beatmap_player: BeatmapPlayer):
	self.beatmap_player = beatmap_player
	beatmap = beatmap_player.beatmap
	
	started = false
	time = 0
	timing = null
	next_beat = null
	next_timing = null
	
	audio_player.stream = beatmap.track

func play() -> void:
	started = true
	
	var start_timing = beatmap.get_current_timing(beatmap.get_object_start())
	var measure_ahead = start_timing.time - start_timing.beat_length * start_timing.meter
	time = min(measure_ahead, 0)
	
	timing = beatmap.get_current_timing(time)
	timing_changed.emit(timing)
	
	if timing != null:
		next_beat = beatmap.get_beat(time).get_next()
	
	next_timing = beatmap.get_next_timing(time)

func seek(new_time: float) -> void:
	if not started:
		return
	
	time = clamp(new_time, 0, beatmap.track.get_length())
	if time < beatmap.track.get_length():
		if audio_player.playing:
			audio_player.seek(time)
		else:
			audio_player.play(time)
		time += AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	else:
		audio_player.stop()
	
	timing = beatmap.get_current_timing(time)
	timing_changed.emit(timing)
	
	if timing != null:
		next_beat = beatmap.get_beat(time).get_next()
	
	next_timing = beatmap.get_next_timing(time)
	
	seeked.emit(time)

func _process(delta: float) -> void:
	if not started:
		return
	
	if time >= 0:
		time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	else:
		time += delta
		if time >= 0:
			audio_player.play()
			time = 0
	
	var next_beat_time = INF if next_beat == null else next_beat.time
	var next_timing_time = INF if next_timing == null else next_timing.time
	while time >= next_beat_time or time >= next_timing_time:
		if next_timing_time <= next_beat_time:
			timing = next_timing
			timing_changed.emit(timing)
			
			next_timing = beatmap.get_next_timing(timing.time)
			
			next_beat = beatmap.get_beat(timing.time)
			beat_reached.emit(next_beat)
			next_beat = next_beat.get_next()
		else:
			beat_reached.emit(next_beat)
			next_beat = next_beat.get_next()
		
		next_beat_time = INF if next_beat == null else next_beat.time
		next_timing_time = INF if next_timing == null else next_timing.time
