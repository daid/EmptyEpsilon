#version 120
//Simple per-pixel light shader.

// Constants
const vec4 light0_position = vec4(20000., 20000., 20000., 1.0);
const vec4 light1_position = vec4(0., 0., 0., 1.);

// Program inputs
uniform sampler2D baseMap;
uniform vec4 color;
uniform vec4 atmosphereColor;

// Per-fragment inputs
varying vec3 fragnormal;
varying vec3 viewspace_position;
varying vec2 fragtexcoords;

void main()
{
	vec3 lightDir = normalize(vec3(light1_position) - viewspace_position);
	float intensity = max(0.0, dot(lightDir, fragnormal));
	
	vec3 base = texture2D(baseMap, fragtexcoords.st).rgb;
	
	gl_FragColor = vec4((base * intensity) + (atmosphereColor.rgb * (1.0 - intensity)), color.a);
}
