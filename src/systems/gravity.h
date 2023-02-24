#pragma once

#include "ecs/system.h"


class GravitySystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
