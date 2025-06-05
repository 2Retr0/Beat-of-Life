class_name Bubble extends Node3D

@export var player_bubble: Texture

@export var crush_bubble: Texture

@export var emotes_root: Node3D

@export var emotes: Array[EmojiNoteDrawable]

@export var current_frame: int = 0

@export var sprite: Sprite3D

func set_is_player(is_player: bool) -> void:
	if is_player:
		sprite.texture = player_bubble
	else:
		sprite.texture = crush_bubble

func add_drawable(emote: EmojiNoteDrawable) -> void:
	emotes_root.add_child(emote)
	emote.position = Vector3(emotes.size() * 1.2, 0, 0)
	emote.set_frame(current_frame)
	emotes.append(emote)

func set_frame(frame: int) -> void:
	current_frame = frame
	for emote in emotes:
		emote.set_frame(frame)

func dispose() -> void:
	for emote in emotes:
		emote.dispose()
	queue_free()
