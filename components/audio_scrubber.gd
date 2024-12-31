extends PanelContainer

@export var title : String :
	set(value):
		title = value
		$MarginContainer/VBoxContainer/Title.text = value
@export var track : AudioStreamPlayer

@onready var progress_bar : ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var time_elapsed_label : RichTextLabel = $MarginContainer/VBoxContainer/TimingLabels/TimeElapsedLabel
@onready var time_remaining_label : RichTextLabel = $MarginContainer/VBoxContainer/TimingLabels/TimeRemainingLabel

func _get_timestamp(value : float) -> String:
	return '%02.0f:%02.0f' % [value / 60.0, fposmod(value, 60.0)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not track: return
	var time := track.get_playback_position()
	var duration := track.stream.get_length()

	progress_bar.value = time / duration
	time_elapsed_label.text = _get_timestamp(time)
	time_remaining_label.text = '−' + _get_timestamp(duration - time)
