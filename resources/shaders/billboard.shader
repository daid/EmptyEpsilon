[vertex]
uniform vec4 color;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;

attribute vec3 position;
attribute vec2 texcoords;

varying vec2 fragtexcoords;
varying vec4 fragcolor;

void main()
{
    fragtexcoords = texcoords;
    gl_Position = projection * ((view * model * vec4(position, 1.0)) + vec4((texcoords.x - 0.5) * color.a, (texcoords.y - 0.5) * color.a, 0.0, 0.0));
    fragcolor = vec4(color.rgb, 1.0);
}

[fragment]
uniform sampler2D textureMap;

varying vec4 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    gl_FragColor = texture2D(textureMap, fragtexcoords.st) * fragcolor;
}
