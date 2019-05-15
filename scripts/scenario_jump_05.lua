-- Name: Jump 05
-- Type: Mission

function init()

    odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)

-- Station
 planet1 = Planet():setPosition(-50000, 50000):setPlanetSurfaceTexture("planets/TE49-HE75.png"):setPlanetRadius(40000)
 

end
