-- Name: Practice 1
-- Type: Odysseus practice mission - No enemies

function init()

     odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)
	
Planet():setPosition(-40000, -40000):setPlanetSurfaceTexture("planets/gas-1.png"):setDistanceFromMovementPlane(-2000):setPlanetRadius(30000)



end
