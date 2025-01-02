@tool
class_name AudioSynchronizer extends Node
## Audio latency-corrected osu! beatmap player.
##
## Blah blah
##
## Additionally, a beat-aligned rest time will be precalculated to ensure hit
## objects can be pre-spawned.

## Called on an interval of every BPS (e.g., when the metronome ticks)
signal on_beat

@export var track : AudioStream :
	set(value):
		track = value
		assert(track)
		var path = '%s.osu' % track.resource_path.trim_suffix('.%s' % track.resource_path.get_file().get_extension())
		print(path)
		if not FileAccess.file_exists(path): return
		
		var beatmap = Beatmap.load_beatmap(path)
		beatmap.beatmap_set.track = track
		self.beatmap = beatmap

@export var beatmap : Beatmap :
	set(value):
		beatmap = value
		assert(beatmap)
		self.offset = beatmap.get_start_offset()
		self.current_bpm = beatmap.get_bpm(offset)
		self.current_beat_interval = beatmap.get_beat_interval(offset)
		self.current_meter = beatmap.get_meter(offset)
		self.next_timing = beatmap.get_current_timing_end(offset)

@onready var audio_player : AudioStreamPlayer = $Track
@onready var metronome : AudioStreamPlayer = $Metronome

var time : float
var next_metronome_time : float

var has_played : bool = false
var has_started := false
var offset : float = 0
var current_bpm : float = 0
var current_beat_interval : float = 0
var current_meter : int = 4
var next_timing : float = INF
var use_metronome := true

func start():
	# Give a one measure preparation before starting the song...
	self.time = -((current_meter + 1) * current_beat_interval) + beatmap.get_start_offset()
	self.next_metronome_time = self.time + current_beat_interval
	audio_player.stream = beatmap.beatmap_set.track
	has_started = true

func _process(delta):
	if not has_started: return

	if has_played:
		# Source: https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
		time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	else:
		if time > -AudioServer.get_time_to_next_mix():
			audio_player.play()
			has_played = true
		time += delta
	
	if time >= next_timing:
		self.current_bpm = beatmap.get_bpm(time)
		self.current_beat_interval = beatmap.get_beat_interval(time)
		self.current_meter = beatmap.get_meter(time)
		self.next_timing = beatmap.get_current_timing_end(time)
		next_metronome_time = beatmap.get_current_timing_start(time)
	
	if time >= next_metronome_time:
		next_metronome_time += current_beat_interval
		on_beat.emit()

		if use_metronome: metronome.play()
