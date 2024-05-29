#pragma once

#include "ecs/system.h"
#include "components/missile.h"
#include "components/missiletubes.h"
#include "systems/collision.h"
#include "systems/radar.h"


class MissileSystem
: public sp::ecs::System
, public sp::CollisionHandler
, public RenderRadarInterface<DelayedExplodeOnTouch, 10, RadarRenderSystem::FlagGM>
{
public:
    MissileSystem();

    void update(float delta) override;
    void collision(sp::ecs::Entity a, sp::ecs::Entity b, float force) override;
    void renderOnRadar(sp::RenderTarget& renderer, sp::ecs::Entity e, glm::vec2 screen_position, float scale, float rotation, DelayedExplodeOnTouch& component) override;

    static void startLoad(sp::ecs::Entity source, MissileTubes::MountPoint& tube, EMissileWeapons type);
    static void startUnload(sp::ecs::Entity source, MissileTubes::MountPoint& tube);
    static void fire(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target);
    static float calculateFiringSolution(sp::ecs::Entity source, const MissileTubes::MountPoint& tube, sp::ecs::Entity target);

private:
    static void explode(sp::ecs::Entity source, sp::ecs::Entity target, ExplodeOnTouch& eot);
    static void spawnProjectile(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float angle, sp::ecs::Entity target);
};
