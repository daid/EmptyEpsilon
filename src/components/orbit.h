#pragma once

#include "ecs/entity.h"

// Component to orbit around another object or a fixed point
class Orbit
{
public:
    sp::ecs::Entity target;
    glm::vec2 center;
    float distance = 1000.0f;
    float time = 60.0f;
};
