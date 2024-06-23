function setScenarioChange(nextScenario)

	if nextScenario == 1 then
		scenarioLua = "scenario_jump_01.lua"
		scenarioLuaCurrent = "scenario_jump_00.lua"
	elseif nextScenario == 2 then
		scenarioLua = "scenario_jump_02.lua"
		scenarioLuaCurrent = "scenario_jump_01.lua"
	elseif nextScenario == 3 then
		scenarioLua = "scenario_jump_03.lua"
		scenarioLuaCurrent = "scenario_jump_02.lua"
	elseif nextScenario == 4 then
		scenarioLua = "scenario_jump_04.lua"
		scenarioLuaCurrent = "scenario_jump_03.lua"
	elseif nextScenario == 5 then
		scenarioLua = "scenario_jump_05.lua"
		scenarioLuaCurrent = "scenario_jump_04.lua"
	elseif nextScenario == 6 then
		scenarioLua = "scenario_jump_06.lua"
		scenarioLuaCurrent = "scenario_jump_05.lua"
	elseif nextScenario == 7 then
		scenarioLua = "scenario_jump_07.lua"
		scenarioLuaCurrent = "scenario_jump_06.lua"
	elseif nextScenario == 8 then
		scenarioLua = "scenario_jump_08.lua"
		scenarioLuaCurrent = "scenario_jump_07.lua"
	elseif nextScenario == 9 then
		scenarioLua = "scenario_jump_09.lua"
		scenarioLuaCurrent = "scenario_jump_08.lua"
	elseif nextScenario == 10 then
		scenarioLua = "scenario_jump_10.lua"
		scenarioLuaCurrent = "scenario_jump_09.lua"
	elseif nextScenario == 11 then
		scenarioLua = "scenario_jump_11.lua"
		scenarioLuaCurrent = "scenario_jump_10.lua"
	elseif nextScenario == 12 then
		scenarioLua = "scenario_jump_12.lua"
		scenarioLuaCurrent = "scenario_jump_11.lua"
	elseif nextScenario == 13 then
		scenarioLua = "scenario_jump_13.lua"
		scenarioLuaCurrent = "scenario_jump_12.lua"
	elseif nextScenario == 14 then
		scenarioLua = "scenario_jump_14.lua"
		scenarioLuaCurrent = "scenario_jump_13.lua"
	elseif nextScenario == 15 then
		scenarioLua = "scenario_jump_15.lua"
		scenarioLuaCurrent = "scenario_jump_14.lua"
	elseif nextScenario == 16 then
		scenarioLua = "scenario_jump_16.lua"
		scenarioLuaCurrent = "scenario_jump_15.lua"
	elseif nextScenario == 17 then
		scenarioLua = "scenario_jump_17.lua"
		scenarioLuaCurrent = "scenario_jump_16.lua"
	elseif nextScenario == 18 then
		scenarioLua = "scenario_jump_18.lua"
		scenarioLuaCurrent = "scenario_jump_17.lua"
	end

	if scenarioMap == nil then
		scenarioMap = ""
	end
	currentJump = nextScenario-1
	addGMMessage("Jump " .. currentJump .. " loaded. \nScenario file: " .. scenarioLuaCurrent .. "\n" .. scenarioMap)

	scenarioButtonText = "Load Jump " .. nextScenario
	setChangeButton("Reload current Jump", scenarioLuaCurrent)
	setChangeButton(scenarioButtonText, scenarioLua)
end

function setChangeButton(scenarioButtonText, scenarioLua)
	addGMFunction(
		_("Scenario", scenarioButtonText), function()
		--Remove the button to set up next scenario
		setCancelChangeButton(scenarioButtonText, scenarioLua)
		setConfirmChangeButton(scenarioButtonText, scenarioLua)
		end)
end

function setCancelChangeButton(scenarioButtonText, scenarioLua)
	addGMFunction(
		_("Scenario", "Cancel load"),function()
		--Remove buttons when changeled
		removeGMFunction("Confirm load")
		removeGMFunction("Cancel load")
	end)
end

function setConfirmChangeButton(scenarioButtonText, scenarioLua)
	addGMFunction(
		_("Scenario", "Confirm load"),function()
		removeGMFunction("Confirm load")

		if odysseus:isLandingPadLaunched(1) then
			dock_essody18_force()
		end
		if odysseus:isLandingPadLaunched(2) then
			dock_essody23_force()
		end
		if odysseus:isLandingPadLaunched(3) then
			dock_essody36_force()
		end
		if odysseus:isLandingPadLaunched(4) then
			dock_starcaller_force()
		end
		setScenario(scenarioLua)
	end)
end

function changeScenarioCancel(scenarioButtonText, scenarioLua)
	removeGMFunction("Confirm load")
		removeGMFunction("Cancel load")
	addGMFunction(scenarioButtonText, changeScenarioPrep)
end