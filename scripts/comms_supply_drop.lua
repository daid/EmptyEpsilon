--- Supply ship comms.
--
-- Stripped comms that do not allow any interaction.
-- Used for transport ships spawned in `util_random_transports.lua`.
--
-- TODO `player` can be replaced by `comms_source`
--
-- @script comms_supply_drop

--- Main menu.
function commsShipMainMenu()
    if player:isFriendly(comms_target) then
        setCommsMessage("Transporting goods.")
        return true
    end
    if player:isEnemy(comms_target) then
        return false
    end
    setCommsMessage("We have nothing for you.\nGood day.")
end

commsShipMainMenu()
