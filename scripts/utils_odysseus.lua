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


-- spawn the ESS Odysseus
local orotation = irandom(0, 360)
odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Helios Corvette"):setCallSign("ESS Odysseus"):setPosition(0, 0):commandTargetRotation(orotation):setHeading(orotation+90):setCanBeDestroyed(false):setCanSelfDestruct(false)
addGMFunction(_("odysseusmanagement", "Check Odysseus Status"), function() checkOdysseusStatus() end)
setFighterSyncButtons()
--Sets suffix index for generating npc ship callsigns. Resets for every scenario
suffix_index = 100

status_essody18 = 3
status_essody23 = 3
status_essody36 = 3
status_starcaller = 3

function checkOdysseusStatus()
  hullHealth = odysseus:getHull()
  hullHealthMax = string.format("%.2f", odysseus:getHullMax())
  impulseHealth = string.format("%.2f", odysseus:getSystemHealth("impulse"))
  reactorHealth = string.format("%.2f", odysseus:getSystemHealth("reactor"))
  beamweaponsHealth = string.format("%.2f", odysseus:getSystemHealth("beamweapons"))
  missilesystemHealth = string.format("%.2f", odysseus:getSystemHealth("missilesystem"))

--  odysseusHealth = "Hull: " .. hullHealth .. "\nImpulse health: " .. impulseHealth .. "\nReactor health: " .. reactorHealth .. "\nBeams health: " .. beamweaponsHealth .. "\nMissiles health: " .. missilesystemHealth .. "\nstatus_essody18: " .. status_essody18 .. "\nstatus_essody23: " .. status_essody23 .. "\nstatus_essody36: " .. status_essody36 .. "\nstatus_starcaller: " .. status_starcaller
fighterStatuses = "0 = Broken, 1 = 'Docked, 2 = Launched, 3 = Not synced from Backend"
odysseusStatus = "Hull: " .. hullHealth .. "/" .. hullHealthMax .. "\nImpulse health: " .. impulseHealth .. "\nReactor: " .. reactorHealth .."/1.0\n" .. fighterStatuses .. "\nstatus_essody18: " .. status_essody18 .. "\nstatus_essody23: " .. status_essody23 .. "\nstatus_essody36: " .. status_essody36 .. "\nstatus_starcaller: " .. status_starcaller
  addGMMessage(odysseusStatus)
end


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

	if fleetJumpStatus == "jumpOutAfter" then
		jumpOutAfter()
	end

  -- If ofysseus data and fighter data have mismatch, run sync automatically
  if odysseus:getLandingPadState(1) ~= status_essody18 then
    sync_buttons()  
  end
  if odysseus:getLandingPadState(2) ~= status_essody23 then
    sync_buttons()  
  end
  if odysseus:getLandingPadState(3) ~= status_essody36 then
    sync_buttons()  
  end
  if odysseus:getLandingPadState(4) ~= status_starcaller then
    sync_buttons()  
  end

  if allow_autodock18 == true and essody18:isValid() then
    local distance = distance(essody18, odysseus)
    if distance > dockingdist then
      remove_autodock18()
    end
  end

  if allow_autodock23 == true and essody23:isValid()then
    local distance = distance(essody23, odysseus)
    if distance > dockingdist then
      remove_autodock23()
    end
  end

  if allow_autodock36 == true and essody36:isValid() then
    local distance = distance(essody36, odysseus)
    if distance > dockingdist then
      remove_autodock36()
    end
  end

  if allow_autodocksc == true and starcaller:isValid() then
    local distance = distance(starcaller, odysseus)
    if distance > dockingdist then
      remove_autodocksc()
    end
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

function table.copy(t)
	local u = {}
	for k, v in pairs(t) do u[k] = v end
	return setmetatable(u, getmetatable(t))
  end
