@tool
class_name Beatmap extends Resource

@export var beatmap_set: BeatmapSet

#@export var ruleset: Ruleset

@export var difficulty_name: StringName

@export var difficulty_creator: StringName

## FIXME: assert that the hit time of all hit objects should be monotonically increasing!
##for i in range(len(beatmap.hit_objects) - 1):
##	assert(beatmap.hit_objects[i].time <= beatmap.hit_objects[i + 1].time)
@export var hit_objects: Array[HitObject]

## FIXME: asser that the start time of all timing points should be monotonically increasing!
##for i in range(len(beatmap.timing_points) - 1):
##	assert(beatmap.timing_points[i].time <= beatmap.timing_points[i + 1].time)
@export var timing_points: Array[TimingPoint]

#func get_start_offset() -> float:
	#if timing_points.is_empty():
		#return 0
	#return timing_points[0].time
#
#func get_current_timing_start(time: float) -> float:
	#var latest_time = 0
	#for timing_point in timing_points:
		#if timing_point.time > latest_time  and timing_point.time <= time:
			#latest_time = timing_point.time
	#return latest_time
#
#func get_current_timing_end(time: float) -> float:
	#var earliest_time = INF
	#for timing_point in timing_points:
		#if timing_point.time < earliest_time  and timing_point.time > time:
			#earliest_time = timing_point.time
	#return earliest_time
#
#func get_bpm(time: float) -> float:
	#var bpm = 60 # Default bpm
	#var latest_time = 0
	#for timing_point in timing_points:
		#if timing_point.time > latest_time and timing_point.time <= time:
			#bpm = timing_point.bpm
			#latest_time = timing_point.time
	#return bpm
#
#func get_beat_interval(time: float) -> float:
	#return 60 / get_bpm(time)
#
#func get_meter(time: float) -> int:
	#var meter = 4 # Default meter
	#var latest_time = 0
	#for timing_point in timing_points:
		#if timing_point.time > latest_time and timing_point.time <= time:
			#meter = timing_point.meter
			#latest_time = timing_point.time
	#return meter

## Parses an osu! mania beatmap ([code].osu[/code]) and sets the [Beatmap]'s
## respective fields.
##
## [i]Note: At the moment, variable BPMs are not supported![/i]

# TODO move somewhere else
# TODO assign proper ruleset so beatmap would actually work
# TODO load beatmap sets

static func load_beatmap(beatmap_file_path: String) -> Beatmap:
	var beatmap = Beatmap.new()
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
				var x = line_parsed[0] as int
				if not x or x == 0: continue

				var time = (line_parsed[2] as int)*1e-3
				# var duration = (line_parsed[5].split(':')[0] as int)*1e-3
				var hit_object = HitObject.new(time)

				beatmap.hit_objects.push_back(hit_object)
	file.close()

	print('(beatmap) loaded: ' + beatmap_file_path)
	print('   --- track title:  %s' % beatmap.beatmap_set.title)
	print('   --- num timings:  %d' % len(beatmap.timing_points))
	print('   --- num objects:  %d' % len(beatmap.hit_objects))
	print('   --- start offset: %fs' % (beatmap.timing_points[0].time if len(beatmap.timing_points) > 0 else 0.0))
	return beatmap


static func load_beatmap_mania(beatmap_file_path: String) -> ManiaBeatmap:
	var beatmap = ManiaBeatmap.new()
	beatmap.ruleset = load('res://rulesets/mania/mania_ruleset.tres')

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
	print('   --- start offset: %fs' % beatmap.get_start_offset())
	return beatmap
