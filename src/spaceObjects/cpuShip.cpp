#include <limits>

#include "ai/aiFactory.h"
#include "ai/ai.h"
#include "main.h"
#include "cpuShip.h"
#include "playerInfo.h"
#include "pathPlanner.h"
#include "nebula.h"

#include "scriptInterface.h"

/// CpuShips are AI controlled ships.
/// They can get different orders.
/// Example: CpuShip():setTemplate("Fighter"):setPosition(random(-10000, 10000), random(0, 3000)):setFaction("Human Navy"):orderRoaming():setScanned(true)
REGISTER_SCRIPT_SUBCLASS(CpuShip, SpaceShip)
{
    /// Switch the AI to a different type. AI can be set per ship, or left per default which will be taken from the shipTemplate then.
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, setAI);

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
    /// Get the order this ship is executing
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, getOrder);
    /// Get the target location of the currently executed order
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, getOrderTargetLocation);
    /// Get the target SpaceObject of the currently executed order
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, getOrderTarget);
}

REGISTER_MULTIPLAYER_CLASS(CpuShip, "CpuShip");
CpuShip::CpuShip()
: SpaceShip("CpuShip")
{
    setFactionId(2);
    orders = AI_Idle;

    setRotation(random(0, 360));
    target_rotation = getRotation();

    comms_script_name = "comms_ship.lua";

    missile_resupply = 0.0;

    if (game_server)
        ai = ShipAIFactory::getAIFactory("default")(this);
    else
        ai = NULL;
}

CpuShip::~CpuShip()
{
    if (ai)
        delete ai;
}

void CpuShip::update(float delta)
{
    SpaceShip::update(delta);

    if (!game_server)
        return;

    for(int n=0; n<SYS_COUNT; n++)
        systems[n].health = std::min(1.0f, systems[n].health + delta * auto_system_repair_per_second);

    if (new_ai_name.length() && ai->canSwitchAI())
    {
        shipAIFactoryFunc_t f = ShipAIFactory::getAIFactory(new_ai_name);
        delete ai;
        ai = f(this);
        new_ai_name = "";
    }
    ai->run(delta);

    //recharge missiles of CPU ships docked to station. uses the same trick as player ships. VERY hackish.
    if (docking_state == DS_Docked)
    {
        P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
        P<SpaceShip> docked_with_ship = docking_target;

        if (docked_with_template_based && !docked_with_ship)
        {
            bool needs_missile = 0;

            for(int n=0; n<MW_Count; n++)
            {
                if  (weapon_storage[n] < weapon_storage_max[n])
                {
                    if (missile_resupply >= missile_resupply_time)
                    {
                        weapon_storage[n] += 1;
                        missile_resupply = 0.0;
                        break;
                    }
                    else
                        needs_missile = 1;
                }
            }

            if (needs_missile)
                missile_resupply += delta;
        }
    }
}

void CpuShip::applyTemplateValues()
{
    SpaceShip::applyTemplateValues();

    new_ai_name = ship_template->default_ai_name;
}

void CpuShip::setAI(string new_ai)
{
    new_ai_name = new_ai;
}

void CpuShip::orderIdle()
{
    orders = AI_Idle;
    order_target = NULL;
    order_target_location = sf::Vector2f();
}

void CpuShip::orderRoaming()
{
    target_rotation = getRotation();
    orders = AI_Roaming;
    order_target = NULL;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly,"Searching for targets.");
}

void CpuShip::orderRoamingAt(sf::Vector2f position)
{
    target_rotation = getRotation();
    orders = AI_Roaming;
    order_target = NULL;
    order_target_location = position;
    this->addBroadcast(FVF_Friendly, "Searching for hostiles around " + string(position.x) + "," + string(position.y) + ".");
}

void CpuShip::orderStandGround()
{
    target_rotation = getRotation();
    orders = AI_StandGround;
    order_target = NULL;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, "Standing ground for now.");
}

void CpuShip::orderDefendLocation(sf::Vector2f position)
{
    orders = AI_DefendLocation;
    order_target = NULL;
    order_target_location = position;
    this->addBroadcast(FVF_Friendly, "Defending " + string(position.x) + "," + string(position.y) + ".");
}

void CpuShip::orderDefendTarget(P<SpaceObject> object)
{
    if (!object)
        return;
    orders = AI_DefendTarget;
    order_target = object;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, "Defending " + object->getCallSign() + ".");
}

void CpuShip::orderFlyFormation(P<SpaceObject> object, sf::Vector2f offset)
{
    if (!object)
        return;
    orders = AI_FlyFormation;
    order_target = object;
    order_target_location = offset;
    this->addBroadcast(FVF_Friendly, "Following " + object->getCallSign() + ".");
}

void CpuShip::orderFlyTowards(sf::Vector2f target)
{
    orders = AI_FlyTowards;
    order_target = NULL;
    order_target_location = target;
    this->addBroadcast(FVF_Friendly, "Moving to " + string(target.x) + "," + string(target.y) + ".");
}

void CpuShip::orderFlyTowardsBlind(sf::Vector2f target)
{
    orders = AI_FlyTowardsBlind;
    order_target = NULL;
    order_target_location = target;
    this->addBroadcast(FVF_Friendly,"Moving to " + string(target.x) + "," + string(target.y) + ".");
}

void CpuShip::orderAttack(P<SpaceObject> object)
{
    if (!object)
        return;
    orders = AI_Attack;
    order_target = object;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, "Moving to attack " + object->getCallSign() + "!");
}

void CpuShip::orderDock(P<SpaceObject> object)
{
    if (!object)
        return;
    orders = AI_Dock;
    order_target = object;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, "Docking to " + object->getCallSign() + ".");
}

void CpuShip::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, bool long_range)
{
    SpaceShip::drawOnGMRadar(window, position, scale, long_range);
    ai->drawOnGMRadar(window, position, scale);
}

std::unordered_map<string, string> CpuShip::getGMInfo()
{
    std::unordered_map<string, string> ret = SpaceShip::getGMInfo();
    ret["Orders"] = getAIOrderString(orders);
    return ret;
}

string CpuShip::getExportLine()
{
    string ret = "CpuShip():setFaction(\"" + getFaction() + "\"):setTemplate(\"" + template_name + "\"):setCallSign(\"" + getCallSign() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";
    switch(orders)
    {
    case AI_Idle: break;
    case AI_Roaming: ret += ":orderRoaming()"; break;
    case AI_StandGround: ret += ":orderStandGround()"; break;
    case AI_DefendLocation: ret += ":orderDefendLocation(" + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AI_DefendTarget: ret += ":orderDefendTarget(?)"; break;
    case AI_FlyFormation: ret += ":orderFlyFormation(?, " + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AI_FlyTowards: ret += ":orderFlyTowards(" + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AI_FlyTowardsBlind: ret += ":orderFlyTowardsBlind(" + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AI_Attack: ret += ":orderAttack(?)"; break;
    case AI_Dock: ret += ":orderDock(?)"; break;
    }
    return ret + getScriptExportModificationsOnTemplate();
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
