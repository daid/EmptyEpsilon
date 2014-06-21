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
    orders = AI_Roaming;
    
    setRotation(random(0, 360));
    targetRotation = getRotation();
}

void CpuShip::update(float delta)
{
    SpaceShip::update(delta);

    if (!gameServer)
        return;

    P<SpaceObject> target = getTarget();
    P<SpaceObject> new_target;
    float target_distance = 0.0;
    if (target)
        target_distance = sf::length(target->getPosition() - getPosition());
    
    //Find new target
    if (orders == AI_StandGround || orders == AI_Roaming)
        new_target = findBestTarget(getPosition(), 5000);
    if (orders == AI_DefendLocation)
        new_target = findBestTarget(order_target_location, 5000);
    if (orders == AI_DefendTarget)
    {
        if (order_target)
            new_target = findBestTarget(order_target->getPosition(), 5000);
        else
            orders = AI_Roaming;
    }
    if (orders == AI_Attack)
        new_target = order_target;
    //Check if we need to drop the current target
    if (target)
    {
        if (orders == AI_Idle)
            target = NULL;
        if (orders == AI_StandGround && target_distance > 5000)
            target = NULL;
        if (orders == AI_DefendLocation && target_distance > 5000)
            target = NULL;
        if (orders == AI_DefendTarget && target_distance > 5000)
            target = NULL;
        if (orders == AI_FlyTowards && target_distance > 5000)
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
    if (target)
    {
        sf::Vector2f position_diff = target->getPosition() - getPosition();
        float distance = sf::length(position_diff);
        
        targetRotation = sf::vector2ToAngle(position_diff);
        if (distance > 1000)
            impulseRequest = 1.0f;
        else
            impulseRequest = (distance - 500.0f) / 500.0f;
    }else{
        //When we are not attacking a target, follow orders
        switch(orders)
        {
        case AI_Idle:            //Don't do anything, don't even attack.
            break;
        case AI_Roaming:         //Fly around and engage at will, without a clear target
            break;
        case AI_StandGround:     //Keep current position, do not fly away, but attack nearby targets.
            targetRotation = getRotation();
            impulseRequest = 0;
            break;
        case AI_FlyTowards:      //Fly towards [order_target_location], attacking enemies that get too close, but disengage and continue when enemy is too far.
        case AI_DefendLocation:  //Defend against enemies getting close to [order_target_location]
            targetRotation = sf::vector2ToAngle(order_target_location - getPosition());
            impulseRequest = 1.0;
            break;
        case AI_DefendTarget:    //Defend against enemies getting close to [order_target] (falls back to AI_Roaming if the target is destroyed)
            targetRotation = sf::vector2ToAngle(order_target->getPosition() - getPosition());
            impulseRequest = 1.0;
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
    float target_distance;
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
