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
uniform float time;
varying vec4 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    float wobbleAmount = 0.1;
    float wobbleSpeed = 3.0;

    vec2 wobble = vec2(
        sin(time * wobbleSpeed + fragtexcoords.y * 10.0) * wobbleAmount,
        cos(time * wobbleSpeed + fragtexcoords.x * 10.0) * wobbleAmount
    );

    vec2 wobbledTexCoords = fragtexcoords + wobble;

    gl_FragColor = texture2D(textureMap, wobbledTexCoords) * fragcolor;
}
