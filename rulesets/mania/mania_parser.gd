class_name ManiaParser extends Object

static func load_beatmap(beatmap_file_path: String) -> ManiaBeatmap:
	var beatmap = ManiaBeatmap.new()
	#beatmap.ruleset = load('res://rulesets/mania/mania_ruleset.tres')

	var beatmap_set = BeatmapSet.new()
	beatmap.beatmap_set = beatmap_set

	assert(beatmap_file_path.ends_with('.osu'), 'Beatmap path must be a .osu file!')
	var file := FileAccess.open(beatmap_file_path, FileAccess.READ)

	# Read the file line by line
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
		if line == '[Metadata]':
			beatmap_set.title = file.get_line().trim_prefix('Title:').strip_edges()
			file.get_line() # Skip title unicode
			beatmap_set.artist = file.get_line().trim_prefix('Artist:').strip_edges()
			file.get_line() # Skip artist unicode
			beatmap.difficulty_creator = file.get_line().trim_prefix('Creator:').strip_edges()
			beatmap.difficulty_name = file.get_line().trim_prefix('Version:').strip_edges()
		elif line == '[Difficulty]':
			file.get_line() # Skip hp drain rate
			beatmap.lane_count = file.get_line().trim_prefix('CircleSize:').strip_edges() as int
		elif line == '[TimingPoints]':
			# Read hit objects
			while !file.eof_reached() and line != '':
				line = file.get_line().strip_edges()
				var line_parsed = line.split(',')
				if len(line_parsed) < 3 or (line_parsed[1] as int) < 0:
					continue
				beatmap.timing_points.push_back(TimingPoint.new((line_parsed[0] as int)*1e-3, 60/((line_parsed[1] as float)*1e-3), (line_parsed[2] as int)))
		elif line == '[HitObjects]':
			# Read hit objects
			while !file.eof_reached():
				line = file.get_line().strip_edges()
				var line_parsed = line.split(',')
				if line_parsed.size() < 6:
					continue
				var type = (line_parsed[3] as int)
				var time = (line_parsed[2] as int) * 1e-3
				var lane = (line_parsed[0] as int) * beatmap.lane_count / 512
				if type == 1 << 0:
					beatmap.hit_objects.push_back(ManiaNote.new(time, lane))
				elif type == 1 << 7:
					var duration = (line_parsed[5].split(':')[0] as int) * 1e-3 - time
					beatmap.hit_objects.push_back(ManiaLongNote.new(time, lane, duration))
	file.close()
	print('(beatmap) loaded: ' + beatmap_file_path)
	print('   --- track title:  %s' % beatmap.beatmap_set.title)
	print('   --- num timings:  %d' % len(beatmap.timing_points))
	print('   --- num objects:  %d' % len(beatmap.hit_objects))
	print('   --- start offset: %fs' % beatmap.timing_points[0].time)
	return beatmap
