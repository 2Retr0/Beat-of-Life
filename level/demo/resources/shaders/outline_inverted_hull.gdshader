shader_type spatial;
render_mode cull_front, unshaded;

uniform vec4 outline_color : source_color = vec4(1,0,0,1);
uniform float outline_size : hint_range(1.0, 2.0);

void vertex() {
	VERTEX *= outline_size;
}

void fragment() {
	ALBEDO = outline_color.rgb;
	ALPHA = outline_color.a;
}
