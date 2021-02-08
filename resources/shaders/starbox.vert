#version 120

// Program inputs
uniform mat4 projection;
uniform mat4 model_view;
uniform float scale;

// Per-vertex inputs
attribute vec3 position;

// Per-vertex outputs
varying vec3 texcoords;

void main()
{
    // For texcoords, undo flipping the Z axis and rotation around X axis
    // from code.
    texcoords = vec3(position.x, position.z, -position.y);

    // We get rid of the translation component, so the box gets always centered around the camera.
    gl_Position = projection * mat4(mat3(model_view)) * vec4(scale * position, 1.);
}
