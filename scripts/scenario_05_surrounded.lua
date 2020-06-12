-- Name: Surrounded
-- Description: You are surrounded by astroids, enemies and mines.
---
--- Spawn the player ship(s) you want. The strength of the enemy is independent of their number and type.
--- (The scenario can be won with a single Atlantis.)
-- Type: Basic

function setCirclePos(obj, angle, distance)
    obj:setPosition(math.sin(angle / 180 * math.pi) * distance, -math.cos(angle / 180 * math.pi) * distance)
end

function init()
    SpaceStation():setTemplate("Small Station"):setPosition(0, -500):setRotation(random(0, 360)):setFaction("Independent")

    for n=1,5 do
        ship = CpuShip():setTemplate("Phobos T3"):orderRoaming()
        setCirclePos(ship, random(0, 360), random(7000, 10000))
    end
    for n=1,2 do
        ship = CpuShip():setTemplate("Piranha F12"):orderRoaming()
        setCirclePos(ship, random(0, 360), random(7000, 10000))
    end

    a = random(0, 360)
    d = 9000
    ship = CpuShip():setTemplate("Atlantis X23"):setRotation(a + 180):orderRoaming()
    setCirclePos(ship, a, d)

    wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180)
    setCirclePos(wingman, a - 5, d + 100)
    wingman:orderFlyFormation(ship, 500, 100)

    wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180)
    setCirclePos(wingman, a + 5, d + 100)
    wingman:orderFlyFormation(ship, -500, 100)

    wingman = CpuShip():setTemplate("MT52 Hornet"):setRotation(a + 180)
    setCirclePos(wingman, a + random(-5, 5), d - 500)
    wingman:orderFlyFormation(ship, 0, 600)


    for n=1,10 do
        setCirclePos(Mine(), random(0, 360), random(10000, 20000))
    end

    for n=1, 300 do
        setCirclePos(Asteroid(), random(0, 360), random(10000, 20000))
    end
end

function update(delta)
    --No victory condition
end
