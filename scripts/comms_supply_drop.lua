--- Supply ship comms.
--
-- Enhanced to allow redirection of supply drops for a minor reputation cost
-- Used for transport ships spawned in `util_random_transports.lua`.
--
-- @script comms_supply_drop

--- Main menu.
function commsShipMainMenu(comms_source, comms_target)
    if comms_source:isFriendly(comms_target) then
        if (comms_target.state == 0) then
            local x, y = comms_target:getOrderTargetLocation()
            setCommsMessage(_("commsShip", "Dropping supplies in sector ") .. getSectorName(x, y))
            for n = 1, comms_source:getWaypointCount() do
                addCommsReply(
                    string.format(_("commsStation", comms_target:getCallSign() .. " - redirect your supply drop to WP %d"), n),
                    function(comms_source, comms_target)
                        local message
                        if comms_source:takeReputationPoints(5) then
                            message = string.format(_("commsStation", "Acknowledged. Redirecting."))
                            local x, y = comms_source:getWaypoint(n)
                            comms_target:orderFlyTowardsBlind(x, y)
                            comms_target.targetX = x
                            comms_target.targetY = y
                        else
                            message = _("commsStation", [[Sorry - we have our orders.]])
                        end
                        setCommsMessage(message)
                    end
                )
            end
        else
            setCommsMessage(_("commsShip", "Returning home."))
        end
        return true
    end
    if comms_source:isEnemy(comms_target) then
        return false
    end
    setCommsMessage(_("commsShip", "We have nothing for you.\nGood day."))
end

-- `comms_source` and `comms_target` are global in comms script
commsShipMainMenu(comms_source, comms_target)
