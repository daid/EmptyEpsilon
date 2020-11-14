-- Name: Surrounded
-- Description: You are surrounded by asteroids, enemies and mines.
---
--- Spawn the player ship(s) you want. The strength of the enemy is independent of their number and type.
--- (The scenario can be won with a single Atlantis.)
-- Type: Basic

--- Scenario
-- @script scenario_05_surrounded

function setCirclePos(obj, angle, distance)
    obj:setPosition(math.sin(angle / 180 * math.pi) * distance, -math.cos(angle / 180 * math.pi) * distance)
end

--- Initialize scenario.
function init()
    -- a station near the center
    -- (Currently, it is not necessary to defend it.)
    SpaceStation():setTemplate("Small Station"):setPosition(0, -500):setRotation(random(0, 360)):setFaction("Independent")

    -- several single Phobos
    for _ = 1, 5 do
        local ship = CpuShip():setTemplate("Phobos T3"):orderRoaming()
        setCirclePos(ship, random(0, 360), random(7000, 10000))
    end

    -- several single Piranha
    for _ = 1, 2 do
        local ship = CpuShip():setTemplate("Piranha F12"):orderRoaming()
        setCirclePos(ship, random(0, 360), random(7000, 10000))
    end

    -- Atlantis with wingmen
    do
        local a = random(0, 360)
        local d = 9000
        local ship = CpuShip():setTemplate("Atlantis X23"):setRotation(a + 180):orderRoaming()
        setCirclePos(ship, a, d)

        do
            local wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180)
            setCirclePos(wingman, a - 5, d + 100)
            wingman:orderFlyFormation(ship, 500, 100)
        end
        do
            local wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180)
            setCirclePos(wingman, a + 5, d + 100)
            wingman:orderFlyFormation(ship, -500, 100)
        end
        do
            local wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180)
            setCirclePos(wingman, a + random(-5, 5), d - 500)
            wingman:orderFlyFormation(ship, 0, 600)
        end
    end

    -- random mines
    for _ = 1, 10 do
        setCirclePos(Mine(), random(0, 360), random(10000, 20000))
    end

    -- random asteroids
    for _ = 1, 300 do
        setCirclePos(Asteroid(), random(0, 360), random(10000, 20000))
    end
end

--- Update scenario.
function update(delta)
    -- No victory condition
end
