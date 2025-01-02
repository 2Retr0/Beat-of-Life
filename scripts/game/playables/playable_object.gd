class_name PlayableObject extends Node

@export var player : BeatmapPlayer

@export var hit_object : HitObject

func initialize(player : BeatmapPlayer, hit_object : HitObject):
	self.player = player
	self.hit_object = hit_object
