class_name Ruleset extends Resource

@export_file('*.tscn') var scene_path : String

func create_player(beatmap : Beatmap) -> BeatmapPlayer:
	var scene = load(scene_path);
	
	var player := scene.instantiate() as BeatmapPlayer;
	player.initialize(beatmap);
	
	return player;
