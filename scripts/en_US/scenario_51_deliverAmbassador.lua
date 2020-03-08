-- Name: Deliver Ambassador Gremus
-- Description: Unrest on Goltin 7 requires the skills of ambassador Gremus. Your mission: transport the ambassador wherever needed. You may encounter resistance.
---
--- You are not flying a destroyer bristling with weapons. You are on a transport freighter with weapons bolted on as an afterthought. These weapons are pointed behind you to deter any marauding pirates. You won't necessarily be able to just destroy any enemies that might attempt to stop you from accomplishing your mission, you may have to evade. The navy wants you to succeed, so has fitted your ship with warp drive and a single diverse ordnance weapons tube which includes nuclear capability. If you get lost or forget your orders, check in with stations for information.
---
--- Player ship: Template model: Flavia P. Falcon. Suggest turning music volume to 10% and sound volume to 100% on server
---
--- Version 3 added expiration timers to relay buttons that trigger audio playback, added a visible mob action timer, converted .wav files to .ogg files to reduce size of download
-- Type: Mission
-- Variation[Hard]: More enemies
-- Variation[Easy]: Fewer enemies

require("utils.lua")
require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")


function init()
	playerCallSign = "Carolina"
	player = PlayerSpaceship():setFaction(humanFaction):setTemplate(flaviaPFalcon)
	player:setPosition(22400, 18200):setCallSign(playerCallSign)
	-- Create various stations of various size, purpose and faction.
    outpost41 = SpaceStation():setTemplate(smallStation):setFaction(humanFaction):setCommsScript(""):setCommsFunction(commsStation)
    outpost41:setPosition(22400, 16100):setCallSign("Outpost-41"):setDescription("Strategically located human station")
    outpost17 = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction)
    outpost17:setPosition(52400, -26150):setCallSign("Outpost-17")
    outpost26 = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction)
    outpost26:setPosition(-42400, -32150):setCallSign("Outpost-26")
    outpost13 = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction):setCommsScript(""):setCommsFunction(commsStation)
	outpost13:setPosition(12600, 27554):setCallSign("Outpost-13"):setDescription("Gathering point for asteroid miners")
    outpost57 = SpaceStation():setTemplate(smallStation):setFaction(kraylorFaction)
	outpost57:setPosition(63630, 47554):setCallSign("Outpost-57")
    science22 = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction)
	science22:setPosition(11200, 67554):setCallSign("Science-22")
    science37 = SpaceStation():setTemplate(smallStation):setFaction(humanFaction):setCommsScript(""):setCommsFunction(commsStation)
	science37:setPosition(-18200, -32554):setCallSign("Science-37"):setDescription("Observatory")
    bpcommnex = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction):setCommsScript(""):setCommsFunction(commsStation)
	bpcommnex:setPosition(-53500,84000):setCallSign("BP Comm Nex"):setDescription("Balindor Prime Communications Nexus")
    goltincomms = SpaceStation():setTemplate(smallStation):setFaction(neutralFaction)
	goltincomms:setPosition(93150,24387):setCallSign("Goltin Comms")
    stationOrdinkal = SpaceStation():setTemplate(mediumStation):setFaction(neutralFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOrdinkal:setPosition(-14600, 47554):setCallSign("Ordinkal"):setDescription("Trading Post")
    stationNakor = SpaceStation():setTemplate(mediumStation):setFaction(neutralFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNakor:setPosition(-34310, -37554):setCallSign("Nakor"):setDescription("Science and trading hub")
    stationKelfist = SpaceStation():setTemplate(mediumStation):setFaction(kraylorFaction)
	stationKelfist:setPosition(44640, 13554):setCallSign("Kelfist")
    stationFranklin = SpaceStation():setTemplate(largeStation):setFaction(humanFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationFranklin:setPosition(-24640, -13554):setCallSign("Franklin"):setDescription("Civilian and military station")
    stationBroad = SpaceStation():setTemplate(largeStation):setFaction(neutralFaction)
	stationBroad:setPosition(44340, 63554):setCallSign("Broad"):setDescription("Trading Post")
    stationBazamoana = SpaceStation():setTemplate(largeStation):setFaction(neutralFaction)
	stationBazamoana:setPosition(35, 87):setCallSign("Bazamoana"):setDescription("Trading Nexus")
    stationPangora = SpaceStation():setTemplate(hugeStation):setFaction(humanFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPangora:setPosition(72340, -23554):setCallSign("Pangora"):setDescription("Major military installation")
	-- Give out some initial reputation points. Give more for easier difficulty levels
	stationFranklin:addReputationPoints(50.0)
	if getScenarioVariation() ~= "Hard" then
		stationFranklin:addReputationPoints(100.0)
	end
	-- Create some asteroids and nebulae
	createRandomAlongArc(Asteroid, 40, 30350, 20000, 11000, 310, 45, 1700)
	createRandomAlongArc(Asteroid, 65, 20000, 20000, 15000, 80, 160, 3500)
	createRandomAlongArc(Asteroid, 100, -30000, 38000, 35000, 270, 340, 3500)
	createObjectsOnLine(-29000, 3000, -50000, 3000, 400, Asteroid, 13, 8, 800)
	createObjectsOnLine(-50000, 3000, -60000, 5000, 400, Asteroid, 8, 6, 800)
	createObjectsOnLine(-60000, 5000, -70000, 7000, 400, Asteroid, 5, 4, 800)
	createRandomAlongArc(Asteroid, 800, 60000, -20000, 190000, 140, 210, 60000)
	createRandomAlongArc(Nebula, 11, -20000, 40000, 30000, 20, 160, 11000)
	createRandomAlongArc(Nebula, 18, 70000, -50000, 55000, 90, 180, 18000)
	-- Have players face a hostile enemy right away (more if difficulty is harder)
	kraylorChaserList = {}
	kraylorChaser1 = CpuShip():setTemplate(phobosT3):setFaction(kraylorFaction):setPosition(24000,18200):setHeading(270)
	kraylorChaser1:orderAttack(player):setScanned(true)
	table.insert(kraylorChaserList,kraylorChaser1)
	if getScenarioVariation() ~= "Easy" then
		kraylorChaser2 = CpuShip():setTemplate(phobosT3):setFaction(kraylorFaction):setPosition(24000,18600):setHeading(270)
		kraylorChaser2:orderFlyFormation(kraylorChaser1,0,400):setScanned(true)
		table.insert(kraylorChaserList,kraylorChaser2)
	end
	if getScenarioVariation() == "Hard" then
		kraylorChaser3 = CpuShip():setTemplate(phobosT3):setFaction(kraylorFaction):setPosition(24000,17800):setHeading(270)
		kraylorChaser3:orderFlyFormation(kraylorChaser1,0,-400):setScanned(true)
		table.insert(kraylorChaserList,kraylorChaser3)
	end
	-- Take station and transport generation script and use with modifications
	stationList = {}
	transportList = {}
	tmp = SupplyDrop()
	for _, obj in ipairs(tmp:getObjectsInRange(300000)) do
		if obj.typeName == "SpaceStation" then
			table.insert(stationList, obj)
		end
	end
	tmp:destroy()
	maxTransport = math.floor(#stationList * 1.5)
	transportPlot = transportSpawn
	plot1 = chasePlayer		-- Start main plot line
	plotAudioButton = audioButtonTimers
end
function audioButtonTimers(delta)
	if playMsgMichaelButton ~= nil then
		if player.playMsgMichaelButton == nil then
			player.playMsgMichaelButton = delta + 180
		end
		player.playMsgMichaelButton = player.playMsgMichaelButton - delta
		if player.playMsgMichaelButton < 0 then
			player:removeCustom(playMsgMichaelButton)
			playMsgMichaelButton = nil
		end
	end
	if playMsgGremus1Button ~= nil then
		if player.playMsgGremus1Button == nil then
			player.playMsgGremus1Button = delta + 180
		end
		player.playMsgGremus1Button = player.playMsgGremus1Button - delta
		if player.playMsgGremus1Button < 0 then
			player:removeCustom(playMsgGremus1Button)
			playMsgGremus1Button = nil
		end
	end
	if playMsgSentry1Button ~= nil then
		if player.playMsgSentry1Button == nil then
			player.playMsgSentry1Button = delta + 180
		end
		player.playMsgSentry1Button = player.playMsgSentry1Button - delta
		if player.playMsgSentry1Button < 0 then
			player:removeCustom(playMsgSentry1Button)
			playMsgSentry1Button = nil
		end
	end
	if playMsgGremus2Button ~= nil then
		if player.playMsgGremus2Button == nil then
			player.playMsgGremus2Button = delta + 180
		end
		player.playMsgGremus2Button = player.playMsgGremus2Button - delta
		if player.playMsgGremus2Button < 0 then
			player:removeCustom(playMsgGremus2Button)
			playMsgGremus2Button = nil
		end
	end
	if playMsgProtocolButton ~= nil then
		if player.playMsgProtocolButton == nil then
			player.playMsgProtocolButton = delta + 180
		end
		player.playMsgProtocolButton = player.playMsgProtocolButton - delta
		if player.playMsgProtocolButton < 0 then
			player:removeCustom(playMsgProtocolButton)
			playMsgProtocolButton = nil
		end
	end
	if playMsgGremus3Button ~= nil then
		if player.playMsgGremus3Button == nil then
			player.playMsgGremus3Button = delta + 180
		end
		player.playMsgGremus3Button = player.playMsgGremus3Button - delta
		if player.playMsgGremus3Button < 0 then
			player:removeCustom(playMsgGremus3Button)
			playMsgGremus3Button = nil
		end
	end
	if playMsgFordinaButton ~= nil then
		if player.playMsgFordinaButton == nil then
			player.playMsgFordinaButton = delta + 180
		end
		player.playMsgFordinaButton = player.playMsgFordinaButton - delta
		if player.playMsgFordinaButton < 0 then
			player:removeCustom(playMsgFordinaButton)
			playMsgFordinaButton = nil
		end
	end
	if playMsgGremus6Button ~= nil then
		if player.playMsgGremus6Button == nil then
			player.playMsgGremus6Button = delta + 180
		end
		player.playMsgGremus6Button = player.playMsgGremus6Button - delta
		if player.playMsgGremus6Button < 0 then
			player:removeCustom(playMsgGremus6Button)
			playMsgGremus6Button = nil
		end
	end
end
function randomStation()
	idx = math.floor(random(1, #stationList + 0.99))
	return stationList[idx]
end

function transportSpawn(delta)
	-- Remove any stations from the list if they have been destroyed
	if #stationList > 0 then
		for idx, obj in ipairs(stationList) do
			if not obj:isValid() then
				table.remove(stationList, idx)
			end
		end
	end
	cnt = 0		-- Initialize transport count
	-- Count transports, remove destroyed transports from list, send transport to random station if docked
	if #transportList > 0 then
		for idx, obj in ipairs(transportList) do
			if not obj:isValid() then
				--Transport destroyed, remove it from the list
				table.remove(transportList, idx)
			else
				if obj:isDocked(obj.target) then
					if obj.undock_delay > 0 then
						obj.undock_delay = obj.undock_delay - delta
					else
						obj.target = randomStation()
						obj.undock_delay = random(5, 30)
						obj:orderDock(obj.target)
					end
				end
				cnt = cnt + 1
			end
		end
	end
	-- Create another transport if fewer than maximum present, send to random station
	if cnt < maxTransport then
		target = randomStation()
		if target:isValid() then
			rnd = irandom(1,5)
			if rnd == 1 then
				name = "Personnel"
			elseif rnd == 2 then
				name = "Goods"
			elseif rnd == 3 then
				name = "Garbage"
			elseif rnd == 4 then
				name = "Equipment"
			else
				name = "Fuel"
			end
			if irandom(1,100) < 15 then
				name = name .. " Jump Freighter " .. irandom(3, 5)
			else
				name = name .. " Freighter " .. irandom(1, 5)
			end
			obj = CpuShip():setTemplate(name):setFaction(neutralFaction)
			obj.target = target
			obj.undock_delay = random(5, 30)
			obj:orderDock(obj.target)
			x, y = obj.target:getPosition()
			xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			table.insert(transportList, obj)
		end
	end
	transportPlot = transportWait
	transportDelay = 0.0
end

function transportWait(delta)
	transportDelay = transportDelay + delta
	if transportDelay > 8 then
		transportPlot = transportSpawn
	end
end

-- Chase player until enemies destroyed or player gets away
function chasePlayer(delta)
	kraylorChaserCount = 0
	nearestChaser = 0
	askForOrders = "orders"		-- Turn on order messages in station communications
	for _, enemy in ipairs(kraylorChaserList) do
		if enemy:isValid() then
			kraylorChaserCount = kraylorChaserCount + 1
			if nearestChaser == 0 then
				nearestChaser = distance(player, enemy)
			else
				nearestChaser = math.min(nearestChaser, distance(player,enemy))
			end
		end
	end
	if kraylorChaserCount == 0 then
		plot1 = getAmbassador
	elseif nearestChaser > 6000 then
		plot1 = getAmbassador
	end
end

-- Tell player to get the ambassador. Create the planet. Start the revolution delay timer
function getAmbassador(delta)
	outpost41:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: CMDMICHL012")
	player:addToShipLog(string.format("[CMDMICHL012](Commander Michael) %s, avoid contact where possible. Get ambassador Gremus at Balindor Prime",playerCallSign),"Yellow")
	if playMsgMichaelButton == nil then
		playMsgMichaelButton = "play"
		player:addCustomButton("Relay",playMsgMichaelButton,"|> CMDMICHL012",playMsgMichael)
	end
	balindorPrime = Planet():setPosition(-50500,84000):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0):setAxialRotationTime(400.0)
	plot1 = ambassadorAboard
	ambassadorEscapedBalindor = false
	fomentTimer = 0.0
	plot2 = revolutionFomenting
	plot3 = balindorInterceptor
	askForBalindorLocation = "ready"
end

function playMsgMichael()
	playSoundFile("sa_51_Michael.ogg")
	player:removeCustom(playMsgMichaelButton)
	playMsgMichaelButton = nil
end

-- Update delay timer. Once timer expires, start revolution timer. Tell player about limited time for mission
function revolutionFomenting(delta)
	fomentTimer = fomentTimer + delta
	if fomentTimer > 60 then
		bpcommnex:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS001")
		player:addToShipLog("[AMBGREMUS001](Ambassador Gremus) I am glad you are coming to get me. There is serious unrest here on Balindor Prime. I am not sure how long I am going to survive. Please hurry, I can hear a mob outside my compound.","Yellow")
		if playMsgGremus1Button == nil then
			playMsgGremus1Button = "play"
			player:addCustomButton("Relay",playMsgGremus1Button,"|> AMBGREMUS001",playMsgGremus1)
		end
		breakoutTimer = 60 * 5
		plot2 = revolutionOccurs
	end
end

function playMsgGremus1()
	playSoundFile("sa_51_Gremus1.ogg")
	player:removeCustom(playMsgGremus1Button)
	playMsgGremus1Button = nil
end

-- Update revolution timer. If timer expires before ship arrives, Gremus dies and mission fails.
function revolutionOccurs(delta)
	breakoutTimer = breakoutTimer - delta
	if breakoutTimer < 0 then
		if ambassadorEscapedBalindor then
			bpcommnex:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: GREMUSGRD003")
			player:addToShipLog("[GREMUSGRD003](Compound Sentry) You got ambassador Gremus just in time. We barely escaped the mob with our lives. I don't recommend bringing the ambassador back anytime soon.","Yellow")
			if playMsgSentry1Button == nil then
				playMsgSentry1Button = "play"
				player:addCustomButton("Relay",playMsgSentry1Button,"|> GREMUSGRD003",playMsgSentry1)
			end
			plot2 = nil
		else
			globalMessage([[Ambassador lost to hostile mob. The Kraylors are victorious]])
			bpcommnex:sendCommsMessage(player, [[(Compound Sentry) I'm sad to report the loss of ambassador Gremus to a hostile mob.]])
			playSoundFile("sa_51_Sentry2.ogg")
			plot2 = defeat
		end
		if player.mob_timer ~= nil then
			player:removeCustom(player.mob_timer)
			player.mob_timer = nil
		end
		if player.mob_timer_ops ~= nil then
			player:removeCustom(player.mob_timer_ops)
			player.mob_timer_ops = nil
		end
	else
		local mob_label = "Mob Action"
		local mob_minutes = math.floor(breakoutTimer / 60)
		local mob_seconds = math.floor(breakoutTimer % 60)
		if mob_minutes <= 0 then
			mob_label = string.format("%s %i",mob_label,mob_seconds)
		else
			mob_label = string.format("%s %i:%.2i",mob_label,mob_minutes,mob_seconds)
		end
		if player:hasPlayerAtPosition("Relay") then
			player.mob_timer = "mob_timer"
			player:addCustomInfo("Relay",player.mob_timer,mob_label)
		end
		if player:hasPlayerAtPosition("Operations") then
			player.mob_timer_ops = "mob_timer_ops"
			player:addCustomInfo("Operations",player.mob_timer_ops,mob_label)
		end
	end
end

function playMsgSentry1()
	playSoundFile("sa_51_Sentry1.ogg")
	player:removeCustom(playMsgSentry1Button)
	playMsgSentry1Button = nil
end

function defeat(delta)
	victory(kraylorFaction)
end

-- Create and send mission prevention enemies
function balindorInterceptor(delta)
	if distance(player,-50500,84000) < 35000 then
		local ao = 20000	-- ambush offset
		local fo = 1000		-- formation offset
		kraylorBalindorInterceptorList = {}
		local x, y = player:getPosition()
		kraylorBalindorInterceptor1 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x-ao,y+ao):setHeading(45)
		kraylorBalindorInterceptor1:orderAttack(player)
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor1)
		kraylorBalindorInterceptor2 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x-(ao+fo),y+ao):setHeading(45)
		kraylorBalindorInterceptor2:orderFlyFormation(kraylorBalindorInterceptor1,fo,0)
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor2)
		kraylorBalindorInterceptor3 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x+ao,y-ao):setHeading(225)
		kraylorBalindorInterceptor3:orderAttack(player)
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor3)
		kraylorBalindorInterceptor4 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x+ao+fo,y-ao):setHeading(225)
		kraylorBalindorInterceptor4:orderFlyFormation(kraylorBalindorInterceptor3,-fo,0)
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor4)
		if getScenarioVariation() ~= "Easy" then
			kraylorBalindorInterceptor5 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x-ao,y+ao+fo):setHeading(45)
			kraylorBalindorInterceptor5:orderFlyFormation(kraylorBalindorInterceptor1,0,fo)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor5)
			kraylorBalindorInterceptor6 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x-(ao+fo),y+ao+fo):setHeading(45)
			kraylorBalindorInterceptor6:orderFlyFormation(kraylorBalindorInterceptor1,fo,fo)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor6)
			kraylorBalindorInterceptor7 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x+ao,y-(ao+fo)):setHeading(225)
			kraylorBalindorInterceptor7:orderFlyFormation(kraylorBalindorInterceptor3,0,-fo)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor7)
			kraylorBalindorInterceptor8 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x+ao+fo,y-(ao+fo)):setHeading(225)
			kraylorBalindorInterceptor8:orderFlyFormation(kraylorBalindorInterceptor3,-fo,-fo)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor8)
		end
		if getScenarioVariation() == "Hard" then
			kraylorBalindorInterceptor9 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x-ao,y+ao+fo*2):setHeading(45)
			kraylorBalindorInterceptor9:orderFlyFormation(kraylorBalindorInterceptor1,0,fo*2)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor9)
			kraylorBalindorInterceptor10 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x-(ao+fo*2),y+ao):setHeading(45)
			kraylorBalindorInterceptor10:orderFlyFormation(kraylorBalindorInterceptor1,fo*2,0)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor10)
			kraylorBalindorInterceptor11 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x+ao,y-(ao+fo*2)):setHeading(225)
			kraylorBalindorInterceptor11:orderFlyFormation(kraylorBalindorInterceptor3,0,-fo*2)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor11)
			kraylorBalindorInterceptor12 = CpuShip():setTemplate(piranhaF8):setFaction(kraylorFaction):setPosition(x+ao+fo*2,y-ao):setHeading(225)
			kraylorBalindorInterceptor12:orderFlyFormation(kraylorBalindorInterceptor3,-fo*2,0)
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor12)
		end
		plot3 = nil
	end
end

-- Now that Gremus is aboard, transport to Ningling requested. Create Ningling station
function ambassadorAboard(delta)
	if distance(player, balindorPrime) < 3300 then
		ambassadorEscapedBalindor = true
		bpcommnex:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS004")
		player:addToShipLog("[AMBGREMUS004](Ambassador Gremus) Thanks for bringing me aboard. Please transport me to Ningling.","Yellow")
		if playMsgGremus2Button == nil then
			playMsgGremus2Button = "play"
			player:addCustomButton("Relay",playMsgGremus2Button,"|> AMBGREMUS004",playMsgGremus2)
		end		
		playSoundFile("sa_51_Gremus2.ogg")
		ningling = SpaceStation():setTemplate(largeStation):setFaction(humanFaction):setCommsScript(""):setCommsFunction(commsStation)
		ningling:setPosition(12200,-62600):setCallSign("Ningling")
		stationFranklin:addReputationPoints(25.0)
		if getScenarioVariation() ~= "Hard" then
			stationFranklin:addReputationPoints(25.0)
		end
		plot1 = gotoNingling
		plot3 = ningAttack
		askForNingLocation = "ready"
	end
end

function playMsgGremus2()
	playSoundFile("sa_51_Gremus2.ogg")
	player:removeCustom(playMsgGremus2Button)
	playMsgGremus2Button = nil
end

-- Create and send more enemies to stop mission 
function ningAttack(delta)
	if distance(player, balindorPrime) > 30000 then
		local ao = 10000	-- ambush offset
		local fo = 500		-- formation offset
		kraylorNingList = {}
		local x, y = player:getPosition()
		kraylorNing1 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x,y-ao):setHeading(180)
		kraylorNing1:orderAttack(player)
		table.insert(kraylorNingList,kraylorNing1)
--		kraylorNing2 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x-fo*2,y-ao):setHeading(180)
--		kraylorNing2:orderFlyFormation(kraylorNing1,-fo*2,0)
--		table.insert(kraylorNingList,kraylorNing2)
--		kraylorNing3 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+fo*2,y-ao):setHeading(180)
--		kraylorNing3:orderFlyFormation(kraylorNing1,fo*2,0)
--		table.insert(kraylorNingList,kraylorNing3)
		kraylorNing4 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x,y+ao):setHeading(0)
		kraylorNing4:orderAttack(player)
		table.insert(kraylorNingList,kraylorNing4)
--		kraylorNing5 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x-fo*2,y+ao):setHeading(0)
--		kraylorNing5:orderFlyFormation(kraylorNing4,-fo*2,0)
--		table.insert(kraylorNingList,kraylorNing5)
--		kraylorNing6 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+fo*2,y+ao):setHeading(0)
--		kraylorNing6:orderFlyFormation(kraylorNing4,fo*2,0)
--		table.insert(kraylorNingList,kraylorNing6)
		if getScenarioVariation() ~= "Easy" then
			kraylorNing7 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x-fo,y-ao-fo*2):setHeading(180)
			kraylorNing7:orderFlyFormation(kraylorNing1,-fo,-fo*2)
			table.insert(kraylorNingList,kraylorNing7)
--			kraylorNing8 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+fo,y-ao-fo*2):setHeading(180)
--			kraylorNing8:orderFlyFormation(kraylorNing1,fo,-fo*2)
--			table.insert(kraylorNingList,kraylorNing8)
			kraylorNing9 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x-fo,y+ao+fo*2):setHeading(0)
			kraylorNing9:orderFlyFormation(kraylorNing4,-fo,fo*2)
			table.insert(kraylorNingList,kraylorNing9)
--			kraylorNing10 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+fo,y+ao+fo*2):setHeading(0)
--			kraylorNing10:orderFlyFormation(kraylorNing4,fo,fo*2)
--			table.insert(kraylorNingList,kraylorNing10)
		end
		if getScenarioVariation() == "Hard" then
			kraylorNing11 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x-fo,y-ao+fo*2):setHeading(180)
			kraylorNing11:orderFlyFormation(kraylorNing1,-fo,fo*2)
			table.insert(kraylorNingList,kraylorNing11)
--			kraylorNing12 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+fo,y-ao+fo*2):setHeading(180)
--			kraylorNing12:orderFlyFormation(kraylorNing1,fo,fo*2)
--			table.insert(kraylorNingList,kraylorNing12)
			kraylorNing13 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x-fo,y+ao-fo*2):setHeading(0)
			kraylorNing13:orderFlyFormation(kraylorNing4,-fo,-fo*2)
			table.insert(kraylorNingList,kraylorNing13)
--			kraylorNing14 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+fo,y+ao-fo*2):setHeading(0)
--			kraylorNing14:orderFlyFormation(kraylorNing4,fo,-fo*2)
--			table.insert(kraylorNingList,kraylorNing14)					
		end
		plot3 = nil
	end
end

-- Tell player to wait for Gremus to finish before next mission goal. Set meeting timer
function gotoNingling(delta)
	if not ningling:isValid() then
		victory(kraylorFaction)
	end
	if player:isDocked(ningling) then
		ningling:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: NINGPCLO002")
		player:addToShipLog("[NINGPCLO002](Ningling Protocol Officer) Ambassador Gremus arrived. The ambassador is scheduled for a brief meeting with liaison Fordina. After that meeting, you will be asked to transport the ambassador to Goltin 7. We will contact you after the meeting.","Yellow")
		if playMsgProtocolButton == nil then
			playMsgProtocolButton = "play"
			player:addCustomButton("Relay",playMsgProtocolButton,"|> NINGPCLO002",playMsgProtocol)
		end
		playSoundFile("sa_51_Protocol.ogg")
		plot1 = waitForAmbassador
		meetingTimer = 0.0
		plot3 = ningWait
	end
end

function playMsgProtocol()
	playSoundFile("sa_51_Protocol.ogg")
	player:removeCustom(playMsgProtocolButton)
	playMsgProtocolButton = nil
end

-- While waiting, spawn more enemies to stop mission
function ningWait(delta)
	local x, y = ningling:getPosition()
	local ao = 25000
	local fo = 1200
	waitNingList = {}
	waitNing1 = CpuShip():setTemplate(hornetMT52):setFaction(kraylorFaction):setPosition(x+ao,y+ao):setHeading(315)
	waitNing1:orderAttack(player)
	table.insert(waitNingList,waitNing1)
	if getScenarioVariation() ~= "Easy" then
		waitNing2 = CpuShip():setTemplate(hornetMU52):setFaction(kraylorFaction):setPosition(x+ao+fo,y+ao):setHeading(315)
		waitNing2:orderFlyFormation(waitNing1,fo,0)
		table.insert(waitNingList,waitNing2)
		waitNing3 = CpuShip():setTemplate(adderMK4):setFaction(kraylorFaction):setPosition(x+ao,y+ao+fo):setHeading(315)
		waitNing3:orderFlyFormation(waitNing1,0,fo)
		table.insert(waitNingList,waitNing3)
	end
	if getScenarioVariation() == "Hard" then
		waitNing4 = CpuShip():setTemplate("Adder MK5"):setFaction(kraylorFaction):setPosition(x+ao+fo*2,y+ao):setHeading(315)
		waitNing4:orderFlyFormation(waitNing1,fo*2,0)
		table.insert(waitNingList,waitNing4)
		waitNing5 = CpuShip():setTemplate("Adder MK5"):setFaction(kraylorFaction):setPosition(x+ao,y+ao+fo*2):setHeading(315)
		waitNing5:orderFlyFormation(waitNing1,0,fo*2)
		table.insert(waitNingList,waitNing5)
	end
	plot3 = nil
end

-- When meeting completes, request dock for next mission goal
function waitForAmbassador(delta)
	if not ningling:isValid() then
		victory(kraylorFaction)
	end
	meetingTimer = meetingTimer + delta
	if meetingTimer > 60 * 5 and not player:isDocked(ningling) then
		ningling:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS007")
		player:addToShipLog(string.format("[AMBGREMUS007](Ambassador Gremus) %s, I am ready to be transported to Goltin 7. Please dock with Ningling",playerCallSign),"Yellow")
		if playMsgGremus3Button == nil then
			playMsgGremus3Button = "play"
			player:addCustomButton("Relay",playMsgGremus3Button,"|> AMBGREMUS007",playMsgGremus3)
		end
		plot1 = getFromNingling
	end
end

function playMsgGremus3()
	playSoundFile("sa_51_Gremus3.ogg")
	player:removeCustom(playMsgGremus3Button)
	playMsgGremus3Button = nil
end

-- Set next goal: Goltin 7. Inform player. Create planet. Start sub-plots
function getFromNingling(delta)
	if not ningling:isValid() then
		victory(kraylorFaction)
	end
	if player:isDocked(ningling) then
		ningling:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS021")
		player:addToShipLog("[AMBGREMUS021](Ambassador Gremus) Thank you for waiting and then for coming back and getting me. I needed the information provided by liaison Fordina to facilitate negotiations at Goltin 7. Let us away!","Yellow")
		player:addToShipLog("Reconfigured beam weapons: pointed one forward, increased range and narrowed focus of rearward","Magenta")
		if playMsgGremus4Button == nil then
			playMsgGremus4Button = "play"
			player:addCustomButton("Relay",playMsgGremus4Button,"|> AMBGREMUS021",playMsgGremus4)
		end
		player:setTypeName("Flavia P. Falcon MK2")
		player:setBeamWeapon(0, 40, 180, 1200.0, 6.0, 6)
		player:setBeamWeapon(1, 20, 0, 1600.0, 6.0, 6)
		goltin = Planet():setPosition(93150,21387):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(80.0)
		artifactResearchCount = 0
		plot1 = travelGoltin
		plot2 = lastSabotage
		plot3 = artifactResearch
		askForGoltinLocation = "ready"
	end
end

function playMsgGremus4()
	playSoundFile("sa_51_Gremus4.ogg")
	player:removeCustom(playMsgGremus4Button)
end

-- Expand artifact sub-plot after player leaves Ningling
function artifactResearch(delta)
	if distance(player, ningling) > 10000 then
		ningling:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: LSNFRDNA009")
		player:addToShipLog("[LSNFRDNA009](Liaison Fordina) Ambassador Gremus, we just received that follow-up information from Goltin 7 we spoke of. It seems they want additional information about several artifacts. Some of these have been reported by stations in the area: Pangora, Nakor and Science-37.","Yellow")
		if playMsgFordinaButton == nil then
			playMsgFordinaButton = "play"
			player:addCustomButton("Relay",playMsgFordinaButton,"|> LSNFRDNA009",playMsgFordina)
		end
		playSoundFile("sa_51_Fordina.ogg")
		askForPangoraLocation = "ready"
		askForNakorLocation = "ready"
		askForScience37Location = "ready"
		plot3 = artifactByStation
		nearPangora = "ready"
		nearNakor = "ready"
		nearScience37 = "ready"
	end
end

function playMsgFordina()
	playSoundFile("sa_51_Fordina.ogg")
	player:removeCustom(playMsgFordinaButton)
	playMsgFordinaButton = nil
end

-- When the player docks, create the artifact nearby. Enable message additions to station relay messages
function artifactByStation(delta)
	if player:isDocked(stationPangora) then
		if nearPangora == "ready" then
			x, y = stationPangora:getPosition()
			nPangora = Artifact():setPosition(x+35000,y+38000):setScanningParameters(3,2):setRadarSignatureInfo(random(2,8),random(2,8),random(2,8))
			nPangora:setModel("artifact3"):allowPickup(false)
			nPangora.beta_radiation = irandom(3,15)
			nPangora.gravity_disruption = irandom(1,21)
			nPangora.ionic_phase_shift = irandom(5,32)
			nPangora.doppler_instability = irandom(1,9)
			nPangora:setDescriptions("Unusual object floating in space", string.format([[Object gives off unusual readings:
			Beta radiation: %i
			Gravity disruption: %i
			Ionic phase shift: %i
			Doppler instability: %i]],nPangora.beta_radiation, nPangora.gravity_disruption, nPangora.ionic_phase_shift, nPangora.doppler_instability))
			nearPangora = "created"
		end
		askForPangoraArtifactLocation = "ready"
	end
	if player:isDocked(stationNakor) then
		if nearNakor == "ready" then
			x, y = stationNakor:getPosition()
			nNakor = Artifact():setPosition(x-35000,y-36000):setScanningParameters(2,3):setRadarSignatureInfo(random(2,5),random(2,5),random(2,8))
			nNakor:setModel("artifact5"):allowPickup(false)
			nNakor.gamma_radiation = irandom(1,9)
			nNakor.organic_decay = irandom(3,43)
			nNakor.gravity_disruption = irandom(2,13)
			nNakor:setDescription("Object with unusual visual properties", string.format([[Sensor readings of interest:
			Gamma radiation: %i
			Organic decay: %i
			Gravity disruption: %i]],nNakor.gamma_radiation, nNakor.organic_decay, nNakor.gravity_disruption))
			nearNakor = "created"
		end
		askForNakorArtifactLocation = "ready"
	end
	if player:isDocked(science37) then
		if nearScience37 == "ready" then
			x, y = science37:getPosition()
			nScience37 = Artifact():setPosition(x+1000,y-40000):setScanningParameters(4,1):setRadarSignatureInfo(random(3,9),random(1,5),random(2,4))
			nScience37:setModel("artifact6"):allowPickup(true)
			nScience37.ionic_phase_shift = irandom(1,9)
			nScience37.organic_decay = irandom(3,13)
			nScience37.theta_particle_emission = irandom(1,15)
			nScience37:setDescription("Small object floating in space", string.format([[Sensors show:
			Ionic pase shift: %i
			Organic decay: %i
			Theta particle emission: %i]],nScience37.ionic_phase_shift, nScience37.organic_decay, nScience37.theta_particle_emission))
			nearScience37 = "created"
		end
		askForScience37ArtifactLocation = "ready"
	end
	if nPangora:isValid() then
		if nPangora:isScannedBy(player) then
			artifactResearchCount = artifactResearchCount + 1
		end
		if distance(player,nPangora) < 5000 then
			pangoraExplodeCountdown = 0.0
			nPangora.gravity_disruption = nPangora.gravity_disruption + 1
			nPangora:setDescriptions("Unusual object floating in space", string.format([[Object gives off unusual readings:
			Beta radiation: %i
			Gravity disruption: %i
			Ionic phase shift: %i
			Doppler instability: %i]],nPangora.beta_radiation, nPangora.gravity_disruption, nPangora.ionic_phase_shift, nPangora.doppler_instability))			
			plot4 = pangoraArtifactChange
		end
	end
	if nNakor:isValid() then
		if nNakor:isScannedBy(player) then
			artifactResearchCount = artifactResearchCount + 1
		end
	end
	if nScience37:isValid() then
		if nScience37:isScannedBy(player) then
			artifactResearchCount = artifactResearchCount + 1
		end
	end
end

function pangoraArtifactChange(delta)
	player:addCustomMessage("Science", "Warning", "The readings on the Pangora artifact have changed") --not working
	plot4 = pangoraArtifactExplode
end

function pangoraArtifactExplode(delta)
	pangoraExplodeCountdown = pangoraExplodeCountdown + delta
	if pangoraExplodeCountdown > 15 then
		if distance(player,nPangora) < 6000 then
			player:setSystemHealth("reactor", player:getSystemHealth("reactor") - random(0.0, 0.5))
			player:setSystemHealth("beamweapons", player:getSystemHealth("beamweapons") - random(0.0, 0.5))
			player:setSystemHealth("maneuver", player:getSystemHealth("maneuver") - random(0.0, 0.5))
			player:setSystemHealth("missilesystem", player:getSystemHealth("missilesystem") - random(0.0, 0.5))
			player:setSystemHealth("impulse", player:getSystemHealth("impulse") - random(1.3, 1.5))
			player:setSystemHealth("warp", player:getSystemHealth("warp") - random(1.3, 1.5))
			player:setSystemHealth("jumpdrive", player:getSystemHealth("jumpdrive") - random(1.3, 1.5))
			player:setSystemHealth("frontshield", player:getSystemHealth("frontshield") - random(0.0, 0.5))
			player:setSystemHealth("rearshield", player:getSystemHealth("rearshield") - random(0.0, 0.5))
		end
		nPangora:explode()
		player:removeCustom("Warning")
		plot4 = nil
	end
end

-- Last ditch attempt to sabotage mission - the big guns
function lastSabotage(delta)
	if distance(player, ningling) > 40000 then
		local ao = 30000
		local fo = 2500
		local x, y = player:getPosition()
		goltinList = {}
		goltin1 = CpuShip():setTemplate(atlantisX23):setFaction(kraylorFaction):setPosition(x+ao,y+ao):setHeading(315)
		goltin1:orderAttack(player)
		table.insert(goltinList,goltin1)
		goltin2 = CpuShip():setTemplate(starhammerII):setFaction(kraylorFaction):setPosition(x,y+ao):setHeading(0)
		goltin2:orderAttack(player)
		table.insert(goltinList,goltin2)
		goltin3 = CpuShip():setTemplate(stalkerQ7):setFaction(kraylorFaction):setPosition(x+ao,y):setHeading(270)
		goltin3:orderAttack(player)
		table.insert(goltinList,goltin3)
		if getScenarioVariation() ~= "Easy" then
			goltin4 = CpuShip():setTemplate(stalkerR7):setFaction(kraylorFaction):setPosition(x+ao+fo,y+ao-fo):setHeading(315)
			goltin4:orderAttack(player)
			table.insert(goltinList,goltin4)
			goltin5 = CpuShip():setTemplate(ranusU):setFaction(kraylorFaction):setPosition(x+fo,y+ao):setHeading(0)
			goltin5:orderAttack(player)
			table.insert(goltinList,goltin5)
			goltin6 = CpuShip():setTemplate(phobosT3):setFaction(kraylorFaction):setPosition(x+ao,y-fo):setHeading(270)
			goltin6:orderAttack(player)
			table.insert(goltinList,goltin6)
		end
		if getScenarioVariation() == "Hard" then
			goltin7 = CpuShip():setTemplate(nirvanaR5):setFaction(kraylorFaction):setPosition(x+ao-fo,y+ao+fo):setHeading(315)
			goltin7:orderAttack(player)
			table.insert(goltinList,goltin7)
			goltin8 = CpuShip():setTemplate(piranhaF12):setFaction(kraylorFaction):setPosition(x-fo,y+ao):setHeading(0)
			goltin8:orderAttack(player)
			table.insert(goltinList,goltin8)
			goltin9 = CpuShip():setTemplate(nirvanaR5A):setFaction(kraylorFaction):setPosition(x+ao,y+fo):setHeading(270)
			goltin9:orderAttack(player)
			table.insert(goltinList,goltin9)
		end
		plot2 = nil
	end
end

-- Arrive at Goltin 7: win if research done or identify artifact research as required for mission completion.
function travelGoltin(delta)
	if artifactResearchCount > 0 then
		if distance(player,goltin) < 3300 then
			globalMessage([[Goltin 7 welcomes ambassador Gremus]])
			goltincomms:sendCommsMessage(player, "(Ambassador Gremus) Thanks for transporting me, "..playerCallSign..[[. Tensions are high, but I think negotiations will succeed. 
			In the meantime, be careful of hostile ships.]])
			playSoundFile("sa_51_Gremus5.ogg")
			lastMessage = 0.0
			plot1 = finalMessage
		end
	else
		if distance(player, goltin) < 3300 then
			goltincomms:sendCommsMessage(player, "Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS032")
			player:addToShipLog(string.format("[AMBGREMUS032](Ambassador Gremus) Thanks for transporting me, %s. I will need artifact research for successful negotiation. Please return with that research when you can.",playerCallSign),"Yellow")
			if playMsgGremus6Button == nil then
				playMsgGremus6Button = "play"
				player:addCustomButton("Relay",playMsgGremus6Button,"|> AMBGREMUS021",playMsgGremus6)
			end			
			plot1 = departForResearch
		end
	end
end

function playMsgGremus6()
	playSoundFile("sa_51_Gremus6.ogg")
	player:removeCustom(playMsgGremus6Button)
	playMsgGremus6Button = nil
end

function departForResearch(delta)
	if distance(player,goltin) > 30000 then
		plot1 = goltinAndResearch
	end
end

-- Win upon return with research
function goltinAndResearch(delta)
	if artifactResearchCount > 0 then
		if distance(player,goltin) < 3300 then
			globalMessage([[Goltin 7 welcomes ambassador Gremus]])
			goltincomms:sendCommsMessage(player, "(Ambassador Gremus) Thanks for researching the artifacts, "..playerCallSign..[[. Tensions are high, but I think negotiations will succeed. In the meantime, be careful of hostile ships.]])
			playSoundFile("sa_51_Gremus7.ogg")
			lastMessage = 0.0
			plot1 = finalMessage			
		end
	end
end

function finalMessage(delta)
	lastMessage = lastMessage + delta
	if lastMessage > 20 then
		plot1 = nil
	end
end

-- Incorporated stations communications script so that I can add messages as needed
function commsStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = random(0.0, 100.0),
        weapons = {
            Homing = "neutral",
            HVLI = "neutral",
            Mine = "neutral",
            Nuke = "friend",
            EMP = "friend"
        },
        weapon_cost = {
            Homing = 2,
            HVLI = 2,
            Mine = 2,
            Nuke = 15,
            EMP = 10
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
        },
        service_cost = {
            supplydrop = 100,
            reinforcements = 150,
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 2.5
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
    comms_data = comms_target.comms_data

    if player:isEnemy(comms_target) then
        return false
    end

    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not player:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end

function handleDockedState()
    -- Handle communications while docked with this station.
    if player:isFriendly(comms_target) then
        setCommsMessage("Good day, officer!\nWhat can we do for you today?")
    else
        setCommsMessage("Welcome to our lovely station.")
    end

    if player:getWeaponStorageMax(homing) > 0 then
        addCommsReply("Do you have spare homing missiles for us? ("..getWeaponCost(homing).."rep each)", function()
            handleWeaponRestock(homing)
        end)
    end
    if player:getWeaponStorageMax(hvli) > 0 then
        addCommsReply("Can you restock us with HVLI? ("..getWeaponCost(hvli).."rep each)", function()
            handleWeaponRestock(hvli)
        end)
    end
    if player:getWeaponStorageMax(mine) > 0 then
        addCommsReply("Please re-stock our mines. ("..getWeaponCost(mine).."rep each)", function()
            handleWeaponRestock(mine)
        end)
    end
    if player:getWeaponStorageMax(nuke) > 0 then
        addCommsReply("Can you supply us with some nukes? ("..getWeaponCost(nuke).."rep each)", function()
            handleWeaponRestock(nuke)
        end)
    end
    if player:getWeaponStorageMax(emp) > 0 then
        addCommsReply("Please re-stock our EMP missiles. ("..getWeaponCost(emp).."rep each)", function()
            handleWeaponRestock(emp)
        end)
    end
	-- Include helpful location waypoint providers for handling large map
	if isAllowedTo(askForBalindorLocation) then
		addCommsReply("Where is Balindor Prime?", function()
			player:commandAddWaypoint(-50500,84000)
			setCommsMessage(string.format("Added waypoint %i to your navigation system for Balindor Prime",player:getWaypointCount()))
			askForBalindorLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForNingLocation) then
		addCommsReply("Where is Ningling?", function()
			player:commandAddWaypoint(12200,-62600)
			setCommsMessage(string.format("Added waypoint %i for Ningling station",player:getWaypointCount()))
			askForNingLocation = "complete"
			addCommsReply("Back", commsStation)			
		end)
	end
	if isAllowedTo(askForGoltinLocation) then
		addCommsReply("Where is Goltin 7?", function()
			player:commandAddWaypoint(93150,21387)
			setCommsMessage(string.format("Added waypoint %i for Goltin 7",player:getWaypointCount()))
			askForGoltinLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForPangoraLocation) then
		addCommsReply("Where is Pangora?", function()
			player:commandAddWaypoint(stationPangora:getPosition())
			setCommsMessage(string.format("Added waypoint %i for Pangora station",player:getWaypointCount()))
			askForPangoraLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForNakorLocation) then
		addCommsReply("Where is Nakor?", function()
			player:commandAddWaypoint(stationNakor:getPosition())
			setCommsMessage(string.format("Added waypoint %i for Nakor station",player:getWaypointCount()))
			askForNakorLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForScience37Location) then
		addCommsReply("Where is Science-37?", function()
			player:commandAddWaypoint(science37:getPosition())
			setCommsMessage(string.format("Added a waypoint %i for station Science-37",player:getWaypointCount()))
			askForScience37Location = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	-- Include clue messages for artifacts near identified stations
	if isAllowedTo(askForPangoraArtifactLocation) then
		addCommsReply("Any reports of artifacts near Pangora?", function()
			setCommsMessage("Some freighters report seeing an artifact on approximate heading 135 from Pangora")
			askForPangoraArtifactLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForNakorArtifactLocation) then
		addCommsReply("Heard of any artifacts near Nakor?", function()
			setCommsMessage("Some have reported seeing object on approximate heading of 315 from Nakor station")
			askForNakorArtifactLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForScience37ArtifactLocation) then
		addCommsReply("Has anyone reported seeing artifacts near Science-37?", function()
			setCommsMessage("Freighters doing business here occasionally report an object on approximate heading zero from Science-37 station")
			askForScience37ArtifactLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	-- Include orders upon request for when they are missed
	if isAllowedTo(askForOrders) then
		addCommsReply("What are my current orders?", function()
			oMessage = ""
			if plot1 == chasePlayer or plot1 == getAmbassador or plot1 == ambassadorAboard then
				oMessage = "Current Orders: Get ambassador Gremus from Balindor Prime. Avoid contact if possible. "
			elseif plot1 == gotoNingling then
				oMessage = "Current Orders: Transport ambassador Gremus to Ningling. "
			elseif plot1 == waitForAmbassador then
				oMessage = "Current Orders: Wait for ambassador Gremus to complete business at Ningling. "
			elseif plot1 == getFromNingling then
				oMessage = "Current Orders: Dock with Ningling to get ambassador Gremus. "
			elseif plot1 == travelGoltin then
				oMessage = "Current Orders: Transport ambassador Gremus to Goltin 7. "
			end
			if plot3 == artifactResearch or plot3 == artifactByStation then
				oMessage = oMessage.."Additional Orders: Research artifacts. Some artifacts reported near Pangora, Nakor and Science-37. "
				if plot1 == departForResearch or plot1 == goltinAndResearch then
					oMessage = oMessage.."Provide artifact research to ambassador Gremus on Goltin 7. "
				end
			end
			setCommsMessage(oMessage)
			addCommsReply("Back", commsStation)
		end)
	end
end

function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then setCommsMessage("You need to stay docked for that action."); return end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == nuke then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == emp then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == nuke then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage("Not enough reputation.")
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage("You are fully loaded and ready to explode things.")
        else
            setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
        end
        addCommsReply("Back", commsStation)
    end
end

function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        setCommsMessage("Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        setCommsMessage("Greetings.\nIf you want to do business, please dock with us first.")
    end
    if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage("We have dispatched a supply ship toward WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply("Please send reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
                        else
                            setCommsMessage("Not enough reputation!");
                        end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
	-- Add helpful waypoint creation messages
	if isAllowedTo(askForBalindorLocation) then
		addCommsReply("Where is Balindor Prime?", function()
			player:commandAddWaypoint(-50500,84000)
			setCommsMessage("Added a waypoint to your navigation system for Balindor Prime")
			askForBalindorLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForNingLocation) then
		addCommsReply("Where is Ningling?", function()
			player:commandAddWaypoint(12200,-62600)
			setCommsMessage("Added a waypoint for Ningling station")
			askForNingLocation = "complete"
			addCommsReply("Back", commsStation)			
		end)
	end
	if isAllowedTo(askForGoltinLocation) then
		addCommsReply("Where is Goltin 7?", function()
			player:commandAddWaypoint(93150,21387)
			setCommsMessage("Added a waypoint for Goltin 7")
			askForGoltinLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForPangoraLocation) then
		addCommsReply("Where is Pangora?", function()
			player:commandAddWaypoint(stationPangora:getPosition())
			setCommsMessage("Added a waypoint for Pangora station")
			askForPangoraLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForNakorLocation) then
		addCommsReply("Where is Nakor?", function()
			player:commandAddWaypoint(stationNakor:getPosition())
			setCommsMessage("Added a waypoint for Nakor station")
			askForNakorLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForScience37Location) then
		addCommsReply("Where is Science-37?", function()
			player:commandAddWaypoint(science37:getPosition())
			setCommsMessage("Added a waypoint for station Science-37")
			askForScience37Location = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	-- Add artifact location clues
	if isAllowedTo(askForPangoraArtifactLocation) then
		addCommsReply("Any reports of artifacts near Pangora?", function()
			setCommsMessage("Some freighters report seeing an artifact on approximate heading 135 from Pangora")
			askForPangoraArtifactLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForNakorArtifactLocation) then
		addCommsReply("Heard of any artifacts near Nakor?", function()
			setCommsMessage("Some have reported seeing object on approximate heading of 315 from Nakor station")
			askForNakorArtifactLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
	if isAllowedTo(askForScience37ArtifactLocation) then
		addCommsReply("Has anyone reported seeing artifacts near Science-37?", function()
			setCommsMessage("Freighters doing business here occasionally report an objecton approximate heading zero from Science-37 station")
			askForScience37ArtifactLocation = "complete"
			addCommsReply("Back", commsStation)
		end)
	end
end

function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
	if state == "ready" then
		return true
	end
	if state == "orders" and comms_target:getFaction() == humanFaction then
		return true
	end
    return false
end

-- Return the number of reputation points that a specified weapon costs for the current player
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end

-- Return the number of reputation points that a specified service costs for the current player
function getServiceCost(service)
    return math.ceil(comms_data.service_cost[service])
end

function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end

function update(delta)
    if not player:isValid() then
        victory(kraylorFaction)
        return
    end   
	if plot1 == nil then
		victory(humanFaction)
		return
	end
	if plot2 == defeat then
		victory(kraylorFaction)
	end
    if plot1 ~= nil then
        plot1(delta)
    end
	if plot2 ~= nil then
		plot2(delta)
	end
	if plot3 ~= nil then
		plot3(delta)
	end
	if plot4 ~= nil then
		plot4(delta)
	end
	if transportPlot ~= nil then
		transportPlot(delta)
	end
	if plotAudioButton ~= nil then
		plotAudioButton(delta)
	end
end

-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
	if randomize == nil then randomize = 0 end
	local sa = startArc
	local ea = endArcClockwise
	if sa > ea then
		ea = ea + 360
	end
	for n=1,amount do
		local r = random(sa,ea)
		local dist = distance + random(-randomize,randomize)
		local xo = x + math.cos(r / 180 * math.pi) * dist
		local yo = y + math.sin(r / 180 * math.pi) * dist
		object_type():setPosition(xo, yo)
	end
end
