-- Name: Jump 02
-- Type: Odysseus
-- Description: Map: - Enemies: Backup enemy fleet Allies: No friendly fleet

require("utils.lua")
require("utils_odysseus.lua")
setScenarioChange(3)

function init()
	
	local ox =-10000
	local oy = 15000
	odysseus:setPosition(ox, oy)
	
	-- Generate scenario map
		addGMFunction(_("buttonGM", "Coordinates D3-117"), function() 
		setUpPlanet("Sronsh", ox-85000, oy-25000) 
		removeGMFunction("Coordinates D3-117")
		removeGMFunction("Other coordinates")
	end)
	addGMFunction(_("buttonGM", "Other coordinates"), function()
		removeGMFunction("Coordinates D3-117")
		removeGMFunction("Other coordinates")
	end)

	addGMFunction(_("buttonGM", "OC - Machine - Backup XS"), function() spawnwave(1) end)

	generateSpace(ox, oy)


end


