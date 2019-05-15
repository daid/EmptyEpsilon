-- Name: Jump 14
-- Type: Mission

function init()

      odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)
	
Planet():setPosition(-10000, -10000):setPlanetSurfaceTexture("planets/asteroid.png"):setDistanceFromMovementPlane(-2000):setPlanetRadius(5000)


end
