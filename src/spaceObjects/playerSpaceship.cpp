#include "playerSpaceship.h"
#include "gui/colorConfig.h"
#include "repairCrew.h"
#include "explosionEffect.h"
#include "gameGlobalInfo.h"
#include "main.h"
#include "preferenceManager.h"
#include "soundManager.h"
#include "random.h"

#include "scriptInterface.h"

#include <SDL_assert.h>

/// A PlayerSpaceship is a SpaceShip controlled by a player crew.
/// If a function name begins with "command", the function is equivalent to the crew taking a corresponding action.
/// Such commands can be limited by the ship's capabilities, including systems damage, lack of power, or insufficient weapons stocks.
REGISTER_SCRIPT_SUBCLASS(PlayerSpaceship, SpaceShip)
{
    /// Returns the coordinates of a waypoint with the given index that's been set by this PlayerSpaceship.
    /// Waypoints are 1-indexed.
    /// Example: x,y = player:getWaypoint(1)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getWaypoint);
    /// Returns the total number of active waypoints owned by this PlayerSpaceship.
    /// Example: player:getWaypointCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getWaypointCount);
    /// Returns this PlayerSpaceship's EAlertLevel.
    /// Returns "Normal", "YELLOW ALERT", "RED ALERT", which differ from the valid values for PlayerSpaceship:commandSetAlertLevel().
    /// Example: player:getAlertLevel()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getAlertLevel);
    /// Defines whether this PlayerSpaceship's shields are raised (true) or lowered (false).
    /// Compare to CpuShips, whose shields are always active.
    /// Example: player:setShieldsActive(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setShieldsActive);
    /// Adds a message to this PlayerSpaceship's log.
    /// Takes a string as the message and a color applied to the logged message.
    /// Example: player:addToShipLog("Acknowledged","yellow") -- adds "Acknowledged" in yellow to the `player` ship's log
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, addToShipLog);
    /// Moves all players connected to this ship to the same crew positions on another PlayerSpaceship.
    /// If the target isn't a PlayerSpaceship, this function has no effect.
    /// Use this in scenarios to change the crew's ship.
    /// Example: player:transferPlayersToShip(player2) -- transfer all player crew to `player2`
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, transferPlayersToShip);
    /// Transfers only the crew members on a specific crew position to another PlayerSpaceship.
    /// If a player is in multiple positions, this matches any of their positions and moves that player to all of the same positions on the destination ship.
    /// Example: player:transferPlayersAtPositionToShip("helms",player2) -- transfer all crew on Helms to `player2`
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, transferPlayersAtPositionToShip);
    /// Returns whether a player occupies the given crew position on this PlayerSpaceship.
    /// Example: player:hasPlayerAtPosition("helms")
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, hasPlayerAtPosition);

    /// Returns whether this PlayerSpaceship's comms are not in use.
    /// Use this to determine whether the player can accept an incoming hail or chat.
    /// Example: player:isCommsInactive()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsInactive);
    /// Returns whether this PlayerSpaceship is opening comms with another SpaceObject.
    /// Example: player:isCommsOpening()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsOpening);
    /// Returns whether this PlayerSpaceship is being hailed by another SpaceObject.
    /// Example: player:isCommsBeingHailed()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsBeingHailed);
    /// Returns whether this PlayerSpaceship is being hailed by the GM.
    /// Example: player:isCommsBeingHailedByGM()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsBeingHailedByGM);
    /// Returns whether comms to this PlayerSpaceship have failed to open.
    /// Example: player:isCommsFailed()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsFailed);
    /// Returns whether comms to this PlayerSpaceship were broken off by the other SpaceObject.
    /// Example: player:isCommsBroken()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsBroken);
    /// Returns whether comms between this PlayerSpaceship and a SpaceObject were intentionally closed.
    /// Example: player:isCommsClosed()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsClosed);
    /// Returns whether this PlayerSpaceship is engaged in text chat with either the GM or another PlayerSpaceship.
    /// Example: player:isCommsChatOpen()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsChatOpen);
    /// Returns whether this PlayerSpaceship is engaged in text chat with the GM.
    /// Example: player:isCommsChatOpenToGM()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsChatOpenToGM);
    /// Returns whether this PlayerSpaceship is engaged in text chat with another PlayerSpaceship.
    /// Example: player:isCommsChatOpenToPlayer()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsChatOpenToPlayer);
    /// Returns whether this PlayerSpaceship is engaged in comms with a scripted SpaceObject.
    /// Example: player:isCommsScriptOpen()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isCommsScriptOpen);

    /// Sets this PlayerSpaceship's energy level.
    /// Values are limited from 0 to the energy level max. Negative or excess values are capped to the limits.
    /// Example: player:setEnergyLevel(1000) -- sets the ship's energy to either 1000 or the max limit, whichever is lower
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setEnergyLevel);
    /// Sets this PlayerSpaceship's energy capacity.
    /// Valid values are 0 or any positive number.
    /// If the new limit is lower than the ship's current energy level, this also reduces the energy level.
    /// Example: player:setEnergyLevelMax(1000) -- sets the ship's energy limit to 1000
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setEnergyLevelMax);
    /// Returns this PlayerSpaceship's energy level.
    /// Example: player:getEnergyLevel()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getEnergyLevel);
    /// Returns this PlayerSpaceship's energy capacity.
    /// Example: player:getEnergyLevelMax()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getEnergyLevelMax);

    /// Returns how much energy is consumed per second by this PlayerSpaceship's shields while active.
    /// Example: player:getEnergyShieldUsePerSecond()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getEnergyShieldUsePerSecond);
    /// Sets how much energy is consumed per second by this PlayerSpaceship's shields while active.
    /// Example: player:setEnergyShieldUsePerSecond(1.5)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setEnergyShieldUsePerSecond);
    /// Returns how much energy is consumed per second by this PlayerSpaceship's warp drive while in use.
    /// Example: player:getEnergyWarpPerSecond()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getEnergyWarpPerSecond);
    /// Sets how much energy is consumed per second by this PlayerSpaceship's warp drive while in use.
    /// Example: player:setEnergyWarpPerSecond(1.7)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setEnergyWarpPerSecond);

    /// Sets the maximum amount of coolant available to engineering on this PlayerSpaceship.
    /// Defaults to 10, which by default allows engineering to set 100% coolant on one system.
    /// Valid values are 0 or any positive number.
    /// If the new limit is less than the coolant already distributed, this automatically reduces distribution percentages.
    /// Example: player:setMaxCoolant(5) -- halves the amount of available coolant
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setMaxCoolant);
    /// Returns the maximum amount of coolant available to engineering on this PlayerSpaceship.
    /// Example: player:getMaxCoolant()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getMaxCoolant);

    /// Sets the number of scan probes stocked by this PlayerSpaceship.
    /// Values are limited from 0 to the scan probe count max. Negative or excess values are capped to the limits.
    /// Example: player:setScanProbeCount(20) -- sets the ship's scan probes to either 20 or the max limit, whichever is fewer
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setScanProbeCount);
    /// Returns the number of scan probes stocked by this PlayerSpaceship.
    /// Example: player:getScanProbeCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getScanProbeCount);
    /// Sets this PlayerSpaceship's capacity for scan probes.
    /// Valid values are 0 or any positive number.
    /// If the new limit is less than the current scan probe stock, this automatically reduces the stock.
    /// Example: player:setMaxScanProbeCount(30) -- sets the ship's scan probe capacity to 30
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setMaxScanProbeCount);
    /// Returns this PlayerSpaceship's capacity for scan probes.
    /// Example: player:getMaxScanProbeCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getMaxScanProbeCount);

    /// Adds a custom interactive button with the given reference name to the given crew position screen.
    /// By default, custom buttons and info are stacked in order of creation. Use the order value to specify a priority, with lower values appearing higher in the list.
    /// If the reference name is unique, this creates a new button. If the reference name exists, this modifies the existing button.
    /// The caption sets the button's text label.
    /// When clicked, the button calls the given function.
    /// Example:
    /// -- Add a custom button to Engineering, lower in the order relative to other items, that prints the player ship's coolant max to the console or logging file when clicked
    /// player:addCustomButton("engineering","get_coolant_max","Get Coolant Max",function() print("Coolant: " .. player:getMaxCoolant()) end,10)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, addCustomButton);
    /// Adds a custom non-interactive info label with the given reference name to the given crew position screen.
    /// By default, custom buttons and info are stacked in order of creation. Use the order value to specify a priority.
    /// If the reference name is unique, this creates a new info. If the reference name exists, this modifies the existing info.
    /// The caption sets the info's text value.
    /// Example:
    /// -- Displays the coolant max value on Engineering at or near the top of the custom button/info order
    /// player:addCustomInfo("engineering","show_coolant_max","Coolant Max: " .. player:getMaxCoolant(),0)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, addCustomInfo);
    /// Displays a dismissable message with the given reference name on the given crew position screen.
    /// The caption sets the message's text.
    /// Example:
    /// -- Displays the coolant max value on Engineering as a dismissable message
    /// player:addCustomMessage("engineering","message_coolant_max","Coolant max: " .. player:getMaxCoolant())
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, addCustomMessage);
    /// As PlayerSpaceship:addCustomMessage(), but calls the given function when dismissed.
    /// Example:
    /// -- Displays the coolant max value on Engineering as a dismissable message, and prints "dismissed" to the console or logging file when dismissed
    /// player:addCustomMessageWithCallback("engineering","message_coolant_max","Coolant max: " .. player:getMaxCoolant(),function() print("Dismissed!") end)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, addCustomMessageWithCallback);
    /// Removes the custom function, info, or message with the given reference name.
    /// Example: player:removeCustom("show_coolant_max") -- removes the custom item named "show_coolant_max"
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, removeCustom);

    /// Returns the index of the ESystem targeted by this PlayerSpaceship's weapons.
    /// Returns -1 for the hull.
    /// Example: player:getBeamSystemTarget()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getBeamSystemTarget);
    /// Returns the name of the ESystem targeted by this PlayerSpaceship's weapons.
    /// Returns "UNKNOWN" for the hull.
    /// Example: player:getBeamSystemTargetName()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getBeamSystemTargetName);

    /// Commands this PlayerSpaceship to set a new target rotation.
    /// A value of 0 is equivalent to a heading of 90 degrees ("east").
    /// Accepts 0, positive, or negative values.
    /// To objectively rotate the PlayerSpaceship as a SpaceObject, rather than commanding it to turn using its maneuverability, use SpaceObject:setRotation().
    /// Examples:
    /// player:commandTargetRotation(0) -- command the ship toward a heading of 90 degrees
    /// heading = 180; player:commandTargetRotation(heading - 90) -- command the ship toward a heading of 180 degrees
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandTargetRotation);
    /// Commands this PlayerSpaceship to request a new impulse speed.
    /// Valid values are -1.0 (-100%; full reverse) to 1.0 (100%; full forward).
    /// The ship's impulse value remains bound by its impulse acceleration rates.
    /// Example: player:commandImpulse(0.5) -- command this ship to engage forward half impulse
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandImpulse);
    /// Commands this PlayerSpaceship to request a new warp level.
    /// Valid values are any positive integer, or 0.
    /// Warp controls on crew position screens are limited to 4.
    /// Example: player:commandWarp(2) -- activate the warp drive at level 2
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandWarp);
    /// Commands this PlayerSpaceship to request a jump of the given distance.
    /// Valid values are any positive number, or 0, including values outside of the ship's minimum and maximum jump ranges.
    /// A jump of a greater distance than the ship's maximum jump range results in a negative jump drive charge.
    /// Example: player:commandJump(25000) -- initiate a 25U jump on the current heading
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandJump);
    /// Commands this PlayerSpaceship to set its weapons target to the given SpaceObject.
    /// Example: player:commandSetTarget(enemy)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetTarget);
    /// Commands this PlayerSpaceship to load the WeaponTube with the given index with the given weapon type.
    /// This command respects tube allow/disallow limits.
    /// Example: player:commandLoadTube(0,"HVLI")
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandLoadTube);
    /// Commands this PlayerSpaceship to unload the WeaponTube with the given index.
    /// Example: player:commandUnloadTube(0)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandUnloadTube);
    /// Commands this PlayerSpaceship to fire the WeaponTube with the given index at the given missile target angle in degrees, without a weapons target.
    /// The target angle behaves as if the Weapons crew had unlocked targeting and manually aimed its trajectory.
    /// A target angle value of 0 is equivalent to a heading of 90 degrees ("east").
    /// Accepts 0, positive, or negative values.
    /// Examples:
    /// player:commandFireTube(0,0) -- command firing tube 0 at a heading 90
    /// target_heading = 180; player:commandFireTube(0,target_heading - 90) -- command firing tube 0 at a heading 180
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandFireTube);
    /// Commands this PlayerSpaceship to fire the given weapons tube with the given SpaceObject as its target.
    /// Example: player:commandFireTubeAtTarget(0,enemy) -- command firing tube 0 at target `enemy`
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandFireTubeAtTarget);
    /// Commands this PlayerSpaceship to raise (true) or lower (false) its shields.
    /// Example: player:commandSetShields(true) -- command raising shields
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetShields);
    /// Commands this PlayerSpaceship to change its Main Screen view to the given setting.
    /// Example: player:commandMainScreenSetting("tactical") -- command setting the main screen view to tactical radar
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMainScreenSetting);
    /// Commands this PlayerSpaceship to change its Main Screen comms overlay to the given setting.
    /// Example: player:commandMainScreenOverlay("hidecomms") -- command setting the main screen view to hide the comms overlay
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMainScreenOverlay);
    /// Commands this PlayerSpaceship to initiate a scan of the given SpaceObject.
    /// If the scanning mini-game is enabled, this opens it on the relevant crew screens.
    /// This command does NOT respect the player's ability to select the object for scanning, whether due to it being out of radar range or otherwise untargetable.
    /// Example: player:commandScan(enemy)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandScan);
    /// Commands this PlayerSpaceship to set the power level of the given system.
    /// Valid values are 0 or greater, with 1.0 equivalent to 100 percent. Values greater than 1.0 are allowed.
    /// Example: player:commandSetSystemPowerRequest("impulse",1.0) -- command setting the impulse drive power to 100%
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetSystemPowerRequest);
    /// Commands this PlayerSpaceship to set the coolant level of the given system.
    /// Valid values are from 0 to 10.0, with 10.0 equivalent to 100 percent.
    /// Values greater than 10.0 are allowed if the ship's coolant max is greater than 10.0, but controls on crew position screens are limited to 10.0 (100%).
    /// Example: player:commandSetSystemCoolantRequest("impulse",10.0) -- command setting the impulse drive coolant to 100%
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetSystemCoolantRequest);
    /// Commands this PlayerSpaceship to initiate docking with the given SpaceObject.
    /// This initiates docking only if the target is dockable and within docking range.
    /// Example: player:commandDock(base)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandDock);
    /// Commands this PlayerSpaceship to undock from any SpaceObject it's docked with.
    /// Example: player:commandUndock()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandUndock);
    /// Commands this PlayerSpaceship to abort an in-progress docking operation.
    /// Example: player:commandAbortDock()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAbortDock);
    /// Commands this PlayerSpaceship to hail the given SpaceObject.
    /// If the target object is a PlayerSpaceship or the GM is intercepting all comms, open text chat comms.
    /// Example: player:commandOpenTextComm(base)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandOpenTextComm);
    /// Commands this PlayerSpaceship to close comms.
    /// Example: player:commandCloseTextComm()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCloseTextComm);
    /// Commands whether this PlayerSpaceship answers (true) or rejects (false) an incoming hail.
    /// Example: player:commandAnswerCommHail(false) -- commands to reject an active incoming hail
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAnswerCommHail);
    /// Commands this PlayerSpaceship to select the reply with the given index during a comms dialogue.
    /// Example: player:commandSendComm(0) -- commands to select the first option in a comms dialogue
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSendComm);
    /// Commands this PlayerSpaceship to send the given message to the active text comms chat.
    /// This works whether the chat is with another PlayerSpaceship or the GM.
    /// Example: player:commandSendCommPlayer("I will destroy you!") -- commands to send this message in the active text chat
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSendCommPlayer);
    /// Commands whether repair crews on this PlayerSpaceship automatically move to rooms of damaged systems.
    /// Use this command to reduce the need for player interaction in Engineering, especially when combined with setAutoCoolant/auto_coolant_enabled.
    /// Crews set to move automatically don't respect crew collisions, allowing multiple crew to occupy a single space.
    /// Example: player:commandSetAutoRepair(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetAutoRepair);
    /// Commands this PlayerSpaceship to set its beam frequency to the given value.
    /// Valid values are 0 to 20, which map to 400THz to 800THz at 20THz increments. (spaceship.cpp frequencyToString())
    /// Example: player:commandSetAutoRepair(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetBeamFrequency);
    /// Commands this PlayerSpaceship to target the given ship system with its beam weapons.
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetBeamSystemTarget);
    /// Sets this SpaceShip's shield frequency index.
    /// To convert the index to the value used by players, multiply it by 20, then add 400.
    /// Valid values are 0 (400THz) to 20 (800THz).
    /// Unlike SpaceShip:setShieldsFrequency(), this initiates shield calibration to change the frequency, which disables shields for a period.
    /// Example:
    /// frequency = ship:setShieldsFrequency(10) -- frequency is 600THz
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetShieldFrequency);
    /// Commands this PlayerSpaceship to add a waypoint at the given coordinates.
    /// This respects the 9-waypoint limit and won't add more waypoints if 9 already exist.
    /// Example: player:commandAddWaypoint(1000,2000)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAddWaypoint);
    /// Commands this PlayerSpaceship to remove the waypoint with the given index.
    /// This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
    /// Example: player:commandRemoveWaypoint(0) -- removes waypoint 1
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandRemoveWaypoint);
    /// Commands this PlayerSpaceship to move the waypoint with the given index to the given coordinates.
    /// This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
    /// Example: player:commandMoveWaypoint(0,-1000,-2000) -- moves waypoint 1 to -1000,-2000
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMoveWaypoint);
    /// Commands this PlayerSpaceship to activate its self-destruct sequence.
    /// Example: player:commandActivateSelfDestruct()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandActivateSelfDestruct);
    /// Commands this PlayerSpaceship to cancel its self-destruct sequence.
    /// Example: player:commandCancelSelfDestruct()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCancelSelfDestruct);
    /// Commands this PlayerSpaceship to submit the given self-destruct authorization code for the code request with the given index.
    /// Codes are 0-indexed. Index 0 corresponds to code A, 1 to B, etc.
    /// Example: player:commandConfirmDestructCode(0,46223) -- commands submitting 46223 as self-destruct confirmation code A
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandConfirmDestructCode);
    /// Commands this PlayerSpaceship to set its forward combat maneuver to the given value.
    /// Valid values are any from -1.0 (full reverse) to 1.0 (full forward).
    /// The maneuver continues until the ship's combat maneuver reserves are depleted.
    /// Crew screens allow only forward combat maneuvers, and the combat maneuver controls do not reflect a boost set via this command.
    /// Example: player:commandCombatManeuverBoost(0.5) -- commands boosting forward at half combat maneuver capacity
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCombatManeuverBoost);
    /// Commands this PlayerSpaceship to launch a ScanProbe to the given coordinates.
    /// Example: player:commandLaunchProbe(1000,2000) -- commands launching a scan probe to 1000,2000
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandLaunchProbe);
    /// Commands this PlayerSpaceship to link the science screen to the given ScanProbe.
    /// This is equivalent to selecting a probe on Relay and clicking "Link to Science".
    /// Unlike "Link to Science", this function can link science to any given probe, regardless of which ship launched it or what faction it belongs to.
    /// Example: player:commandSetScienceLink(probe_object) -- link ScanProbe `probe` to this ship's science
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetScienceLink);
    /// Commands this PlayerSpaceship to unlink the science screen from any ScanProbe.
    /// This is equivalent to clicking "Link to Science" on Relay when a link is already active.
    /// Example: player:commandClearScienceLink()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandClearScienceLink);
    /// Commands this PlayerSpaceship to set the given alert level.
    /// Valid values are "normal", "yellow", "red", which differ from the values returned by PlayerSpaceship:getAlertLevel().
    /// Example: player:commandSetAlertLevel("red") -- commands red alert
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetAlertLevel);

    /// Returns the number of repair crews on this PlayerSpaceship.
    /// Example: player:getRepairCrewCount()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getRepairCrewCount);
    /// Sets the total number of repair crews on this PlayerSpaceship.
    /// If the value is less than the number of repair crews, this function removes repair crews.
    /// If the value is greater, this function adds new repair crews into random rooms.
    /// Example: player:setRepairCrewCount(5)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setRepairCrewCount);
    /// Defines whether automatic coolant distribution is enabled on this PlayerSpaceship.
    /// If true, coolant is automatically distributed proportionally to the amount of heat in that system.
    /// Use this command to reduce the need for player interaction in Engineering, especially when combined with commandSetAutoRepair/auto_repair_enabled.
    /// Example: player:setAutoCoolant(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setAutoCoolant);
    /// Sets a control code password required for a player to join this PlayerSpaceship.
    /// Control codes are case-insensitive.
    /// Example: player:setControlCode("abcde") -- matches "abcde", "ABCDE", "aBcDe"
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setControlCode);
    /// Defines a function to call when this PlayerSpaceship launches a probe.
    /// Passes the launching PlayerSpaceship and launched ScanProbe.
    /// Example:
    /// -- Prints probe launch details to the console output or logging file
    /// player:onProbeLaunch(function (player, probe)
    ///     print("Probe " .. probe:getCallSign() .. " launched from ship " .. player:getCallSign())
    /// end)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, onProbeLaunch);
    /// Defines a function to call when this PlayerSpaceship links a probe to the science screen.
    /// Passes the PlayerShip and linked ScanProbe.
    /// Example:
    /// -- Prints probe linking details to the console output or logging file
    /// player:onProbeLink(function (player, probe)
    ///     print("Probe " .. probe:getCallSign() .. " linked to Science on ship " .. player:getCallSign())
    /// end)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, onProbeLink);
    /// Defines a function to call when this PlayerSpaceship unlinks a probe from the science screen.
    /// Passes the PlayerShip and previously linked ScanProbe.
    /// This function is not called when the probe is destroyed or expires.
    /// See ScanProbe:onDestruction() and ScanProbe:onExpiration().
    /// Example:
    /// -- Prints probe unlinking details to the console output or logging file
    /// player:onProbeUnlink(function (player, probe)
    ///     print("Probe " .. probe:getCallSign() .. " unlinked from Science on ship " .. player:getCallSign())
    /// end)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, onProbeUnlink);
    /// Returns this PlayerSpaceship's long-range radar range.
    /// Example: player:getLongRangeRadarRange()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getLongRangeRadarRange);
    /// Returns this PlayerSpaceship's short-range radar range.
    /// Example: player:getShortRangeRadarRange()
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, getShortRangeRadarRange);
    /// Sets this PlayerSpaceship's long-range radar range.
    /// PlayerSpaceships use this range on the science and operations screens' radar.
    /// Example: player:setLongRangeRadarRange(30000) -- sets the ship's long-range radar range to 30U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setLongRangeRadarRange);
    /// Sets this PlayerSpaceship's short-range radar range.
    /// PlayerSpaceships use this range on the helms, weapons, and single pilot screens' radar.
    /// This also defines the shared radar radius on the relay screen for friendly ships and stations, and how far into nebulae that this SpaceShip can detect objects.
    /// Example: player:setShortRangeRadarRange(5000) -- sets the ship's long-range radar range to 5U
    REGISTER_SCRIPT_CLASS_FUNCTION(ShipTemplateBasedObject, setShortRangeRadarRange);
    /// Defines whether scanning features appear on related crew screens in this PlayerSpaceship.
    /// Example: player:setCanScan(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setCanScan);
    /// Returns whether scanning features appear on related crew screens in this PlayerSpaceship.
    /// Example: player:getCanScan()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getCanScan);
    /// Defines whether hacking features appear on related crew screens in thisPlayerSpaceship.
    /// Example: player:setCanHack(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setCanHack);
    /// Returns whether hacking features appear on related crew screens in this PlayerSpaceship.
    /// Example: player:getCanHack()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getCanHack);
    /// Defines whether the "Request Docking" button appears on related crew screens in this PlayerSpaceship.
    /// This doesn't override any docking class restrictions set on a target SpaceShip.
    /// Example: player:setCanDock(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setCanDock);
    /// Returns whether the "Request Docking" button appears on related crew screens in this PlayerSpaceship.
    /// Example: player:getCanDock()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getCanDock);
    /// Defines whether combat maneuver controls appear on related crew screens in this PlayerSpaceship.
    /// Example: player:setCanCombatManeuver(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setCanCombatManeuver);
    /// Returns whether combat maneuver controls appear on related crew screens in this PlayerSpaceship.
    /// Example: player:getCanCombatManeuver()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getCanCombatManeuver);
    /// Defines whether ScanProbe-launching controls appear on related crew screens in this PlayerSpaceship.
    /// Example: player:setCanLaunchProbe(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setCanLaunchProbe);
    /// Returns whether ScanProbe-launching controls appear on related crew screens in this PlayerSpaceship.
    /// Example: player:getCanLaunchProbe()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getCanLaunchProbe);
    /// Defines whether self-destruct controls appear on related crew screens in this PlayerSpaceship.
    /// Example: player:setCanSelfDestruct(true)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setCanSelfDestruct);
    /// Returns whether self-destruct controls appear on related crew screens in this PlayerSpaceship.
    /// This returns false if this ship's self-destruct size and damage are both 0, even if you set setCanSelfDestruct(true).
    /// Example: player:getCanSelfDestruct()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getCanSelfDestruct);
    /// Sets the amount of damage done to nearby SpaceObjects when this PlayerSpaceship self-destructs.
    /// Any given value is randomized +/- 33 percent upon self-destruction.
    /// Example: player:setSelfDestructDamage(150)
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setSelfDestructDamage);
    /// Returns the amount of base damage done to nearby SpaceObjects when this PlayerSpaceship self-destructs.
    /// Example: player:getSelfDestructDamage()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getSelfDestructDamage);
    /// Sets the radius of the explosion created when this PlayerSpaceship self-destructs.
    /// All SpaceObjects within this radius are dealt damage upon self-destruction.
    /// Example: player:setSelfDestructSize(1500) -- sets a 1.5U self-destruction explosion and damage radius
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setSelfDestructSize);
    /// Returns the radius of the explosion created when this PlayerSpaceship self-destructs.
    /// All SpaceObjects within this radius are dealt damage upon self-destruction.
    /// Example: ship:getSelfDestructSize()
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getSelfDestructSize);
    /// Sets the landing pad indicated by the parameter to state 'Launched', indicating that a ship is docked there.
    /// Example: ship:setLandingPadDocked(1) -- sets the status of landing pad 1 to 'Docked''
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setLandingPadDocked);
    /// Sets the landing pad indicated by the parameter to 'Destroyed', indicating that the ship associated with the landing pad has been destroyed/incapacitated.
    /// Example: ship:setLandingPadDestroyed(1) -- sets the status of landing pad 1 to 'Destroyed'
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setLandingPadDestroyed);
    /// Sets the landing pad indicated by the parameter to 'Launched', indicating that there is no ship docked there.
    /// Example: ship:setLandingPadLaunched(1) -- sets the status of landing pad 1 to 'Launched''
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setLandingPadLaunched);
    /// Checks whether the state of landing pad indicated by the parameter is 'Docked' or not.
    /// Example: ship:isLandingPadDocked(3) -- returns 'true' if a ship is docked on landing pad 3; returns 'false' if the ship is destroyed or launched
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isLandingPadDocked);
    /// Checks whether the state of landing pad indicated by the parameter is 'Destroyed' or not.
    /// Example: ship:isLandingPadDestroyed(3) -- returns 'true' if the ship associated with landing pad 3 is destroyed/incapacitated; returns 'false' if the ship is docked or launched
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isLandingPadDestroyed);
    /// Checks whether the state of landing pad indicated by the parameter is 'Launched' or not.
    /// Example: ship:isLandingPadLaunched(3) -- returns 'true' if the ship associated with landing pad 3 is launched; returns 'false' if the ship is docked or destroyed
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, isLandingPadLaunched);
    /// Sets the landing pad indicated by the number parameter to the state indicated by the state parameter (0 = 'Destroyed', 1 = 'Docked', 2 = 'Launched').
    /// Example: ship:setLandingPadState(1, 1) -- sets the status of landing pad 1 to 'Docked'
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, setLandingPadState);
    /// Returns the state of the landing pad in question as an enumerable with values 'LP_Docked', 'LP_Destroyed' and 'LP_Launched'.
    /// Example: ship:getLandingPadState(3) -- returns 'LP_Docked' if a ship is docked on landing pad 3, 'LP_Destroyed' if the ship associated with landing pad 3 has been destroyed (and has not yet been retrieved), and 'LP_Launched' if the ship associated with landing pad 3 has been launched
    REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, getLandingPadState);
}

static const int16_t CMD_TARGET_ROTATION = 0x0001;
static const int16_t CMD_IMPULSE = 0x0002;
static const int16_t CMD_WARP = 0x0003;
static const int16_t CMD_JUMP = 0x0004;
static const int16_t CMD_SET_TARGET = 0x0005;
static const int16_t CMD_LOAD_TUBE = 0x0006;
static const int16_t CMD_UNLOAD_TUBE = 0x0007;
static const int16_t CMD_FIRE_TUBE = 0x0008;
static const int16_t CMD_SET_SHIELDS = 0x0009;
static const int16_t CMD_SET_MAIN_SCREEN_SETTING = 0x000A; // Overlay is 0x0027
static const int16_t CMD_SCAN_OBJECT = 0x000B;
static const int16_t CMD_SCAN_DONE = 0x000C;
static const int16_t CMD_SCAN_CANCEL = 0x000D;
static const int16_t CMD_SET_SYSTEM_POWER_REQUEST = 0x000E;
static const int16_t CMD_SET_SYSTEM_COOLANT_REQUEST = 0x000F;
static const int16_t CMD_DOCK = 0x0010;
static const int16_t CMD_UNDOCK = 0x0011;
static const int16_t CMD_OPEN_TEXT_COMM = 0x0012; //TEXT communication
static const int16_t CMD_CLOSE_TEXT_COMM = 0x0013;
static const int16_t CMD_SEND_TEXT_COMM = 0x0014;
static const int16_t CMD_SEND_TEXT_COMM_PLAYER = 0x0015;
static const int16_t CMD_ANSWER_COMM_HAIL = 0x0016;
static const int16_t CMD_SET_AUTO_REPAIR = 0x0017;
static const int16_t CMD_SET_BEAM_FREQUENCY = 0x0018;
static const int16_t CMD_SET_BEAM_SYSTEM_TARGET = 0x0019;
static const int16_t CMD_SET_SHIELD_FREQUENCY = 0x001A;
static const int16_t CMD_ADD_WAYPOINT = 0x001B;
static const int16_t CMD_REMOVE_WAYPOINT = 0x001C;
static const int16_t CMD_MOVE_WAYPOINT = 0x001D;
static const int16_t CMD_ACTIVATE_SELF_DESTRUCT = 0x001E;
static const int16_t CMD_CANCEL_SELF_DESTRUCT = 0x001F;
static const int16_t CMD_CONFIRM_SELF_DESTRUCT = 0x0020;
static const int16_t CMD_COMBAT_MANEUVER_BOOST = 0x0021;
static const int16_t CMD_COMBAT_MANEUVER_STRAFE = 0x0022;
static const int16_t CMD_LAUNCH_PROBE = 0x0023;
static const int16_t CMD_SET_ALERT_LEVEL = 0x0024;
static const int16_t CMD_SET_SCIENCE_LINK = 0x0025;
static const int16_t CMD_ABORT_DOCK = 0x0026;
static const int16_t CMD_SET_MAIN_SCREEN_OVERLAY = 0x0027;
static const int16_t CMD_HACKING_FINISHED = 0x0028;
static const int16_t CMD_CUSTOM_FUNCTION = 0x0029;
static const int16_t CMD_TURN_SPEED = 0x002A;

string alertLevelToString(EAlertLevel level)
{
    // Convert an EAlertLevel to a string.
    switch(level)
    {
    case AL_RedAlert: return "RED ALERT";
    case AL_YellowAlert: return "YELLOW ALERT";
    case AL_Normal: return "Normal";
    default:
        return "???";
    }
}

string alertLevelToLocaleString(EAlertLevel level)
{
    // Convert an EAlertLevel to a translated string.
    switch(level)
    {
    case AL_RedAlert: return tr("alert","RED ALERT");
    case AL_YellowAlert: return tr("alert","YELLOW ALERT");
    case AL_Normal: return tr("alert","Normal");
    default:
        return "???";
    }
}

// Configure ship's log packets.
static inline sp::io::DataBuffer& operator << (sp::io::DataBuffer& packet, const PlayerSpaceship::ShipLogEntry& e) { return packet << e.prefix << e.text << e.color.r << e.color.g << e.color.b << e.color.a; }
static inline sp::io::DataBuffer& operator >> (sp::io::DataBuffer& packet, PlayerSpaceship::ShipLogEntry& e) { packet >> e.prefix >> e.text >> e.color.r >> e.color.g >> e.color.b >> e.color.a; return packet; }

REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");
PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship", 5000)
{
    // Initialize ship settings
    main_screen_setting = MSS_Front;
    main_screen_overlay = MSO_HideComms;
    hull_damage_indicator = 0.0;
    jump_indicator = 0.0;
    comms_state = CS_Inactive;
    comms_open_delay = 0.0;
    shield_calibration_delay = 0.0;
    auto_repair_enabled = false;
    auto_coolant_enabled = false;
    max_coolant = max_coolant_per_system;
    scan_probe_stock = max_scan_probes;
    alert_level = AL_Normal;
    shields_active = false;
    control_code = "";

    setFactionId(1);

    // For now, set player ships to always be fully scanned to all other ships
    for(unsigned int faction_id = 0; faction_id < factionInfo.size(); faction_id++)
        setScannedStateForFaction(faction_id, SS_FullScan);

    updateMemberReplicationUpdateDelay(&target_rotation, 0.1);
    registerMemberReplication(&can_scan);
    registerMemberReplication(&can_hack);
    registerMemberReplication(&can_dock);
    registerMemberReplication(&can_combat_maneuver);
    registerMemberReplication(&can_self_destruct);
    registerMemberReplication(&can_launch_probe);
    registerMemberReplication(&hull_damage_indicator, 0.5);
    registerMemberReplication(&jump_indicator, 0.5);
    registerMemberReplication(&energy_level, 0.1);
    registerMemberReplication(&energy_warp_per_second, .5f);
    registerMemberReplication(&energy_shield_use_per_second, .5f);
    registerMemberReplication(&max_energy_level);
    registerMemberReplication(&main_screen_setting);
    registerMemberReplication(&main_screen_overlay);
    registerMemberReplication(&scanning_delay, 0.5);
    registerMemberReplication(&scanning_complexity);
    registerMemberReplication(&scanning_depth);
    registerMemberReplication(&shields_active);
    registerMemberReplication(&shield_calibration_delay, 0.5);
    registerMemberReplication(&auto_repair_enabled);
    registerMemberReplication(&max_coolant);
    registerMemberReplication(&auto_coolant_enabled);
    registerMemberReplication(&beam_system_target);
    registerMemberReplication(&comms_state);
    registerMemberReplication(&comms_open_delay, 1.0);
    registerMemberReplication(&comms_reply_message);
    registerMemberReplication(&comms_target_name);
    registerMemberReplication(&comms_incomming_message);
    registerMemberReplication(&ships_log);
    registerMemberReplication(&waypoints);
    registerMemberReplication(&scan_probe_stock);
    registerMemberReplication(&activate_self_destruct);
    registerMemberReplication(&self_destruct_countdown, 0.2);
    registerMemberReplication(&alert_level);
    registerMemberReplication(&linked_science_probe_id);
    registerMemberReplication(&control_code);
    registerMemberReplication(&custom_functions);

    // Determine which stations must provide self-destruct confirmation codes.
    for(int n = 0; n < max_self_destruct_codes; n++)
    {
        self_destruct_code[n] = 0;
        self_destruct_code_confirmed[n] = false;
        self_destruct_code_entry_position[n] = helmsOfficer;
        self_destruct_code_show_position[n] = helmsOfficer;
        registerMemberReplication(&self_destruct_code[n]);
        registerMemberReplication(&self_destruct_code_confirmed[n]);
        registerMemberReplication(&self_destruct_code_entry_position[n]);
        registerMemberReplication(&self_destruct_code_show_position[n]);
    }

    // Initialize each subsystem to be powered with no coolant or heat.
    for(unsigned int n = 0; n < SYS_COUNT; n++)
    {
        SDL_assert(n < default_system_power_factors.size());
        systems[n].health = 1.0f;
        systems[n].power_level = 1.0f;
        systems[n].power_rate_per_second = ShipSystem::default_power_rate_per_second;
        systems[n].power_request = 1.0f;
        systems[n].coolant_level = 0.0f;
        systems[n].coolant_rate_per_second = ShipSystem::default_coolant_rate_per_second;
        systems[n].heat_level = 0.0f;
        systems[n].heat_rate_per_second = ShipSystem::default_heat_rate_per_second;
        systems[n].power_factor = default_system_power_factors[n];

        registerMemberReplication(&systems[n].power_level);
        registerMemberReplication(&systems[n].power_rate_per_second, .5f);
        registerMemberReplication(&systems[n].power_request);
        registerMemberReplication(&systems[n].coolant_level);
        registerMemberReplication(&systems[n].coolant_rate_per_second, .5f);
        registerMemberReplication(&systems[n].coolant_request);
        registerMemberReplication(&systems[n].heat_level, 1.0);
        registerMemberReplication(&systems[n].heat_rate_per_second, .5f);
        registerMemberReplication(&systems[n].power_factor);
    }

    if (game_server)
    {
        if (gameGlobalInfo->insertPlayerShip(this) < 0)
        {
            destroy();
        }

        // Initialize the ship's log.
        addToShipLog(tr("shiplog", "Start of log"), colorConfig.log_generic);
    }

    // Initialize player ship callsigns with a "PL" designation.
    setCallSign("PL" + string(getMultiplayerId()));
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
PlayerSpaceship::~PlayerSpaceship()
{
}

void PlayerSpaceship::update(float delta)
{
    // If we're flashing the screen for hull damage, tick the fade-out.
    if (hull_damage_indicator > 0)
        hull_damage_indicator -= delta;

    // If we're jumping, tick the countdown timer.
    if (jump_indicator > 0)
        jump_indicator -= delta;

    // If shields are calibrating, tick the calibration delay. Factor shield
    // subsystem effectiveness when determining the tick rate.
    if (shield_calibration_delay > 0)
    {
        shield_calibration_delay -= delta * (getSystemEffectiveness(SYS_FrontShield) + getSystemEffectiveness(SYS_RearShield)) / 2.0f;
    }

    // Docking actions.
    if (docking_state == DS_Docked)
    {
        P<ShipTemplateBasedObject> docked_with_template_based = docking_target;
        P<SpaceShip> docked_with_ship = docking_target;

        // Derive a base energy request rate from the player ship's maximum
        // energy capacity.
        float energy_request = std::min(delta * 10.0f, max_energy_level - energy_level);

        // If we're docked with a shipTemplateBasedObject, and that object is
        // set to share its energy with docked ships, transfer energy from the
        // mothership to docked ships until the mothership runs out of energy
        // or the docked ship doesn't require any.
        if (docked_with_template_based && docked_with_template_based->shares_energy_with_docked)
        {
            if (!docked_with_ship || docked_with_ship->useEnergy(energy_request))
                energy_level += energy_request;
        }

        // If a shipTemplateBasedObject and is allowed to restock
        // scan probes with docked ships.
        if (docked_with_template_based && docked_with_template_based->restocks_scan_probes)
        {
            if (scan_probe_stock < max_scan_probes)
            {
                scan_probe_recharge += delta;

                if (scan_probe_recharge > scan_probe_charge_time)
                {
                    scan_probe_stock += 1;
                    scan_probe_recharge = 0.0;
                }
            }
        }
    }else{
        scan_probe_recharge = 0.0;
    }

    // Automate cooling if auto_coolant_enabled is true. Distributes coolant to
    // subsystems proportionally to their share of the total generated heat.
    if (auto_coolant_enabled)
    {
        float total_heat = 0.0;

        for(int n = 0; n < SYS_COUNT; n++)
        {
            if (!hasSystem(ESystem(n))) continue;
            total_heat += systems[n].heat_level;
        }
        if (total_heat > 0.0f)
        {
            for(int n = 0; n < SYS_COUNT; n++)
            {
                if (!hasSystem(ESystem(n))) continue;
                systems[n].coolant_request = max_coolant * systems[n].heat_level / total_heat;
            }
        }
    }

    // Actions performed on the server only.
    if (game_server)
    {
        // Comms actions
        if (comms_state == CS_OpeningChannel)
        {
            if (comms_open_delay > 0)
            {
                comms_open_delay -= delta;
            }else{
                if (!comms_target)
                {
                    comms_state = CS_ChannelBroken;
                }else{
                    comms_reply_id.clear();
                    comms_reply_message.clear();
                    P<PlayerSpaceship> playerShip = comms_target;
                    if (playerShip)
                    {
                        comms_open_delay = PlayerSpaceship::comms_channel_open_time;

                        if (playerShip->comms_state == CS_Inactive || playerShip->comms_state == CS_ChannelFailed || playerShip->comms_state == CS_ChannelBroken || playerShip->comms_state == CS_ChannelClosed)
                        {
                            playerShip->comms_state = CS_BeingHailed;
                            playerShip->comms_target = this;
                            playerShip->comms_target_name = getCallSign();
                        }
                    }else{
                        if (gameGlobalInfo->intercept_all_comms_to_gm)
                        {
                            comms_state = CS_ChannelOpenGM;
                        }else{
                            if (comms_script_interface.openCommChannel(this, comms_target))
                                comms_state = CS_ChannelOpen;
                            else
                                comms_state = CS_ChannelFailed;
                        }
                    }
                }
            }
        }
        if (comms_state == CS_ChannelOpen || comms_state == CS_ChannelOpenPlayer)
        {
            if (!comms_target)
                comms_state = CS_ChannelBroken;
        }

        // Consume power if shields are enabled.
        if (shields_active)
            useEnergy(delta * getEnergyShieldUsePerSecond());

        // Consume power based on subsystem requests and state.
        energy_level += delta * getNetSystemEnergyUsage();

        // Check how much coolant we have requested in total, and if that's beyond the
        //  amount of coolant we have, see how much we need to adjust our request.
        float total_coolant_request = 0.0f;
        for(int n = 0; n < SYS_COUNT; n++)
        {
            if (!hasSystem(ESystem(n))) continue;
            total_coolant_request += systems[n].coolant_request;
        }
        float coolant_request_factor = 1.0f;
        if (total_coolant_request > max_coolant)
            coolant_request_factor = max_coolant / total_coolant_request;

        for(int n = 0; n < SYS_COUNT; n++)
        {
            if (!hasSystem(ESystem(n))) continue;

            if (systems[n].power_request > systems[n].power_level)
            {
                systems[n].power_level += delta * systems[n].power_rate_per_second;
                if (systems[n].power_level > systems[n].power_request)
                    systems[n].power_level = systems[n].power_request;
            }
            else if (systems[n].power_request < systems[n].power_level)
            {
                systems[n].power_level -= delta * systems[n].power_rate_per_second;
                if (systems[n].power_level < systems[n].power_request)
                    systems[n].power_level = systems[n].power_request;
            }

            float coolant_request = systems[n].coolant_request * coolant_request_factor;
            if (coolant_request > systems[n].coolant_level)
            {
                systems[n].coolant_level += delta * systems[n].coolant_rate_per_second;
                if (systems[n].coolant_level > coolant_request)
                    systems[n].coolant_level = coolant_request;
            }
            else if (coolant_request < systems[n].coolant_level)
            {
                systems[n].coolant_level -= delta * systems[n].coolant_rate_per_second;
                if (systems[n].coolant_level < coolant_request)
                    systems[n].coolant_level = coolant_request;
            }

            // Add heat to overpowered subsystems.
            addHeat(ESystem(n), delta * systems[n].getHeatingDelta() * systems[n].heat_rate_per_second);
        }

        // If reactor health is worse than -90% and overheating, it explodes,
        // destroying the ship and damaging a 0.5U radius.
        if (can_be_destroyed && systems[SYS_Reactor].health < -0.9f && systems[SYS_Reactor].heat_level == 1.0f)
        {
            ExplosionEffect* e = new ExplosionEffect();
            e->setSize(1000.0f);
            e->setPosition(getPosition());
            e->setRadarSignatureInfo(0.0, 0.4, 0.4);

            DamageInfo info(this, DT_Kinetic, getPosition());
            SpaceObject::damageArea(getPosition(), 500, 30, 60, info, 0.0);

            destroy();
            return;
        }

        if (energy_level < 0.0f)
            energy_level = 0.0f;

        // If the ship has less than 10 energy, drop shields automatically.
        if (energy_level < 10.0f)
        {
            shields_active = false;
        }

        // If a ship is jumping or warping, consume additional energy.
        if (has_warp_drive && warp_request > 0 && !(has_jump_drive && jump_delay > 0))
        {
            // If warping, consume energy at a rate of 120% the warp request.
            // If shields are up, that rate is increased by an additional 50%.
            if (!useEnergy(getEnergyWarpPerSecond() * delta * getSystemEffectiveness(SYS_Warp) * powf(current_warp, 1.3f) * (shields_active ? 1.7f : 1.0f)))
                // If there's not enough energy, fall out of warp.
                warp_request = 0;
        }

        if (scanning_target)
        {
            // If the scan setting or a target's scan complexity is none/0,
            // complete the scan after a delay.
            if (scanning_complexity < 1)
            {
                scanning_delay -= delta;
                if (scanning_delay < 0)
                {
                    scanning_target->scannedBy(this);
                    scanning_target = NULL;
                }
            }
        }else{
            // Otherwise, ignore the scanning_delay setting.
            scanning_delay = 0.0;
        }

        if (activate_self_destruct)
        {
            // If self-destruct has been activated but not started ...
            if (self_destruct_countdown <= 0.0f)
            {
                bool do_self_destruct = true;
                // ... wait until the confirmation codes are entered.
                for(int n = 0; n < max_self_destruct_codes; n++)
                    if (!self_destruct_code_confirmed[n])
                        do_self_destruct = false;

                // Then start and announce the countdown.
                if (do_self_destruct)
                {
                    self_destruct_countdown = PreferencesManager::get("self_destruct_countdown", "10").toFloat();
                    playSoundOnMainScreen("sfx/vocal_self_destruction.wav");
                }
            }else{
                // If the countdown has started, tick the clock.
                self_destruct_countdown -= delta;

                // When time runs out, blow up the ship and damage a
                // configurable radius.
                if (self_destruct_countdown <= 0.0f)
                {
                    for(int n = 0; n < 5; n++)
                    {
                        ExplosionEffect* e = new ExplosionEffect();
                        e->setSize(self_destruct_size * 0.67f);
                        e->setPosition(getPosition() + rotateVec2(glm::vec2(0, random(0, self_destruct_size * 0.33f)), random(0, 360)));
                        e->setRadarSignatureInfo(0.0, 0.6, 0.6);
                    }

                    DamageInfo info(this, DT_Kinetic, getPosition());
                    SpaceObject::damageArea(getPosition(), self_destruct_size, self_destruct_damage - (self_destruct_damage / 3.0f), self_destruct_damage + (self_destruct_damage / 3.0f), info, 0.0);

                    destroy();
                    return;
                }
            }
        }
    }else{
        // Actions performed on the client-side only.

        // If scan settings or the scan target's complexity is 0/none, tick
        // the scan delay timer.
        if (scanning_complexity < 1)
        {
            if (scanning_delay > 0.0f)
                scanning_delay -= delta;
        }

        // If opening comms, tick the comms open delay timer.
        if (comms_open_delay > 0)
            comms_open_delay -= delta;
    }

    // Perform all other ship update actions.
    SpaceShip::update(delta);

    // Cap energy at the max_energy_level.
    if (energy_level > max_energy_level)
        energy_level = max_energy_level;
}

void PlayerSpaceship::applyTemplateValues()
{
    // Apply default spaceship object values first.
    SpaceShip::applyTemplateValues();

    // Set the ship's number of repair crews in Engineering from the ship's
    // template.
    setRepairCrewCount(ship_template->repair_crew_count);

    // Set the ship's capabilities.
    can_scan = ship_template->can_scan;
    can_hack = ship_template->can_hack;
    can_dock = ship_template->can_dock;
    can_combat_maneuver = ship_template->can_combat_maneuver;
    can_self_destruct = ship_template->can_self_destruct;
    can_launch_probe = ship_template->can_launch_probe;
    if (!on_new_player_ship_called)
    {
        on_new_player_ship_called = true;
        gameGlobalInfo->on_new_player_ship.call<void>(P<PlayerSpaceship>(this));
    }
}

void PlayerSpaceship::executeJump(float distance)
{
    // When jumping, reset the jump effect and move the ship.
    jump_indicator = 2.0;
    SpaceShip::executeJump(distance);
}

void PlayerSpaceship::takeHullDamage(float damage_amount, DamageInfo& info)
{
    // If taking non-EMP damage, light up the hull damage overlay.
    if (info.type != DT_EMP)
    {
        hull_damage_indicator = 1.5;
    }

    // Take hull damage like any other ship.
    SpaceShip::takeHullDamage(damage_amount, info);
}

void PlayerSpaceship::setMaxCoolant(float coolant)
{
    max_coolant = std::max(coolant, 0.0f);
}

void PlayerSpaceship::setSystemCoolantRequest(ESystem system, float request)
{
    request = std::max(0.0f, std::min(request, std::min((float) max_coolant_per_system, max_coolant)));
    systems[system].coolant_request = request;
}

bool PlayerSpaceship::useEnergy(float amount)
{
    // Try to consume an amount of energy. If it works, return true.
    // If it doesn't, return false.
    if (energy_level >= amount)
    {
        energy_level -= amount;
        return true;
    }
    return false;
}

void PlayerSpaceship::addHeat(ESystem system, float amount)
{
    // Add heat to a subsystem if it's present.
    if (!hasSystem(system)) return;

    systems[system].heat_level += amount;

    if (systems[system].heat_level > 1.0f)
    {
        float overheat = systems[system].heat_level - 1.0f;
        systems[system].heat_level = 1.0f;

        if (gameGlobalInfo->use_system_damage)
        {
            // Heat damage is specified as damage per second while overheating.
            // Calculate the amount of overheat back to a time, and use that to
            // calculate the actual damage taken.
            systems[system].health -= overheat / systems[system].heat_rate_per_second * damage_per_second_on_overheat;

            if (systems[system].health < -1.0f)
                systems[system].health = -1.0f;
        }
    }

    if (systems[system].heat_level < 0.0f)
        systems[system].heat_level = 0.0f;
}

void PlayerSpaceship::playSoundOnMainScreen(string sound_name)
{
    sp::io::DataBuffer packet;
    packet << CMD_PLAY_CLIENT_SOUND;
    packet << max_crew_positions;
    packet << sound_name;
    broadcastServerCommand(packet);
}

float PlayerSpaceship::getNetSystemEnergyUsage()
{
    // Get the net delta of energy draw for subsystems.
    float net_power = 0.0;

    // Determine each subsystem's energy draw.
    for(int n = 0; n < SYS_COUNT; n++)
    {
        
        if (!hasSystem(ESystem(n))) continue;

        const auto& system = systems[n];
        // Factor the subsystem's health into energy generation.
        auto power_user_factor = system.getPowerUserFactor();
        if (power_user_factor < 0)
        {
            float f = getSystemEffectiveness(ESystem(n));
            if (f > 1.0f)
                f = (1.0f + f) / 2.0f;
            net_power -= power_user_factor * f;
        }
        else
        {
            net_power -= power_user_factor * system.power_level;
        }
    }

    // Return the net subsystem energy draw.
    return net_power;
}

int PlayerSpaceship::getRepairCrewCount()
{
    // Count and return the number of repair crews on this ship.
    return getRepairCrewFor(this).size();
}

void PlayerSpaceship::setRepairCrewCount(int amount)
{
    // This is a server-only function, and we only care about repair crews when
    // we care about subsystem damage.
    if (!game_server || !gameGlobalInfo->use_system_damage)
        return;

    // Prevent negative values.
    amount = std::max(0, amount);

    // Get the number of repair crews for this ship.
    PVector<RepairCrew> crew = getRepairCrewFor(this);

    // Remove excess crews by shifting them out of the array.
    while(int(crew.size()) > amount)
    {
        crew[0]->destroy();
        crew.update();
    }

    if (ship_template->rooms.size() == 0 && amount != 0)
    {
        LOG(WARNING) << "Not adding repair crew to ship \"" << callsign << "\", because it has no rooms. Fix this by adding rooms to the ship template \"" << template_name << "\".";
        return;
    }

    // Add crews until we reach the provided amount.
    for(int create_amount = amount - crew.size(); create_amount > 0; create_amount--)
    {
        P<RepairCrew> rc = new RepairCrew();
        rc->ship_id = getMultiplayerId();
    }
}

void PlayerSpaceship::addToShipLog(string message, glm::u8vec4 color)
{
    // Cap the ship's log size to 100 entries. If it exceeds that limit,
    // start erasing entries from the beginning.
    if (ships_log.size() > 100)
        ships_log.erase(ships_log.begin());

    // Timestamp a log entry, color it, and add it to the end of the log.
    ships_log.emplace_back(gameGlobalInfo->getMissionTime() + string(": "), message, color);
}

void PlayerSpaceship::addToShipLogBy(string message, P<SpaceObject> target)
{
    // Log messages received from other ships. Friend-or-foe colors are drawn
    // from colorConfig (colors.ini).
    if (!target)
        addToShipLog(message, colorConfig.log_receive_neutral);
    else if (isFriendly(target))
        addToShipLog(message, colorConfig.log_receive_friendly);
    else if (isEnemy(target))
        addToShipLog(message, colorConfig.log_receive_enemy);
    else
        addToShipLog(message, colorConfig.log_receive_neutral);
}

const std::vector<PlayerSpaceship::ShipLogEntry>& PlayerSpaceship::getShipsLog() const
{
    // Return the ship's log.
    return ships_log;
}

void PlayerSpaceship::transferPlayersToShip(P<PlayerSpaceship> other_ship)
{
    // Don't do anything without a valid target. The target must be a
    // PlayerSpaceship.
    if (!other_ship)
        return;

    // For each player, move them to the same station on the target.
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->ship_id == getMultiplayerId())
        {
            i->ship_id = other_ship->getMultiplayerId();
        }
    }
}

void PlayerSpaceship::transferPlayersAtPositionToShip(ECrewPosition position, P<PlayerSpaceship> other_ship)
{
    // Don't do anything without a valid target. The target must be a
    // PlayerSpaceship.
    if (!other_ship)
        return;

    // For each player, check which position they fill. If the position matches
    // the requested position, move that player. Otherwise, ignore them.
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->ship_id == getMultiplayerId() && i->crew_position[position])
        {
            i->ship_id = other_ship->getMultiplayerId();
        }
    }
}

bool PlayerSpaceship::hasPlayerAtPosition(ECrewPosition position)
{
    // If a position is occupied by a player, return true.
    // Otherwise, return false.
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->ship_id == getMultiplayerId() && i->crew_position[position])
        {
            return true;
        }
    }
    return false;
}

void PlayerSpaceship::addCustomButton(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback, std::optional<int> order)
{
    removeCustom(name);
    custom_functions.emplace_back();
    CustomShipFunction& csf = custom_functions.back();
    csf.type = CustomShipFunction::Type::Button;
    csf.name = name;
    csf.crew_position = position;
    csf.caption = caption;
    csf.callback = callback;
    csf.order = order.value_or(0);
    std::stable_sort(custom_functions.begin(), custom_functions.end());
}

void PlayerSpaceship::addCustomInfo(ECrewPosition position, string name, string caption, std::optional<int> order)
{
    removeCustom(name);
    custom_functions.emplace_back();
    CustomShipFunction& csf = custom_functions.back();
    csf.type = CustomShipFunction::Type::Info;
    csf.name = name;
    csf.crew_position = position;
    csf.caption = caption;
    csf.order = order.value_or(0);
    std::stable_sort(custom_functions.begin(), custom_functions.end());
}

void PlayerSpaceship::addCustomMessage(ECrewPosition position, string name, string caption)
{
    removeCustom(name);
    custom_functions.emplace_back();
    CustomShipFunction& csf = custom_functions.back();
    csf.type = CustomShipFunction::Type::Message;
    csf.name = name;
    csf.crew_position = position;
    csf.caption = caption;
    std::stable_sort(custom_functions.begin(), custom_functions.end());
}

void PlayerSpaceship::addCustomMessageWithCallback(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback)
{
    removeCustom(name);
    custom_functions.emplace_back();
    CustomShipFunction& csf = custom_functions.back();
    csf.type = CustomShipFunction::Type::Message;
    csf.name = name;
    csf.crew_position = position;
    csf.caption = caption;
    csf.callback = callback;
    std::stable_sort(custom_functions.begin(), custom_functions.end());
}

void PlayerSpaceship::removeCustom(string name)
{
    for(auto it = custom_functions.begin(); it != custom_functions.end();)
    {
        if (it->name == name)
            it = custom_functions.erase(it);
        else
            it++;
    }
}

void PlayerSpaceship::setCommsMessage(string message)
{
    // Record a new comms message to the ship's log.
    for(string line : message.split("\n"))
        addToShipLog(line, glm::u8vec4(192, 192, 255, 255));
    // Display the message in the messaging window.
    comms_incomming_message = message;
}

void PlayerSpaceship::addCommsIncommingMessage(string message)
{
    // Record incoming comms messages to the ship's log.
    for(string line : message.split("\n"))
        addToShipLog(line, glm::u8vec4(192, 192, 255, 255));
    // Add the message to the messaging window.
    comms_incomming_message = comms_incomming_message + "\n> " + message;
}

void PlayerSpaceship::addCommsOutgoingMessage(string message)
{
    // Record outgoing comms messages to the ship's log.
    for(string line : message.split("\n"))
        addToShipLog(line, colorConfig.log_send);
    // Add the message to the messaging window.
    comms_incomming_message = comms_incomming_message + "\n< " + message;
}

void PlayerSpaceship::addCommsReply(int32_t id, string message)
{
    if (comms_reply_id.size() >= 200)
        return;
    comms_reply_id.push_back(id);
    comms_reply_message.push_back(message);
}

bool PlayerSpaceship::hailCommsByGM(string target_name)
{
    // If a ship's comms aren't engaged, receive the GM's hail.
    // Otherwise, return false.
    if (!isCommsInactive() && !isCommsFailed() && !isCommsBroken() && !isCommsClosed())
        return false;

    // Log the hail.
    addToShipLog(tr("shiplog", "Hailed by {name}").format({{"name", target_name}}), colorConfig.log_generic);

    // Set comms to the hail state and notify Relay/comms.
    comms_state = CS_BeingHailedByGM;
    comms_target_name = target_name;
    comms_target = nullptr;
    return true;
}

bool PlayerSpaceship::hailByObject(P<SpaceObject> object, string opening_message)
{
    // If trying to open comms with a non-object, return false.
    if (isCommsOpening() || isCommsBeingHailed())
    {
        if (comms_target != object)
        {
            return false;
        }
    }

    // If comms are engaged, return false.
    if (isCommsBeingHailedByGM())
    {
        return false;
    }
    if (isCommsChatOpen() || isCommsScriptOpen())
    {
        return false;
    }

    // Receive a hail from the object.
    comms_target = object;
    comms_target_name = object->getCallSign();
    comms_state = CS_BeingHailed;
    comms_incomming_message = opening_message;
    return true;
}

void PlayerSpaceship::switchCommsToGM()
{
    comms_state = CS_ChannelOpenGM;
    if (comms_incomming_message == "?")
        comms_incomming_message = "";
}

void PlayerSpaceship::closeComms()
{
    // If comms are closed, state it and log it to the ship's log.
    if (comms_state != CS_Inactive)
    {
        if (comms_state == CS_ChannelOpenPlayer && comms_target)
        {
            P<PlayerSpaceship> player_ship = comms_target;
            player_ship->comms_state = CS_ChannelClosed;
            player_ship->addToShipLog(tr("shiplog", "Communication channel closed by other side"), colorConfig.log_generic);
        }
        if (comms_state == CS_OpeningChannel && comms_target)
        {
            P<PlayerSpaceship> player_ship = comms_target;
            if (player_ship)
            {
                if (player_ship->comms_state == CS_BeingHailed && player_ship->comms_target == this)
                {
                    player_ship->comms_state = CS_Inactive;
                    player_ship->addToShipLog(tr("shiplog", "Hailing from {callsign} stopped").format({{"callsign", getCallSign()}}), colorConfig.log_generic);
                }
            }
        }
        addToShipLog(tr("shiplog", "Communication channel closed"), colorConfig.log_generic);
        if (comms_state == CS_ChannelOpenGM)
            comms_state = CS_ChannelClosed;
        else
            comms_state = CS_Inactive;
    }
}

void PlayerSpaceship::onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet)
{
    // Receive a command from a client. Code in this function is executed on
    // the server only.
    int16_t command;
    packet >> command;

    switch(command)
    {
    case CMD_TARGET_ROTATION:
        turnSpeed = 0;
        packet >> target_rotation;
        break;
    case CMD_TURN_SPEED:
        target_rotation = getRotation();
        packet >> turnSpeed;
        break;
    case CMD_IMPULSE:
        packet >> impulse_request;
        break;
    case CMD_WARP:
        packet >> warp_request;
        break;
    case CMD_JUMP:
        {
            float distance;
            packet >> distance;
            initializeJump(distance);
        }
        break;
    case CMD_SET_TARGET:
        {
            packet >> target_id;
        }
        break;
    case CMD_LOAD_TUBE:
        {
            int8_t tube_nr;
            EMissileWeapons type;
            packet >> tube_nr >> type;

            if (tube_nr >= 0 && tube_nr < max_weapon_tubes)
                weapon_tube[tube_nr].startLoad(type);
        }
        break;
    case CMD_UNLOAD_TUBE:
        {
            int8_t tube_nr;
            packet >> tube_nr;

            if (tube_nr >= 0 && tube_nr < max_weapon_tubes)
            {
                weapon_tube[tube_nr].startUnload();
            }
        }
        break;
    case CMD_FIRE_TUBE:
        {
            int8_t tube_nr;
            float missile_target_angle;
            packet >> tube_nr >> missile_target_angle;

            if (tube_nr >= 0 && tube_nr < max_weapon_tubes)
                weapon_tube[tube_nr].fire(missile_target_angle);
        }
        break;
    case CMD_SET_SHIELDS:
        {
            bool active;
            packet >> active;

            if (shield_calibration_delay <= 0.0f && active != shields_active)
            {
                shields_active = active;
                if (active)
                {
                    playSoundOnMainScreen("sfx/shield_up.wav");
                }
                else
                {
                    playSoundOnMainScreen("sfx/shield_down.wav");
                }
            }
        }
        break;
    case CMD_SET_MAIN_SCREEN_SETTING:
        packet >> main_screen_setting;
        break;
    case CMD_SET_MAIN_SCREEN_OVERLAY:
        packet >> main_screen_overlay;
        break;
    case CMD_SCAN_OBJECT:
        {
            int32_t id;
            packet >> id;

            P<SpaceObject> obj = game_server->getObjectById(id);
            if (obj)
            {
                scanning_target = obj;
                scanning_complexity = obj->scanningComplexity(this);
                scanning_depth = obj->scanningChannelDepth(this);
                scanning_delay = max_scanning_delay;
            }
        }
        break;
    case CMD_SCAN_DONE:
        if (scanning_target && scanning_complexity > 0)
        {
            if (scanning_complexity == scanning_target->scanningComplexity(this) && scanning_depth == scanning_target->scanningChannelDepth(this))
                scanning_target->scannedBy(this);
            scanning_target = nullptr;
        }
        break;
    case CMD_SCAN_CANCEL:
        if (scanning_target && scanning_complexity > 0)
        {
            scanning_target = nullptr;
        }
        break;
    case CMD_SET_SYSTEM_POWER_REQUEST:
        {
            ESystem system;
            float request;
            packet >> system >> request;
            if (system < SYS_COUNT && request >= 0.0f && request <= 3.0f)
                systems[system].power_request = request;
        }
        break;
    case CMD_SET_SYSTEM_COOLANT_REQUEST:
        {
            ESystem system;
            float request;
            packet >> system >> request;
            if (system < SYS_COUNT && request >= 0.0f && request <= 10.0f)
                setSystemCoolantRequest(system, request);
        }
        break;
    case CMD_DOCK:
        {
            int32_t id;
            packet >> id;
            requestDock(game_server->getObjectById(id));
        }
        break;
    case CMD_UNDOCK:
        requestUndock();
        break;
    case CMD_ABORT_DOCK:
        abortDock();
        break;
    case CMD_OPEN_TEXT_COMM:
        if (comms_state == CS_Inactive || comms_state == CS_BeingHailed || comms_state == CS_BeingHailedByGM || comms_state == CS_ChannelClosed)
        {
            int32_t id;
            packet >> id;
            comms_target = game_server->getObjectById(id);
            if (comms_target)
            {
                P<PlayerSpaceship> player = comms_target;
                comms_state = CS_OpeningChannel;
                comms_open_delay = comms_channel_open_time;
                comms_target_name = comms_target->getCallSign();
                comms_incomming_message = tr("chatdialog", "Opened comms with {name}").format({{"name", comms_target_name}});
                addToShipLog(tr("shiplog", "Hailing: {name}").format({{"name", comms_target_name}}), colorConfig.log_generic);
            }else{
                comms_state = CS_Inactive;
            }
        }
        break;
    case CMD_CLOSE_TEXT_COMM:
        closeComms();
        break;
    case CMD_ANSWER_COMM_HAIL:
        if (comms_state == CS_BeingHailed)
        {
            bool anwser;
            packet >> anwser;
            P<PlayerSpaceship> playerShip = comms_target;

            if (playerShip)
            {
                if (anwser)
                {
                    comms_state = CS_ChannelOpenPlayer;
                    playerShip->comms_state = CS_ChannelOpenPlayer;

                    comms_incomming_message = tr("chatdialog", "Opened comms to {callsign}").format({{"callsign", playerShip->getCallSign()}});
                    playerShip->comms_incomming_message = tr("chatdialog", "Opened comms to {callsign}").format({{"callsign", getCallSign()}});
                    addToShipLog(tr("shiplog", "Opened communication channel to {callsign}").format({{"callsign", playerShip->getCallSign()}}), colorConfig.log_generic);
                    playerShip->addToShipLog(tr("shiplog", "Opened communication channel to {callsign}").format({{"callsign", getCallSign()}}), colorConfig.log_generic);
                }else{
                    addToShipLog(tr("shiplog", "Refused communications from {callsign}").format({{"callsign", playerShip->getCallSign()}}), colorConfig.log_generic);
                    playerShip->addToShipLog(tr("shiplog", "Refused communications to {callsign}").format({{"callsign", getCallSign()}}), colorConfig.log_generic);
                    comms_state = CS_Inactive;
                    playerShip->comms_state = CS_ChannelFailed;
                }
            }else{
                if (anwser)
                {
                    if (!comms_target)
                    {
                        addToShipLog(tr("shiplog", "Hail suddenly went dead."), colorConfig.log_generic);
                        comms_state = CS_ChannelBroken;
                    }else{
                        addToShipLog(tr("shiplog", "Accepted hail from {callsign}").format({{"callsign", comms_target->getCallSign()}}), colorConfig.log_generic);
                        comms_reply_id.clear();
                        comms_reply_message.clear();
                        if (comms_incomming_message == "")
                        {
                            if (comms_script_interface.openCommChannel(this, comms_target))
                                comms_state = CS_ChannelOpen;
                            else
                                comms_state = CS_ChannelFailed;
                        }else{
                            // Set the comms message again, so it ends up in
                            // the ship's log.
                            // comms_incomming_message was set by
                            // "hailByObject", without ending up in the log.
                            setCommsMessage(comms_incomming_message);
                            comms_state = CS_ChannelOpen;
                        }
                    }
                }else{
                    if (comms_target)
                        addToShipLog(tr("shiplog", "Refused hail from {callsign}").format({{"callsign", comms_target->getCallSign()}}), colorConfig.log_generic);
                    comms_state = CS_Inactive;
                }
            }
        }
        if (comms_state == CS_BeingHailedByGM)
        {
            bool anwser;
            packet >> anwser;

            if (anwser)
            {
                comms_state = CS_ChannelOpenGM;

                addToShipLog(tr("shiplog", "Opened communication channel to {name}").format({{"name", comms_target_name}}), colorConfig.log_generic);
                comms_incomming_message = tr("chatdialog", "Opened comms with {name}").format({{"name", comms_target_name}});
            }else{
                addToShipLog(tr("shiplog", "Refused hail from {name}").format({{"name", comms_target_name}}), colorConfig.log_generic);
                comms_state = CS_Inactive;
            }
        }
        break;
    case CMD_SEND_TEXT_COMM:
        if (comms_state == CS_ChannelOpen && comms_target)
        {
            uint8_t index;
            packet >> index;
            if (index < comms_reply_id.size())
            {
                addToShipLog(comms_reply_message[index], colorConfig.log_send);

                comms_incomming_message = "?";
                int id = comms_reply_id[index];
                comms_reply_id.clear();
                comms_reply_message.clear();
                comms_script_interface.commChannelMessage(id);
            }
        }
        break;
    case CMD_SEND_TEXT_COMM_PLAYER:
        if (comms_state == CS_ChannelOpenPlayer || comms_state == CS_ChannelOpenGM)
        {
            string message;
            packet >> message;

            addCommsOutgoingMessage(message);
            P<PlayerSpaceship> playership = comms_target;
            if (comms_state == CS_ChannelOpenPlayer && playership)
                playership->addCommsIncommingMessage(message);
        }
        break;
    case CMD_SET_AUTO_REPAIR:
        packet >> auto_repair_enabled;
        break;
    case CMD_SET_BEAM_FREQUENCY:
        {
            int32_t new_frequency;
            packet >> new_frequency;
            beam_frequency = new_frequency;
            if (beam_frequency < 0)
                beam_frequency = 0;
            if (beam_frequency > SpaceShip::max_frequency)
                beam_frequency = SpaceShip::max_frequency;
        }
        break;
    case CMD_SET_BEAM_SYSTEM_TARGET:
        {
            ESystem system;
            packet >> system;
            beam_system_target = system;
            if (beam_system_target < SYS_None)
                beam_system_target = SYS_None;
            if (beam_system_target > ESystem(int(SYS_COUNT) - 1))
                beam_system_target = ESystem(int(SYS_COUNT) - 1);
        }
        break;
    case CMD_SET_SHIELD_FREQUENCY:
        if (shield_calibration_delay <= 0.0f)
        {
            int32_t new_frequency;
            packet >> new_frequency;
            if (new_frequency != shield_frequency)
            {
                shield_frequency = new_frequency;
                shield_calibration_delay = shield_calibration_time;
                shields_active = false;
                if (shield_frequency < 0)
                    shield_frequency = 0;
                if (shield_frequency > SpaceShip::max_frequency)
                    shield_frequency = SpaceShip::max_frequency;
            }
        }
        break;
    case CMD_ADD_WAYPOINT:
        {
            glm::vec2 position{};
            packet >> position;
            if (waypoints.size() < 9)
                waypoints.push_back(position);
        }
        break;
    case CMD_REMOVE_WAYPOINT:
        {
            int32_t index;
            packet >> index;
            if (index >= 0 && index < int(waypoints.size()))
                waypoints.erase(waypoints.begin() + index);
        }
        break;
    case CMD_MOVE_WAYPOINT:
        {
            int32_t index;
            glm::vec2 position{};
            packet >> index >> position;
            if (index >= 0 && index < int(waypoints.size()))
                waypoints[index] = position;
        }
        break;
    case CMD_ACTIVATE_SELF_DESTRUCT:
        activate_self_destruct = true;
        for(int n=0; n<max_self_destruct_codes; n++)
        {
            self_destruct_code[n] = irandom(0, 99999);
            self_destruct_code_confirmed[n] = false;
            self_destruct_code_entry_position[n] = max_crew_positions;
            while(self_destruct_code_entry_position[n] == max_crew_positions)
            {
                self_destruct_code_entry_position[n] = ECrewPosition(irandom(0, relayOfficer));
                for(int i=0; i<n; i++)
                    if (self_destruct_code_entry_position[n] == self_destruct_code_entry_position[i])
                        self_destruct_code_entry_position[n] = max_crew_positions;
            }
            self_destruct_code_show_position[n] = max_crew_positions;
            while(self_destruct_code_show_position[n] == max_crew_positions)
            {
                self_destruct_code_show_position[n] = ECrewPosition(irandom(0, relayOfficer));
                if (self_destruct_code_show_position[n] == self_destruct_code_entry_position[n])
                    self_destruct_code_show_position[n] = max_crew_positions;
                for(int i=0; i<n; i++)
                    if (self_destruct_code_show_position[n] == self_destruct_code_show_position[i])
                        self_destruct_code_show_position[n] = max_crew_positions;
            }
        }
        break;
    case CMD_CANCEL_SELF_DESTRUCT:
        if (self_destruct_countdown <= 0.0f)
        {
            activate_self_destruct = false;
        }
        break;
    case CMD_CONFIRM_SELF_DESTRUCT:
        {
            int8_t index;
            uint32_t code;
            packet >> index >> code;
            if (index >= 0 && index < max_self_destruct_codes && self_destruct_code[index] == code)
                self_destruct_code_confirmed[index] = true;
        }
        break;
    case CMD_COMBAT_MANEUVER_BOOST:
        {
            float request_amount;
            packet >> request_amount;
            if (request_amount >= 0.0f && request_amount <= 1.0f)
                combat_maneuver_boost_request = request_amount;
        }
        break;
    case CMD_COMBAT_MANEUVER_STRAFE:
        {
            float request_amount;
            packet >> request_amount;
            if (request_amount >= -1.0f && request_amount <= 1.0f)
                combat_maneuver_strafe_request = request_amount;
        }
        break;
    case CMD_LAUNCH_PROBE:
        if (scan_probe_stock > 0)
        {
            glm::vec2 target{};
            packet >> target;
            P<ScanProbe> p = new ScanProbe();
            p->setPosition(getPosition());
            p->setTarget(target);
            p->setOwner(this);
            if (on_probe_launch.isSet())
            {
                on_probe_launch.call<void>(P<PlayerSpaceship>(this), P<ScanProbe>(p));
            }
            scan_probe_stock--;
        }
        break;
    case CMD_SET_ALERT_LEVEL:
        {
            packet >> alert_level;
        }
        break;
    case CMD_SET_SCIENCE_LINK:
        {
            // Capture previously linked probe, if there is one.
            P<ScanProbe> old_linked_probe;

            if (linked_science_probe_id != -1)
            {
                old_linked_probe = game_server->getObjectById(linked_science_probe_id);
            }

            packet >> linked_science_probe_id;

            if (linked_science_probe_id != -1 && on_probe_link.isSet())
            {
                P<ScanProbe> new_linked_probe = game_server->getObjectById(linked_science_probe_id);

                if (new_linked_probe)
                {
                    on_probe_link.call<void>(P<PlayerSpaceship>(this), P<ScanProbe>(new_linked_probe));
                }
            }
            else if (linked_science_probe_id == -1 && on_probe_unlink.isSet())
            {
                on_probe_unlink.call<void>(P<PlayerSpaceship>(this), P<ScanProbe>(old_linked_probe));
            }
        }
        break;
    case CMD_HACKING_FINISHED:
        {
            int32_t id;
            string target_system;
            packet >> id >> target_system;
            P<SpaceObject> obj = game_server->getObjectById(id);
            if (obj)
                obj->hackFinished(this, target_system);
        }
        break;
    case CMD_CUSTOM_FUNCTION:
        {
            string name;
            packet >> name;
            for(CustomShipFunction& csf : custom_functions)
            {
                if (csf.name == name)
                {
                    if (csf.type == CustomShipFunction::Type::Button)
                    {
                        auto cb = csf.callback;
                        cb.call<void>();
                    }
                    else if (csf.type == CustomShipFunction::Type::Message)
                    {
                        auto cb = csf.callback;
                        cb.call<void>();
                        removeCustom(name);
                    }
                    break;
                }
            }
        }
        break;
    }
}

// Client-side functions to send a command to the server.
void PlayerSpaceship::commandTargetRotation(float target)
{
    sp::io::DataBuffer packet;
    packet << CMD_TARGET_ROTATION << target;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandTurnSpeed(float turnSpeed)
{
    sp::io::DataBuffer packet;
    packet << CMD_TURN_SPEED << turnSpeed;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandImpulse(float target)
{
    sp::io::DataBuffer packet;
    packet << CMD_IMPULSE << target;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandWarp(int8_t target)
{
    sp::io::DataBuffer packet;
    packet << CMD_WARP << target;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandJump(float distance)
{
    sp::io::DataBuffer packet;
    packet << CMD_JUMP << distance;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetTarget(P<SpaceObject> target)
{
    sp::io::DataBuffer packet;
    if (target)
        packet << CMD_SET_TARGET << target->getMultiplayerId();
    else
        packet << CMD_SET_TARGET << int32_t(-1);
    sendClientCommand(packet);
}

void PlayerSpaceship::commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType)
{
    sp::io::DataBuffer packet;
    packet << CMD_LOAD_TUBE << tubeNumber << missileType;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandUnloadTube(int8_t tubeNumber)
{
    sp::io::DataBuffer packet;
    packet << CMD_UNLOAD_TUBE << tubeNumber;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandFireTube(int8_t tubeNumber, float missile_target_angle)
{
    sp::io::DataBuffer packet;
    packet << CMD_FIRE_TUBE << tubeNumber << missile_target_angle;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandFireTubeAtTarget(int8_t tubeNumber, P<SpaceObject> target)
{
  float targetAngle = 0.0;

  if (!target || tubeNumber < 0 || tubeNumber >= getWeaponTubeCount())
    return;

  targetAngle = weapon_tube[tubeNumber].calculateFiringSolution(target);

  if (targetAngle == std::numeric_limits<float>::infinity())
      targetAngle = getRotation() + weapon_tube[tubeNumber].getDirection();

  commandFireTube(tubeNumber, targetAngle);
}

void PlayerSpaceship::commandSetShields(bool enabled)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_SHIELDS << enabled;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandMainScreenSetting(EMainScreenSetting mainScreen)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_MAIN_SCREEN_SETTING << mainScreen;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandMainScreenOverlay(EMainScreenOverlay mainScreen)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_MAIN_SCREEN_OVERLAY << mainScreen;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandScan(P<SpaceObject> object)
{
    sp::io::DataBuffer packet;
    packet << CMD_SCAN_OBJECT << object->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemPowerRequest(ESystem system, float power_request)
{
    sp::io::DataBuffer packet;
    systems[system].power_request = power_request;
    packet << CMD_SET_SYSTEM_POWER_REQUEST << system << power_request;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemCoolantRequest(ESystem system, float coolant_request)
{
    sp::io::DataBuffer packet;
    systems[system].coolant_request = coolant_request;
    packet << CMD_SET_SYSTEM_COOLANT_REQUEST << system << coolant_request;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandDock(P<SpaceObject> object)
{
    if (!object) return;
    sp::io::DataBuffer packet;
    packet << CMD_DOCK << object->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandUndock()
{
    sp::io::DataBuffer packet;
    packet << CMD_UNDOCK;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandAbortDock()
{
    sp::io::DataBuffer packet;
    packet << CMD_ABORT_DOCK;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandOpenTextComm(P<SpaceObject> obj)
{
    if (!obj) return;
    sp::io::DataBuffer packet;
    packet << CMD_OPEN_TEXT_COMM << obj->getMultiplayerId();
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCloseTextComm()
{
    sp::io::DataBuffer packet;
    packet << CMD_CLOSE_TEXT_COMM;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandAnswerCommHail(bool awnser)
{
    sp::io::DataBuffer packet;
    packet << CMD_ANSWER_COMM_HAIL << awnser;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSendComm(uint8_t index)
{
    sp::io::DataBuffer packet;
    packet << CMD_SEND_TEXT_COMM << index;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSendCommPlayer(string message)
{
    sp::io::DataBuffer packet;
    packet << CMD_SEND_TEXT_COMM_PLAYER << message;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetAutoRepair(bool enabled)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_AUTO_REPAIR << enabled;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetBeamFrequency(int32_t frequency)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_BEAM_FREQUENCY << frequency;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetBeamSystemTarget(ESystem system)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_BEAM_SYSTEM_TARGET << system;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetShieldFrequency(int32_t frequency)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_SHIELD_FREQUENCY << frequency;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandAddWaypoint(glm::vec2 position)
{
    sp::io::DataBuffer packet;
    packet << CMD_ADD_WAYPOINT << position;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandRemoveWaypoint(int32_t index)
{
    sp::io::DataBuffer packet;
    packet << CMD_REMOVE_WAYPOINT << index;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandMoveWaypoint(int32_t index, glm::vec2 position)
{
    sp::io::DataBuffer packet;
    packet << CMD_MOVE_WAYPOINT << index << position;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandActivateSelfDestruct()
{
    sp::io::DataBuffer packet;
    packet << CMD_ACTIVATE_SELF_DESTRUCT;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCancelSelfDestruct()
{
    sp::io::DataBuffer packet;
    packet << CMD_CANCEL_SELF_DESTRUCT;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandConfirmDestructCode(int8_t index, uint32_t code)
{
    sp::io::DataBuffer packet;
    packet << CMD_CONFIRM_SELF_DESTRUCT << index << code;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCombatManeuverBoost(float amount)
{
    combat_maneuver_boost_request = amount;
    sp::io::DataBuffer packet;
    packet << CMD_COMBAT_MANEUVER_BOOST << amount;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCombatManeuverStrafe(float amount)
{
    combat_maneuver_strafe_request = amount;
    sp::io::DataBuffer packet;
    packet << CMD_COMBAT_MANEUVER_STRAFE << amount;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandLaunchProbe(glm::vec2 target_position)
{
    sp::io::DataBuffer packet;
    packet << CMD_LAUNCH_PROBE << target_position;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandScanDone()
{
    sp::io::DataBuffer packet;
    packet << CMD_SCAN_DONE;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandScanCancel()
{
    sp::io::DataBuffer packet;
    packet << CMD_SCAN_CANCEL;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetAlertLevel(EAlertLevel level)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_ALERT_LEVEL;
    packet << level;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandHackingFinished(P<SpaceObject> target, string target_system)
{
    sp::io::DataBuffer packet;
    packet << CMD_HACKING_FINISHED;
    packet << target->getMultiplayerId();
    packet << target_system;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandCustomFunction(string name)
{
    sp::io::DataBuffer packet;
    packet << CMD_CUSTOM_FUNCTION;
    packet << name;
    sendClientCommand(packet);
}

void PlayerSpaceship::commandSetScienceLink(P<ScanProbe> probe)
{
    sp::io::DataBuffer packet;

    // Pass the probe's multiplayer ID if the probe isn't nullptr.
    if (probe)
    {
        packet << CMD_SET_SCIENCE_LINK;
        packet << probe->getMultiplayerId();
        sendClientCommand(packet);
    }
    // Otherwise, it's invalid. Warn and do nothing.
    else
    {
        LOG(WARNING) << "commandSetScienceLink received a null or invalid ScanProbe, so no command was sent.";
    }
}

void PlayerSpaceship::commandClearScienceLink()
{
    sp::io::DataBuffer packet;

    packet << CMD_SET_SCIENCE_LINK;
    packet << int32_t(-1);
    sendClientCommand(packet);
}

void PlayerSpaceship::onReceiveServerCommand(sp::io::DataBuffer& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_PLAY_CLIENT_SOUND:
        if (my_spaceship == this && my_player_info)
        {
            ECrewPosition position;
            string sound_name;
            packet >> position >> sound_name;
            if ((position == max_crew_positions && my_player_info->main_screen) || (position < sizeof(my_player_info->crew_position) && my_player_info->crew_position[position]))
            {
                soundManager->playSound(sound_name);
            }
        }
        break;
    }
}

void PlayerSpaceship::drawOnGMRadar(sp::RenderTarget& renderer, glm::vec2 position, float scale, float rotation, bool long_range)
{
    if (docked_style == DockStyle::Internal) return;

    SpaceShip::drawOnGMRadar(renderer, position, scale, rotation, long_range);

    if (long_range)
    {
        float long_radar_indicator_radius = getLongRangeRadarRange() * scale;
        float short_radar_indicator_radius = getShortRangeRadarRange() * scale;

        // Draw long-range radar radius indicator
        renderer.drawCircleOutline(position, long_radar_indicator_radius, 3.0, glm::u8vec4(255, 255, 255, 64));

        // Draw short-range radar radius indicator
        renderer.drawCircleOutline(position, short_radar_indicator_radius, 3.0, glm::u8vec4(255, 255, 255, 64));
    }
}

string PlayerSpaceship::getExportLine()
{
    string result = "PlayerSpaceship():setTemplate(\"" + template_name + "\"):setPosition(" + string(getPosition().x, 0) + ", " + string(getPosition().y, 0) + ")" + getScriptExportModificationsOnTemplate();
    if (getShortRangeRadarRange() != ship_template->short_range_radar_range)
        result += ":setShortRangeRadarRange(" + string(getShortRangeRadarRange(), 0) + ")";
    if (getLongRangeRadarRange() != ship_template->long_range_radar_range)
        result += ":setLongRangeRadarRange(" + string(getLongRangeRadarRange(), 0) + ")";
    if (can_scan != ship_template->can_scan)
        result += ":setCanScan(" + string(can_scan, true) + ")";
    if (can_hack != ship_template->can_hack)
        result += ":setCanHack(" + string(can_hack, true) + ")";
    if (can_dock != ship_template->can_dock)
        result += ":setCanDock(" + string(can_dock, true) + ")";
    if (can_combat_maneuver != ship_template->can_combat_maneuver)
        result += ":setCanCombatManeuver(" + string(can_combat_maneuver, true) + ")";
    if (can_self_destruct != ship_template->can_self_destruct)
        result += ":setCanSelfDestruct(" + string(can_self_destruct, true) + ")";
    if (can_launch_probe != ship_template->can_launch_probe)
        result += ":setCanLaunchProbe(" + string(can_launch_probe, true) + ")";
    if (auto_coolant_enabled)
        result += ":setAutoCoolant(true)";
    if (auto_repair_enabled)
        result += ":commandSetAutoRepair(true)";

    // Update power factors, only for the systems where it changed.
    for (unsigned int sys_index = 0; sys_index < SYS_COUNT; ++sys_index)
    {
        auto system = static_cast<ESystem>(sys_index);
        if (hasSystem(system))
        {
            SDL_assert(sys_index < default_system_power_factors.size());
            auto default_factor = default_system_power_factors[sys_index];
            auto current_factor = getSystemPowerFactor(system);
            auto difference = std::fabs(current_factor - default_factor) > std::numeric_limits<float>::epsilon();
            if (difference)
            {
                result += ":setSystemPowerFactor(\"" + getSystemName(system) + "\", " + string(current_factor, 1) + ")";
            }

            if (std::fabs(getSystemCoolantRate(system) - ShipSystem::default_coolant_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemCoolantRate(\"" + getSystemName(system) + "\", " + string(getSystemCoolantRate(system), 2) + ")";
            }

            if (std::fabs(getSystemHeatRate(system) - ShipSystem::default_heat_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemHeatRate(\"" + getSystemName(system) + "\", " + string(getSystemHeatRate(system), 2) + ")";
            }

            if (std::fabs(getSystemPowerRate(system) - ShipSystem::default_power_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemPowerRate(\"" + getSystemName(system) + "\", " + string(getSystemPowerRate(system), 2) + ")";
            }
        }
    }

    if (std::fabs(getEnergyShieldUsePerSecond() - default_energy_shield_use_per_second) > std::numeric_limits<float>::epsilon())
    {
        result += ":setEnergyShieldUsePerSecond(" + string(getEnergyShieldUsePerSecond(), 2) + ")";
    }

    if (std::fabs(getEnergyWarpPerSecond() - default_energy_warp_per_second) > std::numeric_limits<float>::epsilon())
    {
        result += ":setEnergyWarpPerSecond(" + string(getEnergyWarpPerSecond(), 2) + ")";
    }
    return result;
}

void PlayerSpaceship::onProbeLaunch(ScriptSimpleCallback callback)
{
    this->on_probe_launch = callback;
}

void PlayerSpaceship::onProbeLink(ScriptSimpleCallback callback)
{
    this->on_probe_link = callback;
}

void PlayerSpaceship::onProbeUnlink(ScriptSimpleCallback callback)
{
    this->on_probe_unlink = callback;
}

#include "playerSpaceship.hpp"
