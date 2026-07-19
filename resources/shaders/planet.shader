[vertex]
// Program inputs
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

// Per-vertex inputs
attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_texcoords;

// Per-vertex outputs
varying vec3 v_normal;
varying vec2 v_texcoords;

void main()
{
	v_normal = normalize((u_model * vec4(a_normal, 0.)).xyz);
	vec4 modelview_position = u_view * u_model * vec4(a_position, 1.);
	
	v_texcoords = a_texcoords;
	gl_Position = u_projection * modelview_position;
}

[fragment]
// Constants
const vec4 light0_position = vec4(20000., 20000., 20000., 1.0);
const vec4 light1_position = vec4(0., 0., 0., 1.);

// Program inputs
uniform vec3 u_specularLightDirection;
uniform sampler2D u_baseMap;
uniform vec4 u_color;
uniform vec4 u_atmosphereColor;

// Per-fragment inputs
varying vec3 v_normal;
varying vec2 v_texcoords;

void main()
{
	float intensity = max(0.0, dot(u_specularLightDirection, v_normal));
	
	vec3 base = texture2D(u_baseMap, v_texcoords.st).rgb;
	
	gl_FragColor = vec4((base * intensity) + (u_atmosphereColor.rgb * (1.0 - intensity)), u_color.a);
}
