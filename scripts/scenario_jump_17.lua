-- Name: Jump 17
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Planet LA05-WE50

require("utils.lua")
require("utils_odysseus.lua")

function init()
	local sx = 5000
	local sy = -4500
	setSpawnFleetButton("Friendly 5 A", 5, "A", sx, sy, 2, 3, true, "idle", 0, 1, 0, 3)
	setSpawnFleetButton("Friendly 5 B - No Karma", 5, "B", sx, sy, 2, 3, true, "idle", 0, 1, 0, 3)

	
	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - XL"), function() spawnwave(5) end)

 
  setScenarioChange('Change scenario - 18', "scenario_jump_18.lua")

  	-- Generate scenario map
      generateSpace(sx, sy)


	  planet = setUpPlanet("P-LA05-WE50", 105000, 25000)
	  

	
end

