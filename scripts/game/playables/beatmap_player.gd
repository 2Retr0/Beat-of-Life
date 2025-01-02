class_name BeatmapPlayer extends Node

@export var audio_player : AudioStreamPlayer

@export var beatmap : Beatmap

@export var current_time : float

func initialize(beatmap : Beatmap):
	self.beatmap = beatmap
	audio_player.stream = beatmap.beatmap_set.track

func play():
	audio_player.play()

func _process(delta):
	var calculated_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	current_time = max(current_time, calculated_time);

func create_playable(hit_object : HitObject) -> PlayableObject:
	return null
