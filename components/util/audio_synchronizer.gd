class_name AudioSynchronizer extends Node
## Audio latency-corrected osu! beatmap player.
##
## Blah blah
##
## Additionally, a beat-aligned rest time will be precalculated to ensure hit
## objects can be pre-spawned.

## Called on an interval of every BPS (e.g., when the metronome ticks)
signal on_beat

@export var beatmap : Beatmap :
	set(value):
		beatmap = value
		assert(beatmap)
		self.current_beat_interval = self.beatmap.timings[0].beat_interval
		self.current_bps = 1.0 / self.current_beat_interval
		self.current_beats_per_measure = self.beatmap.timings[0].beats_per_measure

@onready var track : AudioStreamPlayer = $Track
@onready var metronome : AudioStreamPlayer = $Metronome

var time : float
var next_metronome_time : float

var has_played : bool = false
var has_started := false
var timing_idx : int = 0
var current_bps : float = 0
var current_beat_interval : float = 0
var current_beats_per_measure : int = 4
var use_metronome := true

func start():
	# Give a one measure preparation before starting the song...
	self.time = -((current_beats_per_measure + 1) * current_beat_interval) + beatmap.start_offset
	self.next_metronome_time = self.time + current_beat_interval
	track.stream = beatmap.track
	has_started = true

func _process(delta):
	if not has_started: return

	if has_played:
		# Source: https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
		time = track.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	else:
		if time > -AudioServer.get_time_to_next_mix():
			track.play()
			has_played = true
		time += delta

	if timing_idx < len(beatmap.timings) and time >= beatmap.timings[timing_idx].start_time:
		var timing_point = self.beatmap.timings[timing_idx]
		current_beat_interval = timing_point.beat_interval
		current_bps = 1.0 / current_beat_interval
		current_beats_per_measure = timing_point.beats_per_measure
		next_metronome_time = timing_point.start_time
		timing_idx += 1

	if time >= next_metronome_time:
		next_metronome_time += current_beat_interval
		on_beat.emit()

		if use_metronome: metronome.play()
