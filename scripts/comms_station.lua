function mainMenu()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	
	if player:isEnemy(comms_target) then
		return false
	end

	if player:isFriendly(comms_target) then
		if comms_target:areEnemiesInRange(5000) then
			setCommsMessage("We are under attack! No time for chatting!");
			return true
		end
		if not player:isDocked(comms_target) then
			setCommsMessage("Good day officer,\nIf you need supplies please dock with us first.");
			addCommsReply("Can you send a supply drop? (100rep)", function()
                if player:getWaypointCount() < 1 then
                    setCommsMessage("You need to set a waypoint before you can request backup.");
                else
                    setCommsMessage("Where do we need to drop off your supplies?");
                    for n=1,player:getWaypointCount() do
                        addCommsReply("WP" .. n, function()
                            if player:takeReputationPoints(100) then
                                local position_x, position_y = comms_target:getPosition()
                                local target_x, target_y = player:getWaypoint(n)
                                local script = Script()
                                script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                                script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                                script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                                setCommsMessage("We have dispatched a supply ship towards WP" .. n);
                            else
                                setCommsMessage("Not enough rep!");
                            end
                            addCommsReply("Back", mainMenu)
                        end)
                    end
                end
				addCommsReply("Back", mainMenu)
			end)
			addCommsReply("Please send backup! (150rep)", function()
                if player:getWaypointCount() < 1 then
                    setCommsMessage("You need to set a waypoint before you can request backup.");
                else
                    setCommsMessage("Where does the backup needs to go?");
                    for n=1,player:getWaypointCount() do
                        addCommsReply("WP" .. n, function()
                            if player:takeReputationPoints(150) then
                                ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setShipTemplate("Fighter"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                                setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                            else
                                setCommsMessage("Not enough rep!");
                            end
                            addCommsReply("Back", mainMenu)
                        end)
                    end
                end
                addCommsReply("Back", mainMenu)
			end)
			return true
		end
		
		-- Friendly station, docked.
		setCommsMessage("Good day officer,\nWhat can we do for you today?")
		addCommsReply("Do you have spare homing missiles for us? (2rep each)", function()
			if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not player:takeReputationPoints(2 * (player:getWeaponStorageMax("Homing") - player:getWeaponStorage("Homing"))) then setCommsMessage("Not enough reputation."); return end
			if player:getWeaponStorage("Homing") >= player:getWeaponStorageMax("Homing") then
				setCommsMessage("Sorry sir, but you are fully stocked with homing missiles.");
				addCommsReply("Back", mainMenu)
			else
				player:setWeaponStorage("Homing", player:getWeaponStorageMax("Homing"))
				setCommsMessage("Filled up your missile supply.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our mines. (2rep each)", function()
			if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not player:takeReputationPoints(2 * (player:getWeaponStorageMax("Mine") - player:getWeaponStorage("Mine"))) then setCommsMessage("Not enough reputation."); return end
			if player:getWeaponStorage("Mine") >= player:getWeaponStorageMax("Mine") then
				setCommsMessage("Captain,\nYou have all the mines you can fit in that ship.");
				addCommsReply("Back", mainMenu)
			else
				player:setWeaponStorage("Mine", player:getWeaponStorageMax("Mine"))
				setCommsMessage("These mines, are yours.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Can you supply us with some nukes. (15rep each)", function()
			if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not player:takeReputationPoints(15 * (player:getWeaponStorageMax("Nuke") - player:getWeaponStorage("Nuke"))) then setCommsMessage("Not enough reputation."); return end
			if player:getWeaponStorage("Nuke") >= player:getWeaponStorageMax("Nuke") then
				setCommsMessage("All nukes are charged and primed for distruction.");
				addCommsReply("Back", mainMenu)
			else
				player:setWeaponStorage("Nuke", player:getWeaponStorageMax("Nuke"))
				setCommsMessage("You are fully loaded,\nand ready to explode things.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our EMP Missiles. (10rep each)", function()
			if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not player:takeReputationPoints(10 * (player:getWeaponStorageMax("EMP") - player:getWeaponStorage("EMP"))) then setCommsMessage("Not enough reputation."); return end
			if player:getWeaponStorage("EMP") >= player:getWeaponStorageMax("EMP") then
				setCommsMessage("All storage for EMP missiles is filled sir.");
				addCommsReply("Back", mainMenu)
			else
				player:setWeaponStorage("EMP", player:getWeaponStorageMax("EMP"))
				setCommsMessage("Recallibrated the electronics and\nfitted you with all the EMP missiles you can carry.")
				addCommsReply("Back", mainMenu)
			end
		end)
	else
		if not player:isDocked(comms_target) then
			setCommsMessage("Greetings sir.\nIf you want to do business please dock with us first.");
			return true
		end
		
		-- Neutral station
		setCommsMessage("Welcome to our lovely station")
		addCommsReply("Do you have spare homing missiles for us? (5rep each)", function()
			if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if player:getWeaponStorage("Homing") >= player:getWeaponStorageMax("Homing") / 2 then
				setCommsMessage("You seem to have more then enough missiles");
				addCommsReply("Back", mainMenu)
			else
				if not player:takeReputationPoints(5 * ((player:getWeaponStorageMax("Homing") / 2) - player:getWeaponStorage("Homing"))) then setCommsMessage("Not enough reputation."); return end
				player:setWeaponStorage("Homing", player:getWeaponStorageMax("Homing") / 2)
				setCommsMessage("We generously resupplied you with some free homing missiles.\nPut them to good use.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our mines. (5rep each)", function()
			if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if player:getWeaponStorage("Mine") >= player:getWeaponStorageMax("Mine") then
				setCommsMessage("You are fully stocked with mines.");
				addCommsReply("Back", mainMenu)
			else
				if not player:takeReputationPoints(5 * (player:getWeaponStorageMax("Mine") - player:getWeaponStorage("Mine"))) then setCommsMessage("Not enough reputation."); return end
				player:setWeaponStorage("Mine", player:getWeaponStorageMax("Mine"))
				setCommsMessage("Here, have some mines.\nMines are good defensive weapons.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Can you supply us with some nukes.", function()
			setCommsMessage("We do not deal in weapons of mass destruction.")
			addCommsReply("Back", mainMenu)
		end)
		addCommsReply("Please re-stock our EMP Missiles.", function()
			setCommsMessage("We do not deal in weapons of mass disruption.")
			addCommsReply("Back", mainMenu)
		end)
	end
end
mainMenu()
