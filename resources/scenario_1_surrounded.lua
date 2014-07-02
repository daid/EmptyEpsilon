-- Name: Surrounded
-- Description: You are surrounded by astroids, enemies and mines.

function setCirclePos(obj, angle, distance)
	obj:setPosition(math.sin(angle / 180 * math.pi) * distance, -math.cos(angle / 180 * math.pi) * distance)
end

function init()
    SpaceStation():setPosition(0, -500):setRotation(random(0, 360)):setFaction(0)
    
    for n=1,5 do
        ship = CpuShip():setShipTemplate("Fighter"):orderRoaming()
		setCirclePos(ship, random(0, 360), random(7000, 10000))
	end
    for n=1,3 do
        ship = CpuShip():setShipTemplate("Missile Cruiser"):orderRoaming()
		setCirclePos(ship, random(0, 360), random(7000, 10000))
	end
	
	a = 0 --random(0, 360)
	d = 9000
    for n=1,3 do
		ship = CpuShip():setShipTemplate("Cruiser"):orderRoaming()
		setCirclePos(ship, a + random(-5, 5), d + random(-100, 100))
	end
	ship = CpuShip():setShipTemplate("Dreadnought"):orderRoaming()
	setCirclePos(ship, a + random(-5, 5), d + random(-100, 100))
	
	
    for n=1,100 do
        setCirclePos(Mine(), random(0, 360), random(10000, 20000))
    end
    
    for n=1, 1000 do
        setCirclePos(Asteroid(), random(0, 360), random(10000, 20000))
    end
end

function update(delta)
	--No victory condition
end
