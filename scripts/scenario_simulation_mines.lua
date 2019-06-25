-- Name: Fighter race - Mines
-- Type: Race
-- Description: Mine field! How fast you can go? Going around the mine field is not a solution, it will break your fighter! Once you finish the race, your time will show up at top left corner.

require("utils.lua")
require("utils_odysseus.lua")


function init()

	passTime = 0
	plotZ = delayChecks
	delayCheck = 0
	seconds = 0

		simulation01 = PlayerSpaceship():setFaction("EOC Starfleet"):setTemplate("Fighter F967"):setPosition(0, 0)
		simulation01:setCallSign("simulation01"):setAutoCoolant(true)
		
		startZone = Zone():setColor(0, 0, 255)
		startZone:setPoints(1000, -10000,
							-1000, -10000,
							-1000, 10000,
							1000, 10000)
		
		endZone = Zone():setColor(0, 0, 255)
		endZone:setPoints(51000, -10000,
							55000, -10000,
							55000, 10000,
							51000, 10000)		
							
		southZone = Zone():setColor(255, 0, 0)
		southZone:setPoints(-1000, 10000,
							-1000, 20000,
							55000, 20000,
							55000, 10000)	
							
		northZone = Zone():setColor(255, 0, 0)
		northZone:setPoints(-1000, -10000,
							-1000, -20000,
							55000, -20000,
							55000, -10000)	
							

        for n=1,150 do

			Mine():setPosition(random(1000, 51000), random(-10000, 10000))

        end


end

function delayChecks(delta)

	if northZone:isInside(simulation01) or
		southZone:isInside(simulation01) then
		
		simulation01:commandSetAlertLevel("yellow")
		dropHealth(simulation01)
	else
		simulation01:commandSetAlertLevel("normal")
	end

	if not startZone:isInside(simulation01) and
	not endZone:isInside(simulation01) then 
		passTime = passTime + 1
	end
		
	if endZone:isInside(simulation01) then
		passTime = passTime / 60
		simulation01:addCustomInfo("Helms", "Route passed!", passTime)
	end

end



function dropHealth(ship)
					systemHit = math.random(1,30)
				if systemHit == 1 then
					ship:setSystemHealth("reactor", ship:getSystemHealth("reactor")*.99)
				elseif systemHit == 2 then
					ship:setSystemHealth("beamweapons", ship:getSystemHealth("beamweapons")*.99)
				elseif systemHit == 3 then
					ship:setSystemHealth("maneuver", ship:getSystemHealth("maneuver")*.99)
				elseif systemHit == 4 then
					ship:setSystemHealth("missilesystem", ship:getSystemHealth("missilesystem")*.99)
				elseif systemHit == 5 then
					ship:setSystemHealth("frontshield", ship:getSystemHealth("frontshield")*.99)
				elseif systemHit == 6 then
					ship:setSystemHealth("impulse", ship:getSystemHealth("impulse")*.99)
				else
					ship:setSystemHealth("rearshield", ship:getSystemHealth("rearshield")*.99)
				end


end

function update(delta)
	if delta == 0 then
		return
		--game paused
	end

	if plotZ ~= nil then
		plotZ(delta)
	end

end
