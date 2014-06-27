#include "cpuShip.h"
#include "playerInfo.h"
#include "factionInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS(CpuShip)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShipTemplate);
}

REGISTER_MULTIPLAYER_CLASS(CpuShip, "CpuShip");
CpuShip::CpuShip()
: SpaceShip("CpuShip")
{
    factionId = 2;
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
    bool has_missiles = weaponTubes > 0 && weaponStorage[MW_Homing] > 0, has_beams = false;
    //If we have weapon tubes, load them with torpedoes
    for(int n=0; n<weaponTubes; n++)
    {
        if (weaponTube[n].state == WTS_Empty && weaponStorage[MW_Homing] > 0)
            loadTube(n, MW_Homing);
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
    if (orders == AI_StandGround || orders == AI_Roaming || orders == AI_FlyTowards)
        new_target = findBestTarget(getPosition(), 7000);
    if (orders == AI_DefendLocation)
        new_target = findBestTarget(order_target_location, 7000);
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
        
        if (!target)
            targetId = -1;
    }
    
    //Check if we want to switch to a new target
    if (new_target)
    {
        float new_distance = sf::length(new_target->getPosition() - getPosition());
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
        
        if (orders == AI_StandGround)
        {
            impulseRequest = 0.0f;
            warpRequest = 0.0;
        }else{
            if (distance > 7000 && hasWarpdrive)
            {
                warpRequest = 1.0;
            }else{
                warpRequest = 0.0;
            }
            if (distance > 10000 && hasJumpdrive && jumpDelay <= 0.0)
            {
                if (fabs(sf::angleDifference(targetRotation, getRotation())) < 1.0)
                    initJump(distance - 3000);
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
            break;
        case AI_Roaming:         //Fly around and engage at will, without a clear target
            //Could mean 3 things
            // 1) we are looking for a target
            // 2) we ran out of missiles
            // 3) we have no weapons
            if (has_missiles || has_beams)
            {
                new_target = findBestTarget(getPosition(), 20000);
                if (new_target)
                    targetId = new_target->getMultiplayerId();
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
            break;
        case AI_Attack:          //Attack [order_target] very specificly.
            targetRotation = getRotation();
            impulseRequest = 0;
            break;
        }
        impulseRequest = 0.0;
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
        if (!space_object || !space_object->canBeTargeted() || factionInfo[factionId].states[space_object->factionId] != FVF_Enemy || space_object == target)
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
    orders = AI_Roaming;
}

void CpuShip::orderStandGround()
{
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

