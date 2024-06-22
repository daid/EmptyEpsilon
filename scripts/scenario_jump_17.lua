-- Name: Jump 17
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Planet LA05-WE50

require("utils.lua")
require("utils_odysseus.lua")
setScenarioChange(18)

function init()
	local sx = -5000
	local sy = -4500
	setSpawnFleetButton(5, "A", sx, sy, 2, 3, true, "idle", 0, 1, 0, 3)
	setSpawnFleetButton(5, "B", sx, sy, 2, 3, true, "idle", 0, 1, 0, 3)

	
	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - XL"), function() spawnwave(5) end)
	addGMFunction(_("Enemy", "OC - Machine - Boarding"), function() spawnwave(1, "boarding") end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)
	addGMFunction("Destroy ESS Valkyrie", confirm_valkyrie)

  	-- Generate scenario map
      generateSpace(sx, sy)


	  planet = setUpPlanet("P-LA05-WE50", 105000, 25000)
	  

	
end

