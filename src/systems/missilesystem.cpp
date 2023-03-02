#include "systems/missilesystem.h"

#include "components/collision.h"
#include "components/missiletubes.h"
#include "ecs/query.h"
#include "multiplayer_server.h"


void MissileSystem::update(float delta)
{
    for(auto [entity, tubes] : sp::ecs::Query<MissileTubes>())
    {
        for(int n=0; n<tubes.count; n++)
        {
            auto& tube = tubes.mounts[n];
            if (tube.delay > 0.0f)
            {
                tube.delay -= delta * tubes.getSystemEffectiveness();
            }else{
                switch(tube.state)
                {
                case MissileTubes::MountPoint::State::Loading:
                    tube.state = MissileTubes::MountPoint::State::Loaded;
                    break;
                case MissileTubes::MountPoint::State::Unloading:
                    tube.state = MissileTubes::MountPoint::State::Empty;
                    if (tubes.storage[tube.type_loaded] < tubes.storage_max[tube.type_loaded])
                        tubes.storage[tube.type_loaded]++;
                    tube.type_loaded = MW_None;
                    break;
                case MissileTubes::MountPoint::State::Firing:
                    if (game_server)
                    {
                        spawnProjectile(entity, tube, 0, {});

                        tube.fire_count -= 1;
                        if (tube.fire_count > 0)
                        {
                            tube.delay = 1.5;
                        }
                        else
                        {
                            tube.state = MissileTubes::MountPoint::State::Empty;
                            tube.type_loaded = MW_None;
                        }
                    }
                    break;
                default:
                    break;
                }
            }
        }
    }
}

#include "spaceObjects/missiles/EMPMissile.h"
#include "spaceObjects/missiles/homingMissile.h"
#include "spaceObjects/mine.h"
#include "spaceObjects/missiles/nuke.h"
#include "spaceObjects/missiles/hvli.h"
#include "spaceObjects/spaceship.h"
#include "multiplayer_server.h"
#include "components/warpdrive.h"
#include <SDL_assert.h>


void MissileSystem::startLoad(sp::ecs::Entity source, MissileTubes::MountPoint& tube, EMissileWeapons type)
{
    if (!tube.canLoad(type))
        return;
    if (tube.state != MissileTubes::MountPoint::State::Empty)
        return;
    auto tubes = source.getComponent<MissileTubes>();
    if (!tubes) return;
    if (tubes->storage[type] <= 0)
        return;

    tube.state = MissileTubes::MountPoint::State::Loading;
    tube.delay = tube.load_time;
    tube.type_loaded = type;
    tubes->storage[type]--;
}

void MissileSystem::startUnload(sp::ecs::Entity source, MissileTubes::MountPoint& tube)
{
    if (tube.state == MissileTubes::MountPoint::State::Loaded)
    {
        tube.state = MissileTubes::MountPoint::State::Unloading;
        tube.delay = tube.load_time;
    }
}

void MissileSystem::fire(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target)
{
    Faction::didAnOffensiveAction(source);

    auto docking_port = source.getComponent<DockingPort>();
    if (docking_port && docking_port->state != DockingPort::State::NotDocking) return;

    auto warp = source.getComponent<WarpDrive>();
    if (warp && warp->current > 0.0f) return;
    if (tube.state != MissileTubes::MountPoint::State::Loaded) return;

    if (tube.type_loaded == MW_HVLI)
    {
        tube.fire_count = 5;
        tube.state = MissileTubes::MountPoint::State::Firing;
        tube.delay = 0.0;
    }else{
        spawnProjectile(source, tube, target_angle, target);
        tube.state = MissileTubes::MountPoint::State::Empty;
        tube.type_loaded = MW_None;
    }
}

void MissileSystem::spawnProjectile(sp::ecs::Entity source, MissileTubes::MountPoint& tube, float target_angle, sp::ecs::Entity target)
{
    auto source_transform = source.getComponent<sp::Transform>();
    if (!source_transform) return;
    auto fireLocation = source_transform->getPosition() + rotateVec2(glm::vec2(tube.position), source_transform->getRotation());
    switch(tube.type_loaded)
    {
    case MW_Homing:
        {
            P<HomingMissile> missile = new HomingMissile();
            missile->owner = *source.getComponent<SpaceObject*>();
            missile->setFactionId(missile->owner->getFactionId());
            missile->target = target;
            missile->setPosition(fireLocation);
            missile->setRotation(source_transform->getRotation() + tube.direction);
            missile->target_angle = target_angle;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(tube.size);
        }
        break;
    case MW_Nuke:
        {
            P<Nuke> missile = new Nuke();
            missile->owner = *source.getComponent<SpaceObject*>();
            missile->setFactionId(missile->owner->getFactionId());
            missile->target = target;
            missile->setPosition(fireLocation);
            missile->setRotation(source_transform->getRotation() + tube.direction);
            missile->target_angle = target_angle;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(tube.size);
        }
        break;
    case MW_Mine:
        {
            P<Mine> missile = new Mine();
            missile->owner = *source.getComponent<SpaceObject*>();
            missile->setFactionId(missile->owner->getFactionId());
            missile->setPosition(fireLocation);
            missile->setRotation(source_transform->getRotation() + tube.direction);
            missile->eject();
        }
        break;
    case MW_HVLI:
        {
            P<HVLI> missile = new HVLI();
            missile->owner = *source.getComponent<SpaceObject*>();
            missile->setFactionId(missile->owner->getFactionId());
            missile->setPosition(fireLocation);
            missile->setRotation(source_transform->getRotation() + tube.direction);
            missile->target_angle = source_transform->getRotation() + tube.direction;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(tube.size);
        }
        break;
    case MW_EMP:
        {
            P<EMPMissile> missile = new EMPMissile();
            missile->owner = *source.getComponent<SpaceObject*>();
            missile->setFactionId(missile->owner->getFactionId());
            missile->target = target;
            missile->setPosition(fireLocation);
            missile->setRotation(source_transform->getRotation() + tube.direction);
            missile->target_angle = target_angle;
            missile->category_modifier = MissileWeaponData::convertSizeToCategoryModifier(tube.size);
        }
        break;
    default:
        break;
    }
}

float MissileSystem::calculateFiringSolution(sp::ecs::Entity source, const MissileTubes::MountPoint& tube, sp::ecs::Entity target)
{
    if (!target)
        return std::numeric_limits<float>::infinity();
    const MissileWeaponData& data = MissileWeaponData::getDataFor(tube.type_loaded);
    if (data.turnrate == 0.0f)  //If the missile cannot turn, we cannot find a firing solution.
        return std::numeric_limits<float>::infinity();
    auto source_transform = source.getComponent<sp::Transform>();
    if (!source_transform)
        return std::numeric_limits<float>::infinity();
    auto target_transform = target.getComponent<sp::Transform>();
    if (!target_transform)
        return std::numeric_limits<float>::infinity();
    auto target_physics = target.getComponent<sp::Physics>();

    auto target_position = target_transform->getPosition();
    auto target_velocity = target_physics ? target_physics->getVelocity() : glm::vec2{0, 0};
    float target_velocity_length = glm::length(target_velocity);
    float missile_angle = vec2ToAngle(target_position - source_transform->getPosition());
    float turn_radius = ((360.0f / data.turnrate) * data.speed) / (2.0f * float(M_PI));
    float missile_exit_angle = source_transform->getRotation() + tube.direction;
    float target_radius = target_physics ? target_physics->getSize().x : 100.0f;

    for(int iterations=0; iterations<10; iterations++)
    {
        float angle_diff = angleDifference(missile_angle, missile_exit_angle);

        float left_or_right = 90;
        if (angle_diff > 0)
            left_or_right = -90;

        auto turn_center = source_transform->getPosition() + vec2FromAngle(missile_exit_angle + left_or_right) * turn_radius;
        auto turn_exit = turn_center + vec2FromAngle(missile_angle - left_or_right) * turn_radius;
        if (target_velocity_length < 1.0f)
        {
            //If the target is almost standing still, just target the position directly instead of using the velocity of the target in the calculations.
            float time_missile = glm::length(turn_exit - target_position) / data.speed;
            auto interception = turn_exit + vec2FromAngle(missile_angle) * data.speed * time_missile;
            float r = target_radius * 0.5f;
            if (glm::length2(interception - target_position) < r*r)
                return missile_angle;
            missile_angle = vec2ToAngle(target_position - turn_exit);
        }
        else
        {
            auto missile_velocity = vec2FromAngle(missile_angle) * data.speed;
            //Calculate the position where missile and the target will cross each others path.
            auto intersection = lineLineIntersection(target_position, target_position + target_velocity, turn_exit, turn_exit + missile_velocity);
            //Calculate the time it will take for the target and missile to reach the intersection
            float turn_time = fabs(angle_diff) / data.turnrate;
            float time_target = glm::length((target_position - intersection)) / target_velocity_length;
            float time_missile = glm::length(turn_exit - intersection) / data.speed + turn_time;
            //Calculate the time in which the radius will be on the intersection, to know in which time range we need to hit.
            float time_radius = (target_radius * 0.5f) / target_velocity_length;//TODO: This value could be improved, as it is allowed to be bigger when the angle between the missile and the ship is low
            // When both the missile and the target are at the same position at the same time, we can take a shot!
            if (fabsf(time_target - time_missile) < time_radius)
                return missile_angle;

            //When we cannot hit the target with this setup yet. Calculate a new intersection target, and aim for that.
            float guessed_impact_time = (time_target * target_velocity_length / (target_velocity_length + data.speed)) + (time_missile * data.speed / (target_velocity_length + data.speed));
            auto new_target_position = target_position + target_velocity * guessed_impact_time;
            missile_angle = vec2ToAngle(new_target_position - turn_exit);
        }
    }
    return std::numeric_limits<float>::infinity();
}
