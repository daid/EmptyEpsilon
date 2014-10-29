function mainMenu()
	if player:isFriendly(comms_target) then
		setCommsMessage("Sir, how can we assist?");
		addCommsReply("Defend a location", function()
			if player:getWaypointCount() == 0 then
				setCommsMessage("No waypoints set, please set a waypoint first.");
			else
				setCommsMessage("Which waypoint do we need to defend?");
				for n=0,player:getWaypointCount()-1 do
					addCommsReply("Defend at WP" .. n, function()
						comms_target:orderDefendLocation(player:getWaypoint(n))
						setCommsMessage("We are heading to assist at WP" .. n);
						addCommsReply("Back", mainMenu)
					end)
				end
			end
		end)
		return true
	end
	if player:isEnemy(comms_target) then
		return false
	end
	setCommsMessage("We have nothing for you.\nGood day.");
end
mainMenu()
