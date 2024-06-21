-- Name: Jump 01
-- Type: Odysseus
-- Description: Map: Space station Solaris 7 - aproximetely 15 minutes fly from the starting point. Enemies: Button to spawn small enemy fleet at the edge of player visibility range. Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")
setScenarioChange(2)

function init()
	addGMFunction(_("buttonGM", "OC - Machine - S"), function() spawnwave(2) end)
	addGMFunction(_("buttonGM", "OC - Machine - Backup XS"), function() spawnwave(1) end)

	local ox =10000
	local oy = 15000
	odysseus:setPosition(ox, oy)

	local r = 220
	local distance = 54000
	fx = math.floor(ox + math.cos(r / 180 * math.pi) * distance)
	fy = math.floor(oy + math.sin(r / 180 * math.pi) * distance)

	
	-- Generate scenario map
	-- Station generation location
	-- FX and FY parameters which to avoid when creating random space
	generateSpace(fx, fy)

	-- Lisää päälle nebula
	Nebula():setPosition(fx+2000, fy-1000)
	local station = SpaceStation():setFaction("EOC Starfleet"):setTemplate("Medium station"):setCallSign("Solaris 7"):setPosition(fx, fy)

end
