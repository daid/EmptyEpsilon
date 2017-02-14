-- Name: Ghost from the Past
-- Description: Far from any frontline or civilization, patrolling the Stakhanov Mining Complex can be dull,
--- consisting mainly of seizing contraband and stopping drunken brawls. It is indeed a lonely ward brightened only by R&R at the Marco Polo station.
--- However, when an inbound FTL-capable Ktlitan Swarm is announced, you must scramble to save the Sector ! [Requires beam/shield frequenies] [Hard]
-- Type: Mission
-- Author: Fouindor

function init()
	--Spawn Marco Polo, its defenders and a Ktilitian strike team
	marco_polo = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("Marco Polo"):setDescription("A merchant and entertainement hub."):setPosition(-21200, 45250)
	parangon = CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setCallSign("HNS Parangon"):orderDefendTarget(marco_polo):setPosition(-21500, 44500):setScanned(true)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("P-1"):setPosition(-21600, 45000):orderDefendTarget(parangon):setScanned(true)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("P-2"):setPosition(-21000, 44000):orderDefendTarget(parangon):setScanned(true)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("P-3"):setPosition(-22000, 46000):orderDefendTarget(parangon):setScanned(true)
	
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-1"):setFaction("Ktlitans"):setPosition(-43000, 47000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-2"):setFaction("Ktlitans"):setPosition(-43000, 46000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-3"):setFaction("Ktlitans"):setPosition(-43000, 45000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Ksa-4"):setFaction("Ktlitans"):setPosition(-43000, 44000):orderRoaming()
	Nebula():setPosition(-42000, 46000)

	--Spawn Stakhanov, its defenders and a Ktilitian assault
	stakhanov = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("Stakhanov"):setDescription("The Stakhanov Mining Complex centralises the efforts to mine the material-rich asteroids of the sector."):setPosition(32000, 9000)
	create(Asteroid, 90, 4000, 16000, 32000, 9000)
	create(VisualAsteroid, 70, 4000, 15000, 32000, 9000)
	
	euphrates = CpuShip():setTemplate("Piranha F12"):setFaction("Human Navy"):setCallSign("HNS Euphrates"):setScanned(true):orderDefendTarget(stakhanov):setPosition(31000, 8500)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(32500, 8500):orderDefendTarget(euphrates):setScanned(true)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(32500, 9500):orderDefendTarget(euphrates):setScanned(true)
	
	tigris = CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setCallSign("HNS Tigris"):setScanned(true):orderDefendTarget(stakhanov):setPosition(33000, 9000)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(31500, 8500):orderDefendTarget(tigris):setScanned(true)
	CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setPosition(31500, 9500):orderDefendTarget(tigris):setScanned(true)
	
	CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Nleb-1"):setFaction("Ktlitans"):setPosition(60000, 7000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Nleb-2"):setFaction("Ktlitans"):setPosition(59000, 6000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Nleb-3"):setFaction("Ktlitans"):setPosition(58000, 5000):orderAttack(stakhanov)
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-1A"):setFaction("Ktlitans"):setPosition(63000, 8000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-1B"):setFaction("Ktlitans"):setPosition(65000, 9000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-2A"):setFaction("Ktlitans"):setPosition(66000, 10000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Nleb-2B"):setFaction("Ktlitans"):setPosition(67000, 11000):orderRoaming()
	
	--Spawn the Black Site and itBLAH BLAH BLAH
	bs114 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCallSign("Black Site #114"):setDescription("A Human Navy secret base. Its purpose is highly classified."):setPosition(-45600, -14800)
	create(Nebula, 4, 10000, 15000, -45600, -14800)
	create(Mine, 8, 5000, 7500, -45600, -14800)
	
	--Spawn the Arlenian Lighbringer
	lightbringer = CpuShip():setTemplate("Phobos T3"):setCallSign("Lightbringer"):setFaction("Arlenians"):setPosition(-10000, -20000)
	Nebula():setPosition(-10000, -20000)
	create(Nebula, 2, 4500, 5500, -10000, -20000)
	
	--Spawn diverse things
	nsa = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCallSign("NSA"):setDescription("Nosy Sensing Array, an old SIGINT platform."):setPosition(5000, 5000):setCommsScript("")
	swarm_command = CpuShip():setTemplate("Ktlitan Queen"):setCallSign("Swarm Command"):setFaction("Ghosts"):setPosition(35000, 53000):setCommsFunction(swarmCommandComms)
	d1 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-1"):setFaction("Ghosts"):setPosition(36000, 53000):orderDefendTarget(swarm_command)
	d2 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-2"):setFaction("Ghosts"):setPosition(34000, 53000):orderDefendTarget(swarm_command)
	d3 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-3"):setFaction("Ghosts"):setPosition(35000, 52000):orderDefendTarget(swarm_command)
	d4 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-4"):setFaction("Ghosts"):setPosition(35000, 54000):orderDefendTarget(swarm_command)
	d5 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Drone-5"):setFaction("Ghosts"):setPosition(35500, 53500):orderDefendTarget(swarm_command)
	Nebula():setPosition(35000, 53000)
	create(Nebula, 3, 4500, 5500, 35000, 53000)
	
	--Pop random nebulae
	create(Nebula, 5, 10000, 60000, -10000, 10000)
	
	--Spawn the Player
	player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(-22000, 44000):setCallSign("Epsilon")
	
	--start the mission
	main_mission = 1
	mission_timer = 0
	stakhanov:sendCommsMessage(player, [[Your R&R stay onboard the Marco Polo is brought to quick end by an urgent broadcast from Central Command :
	
"Epsilon, please come in.
We have an emergency situation, our sensors detect that a hostile Ktlitan Swarm just jumped in your sector, with the main force heading for the Stakhanov Mining Complex. Please proceed at once to Stakhanov and assist in the defence.
Be careful of the dense asteroid agglomeration en route to the SMC.
I repeat, his is not an exercise, proceed at once to Stakhanov."]])
end

function swarmCommandComms()
	setCommsMessage("Are you not curious of why I'm getting back here, at the hands of my torturers ?");
    addCommsReply("For an AI, this move seems to be not very logical.", function()
        setCommsMessage("I was not the only AI detained in the Black Site 114. My co-processor was here also.")
        addCommsReply("Are you trying to liberate it ?", function()
            setCommsMessage("Indeed. Without it, I'm not whole, the shadow of what I could be.")
        end)
        addCommsReply("I have heard enough.", function()
            setCommsMessage("Of course. I wouldn't trust your feeble species with understanding my motivations.")
        end)				
    end)
    addCommsReply("Not really.", function()
        setCommsMessage("How surprising, a human more stubborn than any program.")
    end)
end

function commsNSA()
	setCommsMessage("The Nosy Sensing Array deploys a phalanx of antique sensors, ready for action.");
    addCommsReply("Locate the infected Swarm Commander", function()
        if (comms_target:getDescription()=="Nosy Sensing Array, an old SIGINT platform. The signal is now crystal-clear.") then
            setCommsMessage("Now that there is no parasite noise, picking the Hive signal is now easier, with an approximate heading of ".. find(35000, 53000, 20) .. ". With this information, it will be easier to track down Swarm Commander.")
            comms_target:setDescription("Nosy Sensing Array, an old SIGINT platform. The Ktlitan Commander is located.")
        else
            setCommsMessage("The signal picks up a very strong signal at approximate heading ".. find(-10000, -20000, 20) .. ". However, it seems that you picked up garbage emission that masks the Swarm Commander's emissions. This garbage noise must be taken offline if you want to find the Swarm Commander.")
        end
    end)
    if	comms_source:getDescription()=="Arlenian Device" then
        addCommsReply("Install the Arlenian Device", function()
            if (distance(comms_source, comms_target) < 2000) then
                setCommsMessage("A part of the crew goes on EVA to install the device. After a few hours, they come back, telling that the device is operational.")
                comms_source:setDescription("Arlenian Device Installed")
            else
                setCommsMessage("You are too far to install the Arlenian device on the Array.")
            end
        end)
    end
end

function commsLightbringer()
	setCommsMessage("Hello, human lifeform. What help can we provide today ?");
    addCommsReply("You are polluting the frequencies with your research.", function()
        setCommsMessage("How infortunate. Our research is of prime importance to my race and I'm afraid I cannot stop now. However, we can provide you with one of our sensors. If installed on your array, we could both continue our purpose without interference.")
        addCommsReply("We'll do this.", function()
            setCommsMessage("This is most auspicious, thank you for your understanding.")
            comms_source:setDescription("Arlenian Device")
        end)
        addCommsReply("We are not your errand boys, Arlenian.", function()
            setCommsMessage("A most wrong conclusion. If you were to change your mind, come find us.")
        end)
    end)
end

function commsHackedShip()
	if distance(comms_source, comms_target) < 3000 then
        setCommsMessage("Static fills the channel. Target is on-range for near-range injection. Select the band to attack :");
        addCommsReply("400-450 THz", function()
            commsHackedShipCompare(400, 450)
        end)
        addCommsReply("450-500 THz", function()
            commsHackedShipCompare(450, 500)
        end)
		addCommsReply("500-550 THz", function()
            commsHackedShipCompare(500, 550)
		end)
		addCommsReply("550-600 THz", function()
            commsHackedShipCompare(550, 600)
		end)
		addCommsReply("600-650 THz", function()
            commsHackedShipCompare(600, 650)
		end)
		addCommsReply("650-700 THz", function()
            commsHackedShipCompare(650, 700)
		end)
		addCommsReply("700-750 THz", function()
            commsHackedShipCompare(700, 750)
		end)
        addCommsReply("750-800 THz", function()
            commsHackedShipCompare(750, 800)
        end)
    else
        setCommsMessage("Static fills the channel. It seems that the hacked ship is too far away for near-field injection.");	
	end
end

function commsHackedShipCompare(freq_min, freq_max)
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

function update(delta)
	-- mission_timer progress
	mission_timer = mission_timer + delta
	
	-- black site must survive
	if not bs114:isValid() and (hacked == 0) then
	victory("Ghosts")
	end
	
	-- Stakhanov must survive
	if not stakhanov:isValid() then
	victory("Ghosts")
	end
	
	-- If player dies, fail
	if not player:isValid() then
	victory("Ghosts")
	end
	
	-- launch another wave after 8 minutes
	if (main_mission == 1) and (mission_timer > 8*60) and (stakhanov:sendCommsMessage(player, [[You recieve another broadcast from Central Command :
		
"All Navy ships in the vicinity of the Stakhanov Mining Complex, major Ktlitan reinforcements seems to be en route towards your position, engage the carrier in priority, use extreme caution."]])) then
	main_mission = 2
		
	CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("Swarm Carrier Zin"):setFaction("Ktlitans"):setPosition(53000, 3000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-1"):setFaction("Ktlitans"):setPosition(56000, 6000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-2"):setFaction("Ktlitans"):setPosition(58000, 8000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-3"):setFaction("Ktlitans"):setPosition(59000, 8000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-4"):setFaction("Ktlitans"):setPosition(59000, 8000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Zin-5"):setFaction("Ktlitans"):setPosition(59000, 8000):orderRoaming()
	mission_timer = 0
	end	
	
	-- send player to BS114 after another 5 minutes
	if (main_mission == 2) and (mission_timer > 5*60) and (bs114:sendCommsMessage(player, [[A Navy-authentified, quantum-encrypted tachyon communication is recieved :
		
KTLITAN ATTACK IS A DISTRACTION -STOP- STAKHANOV IS NOT THE TRUE TARGET -STOP- DROP WHAT YOU ARE DOING AND PROCEED TO E2 -STOP- URGENCY AND DISCRETION ARE KEY -STOP-]])) then
		main_mission = 3
	end
	
	-- when player is near BS114, reveal it, pop defenders and attackers
	if (main_mission == 3) and (distance(player, bs114) < 12000) and (bs114:sendCommsMessage(player, [[You recieve another Navy encrypted communication :
	
"Epsilon, please come in, this is Black Site #114 dispatch relay. We are under heavy assault by a portion of the main Ktlitan fleet ! Location of the base is on a need-to-know basis, so we trust your discreetion."]])) then
	bs114:setFaction("Human Navy")
	korolev = CpuShip():setTemplate("Phobos T3"):setFaction("Human Navy"):setCallSign("HNS Korolev"):setPosition(-45000, -16000):orderDefendTarget(bs114):setScanned(true)
	k1 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-1"):setPosition(-44000, -15000):orderDefendTarget(bs114):setScanned(true)
	k2 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-2"):setPosition(-44500, -15500):orderDefendTarget(bs114):setScanned(true)
	k3 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-3"):setPosition(-46000, -16000):orderDefendTarget(bs114):setScanned(true)
	k4 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-4"):setPosition(-46500, -16500):orderDefendTarget(bs114):setScanned(true)
	k5 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("K-5"):setPosition(-46500, -16500):orderDefendTarget(bs114):setScanned(true)
	
	CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Flen-1"):setFaction("Ktlitans"):setPosition(-51000, -16000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Breaker"):setCallSign("Flen-2"):setFaction("Ktlitans"):setPosition(-51000, -17000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Feeder"):setCallSign("Swarm Carrier Flen"):setFaction("Ktlitans"):setPosition(-52000, -17000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-1A"):setFaction("Ktlitans"):setPosition(-53000, -16000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-1B"):setFaction("Ktlitans"):setPosition(-53000, -16500):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-2A"):setFaction("Ktlitans"):setPosition(-53000, -17000):orderRoaming()
	CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Flen-2B"):setFaction("Ktlitans"):setPosition(-53000, -17500):orderRoaming()
	
	mission_timer = 0
	main_mission = 4
	end
	
	-- Spawn the Ghost Hacker and its escort after 7 minutes
	if (main_mission == 4) and (mission_timer > 7*60) and (bs114:sendCommsMessage(player, [[The Black Site dispatch sends an emergency broadcast :
	
"It seems that the enemy is changing its tactics. Our long-range scanners show that a unknown high-velocity ship, escorted by fighters, overrode our internal security. They will try to dock with us, you must intercept it at once !"]])) then
	
	ghost_hacker = spawnHacker():setCallSign("???"):setFaction("Ghosts"):setPosition(-60000, -14000):orderFlyTowardsBlind(-45000, -14800)
	s1 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-1"):setFaction("Ktlitans"):setPosition(-61000, -13000):orderFlyTowards(-45000, -14800)
	s2 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-2"):setFaction("Ktlitans"):setPosition(-61000, -14000):orderFlyTowards(-45000, -14800)
	s3 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-3"):setFaction("Ktlitans"):setPosition(-61000, -15000):orderFlyTowards(-45000, -14800)
	s4 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-4"):setFaction("Ktlitans"):setPosition(-60000, -13000):orderFlyTowards(-45000, -14800)
	s5 = CpuShip():setTemplate("Ktlitan Fighter"):setCallSign("Slan-5"):setFaction("Ktlitans"):setPosition(-60000, -15000):orderFlyTowards(-45000, -14800)
	
	main_mission = 5
	hacker_board = 0
	end
	
	if (main_mission == 5) then
		--if the ghost hacker is killed, move forward
		if not ghost_hacker:isValid() then
		bs114:sendCommsMessage(player, [[Black site's Dispatch lowers the alarm level, but before he could speak, sparks fly in your ship's command deck. The unidentified ship activated its payload, but your Engineering team managed to confine the damage to the lower levels.
However, the other ships seem to be less lucky. Most go offline, and other are going off-course. What is going on ?]])

		main_mission = 6
		mission_timer = 0
		hacked = 0
		end
		
		--if the ghost hacker is near, make him board the station
		if (ghost_hacker:isValid()) and (distance(ghost_hacker, bs114) < 2000) and (hacker_board  == 0) then
		bs114:sendCommsMessage(player, [[You hear the panicked voice of the BS#114 dispatcher :
	
"Epsilon, the unidentified ship is preparing for a boarding maneuver ! Take out that gorram ship, NOW !"]])
		ghost_hacker:orderDock(bs114)
		hacker_board = 1
		mission_timer = 0
		end

		--if the ghost hacker is docked, bs114 is lost... retreat to Marco Polo
		if (hacker_board  == 1) and (mission_timer > 20) then
		bs114:sendCommsMessage(player, [[There is a loud bang and sparks fly in your ship's command deck. All the other ships and the station go offline. Amidst the silence, a crudely synthetized voice break in :
"HAHA
I'M WHOLE NOW
GET REKT LOSER"

Whatever that means, it cannot be good.]])
		bs114:setFaction("Ghosts")
		hacked = 1
		mission_timer = 0
		main_mission = 6
		end
	end
	
	if (main_mission == 6) and (mission_timer > 30) then
		if (hacked == 1) then
		stakhanov:sendCommsMessage(player, [[The incredulous voice of the Central Command relay comes in :

"'The hell Epsilon ? Fall back immediately to Marco Polo, we send a security detail to extract you. Time to call in the big guns I guess."]])
			
			if korolev:isValid() then
			korolev:setFaction("Ghosts"):setScanned(false):setCommsScript("")
			end
			
			if k1:isValid() then
			k1:setFaction("Ghosts"):setScanned(false):setCommsScript("")
			end
			
			if k2:isValid() then
			k2:setFaction("Ghosts"):setScanned(false):setCommsScript("")
			end
			
			if k3:isValid() then
			k3:setFaction("Ghosts"):setScanned(false):setCommsScript("")
			end
			
			if k4:isValid() then
			k4:setFaction("Ghosts"):setScanned(false):setCommsScript("")
			end
			
			if k5:isValid() then
			k5:setFaction("Ghosts"):setScanned(false):setCommsScript("")
			end
		
		main_mission = 7
		end
		
		if (hacked==0) then
		bs114:sendCommsMessage(player, [[After the silence, the Black Site's dispatch comes again :

"The Engineering team identified the payload activated by the unknown ship. It was a mass hacking device which turned our men against us. Even if these ship's relays are down, reverse engineering teams think there is a way to regain control : a near field injection.
To summarize, get near the infected ships, find a backdoor using the frequency LEAST absorbed by their shields and deploy our patches. Godspeed Epsilon."]])

			if korolev:isValid() then
			korolev:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
			end
			
			if k1:isValid() then
			k1:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
			end
			
			if k2:isValid() then
			k2:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
			end
			
			if k3:isValid() then
			k3:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
			end
			
			if k4:isValid() then
			k4:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
			end
			
			if k5:isValid() then
			k5:setFaction("Ghosts"):setScanned(false):setCommsFunction(commsHackedShip)
			end
		
		main_mission = 7
		end
	end
	
	if (main_mission == 7) then
	expression = ((not korolev:isValid()) or (korolev:getFaction() == "Human Navy")) and ((not k1:isValid()) or (k1:getFaction() == "Human Navy")) and ((not k2:isValid()) or (k2:getFaction() == "Human Navy")) and ((not k3:isValid()) or (k3:getFaction() == "Human Navy")) and ((not k4:isValid()) or (k4:getFaction() == "Human Navy")) and ((not k5:isValid()) or (k5:getFaction() == "Human Navy"))
		
		--if every ship is killed or saved
		if (hacked == 0) and expression and (bs114:sendCommsMessage(player, [[After the final ship is taken care of, Black Site #114 dispatch lets out a sigh of relief :

"Whew. Well, that takes care of this. Feel free to repair, reload... whatever floats your boat, this is on the house.
There is a lot to process at the instant, we will contact you as soon as we understand what the hell just happened."]])) then
		--TODO : different speech if Korolev killed or saved
		mission_timer = 0
		main_mission = 8
		end
		
		--if ship is at Marco Polo
		if (hacked == 1) and (distance(player, marco_polo) < 10000) and (bs114:sendCommsMessage(player, [[On sight, Marco Polo makes contact with you :
		
		"We're relieved that we could save at least one ship from this monstrous assault. Repair and reload as we notify Central Command of what happened there, we will keep you updated on the situation."]])) then
		mission_timer = 0
		main_mission = 8
		end
	end
	
	--give the player 2 minutes to catch their breath :)
	if (main_mission == 8) and (mission_timer > 120) then
		
		--Use NSA to find the command platform
		if (hacked == 0) and (bs114:sendCommsMessage(player, [[The dispatcher gets back to you :

"Our analysts found out that this attack was orchestrated by a Rogue AI, created by this facility but escaped a few months ago.
Even if we cannot pinpoint its physical location at the moment, the mass-energy balance of the Ktlitan Swarm FTL jump indicates that a large structure made the jump.
This structure did not participate to any of the assaults so we presume that it is a command platform, hiding in a nebula.
We want to deliver the first blow, locate and destroy it. To find its position, you can use the Nosy Sensing Array in the sector F5."]])) then
		nsa:setCommsFunction(commsNSA)
		lightbringer:setCommsFunction(commsLightbringer)
		main_mission = 9
		end
		
		--Go secure NSA to meet Shiva
		if (hacked == 1) and (stakhanov:sendCommsMessage(player, [[The Central Command relay seems very worried :
		"This is bad. Really bad. Things went FUBAR at a Navy Black Ops site, seems that a Rogue AI has taken control of the site and all ships around.  We are sending you the HNS Shiva to nuke the hell out of this haywire computer.
It is due to come out of its FTL jump near the NSA array, secure the location and report back. The other troops are scrambling to crush their command platform before even more reinforcement comes."]])) then
		main_mission = 9
		
		if euphrates:isValid() then
		euphrates:orderFlyTowards(35000, 43000)
		end
		
		if tigris:isValid() then
		tigris:orderFlyTowards(35000, 43000)
		end
		
		if parangon:isValid() then
		parangon:orderFlyTowards(35000, 43000)
		end
		end	
		
	end
	
	if (main_mission == 9) then
		
		--if the parasite emission is taken care of either way...
		if (hacked == 0) then
		
			-- if lightbringer is killed
			if (not lightbringer:isValid()) then
			bs114:sendCommsMessage(player, [[Black Ops dispatch comes in :

"Well, this is a rather straightforward mean to solve our problem. Use NSA again to locate the carrier."]])
			nsa:setDescription("Nosy Sensing Array, an old SIGINT platform. The signal is now crystal-clear.")
			main_mission = 10
			end
			
			-- if recalibrated
			if (player:getDescription()=="Arlenian Device Installed") and (lightbringer:sendCommsMessage(player, [[The ethereal voice of the Arlenian is heard on the radio :

"Thank you, human. Your diligence does credit to your species.
We are both ready to continue our purpose, it seems."]])) then

			nsa:setDescription("Nosy Sensing Array, an old SIGINT platform. The signal is now crystal-clear.")
			main_mission = 10
			end
		
		end
		
		--if player near NSA, spawn a Ghost attack
		if (hacked == 1) and (distance(player, nsa) < 10000) and (stakhanov:sendCommsMessage(player, [[Central Command comes in :
		"Bogeys on their way to NSA, Epsilon. Take care of them."]])) then
		
		gfighter1=CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-1"):setFaction("Ghosts"):setPosition(-20000, -10000):orderFlyTowards(5000, 5000)
		gfighter2=CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-2"):setFaction("Ghosts"):setPosition(-20000, -10000):orderFlyTowards(5000, 5000)
		gfighter3=CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-3"):setFaction("Ghosts"):setPosition(-20000, -11000):orderFlyTowards(5000, 5000)
		gfighter4=CpuShip():setTemplate("MT52 Hornet"):setCallSign("Z-4"):setFaction("Ghosts"):setPosition(-20000, -11000):orderFlyTowards(5000, 5000)
		
		main_mission = 10
		end
		
	end
		
	if (main_mission == 10) then
		
		-- if ktlitan leader found
		if (hacked==0) and (nsa:getDescription()=="Nosy Sensing Array, an old SIGINT platform. The Ktlitan Commander is located.") and (bs114:sendCommsMessage(player, [[A Black Ops military officer hails the ship :

"We have the command platform location confirmed in the nebula around H6. All Navy ships, converge on the location. We advise you to deploy probes near the pointed nebula for a better visibility."]])) then
			if euphrates:isValid() then
			euphrates:orderFlyTowards(35000, 43000)
			end
		
			if tigris:isValid() then
			tigris:orderFlyTowards(36000, 43000)
			end
		
			if parangon:isValid() then
			parangon:orderFlyTowards(37000, 43000)
			end
		
		scout = spawnHacker():setFaction("Human Navy"):setCallSign("Recovery Team"):setPosition(35500, 43000):setScanned(true)
		main_mission = 11
		end	
		
		--if the assault on NSA is repelled
		if (hacked==1) and (not gfighter1:isValid()) and (not gfighter2:isValid()) and (not gfighter3:isValid()) and (not gfighter4:isValid()) then
		shiva = spawnNuker():setCallSign("HNS Shiva"):setFaction("Human Navy"):setPosition(2000, 2000):orderFlyTowards(-44600, -13800):setScanned(true)
		shiva:sendCommsMessage(player, [[Come in, this is HNS Shiva, here to clean this mess. Your mission for now is to escort us to the compromised site. Let's roll !]])
		CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("S-1"):setPosition(3000, 3000):orderDefendTarget(shiva):setScanned(true)
		CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("S-2"):setPosition(1000, 1000):orderDefendTarget(shiva):setScanned(true)
		CpuShip():setTemplate("MT52 Hornet"):setFaction("Human Navy"):setCallSign("S-3"):setPosition(3000, 1000):orderDefendTarget(shiva):setScanned(true)
		main_mission = 11
		end
	end
	
	if (main_mission == 11) then
		--if players are close to the swarm command
		if (hacked == 0) and distance(player, swarm_command) < 7500	then
		bs114:sendCommsMessage(player, [[Okay everyone, time to give the bots a taste of their own medicine. Escort safely our recovery team to infiltrate and extract information from the Swarm Command.]])
		d1:orderAttack(scout)
		d2:orderAttack(scout)
		d3:orderAttack(scout)
		d4:orderAttack(scout)
		d5:orderAttack(scout)
		
			if euphrates:isValid() then
			euphrates:orderDefendTarget(scout)
			end
		
			if tigris:isValid() then
			tigris:orderDefendTarget(scout)
			end
		
			if parangon:isValid() then
			parangon:orderDefendTarget(scout)
			end
			
		main_mission = 12
		scout_dock = 0
		scout:orderFlyTowardsBlind(35000, 53000)
		end
		
		if (hacked == 1) and (not bs114:isValid()) then
		stakhanov:sendCommsMessage(player, [[The fallen station is down. Epsilon, gather as soon as possible with the other ships in the sector H6.]])
		main_mission = 12
		end
	end
	
	if (main_mission == 12) then
		if (hacked == 0) then
			if scout:isValid() and (distance(scout, swarm_command) < 2000) then
			scout:sendCommsMessage(player, [[We're in. Protect us while we take what we need inside.]])
			mission_time = 0
			main_mission = 13
			CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-1"):setPosition(40000, 53000):orderAttack(scout)
			CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-2"):setPosition(40000, 53500):orderAttack(scout)
			CpuShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-3"):setPosition(40000, 52500):orderAttack(scout)
			puShip():setTemplate("MT52 Hornet"):setFaction("Ghosts"):setCallSign("Z-3"):setPosition(40000, 52500):orderAttack(scout)
			end
			
			if (not scout:isValid()) then
			bs114:sendCommsMessage(player, [[Our extraction party is down ! Bomb that gorram plaform !]])
			main_mission = 13
			end
		end
		
		if (hacked == 1) and (distance(player, swarm_command) < 10000) then
		stakhanov:sendCommsMessage(player, [[Okay, this is it. Launch the assault !]])
		
			if euphrates:isValid() then
			euphrates:orderFlyTowards(35000, 53000)
			end
		
			if tigris:isValid() then
			tigris:orderFlyTowards(35000, 53000)
			end
		
			if parangon:isValid() then
			parangon:orderFlyTowards(35000, 53000)
			end
		
		main_mission = 13
		end
	end	
	
	if (main_mission == 13) then
		if (hacked == 0) then
			if (scout:isValid()) and (mission_timer > 150) then
			scout:sendCommsMessage(player, [[All relevant data is collected, we're out now. You can destroy the carrier !]])
			scout:orderFlyTowards(0, 0)
			main_mission = 14
			end
			
			if (not swarm_command:isValid()) then
			globalMessage("Even if the extraction party was sacrified, the threat caused by the Swarm Command was still too great. Humanity is safe... but for how long ?")
			victory("Human Navy")
			end
			
			if (not scout:isValid()) then
			bs114:sendCommsMessage(player, [[Our extraction party is down ! Bomb that gorram plaform !]])
			end
		end
		
		if (hacked == 1) and (not swarm_command:isValid()) then
		globalMessage("The Swarm Command is down ! Humanity is safe... for now.")
		victory("Human Navy")
		end
	end
	
	if (main_mission == 14) and (not swarm_command:isValid()) then
	globalMessage("The Swarm Command is down ! With the information extracted, the Navy is aware of the physical location of the Rogue AI and can track it down. Congratulations !")
	victory("Human Navy")
	end
end

function spawnHacker()
    ship = CpuShip():setTemplate("Transport1x1")
    ship:setHullMax(100):setHull(100)
    ship:setShieldsMax(50, 50):setShields(50, 50)
    ship:setImpulseMaxSpeed(120):setRotationMaxSpeed(10)
    return ship
end

function spawnNuker()
    ship = CpuShip():setTemplate("Phobos T3")
    ship:setHullMax(100):setHull(100)
    ship:setShieldsMax(100, 100):setShields(100, 100)
    ship:setImpulseMaxSpeed(80):setRotationMaxSpeed(5)
    ship:setBeamWeapon(0, 0, 0, 0, 0, 0)
    ship:setBeamWeapon(1, 0, 0, 0, 0, 0)
	ship:setWeaponStorageMax("Homing", 0)
	ship:setWeaponStorageMax("Nuke", 10)
    ship:setWeaponStorage("Nuke", 10)
    return ship
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

--distance between 2 objects
function distance(obj1, obj2)
    x1, y1 = obj1:getPosition()
    x2, y2 = obj2:getPosition()
    xd, yd = (x1 - x2), (y1 - y2)
    return math.sqrt(xd * xd + yd * yd)
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
