--- Elementary Lua additions to EE.
--
-- (It might be a good idea to let EE provide some of these values.)
--
-- **Planned additions**
--
-- - Constants for crew positions.
--
-- **Changelog**
--
-- *Version 0.7* (2020.08)
--
-- - Add constants for the scanned states and the array `SCANNED_STATES`.
--
-- *Version 0.6* (2020.05)
--
-- - Add the constant `MAX_PLAYER_SHIPS`.
-- - Add constants for the missile types and the array `MISSILE_TYPES`.
-- - Add constants for the alert levels and the array `ALERT_LEVELS`.
--
-- *Version 0.5* (2020.05)
--
-- - Add the constants `SYS_REACTOR` etc. and the array `SYSTEMS`.
--
-- @usage
-- require("ee.lua")
-- -- and see below
--
-- @module ee
-- @author Tom

--- Playerships.
-- @section playerships

--- Maximum number of player spaceships.
--
-- @usage
-- for index = 1, MAX_PLAYER_SHIPS do
--   local pship = getPlayerShip(index)
--   if pship then
--     -- do something
--     print(index, pship:getCallSign())
--   end
-- end
MAX_PLAYER_SHIPS = 32

--- Missiles.
--
-- String constants for the missile types (type `EMissileWeapons` in `script_reference.html`).
--
-- @section missile_types

--- `"Homing"`
MISSILE_HOMING = "Homing"
--- `"Nuke"`
MISSILE_NUKE = "Nuke"
--- `"Mine"`
MISSILE_MINE = "Mine"
--- `"EMP"`
MISSILE_EMP = "EMP"
--- `"HVLI"`
MISSILE_HVLI = "HVLI"

--- Array of the missile types.
MISSILE_TYPES = {
  MISSILE_HOMING,
  MISSILE_NUKE,
  MISSILE_MINE,
  MISSILE_EMP,
  MISSILE_HVLI
}

--- Systems.
--
-- String constants for the systems (type `ESystem` in `script_reference.html`).
-- They can be used as argument in functions concerning Engineering.
--
-- The values are taken from `shipTemplate.hpp`.
--
-- @section systems

--- `"reactor"`
SYS_REACTOR = "reactor"
--- `"beamweapons"`
SYS_BEAMWEAPONS = "beamweapons"
--- `"missilesystem"`
SYS_MISSILESYSTEM = "missilesystem"
--- `"maneuver"`
SYS_MANEUVER = "maneuver"
--- `"impulse"`
SYS_IMPULSE = "impulse"
--- `"warp"`
SYS_WARP = "warp"
--- `"jumpdrive"`
SYS_JUMPDRIVE = "jumpdrive"
--- `"frontshield"`
SYS_FRONTSHIELD = "frontshield"
--- `"rearshield"`
SYS_REARSHIELD = "rearshield"

--- Array of the system names.
--
-- @usage
-- local pship = getPlayerShip(-1)
-- for _, system in ipairs(SYSTEMS) do
--   pship:setSystemHealth(system, 1.0)
--   pship:setSystemHeat(system, 0.0)
--   pship:setSystemPower(system, 1.0)
--   pship:commandSetSystemPowerRequest(system, 1.0)
--   pship:setSystemCoolant(system, 0.0)
--   pship:commandSetSystemCoolantRequest(system, 0.0)
-- end
SYSTEMS = {
  SYS_REACTOR,
  SYS_BEAMWEAPONS,
  SYS_MISSILESYSTEM,
  SYS_MANEUVER,
  SYS_IMPULSE,
  SYS_WARP,
  SYS_JUMPDRIVE,
  SYS_FRONTSHIELD,
  SYS_REARSHIELD
}

--- Scanned states.
--
-- String constants for the scanned states (type `EScannedState` in `script_reference.html`).
--
-- See `EScannedState` in `spaceObject.h`.
--
-- @section scanned_states

--- `"notscanned"`
SS_NOT_SCANNED = "notscanned"
--- `"friendorfoeidentified"`
SS_FRIEND_OR_FOE_IDENTIFIED = "friendorfoeidentified"
--- `"simplescan"`
SS_SIMPLE_SCAN = "simplescan"
--- `"fullscan"`
SS_FULL_SCAN = "fullscan"

--- Array of the scanned states.
SCANNED_STATES = {
  SS_NOT_SCANNED,
  SS_FRIEND_OR_FOE_IDENTIFIED,
  SS_SIMPLE_SCAN,
  SS_FULL_SCAN
}

--- Alert Levels.
--
-- String constants for the alert levels (type `EAlertLevel` in `script_reference.html`).
--
-- See `playerSpaceship.cpp`.
--
-- @section alert_levels

--- `"Normal"` alert
ALERT_NORMAL = "Normal"
--- `"YELLOW ALERT"`
ALERT_YELLOW = "YELLOW ALERT"
--- `"RED ALERT"`
ALERT_RED = "RED ALERT"

--- Array of the alert levels.
ALERT_LEVELS = {
  ALERT_NORMAL,
  ALERT_YELLOW,
  ALERT_RED
}

--- Scanning Complexity.
--
-- String constants for scanning complexity (type `EScanningComplexity` in `script_reference.html`).
--
-- See `gameGlobalInfo.h`.

SC_NONE = "none"
SC_SIMPLE = "simple"
SC_NORMAL = "normal"
SC_ADVANCED = "advanced"

--- Array of the scan complexities.
SCANNING_COMPLEXITIES = {
  SC_NONE,
  SC_SIMPLE,
  SC_NORMAL,
  SC_ADVANCED
}

--- Hacking Games.
--
-- String constants for hacking games (type `EHackingGames` in `script_reference.html`).
--
-- See `gameGlobalInfo.h`.

HG_Mine = "mines"
HG_Lights = "lights"
HG_All = "all"

--- Array of the scan complexities.
HACKING_GAMES = {
  HG_Mine,
  HG_Lights,
  HG_All,
}
