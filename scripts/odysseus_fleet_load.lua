- EOC Starfleet		
	aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setCallSign("ESS Aurora"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):setRotation(-75)
	
	flagship = aurora

	taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("CSS Taurus"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -1500, 250) 
	valkyrie = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("ESS Valkyrie"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -3000, 500) 
	aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setCallSign("ESS Aries"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -4500, 750) 

	inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Inferno"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -6000, 1000) 
		
	harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Harbinger"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -9000, 7000) 

	envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("ESS Envoy"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -250, 1500) 
	bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("ESS Bluecoat"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -500, 3000) 
	
	burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setCallSign("OSS Burro"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -750, 4500) 
	arthas = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setCallSign("ESS Arthas"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -1000, 6000) 

	valor = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Valor"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -4000, 9000) 

	warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Warrior"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -1500, 8500) 
	

	halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setCallSign("ESS Halo"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -7000, 9000) 
	

-- Civilians
	prophet = CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setCallSign("CSS Prophet"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -1000, 1000) 
	karma = CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setCallSign("OSS Karma"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -2000, 2000) 
	marauder = CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setCallSign("OSS Marauder"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -3000, 3000) 
	discovery = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("ESS Discovery"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -4000, 4000) 
	whirlwind = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("CSS Whirlwind"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -5000, 5000) 
	memory = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("ESS Memory"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -6000, 6000) 

	vulture = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("OSS Vulture"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -4000, 3000) 
	cyclone = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("CSS Cyclone"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -3000, 4000) 
	
	ravenger = CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("OSS Ravager"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -7000, 6000) 
	spectrum = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("ESS Spectrum"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -6000, 7000) 

	
	centurio = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("CSS Centurio"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -7000, 4000) 
	polaris = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("ESS Polaris"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -4000, 7000) 
	
	
	immortal = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("OSS Immortal"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -5500, 3500) 
	
	starfall = CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("OSS Starfall"):setPosition(x + random(10000, 20000), y + random(-20000, -10000)):orderFlyFormation(flagship, -3500, 5500) 
