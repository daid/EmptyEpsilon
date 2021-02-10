//Simple per-pixel light shader.

uniform vec3 camera_position;

void main()
{
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position = gl_ProjectionMatrix * ((gl_ModelViewMatrix * gl_Vertex) + vec4((gl_TexCoord[0].x - 0.5) * gl_Color.a, (gl_TexCoord[0].y - 0.5) * gl_Color.a, 0.0, 0.0));
	gl_FrontColor = vec4(gl_Color.rgb, 1.0);
	gl_BackColor = gl_FrontColor;
}
