#pragma once

#include <glm/gtc/type_precision.hpp>
#include <vector>
#include <stringImproved.h>


class Zone
{
public:
    glm::u8vec4 color{255,255,255, 0};
    std::vector<glm::vec2> outline;
    std::vector<uint16_t> triangles;
    string label;
    glm::vec2 label_offset;
    string skybox;
    float skybox_fade_distance = 0.0f; // distance from edge of zone for skybox to fully fade in
    float radius;
    bool zone_dirty = true;

    void updateTriangles();
};
