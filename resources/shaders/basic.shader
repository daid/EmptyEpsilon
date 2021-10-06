[vertex]
uniform vec4 color;
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

attribute vec3 position;
attribute vec2 texcoords;

varying vec2 fragtexcoords;

void main()
{
    fragtexcoords = texcoords;
    gl_Position = projection * view * model * vec4(position, 1.0);
}

[fragment]
uniform vec4 color;
uniform sampler2D textureMap;

varying vec2 fragtexcoords;

void main()
{
    gl_FragColor = texture2D(textureMap, fragtexcoords.st) * color;
    gl_FragColor.rgb *= color.a;
}
