class_name TimeSeriesData extends Resource
##

var _timings : Array[float]
var _data : Array[Resource]
var _staged : Array[Array]

## Stages time series data; the data does not need to arrive in order.
func record(value: Resource, time: float) -> void:
	_staged.append([time, _create_new_level_score(value)])

## Commits the staged data in order.
func commit() -> void:
	_staged.sort_custom(func(a, b): return a[0] < b[0])
	# TODO: It would be cool if records were implemented as incremental changes
	if size() > 0 and len(_staged) > 0:
		assert(_timings[-1] <= _staged[0][0], 'Monotonicity violated! %f is not less than or equal to %f!' % [_timings[-1], _staged[0][0]])
	for pair in _staged:
		_timings.append(pair[0])
		_data.append(pair[1])
	_staged.clear()

## Returns the closest recorded data that occurs before [param time].
func find(time: float) -> Resource:
	return _create_new_level_score(_data[_timings.bsearch(time, false) - 1])

func size() -> int:
	return len(_data)

## Deletes all timings and data recorded after [param time] allowing new data
## to be recorded after.
func rollback(time: float) -> Resource:
	var index := _timings.bsearch(time, false)
	_timings = _timings.slice(0, index, true)
	_data = _data.slice(0, index, true)
	return _create_new_level_score(_data[-1]) if size() > 0 else null

## ALERT: THIS IS ONLY NEEDED BECAUSE RESOURCE.DUPLICATE(DEEP=TRUE) DOESN'T WORK ITS BROKEN AND HAS BEEN BROKEN FOR YEARS WTF???!
func _create_new_level_score(score: LevelScore) -> LevelScore:
	var new_score := LevelScore.new()
	new_score.score = score.score
	new_score.combo = score.combo
	new_score.max_combo = score.max_combo
	new_score.accuracy = score.accuracy
	new_score.cumulative_accuracy = score.cumulative_accuracy
	new_score.cumulative_accuracy_max = score.cumulative_accuracy_max
	return new_score
