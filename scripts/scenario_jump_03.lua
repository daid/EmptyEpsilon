-- Name: Jump 03
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. Planet DE47-HC55

require("utils.lua")
require("utils_odysseus.lua")


function init()

	-- Add GM common functions - Order of the buttons: fleet, enemies, Scenario change, scenario specific

	-- Which fleet to spawn
	-- A, B cordinates from Odysseus position to spawn Aurora
	-- DistanceMin and distanceMax are values which are ued to calculate distance from Aurora
	-- distanceModifier defines multiplier to fleet ship from each other when flying in form. Default value 2
	-- Spawn modifier defines how much misplaced the ships are when spawn on the map
	-- 1 = just a little bit off and disoriented, 2 = bit more chaotic situation, 3 = way too quick jump, totally lost
	-- If X coordinated of Aurora spawning point is positive, it will take longer for ships to get back to gether
	--setSpawnFleetButton("Button text", "friendlyOne", A, B, distanceModifier, spawnModifier, revealCallSignsAtSpawn)	
	
	local sx = -50000
	local sy = -25000
	setSpawnFleetButton("Friendly 1 - No callsigns", 1, sx, sy, 2, 1, false)

	-- Spawnface parameters: (enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
    addGMFunction(_("buttonGM", "Enemy - Large"), function() spawnwave(4) end)
	addGMFunction(_("buttonGM", "Enemy - Backup - Small"), function() spawnwave(2) end)

	setScenarioChange('Change scenario - 04', "scenario_jump_04.lua")

	local lx = 65000
	local ly = 35000
	-- Travel time in minutes, direction
	setUpLaunchmissionButtons(1, lx, ly)
	
	-- Generate scenario map
	generateSpace(sx, sy)

	--SetUpPlanet clears all objects under the planet and adds the planet to the location
	--setUpPlanet("name", x, y, plane offset modifier)
	local velian = setUpPlanet("Velian", lx,ly, 0.9)

end

