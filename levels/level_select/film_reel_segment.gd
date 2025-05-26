extends MeshInstance3D

@export var preview: Texture2D :
	set(value):
		preview = value
		$Preview.texture = value
