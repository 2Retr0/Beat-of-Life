#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0) uniform sampler2D input_texture;
layout(set = 0, binding = 1, rgba16f) writeonly restrict uniform image2D output_image;

layout(push_constant, std430) uniform PushConstant {
	ivec2 dims_downsample; // Dimensions of the downsampled image
    float offset;
};

#define texture_clamped(tex, uv) texture(tex, clamp((uv), vec2(0), dims_downsample) / dims)
void main() {
    const ivec2 id = ivec2(gl_GlobalInvocationID.xy);
    const ivec2 dims = textureSize(input_texture, 0);
    const vec2 uv = id*2.0 + 0.5;

    if (any(greaterThanEqual(id, dims_downsample))) return;

    vec4 col = texture_clamped(input_texture, uv)*4.0;
    col += texture_clamped(input_texture, uv - offset*vec2(0.5, +0.5));
    col += texture_clamped(input_texture, uv + offset*vec2(0.5, +0.5));
    col += texture_clamped(input_texture, uv - offset*vec2(0.5, -0.5));
    col += texture_clamped(input_texture, uv + offset*vec2(0.5, -0.5));
    col /= 8.0;

    imageStore(output_image, id, col);
}