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

 addGMFunction("Enemy Fleet", function()
	
	x, y = odysseus:getPosition()
	
	-- Fighters: 100
	-- Crusers: 40
		for n=1,12 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, -20000), y + random(-50000,-20000)):orderRoaming(x, y)
        end
		
		
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-50000, -20000), y + random(-50000,-20000)):orderRoaming(x, y)

		for n=1,4 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-30000, -10000), y + random(-30000,-15000)):orderRoaming(x, y)
        end
   
	
	removeGMFunction("Enemy Fleet")
	end)
end
