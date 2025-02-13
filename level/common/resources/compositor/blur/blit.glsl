#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba16f) readonly restrict uniform image2D input_image;
layout(set = 0, binding = 1, rgba16f) writeonly restrict uniform image2D output_image;

void main() {
    const ivec2 id = ivec2(gl_GlobalInvocationID.xy);

    if (any(greaterThanEqual(id, imageSize(input_image)))) return;

    imageStore(output_image, id, imageLoad(input_image, id));
}