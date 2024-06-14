-- Name: Jump 08
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
	setSpawnFleetButton("Friendly 2", 2, sx, sy, 2, 1, true)

	-- Spawnwave(distance from Odysseus, enemy size)
	addGMFunction(_("Enemy", "Enemy - Small"), function() spawnwave(2) end)

	
	setScenarioChange('Change scenario - 09', "scenario_jump_09.lua")
	
	 addGMFunction("Destroy ESS polaris", confirm_polaris)

	-- Generate scenario map
	generateSpace(sx, sy)

	planet = setUpPlanet("P-TE95-LN71", 105000, 25000)

end
