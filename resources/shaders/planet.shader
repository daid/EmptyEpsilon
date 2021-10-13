[vertex]
// Program inputs
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Per-vertex inputs
attribute vec3 position;
attribute vec3 normal;
attribute vec2 texcoords;

// Per-vertex outputs
varying vec3 fragnormal;
varying vec3 viewspace_position;
varying vec2 fragtexcoords;

void main()
{
	fragnormal = normalize((model * vec4(normal, 0.)).xyz);
	vec4 modelview_position = view * model * vec4(position, 1.);
	viewspace_position = vec3(modelview_position);
	
	fragtexcoords = texcoords;
	gl_Position = projection * modelview_position;
}

[fragment]
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
	float intensity = clamp(dot(lightDir, fragnormal), 0.0, 1.0);
	
	vec3 base = texture2D(baseMap, fragtexcoords.st).rgb;
	
	gl_FragColor = vec4((base * intensity) + (atmosphereColor.rgb * (1.0 - intensity)), color.a);
}
