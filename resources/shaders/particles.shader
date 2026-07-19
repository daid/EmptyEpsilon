[vertex]

// Constants

// Program inputs
uniform mat4 u_projection;
uniform mat4 u_view;

// Per-vertex inputs
attribute vec3 a_center;
attribute vec2 a_texcoords;
attribute vec3 a_color;
attribute float a_size;

// Per-vertex outputs
varying vec3 v_color;
varying vec2 v_texcoords;

void main()
{
    vec4 viewspace_center = u_view * vec4(a_center, 1.0);
    vec4 viewspace_halfextents = vec4(a_texcoords.x - .5, a_texcoords.y - .5, 0., 0.) * a_size;

    // Outputs to fragment shader
    gl_Position = u_projection * (viewspace_center + viewspace_halfextents);
    v_texcoords = a_texcoords;
    v_color = a_color;
}

[fragment]

// Program inputs
uniform sampler2D u_textureMap;

// Per-fragment inputs
varying vec3 v_color;
varying vec2 v_texcoords;

void main()
{
    gl_FragColor = texture2D(u_textureMap, v_texcoords.st) * vec4(v_color, 1.);
}
