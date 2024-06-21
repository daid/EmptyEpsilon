-- Name: Jump 14
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Asteroid belt.

require("utils.lua")
require("utils_odysseus.lua")
setScenarioChange(15)

function init()
	local ox =-7000
	local oy = 2000
	odysseus:setPosition(ox, oy)

	local sx = 5000
	local sy = 4500

	setSpawnFleetButton(4, "A", sx, sy, 2, 1, true, "formation", 0, 1, 0, 3)
	setSpawnFleetButton(4, "B", sx, sy, 2, 1, true, "formation", 0, 1, 0, 3)

	addGMFunction("Clear setup buttons", clearbuttons)

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
	addGMFunction(_("Enemy", "OC - Machine - L"), function() spawnwave(4) end)
	addGMFunction(_("Enemy", "OC - Machine - Backup XS"), function() spawnwave(1) end)

	-- Generate scenario map

	planet = setUpPlanet("P-SI14-UX98", ox+30000, oy-15000,0.9)

	for n=1, 4 do
		local posx = random(-80000, -10000)
		local posy = random(-80000, 80000)
                    Nebula():setPosition(posx, posy)
	end

	--x1, y1, x2, y2, spacing, object_type, rows, chance, randomize
	createObjectsOnLine(120000,-80000, 120000,80000, 40000, Nebula, 1, 100, 1)

	essody18_launched = 0
	essody23_launched = 0
	essody36_launched = 0
	starcaller_launched = 0
  
	  odysseus_delay = 1
	  essody18_delay = 1
	  essody23_delay = 1
	  essody36_delay = 1
	  starcaller_delay = 1
  
	  odysseus_alert = 1
	  essody18_alert = 1
	  essody23_alert = 1
	  essody36_alert = 1
	  starcaller_alert = 1
  
  
  -- Plan
  
	warningZone = Zone():setColor(0,0,0)
	warningZone:setPoints(22000,-100000,
						33000,-100000,
						33000,100000,
						22000,100000)
  
	critWarningZone = Zone():setColor(50,0,0)
	critWarningZone:setPoints(33000, -100000,
						44000,-100000,
						44000,100000,
						33000,100000)
  
	dangerZone = Zone():setColor(100,0,0)
	dangerZone:setPoints(44000,-100000,
						50000,-100000,
						50000,100000,
						44000,100000)
  
	critDangerZone = Zone():setColor(150,0,0)
	critDangerZone:setPoints(50000,-100000,
						55000,-100000,
						55000,100000,
						50000,100000)
  
	deathDangerZone = Zone():setColor(200,0,0)
	deathDangerZone:setPoints(55000,-100000,
						59000,-100000,
						59000,100000,
						55000,100000)
  
	colorZone = Zone():setColor(255, 0, 0)
	colorZone:setPoints(59000,-100000,
						200000,-100000,
						200000,100000,
						59000,100000)

	  plotZ = delayChecks
  
	odysseus:addToShipLog("EVA sector scanning alarm. Anomalous radiation field detected at heading 90.", "Red")
  
  end

function clearbuttons()
	removeGMFunction("Friendly 4A")
	removeGMFunction("Friendly 4B")
end

  function delayChecks(delta)
  
	  if odysseus_alert < 1 then
		  launchShipAlert(odysseus)
		  odysseus_alert = 15
	  else
		  odysseus_alert = odysseus_alert - delta
	  end
	  if odysseus_delay < 1 then
		  zoneChecks(odysseus)
		  odysseus_delay = 4
	  else
		  odysseus_delay = odysseus_delay - delta
	  end
  
  
	if essody18_launched == 1 then
		if essody18_alert < 1 then
			launchShipAlert(essody18)
			essody18_alert = 15
		else
			essody18_alert = essody18_alert - delta
		end
		  if essody18_delay < 1 then
			  zoneChecks(essody18)
			  essody18_delay = 4
		  else
			  essody18_delay = essody18_delay - delta
		  end
	end
  
	if essody23_launched == 1 then
		  if essody23_alert < 1 then
			  launchShipAlert(essody23)
			  essody23_alert = 15
		  else
			  essody23_alert = essody23_alert - delta
		  end
  
		  if essody23_delay < 1 then
			  zoneChecks(essody23)
			  essody23_delay = 4
		  else
			  essody23_delay = essody23_delay - delta
		  end
	end
  
	if essody36_launched == 1 then
		  if essody36_alert < 1 then
			  launchShipAlert(essody36)
			  essody36_alert = 15
		  else
			  essody36_alert = essody36_alert - delta
		  end
  
		  if essody36_delay < 1 then
			  zoneChecks(essody36)
			  essody36_delay = 4
		  else
			  essody36_delay = essody36_delay - delta
		  end
	end
  
	if starcaller_launched == 1 then
		  if starcaller_alert < 1 then
			  launchShipAlert(starcaller)
			  starcaller_alert = 15
		  else
			  starcaller_alert = starcaller_alert - delta
		  end
  
		  if starcaller_delay < 1 then
			  zoneChecks(starcaller)
			  starcaller_delay = 4
		  else
			  starcaller_delay = starcaller_delay - delta
		  end
	end
  
  end
  
  function zoneChecks(ship)
  
	  if dangerZone:isInside(ship) then
		  for n=1,4 do
			  dropHealth(ship)
		  end
	  end
	  if critDangerZone:isInside(ship) then
		  for n=1,8 do
			  dropHealth(ship)
		  end
	  end
	  if deathDangerZone:isInside(ship) then
		  for n=1,16 do
			  dropHealth(ship)
		  end
	  end
  
  end
  
  function launchShipAlert(ship)
		  if warningZone:isInside(ship) then
			  ship:addToShipLog("EVA scanning results. Space radiation level elevated.", "Blue")
		  end
		  if critWarningZone:isInside(ship) then
			  alertLevel = ship:getAlertLevel()
  
			  if alertLevel == "Normal" then
				  ship:commandSetAlertLevel("yellow")
			  end
  
			  ship:addToShipLog("EVA scanning results. Space radiation level critical.", "Yellow")
		  end
		  if colorZone:isInside(ship)	then
		  alertLevel = ship:getAlertLevel()
  
			  if alertLevel == "Normal" then
				  ship:commandSetAlertLevel("red")
			  end
  
			  ship:addToShipLog("EVA scanning results. Space radiation level lethal.", "Red")
		  end
  end
  
  function dropHealth(ship)
					  systemHit = math.random(1,7)
				  if systemHit == 1 then
					  ship:setSystemHealth("reactor", ship:getSystemHealth("reactor")*.99)
				  elseif systemHit == 2 then
					  ship:setSystemHealth("beamweapons", ship:getSystemHealth("beamweapons")*.99)
				  elseif systemHit == 3 then
					  ship:setSystemHealth("maneuver", ship:getSystemHealth("maneuver")*.99)
				  elseif systemHit == 4 then
					  ship:setSystemHealth("missilesystem", ship:getSystemHealth("missilesystem")*.99)
				  elseif systemHit == 5 then
					  ship:setSystemHealth("frontshield", ship:getSystemHealth("frontshield")*.99)
				  elseif systemHit == 6 then
					  ship:setSystemHealth("impulse", ship:getSystemHealth("impulse")*.99)
				  else
					  ship:setSystemHealth("rearshield", ship:getSystemHealth("rearshield")*.99)
				  end
  
  
  end
  