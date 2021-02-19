//Simple per-pixel light shader.

const vec4 light0_position = vec4(20000., 20000., 20000., 1.0);
const vec4 light1_position = vec4(0., 0., 0., 1.);

// Program inputs
uniform sampler2D baseMap;
uniform sampler2D specularMap;
uniform sampler2D illuminationMap;

uniform vec4 color;

// Per-fragment inputs
varying vec3 fragnormal;
varying vec3 viewspace_position;
varying vec2 fragtexcoords;


void main()
{
	vec3 lightDir = normalize(vec3(light0_position) - viewspace_position);
	vec3 lightDir2 = normalize(vec3(light1_position) - viewspace_position);
	vec3 n = fragnormal;
	float intensity = max(0.1, dot(lightDir, n));
	float specularIntensity = min(1.0, pow(max(0.0, dot(lightDir2, n)) * 1.2, 20.0));
	
	vec3 base = texture2D(baseMap, fragtexcoords.st).rgb;
	vec3 illumination = texture2D(illuminationMap, fragtexcoords.st).rgb;
	vec3 specular = texture2D(specularMap, fragtexcoords.st).rgb;
	
	gl_FragColor = vec4(((base - illumination) * intensity) + (specular * specularIntensity) + illumination, color.a);
	//gl_FragColor = vec4(base, gl_Color.a);
	//gl_FragColor = vec4(specular * specularIntensity, gl_Color.a);
}
