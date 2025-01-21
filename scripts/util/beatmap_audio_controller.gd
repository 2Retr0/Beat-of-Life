class_name BeatmapAudioController extends Node
## Audio latency-corrected audio stream player with dynamic BPM tracking.

## Called on an BPM aligned interval
signal beat
## Called when the position in the track is changed
signal seeked(delta : float)
## Called when beatmap playback is finished
signal finished
## Called when the current timing point changes
signal timing_changed(new_timing_point : TimingPoint)

@export var stream : AudioStream :
	set(value):
		stream = value
		has_started = false
		$Track.stream = stream
@export var timing_points : Array[TimingPoint] :
	set(value):
		timing_points = value
		_set_new_timing_point(0) # Initialize timing point references

var time : float
var next_beat_time : float
var timing_point : TimingPoint
var next_timing_point : TimingPoint

var has_started := false
var timing_point_index := -1

@onready var track := $Track

func play(from_position: float = INF) -> void:
	assert(len(timing_points) > 0, 'Erm, you need some timing points!')
	assert(stream, 'Erm, you need an audio stream!')

	# TODO: Maybe make the caller responsible for the one measure offset
	# By default, give a one measure preparation before starting the song...
	if from_position == INF:
		var mod_meter = timing_point.meter % 4 if timing_point.meter % 4 != 0 else 4 # FIXME: Not correct for meter > 4
		time = timing_point.time - ((mod_meter + 1.0) * timing_point.beat_length)
	else:
		time = from_position
	has_started = true
	seek(time)

## Moves the audio track position to [code]to_position[/code], if the track is
## currently playing.
func seek(to_position: float) -> void:
	if not has_started or time == to_position: return

	var old_time := time
	time = minf(to_position, stream.get_length())
	# Determine whether the audio stream should be playing or not
	if time >= 0.0 and time < stream.get_length():
		if track.playing:
			track.seek(time)
		else:
			track.play(time)
		time += AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	else:
		track.stop()

	# Search for the relevant timing point
	for i in len(timing_points):
		if timing_points[i].time < time: continue
		_set_new_timing_point(maxi(0, i - 1))
		break
	next_beat_time = _get_beat_aligned_time(time + timing_point.beat_length)
	seeked.emit(to_position - old_time)

func _process(delta: float) -> void:
	if not has_started: return

	if time >= 0:
		# Source: https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
		time = track.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	elif time <= -AudioServer.get_time_to_next_mix():
		time += delta
	else:
		track.play()
		time = 0.0

	if timing_point_index + 1 < len(timing_points) and time >= next_timing_point.time:
		_set_new_timing_point(timing_point_index + 1)

	if time >= next_beat_time:
		next_beat_time = _get_beat_aligned_time(next_beat_time + timing_point.beat_length)
		beat.emit()

func _set_new_timing_point(index : int) -> void:
	if index == timing_point_index: return
	timing_point_index = index
	timing_point = timing_points[index]
	next_timing_point = timing_points[mini(index + 1, len(timing_points) - 1)]
	timing_changed.emit(timing_point)

func _get_beat_aligned_time(time : float) -> float:
	return timing_point.time + round((time - timing_point.time) / timing_point.beat_length)*timing_point.beat_length

func _on_track_finished() -> void:
	finished.emit()
