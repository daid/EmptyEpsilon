#include <limits>

#include "cpuShip.h"
#include "playerInfo.h"
#include "pathPlanner.h"
#include "nebula.h"

#include "scriptInterface.h"

/// CpuShips are AI controlled ships.
/// They can get different orders.
/// Example: CpuShip():setShipTemplate("Fighter"):setPosition(random(-10000, 10000), random(0, 3000)):setFaction("Human Navy"):orderRoaming():setScanned(true)
REGISTER_SCRIPT_SUBCLASS(CpuShip, SpaceShip)
{
    /// Order this ship to stand still and do nothing.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderIdle);
    /// Order this ship to roam around the world and attack targets
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderRoaming);
    /// Order this ship to stand still, but still target and try to hit nearby enemies
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderStandGround);
    /// Order this ship to defend a specific location. It will attack enemies near this target.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDefendLocation);
    /// Order this ship to defend a specific object. It will attack enemies near this object.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDefendTarget);
    /// Order this ship to fly in formation with another ship. It will attack nearby enemies.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyFormation);
    /// Order this ship to fly to a location, attacking everything alogn the way.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyTowards);
    /// Order this ship to fly to a location, without attacking anything
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyTowardsBlind);
    /// Order this ship to attack a specific target. If the target is destroyed it will fall back to roaming orders.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderAttack);
    /// Order this ship to dock at a specific object (station or otherwise)
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDock);
}

REGISTER_MULTIPLAYER_CLASS(CpuShip, "CpuShip");
CpuShip::CpuShip()
: SpaceShip("CpuShip")
{
    setFactionId(2);
    orders = AI_Idle;

    setRotation(random(0, 360));
    targetRotation = getRotation();
    shields_active = true;
    missile_fire_delay = 0.0;

    comms_script_name = "comms_ship.lua";
}

void CpuShip::update(float delta)
{
    SpaceShip::update(delta);

    if (!game_server)
        return;
    
    for(int n=0; n<SYS_COUNT; n++)
        systems[n].health = std::min(1.0f, systems[n].health + delta * auto_system_repair_per_second);

    if (missile_fire_delay > 0.0)
        missile_fire_delay -= delta;

    //Check the weapon state,
    has_missiles = weapon_tubes > 0 && weapon_storage[MW_Homing] > 0;
    has_beams = false;
    //If we have weapon tubes, load them with torpedoes
    for(int n=0; n<weapon_tubes; n++)
    {
        if (weaponTube[n].state == WTS_Empty && weapon_storage[MW_Homing] > 0)
            loadTube(n, MW_Homing);
        if (weaponTube[n].state == WTS_Loaded && weaponTube[n].type_loaded == MW_Homing)
            has_missiles = true;
    }
    
    beam_weapon_range = 0;
    for(int n=0; n<maxBeamWeapons; n++)
    {
        if (beamWeapons[n].range > 0)
        {
            if (sf::angleDifference(beamWeapons[n].direction, 0.0f) < beamWeapons[n].arc / 2.0f)
            {
                beam_weapon_range = std::max(beam_weapon_range, beamWeapons[n].range);
            }
            has_beams = true;
            break;
        }
    }

    P<SpaceObject> target = getTarget();
    P<SpaceObject> new_target;
    if (target && target->canHideInNebula() && (target->getPosition() - getPosition()) > 5000.0f && Nebula::blockedByNebula(getPosition(), target->getPosition()))
    {
        if (orders == AI_Roaming)
            order_target_location = target->getPosition();
        target = NULL;
    }
    if (target && !isEnemy(target))
        target = NULL;

    //Find new target which we might switch to
    if (orders == AI_Roaming)
        new_target = findBestTarget(getPosition(), 8000);
    if (orders == AI_StandGround || orders == AI_FlyTowards)
        new_target = findBestTarget(getPosition(), 7000);
    if (orders == AI_DefendLocation)
        new_target = findBestTarget(order_target_location, 7000);
    if (orders == AI_FlyFormation && order_target)
    {
        P<SpaceShip> ship = order_target;
        if (ship && ship->getTarget() && (ship->getTarget()->getPosition() - getPosition()) < 5000.0f)
            new_target = ship->getTarget();
    }
    if (orders == AI_DefendTarget)
    {
        if (order_target)
            new_target = findBestTarget(order_target->getPosition(), 7000);
    }
    if (orders == AI_Attack)
        new_target = order_target;
    
    //Check if we need to drop the current target
    if (target)
    {
        float target_distance = sf::length(target->getPosition() - getPosition());
        if (orders == AI_Idle)
            target = NULL;
        if (orders == AI_StandGround && target_distance > 8000)
            target = NULL;
        if (orders == AI_DefendLocation && target_distance > 8000)
            target = NULL;
        if (orders == AI_DefendTarget && target_distance > 8000)
            target = NULL;
        if (orders == AI_FlyTowards && target_distance > 8000)
            target = NULL;
        if (orders == AI_FlyTowardsBlind)
            target = NULL;
        if (orders == AI_FlyFormation && target_distance > 6000)
            target = NULL;
    }

    //Check if we want to switch to a new target
    if (new_target)
    {
        if (!target || betterTarget(new_target, target))
        {
            target = new_target;
        }
    }
    if (!target)
        targetId = -1;
    else
        targetId = target->getMultiplayerId();

    float attack_distance = 4000.0;
    if (has_beams)
        attack_distance = beam_weapon_range * 0.7;
    //If we have a target, engage the target.
    if (target && (has_missiles || has_beams))
    {
        sf::Vector2f position_diff = target->getPosition() - getPosition();
        float distance = sf::length(position_diff);
        targetRotation = sf::vector2ToAngle(position_diff);

        if (orders == AI_StandGround)
        {
            pathPlanner.clear();
        }else{
            pathPlanner.plan(getPosition(), target->getPosition());
        }

        if (distance < 4500 && has_missiles)
        {
            for(int n=0; n<weapon_tubes; n++)
            {
                if (weaponTube[n].state == WTS_Loaded && missile_fire_delay <= 0.0)
                {
                    float target_angle = calculateFiringSolution(target);
                    if (target_angle != std::numeric_limits<float>::infinity())
                        fireTube(n, target_angle);
                    missile_fire_delay = tubeLoadTime / weapon_tubes / 2.0;
                }
            }
        }
    }else{
        //When we are not attacking a target, follow orders
        switch(orders)
        {
        case AI_Idle:            //Don't do anything, don't even attack.
            pathPlanner.clear();
            break;
        case AI_Roaming:         //Fly around and engage at will, without a clear target
            //Could mean 3 things
            // 1) we are looking for a target
            // 2) we ran out of missiles
            // 3) we have no weapons
            if (has_missiles || has_beams)
            {
                new_target = findBestTarget(getPosition(), 50000);
                if (new_target)
                {
                    targetId = new_target->getMultiplayerId();
                }else{
                    sf::Vector2f diff = order_target_location - getPosition();
                    if (diff < 1000.0f)
                        order_target_location = sf::Vector2f(random(-30000, 30000), random(-30000, 30000));
                    pathPlanner.plan(getPosition(), order_target_location);
                }
            }else{
                //TODO: Find someething which can re-stock our weapons.
                pathPlanner.clear();
            }
            break;
        case AI_StandGround:     //Keep current position, do not fly away, but attack nearby targets.
            pathPlanner.clear();
            break;
        case AI_FlyTowards:      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
        case AI_FlyTowardsBlind: //Fly towards [order_target_location], not attacking anything
            pathPlanner.plan(getPosition(), order_target_location);
            if ((getPosition() - order_target_location) < getRadius())
            {
                if (orders == AI_FlyTowards)
                    orderDefendLocation(order_target_location);
                else
                    orderIdle();
            }
            break;
        case AI_DefendLocation:  //Defend against enemies getting close to [order_target_location]
            {
                sf::Vector2f target_position = order_target_location;
                target_position += sf::vector2FromAngle(sf::vector2ToAngle(target_position - getPosition()) + 170.0f) * 1500.0f;
                pathPlanner.plan(getPosition(), target_position);
            }
            break;
        case AI_DefendTarget:    //Defend against enemies getting close to [order_target] (falls back to AI_Roaming if the target is destroyed)
            if (order_target)
            {
                sf::Vector2f target_position = order_target->getPosition();
                float circle_distance = 2000.0f + order_target->getRadius() * 2.0 + getRadius() * 2.0;
                target_position += sf::vector2FromAngle(sf::vector2ToAngle(target_position - getPosition()) + 170.0f) * circle_distance;
                pathPlanner.plan(getPosition(), target_position);
            }else{
                orders = AI_Roaming;    //We pretty much lost our defending target, so just start roaming.
            }
            break;
        case AI_FlyFormation:    //Fly [order_target_location] offset from [order_target]. Allows for nicely flying in formation.
            if (order_target)
            {
                sf::Vector2f target_position = order_target->getPosition() + sf::rotateVector(order_target_location, order_target->getRotation());
                pathPlanner.plan(getPosition(), target_position);
            }else{
                orders = AI_Roaming;
            }
            break;
        case AI_Attack:          //Attack [order_target] very specificly.
            pathPlanner.clear();
            break;
        case AI_Dock:            //Dock with [order_target]
            if (order_target)
            {
                sf::Vector2f target_position = order_target->getPosition();
                sf::Vector2f diff = getPosition() - target_position;
                float dist = sf::length(diff);
                if (dist < 600 + order_target->getRadius())
                {
                    requestDock(order_target);
                    pathPlanner.clear();
                }else{
                    target_position += (diff / dist) * 500.0f;
                    pathPlanner.plan(getPosition(), target_position);
                }
            }else{
                orders = AI_Roaming;    //We pretty much lost our defending target, so just start roaming.
            }
            break;
        }
    }
    
    if (pathPlanner.route.size() > 0)
    {
        if (docking_state == DS_Docked)
            requestUndock();
    
        sf::Vector2f diff = pathPlanner.route[0] - getPosition();
        float distance = sf::length(diff);
        
        if (pathPlanner.route.size() == 1 && orders == AI_FlyFormation && !target)
        {
            //Formation flying code
            float r = getRadius() * 5.0;
            targetRotation = sf::vector2ToAngle(diff);
            if (distance > r)
            {
                float angle_diff = sf::angleDifference(targetRotation, getRotation());
                if (angle_diff > 10.0)
                    impulseRequest = 0.0;
                else if (angle_diff > 5.0)
                    impulseRequest = (10.0 - angle_diff) / 5.0;
                else
                    impulseRequest = 1.0;
            }else{
                if (distance > r / 2.0)
                {
                    targetRotation += sf::angleDifference(targetRotation, order_target->getRotation()) * (1.0 - distance / r);
                    impulseRequest = distance / r;
                }else{
                    targetRotation = order_target->getRotation();
                    impulseRequest = 0.0;
                }
            }
        }else{
            //Normal flying towards target code
            targetRotation = sf::vector2ToAngle(diff);
            float rotation_diff = fabs(sf::angleDifference(targetRotation, getRotation()));
            
            if (hasWarpdrive && rotation_diff < 30.0 && distance > 2000)
            {
                warpRequest = 1.0;
            }else{
                warpRequest = 0.0;
            }
            if (distance > 10000 && hasJumpdrive && jumpDelay <= 0.0)
            {
                if (rotation_diff < 1.0)
                {
                    float jump = distance;
                    if (pathPlanner.route.size() < 2)
                    {
                        jump -= 3000;
                        if (has_missiles)
                            jump -= 5000;
                    }
                    if (jump > 10000)
                        jump = 10000;
                    jump += random(-1500, 1500);
                    initJump(jump / 1000);
                }
            }
            float keep_distance = attack_distance;
            if (!target)
                keep_distance = 100.0;
            if (pathPlanner.route.size() > 1)
                keep_distance = 0.0;

            if (distance > keep_distance + impulseMaxSpeed)
                impulseRequest = 1.0f;
            else
                impulseRequest = (distance - keep_distance) / impulseMaxSpeed;
            if (rotation_diff > 90)
                impulseRequest = -impulseRequest;
            else if (rotation_diff < 45)
                impulseRequest *= 1.0 - ((rotation_diff - 45.0f) / 45.0);
        }
    }else{
        targetRotation = getRotation();
        warpRequest = 0.0;
        impulseRequest = 0.0f;

        if (orders == AI_StandGround && target)
            targetRotation = sf::vector2ToAngle(target->getPosition() - getPosition());
    }
}

P<SpaceObject> CpuShip::findBestTarget(sf::Vector2f position, float radius)
{
    float target_score = 0.0;
    PVector<Collisionable> objectList = CollisionManager::queryArea(position - sf::Vector2f(radius, radius), position + sf::Vector2f(radius, radius));
    P<SpaceObject> target;
    foreach(Collisionable, obj, objectList)
    {
        P<SpaceObject> space_object = obj;
        if (!space_object || !space_object->canBeTargeted() || !isEnemy(space_object) || space_object == target)
            continue;
        if (space_object->canHideInNebula() && (space_object->getPosition() - getPosition()) > 5000.0f && Nebula::blockedByNebula(getPosition(), space_object->getPosition()))
            continue;
        float score = targetScore(space_object);
        if (!target || score > target_score)
        {
            target = space_object;
            target_score = score;
        }
    }
    return target;
}

float CpuShip::targetScore(P<SpaceObject> target)
{
    sf::Vector2f position_difference = target->getPosition() - getPosition();
    float distance = sf::length(position_difference);
    //sf::Vector2f position_difference_normal = position_difference / distance;
    //float rel_velocity = dot(target->getVelocity(), position_difference_normal) - dot(getVelocity(), position_difference_normal);
    float angle_difference = sf::angleDifference(getRotation(), sf::vector2ToAngle(position_difference));
    float score = -distance - fabsf(angle_difference / rotationSpeed * impulseMaxSpeed) * 1.5f;
    if (P<SpaceStation>(target))
        score -= 5000;
    if (distance < 5000 && has_missiles)
        score += 500;
    /*
    if (distance < beam_weapon_range)
    {
        for(int n=0; n<maxBeamWeapons; n++)
        {
            if (distance < beamWeapons[n].range)
            {
                //if (sf::angleDifference(angle_difference, beamWeapons[n].direction) < beamWeapons[n].arc / 2.0f)
                //    score += 1000;
            }
        }
    }
    */
    return score;
}

bool CpuShip::betterTarget(P<SpaceObject> new_target, P<SpaceObject> current_target)
{
    float new_score = targetScore(new_target);
    float current_score = targetScore(current_target);
    if (new_score > current_score * 1.5f)
        return true;
    if (new_score > current_score + 5000.0f)
        return true;
    return false;
}

float CpuShip::calculateFiringSolution(P<SpaceObject> target)
{
    sf::Vector2f target_position = target->getPosition();
    sf::Vector2f target_velocity = target->getVelocity();
    float target_velocity_length = sf::length(target_velocity);
    float missile_angle = sf::vector2ToAngle(target->getPosition() - getPosition());
    float missile_speed = 200.0f;
    float missile_turn_rate = 10.0f;
    float turn_radius = ((360.0f / missile_turn_rate) * missile_speed) / (2.0f * M_PI);
    
    for(int iterations=0; iterations<10; iterations++)
    {
        float angle_diff = sf::angleDifference(missile_angle, getRotation());
        
        float left_or_right = 90;
        if (angle_diff > 0)
            left_or_right = -90;
        
        sf::Vector2f turn_center = getPosition() + sf::vector2FromAngle(getRotation() + left_or_right) * turn_radius;
        sf::Vector2f turn_exit = turn_center + sf::vector2FromAngle(missile_angle - left_or_right) * turn_radius;
        if (target_velocity_length < 1.0f)
        {
            //If the target is almost standing still, just target the position directly instead of using the velocity of the target in the calculations.
            float time_missile = sf::length(turn_exit - target_position) / missile_speed;
            sf::Vector2f interception = turn_exit + sf::vector2FromAngle(missile_angle) * missile_speed * time_missile;
            if ((interception - target_position) < target->getRadius() / 2)
                return missile_angle;
            missile_angle = sf::vector2ToAngle(target->getPosition() - turn_exit);
        }
        else
        {
            sf::Vector2f missile_velocity = sf::vector2FromAngle(missile_angle) * missile_speed;
            //Calculate the position where missile and the target will cross each others path.
            sf::Vector2f intersection = sf::lineLineIntersection(target_position, target_position + target_velocity, turn_exit, turn_exit + missile_velocity);
            //Calculate the time it will take for the target and missile to reach the intersection
            float turn_time = fabs(angle_diff) / missile_turn_rate;
            float time_target = sf::length((target_position - intersection)) / target_velocity_length;
            float time_missile = sf::length(turn_exit - intersection) / missile_speed + turn_time;
            //Calculate the time in which the radius will be on the intersection, to know in which time range we need to hit.
            float time_radius = (target->getRadius() / 2.0) / target_velocity_length;//TODO: This value could be improved, as it is allowed to be bigger when the angle between the missile and the ship is low
            // When both the missile and the target are at the same position at the same time, we can take a shot!
            if (fabsf(time_target - time_missile) < time_radius)
                return missile_angle;
            
            //When we cannot hit the target with this setup yet. Calculate a new intersection target, and aim for that.
            float guessed_impact_time = (time_target * target_velocity_length / (target_velocity_length + missile_speed)) + (time_missile * missile_speed / (target_velocity_length + missile_speed));
            sf::Vector2f new_target_position = target->getPosition() + target_velocity * guessed_impact_time;
            missile_angle = sf::vector2ToAngle(new_target_position - turn_exit);
        }
    }
    return std::numeric_limits<float>::infinity();
}

void CpuShip::orderIdle()
{
    orders = AI_Idle;
}

void CpuShip::orderRoaming()
{
    targetRotation = getRotation();
    orders = AI_Roaming;
}

void CpuShip::orderStandGround()
{
    targetRotation = getRotation();
    orders = AI_StandGround;
}

void CpuShip::orderDefendLocation(sf::Vector2f position)
{
    orders = AI_DefendLocation;
    order_target_location = position;
}

void CpuShip::orderDefendTarget(P<SpaceObject> object)
{
    orders = AI_DefendTarget;
    order_target = object;
}

void CpuShip::orderFlyFormation(P<SpaceObject> object, sf::Vector2f offset)
{
    orders = AI_FlyFormation;
    order_target = object;
    order_target_location = offset;
}

void CpuShip::orderFlyTowards(sf::Vector2f target)
{
    orders = AI_FlyTowards;
    order_target_location = target;
}

void CpuShip::orderFlyTowardsBlind(sf::Vector2f target)
{
    orders = AI_FlyTowardsBlind;
    order_target_location = target;
}

void CpuShip::orderAttack(P<SpaceObject> object)
{
    orders = AI_Attack;
    order_target = object;
}

void CpuShip::orderDock(P<SpaceObject> object)
{
    orders = AI_Dock;
    order_target = object;
}

string getAIOrderString(EAIOrder order)
{
    switch(order)
    {
    case AI_Idle: return "Idle";
    case AI_Roaming: return "Roaming";
    case AI_StandGround: return "Stand Ground";
    case AI_DefendLocation: return "Defend Location";
    case AI_DefendTarget: return "Defend Target";
    case AI_FlyFormation: return "Fly in formation";
    case AI_FlyTowards: return "Fly towards";
    case AI_FlyTowardsBlind: return "Fly towards (ignore all)";
    case AI_Attack: return "Attack";
    case AI_Dock: return "Dock";
    }
    return "Unknown";
}

