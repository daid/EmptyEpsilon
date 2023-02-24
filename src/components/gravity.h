#pragma once

#include <glm/vec2.hpp>
#include "scriptInterface.h"


class Gravity
{
public:
    float range = 5000.0f;
    float force = 50.0f;
    bool damage = false;

    glm::vec2 wormhole_target{};
    ScriptSimpleCallback on_teleportation;
};
