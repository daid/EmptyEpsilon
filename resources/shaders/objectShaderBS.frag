//Simple per-pixel light shader.

uniform sampler2D baseMap;
uniform sampler2D specularMap;

varying vec3 normal;
varying vec3 position;

void main()
{
	vec3 lightDir = normalize(vec3(gl_LightSource[0].position) - position);
	vec3 lightDir2 = normalize(vec3(gl_LightSource[1].position) - position);
	vec3 n = normalize(normal);
	float intensity = max(0.1, dot(lightDir, n));
	float specularIntensity = min(1.0, pow(max(0.0, dot(lightDir2, n)) * 1.2, 20.0));
	
	vec3 base = texture2D(baseMap, gl_TexCoord[0].st).rgb;
	vec3 specular = texture2D(specularMap, gl_TexCoord[0].st).rgb;
	
	gl_FragColor = vec4(((base) * intensity) + (specular * specularIntensity), gl_Color.a);
}
