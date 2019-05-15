-- Name: Jump 01
-- Type: Mission

function init()

    odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)

-- Station
	station = SpaceStation():setFaction("Civilians"):setTemplate("Medium station"):setCallSign("Solaris 7"):setPosition(20000, 20000)

	
	for asteroid_counter=1,50 do
		Asteroid():setPosition(random(-200000, 200000), random(-200000, 200000))
	end


end
