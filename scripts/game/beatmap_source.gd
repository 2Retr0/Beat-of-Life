# Allows loading a beatmap in different ways
# For example loading a resource or from a file on disk
class_name BeatmapSource extends Resource

func get_beatmap() -> Beatmap:
	assert(false, 'Beatmap source not implemented')
	return null
