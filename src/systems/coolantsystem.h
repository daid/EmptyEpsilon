#pragma once

#include "ecs/system.h"
#include "systems/collision.h"


class CoolantSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
