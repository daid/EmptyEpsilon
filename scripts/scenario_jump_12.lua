-- Name: Jump 12
-- Type: Mission

function init()

      odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0):setCanBeDestroyed(false)
	 
-- Launched buttons
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
	

	for asteroid_counter=1,50 do
		Asteroid():setPosition(random(-75000, 75000), random(-75000, 75000))
	end


	addGMFunction("Enemy north", wave_north)
	addGMFunction("Enemy east", wave_east)
	addGMFunction("Enemy south", wave_south)
	addGMFunction("Enemy west", wave_west)

end

function wave_north()
	
		x, y = odysseus:getPosition()
		
	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, 50000), y + random(-70000,-60000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, 50000), y + random(-70000, -60000)):orderRoaming(x, y)
        end
		
	end


	
function wave_east()
	
		x, y = odysseus:getPosition()
		
	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(60000, 70000), y + random(-50000, 50000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(60000, 70000), y + random(-50000, 50000)):orderRoaming(x, y)
        end
		
	end
	
	function wave_south()
	
		x, y = odysseus:getPosition()
		
	-- Fighters 10
	-- Cruisers 5
		
		
				for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, 50000), y + random(60000,70000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, 50000), y + random(60000,70000)):orderRoaming(x, y)
        end

		
	end
	
		function wave_west()
	
		x, y = odysseus:getPosition()
		
	-- Fighters 10
	-- Cruisers 5
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, -60000), y + random(-50000, 50000)):orderRoaming(x, y)
        end

		for n=1,5 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-70000, -60000), y + random(-50000, 50000)):orderRoaming(x, y)
        end		
	end
	
	

function launch_essody18()
	odyfig18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig18:setCallSign("ESSODY18"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY18")
	
	odyfig18:addCustomButton("Helms", "Dock ESSODY18", "Dock ESSODY18", dock_essody18)
end	

function dock_essody18()
	odyfig18:destroy()
		
	odysseus:removeCustom("Dock ESSODY18")
	
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
end	



function launch_essody23()	
	odyfig23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig23:setCallSign("ESSODY23"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY23")
	
	odyfig23:addCustomButton("Helms", "Dock ESSODY23", "Dock ESSODY23", dock_essody23)
end

function dock_essody23()
	odyfig23:destroy()
		
	odysseus:removeCustom("Dock ESSODY23")
	
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
end	



function launch_essody36()
	odyfig36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig36:setCallSign("ESSODY36"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY36")
	odyfig36:addCustomButton("Helms", "Dock ESSODY36", "Dock ESSODY36", dock_essody36)
	
end

function dock_essody36()
	odyfig36:destroy()
		
	odysseus:removeCustom("Dock ESSODY36")
	
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
end	
