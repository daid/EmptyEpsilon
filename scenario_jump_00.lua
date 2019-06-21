-- Name: Jump 00
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids. 

require("utils.lua")
require("utils_odysseus.lua")


function init()

	essody18_dockable = false
	essody23_dockable = false
	essody36_dockable = false
	starcalle_dockable = false
	
    odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0):setCanBeDestroyed(false)
	
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)

	

        for n=1,100 do

			Asteroid():setPosition(random(-100000, 100000), random(-100000, 100000)):setSize(random(100, 500))

			VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))

        end
		
		for n=1,10 do

			Nebula():setPosition(random(-100000, 100000), random(-100000, 100000))

        end

		addGMFunction("Enemy north", wavenorth)
	addGMFunction("Enemy east", waveeast)
	addGMFunction("Enemy south", wavesouth)
	addGMFunction("Enemy west", wavewest)
	
	addGMFunction("Starcaller Fixed", launch_starcaller_button)
	addGMFunction("Change scenario", changeScenarioPrep)
	


end

function wavenorth()
	
	x, y = odysseus:getPosition()
	wave_north(x, y, odysseus)	
	
		
end

function waveeast()
	
	x, y = odysseus:getPosition()
	wave_east(x, y, odysseus)		
		
end

function wavesouth()
	
	x, y = odysseus:getPosition()
	wave_south(x, y, odysseus)			
		
end

function wavewest()
	
	x, y = odysseus:getPosition()
	wave_west(x, y, odysseus)		
		
end

-- Change scenario

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
	setScenario("scenario_jump_01.lua", "Null")
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


function update(delta)


end
