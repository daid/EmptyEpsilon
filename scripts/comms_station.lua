--- Basic station comms.
--
-- Station comms that allows buying ordnance, supply drop, and reinforcements.
-- Default script for any `SpaceStation`.
--
-- @script comms_station

-- uses `mergeTables`
require("utils.lua")

-- NOTE this could be imported
local MISSILE_TYPES = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}

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
    if comms_source:isFriendly(comms_target) then
        setCommsMessage("Good day, officer! Welcome to " .. comms_target:getCallSign() .. ".\nWhat can we do for you today?")
    else
        setCommsMessage("Welcome to our lovely station " .. comms_target:getCallSign() .. ".")
    end

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
                function()
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
        if weapon == "Nuke" then
            setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then
            setCommsMessage("We do not deal in weapons of mass disruption.")
        else
            setCommsMessage("We do not deal in those weapons.")
        end
        return
    end

    local points_per_item = getWeaponCost(comms_source, comms_target, weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus(comms_source, comms_target)]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.")
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.")
        end
        addCommsReply("Back", commsStationMainMenu)
    else
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
            setCommsMessage("You are fully loaded and ready to explode things.")
        else
            setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
        end
        addCommsReply("Back", commsStationMainMenu)
    end
end

--- Handle communications when we are not docked with the station.
--
-- @tparam PlayerSpaceship comms_source
-- @tparam SpaceStation comms_target
function commsStationUndocked(comms_source, comms_target)
    if comms_source:isFriendly(comms_target) then
        setCommsMessage("This is " .. comms_target:getCallSign() .. ". Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        setCommsMessage("This is " .. comms_target:getCallSign() .. ". Greetings.\nIf you want to do business, please dock with us first.")
    end

    -- supply drop
    if isAllowedTo(comms_source, comms_target, comms_target.comms_data.services.supplydrop) then
        addCommsReply(
            "Can you send a supply drop? (" .. getServiceCost(comms_source, comms_target, "supplydrop") .. "rep)",
            function()
                if comms_source:getWaypointCount() < 1 then
                    setCommsMessage("You need to set a waypoint before you can request backup.")
                else
                    setCommsMessage("To which waypoint should we deliver your supplies?")
                    for n = 1, comms_source:getWaypointCount() do
                        addCommsReply(
                            "WP" .. n,
                            function()
                                if comms_source:takeReputationPoints(getServiceCost(comms_source, comms_target, "supplydrop")) then
                                    local position_x, position_y = comms_target:getPosition()
                                    local target_x, target_y = comms_source:getWaypoint(n)
                                    local script = Script()
                                    script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                                    script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                                    script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                                    setCommsMessage("We have dispatched a supply ship toward WP" .. n)
                                else
                                    setCommsMessage("Not enough reputation!")
                                end
                                addCommsReply("Back", commsStationMainMenu)
                            end
                        )
                    end
                end
                addCommsReply("Back", commsStationMainMenu)
            end
        )
    end

    -- reinforcements
    if isAllowedTo(comms_source, comms_target, comms_target.comms_data.services.reinforcements) then
        addCommsReply(
            "Please send reinforcements! (" .. getServiceCost(comms_source, comms_target, "reinforcements") .. "rep)",
            function()
                if comms_source:getWaypointCount() < 1 then
                    setCommsMessage("You need to set a waypoint before you can request reinforcements.")
                else
                    setCommsMessage("To which waypoint should we dispatch the reinforcements?")
                    for n = 1, comms_source:getWaypointCount() do
                        addCommsReply(
                            "WP" .. n,
                            function()
                                if comms_source:takeReputationPoints(getServiceCost(comms_source, comms_target, "reinforcements")) then
                                    local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                                    setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n)
                                else
                                    setCommsMessage("Not enough reputation!")
                                end
                                addCommsReply("Back", commsStationMainMenu)
                            end
                        )
                    end
                end
                addCommsReply("Back", commsStationMainMenu)
            end
        )
    end
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

-- `comms_source` and `comms_target` are global in comms script.
commsStationMainMenu(comms_source, comms_target)
