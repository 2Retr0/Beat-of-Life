@tool
extends Path3D

@export var num_instances := 4 :
	set(value):
		num_instances = maxi(1, value)
		_generate_multimeshes()

@export var distance_between_instances := 0.6748:
	set(value):
		distance_between_instances = value
		_generate_multimeshes()

@export var regenerate_multimeshes = false :
	set(value):
		if value: _generate_multimeshes()


func _ready() -> void:
	_generate_multimeshes()

func _generate_multimeshes():
	if not is_node_ready(): return

	# Free existing multimeshes (except first)
	var children := get_children()
	for child in children.slice(1):
		child.free()

	# Add new multimeshes The number of multimeshes
	# balances draw calls with amount of uploaded geometry.
	for i in range(num_instances - 1):
		var new_instance := children[0].duplicate()
		new_instance.multimesh = children[0].multimesh.duplicate()
		add_child(new_instance)

	var path_length := curve.get_baked_length()
	var total_instances := floori(path_length / distance_between_instances)
	var current_instance := 0

	# Distribute multimeshes such that instances conform along the path.
	for multimesh_instance: MultiMeshInstance3D in get_children():
		var multimesh := multimesh_instance.multimesh
		multimesh.instance_count = mini(total_instances - current_instance, ceili(float(total_instances) / get_child_count()))
		for i in range(0, multimesh.instance_count):
			var curve_distance := distance_between_instances * (current_instance + 0.5)
			var position := curve.sample_baked(curve_distance, true)

			var basis := Basis()
			var up := curve.sample_baked_up_vector(curve_distance, true)
			var forward := position.direction_to(curve.sample_baked(curve_distance + 0.1, true))

			basis.y = up
			basis.x = forward.cross(up).normalized()
			basis.z = -forward

			multimesh.set_instance_transform(i, Transform3D(basis, position))
			current_instance += 1

		# Overwrite current instance's multimesh with unique multimesh resource.
		multimesh_instance.multimesh = multimesh


func _on_curve_changed():
	_generate_multimeshes()
