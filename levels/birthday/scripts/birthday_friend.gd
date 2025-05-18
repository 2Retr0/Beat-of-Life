extends Sprite3D

@export var lane: int

@export var normal_sprites: Texture2D

@export var normal_sprites_count: int

@export var bad_sprites: Texture2D

@export var bad_sprites_count: int

@export var player: BirthdayPlayer

@export var beat_index: int

func _ready() -> void:
	texture = normal_sprites
	hframes = normal_sprites_count
	frame = 0
	player.judgment_received.connect(judgment_received)
	player.audio_controller.beat_reached.connect(next_frame)

func update(texture: Texture2D, count: int):
	self.texture = texture
	hframes = count
	frame = beat_index % hframes

func next_frame(new_beat: Beat):
	beat_index = new_beat.index
	update(texture, hframes)

func judgment_received(judgment: Judgment):
	if judgment.hit_object.lane == lane:
		if judgment.result == HitResult.Enum.Perfect or judgment.result == HitResult.Enum.Good:
			update(normal_sprites, normal_sprites_count)
		elif judgment.result == HitResult.Enum.Miss:
			update(bad_sprites, bad_sprites_count)
