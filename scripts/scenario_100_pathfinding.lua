-- Name: Pathfinding test
-- This shows examples of pathfinding situations
-- Type: Development

--- Scenario
-- @script scenario_100_pathfinding

-- Utility function to place N asteroids along a line
function placeAsteroidsAlongLine(startX, startY, count, separationX, separationY)
    for i = 0, count - 1 do
        local x = startX + i * separationX
        local y = startY + i * separationY
        Asteroid():setPosition(x, y)
    end
end

function init()
    -- Moving straight towards each other
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(0,0):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(4000, 0)
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(4000,0):setRotation(180):setFaction('Independent'):orderFlyTowardsBlind(0, 0)

    -- Ship flying small asteroid wall
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(0,5000):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(4000, 5000)
    placeAsteroidsAlongLine(2000, 4800, 3, 0, 200)

    -- Ship flying small asteroid wall
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(0,10000):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(4000, 10000)
    placeAsteroidsAlongLine(2000, 9400, 7, 0, 200)

    -- Ship With U blocking
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(0,15000):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(4000, 15000)
    placeAsteroidsAlongLine(0, 14000, 5, 200, 0)
    placeAsteroidsAlongLine(0, 16000, 5, 200, 0)
    placeAsteroidsAlongLine(1000, 14000, 11, 0, 200)

    -- Ship With U blocking
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(0,20000):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(4000, 20000)
    placeAsteroidsAlongLine(-1000, 21000, 11, 200, 0)
    placeAsteroidsAlongLine(-1000, 19000, 11, 0, 200)
    placeAsteroidsAlongLine(1000, 19000, 11, 0, 200)

    -- Random asteroid field
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(10000,0):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(17000, 0)
    Asteroid():setPosition(15892, -2312):setRotation(288)
    Asteroid():setPosition(13699, -1727):setRotation(350)
    Asteroid():setPosition(12233, 1009):setRotation(356)
    Asteroid():setPosition(11028, 1009):setRotation(194)
    Asteroid():setPosition(10856, -1144):setRotation(239)
    Asteroid():setPosition(11674, 20):setRotation(102)
    Asteroid():setPosition(11588, -1703):setRotation(107)
    Asteroid():setPosition(12922, -1014):setRotation(219)
    Asteroid():setPosition(13991, 876):setRotation(183)
    Asteroid():setPosition(13051, -2607):setRotation(10)
    Asteroid():setPosition(14371, 28):setRotation(69)
    Asteroid():setPosition(13223, 1568):setRotation(248)
    Asteroid():setPosition(11501, 1870):setRotation(144)
    Asteroid():setPosition(14170, 2171):setRotation(312)
    Asteroid():setPosition(14488, -2166):setRotation(223)

    -- Ship stuck trying to reverse against station
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(10000,5000):setRotation(180):setFaction('Independent'):orderFlyTowardsBlind(14000, 5000)
    SpaceStation():setTemplate('Large Station'):setPosition(10700, 5000):setRotation(0):setFaction('Independent')
    
    -- Trying to dock to a station with asteroids around
    local station = SpaceStation():setTemplate('Large Station'):setPosition(15000, 10000):setRotation(0):setFaction('Independent')
    placeAsteroidsAlongLine(14200, 9000, 10, 200, 0)
    placeAsteroidsAlongLine(14200, 11000, 10, 200, 0)
    placeAsteroidsAlongLine(14000, 9000, 11, 0, 200)
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(10000,10000):setRotation(0):setFaction('Independent'):orderDock(station)
    
    -- Diagonal lines
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(10000,15000):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(17000, 15000)
    placeAsteroidsAlongLine(12000, 14000, 10, 200, 200)
    CpuShip():setTemplate('Fuel Freighter 1'):setPosition(10000,20000):setRotation(0):setFaction('Independent'):orderFlyTowardsBlind(17000, 20000)
    placeAsteroidsAlongLine(14000, 19000, 10, -200, 200)
end

function update(delta)
    -- No victory condition
end
