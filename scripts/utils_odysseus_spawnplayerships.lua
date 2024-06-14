-- Ship spawning and docking - Developed by Ville M. for Odysseus 2024

-- Ship Enabler
function allow_essody18()
	odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
  	odysseus:setLandingPadDocked(1)
	removeGMFunction("Allow ESSODY-F18")
end

function allow_essody23()
	odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
  	odysseus:setLandingPadDocked(2)
	removeGMFunction("Allow ESSODY-F23")
end
function allow_essody36()
	odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
  	odysseus:setLandingPadDocked(3)
	removeGMFunction("Allow ESSODY-F36")
end
function allow_starcaller()
	odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
  	odysseus:setLandingPadDocked(4)
	removeGMFunction("Allow STARCALLER")
end

-- Ship Launcher
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
	essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Starfighter"):setCanSelfDestruct(false):setPosition(x + 200, y + 200):setCallSign("ESSODY-F18"):setAutoCoolant(true):onDestruction(
	function(this, instigator) 
		odysseus:setLandingPadDestroyed(1)
		addGMFunction("Allow ESSODY-F18", allow_essody18)
	end)

	essody18:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody18)
  	odysseus:setLandingPadLaunched(1)
	essody18_launched = 1
end

function spawn_essody23()
	x, y = odysseus:getPosition()
	essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Starfighter"):setCanSelfDestruct(false):setPosition(x + 250, y + 250):setCallSign("ESSODY-F23"):setAutoCoolant(true):onDestruction(
    function(this, instigator) 
      	odysseus:setLandingPadDestroyed(2)
      	addGMFunction("Allow ESSODY-F23", allow_essody23)
    end)
	essody23:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody23)
  	odysseus:setLandingPadLaunched(2)
	essody23_launched = 1
end
function spawn_essody36()
	x, y = odysseus:getPosition()
	essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Starfighter"):setCanSelfDestruct(false):setPosition(x + 300, y + 300):setCallSign("ESSODY-F36"):setAutoCoolant(true):onDestruction(
    function(this, instigator) 
      	odysseus:setLandingPadDestroyed(3)
      	addGMFunction("Allow ESSODY-F36", allow_essody36)
    end)
	essody36:addCustomButton("Helms", "dock_to_odysseus", "Dock to Odysseys", dock_essody36)
  	odysseus:setLandingPadLaunched(3)
	essody36_launched = 1
end
function spawn_starcaller()
	x, y = odysseus:getPosition()
	starcaller = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Comet Class Scout"):setCanSelfDestruct(false):setPosition(x - 400, y + 400):setCallSign("ESS Starcaller"):setAutoCoolant(true):onDestruction(
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
			odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
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
			odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
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
			odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
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
	removeGMFunction("Allow ESSODY-F18")
	removeGMFunction("Allow ESSODY-F23")
	removeGMFunction("Allow ESSODY-F36")
	removeGMFunction("Allow STARCALLER")
	odysseus:removeCustom("launch_pad_1")
	odysseus:removeCustom("launch_pad_2")
	odysseus:removeCustom("launch_pad_3")
	odysseus:removeCustom("launch_pad_4")

	if odysseus:isLandingPadDestroyed(1) then
		addGMFunction("Allow ESSODY-F18", allow_essody18)
	end
	if odysseus:isLandingPadDestroyed(2) then
		addGMFunction("Allow ESSODY-F23", allow_essody23)
	end
	if odysseus:isLandingPadDestroyed(3) then
		addGMFunction("Allow ESSODY-F36", allow_essody36)
	end
	if odysseus:isLandingPadDestroyed(4) then
		addGMFunction("Allow STARCALLER", allow_starcaller)
	end

	if odysseus:isLandingPadDocked(1) then
		odysseus:addCustomButton("Relay", "launch_pad_1", "Launch ESSODY-F18", launch_essody18)
	end
	if odysseus:isLandingPadDocked(2) then
		odysseus:addCustomButton("Relay", "launch_pad_2", "Launch ESSODY-F23", launch_essody23)
	end
	if odysseus:isLandingPadDocked(3) then
		odysseus:addCustomButton("Relay", "launch_pad_3", "Launch ESSODY-F36", launch_essody36)
	end
	if odysseus:isLandingPadDocked(4) then
		odysseus:addCustomButton("Relay", "launch_pad_4", "Launch STARCALLER", launch_starcaller)
	end
end
