-- Name: 001 Test template
-- Description: Empty scenario, no enemies, no friendlies. Can be used by a GM player to setup a scenario in the GM screen. The F5 key can be used to copy the current layout to the clipboard for use in scenario scripts.
-- Type: Basic

function init()



	 expfighter = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967")
	expfighter:setCallSign("Experimental Fighter"):setPosition(0, 0):setCanBeDestroyed(false)

	expfighter:addCustomButton("Helms", "Reset scenario", "Reset scenario", resetScen)


	CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setCallSign("FGT1"):setPosition(5000, -2000)
	CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setCallSign("CRU1"):setPosition(5000, 0)
	CpuShip():setFaction("Machines"):setTemplate("Machine Frigate"):setCallSign("FRI1"):setPosition(5000, 2000)



	addGMFunction("Reset scenario", resetScen)


end

function resetScen()

    --Clean up the current play field. Find all objects and destroy everything that is not a player.
    -- If it is a player, position him in the center of the scenario.
    for _, obj in ipairs(getAllObjects()) do
        if obj.typeName == "PlayerSpaceship" then
            obj:setPosition(0, 0)
        else
            obj:destroy()
        end
	end


	CpuShip():setFaction("Machines"):setTemplate("Machine Fighter"):setCallSign("FGT1"):setPosition(5000, -2000)
	CpuShip():setFaction("Machines"):setTemplate("Machine Cruiser"):setCallSign("CRU1"):setPosition(5000, 0)
	CpuShip():setFaction("Machines"):setTemplate("Machine Frigate"):setCallSign("FRI1"):setPosition(5000, 2000)


end




function update(delta)


end
