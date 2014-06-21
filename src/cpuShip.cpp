#include "cpuShip.h"
#include "playerInfo.h"

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
    if (gameServer)
    {
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
            }
            break;
        }
    }
    
    SpaceShip::update(delta);
}
