#pragma once

#include "ecs/system.h"


class BasicMovementSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
