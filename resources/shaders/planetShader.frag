//Simple per-pixel light shader.

uniform sampler2D baseMap;
uniform sampler2D illuminationMap;
uniform sampler2D specularMap;
uniform vec4 atmosphereColor;

varying vec3 normal;
varying vec3 position;

void main()
{
	vec3 lightDir = normalize(vec3(gl_LightSource[1].position) - position);
	float intensity = max(0.0, dot(lightDir, normalize(normal)));
	
	vec3 base = texture2D(baseMap, gl_TexCoord[0].st).rgb;
	
	gl_FragColor = vec4((base * intensity) + (atmosphereColor.rgb * (1.0 - intensity)), gl_Color.a);
}
