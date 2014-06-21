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
    state = AI_Engage;
}

void CpuShip::update(float delta)
{
    SpaceShip::update(delta);

    if (!gameServer)
        return;

    P<SpaceObject> target = getTarget();
    switch(state)
    {
    case AI_Engage:
        float target_distance;
        PVector<Collisionable> objectList = CollisionManager::queryArea(getPosition() - sf::Vector2f(5000, 5000), getPosition() + sf::Vector2f(5000, 5000));
        P<SpaceObject> new_target;
        foreach(Collisionable, obj, objectList)
        {
            P<SpaceObject> space_object = obj;
            if (!space_object || !space_object->canBeTargeted() || factionInfo[factionId].states[space_object->factionId] != FVF_Enemy || space_object == target)
                continue;
            float distance = sf::length(space_object->getPosition() - getPosition());
            if (!new_target || target_distance > distance)
            {
                new_target = space_object;
                target_distance = distance;
            }
        }
        if (new_target && (!target || (sf::length(target->getPosition() - getPosition()) > target_distance * 1.5f && target_distance > 1500.0)))
        {
            target = new_target;
            targetId = new_target->getMultiplayerId();
        }

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
            impulseRequest = 0.0;
        }
        break;
    }
}
