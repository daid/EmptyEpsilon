-- Name: Odysseus utils
-- Modified and simplified the functions after the Odysseus larp by Mikko B
-- FOR SOME REASON THE FIRST SCENE NEEDS TO BE LOADED TWICE FOR THE SCRIPTS TO WORK PROPERLY.

-- Add common GM functions
addGMFunction("Enemy north", wavenorth)
addGMFunction("Enemy east", waveeast)
addGMFunction("Enemy south", wavesouth)
addGMFunction("Enemy west", wavewest)
addGMFunction("Allow ESSODY18", allow_essody18)
addGMFunction("Allow ESSODY23", allow_essody23)
addGMFunction("Allow ESSODY36", allow_essody36)
addGMFunction("Allow STARCALLER", allow_starcaller)

-- spawn the ESS Odysseus
odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743"):setCallSign("ESS Odysseus"):setPosition(0, 0):setCanBeDestroyed(false)


-- Enemy spawner
function wavenorth()
	x, y = odysseus:getPosition()
	odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 0.", "Red")
	spawn_wave(x, y-60000)
end

function waveeast()
	x, y = odysseus:getPosition()
	odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 90.", "Red")
	spawn_wave(x+60000, y)
end

function wavewest()
	x, y = odysseus:getPosition()
	odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 270.", "Red")
	spawn_wave(x-60000, y)
end

function wavesouth()
	x, y = odysseus:getPosition()
	odysseus:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 180.", "Red")
	spawn_wave(x, y+60000)
end

function spawn_wave(x, y)
    for n=1, 30 do
        local r = random(0, 360)
        local distance = random(1000, 30000)
        x1 = x + math.cos(r / 180 * math.pi) * distance
        y1 = y + math.sin(r / 180 * math.pi) * distance
        CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setPosition(x1, y1):orderRoaming(x, y)
    end
		for n=1, 5 do
        local r = random(0, 360)
        local distance = random(3000, 20000)
        x1 = x + math.cos(r / 180 * math.pi) * distance
        y1 = y + math.sin(r / 180 * math.pi) * distance
        CpuShip():setFaction("Machines"):setTemplate("Frigate Stinger"):setPosition(x1, y1):orderRoaming(x, y)
    end
       CpuShip():setFaction("Machines"):setTemplate("Cruiser Reaper"):setPosition(x, y):orderRoaming(x, y)
end

-- Ship Enabler

function allow_essody18()
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
	removeGMFunction("Allow ESSODY18")
end
function allow_essody23()
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
	removeGMFunction("Allow ESSODY23")
end
function allow_essody36()
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
	removeGMFunction("Allow ESSODY36")
end
function allow_starcaller()
	odysseus:addCustomButton("Relay", "Launch STARCALLER", "Launch STARCALLER", launch_starcaller)
	removeGMFunction("Allow STARCALLER")
end

-- Ship Launcher (simplified and removed unnecessary confirmation)
function launch_essody18()
	odysseus:removeCustom("Launch ESSODY18")
	spawn_essody18()
end
function launch_essody23()
	odysseus:removeCustom("Launch ESSODY23")
	spawn_essody23()
end
function launch_essody36()
	odysseus:removeCustom("Launch ESSODY36")
	spawn_essody36()
end
function launch_starcaller()
	odysseus:removeCustom("Launch STARCALLER")
	spawn_starcaller()
end

-- Ship spawner
function spawn_essody18()
	x, y = odysseus:getPosition()
	essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x + 200, y + 200):setCallSign("ESSODY18"):setAutoCoolant(true)
	essody18:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody18)
	essody18_launched = 1
end
function spawn_essody23()
	x, y = odysseus:getPosition()
	essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x + 250, y + 250):setCallSign("ESSODY23"):setAutoCoolant(true)
	essody23:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody23)
	essody23_launched = 1
end
function spawn_essody36()
	x, y = odysseus:getPosition()
	essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x + 300, y + 300):setCallSign("ESSODY36"):setAutoCoolant(true)
	essody36:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody36)
	essody36_launched = 1
end
function spawn_starcaller()
	x, y = odysseus:getPosition()
	starcaller = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Scoutship S392"):setPosition(x - 400, y + 400):setCallSign("ESS Starcaller"):setAutoCoolant(true)
	starcaller:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_starcaller)
	starcaller_launched = 1
end

-- Ship docker
dockingdist = 800   --Set docking distance to 0.8U

function dock_essody18()
	x, y = essody18:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			essody18:destroy()
			essody18_launched = 0
			odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18)
		else
			essody18:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
end
function dock_essody23()
	x, y = essody23:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			essody23:destroy()
			essody23_launched = 0
			odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
		else
			essody23:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
end
function dock_essody36()
	x, y = essody36:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			essody36:destroy()
			essody36_launched = 0
			odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
		else
			essody36:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
end
function dock_starcaller()
	x, y = starcaller:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			starcaller:destroy()
			starcaller_launched = 0
			odysseus:addCustomButton("Relay", "Launch STARCALLER", "Launch STARCALLER", launch_starcaller)
		else
			starcaller:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
		end
	end
end
