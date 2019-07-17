-- Name: Jump 16
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids. EOC fleet.

require("utils.lua")
require("utils_odysseus.lua")

function init()

	destroyEnemy = false
	destroy_delay = 1
	radius = 100
	enemyCount = 0
	enemyKills = 0

	for asteroid_counter=1,50 do
		Asteroid():setPosition(random(-75000, 75000), random(-75000, 75000))
	end

	x, y = odysseus:getPosition()


-- EOC Starfleet
	aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):setRotation(-75):setScannedByFaction("Corporate owned"):setCallSign("ESS Aurora"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	flagship = aurora

	taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -1500, 250):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Taurus") :setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -4500, 750):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Aries"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -6000, 1000):setScannedByFaction("Corporate owned"):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Inferno"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -9000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Harbinger"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -250, 1500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Envoy"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -500, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Bluecoat"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -750, 4500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Burro"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	arthas = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -1000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Arthas"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	valor = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -4000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Valor"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -1500, 8500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Warrior"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)


	halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -7000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Halo"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

-- Civilians

	karma = CpuShip():setFaction("Unregistered"):setTemplate("Scoutship S835"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -2000, 2000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Karma"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	marauder = CpuShip():setFaction("Corporate owned"):setTemplate("Scoutship S835"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -3000, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Marauder"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	discovery = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -4000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Discovery"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	whirlwind = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -5000, 5000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Whirlwind"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	memory = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -6000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Memory"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	cyclone = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -3000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Cyclone"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	ravenger = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -7000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Ravager"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	spectrum = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -6000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Spectrum"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	centurion = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -7000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Centurion"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	immortal = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -5500, 3500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	starfall = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 10000), y + random(-20000, 20000)):orderFlyFormation(flagship, -3500, 5500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Starfall"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

  addGMFunction("Enemy wave one + Nest", wave_one)


end


function wave_one()

	x, y = odysseus:getPosition()
	x0 = x+40000

	odysseus:addToShipLog("EVA sector scanner alarm. Enormous incoming jump detected from heading 90.", "Red")

	CpuShip():setFaction("Machines"):setTemplate("Machine Mothership"):setPosition(x+40000, y):orderRoaming(x, y):setRotation(100):setScanned(true)

	spawn_wave(x+50000, y)
	spawn_wave(x+50000, y-30000)
	spawn_wave(x+50000, y+30000)

	removeGMFunction("Enemy wave one + Nest")
	addGMFunction("Launch destruction", cleanup_confirm)
end


function cleanup_confirm()
	addGMFunction("Cancel destruction", cleanup_cancel)
	addGMFunction("Confirm destruction", cleanup_prep)
	removeGMFunction("Launch destruction")
end


function cleanup_cancel()
	addGMFunction("Launch destruction", cleanup_confirm)
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")

end

function cleanup_prep()
	removeGMFunction("Cancel destruction")
	removeGMFunction("Confirm destruction")

	for _, obj in ipairs(getAllObjects()) do

		faction = obj:getFaction()

		if faction == "Machines" then
			enemyCount = enemyCount + 1
		end
	end

	enemyCount = enemyCount * 97 / 100

	destroyEnemy = true

end



function cleanup(delta)

	if starcaller:isValid() then
		x, y = starcaller:getPosition()
		host = Asteroid():setPosition(x, y)
		starcaller:destroy()
	end
	x, y = host:getPosition()

	if destroy_delay < 0 then
		for _, obj in ipairs(getObjectsInRadius(x, y, radius)) do

			faction = obj:getFaction()

			if faction == "Machines" then
				--obj:destroy()
				obj:takeDamage(999999999)
				enemyKills = enemyKills + 1
			end

			if enemyKills >= enemyCount then
				destroyEnemy = false
				odysseus:addToShipLog("EVA sector scanner report. Machine fleet size reduced by over 97%.", "Red")
				return
			end

		end


		radius = radius + 100
		destroy_delay = 0.01
	else

		destroy_delay = destroy_delay - delta

	end

	if enemyKills >= enemyCount then
		destroyEnemy = false
		odysseus:addToShipLog("EVA sector scanner report. Machine fleet size reduced by over 97%.", "Red")
	end
end



function update(delta)

	if delta == 0 then

		return

		--game paused
	end

	if destroyEnemy then
		cleanup(delta)
	end

end
