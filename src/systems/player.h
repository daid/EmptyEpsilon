#pragma once

#include "ecs/system.h"


class PlayerSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
