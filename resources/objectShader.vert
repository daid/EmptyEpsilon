//Simple per-pixel light shader.

varying vec3 normal;
varying vec3 position;

void main()
{
	normal = normalize(gl_NormalMatrix * gl_Normal);
	position = vec3(gl_ModelViewMatrix * gl_Vertex);
	
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
	gl_FrontColor = gl_Color;
	gl_BackColor = gl_Color;
}
