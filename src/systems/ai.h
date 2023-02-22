#pragma once

#include "ecs/system.h"


class AISystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
