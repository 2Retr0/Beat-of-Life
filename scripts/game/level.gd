class_name Level extends Resource

@export var level_name: StringName

@export var beatmaps : Array[BeatmapSource]

@export_file('*.tscn') var player_scene_path: String

func play(source: BeatmapSource) -> BeatmapPlayer:
	if not beatmaps.has(source):
		return

	var scene = load(player_scene_path)

	var player := scene.instantiate() as BeatmapPlayer
	player.initialize(source.get_beatmap())
#
	return player
