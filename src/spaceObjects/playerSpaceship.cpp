#include "playerSpaceship.h"
#include "gui/colorConfig.h"
#include "repairCrew.h"
#include "explosionEffect.h"
#include "gameGlobalInfo.h"
#include "main.h"
#include "preferenceManager.h"
#include "soundManager.h"
#include "random.h"
#include "ecs/query.h"

#include "components/collision.h"
#include "components/impulse.h"
#include "components/hull.h"
#include "components/customshipfunction.h"
#include "components/shiplog.h"
#include "components/probe.h"
#include "components/reactor.h"
#include "components/coolant.h"
#include "components/beamweapon.h"
#include "components/warpdrive.h"
#include "components/jumpdrive.h"
#include "components/shields.h"
#include "components/target.h"
#include "components/missiletubes.h"
#include "components/maneuveringthrusters.h"
#include "components/selfdestruct.h"
#include "systems/jumpsystem.h"
#include "systems/docking.h"
#include "systems/missilesystem.h"
#include "systems/selfdestruct.h"
#include "systems/comms.h"

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
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandTargetRotation);
    /// Commands this PlayerSpaceship to request a new impulse speed.
    /// Valid values are -1.0 (-100%; full reverse) to 1.0 (100%; full forward).
    /// The ship's impulse value remains bound by its impulse acceleration rates.
    /// Example: player:commandImpulse(0.5) -- command this ship to engage forward half impulse
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandImpulse);
    /// Commands this PlayerSpaceship to request a new warp level.
    /// Valid values are any positive integer, or 0.
    /// Warp controls on crew position screens are limited to 4.
    /// Example: player:commandWarp(2) -- activate the warp drive at level 2
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandWarp);
    /// Commands this PlayerSpaceship to request a jump of the given distance.
    /// Valid values are any positive number, or 0, including values outside of the ship's minimum and maximum jump ranges.
    /// A jump of a greater distance than the ship's maximum jump range results in a negative jump drive charge.
    /// Example: player:commandJump(25000) -- initiate a 25U jump on the current heading
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandJump);
    /// Commands this PlayerSpaceship to set its weapons target to the given SpaceObject.
    /// Example: player:commandSetTarget(enemy)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetTarget);
    /// Commands this PlayerSpaceship to load the WeaponTube with the given index with the given weapon type.
    /// This command respects tube allow/disallow limits.
    /// Example: player:commandLoadTube(0,"HVLI")
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandLoadTube);
    /// Commands this PlayerSpaceship to unload the WeaponTube with the given index.
    /// Example: player:commandUnloadTube(0)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandUnloadTube);
    /// Commands this PlayerSpaceship to fire the WeaponTube with the given index at the given missile target angle in degrees, without a weapons target.
    /// The target angle behaves as if the Weapons crew had unlocked targeting and manually aimed its trajectory.
    /// A target angle value of 0 is equivalent to a heading of 90 degrees ("east").
    /// Accepts 0, positive, or negative values.
    /// Examples:
    /// player:commandFireTube(0,0) -- command firing tube 0 at a heading 90
    /// target_heading = 180; player:commandFireTube(0,target_heading - 90) -- command firing tube 0 at a heading 180
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandFireTube);
    /// Commands this PlayerSpaceship to fire the given weapons tube with the given SpaceObject as its target.
    /// Example: player:commandFireTubeAtTarget(0,enemy) -- command firing tube 0 at target `enemy`
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandFireTubeAtTarget);
    /// Commands this PlayerSpaceship to raise (true) or lower (false) its shields.
    /// Example: player:commandSetShields(true) -- command raising shields
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetShields);
    /// Commands this PlayerSpaceship to change its Main Screen view to the given setting.
    /// Example: player:commandMainScreenSetting("tactical") -- command setting the main screen view to tactical radar
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMainScreenSetting);
    /// Commands this PlayerSpaceship to change its Main Screen comms overlay to the given setting.
    /// Example: player:commandMainScreenOverlay("hidecomms") -- command setting the main screen view to hide the comms overlay
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMainScreenOverlay);
    /// Commands this PlayerSpaceship to initiate a scan of the given SpaceObject.
    /// If the scanning mini-game is enabled, this opens it on the relevant crew screens.
    /// This command does NOT respect the player's ability to select the object for scanning, whether due to it being out of radar range or otherwise untargetable.
    /// Example: player:commandScan(enemy)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandScan);
    /// Commands this PlayerSpaceship to set the power level of the given system.
    /// Valid values are 0 or greater, with 1.0 equivalent to 100 percent. Values greater than 1.0 are allowed.
    /// Example: player:commandSetSystemPowerRequest("impulse",1.0) -- command setting the impulse drive power to 100%
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetSystemPowerRequest);
    /// Commands this PlayerSpaceship to set the coolant level of the given system.
    /// Valid values are from 0 to 10.0, with 10.0 equivalent to 100 percent.
    /// Values greater than 10.0 are allowed if the ship's coolant max is greater than 10.0, but controls on crew position screens are limited to 10.0 (100%).
    /// Example: player:commandSetSystemCoolantRequest("impulse",10.0) -- command setting the impulse drive coolant to 100%
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetSystemCoolantRequest);
    /// Commands this PlayerSpaceship to initiate docking with the given SpaceObject.
    /// This initiates docking only if the target is dockable and within docking range.
    /// Example: player:commandDock(base)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandDock);
    /// Commands this PlayerSpaceship to undock from any SpaceObject it's docked with.
    /// Example: player:commandUndock()
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandUndock);
    /// Commands this PlayerSpaceship to abort an in-progress docking operation.
    /// Example: player:commandAbortDock()
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAbortDock);
    /// Commands this PlayerSpaceship to hail the given SpaceObject.
    /// If the target object is a PlayerSpaceship or the GM is intercepting all comms, open text chat comms.
    /// Example: player:commandOpenTextComm(base)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandOpenTextComm);
    /// Commands this PlayerSpaceship to close comms.
    /// Example: player:commandCloseTextComm()
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCloseTextComm);
    /// Commands whether this PlayerSpaceship answers (true) or rejects (false) an incoming hail.
    /// Example: player:commandAnswerCommHail(false) -- commands to reject an active incoming hail
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAnswerCommHail);
    /// Commands this PlayerSpaceship to select the reply with the given index during a comms dialogue.
    /// Example: player:commandSendComm(0) -- commands to select the first option in a comms dialogue
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSendComm);
    /// Commands this PlayerSpaceship to send the given message to the active text comms chat.
    /// This works whether the chat is with another PlayerSpaceship or the GM.
    /// Example: player:commandSendCommPlayer("I will destroy you!") -- commands to send this message in the active text chat
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSendCommPlayer);
    /// Commands whether repair crews on this PlayerSpaceship automatically move to rooms of damaged systems.
    /// Use this command to reduce the need for player interaction in Engineering, especially when combined with setAutoCoolant/auto_coolant_enabled.
    /// Crews set to move automatically don't respect crew collisions, allowing multiple crew to occupy a single space.
    /// Example: player:commandSetAutoRepair(true)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetAutoRepair);
    /// Commands this PlayerSpaceship to set its beam frequency to the given value.
    /// Valid values are 0 to 20, which map to 400THz to 800THz at 20THz increments. (spaceship.cpp frequencyToString())
    /// Example: player:commandSetAutoRepair(true)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetBeamFrequency);
    /// Commands this PlayerSpaceship to target the given ship system with its beam weapons.
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetBeamSystemTarget);
    /// Sets this SpaceShip's shield frequency index.
    /// To convert the index to the value used by players, multiply it by 20, then add 400.
    /// Valid values are 0 (400THz) to 20 (800THz).
    /// Unlike SpaceShip:setShieldsFrequency(), this initiates shield calibration to change the frequency, which disables shields for a period.
    /// Example:
    /// frequency = ship:setShieldsFrequency(10) -- frequency is 600THz
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetShieldFrequency);
    /// Commands this PlayerSpaceship to add a waypoint at the given coordinates.
    /// This respects the 9-waypoint limit and won't add more waypoints if 9 already exist.
    /// Example: player:commandAddWaypoint(1000,2000)
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandAddWaypoint);
    /// Commands this PlayerSpaceship to remove the waypoint with the given index.
    /// This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
    /// Example: player:commandRemoveWaypoint(0) -- removes waypoint 1
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandRemoveWaypoint);
    /// Commands this PlayerSpaceship to move the waypoint with the given index to the given coordinates.
    /// This uses a 0-index, while waypoints are numbered on player screens with a 1-index.
    /// Example: player:commandMoveWaypoint(0,-1000,-2000) -- moves waypoint 1 to -1000,-2000
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandMoveWaypoint);
    /// Commands this PlayerSpaceship to activate its self-destruct sequence.
    /// Example: player:commandActivateSelfDestruct()
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandActivateSelfDestruct);
    /// Commands this PlayerSpaceship to cancel its self-destruct sequence.
    /// Example: player:commandCancelSelfDestruct()
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCancelSelfDestruct);
    /// Commands this PlayerSpaceship to submit the given self-destruct authorization code for the code request with the given index.
    /// Codes are 0-indexed. Index 0 corresponds to code A, 1 to B, etc.
    /// Example: player:commandConfirmDestructCode(0,46223) -- commands submitting 46223 as self-destruct confirmation code A
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandConfirmDestructCode);
    /// Commands this PlayerSpaceship to set its forward combat maneuver to the given value.
    /// Valid values are any from -1.0 (full reverse) to 1.0 (full forward).
    /// The maneuver continues until the ship's combat maneuver reserves are depleted.
    /// Crew screens allow only forward combat maneuvers, and the combat maneuver controls do not reflect a boost set via this command.
    /// Example: player:commandCombatManeuverBoost(0.5) -- commands boosting forward at half combat maneuver capacity
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandCombatManeuverBoost);
    /// Commands this PlayerSpaceship to launch a ScanProbe to the given coordinates.
    /// Example: player:commandLaunchProbe(1000,2000) -- commands launching a scan probe to 1000,2000
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandLaunchProbe);
    /// Commands this PlayerSpaceship to link the science screen to the given ScanProbe.
    /// This is equivalent to selecting a probe on Relay and clicking "Link to Science".
    /// Unlike "Link to Science", this function can link science to any given probe, regardless of which ship launched it or what faction it belongs to.
    /// Example: player:commandSetScienceLink(probe_object) -- link ScanProbe `probe` to this ship's science
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetScienceLink);
    /// Commands this PlayerSpaceship to unlink the science screen from any ScanProbe.
    /// This is equivalent to clicking "Link to Science" on Relay when a link is already active.
    /// Example: player:commandClearScienceLink()
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandClearScienceLink);
    /// Commands this PlayerSpaceship to set the given alert level.
    /// Valid values are "normal", "yellow", "red", which differ from the values returned by PlayerSpaceship:getAlertLevel().
    /// Example: player:commandSetAlertLevel("red") -- commands red alert
    //REGISTER_SCRIPT_CLASS_FUNCTION(PlayerSpaceship, commandSetAlertLevel);

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


REGISTER_MULTIPLAYER_CLASS(PlayerSpaceship, "PlayerSpaceship");
PlayerSpaceship::PlayerSpaceship()
: SpaceShip("PlayerSpaceship", 5000)
{
    // Initialize ship settings
    auto_repair_enabled = false;
    
    // For now, set player ships to always be fully scanned to all other ships
    for(auto [entity, info] : sp::ecs::Query<FactionInfo>())
        setScannedStateForFaction(entity, ScanState::State::FullScan);

    registerMemberReplication(&can_hack);
    registerMemberReplication(&auto_repair_enabled);

    if (game_server)
    {
        if (gameGlobalInfo->insertPlayerShip(entity) < 0)
        {
            destroy();
        }

        // Initialize the ship's log.
        addToShipLog(tr("shiplog", "Start of log"), colorConfig.log_generic);
    }

    // Initialize player ship callsigns with a "PL" designation.
    setCallSign("PL" + string(getMultiplayerId()));

    if (entity) {
        setFaction("Human Navy");
    }
}

//due to a suspected compiler bug this deconstructor needs to be explicitly defined
PlayerSpaceship::~PlayerSpaceship()
{
}

void PlayerSpaceship::applyTemplateValues()
{
    // Apply default spaceship object values first.
    SpaceShip::applyTemplateValues();

    // Set the ship's number of repair crews in Engineering from the ship's
    // template.
    setRepairCrewCount(ship_template->repair_crew_count);

    if (entity) {
        entity.getOrAddComponent<Coolant>();
        if (!ship_template->can_combat_maneuver)
            entity.removeComponent<CombatManeuveringThrusters>();
        if (ship_template->can_self_destruct)
            entity.getOrAddComponent<SelfDestruct>();
        if (ship_template->can_scan)
            entity.getOrAddComponent<ScienceScanner>();
        if (ship_template->can_launch_probe)
            entity.getOrAddComponent<ScanProbeLauncher>();
    }

    // Set the ship's capabilities.
    can_hack = ship_template->can_hack;
    if (!on_new_player_ship_called)
    {
        on_new_player_ship_called = true;
        gameGlobalInfo->on_new_player_ship.call<void>(P<PlayerSpaceship>(this));
    }
}

void PlayerSpaceship::setMaxCoolant(float coolant)
{
    //TODO
}

void PlayerSpaceship::setSystemCoolantRequest(ShipSystem::Type system, float request)
{
    auto coolant = entity.getComponent<Coolant>();
    if (!coolant) return;
    request = std::clamp(request, 0.0f, std::min((float) coolant->max_coolant_per_system, coolant->max));
    auto sys = ShipSystem::get(entity, system);
    if (sys)
        sys->coolant_request = request;
}

void PlayerSpaceship::playSoundOnMainScreen(string sound_name)
{
    sp::io::DataBuffer packet;
    packet << CMD_PLAY_CLIENT_SOUND;
    packet << max_crew_positions;
    packet << sound_name;
    broadcastServerCommand(packet);
}

int PlayerSpaceship::getRepairCrewCount()
{
    // Count and return the number of repair crews on this ship.
    return getRepairCrewFor(entity).size();
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
    PVector<RepairCrew> crew = getRepairCrewFor(entity);

    // Remove excess crews by shifting them out of the array.
    while(int(crew.size()) > amount)
    {
        crew[0]->destroy();
        crew.update();
    }

    if (ship_template->rooms.size() == 0 && amount != 0)
    {
        LOG(WARNING) << "Not adding repair crew to ship \"" << getCallSign() << "\", because it has no rooms. Fix this by adding rooms to the ship template \"" << template_name << "\".";
        return;
    }

    // Add crews until we reach the provided amount.
    for(int create_amount = amount - crew.size(); create_amount > 0; create_amount--)
    {
        P<RepairCrew> rc = new RepairCrew();
        rc->ship = entity;
    }
}

void PlayerSpaceship::addToShipLog(string message, glm::u8vec4 color)
{
    auto& log = entity.getOrAddComponent<ShipLog>();
    log.add(message, color);
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

void PlayerSpaceship::transferPlayersToShip(P<PlayerSpaceship> other_ship)
{
    // Don't do anything without a valid target. The target must be a
    // PlayerSpaceship.
    if (!other_ship)
        return;

    // For each player, move them to the same station on the target.
    foreach(PlayerInfo, i, player_info_list)
    {
        if (i->ship == entity)
        {
            i->ship = other_ship->entity;
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
        if (i->ship == entity && i->crew_position[position])
        {
            i->ship = other_ship->entity;
        }
    }
}

bool PlayerSpaceship::hasPlayerAtPosition(ECrewPosition position)
{
    return PlayerInfo::hasPlayerAtPosition(entity, position);
}

void PlayerSpaceship::addCustomButton(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback, std::optional<int> order)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Button;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    f.callback = callback;
    f.order = order.value_or(0);
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::addCustomInfo(ECrewPosition position, string name, string caption, std::optional<int> order)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto& f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Info;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    f.order = order.value_or(0);
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::addCustomMessage(ECrewPosition position, string name, string caption)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto& f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Message;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::addCustomMessageWithCallback(ECrewPosition position, string name, string caption, ScriptSimpleCallback callback)
{
    removeCustom(name);
    auto& csf = entity.getOrAddComponent<CustomShipFunctions>();
    csf.functions.emplace_back();
    auto& f = csf.functions.back();
    f.type = CustomShipFunctions::Function::Type::Message;
    f.name = name;
    f.crew_position = position;
    f.caption = caption;
    f.callback = callback;
    std::stable_sort(csf.functions.begin(), csf.functions.end());
}

void PlayerSpaceship::removeCustom(string name)
{
    auto csf = entity.getComponent<CustomShipFunctions>();
    if (!csf) return;
    for(auto it = csf->functions.begin(); it != csf->functions.end();)
    {
        if (it->name == name)
            it = csf->functions.erase(it);
        else
            it++;
    }
}

void PlayerSpaceship::setCommsMessage(string message)
{
    if (auto transmitter = entity.getComponent<CommsTransmitter>()) {
        // Record a new comms message to the ship's log.
        for(string line : message.split("\n"))
            addToShipLog(line, glm::u8vec4(192, 192, 255, 255));
        // Display the message in the messaging window.
        transmitter->incomming_message = message;
    }
}

void PlayerSpaceship::setEnergyLevel(float amount) {} //TODO
void PlayerSpaceship::setEnergyLevelMax(float amount) {} //TODO
float PlayerSpaceship::getEnergyLevel() { return 0.0f; } //TODO
float PlayerSpaceship::getEnergyLevelMax() { return 0.0f; } //TODO

void PlayerSpaceship::setCanDock(bool enabled)
{
    if (!enabled) {
        //TODO: Undock first!
        entity.removeComponent<DockingPort>();
    } else {
        auto& port = entity.getOrAddComponent<DockingPort>();
        port.dock_class = ship_template->getClass();
        port.dock_subclass = ship_template->getSubClass();
    }
}

bool PlayerSpaceship::getCanDock()
{
    return entity.hasComponent<DockingPort>();
}

ShipSystem::Type PlayerSpaceship::getBeamSystemTarget() { return ShipSystem::Type::None; /* TODO */ }
string PlayerSpaceship::getBeamSystemTargetName() { return ""; /* TODO */ }

void PlayerSpaceship::onReceiveClientCommand(int32_t client_id, sp::io::DataBuffer& packet)
{
    // Receive a command from a client. Code in this function is executed on
    // the server only.
    int16_t command;
    packet >> command;

    switch(command)
    {
    case CMD_TARGET_ROTATION:{
        float f;
        packet >> f;
        auto thrusters = entity.getComponent<ManeuveringThrusters>();
        if (thrusters) { thrusters->stop(); thrusters->target = f; }
        }break;
    case CMD_TURN_SPEED:{
        float f;
        packet >> f;
        auto thrusters = entity.getComponent<ManeuveringThrusters>();
        if (thrusters) { thrusters->stop(); thrusters->rotation_request = f; }
        }break;
    case CMD_IMPULSE:{
        auto engine = entity.getComponent<ImpulseEngine>();
        if (engine)
            packet >> engine->request;
        else {
            float f;
            packet >> f;
        }
        } break;
    case CMD_WARP:{
        auto warp = entity.getComponent<WarpDrive>();
        if (warp)
            packet >> warp->request;
        else {
            uint8_t i;
            packet >> i;
        }
        } break;
    case CMD_JUMP:
        {
            float distance;
            packet >> distance;
            JumpSystem::initializeJump(my_spaceship, distance);
        }
        break;
    case CMD_SET_TARGET:
        {
            sp::ecs::Entity target;
            packet >> target;
            entity.getOrAddComponent<Target>().entity = target;
        }
        break;
    case CMD_LOAD_TUBE:
        {
            int8_t tube_nr;
            EMissileWeapons type;
            packet >> tube_nr >> type;

            auto missiletubes = entity.getComponent<MissileTubes>();
            if (missiletubes && tube_nr >= 0 && tube_nr < missiletubes->count)
                MissileSystem::startLoad(entity, missiletubes->mounts[tube_nr], type);
        }
        break;
    case CMD_UNLOAD_TUBE:
        {
            int8_t tube_nr;
            packet >> tube_nr;

            auto missiletubes = entity.getComponent<MissileTubes>();
            if (missiletubes && tube_nr >= 0 && tube_nr < missiletubes->count)
                MissileSystem::startUnload(entity, missiletubes->mounts[tube_nr]);
        }
        break;
    case CMD_FIRE_TUBE:
        {
            int8_t tube_nr;
            float missile_target_angle;
            packet >> tube_nr >> missile_target_angle;

            auto missiletubes = entity.getComponent<MissileTubes>();
            if (missiletubes && tube_nr >= 0 && tube_nr < missiletubes->count)
                MissileSystem::fire(entity, missiletubes->mounts[tube_nr], missile_target_angle, getTarget() ? getTarget()->entity : sp::ecs::Entity{});
        }
        break;
    case CMD_SET_SHIELDS:
        {
            bool active;
            packet >> active;

            auto shields = entity.getComponent<Shields>();
            if (shields) {
                if (shields->calibration_delay <= 0.0f && active != shields->active)
                {
                    shields->active = active;
                    if (active)
                        playSoundOnMainScreen("sfx/shield_up.wav");
                    else
                        playSoundOnMainScreen("sfx/shield_down.wav");
                }
            }
        }
        break;
    case CMD_SET_MAIN_SCREEN_SETTING:{
        MainScreenSetting mss;
        packet >> mss;
        if (auto pc = entity.getComponent<PlayerControl>())
            pc->main_screen_setting = mss;
        }break;
    case CMD_SET_MAIN_SCREEN_OVERLAY:{
        MainScreenOverlay mso;
        packet >> mso;
        if (auto pc = entity.getComponent<PlayerControl>())
            pc->main_screen_overlay = mso;
        }break;
        break;
    case CMD_SCAN_OBJECT:
        {
            sp::ecs::Entity e;
            packet >> e;

            if (auto scanner = entity.getComponent<ScienceScanner>())
            {
                scanner->delay = max_scanning_delay;
                scanner->target = e;
            }
        }
        break;
    case CMD_SCAN_DONE:
        if (auto ss = entity.getComponent<ScienceScanner>()) {
            if (auto scanstate = ss->target.getComponent<ScanState>()) {
                switch(scanstate->getStateFor(entity)) {
                case ScanState::State::NotScanned:
                case ScanState::State::FriendOrFoeIdentified:
                    if (scanstate->allow_simple_scan)
                        scanstate->setStateFor(entity, ScanState::State::SimpleScan);
                    else
                        scanstate->setStateFor(entity, ScanState::State::FullScan);
                    break;
                case ScanState::State::SimpleScan:
                    scanstate->setStateFor(entity, ScanState::State::FullScan);
                    break;
                case ScanState::State::FullScan:
                    break;
                }
            }
            ss->target = {};
        }
        break;
    case CMD_SCAN_CANCEL:
        if (auto ss = entity.getComponent<ScienceScanner>()) {
            ss->target = {};
        }
        break;
    case CMD_SET_SYSTEM_POWER_REQUEST:
        {
            ShipSystem::Type system;
            float request;
            packet >> system >> request;
            auto sys = ShipSystem::get(entity, system);
            if (sys && request >= 0.0f && request <= 3.0f)
                sys->power_request = request;
        }
        break;
    case CMD_SET_SYSTEM_COOLANT_REQUEST:
        {
            ShipSystem::Type system;
            float request;
            packet >> system >> request;
            setSystemCoolantRequest(system, request);
        }
        break;
    case CMD_DOCK:
        {
            int32_t id;
            packet >> id;
            P<SpaceObject> obj = game_server->getObjectById(id);
            if (obj)
                DockingSystem::requestDock(entity, obj->entity);
        }
        break;
    case CMD_UNDOCK:
        DockingSystem::requestUndock(entity);
        break;
    case CMD_ABORT_DOCK:
        DockingSystem::abortDock(entity);
        break;
    case CMD_OPEN_TEXT_COMM:
        {
            sp::ecs::Entity target;
            packet >> target;
            CommsSystem::openTo(entity, target);
        }
        break;
    case CMD_CLOSE_TEXT_COMM:
        CommsSystem::close(entity);
        break;
    case CMD_ANSWER_COMM_HAIL: 
        {
            bool answer = false;
            packet >> answer;
            CommsSystem::answer(entity, answer);
        }
        break;
    case CMD_SEND_TEXT_COMM:
        {
            uint8_t index;
            packet >> index;
            CommsSystem::selectScriptReply(entity, index);
        }
        break;
    case CMD_SEND_TEXT_COMM_PLAYER:
        {
            string message;
            packet >> message;

            CommsSystem::textReply(entity, message);
        }
        break;
    case CMD_SET_AUTO_REPAIR:
        packet >> auto_repair_enabled;
        break;
    case CMD_SET_BEAM_FREQUENCY:
        {
            int32_t new_frequency;
            packet >> new_frequency;
            auto beamweapons = entity.getComponent<BeamWeaponSys>();
            if (beamweapons)
                beamweapons->frequency = std::clamp(new_frequency, 0, SpaceShip::max_frequency);
        }
        break;
    case CMD_SET_BEAM_SYSTEM_TARGET:
        {
            ShipSystem::Type system;
            packet >> system;
            auto beamweapons = entity.getComponent<BeamWeaponSys>();
            if (beamweapons)
                beamweapons->system_target = (ShipSystem::Type)std::clamp((int)system, 0, (int)(ShipSystem::COUNT - 1));
        }
        break;
    case CMD_SET_SHIELD_FREQUENCY:
        {
            int32_t new_frequency;
            packet >> new_frequency;
            auto shields = entity.getComponent<Shields>();
            if (shields && shields->calibration_delay <= 0.0f && new_frequency != shields->frequency)
            {
                shields->frequency = new_frequency;
                shields->calibration_delay = shields->calibration_time;
                shields->active = false;
                if (shields->frequency < 0)
                    shields->frequency = 0;
                if (shields->frequency > SpaceShip::max_frequency)
                    shields->frequency = SpaceShip::max_frequency;
            }
        }
        break;
    case CMD_ADD_WAYPOINT:
        {
            glm::vec2 position{};
            packet >> position;
            auto lrr = entity.getComponent<LongRangeRadar>();
            if (lrr && lrr->waypoints.size() < 9)
                lrr->waypoints.push_back(position);
        }
        break;
    case CMD_REMOVE_WAYPOINT:
        {
            int32_t index;
            packet >> index;
            auto lrr = entity.getComponent<LongRangeRadar>();
            if (lrr && index >= 0 && index < int(lrr->waypoints.size()))
                lrr->waypoints.erase(lrr->waypoints.begin() + index);
        }
        break;
    case CMD_MOVE_WAYPOINT:
        {
            int32_t index;
            glm::vec2 position{};
            packet >> index >> position;
            auto lrr = entity.getComponent<LongRangeRadar>();
            if (lrr && index >= 0 && index < int(lrr->waypoints.size()))
                lrr->waypoints[index] = position;
        }
        break;
    case CMD_ACTIVATE_SELF_DESTRUCT:
        SelfDestructSystem::activate(entity);
        break;
    case CMD_CANCEL_SELF_DESTRUCT:
        if (auto self_destruct = entity.getComponent<SelfDestruct>()) {
            if (self_destruct->countdown <= 0.0f) {
                self_destruct->active = false;
            }
        }
        break;
    case CMD_CONFIRM_SELF_DESTRUCT:
        {
            int8_t index;
            uint32_t code;
            packet >> index >> code;
            if (auto self_destruct = entity.getComponent<SelfDestruct>()) {
                if (index >= 0 && index < SelfDestruct::max_codes && self_destruct->code[index] == code && self_destruct->active)
                    self_destruct->confirmed[index] = true;
            }
        }
        break;
    case CMD_COMBAT_MANEUVER_BOOST:
        {
            float request_amount;
            packet >> request_amount;
            auto combat = entity.getComponent<CombatManeuveringThrusters>();
            if (combat)
                combat->boost.request = request_amount;
        }
        break;
    case CMD_COMBAT_MANEUVER_STRAFE:
        {
            float request_amount;
            packet >> request_amount;
            auto combat = entity.getComponent<CombatManeuveringThrusters>();
            if (combat)
                combat->strafe.request = request_amount;
        }
        break;
    case CMD_LAUNCH_PROBE:
        if (auto spl = entity.getComponent<ScanProbeLauncher>())
        {
            if (spl->stock > 0) {
                glm::vec2 target{};
                packet >> target;
                P<ScanProbe> p = new ScanProbe();
                p->setPosition(getPosition());
                p->setTarget(target);
                p->setOwner(entity);
                if (spl->on_launch.isSet())
                {
                    spl->on_launch.call<void>(P<PlayerSpaceship>(this), P<ScanProbe>(p));
                }
                spl->stock--;
            }
        }
        break;
    case CMD_SET_ALERT_LEVEL:{
        AlertLevel al;
        packet >> al;
        if (auto ps = entity.getComponent<PlayerControl>())
            ps->alert_level = al;
        }break;
    case CMD_SET_SCIENCE_LINK:
        {
            // Capture previously linked probe, if there is one.
            sp::ecs::Entity target;
            packet >> target;

            // TODO: Check if this probe is ours
            if (auto lrr = entity.getComponent<LongRangeRadar>()) {
                auto old = lrr->linked_probe;
                if (lrr->on_probe_link.isSet() && target)
                    lrr->on_probe_link.call<void>(entity, target);
                lrr->linked_probe = target;
                if (lrr->on_probe_unlink.isSet() && old)
                    lrr->on_probe_unlink.call<void>(entity, old);
            }
        }
        break;
    case CMD_HACKING_FINISHED:
        {
            int32_t id;
            ShipSystem::Type target_system;
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
            if (auto csf = entity.getComponent<CustomShipFunctions>()) {
                for(auto& f : csf->functions)
                {
                    if (f.name == name)
                    {
                        if (f.type == CustomShipFunctions::Function::Type::Button)
                        {
                            auto cb = f.callback;
                            cb.call<void>();
                        }
                        else if (f.type == CustomShipFunctions::Function::Type::Message)
                        {
                            auto cb = f.callback;
                            cb.call<void>();
                            removeCustom(name);
                        }
                        break;
                    }
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
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandTurnSpeed(float turnSpeed)
{
    sp::io::DataBuffer packet;
    packet << CMD_TURN_SPEED << turnSpeed;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandImpulse(float target)
{
    sp::io::DataBuffer packet;
    packet << CMD_IMPULSE << target;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandWarp(int8_t target)
{
    sp::io::DataBuffer packet;
    packet << CMD_WARP << target;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandJump(float distance)
{
    sp::io::DataBuffer packet;
    packet << CMD_JUMP << distance;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetTarget(sp::ecs::Entity target)
{
    sp::io::DataBuffer packet;
    if (target)
        packet << CMD_SET_TARGET << target;
    else
        packet << CMD_SET_TARGET << sp::ecs::Entity();
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandLoadTube(int8_t tubeNumber, EMissileWeapons missileType)
{
    sp::io::DataBuffer packet;
    packet << CMD_LOAD_TUBE << tubeNumber << missileType;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandUnloadTube(int8_t tubeNumber)
{
    sp::io::DataBuffer packet;
    packet << CMD_UNLOAD_TUBE << tubeNumber;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandFireTube(int8_t tubeNumber, float missile_target_angle)
{
    sp::io::DataBuffer packet;
    packet << CMD_FIRE_TUBE << tubeNumber << missile_target_angle;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandFireTubeAtTarget(int8_t tubeNumber, sp::ecs::Entity target)
{
    float targetAngle = 0.0;
    auto missiletubes = my_spaceship.getComponent<MissileTubes>();

    if (!target || !missiletubes || tubeNumber < 0 || tubeNumber >= missiletubes->count)
        return;

    targetAngle = MissileSystem::calculateFiringSolution(my_spaceship, missiletubes->mounts[tubeNumber], target);
    if (targetAngle == std::numeric_limits<float>::infinity()) {
        if (auto transform = my_spaceship.getComponent<sp::Transform>())
            targetAngle = transform->getRotation() + missiletubes->mounts[tubeNumber].direction;
    }

    commandFireTube(tubeNumber, targetAngle);
}

void PlayerSpaceship::commandSetShields(bool enabled)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_SHIELDS << enabled;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandMainScreenSetting(MainScreenSetting mainScreen)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_MAIN_SCREEN_SETTING << mainScreen;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandMainScreenOverlay(MainScreenOverlay mainScreen)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_MAIN_SCREEN_OVERLAY << mainScreen;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandScan(sp::ecs::Entity object)
{
    sp::io::DataBuffer packet;
    packet << CMD_SCAN_OBJECT << object;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemPowerRequest(ShipSystem::Type system, float power_request)
{
    sp::io::DataBuffer packet;
    auto sys = ShipSystem::get(my_spaceship, system);
    if (sys) sys->power_request = power_request;
    packet << CMD_SET_SYSTEM_POWER_REQUEST << system << power_request;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetSystemCoolantRequest(ShipSystem::Type system, float coolant_request)
{
    sp::io::DataBuffer packet;
    auto sys = ShipSystem::get(my_spaceship, system);
    if (sys) sys->coolant_request = coolant_request;
    packet << CMD_SET_SYSTEM_COOLANT_REQUEST << system << coolant_request;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandDock(sp::ecs::Entity object)
{
    if (!object) return;
    sp::io::DataBuffer packet;
    packet << CMD_DOCK << object;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandUndock()
{
    sp::io::DataBuffer packet;
    packet << CMD_UNDOCK;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandAbortDock()
{
    sp::io::DataBuffer packet;
    packet << CMD_ABORT_DOCK;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandOpenTextComm(sp::ecs::Entity obj)
{
    if (!obj) return;
    sp::io::DataBuffer packet;
    packet << CMD_OPEN_TEXT_COMM << obj;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandCloseTextComm()
{
    sp::io::DataBuffer packet;
    packet << CMD_CLOSE_TEXT_COMM;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandAnswerCommHail(bool awnser)
{
    sp::io::DataBuffer packet;
    packet << CMD_ANSWER_COMM_HAIL << awnser;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSendComm(uint8_t index)
{
    sp::io::DataBuffer packet;
    packet << CMD_SEND_TEXT_COMM << index;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSendCommPlayer(string message)
{
    sp::io::DataBuffer packet;
    packet << CMD_SEND_TEXT_COMM_PLAYER << message;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetAutoRepair(bool enabled)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_AUTO_REPAIR << enabled;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetBeamFrequency(int32_t frequency)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_BEAM_FREQUENCY << frequency;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetBeamSystemTarget(ShipSystem::Type system)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_BEAM_SYSTEM_TARGET << system;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetShieldFrequency(int32_t frequency)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_SHIELD_FREQUENCY << frequency;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandAddWaypoint(glm::vec2 position)
{
    sp::io::DataBuffer packet;
    packet << CMD_ADD_WAYPOINT << position;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandRemoveWaypoint(int32_t index)
{
    sp::io::DataBuffer packet;
    packet << CMD_REMOVE_WAYPOINT << index;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandMoveWaypoint(int32_t index, glm::vec2 position)
{
    sp::io::DataBuffer packet;
    packet << CMD_MOVE_WAYPOINT << index << position;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandActivateSelfDestruct()
{
    sp::io::DataBuffer packet;
    packet << CMD_ACTIVATE_SELF_DESTRUCT;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandCancelSelfDestruct()
{
    sp::io::DataBuffer packet;
    packet << CMD_CANCEL_SELF_DESTRUCT;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandConfirmDestructCode(int8_t index, uint32_t code)
{
    sp::io::DataBuffer packet;
    packet << CMD_CONFIRM_SELF_DESTRUCT << index << code;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandCombatManeuverBoost(float amount)
{
    auto combat = my_spaceship.getComponent<CombatManeuveringThrusters>();
    if (!combat) return;
    combat->boost.request = amount;
    sp::io::DataBuffer packet;
    packet << CMD_COMBAT_MANEUVER_BOOST << amount;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandCombatManeuverStrafe(float amount)
{
    auto combat = my_spaceship.getComponent<CombatManeuveringThrusters>();
    if (!combat) return;
    combat->strafe.request = amount;
    sp::io::DataBuffer packet;
    packet << CMD_COMBAT_MANEUVER_STRAFE << amount;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandLaunchProbe(glm::vec2 target_position)
{
    sp::io::DataBuffer packet;
    packet << CMD_LAUNCH_PROBE << target_position;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandScanDone()
{
    sp::io::DataBuffer packet;
    packet << CMD_SCAN_DONE;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandScanCancel()
{
    sp::io::DataBuffer packet;
    packet << CMD_SCAN_CANCEL;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetAlertLevel(AlertLevel level)
{
    sp::io::DataBuffer packet;
    packet << CMD_SET_ALERT_LEVEL;
    packet << level;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandHackingFinished(sp::ecs::Entity target, ShipSystem::Type target_system)
{
    sp::io::DataBuffer packet;
    packet << CMD_HACKING_FINISHED;
    packet << target;
    packet << target_system;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandCustomFunction(string name)
{
    sp::io::DataBuffer packet;
    packet << CMD_CUSTOM_FUNCTION;
    packet << name;
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::commandSetScienceLink(sp::ecs::Entity probe)
{
    sp::io::DataBuffer packet;

    // Pass the probe's multiplayer ID if the probe isn't nullptr.
    if (probe)
    {
        packet << CMD_SET_SCIENCE_LINK;
        packet << probe;
        dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
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
    packet << sp::ecs::Entity{};
    dynamic_cast<PlayerSpaceship*>(*my_spaceship.getComponent<SpaceObject*>())->sendClientCommand(packet);
}

void PlayerSpaceship::onReceiveServerCommand(sp::io::DataBuffer& packet)
{
    int16_t command;
    packet >> command;
    switch(command)
    {
    case CMD_PLAY_CLIENT_SOUND:
        if (my_spaceship == entity && my_player_info)
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
    //if (can_scan != ship_template->can_scan)
    //    result += ":setCanScan(" + string(can_scan, true) + ")";
    if (can_hack != ship_template->can_hack)
        result += ":setCanHack(" + string(can_hack, true) + ")";
    //if (can_dock != ship_template->can_dock)
    //    result += ":setCanDock(" + string(can_dock, true) + ")";
    //if (can_combat_maneuver != ship_template->can_combat_maneuver)
    //    result += ":setCanCombatManeuver(" + string(can_combat_maneuver, true) + ")";
    //if (can_self_destruct != ship_template->can_self_destruct)
    //    result += ":setCanSelfDestruct(" + string(can_self_destruct, true) + ")";
    //if (can_launch_probe != ship_template->can_launch_probe)
    //    result += ":setCanLaunchProbe(" + string(can_launch_probe, true) + ")";
    //if (auto_coolant_enabled)
    //    result += ":setAutoCoolant(true)";
    if (auto_repair_enabled)
        result += ":commandSetAutoRepair(true)";

    // Update power factors, only for the systems where it changed.
    /*
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
                result += ":setSystemPowerFactor(" + string(system) + ", " + string(current_factor, 1) + ")";
            }

            if (std::fabs(getSystemCoolantRate(system) - ShipSystemLegacy::default_coolant_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemCoolantRate(" + string(system) + ", " + string(getSystemCoolantRate(system), 2) + ")";
            }

            if (std::fabs(getSystemHeatRate(system) - ShipSystemLegacy::default_heat_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemHeatRate(" + string(system) + ", " + string(getSystemHeatRate(system), 2) + ")";
            }

            if (std::fabs(getSystemPowerRate(system) - ShipSystemLegacy::default_power_rate_per_second) > std::numeric_limits<float>::epsilon())
            {
                result += ":setSystemPowerRate(" + string(system) + ", " + string(getSystemPowerRate(system), 2) + ")";
            }
        }
    }
    */

    //if (std::fabs(getEnergyShieldUsePerSecond() - default_energy_shield_use_per_second) > std::numeric_limits<float>::epsilon())
    //    result += ":setEnergyShieldUsePerSecond(" + string(getEnergyShieldUsePerSecond(), 2) + ")";

    //if (std::fabs(getEnergyWarpPerSecond() - default_energy_warp_per_second) > std::numeric_limits<float>::epsilon())
    //    result += ":setEnergyWarpPerSecond(" + string(getEnergyWarpPerSecond(), 2) + ")";
    return result;
}

void PlayerSpaceship::onProbeLaunch(ScriptSimpleCallback callback)
{
    //TODO this->on_probe_launch = callback;
}

void PlayerSpaceship::onProbeLink(ScriptSimpleCallback callback)
{
    //TODO this->on_probe_link = callback;
}

void PlayerSpaceship::onProbeUnlink(ScriptSimpleCallback callback)
{
    //TODO this->on_probe_unlink = callback;
}

#include "playerSpaceship.hpp"
