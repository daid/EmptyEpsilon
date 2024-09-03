[vertex]
uniform vec4 color;
uniform mat4 view;
uniform mat4 projection;
uniform mat4 model;

attribute vec3 position;
attribute vec2 texcoords;

varying vec2 fragtexcoords;
varying vec4 fragcolor;

void main()
{
    fragtexcoords = texcoords;
    gl_Position = projection * ((view * model * vec4(position, 1.0)) + vec4((texcoords.x - 0.5) * color.a, (texcoords.y - 0.5) * color.a, 0.0, 0.0));
    fragcolor = vec4(color.rgb, 1.0);
}

[fragment]
uniform sampler2D textureMap;
uniform float time;
varying vec4 fragcolor;
varying vec2 fragtexcoords;

// Adjusted parameters
const float spiralIntensity = 0.08;
const float spiralFrequency = 5.0;
const float spiralSpeed = 0.3;
const float inwardIntensity = 0.15;
const float inwardFrequency = 3.0;
const float inwardSpeed = 0.1;
const float colorShiftIntensity = 0.05;
const float colorShiftFrequency = 1.0;
const float effectSize = 0.6; // Adjust this value to control how large the effect grows

void main()
{
    vec2 center = vec2(0.5, 0.5);
    vec2 toCenter = center - fragtexcoords;
    float dist = length(toCenter);
    
    // Limit the effect to a certain radius
    float normalizedDist = smoothstep(0.0, effectSize, dist);
    float effectStrength = 1.0 - normalizedDist;
    
    float angle = atan(toCenter.y, toCenter.x);
    float spiral = sin(dist * spiralFrequency - time * spiralSpeed + angle) * spiralIntensity;
    
    float inward = sin(dist * inwardFrequency - time * inwardSpeed) * inwardIntensity;
    
    vec2 distortion = normalize(toCenter) * (spiral + inward) * effectStrength;
    vec2 distortedCoords = fragtexcoords + distortion;
    
    gl_FragColor = texture2D(textureMap, distortedCoords) * fragcolor;
    
    float colorShift = sin(dist * colorShiftFrequency - time) * colorShiftIntensity + 1.0;
    gl_FragColor.rgb *= vec3(colorShift, 1.0, 1.0/colorShift);
}