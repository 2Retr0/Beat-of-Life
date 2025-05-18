shader_type canvas_item;
render_mode unshaded;

//uniform vec3 background_color : source_color = vec3(0.82, 0.67, 0.71);
uniform float tiling : hint_range(1.0, 50.0) = 15.0;
uniform float gap : hint_range(1.0, 10.0) = 1.5;
uniform int tick = 0;
uniform sampler2D tiled_texture : source_color;

vec2 rotate(vec2 uv, float theta) {
    return 0.5 + mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)))*(uv - 0.5);
}

void fragment() {
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
}
