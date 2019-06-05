-- Name: Jump 11
-- Type: Mission
-- Type: Mission

function init()

      odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0):setCanBeDestroyed(false)
	
	planet1 = Planet():setPosition(50000, -30000):setPlanetSurfaceTexture("planets/moon-1.png"):setDistanceFromMovementPlane(2000):setPlanetRadius(15000)
 
	
-- Launched buttons
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)


	for asteroid_counter=1,50 do
		Asteroid():setPosition(random(-75000, 75000), random(-75000, 75000))
	end

	x, y = odysseus:getPosition()
	
-- EOC Starfleet		
	aurora = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):setRotation(-75):setScannedByFaction("Corporate owned"):setCallSign("ESS Aurora"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)
	
	flagship = aurora

	taurus = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -1500, 250):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Taurus") :setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 

	valkyrie = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -3000, 500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Valkyrie"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	aries = CpuShip():setFaction("EOC Starfleet"):setTemplate("Scoutship S342"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -4500, 750):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Aries"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 

	inferno = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -6000, 1000):setScannedByFaction("Corporate owned"):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Inferno"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)
		
	harbringer = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -9000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Harbinger"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)

	envoy = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -250, 1500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Envoy"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)
	
	bluecoat = CpuShip():setFaction("EOC Starfleet"):setTemplate("Corvette C754"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -500, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Bluecoat"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	burro = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cargoship T842"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -750, 4500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Burro"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false)
	
	warrior = CpuShip():setFaction("EOC Starfleet"):setTemplate("Cruiser C753"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -1500, 8500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Warrior"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	

	halo = CpuShip():setFaction("EOC Starfleet"):setTemplate("Battlecruiser B952"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -7000, 9000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Halo"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
-- Civilians
	prophet = CpuShip():setFaction("Faith of the High Science"):setTemplate("Scoutship S835"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -1000, 1000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Prophet"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	karma = CpuShip():setFaction("Unregistered"):setTemplate("Scoutship S835"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -2000, 2000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Karma"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	marauder = CpuShip():setFaction("Corporate owned"):setTemplate("Scoutship S835"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -3000, 3000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Marauder"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	discovery = CpuShip():setFaction("Government owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -4000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Discovery"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	whirlwind = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -5000, 5000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Whirlwind"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	
	cyclone = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -3000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Cyclone"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	ravenger = CpuShip():setFaction("Corporate owned"):setTemplate("Corvette C348"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -7000, 6000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Ravager"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	spectrum = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -6000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Spectrum"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	centurion = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -7000, 4000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("CSS Centurion"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
			
	immortal = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-30000, 30000), y + random(-30000, 30000)):orderFlyFormation(flagship, -5500, 3500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	


	addGMFunction("Destroy ESS Polaris", function ()
		polaris:destroy();
		removeGMFunction("Destroy ESS Polaris")
	end)

		
    addGMFunction("Enemy wave one", wave_one)
    addGMFunction("Enemy wave two", wave_two)
	
	
	addGMFunction("Fighter launchers", fighter_launchers)

end


function wave_one()
	
		x, y = odysseus:getPosition()
		
	-- Fighters 100
	-- Cruisers 35
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-20000, 25000), y + random(-70000,-50000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-20000, 25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, 40000), y + random(-70000, -50000)):orderRoaming(x, y)
        end
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-20000, 25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-40000, 40000), y + random(-80000, -50000)):orderRoaming(x, y)
        end
		
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-20000, 25000), y + random(-80000,-50000)):orderRoaming(x, y)
        end
		
		for n=1,15 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-20000, 25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, 40000), y + random(-60000, -30000)):orderRoaming(x, y)
        end
		
	removeGMFunction("Enemy wave one")
	end

function wave_two()

	x, y = odysseus:getPosition()
	
	-- Fighters 100
	-- Cruisers 35
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, 25000), y + random(-60000,-50000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, 25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-65000, 40000), y + random(-80000, -40000)):orderRoaming(x, y)
        end
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-40000, 25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-65000, 40000), y + random(-60000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,10 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-40000, 25000), y + random(-80000,-40000)):orderRoaming(x, y)
        end
		
		for n=1,15 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setPosition(x + random(-40000, 25000), y + random(-65000, -40000)):orderRoaming(x, y)
        end
		
		for n=1,20 do
			CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setPosition(x + random(-65000, 40000), y + random(-80000, -50000)):orderRoaming(x, y)
        end
		
	removeGMFunction("Enemy wave two")
	end




	function fighter_launchers()
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

		addGMFunction("Hide Fighter launchers", function()
			removeGMFunction("Aurora Fighters")
			removeGMFunction("Halo Fighters")
			removeGMFunction("Taurus Fighters")
			removeGMFunction("Envoy Fighters")
			removeGMFunction("Valkyrie Fighters")
			removeGMFunction("Harbringer Fighters")
			removeGMFunction("Inferno Fighters")
			removeGMFunction("Valor Fighters")
			removeGMFunction("Warrior Fighters")
			removeGMFunction("Hide Fighter launchers")
			addGMFunction("Fighter launchers", fighter_launchers)
		end)

		
	removeGMFunction("Fighter launchers")
	end


function launch_essody18()
	odyfig18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig18:setCallSign("ESSODY18"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY18")
	
	odyfig18:addCustomButton("Helms", "Dock ESSODY18", "Dock ESSODY18", dock_essody18)
end	

function dock_essody18()
	odyfig18:destroy()
		
	odysseus:removeCustom("Dock ESSODY18")
	
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
end	



function launch_essody23()	
	odyfig23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig23:setCallSign("ESSODY23"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY23")
	
	odyfig23:addCustomButton("Helms", "Dock ESSODY23", "Dock ESSODY23", dock_essody23)
end

function dock_essody23()
	odyfig23:destroy()
		
	odysseus:removeCustom("Dock ESSODY23")
	
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
end	



function launch_essody36()
	odyfig36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	odyfig36:setCallSign("ESSODY36"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY36")
	odyfig36:addCustomButton("Helms", "Dock ESSODY36", "Dock ESSODY36", dock_essody36)
	
end

function dock_essody36()
	odyfig36:destroy()
		
	odysseus:removeCustom("Dock ESSODY36")
	
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
end	
