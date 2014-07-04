function mainMenu()
	if isEnemy() then
		return false
	end

	if not isDocked() then
		setCommsMessage("Greetings sir.\nIf you want to do business please dock with us first.");
		return true
	end

	if isFriendly() then
		-- Friendly station
		setCommsMessage("Good day captain,\nWhat can we do for you today?")
		addCommsReply("Do you have spare homing missiles for us?", function()
			if getWeaponStorage("Homing") >= getWeaponStorageMax("Homing") then
				setCommsMessage("Sorry sir, but you are fully stocked with homing missiles.");
				addCommsReply("Back", mainMenu)
			else
				setWeaponStorage("Homing", getWeaponStorageMax("Homing"))
				setCommsMessage("Filled up your missile supply.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our mines.", function()
			if getWeaponStorage("Mine") >= getWeaponStorageMax("Mine") then
				setCommsMessage("Captain,\nYou have all the mines you can fit in that ship.");
				addCommsReply("Back", mainMenu)
			else
				setWeaponStorage("Mine", getWeaponStorageMax("Mine"))
				setCommsMessage("These mines, are yours.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Can you supply us with some nukes.", function()
			if getWeaponStorage("Nuke") >= getWeaponStorageMax("Nuke") then
				setCommsMessage("All nukes are charged and primed for distruction.");
				addCommsReply("Back", mainMenu)
			else
				setWeaponStorage("Nuke", getWeaponStorageMax("Nuke"))
				setCommsMessage("You are fully loaded,\nand ready to explode things.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our EMP Missiles.", function()
			if getWeaponStorage("EMP") >= getWeaponStorageMax("EMP") then
				setCommsMessage("All storage for EMP missiles is filled sir.");
				addCommsReply("Back", mainMenu)
			else
				setWeaponStorage("EMP", getWeaponStorageMax("EMP"))
				setCommsMessage("Recallibrated the electronics and\nfitted you with all the EMP missiles you can carry.")
				addCommsReply("Back", mainMenu)
			end
		end)
	else
		-- Neutral station
		setCommsMessage("Welcome to our lovely station")
		addCommsReply("Do you have spare homing missiles for us?", function()
			if getWeaponStorage("Homing") >= getWeaponStorageMax("Homing") / 2 then
				setCommsMessage("You seem to have more then enough missiles");
				addCommsReply("Back", mainMenu)
			else
				setWeaponStorage("Homing", getWeaponStorageMax("Homing") / 2)
				setCommsMessage("We generously resupplied you with some free homing missiles.\nPut them to good use.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our mines.", function()
			if getWeaponStorage("Mine") >= getWeaponStorageMax("Mine") then
				setCommsMessage("You are fully stocked with mines.");
				addCommsReply("Back", mainMenu)
			else
				setWeaponStorage("Mine", getWeaponStorageMax("Mine"))
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