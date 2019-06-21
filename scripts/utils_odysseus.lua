-- Name: Odysseus utils


function wave_north(x, y, ship)
		
	ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")
		
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, 70000), y + random(-80000,-60000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, 70000), y + random(-80000, -60000)):orderRoaming(x, y)
        end
		
	end


	
function wave_east(x, y, ship)
		
	ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")
		
	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(60000, 80000), y + random(-70000, 70000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(60000, 80000), y + random(-70000, 70000)):orderRoaming(x, y)
        end
		
	end
	
	function wave_south(x, y, ship)
			
			ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")
	-- Fighters 10
	-- Cruisers 5
		
		
				for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, 70000), y + random(60000,80000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, 70000), y + random(60000,80000)):orderRoaming(x, y)
        end

		
	end
	
		function wave_west(x, y, ship)
			
		ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")
	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-80000, -60000), y + random(-70000, 70000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-80000, -60000), y + random(-70000, 70000)):orderRoaming(x, y)
        end		
	end
	
	
	function aurora_fighter(aurora)
		
		 x, y = aurora:getPosition()

			for n=1,69 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
			
		removeGMFunction("Aurora Fighters")
	end
	
