shader_type canvas_item;

uniform float radius : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = (UV - 0.5)*vec2(SCREEN_PIXEL_SIZE.y/SCREEN_PIXEL_SIZE.x, 1);
	COLOR.a = smoothstep(-0.01, 0.00, length(uv) - radius*sqrt(2.0));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
