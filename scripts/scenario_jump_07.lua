-- Name: Jump 07
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Planet CA95-LN71
require("utils.lua")
require("utils_odysseus.lua")



function init()
	
	local ox =70000
	local oy = -15000
	odysseus:setPosition(ox, oy)
	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific
	addGMFunction(_("buttonGM", "Coordinates C8-80"), function() 
		setUpPlanet("P-PU80-GL38", ox+85000, oy+25000) 
		removeGMFunction("Coordinates C8-80")
		removeGMFunction("Coordinates something else")
	end)
	addGMFunction(_("buttonGM", "Coordinates something else"), function() 
		removeGMFunction("Coordinates C8-80")
		removeGMFunction("Coordinates something else")
		end)

	local sx = 5000
	local sy = 4500
	setSpawnFleetButton("Friendly 2", 2, "A", sx, sy, 2, 1, true, "formation", 0, 3, 0, 2)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)

   
	setScenarioChange('Change scenario - 08', "scenario_jump_08.lua")

	-- Generate scenario map
	generateSpace(sx, sy)

end
