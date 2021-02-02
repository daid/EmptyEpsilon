#version 120

// Constants
// ES2 does not support constant arrays
// this is a way around (since vectors can be indexed)
const vec4 texcoord_s = vec4(0., 1., 1., 0.);
const vec4 texcoord_t = vec4(0., 0., 1., 1.);

const int max_instance_count = 64; // ! Sync up with code !

// Program inputs
// From the spec, we're allowed 128 rows x 4 columns.
// Each array entry is 1 row.
// Since we need two uniforms, we saturate at 64 each.
uniform vec3 centers[max_instance_count];
uniform vec4 color_and_sizes[max_instance_count]; // RGB color, alpha channel = size.

// Per-vertex inputs
attribute float vertex_id; // actually a uint8 (must be float in ES2)

// Per-vertex outputs
varying vec3 fragcolor;
varying vec2 fragtexcoords;


vec2 resolve_texcoords(int vertex_id)
{
    return vec2(texcoord_s[vertex_id], texcoord_t[vertex_id]);
}

void main()
{
    int instance_id = int(floor(vertex_id / 4.));
    int relative_vertex_id = int(mod(vertex_id, 4.));
    vec3 center = centers[instance_id];
    vec4 color_and_size = color_and_sizes[instance_id];
    vec2 texcoords = resolve_texcoords(relative_vertex_id);

    vec4 viewspace_center = gl_ModelViewMatrix * vec4(center, 1.0);
    vec4 viewspace_halfextents = vec4(texcoords.x - .5, texcoords.y - .5, 0., 0.) * color_and_size.w;

    // Outputs to fragment shader
    gl_Position = gl_ProjectionMatrix * (viewspace_center + viewspace_halfextents);
    fragtexcoords = texcoords;
    fragcolor = color_and_size.rgb;
}
