
function setScenarioChange(buttonText, scenarioLua)

	setChangeButton(buttonText, scenarioLua)

end

function setChangeButton(buttonText, scenarioLua)
	addGMFunction(
		_("Scenario", buttonText), function()
		--Remove the button to set up next scenario
		removeGMFunction(buttonText)
		setCancelChangeButton(buttonText, scenarioLua)
		setConfirmChangeButton(buttonText, scenarioLua)
		end)
end

function setCancelChangeButton(buttonText, scenarioLua)
	addGMFunction(
		_("Scenario", "Cancel change"),function()
		--Remove buttons when changeled
		removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
		setChangeButton(buttonText, scenarioLua)
	end)
end

function setConfirmChangeButton(buttonText, scenarioLua)
	addGMFunction(
		_("Scenario", "Confirm change"),function()
		removeGMFunction("Confirm change")
		setScenario(scenarioLua, "Null")
	end)
end

function changeScenarioCancel(buttonText, scenarioLua)
	removeGMFunction("Confirm change")
		removeGMFunction("Cancel change")
	addGMFunction(buttonText, changeScenarioPrep)
end