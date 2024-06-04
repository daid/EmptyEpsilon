-- Name: Jump 01
-- Type: Odysseus
-- Description: Onload: Odysseus, random asteroids. Spacestation Solaris 7.

require("utils.lua")
require("utils_odysseus.lua")

function init()

  	-- Station
  	station = SpaceStation():setFaction("EOC Starfleet"):setTemplate("Medium station"):setCallSign("Solaris 7"):setPosition(20000, 20000)

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

	addGMFunction("Change scenario to 02", changeScenarioPrep)
end

function changeScenarioPrep()

	removeGMFunction("Change scenario to 02")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)

end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 02", changeScenarioPrep)

end

function changeScenario()

	setScenario("scenario_jump_02.lua", "Null")

end
