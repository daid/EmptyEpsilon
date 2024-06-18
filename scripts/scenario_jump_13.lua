-- Name: Jump 13
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Radiation field. Planet.

require("utils.lua")
require("utils_odysseus.lua")

function init()
	local ox =-4000
	local oy = 2000
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
	local sx = 5000
	local sy = 4500
	setSpawnFleetButton("Friendly 3 A", 3, "A", sx, sy, 2, 1, true, "idle", 0, 0, 0, 1)
	setSpawnFleetButton("Friendly 3 B - No Karma", 3, "B", sx, sy, 2, 1, true, "idle", 0, 0, 0, 1)

	addGMFunction("Set asteroid field", setProphetAsteroid)


	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
addGMFunction("Clear setup buttons", clearbuttons)
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)

   
	setScenarioChange('Change scenario - 14', "scenario_jump_14.lua")

	addGMFunction("Destroy CSS Prophet", confirm_prophet)

	-- Generate scenario map
--	generateSpace(sx, sy)


--	createObjectsOnLine(-7000, 5000, 3000, 0, 500, Asteroid, 20, 100, 15000)

	for n=1, 4 do
		local posx = random(-80000, 30000)
		local posy = random(-80000, 80000)
                    Nebula():setPosition(posx, posy)
	end

	
end

function clearbuttons()
	removeGMFunction("Friendly 3 A")
	removeGMFunction("Friendly 3 B")
	removeGMFunction("Set asteroid field")
	removeGMFunction("Clear setup buttons")
end

function setProphetAsteroid()

	local px, py = prophet:getPosition()

	for n=1, 200 do
		local r = irandom(0, 360)
		local distance = irandom(250, 20000)
		x1 =px + math.cos(r / 180 * math.pi) * distance
		y1 = py + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(100, 500))
	end
	local ox, oy = odysseus:getPosition()
	
	for n=1, 50 do
		local r = irandom(0, 360)
		local distance = irandom(500, 10000)
		x1 = ox + math.cos(r / 180 * math.pi) * distance
		y1 = oy + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(100, 500))
	end


end
