@tool
class_name Demo extends Node

@export var track: AudioStream :
	set(value):
		track = value
		assert(track)
		var path = '%s.osu' % track.resource_path.trim_suffix('.%s' % track.resource_path.get_file().get_extension())
		print(path)
		if not FileAccess.file_exists(path): return
		
		var beatmap = ManiaParser.load_beatmap(path)
		beatmap.beatmap_set.track = track
		self.beatmap = beatmap

@export var beatmap: ManiaBeatmap

func _ready() -> void:
	var player = beatmap.ruleset.create_player(beatmap)
	
	add_child(player)
	
	player.play()
