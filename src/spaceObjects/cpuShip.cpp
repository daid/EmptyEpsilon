#include <i18n.h>
#include <limits>

#include "ai/aiFactory.h"
#include "ai/ai.h"
#include "main.h"
#include "cpuShip.h"
#include "playerInfo.h"
#include "nebula.h"
#include "random.h"
#include "multiplayer_server.h"
#include "components/maneuveringthrusters.h"

#include "scriptInterface.h"

/// A CpuShip is an AI-controlled SpaceShip.
/// The AI can be assigned an order (be idle, roam freely, defend location, etc.) and a combat behavior state (attack at close or long range, be evasive).
/// AI behaviors are defined in ai.cpp and other files in src/ai/.
/// CpuShip:order... functions also broadcast their orders over friendly comms.
/// Autonomous combat AI orders use the CpuShip's short- and long-range radar ranges to acquire targets, which can be affected by nebulae.
/// They also rank prospective targets by their type, distance, and capabilities.
/// Example:
/// -- Place a Fighter-class Human Navy CpuShip, order it to roam, and if it engages in combat it will fight evasively
/// ship = CpuShip():setTemplate("Fighter"):setPosition(10000,3000):setFaction("Human Navy"):orderRoaming():setAI("evasive"):setScanned(true)
REGISTER_SCRIPT_SUBCLASS(CpuShip, SpaceShip)
{
    /// Sets the default combat AI state for this CpuShip.
    /// Combat AI states determine the AI's combat tactics and responses.
    /// They're distinct from orders, which determine the ship's active objectives and are defined by CpuShip:order...() functions.
    /// Combat AI state can be set per CpuShip, defined in the ShipTemplate, or left to "default".
    /// Valid combat AI states are:
    /// - "default" directly pursues enemies at beam range while making opportunistic missile attacks
    /// - "evasion" maintains distance from enemy weapons and evades attacks
    /// - "fighter" prefers strafing maneuvers and attacks briefly at close range while passing
    /// - "missilevolley" prefers lining up missile attacks from long range
    /// Example: ship:setAI("fighter")
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, setAI);
    /// Orders this CpuShip to stay at its current position and do nothing.
    /// Idle CpuShips don't target or attack nearby enemies.
    /// Example: ship:orderIdle()
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderIdle);
    /// Orders this CpuShip to roam and engage at will, without a specific target.
    /// A Roaming ship can acquire hostile targets within its long-range radar range, and prefers the best hostile target within 2U of its short-range radar range.
    /// If this ship has weapon tubes but lacks beam weapons and is out of weapons stock, it attempts to Retreat to a weapons restock target within long-range radar range.
    /// Example: ship:orderRoaming()
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderRoaming);
    /// Orders this CpuShip to move toward the given SpaceObject and dock, restock weapons, and repair its hull.
    /// If the SpaceObject is a dockable ShipTemplateBasedObject, this ship moves directly toward it and docks with it as soon as possible.
    /// If not, this ship moves toward the best weapons restocking target within relay range (double its long-range radar range).
    /// If this ship still can't find a restocking target, or it is fully repaired and re-stocked, this ship reverts to Roaming orders.
    /// Example: ship:orderRetreat(base) -- retreat to the SpaceObject `base`
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderRetreat);
    /// Orders this CpuShip to stay at its current position and attack nearby hostiles.
    /// This ship will rotate to face a target and fires missiles within 4.5U if it has any, but won't move, roam, or patrol.
    /// Example: ship:orderStandGround()
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderStandGround);
    /// Orders this CpuShip to move to the given coordinates, patrol within a 1.5U radius, and attack any hostiles that move within 2U of its short-range radar range.
    /// If a targeted hostile moves more than 3U out of this ship's short-range radar range, this ship drops the target and resumes defending its position.
    /// Example: ship:orderDefendLocation(500, 1000) -- defend the space near these coordinates
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDefendLocation);
    /// Orders this CpuShip to maintain a 2U escort distance from the given SpaceObject and attack nearby hostiles.
    /// If a targeted hostile moves more than 3U out of this ship's short-range radar range, this ship drops the target and resumes escorting.
    /// If the SpaceObject being defended is destroyed, this ship reverts to Roaming orders.
    /// Example: ship:orderDefendTarget(base) -- defend the space near the SpaceObject `base`
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDefendTarget);
    /// Orders this CpuShip to fly toward the given SpaceObject and follow it from the given offset distance.
    /// This ship also targets anything its given SpaceObject targets.
    /// If the SpaceObject being followed is destroyed, this ship reverts to Roaming orders.
    /// Give multiple CpuShips the same SpaceObject and different offsets to create a formation.
    /// Example: ship:orderFlyFormation(leader, 500, 250) -- fly 0.5U off the wing and 0.25U off the tail of the SpaceObject `leader`
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyFormation);
    /// Orders this CpuShip to move toward the given coordinates, and to attack hostiles that approach within its short-range radar range during transit.
    /// This ship uses any warp or jump drive capabilities to arrive near its destination.
    /// This ship disengages from combat and continues toward its destination if its target moves more than 3U out of its short-range radar range.
    /// Upon arrival, this ship reverts to the Defend Location orders with its destination as the target.
    /// Example: ship:orderFlyTowards(500, 1000) -- move to these coordinates, attacking nearby hostiles on the way
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyTowards);
    /// Orders this CpuShip to move toward the given coordinates, ignoring all hostiles on the way.
    /// Upon arrival, this ship reverts to the Idle orders.
    /// Example: ship:orderFlyTowardsBlind(500, 1000) -- move to these coordinates, ignoring hostiles
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderFlyTowardsBlind);
    /// Orders this CpuShip to attack the given SpaceObject.
    /// Example: ship:orderAttack(player)
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderAttack);
    /// Orders this CpuShip to Fly Toward and dock with the given SpaceObject, if possible.
    /// If its target doesn't exist, revert to Roaming orders.
    /// Example: ship:orderDock(spaceStation)
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, orderDock);
    /// Returns this CpuShip's current orders.
    /// Example: ship_orders = ship:getOrder()
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, getOrder);
    /// Returns the coordinates for this CpuShip's orders.
    /// If the orders target a SpaceObject instead of coordinates, use CpuShip:getOrderTarget().
    /// Some orders, such as Roaming, have no target.
    /// Returns the order's x,y coordinates, or 0,0 if not defined.
    /// Example: x,y = ship:getOrderTargetLocation()
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, getOrderTargetLocation);
    /// Returns the target SpaceObject for this CpuShip's orders.
    /// If the orders target coordinates instead of an object, use CpuShip:getOrderTargetLocation().
    /// Some orders, such as Roaming, have no target.
    /// Example: target = ship:getOrderTarget()
    REGISTER_SCRIPT_CLASS_FUNCTION(CpuShip, getOrderTarget);
}

REGISTER_MULTIPLAYER_CLASS(CpuShip, "CpuShip");
CpuShip::CpuShip()
: SpaceShip("CpuShip")
{
    setRotation(random(0, 360));

    if (entity) {
        setFaction("Kraylor");
        entity.getOrAddComponent<AIController>().new_name = "default";
    }
}

CpuShip::~CpuShip()
{
}

void CpuShip::applyTemplateValues()
{
    SpaceShip::applyTemplateValues();

    if (auto ai = entity.getComponent<AIController>())
        ai->new_name = ship_template->default_ai_name;
}

void CpuShip::setAI(string new_ai)
{
    if (auto ai = entity.getComponent<AIController>())
        ai->new_name = new_ai;
}

void CpuShip::orderIdle()
{
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::Idle;
        ai->order_target = {};
        ai->order_target_location = glm::vec2(0, 0);
    }
}

void CpuShip::orderRoaming()
{
    auto thrusters = entity.getComponent<ManeuveringThrusters>();
    if (thrusters) thrusters->stop();
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::Roaming;
        ai->order_target = {};
        ai->order_target_location = glm::vec2(0, 0);
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Searching for targets."));
    }
}

void CpuShip::orderRoamingAt(glm::vec2 position)
{
    auto thrusters = entity.getComponent<ManeuveringThrusters>();
    if (thrusters) thrusters->stop();
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::Roaming;
        ai->order_target = {};
        ai->order_target_location = position;
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Searching for hostiles around {x},{y}.").format({{"x", string(position.x)}, {"y", string(position.y)}}));
    }
}

void CpuShip::orderRetreat(P<SpaceObject> object)
{
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::Retreat;
        if (!object)
        {
            ai->order_target = {};
            this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Searching for supplies."));
        }else{
            ai->order_target = object->entity;
            this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Docking to {callsign}.").format({{"callsign", object->getCallSign()}}));
        }
        ai->order_target_location = glm::vec2(0, 0);
    }
}

void CpuShip::orderStandGround()
{
    auto thrusters = entity.getComponent<ManeuveringThrusters>();
    if (thrusters) thrusters->stop();
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::StandGround;
        ai->order_target = {};
        ai->order_target_location = glm::vec2(0, 0);
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Standing ground for now."));
    }
}

void CpuShip::orderDefendLocation(glm::vec2 position)
{
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::DefendLocation;
        ai->order_target = {};
        ai->order_target_location = position;
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Defending {x},{y}.").format({{"x", string(position.x)}, {"y", string(position.y)}}));
    }
}

void CpuShip::orderDefendTarget(P<SpaceObject> object)
{
    if (!object)
        return;
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::DefendTarget;
        ai->order_target = object->entity;
        ai->order_target_location = glm::vec2(0, 0);
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Defending {callsign}.").format({{"callsign", object->getCallSign()}}));
    }
}

void CpuShip::orderFlyFormation(P<SpaceObject> object, glm::vec2 offset)
{
    if (!object)
        return;
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::FlyFormation;
        ai->order_target = object->entity;
        ai->order_target_location = offset;
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Following {callsign}.").format({{"callsign", object->getCallSign()}}));
    }
}

void CpuShip::orderFlyTowards(glm::vec2 target)
{
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::FlyTowards;
        ai->order_target = {};
        ai->order_target_location = target;
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Moving to {x},{y}.").format({{"x", string(target.x)}, {"y", string(target.y)}}));
    }
}

void CpuShip::orderFlyTowardsBlind(glm::vec2 target)
{
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::FlyTowardsBlind;
        ai->order_target = {};
        ai->order_target_location = target;
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Moving to {x},{y}.").format({{"x", string(target.x)}, {"y", string(target.y)}}));
    }
}

void CpuShip::orderAttack(P<SpaceObject> object)
{
    if (!object)
        return;
    
    // Attack only if the target is hostile.
    // Otherwise we just chase the target without firing on it.
    if (this->isEnemy(object))
    {
        if (auto ai = entity.getComponent<AIController>()) {
            ai->orders = AIOrder::Attack;
            ai->order_target = {};
            ai->order_target_location = glm::vec2(0, 0);
            this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Moving to attack {callsign}!").format({{"callsign", object->getCallSign()}}));
        }
    } else {
        LOG(WARNING) << "Tried to give " + this->getCallSign() + " an order to attack a non-hostile target";
        return;
    }
}

void CpuShip::orderDock(P<SpaceObject> object)
{
    if (!object)
        return;
    if (auto ai = entity.getComponent<AIController>()) {
        ai->orders = AIOrder::Dock;
        ai->order_target = {};
        ai->order_target_location = glm::vec2(0, 0);
        this->addBroadcast(FactionRelation::Friendly, tr("cpulog", "Docking to {callsign}.").format({{"callsign", object->getCallSign()}}));
    }
}

void CpuShip::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    SpaceShip::drawOnGMRadar(renderer, position, scale, rotation, long_range);
    //if (game_server && ai)
    //TODO    ai->drawOnGMRadar(renderer, position, scale);
}

std::unordered_map<string, string> CpuShip::getGMInfo()
{
    std::unordered_map<string, string> ret = SpaceShip::getGMInfo();
    //ret[trMark("gm_info", "Orders")] = getLocaleAIOrderString(orders);
    return ret;
}

string CpuShip::getExportLine()
{
    string ret = "CpuShip():setFaction(\"" + getFaction() + "\"):setTemplate(\"" + template_name + "\"):setCallSign(\"" + getCallSign() + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")";

    if (getShortRangeRadarRange() != ship_template->short_range_radar_range)
    {
        ret += ":setShortRangeRadarRange(" + string(getShortRangeRadarRange(), 0) + ")";
    }

    if (getLongRangeRadarRange() != ship_template->long_range_radar_range)
    {
        ret += ":setLongRangeRadarRange(" + string(getLongRangeRadarRange(), 0) + ")";
    }
/*
    switch(orders)
    {
    case AIOrder::Idle: break;
    case AIOrder::Roaming: ret += ":orderRoaming()"; break;
    case AIOrder::Retreat: ret += ":orderRetreat(?)"; break;
    case AIOrder::StandGround: ret += ":orderStandGround()"; break;
    case AIOrder::DefendLocation: ret += ":orderDefendLocation(" + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AIOrder::DefendTarget: ret += ":orderDefendTarget(?)"; break;
    case AIOrder::FlyFormation: ret += ":orderFlyFormation(?, " + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AIOrder::FlyTowards: ret += ":orderFlyTowards(" + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AIOrder::FlyTowardsBlind: ret += ":orderFlyTowardsBlind(" + string(order_target_location.x, 0) + ", " + string(order_target_location.y, 0) + ")"; break;
    case AIOrder::Attack: ret += ":orderAttack(?)"; break;
    case AIOrder::Dock: ret += ":orderDock(?)"; break;
    }
    */
    return ret + getScriptExportModificationsOnTemplate();
}

string getAIOrderString(AIOrder order)
{
    switch(order)
    {
    case AIOrder::Idle: return "Idle";
    case AIOrder::Roaming: return "Roaming";
    case AIOrder::Retreat: return "Retreat";
    case AIOrder::StandGround: return "Stand Ground";
    case AIOrder::DefendLocation: return "Defend Location";
    case AIOrder::DefendTarget: return "Defend Target";
    case AIOrder::FlyFormation: return "Fly in formation";
    case AIOrder::FlyTowards: return "Fly towards";
    case AIOrder::FlyTowardsBlind: return "Fly towards (ignore all)";
    case AIOrder::Attack: return "Attack";
    case AIOrder::Dock: return "Dock";
    }
    return "Unknown";
}

string getLocaleAIOrderString(AIOrder order)
{
    switch(order)
    {
    case AIOrder::Idle: return tr("orderscpu", "Idle");
    case AIOrder::Roaming: return tr("orderscpu", "Roaming");
    case AIOrder::Retreat: return tr("orderscpu", "Retreat");
    case AIOrder::StandGround: return tr("orderscpu", "Stand Ground");
    case AIOrder::DefendLocation: return tr("orderscpu", "Defend Location");
    case AIOrder::DefendTarget: return tr("orderscpu", "Defend Target");
    case AIOrder::FlyFormation: return tr("orderscpu", "Fly in formation");
    case AIOrder::FlyTowards: return tr("orderscpu", "Fly towards");
    case AIOrder::FlyTowardsBlind: return tr("orderscpu", "Fly towards (ignore all)");
    case AIOrder::Attack: return tr("orderscpu", "Attack");
    case AIOrder::Dock: return tr("orderscpu", "Dock");
    }
    return "Unknown";
}

template<> int convert<AIOrder>::returnType(lua_State* L, AIOrder o)
{
    lua_pushstring(L, getAIOrderString(o).c_str());
    return 1;
}
