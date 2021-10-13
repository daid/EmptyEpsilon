[vertex]
//Simple per-pixel light shader.

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
//Simple per-pixel light shader.

const vec4 light0_position = vec4(20000., 20000., 20000., 1.0);
const vec4 light1_position = vec4(0., 0., 0., 1.);

// Program inputs
uniform sampler2D baseMap;
#ifdef SPECULAR
uniform sampler2D specularMap;
#endif
#ifdef ILLUMINATION
uniform sampler2D illuminationMap;
#endif

// Per-fragment inputs
varying vec3 fragnormal;
varying vec3 viewspace_position;
varying vec2 fragtexcoords;


void main()
{
	vec3 lightDir = normalize(vec3(light0_position) - viewspace_position);
	vec3 lightDir2 = normalize(vec3(light1_position) - viewspace_position);
	vec3 n = fragnormal;
	float intensity = clamp(dot(lightDir, n), 0.1, 1.0);
	float specularIntensity = min(1.0, pow(max(0.0, dot(lightDir2, n)) * 1.2, 20.0));
	
	vec4 base = texture2D(baseMap, fragtexcoords.st);
#ifdef ILLUMINATION
	vec4 illumination = texture2D(illuminationMap, fragtexcoords.st);
#else
    vec4 illumination = vec4(0.0, 0.0, 0.0, 0.0);
#endif
#ifdef SPECULAR
	vec4 specular = texture2D(specularMap, fragtexcoords.st);
#else
	vec4 specular = vec4(0.0, 0.0, 0.0, 0.0);
#endif
	
	gl_FragColor = ((base - illumination) * intensity) + (specular * specularIntensity) + illumination;
}
