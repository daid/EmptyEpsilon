[vertex]
//Simple per-pixel light shader.

// Program inputs
uniform mat4 u_model;
uniform mat4 u_view;
uniform mat4 u_projection;

// Per-vertex inputs
attribute vec3 a_position;
attribute vec3 a_normal;
attribute vec2 a_texcoords;
attribute vec3 a_tangent;

// Per-vertex outputs
varying vec3 v_normal;
varying vec2 v_texcoords;
varying vec3 v_tangent;

void main()
{
	v_normal = normalize((u_model * vec4(a_normal, 0.)).xyz);
	v_tangent = normalize((u_model * vec4(a_tangent, 0.)).xyz);
	vec4 modelview_position = u_view * u_model * vec4(a_position, 1.);
	
	v_texcoords = a_texcoords;
	gl_Position = u_projection * modelview_position;
}

[fragment]
//Simple per-pixel light shader.

// Program inputs
uniform vec3 u_ambientLightDirection;

uniform sampler2D u_baseMap;
#ifdef SPECULAR
uniform vec3 u_specularLightDirection;
uniform sampler2D u_specularMap;
#endif
#ifdef ILLUMINATION
uniform sampler2D u_illuminationMap;
uniform vec4 u_illuminationModulation;
#endif
#ifdef NORMAL
uniform sampler2D u_normalMap;
#endif

// Per-fragment inputs
varying vec3 v_normal;
varying vec2 v_texcoords;
varying vec3 v_tangent;

void main()
{
	vec3 n = v_normal;
#ifdef NORMAL
	vec3 bitangent = cross(v_tangent, n);
	mat3 TBN = mat3(normalize(v_tangent), normalize(bitangent), normalize(n));
	n = normalize(TBN * (texture2D(u_normalMap, v_texcoords.st).rgb * 2.0 - 1.0)); 
#endif
	float intensity = max(0.1, dot(u_ambientLightDirection, n));
	
	vec4 base = texture2D(u_baseMap, v_texcoords.st);
#ifdef ILLUMINATION
	vec4 illumination = texture2D(u_illuminationMap, v_texcoords.st) * u_illuminationModulation;
#else
    vec4 illumination = vec4(0.0, 0.0, 0.0, 0.0);
#endif
#ifdef SPECULAR
	float specularIntensity = min(1.0, pow(max(0.0, dot(u_specularLightDirection, n)) * 1.2, 20.0));
	vec4 specular = specularIntensity * texture2D(u_specularMap, v_texcoords.st);
#else
	vec4 specular = vec4(0.0, 0.0, 0.0, 0.0);
#endif

	gl_FragColor = ((base - illumination) * intensity) + specular + illumination;
}
