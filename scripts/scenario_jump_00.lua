-- Name: Jump 00
-- Type: Odysseus
-- Description: Map: Jump point element near starting point. Enemies: Button to spawn small enemy fleet at the edge of player visibility range Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")

function init()
    addGMFunction(_("buttonGM", "OC - Machine - S"), function() spawnwave(2) end)
	
	setScenarioChange('Change scenario - 01', "scenario_jump_01.lua")

	-- Generate scenario map
	-- Random asteroids and nebula
	local ox = -48000
	local oy = 37000
	odysseus:setPosition(ox,oy)
	generateSpace(ox, oy)

	--Scenario specific space objects
	local jumpPoint = CpuShip():setFaction("EOC Starfleet"):setTemplate("Jump point"):setPosition(ox-2000, oy-1500):setCallSign("Jump point - A3"):setCanBeDestroyed(true):setScannedByFaction("EOC Starfleet", true)
end

