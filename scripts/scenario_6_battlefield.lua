-- Name: Battlefield
-- Description: The Humans are fighting off the Exuari who are on all out war on a neutral station.

function setCirclePos(obj, x, y, angle, distance)
	obj:setPosition(x + math.sin(angle / 180 * math.pi) * distance, y + -math.cos(angle / 180 * math.pi) * distance)
end

function init()
    neutral_station = SpaceStation():setPosition(0, -15000):setRotation(random(0, 360)):setFaction("Independent")
	friendly_station = SpaceStation():setPosition(-10000, -25000):setRotation(random(0, 360)):setFaction("Human Navy")
    --Put some mines around the friendly station.
    for n=1,30 do
        setCirclePos(Mine(), -10000, -25000, n * 10, 5000)
    end
	--Put some neutral tugs around the neutral station, just as cannon fodder.
    for n=1,5 do
        setCirclePos(CpuShip():setShipTemplate("Tug"):setFaction("Independent"):setScanned(true), 0, -15000, random(0, 360), random(1000, 5000))
    end
	
	for n=1,20 do
		CpuShip():setShipTemplate("Fighter"):setPosition(random(-10000, 10000), random(0, 3000)):setFaction("Human Navy"):orderRoaming():setScanned(true)
	end
	for n=1,10 do
		CpuShip():setShipTemplate("Cruiser"):setPosition(random(-10000, 10000), random(0, 2000)):setFaction("Human Navy"):orderRoaming():setScanned(true)
	end

	for n=1,20 do
		CpuShip():setShipTemplate("Fighter"):setPosition(random(-13000, 13000), random(5000, 8000)):setFaction("Exuari"):orderRoaming():setScanned(true)
	end
	for n=1,10 do
		CpuShip():setShipTemplate("Cruiser"):setPosition(random(-13000, 13000), random(5000, 8000)):setFaction("Exuari"):orderRoaming()
	end
	for n=1,3 do
		CpuShip():setShipTemplate("Adv. Gunship"):setPosition(random(-13000, 13000), 5000):setFaction("Exuari"):orderRoaming()
	end
	CpuShip():setShipTemplate("Dreadnought"):setPosition(0, 7000):setFaction("Exuari"):orderRoaming():setRotation(0)
end

function update(delta)
	--No victory condition
end
