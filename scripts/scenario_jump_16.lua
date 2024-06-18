-- Name: Jump 16
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet.

require("utils.lua")
require("utils_odysseus.lua")

function init()
	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific


	-- Which fleet to spawn
	-- A, B cordinates from Odysseus position to spawn Aurora
	-- DistanceMin and distanceMax are values which are ued to calculate distance from Aurora
	-- distanceModifier defines multiplier to fleet ship from each other when flying in form. Default value 2
	-- Spawn modifier defines how much misplaced the ships are when spawn on the map
	-- 1 = just a little bit off and disoriented, 2 = bit more chaotic situation, 3 = way too quick jump, totally lost
	-- If X coordinated of Aurora spawning point is positive, it will take longer for ships to get back to gether
	--setSpawnFleetButton("Button text", "friendlyOne", A, B, distanceModifier, spawnModifier, revealCallSignsAtSpawn)		
	local sx = 5000
	local sy = -4500
	setSpawnFleetButton("Friendly 4 A", 4, "A", sx, sy, 2, 1, true, "formation", 0, 1, 0, 1)
	setSpawnFleetButton("Friendly 4 B - No Karma", 4, "B", sx, sy, 2, 1, true, "formation", 0, 1, 0, 1)

	
	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - XL"), function() spawnwave(5) end)

	addGMFunction("Destroy ESS Valkyrie", confirm_valkyrie)

	generateSpace(sx, sy)

	

	
	setScenarioChange('Change scenario - 17', "scenario_jump_17.lua")

end

