-- Name: Jump 00
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids.

require("utils.lua")
require("utils_odysseus.lua")

function init()
  	for n=1,100 do
		Asteroid():setPosition(random(-100000, 100000), random(-100000, 100000)):setSize(random(100, 500))
		VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))
  	end

	for n=1,10 do
		Nebula():setPosition(random(-100000, 100000), random(-100000, 100000))
  	end

	-- Add common GM functions
	addGMFunction("Sync buttons", sync_buttons)
	
	addGMFunction("Enemy north", wavenorth)
	addGMFunction("Enemy east", waveeast)
	addGMFunction("Enemy south", wavesouth)
	addGMFunction("Enemy west", wavewest)
	
	addGMFunction("Change scenario to 01", changeScenarioPrep)
end

function changeScenarioPrep()
	removeGMFunction("Change scenario to 01")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)
end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 01", changeScenarioPrep)
end

function changeScenario()
	setScenario("scenario_jump_01.lua", "Null")
end
