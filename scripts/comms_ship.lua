-- Name: Basic ship comms
-- Description: Simple ship comms that allows setting orders if friendly. Default script for any cpuShip.

function mainMenu()
	if player:isFriendly(comms_target) then
		setCommsMessage("Sir, how can we assist?");
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
		addCommsReply("Assist me", function()
			setCommsMessage("Heading towards you to assist you");
			comms_target:orderDefendTarget(player)
			addCommsReply("Back", mainMenu)
		end)
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
	if player:isEnemy(comms_target) then
		return false
	end
	setCommsMessage("We have nothing for you.\nGood day.");
end
mainMenu()
