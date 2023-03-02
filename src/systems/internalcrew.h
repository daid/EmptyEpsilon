#pragma once

#include "ecs/system.h"


class InternalCrewSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
