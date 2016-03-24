uniform sampler2D texture;
uniform vec2 inputSize;
uniform vec2 textureSize;
uniform float amount;

void main(void) {
	vec2 coord = gl_TexCoord[0].xy * textureSize / inputSize;
	vec2 cen = vec2(0.5, 0.5) - coord;
	vec2 mcen = amount*log(length(cen) * 0.5 + 0.75)*normalize(cen);
	gl_FragColor = texture2D(texture, gl_TexCoord[0].xy+mcen * inputSize / textureSize);
}
