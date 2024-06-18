-- Name: Jump 01
-- Type: Odysseus
-- Description: Map: Space station Solaris 7 - aproximetely 15 minutes fly from the starting point. Enemies: Button to spawn small enemy fleet at the edge of player visibility range. Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")

function init()
	addGMFunction(_("buttonGM", "OC - Machine - S"), function() spawnwave(2) end)

	setScenarioChange('Change scenario - 02', "scenario_jump_02.lua")
	local ox =10000
	local oy = 15000
	odysseus:setPosition(ox, oy)
	-- Travel time in minutes, direction
--	setUpLaunchmissionButtons("essodylc45", 3, lx,ly)
--	setUpLaunchmissionButtons("essodylc79", 3, lx,ly)
	local r = 220
	local distance = 54000
	fx = ox + math.cos(r / 180 * math.pi) * distance
	fy = oy + math.sin(r / 180 * math.pi) * distance

	
	-- Generate scenario map
	-- Station generation location
	-- FX and FY parameters which to avoid when creating random space
	generateSpace(fx, fy)

	local station = SpaceStation():setFaction("EOC Starfleet"):setTemplate("Medium station"):setCallSign("Solaris 7"):setPosition(fx, fy)

end