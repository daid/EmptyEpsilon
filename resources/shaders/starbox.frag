#version 100

precision mediump float;

// Program inputs
uniform samplerCube starbox;

// Per-fragment inputs.
varying vec3 texcoords;

void main()
{
    gl_FragColor = textureCube(starbox, texcoords);
}
