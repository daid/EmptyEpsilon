-- Name: Jump 10
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet.

require("utils.lua")
require("utils_odysseus.lua")


function init()
	local ox =-33000
	local oy =-5000
	odysseus:setPosition(ox, oy)

	local sx = 5000
	local sy = -4500
	setSpawnFleetButton("Friendly 2", 2, "A", sx, sy, 2, 2, true, "formation", 0, 2, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)

      
	setScenarioChange('Change scenario - 11', "scenario_jump_11.lua")

	-- Generate scenario map
	generateSpace(sx, sy)

	planet = setUpPlanet("P-OC46-DA97", ox+105000, oy+25000)


end
