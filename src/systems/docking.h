#pragma once

#include "ecs/system.h"
#include "systems/collision.h"


class DockingSystem : public sp::ecs::System, public sp::CollisionHandler
{
public:
    DockingSystem();

    void update(float delta) override;
    static bool canStartDocking(sp::ecs::Entity entity);

    static void requestDock(sp::ecs::Entity entity, sp::ecs::Entity target);
    static void requestUndock(sp::ecs::Entity entity);
    static void abortDock(sp::ecs::Entity entity);

    void collision(sp::ecs::Entity a, sp::ecs::Entity b, float force) override;
};
