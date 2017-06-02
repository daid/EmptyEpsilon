//Simple per-pixel light shader.

uniform sampler2D baseMap;
uniform sampler2D illuminationMap;
uniform sampler2D specularMap;

varying vec3 normal;
varying vec3 position;

void main()
{
	vec3 lightDir = normalize(vec3(gl_LightSource[0].position) - position);
	float intensity = max(0.1, dot(lightDir, normalize(normal)));
	
	vec3 base = texture2D(baseMap, gl_TexCoord[0].st).rgb;
	
	gl_FragColor = vec4((base * intensity), gl_Color.a);
}
