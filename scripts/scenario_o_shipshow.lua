-- Name: Odysseus shiptype show
-- Description: Odysseus ships and models shown
-- Type: Mission

function init()
    -- Create the main ship for the players.

	
	player = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Scoutship S392")
	player:setCallSign("ESS Starcaller"):setPosition(0, 3000)

    player = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	player:setCallSign("Odysseus"):setPosition(0, 5000)

	player = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	player:setCallSign("ESSODY18"):setPosition(0, 1000):isDocked("Odysseus")

	player = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	player:setCallSign("ESSODY23"):setPosition(0, 1000):isDocked("Odysseus")

	player = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	player:setCallSign("ESSODY36"):setPosition(0, 1000)
		

-- Station
	station = SpaceStation():setFaction("Civilians"):setTemplate("Medium station"):setCallSign("Solaris 7"):setPosition(-2000, -1000)


-- EOC Starfleet		
	CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):setCallSign("ESSAUR04"):setPosition(2000, 1000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setCallSign("ESS Aries"):setPosition(2000, 3000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setCallSign("ESS Arthas"):setPosition(2000, 3000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setCallSign("OSS Burro"):setPosition(3000, 3000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Harbinger"):setPosition(2000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Inferno"):setPosition(2000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Valor"):setPosition(2000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setCallSign("ESS Warrior"):setPosition(2000, 5000)


	CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("CSS Taurus"):setPosition(3000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("ESS Bluecoat"):setPosition(3000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("ESS Envoy"):setPosition(3000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setCallSign("ESS Valkyrie"):setPosition(3000, 5000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setCallSign("ESS Halo"):setPosition(2000, 7000)

	CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setCallSign("ESS Aurora"):setPosition(2000, 7000)


-- Civilians
	CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setCallSign("CSS Prophet"):setPosition(4000, 3000)

	CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setCallSign("OSS Karma"):setPosition(4000, 3000)

	CpuShip():setFaction("Civilians"):setTemplate("Scoutship S835"):setCallSign("OSS Marauder"):setPosition(4000, 3000)
	
	CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("ESS Discovery"):setPosition(4000, 5000)
	
	CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("CSS Whirlwind"):setPosition(4000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("ESS Memory"):setPosition(4000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("OSS Ravager"):setPosition(4000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Corvette C348"):setCallSign("OSS Vulture"):setPosition(4000, 5000)

	
	CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("CSS Centurio"):setPosition(5000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("CSS Cyclone"):setPosition(5000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("ESS Polaris"):setPosition(5000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("ESS Spectrum"):setPosition(5000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("OSS Immortal"):setPosition(5000, 5000)

	CpuShip():setFaction("Civilians"):setTemplate("Cruiser C243"):setCallSign("OSS Starfall"):setPosition(5000, 5000)


	
	-- Machines
	CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(6000, 1000)
	CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(6000, 5000)
	CpuShip():setFaction("Machines"):setTemplate("Machine Unknown"):setPosition(6000, 9000)
	

	
end

function update(delta)
end