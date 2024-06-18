-- Name: Jump 09
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Planet OC46-DA97

require("utils.lua")
require("utils_odysseus.lua")


function init()
	local ox = 30000
	local oy = -20000
	odysseus:setPosition(ox, oy)

	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific
	addGMFunction("Sync fighter status", sync_buttons)

		-- Generate scenario map


		addGMFunction(_("buttonGM", "Coordinates B8-48"), function() 
			removeGMFunction("Coordinates C8-80")
			removeGMFunction("Coordinates B8-64")
			removeGMFunction("Coordinates B8-48")
		end)
		addGMFunction(_("buttonGM", "Coordinates B8-64"), function() 
			removeGMFunction("Coordinates C8-80")
			removeGMFunction("Coordinates B8-64")
			removeGMFunction("Coordinates B8-48")
		end)
		addGMFunction(_("buttonGM", "Coordinates C8-80"), function() 
			setUpPlanet("P-PU80-GL38", ox+85000, oy+25000) 
			removeGMFunction("Coordinates C8-80")
			removeGMFunction("Coordinates C1-65")
			removeGMFunction("Coordinates C1-66")
		end)

	local sx = 5000
	local sy = 4500
	setSpawnFleetButton("Friendly 2", 2, "A", sx, sy, 2, 3, true, "formation", 0, 1, 0, 2)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)
	
	setScenarioChange('Change scenario - 10', "scenario_jump_10.lua")
	addGMFunction("Order Polaris idle", idle_polaris)

	

	-- Generate scenario map
	generateSpace(sx, sy)


end

function idle_polaris()
	polaris:orderIdle()
	removeGMFunction("Order Polaris idle")
	addGMFunction("Destroy ESS polaris", confirm_polaris)

end