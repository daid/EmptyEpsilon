#pragma once

#include "ecs/system.h"


class ShieldSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
