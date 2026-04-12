[vertex]
// Program inputs.
uniform mat4 u_projection;
uniform mat4 u_view;
uniform vec2 u_velocity;

// Per-vertex inputs
attribute vec3 a_position;
attribute float a_sign_value;

void main()
{    
    gl_Position = u_projection * u_view * vec4(a_position.xy + a_sign_value * u_velocity, a_position.z, 1.);
}

[fragment]
// Shader constants
const vec4 color = vec4(0.7, 0.5, 0.35, 0.07);

void main()
{
    gl_FragColor = color;
}
