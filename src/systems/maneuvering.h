#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"


class ManeuveringSystem : public sp::ecs::System
{
public:
    void update(float delta) override;
};
