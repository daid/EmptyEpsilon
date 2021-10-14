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
varying vec2 fragtexcoords;

void main()
{
	fragnormal = normalize((model * vec4(normal, 0.)).xyz);
	vec4 modelview_position = view * model * vec4(position, 1.);
	
	fragtexcoords = texcoords;
	gl_Position = projection * modelview_position;
}

[fragment]
//Simple per-pixel light shader.

// Program inputs
uniform vec3 ambientLightDirection;

uniform sampler2D baseMap;
#ifdef SPECULAR
uniform vec3 specularLightDirection;
uniform sampler2D specularMap;
#endif
#ifdef ILLUMINATION
uniform sampler2D illuminationMap;
#endif

// Per-fragment inputs
varying vec3 fragnormal;
varying vec2 fragtexcoords;


void main()
{
	vec3 n = fragnormal;
	float intensity = max(0.1, dot(ambientLightDirection, n));
	
	vec4 base = texture2D(baseMap, fragtexcoords.st);
#ifdef ILLUMINATION
	vec4 illumination = texture2D(illuminationMap, fragtexcoords.st);
#else
    vec4 illumination = vec4(0.0, 0.0, 0.0, 0.0);
#endif
#ifdef SPECULAR
	float specularIntensity = min(1.0, pow(max(0.0, dot(specularLightDirection, n)) * 1.2, 20.0));
	vec4 specular = specularIntensity * texture2D(specularMap, fragtexcoords.st);
#else
	vec4 specular = vec4(0.0, 0.0, 0.0, 0.0);
#endif
	
	gl_FragColor = ((base - illumination) * intensity) + specular + illumination;
}
