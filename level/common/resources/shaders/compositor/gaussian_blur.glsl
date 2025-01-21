#[compute]
#version 450

#define BLOCK_SIZE            (128)
#define BLUR_RADIUS_MAX       (64)
#define BLUR_VARIANCE_MAX     (64.0)
#define CACHE_SIZE            (BLOCK_SIZE + BLUR_RADIUS_MAX)
#define CACHE_LOAD_ITERATIONS ((CACHE_SIZE + (BLOCK_SIZE - 1)) / BLOCK_SIZE)

layout(local_size_x = BLOCK_SIZE, local_size_y = 1, local_size_z = 1) in;

layout(rgba16f, set = 0, binding = 0) uniform restrict readonly image2D input_image;
layout(rgba16f, set = 1, binding = 0) uniform restrict writeonly image2D output_image;

layout(push_constant, std430) uniform PushConstant {
	float t;
};

shared vec3 cache[CACHE_SIZE];

const float weights[BLUR_RADIUS_MAX + 1] = float[BLUR_RADIUS_MAX + 1](
	0.0111015, 0.0114454, 0.0117886, 0.0121301, 0.0124694, 0.0128057, 0.0131381, 0.0134661, 
	0.0137888, 0.0141054, 0.0144152, 0.0147175, 0.0150114, 0.0152962, 0.0155713, 0.0158358, 
	0.0160891, 0.0163304, 0.0165593, 0.0167749, 0.0169768, 0.0171643, 0.0173370, 0.0174943, 
	0.0176358, 0.0177611, 0.0178698, 0.0179616, 0.0180363, 0.0180937, 0.0181335, 0.0181556, 
	0.0181600, 0.0181467, 0.0181158, 0.0180672, 0.0180011, 0.0179178, 0.0178175, 0.0177005, 
	0.0175670, 0.0174176, 0.0172525, 0.0170724, 0.0168776, 0.0166688, 0.0164465, 0.0162113, 
	0.0159639, 0.0157049, 0.0154350, 0.0151550, 0.0148655, 0.0145673, 0.0142612, 0.0139479, 
	0.0136281, 0.0133027, 0.0129724, 0.0126379, 0.0123001, 0.0119596, 0.0116172, 0.0112735,
	0.0055077
);

// Burmann series approximation for error function
// Source: https://en.wikipedia.org/wiki/Error_function
float erf(in float x) {
	const float p = sqrt(3.14159265)*0.5;
    float a = exp(-x*x);
    return sign(x)/p * sqrt(1.0 - a) * (p + 0.155*a - 0.042625*a*a);
}

// Gaussian with sigma correction
// Source: https://bartwronski.com/2021/10/31/practical-gaussian-filter-binomial-filter-and-small-sigma-gaussians/
float gaussian_sigma_corrected(in float x, in float sigma) {
	float a = sqrt(0.5) / sigma;
	return 0.5 * (erf((x + 0.5)*a) - erf((x - 0.5)*a));
}

void main() {
    const ivec2 id = ivec2(gl_GlobalInvocationID.xy);
    const ivec2 id_local = ivec2(gl_LocalInvocationID.xy);

	const ivec2 dims = imageSize(input_image);
	const ivec2 dims_block = ivec2(gl_WorkGroupSize.xy);

    const int id_global = int(dims_block.x*gl_WorkGroupID.x) - BLUR_RADIUS_MAX/2;

	// --- Load Tile into Shared Memory ---
	for (int i = 0; i < CACHE_LOAD_ITERATIONS; ++i) {
        int cache_id = id_local.x + dims_block.x*i;
        int image_id = (id_global + cache_id);
		if (image_id < 0 || image_id > dims.x)
			cache[cache_id] = vec3(0.0333);
		else
			cache[cache_id] = imageLoad(input_image, ivec2(image_id, id.y)).rgb;
    }
	barrier();

	if (any(greaterThanEqual(id, dims))) return;

	// --- Gaussian Blur ---
	vec3 col = vec3(0);
	if (t >= 0.999) {
		// Use precomputed weights for Gaussian kernel
		for (int i = 0; i < BLUR_RADIUS_MAX + 1; ++i)
			col += cache[id_local.x + i].rgb * weights[i];
	} else {
		// Use dynamically compute weight for Gaussian kernel
		float radius = max(1.0, float(BLUR_RADIUS_MAX)*(1.0 - (1.0 - t)*(1.0 - t)));
		float variance = BLUR_VARIANCE_MAX * t*t * (2.0 - t);

		// Normalization factor for Gaussian weights
		// Source: https://www.wolframalpha.com/input?i2d=true&i=Sum%5BDivide%5B1%2C2%5D%5C%2840%29erf%5C%2840%29Divide%5Bn%2B0.5%2Cs%5DSqrt%5B0.5%5D%5C%2841%29-erf%5C%2840%29Divide%5Bn-0.5%2Cs%5DSqrt%5B0.5%5D%5C%2841%29%2C%7Bn%2C-x%2Cx%7D%5D
		float n = 1.0 / erf((2.0*radius + 1.0) / (2.0*sqrt(2.0) * variance));
		for (int i = 0; i < int(radius); ++i) {
			float j = float(i*2) - radius;
			float g0 = gaussian_sigma_corrected(j+0.0, variance);
			float g1 = gaussian_sigma_corrected(j+1.0, variance);
			float gm = g0 + g1;
			col += cache[id_local.x + int((BLUR_RADIUS_MAX + j+g1/gm)*0.5)].rgb * gm*n;
		}
	}

	// Transpose for next pass.
	imageStore(output_image, id.yx, vec4(col, 1));
}