-- Name: Jump 07
-- Type: Odysseus
-- Description: No objects of interest.

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: No objects of interest. \nNo setup actions."
setScenarioChange(8)


function init()
	
	local ox =20000
	local oy = -15000
	odysseus:setPosition(ox, oy)
	addGMFunction(_("buttonGM", "Coordinates C8-80"), function() 
		setUpPlanet("P-PU80-GL38", ox+65000, oy+25000) 
		removeGMFunction("Coordinates C8-80")
		removeGMFunction("Other coordinates")
	end)
	addGMFunction(_("buttonGM", "Other coordinates"), function() 
		removeGMFunction("Coordinates C8-80")
		removeGMFunction("Other coordinates")
		end)

	local sx = -5000
	local sy = 4500
	setSpawnFleetButton(2, nil, sx, sy, 2, 1, true, "formation", 0, 3, 0, 2)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - S"), function() spawnwave(2) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)

   
	-- Generate scenario map
	generateSpace(sx, sy)

end
