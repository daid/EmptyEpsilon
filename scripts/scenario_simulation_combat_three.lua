-- Name: Fighter practice - 3 fighters
-- Description: Fighter practice - 3 EOC vs. 1 Predator
-- Type: Basic
-- Variation[3-2-0-0]: Three EOC against two machine Predators
-- Variation[3-3-0-0]: Three EOC against three machine Predators
-- Variation[3-5-0-0]: Three EOC against five machine Predators
-- Variation[3-0-1-0]: Three EOC against one machine Reapers
-- Variation[3-0-0-1]: Three EOC against one machine Stinger
-- Variation[3-1-1-0]: Three EOC against one machine Predator and one machine Reaper
-- Variation[3-1-0-1]: Three EOC against one machine Predator and one machine Stinger


function init()

	simulation01 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(0, 0)
	simulation01:setCallSign("Sim01"):setAutoCoolant(true)

	simulation02 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(0, 500)
	simulation02:setCallSign("Sim02"):setAutoCoolant(true)

	simulation03 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(0, -500)
	simulation03:setCallSign("Sim03"):setAutoCoolant(true)
		

	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()

if getScenarioVariation() == "3-2-0-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2500):orderRoaming()
end

if getScenarioVariation() == "3-3-0-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2500):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -3000):orderRoaming()
end

if getScenarioVariation() == "3-5-0-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2500):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -3000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -3500):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(9500, -3000):orderRoaming()
end

if getScenarioVariation() == "3-0-1-0" then
	CpuShip():setFaction("Machines"):setTemplate("Cruiser Reaper"):setCallSign("CRU1"):setPosition(10000, -2000):orderRoaming()
end

if getScenarioVariation() == "3-0-0-1" then
	CpuShip():setFaction("Machines"):setTemplate("Frigate Stinger"):setCallSign("FRI1"):setPosition(10000, -2500):orderRoaming()
end

if getScenarioVariation() == "3-1-1-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Cruiser Reaper"):setCallSign("CRU1"):setPosition(10000, -2500):orderRoaming()
end

if getScenarioVariation() == "3-1-0-1" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Frigate Stinger"):setCallSign("FRI1"):setPosition(10000, -2500):orderRoaming()
end

	addGMFunction("Reset scenario", resetScen)

end

function update(delta)


end
