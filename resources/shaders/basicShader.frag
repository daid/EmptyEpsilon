//Simple per-pixel light shader.

uniform sampler2D textureMap;

void main()
{
	gl_FragColor = texture2D(textureMap, gl_TexCoord[0].st) * gl_Color;
	gl_FragColor.rgb *= gl_Color.a;
}
