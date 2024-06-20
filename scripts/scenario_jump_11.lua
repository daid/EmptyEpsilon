-- Name: Jump 11
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Moon.

require("utils.lua")
require("utils_odysseus.lua")



function init()
	local ox =28000
	local oy =-30000
	odysseus:setPosition(ox, oy)

	local sx = 5000
	local sy = 4500
	setSpawnFleetButton("Friendly 3", 3, "A", sx, sy, 2, 1, true, "formation", 0, 3, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)


   
	setScenarioChange('Change scenario - 12', "scenario_jump_12.lua")

	generateSpace(sx, sy)

end
