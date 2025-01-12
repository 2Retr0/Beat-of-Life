shader_type spatial;

uniform vec3 albedo : source_color = vec3(1.0);
uniform float power : hint_range(0, 1) = 1.0;
uniform float tiling = 1.0;

void fragment() {
	// Called for every pixel the material is visible on.
	ivec2 p = ivec2((INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz * tiling + 1e3);
	ALBEDO = mix(albedo, albedo*float((p.x + p.y) % 2), power);
}
