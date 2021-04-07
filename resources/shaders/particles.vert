#version 120

// Constants

// Program inputs
uniform mat4 projection;
uniform mat4 model_view;

// Per-vertex inputs
attribute vec3 center;
attribute vec2 texcoords;
attribute vec3 color;
attribute float size;

// Per-vertex outputs
varying vec3 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    vec4 viewspace_center = model_view * vec4(center, 1.0);
    vec4 viewspace_halfextents = vec4(texcoords.x - .5, texcoords.y - .5, 0., 0.) * size;

    // Outputs to fragment shader
    gl_Position = projection * (viewspace_center + viewspace_halfextents);
    fragtexcoords = texcoords;
    fragcolor = color;
}
