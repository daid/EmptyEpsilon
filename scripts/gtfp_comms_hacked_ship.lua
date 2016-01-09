-- Name: Hacked ship comms
-- Description: For Ghost from the Past

function mainMenu()
	if distance(player, comms_target) < 3000 then
	setCommsMessage("Static fills the channel. Target is on-range for near-range injection. Select the band to attack :");
		addCommsReply("400-450 THz", function()
		compare(400, 450)
		end)
		addCommsReply("450-500 THz", function()
		compare(450, 500)
		end)
		addCommsReply("500-550 THz", function()
		compare(500, 550)
		end)
		addCommsReply("550-600 THz", function()
		compare(550, 600)
		end)
		addCommsReply("600-650 THz", function()
		compare(600, 650)
		end)
		addCommsReply("650-700 THz", function()
		compare(650, 700)
		end)
		addCommsReply("700-750 THz", function()
		compare(700, 750)
		end)
		addCommsReply("750-800 THz", function()
		compare(750, 800)
		end)
	else
	setCommsMessage("Static fills the channel. It seems that the hacked ship is too far away for near-field injection.");	
	end
end

function compare(freq_min, freq_max)
frequency = 400 + (comms_target:getShieldsFrequency() * 20)
	if (freq_min <= frequency)  and (frequency <= freq_max) then
	setCommsMessage("Soon after, a backdoor channel opens, indicating that the near-field injection worked.");
	addCommsReply("Deploy patch", function()
	comms_target:setFaction("Human Navy")
	setCommsMessage("The patch removes the exploit used to control remotely the ship. After a few seconds, the captain comes in : You saved us ! Hurray for Epsilon !");
	end)
	else
	setCommsMessage("Nothing happens. Seems that the near-field injection failed.");
	end
end

function distance(obj1, obj2)
    x1, y1 = obj1:getPosition()
    x2, y2 = obj2:getPosition()
    xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
end

mainMenu()
