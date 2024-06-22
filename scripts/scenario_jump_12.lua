-- Name: Jump 12
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids.

require("utils.lua")
require("utils_odysseus.lua")
setScenarioChange(13)

function init()
	local ox =-30000
	local oy = 20000
	odysseus:setPosition(ox, oy)

	local sx = -5000
	local sy = 6500
	setSpawnFleetButton(3, nil, sx, sy, 2, 1, true, "formation", 0, 3, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - Moon SX"), function() spawnwave(1, "target", ox+2000, oy-15000) end)
	addGMFunction(_("Enemy", "OC - Machine - SX"), function() spawnwave(1) end)

	addGMFunction(_("Enemy", "OC - Machine - XL"), function() spawnwave(5) end)

	-- Generate scenario map

	generateSpace(sx, sy)

	planet = setUpPlanet("M12-PI87", ox+2000, oy-15000, 0.99)
	planet = setUpPlanet("P-OC04-YU08", ox+20000, oy-53000, 1.4)

	addGMFunction("Destroy OSS Karma", confirm_karma)


end
