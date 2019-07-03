-- Name: Jump 02
-- Type: Mission
-- Description: Onload: Odysseus, random asteroids.

require("utils.lua")
require("utils_odysseus.lua")

function init()


       odysseus = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Corvette C743")
	odysseus:setCallSign("ESS Odysseus"):setPosition(0, 0):setCanBeDestroyed(false)


        for n=1,100 do

			Asteroid():setPosition(random(-100000, 100000), random(-100000, 100000)):setSize(random(100, 500))

			VisualAsteroid():setPosition(random(-100000, 190000), random(-100000, 100000)):setSize(random(100, 500))

        end

	addGMFunction("Change scenario to 03", changeScenarioPrep)

  	addGMFunction("Enemy north", wavenorth)
  	addGMFunction("Enemy east", waveeast)
  	addGMFunction("Enemy south", wavesouth)
  	addGMFunction("Enemy west", wavewest)

  	addGMFunction("Allow ESSODY18", allow_essody18_prep)
  	addGMFunction("Allow ESSODY23", allow_essody23_prep)
  	addGMFunction("Allow ESSODY36", allow_essody36_prep)

  	addGMFunction("Allow Starcaller", allow_starcaller_prep)


end

function changeScenarioPrep()

	removeGMFunction("Change scenario to 03")
	addGMFunction("Cancel change", changeScenarioCancel)
	addGMFunction("Confirm change", changeScenario)

end

function changeScenarioCancel()
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction("Change scenario to 03", changeScenarioPrep)

end

function changeScenario()

	setScenario("scenario_jump_03.lua", "Null")

end

function wavenorth()

	x, y = odysseus:getPosition()
	wave_north(x, y, odysseus)


end

function waveeast()

	x, y = odysseus:getPosition()
	wave_east(x, y, odysseus)

end

function wavesouth()

	x, y = odysseus:getPosition()
	wave_south(x, y, odysseus)

end

function wavewest()

	x, y = odysseus:getPosition()
	wave_west(x, y, odysseus)

end


-- FIGHTER AND STARCALLER LAUNCHING
function allow_starcaller_prep()
	addGMFunction("Cancel Starcaller", allow_starcaller_cancel)
	addGMFunction("Confirm Starcaller", allow_starcaller_confirm)
	removeGMFunction("Allow Starcaller")
end

function allow_starcaller_cancel()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	addGMFunction("Allow Starcaller", allow_starcaller_prep)
end

function allow_starcaller_confirm()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller_prep)
end

function allow_essody18_prep()
	addGMFunction("Cancel ESSODY18", allow_essody18_cancel)
	addGMFunction("Confirm ESSODY18", allow_essody18_confirm)
	removeGMFunction("Allow ESSODY18")
end


function allow_essody18_cancel()
	removeGMFunction("Cancel ESSODY18")
	removeGMFunction("Confirm ESSODY18")
	addGMFunction("Allow ESSODY18", allow_essody18)
end

function allow_essody18_confirm()
	removeGMFunction("Cancel ESSODY18")
	removeGMFunction("Confirm ESSODY18")
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18_prep)
end

function allow_essody18()
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18_prep)
	removeGMFunction("Allow ESSODY18")
end

function launch_essody18_prep()
	odysseus:removeCustom("Launch ESSODY18")
	odysseus:addCustomButton("Relay", "Cancel ESSODY18 launch", "Cancel ESSODY18 launch", launch_essody18_cancel)
	odysseus:addCustomButton("Relay", "Confirm ESSODY18 launch", "Confirm ESSODY18 launch", launch_essody18_confirm)
end

function launch_essody18_cancel()
	odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody18_prep)
	odysseus:removeCustom("Cancel ESSODY18 launch")
	odysseus:removeCustom("Confirm ESSODY18 launch")
end

function launch_essody18_confirm()
	odysseus:removeCustom("Cancel ESSODY18 launch")
	odysseus:removeCustom("Confirm ESSODY18 launch")
	launch_essody18()
end


function allow_essody23_prep()
	addGMFunction("Cancel ESSODY23", allow_essody23_cancel)
	addGMFunction("Confirm ESSODY23", allow_essody23_confirm)
	removeGMFunction("Allow ESSODY23")
end


function allow_essody23_cancel()
	removeGMFunction("Cancel ESSODY23")
	removeGMFunction("Confirm ESSODY23")
	addGMFunction("Allow ESSODY23", allow_essody23)
end

function allow_essody23_confirm()
	removeGMFunction("Cancel ESSODY23")
	removeGMFunction("Confirm ESSODY23")
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23_prep)
end

function allow_essody23()
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23_prep)
	removeGMFunction("Allow ESSODY23")
end

function launch_essody23_prep()
	odysseus:removeCustom("Launch ESSODY23")
	odysseus:addCustomButton("Relay", "Cancel ESSODY23 launch", "Cancel ESSODY23 launch", launch_essody23_cancel)
	odysseus:addCustomButton("Relay", "Confirm ESSODY23 launch", "Confirm ESSODY23 launch", launch_essody23_confirm)
end

function launch_essody23_cancel()
	odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23_prep)
	odysseus:removeCustom("Cancel ESSODY23 launch")
	odysseus:removeCustom("Confirm ESSODY23 launch")
end

function launch_essody23_confirm()
	odysseus:removeCustom("Cancel ESSODY23 launch")
	odysseus:removeCustom("Confirm ESSODY23 launch")
	launch_essody23()
end

function allow_essody36_prep()
	addGMFunction("Cancel ESSODY36", allow_essody36_cancel)
	addGMFunction("Confirm ESSODY36", allow_essody36_confirm)
	removeGMFunction("Allow ESSODY36")
end


function allow_essody36_cancel()
	removeGMFunction("Cancel ESSODY36")
	removeGMFunction("Confirm ESSODY36")
	addGMFunction("Allow ESSODY36", allow_essody36)
end

function allow_essody36_confirm()
	removeGMFunction("Cancel ESSODY36")
	removeGMFunction("Confirm ESSODY36")
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36_prep)
end

function allow_essody36()
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36_prep)
	removeGMFunction("Allow ESSODY36")
end

function launch_essody36_prep()
	odysseus:removeCustom("Launch ESSODY36")
	odysseus:addCustomButton("Relay", "Cancel ESSODY36 launch", "Cancel ESSODY36 launch", launch_essody36_cancel)
	odysseus:addCustomButton("Relay", "Confirm ESSODY36 launch", "Confirm ESSODY36 launch", launch_essody36_confirm)
end

function launch_essody36_cancel()
	odysseus:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36_prep)
	odysseus:removeCustom("Cancel ESSODY36 launch")
	odysseus:removeCustom("Confirm ESSODY36 launch")
end

function launch_essody36_confirm()
	odysseus:removeCustom("Cancel ESSODY36 launch")
	odysseus:removeCustom("Confirm ESSODY36 launch")
	launch_essody36()
end


function allow_starcaller_prep()
	addGMFunction("Cancel Starcaller", allow_starcaller_cancel)
	addGMFunction("Confirm Starcaller", allow_starcaller_confirm)
	removeGMFunction("Allow Starcaller")
end


function allow_starcaller_cancel()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	addGMFunction("Allow Starcaller", allow_starcaller_prep)
end

function allow_starcaller_confirm()
	removeGMFunction("Cancel Starcaller")
	removeGMFunction("Confirm Starcaller")
	odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller_prep)
end

function allow_starcaller()
	odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller_prep)
	removeGMFunction("Allow Starcaller")
end

function launch_starcaller_prep()
	odysseus:removeCustom("Launch Starcaller")
	odysseus:addCustomButton("Relay", "Cancel Starcaller launch", "Cancel Starcaller launch", launch_starcaller_cancel)
	odysseus:addCustomButton("Relay", "Confirm Starcaller launch", "Confirm Starcaller launch", launch_starcaller_confirm)
end

function launch_starcaller_cancel()
	odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller_prep)
	odysseus:removeCustom("Cancel Starcaller launch")
	odysseus:removeCustom("Confirm Starcaller launch")
end

function launch_starcaller_confirm()
	odysseus:removeCustom("Cancel Starcaller launch")
	odysseus:removeCustom("Confirm Starcaller launch")
	launch_starcaller()
end


-- Player launched functions for fighters and starcaller
	function launch_starcaller()

x, y = odysseus:getPosition()

		starcaller = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Scoutship S392"):setPosition(x - 400, y + 400):setCallSign("ESS Starcaller"):setAutoCoolant(true)

		odysseus:removeCustom("Launch Starcaller")

		starcaller:addCustomButton("Helms", "Dock to Odysseus", "Dock to Odysseus", dock_starcaller)

	end

	function dock_starcaller()
		x, y = starcaller:getPosition()

		dockable = false

		for _, obj in ipairs(getObjectsInRadius(x, y, 800)) do

			callSign = obj:getCallSign()

			if callSign == "ESS Odysseus" then
				dockable = true
			end

		end

		if dockable == true then
			starcaller:destroy()
			odysseus:addCustomButton("Relay", "Launch Starcaller", "Launch Starcaller", launch_starcaller_prep)
		else
			starcaller:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
		end
	end


	function launch_essody18()

	x, y = odysseus:getPosition()

		essody18 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 300)
		essody18:setCallSign("ESSODY18"):setAutoCoolant(true)

		odysseus:removeCustom("Launch ESSODY18")

		essody18:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody18)

	end

	function dock_essody18()

		x, y = essody18:getPosition()

		dockable = false

		for _, obj in ipairs(getObjectsInRadius(x, y, 800)) do

			callSign = obj:getCallSign()

			if callSign == "ESS Odysseus" then
				dockable = true
			end

		end

		if dockable == true then
			essody18:destroy()

				odysseus:addCustomButton("Relay", "Launch ESSODY18", "Launch ESSODY18", launch_essody36)
		else
			essody18:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
		end

	end



	function launch_essody23()

	x, y = odysseus:getPosition()

		essody23 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 200)
		essody23:setCallSign("ESSODY23"):setAutoCoolant(true)

		odysseus:removeCustom("Launch ESSODY23")

		essody23:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody23)
	end

	function dock_essody23()

		x, y = essody23:getPosition()

		dockable = false

		for _, obj in ipairs(getObjectsInRadius(x, y, 800)) do

			callSign = obj:getCallSign()

			if callSign == "ESS Odysseus" then
				dockable = true
			end

		end

		if dockable == true then
			essody23:destroy()

				odysseus:addCustomButton("Relay", "Launch ESSODY23", "Launch ESSODY23", launch_essody23)
		else
			essody23:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
		end

	end



	function launch_essody36()

	x, y = odysseus:getPosition()

		essody36 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(x, y + 100)
		essody36:setCallSign("ESSODY36"):setAutoCoolant(true)

		odysseus:removeCustom("Launch ESSODY36")
		essody36:addCustomButton("Helms", "Dock to Odysseys", "Dock to Odysseys", dock_essody36)

	end

	function dock_essody36()

		x, y = essody36:getPosition()

		dockable = false

		for _, obj in ipairs(getObjectsInRadius(x, y, 800)) do

			callSign = obj:getCallSign()

			if callSign == "ESS Odysseus" then
				dockable = true
			end

		end

		if dockable == true then
			essody36:destroy()

				ship:addCustomButton("Relay", "Launch ESSODY36", "Launch ESSODY36", launch_essody36)
		else
				essody36:addCustomMessage("Helms", "Distance too far. Docking canceled.", "Distance too far. Docking canceled.")
		end


	end
