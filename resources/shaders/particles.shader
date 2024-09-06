[vertex]

// Constants

// Program inputs
uniform mat4 projection;
uniform mat4 view;

// Per-vertex inputs
attribute vec4 center_and_size;
attribute vec4 color_and_texcoords;

// Per-vertex outputs
varying vec3 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    // Decode texcoords.
    // As an input we get a value with the following encoding mapping:
    // y is associated with 0.7.
    // x is associated with 0.2.
    // y = 1 iff input > 0.65, 0 otherwise.
    // x = 1 iff (input - 0.7 * y) > 0.1, 0 otherwise. 
    // 0.00 -> { 0, 0 } > 0.65 ? -0  * 0.00 = 0.00 > 0.10 ? 0
    // 0.70 -> { 0, 1 } > 0.65 ? -0  * 0.00 = 0.20 > 0.10 ? y
    // 0.20 -> { 1, 0 } > 0.65 ? -1  * 0.65 = 0.05 > 0.10 ? n
    // 0.90 -> { 1, 1 } > 0.65 ? -1  * 0.65 = 0.15 > 0.10 ? y
    vec2 texcoords = vec2(0., step(0.65, color_and_texcoords.w));
    texcoords.x = step(0.10, color_and_texcoords.w - 0.65 * texcoords.y);
    
    vec4 viewspace_center = view * vec4(center_and_size.xyz, 1.0);
    vec4 viewspace_halfextents = vec4(texcoords.x - .5, texcoords.y - .5, 0., 0.) * center_and_size.w;

    // Outputs to fragment shader
    gl_Position = projection * (viewspace_center + viewspace_halfextents);
    fragtexcoords = texcoords;
    fragcolor = color_and_texcoords.rgb;
}

[fragment]

// Program inputs
uniform sampler2D textureMap;

// Per-fragment inputs
varying vec3 fragcolor;
varying vec2 fragtexcoords;

void main()
{
    gl_FragColor = texture2D(textureMap, fragtexcoords.st) * vec4(fragcolor, 1.);
}
