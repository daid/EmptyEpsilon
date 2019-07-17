-- Name: Jump 08
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids. EOC fleet.

function init()

  for n=1,100 do
    Asteroid():setPosition(random(-100000, 100000), random(-100000, 100000)):setSize(random(100, 500))
    VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))
  end

  for n=1,10 do
    Nebula():setPosition(random(-100000, 100000), random(-100000, 100000))
  end

	x, y = odysseus:getPosition()

-- EOC Starfleet
	aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):setRotation(-75):setScannedByFaction("Corporate owned"):setCallSign("ESS Aurora"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)


	taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -1500, 250):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Taurus") :setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	valkyrie = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -3000, 500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Valkyrie"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -4500, 750):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Aries"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -6000, 1000):setScannedByFaction("Corporate owned"):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Inferno"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -9000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Harbinger"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -250, 1500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Envoy"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -500, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Bluecoat"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -750, 4500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Burro"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	arthas = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -1000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Arthas"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	valor = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -4000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Valor"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -1500, 8500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Warrior"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)


	halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -7000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Halo"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

-- Civilians
	prophet = CpuShip():setFaction("Faith of the High Science"):setTemplate("Scoutship S835"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -1000, 1000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Prophet"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	karma = CpuShip():setFaction("Unregistered"):setTemplate("Scoutship S835"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -2000, 2000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Karma"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	marauder = CpuShip():setFaction("Corporate owned"):setTemplate("Scoutship S835"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -3000, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Marauder"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	discovery = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -4000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Discovery"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	whirlwind = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -5000, 5000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Whirlwind"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	memory = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -6000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Memory"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	cyclone = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -3000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Cyclone"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	ravenger = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -7000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Ravager"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	spectrum = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -6000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Spectrum"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	centurion = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -7000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Centurion"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	polaris = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -4000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Polaris"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(true)

	immortal = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -5500, 3500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	starfall = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-50000, 50000), y + random(-50000, 50000)):orderFlyFormation(aurora, -3500, 5500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Starfall"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)


	addGMFunction("EOC orders", eoc_orders)
  addGMFunction("Destroy ESS polaris", confirm_polaris)
	addGMFunction("Change scenario to 09", changeScenarioPrep)

end

function changeScenarioPrep()

	removeGMFunction("Change scenario to 09")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)

end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 09", changeScenarioPrep)

end

function changeScenario()

	setScenario("scenario_jump_09.lua", "Null")

end


function eoc_orders()
	x, y = odysseus:getPosition()

-- Fleet to battle

aurora:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
taurus:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
valkyrie:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
aries:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
inferno:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
hardbringer:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
envoy:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
bluecoat:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
burro:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
arthas:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
valor:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
warrior:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))
halo:orderRoaming(x + random(-20000, 25000), y + random(-60000,-25000))

-- Civilians to safety
	prophet:orderFlyTowardsBlind(x + 45000, y + 40000)
	karma:orderFlyTowardsBlind(x + 40000, y + 35000)
	marauder:orderFlyTowardsBlind(x + 45000, y + 41000)
	discovery:orderFlyTowardsBlind(x + 40000, y + 38000)
	whirlwind:orderFlyTowardsBlind(x + 45000, y + 35000)
	memory:orderFlyTowardsBlind(x + 40000, y + 42000)
	cyclone:orderFlyTowardsBlind(x + 43000, y + 40000)
	ravenger:orderFlyTowardsBlind(x + -45000, y + 30000)
	spectrum:orderFlyTowardsBlind(x + -40000, y + 30000)
	polaris:orderFlyTowardsBlind(x + -45000, y + 35000)
	immortal:orderFlyTowardsBlind(x + -39000, y + 31000)
	starfall:orderFlyTowardsBlind(x + -40000, y + 30000)
end


function confirm_polaris()
	removeGMFunction("Destroy ESS polaris")
	addGMFunction("Cancel destruction", cancel_polaris)
	addGMFunction("Confirm destruction", destroy_polaris)

end

function cancel_polaris()
	addGMFunction("Destroy ESS polaris", confirm_polaris)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
end


function destroy_polaris()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")
	polaris:destroy()
	odysseus:addToShipLog("EVA long range scanning results. ESS Polaris left from scanner range. No jump detected.", "Red")
end
