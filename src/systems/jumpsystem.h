#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"


class JumpSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    static void initializeJump(sp::ecs::Entity entity, float distance);
};
