#include "cpuShip.h"
#include "playerInfo.h"
#include "fractionInfo.h"

#include "scriptInterface.h"
REGISTER_SCRIPT_CLASS(CpuShip)
{
    REGISTER_SCRIPT_CLASS_FUNCTION(SpaceShip, setShipTemplate);
}

REGISTER_MULTIPLAYER_CLASS(CpuShip, "CpuShip");
CpuShip::CpuShip()
: SpaceShip("CpuShip")
{
    fractionId = 2;
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
            float target_distance;
            
            PVector<Collisionable> objectList = CollisionManager::queryArea(getPosition() - sf::Vector2f(5000, 5000), getPosition() + sf::Vector2f(5000, 5000));
            foreach(Collisionable, obj, objectList)
            {
                P<SpaceObject> space_object = obj;
                if (!space_object || !space_object->canBeTargeted() || fractionInfo[fractionId].states[space_object->fractionId] != FVF_Enemy)
                    continue;
                float distance = sf::length(space_object->getPosition() - getPosition());
                if (!target || target_distance > distance)
                {
                    target = space_object;
                    targetId = target->getMultiplayerId();
                    target_distance = distance;
                }
            }
        }
        break;
    }
}
