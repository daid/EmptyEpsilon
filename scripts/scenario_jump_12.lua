-- Name: Jump 12
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids.

require("utils.lua")
require("utils_odysseus.lua")


function init()
	local ox =-30000
	local oy = 20000
	odysseus:setPosition(ox, oy)

	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific

	
	-- Which fleet to spawn
	-- A, B cordinates from Odysseus position to spawn Aurora
	-- DistanceMin and distanceMax are values which are ued to calculate distance from Aurora
	-- distanceModifier defines multiplier to fleet ship from each other when flying in form. Default value 2
	-- Spawn modifier defines how much misplaced the ships are when spawn on the map
	-- 1 = just a little bit off and disoriented, 2 = bit more chaotic situation, 3 = way too quick jump, totally lost
	-- If X coordinated of Aurora spawning point is positive, it will take longer for ships to get back to gether
	--setSpawnFleetButton("Button text", "friendlyOne", A, B, distanceModifier, spawnModifier, revealCallSignsAtSpawn)		
	local sx = -5000
	local sy = 4500
	setSpawnFleetButton("Friendly 3", 3, "A", sx, sy, 2, 1, true, "formation", 0, 3, 0, 3)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - Moon SX"), function() spawnwave(1, "target", ox+2000, oy-15000) end)
	addGMFunction(_("Enemy", "OC - Machine - Fleet SX"), function() spawnwave(1) end)

	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)

   
	setScenarioChange('Change scenario - 13', "scenario_jump_13.lua")

	-- Generate scenario map

	generateSpace(sx, sy)

	planet = setUpPlanet("M12-PI87", ox+2000, oy-15000, 0.99)
	planet = setUpPlanet("P-OC04-YU08", ox+20000, oy-53000, 1.4)

	addGMFunction("Destroy OSS Karma", confirm_karma)


end
