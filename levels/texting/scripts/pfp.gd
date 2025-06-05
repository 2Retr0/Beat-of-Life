class_name Pfp extends Sprite3D

@export var textures: Array[Texture]
@export var frame_counts: Array[int]

@export var player: TextingPlayer

@export var frame_num: int

func _ready() -> void:
	texture = textures[0]
	hframes = frame_counts[0]
	player.judgment_received.connect(handle_judgment)

func handle_judgment(judgment: Judgment) -> void:
	if judgment.hit_object.lane < 4:
		return
	
	texture = textures[judgment.result]
	hframes = frame_counts[judgment.result]
	update_frame()

func change_frame(frame_num: int) -> void:
	self.frame_num = frame_num
	update_frame()

func update_frame() -> void:
	frame = min(frame_num % 4, hframes - 1)
