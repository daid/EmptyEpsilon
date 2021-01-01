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
    /// Order this ship to restock missiles at a specific station or finds a close station
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderRetreat);
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

    restocks_missiles_docked = true;
    comms_script_name = "comms_ship.lua";

    missile_resupply = 0.0;

    new_ai_name = "default";
    ai = nullptr;
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

    if (new_ai_name.length() && (!ai || ai->canSwitchAI()))
    {
        shipAIFactoryFunc_t f = ShipAIFactory::getAIFactory(new_ai_name);
        delete ai;
        ai = f(this);
        new_ai_name = "";
    }
    if (ai)
        ai->run(delta);

    //recharge missiles of CPU ships docked to station. Can be disabled setting the restocks_missiles_docked flag to false.
    if (docking_state == DS_Docked)
    {
        P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
        P<SpaceShip> docked_with_ship = docking_target;

        if (docked_with_template_based && docked_with_template_based->restocks_missiles_docked)
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
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Searching for targets."));
}

void CpuShip::orderRoamingAt(sf::Vector2f position)
{
    target_rotation = getRotation();
    orders = AI_Roaming;
    order_target = NULL;
    order_target_location = position;
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Searching for hostiles around {x},{y}.").format({{"x", string(position.x)}, {"y", string(position.y)}}));
}

void CpuShip::orderRetreat(P<SpaceObject> object)
{
    orders = AI_Retreat;
    if (!object)
    {
        order_target = NULL;
        this->addBroadcast(FVF_Friendly, tr("cpulog", "Searching for supplies."));
    }else{
        order_target = object;
        this->addBroadcast(FVF_Friendly, tr("cpulog", "Docking to {callsign}.").format({{"callsign", object->getCallSign()}}));
    }
    order_target_location = sf::Vector2f();
}

void CpuShip::orderStandGround()
{
    target_rotation = getRotation();
    orders = AI_StandGround;
    order_target = NULL;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Standing ground for now."));
}

void CpuShip::orderDefendLocation(sf::Vector2f position)
{
    orders = AI_DefendLocation;
    order_target = NULL;
    order_target_location = position;
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Defending {x},{y}.").format({{"x", string(position.x)}, {"y", string(position.y)}}));
}

void CpuShip::orderDefendTarget(P<SpaceObject> object)
{
    if (!object)
        return;
    orders = AI_DefendTarget;
    order_target = object;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Defending {callsign}.").format({{"callsign", object->getCallSign()}}));
}

void CpuShip::orderFlyFormation(P<SpaceObject> object, sf::Vector2f offset)
{
    if (!object)
        return;
    orders = AI_FlyFormation;
    order_target = object;
    order_target_location = offset;
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Following {callsign}.").format({{"callsign", object->getCallSign()}}));
}

void CpuShip::orderFlyTowards(sf::Vector2f target)
{
    orders = AI_FlyTowards;
    order_target = NULL;
    order_target_location = target;
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Moving to {targetx},").format({{"targetx", string(target.x)}}) + string(target.y) + ".");
}

void CpuShip::orderFlyTowardsBlind(sf::Vector2f target)
{
    orders = AI_FlyTowardsBlind;
    order_target = NULL;
    order_target_location = target;
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Moving to {targetx},").format({{"targetx", string(target.x)}}) + string(target.y) + ".");
}

void CpuShip::orderAttack(P<SpaceObject> object)
{
    if (!object)
        return;
    orders = AI_Attack;
    order_target = object;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Moving to attack {callsign}!").format({{"callsign", object->getCallSign()}}));
}

void CpuShip::orderDock(P<SpaceObject> object)
{
    if (!object)
        return;
    orders = AI_Dock;
    order_target = object;
    order_target_location = sf::Vector2f();
    this->addBroadcast(FVF_Friendly, tr("cpulog", "Docking to {callsign}.").format({{"callsign", object->getCallSign()}}));
}

void CpuShip::drawOnGMRadar(sf::RenderTarget& window, sf::Vector2f position, float scale, float rotation, bool long_range)
{
    SpaceShip::drawOnGMRadar(window, position, scale, rotation, long_range);
    if (game_server && ai)
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
    case AI_Retreat: ret += ":orderRetreat(?)"; break;
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
    case AI_Idle: return tr("orderscpu", "Idle");
    case AI_Roaming: return tr("orderscpu", "Roaming");
    case AI_Retreat: return tr("orderscpu", "Retreat");
    case AI_StandGround: return tr("orderscpu", "Stand Ground");
    case AI_DefendLocation: return tr("orderscpu", "Defend Location");
    case AI_DefendTarget: return tr("orderscpu", "Defend Target");
    case AI_FlyFormation: return tr("orderscpu", "Fly in formation");
    case AI_FlyTowards: return tr("orderscpu", "Fly towards");
    case AI_FlyTowardsBlind: return tr("orderscpu", "Fly towards (ignore all)");
    case AI_Attack: return tr("orderscpu", "Attack");
    case AI_Dock: return tr("orderscpu", "Dock");
    }
    return "Unknown";
}

template<> int convert<EAIOrder>::returnType(lua_State* L, EAIOrder o)
{
    lua_pushstring(L, getAIOrderString(o).c_str());
    return 1;
}
