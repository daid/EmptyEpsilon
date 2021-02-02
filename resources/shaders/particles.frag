#version 120

// Program inputs
uniform sampler2D textureMap;

// Per-fragment inputs
varying vec3 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    gl_FragColor = texture2D(textureMap, fragtexcoords.st) * vec4(fragcolor, 1.);
}
