#pragma once

#include "ecs/system.h"
#include "systems/collision.h"


class EnergySystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
