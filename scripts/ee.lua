--- Elementary Lua additions to EE.
--
-- (It might be a good idea to let EE provide some of these values.)
--
-- **Changelog**
--
-- *Version 0.5* (2020.05)
--
-- - Add `SYS_REACTOR` etc. and the array `SYSTEMS`.
--
-- @usage
-- require("ee.lua")
-- -- and see below
--
-- @module ee
-- @author Tom

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

--- Array of system names.
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
