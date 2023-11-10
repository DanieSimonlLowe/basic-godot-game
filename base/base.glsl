#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 20, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430) restrict buffer dataBuffer {
    uint blocks[14490];
}
data;

void update_block(uint pos, uint block) {
    if (topPos > 14489) {
        return;
    }

    uint otherBlock = data.blocks[pos]
    if (block == 1 && otherBlock == 2) {
        data.blocks[gl_GlobalInvocationID.x] = 2
    }
}

// The code we want to execute in each invocation
void main() {
    // gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
    uint block = data.blocks[gl_GlobalInvocationID.x];
    update_block(gl_GlobalInvocationID.x - 160);
    update_block(gl_GlobalInvocationID.x + 160);
    update_block(gl_GlobalInvocationID.x + 1);
    update_block(gl_GlobalInvocationID.x - 1);
}