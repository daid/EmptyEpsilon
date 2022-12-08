#pragma once

#include "ecs/system.h"
#include "components/missiletubes.h"


class MissileSystem : public sp::ecs::System
{
public:
    void update(float delta) override;

    static void startLoad(sp::ecs::Entity source, MissileTubes::MountPoint& tube, EMissileWeapons type);
    static void startUnload(sp::ecs::Entity source, MissileTubes::MountPoint& tube);
    static void fire(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target);
    static float calculateFiringSolution(sp::ecs::Entity source, const MissileTubes::MountPoint& tube, sp::ecs::Entity target);

private:
    static void spawnProjectile(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float angle, sp::ecs::Entity target);
};
