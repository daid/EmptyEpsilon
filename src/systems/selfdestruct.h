#pragma once

#include "ecs/system.h"
#include "ecs/entity.h"


class SelfDestructSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    static bool activate(sp::ecs::Entity entity);
};
