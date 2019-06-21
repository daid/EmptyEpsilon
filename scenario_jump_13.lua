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
	
    odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0):setCanBeDestroyed(false)

-- Launched buttons
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
	

-- Station
 planet1 = Planet():setPosition(-40000, 40000):setPlanetSurfaceTexture("planets/SI14-UX98.png"):setDistanceFromMovementPlane(2000):setPlanetRadius(20000)
		

	warningZone = Zone():setColor(0,0,0)
	warningZone:setPoints(42000,-100000,
						43000,-100000,
						43000,100000,
						42000,100000)
						
	critWarningZone = Zone():setColor(0,0,0)
	critWarningZone:setPoints(43000, -100000,
						44000,-100000,
						44000,100000,
						43000,100000)
	
	dangerZone = Zone():setColor(0,0,0)
	dangerZone:setPoints(44000,-100000,
						45999,-100000,
						45999,100000,
						44000,100000)
	
	critDangerZone = Zone():setColor(0,0,0)
	critDangerZone:setPoints(46000,-100000,
						47999,-100000,
						47999,100000,
						46000,100000)	
						
	deathDangerZone = Zone():setColor(0,0,0)
	deathDangerZone:setPoints(48000,-100000,
						99000,-100000,
						99000,100000,
						48000,100000)	
						
					

					
	colorZone = Zone():setColor(255, 0, 0)
	colorZone:setPoints(44000,-100000,
						99000,-100000,
						99000,100000,
						44000,100000)	

						
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
	
	polaris = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -4000, 7000):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("ESS Polaris"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
		
	immortal = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -5500, 3500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Immortal"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 
	
	starfall = CpuShip():setFaction("Corporate owned"):setTemplate("Cruiser C243"):setPosition(x + random(-20000, 20000), y + random(-50000, -35000)):orderFlyFormation(flagship, -3500, 5500):setScannedByFaction("Corporate owned", true):setScannedByFaction("Faith of the High Science", true):setScannedByFaction("Government owned", true):setScannedByFaction("Unregistered", true):setCallSign("OSS Starfall"):setScannedByFaction("EOC Starfleet", true):setCanBeDestroyed(false) 


	addGMFunction("Fighter launchers", fighter_launchers)
	
	addGMFunction("Enemy north", wavenorth)
	addGMFunction("Enemy south", wavesouth)
	addGMFunction("Enemy west", wavewest)

	addGMFunction("Starcaller Fixed", launch_starcaller_button)
	addGMFunction("Change scenario", changeScenarioPrep)
	
	plotZ = delayChecks

end

	
function changeScenarioPrep()

	removeGMFunction("Change scenario")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)
	
end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario", changeScenarioPrep)

end

function changeScenario()

	setScenario("scenario_jump_14.lua", "Null")
	
end

function wavenorth()
	
	x, y = odysseus:getPosition()
	wave_north(x, y, odysseus)	
	
		
end

function waveeast()
	
	x, y = odysseus:getPosition()
	wave_east(x, y, odysseus)		
		
end

function wavesouth()
	
	x, y = odysseus:getPosition()
	wave_south(x, y, odysseus)			
		
end

function wavewest()
	
	x, y = odysseus:getPosition()
	wave_west(x, y, odysseus)		
		
end
	


	function fighter_launchers()
		addGMFunction("Aurora Fighters", function()
		
		 x, y = aurora:getPosition()

			for n=1,69 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Aurora Fighters")
		end)
		
		addGMFunction("Halo Fighters", function()
		
		x, y = halo:getPosition()
		
			for n=1,51 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Halo Fighters")
		end)
		
		addGMFunction("Taurus Fighters", function()
		
		x, y = taurus:getPosition()
		
			for n=1,10 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Taurus Fighters")
		end)
		
		addGMFunction("Envoy Fighters", function()
		
		x, y = envoy:getPosition()
		
			for n=1,4 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Envoy Fighters")
		end)

		addGMFunction("Valkyrie Fighters", function()
		
		x, y = valkyrie:getPosition()
		
			for n=1,9 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Valkyrie Fighters")
		end)
		
		addGMFunction("Harbringer Fighters", function()
		
		x, y = harbringer:getPosition()
		
			for n=1,16 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Harbringer Fighters")
		end)

		addGMFunction("Inferno Fighters", function()
		
		x, y = inferno:getPosition()
		
			for n=1,27 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Inferno Fighters")
		end)
		
		addGMFunction("Valor Fighters", function()
		
		x, y = valor:getPosition()
		
			for n=1,20 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
			end
		removeGMFunction("Valor Fighters")
		end)

		addGMFunction("Warrior Fighters", function()
		
		x, y = warrior:getPosition()
		
			for n=1,18 do
				CpuShip():setFaction("EOC Starfleet"):setTemplate("Fighter F975"):orderDefendLocation(x, y):setPosition(x + random(-1000, 1000), y + random(-1000, 1000))
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



function launch_starcaller_button()
	addGMFunction("Cancel Starcaller", launch_starcaller_button_cancel)
	addGMFunction("Confirm Starcaller", launch_starcaller_button_confirm)
	removeGMFunction("Starcaller Fixed")
end

function launch_starcaller_button_cancel()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	addGMFunction("Starcaller Fixed", launch_starcaller_button)
end

function launch_starcaller_button_confirm()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller)
end

-- Player launched functions for fighters and starcaller
function launch_starcaller()

x, y = odysseus:getPosition()


	starcaller = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Scoutship S392"):setPosition(x, y + 400)
	starcaller:setCallSign("ESS Starcaller"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch Starcaller")
	
	starcaller:addCustomButton("Helms", "Dock to Odysseus", "Dock to Odysseus", dock_starcaller)

end

function dock_starcaller()
	x, y = starcaller:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		starcaller:destroy()			
		odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller)
	else
		starcaller:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end
end	


function launch_essody18()

	x, y = odysseus:getPosition()

	essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 300)
	essody18:setCallSign("ESSODY18"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY18")
	
	essody18:addCustomButton("Helms", "Dock to Odysseus", "Dock to Odysseus", dock_essody18)

end	

function dock_essody18()

	x, y = essody18:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		essody18:destroy()
			
			odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody36)
	else
		essody18:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end


end	



function launch_essody23()	

x, y = odysseus:getPosition()


	essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 200)
	essody23:setCallSign("ESSODY23"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY23")
	
	essody23:addCustomButton("Helms", "Dock to Odysseus", "Dock to Odysseus", dock_essody23)
end

function dock_essody23()

	x, y = essody23:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		essody23:destroy()
			
			odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	else
		essody23:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end

end	



function launch_essody36()

x, y = odysseus:getPosition()

	essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 100)
	essody36:setCallSign("ESSODY36"):setAutoCoolant(true)
	
	odysseus:removeCustom("Launch ESSODY36")
	essody36:addCustomButton("Helms", "Dock to Odysseus", "Dock to Odysseus", dock_essody36)
	
end

function dock_essody36()

	x, y = essody36:getPosition()
	
	dockable = false
	
	for _, obj in ipairs(getObjectsInRadius(x, y, 500)) do

		callSign = obj:getCallSign()

		if callSign == "ESS Odysseus" then
			dockable = true
		end
		
	end

	if dockable == true then
		essody36:destroy()
			
			odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
	else
			essody36:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
	end

			
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
		
		if essody23_alert < 1 then
			launchShipAlert(essody23)
			essody23_alert = 15
		else
			essody23_alert = essody23_alert - delta
		end
		
		if essody23_delay < 1 then
			zoneChecks(essody18)
			essody23_delay = 4
		else 
			essody23_delay = essody23_delay - delta
		end
		
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
			alertLevel = ship:getAlertLevel()
			
			if alertLevel == "Normal" then
				ship:commandSetAlertLevel("yellow")
			end

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

	     