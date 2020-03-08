require("options.lua")
require(lang .. "/comms.lua")

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

function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(shipComms_neutralGreetings);
	else
		setCommsMessage(shipComms_friendlyGreetings);
	end
	addCommsReply(shipComms_requireWaypointProtection, function()
		if player:getWaypointCount() == 0 then
			setCommsMessage(shipComms_waypointRequiredForProtection);
			addCommsReply(commonComms_back, mainMenu)
		else
			setCommsMessage(shipComms_protectedWaypoint);
			for n=1,player:getWaypointCount() do
				addCommsReply(waypointShort .. n, function()
					comms_target:orderDefendLocation(player:getWaypoint(n))
					setCommsMessage(shipComms_headingToWaypoint(n));
					addCommsReply(commonComms_back, mainMenu)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(shipComms_assistMe, function()
			setCommsMessage(shipComms_headingTowardsYou);
			comms_target:orderDefendTarget(player)
			addCommsReply(commonComms_back, mainMenu)
		end)
	end
	addCommsReply(shipComms_reportStatus, function()
		msg = shipComms_hull .. ": " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. shipComms_shield .. ": " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. shipComms_frontShield .. ": " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. shipComms_rearShield .. ": " .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. shipComms_shield .. " " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end

		missile_types = {shipComms_homings, shipComms_nukes, shipComms_mines, shipComms_emp, shipComms_hvli}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " : " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end

		setCommsMessage(msg);
		addCommsReply(commonComms_back, mainMenu)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(shipComms_dockAt(obj:getCallSign()), function()
				setCommsMessage(shipComms_dockingAt(obj:getCallSign()) .. ".");
				comms_target:orderDock(obj)
				addCommsReply(commonComms_back, mainMenu)
			end)
		end
	end
	return true
end

function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = shipComms_defaultTaunt
		taunt_success_reply = shipComms_defaultTauntSuccess
		taunt_failed_reply = shipComms_defaultTauntFail
		if faction == kraylorFaction then
			setCommsMessage(shipComms_kraylor);
		elseif faction == arleniansFaction then
			setCommsMessage(shipComms_arlenians);
		elseif faction == exuariFaction then
			setCommsMessage(shipComms_exuari);
		elseif faction == gitmFaction then
			setCommsMessage(shipComms_ghosts);
			taunt_option = shipComms_ghostsTaunt
			taunt_success_reply = shipComms_ghostsTauntSuccess
			taunt_failed_reply = shipComms_ghostsTauntFail
		elseif faction == hiveFaction then
			setCommsMessage(shipComms_ktlitans);
			taunt_option = shipComms_ktlitansTaunt
			taunt_success_reply = shipComms_ktlitansTauntSuccess
			taunt_failed_reply = shipComms_ktlitansTauntFail
		else
			setCommsMessage(shipComms_mindYourBusiness);
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
		setCommsMessage(shipComms_friendlyDismiss);
	else
		setCommsMessage(shipComms_neutralDismiss);
	end
	return true
end

mainMenu()
