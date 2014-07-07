#include "cpuShip.h"
#include "playerInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_SUBCLASS(CpuShip, SpaceObject)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setPosition);
    REGISTER_SCRIPT_CLASS_FUNCTION(Collisionable, setRotation);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShipTemplate);
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setScanned);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderIdle);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderRoaming);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderStandGround);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDefendLocation);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDefendTarget);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyFormation);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyTowards);
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderAttack);
}

REGISTER_MULTIPLAYER_CLASS(CpuShip, "CpuShip");
CpuShip::CpuShip()
: SpaceShip("CpuShip")
{
    faction_id = 2;
    orders = AI_Idle;
    
    setRotation(random(0, 360));
    targetRotation = getRotation();
    shields_active = true;
    missile_fire_delay = 0.0;
}

void CpuShip::update(float delta)
{
    SpaceShip::update(delta);

    if (!gameServer)
        return;
        
    if (missile_fire_delay > 0.0)
        missile_fire_delay -= delta;
    
    //Check the weapon state, 
    bool has_missiles = weaponTubes > 0 && weapon_storage[MW_Homing] > 0;
    bool has_beams = false;
    //If we have weapon tubes, load them with torpedoes
    for(int n=0; n<weaponTubes; n++)
    {
        if (weaponTube[n].state == WTS_Empty && weapon_storage[MW_Homing] > 0)
            loadTube(n, MW_Homing);
        if (weaponTube[n].state == WTS_Loaded && weaponTube[n].typeLoaded == MW_Homing)
            has_missiles = true;
    }
    for(int n=0; n<maxBeamWeapons; n++)
    {
        if (beamWeapons[n].range > 0)
        {
            has_beams = true;
            break;
        }
    }

    P<SpaceObject> target = getTarget();
    P<SpaceObject> new_target;
    float target_distance = 0.0;
    if (target)
        target_distance = sf::length(target->getPosition() - getPosition());
    
    //Find new target
    if (orders == AI_Roaming)
        new_target = findBestTarget(getPosition(), 8000);
    if (orders == AI_StandGround || orders == AI_FlyTowards)
        new_target = findBestTarget(getPosition(), 7000);
    if (orders == AI_DefendLocation)
        new_target = findBestTarget(order_target_location, 7000);
    if (orders == AI_FlyFormation && order_target)
    {
        P<SpaceShip> ship = order_target;
        if (ship && ship->getTarget() && sf::length(ship->getTarget()->getPosition() - getPosition()) < 5000)
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
        if (orders == AI_FlyFormation && target_distance > 6000)
            target = NULL;
        
        if (!target)
            targetId = -1;
    }
    
    //Check if we want to switch to a new target
    if (new_target)
    {
        float new_distance = sf::length(new_target->getPosition() - getPosition());
        P<SpaceStation> station = target;
        if (station)
            target_distance += 5000;
        if (!target || (target_distance > new_distance * 1.5f && new_distance > 1500.0))
        {
            target = new_target;
            targetId = new_target->getMultiplayerId();
        }
    }

    //If we have a target, engage the target.
    if (target && (has_missiles || has_beams))
    {
        float attack_distance = 4000.0;
        if (has_beams)
            attack_distance = 700.0;
        
        sf::Vector2f position_diff = target->getPosition() - getPosition();
        float distance = sf::length(position_diff);
        targetRotation = sf::vector2ToAngle(position_diff);
        
        warpRequest = 0.0;
        if (orders == AI_StandGround)
        {
            impulseRequest = 0.0f;
        }else{
            if (hasWarpdrive && fabs(sf::angleDifference(targetRotation, getRotation())) < 50.0)
            {
                if ((has_missiles && distance > 7000) || (!has_missiles && distance > 2000))
                    warpRequest = 1.0;
            }
            if (distance > 10000 && hasJumpdrive && jumpDelay <= 0.0)
            {
                if (fabs(sf::angleDifference(targetRotation, getRotation())) < 1.0)
                {
                    float jump = distance - 3000;
                    if (has_missiles)
                        jump = distance - 8000;
                    if (jump > 10000)
                        jump = 10000;
                    initJump(jump / 1000);
                }
            }
            
            if (distance > attack_distance + impulseMaxSpeed)
                impulseRequest = 1.0f;
            else
                impulseRequest = (distance - attack_distance) / impulseMaxSpeed;
        }
        
        if (distance < 4500 && has_missiles && fabs(sf::angleDifference(targetRotation, getRotation())) < 30.0)
        {
            for(int n=0; n<weaponTubes; n++)
            {
                if (weaponTube[n].state == WTS_Loaded && missile_fire_delay <= 0.0)
                {
                    fireTube(n);
                    missile_fire_delay = tubeLoadTime / weaponTubes / 2.0;
                }
            }
        }
    }else{
        //When we are not attacking a target, follow orders
        switch(orders)
        {
        case AI_Idle:            //Don't do anything, don't even attack.
            impulseRequest = 0.0;
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
                    if (sf::length(diff) < 1000.0)
                        order_target_location = sf::Vector2f(random(-30000, 30000), random(-30000, 30000));
                    targetRotation = sf::vector2ToAngle(diff);
                    impulseRequest = 1.0;
                }
            }else{
                impulseRequest = 0.0;
            }
            break;
        case AI_StandGround:     //Keep current position, do not fly away, but attack nearby targets.
            targetRotation = getRotation();
            impulseRequest = 0;
            break;
        case AI_FlyTowards:      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
        case AI_FlyTowardsBlind: //Fly towards [order_target_location], not attacking anything
        case AI_DefendLocation:  //Defend against enemies getting close to [order_target_location]
            targetRotation = sf::vector2ToAngle(order_target_location - getPosition());
            impulseRequest = 1.0;
            break;
        case AI_DefendTarget:    //Defend against enemies getting close to [order_target] (falls back to AI_Roaming if the target is destroyed)
            if (order_target)
            {
                targetRotation = sf::vector2ToAngle(order_target->getPosition() - getPosition());
                impulseRequest = 1.0;
            }else{
                orders = AI_Roaming;    //We pretty much lost our defending target, so just start roaming.
            }
            break;
        case AI_FlyFormation:    //Fly [order_target_location] offset from [order_target]. Allows for nicely flying in formation.
            if (order_target)
            {
                sf::Vector2f target_position = order_target->getPosition() + sf::rotateVector(order_target_location, order_target->getRotation());
                
                float r = getRadius() * 5.0;
                targetRotation = sf::vector2ToAngle(target_position - getPosition());
                float dist = sf::length(target_position - getPosition());
                if (sf::length(target_position - getPosition()) > r)
                {
                    float angle_diff = sf::angleDifference(targetRotation, getRotation());
                    if (angle_diff > 10.0)
                        impulseRequest = 0.0;
                    else if (angle_diff > 5.0)
                        impulseRequest = (10.0 - angle_diff) / 5.0;
                    else
                        impulseRequest = 1.0;
                }else{
                    if (dist > r / 2.0)
                    {
                        targetRotation += sf::angleDifference(targetRotation, order_target->getRotation()) * (1.0 - dist / r);
                        impulseRequest = dist / r;
                    }else{
                        targetRotation = order_target->getRotation();
                        impulseRequest = 0.0;
                    }
                }
            }else{
                orders = AI_Roaming;
            }
            break;
        case AI_Attack:          //Attack [order_target] very specificly.
            targetRotation = getRotation();
            impulseRequest = 0;
            break;
        }
    }
}

P<SpaceObject> CpuShip::findBestTarget(sf::Vector2f position, float radius)
{
    float target_distance = 0.0;
    PVector<Collisionable> objectList = CollisionManager::queryArea(position - sf::Vector2f(radius, radius), position + sf::Vector2f(radius, radius));
    P<SpaceObject> target;
    foreach(Collisionable, obj, objectList)
    {
        P<SpaceObject> space_object = obj;
        if (!space_object || !space_object->canBeTargeted() || !isEnemy(space_object) || space_object == target)
            continue;
        float distance = sf::length(space_object->getPosition() - position);
        if (distance > radius)
            continue;
        if (!target || target_distance > distance)
        {
            target = space_object;
            target_distance = distance;
        }
    }
    return target;
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

void CpuShip::orderAttack(P<SpaceObject> object)
{
    orders = AI_Attack;
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
    }
    return "Unknown";
}

