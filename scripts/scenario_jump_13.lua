-- Name: Jump 13
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids. EOC fleet. Radiation field. Planet.

require("utils.lua")
require("utils_odysseus.lua")

function init()

  for n=1,100 do
    Asteroid():setPosition(random(-100000, 100000), random(-100000, 100000)):setSize(random(100, 500))
    VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))
  end

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


-- Planet
  planet1 = Planet():setPosition(-60000, 40000):setPlanetSurfaceTexture("planets/SI14-UX98.png"):setDistanceFromMovementPlane(2000):setPlanetRadius(30000)


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


	x, y = odysseus:getPosition()

-- EOC Starfleet
	aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):setRotation(-75):setScannedByFaction("Corporate owned"):setCallSign("ESS Aurora"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	flagship = aurora

	taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -1500, 250):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Taurus") :setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	valkyrie = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -3000, 500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Valkyrie"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -4500, 750):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Aries"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -6000, 1000):setScannedByFaction("Corporate owned"):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Inferno"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -9000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Harbinger"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -250, 1500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Envoy"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -500, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Bluecoat"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -750, 4500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Burro"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	arthas = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -1000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Arthas"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	valor = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -4000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Valor"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -1500, 8500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Warrior"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)


	halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -7000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Halo"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

-- Civilians

	karma = CpuShip():setFaction("Unregistered"):setTemplate("Scoutship S835"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -2000, 2000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Karma"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	marauder = CpuShip():setFaction("Corporate owned"):setTemplate("Scoutship S835"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -3000, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Marauder"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	discovery = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -4000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Discovery"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	whirlwind = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -5000, 5000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Whirlwind"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	memory = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -6000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Memory"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	cyclone = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -3000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Cyclone"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	ravenger = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -7000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Ravager"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	spectrum = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -6000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Spectrum"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	centurion = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -7000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Centurion"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	immortal = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -5500, 3500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	starfall = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -3500, 5500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Starfall"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)


	addGMFunction("Change scenario to 14", changeScenarioPrep)


	plotZ = delayChecks

  odysseus:addToShipLog("EVA sector scanning alarm. Anomalous radiation field detected at heading 90.", "Red")

end


function changeScenarioPrep()
	removeGMFunction("Change scenario to 14")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)
end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
	removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 14", changeScenarioPrep)
end

function changeScenario()
	setScenario("scenario_jump_14.lua", "Null")
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
				ship:commandSetAlertLevel("yellow")
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


function update(delta)
	if delta == 0 then
		return
		--game paused
	end

	if plotZ ~= nil then
		plotZ(delta)
	end

end
