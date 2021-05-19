-- Name: Basic
-- Description: A few random stations are under attack by enemies, with random terrain around them. Destroy all enemies to win.
---
--- The scenario provides a single player-controlled Atlantis, which is sufficient to win even in the "Extreme" variant.
---
--- Other player ships can be spawned, but the strength of enemy ships is independent of the number and types of player ships.
-- Type: Basic
-- Variation[Empty]: No enemies. Recommended for GM-controlled scenarios and rookie crew orientation. The scenario continues until the GM declares victory or all Human Navy ships are destroyed.
-- Variation[Easy]: Fewer enemies. Recommended for inexperienced crews.
-- Variation[Hard]: More enemies. Recommended if you have multiple player-controlled ships.
-- Variation[Extreme]: Many enemies. Inexperienced player crews will pretty surely be overwhelmed.

--- Scenario
-- @script scenario_00_basic

require("utils.lua")
-- For this scenario, utils.lua provides:
--   vectorFromAngle(angle, length)
--      Returns a relative vector (x, y coordinates)
--   setCirclePos(obj, x, y, angle, distance)
--      Returns the object with its position set to the resulting coordinates.
--   distance(a, b, c, d)
--      Returns the distance between two objects/coordinates
--   angleRotation(a, b, c, d)
--      Returns the bearing between first object/coordinate and second object/coordinate. 

-- Global variables for this scenario
local enemyList
local friendlyList
local stationList
local addWavesToGMPosition      -- If set to true, add wave will require GM to click on the map to position, where the wave should be spawned. 

--- Wrapper to adding an enemy wave
--
-- This wrapper either calls addWaveInner directly (when on random wave positioning)
-- or after onGMClick (when set to GM wave positioning).
--
-- @tparam table list A table containing enemy ship objects.
-- @tparam integer kind A number; at each integer, determines a different wave of ships to add
--  to the list. Any number is valid, but only 0.99-9.0 are meaningful.
-- @tparam number a The spawned wave's heading relative to the players' spawn point (ignored when on GM positioning).
-- @tparam number d The spawned wave's distance from the players' spawn point (ignored when on GM positioning).
function addWave(list, kind, a, d)
    if addWavesToGMPosition then
        onGMClick(function(x,y) 
            onGMClick(nil)
            addWaveInner(list, kind, angleRotation(0, 0, x, y), distance(0, 0, x, y))
        end)
    else
        addWaveInner(list, kind, a, d)
    end
end

--- Add an enemy wave.
--
-- That is, create enemy wave and add all its ships to `list`.
--
-- @tparam table list A table containing enemy ship objects.
-- @tparam integer kind A number; at each integer, determines a different wave of ships to add
--  to the list. Any number is valid, but only 0.99-9.0 are meaningful.
-- @tparam number a The spawned wave's heading relative to the players' spawn point.
-- @tparam number d The spawned wave's distance from the players' spawn point.
function addWaveInner(list, kind, a, d)
    if kind < 1.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("Stalker Q7"):setRotation(a + 180):orderRoaming(), 0, 0, a, d))
    elseif kind < 2.0 then
        local leader = setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-1, 1), d + random(-100, 100))
        table.insert(list, leader)
        table.insert(list, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, -400, 0), 0, 0, a + random(-1, 1), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, 400, 0), 0, 0, a + random(-1, 1), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, -400, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, 400, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
    elseif kind < 3.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("Adder MK5"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("Adder MK5"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 4.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 5.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("Atlantis X23"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 6.0 then
        local leader = setCirclePos(CpuShip():setTemplate("Piranha F12"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100))
        table.insert(list, leader)
        table.insert(list, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, -1500, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180):orderFlyFormation(leader, 1500, 400), 0, 0, a + random(-1, 1), d + random(-100, 100)))
    elseif kind < 7.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("Phobos T3"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 8.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("Nirvana R5"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    elseif kind < 9.0 then
        table.insert(list, setCirclePos(CpuShip():setTemplate("MU52 Hornet"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    else
        table.insert(list, setCirclePos(CpuShip():setTemplate("Stalker R7"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
        table.insert(list, setCirclePos(CpuShip():setTemplate("Stalker R7"):setRotation(a + 180):orderRoaming(), 0, 0, a + random(-5, 5), d + random(-100, 100)))
    end
end

--- Returns a semi-random heading.
--
-- @tparam number cnt A counter, generally between 1 and the number of enemy groups.
-- @tparam number enemy_group_count A number of enemy groups, generally set by the scenario variation.
-- @treturn number a random angle (between 0-60 and 360+60)
function randomWaveAngle(cnt, enemy_group_count)
    return cnt * 360 / enemy_group_count + random(-60, 60)
end

--- Returns a semi-random distance.
--
-- `enemy_group_count` is multiplied by 3 u and increases the distance.
--
-- @tparam number enemy_group_count A number of enemy groups, generally set by the scenario variation.
-- @treturn number a distance
function randomWaveDistance(enemy_group_count)
    return random(35000, 40000 + enemy_group_count * 3000)
end

--- Initializes main GM Menu
function gmButtons()
    clearGMFunctions()
    addGMFunction("+Named Waves",namedWaves)
    addGMFunction("Random wave",function()
        addWave(
            enemyList,
            random(0,10),
            randomWaveAngle(math.random(20),math.random(20)),
            randomWaveDistance(math.random(20))
        )
    end)
    
    -- Let the GM spawn random reinforcements. Their distance from the
    -- players' spawn point is about half that of enemy waves.
    addGMFunction("Random friendly", function()
        local friendlyShip = {"Phobos T3", "MU52 Hornet", "Piranha F12"}
        local friendlyShipIndex = math.random(#friendlyShip)
        
        if addWavesToGMPosition then
            onGMClick(function(x,y) 
                onGMClick(nil)
                local a = angleRotation(0, 0, x, y)
                local d = distance(0, 0, x, y)
                table.insert(friendlyList, setCirclePos(CpuShip():setTemplate(friendlyShip[friendlyShipIndex]):setRotation(a):setFaction("Human Navy"):orderRoaming():setScanned(true), 0, 0, a + random(-5, 5), d + random(-100, 100)))
            end)
        else
            local a = randomWaveAngle(math.random(20), math.random(20))
            local d = random(15000, 20000 + math.random(20) * 1500)
            table.insert(friendlyList, setCirclePos(CpuShip():setTemplate(friendlyShip[friendlyShipIndex]):setRotation(a):setFaction("Human Navy"):orderRoaming():setScanned(true), 0, 0, a + random(-5, 5), d + random(-100, 100)))
        end
    end)
        
    addGMPositionToggle()
    
    -- End scenario with Human Navy (players) victorious.
    addGMFunction("Win",gmVictoryYesNo)
end

--- Shows Yes/No question dialogue GM submenu with question if Human Navy should win. 
function gmVictoryYesNo()
    clearGMFunctions()
    addGMFunction("Victory?", function() string.format("") end)
    addGMFunction("Yes", function() 
        victory("Human Navy")
        clearGMFunctions()
        addGMFunction("Players have won", function() string.format("") end)
        addGMFunction("Scenario ended", function() string.format("") end)
    end)
    addGMFunction("No", gmButtons)
end

--- Generate GM Toggle button for changing wave positioning variant. 
function addGMPositionToggle()
    local name = "Position: "

    if(addWavesToGMPosition) then
        name = name.."GM"
    else
        name = name.."Random"
    end

    addGMFunction(name, function()
        string.format("")   -- Provides global context for SeriousProton
        addWavesToGMPosition = not addWavesToGMPosition
        gmButtons()
    end)
end

--- Shows "Named waves" GM submenu (that allows spawning more waves).
function namedWaves()
    local wave_names = {
        [0] = "Strikeship",
        [1] = "Fighter",
        [2] = "Gunship",
        [4] = "Dreadnought",
        [5] = "Missile Cruiser",
        [6] = "Cruiser",
        [9] = "Adv. striker",
    }
    clearGMFunctions()
    addGMFunction("-From Named Waves",gmButtons)
    for index, name in pairs(wave_names) do
        addGMFunction(name,function()
            string.format("")
            addWave(enemyList,index,randomWaveAngle(math.random(20), math.random(20)), randomWaveDistance(math.random(5)))
        end)
    end
end

--- Initialize scenario.
function init()
    -- Spawn a player Atlantis.
    player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")

    enemyList = {}
    friendlyList = {}
    stationList = {}
    
    addWavesToGMPosition = false

    -- Randomly distribute 3 allied stations throughout the region.
    local n
    n = 0
    -- station_X.comms_data are not yet used, it is here for time when Defense Fleet functionality is implemented to comms_station.lua
    station_1 = SpaceStation():setTemplate("Small Station"):setRotation(random(0, 360)):setFaction("Human Navy")
    setCirclePos(station_1, 0, 0, n * 360 / 3 + random(-30, 30), random(10000, 22000))
    station_1.comms_data = {
        idle_defense_fleet = {
            DF1 = "MT52 Hornet",
            DF2 = "MT52 Hornet",
            DF3 = "MT52 Hornet",
        }
    }
    table.insert(stationList, station_1)
    table.insert(friendlyList, station_1)
    n = 1
    station_2 = SpaceStation():setTemplate("Medium Station"):setRotation(random(0, 360)):setFaction("Human Navy")
    setCirclePos(station_2, 0, 0, n * 360 / 3 + random(-30, 30), random(10000, 22000))
    station_2.comms_data = {
        idle_defense_fleet = {
            DF1 = "Adder MK5",
            DF2 = "Adder MK5",
            DF3 = "Adder MK5",
        }
    }
    table.insert(stationList, station_2)
    table.insert(friendlyList, station_2)
    n = 2
    station_3 = SpaceStation():setTemplate("Large Station"):setRotation(random(0, 360)):setFaction("Human Navy")
    setCirclePos(station_3, 0, 0, n * 360 / 3 + random(-30, 30), random(10000, 22000))
    station_3.comms_data = {
        idle_defense_fleet = {
            DF1 = "Phobos T3",
            DF2 = "Phobos T3",
            DF3 = "Phobos T3",
        }
    }
    table.insert(stationList, station_3)
    table.insert(friendlyList, station_3)

    -- Start the players with 300 reputation.
    friendlyList[1]:addReputationPoints(300.0)

    -- Randomly scatter nebulae near the players' spawn point.
    local cx, cy = friendlyList[1]:getPosition()
    setCirclePos(Nebula(), cx, cy, random(0, 360), 6000)

    for idx = 1, 5 do
        setCirclePos(Nebula(), 0, 0, random(0, 360), random(20000, 45000))
    end
    gmButtons()

    -- Set the number of enemy waves based on the scenario variation.
    local counts = {
        ["Extreme"] = 20,
        ["Hard"] = 8,
        -- default:
        ["None"] = 5,
        ["Easy"] = 3,
        ["Empty"] = 0
    }
    local enemy_group_count = counts[getScenarioVariation()]
    assert(enemy_group_count, "unknown variation " .. getScenarioVariation() .. " could not set enemy_group_count")

    -- If not in the Empty variation, spawn the corresponding number of random
    -- enemy waves at distributed random headings and semi-random distances
    -- relative to the players' spawn point.
    for cnt = 1, enemy_group_count do
        local a = randomWaveAngle(cnt, enemy_group_count)
        local d = randomWaveDistance(enemy_group_count)
        local kind = random(0, 10)
        addWaveInner(enemyList, kind, a, d)
    end

    -- Spawn 2-5 random asteroid belts.
    for i_ = 1, irandom(2, 5) do
        local a = random(0, 360)
        local a2 = random(0, 360)
        local d = random(3000, 40000)
        local x, y = vectorFromAngle(a, d)

        for j_ = 1, 50 do
            local dx1, dy1 = vectorFromAngle(a2, random(-1000, 1000))
            local dx2, dy2 = vectorFromAngle(a2 + 90, random(-20000, 20000))
            local posx = x + dx1 + dx2
            local posy = x + dy1 + dy2
            -- Avoid spawning asteroids within 1U of the player start position or
            -- 2U of any station.
            if math.abs(posx) > 1000 and math.abs(posy) > 1000 then
                for k_, station in ipairs(stationList) do
                    if distance(station, posx, posy) > 2000 then
                        Asteroid():setPosition(posx, posy):setSize(random(100, 500))
                    end
                end
            end
        end

        for j_ = 1, 100 do
            local dx1, dy1 = vectorFromAngle(a2, random(-1500, 1500))
            local dx2, dy2 = vectorFromAngle(a2 + 90, random(-20000, 20000))
            VisualAsteroid():setPosition(x + dx1 + dx2, y + dy1 + dy2)
        end
    end

    -- Spawn 0-3 random mine fields.
    for i_ = 1, irandom(0, 3) do
        local a = random(0, 360)
        local a2 = random(0, 360)
        local d = random(20000, 40000)
        local x, y = vectorFromAngle(a, d)

        for nx = -1, 1 do
            for ny = -5, 5 do
                if random(0, 100) < 90 then
                    local dx1, dy1 = vectorFromAngle(a2, (nx * 1000) + random(-100, 100))
                    local dx2, dy2 = vectorFromAngle(a2 + 90, (ny * 1000) + random(-100, 100))
                    Mine():setPosition(x + dx1 + dx2, y + dy1 + dy2)
                end
            end
        end
    end

    -- Spawn a random black hole.
    local x, y
    local spawn_hole = false

    -- Avoid spawning black holes too close to stations.
    while not spawn_hole do
        -- Generate random coordinates between 10U and 45U from the origin.
        local a = random(0, 360)
        local d = random(10000, 45000)
        x, y = vectorFromAngle(a, d)

        -- Check station distance from possible black hole locations.
        -- If it's too close to a station, generate new coordinates.
        for i_, station in ipairs(stationList) do
            if distance(station, x, y) > 5000 then
                spawn_hole = true
            else
                spawn_hole = false
            end
        end
    end

    BlackHole():setPosition(x, y)
    
    -- Spawn random neutral transports.
    Script():run("util_random_transports.lua")
end

--- Update.
--
-- @tparam number delta the time delta (in seconds)
function update(delta)
    -- Count all surviving enemies and allies.
    local enemy_count = 0
    for i_, enemy in ipairs(enemyList) do
        if enemy:isValid() then
            enemy_count = enemy_count + 1
        end
    end
    local friendly_count = 0
    for i_, friendly in ipairs(friendlyList) do
        if friendly:isValid() then
            friendly_count = friendly_count + 1
        end
    end

    -- If not playing the Empty variation, declare victory for the
    -- Humans (players) once all enemies are destroyed. Note that players can win
    -- even if they destroy the enemies by blowing themselves up.
    --
    -- In the Empty variation, the GM must use the Win button to declare
    -- a Human victory.
    if (enemy_count == 0 and getScenarioVariation() ~= "Empty") then
        victory("Human Navy")
    end

    -- If all allies are destroyed, the Humans (players) lose.
    if friendly_count == 0 then
        victory("Kraylor")
    else
        -- As the battle continues, award reputation based on
        -- the players' progress and number of surviving allies.
        for i_, friendly in ipairs(friendlyList) do
            if friendly:isValid() then
                friendly:addReputationPoints(delta * friendly_count * 0.1)
            end
        end
    end
end
