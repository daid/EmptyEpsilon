-- Name: Jump 02
-- Type: Odysseus
-- Description: Map: - Enemies: Backup enemy fleet Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")

function init()
	-- Add GM common functions - Order of the buttons: Fleet, enemies, Scenario change, scenario specific
	addGMFunction(_("buttonGM", "Enemy - Small - Backup"), function() spawnwave(2) end)
  
	setScenarioChange('Change scenario - 03', "scenario_jump_03.lua")

	-- Generate scenario map
	addGMFunction(_("buttonGM", "Coordinates D3-117"), function() 
		setUpPlanet("Sronsh", -85000, -25000) 
		removeGMFunction("Coordinates D3-117")
		removeGMFunction("Coordinates D3-101")
	end)

	addGMFunction(_("buttonGM", "Coordinates D3-101"), function()
		removeGMFunction("Coordinates D3-117")
		removeGMFunction("Coordinates D3-101")
	end)

	generateSpace(fx, fy)


end


