require("utils.lua")
require("options.lua")
require(lang .. "/comms.lua")

function mainMenu()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        },
        weapon_cost = {
            Homing = 2,
            HVLI = 2,
            Mine = 2,
            Nuke = 15,
            EMP = 10
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
        },
        service_cost = {
            supplydrop = 100,
            reinforcements = 150,
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 2.5
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
    comms_data = comms_target.comms_data

    if player:isEnemy(comms_target) then
        return false
    end

    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage(stationComms_underAttackGreetings);
        return true
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end

function handleDockedState()
    -- Handle communications while docked with this station.
    if player:isFriendly(comms_target) then
        setCommsMessage(stationComms_dockedFriendlyGreetings)
    else
        setCommsMessage(stationComms_dockedNeutralGreetings)
    end

    if player:getWeaponStorageMax(homing) > 0 then
        addCommsReply(stationComms_askForHoming .. " ("..getWeaponCost(homing) .. " " .. reputationEachShort .. ")", function()
            handleWeaponRestock(homing)
        end)
    end
    if player:getWeaponStorageMax(hvli) > 0 then
        addCommsReply(stationComms_askForHVLI .. " ("..getWeaponCost(hvli) .. " " .. reputationEachShort .. ")", function()
            handleWeaponRestock(hvli)
        end)
    end
    if player:getWeaponStorageMax(mine) > 0 then
        addCommsReply(stationComms_askForMines .. " (" .. getWeaponCost(mine) .. " " .. reputationEachShort .. ")", function()
            handleWeaponRestock(mine)
        end)
    end
    if player:getWeaponStorageMax(nuke) > 0 then
        addCommsReply(stationComms_askForNukes .. " ("..getWeaponCost(nuke) .. " " .. reputationEachShort .. ")", function()
            handleWeaponRestock(nuke)
        end)
    end
    if player:getWeaponStorageMax(emp) > 0 then
        addCommsReply(stationComms_askForEMP .. " ("..getWeaponCost(emp) .. " " .. reputationEachShort .. ")", function()
            handleWeaponRestock(emp)
        end)
    end
end

function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then setCommsMessage(stationComms_prematureUndocking); return end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == nuke then setCommsMessage(stationComms_noNukes)
        elseif weapon == emp then setCommsMessage(stationComms_noEMP)
        else setCommsMessage(stationNoOther) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == nuke then
            setCommsMessage(stationComms_nukesRefilled);
        else
            setCommsMessage(stationComms_alreadyFull);
        end
        addCommsReply(commonComms_back, mainMenu)
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage(stationComms_notEnoughReputation)
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage(stationComms_otherFull)
        else
            setCommsMessage(stationComms_generouslyRefilled)
        end
        addCommsReply(commonComms_back, mainMenu)
    end
end

function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        setCommsMessage(stationComms_undockedFriendlyGreetings)
    else
        setCommsMessage(stationComms_undockedNeutralGreetings)
    end
    if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(stationComms_requireSupplyDrop .. " (" .. getServiceCost("supplydrop") .. reputationShort .. ")", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(stationComms_waypointRequiredForSupply);
            else
                setCommsMessage(stationComms_suppliesWaypoint);
                for n=1,player:getWaypointCount() do
                    addCommsReply(waypointShort .. n, function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage(stationComms_supplyDispatched(n));
                        else
                            setCommsMessage(stationComms_notEnoughReputation);
                        end
                        addCommsReply(commonComms_back, mainMenu)
                    end)
                end
            end
            addCommsReply(commonComms_back, mainMenu)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply(stationComms_requireBackup .. " (" .. getServiceCost("reinforcements") .. reputationShort .. ")", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(stationComms_waypointRequiredForBackup);
            else
                setCommsMessage(stationComms_backupWaypoint);
                for n=1,player:getWaypointCount() do
                    addCommsReply(waypointShort .. n, function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage(stationComms_backupDispatched(ship:getCallSign(), n));
                        else
                            setCommsMessage(stationComms_notEnoughReputation);
                        end
                        addCommsReply(commonComms_back, mainMenu)
                    end)
                end
            end
            addCommsReply(commonComms_back, mainMenu)
        end)
    end
end

function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
    return false
end

-- Return the number of reputation points that a specified weapon costs for the
-- current player.
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end

-- Return the number of reputation points that a specified service costs for
-- the current player.
function getServiceCost(service)
    return math.ceil(comms_data.service_cost[service])
end

function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end

mainMenu()
