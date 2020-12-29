-- Name: Waves
-- Description: Waves of increasingly difficult enemies.
--- There is no victory. How many waves can you destroy?
---
--- Spawn the player ship(s) you want. The strength of the enemy is independent of their number and type.
-- Type: Basic
-- Variation[Hard]: Difficulty starts at wave 5 and increases by 1.5 after the players defeat each wave. (Players are more quickly overwhelmed, leading to shorter games.)
-- Variation[Easy]: Makes each wave easier by decreasing the number of ships in each wave. (Takes longer for the players to be overwhelmed; good for new players.)

--- Scenario
-- @script scenario_03_waves

require("utils.lua")
-- For this scenario, utils.lua provides:
--   vectorFromAngle(angle, length)
--      Returns a relative vector (x, y coordinates)
--   setCirclePos(obj, x, y, angle, distance)
--      Returns the object with its position set to the resulting coordinates.

function randomStationTemplate()
    local rnd = random(0, 100)
    if rnd < 10 then
        return "Huge Station"
    end
    if rnd < 20 then
        return "Large Station"
    end
    if rnd < 50 then
        return "Medium Station"
    end
    return "Small Station"
end

function init()
    -- global variables:
    waveNumber = 0
    spawnWaveDelay = nil
    enemyList = {}
    friendlyList = {}

    PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")

    -- Give the mission to the (first) player ship
    local text = [[At least one friendly base must survive.
Destroy all enemy ships. After a short delay, the next wave will appear.
And so on ...
How many waves can you destroy?]]
    getPlayerShip(-1):addToShipLog(text, "white")

    -- Random friendly stations
    for _ = 1, 2 do
        local station = SpaceStation():setTemplate(randomStationTemplate()):setFaction("Human Navy"):setPosition(random(-5000, 5000), random(-5000, 5000))
        table.insert(friendlyList, station)
    end

    -- Random neutral stations
    for _ = 1, 6 do
        local station = SpaceStation():setTemplate(randomStationTemplate()):setFaction("Independent")
        setCirclePos(station, 0, 0, random(0, 360), random(15000, 30000))
    end
    friendlyList[1]:addReputationPoints(150.0)

    -- Random nebulae
    local x, y = vectorFromAngle(random(0, 360), 15000)
    for n = 1, 5 do
        local xx, yy = vectorFromAngle(random(0, 360), random(2500, 10000))
        Nebula():setPosition(x + xx, y + yy)
    end

    -- Random asteroids
    local a, a2, d
    local dx1, dy1
    local dx2, dy2
    for cnt = 1, random(2, 7) do
        a = random(0, 360)
        a2 = random(0, 360)
        d = random(3000, 15000 + cnt * 5000)
        x, y = vectorFromAngle(a, d)
        for acnt = 1, 25 do
            dx1, dy1 = vectorFromAngle(a2, random(-1000, 1000))
            dx2, dy2 = vectorFromAngle(a2 + 90, random(-10000, 10000))
            Asteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
        end
        for acnt = 1, 50 do
            dx1, dy1 = vectorFromAngle(a2, random(-1500, 1500))
            dx2, dy2 = vectorFromAngle(a2 + 90, random(-10000, 10000))
            VisualAsteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
        end
    end

    -- First enemy wave
    spawnWave()

    -- Random transports
    Script():run("util_random_transports.lua")
end

function randomSpawnPointInfo(distance)
    local x, y
    local rx, ry
    if random(0, 100) < 50 then
        if random(0, 100) < 50 then
            x = -distance
        else
            x = distance
        end
        rx = 2500
        y = 0
        ry = 5000 + 1000 * waveNumber
    else
        x = 0
        rx = 5000 + 1000 * waveNumber
        if random(0, 100) < 50 then
            y = -distance
        else
            y = distance
        end
        ry = 2500
    end
    return x, y, rx, ry
end

function spawnWave()
    waveNumber = waveNumber + 1
    getPlayerShip(-1):addToShipLog("Wave " .. waveNumber, "red")
    friendlyList[1]:addReputationPoints(150 + waveNumber * 15)

    enemyList = {}

    -- Calculate score of wave
    local totalScoreRequirement  -- actually: remainingScoreRequirement
    if getScenarioVariation() == "Hard" then
        totalScoreRequirement = math.pow(waveNumber * 1.5 + 4, 1.3) * 10
    elseif getScenarioVariation() == "Easy" then
        totalScoreRequirement = math.pow(waveNumber * 0.8, 1.3) * 9
    else
        totalScoreRequirement = math.pow(waveNumber, 1.3) * 10
    end

    local scoreInSpawnPoint = 0
    local spawnDistance = 20000
    local spawnPointLeader = nil
    local spawn_x, spawn_y, spawn_range_x, spawn_range_y = randomSpawnPointInfo(spawnDistance)
    while totalScoreRequirement > 0 do
        local ship = CpuShip():setFaction("Ghosts")
        ship:setPosition(random(-spawn_range_x, spawn_range_x) + spawn_x, random(-spawn_range_y, spawn_range_y) + spawn_y)

        -- Make the first ship the leader at this spawn point
        if spawnPointLeader == nil then
            ship:orderRoaming()
            spawnPointLeader = ship
        else
            ship:orderDefendTarget(spawnPointLeader)
        end

        -- Set ship type
        local typeRoll = random(0, 10)
        local score
        if typeRoll < 2 then
            if irandom(1, 100) < 80 then
                ship:setTemplate("MT52 Hornet")
            else
                ship:setTemplate("MU52 Hornet")
            end
            score = 5
        elseif typeRoll < 3 then
            if irandom(1, 100) < 80 then
                ship:setTemplate("Adder MK5")
            else
                ship:setTemplate("WX-Lindworm")
            end
            score = 7
        elseif typeRoll < 6 then
            if irandom(1, 100) < 80 then
                ship:setTemplate("Phobos T3")
            else
                ship:setTemplate("Piranha F12")
            end
            score = 15
        elseif typeRoll < 7 then
            ship:setTemplate("Ranus U")
            score = 25
        elseif typeRoll < 8 then
            if irandom(1, 100) < 50 then
                ship:setTemplate("Stalker Q7")
            else
                ship:setTemplate("Stalker R7")
            end
            score = 25
        elseif typeRoll < 9 then
            ship:setTemplate("Atlantis X23")
            score = 50
        else
            ship:setTemplate("Odin")
            score = 250
        end
        assert(score ~= nil)

        -- Destroy ship if it was too strong else take it
        if score > totalScoreRequirement * 1.1 + 5 then
            ship:destroy()
        else
            table.insert(enemyList, ship)
            totalScoreRequirement = totalScoreRequirement - score
            scoreInSpawnPoint = scoreInSpawnPoint + score
        end

        -- Start new spawn point farther away
        if scoreInSpawnPoint > totalScoreRequirement * 2.0 then
            spawnDistance = spawnDistance + 5000
            spawn_x, spawn_y, spawn_range_x, spawn_range_y = randomSpawnPointInfo(spawnDistance)
            scoreInSpawnPoint = 0
            spawnPointLeader = nil
        end
    end

    globalMessage(string.format(_("Wave %d"), waveNumber))
end

function update(delta)
    -- Show countdown, spawn wave
    if spawnWaveDelay ~= nil then
        spawnWaveDelay = spawnWaveDelay - delta
        if spawnWaveDelay < 5 then
            globalMessage(math.ceil(spawnWaveDelay))
        end
        if spawnWaveDelay < 0 then
            spawnWave()
            spawnWaveDelay = nil
        end
        return
    end

    -- Count enemies and friends
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
    -- Continue ...
    if enemy_count == 0 then
        spawnWaveDelay = 15.0
        globalMessage("Wave cleared!")
        getPlayerShip(-1):addToShipLog("Wave " .. waveNumber .. " cleared.", "green")
    end
    -- ... or lose
    if friendly_count == 0 then
        victory("Ghosts") -- Victory for the Ghosts (= defeat for the players)
    end
end
