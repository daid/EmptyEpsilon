-- Name: NSA
-- Description: For Ghost from the Past mission

function mainMenu()
	setCommsMessage("The Nosy Sensing Array deploys a phalanx of antique sensors, ready for action.");
		addCommsReply("Locate the infected Swarm Commander", function()
			if (comms_target:getDescription()=="Nosy Sensing Array, an old SIGINT platform. The signal is now crystal-clear.") then
			setCommsMessage("Now that there is no parasite noise, picking the Hive signal is now easier, with an approximate heading of ".. find(35000, 53000, 20) .. ". With this information, it will be easier to track down Swarm Commander.")
			comms_target:setDescription("Nosy Sensing Array, an old SIGINT platform. The Ktlitan Commander is located.")
			else
			setCommsMessage("The signal picks up a very strong signal at approximate heading ".. find(-10000, -20000, 20) .. ". However, it seems that you picked up garbage emission that masks the Swarm Commander's emissions. This garbage noise must be taken offline if you want to find the Swarm Commander.")
			end
		end)
		if	player:getDescription()=="Arlenian Device" then
			addCommsReply("Install the Arlenian Device", function()
				if (distance(player, comms_target) < 2000) then
				setCommsMessage("A part of the crew goes on EVA to install the device. After a few hours, they come back, telling that the device is operational.")
				player:setDescription("Arlenian Device Installed")
				else
				setCommsMessage("You are too far to install the Arlenian device on the Array.")
				end
			end)
		end
end

function find(x_target, y_target, randomness)
	pi = 3.14
	x_player, y_player = player:getPosition()
	angle = round(((random(-randomness, randomness) + 270 + 180 * math.atan2(y_player - y_target, x_player - x_target) / 3.14) % 360), 1)
	return angle
end

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function distance(obj1, obj2)
    x1, y1 = obj1:getPosition()
    x2, y2 = obj2:getPosition()
    xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

mainMenu()
