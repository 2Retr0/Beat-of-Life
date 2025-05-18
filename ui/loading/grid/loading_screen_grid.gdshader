shader_type canvas_item;
render_mode unshaded;

//uniform vec3 background_color : source_color = vec3(0.82, 0.67, 0.71);
uniform float tiling : hint_range(1.0, 50.0) = 15.0;
uniform float gap : hint_range(1.0, 10.0) = 1.5;
uniform int tick = 0;
uniform sampler2D tiled_texture : source_color;

group_uniforms loading_screen;
uniform float tiling2 : hint_range(1.0, 50.0) = 15.0;
uniform float progress : hint_range(0.0, 2.0) = 0.0;
uniform float viewport_aspect_ratio;

vec2 rotate(vec2 uv, float theta) {
    return 0.5 + mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)))*(uv - 0.5);
}

// Source: https://iquilezles.org/articles/distfunctions2d/
float sdf_box(in vec2 p, in vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

void fragment() {
	if (progress == 2.0) discard;

	// Called for every pixel the material is visible on.
	vec2 uv = FRAGCOORD.xy / vec2(textureSize(tiled_texture, 0));
	uv *= tiling;                      // Tile UV
	uv -= TIME;                        // Scroll UV according to time
	uv.x += floor(uv.y / gap)*gap*0.5; // Stagger odd-indexed rows
	vec2 checkerboard = floor(uv / gap);
	uv = mod(uv, gap);                 // Add gap between tiles
	uv += -gap*0.5 + 0.5;              // Center UV to middle of gap

	// Rotate sprite depending on tick in a checkerboard pattern
	float theta = mix(-1.0, 1.0, float(tick % 2)) * TAU*0.0375;
	uv = rotate(uv, mix(-theta, theta, mod(checkerboard.x+checkerboard.y, 2.0)));

	// Disregard UV values outside of range 0..1
	float mix_factor = texture(tiled_texture, uv).a*0.125 * float(dot(step(vec2(0), uv)*step(uv, vec2(1)), vec2(1)) == 2.0);
	COLOR.rgb = mix(COLOR.rgb, vec3(dot(COLOR.rgb, vec3(0.2125, 0.7154, 0.0721)))*1.75, mix_factor);

	// --- Squares ---
	vec2 uv2 = UV/vec2(viewport_aspect_ratio, 1)*tiling2;
	float box_size = clamp(rotate(floor(uv2)/tiling2, -PI*0.25).x - (fract(progress)*2.0 - 1.0)*1.212, 0.0, 1.0);
	box_size = smoothstep(0.0, 0.5, 1.0 - box_size);
	box_size = mix(box_size, 1.0 - box_size, floor(progress));
	COLOR.a = 1.0 - step(0.0, sdf_box(fract(uv2) - 0.5, vec2(box_size)));
}
