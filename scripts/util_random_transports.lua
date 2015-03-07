stationList = {}
transportList = {}
spawn_delay = 0

function vectorFromAngle(angle, length)
	return math.cos(angle / 180 * math.pi) * length, math.sin(angle / 180 * math.pi) * length
end

function init()
	tmp = SupplyDrop()
	for _, obj in ipairs(tmp:getObjectsInRange(100000)) do
		if obj.typeName == "SpaceStation" then
			table.insert(stationList, obj)
		end
	end
	tmp:destroy()
end

function randomStation()
	idx = math.floor(random(1, #stationList + 0.99))
	return stationList[idx]
end

function update(delta)
	cnt = 0
	for idx, obj in ipairs(transportList) do
		if not obj:isValid() then
			--Transport destroyed, remove it from the list
			table.remove(transportList, idx)
		else
			if obj:isDocked(obj.target) then
				if obj.undock_delay > 0 then
					obj.undock_delay = obj.undock_delay - delta
				else
					obj.target = randomStation()
					obj.undock_delay = random(5, 30)
					obj:orderDock(obj.target)
				end
			end
			cnt = cnt + 1
		end
	end

	if spawn_delay >= 0 then
		spawn_delay = spawn_delay - delta
	end

	if cnt < #stationList then
		if spawn_delay < 0 then
			spawn_delay = random(30, 50)
			
			obj = CpuShip():setShipTemplate('Tug'):setFaction('Independent')
			obj.target = randomStation()
			obj.undock_delay = random(5, 30)
			obj:orderDock(obj.target)
			x, y = obj.target:getPosition()
			xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			table.insert(transportList, obj)
		end
	end
end