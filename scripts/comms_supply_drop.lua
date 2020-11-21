--- Supply ship comms.
--
-- Stripped comms that do not allow any interaction.
-- Used for transport ships spawned in `util_random_transports.lua`.
--
-- @script comms_supply_drop

--- Main menu.
function commsShipMainMenu(comms_source, comms_target)
    if comms_source:isFriendly(comms_target) then
        setCommsMessage("Transporting goods.")
        return true
    end
    if comms_source:isEnemy(comms_target) then
        return false
    end
    setCommsMessage("We have nothing for you.\nGood day.")
end

-- `comms_source` and `comms_target` are global in comms script
commsShipMainMenu(comms_source, comms_target)
