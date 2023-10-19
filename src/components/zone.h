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
    float radius;
};
