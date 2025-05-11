-- Name: Deliver Ambassador Gremus
-- Description: Unrest on Goltin 7 requires the skills of ambassador Gremus. Your mission: transport the ambassador wherever needed. You may encounter resistance.
---
--- You are not flying a destroyer bristling with weapons. You are on a transport freighter with weapons bolted on as an afterthought. These weapons are pointed behind you to deter any marauding pirates. You won't necessarily be able to just destroy any enemies that might attempt to stop you from accomplishing your mission, you may have to evade. The navy wants you to succeed, so has fitted your ship with warp drive and a single diverse ordnance weapons tube which includes nuclear capability. If you get lost or forget your orders, check in with stations for information.
---
--- Player ship: Template model: Flavia P. Falcon. Suggest turning music volume to 10% and sound volume to 100% on server so the speaking audio can be heard. Designed for 5 or 6 bridge officers
--- Duration: 30 - 90 minutes. Medium difficulty (adjustable)
--- Version 5
-- Type: Mission
-- Setting[Difficulty]: Determine how difficult the scenario will be by the number of enemy ships.
-- Difficulty[Normal|Default]: Normal difficulty
-- Difficulty[Easy]: Easier than normal difficulty - fewer enemies
-- Difficulty[Hard]: Harder than normal difficulty - more enemies

require("utils.lua")
require("generate_call_sign_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")
require("control_code_scenario_utility.lua")

function init()
	scenario_version = "5.0.4"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Deliver Ambassador Gremus    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print(_VERSION)
	end
	playerCallSign = "Damocles"
	player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Flavia P.Falcon")
	player:setPosition(22400, 18200):setCallSign(playerCallSign):setHeading(90)
	player.location_help = {}
	player.report_help = {}
	-- Create various stations of various size, purpose and faction.
	stationList = {}
    outpost41 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
    outpost41:setPosition(22400, 16100):setCallSign("Outpost-41"):setDescription(_("scienceDescription-station", "Strategically located human station"))
    table.insert(stationList,outpost41)
    outpost17 = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
    outpost17:setPosition(52400, -26150):setCallSign("Outpost-17")
    table.insert(stationList,outpost17)
    outpost26 = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
    outpost26:setPosition(-42400, -32150):setCallSign("Outpost-26")
    table.insert(stationList,outpost26)
    outpost13 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	outpost13:setPosition(12600, 27554):setCallSign("Outpost-13"):setDescription(_("scienceDescription-station", "Gathering point for asteroid miners"))
    table.insert(stationList,outpost13)
    outpost57 = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor")
	outpost57:setPosition(63630, 47554):setCallSign("Outpost-57")
    table.insert(stationList,outpost57)
    science22 = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	science22:setPosition(11200, 67554):setCallSign("Science-22")
    table.insert(stationList,science22)
    science37 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	science37:setPosition(-18200, -32554):setCallSign("Science-37"):setDescription(_("scienceDescription-station", "Observatory"))
    table.insert(stationList,science37)
    bpcommnex = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	bpcommnex:setPosition(-53500,84000):setCallSign("BP Comm Nex"):setDescription(_("scienceDescription-station", "Balindor Prime Communications Nexus"))
    table.insert(stationList,bpcommnex)
    goltincomms = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	goltincomms:setPosition(93150,24387):setCallSign("Goltin Comms")
    table.insert(stationList,goltincomms)
    stationOrdinkal = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOrdinkal:setPosition(-14600, 47554):setCallSign("Ordinkal"):setDescription(_("scienceDescription-station", "Trading Post"))
    table.insert(stationList,stationOrdinkal)
    stationNakor = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationNakor:setPosition(-34310, -37554):setCallSign("Nakor"):setDescription(_("scienceDescription-station", "Science and trading hub"))
    table.insert(stationList,stationNakor)
    stationKelfist = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor")
	stationKelfist:setPosition(44640, 13554):setCallSign("Kelfist")
    table.insert(stationList,stationKelfist)
    stationFranklin = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationFranklin:setPosition(-24640, -13554):setCallSign("Franklin"):setDescription(_("scienceDescription-station", "Civilian and military station"))
    table.insert(stationList,stationFranklin)
    stationBroad = SpaceStation():setTemplate("Large Station"):setFaction("Independent")
	stationBroad:setPosition(44340, 63554):setCallSign("Broad"):setDescription(_("scienceDescription-station", "Trading Post"))
    table.insert(stationList,stationBroad)
    stationBazamoana = SpaceStation():setTemplate("Large Station"):setFaction("Independent")
	stationBazamoana:setPosition(35, 87):setCallSign("Bazamoana"):setDescription(_("scienceDescription-station", "Trading Nexus"))
    table.insert(stationList,stationBazamoana)
    stationPangora = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationPangora:setPosition(72340, -23554):setCallSign("Pangora"):setDescription(_("scienceDescription-station", "Major military installation"))
    table.insert(stationList,stationPangora)
	--	Set up variables based on difficulty setting
	local config_diff = {
		["Normal"] =	{val = 1,	rep = 150},
		["Easy"] =		{val = .5,	rep = 150},
		["Hard"] =		{val = 2,	rep = 50},
	}
	difficulty_variation =	getScenarioSetting("Difficulty")
	difficulty_value =		config_diff[difficulty_variation].val
	difficulty_rep =		config_diff[difficulty_variation].rep
	player:addReputationPoints(difficulty_rep)	-- Give out some initial reputation points. Give more for easier difficulty levels
	-- Create some asteroids and nebulae
	createRandomAlongArc(Asteroid, 40, 30350, 20000, 11000, 310, 45, 1700)
	createRandomAlongArc(VisualAsteroid, 80, 30350, 20000, 11000, 310, 45, 1700)
	createRandomAlongArc(Asteroid, 65, 20000, 20000, 15000, 80, 160, 3500)
	createRandomAlongArc(VisualAsteroid, 130, 20000, 20000, 15000, 80, 160, 3500)
	createRandomAlongArc(Asteroid, 100, -30000, 38000, 35000, 270, 340, 3500)
	createRandomAlongArc(VisualAsteroid, 200, -30000, 38000, 35000, 270, 340, 3500)
	createAsteroidsOnLine(-29000, 3000, -50000, 3000, 400, Asteroid, 13, 8, 800)
	createAsteroidsOnLine(-29000, 3000, -50000, 3000, 400, VisualAsteroid, 26, 8, 800)
	createAsteroidsOnLine(-50000, 3000, -60000, 5000, 400, Asteroid, 8, 6, 800)
	createAsteroidsOnLine(-50000, 3000, -60000, 5000, 400, VisualAsteroid, 16, 6, 800)
	createAsteroidsOnLine(-60000, 5000, -70000, 7000, 400, Asteroid, 5, 4, 800)
	createAsteroidsOnLine(-60000, 5000, -70000, 7000, 400, VisualAsteroid, 10, 4, 800)
	createRandomAlongArc(Asteroid, 800, 60000, -20000, 190000, 140, 210, 60000)
	createRandomAlongArc(VisualAsteroid, 1600, 60000, -20000, 190000, 140, 210, 60000)
	createRandomAlongArc(Nebula, 11, -20000, 40000, 30000, 20, 160, 11000)
	createRandomAlongArc(Nebula, 18, 70000, -50000, 55000, 90, 180, 18000)
	-- Have players face a hostile enemy right away (more if difficulty is harder)
	kraylorChaserList = {}
	kraylorChaser1 = CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(24000,18200):setHeading(270)
	kraylorChaser1:orderAttack(player):setScanned(true):setCallSign(generateCallSign(nil,"Kraylor"))
	table.insert(kraylorChaserList,kraylorChaser1)
	if difficulty_variation ~= "Easy" then
		kraylorChaser2 = CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(24000,18600):setHeading(270)
		kraylorChaser2:orderFlyFormation(kraylorChaser1,0,400):setScanned(true):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorChaserList,kraylorChaser2)
	end
	if difficulty_variation == "Hard" then
		kraylorChaser3 = CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(24000,17800):setHeading(270)
		kraylorChaser3:orderFlyFormation(kraylorChaser1,0,-400):setScanned(true):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorChaserList,kraylorChaser3)
	end
	-- Take station and transport generation script and use with modifications
	transportList = {}
	maxTransport = math.floor(#stationList * 1.5)
	transportPlot = randomTransports
	plot1 = chasePlayer		-- Start main plot line
	allowNewPlayerShips(false)
	mainGMButtons()
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
	addGMFunction(_("buttonGM","+Control Codes"),manageControlCodes)
	addGMFunction(_("buttonGM","Terrorist End"),terroristEnd)
end
--	Utilities
function audioButtonTimers(delta)
	--	Make the audio playback buttons on Relay go after 3 minutes
	if player.message_expire_time == nil then
		player.message_expire_time = {}
	end
	local button_list = {
		["michael"] =	{button = player.play_msg_michael_button},
		["gremus_1"] =	{button = player.play_msg_gremus_1_button},
		["sentry_1"] =	{button = player.play_msg_sentry_1_button},
		["gremus_2"] =	{button = player.play_msg_gremus_2_button},
		["protocol"] =	{button = player.play_msg_protocol_button},
		["gremus_3"] =	{button = player.play_msg_gremus_3_button},
		["fordina"] =	{button = player.play_msg_fordina_button},
		["gremus_6"] =	{button = player.play_msg_gremus_6_button},
	}
	for label,detail in pairs(button_list) do
		if detail.button ~= nil then
			if player.message_expire_time[label] == nil then
				player.message_expire_time[label] = getScenarioTime() + 180
			end
			if getScenarioTime() > player.message_expire_time[label] then
				player:removeCustom(detail.button)
				detail.button = nil
			end
		end
	end
end
function randomTransports()
	local clean_list = true
	for i,station in ipairs(stationList) do
		if station == nil or not station:isValid() then
			stationList[i] = stationList[#stationList]
			stationList[#stationList] = nil
			clean_list = false
			break
		end
	end
	if clean_list then
		for i,transport in ipairs(transportList) do
			if transport == nil or not transport:isValid() then
				transportList[i] = transportList[#transportList]
				transportList[#transportList] = nil
				clean_list = false
				break
			end
		end
	end
	if clean_list then
		for i,transport in ipairs(transportList) do
			if transport:isDocked(transport.target) then
				if transport.undock_time == nil then
					transport.undock_time = getScenarioTime() + random(5,30)
				end
				if getScenarioTime() > transport.undock_time then
					transport.undock_time = nil
					transport.target = stationList[math.random(1,#stationList)]
					transport:orderDock(transport.target)
				end
			end
		end
		if transport_spawn_time == nil then
			transport_spawn_time = getScenarioTime() + random(8,20)
		end
		if getScenarioTime() > transport_spawn_time then
			transport_spawn_time = nil
			if #transportList < maxTransport then
				local transport_name = {
					"Personnel","Goods","Garbage","Equipment","Fuel"
				}
				local name = string.format("%s Freighter %i",transport_name[math.random(1,#transport_name)],math.random(1,5))
				if random(1,100) < 15 then
					name = string.format("%s Jump Freighter %i",transport_name[math.random(1,#transport_name)],math.random(3,5))
				end
				local transport = CpuShip():setTemplate(name):setFaction("Independent")
				transport:setCommsScript(""):setCommsFunction(commsShip):setCallSign(generateCallSign(nil,"Independent"))
				transport.target = stationList[math.random(1,#stationList)]
				transport:orderDock(transport.target)
				local tx, ty = vectorFromAngle(random(0,360),random(25000,40000))
				transport:setPosition(tx,ty)
				table.insert(transportList,transport)
			end
		end
	end
end
function createAsteroidsOnLine(x1, y1, x2, y2, spacing, object_type, rows, chance, randomize)
-- Create objects along a line between two vectors, optionally with grid
-- placement and randomization.
--
-- createObjectsOnLine(x1, y1, x2, y2, spacing, object_type, rows, chance, randomize)
--   x1, y1: Starting coordinates
--   x2, y2: Ending coordinates
--   spacing: The distance between each object.
--   object_type: The object type. Calls `object_type():setPosition()`.
--   rows (optional): The number of rows, minimum 1. Defaults to 1.
--   chance (optional): The percentile chance an object will be created,
--     minimum 1. Defaults to 100 (always).
--   randomize (optional): If present, randomize object placement by this
--     amount. Defaults to 0 (grid).
--
--   Examples: To create a mine field, run:
--     createObjectsOnLine(0, 0, 10000, 0, 1000, Mine, 4)
--   This creates 4 rows of mines from 0,0 to 10000,0, with mines spaced 1U
--   apart.
--
--   The `randomize` parameter adds chaos to the pattern. This works well for
--   asteroid fields:
--     createObjectsOnLine(0, 0, 10000, 0, 300, Asteroid, 4, 100, 800)
    if rows == nil then rows = 1 end
    if chance == nil then chance = 100 end
    if randomize == nil then randomize = 0 end
    local d = distance(x1, y1, x2, y2)
    local xd = (x2 - x1) / d
    local yd = (y2 - y1) / d
    for cnt_x=0,d,spacing do
        for cnt_y=0,(rows-1)*spacing,spacing do
            local px = x1 + xd * cnt_x + yd * (cnt_y - (rows - 1) * spacing * 0.5) + random(-randomize, randomize)
            local py = y1 + yd * cnt_x - xd * (cnt_y - (rows - 1) * spacing * 0.5) + random(-randomize, randomize)
            local a = nil
            if random(0, 100) < chance then
                a = object_type():setPosition(px, py)
            end
            if a ~= nil then
            	if isObjectType(a,"Asteroid") or isObjectType(a,"VisualAsteroid") then
	            	a:setSize(random(4,300) + random(4,300) + random(4,300))
	            end
            end
        end
    end
end
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
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
		local a = object_type():setPosition(xo, yo)
		if isObjectType(a,"Asteroid") or isObjectType(a,"VisualAsteroid") then
			a:setSize(random(4,300) + random(4,300) + random(4,300))
		end
	end
end
function vectorFromAngleNorth(angle,distance)
	if spew_function_diagnostic then print("top of vector from angle north") end
--	print("input angle to vectorFromAngleNorth:")
--	print(angle)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	if spew_function_diagnostic then print("bottom (ish) of vector from angle north") end
	return x, y
end
------------------------------
--	Plot related functions  --
------------------------------
--	Plot 1 (the main plot points)
function chasePlayer(delta)	-- Chase player until enemies destroyed or player gets away
	--linear from init
	kraylorChaserCount = 0
	nearestChaser = 0
	askForOrders = "orders"		-- Turn on order messages in station communications
	for i, enemy in ipairs(kraylorChaserList) do
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
function getAmbassador(delta)	--1st Gremus mission, create planet, and set foment time
	--linear from plot 1, chase player
	outpost41:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: CMDMICHL012"))
	player:addToShipLog(string.format(_("audio-shipLog","[CMDMICHL012](Commander Michael) %s, avoid contact where possible. Get ambassador Gremus at Balindor Prime"),playerCallSign),"Yellow")
	if player.play_msg_michael_button == nil then
		player.play_msg_michael_button = "play_msg_michael_button"
		player:addCustomButton("Relay",player.play_msg_michael_button,_("audio-buttonRelay","|> CMDMICHL012"),function()
			playSoundFile("audio/scenario/51/sa_51_Michael.ogg")
			player:removeCustom(player.play_msg_michael_button)
			player.play_msg_michael_button = nil
		end)
	end
	balindorPrime = Planet():setPosition(-50500,84000):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png"):setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0):setAxialRotationTime(400.0)
	balindorPrime:setCallSign("Balindor Prime")
	balindorMoon = Planet():setPlanetRadius(1000):setDistanceFromMovementPlane(-500):setPlanetSurfaceTexture("planets/moon-1.png"):setAxialRotationTime(450)
	balindorMoon:setPosition(-42500,84000):setOrbit(balindorPrime,1500)
	bpcommnex.bp_angle = 270
	local bcn_x, bcn_y = bpcommnex:getPosition()
	bpcommnex.bp_distance = distance(-50500,84000,bcn_x, bcn_y)
	plot1 = ambassadorAboard
	ambassadorEscapedBalindor = false
	foment_time = getScenarioTime() + 60
	plot2 = revolutionFomenting
	plot3 = balindorInterceptor
	player.location_help.askForBalindorLocation = "ready"
end
function ambassadorAboard(delta)	--Take Gremus to Ningling msg, create Ningling, add rep
	--linear from plot 1, get ambassador
	if distance(player, balindorPrime) < 3300 then
		ambassadorEscapedBalindor = true
		bpcommnex:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS004"))
		player:addToShipLog(_("audio-shipLog","[AMBGREMUS004](Ambassador Gremus) Thanks for bringing me aboard. Please transport me to Ningling."),"Yellow")
		if player.play_msg_gremus_2_button == nil then
			player.play_msg_gremus_2_button = "play_msg_gremus_2_button"
			player:addCustomButton("Relay",player.play_msg_gremus_2_button,_("audio-buttonRelay","|> AMBGREMUS004"),function()
				playSoundFile("audio/scenario/51/sa_51_Gremus2.ogg")
				player:removeCustom(player.play_msg_gremus_2_button)
				playMsgGremus2Button = nil
			end)
		end
		ningling = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
		ningling:setPosition(12200,-62600):setCallSign("Ningling")
		table.insert(stationList,ningling)
		player:addReputationPoints(25.0)
		if difficulty_variation ~= "Hard" then
			player:addReputationPoints(25.0)
		end
		plot1 = gotoNingling
		plot3 = ningAttack
		player.location_help.askForNingLocation = "ready"
	end
end
function gotoNingling(delta)	--Wait for Gremus msg, set meet time
	--linear from plot 1, ambassador aboard
	if not ningling:isValid() then
		globalMessage(_("msgMainscreen","Ningling destroyed.\nCritical information fails to reach Ambassador Gremus.\nMission fails."))
		victory("Kraylor")
	end
	if player:isDocked(ningling) then
		ningling:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: NINGPCLO002"))
		player:addToShipLog(_("audio-shipLog","[NINGPCLO002](Ningling Protocol Officer) Ambassador Gremus arrived. The ambassador is scheduled for a brief meeting with liaison Fordina. After that meeting, you will be asked to transport the ambassador to Goltin 7. We will contact you after the meeting."),"Yellow")
		if player.play_msg_protocol_button == nil then
			player.play_msg_protocol_button = "play_msg_protocol_button"
			player:addCustomButton("Relay",player.play_msg_protocol_button,_("audio-buttonRelay","|> NINGPCLO002"),function()
				playSoundFile("audio/scenario/51/sa_51_Protocol.ogg")
				player:removeCustom(player.play_msg_protocol_button)
				player.play_msg_protocol_button = nil
			end)
		end
		plot1 = waitForAmbassador
		meeting_time = getScenarioTime() + 60*5
		plot3 = ningWait
	end
end
function waitForAmbassador(delta)	--When meeting completes, request dock for next goal
	--linear from plot 1, go to ningling
	if not ningling:isValid() then
		globalMessage(_("msgMainscreen","Ningling destroyed.\nCritical information fails to reach Ambassador Gremus.\nMission fails."))
		victory("Kraylor")
	end
	if getScenarioTime() > meeting_time and not player:isDocked(ningling) then
		ningling:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS007"))
		player:addToShipLog(string.format(_("audio-shipLog","[AMBGREMUS007](Ambassador Gremus) %s, I am ready to be transported to Goltin 7. Please dock with Ningling"),playerCallSign),"Yellow")
		if player.play_msg_gremus_3_button == nil then
			player.play_msg_gremus_3_button = "play_msg_gremus_3_button"
			player:addCustomButton("Relay",player.play_msg_gremus_3_button,_("audio-buttonRelay","|> AMBGREMUS007"),function()
				playSoundFile("audio/scenario/51/sa_51_Gremus3.ogg")
				player:removeCustom(player.play_msg_gremus_3_button)
				player.play_msg_gremus_3_button = nil
			end)
		end
		plot1 = getFromNingling
	end
end
function getFromNingling(delta)	--Goltin 7 goal, create planet, start sub-plots
	--linear from plot 1, get from ningling
	if not ningling:isValid() then
		globalMessage(_("msgMainscreen","Ningling destroyed.\nCritical information fails to reach Ambassador Gremus.\nMission fails."))
		victory("Kraylor")
	end
	if player:isDocked(ningling) then
		ningling:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS021"))
		player:addToShipLog(_("audio-shipLog","[AMBGREMUS021](Ambassador Gremus) Thank you for waiting and then for coming back and getting me. I needed the information provided by liaison Fordina to facilitate negotiations at Goltin 7. Let us away!"),"Yellow")
		player:addToShipLog(_("upgrade-shipLog","Reconfigured beam weapons: pointed one forward and increased its range and narrowed its focus"),"Magenta")
		if difficulty_variation ~= "Hard" then
			player:setImpulseMaxSpeed(75)
			player:addToShipLog(_("upgrade-shipLog","Also increased the top speed of your impulse engine"),"Magenta")
		end
		if player.play_msg_gremus_4_button == nil then
			player.play_msg_gremus_4_button = "play_msg_gremus_4_button"
			player:addCustomButton("Relay",player.play_msg_gremus_4_button,_("audio-buttonRelay","|> AMBGREMUS021"),function()
				playSoundFile("audio/scenario/51/sa_51_Gremus4.ogg")
				player:removeCustom(player.play_msg_gremus_4_button)
			end)
		end
		player:setTypeName("Flavia P. Falcon MK2")
		player:setBeamWeapon(0, 40, 180, 1200.0, 6.0, 6)
		player:setBeamWeapon(1, 20, 0, 1600.0, 6.0, 6)
		goltin = Planet():setPosition(93150,21387):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(80.0)
		goltin:setCallSign("Goltin 7")
		artifact_research_count = 0
		plot1 = travelGoltin
		plot2 = lastSabotage
		plot3 = artifactResearch
		player.location_help.askForGoltinLocation = "ready"
	end
end
function travelGoltin(delta)	--Go to Goltin, win if research complete or identify research as goal
	--linear from plot 1, travel to goltin
	if artifact_research_count > 0 then
		if distance(player,goltin) < 3300 then
			globalMessage(_("msgMainscreen",[[Goltin 7 welcomes ambassador Gremus]]))
			goltincomms:sendCommsMessage(player, string.format(_("audio-incCall", "(Ambassador Gremus) Thanks for transporting me, %s. Tensions are high, but I think negotiations will succeed.\nIn the meantime, be careful of hostile ships."), playerCallSign))
			playSoundFile("audio/scenario/51/sa_51_Gremus5.ogg")
			last_message_time = getScenarioTime() + 20
			plot1 = finalMessage
		end
	else
		if distance(player, goltin) < 3300 then
			goltincomms:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS032"))
			player:addToShipLog(string.format(_("audio-shipLog","[AMBGREMUS032](Ambassador Gremus) Thanks for transporting me, %s. I will need artifact research for successful negotiation. Please return with that research when you can."),playerCallSign),"Yellow")
			if player.play_msg_gremus_6_button == nil then
				player.play_msg_gremus_6_button = "play_msg_gremus_6_button"
				player:addCustomButton("Relay",player.play_msg_gremus_6_button,_("audio-buttonRelay","|> AMBGREMUS021"),function()
					playSoundFile("audio/scenario/51/sa_51_Gremus6.ogg")
					player:removeCustom(player.play_msg_gremus_6_button)
					player.play_msg_gremus_6_button = nil
				end)
			end
			plot1 = departForResearch
		end
	end
end
function departForResearch(delta)
	--linear from plot 1, travel goltin
	if distance(player,goltin) > 30000 then
		plot1 = goltinAndResearch
	end
end
function goltinAndResearch(delta)	--Complete mission when returning with research
	--linear from plot 1, depart for research
	if artifact_research_count > 0 then
		if distance(player,goltin) < 3300 then
			globalMessage(_("msgMainscreen",[[Goltin 7 welcomes ambassador Gremus]]))
			goltincomms:sendCommsMessage(player, string.format(_("audio-incCall", "(Ambassador Gremus) Thanks for researching the artifacts, %s. Tensions are high, but I think negotiations will succeed. In the meantime, be careful of hostile ships."), playerCallSign))
			playSoundFile("audio/scenario/51/sa_51_Gremus7.ogg")
			last_message_time = getScenarioTime() + 20
			plot1 = finalMessage			
		end
	end
end
function finalMessage(delta)
	--linear from either plot 1, goltin and research or plot 1, travel goltin
	if getScenarioTime() > last_message_time then
		plot1 = nil
	end
end
--	Plot 2 (revolution, last batch of enemies)
function revolutionFomenting(delta)	--At foment time, send fomenting msg (limited time) and set revolution time
	--started from plot 1, get ambassador
	if getScenarioTime() > foment_time then
		bpcommnex:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: AMBGREMUS001"))
		player:addToShipLog(_("audio-shipLog","[AMBGREMUS001](Ambassador Gremus) I am glad you are coming to get me. There is serious unrest here on Balindor Prime. I am not sure how long I am going to survive. Please hurry, I can hear a mob outside my compound."),"Yellow")
		if player.play_msg_gremus_1_button == nil then
			player.play_msg_gremus_1_button = "play_msg_gremus_1_button"
			player:addCustomButton("Relay",player.play_msg_gremus_1_button,_("audio-buttonRelay","|> AMBGREMUS001"),function()
				playSoundFile("audio/scenario/51/sa_51_Gremus1.ogg")
				player:removeCustom(player.play_msg_gremus_1_button)
				player.play_msg_gremus_1_button = nil
			end)
		end
		breakout_time = getScenarioTime() + 60*5
		plot2 = revolutionOccurs
	end
end
function revolutionOccurs(delta)
	--linear from plot 2, revolution fomenting
	if getScenarioTime() > breakout_time then	--Handle revolution (lose mission or continue)
		if ambassadorEscapedBalindor then
			bpcommnex:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: GREMUSGRD003"))
			player:addToShipLog(_("audio-shipLog","[GREMUSGRD003](Compound Sentry) You got ambassador Gremus just in time. We barely escaped the mob with our lives. I don't recommend bringing the ambassador back anytime soon."),"Yellow")
			if player.play_msg_sentry_1_button == nil then
				player.play_msg_sentry_1_button =  "play_msg_sentry_1_button"
				player:addCustomButton("Relay",player.play_msg_sentry_1_button,_("audio-buttonRelay","|> GREMUSGRD003"),function()
					playSoundFile("audio/scenario/51/sa_51_Sentry1.ogg")
					player:removeCustom(player.play_msg_sentry_1_button)
					player.play_msg_sentry_1_button = nil
				end)
			end
			plot2 = nil
		else
			globalMessage(_("audio-msgMainscreen",[[Ambassador lost to hostile mob. The Kraylors are victorious]]))
			bpcommnex:sendCommsMessage(player, _("audio-incCall",[[(Compound Sentry) I'm sad to report the loss of ambassador Gremus to a hostile mob.]]))
			playSoundFile("audio/scenario/51/sa_51_Sentry2.ogg")
			defeat_message_time = getScenarioTime() + 15
			plot2 = defeatMessage
		end
		if player.mob_timer ~= nil then
			player:removeCustom(player.mob_timer)
			player.mob_timer = nil
		end
		if player.mob_timer_ops ~= nil then
			player:removeCustom(player.mob_timer_ops)
			player.mob_timer_ops = nil
		end
	else	--Update revolution timer
		local mob_label = _("audio-tabRelay&Operations","Mob Action")
		local breakout_remainder = breakout_time - getScenarioTime()
		local mob_minutes = math.floor(breakout_remainder / 60)
		local mob_seconds = math.floor(breakout_remainder % 60)
		if mob_minutes <= 0 then
			mob_label = string.format(_("audio-tabRelay&Operations", "%s %i"),mob_label,mob_seconds)
		else
			mob_label = string.format(_("audio-tabRelay&Operations", "%s %i:%.2i"),mob_label,mob_minutes,mob_seconds)
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
function defeatMessage(delta)
	--linear from plot 2, revolution occurs
	if getScenarioTime() > defeat_message_time then
		plot2 = defeat
	end
end
function defeat(delta)
	--linear from plot 2, defeat message
	victory("Kraylor")
end
function lastSabotage(delta)	--Last ditch attempt to sabotage mission, the big guns
	--started from plot 1, get from ningling
	if distance(player, ningling) > 40000 then
		local ao = 30000
		local fo = 2500
		local x, y = player:getPosition()
		goltinList = {}
		goltin1 = CpuShip():setTemplate("Atlantis X23"):setFaction("Kraylor"):setPosition(x+ao,y+ao):setHeading(315)
		goltin1:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(goltinList,goltin1)
		goltin2 = CpuShip():setTemplate("Starhammer II"):setFaction("Kraylor"):setPosition(x,y+ao):setHeading(0)
		goltin2:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(goltinList,goltin2)
		goltin3 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x+ao,y):setHeading(270)
		goltin3:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(goltinList,goltin3)
		if difficulty_variation ~= "Easy" then
			goltin4 = CpuShip():setTemplate("Stalker R7"):setFaction("Kraylor"):setPosition(x+ao+fo,y+ao-fo):setHeading(315)
			goltin4:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(goltinList,goltin4)
			goltin5 = CpuShip():setTemplate("Ranus U"):setFaction("Kraylor"):setPosition(x+fo,y+ao):setHeading(0)
			goltin5:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(goltinList,goltin5)
			goltin6 = CpuShip():setTemplate("Phobos T3"):setFaction("Kraylor"):setPosition(x+ao,y-fo):setHeading(270)
			goltin6:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(goltinList,goltin6)
		end
		if difficulty_variation == "Hard" then
			goltin7 = CpuShip():setTemplate("Nirvana R5"):setFaction("Kraylor"):setPosition(x+ao-fo,y+ao+fo):setHeading(315)
			goltin7:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(goltinList,goltin7)
			goltin8 = CpuShip():setTemplate("Piranha F12"):setFaction("Kraylor"):setPosition(x-fo,y+ao):setHeading(0)
			goltin8:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(goltinList,goltin8)
			goltin9 = CpuShip():setTemplate("Nirvana R5A"):setFaction("Kraylor"):setPosition(x+ao,y+fo):setHeading(270)
			goltin9:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(goltinList,goltin9)
		end
		plot2 = nil
	end
end
--	Plot 3 (enemies and artifacts)
function balindorInterceptor(delta)	--Mission prevention enemies
	--started from plot 1, get ambassador
	if distance(player,-50500,84000) < 35000 then
		local ao = 20000	-- ambush offset
		local fo = 1000		-- formation offset
		kraylorBalindorInterceptorList = {}
		local x, y = player:getPosition()
		kraylorBalindorInterceptor1 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x-ao,y+ao):setHeading(45)
		kraylorBalindorInterceptor1:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor1)
		kraylorBalindorInterceptor2 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x-(ao+fo),y+ao):setHeading(45)
		kraylorBalindorInterceptor2:orderFlyFormation(kraylorBalindorInterceptor1,fo,0):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor2)
		kraylorBalindorInterceptor3 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x+ao,y-ao):setHeading(225)
		kraylorBalindorInterceptor3:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor3)
		kraylorBalindorInterceptor4 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x+ao+fo,y-ao):setHeading(225)
		kraylorBalindorInterceptor4:orderFlyFormation(kraylorBalindorInterceptor3,-fo,0):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor4)
		if difficulty_variation ~= "Easy" then
			kraylorBalindorInterceptor5 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x-ao,y+ao+fo):setHeading(45)
			kraylorBalindorInterceptor5:orderFlyFormation(kraylorBalindorInterceptor1,0,fo):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor5)
			kraylorBalindorInterceptor6 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x-(ao+fo),y+ao+fo):setHeading(45)
			kraylorBalindorInterceptor6:orderFlyFormation(kraylorBalindorInterceptor1,fo,fo):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor6)
			kraylorBalindorInterceptor7 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x+ao,y-(ao+fo)):setHeading(225)
			kraylorBalindorInterceptor7:orderFlyFormation(kraylorBalindorInterceptor3,0,-fo):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor7)
			kraylorBalindorInterceptor8 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x+ao+fo,y-(ao+fo)):setHeading(225)
			kraylorBalindorInterceptor8:orderFlyFormation(kraylorBalindorInterceptor3,-fo,-fo):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor8)
		end
		if difficulty_variation == "Hard" then
			kraylorBalindorInterceptor9 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x-ao,y+ao+fo*2):setHeading(45)
			kraylorBalindorInterceptor9:orderFlyFormation(kraylorBalindorInterceptor1,0,fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor9)
			kraylorBalindorInterceptor10 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x-(ao+fo*2),y+ao):setHeading(45)
			kraylorBalindorInterceptor10:orderFlyFormation(kraylorBalindorInterceptor1,fo*2,0):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor10)
			kraylorBalindorInterceptor11 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x+ao,y-(ao+fo*2)):setHeading(225)
			kraylorBalindorInterceptor11:orderFlyFormation(kraylorBalindorInterceptor3,0,-fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor11)
			kraylorBalindorInterceptor12 = CpuShip():setTemplate("Piranha F8"):setFaction("Kraylor"):setPosition(x+ao+fo*2,y-ao):setHeading(225)
			kraylorBalindorInterceptor12:orderFlyFormation(kraylorBalindorInterceptor3,-fo*2,0):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorBalindorInterceptorList,kraylorBalindorInterceptor12)
		end
		plot3 = nil
	end
end
function ningAttack(delta)	--More enemies to stop mission
	--started from plot 1, ambassador aboard
	if distance(player, balindorPrime) > 30000 then
		local ao = 10000	-- ambush offset
		local fo = 500		-- formation offset
		kraylorNingList = {}
		local x, y = player:getPosition()
		kraylorNing1 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x,y-ao):setHeading(180)
		kraylorNing1:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorNingList,kraylorNing1)
		kraylorNing4 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x,y+ao):setHeading(0)
		kraylorNing4:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(kraylorNingList,kraylorNing4)
		if difficulty_variation ~= "Easy" then
			kraylorNing7 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x-fo,y-ao-fo*2):setHeading(180)
			kraylorNing7:orderFlyFormation(kraylorNing1,-fo,-fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorNingList,kraylorNing7)
			kraylorNing9 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x-fo,y+ao+fo*2):setHeading(0)
			kraylorNing9:orderFlyFormation(kraylorNing4,-fo,fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorNingList,kraylorNing9)
		end
		if difficulty_variation == "Hard" then
			kraylorNing11 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x-fo,y-ao+fo*2):setHeading(180)
			kraylorNing11:orderFlyFormation(kraylorNing1,-fo,fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorNingList,kraylorNing11)
			kraylorNing13 = CpuShip():setTemplate("Stalker Q7"):setFaction("Kraylor"):setPosition(x-fo,y+ao-fo*2):setHeading(0)
			kraylorNing13:orderFlyFormation(kraylorNing4,-fo,-fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
			table.insert(kraylorNingList,kraylorNing13)
		end
		plot3 = nil
	end
end
function ningWait(delta)	--While waiting, more enemies arrive to try to stop mission
	--started from plot 1, go to ningling
	local x, y = ningling:getPosition()
	local ao = 25000
	local fo = 1200
	waitNingList = {}
	waitNing1 = CpuShip():setTemplate("MT52 Hornet"):setFaction("Kraylor"):setPosition(x+ao,y+ao):setHeading(315)
	waitNing1:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
	table.insert(waitNingList,waitNing1)
	if difficulty_variation ~= "Easy" then
		waitNing2 = CpuShip():setTemplate("MU52 Hornet"):setFaction("Kraylor"):setPosition(x+ao+fo,y+ao):setHeading(315)
		waitNing2:orderFlyFormation(waitNing1,fo,0):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(waitNingList,waitNing2)
		waitNing3 = CpuShip():setTemplate("Adder MK4"):setFaction("Kraylor"):setPosition(x+ao,y+ao+fo):setHeading(315)
		waitNing3:orderFlyFormation(waitNing1,0,fo):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(waitNingList,waitNing3)
	end
	if difficulty_variation == "Hard" then
		waitNing4 = CpuShip():setTemplate("Adder MK5"):setFaction("Kraylor"):setPosition(x+ao+fo*2,y+ao):setHeading(315)
		waitNing4:orderFlyFormation(waitNing1,fo*2,0):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(waitNingList,waitNing4)
		waitNing5 = CpuShip():setTemplate("Adder MK5"):setFaction("Kraylor"):setPosition(x+ao,y+ao+fo*2):setHeading(315)
		waitNing5:orderFlyFormation(waitNing1,0,fo*2):setCallSign(generateCallSign(nil,"Kraylor"))
		table.insert(waitNingList,waitNing5)
	end
	plot3 = nil
end
function artifactResearch(delta)	--Expand artifact sub-plot after player leaves Ningling
	--started from plot 1, get from ningling
	if distance(player, ningling) > 10000 then
		ningling:sendCommsMessage(player, _("audio-incCall","Audio message received. Auto-transcribed into log. Stored for playback: LSNFRDNA009"))
		player:addToShipLog(_("audio-shipLog","[LSNFRDNA009](Liaison Fordina) Ambassador Gremus, we just received that follow-up information from Goltin 7 we spoke of. It seems they want additional information about several artifacts. Some of these have been reported by stations in the area: Pangora, Nakor and Science-37."),"Yellow")
		if player.play_msg_fordina_button == nil then
			player.play_msg_fordina_button = "play_msg_fordina_button"
			player:addCustomButton("Relay",player.play_msg_fordina_button,_("audio-buttonRelay","|> LSNFRDNA009"),function()
				playSoundFile("audio/scenario/51/sa_51_Fordina.ogg")
				player:removeCustom(player.play_msg_fordina_button)
				player.play_msg_fordina_button = nil
			end)
		end
		askForPangoraLocation = "ready"
		askForNakorLocation = "ready"
		askForScience37Location = "ready"
		player.location_help.askForPangoraLocation = "ready"
		player.location_help.askForNakorLocation = "ready"
		player.location_help.askForScience37Location = "ready"
		plot3 = artifactByStation
		nearPangora = "ready"
		nearNakor = "ready"
		nearScience37 = "ready"
	end
end
function artifactByStation(delta)	--When player docks, create nearby artifact. Enable comms message additions for station
	--linear from plot 3, artifact research
	if player:isDocked(stationPangora) then
		if nearPangora == "ready" then
			local x, y = stationPangora:getPosition()
			nPangora = Artifact():setPosition(x+35000,y+38000):setScanningParameters(3,2):setRadarSignatureInfo(random(2,8),random(2,8),random(2,8))
			nPangora:setModel("artifact3"):allowPickup(false)
			nPangora.beta_radiation = irandom(3,15)
			nPangora.gravity_disruption = irandom(1,21)
			nPangora.ionic_phase_shift = irandom(5,32)
			nPangora.doppler_instability = irandom(1,9)
			nPangora:setDescriptions(_("scienceDescription-artifact","Unusual object floating in space"), string.format(_("scienceDescription-artifact",[[Object gives off unusual readings:
			Beta radiation: %i
			Gravity disruption: %i
			Ionic phase shift: %i
			Doppler instability: %i]]),nPangora.beta_radiation, nPangora.gravity_disruption, nPangora.ionic_phase_shift, nPangora.doppler_instability))
			nearPangora = "created"
		end
		player.report_help.askForPangoraArtifactLocation = "ready"
	end
	if player:isDocked(stationNakor) then
		if nearNakor == "ready" then
			local x, y = stationNakor:getPosition()
			nNakor = Artifact():setPosition(x-35000,y-36000):setScanningParameters(2,3):setRadarSignatureInfo(random(2,5),random(2,5),random(2,8))
			nNakor:setModel("artifact5"):allowPickup(false)
			nNakor.gamma_radiation = irandom(1,9)
			nNakor.organic_decay = irandom(3,43)
			nNakor.gravity_disruption = irandom(2,13)
			nNakor:setDescription(_("scienceDescription-artifact","Object with unusual visual properties"), string.format(_("scienceDescription-artifact",[[Sensor readings of interest:
			Gamma radiation: %i
			Organic decay: %i
			Gravity disruption: %i]]),nNakor.gamma_radiation, nNakor.organic_decay, nNakor.gravity_disruption))
			nearNakor = "created"
		end
		player.report_help.askForNakorArtifactLocation = "ready"
	end
	if player:isDocked(science37) then
		if nearScience37 == "ready" then
			local x, y = science37:getPosition()
			nScience37 = Artifact():setPosition(x+1000,y-40000):setScanningParameters(4,1):setRadarSignatureInfo(random(3,9),random(1,5),random(2,4))
			nScience37:setModel("artifact6"):allowPickup(true)
			nScience37.ionic_phase_shift = irandom(1,9)
			nScience37.organic_decay = irandom(3,13)
			nScience37.theta_particle_emission = irandom(1,15)
			nScience37:setDescription(_("scienceDescription-artifact","Small object floating in space"), string.format(_("scienceDescription-artifact",[[Sensors show:
			Ionic pase shift: %i
			Organic decay: %i
			Theta particle emission: %i]]),nScience37.ionic_phase_shift, nScience37.organic_decay, nScience37.theta_particle_emission))
			nearScience37 = "created"
		end
		player.report_help.askForScience37ArtifactLocation = "ready"
	end
	if nPangora ~= nil and nPangora:isValid() then
		if nPangora:isScannedBy(player) and nPangora.already_scanned == nil then
			artifact_research_count = artifact_research_count + 1
			nPangora.already_scanned = true
		end
		if distance(player,nPangora) < 5000 then
			pangora_explode_time = getScenarioTime() + 15
			nPangora.gravity_disruption = nPangora.gravity_disruption + 1
			nPangora:setDescriptions(_("scienceDescription-artifact","Unusual object floating in space"), string.format(_("scienceDescription-artifact",[[Object gives off unusual readings:
			Beta radiation: %i
			Gravity disruption: %i
			Ionic phase shift: %i
			Doppler instability: %i]]),nPangora.beta_radiation, nPangora.gravity_disruption, nPangora.ionic_phase_shift, nPangora.doppler_instability))			
			plot4 = pangoraArtifactChange
		end
	end
	if nNakor ~= nil and nNakor:isValid() then
		if nNakor:isScannedBy(player) and nNakor.already_scanned == nil then
			artifact_research_count = artifact_research_count + 1
			nNakor.already_scanned = true
		end
	end
	if nScience37 ~= nil and nScience37:isValid() then
		if nScience37:isScannedBy(player) and nScience37.already_scanned == nil then
			artifact_research_count = artifact_research_count + 1
			nScience37.already_scanned = true
		end
	end
end
--	Plot 4 (exploding artifact)
function pangoraArtifactChange(delta)
	--started from plot 3, artifact by station
	if player.pangora_reading_change_message == nil then
		player:addCustomMessage("Science", _("artifact-msgScience", "Warning"), _("artifact-msgScience","The readings on the Pangora artifact have changed"))
		player.pangora_reading_change_message = "sent"
	end
	plot4 = pangoraArtifactExplode
end
function pangoraArtifactExplode(delta)
	--linear from plot 4, pangora artifact change
	if getScenarioTime() > pangora_explode_time then
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
		plot4 = nil
	end
end
--	Plot 5 (terrorist end)
function terroristEnd()
	plot5 = maintainTerrorists
	addGMMessage(_("msgGM","Terrorist ending initiated"))
end
function maintainTerrorists()
	if terrorist_list == nil then
		terrorist_list = {}
		local px, py = player:getPosition()
		local attack_angle = random(0,360)
		for i=1,6 do
			local tx, ty = vectorFromAngle(attack_angle,player:getLongRangeRadarRange())
			local ship = CpuShip():setTemplate("Stalker Q7"):setPosition(px + tx, py + ty):setFaction("Kraylor")
			ship:orderAttack(player):setCallSign(generateCallSign(nil,"Kraylor"))
			ship:setImpulseMaxSpeed(90):setRotationMaxSpeed(20)
			table.insert(terrorist_list,ship)
			attack_angle = (attack_angle + 60) % 360
		end
	end
	if player.ultimatum == nil then
		if availableForComms(player) then
			for i,ship in ipairs(terrorist_list) do
				if ship:isValid() then
					ship:sendCommsMessage(player,_("KraylorEndline-incCall","We apologize for the imminent destruction of your ship, but you are harboring Ambassador Gremus aboard, a known menace to polite society."))
					player.ultimatum = "sent"
					break
				end
			end
		end
	end
	for i,ship in ipairs(terrorist_list) do
		if ship:isValid() then
			if ship.jammer == nil then
				if distance(ship,player) < 5000 then
					local wj_x, wj_y = ship:getPosition()
					WarpJammer():setPosition(wj_x,wj_y):setRange(20000):setHull(100)
					ship.jammer = "dropped"
				end
			end
		end
	end
end
------------------------------
--	Station Communications  --
------------------------------
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
    if comms_source:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage(_("station-comms","We are under attack! No time for chatting!"))
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
    if comms_source:isFriendly(comms_target) then
        setCommsMessage(_("station-comms", "Good day, officer!\nWhat can we do for you today?"))
    else
        setCommsMessage(_("station-comms", "Welcome to our lovely station."))
    end
	local weapon_prompts = {
		["Homing"] = {
			string.format(_("ammo-comms", "Do you have spare homing missiles for us? (%d rep each)"), getWeaponCost("Homing")),
			string.format(_("ammo-comms", "Do you have extra homing missiles? (%d rep each)"), getWeaponCost("Homing")),
			string.format(_("ammo-comms", "We could use some homing missiles. (%d rep each)"), getWeaponCost("Homing")),
		},
		["HVLI"] = {
			string.format(_("ammo-comms", "Can you restock us with HVLI? (%d rep each)"), getWeaponCost("HVLI")),
			string.format(_("ammo-comms", "What about HVLI? (%d rep each)"), getWeaponCost("HVLI")),
			string.format(_("ammo-comms", "We need some High Velocity Lead Impactors. (%d rep each)"), getWeaponCost("HVLI")),
		},
		["Mine"] = {
			string.format(_("ammo-comms", "Please restock our mines. (%d rep each)"), getWeaponCost("Mine")),
			string.format(_("ammo-comms", "How about mines? (%d rep each)"), getWeaponCost("Mine")),
			string.format(_("ammo-comms", "We are running low on mines. (%d rep each)"), getWeaponCost("Mine")),
		},
		["EMP"] = {
			string.format(_("ammo-comms", "Please restock our EMP missiles. (%d rep each)"), getWeaponCost("EMP")),
			string.format(_("ammo-comms", "Got any EMPs? (%d rep each)"), getWeaponCost("EMP")),
			string.format(_("ammo-comms", "We need Electro-Magnetic Pulse missiles. (%d rep each)"), getWeaponCost("EMP")),
		},
		["Nuke"] = {
			string.format(_("ammo-comms", "Can you supply us with some nukes? (%d rep each)"), getWeaponCost("Nuke")),
			string.format(_("ammo-comms", "We really need some nukes. (%d rep each)"), getWeaponCost("Nuke")),
			string.format(_("ammo-comms", "We could use some nuclear missiles. (%d rep each)"), getWeaponCost("Nuke")),
		}
	}
	for weapon,prompt in pairs(weapon_prompts) do
		if comms_source:getWeaponStorageMax(weapon) > 0 then
			addCommsReply(prompt[math.random(1,#prompt)],function()
				string.format("")
				handleWeaponRestock(weapon)
			end)
		end
	end
	helpfulWaypoints()
	-- Include orders upon request for when they are missed
	if isAllowedTo(askForOrders) then
		addCommsReply(_("orders-comms","What are my current orders?"), function()
			oMessage = _("orders-comms","Whatever ambassador Gremus says. ")
			if plot1 == chasePlayer or plot1 == getAmbassador or plot1 == ambassadorAboard then
				oMessage = _("orders-comms","Current Orders: Get ambassador Gremus from Balindor Prime. Avoid contact if possible. ")
			elseif plot1 == gotoNingling then
				oMessage = _("orders-comms","Current Orders: Transport ambassador Gremus to Ningling. ")
			elseif plot1 == waitForAmbassador then
				oMessage = _("orders-comms","Current Orders: Wait for ambassador Gremus to complete business at Ningling. ")
			elseif plot1 == getFromNingling then
				oMessage = _("orders-comms","Current Orders: Dock with Ningling to get ambassador Gremus. ")
			elseif plot1 == travelGoltin then
				oMessage = _("orders-comms","Current Orders: Transport ambassador Gremus to Goltin 7. ")
			end
			if plot3 == artifactResearch or plot3 == artifactByStation then
				oMessage = string.format(_("artifactOrders-comms","%sAdditional Orders: Research artifacts. Some artifacts reported near Pangora, Nakor and Science-37. "),oMessage)
				if plot1 == departForResearch or plot1 == goltinAndResearch then
					oMessage = string.format(_("artifactOrders-comms","%sProvide artifact research to ambassador Gremus on Goltin 7. "),oMessage)
				end
			end
			setCommsMessage(oMessage)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then 
    	setCommsMessage(_("station-comms","You need to stay docked for that action."))
    	return 
    end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then 
        	setCommsMessage(_("ammo-comms","We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then 
        	setCommsMessage(_("ammo-comms","We do not deal in weapons of mass disruption."))
        else 
        	setCommsMessage(_("ammo-comms","We do not deal in those weapons."))
        end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms","All nukes are charged and primed for destruction."))
        else
            setCommsMessage(_("ammo-comms","Sorry, sir, but you are as fully stocked as I can allow."))
        end
    else
        if not player:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage(_("needRep-comms","Not enough reputation."))
            return
        end
        player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
        if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
            setCommsMessage(_("ammo-comms","You are fully loaded and ready to explode things."))
        else
            setCommsMessage(_("ammo-comms","We generously resupplied you with some weapon charges.\nPut them to good use."))
        end
    end
    addCommsReply(_("Back"), commsStation)
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        setCommsMessage(_("station-comms","Good day, officer.\nIf you need supplies, please dock with us first."))
    else
        setCommsMessage(_("station-comms","Greetings.\nIf you want to do business, please dock with us first."))
    end
    if isAllowedTo(comms_target.comms_data.services.supplydrop) then
    	addCommsReply(string.format(_("stationAssist-comms","Can you send a supply drop? (%s rep)"),getServiceCost("supplydrop")),function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms","You need to set a waypoint before you can request backup."))
            else
                setCommsMessage(_("stationAssist-comms","To which waypoint should we deliver your supplies?"))
                for n=1,player:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %s"),n),function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage(string.format(_("stationAssist-comms","We have dispatched a supply ship toward waypoint %s"),n))
                        else
                            setCommsMessage(_("needRep-comms","Not enough reputation!"))
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
    	addCommsReply(string.format(_("stationAssist-comms","Please send reinforcements! (rep %s)"),getServiceCost("reinforcements")),function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms","You need to set a waypoint before you can request reinforcements."))
            else
                setCommsMessage(_("stationAssist-comms","To which waypoint should we dispatch the reinforcements?"))
                for n=1,player:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms","Waypoint %s"),n),function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to assist at waypoint %s"),ship:getCallSign(),n))
                        else
                            setCommsMessage(_("needRep-comms","Not enough reputation!"))
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
    helpfulWaypoints()
end
function helpfulWaypoints()
	-- Add helpful waypoint creation messages
	points_of_interest = {
		{id = "askForBalindorLocation",	prompt = _("path-comms","Where is Balindor Prime?"),	resp = _("path-comms","planet Balindor Prime"),	poi = balindorPrime},
		{id = "askForNingLocation",		prompt = _("path-comms","Where is Ningling?"),			resp = _("path-comms","Ningling station"),		poi = ningling},
		{id = "askForGoltinLocation",	prompt = _("path-comms","Where is Goltin 7?"),			resp = _("path-comms","planet Goltin 7"),		poi = goltin},
		{id = "askForPangoraLocation",	prompt = _("path-comms","Where is Pangora?"),			resp = _("path-comms","Pangora station"),		poi = stationPangora},
		{id = "askForNakorLocation",	prompt = _("path-comms","Where is Nakor?"),				resp = _("path-comms","Nakor station"),			poi = stationNakor},
		{id = "askForScience37Location",prompt = _("path-comms","Where is Science-37?"),		resp = _("path-comms","station Science-37"),	poi = science37},
	}
	for i,point_of_interest in ipairs(points_of_interest) do
		if isAllowedTo(player.location_help[point_of_interest.id]) then
			addCommsReply(point_of_interest.prompt,function()
				local replace_waypoint = false
				if player:getWaypointCount() >= 9 then
					player:commandRemoveWaypoint(9)
					replace_waypoint = true
				end
				local px, py = point_of_interest.poi:getPosition()
				player:commandAddWaypoint(px, py)
				if replace_waypoint then
					setCommsMessage(string.format(_("path-comms","Replaced former waypoint 9 with new waypoint 9 for %s.\nYou reached the 9 waypoint maximum."),point_of_interest.resp))
				else
					setCommsMessage(string.format(_("path-comms","Added a waypoint to your navigation system for %s"),point_of_interest.resp))
				end
				player.location_help[point_of_interest.id] = "complete"
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	-- Add artifact location clues
	local artifact_reports = {
		{id = "askForPangoraArtifactLocation",		prompt = _("artifact-comms","Any reports of artifacts near Pangora?"),					resp = _("artifact-comms","Some freighters report seeing an artifact on approximate heading 135 from Pangora.")},
		{id = "askForNakorArtifactLocation",		prompt = _("artifact-comms","Heard of any artifacts near Nakor?"),						resp = _("artifact-comms","Some have reported seeing object on approximate heading of 315 from Nakor station.")},
		{id = "askForScience37ArtifactLocation",	prompt = _("artifact-comms","Has anyone reported seeing artifacts near Science-37?"),	resp = _("artifact-comms","Freighters doing business here occasionally report an objecton approximate heading zero from Science-37 station.")},
	}
	for i,report in ipairs(artifact_reports) do
		if isAllowedTo(player.report_help[report.id]) then
			addCommsReply(report.prompt, function()
				setCommsMessage(report.resp)
				player.report_help[report.id] = "complete"
				addCommsReply(_("Back"), commsStation)
			end)
		end
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
	if state == "orders" and comms_target:getFaction() == "Human Navy" then
		return true
	end
    return false
end
function getWeaponCost(weapon)	--Return reputation points required for specified weapon for player
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function getServiceCost(service)	--Return reputation points required for specified service for player
    return math.ceil(comms_data.service_cost[service])
end
function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function availableForComms(p)
	if not p:isCommsInactive() then
		return false
	end
	if p:isCommsOpening() then
		return false
	end
	if p:isCommsBeingHailed() then
		return false
	end
	if p:isCommsBeingHailedByGM() then
		return false
	end
	if p:isCommsChatOpen() then
		return false
	end
	if p:isCommsChatOpenToGM() then
		return false
	end
	if p:isCommsChatOpenToPlayer() then
		return
	end
	if p:isCommsScriptOpen() then
		return false
	end
	return true
end
function update(delta)
    if not player:isValid() then
    	globalMessage(string.format(_("msgMainscreen","%s destroyed. Ambassador Gremus killed.\nWar begins on Goltin 7. Disgrace abounds."),playerCallSign))
        victory("Kraylor")
        return
    end   
	if plot1 == nil then
		globalMessage(_("msgMainscreen","Congratulations! You delivered ambassador Gremus\n...and did other things, too."))
		victory("Human Navy")
		return
	end
	if plot2 == defeat then
		victory("Kraylor")
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
	if plot5 ~= nil then
		plot5()
	end
	if transportPlot ~= nil then
		transportPlot()
	end
	audioButtonTimers()
    if bpcommnex ~= nil and bpcommnex:isValid() and balindorPrime ~= nil then
    	bpcommnex.bp_angle = bpcommnex.bp_angle + delta*.25
    	if bpcommnex.bp_angle > 360 then
    		bpcommnex.bp_angle = bpcommnex.bp_angle - 360
    	end
		local sx, sy = vectorFromAngleNorth(bpcommnex.bp_angle,bpcommnex.bp_distance)
		local bx, by = balindorPrime:getPosition()
		bpcommnex:setPosition(bx + sx, by + sy)
	end
end

