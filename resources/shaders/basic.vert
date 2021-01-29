#version 120

uniform vec4 color;
uniform mat4 modelViewProj;

attribute vec3 position;
attribute vec2 texcoords;

varying vec2 fragtexcoords;

void main()
{
    fragtexcoords = texcoords;
    gl_Position = gl_ModelViewProjectionMatrix * vec4(position, 1.0);
}
