local Entity = getLuaEntityFunctionTable()
__default_player_ship_faction = "Human Navy"

--- A PlayerSpaceship is a player-controlled ship entity. It has all the components of a ship (weapons, drives, systems) plus player-specific components (crew controls, waypoints, custom buttons).
--- If a function name begins with "command", the function is equivalent to the crew taking a corresponding action.
--- Such commands can be limited by the ship's capabilities, including systems damage, lack of power, or insufficient weapons stocks.
--- @type creation
function PlayerSpaceship()
    local e = createEntity()

    -- player ships default to fully scanned
    local scan_state = {allow_simple_scan = true}
    for idx, faction in ipairs(getEntitiesWithComponent("faction_info")) do
        table.insert(scan_state, {faction = faction, state = "fullscan"})
    end

    e.components = {
        player_control = {},
        ship_log = {},
        custom_ship_functions = {},
        transform = {rotation=random(0, 360)},
        callsign = {callsign=generateRandomCallSign()},
        scan_state = scan_state,
    }
    e:setFaction(__default_player_ship_faction)
    return e
end

--- Returns the coordinates of a waypoint with the given index that's been set by this player ship.
--- Waypoints are 1-indexed.
--- Example: x,y = player:getWaypoint(1)
function Entity:getWaypoint(index)
    if self.components.waypoints and index > 0 and index <= #self.components.waypoints then
        local wp = self.components.waypoints[index]
        return wp.x, wp.y
    end
    return 0, 0
end
--- Returns visual ID of the waypoint.
--- Waypoints are 1-indexed.
--- Example: id = player:getWaypointID(1)
function Entity:getWaypointID(index)
    if self.components.waypoints and index > 0 and index <= #self.components.waypoints then
        local wp = self.components.waypoints[index]
        return wp.id
    end
    return 0
end
--- Returns the total number of active waypoints owned by this player ship.
--- Example: player:getWaypointCount()
function Entity:getWaypointCount()
    if self.components.waypoints then return #self.components.waypoints end
    return 0
end
--- Returns this player ship's EAlertLevel.
--- Returns "Normal", "YELLOW ALERT", "RED ALERT", which differ from the valid values for commandSetAlertLevel().
--- Example: player:getAlertLevel()
function Entity:getAlertLevel()
    if self.components.player_control then return self.components.player_control.alert_level end
    return "Normal"
end
--- Defines whether this player ship's shields are raised (true) or lowered (false).
--- Compare to CPU ships, whose shields are always active.
--- Example: player:setShieldsActive(true)
function Entity:setShieldsActive(active)
    if self.components.shields ~= nil then self.components.shields.active = active end
    return self
end
--- Adds a message to this player ship's log.
--- Takes a string as the message and a color applied to the logged message.
--- Example: player:addToShipLog("Acknowledged","yellow") -- adds "Acknowledged" in yellow to the `player` ship's log
function Entity:addToShipLog(message, color)
    addEntryToShipsLog(self, message, color)
end
--- Moves all players connected to this ship to the same crew positions on another player ship.
--- If the target isn't a player ship, this function has no effect.
--- Use this in scenarios to change the crew's ship.
--- Example: player:transferPlayersToShip(player2) -- transfer all player crew to `player2`
function Entity:transferPlayersToShip(other_ship)
    transferPlayersFromShipToShip(self, other_ship)
end
--- Transfers only the crew members on a specific crew position to another player ship.
--- If a player is in multiple positions, this matches any of their positions and moves that player to all of the same positions on the destination ship.
--- Example: player:transferPlayersAtPositionToShip("helms",player2) -- transfer all crew on Helms to `player2`
function Entity:transferPlayersAtPositionToShip(station, other_ship)
    transferPlayersFromShipToShip(self, other_ship, station)
end
--- Returns whether a player occupies the given crew position on this player ship.
--- Example: player:hasPlayerAtPosition("helms")
function Entity:hasPlayerAtPosition(station)
    return hasPlayerCrewAtPosition(self, station)
end

--- Returns whether this player ship's comms are not in use.
--- Use this to determine whether the player can accept an incoming hail or chat.
--- Example: player:isCommsInactive()
function Entity:isCommsInactive()
    if self.components.comms_transmitter then return self.components.comms_transmitter.state == "inactive" end
    return true
end
--- Returns whether this player ship is opening comms with another entity.
--- Example: player:isCommsOpening()
function Entity:isCommsOpening()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "opening"
    end
end
--- Returns whether this player ship is being hailed by another entity.
--- Example: player:isCommsBeingHailed()
function Entity:isCommsBeingHailed()
    if self.components.comms_transmitter then
        local state = self.components.comms_transmitter.state
        return state == "hailed" or state == "hailed_player" or state == "hailed_gm"
    end
end
--- Returns whether this player ship is being hailed by the GM.
--- Example: player:isCommsBeingHailedByGM()
function Entity:isCommsBeingHailedByGM()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "hailed_gm"
    end
end
--- Returns whether comms to this player ship have failed to open.
--- Example: player:isCommsFailed()
function Entity:isCommsFailed()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "failed"
    end
end
--- Returns whether comms to this player ship were broken off by the other entity.
--- Example: player:isCommsBroken()
function Entity:isCommsBroken()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "broken"
    end
end
--- Returns whether comms between this player ship and an entity were intentionally closed.
--- Example: player:isCommsClosed()
function Entity:isCommsClosed()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "closed"
    end
end
--- Returns whether this player ship is engaged in text chat with either the GM or another player ship.
--- Example: player:isCommsChatOpen()
function Entity:isCommsChatOpen()
    if self.components.comms_transmitter then
        local state = self.components.comms_transmitter.state
        return state == "open_gm" or state == "open_player"
    end
end
--- Returns whether this player ship is engaged in text chat with the GM.
--- Example: player:isCommsChatOpenToGM()
function Entity:isCommsChatOpenToGM()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "open_gm"
    end
end
--- Returns whether this player ship is engaged in text chat with another player ship.
--- Example: player:isCommsChatOpenToPlayer()
function Entity:isCommsChatOpenToPlayer()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "open_player"
    end
end
--- Returns whether this player ship is engaged in comms with a scripted entity.
--- Example: player:isCommsScriptOpen()
function Entity:isCommsScriptOpen()
    if self.components.comms_transmitter then
        return self.components.comms_transmitter.state == "open"
    end
end

--- Sets this player ship's energy level.
--- Values are limited from 0 to the energy level max. Negative or excess values are capped to the limits.
--- Example: player:setEnergyLevel(1000) -- sets the ship's energy to either 1000 or the max limit, whichever is lower
function Entity:setEnergyLevel(amount)
    if self.components.reactor then self.components.reactor.energy = amount end
    return self
end
--- Sets this player ship's energy capacity.
--- Valid values are 0 or any positive number.
--- If the new limit is lower than the ship's current energy level, this also reduces the energy level.
--- Example: player:setEnergyLevelMax(1000) -- sets the ship's energy limit to 1000
function Entity:setEnergyLevelMax(amount)
    if self.components.reactor then self.components.reactor.max_energy = amount end
    return self
end
--- Returns this player ship's energy level.
--- Example: player:getEnergyLevel()
function Entity:getEnergyLevel()
    if self.components.reactor then return self.components.reactor.energy end
    return 0
end
--- Returns this player ship's energy capacity.
--- Example: player:getEnergyLevelMax()
function Entity:getEnergyLevelMax()
    if self.components.reactor then return self.components.reactor.max_energy end
    return 0
end

--- Returns how much energy is consumed per second by this player ship's shields while active.
--- Example: player:getEnergyShieldUsePerSecond()
function Entity:getEnergyShieldUsePerSecond()
    if self.components.shields then return self.components.shields.energy_use_per_second end
    return 0.0
end
--- Sets how much energy is consumed per second by this player ship's shields while active.
--- Example: player:setEnergyShieldUsePerSecond(1.5)
function Entity:setEnergyShieldUsePerSecond(amount)
    if self.components.shields then self.components.shields.energy_use_per_second = amount end
    return self
end
--- Returns how much energy is consumed per second by this player ship's warp drive while in use.
--- Example: player:getEnergyWarpPerSecond()
function Entity:getEnergyWarpPerSecond()
    if self.components.warp_drive then return self.components.warp_drive.energy_warp_per_second end
    return 0.0
end
--- Sets how much energy is consumed per second by this player ship's warp drive while in use.
--- Example: player:setEnergyWarpPerSecond(1.7)
function Entity:setEnergyWarpPerSecond(amount)
    if self.components.warp_drive then self.components.warp_drive.energy_warp_per_second = amount end
    return self
end

--- Sets the maximum amount of coolant available to engineering on this player ship.
--- Defaults to 10, which by default allows engineering to set 100% coolant on one system.
--- Valid values are 0 or any positive number.
--- If the new limit is less than the coolant already distributed, this automatically reduces distribution percentages.
--- Example: player:setMaxCoolant(5) -- halves the amount of available coolant
function Entity:setMaxCoolant(amount)
    if self.components.coolant then self.components.coolant.max = amount end
    return self
end
--- Returns the maximum amount of coolant available to engineering on this player ship.
--- Example: player:getMaxCoolant()
function Entity:getMaxCoolant()
    if self.components.coolant then return self.components.coolant.max end
    return 0.0
end

--- Sets the number of scan probes stocked by this player ship.
--- Values are limited from 0 to the scan probe count max. Negative or excess values are capped to the limits.
--- Example: player:setScanProbeCount(20) -- sets the ship's scan probes to either 20 or the max limit, whichever is fewer
function Entity:setScanProbeCount(amount)
    if self.components.scan_probe_launcher then self.components.scan_probe_launcher.stock = amount end
    return self
end
--- Returns the number of scan probes stocked by this player ship.
--- Example: player:getScanProbeCount()
function Entity:getScanProbeCount()
    if self.components.scan_probe_launcher then return self.components.scan_probe_launcher.stock end
    return 0
end
--- Sets this player ship's capacity for scan probes.
--- Valid values are 0 or any positive number.
--- If the new limit is less than the current scan probe stock, this automatically reduces the stock.
--- Example: player:setMaxScanProbeCount(30) -- sets the ship's scan probe capacity to 30
function Entity:setMaxScanProbeCount(amount)
    if self.components.scan_probe_launcher then self.components.scan_probe_launcher.max = amount end
    return self
end
--- Returns this player ship's capacity for scan probes.
--- Example: player:getMaxScanProbeCount()
function Entity:getMaxScanProbeCount()
    if self.components.scan_probe_launcher then return self.components.scan_probe_launcher.max end
    return 0
end
--- Adds a custom interactive button with the given reference name to the given crew position screen.
--- By default, custom buttons and info are stacked in order of creation.
--- If the reference name is unique, this creates a new button. If the reference name exists, this modifies the existing button.
--- The caption sets the button's text label.
--- When clicked, the button calls the given function.
--- Example:
--- -- Add a custom button to Engineering that prints the player ship's coolant max to the console or logging file when clicked
--- player:addCustomButton("engineering","get_coolant_max","Get Coolant Max",function() print("Coolant: " .. player:getMaxCoolant()) end)
function Entity:addCustomButton(station, key, label, callback)
    setPlayerShipCustomFunction(self, "button", key, label, station, callback, 0)
    return self
end
--- Adds a custom non-interactive info label with the given reference name to the given crew position screen.
--- By default, custom buttons and info are stacked in order of creation. Use the order value to specify a priority.
--- If the reference name is unique, this creates a new info. If the reference name exists, this modifies the existing info.
--- The caption sets the info's text value.
--- Example:
--- -- Displays the coolant max value on Engineering at or near the top of the custom button/info order
--- player:addCustomInfo("engineering","show_coolant_max","Coolant Max: " .. player:getMaxCoolant(),0)
function Entity:addCustomInfo(station, key, label, order)
    setPlayerShipCustomFunction(self, "info", key, label, station, nil, order)
    return self
end
--- Displays a dismissable message with the given reference name on the given crew position screen.
--- The caption sets the message's text.
--- Example:
--- -- Displays the coolant max value on Engineering as a dismissable message
--- player:addCustomMessage("engineering","message_coolant_max","Coolant max: " .. player:getMaxCoolant())
function Entity:addCustomMessage(station, key, message)
    setPlayerShipCustomFunction(self, "message", key, message, station, nil, 0)
    return self
end
--- As addCustomMessage(), but calls the given function when dismissed.
--- Example:
--- -- Displays the coolant max value on Engineering as a dismissable message, and prints "dismissed" to the console or logging file when dismissed
--- player:addCustomMessageWithCallback("engineering","message_coolant_max","Coolant max: " .. player:getMaxCoolant(),function() print("Dismissed!") end)
function Entity:addCustomMessageWithCallback(station, key, message, callback)
    setPlayerShipCustomFunction(self, "message", key, message, station, callback, 0)
    return self
end
--- Removes the custom function, info, or message with the given reference name.
--- Example: player:removeCustom("show_coolant_max") -- removes the custom item named "show_coolant_max"
function Entity:removeCustom(key)
    removePlayerShipCustomFunction(self, key)
    return self
end

--- Returns the index of the ESystem targeted by this player ship's weapons.
--- Returns -1 for the hull.
--- Example: player:getBeamSystemTarget()
function Entity:getBeamSystemTarget()
    local target_name = self:getBeamSystemTargetName()
    if target_name == "reactor" then return 0 end
    if target_name == "beamweapons" then return 1 end
    if target_name == "missilesystem" then return 2 end
    if target_name == "maneuver" then return 3 end
    if target_name == "impulse" then return 4 end
    if target_name == "warp" then return 5 end
    if target_name == "jumpdrive" then return 6 end
    if target_name == "frontshield" then return 7 end
    if target_name == "rearshield" then return 8 end
    return -1
end
--- Returns the name of the ESystem targeted by this player ship's weapons.
--- Returns "UNKNOWN" for the hull.
--- Example: player:getBeamSystemTargetName()
function Entity:getBeamSystemTargetName()
    if self.components.beam_weapons then return self.components.beam_weapons.system_target end
    return "UNKNOWN"
end

--- Commands this player ship to set a new target rotation.
--- A value of 0 is equivalent to a heading of 90 degrees ("east").
--- Accepts 0, positive, or negative values.
--- To objectively rotate the player ship as an entity, rather than commanding it to turn using its maneuverability, use setRotation().
--- Examples:
--- player:commandTargetRotation(0) -- command the ship toward a heading of 90 degrees
--- heading = 180; player:commandTargetRotation(heading - 90) -- command the ship toward a heading of 180 degrees
function Entity:commandTargetRotation(target)
    commandTargetRotation(self, target)
    return self
end
--- Commands this player ship to request a new impulse speed.
--- Valid values are -1.0 (-100%; full reverse) to 1.0 (100%; full forward).
--- The ship's impulse value remains bound by its impulse acceleration rates.
--- Example: player:commandImpulse(0.5) -- command this ship to engage forward half impulse
function Entity:commandImpulse(target)
    commandImpulse(self, target)
    return self
end
--- Commands this player ship to request a new warp level.
--- Valid values are any positive integer, or 0.
--- Warp controls on crew position screens are limited to 4.
--- Example: player:commandWarp(2) -- activate the warp drive at level 2
function Entity:commandWarp(target)
    commandWarp(self, target)
    return self
end
--- Commands this player ship to request a jump of the given distance.
--- Valid values are any positive number, or 0, including values outside of the ship's minimum and maximum jump ranges.
--- A jump of a greater distance than the ship's maximum jump range results in a negative jump drive charge.
--- Example: player:commandJump(25000) -- initiate a 25U jump on the current heading
function Entity:commandJump(target)
    commandJump(self, target)
    return self
end
--- Commands this player ship to abort a jump in progress.
--- Example: player:commandAbortJump() -- aborts a jump if in progress
function Entity:commandAbortJump()
    commandAbortJump(self)
    return self
end
--- Commands this player ship to set its weapons target to the given entity.
--- Example: player:commandSetTarget(enemy)
function Entity:commandSetTarget(target)
    commandSetTarget(self, target)
    return self
end
--- Commands this player ship to load the WeaponTube with the given index with the given weapon type.
--- This command respects tube allow/disallow limits.
--- Example: player:commandLoadTube(0,"HVLI")
function Entity:commandLoadTube(index, missile_type)
    commandLoadTube(self, index, missile_type)
    return self
end
--- Commands this player ship to unload the WeaponTube with the given index.
--- Example: player:commandUnloadTube(0)
function Entity:commandUnloadTube(index)
    commandUnloadTube(self, index)
    return self
end
--- Commands this player ship to fire the WeaponTube with the given index.
--- The tube fires in its current direction. To fire at a specific target, use commandFireTubeAtTarget().
--- Example: player:commandFireTube(0) -- command firing tube 0
function Entity:commandFireTube(index)
    commandFireTube(self, index)
    return self
end
--- Commands this player ship to fire the given weapons tube with the given entity as its target.
--- Example: player:commandFireTubeAtTarget(0,enemy) -- command firing tube 0 at target `enemy`
function Entity:commandFireTubeAtTarget(index, target)
    commandFireTubeAtTarget(self, index, target)
    return self
end
--- Commands this player ship to raise (true) or lower (false) its shields.
--- Example: player:commandSetShields(true) -- command raising shields
function Entity:commandSetShields(enabled)
    commandSetShields(self, enabled)
    return self
end
--- Commands this player ship to change its Main Screen view to the given setting.
--- Example: player:commandMainScreenSetting("tactical") -- command setting the main screen view to tactical radar
function Entity:commandMainScreenSetting(setting)
    commandMainScreenSetting(self, setting)
    return self
end
--- Commands this player ship to change its Main Screen comms overlay to the given setting.
--- Example: player:commandMainScreenOverlay("hidecomms") -- command setting the main screen view to hide the comms overlay
function Entity:commandMainScreenOverlay(setting)
    commandMainScreenOverlay(self, setting)
    return self
end
--- Commands this player ship to initiate a scan of the given entity.
--- If the scanning mini-game is enabled, this opens it on the relevant crew screens.
--- This command does NOT respect the player's ability to select the object for scanning, whether due to it being out of radar range or otherwise untargetable.
--- Example: player:commandScan(enemy)
function Entity:commandScan(target)
    commandScan(self, target)
    return self
end
--- Commands this player ship to set the power level of the given system.
--- Valid values are 0 or greater, with 1.0 equivalent to 100 percent. Values greater than 1.0 are allowed.
--- Example: player:commandSetSystemPowerRequest("impulse",1.0) -- command setting the impulse drive power to 100%
function Entity:commandSetSystemPowerRequest(system, request)
    commandSetSystemPowerRequest(self, system, request)
    return self
end
--- Commands this player ship to set the coolant level of the given system.
--- Valid values are from 0 to 10.0, with 10.0 equivalent to 100 percent.
--- Values greater than 10.0 are allowed if the ship's coolant max is greater than 10.0, but controls on crew position screens are limited to 10.0 (100%).
--- Example: player:commandSetSystemCoolantRequest("impulse",10.0) -- command setting the impulse drive coolant to 100%
function Entity:commandSetSystemCoolantRequest(system, request)
    commandSetSystemCoolantRequest(self, system, request)
    return self
end
--- Commands this player ship to initiate docking with the given entity.
--- This initiates docking only if the target is dockable and within docking range.
--- Example: player:commandDock(base)
function Entity:commandDock(target)
    commandDock(self, target)
    return self
end
--- Commands this player ship to undock from any entity it's docked with.
--- Example: player:commandUndock()
function Entity:commandUndock()
    commandUndock(self)
    return self
end
--- Commands this player ship to abort an in-progress docking operation.
--- Example: player:commandAbortDock()
function Entity:commandAbortDock()
    commandAbortDock(self)
    return self
end
--- Commands this player ship to hail the given entity.
--- If the target object is a player ship or the GM is intercepting all comms, open text chat comms.
--- Example: player:commandOpenTextComm(base)
function Entity:commandOpenTextComm(target)
    commandOpenTextComm(self, target)
    return self
end
--- Commands this player ship to close comms.
--- Example: player:commandCloseTextComm()
function Entity:commandCloseTextComm()
    commandCloseTextComm(self)
    return self
end
--- Commands whether this player ship answers (true) or rejects (false) an incoming hail.
--- Example: player:commandAnswerCommHail(false) -- commands to reject an active incoming hail
function Entity:commandAnswerCommHail(response)
    commandAnswerCommHail(self, response)
    return self
end
--- Commands this player ship to select the reply with the given index during a comms dialogue.
--- Example: player:commandSendComm(0) -- commands to select the first option in a comms dialogue
function Entity:commandSendComm(index)
    commandSendComm(self, index)
    return self
end
--- Commands this player ship to send the given message to the active text comms chat.
--- This works whether the chat is with another player ship or the GM.
--- Example: player:commandSendCommPlayer("I will destroy you!") -- commands to send this message in the active text chat
function Entity:commandSendCommPlayer(message)
    commandSendCommPlayer(self, message)
    return self
end
--- Commands whether repair crews on this player ship automatically move to rooms of damaged systems.
--- Use this command to reduce the need for player interaction in Engineering, especially when combined with setAutoCoolant/auto_coolant_enabled.
--- Crews set to move automatically don't respect crew collisions, allowing multiple crew to occupy a single space.
--- Example: player:commandSetAutoRepair(true)
function Entity:commandSetAutoRepair(enabled)
    commandSetAutoRepair(self, enabled)
    return self
end
--- Commands this player ship to set its beam frequency to the given value.
--- Valid values are 0 to 20, which map to 400THz to 800THz at 20THz increments. (spaceship.cpp frequencyToString())
--- Example: player:commandSetBeamFrequency(2)
function Entity:commandSetBeamFrequency(index)
    commandSetBeamFrequency(self, index)
    return self
end
--- Commands this player ship to target the given ship system with its beam weapons.
function Entity:commandSetBeamSystemTarget(target)
    commandSetBeamSystemTarget(self, target)
    return self
end
--- Commands this player ship to calibrate its shield frequency to the given index.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Valid values are 0 (400THz) to 20 (800THz).
--- Unlike setShieldsFrequency(), this initiates shield calibration to change the frequency, which disables shields for a period.
--- Example: player:commandSetShieldFrequency(10) -- calibrate shield frequency to 600THz
function Entity:commandSetShieldFrequency(index)
    commandSetShieldFrequency(self, index)
    return self
end
--- Commands this player ship to add a waypoint at the given coordinates.
--- This respects the 9-waypoint limit and won't add more waypoints if 9 already exist.
--- Example: player:commandAddWaypoint(1000,2000)
function Entity:commandAddWaypoint(x, y)
    commandAddWaypoint(self, x, y)
    return self
end
--- Commands this player ship to remove the waypoint with the given index.
--- This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
--- Example: player:commandRemoveWaypoint(0) -- removes waypoint 1
function Entity:commandRemoveWaypoint(index)
    commandRemoveWaypoint(self, index)
    return self
end
--- Commands this player ship to move the waypoint with the given index to the given coordinates.
--- This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
--- Example: player:commandMoveWaypoint(0,-1000,-2000) -- moves waypoint 1 to -1000,-2000
function Entity:commandMoveWaypoint(index, x, y)
    commandMoveWaypoint(self, index, x, y)
    return self
end
--- Commands this player ship to activate its self-destruct sequence.
--- Example: player:commandActivateSelfDestruct()
function Entity:commandActivateSelfDestruct()
    commandActivateSelfDestruct(self)
    return self
end
--- Commands this player ship to cancel its self-destruct sequence.
--- Example: player:commandCancelSelfDestruct()
function Entity:commandCancelSelfDestruct()
    commandCancelSelfDestruct(self)
    return self
end
--- Commands this player ship to submit the given self-destruct authorization code for the code request with the given index.
--- Codes are 0-indexed. Index 0 corresponds to code A, 1 to B, etc.
--- Example: player:commandConfirmDestructCode(0,46223) -- commands submitting 46223 as self-destruct confirmation code A
function Entity:commandConfirmDestructCode(index, code)
    commandConfirmDestructCode(self, index, code)
    return self
end
--- Commands this player ship to set its forward combat maneuver to the given value.
--- Valid values are any from -1.0 (full reverse) to 1.0 (full forward).
--- The maneuver continues until the ship's combat maneuver reserves are depleted.
--- Crew screens allow only forward combat maneuvers, and the combat maneuver controls do not reflect a boost set via this command.
--- Example: player:commandCombatManeuverBoost(0.5) -- commands boosting forward at half combat maneuver capacity
function Entity:commandCombatManeuverBoost(amount)
    commandCombatManeuverBoost(self, amount)
    return self
end
--- Commands this player ship to launch a ScanProbe to the given coordinates.
--- Example: player:commandLaunchProbe(1000,2000) -- commands launching a scan probe to 1000,2000
function Entity:commandLaunchProbe(x, y)
    commandLaunchProbe(self, x, y)
    return self
end
--- Commands this player ship to link the science screen to the given ScanProbe.
--- This is equivalent to selecting a probe on Relay and clicking "Link to Science".
--- Unlike "Link to Science", this function can link science to any given probe, regardless of which ship launched it or what faction it belongs to.
--- Example: player:commandSetScienceLink(probe_object) -- link ScanProbe `probe` to this ship's science
function Entity:commandSetScienceLink(target)
    commandSetScienceLink(self, target)
    return self
end
--- Commands this player ship to unlink the science screen from any ScanProbe.
--- This is equivalent to clicking "Link to Science" on Relay when a link is already active.
--- Example: player:commandClearScienceLink()
function Entity:commandClearScienceLink()
    commandClearScienceLink(self)
    return self
end
--- Commands this player ship to set the given alert level.
--- Valid values are "normal", "yellow", "red", which differ from the values returned by getAlertLevel().
--- Example: player:commandSetAlertLevel("red") -- commands red alert
function Entity:commandSetAlertLevel(level)
    commandSetAlertLevel(self, level)
    return self
end

--- Returns the number of repair crews on this player ship.
--- Example: player:getRepairCrewCount()
function Entity:getRepairCrewCount()
    local count = 0
    for idx, e in ipairs(getEntitiesWithComponent("internal_crew")) do
        if e.components.internal_crew.ship == self then
            count = count + 1
        end
    end
    return count
end
--- Sets the total number of repair crews on this player ship.
--- If the value is less than the number of repair crews, this function removes repair crews.
--- If the value is greater, this function adds new repair crews into random rooms.
--- Example: player:setRepairCrewCount(5)
function Entity:setRepairCrewCount(amount)
    if self.components.internal_rooms then
        for idx, e in ipairs(getEntitiesWithComponent("internal_crew")) do
            if e.components.internal_crew.ship == self then
                amount = amount - 1
                if amount < 0 then
                    e:destroy()
                end
            end
        end
        for n=1,amount do
            local crew = createEntity()
            crew.components.internal_crew = {ship=self}
            crew.components.internal_repair_crew = {}
        end
    end
    return self
end
--- Defines whether automatic coolant distribution is enabled on this player ship.
--- If true, coolant is automatically distributed proportionally to the amount of heat in that system.
--- Use this command to reduce the need for player interaction in Engineering, especially when combined with commandSetAutoRepair/auto_repair_enabled.
--- Example: player:setAutoCoolant(true)
function Entity:setAutoCoolant(enabled)
    if self.components.coolant then self.components.coolant.auto_levels = enabled end
    return self
end
--- Sets a control code password required for a player to join this player ship.
--- Control codes are case-insensitive.
--- Example: player:setControlCode("abcde") -- matches "abcde", "ABCDE", "aBcDe"
function Entity:setControlCode(code)
    if self.components.player_control then self.components.player_control.control_code = code end
    return self
end
--- Defines a function to call when this player ship launches a probe.
--- Passes the launching player ship and launched ScanProbe.
--- Example:
--- -- Prints probe launch details to the console output or logging file
--- player:onProbeLaunch(function (player, probe)
---     print("Probe " .. probe:getCallSign() .. " launched from ship " .. player:getCallSign())
--- end)
function Entity:onProbeLaunch(callback)
    if self.components.scan_probe_launcher then self.components.scan_probe_launcher.on_launch = callback end
    return self
end
--- Defines a function to call when this player ship links a probe to the science screen.
--- Passes the player ship and linked ScanProbe.
--- Example:
--- -- Prints probe linking details to the console output or logging file
--- player:onProbeLink(function (player, probe)
---     print("Probe " .. probe:getCallSign() .. " linked to Science on ship " .. player:getCallSign())
--- end)
function Entity:onProbeLink(callback)
    if self.components.radar_link then self.components.radar_link.on_link = callback end
    return self
end
--- Defines a function to call when this player ship unlinks a probe from the science screen.
--- Passes the player ship and previously linked ScanProbe.
--- This function is not called when the probe is destroyed or expires.
--- See ScanProbe:onDestruction() and ScanProbe:onExpiration().
--- Example:
--- -- Prints probe unlinking details to the console output or logging file
--- player:onProbeUnlink(function (player, probe)
---     print("Probe " .. probe:getCallSign() .. " unlinked from Science on ship " .. player:getCallSign())
--- end)
function Entity:onProbeUnlink(callback)
    if self.components.radar_link then self.components.radar_link.on_unlink = callback end
    return self
end
--- Returns this ships's long-range radar range.
--- Example: player:getLongRangeRadarRange()
function Entity:getLongRangeRadarRange()
    if self.components.long_range_radar then return self.components.long_range_radar.long_range end
    return 50000
end
--- Returns this player ship's short-range radar range.
--- Example: player:getShortRangeRadarRange()
function Entity:getShortRangeRadarRange()
    if self.components.long_range_radar then return self.components.long_range_radar.short_range end
    return 5000
end
--- Sets this player ship's long-range radar range.
--- Player ships use this range on the science and operations screens' radar.
--- Example: player:setLongRangeRadarRange(30000) -- sets the ship's long-range radar range to 30U
function Entity:setLongRangeRadarRange(range)
    if self.components.long_range_radar then self.components.long_range_radar.long_range = range end
    return self
end
--- Sets this player ship's short-range radar range.
--- Player ships use this range on the helms, weapons, and single pilot screens' radar.
--- This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this ship can detect objects.
--- Example: player:setShortRangeRadarRange(5000) -- sets the ship's short-range radar range to 5U
function Entity:setShortRangeRadarRange(range)
    if self.components.long_range_radar then self.components.long_range_radar.short_range = range end
    return self
end
--- Defines whether scanning features appear on related crew screens in this player ship.
--- Example: player:setCanScan(true)
function Entity:setCanScan(enabled)
    if enabled then self.components.science_scanner = {} else self.components.science_scanner = nil end
    return self
end
--- Returns whether scanning features appear on related crew screens in this player ship.
--- Example: player:getCanScan()
function Entity:getCanScan()
    return self.components.science_scanner ~= nil
end
--- Defines whether hacking features appear on related crew screens in this player ship.
--- Example: player:setCanHack(true)
function Entity:setCanHack(enabled)
    if enabled then self.components.hacking_device = {} else self.components.hacking_device = nil end
    return self
end
--- Returns whether hacking features appear on related crew screens in this player ship.
--- Example: player:getCanHack()
function Entity:getCanHack()
    return self.components.hacking_device ~= nil
end
--- Defines whether the "Request Docking" button appears on related crew screens in this player ship.
--- This doesn't override any docking class restrictions set on a target ship.
--- Example: player:setCanDock(true)
function Entity:setCanDock(enabled)
    if enabled then
        self.components.docking_port = {}
    else
        self.components.docking_port = nil
    end
    return self
end
--- Returns whether the "Request Docking" button appears on related crew screens in this player ship.
--- Example: player:getCanDock()
function Entity:getCanDock()
    return self.components.docking_port ~= nil
end
--- Defines whether combat maneuver controls appear on related crew screens in this player ship.
--- Example: player:setCanCombatManeuver(true)
function Entity:setCanCombatManeuver(enabled)
    if enabled then self.components.combat_maneuvering_thrusters = {} else self.components.combat_maneuvering_thrusters = nil end
    return self
end
--- Returns whether combat maneuver controls appear on related crew screens in this player ship.
--- Example: player:getCanCombatManeuver()
function Entity:getCanCombatManeuver()
    return self.components.combat_maneuvering_thrusters ~= nil
end
--- Defines whether ScanProbe-launching controls appear on related crew screens in this player ship.
--- Example: player:setCanLaunchProbe(true)
function Entity:setCanLaunchProbe(enabled)
    if enabled then self.components.scan_probe_launcher = {} else self.components.scan_probe_launcher = nil end
    return self
end
--- Returns whether ScanProbe-launching controls appear on related crew screens in this player ship.
--- Example: player:getCanLaunchProbe()
function Entity:getCanLaunchProbe()
    return self.components.scan_probe_launcher ~= nil
end
--- Defines whether self-destruct controls appear on related crew screens in this player ship.
--- Example: player:setCanSelfDestruct(true)
function Entity:setCanSelfDestruct(enabled)
    if enabled then self.components.self_destruct = {} else self.components.self_destruct = nil end
    return self
end
--- Returns whether self-destruct controls appear on related crew screens in this player ship.
--- This returns false if this ship's self-destruct size and damage are both 0, even if you set setCanSelfDestruct(true).
--- Example: player:getCanSelfDestruct()
function Entity:getCanSelfDestruct()
    return self.components.self_destruct ~= nil
end
--- Sets the amount of damage done to nearby entities when this player ship self-destructs.
--- Any given value is randomized +/- 33 percent upon self-destruction.
--- Example: player:setSelfDestructDamage(150)
function Entity:setSelfDestructDamage(amount)
    if self.components.self_destruct then self.components.self_destruct.damage = amount end
    return self
end
--- Returns the amount of base damage done to nearby entities when this player ship self-destructs.
--- Example: player:getSelfDestructDamage()
function Entity:getSelfDestructDamage()
    if self.components.self_destruct then return self.components.self_destruct.damage end
    return 0
end
--- Sets the radius of the explosion created when this player ship self-destructs.
--- All entities within this radius are dealt damage upon self-destruction.
--- Example: player:setSelfDestructSize(1500) -- sets a 1.5U self-destruction explosion and damage radius
function Entity:setSelfDestructSize(size)
    if self.components.self_destruct then self.components.self_destruct.size = size end
    return self
end
--- Returns the radius of the explosion created when this player ship self-destructs.
--- All entities within this radius are dealt damage upon self-destruction.
--- Example: ship:getSelfDestructSize()
function Entity:getSelfDestructSize()
    if self.components.self_destruct then return self.components.self_destruct.size end
    return 0
end
