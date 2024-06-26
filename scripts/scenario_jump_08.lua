-- Name: Jump 08
-- Type: Odysseus
-- Description: Planet at east


require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: Planet at east \nNo setup actions."
setScenarioChange(9)

function init()
	local ox =-13000
	local oy = 24000
	odysseus:setPosition(ox, oy)

	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific

	local sx = -5000
	local sy = 4500
	setSpawnFleetButton(2, nil, sx, sy, 2, 2, true, "formation", 0, 2, 0, 1)

	-- Spawnwave(distance from Odysseus, enemy size)
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)

	-- Generate scenario map
	generateSpace(sx, sy)

	planet = setUpPlanet("P-TE95-LN71", ox+55000, oy+25000)

end
