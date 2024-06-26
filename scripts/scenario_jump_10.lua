-- Name: Jump 10
-- Type: Odysseus
-- Description: Planet at east

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: Planet at east \nNo setup actions."
setScenarioChange(11)

function init()
	local ox =-33000
	local oy =-5000
	odysseus:setPosition(ox, oy)

	local sx = 5000
	local sy = -8500
	setSpawnFleetButton(2, nil, sx, sy, 2, 2, true, "formation", 0, 2, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - M"), function() spawnwave(3) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)

 
	-- Generate scenario map
	generateSpace(sx, sy)

	planet = setUpPlanet("P-OC46-DA97", ox+85000, oy+25000)


end
