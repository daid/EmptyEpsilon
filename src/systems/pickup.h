#pragma once

#include "ecs/system.h"
#include "systems/collision.h"


class PickupSystem : public sp::ecs::System, public sp::CollisionHandler
{
public:
    PickupSystem();

    void update(float delta) override;

    void collision(sp::ecs::Entity a, sp::ecs::Entity b, float force) override;
};
