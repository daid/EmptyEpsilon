-- Name: Jump 03
-- Type: Mission

function init()

    odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0)
		
	
-- Station
 planet1 = Planet():setPosition(52000, 52000):setPlanetSurfaceTexture("planets/DE47-HC55.png"):setPlanetRadius(50000):setDistanceFromMovementPlane(-2000):setAxialRotationTime(80.0)
 
	
    addGMFunction("Generate EOC Fleet", function()
	
	x, y = odysseus:getPosition()
	
-- EOC Starfleet		
	aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):setRotation(-75):setScannedByFaction("Civilians")
	
	flagship = aurora

	taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -1500, 250):setScannedByFaction("Civilians", true) 
	valkyrie = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -3000, 500):setScannedByFaction("Civilians", true) 
	aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -4500, 750):setScannedByFaction("Civilians", true) 

	inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -6000, 1000):setScannedByFaction("Civilians")
		
	harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -9000, 7000):setScannedByFaction("Civilians", true) 

	envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -250, 1500):setScannedByFaction("Civilians", true) 
	bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -500, 3000):setScannedByFaction("Civilians", true) 
	
	burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -750, 4500):setScannedByFaction("Civilians", true) 
	arthas = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -1000, 6000):setScannedByFaction("Civilians", true) 

	valor = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -4000, 9000):setScannedByFaction("Civilians", true) 

	warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -1500, 8500):setScannedByFaction("Civilians", true) 
	

	halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -7000, 9000):setScannedByFaction("Civilians", true) 
	

-- Civilians
	prophet = CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -1000, 1000):setScannedByFaction("Civilians", true) 
	karma = CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -2000, 2000):setScannedByFaction("Civilians", true) 
	marauder = CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -3000, 3000):setScannedByFaction("Civilians", true) 
	discovery = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -4000, 4000):setScannedByFaction("Civilians", true) 
	whirlwind = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -5000, 5000):setScannedByFaction("Civilians", true) 
	memory = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -6000, 6000):setScannedByFaction("Civilians", true) 

	vulture = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -4000, 3000):setScannedByFaction("Civilians", true) 
	cyclone = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -3000, 4000):setScannedByFaction("Civilians", true) 
	
	ravenger = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -7000, 6000):setScannedByFaction("Civilians", true) 
	spectrum = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -6000, 7000):setScannedByFaction("Civilians", true) 

	
	centurio = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -7000, 4000):setScannedByFaction("Civilians", true) 
	polaris = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -4000, 7000):setScannedByFaction("Civilians", true) 
	
	
	immortal = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -5500, 3500):setScannedByFaction("Civilians", true) 
	
	starfall = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setPosition(x + random(20000, 40000), y + random(-40000, -20000)):orderFlyFormation(flagship, -3500, 5500):setScannedByFaction("Civilians", true) 

	removeGMFunction("Generate EOC Fleet")
	
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
	centurio:setCallSign("CSS Centurio"):setScannedByFaction("EOC Starfleet", true)
	polaris:setCallSign("ESS Polaris"):setScannedByFaction("EOC Starfleet", true)
	immortal:setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true)
	starfall:setCallSign("OSS Starfall"):setScannedByFaction("EOC Starfleet", true)
	removeGMFunction("Reveal Callsigns")

end)
	
	-- Esimerkki koodista miten tehdään nappi jolla tuhotaan yksi alus. Ei räjähdysefektejä tms tällä hetkellä.
	addGMFunction("Destroy Ravenger", function()
		ravenger:destroy()
	removeGMFunction("Destroy Ravenger")
	end)

addGMFunction("Fighter launchers", function()
	addGMFunction("Aurora Fighters", function()
	
	 x, y = aurora:getPosition()

		for n=1,69 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Aurora Fighters")
	end)
	
	addGMFunction("Halo Fighters", function()
	
	x, y = halo:getPosition()
	
		for n=1,51 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Halo Fighters")
	end)
	
	addGMFunction("Taurus Fighters", function()
	
	x, y = taurus:getPosition()
	
		for n=1,10 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Taurus Fighters")
	end)
	
	addGMFunction("Envoy Fighters", function()
	
	x, y = envoy:getPosition()
	
		for n=1,4 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Envoy Fighters")
	end)

	addGMFunction("Valkyrie Fighters", function()
	
	x, y = valkyrie:getPosition()
	
		for n=1,9 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Valkyrie Fighters")
	end)
	
	addGMFunction("Harbringer Fighters", function()
	
	x, y = harbringer:getPosition()
	
		for n=1,16 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Harbringer Fighters")
	end)

	addGMFunction("Inferno Fighters", function()
	
	x, y = inferno:getPosition()
	
		for n=1,27 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Inferno Fighters")
	end)
	
	addGMFunction("Valor Fighters", function()
	
	x, y = valor:getPosition()
	
		for n=1,20 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Valor Fighters")
	end)

	addGMFunction("Warrior Fighters", function()
	
	x, y = warrior:getPosition()
	
		for n=1,18 do
			CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
        end
	removeGMFunction("Warrior Fighters")
	end)
	removeGMFunction("EOC Fighter launchers")
end)
	
	
	end)
		

    addGMFunction("Enemy Fleet 1st wave", function()
	
	x, y = odysseus:getPosition()
	
	-- Fighters: 100
	-- Crusers: 40
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-30000, -15000), y + random(-30000,-15000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, -25000), y + random(-30000,-15000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-30000, -15000), y + random(-50000,-25000)):orderRoaming(x, y)
        end

		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-50000, -25000), y + random(-30000,-15000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-30000, -15000), y + random(-50000,-25000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-50000, -25000), y + random(-30000,-15000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-30000, -15000), y + random(-50000,-25000)):orderRoaming(x, y)
        end

	removeGMFunction("Enemy Fleet 1st wave")
	end)
	
    addGMFunction("Enemy Fleet 2nd wave", function()
	
	-- Fighters 100
	-- Cruisers 60
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, -25000), y + random(-40000,-25000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, -25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-65000, -40000), y + random(-40000, -25000)):orderRoaming(x, y)
        end
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, -25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-65000, -40000), y + random(-40000, -25000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-40000, -25000), y + random(-40000,-25000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-40000, -25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-65000, -40000), y + random(-40000, -25000)):orderRoaming(x, y)
        end
		
	removeGMFunction("Enemy Fleet 2nd wave")
	end)
	
	

end
