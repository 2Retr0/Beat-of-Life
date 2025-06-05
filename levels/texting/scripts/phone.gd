class_name Phone extends Node

@export var current_frame: int = 0

@export var emotes: Node

@export var bubbles: Node

@export var current_bubble: Bubble

@export var bubble_scene: PackedScene

@export var player_message_sfx: AudioStream

@export var crush_message_sfx: AudioStream

@export var sfx_player: AudioStreamPlayer

@export var pfp: Pfp

func get_bubble() -> Bubble:
	return current_bubble

func add_bubble(is_player: bool) -> Bubble:
	for bubble in bubbles.get_children():
		bubble.position = Vector3(0, bubble.position.y + 1.75, 0)
	current_bubble = bubble_scene.instantiate()
	current_bubble.set_is_player(is_player)
	bubbles.add_child(current_bubble)
	if bubbles.get_children().size() > 2:
		bubbles.get_child(0).dispose()
	if is_player:
		sfx_player.stream = player_message_sfx
	else:
		sfx_player.stream = crush_message_sfx
	sfx_player.play()
	return current_bubble

func tick_frame() -> void:
	for emote in emotes.get_children():
		emote.set_frame(current_frame)
	for bubble in bubbles.get_children():
		bubble.set_frame(current_frame)
	pfp.change_frame(current_frame)
	current_frame += 1

func dispose() -> void:
	for bubble in bubbles.get_children():
		bubble.dispose()
