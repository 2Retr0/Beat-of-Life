shader_type spatial;

#define TILING 300.0
#define EPS    TILING*2e-4

uniform vec3 albedo_color : source_color = vec3(1);
uniform float roughness : hint_range(0.0, 1.0) = 0.5;
uniform float hatching_strength : hint_range(0.0, 1.0) = 0.15;
uniform float halftone_strength : hint_range(0.0, 1.0) = 0.8;

void fragment() {
	ALBEDO = albedo_color;
}

vec2 rotate(vec2 uv, float theta) {
    return 0.5 + mat2(vec2(cos(theta), -sin(theta)), vec2(sin(theta), cos(theta)))*(uv - 0.5);
}

float band(float x, float start, float end, float delta) {
	return smoothstep(start, start + delta, x) * (1.0 - smoothstep(end - delta, end, x));
}

void light() {
	// Called for every pixel for every light affecting the material.
	vec2 uv = FRAGCOORD.xy / max(VIEWPORT_SIZE.x, VIEWPORT_SIZE.y);
	uv = rotate(uv*TILING, PI/3.0);
	
	vec3 reflected = 2.0*NORMAL*dot(NORMAL, LIGHT) - LIGHT;
	float norm_nl = dot(NORMAL, LIGHT)*0.5 + 0.5;
	float dot_nl = max(0.0, dot(NORMAL, LIGHT));
	float dot_rv = max(0.0, dot(reflected, VIEW));
	float dot_nv = max(0.0, dot(NORMAL, VIEW));
	
	// --- SHADOWS ---
	float shadow_band = band(norm_nl, 0.0, 0.6, 0.3);
	vec2 uv_shadow = uv*2.0;
	float shadow = band(mod(uv_shadow.x, 2.0), 0.0 - EPS, 1.0 + EPS, EPS) * hatching_strength;
	
	// --- MIDTONES ---
	float midtone_band = band(norm_nl, 0.3, 0.7, 0.3);
	vec2 uv_midtone = fract(uv) - 0.5;
	float midtone = smoothstep(0.0, EPS, length(uv_midtone) - min(0.3, midtone_band));
	midtone *= max(0.05, dot_nl);
	
	// --- HIGHLIGHTS ---
	float smoothness = 1.0 - roughness;
	float specular = pow(dot_rv, 30.0*max(smoothness, 1e-5)); // Specular
	specular += pow(1.0 - dot_nv, 5.0*smoothness)*0.2;        // Fresnel
	specular *= smoothness;
	
	vec2 uv_highlight = fract(rotate(uv, -PI/6.0)*0.75) - 0.5;
	float highlight = 1.0 - smoothstep(0.0, EPS, length(uv_highlight) - min(0.3, (1.0 - specular)));
	highlight *= halftone_strength*smoothness;
	
	float lambert = dot_nl;
	lambert = mix(lambert, shadow, shadow_band*hatching_strength);
	lambert = mix(lambert, midtone, midtone_band*halftone_strength);
	
	const vec3 light = ATTENUATION * LIGHT_COLOR/PI;
	DIFFUSE_LIGHT += lambert * light;
	SPECULAR_LIGHT += (highlight + 1.0)*specular * light * vec3(0.75,0.6,1.0);
}
