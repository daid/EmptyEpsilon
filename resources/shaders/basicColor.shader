[vertex]

// Program inputs
uniform mat4 u_projection;
uniform mat4 u_view;
uniform mat4 u_model;

// Per-vertex inputs
attribute vec3 a_position;

void main()
{
    gl_Position = u_projection * u_view * u_model * vec4(a_position, 1.0);
}

[fragment]

// Program inputs
uniform vec4 u_color;

void main()
{
    gl_FragColor = u_color;
}
