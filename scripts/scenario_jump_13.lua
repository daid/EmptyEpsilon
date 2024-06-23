-- Name: Jump 13
-- Type: Odysseus
-- Description: No objects of interest.

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: No objects of interest. \nSetup actions: Choose right fleet to spawn. \nMove Prophet. Spawn asteroids."

setScenarioChange(14)

function init()
	local ox =-4000
	local oy = 2000
	odysseus:setPosition(ox, oy)

	local sx = 10000
	local sy = -14500
	setSpawnFleetButton(3, "A", sx, sy, 2, 1, true, "idle", 0, 0, 0, 1)
	setSpawnFleetButton(3, "B", sx, sy, 2, 1, true, "idle", 0, 0, 0, 1)

	addGMFunction("Set asteroid field", setProphetAsteroid)

	addGMFunction("Clear setup buttons", clearbuttons)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	

	addGMFunction(_("Enemy", "OC - Machine - S"), function() spawnwave(2) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)

	addGMFunction("Destroy CSS Prophet", confirm_prophet)

	-- Generate scenario map
	generateSpace(sx, sy)

	for n=1, 4 do
		local posx = random(-80000, 30000)
		local posy = random(-80000, 80000)
        Nebula():setPosition(posx, posy)
	end

	
end

function clearbuttons()
	removeGMFunction("Set asteroid field")
	removeGMFunction("Clear setup buttons")
end

function setProphetAsteroid()

	local px, py = prophet:getPosition()

	for n=1, 20 do
		local r = irandom(0, 360)
		local distance = irandom(250, 1000)
		x1 =px + math.cos(r / 180 * math.pi) * distance
		y1 = py + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(100, 500))
	end
	for n=1, 40 do
		local r = irandom(0, 360)
		local distance = irandom(1000, 10000)
		x1 =px + math.cos(r / 180 * math.pi) * distance
		y1 = py + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(100, 500))
	end
	for n=1, 100 do
		local r = irandom(0, 360)
		local distance = irandom(10000, 20000)
		x1 =px + math.cos(r / 180 * math.pi) * distance
		y1 = py + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(100, 500))
	end

	local ox, oy = odysseus:getPosition()
	
	for n=1, 20 do
		local r = irandom(10, 200)
		local distance = irandom(500, 5000)
		x1 = ox + math.cos(r / 180 * math.pi) * distance
		y1 = oy + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(100, 500))
	end


end
