class_name BeatmapPlayer2 extends Node
## Audio latency-corrected osu! beatmap player.
##
## Blah blah
##
## Additionally, a beat-aligned rest time will be precalculated to ensure hit
## objects can be pre-spawned.

## Called on an interval of every BPS (e.g., when the metronome ticks)
signal on_beat
## Called when beatmap playback is finished
signal finished
signal timing_changed(new_timing_point : TimingPoint)

@export var beatmap : Beatmap

var time : float
var next_beat_time : float

var has_played : bool = false
var has_started := false
var current_timing_point_index := 0
var current_timing_point : TimingPoint :
	set(value):
		current_timing_point = value
		timing_changed.emit(current_timing_point)
var next_timing_point : TimingPoint

func play() -> void:
	assert(beatmap, 'Erm, you need a beatmap!')
	if len(beatmap.timing_points) > 0:
		current_timing_point = beatmap.timing_points[0]
		next_timing_point = beatmap.timing_points[1] if len(beatmap.timing_points) > 1 else current_timing_point

	# Give a one measure preparation before starting the song...
	self.time = -((current_timing_point.meter + 1.0) * current_timing_point.beat_length) + current_timing_point.time
	self.next_beat_time = self.time + current_timing_point.beat_length
	$Track.stream = beatmap.beatmap_set.track
	has_started = true

func _process(delta: float) -> void:
	if not has_started: return

	if has_played:
		# Source: https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
		time = $Track.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	else:
		if time > -AudioServer.get_time_to_next_mix():
			$Track.play()
			has_played = true
		time += delta

	if current_timing_point_index + 1 < len(beatmap.timing_points) and time >= next_timing_point.time:
		current_timing_point_index += 1
		current_timing_point = next_timing_point
		next_timing_point = beatmap.timing_points[current_timing_point_index]

	# NOTE: I think this may have the potential to desync with AudioServer playback
	if time >= next_beat_time:
		print(next_beat_time + (next_beat_time + current_timing_point.beat_length) - current_timing_point.time, ' ', ceil((next_beat_time + (next_beat_time + current_timing_point.beat_length) - current_timing_point.time) / current_timing_point.beat_length) * (next_beat_time + current_timing_point.beat_length) - current_timing_point.beat_length)
		next_beat_time += current_timing_point.beat_length
		on_beat.emit()


func _on_track_finished() -> void:
	finished.emit()
