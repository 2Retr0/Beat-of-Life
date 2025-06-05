class_name Hand extends Sprite3D

@export var min_lane: int
@export var max_lane: int

@export var frame_time: float = 0.1
@export var frame_timer: float = 0

@export var player: TextingPlayer

func _ready() -> void:
	player.input_received.connect(handle_input)

func _process(delta: float) -> void:
	if frame != 0:
		frame_timer -= delta
		if frame_timer <= 0:
			frame = (frame + 1) % hframes
			if frame != 0:
				frame_timer = frame_time

func handle_input(lane: int) -> void:
	if lane >= min_lane and lane <= max_lane:
		frame = 1
		frame_timer = frame_time
