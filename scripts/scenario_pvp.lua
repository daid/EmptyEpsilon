-- Name: Clash in Shangri-La (PVP)
-- Description: Since its creation, the Shangri-la station was governed by a multi-ethnic consortium which assured the independence of the station across the conflicts that shook the sector. However, the station's tranquility came to an abrupt end when most of the governing consortium's members were assassinated under a Exuari false flag operation. Now the station is in state of civil war, with total infighting breaking out between warring factions. Both the neighboring Human Navy and Kraylors are worried that the breakdown of order in Shangri-La could give any advantage to the other and sent out "peacekeepers" to turn the situation to their own advantage. Human Navy's HNS Gallipoli and Kraylor's Crusader Naa'Tvek face off in an all out battle for Shangri-La.

function init()
	humanTroops = {}
	kraylorTroops = {}
	
	template = ShipTemplate():setName("Troop Transport"):setModel("transport_2_1")
    template:setHull(100)
    template:setShields(50, 50)
    template:setSpeed(100, 10, 10)
	
	-- stations
	shangri_la = SpaceStation():setPosition(10000, 10000):setTemplate('Large Station'):setFaction("Independent"):setRotation(random(0, 360)):setCallSign("Shangri-La"):setCommsFunction(shangrilaComms)
	
	human_shipyard = SpaceStation():setPosition(-7500, 15000):setTemplate('Small Station'):setFaction("Human Navy"):setRotation(random(0, 360)):setCallSign("Mobile Shipyard"):setCommsFunction(stationComms)
	CpuShip():setTemplate('Cruiser'):setFaction("Human Navy"):setPosition(-8000, 16500):orderDefendTarget(human_shipyard)
	CpuShip():setTemplate('Cruiser'):setFaction("Human Navy"):setPosition(-6000, 13500):orderDefendTarget(human_shipyard)
	CpuShip():setTemplate('Cruiser'):setFaction("Human Navy"):setPosition(-7000, 14000):orderDefendTarget(human_shipyard)
	CpuShip():setTemplate('Adv. Gunship'):setFaction("Human Navy"):setPosition(-8000, 14000):orderDefendTarget(human_shipyard)
	
	kraylor_shipyard = SpaceStation():setPosition(27500, 5000):setTemplate('Small Station'):setFaction("Kraylor"):setRotation(random(0, 360)):setCallSign("Forward Command"):setCommsFunction(stationComms)
	CpuShip():setTemplate('Cruiser'):setFaction("Kraylor"):setPosition(29000, 5000):orderDefendTarget(kraylor_shipyard)
	CpuShip():setTemplate('Cruiser'):setFaction("Kraylor"):setPosition(25000, 5000):orderDefendTarget(kraylor_shipyard)
	CpuShip():setTemplate('Cruiser'):setFaction("Kraylor"):setPosition(27500, 6000):orderDefendTarget(kraylor_shipyard)
	CpuShip():setTemplate('Adv. Gunship'):setFaction("Kraylor"):setPosition(27000, 5000):orderDefendTarget(kraylor_shipyard)
	
	
	--spawn players
	gallipoli = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setPosition(-8500, 15000):setCallSign("HNS Gallipoli")
	crusader = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Player Cruiser"):setPosition(26500, 5000):setCallSign("Crusader Naa'Tvek")
	
	-- timers
	time = 0
	wave_timer = 0
	troop_timer = 0
	kraylor_respawn = 0
	human_respawn = 0
	
	human_points = 0
	kraylor_points = 0
	
	human_shipyard:sendCommsMessage(gallipoli, [[Captain, it seems that the Kraylor are making their move to take the Shangri-La station in the F5 sector. Provide a spatial cover for while our troop transports board the station to reclaim it.]])
	kraylor_shipyard:sendCommsMessage(crusader, [[Greetings, Crusader. Your mission is to securize the Shangri-La station in the F5 sector, as the feeble humans think it's theirs for the taking. Support our glorious soldiers by preventing the heretics from harming our transports and cleansing all enemy opposition !]])
	
	--create terrain
	create(Asteroid, 20, 5000, 10000, 10000, 10000)
	create(VisualAsteroid, 10, 5000, 10000, 10000, 10000)
	create(Mine, 10, 5000, 10000, 10000, 10000)
	
	--spawn first wave
	table.insert(humanTroops, CpuShip():setTemplate('Troop Transport'):setFaction("Human Navy"):setPosition(-7000, 15000):orderDock(shangri_la))
	CpuShip():setTemplate('Fighter'):setFaction("Human Navy"):setPosition(-7000, 15500):orderFlyTowards(shangri_la:getPosition())
	CpuShip():setTemplate('Fighter'):setFaction("Human Navy"):setPosition(-7000, 14500):orderFlyTowards(shangri_la:getPosition())
	
	table.insert(kraylorTroops, CpuShip():setTemplate('Troop Transport'):setFaction("Kraylor"):setPosition(26500, 5000):orderDock(shangri_la))
	CpuShip():setTemplate('Fighter'):setFaction("Kraylor"):setPosition(26500, 5500):orderFlyTowards(shangri_la:getPosition())
	CpuShip():setTemplate('Fighter'):setFaction("Kraylor"):setPosition(26500, 4500):orderFlyTowards(shangri_la:getPosition())
end

function shangrilaComms()
	setCommsMessage("Your faction's militia commander picks up :\nWhat can we do, Captain ?")
    addCommsReply("Give us a status report.", function()
        setCommsMessage("Here are the latest news from the front.\nHuman Dominance : ".. human_points .. "\nKraylor Dominance : ".. kraylor_points .. "\nTime Elapsed : ".. time)			
    end)
end

function stationComms()
	if comms_source:isFriendly(comms_target) then
		if not comms_source:isDocked(comms_target) then
			setCommsMessage("A dispatcher comes in:\nGreetings Captain, if you want supplies, please dock with us.")
		else
			setCommsMessage("A dispatcher comes in:\nGreetings Captain, what can we do for you ?")		
		end
		
		addCommsReply("I need a status report.", function()
			setCommsMessage("Here are the latest news from the front.\nHuman Dominance : ".. human_points .. "\nKraylor Dominance : ".. kraylor_points .. "\nTime Elapsed : ".. time)			
		end)
		addCommsReply("Send in more troops. (100 reputation)", function()
			if not comms_source:takeReputationPoints(100) then setCommsMessage("Not enough reputation."); return end
			setCommsMessage("We sent a squad to support the assault on the base.")
			table.insert(kraylorTroops, CpuShip():setFaction(getFaction(comms_target)):setFaction("Kraylor"):setPosition(getPosition(comms_target)):orderDock(shangri_la))
			CpuShip():setTemplate('Fighter'):setFaction(getFaction(comms_target)):setPosition(getPosition(comms_target)):orderFlyTowards(shangri_la:getPosition())
			CpuShip():setTemplate('Fighter'):setFaction(getFaction(comms_target)):setPosition(getPosition(comms_target)):orderFlyTowards(shangri_la:getPosition())
		end)
		addCommsReply("We need some space-based firepower. (150 reputation)", function()
			if not comms_source:takeReputationPoints(150) then setCommsMessage("Not enough reputation."); return end
			setCommsMessage("Okay, we dispatched a strike wing to support you.")
			CpuShip():setTemplate('Fighter'):setFaction(getFaction(comms_target)):setPosition(getPosition(comms_target)):orderFlyTowards(shangri_la:getPosition())
			CpuShip():setTemplate('Adv. Gunship'):setFaction(getFaction(comms_target)):setPosition(getPosition(comms_target)):orderFlyTowards(shangri_la:getPosition())
			CpuShip():setTemplate('Fighter'):setFaction(getFaction(comms_target)):setPosition(getPosition(comms_target)):orderFlyTowards(shangri_la:getPosition())
		end)
			if comms_source:isDocked(comms_target) then
				addCommsReply("We need supplies.", supplyDialogue)
			end
	else
		setCommsMessage("We'll bring your destruction !")
	end
end

function supplyDialogue()
	setCommsMessage("Yes ? What do you want ?")
		addCommsReply("Do you have spare homing missiles for us? (2rep each)", function()
			if not comms_source:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not comms_source:takeReputationPoints(2 * (comms_source:getWeaponStorageMax("Homing") - comms_source:getWeaponStorage("Homing"))) then setCommsMessage("Not enough reputation."); return end
			if comms_source:getWeaponStorage("Homing") >= comms_source:getWeaponStorageMax("Homing") then
				setCommsMessage("Sorry sir, but you are fully stocked with homing missiles.");
				addCommsReply("Back", mainMenu)
			else
				comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorageMax("Homing"))
				setCommsMessage("Filled up your missile supply.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our mines. (2rep each)", function()
			if not comms_source:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not comms_source:takeReputationPoints(2 * (comms_source:getWeaponStorageMax("Mine") - comms_source:getWeaponStorage("Mine"))) then setCommsMessage("Not enough reputation."); return end
			if comms_source:getWeaponStorage("Mine") >= comms_source:getWeaponStorageMax("Mine") then
				setCommsMessage("Captain,\nYou have all the mines you can fit in that ship.");
				addCommsReply("Back", mainMenu)
			else
				comms_source:setWeaponStorage("Mine", comms_source:getWeaponStorageMax("Mine"))
				setCommsMessage("These mines, are yours.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Can you supply us with some nukes? (15rep each)", function()
			if not comms_source:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not comms_source:takeReputationPoints(15 * (comms_source:getWeaponStorageMax("Nuke") - comms_source:getWeaponStorage("Nuke"))) then setCommsMessage("Not enough reputation."); return end
			if comms_source:getWeaponStorage("Nuke") >= comms_source:getWeaponStorageMax("Nuke") then
				setCommsMessage("All nukes are charged and primed for destruction.");
				addCommsReply("Back", mainMenu)
			else
				comms_source:setWeaponStorage("Nuke", comms_source:getWeaponStorageMax("Nuke"))
				setCommsMessage("You are fully loaded,\nand ready to explode things.")
				addCommsReply("Back", mainMenu)
			end
		end)
		addCommsReply("Please re-stock our EMP Missiles. (10rep each)", function()
			if not comms_source:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
			if not comms_source:takeReputationPoints(10 * (comms_source:getWeaponStorageMax("EMP") - comms_source:getWeaponStorage("EMP"))) then setCommsMessage("Not enough reputation."); return end
			if comms_source:getWeaponStorage("EMP") >= comms_source:getWeaponStorageMax("EMP") then
				setCommsMessage("All storage for EMP missiles is filled, sir.");
				addCommsReply("Back", mainMenu)
			else
				comms_source:setWeaponStorage("EMP", comms_source:getWeaponStorageMax("EMP"))
				setCommsMessage("Recallibrated the electronics and fitted you with all the EMP missiles you can carry.")
				addCommsReply("Back", mainMenu)
			end
		end)
end

function update(delta)
	-- increment timers
	time = time + delta
	wave_timer = wave_timer + delta
	troop_timer = troop_timer + delta
	
	if (not gallipoli:isValid()) then
		if human_respawn > 20 then
			gallipoli = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Player Cruiser"):setPosition(-8500, 15000):setCallSign("HNS Heinlein")
		else
			human_respawn = human_respawn + delta
		end
	end
	
	if (not crusader:isValid()) then
		if kraylor_respawn > 20 then
			crusader = PlayerSpaceship():setFaction("Kraylor"):setTemplate("Player Cruiser"):setPosition(19000, -14500):setCallSign("Crusader Elak'raan")
		else
			kraylor_respawn = kraylor_respawn + delta
		end
	end
	
	-- add reputation to both sides
	gallipoli:addReputationPoints(delta * 0.3)
	crusader:addReputationPoints(delta * 0.3)
	
	-- if a side has no station or flagship, it loses. victory in 40 points
	if ((not gallipoli:isValid()) and (not human_shipyard:isValid())) or kraylor_points > 40 then
		victory("Kraylor")
	end
	
	if ((not crusader:isValid()) and (not kraylor_shipyard:isValid())) or human_points > 40 then
		victory("Human Navy")
	end	
	
	-- if either of the flagship is sunk, the other side gains a reputation bonus
	if (not gallipoli:isValid()) then
		kraylor_shipyard:sendCommsMessage(crusader, [[Well done, Crusader ! The pathetic Human flagship has been disabled, go for the victory !]])
		crusader:addReputationPoints(50)
		kraylor_points = kraylor_points + 5
		human_respawn = 0
	end
	
	if (not crusader:isValid()) then
		human_shipyard:sendCommsMessage(gallipoli, [[Good job, Captain ! With the Kraylor flagship out of the way, we can land the final blow !]])
		gallipoli:addReputationPoints(50)
		human_points = human_points + 5
		krayor_respawn =  0
	end
	
	-- pop a wave of 2 fighters, 1 troop transport
	if wave_timer > 150 and (human_shipyard:isValid()) then
		
		line = random(0, 20) * 500
		table.insert(humanTroops, CpuShip():setTemplate('Troop Transport'):setFaction("Human Navy"):setPosition(-7000, 5000 + line):orderDock(shangri_la))
		CpuShip():setTemplate('Fighter'):setFaction("Human Navy"):setPosition(-7000, 5500 + line):orderFlyTowards(shangri_la:getPosition())
		CpuShip():setTemplate('Fighter'):setFaction("Human Navy"):setPosition(-7000, 4500 + line):orderFlyTowards(shangri_la:getPosition())
	
		line = random(0, 20) * 500
		table.insert(kraylorTroops, CpuShip():setTemplate('Troop Transport'):setFaction("Kraylor"):setPosition(27000, -5000 + line):orderDock(shangri_la))
		CpuShip():setTemplate('Fighter'):setFaction("Kraylor"):setPosition(27000, -5500 + line):orderFlyTowards(shangri_la:getPosition())
		CpuShip():setTemplate('Fighter'):setFaction("Kraylor"):setPosition(27000, -4500 + line):orderFlyTowards(shangri_la:getPosition())
		
		wave_timer = 0
	end
	
	-- count transports
	if troop_timer > 10 then
		for _, transport in ipairs(kraylorTroops) do
			if transport:isValid() and transport:isDocked(shangri_la) then
				kraylor_points = kraylor_points + 1
			end
		end
	
		for _, transport in ipairs(humanTroops) do
			if transport:isValid() and transport:isDocked(shangri_la) then
				human_points = human_points + 1
			end
		end
		
		troop_timer = 0	
	end
	
	-- if the station is blown, nobody wins
	if (not shangri_la:isValid()) then
		--TODO
	end
end

-- create amount of object_type, at a distance between dist_min and dist_max around the point (x0, y0)
function create(object_type, amount, dist_min, dist_max, x0, y0)
        for n=1,amount do
		local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        object_type():setPosition(x, y)
		end
end