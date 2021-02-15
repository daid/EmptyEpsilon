#version 120

// Constants
// ES2 does not support constant arrays
// this is a way around (since vectors can be indexed)
const vec4 texcoord_s = vec4(0., 1., 1., 0.);
const vec4 texcoord_t = vec4(0., 0., 1., 1.);

const int max_instance_count = 60; // ! Sync up with code !
// Computing the instance limit:
// GLSL 1.00: Appendix A: Limitations for ES 2.0111 7 Counting of Varyings and Uniforms
// Spec says *minimum* of 128 rows x 4 columns for uniforms ()
// As uniform inputs, we have our two matrices - 4 rows each.
// That leaves us with (128 - 8 = ) 120 rows.
// we need two rows per instance, hence 60 instances.


// Program inputs
uniform mat4 projection;
uniform mat4 model_view;

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

    vec4 viewspace_center = model_view * vec4(center, 1.0);
    vec4 viewspace_halfextents = vec4(texcoords.x - .5, texcoords.y - .5, 0., 0.) * color_and_size.w;

    // Outputs to fragment shader
    gl_Position = projection * (viewspace_center + viewspace_halfextents);
    fragtexcoords = texcoords;
    fragcolor = color_and_size.rgb;
}
