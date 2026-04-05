[vertex]
uniform mat4 u_view;
uniform mat4 u_projection;
uniform mat4 u_model;
uniform vec4 u_color;

attribute vec3 a_position;
attribute vec2 a_texcoords;

varying vec2 v_texcoords;

void main()
{
    v_texcoords = a_texcoords;
    gl_Position = u_projection * ((u_view * u_model * vec4(a_position, 1.0)) + vec4((a_texcoords.x - 0.5) * u_color.a, (a_texcoords.y - 0.5) * u_color.a, 0.0, 0.0));
}

[fragment]
uniform vec4 u_color;
uniform sampler2D u_textureMap;

varying vec4 v_color;
varying vec2 v_texcoords;

void main()
{
    gl_FragColor = texture2D(u_textureMap, v_texcoords.st) * vec4(u_color.rgb, 1.0);
}
