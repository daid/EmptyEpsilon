-- Name: Empty space
-- Description: Empty scenario, no enemies, no friendlies, only a lonely station. Can be used by a GM player to setup a scenario in the GM screen.

function init()
	--SpaceStation():setPosition(1000, 1000):setTemplate('Small Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--SpaceStation():setPosition(-1000, 1000):setTemplate('Medium Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--SpaceStation():setPosition(1000, -1000):setTemplate('Large Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--SpaceStation():setPosition(-1000, -1000):setTemplate('Huge Station'):setFaction("Human Navy"):setRotation(random(0, 360))
	--PlayerSpaceship():setFaction("Human Navy"):setShipTemplate("Player Cruiser"):setRotation(200)
	--Nebula():setPosition(-5000, 0)
	CpuShip():setPosition(4000, 0):setShipTemplate("Missile Cruiser"):setRotation(180):orderRoaming()
	CpuShip():setPosition(0, 3000):setFaction("Human Navy"):setShipTemplate("Cruiser"):setRotation(-90):orderFlyTowardsBlind(0, -5000)
end

function update(delta)
	--No victory condition
end
