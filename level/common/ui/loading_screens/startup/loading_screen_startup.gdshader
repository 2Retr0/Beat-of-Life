shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

vec2 rotate(vec2 uv, float theta) {
    return 0.5 + mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)))*(uv - 0.5);
}
void fragment() {
	float box_size = clamp(rotate(UV, PI*0.1).x - (progress*2.0 - 1.0)*2.0, 0.0, 1.0);
	COLOR.a = smoothstep(0.0, 0.2, box_size);
}