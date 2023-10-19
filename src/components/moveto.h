#pragma once

#include <glm/vec2.hpp>
#include "script/callback.h"



// Component to move to a specific spot at a fixed speed
class MoveTo
{
public:
    float speed = 1000.0;
    glm::vec2 target{0, 0};
    sp::script::Callback on_arrival;
};
