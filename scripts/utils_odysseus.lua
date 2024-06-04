-- Name: Odysseus utils
-- Modified and simplified the functions after the Odysseus larp by Mikko B
-- FOR SOME REASON THE FIRST SCENE NEEDS TO BE LOADED TWICE FOR THE SCRIPTS TO WORK PROPERLY.

-- Add common GM functions (these need to be added in the scenario scripts, so commented out here -Ville)
-- addGMFunction("Enemy north", wavenorth)
-- addGMFunction("Enemy east", waveeast)
-- addGMFunction("Enemy south", wavesouth)
-- addGMFunction("Enemy west", wavewest)
-- addGMFunction("Allow ESSODY18", allow_essody18)
-- addGMFunction("Allow ESSODY23", allow_essody23)
-- addGMFunction("Allow ESSODY36", allow_essody36)
-- addGMFunction("Allow STARCALLER", allow_starcaller)

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
	odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY18", launch_essody18)
  	odysseus:setLandingPadDocked(1)
	removeGMFunction("Allow ESSODY18")
end
function allow_essody23()
	odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY23", launch_essody23)
  	odysseus:setLandingPadDocked(2)
	removeGMFunction("Allow ESSODY23")
end
function allow_essody36()
	odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY36", launch_essody36)
  	odysseus:setLandingPadDocked(3)
	removeGMFunction("Allow ESSODY36")
end
function allow_starcaller()
	odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
  	odysseus:setLandingPadDocked(4)
	removeGMFunction("Allow STARCALLER")
end

-- Ship Launcher (simplified and removed unnecessary confirmation)
function launch_essody18()
	odysseus:removeCustom("launch_pad_1")
	spawn_essody18()
end
function launch_essody23()
	odysseus:removeCustom("launch_pad_2")
	spawn_essody23()
end
function launch_essody36()
	odysseus:removeCustom("launch_pad_3")
	spawn_essody36()
end
function launch_starcaller()
	odysseus:removeCustom("launch_pad_4")
	spawn_starcaller()
end

-- Ship spawner
function spawn_essody18()
	x, y = odysseus:getPosition()
	essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x + 200, y + 200):setCallSign("ESSODY18"):setAutoCoolant(true):onDestruction(
	function(this, instigator) 
		odysseus:setLandingPadDestroyed(1)
		addGMFunction("Allow ESSODY18", allow_essody18)
	end)
	essody18:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody18)
  	odysseus:setLandingPadLaunched(1)
	essody18_launched = 1
end
function spawn_essody23()
	x, y = odysseus:getPosition()
	essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x + 250, y + 250):setCallSign("ESSODY23"):setAutoCoolant(true):onDestruction(
    function(this, instigator) 
      	odysseus:setLandingPadDestroyed(2)
      	addGMFunction("Allow ESSODY23", allow_essody23)
    end)
	essody23:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody23)
  	odysseus:setLandingPadLaunched(2)
	essody23_launched = 1
end
function spawn_essody36()
	x, y = odysseus:getPosition()
	essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x + 300, y + 300):setCallSign("ESSODY36"):setAutoCoolant(true):onDestruction(
    function(this, instigator) 
      	odysseus:setLandingPadDestroyed(3)
      	addGMFunction("Allow ESSODY36", allow_essody36)
    end)
	essody36:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody36)
  	odysseus:setLandingPadLaunched(3)
	essody36_launched = 1
end
function spawn_starcaller()
	x, y = odysseus:getPosition()
	starcaller = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Scoutship S392"):setPosition(x - 400, y + 400):setCallSign("ESS Starcaller"):setAutoCoolant(true):onDestruction(
    function(this, instigator) 
      	odysseus:setLandingPadDestroyed(4)
      	addGMFunction("Allow STARCALLER", allow_starcaller)
    end)
	starcaller:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_starcaller)
  	odysseus:setLandingPadLaunched(4)
	starcaller_launched = 1
end

-- Ship docker
dockingdist = 800   --Set docking distance to 0.8U

function dock_essody18()
	x, y = essody18:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			essody18_launched = 0
      		odysseus:setLandingPadDocked(1)
			odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY18", launch_essody18)
			essody18:destroy()
			return
		end
	end
	essody18:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
end
function dock_essody23()
	x, y = essody23:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			essody23_launched = 0
      		odysseus:setLandingPadDocked(2)
			odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY23", launch_essody23)
			essody23:destroy()
			return
		end
	end
	essody23:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
end
function dock_essody36()
	x, y = essody36:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			essody36_launched = 0
      		odysseus:setLandingPadDocked(3)
			odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY36", launch_essody36)
			essody36:destroy()
			return
		end
	end
	essody36:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
end
function dock_starcaller()
	x, y = starcaller:getPosition()
	for _, obj in ipairs(getObjectsInRadius(x, y, dockingdist)) do
		callSign = obj:getCallSign()
		if callSign == "ESS Odysseus" then
			starcaller_launched = 0
      		odysseus:setLandingPadDocked(4)
			odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
			starcaller:destroy()
			return
		end
	end
	starcaller:addCustomMessage("Helms", "Distance too far. Docking cancelled.", "Distance too far. Docking cancelled.")
end

-- Button synchronizer
function sync_buttons()
	removeGMFunction("Allow ESSODY18")
	removeGMFunction("Allow ESSODY23")
	removeGMFunction("Allow ESSODY36")
	removeGMFunction("Allow STARCALLER")
	odysseus:removeCustom("launch_pad_1")
	odysseus:removeCustom("launch_pad_2")
	odysseus:removeCustom("launch_pad_3")
	odysseus:removeCustom("launch_pad_4")
	
	if odysseus:isLandingPadDestroyed(1) then
		addGMFunction("Allow ESSODY18", allow_essody18)
	end
	if odysseus:isLandingPadDestroyed(2) then
		addGMFunction("Allow ESSODY23", allow_essody23)
	end
	if odysseus:isLandingPadDestroyed(3) then
		addGMFunction("Allow ESSODY36", allow_essody36)
	end
	if odysseus:isLandingPadDestroyed(4) then
		addGMFunction("Allow STARCALLER", allow_starcaller)
	end

	if odysseus:isLandingPadDocked(1) then
		odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY18", launch_essody18)
	end
	if odysseus:isLandingPadDocked(2) then
		odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY23", launch_essody23)
	end
	if odysseus:isLandingPadDocked(3) then
		odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY36", launch_essody36)
	end
	if odysseus:isLandingPadDocked(4) then
		odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
	end
end
