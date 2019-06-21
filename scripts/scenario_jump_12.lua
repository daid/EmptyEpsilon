-- Name: Jump 12
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids. 

require("utils.lua")
require("utils_odysseus.lua")

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
	
	addGMFunction("Starcaller Fixed", launch_starcaller_button)

	addGMFunction("Change scenario", changeScenarioPrep)

end

function changeScenarioPrep()

	removeGMFunction("Change scenario")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)
	
end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario", changeScenarioPrep)

end

function changeScenario()

	setScenario("scenario_jump_13.lua", "Null")
	
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
	
	

function launch_starcaller_button()
	addGMFunction("Cancel Starcaller", launch_starcaller_button_cancel)
	addGMFunction("Confirm Starcaller", launch_starcaller_button_confirm)
	removeGMFunction("Starcaller Fixed")
end

function launch_starcaller_button_cancel()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	addGMFunction("Starcaller Fixed", launch_starcaller_button)
end

function launch_starcaller_button_confirm()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller)
end

-- Player launched functions for fighters and starcaller
function launch_starcaller()

x, y = odysseus:getPosition()


	starcaller = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Scoutship S392"):setPosition(x, y + 400)
	starcaller:setCallSign("ESS Starcaller"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch Starcaller")
	
	starcaller:addCustomButton("Helms", "Dock to Odysseus", "Dock to Odysseus", dock_starcaller)

end

function dock_starcaller()
	x, y = starcaller:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		starcaller:destroy()			
		odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller)
	else
		starcaller:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end
end	


function launch_essody18()

	x, y = odysseus:getPosition()

	essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 300)
	essody18:setCallSign("ESSODY18"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY18")
	
	essody18:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody18)

end	

function dock_essody18()

	x, y = essody18:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		essody18:destroy()
			
			odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody36)
	else
		essody18:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end


end	



function launch_essody23()	

x, y = odysseus:getPosition()


	essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 200)
	essody23:setCallSign("ESSODY23"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY23")
	
	essody23:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody23)
end

function dock_essody23()

	x, y = essody23:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		essody23:destroy()
			
			odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	else
		essody23:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end

end	



function launch_essody36()

x, y = odysseus:getPosition()

	essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 100)
	essody36:setCallSign("ESSODY36"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY36")
	essody36:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody36)
	
end

function dock_essody36()

	x, y = essody36:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		essody36:destroy()
			
			odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
	else
			essody36:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end

			
end	