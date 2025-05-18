extends PanelContainer

@export var title : String :
	set(value):
		title = value
		$MarginContainer/VBoxContainer/Title.text = value
@export var audio_controller: AudioController

@onready var progress_bar : ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var time_elapsed_label : RichTextLabel = $MarginContainer/VBoxContainer/TimingLabels/TimeElapsedLabel
@onready var time_remaining_label : RichTextLabel = $MarginContainer/VBoxContainer/TimingLabels/TimeRemainingLabel

func _ready() -> void:
	audio_controller.timing_changed.connect(_update_bpm)

func _process(delta: float) -> void:
	if not audio_controller or not audio_controller.audio_player.stream:
		return
	
	var time := audio_controller.time
	var duration := audio_controller.audio_player.stream.get_length()

	progress_bar.value = time / duration
	time_elapsed_label.text = _get_timestamp(time)
	time_remaining_label.text = '−' + _get_timestamp(duration - time)

func _get_timestamp(value : float) -> String:
	return '%02.0f:%02.0f' % [floor(value / 60.0), fposmod(value, 60.0)]

func _update_bpm(new_timing_point: TimingPoint) -> void:
	if new_timing_point != null:
		title = 'BPM: %d' % new_timing_point.bpm
