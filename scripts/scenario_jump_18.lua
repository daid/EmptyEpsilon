-- Name: Jump 16
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet.

require("utils.lua")
require("utils_odysseus.lua")

function init()
	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific

	
	-- Which fleet to spawn
	-- fx, fy cordinates from Odysseus position to spawn Aurora
	-- DistanceMin and distanceMax are values which are ued to calculate distance from Aurora
	-- distanceModifier defines multiplier to fleet ship from each other when flying in form. Default value 2
	-- Spawn modifier defines how much misplaced the ships are when spawn on the map
	-- 1 = just a little bit off and disoriented, 2 = bit more chaotic situation, 3 = way too quick jump, totally lost
	-- If X coordinated of Aurora spawning point is positive, it will take longer for ships to get back to gether
	--setSpawnFleetButton("Button text", "friendlyOne", A, B, distanceModifier, spawnModifier, revealCallSignsAtSpawn)		
	local sx = 5000
	local sy = -4500
	setSpawnFleetButton("Friendly 5", 2, sx, sy, 2, 5, true)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "Enemy - Large"), function() spawnwave(5) end)

   
	addGMFunction(_("Enemy", "Enemy end fleet"), function() 
		
		odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 98.", "Red")
		odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 52.", "Red")
		odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 118.", "Red")
		addGMFunction("Launch destruction", cleanup_confirm)

		x, y = odysseus:getPosition()

		spawnwave(6) 
	end)		

  -- Generate scenario map
	destroyEnemy = false
	destroy_delay = 1
	radius = 100
	enemyCount = 0
	enemyKills = 0

	generateSpace(sx, sy)


end


function cleanup_confirm()
	addGMFunction("Cancel destruction", cleanup_cancel)
	addGMFunction("Confirm destruction", cleanup_prep)
	removeGMFunction("Launch destruction")
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

	enemyCount = enemyCount * 97 / 100

	destroyEnemy = true

end



function cleanup(delta)

	if starcaller:isValid() then
		x, y = starcaller:getPosition()
		host = Asteroid():setPosition(x, y)
		starcaller:destroy()
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
				odysseus:addToShipLog("EVA sector scanner report. Machine fleet size reduced by over 97%.", "Red")
				return
			end

		end


		radius = radius + 100
		destroy_delay = 0.01
	else

		destroy_delay = destroy_delay - delta

	end

	if enemyKills >= enemyCount then
		destroyEnemy = false
		odysseus:addToShipLog("EVA sector scanner report. Machine fleet size reduced by over 97%.", "Red")
	end
end



function update(delta)

	if delta == 0 then

		return

		--game paused
	end

	if destroyEnemy then
		cleanup(delta)
	end

end
