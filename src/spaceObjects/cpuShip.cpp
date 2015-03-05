#include <limits>

#include "ai/aiFactory.h"
#include "ai/ai.h"
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

    comms_script_name = "comms_ship.lua";
    
    ai = ShipAIFactory::getAIFactory("default")(this);
}

void CpuShip::update(float delta)
{
    SpaceShip::update(delta);

    if (!game_server)
        return;
    
    for(int n=0; n<SYS_COUNT; n++)
        systems[n].health = std::min(1.0f, systems[n].health + delta * auto_system_repair_per_second);

    ai->run(delta);
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

void CpuShip::orderRoamingAt(sf::Vector2f position)
{
    targetRotation = getRotation();
    orders = AI_Roaming;
    order_target_location = position;
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
