-- Name: Odysseus utils

function wave_north(x, y, ship)

	ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")

		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, 70000), y + random(-105000,-100000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-70000, 70000), y + random(-105000, -100000)):orderRoaming(x, y)
        end

	end



function wave_east(x, y, ship)

	ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")

	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(100000, 105000), y + random(-70000, 70000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(100000, 105000), y + random(-70000, 70000)):orderRoaming(x, y)
        end

	end

	function wave_south(x, y, ship)

			ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")
	-- Fighters 10
	-- Cruisers 5


				for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, 70000), y + random(100000,105000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-70000, 70000), y + random(100000,105000)):orderRoaming(x, y)
        end


	end

		function wave_west(x, y, ship)

		ship:addToShipLog("EVA long range scanning results. Jump to sector detected.", "Blue")
	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-105000, -100000), y + random(-70000, 70000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-105000, -100000), y + random(-70000, 70000)):orderRoaming(x, y)
        end
	end


	-- Ship launchers
