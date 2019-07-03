-- Name: Odysseus utils
-- Fighters 20
-- Frigates 5
-- Cruisers 1

function wave_north(x, y, ship)
	ship:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 0.", "Red")
	spawn_wave(x, y-60000)
end

function wave_east(x, y, ship)
	ship:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 90.", "Red")
	spawn_wave(x+60000, y)
end

function wave_west(x, y, ship)
	ship:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 270.", "Red")
	spawn_wave(x-60000, y)
end

function wave_south(x, y, ship)
	ship:addToShipLog("EVA sector scanner alarm. Multiple incoming jumps detected from heading 180.", "Red")
	spawn_wave(x, y+60000)
end

	function spawn_wave(x, y)
	    for n=1, 30 do
	        local r = random(0, 360)
	        local distance = random(1000, 30000)
	        x1 = x + math.cos(r / 180 * math.pi) * distance
	        y1 = y + math.sin(r / 180 * math.pi) * distance
	        CpuShip():setFaction("Machines"):setTemplate("Fighter Predator"):setPosition(x1, y1):orderRoaming(x, y)
	    end
			for n=1, 5 do
	        local r = random(0, 360)
	        local distance = random(3000, 20000)
	        x1 = x + math.cos(r / 180 * math.pi) * distance
	        y1 = y + math.sin(r / 180 * math.pi) * distance
	        CpuShip():setFaction("Machines"):setTemplate("Frigate Stinger"):setPosition(x1, y1):orderRoaming(x, y)
	    end
	       CpuShip():setFaction("Machines"):setTemplate("Cruiser Reaper"):setPosition(x, y):orderRoaming(x, y)
	end
