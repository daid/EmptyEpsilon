#version 120

// Program inputs.
uniform mat4 projection;
uniform mat4 model_view;
uniform vec2 velocity;

// Per-vertex inputs
attribute vec3 position;
attribute float sign_value;

void main()
{    
    gl_Position = projection * model_view * vec4(position.xy + sign_value * velocity, position.z, 1.);
}
