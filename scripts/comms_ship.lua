-- Name: Basic ship comms
-- Description: Simple ship comms that allows setting orders if friendly. Default script for any cpuShip.

function mainMenu()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	
	if player:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if player:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentified() then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end

function friendlyComms(comms_data)
	if comms_data.friendlyness < 0.2 then
		setCommsMessage("What the fuck do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("Defend a location", function()
		if player:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set, please set a waypoint first.");
		else
			setCommsMessage("Which waypoint do we need to defend?");
			for n=1,player:getWaypointCount() do
				addCommsReply("Defend at WP" .. n, function()
					comms_target:orderDefendLocation(player:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n);
					addCommsReply("Back", mainMenu)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading towards you to assist you");
			comms_target:orderDefendTarget(player)
			addCommsReply("Back", mainMenu)
		end)
	end
	addCommsReply("What is your status?", function()
		msg = "Front Shields: " .. math.floor(comms_target:getFrontShield() / comms_target:getFrontShieldMax() * 100) .. "%\n"
		msg = msg .. "Rear Shields: " .. math.floor(comms_target:getRearShield() / comms_target:getRearShieldMax() * 100) .. "%\n"
		msg = msg .. "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		if comms_target:getWeaponStorageMax("Homing") > 0 then
			msg = msg .. "Missiles: " .. comms_target:getWeaponStorage("Homing") .. "/" .. comms_target:getWeaponStorageMax("Homing") .. "\n"
		end

		setCommsMessage(msg);
		comms_target:orderDefendTarget(player)
		addCommsReply("Back", mainMenu)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign());
				comms_target:orderDock(obj)
				addCommsReply("Back", mainMenu)
			end)
		end
	end
	return true
end

function enemyComms(comms_data)
	if comms_data.friendlyness > 0.5 then
		faction = comms_target:getFaction()
		taunt_option = "We will see to your destruction!"
		taunt_success_reply = "Your bloodline will end here!"
		taunt_failed_reply = "Your feable threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nDieeee weaklingsss!");
		elseif faction == "Arlenians" then
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			setCommsMessage("Your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal english.\nGenerating approprate response for target\n:Do not fucking cross us:\nCommunication halted.");
		else
			setCommsMessage("Mind your own buisness!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 0.1)
		addCommsReply(taunt_option, function()
			if random(0, 100) < 30 then
				comms_target:orderAttack(player)
				setCommsMessage(taunt_success_reply);
			else
				setCommsMessage(taunt_failed_reply);
			end
		end)
		return true
	end
	return false
end

function neutralComms(comms_data)
	if comms_data.friendlyness > 0.5 then
		setCommsMessage("Sorry, no time to chat with you.\nWe are on an important mission.");
	else
		setCommsMessage("We have nothing for you.\nGood day.");
	end
	return true
end

mainMenu()
