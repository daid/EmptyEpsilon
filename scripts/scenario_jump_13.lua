-- Name: Jump 13
-- Type: Mission

function init()

    odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)
	

-- Station
 planet1 = Planet():setPosition(-50000, 50000):setPlanetSurfaceTexture("planets/SI14-UX98.png"):setDistanceFromMovementPlane(2000):setPlanetRadius(45000)
 
 		for n=1,3000 do
			Mine():setPosition(random(20000, 47000),random(-100000, 100000))
        end


end
