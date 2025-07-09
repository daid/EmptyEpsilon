local Entity = getLuaEntityFunctionTable()
__default_cpu_ship_faction = "Kraylor"

--- A CpuShip is an AI-controlled SpaceShip.
--- The AI can be assigned an order (be idle, roam freely, defend location, etc.) and a combat behavior state (attack at close or long range, be evasive).
--- AI behaviors are defined in ai.cpp and other files in src/ai/.
--- CpuShip:order... functions also broadcast their orders over friendly comms.
--- Autonomous combat AI orders use the CpuShip's short- and long-range radar ranges to acquire targets, which can be affected by nebulae.
--- They also rank prospective targets by their type, distance, and capabilities.
--- Example:
--- -- Place a Fighter-class Human Navy CpuShip, order it to roam, and if it engages in combat it will fight evasively
--- ship = CpuShip():setTemplate("Fighter"):setPosition(10000,3000):setFaction("Human Navy"):orderRoaming():setAI("evasive"):setScanned(true)
--- @type creation
function CpuShip()
    local e = createEntity()
    e.components = {
        transform = {rotation=random(0, 360)},
        ai_controller = {new_name="default", orders="roaming"},
        scan_state = {allow_simple_scan=true},
        callsign = {callsign=generateRandomCallSign()},
        comms_receiver = {script="comms_ship.lua"},
    }
    e:setFaction(__default_cpu_ship_faction)
    return e
end

--- Sets the default combat AI state for this CpuShip.
--- Combat AI states determine the AI's combat tactics and responses.
--- They're distinct from orders, which determine the ship's active objectives and are defined by CpuShip:order...() functions.
--- Combat AI state can be set per CpuShip, defined in the ShipTemplate, or left to "default".
--- Valid combat AI states are:
--- - "default" directly pursues enemies at beam range while making opportunistic missile attacks
--- - "evasion" maintains distance from enemy weapons and evades attacks
--- - "fighter" prefers strafing maneuvers and attacks briefly at close range while passing
--- - "missilevolley" prefers lining up missile attacks from long range
--- Example: ship:setAI("fighter")
function Entity:setAI(ai_name)
    if self.components.ai_controller then self.components.ai_controller.new_name = ai_name end
    return self
end
--- Orders this CpuShip to stay at its current position and do nothing.
--- Idle CpuShips don't target or attack nearby enemies.
--- Example: ship:orderIdle()
function Entity:orderIdle()
    if self.components.ai_controller then self.components.ai_controller.orders = "idle" end
    return self
end
--- Orders this CpuShip to roam and engage at will, without a specific target.
--- A Roaming ship can acquire hostile targets within its long-range radar range, and prefers the best hostile target within 2U of its short-range radar range.
--- If this ship has weapon tubes but lacks beam weapons and is out of weapons stock, it attempts to Retreat to a weapons restock target within long-range radar range.
--- Example: ship:orderRoaming()
function Entity:orderRoaming()
    if self.components.ai_controller then self.components.ai_controller = {orders = "roaming", order_target_location={0, 0}} end
    return self
end
function Entity:orderRoamingAt(x, y)
    if self.components.ai_controller then self.components.ai_controller = {orders = "roaming", order_target_location={x, y}} end
    return self
end
--- Orders this CpuShip to move toward the given SpaceObject and dock, restock weapons, and repair its hull.
--- If the SpaceObject is a dockable ShipTemplateBasedObject, this ship moves directly toward it and docks with it as soon as possible.
--- If not, this ship moves toward the best weapons restocking target within relay range (double its long-range radar range).
--- If this ship still can't find a restocking target, or it is fully repaired and re-stocked, this ship reverts to Roaming orders.
--- Example: ship:orderRetreat(base) -- retreat to the SpaceObject `base`
function Entity:orderRetreat(target)
    if self.components.ai_controller then self.components.ai_controller = {orders = "retreat", order_target=target} end
    return self
end
--- Orders this CpuShip to stay at its current position and attack nearby hostiles.
--- This ship will rotate to face a target and fires missiles within 4.5U if it has any, but won't move, roam, or patrol.
--- Example: ship:orderStandGround()
function Entity:orderStandGround()
    if self.components.ai_controller then self.components.ai_controller = {orders = "stand ground"} end
    return self
end
--- Orders this CpuShip to move to the given coordinates, patrol within a 1.5U radius, and attack any hostiles that move within 2U of its short-range radar range.
--- If a targeted hostile moves more than 3U out of this ship's short-range radar range, this ship drops the target and resumes defending its position.
--- Example: ship:orderDefendLocation(500, 1000) -- defend the space near these coordinates
function Entity:orderDefendLocation(x, y)
    if self.components.ai_controller then self.components.ai_controller = {orders = "defend location", order_target_location={x, y}} end
    return self
end
--- Orders this CpuShip to maintain a 2U escort distance from the given SpaceObject and attack nearby hostiles.
--- If a targeted hostile moves more than 3U out of this ship's short-range radar range, this ship drops the target and resumes escorting.
--- If the SpaceObject being defended is destroyed, this ship reverts to Roaming orders.
--- Example: ship:orderDefendTarget(base) -- defend the space near the SpaceObject `base`
function Entity:orderDefendTarget(target)
    if self.components.ai_controller then self.components.ai_controller = {orders = "defend target", order_target=target} end
    return self
end
--- Orders this CpuShip to fly toward the given SpaceObject and follow it from the given offset distance.
--- This ship also targets anything its given SpaceObject targets.
--- If the SpaceObject being followed is destroyed, this ship reverts to Roaming orders.
--- Give multiple CpuShips the same SpaceObject and different offsets to create a formation.
--- Example: ship:orderFlyFormation(leader, 500, 250) -- fly 0.5U off the wing and 0.25U off the tail of the SpaceObject `leader`
function Entity:orderFlyFormation(target, offset_x, offset_y)
    if self.components.ai_controller then self.components.ai_controller = {orders = "fly in formation", order_target=target, order_target_location={x, y}} end
    return self
end
--- Orders this CpuShip to move toward the given coordinates, and to attack hostiles that approach within its short-range radar range during transit.
--- This ship uses any warp or jump drive capabilities to arrive near its destination.
--- This ship disengages from combat and continues toward its destination if its target moves more than 3U out of its short-range radar range.
--- Upon arrival, this ship reverts to the Defend Location orders with its destination as the target.
--- Example: ship:orderFlyTowards(500, 1000) -- move to these coordinates, attacking nearby hostiles on the way
function Entity:orderFlyTowards(x, y)
    if self.components.ai_controller then self.components.ai_controller = {orders = "fly towards", order_target_location={x, y}} end
    return self
end
--- Orders this CpuShip to move toward the given coordinates, ignoring all hostiles on the way.
--- Upon arrival, this ship reverts to the Idle orders.
--- Example: ship:orderFlyTowardsBlind(500, 1000) -- move to these coordinates, ignoring hostiles
function Entity:orderFlyTowardsBlind(x, y)
    if self.components.ai_controller then self.components.ai_controller = {orders = "fly towards (ignore all)", order_target_location={x, y}} end
    return self
end
--- Orders this CpuShip to attack the given SpaceObject.
--- Example: ship:orderAttack(player)
function Entity:orderAttack(target)
    if self.components.ai_controller then self.components.ai_controller = {orders = "attack", order_target=target} end
    return self
end
--- Orders this CpuShip to Fly Toward and dock with the given SpaceObject, if possible.
--- If its target doesn't exist, revert to Roaming orders.
--- Example: ship:orderDock(spaceStation)
function Entity:orderDock(target)
    if self.components.ai_controller then self.components.ai_controller = {orders = "dock", order_target=target} end
    return self
end
--- Returns this CpuShip's current orders.
--- Example: ship_orders = ship:getOrder()
function Entity:getOrder()
    if self.components.ai_controller then return self.components.ai_controller.orders end
end
--- Returns the coordinates for this CpuShip's orders.
--- If the orders target a SpaceObject instead of coordinates, use CpuShip:getOrderTarget().
--- Some orders, such as Roaming, have no target.
--- Returns the order's x,y coordinates, or 0,0 if not defined.
--- Example: x,y = ship:getOrderTargetLocation()
function Entity:getOrderTargetLocation()
    if self.components.ai_controller then return table.unpack(self.components.ai_controller.order_target_location) end
end
--- Returns the target SpaceObject for this CpuShip's orders.
--- If the orders target coordinates instead of an object, use CpuShip:getOrderTargetLocation().
--- Some orders, such as Roaming, have no target.
--- Example: target = ship:getOrderTarget()
function Entity:getOrderTarget()
    if self.components.ai_controller then return self.components.ai_controller.order_target end
end
