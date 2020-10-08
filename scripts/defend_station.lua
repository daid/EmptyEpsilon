--	Supporting script for a station's defensive fleet.
--	In the main script, the station will need a defensive fleet attached/defined.
--	For example:
--	station_1 = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy")
--	station_1.comms_data = {
--		idle_defense_fleet = {
--			DF1 = "MT52 Hornet",
--			DF2 = "MT52 Hornet",
--			DF3 = "Adder MK5",
--			DF4 = "Adder MK5",
--			DF5 = "Phobos T3",
--		}
--	}
require("utils.lua")
function init()
	check_interval = random(4,6)
	check_timer = check_interval
	inactivity_count = 0
	inactivity_max = 300
	local objects = getObjectsInRadius(position_x, position_y, 100)	--position_[x|y] set by calling script
	for _, object in ipairs(objects) do
		if object.typeName == "SpaceStation" then
			if object:getCallSign() == station_name then	--station_name set by calling script
				my_station = object
				break
			end
		end
	end
	if my_station == nil then
		destroyScript()
		return
	end
	--name, faction _id and template set by calling script
	my_ship = CpuShip():setCallSign(string.format("%s %s",station_name,name)):setCommsScript("comms_defend.lua"):setFactionId(faction_id):setPosition(position_x, position_y):setTemplate(template):setScanned(true):orderDefendTarget(my_station)
end
function shipHealthy()
	if my_ship:getHull() < my_ship:getHullMax() then return false end
	if my_ship:getSystemHealth("reactor") <  my_ship:getSystemHealthMax("reactor") then return false end
	if my_ship:getSystemHealth("impulse") <  my_ship:getSystemHealthMax("impulse") then return false end
	if my_ship:getSystemHealth("maneuver") <  my_ship:getSystemHealthMax("maneuver") then return false end
	if my_ship:getBeamWeaponRange(0) > 0 then
		if my_ship:getSystemHealth("beamweapons") <  my_ship:getSystemHealthMax("beamweapons") then return false end
	end
	if my_ship:getWeaponTubeCount() > 0 then
		if my_ship:getSystemHealth("missilesystem") <  my_ship:getSystemHealthMax("missilesystem") then return false end
	end
	if my_ship:hasWarpDrive() then
		if my_ship:getSystemHealth("warp") <  my_ship:getSystemHealthMax("warp") then return false end
	end
	if my_ship:hasJumpDrive() then
		if my_ship:getSystemHealth("jumpdrive") <  my_ship:getSystemHealthMax("jumpdrive") then return false end
	end
	if my_ship:getShieldCount() > 0 then
		if my_ship:getSystemHealth("frontshield") <  my_ship:getSystemHealthMax("frontshield") then return false end
	end
	if my_ship:getShieldCount() > 1 then
		if my_ship:getSystemHealth("rearshield") <  my_ship:getSystemHealthMax("rearshield") then return false end
	end
	return true
end
function shipFull()
	if my_ship:getWeaponTubeCount() > 0 then
		if my_ship:getWeaponStorage("Homing") < my_ship:getWeaponStorageMax("Homing") then return false end
		if my_ship:getWeaponStorage("HVLI") < my_ship:getWeaponStorageMax("HVLI") then return false end
		if my_ship:getWeaponStorage("EMP") < my_ship:getWeaponStorageMax("EMP") then return false end
		if my_ship:getWeaponStorage("Nuke") < my_ship:getWeaponStorageMax("Nuke") then return false end
	end
	return true
end
function update(delta)
	if not my_ship:isValid() then
		destroyScript()
		return
	end
	if my_station ~= nil and my_station:isValid() then
		check_timer = check_timer - delta
		if check_timer < 0 then
			local ship_healthy = shipHealthy()
			local ship_full = shipFull()
			if my_ship:isDocked(my_station) then
				if my_station:areEnemiesInRange(10000) then
					my_ship:orderDefendTarget(my_station)
				else
					if ship_healthy and ship_full then
						my_ship:orderDefendTarget(my_station)
					end
				end
			else
				if my_station:areEnemiesInRange(10000) then
					my_ship:orderDefendTarget(my_station)
				else
					if not ship_healthy then
						my_ship:orderDock(my_station)
					else
						if not ship_full then
							if not my_station:areEnemiesInRange(15000) then
								my_ship:orderDock(my_station)
							end
						end
					end
				end
			end
			if ship_healthy and ship_full then
				inactivity_count = inactivity_count + check_interval
			else
				inactivity_count = 0
			end
			if inactivity_count > inactivity_max then
				my_station.comms_data.idle_defense_fleet[name] = my_ship:getTypeName()
				my_ship:destroy()
				destroyScript()
			end
			check_timer = check_interval
		end
	else
		my_ship:setCommsScript("comms_ship.lua")
		destroyScript()
	end
end
