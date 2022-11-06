#pragma once

#include "ecs/system.h"
#include "systems/collision.h"


class DockingSystem : public sp::ecs::System, public sp::CollisionHandler
{
public:
    DockingSystem();

    void update(float delta) override;

    void collision(sp::ecs::Entity a, sp::ecs::Entity b, float force) override;
};
