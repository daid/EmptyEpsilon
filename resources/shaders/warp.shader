[vertex]
attribute vec2 a_position;
attribute vec2 a_texcoords;

varying vec2 v_texcoords;

void main()
{
    v_texcoords = a_texcoords;
    gl_Position = vec4(a_position, 0.0, 1.0);
}

[fragment]
uniform sampler2D u_texture;
uniform float amount;

varying vec2 v_texcoords;

void main(void) {
	vec2 coord = v_texcoords;
	vec2 cen = vec2(0.5, 0.5) - coord;
	vec2 mcen = amount*log(length(cen) * 0.5 + 0.75)*normalize(cen);
	gl_FragColor = texture2D(u_texture, v_texcoords+mcen);
}
