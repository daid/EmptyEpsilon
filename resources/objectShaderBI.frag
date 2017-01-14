//Simple per-pixel light shader.

uniform sampler2D baseMap;
uniform sampler2D illuminationMap;

varying vec3 normal;
varying vec3 position;

void main()
{
	vec3 lightDir = normalize(vec3(gl_LightSource[0].position) - position);
	vec3 n = normalize(normal);
	float intensity = max(0.1, dot(lightDir, n));
	
	vec3 base = texture2D(baseMap, gl_TexCoord[0].st).rgb;
	vec3 illumination = texture2D(illuminationMap, gl_TexCoord[0].st).rgb;
	
	gl_FragColor = vec4(((base - illumination) * intensity) + illumination, gl_Color.a);
}
