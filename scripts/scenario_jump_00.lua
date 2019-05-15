-- Name: Jump 00
-- Type: Mission

function init()

        odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)
	
	odyfig18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig18:setCallSign("ESSODY18")
	odyfig18:commandDock(odysseus)
	
	odyfig23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig23:setCallSign("ESSODY23")
	odyfig23:commandDock(odysseus)

	odyfig36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig36:setCallSign("ESSODY36")
	odyfig36:commandDock(odysseus)	
	
	for asteroid_counter=1,50 do
		Asteroid():setPosition(random(-200000, 200000), random(-200000, 200000))
	end


end
