#version 120

uniform vec4 color;

attribute vec3 position;
attribute vec2 texcoords;

varying vec2 fragtexcoords;
varying vec4 fragcolor;

void main()
{
    fragtexcoords = texcoords;
    gl_Position = gl_ProjectionMatrix * ((gl_ModelViewMatrix * vec4(position, 1.0)) + vec4((texcoords.x - 0.5) * color.a, (texcoords.y - 0.5) * color.a, 0.0, 0.0));
    fragcolor = vec4(color.rgb, 1.0);
}
