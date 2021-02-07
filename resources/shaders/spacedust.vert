#version 120

// Shader constants
const vec2 distance_limits = vec2(100., 500.);
const float two_pi = 2. * radians(180.);
const float max_input_seed = 32767.;

// Utility functions
// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
vec2 rand(const vec2 v)
{
    return fract(sin(v) * 43758.5453123);
}

float getRadius(const float value)
{
    return distance_limits.x + (distance_limits.y - distance_limits.x) * value;
}

// Program inputs.
uniform mat4 projection;
uniform mat4 model_view;

uniform vec2 velocity;
uniform vec2 center;
uniform float time;

// Per-vertex inputs
attribute float vertex_hash; // Passed in as a signed byte, [-32767,32767], non-zero

void main()
{
    // Two points of the same line
    // Share the same absolute seed.
    float seed = abs(vertex_hash);

    // From the seed, we derive an offset.
    // It places each point at a different base position on a sphere around the spaceship.
    
    // Infer spherical coordinates from the seed.
    float theta = mod(seed, 256.); // [0,255]
    float phi = floor(seed / 256.); // [0,127]
    vec2 theta_phi = two_pi * rand(vec2(theta, phi));

    // Now we can put our particle offset on the sphere.
    // We use a minimum radius to avoid having useless particles inside the ship.
    vec4 sincos = vec4(sin(theta_phi), cos(theta_phi));

    // Standard spherical to cartesian:
    // x = sin(theta) * cos(phi)
    // y = sin(theta) * sin(phi)
    // z = cos(theta)
    float radius = getRadius(seed / max_input_seed); 
    vec3 offset = radius * vec3(sincos.x * sincos.wy, sincos.z);

    
    // Give the illusion of movement by offset further alongside the velocity vector.
    // Use the seed to have particules at different offsets, with different frequencies.
    float speed = length(velocity);
    float particle_frequency =  radius;
    offset.xy -= mod(time * speed + seed, particle_frequency) * normalize(velocity);
    
    // Center the box around the ship's axis of movement.
    offset.xy += particle_frequency / 2. * normalize(velocity);

    // We use the alternating vertex sign to determine either end of the line.
    vec2 line_end = -sign(vertex_hash) * velocity / 100.;
    
    gl_Position = projection * model_view * vec4(center + line_end + offset.xy, offset.z, 1.);
}
