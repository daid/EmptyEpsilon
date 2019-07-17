-- Name: Jump 03
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids. Planet DE47-HC55

require("utils.lua")
require("utils_odysseus.lua")

function init()

  for n=1,100 do
    Asteroid():setPosition(random(-100000, 100000), random(-100000, 100000)):setSize(random(100, 500))
    VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))
  end

  -- Planet
	planet1 = Planet():setPosition(82000, 40000):setPlanetSurfaceTexture("planets/DE47-HC55.png"):setPlanetRadius(40000)

  addGMFunction("Generate EOC Fleet", function()

		x, y = odysseus:getPosition()

	-- EOC Starfleet
		aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):setRotation(-75):setScannedByFaction("Corporate owned"):setCanBeDestroyed(false)

		flagship = aurora

		taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -1500, 250):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		valkyrie = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -3000, 500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -4500, 750):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -6000, 1000):setScannedByFaction("Corporate owned"):setCanBeDestroyed(false)

		harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -9000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -250, 1500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -500, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -750, 4500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		arthas = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -1000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		valor = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -4000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -1500, 8500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -7000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)


	-- Civilians
		prophet = CpuShip():setFaction("Faith of the High Science"):setTemplate("Scoutship S835"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -1000, 1000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		karma = CpuShip():setFaction("Unregistered"):setTemplate("Scoutship S835"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -2000, 2000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		marauder = CpuShip():setFaction("Corporate owned"):setTemplate("Scoutship S835"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -3000, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		discovery = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -4000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		whirlwind = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -5000, 5000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		memory = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -6000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		vulture = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -4000, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		cyclone = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -3000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		ravenger = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -7000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		spectrum = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -6000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		centurion = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -7000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		polaris = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -4000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		immortal = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -5500, 3500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		starfall = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(70000, 100000), y + random(-100000, -70000)):orderFlyFormation(flagship, -3500, 5500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCanBeDestroyed(false)

		removeGMFunction("Generate EOC Fleet")
	end)

	addGMFunction("Reveal Callsigns", function()
	-- EOC Starfleet
		aurora:setCallSign("ESS Aurora"):setScannedByFaction("EOC Starfleet", true)
		taurus:setCallSign("CSS Taurus") :setScannedByFaction("EOC Starfleet", true)
		valkyrie:setCallSign("ESS Valkyrie"):setScannedByFaction("EOC Starfleet", true)
		aries:setCallSign("ESS Aries"):setScannedByFaction("EOC Starfleet", true)
		inferno:setCallSign("ESS Inferno"):setScannedByFaction("EOC Starfleet", true)
		harbringer:setCallSign("ESS Harbinger"):setScannedByFaction("EOC Starfleet", true)
		envoy:setCallSign("ESS Envoy"):setScannedByFaction("EOC Starfleet", true)
		bluecoat:setCallSign("ESS Bluecoat"):setScannedByFaction("EOC Starfleet", true)
		burro:setCallSign("OSS Burro"):setScannedByFaction("EOC Starfleet", true)
		arthas:setCallSign("ESS Arthas"):setScannedByFaction("EOC Starfleet", true)
		valor:setCallSign("ESS Valor"):setScannedByFaction("EOC Starfleet", true)
		warrior:setCallSign("ESS Warrior"):setScannedByFaction("EOC Starfleet", true)
		halo:setCallSign("ESS Halo"):setScannedByFaction("EOC Starfleet", true)

	-- Civilians
		prophet:setCallSign("CSS Prophet"):setScannedByFaction("EOC Starfleet", true)
		karma:setCallSign("OSS Karma"):setScannedByFaction("EOC Starfleet", true)
		marauder:setCallSign("OSS Marauder"):setScannedByFaction("EOC Starfleet", true)
		discovery:setCallSign("ESS Discovery"):setScannedByFaction("EOC Starfleet", true)
		whirlwind:setCallSign("CSS Whirlwind"):setScannedByFaction("EOC Starfleet", true)
		memory:setCallSign("ESS Memory"):setScannedByFaction("EOC Starfleet", true)
		vulture:setCallSign("OSS Vulture"):setScannedByFaction("EOC Starfleet", true)
		cyclone:setCallSign("CSS Cyclone"):setScannedByFaction("EOC Starfleet", true)
		ravenger:setCallSign("OSS Ravager"):setScannedByFaction("EOC Starfleet", true)
		spectrum:setTemplate("Cruiser C243"):setScannedByFaction("EOC Starfleet", true)
		centurion:setCallSign("CSS Centurion"):setScannedByFaction("EOC Starfleet", true)
		polaris:setCallSign("ESS Polaris"):setScannedByFaction("EOC Starfleet", true)
		immortal:setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true)
		starfall:setCallSign("OSS Starfall"):setScannedByFaction("EOC Starfleet", true)
		removeGMFunction("Reveal Callsigns")

	end)

	addGMFunction("Change scenario", changeScenarioPrep)
end

function changeScenarioPrep()

	removeGMFunction("Change scenario")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)

end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 04", changeScenarioPrep)

end

function changeScenario()

	setScenario("scenario_jump_04.lua", "Null")

end
