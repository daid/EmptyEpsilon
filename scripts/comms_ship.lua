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
	if player:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(player) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end

function fleetOrders(comms_target, distance, formation)
	fleet = comms_target:getLeadership()
	for n=1,player:getFleetSize(fleet)-1 do
		fleet_member = player:getFleetMember(fleet, n)
		fleet_member:orderFlyFleetFormation(comms_target, n, distance, formation)
	end
end

function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("Defend a waypoint", function()
		if player:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", mainMenu)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,player:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(player:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
					addCommsReply("Back", mainMenu)
				end)
			end
		end
	end)
	if comms_target:getLeadership() > 0 then
		addCommsReply("Fleet order", function()
			setCommsMessage("Waiting for orders.");
			addCommsReply("Disband your fleet", function()
				setCommsMessage("OK. Fleet " .. comms_target:getLeadership() .." has been disanded.");
				player:disbandFleet(comms_target:getLeadership())
				addCommsReply("Back", mainMenu)
			end)
			addCommsReply("Change formation", function()
				setCommsMessage("Set the formation.");
				addCommsReply("Formation HLine Close", function()
					fleetOrders(comms_target, 500, 1)
					setCommsMessage("Formation changed to HLine Close.");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Formation HLine Spread", function()
					fleetOrders(comms_target, 3000, 1)
					setCommsMessage("Formation changed to HLine Spread.");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Formation Arrow Close", function()
					fleetOrders(comms_target, 500, 2)
					setCommsMessage("Formation changed to Arrow Close.");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Formation Arrow Spread", function()
					fleetOrders(comms_target, 3000, 2)
					setCommsMessage("Formation changed to Arrow Spread.");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Formation Pyramid Close", function()
					fleetOrders(comms_target, 500, 3)
					setCommsMessage("Formation changed to Pyramid Close.");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Formation Pyramid Spread", function()
					fleetOrders(comms_target, 3000, 3)
					setCommsMessage("Formation changed to Pyramid Spread.");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Back", mainMenu)
			end)
		end)
	else
		addCommsReply("Join a fleet", function()
			if player:getFleetCount() == 0 then
				setCommsMessage("No fleet leader set. Please set a fleet leader first.");
				addCommsReply("You are the leader of a brand new fleet !", function()
					player:createFleet(comms_target)
					setCommsMessage("I am honored to be the leader of Fleet" .. comms_target:getLeadership() .. ".");
					addCommsReply("Back", mainMenu)
				end)
				addCommsReply("Back", mainMenu)
			else
				setCommsMessage("Which fleet should we join ?");
				addCommsReply("You are the leader of a brand new fleet !", function()
					player:createFleet(comms_target)
					setCommsMessage("I am honored to be the leader of Fleet" .. comms_target:getLeadership() .. ".");
					addCommsReply("Back", mainMenu)
				end)
				for n=1,player:getFleetCount() do
					addCommsReply("Join Fleet " .. n, function()
						player:setFleetMember(n, comms_target)
						comms_target:orderFlyFleetFormation(player:getFleetLeader(n), player:getFleetMemberId(n, comms_target), 500, 1)
						setCommsMessage("We are heading to assist Fleet " .. n ..".");
						addCommsReply("Back", mainMenu)
					end)
				end
			end
		end)
	end
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(player)
			addCommsReply("Back", mainMenu)
		end)
	end
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. "Front Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. "Rear Shield: " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end

		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " Missiles: " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end

		setCommsMessage(msg);
		addCommsReply("Back", mainMenu)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", mainMenu)
			end)
		end
	end
	return true
end

function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = "We will see to your destruction!"
		taunt_success_reply = "Your bloodline will end here!"
		taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
		elseif faction == "Arlenians" then
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)
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
	if comms_data.friendlyness > 50 then
		setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
	else
		setCommsMessage("We have nothing for you.\nGood day.");
	end
	return true
end

mainMenu()
