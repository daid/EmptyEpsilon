#version 120

uniform sampler2D textureMap;

varying vec4 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    gl_FragColor = texture2D(textureMap, fragtexcoords.st) * fragcolor;
}
