shader_type canvas_item;

uniform float alpha_factor : hint_range(0.0, 1.0) = 0.0;

varying float random_factor;

void vertex() {
	random_factor = clamp(abs(INSTANCE_CUSTOM.x)*(2.0 - abs(INSTANCE_CUSTOM.x)), 0.5, 1.0);
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.a *= alpha_factor*random_factor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
