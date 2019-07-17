-- Name: Jump 12
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids.

require("utils.lua")
require("utils_odysseus.lua")

function init()

	for asteroid_counter=1,50 do
		Asteroid():setPosition(random(-75000, 75000), random(-75000, 75000))
	end

	addGMFunction("Change scenario to 13", changeScenarioPrep)

end

function changeScenarioPrep()
	removeGMFunction("Change scenario to 13")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)
end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 13", changeScenarioPrep)
end

function changeScenario()
	setScenario("scenario_jump_13.lua", "Null")
end
