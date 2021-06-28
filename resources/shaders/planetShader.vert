#version 120
//Simple per-pixel light shader.

// Program inputs
uniform mat4 projection;

// Per-vertex inputs
attribute vec3 position;
attribute vec3 normal;
attribute vec2 texcoords;

// Per-vertex outputs
varying vec3 fragnormal;
varying vec3 viewspace_position;
varying vec2 fragtexcoords;

void main()
{
	fragnormal = normalize(gl_NormalMatrix * normal);
	vec4 modelview_position = gl_ModelViewMatrix * vec4(position, 1.);
	viewspace_position = vec3(modelview_position);
	
	fragtexcoords = texcoords;
	gl_Position = projection * modelview_position;
}
