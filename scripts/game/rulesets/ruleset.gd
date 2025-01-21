class_name Ruleset extends Node

#@export var audio_player: AudioStreamPlayer

@export var beatmap: Beatmap

#@export var last_playback_position: float

#@export var time_increase: float

func initialize(beatmap: Beatmap) -> void:
	self.beatmap = beatmap
	#audio_player.stream = beatmap.beatmap_set.track
#
#func play() -> void:
	## TODO support playing after a certain delay
	#last_playback_position = -1
	#time_increase = 0
#
	#audio_player.play()
#
#func _process(delta: float) -> void:
	#var current_playback_position = audio_player.get_playback_position()
	#if current_playback_position == last_playback_position:
		#time_increase += delta
	#else:
		#last_playback_position = current_playback_position
		#time_increase = 0
	## var calculated_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	#current_time = max(current_time, last_playback_position + time_increase);
