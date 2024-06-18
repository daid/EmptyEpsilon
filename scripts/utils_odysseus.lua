-- Name: Odysseus utils
-- Modified and simplified the functions by Mikko B, Ria B, Ville M

--Functions to set up next scenario
require("utils_odysseus_scenariochange.lua")

-- Functions to spawn enemies
require("utils_odysseus_spawnenemy.lua")

--Functions and logic to spawn different kind friendly fleet combinations
require("utils_odysseus_spawnfleet.lua")

-- Orders for the fleet
require("utils_odysseus_fleet_orders.lua")

--Functions and logic to spawn and dock fighters and starcaller
require("utils_odysseus_spawnplayerships.lua")

-- Generating machine callsigns
require("generate_call_sign_scenario_utility.lua")

-- Generating space objects for Odysseus
require("utils_odysseus_generatespace.lua")

<<<<<<< HEAD
=======
-- Add common GM functions (these need to be added in the scenario scripts, so commented out here -Ville)
-- addGMFunction("Enemy north", wavenorth)
-- addGMFunction("Enemy east", waveeast)
-- addGMFunction("Enemy south", wavesouth)
-- addGMFunction("Enemy west", wavewest)
-- addGMFunction("Allow ESSODY18", allow_essody18)
-- addGMFunction("Allow ESSODY23", allow_essody23)
-- addGMFunction("Allow ESSODY36", allow_essody36)
-- addGMFunction("Allow STARCALLER", allow_starcaller)
>>>>>>> master

-- spawn the ESS Odysseus
local orotation = irandom(0, 360)
odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Helios Corvette"):setCallSign("ESS Odysseus"):setPosition(0, 0):commandTargetRotation(orotation):setHeading(orotation+90):setCanBeDestroyed(false)
odysseus:setCanSelfDestruct(false)

addGMFunction(_("buttonGM", "Sync fighter status"), function() sync_buttons() end)

--Sets suffix index for generating npc ship callsigns. Resets for every scenario
suffix_index = 100


function update(delta)
	if delta == 0 then
		return
	end
  
  --Fleet jumps
	if fleetJumpStatus == "jumpIn" and getScenarioTime() > nextJumpInAt then
		jumpInDelta()
	end
	if fleetJumpStatus == "jumpInAfter" then
		jumpInAfterDelta()
	end
	if fleetJumpStatus == "jumpOut" and getScenarioTime() > nextJumpOutAt then
		jumpOutDelta()
	end

  --Scenario 12
  if plotZ ~= nil then
    plotZ(delta)
  end

  --Scenario 18
	if destroyEnemy then
		cleanup(delta)
	end
end



function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
    end
    return iter
  end

  function in_array(value, array)
    for index = 1, #array do
        if array[index] == value then
            return true
        end
    end
    return false -- We could ommit this part, as nil is like false
end

<<<<<<< HEAD
function table.copy(t)
	local u = {}
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
  end
=======
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
>>>>>>> master
