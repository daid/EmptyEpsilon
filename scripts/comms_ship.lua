--- Basic ship comms.
--
-- Simple ship comms that allows setting orders if friendly.
-- Default script for any `CpuShip`.
--
-- @script comms_ship

-- NOTE this could be imported
local MISSILE_TYPES = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}

--- Main menu of communication.
--
-- Uses one of `commsShipFriendly`, `commsShipNeutral`, `commsShipEnemy`.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsShipMainMenu(comms_source, comms_target)
    if comms_target.comms_data == nil then
        comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
    end

    if comms_source:isFriendly(comms_target) then
        return commsShipFriendly(comms_source, comms_target)
    end
    if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
        return commsShipEnemy(comms_source, comms_target)
    end
    return commsShipNeutral(comms_source, comms_target)
end

--- Handle friendly communication.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsShipFriendly(comms_source, comms_target)
    local comms_data = comms_target.comms_data
    if comms_data.friendlyness < 20 then
        setCommsMessage(_("commsShipAssist", "What do you want?"))
    else
        setCommsMessage(_("commsShipAssist", "Sir, how can we assist?"))
    end
    addCommsReply(
        _("commsShipAssist", "Defend a waypoint"),
        function(comms_source, comms_target)
            if comms_source:getWaypointCount() == 0 then
                setCommsMessage(_("commsShipAssist", "No waypoints set. Please set a waypoint first."))
                addCommsReply(_("button", "Back"), commsShipMainMenu)
            else
                setCommsMessage(_("commsShipAssist", "Which waypoint should we defend?"))
                for n = 1, comms_source:getWaypointCount() do
                    addCommsReply(
                        string.format(_("commsShipAssist", "Defend %s"), formatWaypoint(n)),
                        function(comms_source, comms_target)
                            x, y = comms_source:getWaypoint(n)
                            comms_target:orderDefendLocation(x, y)
                            setCommsMessage(string.format(_("commsShipAssist", "We are heading to assist at %s."), formatWaypoint(n)))
                            addCommsReply(_("button", "Back"), commsShipMainMenu)
                        end
                    )
                end
            end
        end
    )
    if comms_data.friendlyness > 0.2 then
        addCommsReply(
            _("commsShipAssist", "Assist me"),
            function(comms_source, comms_target)
                setCommsMessage(_("commsShipAssist", "Heading toward you to assist."))
                comms_target:orderDefendTarget(comms_source)
                addCommsReply(_("button", "Back"), commsShipMainMenu)
            end
        )
    end
    addCommsReply(
        _("commsShipAssist", "Report status"),
        function(comms_source, comms_target)
            setCommsMessage(getStatusReport(comms_target))
            addCommsReply(_("button", "Back"), commsShipMainMenu)
        end
    )
    for idx, obj in ipairs(comms_target:getObjectsInRange(5000)) do
        if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
            addCommsReply(
                string.format(_("commsShipAssist", "Dock at %s"), obj:getCallSign()),
                function(comms_source, comms_target)
                    setCommsMessage(string.format(_("commsShipAssist", "Docking at %s."), obj:getCallSign()))
                    comms_target:orderDock(obj)
                    addCommsReply(_("button", "Back"), commsShipMainMenu)
                end
            )
        end
    end
    return true
end

--- Handle enemy communication.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsShipEnemy(comms_source, comms_target)
    local comms_data = comms_target.comms_data
    if comms_data.friendlyness > 50 then
        local faction = comms_target:getFaction()
        local message
        local taunt_option = _("commsShipEnemy", "We will see to your destruction!")
        local taunt_success_reply = _("commsShipEnemy", "Your bloodline will end here!")
        local taunt_failed_reply = _("commsShipEnemy", "Your feeble threats are meaningless.")
        if faction == "Kraylor" then
            message = _("commsShipEnemy", [[Ktzzzsss.

You will DIEEee weaklingsss!]])
        elseif faction == "Arlenians" then
            message = _("commsShipEnemy", [[We wish you no harm, but will harm you if we must.

End of transmission.]])
        elseif faction == "Exuari" then
            message = _("commsShipEnemy", "Stay out of our way, or your death will amuse us extremely!")
        elseif faction == "Ghosts" then
            message = _("commsShipEnemy", [[One zero one.

No binary communication detected. Switching to universal speech.

Generating appropriate response for target from human language archives.

:Do not cross us.:

Communication halted.]])
            taunt_option = _("commsShipEnemy", "EXECUTE: SELFDESTRUCT")
            taunt_success_reply = _("commsShipEnemy", "Rogue command received. Targeting source.")
            taunt_failed_reply = _("commsShipEnemy", "External command ignored.")
        elseif faction == "Ktlitans" then
            message = _("commsShipEnemy", [[The hive suffers no threats. Opposition to any of us is opposition to us all.

Stand down or prepare to donate your corpses toward our nutrition.]])
            taunt_option = _("commsShipEnemy", "<Transmits 'The Itsy-Bitsy Spider' on all wavelengths>")
            taunt_success_reply = _("commsShipEnemy", "We do not need permission to pluck apart such an insignificant threat.")
            taunt_failed_reply = _("commsShipEnemy", "The hive has greater priorities than exterminating pests.")
        else
            message = _("commsShipEnemy", "Mind your own business!")
        end
        setCommsMessage(message)

        comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
        addCommsReply(
            taunt_option,
            function(comms_source, comms_target)
                if random(0, 100) < 30 then
                    comms_target:orderAttack(comms_source)
                    setCommsMessage(taunt_success_reply)
                else
                    setCommsMessage(taunt_failed_reply)
                end
            end
        )
        return true
    end
    return false
end

--- Handle neutral communication.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsShipNeutral(comms_source, comms_target)
    local message
    if comms_target.comms_data.friendlyness > 50 then
        message = _("commsShip", [[Sorry, we have no time to chat with you.

We are on an important mission.]])
    else
        message = _("commsShip", [[We have nothing for you.

Good day.]])
    end
    setCommsMessage(message)
    return true
end

--- Return status report of ship.
--
-- Hull, Shields, Missiles.
--
-- @tparam ShipTemplateBasedObject ship the ship
-- @treturn string the report
function getStatusReport(ship)
    local msg = string.format(_("commsShipAssist", "Hull: %d%%\n"), math.floor(ship:getHull() / ship:getHullMax() * 100))

    local shields = ship:getShieldCount()
    if shields == 1 then
        msg = msg .. string.format(_("commsShipAssist", "Shield: %d%%\n"), math.floor(ship:getShieldLevel(0) / ship:getShieldMax(0) * 100))
    elseif shields == 2 then
        msg = msg .. string.format(_("commsShipAssist", "Front Shield: %d%%\n"), math.floor(ship:getShieldLevel(0) / ship:getShieldMax(0) * 100))
        msg = msg .. string.format(_("commsShipAssist", "Rear Shield: %d%%\n"), math.floor(ship:getShieldLevel(1) / ship:getShieldMax(1) * 100))
    else
        for n = 0, shields - 1 do
            msg = msg .. string.format(_("commsShipAssist", "Shield %d: %d%%\n"), n, math.floor(ship:getShieldLevel(n) / ship:getShieldMax(n) * 100))
        end
    end

    for i, missile_type in ipairs(MISSILE_TYPES) do
        if ship:getWeaponStorageMax(missile_type) > 0 then
            msg = msg .. string.format(_("commsShipAssist", "%s Missiles: %d/%d\n"), missile_type, math.floor(ship:getWeaponStorage(missile_type)), math.floor(ship:getWeaponStorageMax(missile_type)))
        end
    end

    return msg
end

--- Format integer i as "WP i".
--
-- @tparam integer i the index of the waypoint
-- @treturn string "WP i"
function formatWaypoint(i)
    return string.format(_("commsShipAssist", "WP %d"), i)
end

-- `comms_source` and `comms_target` are global in comms script.
commsShipMainMenu(comms_source, comms_target)
