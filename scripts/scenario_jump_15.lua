-- Name: Jump 15
-- Type: Odysseus
-- Description: Asteroid field at northeast

require("utils.lua")
require("utils_odysseus.lua")
scenarioMap = "Map objects on load: Asteroid field at northeast \nSetup actions: Choose right fleet to spawn.\nAfter Aurora spawn, Set Aurora heading."

setScenarioChange(16)

function init()
	local ox =-75000
	local oy = 20000
	odysseus:setPosition(ox, oy)

	-- Add GM common functions - Order of the buttons: Sync, fleet, enemies, Scenario change, scenario specific
	local sx = -10000
	local sy = 8500
	setSpawnFleetButton(4, "A", sx, sy, 3, 1, true, "formation", 0, 3, 0, 1)
	setSpawnFleetButton(4, "B", sx, sy, 3, 1, true, "formation", 0, 3, 0, 1)
	addGMFunction(_("Enemy", "Set Aurora heading"), function() 
		if aurora:isValid() then 
			aurora:setHeading(45)
			removeGMFunction("Set Aurora heading")
		end
	end)
	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - M"), function() spawnwave(3) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)

	addGMFunction(_("Enemy", "Harbinger transport"), function() 
		launchHarbinger()
		removeGMFunction("Harbinger transport")
	end)

  local lx = ox +35000
  local ly = oy -35000


  	-- Generate scenario map
	  generateSpace(sx, sy)
	  for n=1, 55 do
		local r = irandom(0, 360)
		local distance = irandom(1000, 20000)
		x1 = lx+3000 + math.cos(r / 180 * math.pi) * distance
		y1 = ly-5000 + math.sin(r / 180 * math.pi) * distance
		Asteroid():setPosition(x1, y1):setSize(random(200, 2000))
	end


	  planet = setUpPlanet("AS-OH108", lx, ly, 0.7)
	  Planet():setPosition(lx-2000, ly+2300):setPlanetRadius(700):setDistanceFromMovementPlane(-500):setPlanetSurfaceTexture("planets/asteroid.png")
	  Planet():setPosition(lx+4000, ly+2300):setPlanetRadius(500):setDistanceFromMovementPlane(-300):setPlanetSurfaceTexture("planets/asteroid.png")
	  Planet():setPosition(lx+2000, ly-2300):setPlanetRadius(600):setDistanceFromMovementPlane(-300):setPlanetSurfaceTexture("planets/asteroid.png")
	  Planet():setPosition(lx+6000, ly+2300):setPlanetRadius(500):setDistanceFromMovementPlane(200):setPlanetSurfaceTexture("planets/asteroid.png")
	  Planet():setPosition(lx-4000, ly+2300):setPlanetRadius(300):setDistanceFromMovementPlane(-100):setPlanetSurfaceTexture("planets/asteroid.png")
	 

	  local dist = distance(odysseus, planet)


end

function launchHarbinger()
	local hx, hy = harbinger:getPosition()
	essharlc83 = CpuShip():setCallSign("ESSHARLC-83"):setTemplate("Aurora Class Landing Craft"):setScannedByFaction("EOC Starfleet"):setFaction("EOC Starfleet"):setPosition(hx, hy):setCanBeDestroyed(false):orderFlyFormation(odysseus, 200, 200)

end