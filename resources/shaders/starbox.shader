[vertex]

// Program inputs
uniform mat4 u_projection;
uniform mat4 u_view;
uniform float u_scale;

// Per-vertex inputs
attribute vec3 a_position;

// Per-vertex outputs
varying vec3 v_texcoords;

void main()
{
    // For texcoords, undo flipping the Z axis and rotation around X axis
    // from code.
    v_texcoords = vec3(a_position.x, a_position.z, -a_position.y);

    // We get rid of the translation component, so the box gets always centered around the camera.
    gl_Position = u_projection * mat4(mat3(u_view)) * vec4(u_scale * a_position, 1.);
}

[fragment]

// Program inputs
uniform samplerCube u_global_starbox;
uniform samplerCube u_local_starbox;
uniform float u_starbox_lerp;

// Per-fragment inputs.
varying vec3 v_texcoords;

void main()
{
    vec4 global_color = textureCube(u_global_starbox, v_texcoords);
    vec4 local_color = textureCube(u_local_starbox, v_texcoords);

    gl_FragColor = mix(global_color, local_color, u_starbox_lerp);
}
