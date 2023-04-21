#pragma once

#include "ecs/system.h"
#include "components/missiletubes.h"
#include "systems/collision.h"


class MissileSystem : public sp::ecs::System, public sp::CollisionHandler
{
public:
    MissileSystem();

    void update(float delta) override;
    void collision(sp::ecs::Entity a, sp::ecs::Entity b, float force) override;

    static void startLoad(sp::ecs::Entity source, MissileTubes::MountPoint& tube, EMissileWeapons type);
    static void startUnload(sp::ecs::Entity source, MissileTubes::MountPoint& tube);
    static void fire(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target);
    static float calculateFiringSolution(sp::ecs::Entity source, const MissileTubes::MountPoint& tube, sp::ecs::Entity target);

private:
    static void spawnProjectile(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float angle, sp::ecs::Entity target);
};
