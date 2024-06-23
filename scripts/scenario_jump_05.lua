-- Name: Jump 05
-- Type: Odysseus
-- Description: No objects of interest.

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: No objects of interest. \nNo setup actions."
setScenarioChange(6)

function init()
	
	local ox =-30000
	local oy = 20000
	odysseus:setPosition(ox, oy)
	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific

	local sx = -1000
	local sy = 2000
	setSpawnFleetButton(2, nil, sx, sy, 2, 3, true, "formation", 0, 1, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - XS"), function() spawnwave(1) end)
	addGMFunction(_("Enemy", "OC - Machine - S"), function() spawnwave(2) end)

	-- Generate scenario map
	generateSpace(sx, sy)

end
