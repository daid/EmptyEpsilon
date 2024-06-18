-- Name: Jump 02
-- Type: Odysseus
-- Description: Map: - Enemies: Backup enemy fleet Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")

function init()
	
	local ox =-10000
	local oy = 15000
	odysseus:setPosition(ox, oy)

	-- Add GM common functions - Order of the buttons: Fleet, enemies, Scenario change, scenario specific  
	setScenarioChange('Change scenario - 03', "scenario_jump_03.lua")

	-- Generate scenario map
	addGMFunction(_("buttonGM", "Coordinates D3-101"), function()
		removeGMFunction("Coordinates D3-117")
		removeGMFunction("Coordinates D3-101")
	end)
		addGMFunction(_("buttonGM", "Coordinates D3-117"), function() 
		setUpPlanet("Sronsh", ox-85000, oy-25000) 
		removeGMFunction("Coordinates D3-117")
		removeGMFunction("Coordinates D3-101")
	end)


	generateSpace(ox, oy)


end


