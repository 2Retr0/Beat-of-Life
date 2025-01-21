class_name Level extends Node

#@export_file('*.tscn') var player_scene_path: String

@export_file('*.tscn') var composer_scene_path: String

@export var audio_controller : BeatmapAudioController
@export var ruleset : Ruleset

func create_player(beatmap: Beatmap) -> BeatmapPlayer:
	#var scene = load(player_scene_path)

	#var player := scene.instantiate() as BeatmapPlayer
	#player.initialize(beatmap)
#
	#return player
	assert(false, 'FIXME')
	return null

func create_composer() -> BeatmapComposer:
	var scene = load(composer_scene_path)

	var composer := scene.instantiate() as BeatmapComposer

	return composer
