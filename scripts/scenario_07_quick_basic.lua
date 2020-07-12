-- Name: Quick Basic
-- Description: Different version of the basic scenario. Which intended to play out quicker. There is only a single small station to defend.
--- This scenario is designed to be ran on conventions. As you can run a 4 player crew in 20 minutes trough a game with minimal experience.
---
--- This scenario is designed for the provided player ship of type Phobos (or Atlantis on Advanced).
-- Type: Convention
-- Variation[Advanced]: Give the players a stronger Atlantis instead of the Phobos. Which is more difficult to control, but has more firepower and defense. Increases enemy strengh as well.
-- Variation[GM Start]: The scenario is not started until the GM gives the start sign. This gives some time for a new crew to get a feeling for the controls before the actual scenario starts.

--- Scenario
-- @script scenario_07_quick_basic

-- Import:
-- vectorFromAngle(angle, length)
-- setCirclePos(obj, x, y, angle, distance)
require("utils.lua")

gametimeleft = 20 * 60 -- Maximum game time in seconds.
timewarning = 10 * 60 -- Used for checking when to give a warning, and to update it so the warning happens once.

ship_names = {
    "SS Epsilon",
    "Ironic Gentleman",
    "Binary Sunset",
    "USS Roddenberry",
    "Earthship Sagan",
    "Explorer",
    "ISV Phantom",
    "Keelhaul",
    "Peacekeeper",
    "WarMonger",
    "Death Bringer",
    "Executor",
    "Excaliber",
    "Voyager",
    "Khan's Wrath",
    "Kronos' Savior",
    "HMS Captor",
    "Imperial Stature",
    "ESS Hellfire",
    "Helen's Fury",
    "Venus' Light",
    "Blackbeard's Way",
    "ISV Monitor",
    "Argent",
    "Echo One",
    "Earth's Might",
    "ESS Tomahawk",
    "Sabretooth",
    "Hiro-maru",
    "USS Nimoy",
    "Earthship Tyson",
    "Destiny's Tear",
    "HMS SuperNova",
    "Alma del Terra",
    "DreadHeart",
    "Devil's Maw",
    "Cougar's Claw",
    "Blood-oath",
    "Imperial Fist",
    "HMS Promise",
    "ESS Catalyst",
    "Hercules Ascendant",
    "Heavens Mercy",
    "HMS Adams",
    "Explorer",
    "Discovery",
    "Stratosphere",
    "USS Kelly",
    "HMS Honour",
    "Devilfish",
    "Minnow",
    "Earthship Nye",
    "Starcruiser Solo",
    "Starcruiser Reynolds",
    "Starcruiser Hunt",
    "Starcruiser Lipinski",
    "Starcruiser Tylor",
    "Starcruiser Kato",
    "Starcruiser Picard",
    "Starcruiser Janeway",
    "Starcruiser Archer",
    "Starcruiser Sisko",
    "Starcruiser Kirk",
    "Aluminum Falcon",
    "SS Essess",
    "Jenny"
}

--- Add an enemy wave.
--
-- @param enemyList A table containing enemy ship objects. The created ships are appended to this array.
-- @param kind A number; at each integer, determines a different wave of ships to add
--  to the enemyList. Any number is valid, but only numbers in [0, 10) are meaningful.
-- @param a The spawned wave's heading relative to the players' spawn point.
-- @param d The spawned wave's distance from the players' spawn point.
function addWave(enemyList, kind, a, d)
    local cx, cy = 0, 0 -- center
    if kind < 1.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Ranus U"):setRotation(a + 180):orderRoaming(), cx, cy, a, d))
    elseif kind < 2.0 then
        local leader = setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-1, 1), d + random(-100, 100))
        table.insert(enemyList, leader)
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, -400, 0), cx, cy, a + random(-1, 1), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, 400, 0), cx, cy, a + random(-1, 1), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, -400, 400), cx, cy, a + random(-1, 1), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, 400, 400), cx, cy, a + random(-1, 1), d + random(-100, 100)))
    elseif kind < 3.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Adder MK5"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Adder MK5"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 4.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 5.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Atlantis X23"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 6.0 then
        local leader = setCirclePos(CpuShip():setTemplate("Piranha F12"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100))
        table.insert(enemyList, leader)
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, -1500, 400), cx, cy, a + random(-1, 1), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, 1500, 400), cx, cy, a + random(-1, 1), d + random(-100, 100)))
    elseif kind < 7.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 8.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("Nirvana R5"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 9.0 then
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("MU52 Hornet"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    else
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("WX-Lindworm"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
        table.insert(enemyList, setCirclePos(CpuShip():setTemplate("WX-Lindworm"):setRotation(a + 180):orderRoaming(), cx, cy, a + random(-5, 5), d + random(-100, 100)))
    end
end

--- Returns a semi-random heading.
--
-- @param cnt A counter, generally between 1 and the number of enemy groups.
-- @param enemy_group_count A number of enemy groups, generally set by the scenario variation.
function getWaveAngle(cnt, enemy_group_count)
    return cnt * 360 / enemy_group_count + random(-60, 60)
end

--- Returns a semi-random distance.
--
-- @param cnt A counter, generally between 1 and the number of enemy groups.
-- @param enemy_group_count A number of enemy groups, generally set by the scenario variation. Unused.
function getWaveDistance(cnt, enemy_group_count)
    return random(25000 + cnt * 1000, 30000 + cnt * 3000)
end

--- Add GM functions.
function initGM()
    -- Let the GM declare the Humans (players) victorious.
    addGMFunction(
        "Win",
        function()
            victory("Human Navy")
        end
    )

    -- Let the GM declare the Humans (players) defeated.
    addGMFunction(
        "Defeat",
        function()
            victory("Kraylor")
        end
    )

    -- Let the GM create more enemies if the players are having a too easy time.
    addGMFunction(
        "Extra wave",
        function()
            addWave(enemyList, random(0, 10), random(0, 360), random(25000, 30000))
        end
    )
end

--- Add target practice for GM Start.
function initGMStart()
    -- global target_practice_drone
    target_practice_drone = CpuShip():setFaction("Ghosts"):setTemplate("MT52 Hornet"):setTypeName("Target practice")
    target_practice_drone:setScannedByFaction("Human Navy", true)
    target_practice_drone:setImpulseMaxSpeed(60)
    target_practice_drone:setBeamWeapon(0, 0, 0, 0.0, 0, 0)
    local x, y = 2500, 3500
    target_practice_drone:setPosition(x, y):orderDefendLocation(x, y)

    addGMFunction(
        "Start",
        function()
            startScenario()
            removeGMFunction("Start")
        end
    )
end

--- Clear GM Start.
function clearGMStart()
    -- global target_practice_drone
    if target_practice_drone ~= nil and target_practice_drone:isValid() then
        target_practice_drone:destroy()
    end
end

--- Init.
function init()
    enemyList = {}
    friendlyList = {}

    -- center of game area
    local cx, cy = 0, 0

    -- Create player ship.
    local template_name = "Phobos M3P"
    if getScenarioVariation() == "Advanced" then
        template_name = "Atlantis"
    end
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate(template_name)
    player:setPosition(cx + random(-2000, 2000), cy + random(-2000, 2000)):setCallSign(ship_names[irandom(1, #ship_names)])
    player:setJumpDrive(true)
    player:setWarpDrive(false)

    -- Start the players with 300 reputation.
    player:addReputationPoints(300.0)

    allowNewPlayerShips(false)

    -- Put a single small station here, which needs to be defended.
    table.insert(friendlyList, SpaceStation():setTemplate("Small Station"):setCallSign("DS-1"):setRotation(random(0, 360)):setFaction("Human Navy"):setPosition(random(-2000, 2000), random(-2000, 2000)))

    -- Randomly scatter nebulae, one closer to the center.
    setCirclePos(Nebula(), cx, cy, random(0, 360), 15000)
    for _ = 1, 5 do
        setCirclePos(Nebula(), cx, cy, random(0, 360), random(23000, 45000))
    end

    initGM()

    -- Spawn 1-3 random asteroid belts.
    for cnt = 1, irandom(1, 3) do
        local a = random(0, 360) -- angle (direction)
        local d = random(3000, 40000) -- distance
        local x, y = vectorFromAngle(a, d)

        local a2 = random(0, 360) -- angle (orientation)

        for _ = 1, 50 do
            local dx1, dy1 = vectorFromAngle(a2, random(-1000, 1000))
            local dx2, dy2 = vectorFromAngle(a2 + 90, random(-20000, 20000))
            Asteroid():setPosition(cx + x + dx1 + dx2, cy + y + dy1 + dy2):setSize(random(100, 500))
        end

        for _ = 1, 100 do
            local dx1, dy1 = vectorFromAngle(a2, random(-1500, 1500))
            local dx2, dy2 = vectorFromAngle(a2 + 90, random(-20000, 20000))
            VisualAsteroid():setPosition(cx + x + dx1 + dx2, cy + y + dy1 + dy2)
        end
    end

    -- Spawn 0-1 random mine fields.
    for cnt = 1, irandom(0, 1) do
        local a = random(0, 360) -- angle (direction)
        local d = random(20000, 40000) -- distance
        local x, y = vectorFromAngle(a, d)

        local a2 = random(0, 360) -- angle (orientation)

        local v = 100 -- variation of mine position
        local spacing = 1000 -- gap between mines
        for nx = -1, 1 do
            for ny = -5, 5 do
                if irandom(0, 100) < 90 then
                    local dx1, dy1 = vectorFromAngle(a2, (nx * spacing) + random(-v, v))
                    local dx2, dy2 = vectorFromAngle(a2 + 90, (ny * spacing) + random(-v, v))
                    Mine():setPosition(cx + x + dx1 + dx2, cy + y + dy1 + dy2)
                end
            end
        end
    end

    -- Create a bunch of neutral stations.
    for _ = 1, 6 do
        setCirclePos(SpaceStation():setTemplate("Small Station"):setFaction("Independent"), cx, cy, random(0, 360), random(15000, 30000))
    end
    -- Spawn random neutral transports.
    Script():run("util_random_transports.lua")

    -- Set the number of enemy waves based on the scenario variation.
    if getScenarioVariation() == "Advanced" then
        enemy_group_count = 6
    else
        enemy_group_count = 3
    end

    -- If we have a GM started scenario.
    scenario_started = false
    if getScenarioVariation() == "GM Start" then
        initGMStart()
    end
end

--- Start Scenario.
--
-- Called once in `update` as soon as the game is unpaused or by the GM.
function startScenario()
    clearGMStart()

    -- If not in the Empty variation, spawn the corresponding number of random
    -- enemy waves at distributed random headings and semi-random distances
    -- relative to the players' spawn point.
    if enemy_group_count > 0 then
        for cnt = 1, enemy_group_count do
            local a = getWaveAngle(cnt, enemy_group_count)
            local d = getWaveDistance(cnt, enemy_group_count)
            local kind = random(0, 10)
            addWave(enemyList, kind, a, d)
        end
    end

    local station = friendlyList[1]
    station:sendCommsMessage(
        player,
        string.format([[%s, your objective is to fend off the incoming Kraylor attack.
Please inform your Captain and crew that you have a total of %d minutes for this mission.
The mission started at the arrival of this message.
Good Luck.]], player:getCallSign(), gametimeleft / 60)
    )
    scenario_started = true
end

--- Return condition as string.
function getCondition()
    local condition = "green"
    for i = 1, player:getShieldCount() do
        if player:getShieldLevel(i) < player:getShieldMax(i) * 0.8 then
            condition = "yellow"
        end
    end
    if player:getHull() < player:getHullMax() * 0.8 then
        condition = "red"
    end
    return condition
end

--- Update.
--
-- @param delta time delta
function update(delta)
    if not scenario_started then
        if not player:isValid() then
            victory("Kraylor")
            local text = "Mission: FAILED (ship lost before mission started)"
            globalMessage(text)
            setBanner(text)
            return
        end
        setBanner("Mission: PREPARING")
        if delta > 0 and getScenarioVariation() ~= "GM Start" then
            -- Start the scenario when the game is not paused and we are not waiting for the GM to start the game.
            startScenario()
        end
    else -- scenario_started
        -- Calculate the game time left, and act on it.
        gametimeleft = gametimeleft - delta
        if gametimeleft < 0 then
            victory("Kraylor")
            local text = "Mission: FAILED (time has run out)"
            globalMessage(text)
            setBanner(text)
            return
        end
        if gametimeleft < timewarning then
            if timewarning <= 1 * 60 then -- Less then 1 minutes left.
                friendlyList[1]:sendCommsMessage(player, string.format([[%s, you have 1 minute remaining.]], player:getCallSign(), timewarning / 60))
                timewarning = timewarning - 2 * 60
            elseif timewarning <= 5 * 60 then -- Less then 5 minutes left. Warn ever 2 minutes instead of every 5.
                friendlyList[1]:sendCommsMessage(player, string.format([[%s, you have %d minutes remaining.]], player:getCallSign(), timewarning / 60))
                timewarning = timewarning - 2 * 60
            else
                friendlyList[1]:sendCommsMessage(player, string.format([[%s, you have %d minutes remaining of mission time.]], player:getCallSign(), timewarning / 60))
                timewarning = timewarning - 5 * 60
            end
        end

        -- Count all surviving enemies and allies.
        local enemy_count = 0
        local friendly_count = 0
        for _, enemy in ipairs(enemyList) do
            if enemy:isValid() then
                enemy_count = enemy_count + 1
            end
        end
        for _, friendly in ipairs(friendlyList) do
            if friendly:isValid() then
                friendly_count = friendly_count + 1
            end
        end

        -- Declare victory for the Humans (players) once all enemies are destroyed.
        -- Note that players can win even if they destroy the enemies by blowing themselves up.
        if enemy_count == 0 then
            victory("Human Navy")
            local text = string.format("Mission: SUCCESS (%d seconds left)", math.floor(gametimeleft))
            globalMessage(text)
            setBanner(text)
            return
        end

        -- If last player ship is destroyed, the Humans (players) lose.
        if not player:isValid() then
            victory("Kraylor")
            local text = "Mission: FAILED (all your ships destroyed)"
            globalMessage(text)
            setBanner(text)
            return
        end

        -- If all allies are destroyed, the Humans (players) lose.
        if friendly_count == 0 then
            victory("Kraylor")
            local text = "Mission: FAILED (no friendlies left)"
            globalMessage(text)
            setBanner(text)
            return
        end

        -- As the battle continues, award reputation based on
        -- the players' progress and number of surviving allies.
        for _, friendly in ipairs(friendlyList) do
            if friendly:isValid() then
                friendly:addReputationPoints(delta * friendly_count * 0.1)
            end
        end

        -- Set banner for cinematic and top down views.
        local condition = getCondition()
        setBanner(string.format("Mission in progress - Time left: %d:%02d - Enemies: %d - Condition: %s", math.floor(gametimeleft / 60), math.floor(gametimeleft % 60), enemy_count, condition))
    end
end
