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

  if allow_autodock18 == true then
    local distance = distance(essody18, odysseus)
    if distance > dockingdist then
      remove_autodock18()
    end
  end

  if allow_autodock23 == true then
    local distance = distance(essody23, odysseus)
    if distance > dockingdist then
      remove_autodock23()
    end
  end

  if allow_autodock36 == true then
    local distance = distance(essody36, odysseus)
    if distance > dockingdist then
      remove_autodock36()
    end
  end

  if allow_autodocksc == true then
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
