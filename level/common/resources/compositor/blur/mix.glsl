#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba16f) restrict uniform image2D source_image;
layout(set = 0, binding = 1, rgba16f) readonly restrict uniform image2D mix_image;

layout(push_constant, std430) uniform PushConstant {
	float factor;
};

void main() {
    const ivec2 id = ivec2(gl_GlobalInvocationID.xy);

    if (any(greaterThanEqual(id, imageSize(source_image)))) return;

    imageStore(source_image, id, mix(imageLoad(source_image, id), imageLoad(mix_image, id), factor));
}