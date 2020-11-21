--- Basic station comms.
--
-- Station comms that allows buying ordnance, supply drop, and reinforcements.
-- Default script for any `SpaceStation`.
--
-- @script comms_station

require("comms.lua")

-- `comms_source` and `comms_target` are global in comms script.
commsStationMainMenu(comms_source, comms_target)
