#include "spaceObjects/cpuShip.h"
#include "spaceObjects/nebula.h"
#include "ai/evasionAI.h"
#include "ai/aiFactory.h"
#include "random.h"
#include "systems/collision.h"
#include "components/missiletubes.h"
#include "components/beamweapon.h"
#include "components/collision.h"
#include "components/jumpdrive.h"
#include "components/warpdrive.h"
#include "components/impulse.h"
#include "components/target.h"
#include "systems/radarblock.h"


REGISTER_SHIP_AI(EvasionAI, "evasion");

EvasionAI::EvasionAI(sp::ecs::Entity owner)
: ShipAI(owner)
{
    evasion_calculation_delay = 0.0;
    is_evading = false;
}

bool EvasionAI::canSwitchAI()
{
    return true;
}

void EvasionAI::run(float delta)
{
    if (evasion_calculation_delay > 0.0f)
        evasion_calculation_delay -= delta;
    ShipAI::run(delta);
}

// @TODO: consider jump drives
void EvasionAI::runOrders()
{
    auto ai = owner.getComponent<AIController>();
    if (!ai) return;
    auto docking_port = owner.getComponent<DockingPort>();
    //When we are not attacking a target, follow orders
    switch(ai->orders)
    {
    case AIOrder::FlyTowards:
        if (!evadeIfNecessary())
        {
            ShipAI::runOrders();
        }
        break;
    case AIOrder::Dock:
        if (ai->order_target && (!docking_port || docking_port->state == DockingPort::State::NotDocking))
        {
            auto ot = ai->order_target.getComponent<sp::Transform>();
            auto transform = owner.getComponent<sp::Transform>();
            if (ot && transform) {
                auto diff = transform->getPosition() - ot->getPosition();
                float dist = glm::length(diff);
                auto physics = ai->order_target.getComponent<sp::Physics>();
                if (dist < 3000 + (physics ? physics->getSize().x : 0.0f))
                {
                    // if close to the docking target: make a run for it
                    return ShipAI::runOrders();
                }
            }
        }
        if (!evadeIfNecessary())
        {
            ShipAI::runOrders();
        }
        break;
    case AIOrder::FlyTowardsBlind: // flying blind means ignoring enemies
    default:
        ShipAI::runOrders();
    }
}

bool EvasionAI::evadeIfNecessary()
{
    if (evasion_calculation_delay > 0.0f){
        if (is_evading)
        {
            flyTowards(evasion_location, 100.0);
        }
        return is_evading;
    }
    evasion_calculation_delay = random(0.25, 0.5);
    auto transform = owner.getComponent<sp::Transform>();
    if (!transform)
        return false;

    is_evading = false;

    auto position = transform->getPosition();
    float scan_radius = 9000.0;

    // NOT AN OBJECT ON THE PLANE, but it represents an escape vector.
    // It tracks which direction is the best to run to (angle) and the strength of the desire to go there (distance from origin)
    glm::vec2 evasion_vector = glm::vec2(0, 0);
    for(auto entity : sp::CollisionSystem::queryArea(position - glm::vec2(scan_radius, scan_radius), position + glm::vec2(scan_radius, scan_radius)))
    {
        if (Faction::getRelation(owner, entity) != FactionRelation::Enemy)
            continue;
        if (RadarBlockSystem::isRadarBlockedFrom(position, entity, short_range))
            continue;
        auto et = entity.getComponent<sp::Transform>();
        if (!et) continue;
        float score = evasionDangerScore(entity, scan_radius);
        if (score == std::numeric_limits<float>::min())
            continue;

        auto vec = position - et->getPosition();
        vec = glm::normalize(vec) * score;
        evasion_vector += vec;
    }

    if (glm::length2(evasion_vector) > 0.0f) // if: evasion is necessary
    {
        // have a bias to your original target.
        // this makes ships fly around enemies rather than straight running from them
        auto ai = owner.getComponent<AIController>();
        auto target_position = ai->order_target_location;
        if (auto t = ai->order_target.getComponent<sp::Transform>())
        {
            target_position = t->getPosition();
        }

        float distance = 12000.0f; // should be big enough for jump drive to be considered
        if (glm::length(target_position) > 0.0f)
        {
            // ships with warp or jump drives have a tendency to fly past enemies quickly
            evasion_vector += glm::normalize(target_position - position) * ((owner.hasComponent<WarpDrive>() || owner.hasComponent<JumpDrive>()) ? 15.0f : 5.0f);
            distance = std::min(distance, glm::length(target_position - position));
        }

        evasion_vector = glm::normalize(evasion_vector) * float(distance);

        evasion_location = position + evasion_vector;
        flyTowards(evasion_location, 100.0);
        is_evading = true;
    }
    return is_evading;
}

// calculate how much of a threat an enemy ship is
float EvasionAI::evasionDangerScore(sp::ecs::Entity ship, float scan_radius)
{
    float enemy_max_beam_range = 0.0;
    float enemy_beam_dps = 0.0;
    float enemy_missile_strength = 0.0;

    auto tubes = ship.getComponent<MissileTubes>();
    if (tubes) {
        for(auto& tube : tubes->mounts)
        {
            if (tube.state != MissileTubes::MountPoint::State::Empty)
                enemy_missile_strength += getMissileWeaponStrength(tube.type_loaded);
        }
    }

    auto beamsystem = ship.getComponent<BeamWeaponSys>();
    if (beamsystem) {
        for(auto& mount : beamsystem->mounts) {
            if (mount.range > 0.0f) {
                enemy_max_beam_range = std::max(enemy_max_beam_range, mount.range);
                if (mount.cycle_time > 0.0f)
                    enemy_beam_dps += mount.damage / mount.cycle_time;
            }
        }
    }

    if (enemy_missile_strength <= 0.0f && (enemy_beam_dps <= 0.0f || enemy_max_beam_range <= 0.0f))
    {
        // enemy is not a threat
        return 0.0;
    }
    auto st = ship.getComponent<sp::Transform>();
    if (!st) return 0.0;
    auto ot = owner.getComponent<sp::Transform>();
    if (!ot) return 0.0;

    auto position_difference = st->getPosition() - ot->getPosition();
    float distance = glm::length(position_difference);
    auto physics = owner.getComponent<sp::Physics>();
    if (physics) enemy_max_beam_range += physics->getSize().x;
    physics = ship.getComponent<sp::Physics>();
    if (physics) enemy_max_beam_range += physics->getSize().x;

    float danger = 0.0;
    if (enemy_missile_strength > 0.0f)
    {
        danger += enemy_missile_strength / 10.f * (scan_radius - std::max(distance, 5000.0f)) / (scan_radius - 4000.0f);
    }

    if (enemy_max_beam_range > 0.0f && distance < 4*enemy_max_beam_range)
    {
        // danger falls off the further we are away from beam range
        danger += enemy_beam_dps * (4*enemy_max_beam_range - std::max(distance, enemy_max_beam_range)) / (3 * enemy_max_beam_range);
    }

    if (auto oi = owner.getComponent<ImpulseEngine>()) {
        if (auto si = ship.getComponent<ImpulseEngine>()) {
            if (std::max(si->max_speed_forward, si->max_speed_reverse) > std::max(oi->max_speed_forward, oi->max_speed_reverse))
                danger *= 1.5f; //yes that sound stupid somebody had mounted its forward reactor on reverse but...
        }
    }
    if (ship.hasComponent<Target>() && ship.getComponent<Target>()->entity == owner)
        danger = (danger + 1) * 2;
    return danger;
}