-- Name: Jump 00
-- Type: Odysseus
-- Description: Map: Jump point element near starting point. Enemies: Button to spawn small enemy fleet at the edge of player visibility range Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")

function init()
	-- Add GM common functions - Order of the buttons: Fleet, enemies, Scenario change, scenario specific

	-- Spawnface parameters: (distance from Odysseus, enemyfleetsize)
	-- 1 = very small, 2 = small, 3 = mdium, 4 = large, 5 = massive, 6 = end fleet
	-- When distance set to 50000, it takes about 7-8 minutes enemy to reach attack range	
    addGMFunction(_("buttonGM", "Enemy - Very small"), function() spawnwave(1) end)
	
	setScenarioChange('Change scenario - 01', "scenario_jump_01.lua")

	-- Generate scenario map
	-- Random asteroids and nebula
	generateSpace(fx, fy)

	--Scenario specific space objects
	local jumpPoint = CpuShip():setFaction("EOC Starfleet"):setTemplate("Jump point"):setPosition(-2000, -1500):setCallSign("Jump point - A3"):setCanBeDestroyed(true):setScannedByFaction("EOC Starfleet", true)

end

