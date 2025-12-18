[vertex]
uniform vec4 u_color;
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

attribute vec3 a_position;
attribute vec2 a_texcoords;

varying vec2 v_fragtexcoords;

void main()
{
    v_fragtexcoords = a_texcoords;
    gl_Position = u_projection * u_view * u_model * vec4(a_position, 1.0);
}

[fragment]
uniform vec4 u_color;
uniform sampler2D u_textureMap;

varying vec2 v_fragtexcoords;

void main()
{
    gl_FragColor = texture2D(u_textureMap, v_fragtexcoords.st) * u_color;
    gl_FragColor.rgb *= u_color.a;
}
