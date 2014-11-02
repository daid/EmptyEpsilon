function init()
	my_ship = CpuShip():setCommsScript(""):setFactionId(faction_id):setPosition(position_x, position_y):setShipTemplate("Tug"):setScanned(true):orderFlyTowardsBlind(target_x, target_y)
	state = 0
end

function update(delta)
	if not my_ship:isValid() then
		destroyScript()
		return
	end
	local x, y = my_ship:getPosition()
	if state == 0 then
		if math.abs(x - target_x) < 300 and math.abs(y - target_y) < 300 then
			SupplyDrop():setPosition(target_x, target_y):setEnergy(500):setWeaponStorage("Nuke", 1):setWeaponStorage("Homing", 4):setWeaponStorage("Mine", 2):setWeaponStorage("EMP", 1)
			my_ship:orderFlyTowardsBlind(position_x, position_y)
			state = 1
		end
	elseif state == 1 then
		if math.abs(x - position_x) < 500 and math.abs(y - position_x) < 500 then
			my_ship:destroy()
			destroyScript()
			return
		end
	end
end
