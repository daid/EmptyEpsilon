-- Name: Off-game training
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Basic

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
	
	odysseus:addCustomButton("Relay", "Reset scenario", "Reset scenario", resetScen)




    Nebula():setPosition(13657, 5143)
    Nebula():setPosition(15088, 9924)
    CpuShip():setFaction("Corporate owned"):setTemplate("Medium station"):setCallSign("VS2"):setPosition(23148, -5093):orderRoaming()
    CpuShip():setFaction("Corporate owned"):setTemplate("Cargoship T842"):setCallSign("NC3"):setPosition(15926, -7037):setWeaponStorage("Homing", 4)
    Asteroid():setPosition(6574, -5741)
    Asteroid():setPosition(6667, 6019)
    Asteroid():setPosition(8704, -3889)
    Asteroid():setPosition(1852, -3148)
    Asteroid():setPosition(8333, 2778)
    Asteroid():setPosition(3981, 11481)
    Asteroid():setPosition(-6481, 10648)
    Asteroid():setPosition(12870, 15278)
    Asteroid():setPosition(15000, 9815)
    Asteroid():setPosition(17037, -5833)
    Asteroid():setPosition(15648, 4074)
    Asteroid():setPosition(26204, 5000)
    Asteroid():setPosition(12593, -9444)
    Asteroid():setPosition(5278, -18889)
    Asteroid():setPosition(-3241, -12963)
    Asteroid():setPosition(4352, -11389)
    Asteroid():setPosition(19352, -14630)
    Asteroid():setPosition(17500, -27315)
    Asteroid():setPosition(-4259, 17315)
    Asteroid():setPosition(9074, 18796)
    Asteroid():setPosition(27593, -28796)
    CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setCallSign("CV5"):setPosition(20370, 8845)
    CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setCallSign("CSS6"):setPosition(20056, 14553)

	
	addGMFunction("Enemy north", wavenorth)
	addGMFunction("Enemy east", waveeast)
	addGMFunction("Enemy south", wavesouth)
	addGMFunction("Enemy west", wavewest)
	
	addGMFunction("Starcaller Fixed", launch_starcaller_button)
	
	addGMFunction("Reset scenario", resetScen)
	

end

function resetScen()

    --Clean up the current play field. Find all objects and destroy everything that is not a player.
    -- If it is a player, position him in the center of the scenario.
    for _, obj in ipairs(getAllObjects()) do
        if obj.typeName == "PlayerSpaceship" then
            obj:setPosition(0, 0)
        else
            obj:destroy()
        end
	end

    Nebula():setPosition(13657, 5143)
    Nebula():setPosition(15088, 9924)
    CpuShip():setFaction("Corporate owned"):setTemplate("Medium station"):setCallSign("VS2"):setPosition(23148, -5093):orderRoaming()
    CpuShip():setFaction("Corporate owned"):setTemplate("Cargoship T842"):setCallSign("NC3"):setPosition(15926, -7037):setWeaponStorage("Homing", 4)
    Asteroid():setPosition(6574, -5741)
    Asteroid():setPosition(6667, 6019)
    Asteroid():setPosition(8704, -3889)
    Asteroid():setPosition(1852, -3148)
    Asteroid():setPosition(8333, 2778)
    Asteroid():setPosition(3981, 11481)
    Asteroid():setPosition(-6481, 10648)
    Asteroid():setPosition(12870, 15278)
    Asteroid():setPosition(15000, 9815)
    Asteroid():setPosition(17037, -5833)
    Asteroid():setPosition(15648, 4074)
    Asteroid():setPosition(26204, 5000)
    Asteroid():setPosition(12593, -9444)
    Asteroid():setPosition(5278, -18889)
    Asteroid():setPosition(-3241, -12963)
    Asteroid():setPosition(4352, -11389)
    Asteroid():setPosition(19352, -14630)
    Asteroid():setPosition(17500, -27315)
    Asteroid():setPosition(-4259, 17315)
    Asteroid():setPosition(9074, 18796)
    Asteroid():setPosition(27593, -28796)
    CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setCallSign("CV5"):setPosition(20370, 8845)
    CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setCallSign("CSS6"):setPosition(20056, 14553)


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
