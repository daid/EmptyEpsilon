--- Default communication for ships and stations.
--
-- - `CpuShip`: get status report and set orders if friendly
-- - `SpaceStation`: supply drop, reinforcements; buy ordnance if docked
--
-- Required by `comms_ship` and `comms_station`.
--
-- Currently, only the first of these two works:
--
-- - You can require this file in *comms scripts* and use the functions here
--   in your scenario's dialogs.
--
-- - Warning:
--   Due to limitations of or a bug in EE, it is not (yet?) possible to require
--   this file and use the provided functions as communication *callbacks*
--   in `ship:setCommsFunction`:
--   The game (version 2020.11.23) would crash.
--
-- Make sure you have `comms_data` set if it is accessed by a function.
-- The defaults `commsShipMainMenu` and `commsStationMainMenu` do that.
--
-- Think about the "Back" replies.
--
-- More info about the comms related functions
-- (`setCommsMessage`, `addCommsReply`;
-- `ship:setCommsFunction`, `ship:setCommsScript`)
-- in `script_reference.html`.
--
-- **Warning**:
-- The function names might change in the future.
-- Be prepared to adjust your scenarios.
--
-- **Usage** (here only for a station):
--
--     -- in scenario_example.lua:
--     SpaceStation():setCommsScript("example_comms_script.lua")
--
--     -- in example_comms_script.lua
--     require("comms.lua")
--
--     function scenarioCommsStationMainMenu(source, target)
--       setCommsMessage("Your message")
--       addCommsReply("default comms", commsStationMainMenu)
--     end
--
--     scenarioCommsStationMainMenu(comms_source, comms_target)
--
-- @module comms

--- Common
-- @section common

-- uses `mergeTables`
require("utils.lua")

-- NOTE this could be imported
local MISSILE_TYPES = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}

--- Format integer i as "WP i".
--
-- @tparam integer i the index of the waypoint
-- @treturn string "WP i"
function formatWaypoint(i)
    return string.format("WP %d", i)
end

--- Ship communication
-- @section ship

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
        setCommsMessage("What do you want?")
    else
        setCommsMessage("Sir, how can we assist?")
    end
    addCommsReply(
        "Defend a waypoint",
        function(comms_source, comms_target)
            if comms_source:getWaypointCount() == 0 then
                setCommsMessage("No waypoints set. Please set a waypoint first.")
                addCommsReply("Back", commsShipMainMenu)
            else
                setCommsMessage("Which waypoint should we defend?")
                for n = 1, comms_source:getWaypointCount() do
                    addCommsReply(
                        string.format("Defend %s", formatWaypoint(n)),
                        function(comms_source, comms_target)
                            comms_target:orderDefendLocation(comms_source:getWaypoint(n))
                            setCommsMessage(string.format("We are heading to assist at %s.", formatWaypoint(n)))
                            addCommsReply("Back", commsShipMainMenu)
                        end
                    )
                end
            end
        end
    )
    if comms_data.friendlyness > 0.2 then
        addCommsReply(
            "Assist me",
            function(comms_source, comms_target)
                setCommsMessage("Heading toward you to assist.")
                comms_target:orderDefendTarget(comms_source)
                addCommsReply("Back", commsShipMainMenu)
            end
        )
    end
    addCommsReply(
        "Report status",
        function(comms_source, comms_target)
            setCommsMessage(getStatusReport(comms_target))
            addCommsReply("Back", commsShipMainMenu)
        end
    )
    for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
        if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
            addCommsReply(
                string.format("Dock at %s", obj:getCallSign()),
                function(comms_source, comms_target)
                    setCommsMessage(string.format("Docking at %s.", obj:getCallSign()))
                    comms_target:orderDock(obj)
                    addCommsReply("Back", commsShipMainMenu)
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
        local taunt_option = "We will see to your destruction!"
        local taunt_success_reply = "Your bloodline will end here!"
        local taunt_failed_reply = "Your feeble threats are meaningless."
        if faction == "Kraylor" then
            message = "Ktzzzsss.\nYou will DIEEee weaklingsss!"
        elseif faction == "Arlenians" then
            message = "We wish you no harm, but will harm you if we must.\nEnd of transmission."
        elseif faction == "Exuari" then
            message = "Stay out of our way, or your death will amuse us extremely!"
        elseif faction == "Ghosts" then
            message = "One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."
            taunt_option = "EXECUTE: SELFDESTRUCT"
            taunt_success_reply = "Rogue command received. Targeting source."
            taunt_failed_reply = "External command ignored."
        elseif faction == "Ktlitans" then
            message = "The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."
            taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
            taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
            taunt_failed_reply = "The hive has greater priorities than exterminating pests."
        else
            message = "Mind your own business!"
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
        message = "Sorry, we have no time to chat with you.\nWe are on an important mission."
    else
        message = "We have nothing for you.\nGood day."
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
    local msg = "Hull: " .. math.floor(ship:getHull() / ship:getHullMax() * 100) .. "%\n"

    local shields = ship:getShieldCount()
    if shields == 1 then
        msg = msg .. "Shield: " .. math.floor(ship:getShieldLevel(0) / ship:getShieldMax(0) * 100) .. "%\n"
    elseif shields == 2 then
        msg = msg .. "Front Shield: " .. math.floor(ship:getShieldLevel(0) / ship:getShieldMax(0) * 100) .. "%\n"
        msg = msg .. "Rear Shield: " .. math.floor(ship:getShieldLevel(1) / ship:getShieldMax(1) * 100) .. "%\n"
    else
        for n = 0, shields - 1 do
            msg = msg .. "Shield " .. n .. ": " .. math.floor(ship:getShieldLevel(n) / ship:getShieldMax(n) * 100) .. "%\n"
        end
    end

    for i, missile_type in ipairs(MISSILE_TYPES) do
        if ship:getWeaponStorageMax(missile_type) > 0 then
            msg = msg .. missile_type .. " Missiles: " .. math.floor(ship:getWeaponStorage(missile_type)) .. "/" .. math.floor(ship:getWeaponStorageMax(missile_type)) .. "\n"
        end
    end

    return msg
end

--- Station communication
-- @section station

--- Main menu of communication.
--
-- - Prepares `comms_data`.
-- - If the station is not an enemy and no enemies are nearby, the dialog is
--   provided by `commsStationUndocked` or `commsStationDocked`.
--   (Back buttons go to the main menu in order to check for enemies again.)
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationMainMenu(comms_source, comms_target)
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(
        comms_target.comms_data,
        {
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
                reinforcements = "friend"
            },
            service_cost = {
                supplydrop = 100,
                reinforcements = 150
            },
            reputation_cost_multipliers = {
                friend = 1.0,
                neutral = 2.5
            },
            max_weapon_refill_amount = {
                friend = 1.0,
                neutral = 0.5
            }
        }
    )

    if comms_source:isEnemy(comms_target) then
        return false
    end

    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!")
        return true
    end
    if not comms_source:isDocked(comms_target) then
        commsStationUndocked(comms_source, comms_target)
    else
        commsStationDocked(comms_source, comms_target)
    end
    return true
end

--- Handle communications while docked with this station.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationDocked(comms_source, comms_target)
    local message
    if comms_source:isFriendly(comms_target) then
        message = string.format("Good day, officer! Welcome to %s.\nWhat can we do for you today?", comms_target:getCallSign())
    else
        message = string.format("Welcome to our lovely station %s.", comms_target:getCallSign())
    end
    setCommsMessage(message)

    local reply_messages = {
        ["Homing"] = "Do you have spare homing missiles for us?",
        ["HVLI"] = "Can you restock us with HVLI?",
        ["Mine"] = "Please re-stock our mines.",
        ["Nuke"] = "Can you supply us with some nukes?",
        ["EMP"] = "Please re-stock our EMP missiles."
    }

    for _, missile_type in ipairs(MISSILE_TYPES) do
        if comms_source:getWeaponStorageMax(missile_type) > 0 then
            addCommsReply(
                string.format("%s (%d rep each)", reply_messages[missile_type], getWeaponCost(comms_source, comms_target, missile_type)),
                function(comms_source, comms_target)
                    handleWeaponRestock(comms_source, comms_target, missile_type)
                end
            )
        end
    end
end

--- Handle weapon restock.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string weapon the missile type
function handleWeaponRestock(comms_source, comms_target, weapon)
    if not comms_source:isDocked(comms_target) then
        setCommsMessage("You need to stay docked for that action.")
        return
    end

    if not isAllowedTo(comms_source, comms_target, comms_target.comms_data.weapons[weapon]) then
        local message
        if weapon == "Nuke" then
            message = "We do not deal in weapons of mass destruction."
        elseif weapon == "EMP" then
            message = "We do not deal in weapons of mass disruption."
        else
            message = "We do not deal in those weapons."
        end
        setCommsMessage(message)
        return
    end

    local points_per_item = getWeaponCost(comms_source, comms_target, weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus(comms_source, comms_target)]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        local message
        if weapon == "Nuke" then
            message = "All nukes are charged and primed for destruction."
        else
            message = "Sorry, sir, but you are as fully stocked as I can allow."
        end
        setCommsMessage(message)
        addCommsReply("Back", commsStationMainMenu)
    else
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        local message
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
            message = "You are fully loaded and ready to explode things."
        else
            message = "We generously resupplied you with some weapon charges.\nPut them to good use."
        end
        setCommsMessage(message)
        addCommsReply("Back", commsStationMainMenu)
    end
end

--- Handle communications when we are not docked with the station.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationUndocked(comms_source, comms_target)
    local message
    if comms_source:isFriendly(comms_target) then
        message = string.format("This is %s. Good day, officer.\nIf you need supplies, please dock with us first.", comms_target:getCallSign())
    else
        message = string.format("This is %s. Greetings.\nIf you want to do business, please dock with us first.", comms_target:getCallSign())
    end
    setCommsMessage(message)

    -- supply drop
    if isAllowedTo(comms_source, comms_target, comms_target.comms_data.services.supplydrop) then
        addCommsReply(
            string.format("Can you send a supply drop? (%d rep)", getServiceCost(comms_source, comms_target, "supplydrop")),
            --
            commsStationSupplyDrop
        )
    end

    -- reinforcements
    if isAllowedTo(comms_source, comms_target, comms_target.comms_data.services.reinforcements) then
        addCommsReply(
            string.format("Please send reinforcements! (%d rep)", getServiceCost(comms_source, comms_target, "reinforcements")),
            --
            commsStationReinforcements
        )
    end
end

--- Ask for a waypoint and deliver supply drop to it.
--
-- Uses the script `supply_drop.lua`
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationSupplyDrop(comms_source, comms_target)
    if comms_source:getWaypointCount() < 1 then
        setCommsMessage("You need to set a waypoint before you can request backup.")
    else
        setCommsMessage("To which waypoint should we deliver your supplies?")
        for n = 1, comms_source:getWaypointCount() do
            addCommsReply(
                formatWaypoint(n),
                function(comms_source, comms_target)
                    local message
                    if comms_source:takeReputationPoints(getServiceCost(comms_source, comms_target, "supplydrop")) then
                        local position_x, position_y = comms_target:getPosition()
                        local target_x, target_y = comms_source:getWaypoint(n)
                        local script = Script()
                        script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                        script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                        script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                        message = string.format("We have dispatched a supply ship toward %s.", formatWaypoint(n))
                    else
                        message = "Not enough reputation!"
                    end
                    setCommsMessage(message)
                    addCommsReply("Back", commsStationMainMenu)
                end
            )
        end
    end
    addCommsReply("Back", commsStationMainMenu)
end

--- Ask for a waypoint and send reinforcements to defend it.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationReinforcements(comms_source, comms_target)
    if comms_source:getWaypointCount() < 1 then
        setCommsMessage("You need to set a waypoint before you can request reinforcements.")
    else
        setCommsMessage("To which waypoint should we dispatch the reinforcements?")
        for n = 1, comms_source:getWaypointCount() do
            addCommsReply(
                formatWaypoint(n),
                function(comms_source, comms_target)
                    local message
                    if comms_source:takeReputationPoints(getServiceCost(comms_source, comms_target, "reinforcements")) then
                        local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                        message = string.format("We have dispatched %s to assist at %s.", ship:getCallSign(), formatWaypoint(n))
                    else
                        message = "Not enough reputation!"
                    end
                    setCommsMessage(message)
                    addCommsReply("Back", commsStationMainMenu)
                end
            )
        end
    end
    addCommsReply("Back", commsStationMainMenu)
end

--- isAllowedTo
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string state
-- @treturn boolean true if allowed
function isAllowedTo(comms_source, comms_target, state)
    -- TODO reconsider the logic of these conditions
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end

--- Return the number of reputation points that a specified weapon costs for the
-- current player.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string weapon the missile type
-- @treturn integer the cost
function getWeaponCost(comms_source, comms_target, weapon)
    local relation = getFriendStatus(comms_source, comms_target)
    return math.ceil(comms_target.comms_data.weapon_cost[weapon] * comms_target.comms_data.reputation_cost_multipliers[relation])
end

--- Return the number of reputation points that a specified service costs for
-- the current player.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @tparam string service the service
-- @treturn integer the cost
function getServiceCost(comms_source, comms_target, service)
    return math.ceil(comms_target.comms_data.service_cost[service])
end

--- Return "friend" or "neutral".
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
-- @treturn string the status
function getFriendStatus(comms_source, comms_target)
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
