# A particular level to be displayed in the level selection
class_name GameLevel extends Resource

# Name of the level or scenario (not the name of the song)
@export var level_name: StringName

# List of difficulties for this level
@export var beatmaps : Array[BeatmapSource]

# Scene to play a beatmap for this level
@export_file('*.tscn') var player_scene_path: String

# Add the BeatmapPlayer to the scene tree after calling this function
func play(source: BeatmapSource) -> BeatmapPlayer:
	if not beatmaps.has(source):
		return

	var scene = load(player_scene_path)

	var player := scene.instantiate() as BeatmapPlayer
	player.initialize(source.get_beatmap())
#
	return player
