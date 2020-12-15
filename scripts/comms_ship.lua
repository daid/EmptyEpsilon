--- Basic ship comms.
--
-- Simple ship comms that allows setting orders if friendly.
-- Default script for any `CpuShip`.
--
-- @script comms_ship

require("comms.lua")

-- `comms_source` and `comms_target` are global in comms script.
commsShipMainMenu(comms_source, comms_target)
