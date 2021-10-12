[vertex]

// Program inputs
uniform mat4 projection;
uniform mat4 model_view;

// Per-vertex inputs
attribute vec3 position;

void main()
{
    gl_Position = projection * model_view * vec4(position, 1.0);
}

[fragment]

// Program inputs
uniform vec4 color;

void main()
{
    gl_FragColor = color;
}
