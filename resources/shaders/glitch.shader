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
uniform float magtitude;
uniform float delta;

varying vec2 v_texcoords;

void main(void) {
	vec2 coord = v_texcoords;
	float rx = 1.0/1024.0 * magtitude * sin(coord.y * 10.0 + delta) * clamp(tan(coord.y * 12.0 + delta), -2.0, 2.0) * sin(coord.y * 50.0 + delta);
	float gx = 1.0/1024.0 * magtitude * sin(coord.y * 1.0 + delta) * clamp(tan(coord.y * 30.0 + delta), -2.0, 2.0) * sin(coord.y * 23.0 + delta);
	float bx = 1.0/1024.0 * magtitude * sin(coord.y * 4.0 + delta) * clamp(tan(coord.y * 14.0 + delta), -2.0, 2.0) * sin(coord.y * 42.0 + delta);
	
	gl_FragColor.r = texture2D(u_texture, coord + vec2(rx, 0)).r;
	gl_FragColor.g = texture2D(u_texture, coord + vec2(gx, 0)).g;
	gl_FragColor.b = texture2D(u_texture, coord + vec2(bx, 0)).b;
}
