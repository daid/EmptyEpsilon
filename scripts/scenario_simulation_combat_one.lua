-- Name: Fighter practice - 1 fighter
-- Description: Fighter practice - Basic variation 1 EOC vs. 1 Machine Predator
-- Type: Basic
-- Variation[1-2-0-0]: One EOC against two machine Predators
-- Variation[1-3-0-0]: One EOC against three machine Predators
-- Variation[1-5-0-0]: One EOC against five machine Predators
-- Variation[1-0-1-0]: One EOC against one machine Reapers
-- Variation[1-0-0-1]: One EOC against one machine Stinger
-- Variation[1-1-1-0]: One EOC against one machine Predator and one machine Reaper
-- Variation[1-1-0-1]: One EOC against one machine Predator and one machine Stinger


function init()

	simulation01 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(0, 0)
	simulation01:setCallSign("Sim01"):setAutoCoolant(true)
	
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()

if getScenarioVariation() == "1-2-0-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2500):orderRoaming()
end

if getScenarioVariation() == "1-3-0-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2500):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -3000):orderRoaming()
end

if getScenarioVariation() == "1-5-0-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2500):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -3000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -3500):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(9500, -3000):orderRoaming()
end

if getScenarioVariation() == "1-0-1-0" then
	CpuShip():setFaction("Machines"):setTemplate("Cruiser Reaper"):setCallSign("CRU1"):setPosition(10000, -2000):orderRoaming()
end

if getScenarioVariation() == "1-0-0-1" then
	CpuShip():setFaction("Machines"):setTemplate("Frigate Stinger"):setCallSign("FRI1"):setPosition(10000, -2500):orderRoaming()
end

if getScenarioVariation() == "1-1-1-0" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Cruiser Reaper"):setCallSign("CRU1"):setPosition(10000, -2500):orderRoaming()
end

if getScenarioVariation() == "1-1-0-1" then
	CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setCallSign("FGT1"):setPosition(10000, -2000):orderRoaming()
	CpuShip():setFaction("Machines"):setTemplate("Frigate Stinger"):setCallSign("FRI1"):setPosition(10000, -2500):orderRoaming()
end

end



function update(delta)


end
