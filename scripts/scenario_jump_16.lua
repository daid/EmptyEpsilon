-- Name: Jump 16
-- Type: Odysseus
-- Description: No objects of interest.

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: No objects of interest. \nSetup actions: Choose right fleet to spawn."

setScenarioChange(17)

function init()
	local sx = 25000
	local sy = -4500
	setSpawnFleetButton(4, "A", sx, sy, 2, 1, true, "formation", 0, 1, 0, 1)
	setSpawnFleetButton(4, "B", sx, sy, 2, 1, true, "formation", 0, 1, 0, 1)

	generateSpace(sx, sy)
	
	addGMFunction(_("Enemy", "OC - Machine - XL"), function() spawnwave(5) end)

end
