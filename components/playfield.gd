extends PanelContainer

const CALIBRATION_NOTE := preload('res://components/calibration_note.tscn')
const AUDIO_LATENCY := 0.033

@export var audio_synchronizer : AudioSynchronizer

var indicators : Array[Control] = []
var next_indicator_index := 0
var hit_queue : Array[CalibrationNote] = []

@onready var hit_offset_label : RichTextLabel = $MarginContainer/HitOffsetControl/HitOffsetLabel
@onready var hit_line : HSeparator = $MarginContainer/VBoxContainer/HitLine

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&'playfield_hit'):
		$HitSoundPlayer.play()
		hit_line.self_modulate = Color.PALE_GREEN

		var time := audio_synchronizer.time
		_remove_invalid_notes(time)

		if hit_queue.is_empty(): return
		# https://osu.ppy.sh/wiki/en/Gameplay/Judgement/osu%21mania
		var hit_offset : float = hit_queue.front().hit_time - time
		if hit_offset > 0.35: return # Disregard hits that are wayyy too early...

		hit_queue.pop_front().queue_free()
		hit_offset_label.text = ('−' if hit_offset < 0.0 else '+') + ('%.0f ms' % [abs(hit_offset)*1e3])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not audio_synchronizer: return

	## --- Setup Beat Indicators --- ##
	# NOTE: This solution won't work for tracks which have variable time signatures!
	#       `current_meter` can be variable throughout the track!
	var beat_indicator : Control = $MarginContainer/GridContainer/BeatIndicator
	indicators.push_back(beat_indicator)
	for i in range(audio_synchronizer.current_meter - 1):
		indicators.push_back(beat_indicator.duplicate())
		$MarginContainer/GridContainer.add_child(indicators.back())

	# Every beat update beat indicators
	audio_synchronizer.on_beat.connect(_on_audio_synchronizer_on_beat)

	# Add notes for start of next track loop
	audio_synchronizer.audio_player.finished.connect(_on_audio_synchronizer_track_finished)


func _physics_process(delta: float) -> void:
	if not audio_synchronizer: return
	_remove_invalid_notes(audio_synchronizer.time)


func _on_audio_synchronizer_on_beat() -> void:
	indicators[next_indicator_index].self_modulate = Color.hex(0xCCCCCCFF)
	next_indicator_index = (next_indicator_index + 1) % len(indicators)

	## --- Add New Note --- ##
	# Add a note ahead-of-time by one measure with a hit time that incorporates
	# audio latency.
	var hit_time := audio_synchronizer.time + audio_synchronizer.current_beat_interval*audio_synchronizer.current_meter + AUDIO_LATENCY
	_push_new_note(hit_time)


func _on_audio_synchronizer_track_finished() -> void:
	for note in hit_queue: note.queue_free()
	hit_queue.clear()
	for i in range(audio_synchronizer.current_meter):
		var hit_time := audio_synchronizer.current_beat_interval*i + audio_synchronizer.offset + AUDIO_LATENCY
		_push_new_note(hit_time)


func _push_new_note(hit_time : float) -> void:
	var note := CALIBRATION_NOTE.instantiate()
	note.audio_synchronizer = audio_synchronizer
	note.hit_time = hit_time
	$MarginContainer/Notes.add_child(note)
	hit_queue.push_back(note)


## Removes deleted or missed notes from the hit queue.
func _remove_invalid_notes(time : float) -> void:
	while not hit_queue.is_empty() and (hit_queue.front() == null or not is_instance_valid(hit_queue.front()) or hit_queue.front().hit_time - time < -0.2):
		hit_queue.pop_front()
		hit_offset_label.text = ''
