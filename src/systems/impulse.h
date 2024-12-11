#pragma once

#include "ecs/system.h"


class ImpulseSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
