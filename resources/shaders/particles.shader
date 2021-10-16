[vertex]

// Constants

// Program inputs
uniform mat4 projection;
uniform mat4 view;

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
    vec4 viewspace_center = view * vec4(center, 1.0);
    vec4 viewspace_halfextents = vec4(texcoords.x - .5, texcoords.y - .5, 0., 0.) * size;

    // Outputs to fragment shader
    gl_Position = projection * (viewspace_center + viewspace_halfextents);
    fragtexcoords = texcoords;
    fragcolor = color;
}

[fragment]

// Program inputs
uniform sampler2D textureMap;

// Per-fragment inputs
varying vec3 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    gl_FragColor = texture2D(textureMap, fragtexcoords.st) * vec4(fragcolor, 1.);
}
