#version 120

// Program inputs
uniform samplerCube starbox;

// Per-fragment inputs.
varying vec3 texcoords;

void main()
{
    gl_FragColor = textureCube(starbox, texcoords);
}
