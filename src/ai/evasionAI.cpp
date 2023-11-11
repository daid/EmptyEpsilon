#include "spaceObjects/cpuShip.h"
#include "spaceObjects/nebula.h"
#include "ai/evasionAI.h"
#include "ai/aiFactory.h"
#include "random.h"


REGISTER_SHIP_AI(EvasionAI, "evasion");

EvasionAI::EvasionAI(CpuShip* owner)
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
    //When we are not attacking a target, follow orders
    switch(owner->getOrder())
    {
    case AI_FlyTowards:
        if (!evadeIfNecessary())
        {
            ShipAI::runOrders();
        }
        break;
    case AI_Dock:
        if (owner->getOrderTarget() && owner->docking_state == DS_NotDocking)
        {
            auto target_position = owner->getOrderTarget()->getPosition();
            auto diff = owner->getPosition() - target_position;
            float dist = glm::length(diff);
            if (dist < 3000 + owner->getOrderTarget()->getRadius())
            {
                // if close to the docking target: make a run for it
                return ShipAI::runOrders();
            }
        }
        if (!evadeIfNecessary())
        {
            ShipAI::runOrders();
        }
        break;
    case AI_FlyTowardsBlind: // flying blind means ignoring enemies
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

    is_evading = false;

    auto position = owner->getPosition();
    float scan_radius = 9000.0;

    PVector<Collisionable> objectList = CollisionManager::queryArea(position - glm::vec2(scan_radius, scan_radius), position + glm::vec2(scan_radius, scan_radius));

    // NOT AN OBJECT ON THE PLANE, but it represents an escape vector.
    // It tracks which direction is the best to run to (angle) and the strength of the desire to go there (distance from origin)
    glm::vec2 evasion_vector = glm::vec2(0, 0);
    foreach(Collisionable, obj, objectList)
    {
        P<SpaceShip> ship = obj;
        if (!ship || !owner->isEnemy(ship))
            continue;
        if (ship->canHideInNebula() && Nebula::blockedByNebula(position, ship->getPosition(), owner->getShortRangeRadarRange()))
            continue;
        float score = evasionDangerScore(ship, scan_radius);
        if (score == std::numeric_limits<float>::min())
            continue;

        auto vec = position - ship->getPosition();
        vec = glm::normalize(vec) * score;
        evasion_vector += vec;
    }

    if (glm::length2(evasion_vector) > 0.0f) // if: evasion is necessary
    {
        // have a bias to your original target.
        // this makes ships fly around enemies rather than straight running from them
        auto target_position = owner->getOrderTargetLocation();
        if (owner->getOrderTarget())
        {
            target_position = owner->getOrderTarget()->getPosition();
        }

        float distance = 12000.0f; // should be big enough for jump drive to be considered
        if (glm::length(target_position) > 0.0f)
        {
            // ships with warp or jump drives have a tendency to fly past enemies quickly
            evasion_vector += glm::normalize(target_position - position) * (owner->hasWarpDrive() || owner->hasJumpDrive() ? 15.0f : 5.0f);
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
float EvasionAI::evasionDangerScore(P<SpaceShip> ship, float scan_radius)
{
    float enemy_max_beam_range = 0.0;
    float enemy_beam_dps = 0.0;
    float enemy_missile_strength = 0.0;

    for(int n=0; n<ship->weapon_tube_count; n++)
    {
        WeaponTube& tube = ship->weapon_tube[n];
        if (!tube.isEmpty())
        {
            enemy_missile_strength += getMissileWeaponStrength(tube.getLoadType());
        }
    }

    for(int n=0; n<max_beam_weapons; n++)
    {
        BeamWeapon& beam = ship->beam_weapons[n];
        if (beam.getRange() > 0)
        {
            if (beam.getRange() > enemy_max_beam_range)
                enemy_max_beam_range = beam.getRange();
            if (beam.getCycleTime() > 0.0f)
                enemy_beam_dps += beam.getDamage() / beam.getCycleTime();
        }
    }

    if (enemy_missile_strength <= 0.0f && (enemy_beam_dps <= 0.0f || enemy_max_beam_range <= 0.0f))
    {
        // enemy is not a threat
        return 0.0;
    }

    auto position_difference = ship->getPosition() - owner->getPosition();
    float distance = glm::length(position_difference);
    enemy_max_beam_range += ship->getRadius() + owner->getRadius();

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

    if (std::max(ship->getImpulseMaxSpeed().forward,ship->getImpulseMaxSpeed().reverse) 
            > std::max(owner->getImpulseMaxSpeed().forward, owner->getImpulseMaxSpeed().reverse))
        danger *= 1.5f; //yes that sound stupid somebody had mounted its forward reactor on reverse but...
    if (P<CpuShip>(ship->getTarget()) == P<CpuShip>(owner))
        danger = (danger + 1) * 2;
    return danger;
}