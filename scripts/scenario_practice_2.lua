-- Name: Practice 1
-- Type: Odysseus practice mission - 5 fighter enemies

function init()

     odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)
	
Planet():setPosition(-40000, -40000):setPlanetSurfaceTexture("planets/gas-1.png"):setDistanceFromMovementPlane(-2000):setPlanetRadius(30000)

	x, y = odysseus:getPosition()
		for n=1, 5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(random(10000, 20000), random(10000, 20000)):orderRoaming(x, y)
        end
		

end
