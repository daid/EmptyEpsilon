local Entity = getLuaEntityFunctionTable()

--- A PlayerSpaceship is a SpaceShip controlled by a player crew.
--- If a function name begins with "command", the function is equivalent to the crew taking a corresponding action.
--- Such commands can be limited by the ship's capabilities, including systems damage, lack of power, or insufficient weapons stocks.
function PlayerSpaceship()
    local e = createEntity()
    e.player_control = {}
    e.transform = {rotation=random(0, 360)}
    e.callsign = {callsign="PL-???"}
    return e
end

--- Returns the coordinates of a waypoint with the given index that's been set by this PlayerSpaceship.
--- Waypoints are 1-indexed.
--- Example: x,y = player:getWaypoint(1)
function Entity:getWaypoint(index)
    --TODO
end
--- Returns the total number of active waypoints owned by this PlayerSpaceship.
--- Example: player:getWaypointCount()
function Entity:getWaypointCount()
    --TODO
end
--- Returns this PlayerSpaceship's EAlertLevel.
--- Returns "Normal", "YELLOW ALERT", "RED ALERT", which differ from the valid values for PlayerSpaceship:commandSetAlertLevel().
--- Example: player:getAlertLevel()
function Entity:getAlertLevel()
    --TODO
end
--- Defines whether this PlayerSpaceship's shields are raised (true) or lowered (false).
--- Compare to CpuShips, whose shields are always active.
--- Example: player:setShieldsActive(true)
function Entity:setShieldsActive(active)
    --TODO
end
--- Adds a message to this PlayerSpaceship's log.
--- Takes a string as the message and a color applied to the logged message.
--- Example: player:addToShipLog("Acknowledged","yellow") -- adds "Acknowledged" in yellow to the `player` ship's log
function Entity:addToShipLog(message, color)
    --TODO
end
--- Moves all players connected to this ship to the same crew positions on another PlayerSpaceship.
--- If the target isn't a PlayerSpaceship, this function has no effect.
--- Use this in scenarios to change the crew's ship.
--- Example: player:transferPlayersToShip(player2) -- transfer all player crew to `player2`
function Entity:transferPlayersToShip(other_ship)
    --TODO
end
--- Transfers only the crew members on a specific crew position to another PlayerSpaceship.
--- If a player is in multiple positions, this matches any of their positions and moves that player to all of the same positions on the destination ship.
--- Example: player:transferPlayersAtPositionToShip("helms",player2) -- transfer all crew on Helms to `player2`
function Entity:transferPlayersAtPositionToShip(station, other_ship)
    --TODO
end
--- Returns whether a player occupies the given crew position on this PlayerSpaceship.
--- Example: player:hasPlayerAtPosition("helms")
function Entity:hasPlayerAtPosition(station)
    --TODO
end

--- Returns whether this PlayerSpaceship's comms are not in use.
--- Use this to determine whether the player can accept an incoming hail or chat.
--- Example: player:isCommsInactive()
function Entity:isCommsInactive()
    --TODO
end
--- Returns whether this PlayerSpaceship is opening comms with another SpaceObject.
--- Example: player:isCommsOpening()
function Entity:isCommsOpening()
    --TODO
end
--- Returns whether this PlayerSpaceship is being hailed by another SpaceObject.
--- Example: player:isCommsBeingHailed()
function Entity:isCommsBeingHailed()
    --TODO
end
--- Returns whether this PlayerSpaceship is being hailed by the GM.
--- Example: player:isCommsBeingHailedByGM()
function Entity:isCommsBeingHailedByGM()
    --TODO
end
--- Returns whether comms to this PlayerSpaceship have failed to open.
--- Example: player:isCommsFailed()
function Entity:isCommsFailed()
    --TODO
end
--- Returns whether comms to this PlayerSpaceship were broken off by the other SpaceObject.
--- Example: player:isCommsBroken()
function Entity:isCommsBroken()
    --TODO
end
--- Returns whether comms between this PlayerSpaceship and a SpaceObject were intentionally closed.
--- Example: player:isCommsClosed()
function Entity:isCommsClosed()
    --TODO
end
--- Returns whether this PlayerSpaceship is engaged in text chat with either the GM or another PlayerSpaceship.
--- Example: player:isCommsChatOpen()
function Entity:isCommsChatOpen()
    --TODO
end
--- Returns whether this PlayerSpaceship is engaged in text chat with the GM.
--- Example: player:isCommsChatOpenToGM()
function Entity:isCommsChatOpenToGM()
    --TODO
end
--- Returns whether this PlayerSpaceship is engaged in text chat with another PlayerSpaceship.
--- Example: player:isCommsChatOpenToPlayer()
function Entity:isCommsChatOpenToPlayer()
    --TODO
end
--- Returns whether this PlayerSpaceship is engaged in comms with a scripted SpaceObject.
--- Example: player:isCommsScriptOpen()
function Entity:isCommsScriptOpen()
    --TODO
end

--- Sets this PlayerSpaceship's energy level.
--- Values are limited from 0 to the energy level max. Negative or excess values are capped to the limits.
--- Example: player:setEnergyLevel(1000) -- sets the ship's energy to either 1000 or the max limit, whichever is lower
function Entity:setEnergyLevel()
    --TODO
end
--- Sets this PlayerSpaceship's energy capacity.
--- Valid values are 0 or any positive number.
--- If the new limit is lower than the ship's current energy level, this also reduces the energy level.
--- Example: player:setEnergyLevelMax(1000) -- sets the ship's energy limit to 1000
function Entity:setEnergyLevelMax()
    --TODO
end
--- Returns this PlayerSpaceship's energy level.
--- Example: player:getEnergyLevel()
function Entity:getEnergyLevel()
    --TODO
end
--- Returns this PlayerSpaceship's energy capacity.
--- Example: player:getEnergyLevelMax()
function Entity:getEnergyLevelMax()
    --TODO
end

--- Returns how much energy is consumed per second by this PlayerSpaceship's shields while active.
--- Example: player:getEnergyShieldUsePerSecond()
function Entity:getEnergyShieldUsePerSecond()
    --TODO
end
--- Sets how much energy is consumed per second by this PlayerSpaceship's shields while active.
--- Example: player:setEnergyShieldUsePerSecond(1.5)
function Entity:setEnergyShieldUsePerSecond(amount)
    --TODO
end
--- Returns how much energy is consumed per second by this PlayerSpaceship's warp drive while in use.
--- Example: player:getEnergyWarpPerSecond()
function Entity:getEnergyWarpPerSecond()
    --TODO
end
--- Sets how much energy is consumed per second by this PlayerSpaceship's warp drive while in use.
--- Example: player:setEnergyWarpPerSecond(1.7)
function Entity:setEnergyWarpPerSecond(amount)
    --TODO
end

--- Sets the maximum amount of coolant available to engineering on this PlayerSpaceship.
--- Defaults to 10, which by default allows engineering to set 100% coolant on one system.
--- Valid values are 0 or any positive number.
--- If the new limit is less than the coolant already distributed, this automatically reduces distribution percentages.
--- Example: player:setMaxCoolant(5) -- halves the amount of available coolant
function Entity:setMaxCoolant()
    --TODO
end
--- Returns the maximum amount of coolant available to engineering on this PlayerSpaceship.
--- Example: player:getMaxCoolant()
function Entity:getMaxCoolant()
    --TODO
end

--- Sets the number of scan probes stocked by this PlayerSpaceship.
--- Values are limited from 0 to the scan probe count max. Negative or excess values are capped to the limits.
--- Example: player:setScanProbeCount(20) -- sets the ship's scan probes to either 20 or the max limit, whichever is fewer
function Entity:setScanProbeCount(amount)
    --TODO
end
--- Returns the number of scan probes stocked by this PlayerSpaceship.
--- Example: player:getScanProbeCount()
function Entity:getScanProbeCount()
    --TODO
end
--- Sets this PlayerSpaceship's capacity for scan probes.
--- Valid values are 0 or any positive number.
--- If the new limit is less than the current scan probe stock, this automatically reduces the stock.
--- Example: player:setMaxScanProbeCount(30) -- sets the ship's scan probe capacity to 30
function Entity:setMaxScanProbeCount(amount)
    --TODO
end
--- Returns this PlayerSpaceship's capacity for scan probes.
--- Example: player:getMaxScanProbeCount()
function Entity:getMaxScanProbeCount()
    --TODO
end

--- Adds a custom interactive button with the given reference name to the given crew position screen.
--- By default, custom buttons and info are stacked in order of creation. Use the order value to specify a priority, with lower values appearing higher in the list.
--- If the reference name is unique, this creates a new button. If the reference name exists, this modifies the existing button.
--- The caption sets the button's text label.
--- When clicked, the button calls the given function.
--- Example:
--- -- Add a custom button to Engineering, lower in the order relative to other items, that prints the player ship's coolant max to the console or logging file when clicked
--- player:addCustomButton("engineering","get_coolant_max","Get Coolant Max",function() print("Coolant: " .. player:getMaxCoolant()) end,10)
function Entity:addCustomButton(station, key, label, callback)
    --TODO
end
--- Adds a custom non-interactive info label with the given reference name to the given crew position screen.
--- By default, custom buttons and info are stacked in order of creation. Use the order value to specify a priority.
--- If the reference name is unique, this creates a new info. If the reference name exists, this modifies the existing info.
--- The caption sets the info's text value.
--- Example:
--- -- Displays the coolant max value on Engineering at or near the top of the custom button/info order
--- player:addCustomInfo("engineering","show_coolant_max","Coolant Max: " .. player:getMaxCoolant(),0)
function Entity:addCustomInfo(station, key, label, order)
    --TODO
end
--- Displays a dismissable message with the given reference name on the given crew position screen.
--- The caption sets the message's text.
--- Example:
--- -- Displays the coolant max value on Engineering as a dismissable message
--- player:addCustomMessage("engineering","message_coolant_max","Coolant max: " .. player:getMaxCoolant())
function Entity:addCustomMessage(station, key, message)
    --TODO
end
--- As PlayerSpaceship:addCustomMessage(), but calls the given function when dismissed.
--- Example:
--- -- Displays the coolant max value on Engineering as a dismissable message, and prints "dismissed" to the console or logging file when dismissed
--- player:addCustomMessageWithCallback("engineering","message_coolant_max","Coolant max: " .. player:getMaxCoolant(),function() print("Dismissed!") end)
function Entity:addCustomMessageWithCallback(station, key, message, callback)
    --TODO
end
--- Removes the custom function, info, or message with the given reference name.
--- Example: player:removeCustom("show_coolant_max") -- removes the custom item named "show_coolant_max"
function Entity:removeCustom(key)
    --TODO
end

--- Returns the index of the ESystem targeted by this PlayerSpaceship's weapons.
--- Returns -1 for the hull.
--- Example: player:getBeamSystemTarget()
function Entity:getBeamSystemTarget()
    --TODO
end
--- Returns the name of the ESystem targeted by this PlayerSpaceship's weapons.
--- Returns "UNKNOWN" for the hull.
--- Example: player:getBeamSystemTargetName()
function Entity:getBeamSystemTargetName()
    --TODO
end

--- Commands this PlayerSpaceship to set a new target rotation.
--- A value of 0 is equivalent to a heading of 90 degrees ("east").
--- Accepts 0, positive, or negative values.
--- To objectively rotate the PlayerSpaceship as a SpaceObject, rather than commanding it to turn using its maneuverability, use SpaceObject:setRotation().
--- Examples:
--- player:commandTargetRotation(0) -- command the ship toward a heading of 90 degrees
--- heading = 180; player:commandTargetRotation(heading - 90) -- command the ship toward a heading of 180 degrees
function Entity:commandTargetRotation(target)
    --TODO
end
--- Commands this PlayerSpaceship to request a new impulse speed.
--- Valid values are -1.0 (-100%; full reverse) to 1.0 (100%; full forward).
--- The ship's impulse value remains bound by its impulse acceleration rates.
--- Example: player:commandImpulse(0.5) -- command this ship to engage forward half impulse
function Entity:commandImpulse(target)
    --TODO
end
--- Commands this PlayerSpaceship to request a new warp level.
--- Valid values are any positive integer, or 0.
--- Warp controls on crew position screens are limited to 4.
--- Example: player:commandWarp(2) -- activate the warp drive at level 2
function Entity:commandWarp()
    --TODO
end
--- Commands this PlayerSpaceship to request a jump of the given distance.
--- Valid values are any positive number, or 0, including values outside of the ship's minimum and maximum jump ranges.
--- A jump of a greater distance than the ship's maximum jump range results in a negative jump drive charge.
--- Example: player:commandJump(25000) -- initiate a 25U jump on the current heading
function Entity:commandJump()
    --TODO
end
--- Commands this PlayerSpaceship to set its weapons target to the given SpaceObject.
--- Example: player:commandSetTarget(enemy)
function Entity:commandSetTarget()
    --TODO
end
--- Commands this PlayerSpaceship to load the WeaponTube with the given index with the given weapon type.
--- This command respects tube allow/disallow limits.
--- Example: player:commandLoadTube(0,"HVLI")
function Entity:commandLoadTube()
    --TODO
end
--- Commands this PlayerSpaceship to unload the WeaponTube with the given index.
--- Example: player:commandUnloadTube(0)
function Entity:commandUnloadTube()
    --TODO
end
--- Commands this PlayerSpaceship to fire the WeaponTube with the given index at the given missile target angle in degrees, without a weapons target.
--- The target angle behaves as if the Weapons crew had unlocked targeting and manually aimed its trajectory.
--- A target angle value of 0 is equivalent to a heading of 90 degrees ("east").
--- Accepts 0, positive, or negative values.
--- Examples:
--- player:commandFireTube(0,0) -- command firing tube 0 at a heading 90
--- target_heading = 180; player:commandFireTube(0,target_heading - 90) -- command firing tube 0 at a heading 180
function Entity:commandFireTube()
    --TODO
end
--- Commands this PlayerSpaceship to fire the given weapons tube with the given SpaceObject as its target.
--- Example: player:commandFireTubeAtTarget(0,enemy) -- command firing tube 0 at target `enemy`
function Entity:commandFireTubeAtTarget()
    --TODO
end
--- Commands this PlayerSpaceship to raise (true) or lower (false) its shields.
--- Example: player:commandSetShields(true) -- command raising shields
function Entity:commandSetShields()
    --TODO
end
--- Commands this PlayerSpaceship to change its Main Screen view to the given setting.
--- Example: player:commandMainScreenSetting("tactical") -- command setting the main screen view to tactical radar
function Entity:commandMainScreenSetting()
    --TODO
end
--- Commands this PlayerSpaceship to change its Main Screen comms overlay to the given setting.
--- Example: player:commandMainScreenOverlay("hidecomms") -- command setting the main screen view to hide the comms overlay
function Entity:commandMainScreenOverlay()
    --TODO
end
--- Commands this PlayerSpaceship to initiate a scan of the given SpaceObject.
--- If the scanning mini-game is enabled, this opens it on the relevant crew screens.
--- This command does NOT respect the player's ability to select the object for scanning, whether due to it being out of radar range or otherwise untargetable.
--- Example: player:commandScan(enemy)
function Entity:commandScan()
    --TODO
end
--- Commands this PlayerSpaceship to set the power level of the given system.
--- Valid values are 0 or greater, with 1.0 equivalent to 100 percent. Values greater than 1.0 are allowed.
--- Example: player:commandSetSystemPowerRequest("impulse",1.0) -- command setting the impulse drive power to 100%
function Entity:commandSetSystemPowerRequest()
    --TODO
end
--- Commands this PlayerSpaceship to set the coolant level of the given system.
--- Valid values are from 0 to 10.0, with 10.0 equivalent to 100 percent.
--- Values greater than 10.0 are allowed if the ship's coolant max is greater than 10.0, but controls on crew position screens are limited to 10.0 (100%).
--- Example: player:commandSetSystemCoolantRequest("impulse",10.0) -- command setting the impulse drive coolant to 100%
function Entity:commandSetSystemCoolantRequest()
    --TODO
end
--- Commands this PlayerSpaceship to initiate docking with the given SpaceObject.
--- This initiates docking only if the target is dockable and within docking range.
--- Example: player:commandDock(base)
function Entity:commandDock()
    --TODO
end
--- Commands this PlayerSpaceship to undock from any SpaceObject it's docked with.
--- Example: player:commandUndock()
function Entity:commandUndock()
    --TODO
end
--- Commands this PlayerSpaceship to abort an in-progress docking operation.
--- Example: player:commandAbortDock()
function Entity:commandAbortDock()
    --TODO
end
--- Commands this PlayerSpaceship to hail the given SpaceObject.
--- If the target object is a PlayerSpaceship or the GM is intercepting all comms, open text chat comms.
--- Example: player:commandOpenTextComm(base)
function Entity:commandOpenTextComm()
    --TODO
end
--- Commands this PlayerSpaceship to close comms.
--- Example: player:commandCloseTextComm()
function Entity:commandCloseTextComm()
    --TODO
end
--- Commands whether this PlayerSpaceship answers (true) or rejects (false) an incoming hail.
--- Example: player:commandAnswerCommHail(false) -- commands to reject an active incoming hail
function Entity:commandAnswerCommHail()
    --TODO
end
--- Commands this PlayerSpaceship to select the reply with the given index during a comms dialogue.
--- Example: player:commandSendComm(0) -- commands to select the first option in a comms dialogue
function Entity:commandSendComm()
    --TODO
end
--- Commands this PlayerSpaceship to send the given message to the active text comms chat.
--- This works whether the chat is with another PlayerSpaceship or the GM.
--- Example: player:commandSendCommPlayer("I will destroy you!") -- commands to send this message in the active text chat
function Entity:commandSendCommPlayer()
    --TODO
end
--- Commands whether repair crews on this PlayerSpaceship automatically move to rooms of damaged systems.
--- Use this command to reduce the need for player interaction in Engineering, especially when combined with setAutoCoolant/auto_coolant_enabled.
--- Crews set to move automatically don't respect crew collisions, allowing multiple crew to occupy a single space.
--- Example: player:commandSetAutoRepair(true)
function Entity:commandSetAutoRepair()
    --TODO
end
--- Commands this PlayerSpaceship to set its beam frequency to the given value.
--- Valid values are 0 to 20, which map to 400THz to 800THz at 20THz increments. (spaceship.cpp frequencyToString())
--- Example: player:commandSetAutoRepair(true)
function Entity:commandSetBeamFrequency()
    --TODO
end
--- Commands this PlayerSpaceship to target the given ship system with its beam weapons.
function Entity:commandSetBeamSystemTarget()
    --TODO
end
--- Sets this SpaceShip's shield frequency index.
--- To convert the index to the value used by players, multiply it by 20, then add 400.
--- Valid values are 0 (400THz) to 20 (800THz).
--- Unlike SpaceShip:setShieldsFrequency(), this initiates shield calibration to change the frequency, which disables shields for a period.
--- Example:
--- frequency = ship:setShieldsFrequency(10) -- frequency is 600THz
function Entity:commandSetShieldFrequency()
    --TODO
end
--- Commands this PlayerSpaceship to add a waypoint at the given coordinates.
--- This respects the 9-waypoint limit and won't add more waypoints if 9 already exist.
--- Example: player:commandAddWaypoint(1000,2000)
function Entity:commandAddWaypoint()
    --TODO
end
--- Commands this PlayerSpaceship to remove the waypoint with the given index.
--- This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
--- Example: player:commandRemoveWaypoint(0) -- removes waypoint 1
function Entity:commandRemoveWaypoint()
    --TODO
end
--- Commands this PlayerSpaceship to move the waypoint with the given index to the given coordinates.
--- This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
--- Example: player:commandMoveWaypoint(0,-1000,-2000) -- moves waypoint 1 to -1000,-2000
function Entity:commandMoveWaypoint()
    --TODO
end
--- Commands this PlayerSpaceship to activate its self-destruct sequence.
--- Example: player:commandActivateSelfDestruct()
function Entity:commandActivateSelfDestruct()
    --TODO
end
--- Commands this PlayerSpaceship to cancel its self-destruct sequence.
--- Example: player:commandCancelSelfDestruct()
function Entity:commandCancelSelfDestruct()
    --TODO
end
--- Commands this PlayerSpaceship to submit the given self-destruct authorization code for the code request with the given index.
--- Codes are 0-indexed. Index 0 corresponds to code A, 1 to B, etc.
--- Example: player:commandConfirmDestructCode(0,46223) -- commands submitting 46223 as self-destruct confirmation code A
function Entity:commandConfirmDestructCode()
    --TODO
end
--- Commands this PlayerSpaceship to set its forward combat maneuver to the given value.
--- Valid values are any from -1.0 (full reverse) to 1.0 (full forward).
--- The maneuver continues until the ship's combat maneuver reserves are depleted.
--- Crew screens allow only forward combat maneuvers, and the combat maneuver controls do not reflect a boost set via this command.
--- Example: player:commandCombatManeuverBoost(0.5) -- commands boosting forward at half combat maneuver capacity
function Entity:commandCombatManeuverBoost()
    --TODO
end
--- Commands this PlayerSpaceship to launch a ScanProbe to the given coordinates.
--- Example: player:commandLaunchProbe(1000,2000) -- commands launching a scan probe to 1000,2000
function Entity:commandLaunchProbe()
    --TODO
end
--- Commands this PlayerSpaceship to link the science screen to the given ScanProbe.
--- This is equivalent to selecting a probe on Relay and clicking "Link to Science".
--- Unlike "Link to Science", this function can link science to any given probe, regardless of which ship launched it or what faction it belongs to.
--- Example: player:commandSetScienceLink(probe_object) -- link ScanProbe `probe` to this ship's science
function Entity:commandSetScienceLink()
    --TODO
end
--- Commands this PlayerSpaceship to unlink the science screen from any ScanProbe.
--- This is equivalent to clicking "Link to Science" on Relay when a link is already active.
--- Example: player:commandClearScienceLink()
function Entity:commandClearScienceLink()
    --TODO
end
--- Commands this PlayerSpaceship to set the given alert level.
--- Valid values are "normal", "yellow", "red", which differ from the values returned by PlayerSpaceship:getAlertLevel().
--- Example: player:commandSetAlertLevel("red") -- commands red alert
function Entity:commandSetAlertLevel()
    --TODO
end

--- Returns the number of repair crews on this PlayerSpaceship.
--- Example: player:getRepairCrewCount()
function Entity:getRepairCrewCount()
    --TODO
end
--- Sets the total number of repair crews on this PlayerSpaceship.
--- If the value is less than the number of repair crews, this function removes repair crews.
--- If the value is greater, this function adds new repair crews into random rooms.
--- Example: player:setRepairCrewCount(5)
function Entity:setRepairCrewCount()
    --TODO
end
--- Defines whether automatic coolant distribution is enabled on this PlayerSpaceship.
--- If true, coolant is automatically distributed proportionally to the amount of heat in that system.
--- Use this command to reduce the need for player interaction in Engineering, especially when combined with commandSetAutoRepair/auto_repair_enabled.
--- Example: player:setAutoCoolant(true)
function Entity:setAutoCoolant()
    --TODO
end
--- Sets a control code password required for a player to join this PlayerSpaceship.
--- Control codes are case-insensitive.
--- Example: player:setControlCode("abcde") -- matches "abcde", "ABCDE", "aBcDe"
function Entity:setControlCode()
    --TODO
end
--- Defines a function to call when this PlayerSpaceship launches a probe.
--- Passes the launching PlayerSpaceship and launched ScanProbe.
--- Example:
--- -- Prints probe launch details to the console output or logging file
--- player:onProbeLaunch(function (player, probe)
---     print("Probe " .. probe:getCallSign() .. " launched from ship " .. player:getCallSign())
--- end)
function Entity:onProbeLaunch()
    --TODO
end
--- Defines a function to call when this PlayerSpaceship links a probe to the science screen.
--- Passes the PlayerShip and linked ScanProbe.
--- Example:
--- -- Prints probe linking details to the console output or logging file
--- player:onProbeLink(function (player, probe)
---     print("Probe " .. probe:getCallSign() .. " linked to Science on ship " .. player:getCallSign())
--- end)
function Entity:onProbeLink(callback)
    --TODO
end
--- Defines a function to call when this PlayerSpaceship unlinks a probe from the science screen.
--- Passes the PlayerShip and previously linked ScanProbe.
--- This function is not called when the probe is destroyed or expires.
--- See ScanProbe:onDestruction() and ScanProbe:onExpiration().
--- Example:
--- -- Prints probe unlinking details to the console output or logging file
--- player:onProbeUnlink(function (player, probe)
---     print("Probe " .. probe:getCallSign() .. " unlinked from Science on ship " .. player:getCallSign())
--- end)
function Entity:onProbeUnlink(callback)
    --TODO
end
--- Returns this PlayerSpaceship's long-range radar range.
--- Example: player:getLongRangeRadarRange()
function Entity:getLongRangeRadarRange()
    --TODO
end
--- Returns this PlayerSpaceship's short-range radar range.
--- Example: player:getShortRangeRadarRange()
function Entity:getShortRangeRadarRange()
    --TODO
end
--- Sets this PlayerSpaceship's long-range radar range.
--- PlayerSpaceships use this range on the science and operations screens' radar.
--- Example: player:setLongRangeRadarRange(30000) -- sets the ship's long-range radar range to 30U
function Entity:setLongRangeRadarRange(range)
    --TODO
end
--- Sets this PlayerSpaceship's short-range radar range.
--- PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
--- This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
--- Example: player:setShortRangeRadarRange(5000) -- sets the ship's long-range radar range to 5U
function Entity:setShortRangeRadarRange(range)
    --TODO
end
--- Defines whether scanning features appear on related crew screens in this PlayerSpaceship.
--- Example: player:setCanScan(true)
function Entity:setCanScan(enabled)
    --TODO
end
--- Returns whether scanning features appear on related crew screens in this PlayerSpaceship.
--- Example: player:getCanScan()
function Entity:getCanScan()
    --TODO
end
--- Defines whether hacking features appear on related crew screens in thisPlayerSpaceship.
--- Example: player:setCanHack(true)
function Entity:setCanHack(enabled)
    --TODO
end
--- Returns whether hacking features appear on related crew screens in this PlayerSpaceship.
--- Example: player:getCanHack()
function Entity:getCanHack()
    --TODO
end
--- Defines whether the "Request Docking" button appears on related crew screens in this PlayerSpaceship.
--- This doesn't override any docking class restrictions set on a target SpaceShip.
--- Example: player:setCanDock(true)
function Entity:setCanDock(enabled)
    --TODO
end
--- Returns whether the "Request Docking" button appears on related crew screens in this PlayerSpaceship.
--- Example: player:getCanDock()
function Entity:getCanDock()
    --TODO
end
--- Defines whether combat maneuver controls appear on related crew screens in this PlayerSpaceship.
--- Example: player:setCanCombatManeuver(true)
function Entity:setCanCombatManeuver(enabled)
    --TODO
end
--- Returns whether combat maneuver controls appear on related crew screens in this PlayerSpaceship.
--- Example: player:getCanCombatManeuver()
function Entity:getCanCombatManeuver()
    --TODO
end
--- Defines whether ScanProbe-launching controls appear on related crew screens in this PlayerSpaceship.
--- Example: player:setCanLaunchProbe(true)
function Entity:setCanLaunchProbe(enabled)
    --TODO
end
--- Returns whether ScanProbe-launching controls appear on related crew screens in this PlayerSpaceship.
--- Example: player:getCanLaunchProbe()
function Entity:getCanLaunchProbe()
    --TODO
end
--- Defines whether self-destruct controls appear on related crew screens in this PlayerSpaceship.
--- Example: player:setCanSelfDestruct(true)
function Entity:setCanSelfDestruct(enabled)
    --TODO
end
--- Returns whether self-destruct controls appear on related crew screens in this PlayerSpaceship.
--- This returns false if this ship's self-destruct size and damage are both 0, even if you set setCanSelfDestruct(true).
--- Example: player:getCanSelfDestruct()
function Entity:getCanSelfDestruct()
    --TODO
end
--- Sets the amount of damage done to nearby SpaceObjects when this PlayerSpaceship self-destructs.
--- Any given value is randomized +/- 33 percent upon self-destruction.
--- Example: player:setSelfDestructDamage(150)
function Entity:setSelfDestructDamage(amount)
    --TODO
end
--- Returns the amount of base damage done to nearby SpaceObjects when this PlayerSpaceship self-destructs.
--- Example: player:getSelfDestructDamage()
function Entity:getSelfDestructDamage()
    --TODO
end
--- Sets the radius of the explosion created when this PlayerSpaceship self-destructs.
--- All SpaceObjects within this radius are dealt damage upon self-destruction.
--- Example: player:setSelfDestructSize(1500) -- sets a 1.5U self-destruction explosion and damage radius
function Entity:setSelfDestructSize(size)
    --TODO
end
--- Returns the radius of the explosion created when this PlayerSpaceship self-destructs.
--- All SpaceObjects within this radius are dealt damage upon self-destruction.
--- Example: ship:getSelfDestructSize()
function Entity:getSelfDestructSize()
    --TODO
end
