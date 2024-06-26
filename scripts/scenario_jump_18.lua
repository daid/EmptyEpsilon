-- Name: Jump 18
-- Type: Odysseus
-- Description: No objects of interest.

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: No objects of interest. \nSetup actions: Choose right fleet to spawn."
addGMMessage("Jump 18 loaded. \nScenario file: scenario_jump_18.lua \nMap setup on load: " .. scenarioMap)
setChangeButton("Reload current Jump", "scenario_jump_18.lua")
function init()
	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific
	addGMFunction(_("buttonGM", "Coordinates H8-239"), function() 
		setUpPlanet("AS-RV693", 85000, 25000) 
		removeGMFunction("Coordinates H8-239")
		removeGMFunction("Coordinates H7-254")
		removeGMFunction("Other coordinates")
	end)
	addGMFunction(_("buttonGM", "Coordinates H7-254"), function() 
		setUpPlanet("P-GD66-NF38", 85000, 25000) 
		removeGMFunction("Coordinates H8-239")
		removeGMFunction("Coordinates H7-254")
		removeGMFunction("Other coordinates")
	end)
	addGMFunction(_("buttonGM", "Other coordinates"), function()
		removeGMFunction("Coordinates H8-239") 
		removeGMFunction("Coordinates H7-254")
		removeGMFunction("Other coordinates")
	end)
	local sx = 10000
	local sy = -14500
	setSpawnFleetButton(5, "A", sx, sy, 2, 3, true, "idle", 0, 3, 0, 3)
	setSpawnFleetButton(5, "B", sx, sy, 2, 3, true, "idle", 0, 3, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	


	addGMFunction(_("Enemy", "OC - Machine - XL + Mother"), function() spawnwave(6, "idle") end)
	addGMFunction(_("Enemy", "OC - Machine - XL"), function() spawnwave(5, "idle") end)

  -- Generate scenario map
	destroyEnemy = false
	destroy_delay = 1
	radius = 300
	enemyCount = 0
	enemyKills = 0

	generateSpace(sx, sy)


end


function cleanup_confirm()
	local scdistance = distance(starcaller, mother)
	if scdistance < 20000 then 
		addGMFunction("Cancel destruction", cleanup_cancel)
		addGMFunction("Confirm destruction", cleanup_prep)
		removeGMFunction("Launch destruction")
	else
		addGMMessage("Distance too far, minimum distance 20 000 ")
	end
end


function cleanup_cancel()
	addGMFunction("Launch destruction", cleanup_confirm)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")

end

function cleanup_prep()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")

	for _, obj in ipairs(getAllObjects()) do

		faction = obj:getFaction()

		if faction == "Machines" then
			enemyCount = enemyCount + 1
		end
	end

	enemyCount = enemyCount * 85 / 100

	destroyEnemy = true

end



function cleanup(delta)

	if starcaller:isValid() then
		x,y = mother:getPosition()
		host = Asteroid():setPosition(x, y)
		starcaller:destroy()
		mother:destroy()
	end
	x, y = host:getPosition()

	if destroy_delay < 0 then
		for _, obj in ipairs(getObjectsInRadius(x, y, radius)) do

			faction = obj:getFaction()	

			if faction == "Machines" then
				--obj:destroy()
				obj:takeDamage(999999999)
				enemyKills = enemyKills + 1
			end

			if enemyKills >= enemyCount then
				destroyEnemy = false
				odysseus:addToShipLog("EVA sector scanner report. Major explosion detected.", "Red")
				odysseus:addToShipLog("EVA sector scanner report. Hostiles immobilized.", "Red")
				return
			end

		end


		radius = radius + 300
		destroy_delay = 0.01
	else

		destroy_delay = destroy_delay - delta

	end

	if enemyKills >= enemyCount then
		destroyEnemy = false
		odysseus:addToShipLog("EVA sector scanner report. Major explosion detected.", "Red")
		odysseus:addToShipLog("EVA sector scanner report. Hostiles immobilized.", "Red")
	end
end
