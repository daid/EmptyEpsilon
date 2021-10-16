[vertex]
// Program inputs.
uniform mat4 projection;
uniform mat4 view;
uniform vec2 velocity;

// Per-vertex inputs
attribute vec3 position;
attribute float sign_value;

void main()
{    
    gl_Position = projection * view * vec4(position.xy + sign_value * velocity, position.z, 1.);
}

[fragment]
// Shader constants
const vec4 color = vec4(0.7, 0.5, 0.35, 0.07);

void main()
{
    gl_FragColor = color;
}
