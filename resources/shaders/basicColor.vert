#version 120

// Program inputs
uniform mat4 projection;
uniform mat4 model_view;

// Per-vertex inputs
attribute vec3 position;

void main()
{
    gl_Position = projection * model_view * vec4(position, 1.0);
}
