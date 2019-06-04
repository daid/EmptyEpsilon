-- Name: Borderline Fever
-- Description: War temperature rises along the border between Human Navy space and Kraylor space. The treaty holds for now, but the diplomats and intelligence operatives fear the Kraylors are about to break the treaty. We must maintain the treaty despite provocation until war is formally declared.
---
--- Version 0
-- Type: Replayable Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Timed]: Victory if all human navy stations and player ships survive for 30 minutes
-- Variation[Timed Easy]: Victory if all human navy stations and player ships survive for 30 minutes, Easy goals and/or enemies
-- Variation[Timed Hard]: Victory if all human navy stations and player ships survive for 30 minutes, Hard goals and/or enemies


-- to do items:

-- Station warning of enemies in area (helpful warnings - shuffle stations)
-- Kraylor ship names for freighters and warships; Human navy ship names for freighters and warships

require("utils.lua")

--[[-----------------------------------------------------------------
      Initialization 
-----------------------------------------------------------------]]--
function init()
	print(_VERSION)
	defaultGameTimeLimitInMinutes = 30	--final: 30 (lowered for test)
	rawKraylorShipStrength = 0
	rawHumanShipStrength = 0
	--These random range values are in seconds, not minutes
	--Place in variables to facilitate testing and tinkering
	--random range 1 final: 120, 300 (lowered for test) initial attack, pincer attack, vengence
	lrr1 = 120		--lower random range
	urr1 = 300		--upper random range
	--random range 2 final: 120, 500 (lowered for test) initial attack, pincer attack, vengence
	lrr2 = 120		--lower random range
	urr2 = 500		--upper random range
	--random range 3 final: 120, 180 (lowered for test) initial attack, pincer attack, vengence
	lrr3 = 120		--lower random range
	urr3 = 180		--upper random range
	--random range 4 final: 30, 300 (lowered for test)	treaty for timed game
	lrr4 = 30
	urr4 = 300
	--random range 4 final: 240, 540 (lowered for test) treaty for game with no time limit
	lrr5 = 240
	urr5 = 540
	
	--end of game victory/defeat values
	enemyDestructionVictoryCondition = 70		--final: 70
	friendlyDestructionDefeatCondition = 50		--final: 50
	destructionDifferenceEndCondition = 20		--final: 20
	--enemy strength evaluation; ratio of stations to ships. Must add up to 1
	enemyStationComponentWeight = .65
	enemyShipComponentWeight = .35
	--friendly strength evaluation; ratio of friendly stations, neutral stations and friendly ships. Must add up to 1
	friendlyStationComponentWeight = .5
	neutralStationComponentWeight = .1
	friendlyShipComponentWeight = .4
	
	repeatExitBoundary = 100
	setVariations()
	initDiagnostic = false
	diagnostic = false
	optionalMissionDiagnostic = false
	paDiagnostic = true
	plot3diagnostic = false
	plot1Diagnostic = false
	updateDiagnostic = false
	healthDiagnostic = false
	plot2diagnostic = false
	endStatDiagnostic = true
	printDetailedStats = true
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	repeat
		setGossipSnippets()
		setGoodsList()
		setListOfStations()
		setBorderZones()
		buildStationsPlus()
		if initDiagnostic then print("weird zone adjustment count: " .. wzac) end
		spawnInInnerZone = false
		spawnMarker = VisualAsteroid():setPosition(0,0)
		spawnInInnerZone = innerZone:isInside(spawnMarker)
		spawnMarker:destroy()
		if wzac > 0 or #kraylorStationList < 5 or #humanStationList < 5 or not spawnInInnerZone then
			resetStationsPlus()
		end
	until(wzac < 1 and #kraylorStationList >= 5 and #humanStationList >= 5 and spawnInInnerZone)
	if not diagnostic then
		for i=1,#innerZoneList do
			innerZoneList[i]:destroy()
		end
		for i=1,#outerZoneList do
			outerZoneList[i]:destroy()
		end
	end
	setFleets()
	setEnemyStationDefenses()
	setOptionalMissions()
	setCharacterNames()
	plot1 = treatyHolds
	treaty = true
	initialAssetsEvaluated = false
	plotC = autoCoolant		--enable buttons for turning on and off automated cooling
	plotCI = cargoInventory
	plotH = healthCheck		--Damage to ship can kill repair crew members
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	plotPB = playerBorderCheck
	plotPWC = playerWarCrimeCheck
	plotED = enemyDefenseCheck
	plotEB = enemyBorderCheck
	enemyEverDetected = false
	enemyBorderCheckInterval = 3
	enemyBorderCheckTimer = enemyBorderCheckInterval
	plotKT = kraylorTransportPlot
	kraylorTransportList = {}
	kraylorTransportSpawnDelay = 20
	plotIT = independentTransportPlot
	independentTransportList = {}
	independentTransportSpawnDelay = 20
	plotFT = friendlyTransportPlot
	friendlyTransportList = {}
	friendlyTransportSpawnDelay = 20
	plotEW = endWar
	endWarTimerInterval = 9
	endWarTimer = endWarTimerInterval
	plotDGM = dynamicGameMasterButtons
	plotPA = personalAmbush
	enemyVesselDestroyedNameList = {}
	enemyVesselDestroyedType = {}
	enemyVesselDestroyedValue = {}
	friendlyVesselDestroyedNameList = {}
	friendlyVesselDestroyedType = {}
	friendlyVesselDestroyedValue = {}
	friendlyStationDestroyedNameList = {}
	friendlyStationDestroyedValue = {}
	enemyStationDestroyedNameList = {}
	enemyStationDestroyedValue = {}
	neutralStationDestroyedNameList = {}
	neutralStationDestroyedValue = {}
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
end
function setVariations()
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
		adverseEffect = .999
		enemyDestructionVictoryCondition = enemyDestructionVictoryCondition*1.1
		friendlyDestructionDefeatCondition = friendlyDestructionDefeatCondition*.9
		destructionDifferenceEndCondition = destructionDifferenceEndCondition*1.1
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
		adverseEffect = .99
		enemyDestructionVictoryCondition = enemyDestructionVictoryCondition*.9
		friendlyDestructionDefeatCondition = friendlyDestructionDefeatCondition*1.1
		destructionDifferenceEndCondition = destructionDifferenceEndCondition*.9
	else
		difficulty = 1		--default (normal)
		adverseEffect = .995
	end
	if string.find(getScenarioVariation(),"Timed") then
		playWithTimeLimit = true
		gameTimeLimit = defaultGameTimeLimitInMinutes*60		
		plot2 = timedGame
	else
		gameTimeLimit = 0
		playWithTimeLimit = false
	end
end
function setConstants()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	--Player ship name lists to supplant standard randomized call sign generation
	playerShipNamesForMP52Hornet = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesForPiranha = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesForFlaviaPFalcon = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesForPhobosM3P = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesForAtlantis = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesForCruiser = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesForMissileCruiser = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesForFighter = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesForBenedict = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesForKiriya = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesForStriker = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	playerShipNamesForLindworm = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesForRepulse = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesForEnder = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesForNautilus = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesForHathcock = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}
	characterNames = {"Frank Brown",
					  "Joyce Miller",
					  "Harry Jones",
					  "Emma Davis",
					  "Zhang Wei Chen",
					  "Yu Yan Li",
					  "Li Wei Wang",
					  "Li Na Zhao",
					  "Sai Laghari",
					  "Anaya Khatri",
					  "Vihaan Reddy",
					  "Trisha Varma",
					  "Henry Gunawan",
					  "Putri Febrian",
					  "Stanley Hartono",
					  "Citra Mulyadi",
					  "Bashir Pitafi",
					  "Hania Kohli",
					  "Gohar Lehri",
					  "Sohelia Lau",
					  "Gabriel Santos",
					  "Ana Melo",
					  "Lucas Barbosa",
					  "Juliana Rocha",
					  "Habib Oni",
					  "Chinara Adebayo",
					  "Tanimu Ali",
					  "Naija Bello",
					  "Shamim Khan",
					  "Barsha Tripura",
					  "Sumon Das",
					  "Farah Munsi",
					  "Denis Popov",
					  "Pasha Sokolov",
					  "Burian Ivanov",
					  "Radka Vasiliev",
					  "Jose Hernandez",
					  "Victoria Garcia",
					  "Miguel Lopez",
					  "Renata Rodriguez"}
	hitZonePermutations = {
		{"warp","beamweapons","reactor"},
		{"jumpdrive","beamweapons","reactor"},
		{"impulse","beamweapons","reactor"},
		{"warp","missilesystem","reactor"},
		{"jumpdrive","missilesystem","reactor"},
		{"impulse","missilesystem","reactor"},
		{"warp","beamweapons","maneuver"},
		{"jumpdrive","beamweapons","maneuver"},
		{"impulse","beamweapons","maneuver"},
		{"warp","missilesystem","maneuver"},
		{"jumpdrive","missilesystem","maneuver"},
		{"impulse","missilesystem","maneuver"},
		{"warp","beamweapons","frontshield"},
		{"jumpdrive","beamweapons","frontshield"},
		{"impulse","beamweapons","frontshield"},
		{"warp","missilesystem","frontshield"},
		{"jumpdrive","missilesystem","frontshield"},
		{"impulse","missilesystem","frontshield"},
		{"warp","beamweapons","rearshield"},
		{"jumpdrive","beamweapons","rearshield"},
		{"impulse","beamweapons","rearshield"},
		{"warp","missilesystem","rearshield"},
		{"jumpdrive","missilesystem","rearshield"},
		{"impulse","missilesystem","rearshield"},
		{"warp","reactor","maneuver"},
		{"jumpdrive","reactor","maneuver"},
		{"impulse","reactor","maneuver"},
		{"warp","reactor","frontshield"},
		{"jumpdrive","reactor","frontshield"},
		{"impulse","reactor","frontshield"},
		{"warp","reactor","rearshield"},
		{"jumpdrive","reactor","rearshield"},
		{"impulse","reactor","rearshield"},
		{"warp","maneuver","frontshield"},
		{"jumpdrive","maneuver","frontshield"},
		{"impulse","maneuver","frontshield"},
		{"warp","maneuver","rearshield"},
		{"jumpdrive","maneuver","rearshield"},
		{"impulse","maneuver","rearshield"},
		{"beamweapons","beamweapons","maneuver"},
		{"missilesystem","beamweapons","maneuver"},
		{"beamweapons","beamweapons","frontshield"},
		{"missilesystem","beamweapons","frontshield"},
		{"beamweapons","beamweapons","rearshield"},
		{"missilesystem","beamweapons","rearshield"},
		{"beamweapons","maneuver","frontshield"},
		{"missilesystem","maneuver","frontshield"},
		{"beamweapons","maneuver","rearshield"},
		{"missilesystem","maneuver","rearshield"},
		{"reactor","maneuver","frontshield"},
		{"reactor","maneuver","rearshield"}
	}
end
function setGossipSnippets()
	gossipSnippets = {}
	table.insert(gossipSnippets,"I hear the head of operations has a thing for his administrative assistant")	--1
	table.insert(gossipSnippets,"My mining friends tell me Krak or Kruk is about to strike it rich")			--2
	table.insert(gossipSnippets,"Did you know you can usually hire replacement repair crew cheaper at friendly stations?")		--3
	table.insert(gossipSnippets,"Under their uniforms, the Kraylors have an extra appendage. I wonder what they use it for")	--4
	table.insert(gossipSnippets,"The Kraylors may be human navy enemies, but they make some mighty fine BBQ Mynock")			--5
	table.insert(gossipSnippets,"The Kraylors and the Ktlitans may be nearing a cease fire from what I hear. That'd be bad news for us")		--6
	table.insert(gossipSnippets,"Docking bay 7 has interesting mind altering substances for sale, but they're monitored between 1900 and 2300")	--7
	table.insert(gossipSnippets,"Watch the sky tonight in quadrant J around 2243. It should be spectacular")					--8
	table.insert(gossipSnippets,"I think the shuttle pilot has a tame miniature Ktlitan caged in his quarters. Sometimes I hear it at night")	--9
	table.insert(gossipSnippets,"Did you hear the screaming chase in the corridors on level 4 last night? Three Kraylors were captured and put in the brig")	--10
	table.insert(gossipSnippets,"Rumor has it that the two Lichten brothers are on the verge of a new discovery. And it's not another wine flavor either")		--11
end
function setCharacterNames()
	for i=1,#humanStationList do
		curStation = humanStationList[i]
		if curStation.character == nil then
			if #characterNames > 0 then
				nameChoice = math.random(1,#characterNames)
				curStation.character = characterNames[nameChoice]
				table.remove(characterNames,nameChoice)
			end
		end
	end
end
function setBorderZones()
	sx, sy = vectorFromAngle(random(0,360),random(20000,30000))
	borderStartAngle = random(0,360)
	borderStartX, borderStartY = vectorFromAngle(borderStartAngle,random(3500,4900))
	halfLength = random(8000,15000)
	zoneLimit = 150000
	borderZone = {}
	innerZoneList = {}
	outerZoneList = {}
	bzi = 1		--border zone index
	--Note: "left" and "right" refer to someone standing on the 2D board at the spawn point looking at the zones being added;
	--		"inner" means closer to the spawn point, "outer" means further away from the spawn point
	borderZoneLeftInnerX = {}
	borderZoneLeftInnerY = {}
	borderZoneRightInnerX = {}
	borderZoneRightInnerY = {}
	borderZoneLeftOuterX = {}
	borderZoneLeftOuterY = {}
	borderZoneRightOuterX = {}
	borderZoneRightOuterY = {}
	bzsx, bzsy = vectorFromAngle(borderStartAngle+270,halfLength)	--border zone start x and y coordinates
	table.insert(borderZoneLeftInnerX, borderStartX+bzsx)
	table.insert(borderZoneLeftInnerY, borderStartY+bzsy)
	bzsx, bzsy = vectorFromAngle(borderStartAngle+90,halfLength)	--border sone start x and y coordinates
	table.insert(borderZoneRightInnerX, borderStartX+bzsx)
	table.insert(borderZoneRightInnerY, borderStartY+bzsy)
	bendAngle = random(1,30)
	negativeBendCount = 0
	positiveBendCount = 0
	if random(1,100) < 50 then
		negativeBendCount = negativeBendCount + bendAngle
		bendAngle = -1*bendAngle
	else
		positiveBendCount = positiveBendCount + bendAngle
	end
	bendAngle = borderStartAngle + bendAngle
	if bendAngle < 0 then
		bendAngle = bendAngle + 360
	end
	borderZoneWidth = random(10000,15000)
	bzsx, bzsy = vectorFromAngle(bendAngle,borderZoneWidth)		--border zone start x and y coordinates
	table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi]+bzsx)
	table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi]+bzsy)
	table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi]+bzsx)
	table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi]+bzsy)
	cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],		--current border zone
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	ilx, ily = vectorFromAngle(borderStartAngle+210,zoneLimit)		--inner left x and y coordinates
	irx, iry = vectorFromAngle(borderStartAngle+150,zoneLimit)		--inner right x and y coordinates
	ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],		--current inner zone
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(50,50,50) end
	table.insert(innerZoneList,ciz)
	olx, oly = vectorFromAngle(borderStartAngle+330,zoneLimit)		--outer left x and y coordinates
	orx, ory = vectorFromAngle(borderStartAngle+30,zoneLimit)		--outer right x and y coordinates
	coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],	--current outer zone
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
						   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
	if initDiagnostic then coz:setColor(0,128,0) end
	table.insert(outerZoneList,coz)
	--new zone on the left
	bzi = bzi + 1
	table.insert(borderZoneRightInnerX,borderZoneLeftInnerX[bzi-1])
	table.insert(borderZoneRightInnerY,borderZoneLeftInnerY[bzi-1])
	table.insert(borderZoneRightOuterX,borderZoneLeftOuterX[bzi-1])
	table.insert(borderZoneRightOuterY,borderZoneLeftOuterY[bzi-1])
	bzx, bzy = vectorFromAngle(bendAngle+270,random(20000,30000))		--border zone x and y corrdinates
	table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi]+bzx)
	table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi]+bzy)
	upBound = 2 + negativeBendCount + positiveBendCount
	cutOff = math.min(positiveBendCount,negativeBendCount)
	newBend = random(1,30)
	if negativeBendCount < positiveBendCount then
		if random(1,upBound) <= cutOff then
			negativeBendCount = negativeBendCount + newBend
			newBend = -1*newBend
		else
			positiveBendCount = positiveBendCount + newBend
		end
	else
		if random(1,upBound) <= cutOff then
			positiveBendCount = positiveBendCount + newBend
		else
			newBend = -1*newBend
			negativeBendCount = negativeBendCount + newBend
		end
	end
	newBend = bendAngle + newBend
	if newBend < 0 then
		newBend = newBend + 360
	end
	bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
	table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi]+bzx)
	table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi]+bzy)
	--new zone on the right
	table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi-1])
	table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi-1])
	table.insert(borderZoneLeftOuterX,borderZoneRightOuterX[bzi-1])
	table.insert(borderZoneLeftOuterY,borderZoneRightOuterY[bzi-1])
	bzx, bzy = vectorFromAngle(bendAngle+90,random(20000,30000))
	table.insert(borderZoneRightInnerX,borderZoneRightInnerX[bzi-1]+bzx)
	table.insert(borderZoneRightInnerY,borderZoneRightInnerY[bzi-1]+bzy)
	bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
	table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi+1]+bzx)
	table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi+1]+bzy)
	--establish current border zone (cbz)
	cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	ilx, ily = vectorFromAngle(bendAngle+210,zoneLimit)
	irx, iry = vectorFromAngle(bendAngle+150,zoneLimit)
	ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(100,100,100) end
	table.insert(innerZoneList,ciz)
	olx, oly = vectorFromAngle(bendAngle+330,zoneLimit)
	orx, ory = vectorFromAngle(bendAngle+30,zoneLimit)
	coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
						   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
	if initDiagnostic then coz:setColor(0,192,0) end
	table.insert(outerZoneList,coz)
	bzi = bzi + 1
	cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	ilx, ily = vectorFromAngle(bendAngle+210,zoneLimit)
	irx, iry = vectorFromAngle(bendAngle+150,zoneLimit)
	ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(150,150,150) end
	table.insert(innerZoneList,ciz)
	olx, oly = vectorFromAngle(bendAngle+330,zoneLimit)
	orx, ory = vectorFromAngle(bendAngle+30,zoneLimit)
	coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
						   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
	if initDiagnostic then coz:setColor(0,255,0) end
	table.insert(outerZoneList,coz)
	for i=1,20 do
		bendAngle = newBend
		--new bend applies to both left and right zones to be added
		upBound = 2 + negativeBendCount + positiveBendCount
		cutOff = math.max(positiveBendCount,negativeBendCount)
		newBend = random(1,30)
		if negativeBendCount < positiveBendCount then
			if random(1,upBound) <= cutOff then
				negativeBendCount = negativeBendCount + newBend
				newBend = -1*newBend
			else
				positiveBendCount = positiveBendCount + newBend
			end
		else
			if random(1,upBound) <= cutOff then
				positiveBendCount = positiveBendCount + newBend
			else
				negativeBendCount = negativeBendCount + newBend
				newBend = -1*newBend
			end
		end
		newBend = bendAngle + newBend
		if newBend < 0 then
			newBend = newBend + 360
		end
		if initDiagnostic then print(string.format("i: %i, bend angle: %.1f, new bend angle: %.1f, upBound: %.1f, pos: %.1f, neg: %.1f, cutoff: %.1f",i,bendAngle,newBend,upBound,positiveBendCount,negativeBendCount,cutOff)) end
		--new zone on the left
		table.insert(borderZoneRightInnerX,borderZoneLeftInnerX[bzi-1])
		table.insert(borderZoneRightInnerY,borderZoneLeftInnerY[bzi-1])
		table.insert(borderZoneRightOuterX,borderZoneLeftOuterX[bzi-1])
		table.insert(borderZoneRightOuterY,borderZoneLeftOuterY[bzi-1])
		bzx, bzy = vectorFromAngle(bendAngle+270,random(20000,30000))
		table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi+1]+bzx)
		table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi+1]+bzy)
		bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
		table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi+1]+bzx)
		table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi+1]+bzy)
		bzi = bzi + 1
		cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
							   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
							   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
							   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
		cbz.detect = 0
		table.insert(borderZone,cbz)
		if i < 3 then
			ilx, ily = vectorFromAngle(bendAngle+210,100000)
			irx, iry = vectorFromAngle(bendAngle+150,100000)
			ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
								   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
								   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
								   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
			if initDiagnostic then ciz:setColor(50,50,50) end
			table.insert(innerZoneList,ciz)
			olx, oly = vectorFromAngle(bendAngle+330,100000)
			orx, ory = vectorFromAngle(bendAngle+30,100000)
			coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
								   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
								   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
								   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
			if initDiagnostic then coz:setColor(0,128,0) end
			table.insert(outerZoneList,coz)
		end
		--new zone on the right
		table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi-1])
		table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi-1])
		table.insert(borderZoneLeftOuterX,borderZoneRightOuterX[bzi-1])
		table.insert(borderZoneLeftOuterY,borderZoneRightOuterY[bzi-1])
		bzx, bzy = vectorFromAngle(bendAngle+90,random(20000,30000))
		table.insert(borderZoneRightInnerX,borderZoneRightInnerX[bzi-1]+bzx)
		table.insert(borderZoneRightInnerY,borderZoneRightInnerY[bzi-1]+bzy)
		bzx, bzy = vectorFromAngle(newBend,borderZoneWidth)
		table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi+1]+bzx)
		table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi+1]+bzy)
		bzi = bzi + 1
		cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
							   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
							   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
							   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
		cbz.detect = 0
		table.insert(borderZone,cbz)
		if i < 3 then
			ilx, ily = vectorFromAngle(bendAngle+210,100000)
			irx, iry = vectorFromAngle(bendAngle+150,100000)
			ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],
								   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
								   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
								   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
			if initDiagnostic then ciz:setColor(50,50,50) end
			table.insert(innerZoneList,ciz)
			olx, oly = vectorFromAngle(bendAngle+330,100000)
			orx, ory = vectorFromAngle(bendAngle+30,100000)
			coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
								   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
								   borderZoneLeftOuterX[bzi]+olx,borderZoneLeftOuterY[bzi]+oly,
								   borderZoneRightOuterX[bzi]+orx,borderZoneRightOuterY[bzi]+ory)
			if initDiagnostic then coz:setColor(0,128,0) end
			table.insert(outerZoneList,coz)
		end
	end
	if initDiagnostic then print(string.format("border zones created: %i",bzi)) end
	bzlx, bzly = vectorFromAngle(borderStartAngle+225,900000)
	bzrx, bzry = vectorFromAngle(borderStartAngle+135,900000)
	innerZone = Zone():setPoints(borderZoneLeftInnerX[1],borderZoneLeftInnerY[1],
								 borderZoneRightInnerX[1],borderZoneRightInnerY[1],
								 borderZoneRightInnerX[3],borderZoneRightInnerY[3],
								 borderZoneRightInnerX[5],borderZoneRightInnerY[5],
								 borderZoneRightInnerX[7],borderZoneRightInnerY[7],
								 borderZoneRightInnerX[9],borderZoneRightInnerY[9],
								 borderZoneRightInnerX[11],borderZoneRightInnerY[11],
								 borderZoneRightInnerX[13],borderZoneRightInnerY[13],
								 borderZoneRightInnerX[15],borderZoneRightInnerY[15],
								 borderZoneRightInnerX[17],borderZoneRightInnerY[17],
								 borderZoneRightInnerX[19],borderZoneRightInnerY[19],
								 borderZoneRightInnerX[21],borderZoneRightInnerY[21],
								 borderZoneRightInnerX[23],borderZoneRightInnerY[23],
								 borderZoneRightInnerX[25],borderZoneRightInnerY[25],
								 borderZoneRightInnerX[27],borderZoneRightInnerY[27],
								 borderZoneRightInnerX[29],borderZoneRightInnerY[29],
								 borderZoneRightInnerX[31],borderZoneRightInnerY[31],
								 borderZoneRightInnerX[33],borderZoneRightInnerY[33],
								 borderZoneRightInnerX[35],borderZoneRightInnerY[35],
								 borderZoneRightInnerX[37],borderZoneRightInnerY[37],
								 borderZoneRightInnerX[39],borderZoneRightInnerY[39],
								 borderZoneRightInnerX[41],borderZoneRightInnerY[41],
								 borderZoneRightInnerX[43],borderZoneRightInnerY[43],
								 borderZoneRightInnerX[43]+bzrx,borderZoneRightInnerY[43]+bzry,
								 borderZoneLeftInnerX[42]+bzlx,borderZoneLeftInnerY[42]+bzly,
								 borderZoneLeftInnerX[42],borderZoneLeftInnerY[42],
								 borderZoneLeftInnerX[40],borderZoneLeftInnerY[40],
								 borderZoneLeftInnerX[38],borderZoneLeftInnerY[38],
								 borderZoneLeftInnerX[36],borderZoneLeftInnerY[36],
								 borderZoneLeftInnerX[34],borderZoneLeftInnerY[34],
								 borderZoneLeftInnerX[32],borderZoneLeftInnerY[32],
								 borderZoneLeftInnerX[30],borderZoneLeftInnerY[30],
								 borderZoneLeftInnerX[28],borderZoneLeftInnerY[28],
								 borderZoneLeftInnerX[26],borderZoneLeftInnerY[26],
								 borderZoneLeftInnerX[24],borderZoneLeftInnerY[24],
								 borderZoneLeftInnerX[22],borderZoneLeftInnerY[22],
								 borderZoneLeftInnerX[20],borderZoneLeftInnerY[20],
								 borderZoneLeftInnerX[18],borderZoneLeftInnerY[18],
								 borderZoneLeftInnerX[16],borderZoneLeftInnerY[16],
								 borderZoneLeftInnerX[14],borderZoneLeftInnerY[14],
								 borderZoneLeftInnerX[12],borderZoneLeftInnerY[12],
								 borderZoneLeftInnerX[10],borderZoneLeftInnerY[10],
								 borderZoneLeftInnerX[8],borderZoneLeftInnerY[8],
								 borderZoneLeftInnerX[6],borderZoneLeftInnerY[6],
								 borderZoneLeftInnerX[4],borderZoneLeftInnerY[4],
								 borderZoneLeftInnerX[2],borderZoneLeftInnerY[2])
	if initDiagnostic then innerZone:setColor(204,0,204) end
	bzrx, bzry = vectorFromAngle(borderStartAngle+45,900000)
	bzlx, bzly = vectorFromAngle(borderStartAngle+315,900000)
	outerZone = Zone():setPoints(borderZoneRightOuterX[2],borderZoneRightOuterY[2],
								 borderZoneRightOuterX[4],borderZoneRightOuterY[4],
								 borderZoneRightOuterX[6],borderZoneRightOuterY[6],
								 borderZoneRightOuterX[8],borderZoneRightOuterY[8],
								 borderZoneRightOuterX[10],borderZoneRightOuterY[10],
								 borderZoneRightOuterX[12],borderZoneRightOuterY[12],
								 borderZoneRightOuterX[14],borderZoneRightOuterY[14],
								 borderZoneRightOuterX[16],borderZoneRightOuterY[16],
								 borderZoneRightOuterX[18],borderZoneRightOuterY[18],
								 borderZoneRightOuterX[20],borderZoneRightOuterY[20],
								 borderZoneRightOuterX[22],borderZoneRightOuterY[22],
								 borderZoneRightOuterX[24],borderZoneRightOuterY[24],
								 borderZoneRightOuterX[26],borderZoneRightOuterY[26],
								 borderZoneRightOuterX[28],borderZoneRightOuterY[28],
								 borderZoneRightOuterX[30],borderZoneRightOuterY[30],
								 borderZoneRightOuterX[32],borderZoneRightOuterY[32],
								 borderZoneRightOuterX[34],borderZoneRightOuterY[34],
								 borderZoneRightOuterX[36],borderZoneRightOuterY[36],
								 borderZoneRightOuterX[38],borderZoneRightOuterY[38],
								 borderZoneRightOuterX[40],borderZoneRightOuterY[40],
								 borderZoneRightOuterX[42],borderZoneRightOuterY[42],
								 borderZoneLeftOuterX[42],borderZoneLeftOuterY[42],
								 borderZoneLeftOuterX[42]+bzlx,borderZoneLeftOuterY[42]+bzly,
								 borderZoneRightOuterX[43]+bzrx,borderZoneRightOuterY[43]+bzry,
								 borderZoneRightOuterX[43],borderZoneRightOuterY[43],
								 borderZoneRightOuterX[41],borderZoneRightOuterY[41],
								 borderZoneRightOuterX[39],borderZoneRightOuterY[39],
								 borderZoneRightOuterX[37],borderZoneRightOuterY[37],
								 borderZoneRightOuterX[35],borderZoneRightOuterY[35],
								 borderZoneRightOuterX[33],borderZoneRightOuterY[33],
								 borderZoneRightOuterX[31],borderZoneRightOuterY[31],
								 borderZoneRightOuterX[29],borderZoneRightOuterY[29],
								 borderZoneRightOuterX[27],borderZoneRightOuterY[27],
								 borderZoneRightOuterX[25],borderZoneRightOuterY[25],
								 borderZoneRightOuterX[23],borderZoneRightOuterY[23],
								 borderZoneRightOuterX[21],borderZoneRightOuterY[21],
								 borderZoneRightOuterX[19],borderZoneRightOuterY[19],
								 borderZoneRightOuterX[17],borderZoneRightOuterY[17],
								 borderZoneRightOuterX[15],borderZoneRightOuterY[15],
								 borderZoneRightOuterX[13],borderZoneRightOuterY[13],
								 borderZoneRightOuterX[11],borderZoneRightOuterY[11],
								 borderZoneRightOuterX[9],borderZoneRightOuterY[9],
								 borderZoneRightOuterX[7],borderZoneRightOuterY[7],
								 borderZoneRightOuterX[5],borderZoneRightOuterY[5],
								 borderZoneRightOuterX[3],borderZoneRightOuterY[3],
								 borderZoneRightOuterX[1],borderZoneRightOuterY[1])
	if initDiagnostic then outerZone:setColor(255,165,0) end
end
function setGoodsList()
	--list of goods available to buy, sell or trade (sell still under development)
	goodsList = {	{"food",0},
					{"medicine",0},
					{"nickel",0},
					{"platinum",0},
					{"gold",0},
					{"dilithium",0},
					{"tritanium",0},
					{"luxury",0},
					{"cobalt",0},
					{"impulse",0},
					{"warp",0},
					{"shield",0},
					{"tractor",0},
					{"repulsor",0},
					{"beam",0},
					{"optic",0},
					{"robotic",0},
					{"filament",0},
					{"transporter",0},
					{"sensor",0},
					{"communication",0},
					{"autodoc",0},
					{"lifter",0},
					{"android",0},
					{"nanites",0},
					{"software",0},
					{"circuit",0},
					{"battery",0}	}
	goods = {}					--overall tracking of goods
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
end
function setListOfStations()
	--array of functions to facilitate randomized station placement (friendly and neutral)
	placeStation = {placeAlcaleica,			-- 1
					placeAnderson,			-- 2
					placeArcher,			-- 3
					placeArchimedes,		-- 4
					placeArmstrong,			-- 5
					placeAsimov,			-- 6
					placeBarclay,			-- 7
					placeBethesda,			-- 8
					placeBroeck,			-- 9
					placeCalifornia,		--10
					placeCalvin,			--11
					placeCavor,				--12
					placeChatuchak,			--13
					placeCoulomb,			--14
					placeCyrus,				--15
					placeDeckard,			--16
					placeDeer,				--17
					placeErickson,			--18
					placeEvondos,			--19
					placeFeynman,			--20
					placeGrasberg,			--21
					placeHayden,			--22
					placeHeyes,				--23
					placeHossam,			--24
					placeImpala,			--25
					placeKomov,				--26
					placeKrak,				--27
					placeKruk,				--28
					placeLipkin,			--29
					placeMadison,			--30
					placeMaiman,			--31
					placeMarconi,			--32
					placeMayo,				--33
					placeMiller,			--34
					placeMuddville,			--35
					placeNexus6,			--36
					placeOBrien,			--37
					placeOlympus,			--38
					placeOrgana,			--39
					placeOutpost15,			--40
					placeOutpost21,			--41
					placeOwen,				--42
					placePanduit,			--43
					placeRipley,			--44
					placeRutherford,		--45
					placeScience7,			--46
					placeShawyer,			--47
					placeShree,				--48
					placeSoong,				--49
					placeTiberius,			--50
					placeTokra,				--51
					placeToohie,			--52
					placeUtopiaPlanitia,	--53
					placeVactel,			--54
					placeVeloquan,			--55
					placeZefram}			--56
	--array of functions to facilitate randomized station placement (friendly, neutral or enemy)
	placeGenericStation = {placeJabba,		-- 1
					placeKrik,				-- 2
					placeLando,				-- 3
					placeMaverick,			-- 4
					placeNefatha,			-- 5
					placeOkun,				-- 6
					placeOutpost7,			-- 7
					placeOutpost8,			-- 8
					placeOutpost33,			-- 9
					placePrada,				--10
					placeResearch11,		--11
					placeResearch19,		--12
					placeRubis,				--13
					placeScience2,			--14
					placeScience4,			--15
					placeSkandar,			--16
					placeSpot,				--17
					placeStarnet,			--18
					placeTandon,			--19
					placeVaiken,			--20
					placeValero}			--21
	--array of functions to facilitate randomized station placement (enemy)
	placeEnemyStation = {placeAramanth,		-- 1
					placeEmpok,				-- 2
					placeGandala,			-- 3
					placeHassenstadt,		-- 4
					placeKaldor,			-- 5
					placeMagMesra,			-- 6
					placeMosEisley,			-- 7
					placeQuestaVerde,		-- 8
					placeRlyeh,				-- 9
					placeScarletCit,		--10
					placeStahlstadt,		--11
					placeTic}				--12
end
function resetStationsPlus()
	for i=1,#stationList do
		stationList[i]:destroy()
	end
	allObjects = getAllObjects()
	for _, obj in ipairs(allObjects) do
		obj:destroy()
	end
end
function buildStationsPlus()
	stationFaction = ""
	stationList = {}
	humanStationList = {}
	humanStationsRemain = true
	kraylorStationList = {}
	kraylorStationsRemain = true
	neutralStationList = {}
	neutralStationsRemain = true
	gbLow = 1		--grid boundary low
	gbHigh = 500	--grid boundary high
	grid = {}		--grid - positional model
	for i=gbLow,gbHigh do
		grid[i] = {}
	end
	gx = gbHigh/2	--grid coordinate x
	gy = gbHigh/2	--grid coordinate y
	gp = 1			--grid position list index
	gSize = random(6000,8000)	--grid cell size in positional units
	adjList = {}				--adjacent space on grid location list
	wzac = 0	--weird zone adjustment count
	planet1 = false
	blackHole1 = false
	planet2 = false
	blackHole2 = false
	humanStationStrength = 0
	kraylorStationStrength = 0
	neutralStationStrength = 0
	repeat
		if gp > 7 and random(1,100) < 20 and not planet1 then
			planet1 = true
			insertPlanet1()
		end
		if planet1 and gp > 19 and random(1,100) < 16 and not blackHole1 then
			blackHole1 = true
			insertBlackHole()
		end
		if planet1 and blackHole1 and gp > 34 and random(1,100) < 23 and not planet2 then
			planet2 = true
			insertPlanet2()
		end
		if planet1 and blackHole1 and planet2 and gp > 55 and random(1,100) < 11 and not blackHole2 then
			blackHole2 = true
			insertBlackHole()
		end
		tSize = math.random(2,5)	--tack on to region size (3-6 since first is outside loop)
		grid[gx][gy] = gp			--set current grid location to grid position list index
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then	--exit loop if there are no more adjacent spaces available
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get adjacent list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getAllAdjacentGridLocations(gx,gy)	
		else
			if random(1,100) < 63 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		ta = VisualAsteroid():setPosition(psx,psy)
		inBorderZone = false
		bzPosCount = 0
		for i=1,#borderZone do
			if borderZone[i]:isInside(ta) then
				inBorderZone = true
				bzPosCount = bzPosCount + 1
			end
		end
		inInnerZone = false
		izPosCount = 0
		for i=1,#innerZoneList do
			if innerZoneList[i]:isInside(ta) then
				inInnerZone = true
				izPosCount = izPosCount + 1
			end
		end
		inOuterZone = false
		ozPosCount = 0
		for i=1,#outerZoneList do
			if outerZoneList[i]:isInside(ta) then
				inOuterZone = true
				ozPosCount = ozPosCount + 1
			end
		end
		pStation = nil
		if inBorderZone then
			placeBorder()
		elseif innerZone:isInside(ta) and outerZone:isInside(ta) then
			wzac = wzac + 1
			if izPosCount > ozPosCount then
				placeInner()
			elseif ozPosCount > izPosCount then
				placeOuter()
			else
				placeBorder()
			end
		elseif innerZone:isInside(ta) then
			placeInner()
		elseif outerZone:isInside(ta) then
			placeOuter()
		elseif inInnerZone and inOuterZone then
			wzac = wzac + 1
			if izPosCount > ozPosCount then
				placeInner()
			elseif ozPosCount > izPosCount then
				placeOuter()
			else
				placeBorder()
			end
		elseif inInnerZone then
			placeInner()
		elseif inOuterZone then
			placeOuter()
		else
			placeBorder()
		end
		if initDiagnostic then
			if pStation ~= nil then
				print(string.format("bz: %i, %s; iz: (%s) %i, %s; oz: (%s) %i, %s, %s faction: %s",bzPosCount,tostring(inBorderZone),tostring(innerZone:isInside(ta)),izPosCount,tostring(inInnerZone),tostring(outerZone:isInside(ta)),ozPosCount,tostring(inOuterZone),pStation:getCallSign(),stationFaction))
			end
		end
		ta:destroy()
		if #gossipSnippets > 0 and stationFaction == "Human Navy" and pStation ~= nil then
			if gp % 2 == 0 then
				ni = math.random(1,#gossipSnippets)
				pStation.gossip = gossipSnippets[ni]
				table.remove(gossipSnippets,ni)
			end
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	until(not neutralStationsRemain or not humanStationsRemain or not kraylorStationsRemain)
	if diagnostic then print(string.format("Human stations: %i, Kraylor stations: %i, Neutral stations: %i",#humanStationList,#kraylorStationList,#neutralStationList)) end
	if not diagnostic then
		placeRandomAroundPoint(Nebula,math.random(7,25),1,150000,0,0)
	end
end
function insertPlanet1()
	tSize = 15
	grid[gx][gy] = gp
	gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	end
	sri = math.random(1,#gRegion)
	bwx = (gRegion[sri][1] - (gbHigh/2))*gSize
	bwy = (gRegion[sri][2] - (gbHigh/2))*gSize
	planetBespin = Planet():setPosition(bwx,bwy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Bespin")
	planetBespin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription("Mining and Gambling")
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function insertPlanet2()
	tSize = 15
	grid[gx][gy] = gp
	gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	end
	sri = math.random(1,#gRegion)
	msx = (gRegion[sri][1] - (gbHigh/2))*gSize
	msy = (gRegion[sri][2] - (gbHigh/2))*gSize
	planetHel = Planet():setPosition(msx,msy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Helicon")
	planetHel:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	planetHel:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	planetHel:setAxialRotationTime(400.0):setDescription("M class planet")
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function insertBlackHole()
	tSize = 22
	grid[gx][gy] = gp
	gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	else
		if random(1,100) >= 35 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	bhx = (gRegion[sri][1] - (gbHigh/2))*gSize
	bhy = (gRegion[sri][2] - (gbHigh/2))*gSize
	BlackHole():setPosition(bhx,bhy)
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function placeInner()
	if stationFaction ~= "Human Navy" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Human Navy"				--set station faction
	if #placeStation > 0 then
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
	elseif #placeGenericStation > 0 then
		si = math.random(1,#placeGenericStation)	--station index
		pStation = placeGenericStation[si]()		--place selected station
		table.remove(placeGenericStation,si)		--remove station from placement list
	else
		humanStationsRemain = false
	end
	if humanStationsRemain then
		if sizeTemplate == "Huge Station" then
			humanStationStrength = humanStationStrength + 10
			pStation.strength = 10
		elseif sizeTemplate == "Large Station" then
			humanStationStrength = humanStationStrength + 5
			pStation.strength = 5
		elseif sizeTemplate == "Medium Station" then
			humanStationStrength = humanStationStrength + 3
			pStation.strength = 3
		else
			humanStationStrength = humanStationStrength + 1
			pStation.strength = 1
		end
		pStation:onDestruction(friendlyStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(humanStationList,pStation)		--save station in friendly station list
	end
end
function placeOuter()
	if stationFaction ~= "Kraylor" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Kraylor"
	if #placeEnemyStation > 0 then
		si = math.random(1,#placeEnemyStation)		--station index
		pStation = placeEnemyStation[si]()			--place selected station
		table.remove(placeEnemyStation,si)			--remove station from placement list
	elseif #placeGenericStation > 0 then
		si = math.random(1,#placeGenericStation)		--station index
		pStation = placeGenericStation[si]()		--place selected station
		table.remove(placeGenericStation,si)		--remove station from placement list
	else
		kraylorStationsRemain = false
	end
	if kraylorStationsRemain then
		if sizeTemplate == "Huge Station" then
			kraylorStationStrength = kraylorStationStrength + 10
			pStation.strength = 10
		elseif sizeTemplate == "Large Station" then
			kraylorStationStrength = kraylorStationStrength + 5
			pStation.strength = 5
		elseif sizeTemplate == "Medium Station" then
			kraylorStationStrength = kraylorStationStrength + 3
			pStation.strength = 3
		else
			kraylorStationStrength = kraylorStationStrength + 1
			pStation.strength = 1
		end
		pStation:onDestruction(enemyStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(kraylorStationList,pStation)	--save station in enemy station list
	end
end
function placeBorder()
	if stationFaction ~= "Independent" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Independent"				--set station faction
	if #placeStation > 0 then
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
	elseif #placeGenericStation > 0 then
		si = math.random(1,#placeGenericStation)	--station index
		pStation = placeGenericStation[si]()		--place selected station
		table.remove(placeGenericStation,si)		--remove station from placement list
	else
		neutralStationsRemain = false
	end
	if neutralStationsRemain then
		if sizeTemplate == "Huge Station" then
			pStation.strength = 10
			neutralStationStrength = neutralStationStrength + 10
		elseif sizeTemplate == "Large Station" then
			pStation.strength = 5
			neutralStationStrength = neutralStationStrength + 5
		elseif sizeTemplate == "Medium Station" then
			pStation.strength = 3
			neutralStationStrength = neutralStationStrength + 3
		else
			pStation.strength = 1
			neutralStationStrength = neutralStationStrength + 1
		end
		pStation:onDestruction(neutralStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(neutralStationList,pStation)	--save station in neutral station list
	end
end
--adjacent empty grid locations around the grid locations of the currently building faction
function getFactionAdjacentGridLocations(lx,ly)
	tempGrid = {}
	for i=gbLow,gbHigh do
		tempGrid[i] = {}
	end
	tempGrid[lx][ly] = 1
	ol = {}
	-- check left
	if lx-1 >= gbLow then
		if tempGrid[lx-1][ly] == nil then
			tempGrid[lx-1][ly] = 1
			if grid[lx-1][ly] == nil then
				table.insert(ol,{lx-1,ly})
			elseif grid[lx-1][ly] >= fb then
				--case 1: traveling left, skip right check
				getFactionAdjacentGridLocationsSkip(1,lx-1,ly)
			end
		end
	end
	--check up
	if ly-1 >= gbLow then
		if tempGrid[lx][ly-1] == nil then
			tempGrid[lx][ly-1] = 1
			if grid[lx][ly-1] == nil then
				table.insert(ol,{lx,ly-1})
			elseif grid[lx][ly-1] >= fb then		
				--case 2: traveling up, skip down check
				getFactionAdjacentGridLocationsSkip(2,lx,ly-1)
			end
		end
	end
	--check right
	if lx+1 <= gbHigh then
		if tempGrid[lx+1][ly] == nil then
			tempGrid[lx+1][ly] = 1
			if grid[lx+1][ly] == nil then
				table.insert(ol,{lx+1,ly})
			elseif grid[lx+1][ly] >= fb then
				--case 3: traveling right, skip left check
				getFactionAdjacentGridLocationsSkip(3,lx+1,ly)
			end
		end
	end
	--check down
	if ly+1 <= gbHigh then
		if tempGrid[lx][ly+1] == nil then
			tempGrid[lx][ly+1] = 1
			if grid[lx][ly+1] == nil then
				table.insert(ol,{lx,ly+1})
			elseif grid[lx][ly+1] >= fb then
				--case 4: traveling down, skip up check
				getFactionAdjacentGridLocationsSkip(4,lx,ly+1)
			end
		end
	end
	return ol
end
--adjacent empty grid locations around the grid locations of the currently building faction, skip check as requested
function getFactionAdjacentGridLocationsSkip(dSkip,lx,ly)
	tempGrid[lx][ly] = 1
	if dSkip ~= 3 then
		--check left
		if lx-1 >= gbLow then
			if tempGrid[lx-1][ly] == nil then
				tempGrid[lx-1][ly] = 1
				if grid[lx-1][ly] == nil then
					table.insert(ol,{lx-1,ly})
				elseif grid[lx-1][ly] >= fb then
					--case 1: traveling left, skip right check
					getFactionAdjacentGridLocationsSkip(1,lx-1,ly)
				end
			end
		end
	end
	if dSkip ~= 4 then
		--check up
		if ly-1 >= gbLow then
			if tempGrid[lx][ly-1] == nil then
				tempGrid[lx][ly-1] = 1
				if grid[lx][ly-1] == nil then
					table.insert(ol,{lx,ly-1})
				elseif grid[lx][ly-1] >= gp then
					--case 2: traveling up, skip down check
					getFactionAdjacentGridLocationsSkip(2,lx,ly-1)
				end
			end
		end
	end
	if dSkip ~= 1 then
		--check right
		if lx+1 <= gbHigh then
			if tempGrid[lx+1][ly] == nil then
				tempGrid[lx+1][ly] = 1
				if grid[lx+1][ly] == nil then
					table.insert(ol,{lx+1,ly})
				elseif grid[lx+1][ly] >= fb then
					--case 3: traveling right, skip left check
					getFactionAdjacentGridLocationsSkip(3,lx+1,ly)
				end
			end
		end
	end
	if dSkip ~= 2 then
		--check down
		if ly+1 <= gbHigh then
			if tempGrid[lx][ly+1] == nil then
				tempGrid[lx][ly+1] = 1
				if grid[lx][ly+1] == nil then
					table.insert(ol,{lx,ly+1})
				elseif grid[lx][ly+1] >= fb then
					--case 4: traveling down, skip up check
					getFactionAdjacentGridLocationsSkip(4,lx,ly+1)
				end
			end
		end
	end
end
--adjacent empty grid locations around all occupied locations
function getAllAdjacentGridLocations(lx,ly)
	tempGrid = {}
	for i=gbLow,gbHigh do
		tempGrid[i] = {}
	end
	tempGrid[lx][ly] = 1
	ol = {}
	-- check left
	if lx-1 >= gbLow then
		if tempGrid[lx-1][ly] == nil then
			tempGrid[lx-1][ly] = 1
			if grid[lx-1][ly] == nil then
				table.insert(ol,{lx-1,ly})
			else
				--case 1: traveling left, skip right check
				getAllAdjacentGridLocationsSkip(1,lx-1,ly)
			end
		end
	end
	--check up
	if ly-1 >= gbLow then
		if tempGrid[lx][ly-1] == nil then
			tempGrid[lx][ly-1] = 1
			if grid[lx][ly-1] == nil then
				table.insert(ol,{lx,ly-1})
			else		
				--case 2: traveling up, skip down check
				getAllAdjacentGridLocationsSkip(2,lx,ly-1)
			end
		end
	end
	--check right
	if lx+1 <= gbHigh then
		if tempGrid[lx+1][ly] == nil then
			tempGrid[lx+1][ly] = 1
			if grid[lx+1][ly] == nil then
				table.insert(ol,{lx+1,ly})
			else
				--case 3: traveling right, skip left check
				getAllAdjacentGridLocationsSkip(3,lx+1,ly)
			end
		end
	end
	--check down
	if ly+1 <= gbHigh then
		if tempGrid[lx][ly+1] == nil then
			tempGrid[lx][ly+1] = 1
			if grid[lx][ly+1] == nil then
				table.insert(ol,{lx,ly+1})
			else
				--case 4: traveling down, skip up check
				getAllAdjacentGridLocationsSkip(4,lx,ly+1)
			end
		end
	end
	return ol
end
--adjacent empty grid locations around all occupied locations, skip as requested
function getAllAdjacentGridLocationsSkip(dSkip,lx,ly)
	tempGrid[lx][ly] = 1
	if dSkip ~= 3 then
		--check left
		if lx-1 >= gbLow then
			if tempGrid[lx-1][ly] == nil then
				tempGrid[lx-1][ly] = 1
				if grid[lx-1][ly] == nil then
					table.insert(ol,{lx-1,ly})
				else
					--case 1: traveling left, skip right check
					getAllAdjacentGridLocationsSkip(1,lx-1,ly)
				end
			end
		end
	end
	if dSkip ~= 4 then
		--check up
		if ly-1 >= gbLow then
			if tempGrid[lx][ly-1] == nil then
				tempGrid[lx][ly-1] = 1
				if grid[lx][ly-1] == nil then
					table.insert(ol,{lx,ly-1})
				else
					--case 2: traveling up, skip down check
					getAllAdjacentGridLocationsSkip(2,lx,ly-1)
				end
			end
		end
	end
	if dSkip ~= 1 then
		--check right
		if lx+1 <= gbHigh then
			if tempGrid[lx+1][ly] == nil then
				tempGrid[lx+1][ly] = 1
				if grid[lx+1][ly] == nil then
					table.insert(ol,{lx+1,ly})
				else
					--case 3: traveling right, skip left check
					getAllAdjacentGridLocationsSkip(3,lx+1,ly)
				end
			end
		end
	end
	if dSkip ~= 2 then
		--check down
		if ly+1 <= gbHigh then
			if tempGrid[lx][ly+1] == nil then
				tempGrid[lx][ly+1] = 1
				if grid[lx][ly+1] == nil then
					table.insert(ol,{lx,ly+1})
				else
					--case 4: traveling down, skip up check
					getAllAdjacentGridLocationsSkip(4,lx,ly+1)
				end
			end
		end
	end
end
--adjacent empty grid locations around the most recently placed item
function getAdjacentGridLocations(lx,ly)
	tempGrid = {}
	for i=gbLow,gbHigh do
		tempGrid[i] = {}
	end
	tempGrid[lx][ly] = 1
	ol = {}
	-- check left
	if lx-1 >= gbLow then
		if tempGrid[lx-1][ly] == nil then
			tempGrid[lx-1][ly] = 1
			if grid[lx-1][ly] == nil then
				table.insert(ol,{lx-1,ly})
			elseif grid[lx-1][ly] == gp then
				--case 1: traveling left, skip right check
				getAdjacentGridLocationsSkip(1,lx-1,ly)
			end
		end
	end
	--check up
	if ly-1 >= gbLow then
		if tempGrid[lx][ly-1] == nil then
			tempGrid[lx][ly-1] = 1
			if grid[lx][ly-1] == nil then
				table.insert(ol,{lx,ly-1})
			elseif grid[lx][ly-1] == gp then		
				--case 2: traveling up, skip down check
				getAdjacentGridLocationsSkip(2,lx,ly-1)
			end
		end
	end
	--check right
	if lx+1 <= gbHigh then
		if tempGrid[lx+1][ly] == nil then
			tempGrid[lx+1][ly] = 1
			if grid[lx+1][ly] == nil then
				table.insert(ol,{lx+1,ly})
			elseif grid[lx+1][ly] == gp then
				--case 3: traveling right, skip left check
				getAdjacentGridLocationsSkip(3,lx+1,ly)
			end
		end
	end
	--check down
	if ly+1 <= gbHigh then
		if tempGrid[lx][ly+1] == nil then
			tempGrid[lx][ly+1] = 1
			if grid[lx][ly+1] == nil then
				table.insert(ol,{lx,ly+1})
			elseif grid[lx][ly+1] == gp then
				--case 4: traveling down, skip up check
				getAdjacentGridLocationsSkip(4,lx,ly+1)
			end
		end
	end
	return ol
end
--adjacent empty grid locations around the most recently placed item, skip as requested
function getAdjacentGridLocationsSkip(dSkip,lx,ly)
	tempGrid[lx][ly] = 1
	if dSkip ~= 3 then
		--check left
		if lx-1 >= gbLow then
			if tempGrid[lx-1][ly] == nil then
				tempGrid[lx-1][ly] = 1
				if grid[lx-1][ly] == nil then
					table.insert(ol,{lx-1,ly})
				elseif grid[lx-1][ly] == gp then
					--case 1: traveling left, skip right check
					getAdjacentGridLocationsSkip(1,lx-1,ly)
				end
			end
		end
	end
	if dSkip ~= 4 then
		--check up
		if ly-1 >= gbLow then
			if tempGrid[lx][ly-1] == nil then
				tempGrid[lx][ly-1] = 1
				if grid[lx][ly-1] == nil then
					table.insert(ol,{lx,ly-1})
				elseif grid[lx][ly-1] == gp then
					--case 2: traveling up, skip down check
					getAdjacentGridLocationsSkip(2,lx,ly-1)
				end
			end
		end
	end
	if dSkip ~= 1 then
		--check right
		if lx+1 <= gbHigh then
			if tempGrid[lx+1][ly] == nil then
				tempGrid[lx+1][ly] = 1
				if grid[lx+1][ly] == nil then
					table.insert(ol,{lx+1,ly})
				elseif grid[lx+1][ly] == gp then
					--case 3: traveling right, skip left check
					getAdjacentGridLocationsSkip(3,lx+1,ly)
				end
			end
		end
	end
	if dSkip ~= 2 then
		--check down
		if ly+1 <= gbHigh then
			if tempGrid[lx][ly+1] == nil then
				tempGrid[lx][ly+1] = 1
				if grid[lx][ly+1] == nil then
					table.insert(ol,{lx,ly+1})
				elseif grid[lx][ly+1] == gp then
					--case 4: traveling down, skip up check
					getAdjacentGridLocationsSkip(4,lx,ly+1)
				end
			end
		end
	end
end
--Randomly choose station size template
function szt()
	stationSizeRandom = random(1,100)
	if stationSizeRandom <= 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom <= 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom <= 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end
--[[-------------------------------------------------------------------
	Human and neutral stations to be placed (all need some kind of goods)
--]]-------------------------------------------------------------------
function placeAlcaleica()
	--Alcaleica
	stationAlcaleica = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAlcaleica:setPosition(psx,psy):setCallSign("Alcaleica"):setDescription("Optical Components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationAlcaleica] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",5,66}}
		else
			goods[stationAlcaleica] = {{"food",math.random(5,10),1},{"optic",5,66}}
			tradeMedicine[stationAlcaleica] = true
		end
	else
		goods[stationAlcaleica] = {{"optic",5,66}}
		tradeFood[stationAlcaleica] = true
		tradeMedicine[stationAlcaleica] = true
	end
	stationAlcaleica.publicRelations = true
	stationAlcaleica.generalInformation = "We make and supply optic components for various station and ship systems"
	stationAlcaleica.stationHistory = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon electronic and optic company"
	return stationAlcaleica
end
function placeAnderson()
	--Anderson 
	stationAnderson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(psx,psy):setCallSign("Anderson"):setDescription("Battery and software engineering")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationAnderson] = {{"food",math.random(5,10),1},{"medicine",5,5},{"battery",5,65},{"software",5,115}}
		else
			goods[stationAnderson] = {{"food",math.random(5,10),1},{"battery",5,65},{"software",5,115}}
		end
	else
		goods[stationAnderson] = {{"battery",5,65},{"software",5,115}}
	end
	tradeLuxury[stationAnderson] = true
	stationAnderson.publicRelations = true
	stationAnderson.generalInformation = "We provide high quality high capacity batteries and specialized software for all shipboard systems"
	stationAnderson.stationHistory = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"
	return stationAnderson
end
function placeArcher()
	--Archer 
	stationArcher = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArcher:setPosition(psx,psy):setCallSign("Archer"):setDescription("Shield and Armor Research")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationArcher] = {{"food",math.random(5,10),1},{"medicine",5,5},{"shield",5,90}}
		else
			goods[stationArcher] = {{"food",math.random(5,10),1},{"shield",5,90}}
			tradeMedicine[stationArcher] = true
		end
	else
		goods[stationArcher] = {{"shield",5,90}}
		tradeMedicine[stationArcher] = true
	end
	tradeLuxury[stationArcher] = true
	stationArcher.publicRelations = true
	stationArcher.generalInformation = "The finest shield and armor manufacturer in the quadrant"
	stationArcher.stationHistory = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	return stationArcher
end
function placeArchimedes()
	--Archimedes
	stationArchimedes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArchimedes:setPosition(psx,psy):setCallSign("Archimedes"):setDescription("Energy and particle beam components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationArchimedes] = {{"food",math.random(5,10),1},{"medicine",5,5},{"beam",5,80}}
		else
			goods[stationArchimedes] = {{"food",math.random(5,10),1},{"beam",5,80}}
			tradeMedicine[stationArchimedes] = true
		end
	else
		goods[stationArchimedes] = {{"beam",5,80}}
		tradeFood[stationArchimedes] = true
	end
	tradeLuxury[stationArchimedes] = true
	stationArchimedes.publicRelations = true
	stationArchimedes.generalInformation = "We fabricate general and specialized components for ship beam systems"
	stationArchimedes.stationHistory = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it"
	return stationArchimedes
end
function placeArmstrong()
	--Armstrong
	stationArmstrong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArmstrong:setPosition(psx,psy):setCallSign("Armstrong"):setDescription("Warp and Impulse engine manufacturing")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationArmstrong] = {{"food",math.random(5,10),1},{"medicine",5,5},{"repulsor",5,62}}
		else
			goods[stationArmstrong] = {{"food",math.random(5,10),1},{"repulsor",5,62}}
		end
	else
		goods[stationArmstrong] = {{"repulsor",5,62}}
	end
--	table.insert(goods[stationArmstrong],{"warp",5,77})
	stationArmstrong.publicRelations = true
	stationArmstrong.generalInformation = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis"
	stationArmstrong.stationHistory = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."
	return stationArmstrong
end
function placeAsimov()
	--Asimov
	stationAsimov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAsimov:setCallSign("Asimov"):setDescription("Training and Coordination"):setPosition(psx,psy)
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationAsimov] = {{"food",math.random(5,10),1},{"medicine",5,5},{"tractor",5,48}}
		else
			goods[stationAsimov] = {{"food",math.random(5,10),1},{"tractor",5,48}}		
		end
	else
		goods[stationAsimov] = {{"tractor",5,48}}
	end
	stationAsimov.publicRelations = true
	stationAsimov.generalInformation = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector"
	stationAsimov.stationHistory = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"
	return stationAsimov
end
function placeBarclay()
	--Barclay
	stationBarclay = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(psx,psy):setCallSign("Barclay"):setDescription("Communication components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationBarclay] = {{"food",math.random(5,10),1},{"medicine",5,5},{"communication",5,58}}
		else
			goods[stationBarclay] = {{"food",math.random(5,10),1},{"communication",5,58}}
			tradeMedicine[stationBarclay] = true
		end
	else
		goods[stationBarclay] = {{"communication",5,58}}
		tradeMedicine[stationBarclay] = true
	end
	stationBarclay.publicRelations = true
	stationBarclay.generalInformation = "We provide a range of communication equipment and software for use aboard ships"
	stationBarclay.stationHistory = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"
	return stationBarclay
end
function placeBethesda()
	--Bethesda 
	stationBethesda = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBethesda:setPosition(psx,psy):setCallSign("Bethesda"):setDescription("Medical research")
	goods[stationBethesda] = {{"food",math.random(5,10),1},{"medicine",5,5},{"autodoc",5,36}}
	stationBethesda.publicRelations = true
	stationBethesda.generalInformation = "We research and treat exotic medical conditions"
	stationBethesda.stationHistory = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century"
	return stationBethesda
end
function placeBroeck()
	--Broeck
	stationBroeck = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBroeck:setPosition(psx,psy):setCallSign("Broeck"):setDescription("Warp drive components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationBroeck] = {{"food",math.random(5,10),1},{"medicine",5,5},{"warp",5,130}}
			if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
		else
			goods[stationBroeck] = {{"food",math.random(5,10),1},{"warp",5,130}}		
			if random(1,100) < 53 then tradeMedicine[stationBroeck] = true end
			if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
		end
	else
		goods[stationBroeck] = {{"warp",5,130}}
		if random(1,100) < 53 then tradeMedicine[stationBroeck] = true end
		if random(1,100) < 14 then tradeFood[stationBroeck] = true end
		if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
	end
	stationBroeck.publicRelations = true
	stationBroeck.generalInformation = "We provide warp drive engines and components"
	stationBroeck.stationHistory = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"
	return stationBroeck
end
function placeCalifornia()
	--California
	stationCalifornia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalifornia:setPosition(psx,psy):setCallSign("California"):setDescription("Mining station")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationCalifornia] = {{"food",math.random(5,10),1},{"medicine",5,5},{"gold",5,25},{"dilithium",2,25}}
		else
			goods[stationCalifornia] = {{"food",math.random(5,10),1},{"gold",5,25},{"dilithium",2,25}}		
		end
	else
		goods[stationCalifornia] = {{"gold",5,25},{"dilithium",2,25}}
	end
	return stationCalifornia
end
function placeCalvin()
	--Calvin 
	stationCalvin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(psx,psy):setCallSign("Calvin"):setDescription("Robotic research")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationCalvin] = {{"food",math.random(5,10),1},{"medicine",5,5},{"robotic",5,87}}
		else
			goods[stationCalvin] = {{"food",math.random(5,10),1},{"robotic",5,87}}		
		end
	else
		goods[stationCalvin] = {{"robotic",5,87}}
		if random(1,100) < 8 then tradeFood[stationCalvin] = true end
	end
	tradeLuxury[stationCalvin] = true
	stationCalvin.publicRelations = true
	stationCalvin.generalInformation = "We research and provide robotic systems and components"
	stationCalvin.stationHistory = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"
	return stationCalvin
end
function placeCavor()
	--Cavor 
	stationCavor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCavor:setPosition(psx,psy):setCallSign("Cavor"):setDescription("Advanced Material components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationCavor] = {{"food",math.random(5,10),1},{"medicine",5,5},{"filament",5,42}}
			if random(1,100) < 33 then tradeLuxury[stationCavor] = true end
		else
			goods[stationCavor] = {{"food",math.random(5,10),1},{"filament",5,42}}	
			if random(1,100) < 50 then
				tradeMedicine[stationCavor] = true
			else
				tradeLuxury[stationCavor] = true
			end
		end
	else
		goods[stationCavor] = {{"filament",5,42}}
		whatTrade = random(1,100)
		if whatTrade < 33 then
			tradeMedicine[stationCavor] = true
		elseif whatTrade > 66 then
			tradeFood[stationCavor] = true
		else
			tradeLuxury[stationCavor] = true
		end
	end
	stationCavor.publicRelations = true
	stationCavor.generalInformation = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction"
	stationCavor.stationHistory = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"
	return stationCavor
end
function placeChatuchak()
	--Chatuchak
	stationChatuchak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationChatuchak:setPosition(psx,psy):setCallSign("Chatuchak"):setDescription("Trading station")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationChatuchak] = {{"food",math.random(5,10),1},{"medicine",5,5},{"luxury",5,60}}
		else
			goods[stationChatuchak] = {{"food",math.random(5,10),1},{"luxury",5,60}}		
		end
	else
		goods[stationChatuchak] = {{"luxury",5,60}}		
	end
	stationChatuchak.publicRelations = true
	stationChatuchak.generalInformation = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here"
	stationChatuchak.stationHistory = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"
	return stationChatuchak
end
function placeCoulomb()
	--Coulomb
	stationCoulomb = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCoulomb:setPosition(psx,psy):setCallSign("Coulomb"):setDescription("Shielded circuitry fabrication")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationCoulomb] = {{"food",math.random(5,10),1},{"medicine",5,5},{"circuit",5,50}}
		else
			goods[stationCoulomb] = {{"food",math.random(5,10),1},{"circuit",5,50}}		
			if random(1,100) < 27 then tradeMedicine[stationCoulomb] = true end
		end
	else
		goods[stationCoulomb] = {{"circuit",5,50}}		
		if random(1,100) < 27 then tradeMedicine[stationCoulomb] = true end
		if random(1,100) < 16 then tradeFood[stationCoulomb] = true end
	end
	if random(1,100) < 82 then tradeLuxury[stationCoulomb] = true end
	stationCoulomb.publicRelations = true
	stationCoulomb.generalInformation = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference"
	stationCoulomb.stationHistory = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"
	return stationCoulomb
end
function placeCyrus()
	--Cyrus
	stationCyrus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCyrus:setPosition(psx,psy):setCallSign("Cyrus"):setDescription("Impulse engine components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationCyrus] = {{"food",math.random(5,10),1},{"medicine",5,5},{"impulse",5,124}}
		else
			goods[stationCyrus] = {{"food",math.random(5,10),1},{"impulse",5,124}}		
			if random(1,100) < 34 then tradeMedicine[stationCyrus] = true end
		end
	else
		goods[stationCyrus] = {{"impulse",5,124}}		
		if random(1,100) < 34 then tradeMedicine[stationCyrus] = true end
		if random(1,100) < 13 then tradeFood[stationCyrus] = true end
	end
	if random(1,100) < 78 then tradeLuxury[stationCyrus] = true end
	stationCyrus.publicRelations = true
	stationCyrus.generalInformation = "We supply high quality impulse engines and parts for use aboard ships"
	stationCyrus.stationHistory = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"
	return stationCyrus
end
function placeDeckard()
	--Deckard
	stationDeckard = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeckard:setPosition(psx,psy):setCallSign("Deckard"):setDescription("Android components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationDeckard] = {{"food",math.random(5,10),1},{"medicine",5,5},{"android",5,73}}
		else
			goods[stationDeckard] = {{"food",math.random(5,10),1},{"android",5,73}}		
		end
	else
		goods[stationDeckard] = {{"android",5,73}}		
		tradeFood[stationDeckard] = true
	end
	tradeLuxury[stationDeckard] = true
	stationDeckard.publicRelations = true
	stationDeckard.generalInformation = "Supplier of android components, programming and service"
	stationDeckard.stationHistory = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"
	return stationDeckard
end
function placeDeer()
	--Deer
	stationDeer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeer:setPosition(psx,psy):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationDeer] = {{"food",math.random(5,10),1},{"medicine",5,5},{"tractor",5,90},{"repulsor",5,95}}
		else
			goods[stationDeer] = {{"food",math.random(5,10),1},{"tractor",5,90},{"repulsor",5,95}}		
			tradeMedicine[stationDeer] = true
		end
	else
		goods[stationDeer] = {{"tractor",5,90},{"repulsor",5,95}}		
		tradeFood[stationDeer] = true
		tradeMedicine[stationDeer] = true
	end
	tradeLuxury[stationDeer] = true
	stationDeer.publicRelations = true
	stationDeer.generalInformation = "We can meet all your pushing and pulling needs with specialized equipment custom made"
	stationDeer.stationHistory = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"
	return stationDeer
end
function placeErickson()
	--Erickson
	stationErickson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationErickson:setPosition(psx,psy):setCallSign("Erickson"):setDescription("Transporter components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationErickson] = {{"food",math.random(5,10),1},{"medicine",5,5},{"transporter",5,63}}
		else
			goods[stationErickson] = {{"food",math.random(5,10),1},{"transporter",5,63}}		
			tradeMedicine[stationErickson] = true 
		end
	else
		goods[stationErickson] = {{"transporter",5,63}}		
		tradeFood[stationErickson] = true
		tradeMedicine[stationErickson] = true 
	end
	tradeLuxury[stationErickson] = true 
	stationErickson.publicRelations = true
	stationErickson.generalInformation = "We provide transporters used aboard ships as well as the components for repair and maintenance"
	stationErickson.stationHistory = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy"
	return stationErickson
end
function placeEvondos()
	--Evondos
	stationEvondos = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationEvondos:setPosition(psx,psy):setCallSign("Evondos"):setDescription("Autodoc components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationEvondos] = {{"food",math.random(5,10),1},{"medicine",5,5},{"autodoc",5,56}}
		else
			goods[stationEvondos] = {{"food",math.random(5,10),1},{"autodoc",5,56}}		
			tradeMedicine[stationEvondos] = true 
		end
	else
		goods[stationEvondos] = {{"autodoc",5,56}}		
		tradeMedicine[stationEvondos] = true 
	end
	if random(1,100) < 41 then tradeLuxury[stationEvondos] = true end
	stationEvondos.publicRelations = true
	stationEvondos.generalInformation = "We provide components for automated medical machinery"
	stationEvondos.stationHistory = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland"
	return stationEvondos
end
function placeFeynman()
	--Feynman 
	stationFeynman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationFeynman:setPosition(psx,psy):setCallSign("Feynman"):setDescription("Nanotechnology research")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationFeynman] = {{"food",math.random(5,10),1},{"medicine",5,5},{"nanites",5,79},{"software",5,115}}
		else
			goods[stationFeynman] = {{"food",math.random(5,10),1},{"nanites",5,79},{"software",5,115}}		
		end
	else
		goods[stationFeynman] = {{"nanites",5,79},{"software",5,115}}		
		tradeFood[stationFeynman] = true
		if random(1,100) < 26 then tradeFood[stationFeynman] = true end
	end
	tradeLuxury[stationFeynman] = true
	stationFeynman.publicRelations = true
	stationFeynman.generalInformation = "We provide nanites and software for a variety of ship-board systems"
	stationFeynman.stationHistory = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"
	return stationFeynman
end
function placeGrasberg()
	--Grasberg
	placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	stationGrasberg = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationGrasberg:setPosition(psx,psy):setCallSign("Grasberg"):setDescription("Mining")
	stationGrasberg.publicRelations = true
	stationGrasberg.generalInformation = "We mine nearby asteroids for precious minerals and process them for sale"
	stationGrasberg.stationHistory = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids"
	grasbergGoods = random(1,100)
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			if grasbergGoods < 20 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif grasbergGoods < 40 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif grasbergGoods < 60 then
				goods[stationGrasberg] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationGrasberg] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if grasbergGoods < 20 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif grasbergGoods < 40 then
				goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif grasbergGoods < 60 then
				goods[stationGrasberg] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationGrasberg] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
		end
	else
		if grasbergGoods < 20 then
			goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif grasbergGoods < 40 then
			goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25}}
		elseif grasbergGoods < 60 then
			goods[stationGrasberg] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationGrasberg] = {{"luxury",5,70}}
		end
		tradeFood[stationGrasberg] = true
	end
	return stationGrasberg
end
function placeHayden()
	--Hayden
	stationHayden = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHayden:setPosition(psx,psy):setCallSign("Hayden"):setDescription("Observatory and stellar mapping")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationHayden] = {{"food",math.random(5,10),1},{"medicine",5,5},{"nanites",5,65}}
		else
			goods[stationHayden] = {{"food",math.random(5,10),1},{"nanites",5,65}}		
		end
	else
		goods[stationHayden] = {{"nanites",5,65}}		
	end
	stationHayden.publicRelations = true
	stationHayden.generalInformation = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding"
	return stationHayden
end
function placeHeyes()
	--Heyes
	stationHeyes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHeyes:setPosition(psx,psy):setCallSign("Heyes"):setDescription("Sensor components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationHeyes] = {{"food",math.random(5,10),1},{"medicine",5,5},{"sensor",5,72}}
		else
			goods[stationHeyes] = {{"food",math.random(5,10),1},{"sensor",5,72}}		
		end
	else
		goods[stationHeyes] = {{"sensor",5,72}}		
	end
	tradeLuxury[stationHeyes] = true 
	stationHeyes.publicRelations = true
	stationHeyes.generalInformation = "We research and manufacture sensor components and systems"
	stationHeyes.stationHistory = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility"
	return stationHeyes
end
function placeHossam()
	--Hossam
	stationHossam = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHossam:setPosition(psx,psy):setCallSign("Hossam"):setDescription("Nanite supplier")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationHossam] = {{"food",math.random(5,10),1},{"medicine",5,5},{"nanites",5,48}}
		else
			goods[stationHossam] = {{"food",math.random(5,10),1},{"nanites",5,48}}		
			if random(1,100) < 44 then tradeMedicine[stationHossam] = true end
		end
	else
		goods[stationHossam] = {{"nanites",5,48}}		
		if random(1,100) < 44 then tradeMedicine[stationHossam] = true end
		if random(1,100) < 24 then tradeFood[stationHossam] = true end
	end
	if random(1,100) < 63 then tradeLuxury[stationHossam] = true end
	stationHossam.publicRelations = true
	stationHossam.generalInformation = "We provide nanites for various organic and non-organic systems"
	stationHossam.stationHistory = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel"
	return stationHossam
end
function placeImpala()
	--Impala
	placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	stationImpala = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationImpala:setPosition(psx,psy):setCallSign("Impala"):setDescription("Mining")
	tradeFood[stationImpala] = true
	tradeLuxury[stationImpala] = true
	stationImpala.publicRelations = true
	stationImpala.generalInformation = "We mine nearby asteroids for precious minerals"
	impalaGoods = random(1,100)
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			if impalaGoods < 20 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif impalaGoods < 40 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif impalaGoods < 60 then
				goods[stationImpala] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationImpala] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if impalaGoods < 20 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif impalaGoods < 40 then
				goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif impalaGoods < 60 then
				goods[stationImpala] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationImpala] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
		end
	else
		if impalaGoods < 20 then
			goods[stationImpala] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif impalaGoods < 40 then
			goods[stationImpala] = {{"luxury",5,70},{"gold",5,25}}
		elseif impalaGoods < 60 then
			goods[stationImpala] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationImpala] = {{"luxury",5,70}}
		end
		tradeFood[stationImpala] = true
	end
	return stationImpala
end
function placeKomov()
	--Komov
	stationKomov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKomov:setPosition(psx,psy):setCallSign("Komov"):setDescription("Xenopsychology training")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationKomov] = {{"food",math.random(5,10),1},{"medicine",5,5},{"filament",5,46}}
		else
			goods[stationKomov] = {{"food",math.random(5,10),1},{"filament",5,46}}
			if random(1,100) < 44 then tradeMedicine[stationKomov] = true end
		end
	else
		goods[stationKomov] = {{"filament",5,46}}		
		if random(1,100) < 44 then tradeMedicine[stationKomov] = true end
		if random(1,100) < 24 then tradeFood[stationKomov] = true end
	end
	stationKomov.publicRelations = true
	stationKomov.generalInformation = "We provide classes and simulation to help train diverse species in how to relate to each other"
	stationKomov.stationHistory = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"
	return stationKomov
end
function placeKrak()
	--Krak
	stationKrak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrak:setPosition(psx,psy):setCallSign("Krak"):setDescription("Mining station")
	posAxisKrak = random(0,360)
	posKrak = random(10000,60000)
	negKrak = random(10000,60000)
	spreadKrak = random(4000,7000)
	negAxisKrak = posAxisKrak + 180
	xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
	posKrakEnd = random(30,70)
	createRandomAlongArc(Asteroid, 30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
	xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
	negKrakEnd = random(40,80)
	createRandomAlongArc(Asteroid, 30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	if random(1,100) < 50 then tradeFood[stationKrak] = true end
	if random(1,100) < 50 then tradeLuxury[stationKrak] = true end
	krakGoods = random(1,100)
	if krakGoods < 10 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krakGoods < 20 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50}}
	elseif krakGoods < 30 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70},{"dilithium",5,50}}
	elseif krakGoods < 40 then
		goods[stationKrak] = {{"nickel",5,20},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krakGoods < 50 then
		goods[stationKrak] = {{"nickel",5,20},{"dilithium",5,50}}
	elseif krakGoods < 60 then
		goods[stationKrak] = {{"nickel",5,20},{"platinum",5,70}}
	elseif krakGoods < 70 then
		goods[stationKrak] = {{"nickel",5,20},{"tritanium",5,50}}
	elseif krakGoods < 80 then
		goods[stationKrak] = {{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	else
		goods[stationKrak] = {{"nickel",5,20}}
	end
	tradeMedicine[stationKrak] = true
	return stationKrak
end
function placeKruk()
	--Kruk
	stationKruk = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKruk:setPosition(psx,psy):setCallSign("Kruk"):setDescription("Mining station")
	posAxisKruk = random(0,360)
	posKruk = random(10000,60000)
	negKruk = random(10000,60000)
	spreadKruk = random(4000,7000)
	negAxisKruk = posAxisKruk + 180
	xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
	posKrukEnd = random(30,70)
	createRandomAlongArc(Asteroid, 30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
	xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
	negKrukEnd = random(40,80)
	createRandomAlongArc(Asteroid, 30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
	krukGoods = random(1,100)
	if krukGoods < 10 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krukGoods < 20 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50}}
	elseif krukGoods < 30 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70},{"dilithium",5,50}}
	elseif krukGoods < 40 then
		goods[stationKruk] = {{"nickel",5,20},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krukGoods < 50 then
		goods[stationKruk] = {{"nickel",5,20},{"dilithium",5,50}}
	elseif krukGoods < 60 then
		goods[stationKruk] = {{"nickel",5,20},{"platinum",5,70}}
	elseif krukGoods < 70 then
		goods[stationKruk] = {{"nickel",5,20},{"tritanium",5,50}}
	elseif krukGoods < 80 then
		goods[stationKruk] = {{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	else
		goods[stationKruk] = {{"nickel",5,20}}
	end
	tradeLuxury[stationKruk] = true
	if random(1,100) < 50 then tradeFood[stationKruk] = true end
	if random(1,100) < 50 then tradeMedicine[stationKruk] = true end
	return stationKruk
end
function placeLipkin()
	--Lipkin
	stationLipkin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(psx,psy):setCallSign("Lipkin"):setDescription("Autodoc components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationLipkin] = {{"food",math.random(5,10),1},{"medicine",5,5},{"autodoc",5,76}}
		else
			goods[stationLipkin] = {{"food",math.random(5,10),1},{"autodoc",5,76}}		
		end
	else
		goods[stationLipkin] = {{"autodoc",5,76}}		
		tradeFood[stationLipkin] = true 
	end
	tradeLuxury[stationLipkin] = true 
	stationLipkin.publicRelations = true
	stationLipkin.generalInformation = "We build and repair and provide components and upgrades for automated facilities designed for ships where a doctor cannot be a crew member (commonly called autodocs)"
	stationLipkin.stationHistory = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"
	return stationLipkin
end
function placeMadison()
	--Madison
	stationMadison = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMadison:setPosition(psx,psy):setCallSign("Madison"):setDescription("Zero gravity sports and entertainment")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationMadison] = {{"food",math.random(5,10),1},{"medicine",5,5},{"luxury",5,70}}
		else
			goods[stationMadison] = {{"food",math.random(5,10),1},{"luxury",5,70}}		
			tradeMedicine[stationMadison] = true 
		end
	else
		goods[stationMadison] = {{"luxury",5,70}}		
		tradeMedicine[stationMadison] = true 
	end
	stationMadison.publicRelations = true
	stationMadison.generalInformation = "Come take in a game or two or perhaps see a show"
	stationMadison.stationHistory = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"
	return stationMadison
end
function placeMaiman()
	--Maiman
	stationMaiman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaiman:setPosition(psx,psy):setCallSign("Maiman"):setDescription("Energy beam components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationMaiman] = {{"food",math.random(5,10),1},{"medicine",5,5},{"beam",5,70}}
		else
			goods[stationMaiman] = {{"food",math.random(5,10),1},{"beam",5,70}}		
			tradeMedicine[stationMaiman] = true 
		end
	else
		goods[stationMaiman] = {{"beam",5,70}}		
		tradeMedicine[stationMaiman] = true 
	end
	stationMaiman.publicRelations = true
	stationMaiman.generalInformation = "We research and manufacture energy beam components and systems"
	stationMaiman.stationHistory = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th centuryon Earth"
	return stationMaiman
end
function placeMarconi()
	--Marconi 
	stationMarconi = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMarconi:setPosition(psx,psy):setCallSign("Marconi"):setDescription("Energy Beam Components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationMarconi] = {{"food",math.random(5,10),1},{"medicine",5,5},{"beam",5,80}}
		else
			goods[stationMarconi] = {{"food",math.random(5,10),1},{"beam",5,80}}		
			tradeMedicine[stationMarconi] = true 
		end
	else
		goods[stationMarconi] = {{"beam",5,80}}		
		tradeMedicine[stationMarconi] = true 
		tradeFood[stationMarconi] = true
	end
	tradeLuxury[stationMarconi] = true
	stationMarconi.publicRelations = true
	stationMarconi.generalInformation = "We manufacture energy beam components"
	stationMarconi.stationHistory = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"
	return stationMarconi
end
function placeMayo()
	--Mayo
	stationMayo = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMayo:setPosition(psx,psy):setCallSign("Mayo"):setDescription("Medical Research")
	goods[stationMayo] = {{"food",5,1},{"medicine",5,5},{"autodoc",5,128}}
	stationMayo.publicRelations = true
	stationMayo.generalInformation = "We research exotic diseases and other human medical conditions"
	stationMayo.stationHistory = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"
	return stationMayo
end
function placeMiller()
	--Miller
	stationMiller = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMiller:setPosition(psx,psy):setCallSign("Miller"):setDescription("Exobiology research")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationMiller] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",10,60}}
		else
			goods[stationMiller] = {{"food",math.random(5,10),1},{"optic",10,60}}		
		end
	else
		goods[stationMiller] = {{"optic",10,60}}		
	end
	stationMiller.publicRelations = true
	stationMiller.generalInformation = "We study recently discovered life forms not native to Earth"
	stationMiller.stationHistory = "This station was named after one the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"
	return stationMiller
end
function placeMuddville()
	--Muddville 
	stationMudd = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMudd:setPosition(psx,psy):setCallSign("Muddville"):setDescription("Trading station")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationMudd] = {{"food",math.random(5,10),1},{"medicine",5,5},{"luxury",10,60}}
		else
			goods[stationMudd] = {{"food",math.random(5,10),1},{"luxury",10,60}}		
		end
	else
		goods[stationMudd] = {{"luxury",10,60}}		
	end
	stationMudd.publicRelations = true
	stationMudd.generalInformation = "Come to Muddvile for all your trade and commerce needs and desires"
	stationMudd.stationHistory = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"
	return stationMudd
end
function placeNexus6()
	--Nexus-6
	stationNexus6 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNexus6:setPosition(psx,psy):setCallSign("Nexus-6"):setDescription("Android components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationNexus6] = {{"food",math.random(5,10),1},{"medicine",5,5},{"android",5,93}}
		else
			goods[stationNexus6] = {{"food",math.random(5,10),1},{"android",5,93}}		
			tradeMedicine[stationNexus6] = true 
		end
	else
		goods[stationNexus6] = {{"android",5,93}}		
		tradeMedicine[stationNexus6] = true 
	end
	stationNexus6.publicRelations = true
	stationNexus6.generalInformation = "We research and manufacture android components and systems. Our design our androids to maximize their likeness to humans"
	stationNexus6.stationHistory = "The station is named after the ground breaking model of android produced by the Tyrell corporation"
	return stationNexus6
end
function placeOBrien()
	--O'Brien
	stationOBrien = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOBrien:setPosition(psx,psy):setCallSign("O'Brien"):setDescription("Transporter components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationOBrien] = {{"food",math.random(5,10),1},{"medicine",5,5},{"transporter",5,76}}
		else
			goods[stationOBrien] = {{"food",math.random(5,10),1},{"transporter",5,76}}		
			if random(1,100) < 34 then tradeMedicine[stationOBrien] = true end
		end
	else
		goods[stationOBrien] = {{"transporter",5,76}}		
		tradeMedicine[stationOBrien] = true 
		if random(1,100) < 13 then tradeFood[stationOBrien] = true end
		if random(1,100) < 34 then tradeMedicine[stationOBrien] = true end
	end
	if random(1,100) < 43 then tradeLuxury[stationOBrien] = true end
	stationOBrien.publicRelations = true
	stationOBrien.generalInformation = "We research and fabricate high quality transporters and transporter components for use aboard ships"
	stationOBrien.stationHistory = "Miles O'Brien started this business after his experience as a transporter chief"
	return stationOBrien
end
function placeOlympus()
	--Olympus
	stationOlympus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOlympus:setPosition(psx,psy):setCallSign("Olympus"):setDescription("Optical components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationOlympus] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",5,66}}
		else
			goods[stationOlympus] = {{"food",math.random(5,10),1},{"optic",5,66}}		
			tradeMedicine[stationOlympus] = true
		end
	else
		goods[stationOlympus] = {{"optic",5,66}}		
		tradeFood[stationOlympus] = true
		tradeMedicine[stationOlympus] = true
	end
	stationOlympus.publicRelations = true
	stationOlympus.generalInformation = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components"
	stationOlympus.stationHistory = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"
	return stationOlympus
end
function placeOrgana()
	--Organa
	stationOrgana = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOrgana:setPosition(psx,psy):setCallSign("Organa"):setDescription("Diplomatic training")
	goods[stationOrgana] = {{"luxury",5,96}}		
	stationOrgana.publicRelations = true
	stationOrgana.generalInformation = "The premeire academy for leadership and diplomacy training in the region"
	stationOrgana.stationHistory = "Established by the royal family so critical during the political upheaval era"
	return stationOrgana
end
function placeOutpost15()
	--Outpost 15
	stationOutpost15 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost15:setPosition(psx,psy):setCallSign("Outpost-15"):setDescription("Mining and trade")
	tradeFood[stationOutpost15] = true
	outpost15Goods = random(1,100)
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			if outpost15Goods < 20 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost15Goods < 40 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost15Goods < 60 then
				goods[stationOutpost15] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationOutpost15] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if outpost15Goods < 20 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif outpost15Goods < 40 then
				goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif outpost15Goods < 60 then
				goods[stationOutpost15] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationOutpost15] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
		end
	else
		if outpost15Goods < 20 then
			goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif outpost15Goods < 40 then
			goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25}}
		elseif outpost15Goods < 60 then
			goods[stationOutpost15] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationOutpost15] = {{"luxury",5,70}}
		end
		tradeFood[stationOutpost15] = true
	end
	placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	return stationOutpost15
end
function placeOutpost21()
	--Outpost 21
	stationOutpost21 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost21:setPosition(psx,psy):setCallSign("Outpost-21"):setDescription("Mining and gambling")
	placeRandomAroundPoint(Asteroid,15,1,15000,psx,psy)
	outpost21Goods = random(1,100)
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			if outpost21Goods < 20 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost21Goods < 40 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1},{"medicine",5,5}}
			elseif outpost21Goods < 60 then
				goods[stationOutpost21] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1},{"medicine",5,5}}
			else
				goods[stationOutpost21] = {{"luxury",5,70},{"food",math.random(5,10),1},{"medicine",5,5}}
			end
		else
			if outpost21Goods < 20 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50},{"food",math.random(5,10),1}}
			elseif outpost21Goods < 40 then
				goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"food",math.random(5,10),1}}
			elseif outpost21Goods < 60 then
				goods[stationOutpost21] = {{"luxury",5,70},{"cobalt",4,50},{"food",math.random(5,10),1}}
			else
				goods[stationOutpost21] = {{"luxury",5,70},{"food",math.random(5,10),1}}
			end
			if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
		end
	else
		if outpost21Goods < 20 then
			goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25},{"cobalt",4,50}}
		elseif outpost21Goods < 40 then
			goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25}}
		elseif outpost21Goods < 60 then
			goods[stationOutpost21] = {{"luxury",5,70},{"cobalt",4,50}}
		else
			goods[stationOutpost21] = {{"luxury",5,70}}
		end
		tradeFood[stationOutpost21] = true
		if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
	end
	tradeLuxury[stationOutpost21] = true
	return stationOutpost21
end
function placeOwen()
	--Owen
	stationOwen = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOwen:setPosition(psx,psy):setCallSign("Owen"):setDescription("Load lifters and components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationOwen] = {{"food",math.random(5,10),1},{"medicine",5,5},{"lifter",5,61}}
		else
			goods[stationOwen] = {{"food",math.random(5,10),1},{"lifter",5,61}}		
		end
	else
		goods[stationOwen] = {{"lifter",5,61}}		
		tradeFood[stationOwen] = true 
	end
	tradeLuxury[stationOwen] = true 
	stationOwen.publicRelations = true
	stationOwen.generalInformation = "We provide load lifters and components for various ship systems"
	stationOwen.stationHistory = "The station is named after Lars Owen. After his extensive eperience with tempermental machinery on Tatooine, he used his subject matter expertise to expand into building and manufacturing the equipment adding innovations based on his years of experience using load lifters and their relative cousins, moisture vaporators"
	return stationOwen
end
function placePanduit()
	--Panduit
	stationPanduit = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPanduit:setPosition(psx,psy):setCallSign("Panduit"):setDescription("Optic components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationPanduit] = {{"food",math.random(5,10),1},{"medicine",5,5},{"optic",5,79}}
		else
			goods[stationPanduit] = {{"food",math.random(5,10),1},{"optic",5,79}}		
			if random(1,100) < 33 then tradeMedicine[stationPanduit] = true end
		end
	else
		goods[stationPanduit] = {{"optic",5,79}}		
		if random(1,100) < 33 then tradeMedicine[stationPanduit] = true end
		if random(1,100) < 27 then tradeFood[stationPanduit] = true end
	end
	tradeLuxury[stationPanduit] = true
	stationPanduit.publicRelations = true
	stationPanduit.generalInformation = "We provide optic components for various ship systems"
	stationPanduit.stationHistory = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"
	return stationPanduit
end
function placeRipley()
	--Ripley
	stationRipley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(psx,psy):setCallSign("Ripley"):setDescription("Load lifters and components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationRipley] = {{"food",math.random(5,10),1},{"medicine",5,5},{"lifter",5,82}}
		else
			goods[stationRipley] = {{"food",math.random(5,10),1},{"lifter",5,82}}		
			tradeMedicine[stationRipley] = true 
		end
	else
		goods[stationRipley] = {{"lifter",5,82}}		
		if random(1,100) < 17 then tradeFood[stationRipley] = true end
		tradeMedicine[stationRipley] = true 
	end
	if random(1,100) < 47 then tradeLuxury[stationRipley] = true end
	stationRipley.publicRelations = true
	stationRipley.generalInformation = "We provide load lifters and components"
	stationRipley.stationHistory = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"
	return stationRipley
end
function placeRutherford()
	--Rutherford
	stationRutherford = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRutherford:setPosition(psx,psy):setCallSign("Rutherford"):setDescription("Shield components and research")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationRutherford] = {{"food",math.random(5,10),1},{"medicine",5,5},{"shield",5,90}}
		else
			goods[stationRutherford] = {{"food",math.random(5,10),1},{"shield",5,90}}		
			tradeMedicine[stationRutherford] = true 
		end
	else
		goods[stationRutherford] = {{"shield",5,90}}		
		tradeMedicine[stationRutherford] = true 
	end
	tradeMedicine[stationRutherford] = true
	if random(1,100) < 43 then tradeLuxury[stationRutherford] = true end
	stationRutherford.publicRelations = true
	stationRutherford.generalInformation = "We research and fabricate components for ship shield systems"
	stationRutherford.stationHistory = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"
	return stationRutherford
end
function placeScience7()
	--Science 7
	stationScience7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience7:setPosition(psx,psy):setCallSign("Science-7"):setDescription("Observatory")
	goods[stationScience7] = {{"food",2,1}}
	return stationScience7
end
function placeShawyer()
	--Shawyer
	stationShawyer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShawyer:setPosition(psx,psy):setCallSign("Shawyer"):setDescription("Impulse engine components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationShawyer] = {{"food",math.random(5,10),1},{"medicine",5,5},{"impulse",5,100}}
		else
			goods[stationShawyer] = {{"food",math.random(5,10),1},{"impulse",5,100}}		
			tradeMedicine[stationShawyer] = true 
		end
	else
		goods[stationShawyer] = {{"impulse",5,100}}		
		tradeMedicine[stationShawyer] = true 
	end
	tradeLuxury[stationShawyer] = true 
	stationShawyer.publicRelations = true
	stationShawyer.generalInformation = "We research and manufacture impulse engine components and systems"
	stationShawyer.stationHistory = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century"
	return stationShawyer
end
function placeShree()
	--Shree
	stationShree = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShree:setPosition(psx,psy):setCallSign("Shree"):setDescription("Repulsor and tractor beam components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationShree] = {{"food",math.random(5,10),1},{"medicine",5,5},{"tractor",5,90},{"repulsor",5,95}}
		else
			goods[stationShree] = {{"food",math.random(5,10),1},{"tractor",5,90},{"repulsor",5,95}}		
			tradeMedicine[stationShree] = true 
		end
	else
		goods[stationShree] = {{"tractor",5,90},{"repulsor",5,95}}		
		tradeMedicine[stationShree] = true 
		tradeFood[stationShree] = true 
	end
	tradeLuxury[stationShree] = true 
	stationShree.publicRelations = true
	stationShree.generalInformation = "We make ship systems designed to push or pull other objects around in space"
	stationShree.stationHistory = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"
	return stationShree
end
function placeSoong()
	--Soong 
	stationSoong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSoong:setPosition(psx,psy):setCallSign("Soong"):setDescription("Android components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationSoong] = {{"food",math.random(5,10),1},{"medicine",5,5},{"android",5,73}}
		else
			goods[stationSoong] = {{"food",math.random(5,10),1},{"android",5,73}}		
		end
	else
		goods[stationSoong] = {{"android",5,73}}		
		tradeFood[stationSoong] = true 
	end
	tradeLuxury[stationSoong] = true 
	stationSoong.publicRelations = true
	stationSoong.generalInformation = "We create androids and android components"
	stationSoong.stationHistory = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"
	return stationSoong
end
function placeTiberius()
	--Tiberius
	stationTiberius = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTiberius:setPosition(psx,psy):setCallSign("Tiberius"):setDescription("Logistics coordination")
	goods[stationTiberius] = {{"food",5,1}}
	stationTiberius.publicRelations = true
	stationTiberius.generalInformation = "We support the stations and ships in the area with planning and communication services"
	stationTiberius.stationHistory = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"
	return stationTiberius
end
function placeTokra()
	--Tokra
	stationTokra = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTokra:setPosition(psx,psy):setCallSign("Tokra"):setDescription("Advanced material components")
	whatTrade = random(1,100)
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationTokra] = {{"food",math.random(5,10),1},{"medicine",5,5},{"filament",5,42}}
			tradeLuxury[stationTokra] = true
		else
			goods[stationTokra] = {{"food",math.random(5,10),1},{"filament",5,42}}	
			if whatTrade < 50 then
				tradeMedicine[stationTokra] = true
			else
				tradeLuxury[stationTokra] = true
			end
		end
	else
		goods[stationTokra] = {{"filament",5,42}}		
		if whatTrade < 33 then
			tradeFood[stationTokra] = true
		elseif whatTrade > 66 then
			tradeMedicine[stationTokra] = true
		else
			tradeLuxury[stationTokra] = true
		end
	end
	stationTokra.publicRelations = true
	stationTokra.generalInformation = "We create multiple types of advanced material components. Our most popular products are our filaments"
	stationTokra.stationHistory = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them"
	return stationTokra
end
function placeToohie()
	--Toohie
	stationToohie = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationToohie:setPosition(psx,psy):setCallSign("Toohie"):setDescription("Shield and armor components and research")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationToohie] = {{"food",math.random(5,10),1},{"medicine",5,5},{"shield",5,90}}
		else
			goods[stationToohie] = {{"food",math.random(5,10),1},{"shield",5,90}}		
			if random(1,100) < 25 then tradeMedicine[stationToohie] = true end
		end
	else
		goods[stationToohie] = {{"shield",5,90}}		
		if random(1,100) < 25 then tradeMedicine[stationToohie] = true end
	end
	tradeLuxury[stationToohie] = true
	stationToohie.publicRelations = true
	stationToohie.generalInformation = "We research and make general and specialized components for ship shield and ship armor systems"
	stationToohie.stationHistory = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."
	return stationToohie
end
function placeUtopiaPlanitia()
	--Utopia Planitia
	stationUtopiaPlanitia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationUtopiaPlanitia:setPosition(psx,psy):setCallSign("Utopia Planitia"):setDescription("Ship building and maintenance facility")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationUtopiaPlanitia] = {{"food",math.random(5,10),1},{"medicine",5,5},{"warp",5,167}}
		else
			goods[stationUtopiaPlanitia] = {{"food",math.random(5,10),1},{"warp",5,167}}
		end
	else
		goods[stationUtopiaPlanitia] = {{"warp",5,167}}
	end
	stationUtopiaPlanitia.publicRelations = true
	stationUtopiaPlanitia.generalInformation = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel"
	return stationUtopiaPlanitia
end
function placeVactel()
	--Vactel
	stationVactel = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVactel:setPosition(psx,psy):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationVactel] = {{"food",math.random(5,10),1},{"medicine",5,5},{"circuit",5,50}}
		else
			goods[stationVactel] = {{"food",math.random(5,10),1},{"circuit",5,50}}		
		end
	else
		goods[stationVactel] = {{"circuit",5,50}}		
	end
	stationVactel.publicRelations = true
	stationVactel.generalInformation = "We specialize in circuitry shielded from external hacking suitable for ship systems"
	stationVactel.stationHistory = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"
	return stationVactel
end
function placeVeloquan()
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(psx,psy):setCallSign("Veloquan"):setDescription("Sensor components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationVeloquan] = {{"food",math.random(5,10),1},{"medicine",5,5},{"sensor",5,68}}
		else
			goods[stationVeloquan] = {{"food",math.random(5,10),1},{"sensor",5,68}}		
			tradeMedicine[stationVeloquan] = true 
		end
	else
		goods[stationVeloquan] = {{"sensor",5,68}}		
		tradeMedicine[stationVeloquan] = true 
		tradeFood[stationVeloquan] = true 
	end
	stationVeloquan.publicRelations = true
	stationVeloquan.generalInformation = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use"
	stationVeloquan.stationHistory = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"
	return stationVeloquan
end
function placeZefram()
	--Zefram
	stationZefram = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(psx,psy):setCallSign("Zefram"):setDescription("Warp engine components")
	if stationFaction == "Human Navy" then
		if random(1,5) <= 1 then
			goods[stationZefram] = {{"food",math.random(5,10),1},{"medicine",5,5},{"warp",5,140}}
		else
			goods[stationZefram] = {{"food",math.random(5,10),1},{"warp",5,140}}		
			if random(1,100) < 27 then tradeMedicine[stationZefram] = true end
		end
	else
		goods[stationZefram] = {{"warp",5,140}}		
		if random(1,100) < 27 then tradeMedicine[stationZefram] = true end
		if random(1,100) < 16 then tradeFood[stationZefram] = true end
	end
	tradeLuxury[stationZefram] = true
	stationZefram.publicRelations = true
	stationZefram.generalInformation = "We specialize in the esoteric components necessary to make warp drives function properly"
	stationZefram.stationHistory = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"
	return stationZefram
end
--[[-------------------------------------------------------------------
	Generic stations to be placed
--]]-------------------------------------------------------------------
function placeJabba()
	--Jabba
	stationJabba = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationJabba:setPosition(psx,psy):setCallSign("Jabba"):setDescription("Commerce and gambling")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationJabba] = {{"luxury",5,math.random(68,81)}}
	elseif stationGoodChoice == 2 then
		goods[stationJabba] = {{"gold",5,math.random(61,77)}}
	else
		goods[stationJabba] = {{"platinum",5,math.random(65,79)}}
	end
	stationJabba.publicRelations = true
	stationJabba.generalInformation = "Come play some games and shop. House take does not exceed 4 percent"
	return stationJabba
end
function placeKrik()
	--Krik
	stationKrik = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrik:setPosition(psx,psy):setCallSign("Krik"):setDescription("Mining station")
	posAxisKrik = random(0,360)
	posKrik = random(30000,80000)
	negKrik = random(20000,60000)
	spreadKrik = random(5000,8000)
	negAxisKrik = posAxisKrik + 180
	xPosAngleKrik, yPosAngleKrik = vectorFromAngle(posAxisKrik, posKrik)
	posKrikEnd = random(40,90)
	createRandomAlongArc(Asteroid, 30+posKrikEnd, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
	xNegAngleKrik, yNegAngleKrik = vectorFromAngle(negAxisKrik, negKrik)
	negKrikEnd = random(30,60)
	createRandomAlongArc(Asteroid, 30+negKrikEnd, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
	tradeFood[stationKrik] = true
	if random(1,100) < 50 then tradeLuxury[stationKrik] = true end
	tradeMedicine[stationKrik] = true
	krikGoods = random(1,100)
	if krikGoods < 10 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krikGoods < 20 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70},{"tritanium",5,50}}
	elseif krikGoods < 30 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70},{"dilithium",5,50}}
	elseif krikGoods < 40 then
		goods[stationKrik] = {{"nickel",5,20},{"tritanium",5,50},{"dilithium",5,50}}
	elseif krikGoods < 50 then
		goods[stationKrik] = {{"nickel",5,20},{"dilithium",5,50}}
	elseif krikGoods < 60 then
		goods[stationKrik] = {{"nickel",5,20},{"platinum",5,70}}
	elseif krikGoods < 70 then
		goods[stationKrik] = {{"nickel",5,20},{"tritanium",5,50}}
	elseif krikGoods < 80 then
		goods[stationKrik] = {{"platinum",5,70},{"tritanium",5,50},{"dilithium",5,50}}
	else
		goods[stationKrik] = {{"nickel",5,20}}
	end
	return stationKrik
end
function placeLando()
	--Lando
	stationLando = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLando:setPosition(psx,psy):setCallSign("Lando"):setDescription("Casino and Gambling")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationLando] = {{"luxury",5,math.random(68,81)}}
	elseif stationGoodChoice == 2 then
		goods[stationLando] = {{"gold",5,math.random(61,77)}}
	else
		goods[stationLando] = {{"platinum",5,math.random(65,79)}}
	end
	return stationLando
end
function placeMaverick()
	--Maverick
	stationMaverick = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaverick:setPosition(psx,psy):setCallSign("Maverick"):setDescription("Gambling and resupply")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationMaverick] = {{"luxury",5,math.random(68,81)}}
	elseif stationGoodChoice == 2 then
		goods[stationMaverick] = {{"gold",5,math.random(61,77)}}
	else
		goods[stationMaverick] = {{"tritanium",5,math.random(65,79)}}
	end
	stationMaverick.publicRelations = true
	stationMaverick.generalInformation = "Relax and meet some interesting players"
	return stationMaverick
end
function placeNefatha()
	--Nefatha
	stationNefatha = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNefatha:setPosition(psx,psy):setCallSign("Nefatha"):setDescription("Commerce and recreation")
	goods[stationNefatha] = {{"luxury",5,70}}
	return stationNefatha
end
function placeOkun()
	--Okun
	stationOkun = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOkun:setPosition(psx,psy):setCallSign("Okun"):setDescription("Xenopsychology research")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationOkun] = {{"optic",5,math.random(52,65)}}
	elseif stationGoodChoice == 2 then
		goods[stationOkun] = {{"filament",5,math.random(55,67)}}
	else
		goods[stationOkun] = {{"lifter",5,math.random(48,69)}}
	end
	return stationOkun
end
function placeOutpost7()
	--Outpost 7
	stationOutpost7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost7:setPosition(psx,psy):setCallSign("Outpost-7"):setDescription("Resupply")
	goods[stationOutpost7] = {{"luxury",5,80}}
	return stationOutpost7
end
function placeOutpost8()
	--Outpost 8
	stationOutpost8 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost8:setPosition(psx,psy):setCallSign("Outpost-8")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationOutpost8] = {{"impulse",5,math.random(69,75)}}
	elseif stationGoodChoice == 2 then
		goods[stationOutpost8] = {{"tractor",5,math.random(55,67)}}
	else
		goods[stationOutpost8] = {{"beam",5,math.random(61,69)}}
	end
	return stationOutpost8
end
function placeOutpost33()
	--Outpost 33
	stationOutpost33 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost33:setPosition(psx,psy):setCallSign("Outpost-33"):setDescription("Resupply")
	goods[stationOutpost33] = {{"luxury",5,75}}
	return stationOutpost33
end
function placePrada()
	--Prada
	stationPrada = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPrada:setPosition(psx,psy):setCallSign("Prada"):setDescription("Textiles and fashion")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationPrada] = {{"luxury",5,math.random(69,75)}}
	elseif stationGoodChoice == 2 then
		goods[stationPrada] = {{"cobalt",5,math.random(55,67)}}
	else
		goods[stationPrada] = {{"dilithium",5,math.random(61,69)}}
	end
	return stationPrada
end
function placeResearch11()
	--Research-11
	stationResearch11 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(psx,psy):setCallSign("Research-11"):setDescription("Stress Psychology Research")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationResearch11] = {{"warp",5,math.random(85,120)}}
	elseif stationGoodChoice == 2 then
		goods[stationResearch11] = {{"repulsor",5,math.random(62,75)}}
	else
		goods[stationResearch11] = {{"robotic",5,math.random(75,89)}}
	end
	return stationResearch11
end
function placeResearch19()
	--Research-19
	stationResearch19 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch19:setPosition(psx,psy):setCallSign("Research-19"):setDescription("Low gravity research")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationResearch19] = {{"transporter",5,math.random(85,94)}}
	elseif stationGoodChoice == 2 then
		goods[stationResearch19] = {{"sensor",5,math.random(62,75)}}
	else
		goods[stationResearch19] = {{"communication",5,math.random(55,89)}}
	end
	return stationResearch19
end
function placeRubis()
	--Rubis
	stationRubis = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRubis:setPosition(psx,psy):setCallSign("Rubis"):setDescription("Resupply")
	goods[stationRubis] = {{"luxury",5,76}}
	stationRubis.publicRelations = true
	stationRubis.generalInformation = "Get your energy here! Grab a drink before you go!"
	return stationRubis
end
function placeScience2()
	--Science 2
	stationScience2 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience2:setPosition(psx,psy):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationScience2] = {{"autodoc",5,math.random(85,94)}}
	elseif stationGoodChoice == 2 then
		goods[stationScience2] = {{"android",5,math.random(62,75)}}
	else
		goods[stationScience2] = {{"nanites",5,math.random(55,89)}}
	end
	return stationScience2
end
function placeScience4()
	--Science 4
	stationScience4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(psx,psy):setCallSign("Science-4"):setDescription("Biotech research")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationScience4] = {{"software",5,math.random(85,94)}}
	elseif stationGoodChoice == 2 then
		goods[stationScience4] = {{"circuit",5,math.random(62,75)}}
	else
		goods[stationScience4] = {{"battery",5,math.random(55,89)}}
	end
	return stationScience4
end
function placeSkandar()
	--Skandar
	stationSkandar = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSkandar:setPosition(psx,psy):setCallSign("Skandar"):setDescription("Routine maintenance and entertainment")
	goods[stationSkandar] = {{"luxury",5,87}}
	stationSkandar.publicRelations = true
	stationSkandar.generalInformation = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars"
	stationSkandar.stationHistory = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax"
	return stationSkandar
end
function placeSpot()
	--Spot
	stationSpot = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSpot:setPosition(psx,psy):setCallSign("Spot"):setDescription("Observatory")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationSpot] = {{"optic",5,math.random(85,94)}}
	elseif stationGoodChoice == 2 then
		goods[stationSpot] = {{"software",5,math.random(62,75)}}
	else
		goods[stationSpot] = {{"sensor",5,math.random(55,89)}}
	end
	return stationSpot
end
function placeStarnet()
	--Starnet 
	stationStarnet = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationStarnet:setPosition(psx,psy):setCallSign("Starnet"):setDescription("Automated weapons systems")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationStarnet] = {{"shield",5,math.random(85,94)}}
	elseif stationGoodChoice == 2 then
		goods[stationStarnet] = {{"beam",5,math.random(62,75)}}
	else
		goods[stationStarnet] = {{"lifter",5,math.random(55,89)}}
	end
	stationStarnet.publicRelations = true
	stationStarnet.generalInformation = "We research and create automated weapons systems to improve ship combat capability"
	return stationStarnet
end
function placeTandon()
	--Tandon
	stationTandon = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTandon:setPosition(psx,psy):setCallSign("Tandon"):setDescription("Biotechnology research")
	stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		goods[stationTandon] = {{"autodoc",5,math.random(85,94)}}
	elseif stationGoodChoice == 2 then
		goods[stationTandon] = {{"robotic",5,math.random(62,75)}}
	else
		goods[stationTandon] = {{"android",5,math.random(55,89)}}
	end
	return stationTandon
end
function placeVaiken()
	--Vaiken
	stationVaiken = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVaiken:setPosition(psx,psy):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
	goods[stationVaiken] = {{"food",10,1},{"medicine",5,5}}
	return stationVaiken
end
function placeValero()
	--Valero
	stationValero = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationValero:setPosition(psx,psy):setCallSign("Valero"):setDescription("Resupply")
	goods[stationValero] = {{"luxury",5,77}}
	return stationValero
end
--[[-------------------------------------------------------------------
	Enemy stations to be placed
--]]-------------------------------------------------------------------
function placeAramanth()
	--Aramanth
	stationAramanth = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Aramanth"):setPosition(psx,psy)
	return stationAramanth
end
function placeEmpok()
	--Empok Nor
	stationEmpok = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationEmpok:setPosition(psx,psy):setCallSign("Empok Nor")
	return stationEmpok
end
function placeGandala()
	--Gandala
	stationGanalda = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationGanalda:setPosition(psx,psy):setCallSign("Ganalda")
	return stationGanalda
end
function placeHassenstadt()
	--Hassenstadt
	stationHassenstadt = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Hassenstadt"):setPosition(psx,psy)
	return stationHassenstadt
end
function placeKaldor()
	--Kaldor
	stationKaldor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Kaldor"):setPosition(psx,psy)
	return stationKaldor
end
function placeMagMesra()
	--Magenta Mesra
	stationMagMesra = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Magenta Mesra"):setPosition(psx,psy)
	return stationMagMesra
end
function placeMosEisley()
	--Mos Eisley
	stationMosEisley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Mos Eisley"):setPosition(psx,psy)
	return stationMosEisley
end
function placeQuestaVerde()
	--Questa Verde
	stationQuestaVerde = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Questa Verde"):setPosition(psx,psy)
	return stationQuestaVerde
end
function placeRlyeh()
	--R'lyeh
	stationRlyeh = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("R'lyeh"):setPosition(psx,psy)
	return stationRlyeh
end
function placeScarletCit()
	--Scarlet Citadel
	stationScarletCitadel = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScarletCitadel:setPosition(psx,psy):setCallSign("Scarlet Citadel")
	return stationScarletCitadel
end
function placeStahlstadt()
	--Stahlstadt
	stationStahlstadt = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCallSign("Stahlstadt"):setPosition(psx,psy)
	return stationStahlstadt
end
function placeTic()
	--Ticonderoga
	stationTic = SpaceStation():setTemplate(szt()):setFaction(stationFaction)
	stationTic:setPosition(psx,psy):setCallSign("Ticonderoga")
	return stationTic
end
--[[-----------------------------------------------------------------
    Set up enemy and friendly fleets
-----------------------------------------------------------------]]--
function setFleets()
	--enemy defensive fleets
	enemyResource = 300 + difficulty*200
	enemyFleetList = {}
	enemyDefensiveFleetList = {}
	enemyFleet1base = kraylorStationList[math.random(1,#kraylorStationList)]
	f1bx, f1by = enemyFleet1base:getPosition()
	enemyFleet1, enemyFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130))
	for _, enemy in ipairs(enemyFleet1) do
		enemy:orderDefendTarget(enemyFleet1base)
	end
	table.insert(enemyFleetList,enemyFleet1)
	table.insert(enemyDefensiveFleetList,enemyFleet1)
	enemyResource = enemyResource - enemyFleet1Power
	if enemyResource > 120 then
		enemyFleet2Power = random(80,120)
	else
		enemyFleet2Power = 120
	end
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base then
			enemyFleet2base = candidate
		end
	until(enemyFleet2base ~= nil)
	f2bx, f2by = enemyFleet2base:getPosition()
	enemyFleet2, enemyFleet2Power = spawnEnemyFleet(f2bx, f2by, enemyFleet2Power)
	for _, enemy in ipairs(enemyFleet2) do
		enemy:orderDefendTarget(enemyFleet2base)
	end
	table.insert(enemyFleetList,enemyFleet2)
	table.insert(enemyDefensiveFleetList,enemyFleet2)
	enemyResource = enemyResource - enemyFleet2Power
	if enemyResource > 120 then
		enemyFleet3Power = random(80,120)
	else
		enemyFleet3Power = 120
	end
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base then
			enemyFleet3base = candidate
		end
	until(enemyFleet3base ~= nil)
	f3bx, f3by = enemyFleet3base:getPosition()
	enemyFleet3, enemyFleet3Power = spawnEnemyFleet(f3bx, f3by, enemyFleet3Power)
	for _, enemy in ipairs(enemyFleet3) do
		enemy:orderDefendTarget(enemyFleet3base)
	end
	table.insert(enemyFleetList,enemyFleet3)
	table.insert(enemyDefensiveFleetList,enemyFleet3)
	enemyResource = enemyResource - enemyFleet3Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base and candidate ~= enemyFleet3base then
			enemyFleet4base = candidate
		end
	until(enemyFleet4base ~= nil)
	f4bx, f4by = enemyFleet4base:getPosition()
	enemyFleet4, enemyFleet4Power = spawnEnemyFleet(f4bx, f4by, enemyResource/2)
	for _, enemy in ipairs(enemyFleet4) do
		enemy:orderDefendTarget(enemyFleet4base)
	end
	table.insert(enemyFleetList,enemyFleet4)
	table.insert(enemyDefensiveFleetList,enemyFleet4)
	enemyResource = enemyResource - enemyFleet4Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base and candidate ~= enemyFleet3base and candidate ~= enemyFleet4base then
			enemyFleet5base = candidate
		end
	until(enemyFleet5base ~= nil)
	f5bx, f5by = enemyFleet5base:getPosition()
	enemyFleet5, enemyFleet5Power = spawnEnemyFleet(f5bx, f5by, enemyResource)
	for _, enemy in ipairs(enemyFleet5) do
		enemy:orderDefendTarget(enemyFleet5base)
	end
	table.insert(enemyFleetList,enemyFleet5)
	table.insert(enemyDefensiveFleetList,enemyFleet5)
	
	--friendly defensive fleets
	
	friendlyResource = 500
	friendlyFleetList = {}
	friendlyHelperFleet = {}
	table.insert(friendlyFleetList,friendlyHelperFleet)
	friendlyFleet1base = humanStationList[math.random(1,#humanStationList)]
	f1bx, f1by = friendlyFleet1base:getPosition()
	friendlyFleet1, friendlyFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130), 1, "Human Navy")
	for _, enemy in ipairs(friendlyFleet1) do
		enemy:orderDefendTarget(friendlyFleet1base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet1)
	friendlyResource = friendlyResource - friendlyFleet1Power
	if friendlyResource > 120 then
		friendlyFleet2Power = random(80,120)
	else
		friendlyFleet2Power = 120
	end
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base then
			friendlyFleet2base = candidate
		end
	until(friendlyFleet2base ~= nil)
	f2bx, f2by = friendlyFleet2base:getPosition()
	friendlyFleet2, friendlyFleet2Power = spawnEnemyFleet(f2bx, f2by, friendlyFleet2Power, 1, "Human Navy")
	for _, enemy in ipairs(friendlyFleet2) do
		enemy:orderDefendTarget(friendlyFleet2base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet2)
	friendlyResource = friendlyResource - friendlyFleet2Power
	if friendlyResource > 120 then
		friendlyFleet3Power = random(80,120)
	else
		friendlyFleet3Power = 120
	end
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base then
			friendlyFleet3base = candidate
		end
	until(friendlyFleet3base ~= nil)
	f3bx, f3by = friendlyFleet3base:getPosition()
	friendlyFleet3, friendlyFleet3Power = spawnEnemyFleet(f3bx, f3by, friendlyFleet3Power, 1, "Human Navy")
	for _, enemy in ipairs(friendlyFleet3) do
		enemy:orderDefendTarget(friendlyFleet3base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet3)
	friendlyResource = friendlyResource - friendlyFleet3Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base and candidate ~= friendlyFleet3base then
			friendlyFleet4base = candidate
		end
	until(friendlyFleet4base ~= nil)
	f4bx, f4by = friendlyFleet4base:getPosition()
	friendlyFleet4, friendlyFleet4Power = spawnEnemyFleet(f4bx, f4by, friendlyResource/2, 1, "Human Navy")
	for _, enemy in ipairs(friendlyFleet4) do
		enemy:orderDefendTarget(friendlyFleet4base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet4)
	friendlyResource = friendlyResource - friendlyFleet4Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= enemyFleet1base and candidate ~= friendlyFleet2base and candidate ~= friendlyFleet3base and candidate ~= friendlyFleet4base then
			friendlyFleet5base = candidate
		end
	until(friendlyFleet5base ~= nil)
	f5bx, f5by = friendlyFleet5base:getPosition()
	friendlyFleet5, enemyFleet5Power = spawnEnemyFleet(f5bx, f5by, friendlyResource, 1, "Human Navy")
	for _, enemy in ipairs(friendlyFleet5) do
		enemy:orderDefendTarget(friendlyFleet5base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet5)
end
function spawnEnemyFleet(xOrigin, yOrigin, power, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(power * danger * difficulty, 5)
	enemyPosition = 0
	sp = irandom(400,900)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	fleetPower = 0
	while enemyStrength > 0 do
		shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end
		fleetPower = fleetPower + stsl[shipTemplateType]
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		if enemyFaction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + stsl[shipTemplateType]
			ship:onDestruction(enemyVesselDestroyed)
		elseif enemyFaction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + stsl[shipTemplateType]
			ship:onDestruction(friendlyVesselDestroyed)
		end
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	fleetPower = math.max(fleetPower/danger/difficulty, 5)
	return enemyList, fleetPower
end
--[[-----------------------------------------------------------------
    Optional mission initialization and routines
-----------------------------------------------------------------]]--
function setOptionalMissions()
	--	faster beams
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						beamTimeBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(beamTimeBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if beamTimeBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase then
				if #goods[candidate] > 0 then
					beamTimeGoodBase = candidate
					gi = 1
					repeat
						beamTimeGood = goods[beamTimeGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if beamTimeGood == "food" or beamTimeGood == "medicine" or beamTimeGood == goods[beamTimeBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[beamTimeBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[beamTimeGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		beamTimeBase.character = "Horace Grayson"
		beamTimeBase.characterDescription = "He dabbles in ship system innovations. He's been working on improving beam weapons by reducing the amount of time between firing. I hear he's already installed some improvements on ships that have docked here previously"
		beamTimeBase.characterFunction = "shrinkBeamCycle"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			beamTimeBase.characterGood = beamTimeGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("I heard there's a guy named %s that can fix ship beam systems up so that they shoot faster. He lives out on %s in %s. He won't charge you much, but it won't be free.",beamTimeBase.character,beamTimeBase:getCallSign(),beamTimeBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if beamTimeBase ~= nil then
			print(string.format("beam time: Base: %s, Sector: %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName()))
		else
			print("beam time: no base")
		end
		if beamTimeGoodBase ~= nil and beamTimeGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",beamTimeGood,beamTimeGoodBase:getCallSign(),beamTimeGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	spin faster
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						spinBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(spinBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if spinBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= spinBase then
				if #goods[candidate] > 0 then
					spinGoodBase = candidate
					gi = 1
					repeat
						spinGood = goods[spinGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if spinGood == "food" or spinGood == "medicine" or spinGood == goods[spinBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[spinBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[spinGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		spinBase.character = "Emily Patel"
		spinBase.characterDescription = "She tinkers with ship systems like engines and thrusters. She's consulted with the military on tuning spin time by increasing thruster power. She's got prototypes that are awaiting formal military approval before installation"
		spinBase.characterFunction = "increaseSpin"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			spinBase.characterGood = spinGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= spinBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("My friend, %s recently quit her job as a ship maintenance technician to set up this side gig. She's been improving ship systems and she's pretty good at it. She set up shop on %s in %s. I hear she's even lining up a contract with the navy for her improvements.",spinBase.character,spinBase:getCallSign(),spinBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if spinBase ~= nil then
			print(string.format("spin: Base: %s, Sector: %s",spinBase:getCallSign(),spinBase:getSectorName()))
		else
			print("spin: no base")
		end
		if spinGoodBase ~= nil and spinGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",spinGood,spinGoodBase:getCallSign(),spinGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	extra missile tube
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						auxTubeBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(auxTubeBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if auxTubeBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= auxTubeBase then
				if #goods[candidate] > 0 then
					auxTubeGoodBase = candidate
					gi = 1
					repeat
						auxTubeGood = goods[auxTubeGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if auxTubeGood == "food" or auxTubeGood == "medicine" or auxTubeGood == goods[auxTubeBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[auxTubeBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[auxTubeGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		auxTubeBase.character = "Fred McLassiter"
		auxTubeBase.characterDescription = "He specializes in miniaturization of weapons systems. He's come up with a way to add a missile tube and some missiles to any ship regardless of size or configuration"
		auxTubeBase.characterFunction = "addAuxTube"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			auxTubeBase.characterGood = auxTubeGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= auxTubeBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("There's this guy, %s out on %s in %s that can add a missile tube to your ship. He even added one to my cousin's souped up freighter. You should see the new paint job: amusingly phallic",auxTubeBase.character,auxTubeBase:getCallSign(),auxTubeBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if auxTubeBase ~= nil then
			print(string.format("aux tube: Base: %s, Sector: %s",auxTubeBase:getCallSign(),auxTubeBase:getSectorName()))
		else
			print("aux tube: no base")
		end
		if auxTubeGoodBase ~= nil and auxTubeGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",auxTubeGood,auxTubeGoodBase:getCallSign(),auxTubeGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	cooler beam weapon firing
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						coolBeamBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(coolBeamBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if coolBeamBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= coolBeamBase then
				if #goods[candidate] > 0 then
					coolBeamGoodBase = candidate
					gi = 1
					repeat
						coolBeamGood = goods[coolBeamGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if coolBeamGood == "food" or coolBeamGood == "medicine" or coolBeamGood == goods[coolBeamBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[coolBeamBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[coolBeamGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		coolBeamBase.character = "Dorothy Ly"
		coolBeamBase.characterDescription = "She developed this technique for cooling beam systems so that they can be fired more often without burning out"
		coolBeamBase.characterFunction = "coolBeam"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			coolBeamBase.characterGood = coolBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= coolBeamBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("There's this girl on %s in %s. She is hot. Her name is %s. When I say she is hot, I mean she has a way of keeping your beam weapons from excessive heat.",coolBeamBase:getCallSign(),coolBeamBase:getSectorName(),coolBeamBase.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if coolBeamBase ~= nil then
			print(string.format("cool beam: Base: %s, Sector: %s",coolBeamBase:getCallSign(),coolBeamBase:getSectorName()))
		else
			print("cool beam: no base")
		end
		if coolBeamGoodBase ~= nil and coolBeamGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",coolBeamGood,coolBeamGoodBase:getCallSign(),coolBeamGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	longer beam range
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						longerBeamBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(longerBeamBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if longerBeamBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= longerBeamBase then
				if #goods[candidate] > 0 then
					longerBeamGoodBase = candidate
					gi = 1
					repeat
						longerBeamGood = goods[longerBeamGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if longerBeamGood == "food" or longerBeamGood == "medicine" or longerBeamGood == goods[longerBeamBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[longerBeamBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[longerBeamGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		longerBeamBase.character = "Gerald Cook"
		longerBeamBase.characterDescription = "He knows how to modify beam systems to extend their range"
		longerBeamBase.characterFunction = "longerBeam"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			longerBeamBase.characterGood = longerBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= longerBeamBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("Do you know about %s? He can extend the range of your beam weapons. He's on %s in %s",longerBeamBase.character,longerBeamBase:getCallSign(),longerBeamBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if longerBeamBase ~= nil then
			print(string.format("longer beam: Base: %s, Sector: %s",longerBeamBase:getCallSign(),longerBeamBase:getSectorName()))
		else
			print("longer beam: no base")
		end
		if longerBeamGoodBase ~= nil and longerBeamGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",longerBeamGood,longerBeamGoodBase:getCallSign(),longerBeamGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	increased beam damage
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase and candidate ~= longerBeamBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						damageBeamBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(damageBeamBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if damageBeamBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= damageBeamBase then
				if #goods[candidate] > 0 then
					damageBeamGoodBase = candidate
					gi = 1
					repeat
						damageBeamGood = goods[damageBeamGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if damageBeamGood == "food" or damageBeamGood == "medicine" or damageBeamGood == goods[damageBeamBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[damageBeamBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[damageBeamGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		damageBeamBase.character = "Sally Jenkins"
		damageBeamBase.characterDescription = "She can make your beams hit harder"
		damageBeamBase.characterFunction = "damageBeam"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			damageBeamBase.characterGood = damageBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= damageBeamBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("You should visit %s in %s. There's a specialist in beam technology that can increase the damage done by your beams. Her name is %s",damageBeamBase:getCallSign(),damageBeamBase:getSectorName(),damageBeamBase.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if damageBeamBase ~= nil then
			print(string.format("more damaging beam: Base: %s, Sector: %s",damageBeamBase:getCallSign(),damageBeamBase:getSectorName()))
		else
			print("more damaging beam: no base")
		end
		if damageBeamGoodBase ~= nil and damageBeamGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",damageBeamGood,damageBeamGoodBase:getCallSign(),damageBeamGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	increased maximum missile storage capacity
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase and candidate ~= longerBeamBase and candidate ~= damageBeamBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						moreMissilesBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(moreMissilesBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if moreMissilesBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= moreMissilesBase then
				if #goods[candidate] > 0 then
					moreMissilesGoodBase = candidate
					gi = 1
					repeat
						moreMissilesGood = goods[moreMissilesGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if moreMissilesGood == "food" or moreMissilesGood == "medicine" or moreMissilesGood == goods[moreMissilesBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[moreMissilesBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[moreMissilesGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		moreMissilesBase.character = "Anh Dung Ly"
		moreMissilesBase.characterDescription = "He can fit more missiles aboard your ship"
		moreMissilesBase.characterFunction = "moreMissiles"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			moreMissilesBase.characterGood = moreMissilesGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= moreMissilesBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("Want to store more missiles on your ship? Talk to %s on station %s in %s. He can retrain your missile loaders and missile storage automation such that you will be able to store more missiles",moreMissilesBase.character,moreMissilesBase:getCallSign(),moreMissilesBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if moreMissilesBase ~= nil then
			print(string.format("more missiles: Base: %s, Sector: %s",moreMissilesBase:getCallSign(),moreMissilesBase:getSectorName()))
		else
			print("more missiles: no base")
		end
		if moreMissilesGoodBase ~= nil and moreMissilesGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",moreMissilesGood,moreMissilesGoodBase:getCallSign(),moreMissilesGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	faster impulse
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase and candidate ~= longerBeamBase and candidate ~= damageBeamBase and candidate ~= moreMissilesBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						fasterImpulseBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(fasterImpulseBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if fasterImpulseBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= fasterImpulseBase then
				if #goods[candidate] > 0 then
					fasterImpulseGoodBase = candidate
					gi = 1
					repeat
						fasterImpulseGood = goods[fasterImpulseGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if fasterImpulseGood == "food" or fasterImpulseGood == "medicine" or fasterImpulseGood == goods[fasterImpulseBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[fasterImpulseBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[fasterImpulseGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		fasterImpulseBase.character = "Doralla Ognats"
		fasterImpulseBase.characterDescription = "She can soup up your impulse engines"
		fasterImpulseBase.characterFunction = "fasterImpulse"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			fasterImpulseBase.characterGood = fasterImpulseGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= fasterImpulseBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("%s, an engineer/mechanic who knows propulsion systems backwards and forwards has a bay at the shipyard on %s in %s. She can give your impulse engines a significant boost to their top speed",fasterImpulseBase.character,fasterImpulseBase:getCallSign(),fasterImpulseBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if fasterImpulseBase ~= nil then
			print(string.format("faster impulse: Base: %s, Sector: %s",fasterImpulseBase:getCallSign(),fasterImpulseBase:getSectorName()))
		else
			print("faster impulse: no base")
		end
		if fasterImpulseGoodBase ~= nil and fasterImpulseGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",fasterImpulseGood,fasterImpulseGoodBase:getCallSign(),fasterImpulseGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	stronger hull
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase and candidate ~= longerBeamBase and candidate ~= damageBeamBase and candidate ~= moreMissilesBase and candidate ~= fasterImpulseBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						strongerHullBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(strongerHullBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if strongerHullBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= strongerHullBase then
				if #goods[candidate] > 0 then
					strongerHullGoodBase = candidate
					gi = 1
					repeat
						strongerHullGood = goods[strongerHullGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if strongerHullGood == "food" or strongerHullGood == "medicine" or strongerHullGood == goods[strongerHullBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[strongerHullBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[strongerHullGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		strongerHullBase.character = "Maduka Lawal"
		strongerHullBase.characterDescription = "He can strengthen your hull"
		strongerHullBase.characterFunction = "strongerHull"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			strongerHullBase.characterGood = strongerHullGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= strongerHullBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("I know of a materials specialist on %s in %s named %s. He can strengthen the hull on your ship",strongerHullBase:getCallSign(),strongerHullBase:getSectorName(),strongerHullBase.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if strongerHullBase ~= nil then
			print(string.format("stronger hull: Base: %s, Sector: %s",strongerHullBase:getCallSign(),strongerHullBase:getSectorName()))
		else
			print("stronger hull: no base")
		end
		if strongerHullGoodBase ~= nil and strongerHullGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",strongerHullGood,strongerHullGoodBase:getCallSign(),strongerHullGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	efficient batteries
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase and candidate ~= longerBeamBase and candidate ~= damageBeamBase and candidate ~= moreMissilesBase and candidate ~= fasterImpulseBase and candidate ~= strongerHullBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						efficientBatteriesBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(efficientBatteriesBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if efficientBatteriesBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= efficientBatteriesBase then
				if #goods[candidate] > 0 then
					efficientBatteriesGoodBase = candidate
					gi = 1
					repeat
						efficientBatteriesGood = goods[efficientBatteriesGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if efficientBatteriesGood == "food" or efficientBatteriesGood == "medicine" or efficientBatteriesGood == goods[efficientBatteriesBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[efficientBatteriesBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[efficientBatteriesGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		efficientBatteriesBase.character = "Susil Tarigan"
		efficientBatteriesBase.characterDescription = "She knows how to increase your maximum energy capacity by improving battery efficiency"
		efficientBatteriesBase.characterFunction = "efficientBatteries"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			efficientBatteriesBase.characterGood = efficientBatteriesGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= efficientBatteriesBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("Have you heard about %s? She's on %s in %s and she can give your ship greater energy capacity by improving your battery efficiency",efficientBatteriesBase.character,efficientBatteriesBase:getCallSign(),efficientBatteriesBase:getSectorName())
			end
		end
	end
	if optionalMissionDiagnostic then
		if efficientBatteriesBase ~= nil then
			print(string.format("efficient batteries: Base: %s, Sector: %s",efficientBatteriesBase:getCallSign(),efficientBatteriesBase:getSectorName()))
		else
			print("efficient batteries: no base")
		end
		if efficientBatteriesGoodBase ~= nil and efficientBatteriesGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",efficientBatteriesGood,efficientBatteriesGoodBase:getCallSign(),efficientBatteriesGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
	--	stronger shields
	missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate ~= spinBase and candidate ~= auxTubeBase and candidate ~= coolBeamBase and candidate ~= longerBeamBase and candidate ~= damageBeamBase and candidate ~= moreMissilesBase and candidate ~= fasterImpulseBase and candidate ~= strongerHullBase and candidate ~= efficientBatteriesBase then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
						strongerShieldsBase = candidate
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(strongerShieldsBase ~= nil or missionAttemptCount > repeatExitBoundary)	
	if strongerShieldsBase ~= nil then
		missionAttemptCount = 0
		matchAway = nil
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= strongerShieldsBase then
				if #goods[candidate] > 0 then
					strongerShieldsGoodBase = candidate
					gi = 1
					repeat
						strongerShieldsGood = goods[strongerShieldsGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if strongerShieldsGood == "food" or strongerShieldsGood == "medicine" or strongerShieldsGood == goods[strongerShieldsBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[strongerShieldsBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[strongerShieldsGoodBase])
				end
			end
			missionAttemptCount = missionAttemptCount + 1
		until(not matchAway or missionAttemptCount > repeatExitBoundary)
		strongerShieldsBase.character = "Paulo Silva"
		strongerShieldsBase.characterDescription = "He can strengthen your shields"
		strongerShieldsBase.characterFunction = "strongerShields"
		if matchAway then
			beamTimeBase.characterGood = "gold pressed latinum"			
		else
			strongerShieldsBase.characterGood = strongerShieldsGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= strongerShieldsBase and candidate.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.gossip = string.format("If you stop at %s in %s, you should talk to %s. He can strengthen your shields. Trust me, it's always good to have stronger shields",strongerShieldsBase:getCallSign(),strongerShieldsBase:getSectorName(),strongerShieldsBase.character)
			end
		end
	end
	if optionalMissionDiagnostic then
		if strongerShieldsBase ~= nil then
			print(string.format("stronger shields: Base: %s, Sector: %s",strongerShieldsBase:getCallSign(),strongerShieldsBase:getSectorName()))
		else
			print("stronger shields: no base")
		end
		if strongerShieldsGoodBase ~= nil and strongerShieldsGood ~= nil then
			print(string.format("  Good: %s, Good Base: %s in %s",strongerShieldsGood,strongerShieldsGoodBase:getCallSign(),strongerShieldsGoodBase:getSectorName()))
		else
			print("  no good defined")
		end
		if clueStation ~= nil then
			print(string.format("  Clue Base: %s in %s",clueStation:getCallSign(),clueStation:getSectorName()))
		else
			print("  no clue base defined")
		end
	end
end
function shrinkBeamCycle()
	if player.shrinkBeamCycleUpgrade == nil then
		addCommsReply("Reduce beam cycle time", function()
			if player:getBeamWeaponRange(0) > 0 then
				if treaty then
					local gi = 1
					local partQuantity = 0
					repeat
						if goods[player][gi][1] == comms_target.characterGood then
							partQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if partQuantity > 0 then
						player.shrinkBeamCycleUpgrade = "done"
						decrementPlayerGoods(comms_target.characterGood)
						player.cargo = player.cargo + 1
						local bi = 0
						repeat
							local tempArc = player:getBeamWeaponArc(bi)
							local tempDir = player:getBeamWeaponDirection(bi)
							local tempRng = player:getBeamWeaponRange(bi)
							local tempCyc = player:getBeamWeaponCycleTime(bi)
							local tempDmg = player:getBeamWeaponDamage(bi)
							player:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .75,tempDmg)
							bi = bi + 1
						until(player:getBeamWeaponRange(bi) < 1)
						setCommsMessage("After accepting your gift, he reduced your Beam cycle time by 25%")
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",comms_target.character,comms_target.characterGood))
					end
				else
					player.shrinkBeamCycleUpgrade = "done"
					bi = 0
					repeat
						tempArc = player:getBeamWeaponArc(bi)
						tempDir = player:getBeamWeaponDirection(bi)
						tempRng = player:getBeamWeaponRange(bi)
						tempCyc = player:getBeamWeaponCycleTime(bi)
						tempDmg = player:getBeamWeaponDamage(bi)
						player:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .75,tempDmg)
						bi = bi + 1
					until(player:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s reduced your Beam cycle time by 25%% at no cost in trade with the message, 'Go get those Kraylors.'",comms_target.character))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function increaseSpin()
	if player.increaseSpinUpgrade == nil then
		addCommsReply("Increase spin speed", function()
			if treaty then
				local gi = 1
				local partQuantity = 0
				repeat
					if goods[player][gi][1] == comms_target.characterGood then
						partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if partQuantity > 0 then
					player.increaseSpinUpgrade = "done"
					decrementPlayerGoods(comms_target.characterGood)
					player.cargo = player.cargo + 1
					player:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
					setCommsMessage(string.format("Ship spin speed increased by 50% after you gave %s to %s",comms_target.characterGood,comms_target.character))
				else
					setCommsMessage(string.format("%s requires %s for the spin upgrade",comms_target.character,comms_target.characterGood))
				end
			else
				player.increaseSpinUpgrade = "done"
				player:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
				setCommsMessage(string.format("%s: I increased the speed your ship spins by 50%%. Normally, I'd require %s, but seeing as you're going out to take on the Kraylors, we worked it out",comms_target.character,comms_target.characterGood))
			end
		end)
	end
end
function addAuxTube()
	if player.auxTubeUpgrade == nil then
		addCommsReply("Add missle tube", function()
			if treaty then
				local gi = 1
				local partQuantity = 0
				local luxQuantity = 0
				repeat
					if goods[player][gi][1] == comms_target.characterGood then
						partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == "luxury" then
						luxQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if partQuantity > 0 and luxQuantity > 0 then
					player.auxTubeUpgrade = "done"
					decrementPlayerGoods(comms_target.characterGood)
					decrementPlayerGoods("luxury")
					player.cargo = player.cargo + 2
					local originalTubes = player:getWeaponTubeCount()
					local newTubes = originalTubes + 1
					player:setWeaponTubeCount(newTubes)
					player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
					player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
					player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
					setCommsMessage(string.format("%s thanks you for the %s and the luxury and installs a homing missile tube for you",comms_target.character,comms_target.characterGood))
				else
					setCommsMessage(string.format("%s requires %s and luxury for the missile tube",comms_target.character,comms_target.characterGood))
				end
			else
				player.auxTubeUpgrade = "done"
				originalTubes = player:getWeaponTubeCount()
				newTubes = originalTubes + 1
				player:setWeaponTubeCount(newTubes)
				player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
				player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
				player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
				setCommsMessage(string.format("%s installs a homing missile tube for you. The %s required was requisitioned from wartime contingency supplies",comms_target.character,comms_target.characterGood))
			end
		end)
	end
end
function coolBeam()
	if player.coolBeamUpgrade == nil then
		addCommsReply("Reduce beam heat", function()
			if player:getBeamWeaponRange(0) > 0 then
				if treaty then
					local gi = 1
					local partQuantity = 0
					repeat
						if goods[player][gi][1] == comms_target.characterGood then
							partQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if partQuantity > 0 then
						player.coolBeamUpgrade = "done"
						decrementPlayerGoods(comms_target.characterGood)
						player.cargo = player.cargo + 1
						local bi = 0
						repeat
							player:setBeamWeaponHeatPerFire(bi,player:getBeamWeaponHeatPerFire(bi) * 0.5)
							bi = bi + 1
						until(player:getBeamWeaponRange(bi) < 1)
						setCommsMessage("Beam heat generation reduced by 50 percent")
					else
						setCommsMessage(string.format("%s says she needs %s before she can cool your beams",comms_target.character,comms_target.characterGood))
					end
				else
					player.coolBeamUpgrade = "done"
					bi = 0
					repeat
						player:setBeamWeaponHeatPerFire(bi,player:getBeamWeaponHeatPerFire(bi) * 0.5)
						bi = bi + 1
					until(player:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s: Beam heat generation reduced by 50 percent, no %s necessary. Go shoot some Kraylors for me",comms_target.character,comms_target.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function longerBeam()
	if player.longerBeamUpgrade == nil then
		addCommsReply("Extend beam range", function()
			if player:getBeamWeaponRange(0) > 0 then
				if treaty then
					local gi = 1
					local partQuantity = 0
					repeat
						if goods[player][gi][1] == comms_target.characterGood then
							partQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if partQuantity > 0 then
						player.longerBeamUpgrade = "done"
						decrementPlayerGoods(comms_target.characterGood)
						player.cargo = player.cargo + 1
						local bi = 0
						repeat
							local tempArc = player:getBeamWeaponArc(bi)
							local tempDir = player:getBeamWeaponDirection(bi)
							local tempRng = player:getBeamWeaponRange(bi)
							local tempCyc = player:getBeamWeaponCycleTime(bi)
							local tempDmg = player:getBeamWeaponDamage(bi)
							player:setBeamWeapon(bi,tempArc,tempDir,tempRng * 1.25,tempCyc,tempDmg)
							bi = bi + 1
						until(player:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format("%s extended your beam range by 25%% and says thanks for the %s",comms_target.character,comms_target.characterGood))
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",comms_target.character,comms_target.characterGood))
					end
				else
					player.longerBeamUpgrade = "done"
					bi = 0
					repeat
						tempArc = player:getBeamWeaponArc(bi)
						tempDir = player:getBeamWeaponDirection(bi)
						tempRng = player:getBeamWeaponRange(bi)
						tempCyc = player:getBeamWeaponCycleTime(bi)
						tempDmg = player:getBeamWeaponDamage(bi)
						player:setBeamWeapon(bi,tempArc,tempDir,tempRng * 1.25,tempCyc,tempDmg)
						bi = bi + 1
					until(player:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s increased your beam range by 25%% without the usual %s from your ship",comms_target.character,comms_target.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function damageBeam()
	if player.damageBeamUpgrade == nil then
		addCommsReply("Increase beam damage", function()
			if player:getBeamWeaponRange(0) > 0 then
				if treaty then
					local gi = 1
					local partQuantity = 0
					repeat
						if goods[player][gi][1] == comms_target.characterGood then
							partQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if partQuantity > 0 then
						player.damageBeamUpgrade = "done"
						decrementPlayerGoods(comms_target.characterGood)
						player.cargo = player.cargo + 1
						local bi = 0
						repeat
							local tempArc = player:getBeamWeaponArc(bi)
							local tempDir = player:getBeamWeaponDirection(bi)
							local tempRng = player:getBeamWeaponRange(bi)
							local tempCyc = player:getBeamWeaponCycleTime(bi)
							local tempDmg = player:getBeamWeaponDamage(bi)
							player:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
							bi = bi + 1
						until(player:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format("%s increased your beam damage by 20%% and stores away the %s",comms_target.character,comms_target.characterGood))
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",comms_target.character,comms_target.characterGood))
					end
				else
					player.damageBeamUpgrade = "done"
					bi = 0
					repeat
						tempArc = player:getBeamWeaponArc(bi)
						tempDir = player:getBeamWeaponDirection(bi)
						tempRng = player:getBeamWeaponRange(bi)
						tempCyc = player:getBeamWeaponCycleTime(bi)
						tempDmg = player:getBeamWeaponDamage(bi)
						player:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
						bi = bi + 1
					until(player:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s increased your beam damage by 20%%, waiving the usual %s requirement",comms_target.character,comms_target.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function moreMissiles()
	if player.moreMissilesUpgrade == nil then
		addCommsReply("Increase missile storage capacity", function()
			if player:getWeaponTubeCount() > 0 then
				if treaty then
					local gi = 1
					local partQuantity = 0
					repeat
						if goods[player][gi][1] == comms_target.characterGood then
							partQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if partQuantity > 0 then
						player.moreMissilesUpgrade = "done"
						decrementPlayerGoods(comms_target.characterGood)
						player.cargo = player.cargo + 1
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						for _, missile_type in ipairs(missile_types) do
							player:setWeaponStorageMax(missile_type, math.ceil(player:getWeaponStorageMax(missile_type)*1.25))
						end
						setCommsMessage(string.format("%s: You can now store at least 25%% more missiles. I appreciate the %s",comms_target.character,comms_target.characterGood))
					else
						setCommsMessage(string.format("%s needs %s for the upgrade",comms_target.character,comms_target.characterGood))
					end
				else
					player.moreMissilesUpgrade = "done"
					missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
					for _, missile_type in ipairs(missile_types) do
						player:setWeaponStorageMax(missile_type, math.ceil(player:getWeaponStorageMax(missile_type)*1.25))
					end
					setCommsMessage(string.format("%s: You can now store at least 25%% more missiles. I found some spare %s on the station. Go launch those missiles at those perfidious treaty-breaking Kraylors",comms_target.character,comms_target.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a missile storage capacity upgrade.")				
			end
		end)
	end
end
function fasterImpulse()
	if player.fasterImpulseUpgrade == nil then
		addCommsReply("Speed up impulse engines", function()
			if treaty then
				local gi = 1
				local partQuantity = 0
				repeat
					if goods[player][gi][1] == comms_target.characterGood then
						partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if partQuantity > 0 then
					player.fasterImpulseUpgrade = "done"
					decrementPlayerGoods(comms_target.characterGood)
					player.cargo = player.cargo + 1
					player:setImpulseMaxSpeed(player:getImpulseMaxSpeed()*1.25)
					setCommsMessage(string.format("%s: Your impulse engines now push you up to 25%% faster. Thanks for the %s",comms_target.character,comms_target.characterGood))
				else
					setCommsMessage(string.format("You need to bring %s to %s for the upgrade",comms_target.characterGood,comms_target.character))
				end
			else
				player.fasterImpulseUpgrade = "done"
				player:setImpulseMaxSpeed(player:getImpulseMaxSpeed()*1.25)
				setCommsMessage(string.format("%s: Your impulse engines now push you up to 25%% faster. I didn't need %s after all. Go run circles around those blinking Kraylors",comms_target.character,comms_target.characterGood))
			end
		end)
	end
end
function strongerHull()
	if player.strongerHullUpgrade == nil then
		addCommsReply("Strengthen hull", function()
			if treaty then
				local gi = 1
				local partQuantity = 0
				repeat
					if goods[player][gi][1] == comms_target.characterGood then
						partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if partQuantity > 0 then
					player.strongerHullUpgrade = "done"
					decrementPlayerGoods(comms_target.characterGood)
					player.cargo = player.cargo + 1
					player:setHullMax(player:getHullMax()*1.5)
					player:setHull(player:getHullMax())
					setCommsMessage(string.format("%s: Thank you for the %s. Your hull is 50%% stronger",comms_target.character,comms_target.characterGood))
				else
					setCommsMessage(string.format("%s: I need %s before I can increase your hull strength",comms_target.character,comms_target.characterGood))
				end
			else
				player.strongerHullUpgrade = "done"
				player:setHullMax(player:getHullMax()*1.5)
				player:setHull(player:getHullMax())
				setCommsMessage(string.format("%s: I made your hull 50%% stronger. I scrounged some %s from around here since you are on the Kraylor offense team",comms_target.character,comms_target.characterGood))
			end
		end)
	end
end
function efficientBatteries()
	if player.efficientBatteriesUpgrade == nil then
		addCommsReply("Increase battery efficiency", function()
			if treaty then
				local gi = 1
				local partQuantity = 0
				repeat
					if goods[player][gi][1] == comms_target.characterGood then
						partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if partQuantity > 0 then
					player.efficientBatteriesUpgrade = "done"
					decrementPlayerGoods(comms_target.characterGood)
					player.cargo = player.cargo + 1
					player:setMaxEnergy(player:getMaxEnergy()*1.25)
					player:setEnergy(player:getMaxEnergy())
					setCommsMessage(string.format("%s: I appreciate the %s. You have a 25%% greater energy capacity due to increased battery efficiency",comms_target.character,comms_target.characterGood))
				else
					setCommsMessage(string.format("%s: You need to bring me some %s before I can increase your battery efficiency",comms_target.character,comms_target.characterGood))
				end
			else
				player.efficientBatteriesUpgrade = "done"
				player:setMaxEnergy(player:getMaxEnergy()*1.25)
				player:setEnergy(player:getMaxEnergy())
				setCommsMessage(string.format("%s increased your battery efficiency by 25%% without the need for %s due to the pressing military demands on your ship",comms_target.character,comms_target.characterGood))
			end
		end)
	end
end
function strongerShields()
	if player.strongerShieldsUpgrade == nil then
		addCommsReply("Strengthen shields", function()
			if treaty then
				local gi = 1
				local partQuantity = 0
				repeat
					if goods[player][gi][1] == comms_target.characterGood then
						partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if partQuantity > 0 then
					player.strongerShieldsUpgrade = "done"
					decrementPlayerGoods(comms_target.characterGood)
					player.cargo = player.cargo + 1
					player:setShieldsMax(player:getShieldMax(0)*1.2)
					setCommsMessage(string.format("%s: I've raised your shield maximum by 20%%, %s. Thanks for bringing the %s",comms_target.character,player:getCallSign(),comms_target.characterGood))
				else
					setCommsMessage(string.format("%s: You need to provide %s before I can raise your shield strength",comms_target.character,comms_target.characterGood))
				end
			else
				player.strongerShieldsUpgrade = "done"
				player:setShieldsMax(player:getShieldMax(0)*1.2)
				setCommsMessage(string.format("%s: Congratulations, %s, your shields are 20%% stronger. Don't worry about the %s. Go kick those Kraylors outta here",comms_target.character,player:getCallSign(),comms_target.characterGood))
			end
		end)
	end
end
--[[-----------------------------------------------------------------
    Station communication 
-----------------------------------------------------------------]]--
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
            Homing = math.random(1,4),
            HVLI = math.random(1,3),
            Mine = math.random(2,5),
            Nuke = math.random(12,18),
            EMP = math.random(7,13)
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            reinforcements = math.random(125,175)
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 3.0
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5
        }
    })
    comms_data = comms_target.comms_data
	setPlayers()
	for p4idx=1,8 do
		local p4obj = getPlayerShip(p4idx)
		if p4obj ~= nil and p4obj:isValid() then
			if p4obj:isCommsOpening() then
				player = p4obj
			end
		end
	end	
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
    if player:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?\n"
    else
		oMsg = "Welcome to our lovely station.\n"
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if comms_target.nukeAvail == nil then
			if math.random(1,10) <= (4 - difficulty) then
				comms_target.nukeAvail = true
			else
				comms_target.nukeAvail = false
			end
			if math.random(1,10) <= (5 - difficulty) then
				comms_target.empAvail = true
			else
				comms_target.empAvail = false
			end
			if math.random(1,10) <= (6 - difficulty) then
				comms_target.homeAvail = true
			else
				comms_target.homeAvail = false
			end
			if math.random(1,10) <= (7 - difficulty) then
				comms_target.mineAvail = true
			else
				comms_target.mineAvail = false
			end
			if math.random(1,10) <= (9 - difficulty) then
				comms_target.hvliAvail = true
			else
				comms_target.hvliAvail = false
			end
		end	--end set up secondary ordnance availability for station if branch
		if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				if player:getWeaponStorageMax("Nuke") > 0 then
					if comms_target.nukeAvail then
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if player:getWeaponStorageMax("EMP") > 0 then
					if comms_target.empAvail then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost("EMP") .. " rep each)", function()
							handleWeaponRestock("EMP")
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if player:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost("Homing") .. " rep each)", function()
							handleWeaponRestock("Homing")
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if player:getWeaponStorageMax("Mine") > 0 then
					if comms_target.mineAvail then
						if math.random(1,10) <= 5 then
							minePrompt = "We could use some mines. ("
						else
							minePrompt = "How about mines? ("
						end
						addCommsReply(minePrompt .. getWeaponCost("Mine") .. " rep each)", function()
							handleWeaponRestock("Mine")
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if player:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost("HVLI") .. " rep each)", function()
							handleWeaponRestock("HVLI")
						end)
					end	--end station has HVLI for player if branch
				end	--end player can accept HVLI if branch
			end)	--end player requests secondary ordnance comms reply branch
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
	if comms_target.publicRelations then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply("Back", commsStation)
			end)
			if comms_target.stationHistory ~= nil then
				addCommsReply("Station history", function()
					setCommsMessage(comms_target.stationHistory)
					addCommsReply("Back", commsStation)
				end)
			end
			if player:isFriendly(comms_target) then
				if comms_target.gossip ~= nil then
					if random(1,100) < 70 then
						addCommsReply("Gossip", function()
							setCommsMessage(comms_target.gossip)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
		end)	--end station info comms reply branch
	end	--end public relations if branch
	if enemyEverDetected then
		addCommsReply("Why the yellow neutral border zones?", function()
			setCommsMessage("Each neutral border zone is equipped with sensors and an auto-transmitter. If the sensors detect enemy forces in the zone, the auto-transmitter sends encoded zone identifying details through subspace. Human navy ships are equipped to recognize this data and color code the appropriate zone on the science and relay consoles.")
		end)
	end
	if comms_target.character ~= nil then
		addCommsReply(string.format("Tell me about %s",comms_target.character), function()
			if comms_target.characterDescription ~= nil then
				setCommsMessage(comms_target.characterDescription)
			else
				if comms_target.characterDeadEnd == nil then
					local deadEndChoice = math.random(1,5)
					if deadEndChoice == 1 then
						comms_target.characterDeadEnd = "Never heard of " .. comms_target.character
					elseif deadEndChoice == 2 then
						comms_target.characterDeadEnd = comms_target.character .. " died last week. The funeral was yesterday"
					elseif deadEndChoice == 3 then
						comms_target.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",comms_target.character,comms_target.character,comms_target.character)
					elseif deadEndChoice == 4 then
						comms_target.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",comms_target.character)
					else
						comms_target.characterDeadEnd = string.format("I think %s moved away",comms_target.character)
					end
				end
				setCommsMessage(comms_target.characterDeadEnd)
			end
			if comms_target.characterFunction == "shrinkBeamCycle" then
				shrinkBeamCycle()
			end
			if comms_target.characterFunction == "increaseSpin" then
				increaseSpin()
			end
			if comms_target.characterFunction == "addAuxTube" then
				addAuxTube()
			end
			if comms_target.characterFunction == "coolBeam" then
				coolBeam()
			end
			if comms_target.characterFunction == "longerBeam" then
				longerBeam()
			end
			if comms_target.characterFunction == "damageBeam" then
				damageBeam()
			end
			if comms_target.characterFunction == "moreMissiles" then
				moreMissiles()
			end
			if comms_target.characterFunction == "fasterImpulse" then
				fasterImpulse()
			end
			if comms_target.characterFunction == "strongerHull" then
				strongerHull()
			end
			if comms_target.characterFunction == "efficientBatteries" then
				efficientBatteries()
			end
			if comms_target.characterFunction == "strongerShields" then
				strongerShields()
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		if math.random(1,5) <= (3 - difficulty) then
			if player:getRepairCrewCount() < player.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not player:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					player:setRepairCrewCount(player:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
			end)
		end
	else
		if math.random(1,5) <= (3 - difficulty) then
			if player:getRepairCrewCount() < player.maxRepairCrew then
				hireCost = math.random(45,90)
			else
				hireCost = math.random(60,120)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not player:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					player:setRepairCrewCount(player:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
			end)
		end
	end
	if goods[comms_target] ~= nil then
		addCommsReply("Buy, sell, trade", function()
			oMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation\n",comms_target:getCallSign())
			local gi = 1		-- initialize goods index
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. "Current Cargo:\n"
			gi = 1
			local cargoHoldEmpty = true
			repeat
				local playerGoodsType = goods[player][gi][1]
				local playerGoodsQuantity = goods[player][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[player])
			if cargoHoldEmpty then
				oMsg = oMsg .. "     Empty\n"
			end
			local playerRep = math.floor(player:getReputationPoints())
			oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format("Type: %s, Quantity: %i, Rep: %i",goodsType,goodsQuantity,goodsRep)
					if player.cargo < 1 then
						oMsg = oMsg .. "\nInsufficient cargo space for purchase"
					elseif goodsRep > playerRep then
						oMsg = oMsg .. "\nInsufficient reputation for purchase"
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. "\nInsufficient station inventory"
					else
						if not player:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. "\nInsufficient reputation for purchase"
						else
							player.cargo = player.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. "\npurchased"
						end
					end
					setCommsMessage(oMsg)
					addCommsReply("Back", commsStation)
				end)	--end buy goods from station for player reputation comms reply branch
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				local foodQuantity = 0
				repeat
					if goods[player][gi][1] == "food" then
						foodQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if foodQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format("Trade food for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)	--end trade food on player ship for goods on station comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end food available on player ship if branch
			end	--end food trade if branch
			-- Buttons for luxury trades
			if tradeLuxury[comms_target] ~= nil then
				gi = 1
				local luxuryQuantity = 0
				repeat
					if goods[player][gi][1] == "luxury" then
						luxuryQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if luxuryQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)	--end trade luxury on player ship for goods on station comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end luxury available on player ship if branch
			end	--end luxury trade if branch
			-- Buttons for medicine trades
			if tradeMedicine[comms_target] ~= nil then
				gi = 1
				local medicineQuantity = 0
				repeat
					if goods[player][gi][1] == "medicine" then
						medicineQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if medicineQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format("Trade medicine for %s",goods[comms_target][gi][1]), function()
							oMsg = string.format("Type: %s,  Quantity: %i",goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. "\nInsufficient station inventory"
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. "\nTraded"
							end
							setCommsMessage(oMsg)
							addCommsReply("Back", commsStation)
						end)	--end trade medicine on player ship for goods on station comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end medicine available on player ship if branch
			end	--end medicine trade if branch
			addCommsReply("Back", commsStation)
		end)	--end of buy, sell trade comms reply branch
		gi = 1
		cargoHoldEmpty = true
		repeat
			playerGoodsType = goods[player][gi][1]
			playerGoodsQuantity = goods[player][gi][2]
			if playerGoodsQuantity > 0 then
				cargoHoldEmpty = false
			end
			gi = gi + 1
		until(gi > #goods[player])
		if not cargoHoldEmpty then
			addCommsReply("Jettison cargo", function()
				setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",player.cargo))
				gi = 1
				repeat
					local goodsType = goods[player][gi][1]
					local goodsQuantity = goods[player][gi][2]
					if goodsQuantity > 0 then
						addCommsReply(goodsType, function()
							decrementPlayerGoods(goodsType)
							player.cargo = player.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",goodsType))
							addCommsReply("Back", commsStation)
						end)
					end
					gi = gi + 1
				until(gi > #goods[player])
				addCommsReply("Back", commsStation)
			end)	--end of cargo present, allow jettison if and comms reply branch
		end	
	end	--end of goods present on comms target if branch
end	--end of handleDockedState function
function setOptionalOrders()
	optionalOrders = ""
end
function isAllowedTo(state)
    if state == "friend" and player:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not player:isEnemy(comms_target) then
        return true
    end
    return false
end

function handleWeaponRestock(weapon)
    if not player:isDocked(comms_target) then 
		setCommsMessage("You need to stay docked for that action.")
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == "EMP" then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
		if player:getReputationPoints() > points_per_item * item_amount then
			if player:takeReputationPoints(points_per_item * item_amount) then
				player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
				if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if player:getReputationPoints() > points_per_item then
				setCommsMessage("You can't afford as much as I'd like to give you")
				addCommsReply("Get just one", function()
					if player:takeReputationPoints(points_per_item) then
						player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + 1)
						if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
							setCommsMessage("You are fully loaded and ready to explode things.")
						else
							setCommsMessage("We generously resupplied you with one weapon charge.\nPut it to good use.")
						end
					else
						setCommsMessage("Not enough reputation.")
					end
					return
				end)
			else
				setCommsMessage("Not enough reputation.")
				return				
			end
		end
        addCommsReply("Back", commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end

function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if player:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	if comms_target.nukeAvail == nil then
		if math.random(1,10) <= (4 - difficulty) then
			comms_target.nukeAvail = true
		else
			comms_target.nukeAvail = false
		end
		if math.random(1,10) <= (5 - difficulty) then
			comms_target.empAvail = true
		else
			comms_target.empAvail = false
		end
		if math.random(1,10) <= (6 - difficulty) then
			comms_target.homeAvail = true
		else
			comms_target.homeAvail = false
		end
		if math.random(1,10) <= (7 - difficulty) then
			comms_target.mineAvail = true
		else
			comms_target.mineAvail = false
		end
		if math.random(1,10) <= (9 - difficulty) then
			comms_target.hvliAvail = true
		else
			comms_target.hvliAvail = false
		end
	end
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("What ordnance do you have available for restock?", function()
			local missileTypeAvailableCount = 0
			oMsg = ""
			if comms_target.nukeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Nuke"
			end
			if comms_target.empAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   EMP"
			end
			if comms_target.homeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Homing"
			end
			if comms_target.mineAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   Mine"
			end
			if comms_target.hvliAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				oMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				oMsg = "We have the following type of ordnance available for restock:" .. oMsg
			else
				oMsg = "We have the following types of ordnance available for restock:" .. oMsg
			end
			setCommsMessage(oMsg)
			addCommsReply("Back", commsStation)
		end)
		local goodsQuantityAvailable = 0
		local gi = 1
		repeat
			if goods[comms_target][gi][2] > 0 then
				goodsQuantityAvailable = goodsQuantityAvailable + goods[comms_target][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[comms_target])
		if goodsQuantityAvailable > 0 then
			addCommsReply("What goods do you have available for sale or trade?", function()
				oMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation\n",comms_target:getCallSign())
				gi = 1		-- initialize goods index
				repeat
					goodsType = goods[comms_target][gi][1]
					goodsQuantity = goods[comms_target][gi][2]
					goodsRep = goods[comms_target][gi][3]
					oMsg = oMsg .. string.format("   %14s: %2i, %3i\n",goodsType,goodsQuantity,goodsRep)
					gi = gi + 1
				until(gi > #goods[comms_target])
				setCommsMessage(oMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("Where can I find particular goods?", function()
			gkMsg = "Friendly stations generally have food or medicine or both. Neutral stations often trade their goods for food, medicine or luxury."
			if comms_target.goodsKnowledge == nil then
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations.\n\nCheck back later, someone else may have better knowledge"
				setCommsMessage(gkMsg)
				addCommsReply("Back", commsStation)
				fillStationBrains()
			else
				if #comms_target.goodsKnowledge == 0 then
					gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
				else
					gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
					for gk=1,#comms_target.goodsKnowledge do
						addCommsReply(comms_target.goodsKnowledgeType[gk],function()
							setCommsMessage(string.format("Station %s in sector %s has %s%s",comms_target.goodsKnowledge[gk],comms_target.goodsKnowledgeSector[gk],comms_target.goodsKnowledgeType[gk],comms_target.goodsKnowledgeTrade[gk]))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				setCommsMessage(gkMsg)
				addCommsReply("Back", commsStation)
			end
		end)
		if comms_target.publicRelations then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				addCommsReply("General information", function()
					setCommsMessage(comms_target.generalInformation)
					addCommsReply("Back", commsStation)
				end)
				if comms_target.stationHistory ~= nil then
					addCommsReply("Station history", function()
						setCommsMessage(comms_target.stationHistory)
						addCommsReply("Back", commsStation)
					end)
				end
				if player:isFriendly(comms_target) then
					if comms_target.gossip ~= nil then
						if random(1,100) < 50 then
							addCommsReply("Gossip", function()
								setCommsMessage(comms_target.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if enemyEverDetected then
			addCommsReply("Why the yellow neutral border zones?", function()
				setCommsMessage("Each neutral border zone is equipped with sensors and an auto-transmitter. If the sensors detect enemy forces in the zone, the auto-transmitter sends encoded zone identifying details through subspace. Human navy ships are equipped to recognize this data and color code the appropriate zone on the science and relay consoles.")
			end)
		end
		addCommsReply("Report status", function()
			msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply("Back", commsStation)
		end)
	end)
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
						if treaty then
							local tempAsteroid = VisualAsteroid():setPosition(player:getWaypoint(n))
							local waypointInBorderZone = false
							for i=1,#borderZone do
								if borderZone[i]:isInside(tempAsteroid) then
									waypointInBorderZone = true
									break
								end
							end
							if waypointInBorderZone then
								setCommsMessage("We cannot break the treaty by sending reinforcements to WP" .. n .. " in the neutral border zone")
							elseif outerZone:isInside(tempAsteroid) then
								setCommsMessage("We cannot break the treaty by sending reinforcements to WP" .. n .. " across the neutral border zones")							
							else
								if player:takeReputationPoints(getServiceCost("reinforcements")) then
									local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
									ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
									table.insert(friendlyHelperFleet,ship)
									setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
								else
									setCommsMessage("Not enough reputation!");
								end
							end
							tempAsteroid:destroy()
						else
							if player:takeReputationPoints(getServiceCost("reinforcements")) then
								ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
								ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
								table.insert(friendlyHelperFleet,ship)
								setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
							else
								setCommsMessage("Not enough reputation!");
							end
						end
                        addCommsReply("Back", commsStation)
                    end)
                end
            end
            addCommsReply("Back", commsStation)
        end)
    end
end

-- Return the number of reputation points that a specified service costs for
-- the current player.
function getServiceCost(service)
    return math.ceil(comms_data.service_cost[service])
end
function fillStationBrains()
	comms_target.goodsKnowledge = {}
	comms_target.goodsKnowledgeSector = {}
	comms_target.goodsKnowledgeType = {}
	comms_target.goodsKnowledgeTrade = {}
	local knowledgeCount = 0
	local knowledgeMax = 10
	for sti=1,#humanStationList do
		if humanStationList[sti] ~= nil and humanStationList[sti]:isValid() then
			if distance(comms_target,humanStationList[sti]) < 75000 then
				brainCheck = 3
			else
				brainCheck = 1
			end
			for gi=1,#goods[humanStationList[sti]] do
				if random(1,10) <= brainCheck then
					table.insert(comms_target.goodsKnowledge,humanStationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,humanStationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[humanStationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[humanStationList[sti]] ~= nil then
						tradeString = " and will trade it for medicine"
						stationTrades = true
					end
					if tradeFood[humanStationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or food"
						else
							tradeString = tradeString .. " and will trade it for food"
							stationTrades = true
						end
					end
					if tradeLuxury[humanStationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or luxury"
						else
							tradeString = tradeString .. " and will trade it for luxury"
						end
					end
					table.insert(comms_target.goodsKnowledgeTrade,tradeString)
					knowledgeCount = knowledgeCount + 1
					if knowledgeCount >= knowledgeMax then
						return
					end
				end
			end
		end
	end
end
function getFriendStatus()
    if player:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--[[-----------------------------------------------------------------
      Ship communication 
-----------------------------------------------------------------]]--
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if goods[comms_target] == nil then
		goods[comms_target] = {goodsList[irandom(1,#goodsList)][1], 1, random(20,80)}
	end
	comms_data = comms_target.comms_data
	setPlayers()
	for p4idx=1,8 do
		local p4obj = getPlayerShip(p4idx)
		if p4obj ~= nil and p4obj:isValid() then
			if p4obj:isCommsOpening() then
				player = p4obj
			end
		end
	end	
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
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	addCommsReply("Defend a waypoint", function()
		if player:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,player:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					if treaty then
						local tempAsteroid = VisualAsteroid():setPosition(player:getWaypoint(n))
						local waypointInBorderZone = false
						for i=1,#borderZone do
							if borderZone[i]:isInside(tempAsteroid) then
								waypointInBorderZone = true
								break
							end
						end
						if waypointInBorderZone then
							setCommsMessage("We cannot break the treaty by defending WP" .. n .. " in the neutral border zone")
						elseif outerZone:isInside(tempAsteroid) then
							setCommsMessage("We cannot break the treaty by defending WP" .. n .. " across the neutral border zones")							
						else
							comms_target:orderDefendLocation(player:getWaypoint(n))
							setCommsMessage("We are heading to assist at WP" .. n ..".");
						end
						tempAsteroid:destroy()
					else
						comms_target:orderDefendLocation(player:getWaypoint(n))
						setCommsMessage("We are heading to assist at WP" .. n ..".");
					end
					addCommsReply("Back", commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(player)
			addCommsReply("Back", commsShip)
		end)
	end
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
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

		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. " Missiles: " .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end
		
		setCommsMessage(msg);
		addCommsReply("Back", commsShip)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_data.friendlyness > 66 then
			-- Offer to trade goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					local gi = 1
					local luxuryQuantity = 0
					repeat
						if goods[player][gi][1] == "luxury" then
							luxuryQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if luxuryQuantity > 0 then
						gi = 1
						repeat
							local goodsType = goods[comms_target][gi][1]
							local goodsQuantity = goods[comms_target][gi][2]
							addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
								if goodsQuantity < 1 then
									setCommsMessage("Insufficient inventory on freighter for trade")
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage("Traded")
								end
								addCommsReply("Back", commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					end
				else	-- Offer to sell goods
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end sell goods comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end sell goods if branch
			end	--end nearby freighter if branch
		elseif comms_data.friendlyness > 33 then
			-- Offer to sell goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end buy goods from freighter comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				else	-- Offer to sell goods double price
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end buy goods from freighter comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end goods sold at double price else branch
			end	--end nearby freighter if branch
		else	--least friendly comms else branch
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end buy goods from freighter comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end goods or equipment freighter if branch
			end	--end nearby freighter if branch
		end	--end least friendly freighter comms else branch
	end
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		local faction = comms_target:getFaction()
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = "We will destroy you"
				taunt_success_reply = "We think not. It is you who will experience destruction!"
			elseif kraylorTauntChoice == 2 then
				taunt_option = "You have no honor"
				taunt_success_reply = "Your insult has brought our wrath upon you. Prepare to die."
				taunt_failed_reply = "Your comments about honor have no meaning to us"
			else
				taunt_option = "We pity your pathetic race"
				taunt_success_reply = "Pathetic? You will regret your disparagement!"
				taunt_failed_reply = "We don't care what you think of us"
			end
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
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if comms_data.friendlyness > 66 then
			setCommsMessage("Yes?")
			-- Offer destination information
			addCommsReply("Where are you headed?", function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply("Back", commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					local gi = 1
					local luxuryQuantity = 0
					repeat
						if goods[player][gi][1] == "luxury" then
							luxuryQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if luxuryQuantity > 0 then
						gi = 1
						repeat
							local goodsType = goods[comms_target][gi][1]
							local goodsQuantity = goods[comms_target][gi][2]
							addCommsReply(string.format("Trade luxury for %s",goods[comms_target][gi][1]), function()
								if goodsQuantity < 1 then
									setCommsMessage("Insufficient inventory on freighter for trade")
								else
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									decrementPlayerGoods("luxury")
									setCommsMessage("Traded")
								end
								addCommsReply("Back", commsShip)
							end)
							gi = gi + 1
						until(gi > #goods[comms_target])
					else
						setCommsMessage("Insufficient luxury to trade")
					end
					addCommsReply("Back", commsShip)
				else	-- Offer to sell goods
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end sell goods comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end sell goods if branch
			end	--end nearby freighter if branch
		elseif comms_data.friendlyness > 33 then
			setCommsMessage("What do you want?")
			-- Offer to sell destination information
			local destRep = random(1,5)
			addCommsReply(string.format("Where are you headed? (cost: %f reputation)",destRep), function()
				if not player:takeReputationPoints(destRep) then
					setCommsMessage("Insufficient reputation")
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply("Back", commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end buy goods from freighter comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				else	-- Offer to sell goods double price
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end buy goods from freighter comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end goods sold at double price else branch
			end	--end nearby freighter if branch
		else	--least friendly comms else branch
			setCommsMessage("Why are you bothering me?")
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(player,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format("Buy one %s for %i reputation",goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if player.cargo < 1 then
								setCommsMessage("Insufficient cargo space for purchase")
							elseif goodsQuantity < 1 then
								setCommsMessage("Insufficient inventory on freighter")
							else
								if not player:takeReputationPoints(goodsRep) then
									setCommsMessage("Insufficient reputation for purchase")
								else
									player.cargo = player.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage("Purchased")
								end
							end
							addCommsReply("Back", commsShip)
						end)	--end buy goods from freighter comms reply branch
						gi = gi + 1
					until(gi > #goods[comms_target])
				end	--end goods or equipment freighter if branch
			end	--end nearby freighter if branch
		end	--end least friendly freighter comms else branch
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
--[[-----------------------------------------------------------------
      Cargo management 
-----------------------------------------------------------------]]--
function incrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[player][gi][1] == goodsType then
			goods[player][gi][2] = goods[player][gi][2] + 1
		end
		gi = gi + 1
	until(gi > #goods[player])
end
function decrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[player][gi][1] == goodsType then
			goods[player][gi][2] = goods[player][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[player])
end
function decrementStationGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
function decrementShipGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_target][gi][1] == goodsType then
			goods[comms_target][gi][2] = goods[comms_target][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_target])
end
--[[-----------------------------------------------------------------
      Utility functions 
-----------------------------------------------------------------]]--
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
		end
	end
end
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
function closestPlayerTo(obj)
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		local closestPlayer = nil
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance < closestDistance then
					closestPlayer = p
					closestDistance = currentDistance
				end
			end
		end
		return closestPlayer
	else
		return nil
	end
end
--nobj = named object for comparison purposes (stations, players, etc)
--compareStationList = list of stations to compare against
function nearStations(nobj, compareStationList)
	local remainingStations = {}
	local closestDistance = 9999999
	for ri, obj in ipairs(compareStationList) do
		if obj ~= nil and obj:isValid() and obj:getCallSign() ~= nobj:getCallSign() then
			table.insert(remainingStations,obj)
			local currentDistance = distance(nobj, obj)
			if currentDistance < closestDistance then
				closestObj = obj
				closestDistance = currentDistance
			end
		end
	end
	for i=1,#remainingStations do
		if remainingStations[i]:getCallSign() == closestObj:getCallSign() then
			table.remove(remainingStations,i)
			break
		end
	end
	return closestObj, remainingStations
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	local enemyStrength = math.max(danger * difficulty * playerPower(),5)
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		local shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		local ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		if enemyFaction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + stsl[shipTemplateType]
			ship:onDestruction(enemyVesselDestroyed)
		elseif enemyFaction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + stsl[shipTemplateType]
			ship:onDestruction(friendlyVesselDestroyed)
		end
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
--evaluate the players for enemy strength and size spawning purposes
function playerPower()
	local playerShipScore = 0
	for p5idx=1,8 do
		local p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	return playerShipScore
end
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if healthDiagnostic then print("health check timer expired") end
		for pidx=1,8 do
			if healthDiagnostic then print("in player loop") end
			local p = getPlayerShip(pidx)
			if healthDiagnostic then print("got player ship") end
			if p ~= nil and p:isValid() then
				if healthDiagnostic then print("valid ship") end
				if p:getRepairCrewCount() > 0 then
					if healthDiagnostic then print("crew on valid ship") end
					local fatalityChance = 0
					if healthDiagnostic then print("shields") end
					sc = p:getShieldCount()
					if healthDiagnostic then print("sc: " .. sc) end
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					if healthDiagnostic then print("reactor") end
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					if healthDiagnostic then print("maneuver") end
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					if healthDiagnostic then print("impulse") end
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if healthDiagnostic then print("beamweapons") end
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
						p.prevBeam = p:getSystemHealth("beamweapons")
					end
					if healthDiagnostic then print("missilesystem") end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if healthDiagnostic then print("warp") end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
						p.prevWarp = p:getSystemHealth("warp")
					end
					if healthDiagnostic then print("jumpdrive") end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
						p.prevJump = p:getSystemHealth("jumpdrive")
					end
					if healthDiagnostic then print("adjust") end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
					end
					if healthDiagnostic then print("check") end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		p:setRepairCrewCount(p:getRepairCrewCount() - 1)
		if p:hasPlayerAtPosition("Engineering") then
			local repairCrewFatality = "repairCrewFatality"
			p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
		end
		if p:hasPlayerAtPosition("Engineering+") then
			local repairCrewFatalityPlus = "repairCrewFatalityPlus"
			p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
		end
	end
end
--[[-----------------------------------------------------------------
      Inventory button for relay/operations 
-----------------------------------------------------------------]]--
function cargoInventory(delta)
	if cargoInventoryList == nil then
		cargoInventoryList = {}
		table.insert(cargoInventoryList,cargoInventory1)
		table.insert(cargoInventoryList,cargoInventory2)
		table.insert(cargoInventoryList,cargoInventory3)
		table.insert(cargoInventoryList,cargoInventory4)
		table.insert(cargoInventoryList,cargoInventory5)
		table.insert(cargoInventoryList,cargoInventory6)
		table.insert(cargoInventoryList,cargoInventory7)
		table.insert(cargoInventoryList,cargoInventory8)
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[p][gi][1]
				playerGoodsQuantity = goods[p][gi][2]
				if playerGoodsQuantity > 0 then
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[p])
			if not cargoHoldEmpty then
				if p:hasPlayerAtPosition("Relay") then
					if p.inventoryButton == nil then
						local tbi = "inventory" .. p:getCallSign()
						p:addCustomButton("Relay",tbi,"Inventory",cargoInventoryList[pidx])
						p.inventoryButton = true
					end
				end
				if p:hasPlayerAtPosition("Operations") then
					if p.inventoryButton == nil then
						local tbi = "inventoryOp" .. p:getCallSign()
						p:addCustomButton("Operations",tbi,"Inventory",cargoInventoryList[pidx])
						p.inventoryButton = true
					end
				end
			end
		end
	end
end
function cargoInventory1()
	local p = getPlayerShip(1)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory2()
	local p = getPlayerShip(2)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory3()
	local p = getPlayerShip(3)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory4()
	local p = getPlayerShip(4)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory5()
	local p = getPlayerShip(5)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory6()
	local p = getPlayerShip(6)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory7()
	local p = getPlayerShip(7)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory8()
	local p = getPlayerShip(8)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	gi = 1
	local cargoHoldEmpty = true
	repeat
		local playerGoodsType = goods[p][gi][1]
		local playerGoodsQuantity = goods[p][gi][2]
		if playerGoodsQuantity > 0 then
			p:addToShipLog(string.format("     %s: %i",playerGoodsType,playerGoodsQuantity),"Yellow")
			cargoHoldEmpty = false
		end
		gi = gi + 1
	until(gi > #goods[p])
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
--[[-----------------------------------------------------------------
      Enable and disable auto-cooling on a ship 
-----------------------------------------------------------------]]--
function autoCoolant(delta)
	if enableAutoCoolFunctionList == nil then
		enableAutoCoolFunctionList = {}
		table.insert(enableAutoCoolFunctionList,enableAutoCool1)
		table.insert(enableAutoCoolFunctionList,enableAutoCool2)
		table.insert(enableAutoCoolFunctionList,enableAutoCool3)
		table.insert(enableAutoCoolFunctionList,enableAutoCool4)
		table.insert(enableAutoCoolFunctionList,enableAutoCool5)
		table.insert(enableAutoCoolFunctionList,enableAutoCool6)
		table.insert(enableAutoCoolFunctionList,enableAutoCool7)
		table.insert(enableAutoCoolFunctionList,enableAutoCool8)
	end
	if disableAutoCoolFunctionList == nil then
		disableAutoCoolFunctionList = {}
		table.insert(disableAutoCoolFunctionList,disableAutoCool1)
		table.insert(disableAutoCoolFunctionList,disableAutoCool2)
		table.insert(disableAutoCoolFunctionList,disableAutoCool3)
		table.insert(disableAutoCoolFunctionList,disableAutoCool4)
		table.insert(disableAutoCoolFunctionList,disableAutoCool5)
		table.insert(disableAutoCoolFunctionList,disableAutoCool6)
		table.insert(disableAutoCoolFunctionList,disableAutoCool7)
		table.insert(disableAutoCoolFunctionList,disableAutoCool8)
	end
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.autoCoolant ~= nil then
				if p:hasPlayerAtPosition("Engineering") then
					if p.autoCoolButton == nil then
						local tbi = "enableAutoCool" .. p:getCallSign()
						p:addCustomButton("Engineering",tbi,"Auto cool",enableAutoCoolFunctionList[pidx])
						tbi = "disableAutoCool" .. p:getCallSign()
						p:addCustomButton("Engineering",tbi,"Manual cool",disableAutoCoolFunctionList[pidx])
						p.autoCoolButton = true
					end
				end
				if p:hasPlayerAtPosition("Engineering+") then
					if p.autoCoolButton == nil then
						tbi = "enableAutoCoolPlus" .. p:getCallSign()
						p:addCustomButton("Engineering+",tbi,"Auto cool",enableAutoCoolFunctionList[pidx])
						tbi = "disableAutoCoolPlus" .. p:getCallSign()
						p:addCustomButton("Engineering+",tbi,"Manual cool",disableAutoCoolFunctionList[pidx])
						p.autoCoolButton = true
					end
				end
			end
		end
	end
end
function enableAutoCool1()
	local p = getPlayerShip(1)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool1()
	local p = getPlayerShip(1)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool2()
	local p = getPlayerShip(2)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool2()
	local p = getPlayerShip(2)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool3()
	local p = getPlayerShip(3)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool3()
	local p = getPlayerShip(3)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool4()
	local p = getPlayerShip(4)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool4()
	local p = getPlayerShip(4)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool5()
	local p = getPlayerShip(5)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool5()
	local p = getPlayerShip(5)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool6()
	local p = getPlayerShip(6)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool6()
	local p = getPlayerShip(6)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool7()
	local p = getPlayerShip(7)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool7()
	local p = getPlayerShip(7)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool8()
	local p = getPlayerShip(8)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool8()
	local p = getPlayerShip(8)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
function setPlayers()
	concurrentPlayerCount = 0
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(500-(difficulty*20))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				local tempPlayerType = pobj:getTypeName()
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesForMP52Hornet > 0 then
						local ni = math.random(1,#playerShipNamesForMP52Hornet)
						pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
						table.remove(playerShipNamesForMP52Hornet,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Piranha" then
					if #playerShipNamesForPiranha > 0 then
						ni = math.random(1,#playerShipNamesForPiranha)
						pobj:setCallSign(playerShipNamesForPiranha[ni])
						table.remove(playerShipNamesForPiranha,ni)
					end
					pobj.shipScore = 16
					pobj.maxCargo = 8
				elseif tempPlayerType == "Flavia P.Falcon" then
					if #playerShipNamesForFlaviaPFalcon > 0 then
						ni = math.random(1,#playerShipNamesForFlaviaPFalcon)
						pobj:setCallSign(playerShipNamesForFlaviaPFalcon[ni])
						table.remove(playerShipNamesForFlaviaPFalcon,ni)
					end
					pobj.shipScore = 13
					pobj.maxCargo = 15
				elseif tempPlayerType == "Phobos M3P" then
					if #playerShipNamesForPhobosM3P > 0 then
						ni = math.random(1,#playerShipNamesForPhobosM3P)
						pobj:setCallSign(playerShipNamesForPhobosM3P[ni])
						table.remove(playerShipNamesForPhobosM3P,ni)
					end
					pobj.shipScore = 19
					pobj.maxCargo = 10
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Atlantis" then
					if #playerShipNamesForAtlantis > 0 then
						ni = math.random(1,#playerShipNamesForAtlantis)
						pobj:setCallSign(playerShipNamesForAtlantis[ni])
						table.remove(playerShipNamesForAtlantis,ni)
					end
					pobj.shipScore = 52
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Cruiser" then
					if #playerShipNamesForCruiser > 0 then
						ni = math.random(1,#playerShipNamesForCruiser)
						pobj:setCallSign(playerShipNamesForCruiser[ni])
						table.remove(playerShipNamesForCruiser,ni)
					end
					pobj.shipScore = 40
					pobj.maxCargo = 6
				elseif tempPlayerType == "Player Missile Cr." then
					if #playerShipNamesForMissileCruiser > 0 then
						ni = math.random(1,#playerShipNamesForMissileCruiser)
						pobj:setCallSign(playerShipNamesForMissileCruiser[ni])
						table.remove(playerShipNamesForMissileCruiser,ni)
					end
					pobj.shipScore = 45
					pobj.maxCargo = 8
				elseif tempPlayerType == "Player Fighter" then
					if #playerShipNamesForFighter > 0 then
						ni = math.random(1,#playerShipNamesForFighter)
						pobj:setCallSign(playerShipNamesForFighter[ni])
						table.remove(playerShipNamesForFighter,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "Benedict" then
					if #playerShipNamesForBenedict > 0 then
						ni = math.random(1,#playerShipNamesForBenedict)
						pobj:setCallSign(playerShipNamesForBenedict[ni])
						table.remove(playerShipNamesForBenedict,ni)
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Kiriya" then
					if #playerShipNamesForKiriya > 0 then
						ni = math.random(1,#playerShipNamesForKiriya)
						pobj:setCallSign(playerShipNamesForKiriya[ni])
						table.remove(playerShipNamesForKiriya,ni)
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == "Striker" then
					if #playerShipNamesForStriker > 0 then
						ni = math.random(1,#playerShipNamesForStriker)
						pobj:setCallSign(playerShipNamesForStriker[ni])
						table.remove(playerShipNamesForStriker,ni)
					end
					pobj.shipScore = 8
					pobj.maxCargo = 4
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
				elseif tempPlayerType == "ZX-Lindworm" then
					if #playerShipNamesForLindworm > 0 then
						ni = math.random(1,#playerShipNamesForLindworm)
						pobj:setCallSign(playerShipNamesForLindworm[ni])
						table.remove(playerShipNamesForLindworm,ni)
					end
					pobj.shipScore = 8
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Repulse" then
					if #playerShipNamesForRepulse > 0 then
						ni = math.random(1,#playerShipNamesForRepulse)
						pobj:setCallSign(playerShipNamesForRepulse[ni])
						table.remove(playerShipNamesForRepulse,ni)
					end
					pobj.shipScore = 14
					pobj.maxCargo = 12
				elseif tempPlayerType == "Ender" then
					if #playerShipNamesForEnder > 0 then
						ni = math.random(1,#playerShipNamesForEnder)
						pobj:setCallSign(playerShipNamesForEnder[ni])
						table.remove(playerShipNamesForEnder,ni)
					end
					pobj.shipScore = 100
					pobj.maxCargo = 20
				elseif tempPlayerType == "Nautilus" then
					if #playerShipNamesForNautilus > 0 then
						ni = math.random(1,#playerShipNamesForNautilus)
						pobj:setCallSign(playerShipNamesForNautilus[ni])
						table.remove(playerShipNamesForNautilus,ni)
					end
					pobj.shipScore = 12
					pobj.maxCargo = 7
				elseif tempPlayerType == "Hathcock" then
					if #playerShipNamesForHathcock > 0 then
						ni = math.random(1,#playerShipNamesForHathcock)
						pobj:setCallSign(playerShipNamesForHathcock[ni])
						table.remove(playerShipNamesForHathcock,ni)
					end
					pobj.shipScore = 30
					pobj.maxCargo = 6
				else
					if #playerShipNamesForLeftovers > 0 then
						ni = math.random(1,#playerShipNamesForLeftovers)
						pobj:setCallSign(playerShipNamesForLeftovers[ni])
						table.remove(playerShipNamesForLeftovers,ni)
					end
					pobj.shipScore = 24
					pobj.maxCargo = 5
					pobj:setWarpDrive(true)
				end
				if pobj.cargo == nil then
					pobj.cargo = pobj.maxCargo
					pobj.maxRepairCrew = pobj:getRepairCrewCount()
					pobj.healthyShield = 1.0
					pobj.prevShield = 1.0
					pobj.healthyReactor = 1.0
					pobj.prevReactor = 1.0
					pobj.healthyManeuver = 1.0
					pobj.prevManeuver = 1.0
					pobj.healthyImpulse = 1.0
					pobj.prevImpulse = 1.0
					if pobj:getBeamWeaponRange(0) > 0 then
						pobj.healthyBeam = 1.0
						pobj.prevBeam = 1.0
					end
					if pobj:getWeaponTubeCount() > 0 then
						pobj.healthyMissile = 1.0
						pobj.prevMissile = 1.0
					end
					if pobj:hasWarpDrive() then
						pobj.healthyWarp = 1.0
						pobj.prevWarp = 1.0
					end
					if pobj:hasJumpDrive() then
						pobj.healthyJump = 1.0
						pobj.prevJump = 1.0
					end
				end
			end
		end
	end
	setConcurrenetPlayerCount = concurrentPlayerCount
end
--[[-------------------------------------------------------------------
	Transport plot 
--]]-------------------------------------------------------------------
function randomStation(randomStations)
	local randomlySelectedStation = nil
	local stationAttemptCount = 0
	repeat
		stationAttemptCount = stationAttemptCount + 1
		local candidate = randomStations[math.random(1,#randomStations)]
		if candidate ~= nil and candidate:isValid() then
			randomlySelectedStation = candidate
		end
	until(randomlySelectedStation ~= nil or stationAttemptCount > 100)
	return randomlySelectedStation
end
--pool = number of nearest stations to randomly choose from
--nobj = named object for comparison purposes
--partialStationList = list of station to compare against
function randomNearStation(pool,nobj,partialStationList)
	local distanceStations = {}
	local rs = {}
	local ni
	local cs
	cs, rs[1] = nearStations(nobj,partialStationList)
	table.insert(distanceStations,cs)
	for ni=2,pool do
		cs, rs[ni] = nearStations(nobj,rs[ni-1])
		table.insert(distanceStations,cs)
	end
	randomlySelectedStation = distanceStations[math.random(1,pool)]
	return randomlySelectedStation
end
function kraylorTransportPlot(delta)
	if kraylorTransportSpawnDelay > 0 then
		kraylorTransportSpawnDelay = kraylorTransportSpawnDelay - delta
	end
	if kraylorTransportSpawnDelay < 0 then
		kraylorTransportSpawnDelay = delta + random(8,20)
		kraylorTransportCount = 0
		invalidKraylorTransportCount = 0
		for kidx, kobj in ipairs(kraylorTransportList) do
			if kobj:isValid() then
				kraylorTransportCount = kraylorTransportCount + 1
				if kobj.target ~= nil and kobj.target:isValid() then
					if kobj:isDocked(kobj.target) then
						if kobj.undock_delay > 0 then
							kobj.undock_delay = kobj.undock_delay - 1
						else
							kobj.target = randomNearStation(math.random(math.min(3,#kraylorStationList),math.min(7,#kraylorStationList)),kobj,kraylorStationList)
							kobj.undock_delay = math.random(1,4)
							kobj:orderDock(kobj.target)
						end
					end
				else
					kobj.target = randomNearStation(math.random(math.min(3,#kraylorStationList),math.min(7,#kraylorStationList)),kobj,kraylorStationList)
					kobj.undock_delay = math.random(1,4)
					kobj:orderDock(kobj.target)
				end
			else
				invalidKraylorTransportCount = invalidKraylorTransportCount + 1
			end
		end
		if invalidKraylorTransportCount > 0 then
			kraylorTransportCount = 0
			tempTransportList = {}
			for _, kobj in ipairs(kraylorTransportList) do
				if kobj ~= nil and kobj:isValid() then
					table.insert(tempTransportList,kobj)
					kraylorTransportCount = kraylorTransportCount + 1
				end
			end
			kraylorTransportList = tempTransportList
		end
		if kraylorTransportCount < math.max(#kraylorStationList/2,5) then
			target = nil
			transportAttemptCount = 0
			repeat
				transportAttemptCount = transportAttemptCount + 1
				target = randomStation(kraylorStationList)
			until((target ~= nil and target:isValid()) or transportAttemptCount > 100)
			if target ~= nil and target:isValid() then
				rnd = math.random(1,5)
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
				if random(1,100) < 40 then
					name = name .. " Jump Freighter " .. irandom(3, 5)
				else
					name = name .. " Freighter " .. irandom(1, 5)
				end
				kobj = CpuShip():setTemplate(name):setFaction('Kraylor'):setCommsScript(""):setCommsFunction(commsShip)
				kobj.target = target
				kobj.undock_delay = math.random(1,4)
				kobj:orderDock(kobj.target)
				kx, ky = kobj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				kobj:setPosition(kx + xd, ky + yd)
				table.insert(kraylorTransportList,kobj)
			end
		end
	end
end
function independentTransportPlot(delta)
	if independentTransportSpawnDelay > 0 then
		independentTransportSpawnDelay = independentTransportSpawnDelay - delta
	end
	if independentTransportSpawnDelay < 0 then
		independentTransportSpawnDelay = delta + random(10,30)
		independentTransportCount = 0
		invalidIndependentTransportCount = 0
		for tidx, obj in ipairs(independentTransportList) do
			if obj:isValid() then
				independentTransportCount = independentTransportCount + 1
				if obj.target ~= nil and obj.target:isValid() then
					if obj:isDocked(obj.target) then
						if obj.undock_delay > 0 then
							obj.undock_delay = obj.undock_delay - 1
						else
							obj.target = randomNearStation(math.random(math.min(4,#neutralStationList),math.min(8,#neutralStationList)),obj,neutralStationList)
							obj.undock_delay = math.random(1,4)
							obj:orderDock(obj.target)
						end
					end
				else
					obj.target = randomNearStation(math.random(math.min(4,#neutralStationList),math.min(8,#neutralStationList)),obj,neutralStationList)
					obj.undock_delay = math.random(1,4)
					obj:orderDock(obj.target)
				end
			else
				invalidIndependentTransportCount = invalidIndependentTransportCount + 1
			end
		end
		if invalidIndependentTransportCount > 0 then
			independentTransportCount = 0
			tempTransportList = {}
			for _, obj in ipairs(independentTransportList) do
				if obj ~= nil and obj:isValid() then
					table.insert(independentTransportList,obj)
					independentTransportCount = independentTransportCount + 1
				end
			end
			independentTransportList = tempTransportList
		end
		if independentTransportCount < #neutralStationList then
			target = nil
			transportAttemptCount = 0
			repeat
				transportAttemptCount = transportAttemptCount + 1
				target = randomStation(neutralStationList)				
			until((target ~= nil and target:isValid()) or transportAttemptCount > 100)
			if target ~= nil and target:isValid() then
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
				if irandom(1,100) < 30 then
					name = name .. " Jump Freighter " .. irandom(3, 5)
				else
					name = name .. " Freighter " .. irandom(1, 5)
				end
				obj = CpuShip():setTemplate(name):setFaction('Independent'):setCommsScript(""):setCommsFunction(commsShip)
				obj.target = target
				obj.undock_delay = irandom(1,4)
				rifl = math.floor(random(1,#goodsList))	-- random item from list
				goodsType = goodsList[rifl][1]
				if goodsType == nil then
					goodsType = "nickel"
				end
				rcoi = math.floor(random(30,90))	-- random cost of item
				goods[obj] = {{goodsType,1,rcoi}}
				obj:orderDock(obj.target)
				x, y = obj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				obj:setPosition(x + xd, y + yd)
				table.insert(independentTransportList, obj)
			end
		end
	end
end
function friendlyTransportPlot(delta)
	if friendlyTransportSpawnDelay > 0 then
		friendlyTransportSpawnDelay = friendlyTransportSpawnDelay - delta
	end
	local friendlyTransportCount = 0
	if friendlyTransportSpawnDelay < 0 then
		friendlyTransportSpawnDelay = delta + random(10,30)
		for tidx, obj in ipairs(friendlyTransportList) do
			if obj ~= nil and obj:isValid() then
				friendlyTransportCount = friendlyTransportCount + 1
				if obj.target ~= nil and obj.target:isValid() then
					if obj:isDocked(obj.target) then
						if obj.undock_delay > 0 then
							obj.undock_delay = obj.undock_delay - 1
						else
							obj.target = randomNearStation(math.random(math.min(4,#humanStationList),math.min(8,#humanStationList)),obj,humanStationList)
							obj.undock_delay = math.random(1,4)
							obj:orderDock(obj.target)
						end
					end
				else
					local transportAttemptCount = 0
					local lowerNear = math.min(4,#humanStationList)
					local upperNear = math.min(8,#humanStationList)
					local randomPool = math.random(lowerNear,upperNear)
					repeat
						transportAttemptCount = transportAttemptCount + 1
						local candidate = randomNearStation(randomPool,obj,humanStationList)
					until((candidate ~= nil and candidate:isValid()) or transportAttemptCount > repeatExitBoundary)
					if candidate ~= nil and candidate:isValid() then
						obj.target = candidate
						obj.undock_delay = math.random(1,4)
						obj:orderDock(obj.target)
					end
				end
			end
		end
		if friendlyTransportCount < math.max(#humanStationList/2,5) then
			target = nil
			local transportAttemptCount = 0
			repeat
				transportAttemptCount = transportAttemptCount + 1
				target = randomStation(humanStationList)				
			until((target ~= nil and target:isValid()) or transportAttemptCount > repeatExitBoundary)
			if target ~= nil and target:isValid() then
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
				if irandom(1,100) < 30 then
					fSize = irandom(3, 5)
					name = name .. " Jump Freighter " .. fSize
				else
					fSize = irandom(1, 5)
					name = name .. " Freighter " .. fSize
				end
				obj = CpuShip():setTemplate(name):setFaction('Human Navy'):setCommsScript(""):setCommsFunction(commsShip)
				obj.target = target
				obj.undock_delay = irandom(1,4)
				local rifl = math.floor(random(1,#goodsList))	-- random item from list
				goodsType = goodsList[rifl][1]
				if goodsType == nil then
					goodsType = "nickel"
				end
				local rcoi = math.floor(random(30,90))	-- random cost of item
				goods[obj] = {{goodsType,fSize,rcoi}}
				obj:orderDock(obj.target)
				x, y = obj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				obj:setPosition(x + xd, y + yd)
				table.insert(friendlyTransportList, obj)
			end
		end
	end
end
--[[-----------------------------------------------------------------
    Plot 1 peace/treaty/war states
-----------------------------------------------------------------]]--
function treatyHolds(delta)
	primaryOrders = "Treaty holds. Patrol border. Stay out of blue neutral border zone"
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() and p.order1 == nil then
			if p.nameAssigned then
				p:addToShipLog(string.format("Greetings captain and crew of %s. The Human/Kraylor treaty has held for a number of years now, but tensions are rising. Your mission: patrol the border area for Kraylor ships. Do not enter the blue neutral border zone. Good luck",p:getCallSign()),"Magenta")
				p.order1 = "sent"
			else
				setPlayers()
			end
		end
	end
	if treatyTimer == nil then
		if playWithTimeLimit then
			treatyTimer = random(lrr4,urr4)
		else
			treatyTimer = random(lrr5,urr5)
		end
	end
	if playWithTimeLimit then
		if gameTimeLimit < 1700 and not initialAssetsEvaluated then
			evaluateInitialAssets()
		end
	else
		if treatyTimer < 40 and not initialAssetsEvaluated then
			evaluateInitialAssets()
		end
	end
	treatyTimer = treatyTimer - delta
	if treatyTimer < 0 then
		if playWithTimeLimit then
			treatyStressTimer = random(lrr4,urr4)
		else
			treatyStressTimer = random(lrr5,urr5)
		end
		primaryOrders = "Treaty holds, Kraylors belligerent. Patrol border. Stay out of blue neutral border zone"
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if not p.nameAssigned then
					setPlayers()
				end
				p:addToShipLog(string.format("%s, The Kraylors threaten to break the treaty. We characterize this behavior as mere sabre rattling. Nevertheless, keep a close watch on the neutral border zone. Until war is actually declared, you are not, I repeat, *not* authorized to enter the neutral border zone",p:getCallSign()),"Magenta")
			end
		end
		if GMBelligerentKraylors ~= nil then
			removeGMFunction(GMBelligerentKraylors)
		end
		GMBelligerentKraylors = nil
		plot1 = treatyStressed
	end
end
function treatyStressed(delta)
	treatyStressTimer = treatyStressTimer - delta
	if not initialAssetsEvaluated then
		if gameTimeLimit < 1700 then
			evaluateInitialAssets()
		end
	end
	if treatyStressTimer < 0 then
		if playWithTimeLimit then
			limitedWarTimer = gameTimeLimit/2
		else
			limitedWarTimer = random(300,600)
		end
		for i=1,#borderZone do
			borderZone[i]:setColor(255,0,0)
		end
		primaryOrders = "War declared. Destroy any Kraylor vessels. Avoid destruction of Kraylor stations"
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if not p.nameAssigned then
					setPlayers()
				end
				p:addToShipLog(string.format("To: Commanding Officer of %s",p:getCallSign()),"Magenta")
				p:addToShipLog("From: Human Navy Headquarters","Magenta")
				p:addToShipLog("    War declared on Kraylors.","Magenta")
				p:addToShipLog("    Target any Kraylor vessel.","Magenta")
				p:addToShipLog("    Avoid targeting Kraylor stations.","Magenta")
				p:addToShipLog("End official dispatch","Magenta")
			end
		end
		if GMLimitedWar ~= nil then
			removeGMFunction(GMLimitedWar)
		end
		GMLimitedWar = nil
		treaty = false
		targetKraylorStations = false
		plot1 = limitedWar
	end
end
function limitedWar(delta)
	if not initialAssetsEvaluated then
		if gameTimeLimit < 1700 then
			evaluateInitialAssets()
		end
	end
	limitedWarTimer = limitedWarTimer - delta
	if limitedWarTimer < 0 then
		primaryOrders = "War continues. Atrocities suspected. Destroy any Kraylor vessels or stations"
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if not p.nameAssigned then
					setPlayers()
				end
				p:addToShipLog(string.format("To: Commanding Officer of %s",p:getCallSign()),"Magenta")
				p:addToShipLog("From: Human Navy Headquarters","Magenta")
				p:addToShipLog("    War continues on Kraylors.","Magenta")
				p:addToShipLog("    Intelligence reports Kraylors targeting civillian assets.","Magenta")
				p:addToShipLog("    All Kraylor targets may be destroyed.","Magenta")
				p:addToShipLog("End official dispatch","Magenta")
			end
		end
		if GMFullWar ~= nil then
			removeGMFunction(GMFullWar)
		end
		GMFullWar = nil
		targetKraylorStations = true
		plot1 = nil
	end
end
function evaluateInitialAssets()
	--delay on evaluation due to avoid penalizing players for black hole destruction due to random placement
	initialAssetsEvaluated = true
	originalHumanStationCount = 0
	originalHumanStationValue = 0
	humanCentroidX = 0
	humanCentroidY = 0
	for i=1,#humanStationList do
		if humanStationList[i] ~= nil and humanStationList[i]:isValid() then
			csx, csy = humanStationList[i]:getPosition()
			humanCentroidX = humanCentroidX + csx
			humanCentroidY = humanCentroidY + csy
			originalHumanStationCount = originalHumanStationCount + 1
			originalHumanStationValue = originalHumanStationValue + humanStationList[i].strength
		end
	end
	humanCentroidX = humanCentroidX/originalHumanStationCount
	humanCentroidY = humanCentroidY/originalHumanStationCount
	originalKraylorStationCount = 0
	originalKraylorStationValue = 0
	kraylorCentroidX = 0
	kraylorCentroidY = 0
	for i=1,#kraylorStationList do
		if kraylorStationList[i] ~= nil and kraylorStationList[i]:isValid() then
			csx, csy = kraylorStationList[i]:getPosition()
			kraylorCentroidX = kraylorCentroidX + csx
			kraylorCentroidY = kraylorCentroidY + csy
			originalKraylorStationCount = originalKraylorStationCount + 1
			originalKraylorStationValue = originalKraylorStationValue + kraylorStationList[i].strength
		end
	end
	kraylorCentroidX = kraylorCentroidX/originalKraylorStationCount
	kraylorCentroidY = kraylorCentroidY/originalKraylorStationCount
	originalNeutralStationCount = 0
	originalNeutralStationValue = 0
	attackAngle = angleFromVector(kraylorCentroidX, kraylorCentroidY, humanCentroidX, humanCentroidY)
	referenceStartX = (kraylorCentroidX + humanCentroidX)/2
	referenceStartY = (kraylorCentroidY + humanCentroidY)/2
	for i=1,#neutralStationList do
		if neutralStationList[i] ~= nil and neutralStationList[i]:isValid() then
			originalNeutralStationCount = originalNeutralStationCount + 1
			originalNeutralStationValue = originalNeutralStationValue + neutralStationList[i].strength
		end
	end
	local playerShipNames = {}
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			table.insert(playerShipNames,p:getCallSign())
			p:addToShipLog(string.format("To: Commanding officer of %s",p:getCallSign()),"Magenta")
			p:addToShipLog("From: Human Navy Headquarters","Magenta")
			p:addToShipLog("    Fleet admiral relieved of fleet command duties.","Magenta")
			p:addToShipLog("    You are granted fleet disposition authority.","Magenta")
			p:addToShipLog("    Fleet assets know to respond to your Relay officer's directives.","Magenta")
			p:addToShipLog("    Prepare for imminent Kraylor intrusion.","Magenta")
		end
	end
	if plot1Diagnostic then
		for i=1,#playerShipNames do
			print(i .. ": " .. playerShipNames[i])
		end
	end
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if #playerShipNames > 1 then
				coordinateList = ""
				for i=1,#playerShipNames do
					if plot1Diagnostic then print(playerShipNames[i]) end
					if playerShipNames[i] ~= p:getCallSign() then
						if plot1Diagnostic then print("    added") end
						coordinateList = coordinateList .. playerShipNames[i] .. ", "
					else
						if plot1Diagnostic then print("    skipped") end
					end
				end
				coordinateList = string.sub(coordinateList,1,string.len(coordinateList)-2)
				if #playerShipNames > 2 then
					p:addToShipLog("    Coordinate with commanders of " .. coordinateList .. ".","Magenta")
				else
					p:addToShipLog("    Coordinate with commander of " .. coordinateList .. ".","Magenta")
				end
			end
			p:addToShipLog("End official dispatch","Magenta")
		end
	end
	plot3 = initialAttack
end
--[[-----------------------------------------------------------------
    Plot 2 timed game
-----------------------------------------------------------------]]--
function timedGame(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		if plot2diagnostic then print("game time limit expired") end
		missionVictory = true
		if plot2diagnostic then print("boolean set") end
		missionCompleteReason = string.format("Player survived for %i minutes",defaultGameTimeLimitInMinutes)
		if plot2diagnostic then print("reason set") end
		endStatistics()
		if plot2diagnostic then print("finished end stats page") end
		victory("Human Navy")
	end
end
--[[-----------------------------------------------------------------
    Plot 3 kraylor attack scheme
-----------------------------------------------------------------]]--
function initialAttack(delta)
	if plot3diagnostic then print("initial attack") end
	local enemyInitialFleet = spawnEnemies(kraylorCentroidX, kraylorCentroidY, 1.3, "Kraylor")
	for _, enemy in ipairs(enemyInitialFleet) do
		enemy:orderFlyTowards(humanCentroidX, humanCentroidY)
		enemy.initialFleetMember = true
	end
	if plot3diagnostic then print("initial fleet created") end
	table.insert(enemyFleetList,enemyInitialFleet)
	if playWithTimeLimit then
		pincerTimer = random(lrr1,urr1)
	else
		pincerTimer = random(lrr2,urr2)
	end
	if plot3diagnostic then print("pincer timer: " .. pincerTimer) end
	plot3 = pincerAttack
end
function pincerAttack(delta)
	pincerTimer = pincerTimer - delta
	if pincerTimer < 0 then
		if plot3diagnostic then print("pincer timer expired") end
		local pincerSize = distance(kraylorCentroidX,kraylorCentroidY,referenceStartX,referenceStartY)*random(.4,.7)
		foundInitialFleetMember = false
		for i=1,#enemyFleetList do
			for j=1,#enemyFleetList[i] do
				exampleEnemy = enemyFleetList[i][j]
				if exampleEnemy.initialFleetMember then
					foundInitialFleetMember = true
					break
				end
			end
			if foundInitialFleetMember then
				break
			end
		end
		if foundInitialFleetMember then
			pincerAngle = exampleEnemy:getHeading()
		else
			pincerAngle = attackAngle
		end
		leftPincerAngle = pincerAngle
		if leftPincerAngle > 360 then
			leftPincerAngle = leftPincerAngle - 360
		end
		leftPincerX, leftPincerY = vectorFromAngle(leftPincerAngle,pincerSize)
		rightPincerAngle = pincerAngle + 180
		if rightPincerAngle > 360 then
			rightPincerAngle = rightPincerAngle - 360
		end
		rightPincerX, rightPincerY = vectorFromAngle(rightPincerAngle,pincerSize)
		if plot3diagnostic then print(string.format("Angles: Pincer: %.1f, Left: %.1f, Right: %.1f",pincerAngle,leftPincerAngle,rightPincerAngle)) end
		local enemyLeftPincerFleet = spawnEnemies(referenceStartX+leftPincerX,referenceStartY+leftPincerY,1.5,"Kraylor")
		for _, enemy in ipairs(enemyLeftPincerFleet) do
			enemy:orderRoaming()
		end
		table.insert(enemyFleetList,enemyLeftPincerFleet)
		local enemyRightPincerFleet = spawnEnemies(referenceStartX+rightPincerX,referenceStartY+rightPincerY,1.5,"Kraylor")
		for _, enemy in ipairs(enemyRightPincerFleet) do
			enemy:orderRoaming()
		end
		table.insert(enemyFleetList,enemyRightPincerFleet)
		if playWithTimeLimit then
			vengenceTimer = random(lrr1,urr1)
		else
			vengenceTimer = random(lrr2,urr2)
		end
		if plot3diagnostic then print("pincer fleets established") end
		plot3 = vengence
	end
end
function vengence(delta)
	vengenceTimer = vengenceTimer - delta
	if vengenceTimer < 0 then
		local availableVengenceCount = 0
		if plot3diagnostic then print("vengence prep") end
		for i=1,#enemyDefensiveFleetList do
			local tempFleet = enemyDefensiveFleetList[i]
			local viableCount = 0
			local onVengence = false
			for _, enemy in ipairs(tempFleet) do
				if enemy ~= nil and enemy:isValid() then
					viableCount = viableCount + 1
					if enemy.vengence then
						onVengence = true
						break
					end
				end
			end
			if viableCount > 0 and not onVengence then
				availableVengenceCount = availableVengenceCount + 1
			end
		end
		if plot3diagnostic then print("vengence prep complete") end
		if availableVengenceCount > 0 then
			if plot3diagnostic then print("fleets available") end
			local vengenceFleet = nil
			repeat
				local candidate = enemyDefensiveFleetList[math.random(1,#enemyDefensiveFleetList)]
				local availableVengence = true
				for _, enemy in ipairs(candidate) do
					if enemy ~= nil and enemy:isValid() and enemy.vengence then
						availableVengence = false
						break
					end
				end
				if availableVengence then
					vengenceFleet = candidate
				end
			until(vengenceFleet ~= nil)
			for _, enemy in ipairs(vengenceFleet) do
				if enemy ~= nil and enemy:isValid() then
					enemy:orderRoaming()
					enemy.vengence = true
				end
			end
			if playWithTimeLimit then
				vengenceTimer = delta + random(lrr3,urr3)
			else
				vengenceTimer = delta + random(lrr2,urr2)
			end
		else
			if plot3diagnostic then print("fleet unavailable, end of vengence plot") end
			plot3 = nil
		end
	end
end
function angleFromVector(p1x, p1y, p2x, p2y)
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	return RAD2DEG * theta
end
--[[-----------------------------------------------------------------
    Plot enemy defenses check
-----------------------------------------------------------------]]--
function setEnemyStationDefenses()
	for i=1,#kraylorStationList do
		local curEStation = kraylorStationList[i]
		if curEStation ~= enemyFleet1base and curEStation ~= enemyFleet2base and curEStation ~= enemyFleet3base and curEStation ~= enemyFleet4base and curEStation ~= enemyFleet5base then
			curEStation.defenseDeployed = false
			local defensiveChoice = random(1,100)
			--local defensiveChoice = 75	--test jammer fleet
			if defensiveChoice < 10 then		--	fighter fleet
				curEStation.defenseType = "fighterFleet"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 20 then	--	zone of ship damage (and temporary counter)
				curEStation.defenseType = "zoneDamage"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 30 then	--	call for help from nearby station
				curEStation.defenseType = "callInHelp"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 40 then	--	mine or minefield
				curEStation.defenseType = "minefield"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 50 then	--	deploy wormhole
				curEStation.defenseType = "wormhole"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 60 then	--	decoy transport (explosive)
				curEStation.defenseType = "transport"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 70 then	--	deploy weapons platform
				curEStation.defenseType = "weaponPlatform"
				curEStation.defenseTriggerDistance = random(2000,5000)
			elseif defensiveChoice < 80 then	--	jammer fleet
				curEStation.defenseType = "jammerFleet"
				curEStation.defenseTriggerDistance = random(2000,5000)
			else								--	drone fleet
				curEStation.defenseType = "droneFleet"
				curEStation.defenseTriggerDistance = random(2000,5000)
			end
		else
			curEStation.defenseDeployed = true
		end
	end
end
function enemyDefenseCheck(delta)
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			for _, enemyStation in ipairs(kraylorStationList) do
				if enemyStation ~= nil and enemyStation:isValid() and not enemyStation.defenseDeployed then
					local distToEnemyStation = distance(p,enemyStation)
					if distToEnemyStation < enemyStation.defenseTriggerDistance then
						if enemyStation.defenseType == "fighterFleet" then
							esx, esy = enemyStation:getPosition()
							local ef, efp = spawnFighterFleet(esx, esy, difficulty*4, "Kraylor")
							for _, enemy in ipairs(ef) do
								enemy:orderDefendTarget(enemyStation)
							end
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "jammerFleet" then
							if jammerList == nil then
								jammerList = {}
							end
							esx, esy = enemyStation:getPosition()
							tpx, tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							tj = WarpJammer():setPosition(esx,esy):setRange(5000):setFaction("Kraylor")
							tj.travelAngle = attackAngle
							tj.triggerDistance = distToEnemyStation
							tj.originX = esx
							tj.originY = esy
							tj.orbit = false
							table.insert(jammerList,tj)
							tj = WarpJammer():setPosition(esx,esy):setRange(5000):setFaction("Kraylor")
							tj.travelAngle = attackAngle + 120
							tj.triggerDistance = distToEnemyStation
							tj.originX = esx
							tj.originY = esy
							tj.orbit = false
							table.insert(jammerList,tj)
							tj = WarpJammer():setPosition(esx,esy):setRange(5000):setFaction("Kraylor")
							tj.travelAngle = attackAngle + 240
							tj.triggerDistance = distToEnemyStation
							tj.originX = esx
							tj.originY = esy
							tj.orbit = false
							table.insert(jammerList,tj)
							enemyStation.defenseDeployed = true
							plotWJ = warpJammerOrbit
						elseif enemyStation.defenseType == "zoneDamage" then
							if defensiveZoneList == nil then
								defensiveZoneList = {}
								p:addToShipLog(string.format("[Sensor technician]: Station %s is putting out some kind of energy field. It could damage our systems",enemyStation:getCallSign()),"Magenta")
							end
							esx, esy = enemyStation:getPosition()
							dh2x, dh2y = vectorFromAngle(60,distToEnemyStation)
							dh4x, dh4y = vectorFromAngle(120,distToEnemyStation)
							dh6x, dh6y = vectorFromAngle(180,distToEnemyStation)
							dh8x, dh8y = vectorFromAngle(240,distToEnemyStation)
							dh10x, dh10y = vectorFromAngle(300,distToEnemyStation)
							dh12x,dh12y = vectorFromAngle(0,distToEnemyStation)
							sz = Zone():setPoints(esx+dh2x,esy+dh2y,
												  esx+dh4x,esy+dh4y,
												  esx+dh6x,esy+dh6y,
												  esx+dh8x,esy+dh8y,
												  esx+dh10x,esy+dh10y,
												  esx+dh12x,esy+dh12y)
							table.insert(defensiveZoneList,sz)
							enemyStation.defenseDeployed = true
							sz.revealDelay = 15
							sz.system = hitZonePermutations[math.random(1,51)]
							plotDZ = enemyDefenseZoneCheck
						elseif enemyStation.defenseType == "callInHelp" then
							local nearestStation, rest = nearStations(enemyStation, kraylorStationList)
							esx, esy = nearestStation:getPosition()
							local ef, efp = spawnEnemies(esx, esy, 1, "Kraylor")
							for _, enemy in ipairs(ef) do
								enemy:orderAttack(p)
							end
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "minefield" then
							esx, esy = enemyStation:getPosition()
							tpx, tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							if artMineList == nil then
								artMineList = {}
							end
							tam = Artifact():setPosition(esx,esy):setModel("artifact4"):allowPickup(false)
							tam.travelAngle = attackAngle
							tam.triggerDistance = distToEnemyStation
							tam.originX = esx
							tam.originY = esy
							table.insert(artMineList,tam)
							enemyStation.defenseDeployed = true
							plotAM = artifactToMinefield
						elseif enemyStation.defenseType == "wormhole" then
							esx, esy = enemyStation:getPosition()
							tpx,tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							if artWormList == nil then
								artWormList = {}
							end
							taw = Artifact():setPosition(esx,esy):setModel("artifact4"):allowPickup(false)
							taw.travelAngle = attackAngle
							taw.triggerDistance = distToEnemyStation
							taw.originX = esx
							taw.originY = esy
							table.insert(artWormList,taw)
							enemyStation.defenseDeployed = true
							plotAW = artifactToWorm
						elseif enemyStation.defenseType == "transport" then
							esx, esy = enemyStation:getPosition()
							local rnd = irandom(1,5)
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
							if irandom(1,100) < 50 then
								name = name .. " Jump Freighter " .. irandom(3, 5)
							else
								name = name .. " Freighter " .. irandom(1, 5)
							end
							if deadlyTransportList == nil then
								deadlyTransportList = {}
							end
							vx, vy = vectorFromAngle(random(0,360),random(25000,30000))
							tdt = CpuShip():setTemplate(name):setFaction('Kraylor'):setCommsScript(""):setCommsFunction(commsShip):orderDock(enemyStation):setPosition(esx+vx,esy+vy)
							table.insert(deadlyTransportList,tdt)
							plotExpTrans = explosiveTransportCheck
							enemyStation.defenseDeployed = true
						elseif enemyStation.defenseType == "weaponPlatform" then
							esx, esy = enemyStation:getPosition()
							tpx, tpy = p:getPosition()
							attackAngle = p:getRotation() + 180
							if artPlatformList == nil then
								artPlatformList = {}
							end
							tap = Artifact():setPosition(esx,esy):setModel("artifact4"):allowPickup(false)
							tap.travelAngle = attackAngle
							tap.triggerDistance = distToEnemyStation/2
							tap.originX = esx
							tap.originY = esy
							table.insert(artPlatformList,tap)
							enemyStation.defenseDeployed = true
							plotWP = artifactToPlatform
						elseif enemyStation.defenseType == "droneFleet" then
							esx, esy = enemyStation:getPosition()
							local ef, efp = spawnDroneFleet(esx, esy, difficulty*6, "Kraylor")
							for _, enemy in ipairs(ef) do
								enemy:orderDefendLocation(esx, esy)
							end
							table.insert(enemyFleetList,ef)
							enemyStation.defenseDeployed = true
						end
					end
				end
			end
		end
	end
end
function artifactToPlatform(delta)
	for i=1,#artPlatformList do
		local tap = artPlatformList[i]
		local apx, apy = tap:getPosition()
		if distance(apx, apy, tap.originX, tap.originY) > tap.triggerDistance then
			if enemyDefensePlatformList == nil then
				enemyDefensePlatformList = {}
			end
			twp = CpuShip():setTemplate("Defense platform"):setFaction("Kraylor"):setPosition(apx,apy):orderRoaming()
			twp.distance = tap.triggerDistance
			twp.originX = tap.originX
			twp.originY = tap.originY
			twp.travelAngle = tap.travelAngle
			table.insert(enemyDefensePlatformList,twp)
			plotWPO = weaponPlatformOrbit
			table.remove(artPlatformList,i)
			tap:destroy()
			break
		else
			local tDeltax, tDeltay = vectorFromAngle(tap.travelAngle,4*difficulty)
			tap:setPosition(apx+tDeltax,apy+tDeltay)
		end
	end
end
function weaponPlatformOrbit(delta)
	for i=1,#enemyDefensePlatformList do
		twp = enemyDefensePlatformList[i]
		if twp ~= nil and twp:isValid() then
			twp.travelAngle = twp.travelAngle + .05*difficulty
			if twp.travelAngle >= 360 then 
				twp.travelAngle = 0
			end
			local newx, newy = vectorFromAngle(twp.travelAngle,twp.distance)
			twp:setPosition(twp.originX+newx, twp.originY+newy)
		end
	end
end
function warpJammerOrbit(delta)
	for i=1,#jammerList do
		tj = jammerList[i]
		if tj ~= nil and tj:isValid() then
			if tj.orbit then
				tj.travelAngle = tj.travelAngle + .05*difficulty
--				if tj.travelAngle >= 360 then
--					tj.travelAngle = 0
--				end
				newx, newy = vectorFromAngle(tj.travelAngle,tj.triggerDistance)
				tj:setPosition(tj.originX+newx,tj.originY+newy)
			else
				local wjx, wjy = tj:getPosition()
				if distance(wjx, wjy, tj.originX, tj.originY) > tj.triggerDistance then
					ef, efp = spawnJammerFleet(esx, esy)
					for _, enemy in ipairs(ef) do
						enemy:orderDefendLocation(tj.originX,tj.originY)
					end
					table.insert(enemyFleetList,ef)
					tj.orbit = true
				else
					local tDeltax, tDeltay = vectorFromAngle(tj.travelAngle,4*difficulty)
					tj:setPosition(wjx+tDeltax,wjy+tDeltay)
				end
			end
		end
	end
end
function artifactToMinefield(delta)
	for i=1,#artMineList do
		local tam = artMineList[i]
		local amx, amy = tam:getPosition()
		if distance(amx, amy, tam.originX, tam.originY) > tam.triggerDistance then
			if tam.mineCount == nil then
				tam.mineCount = 0
			end
			if tam.mineCount < 150 then
				wang = tam.travelAngle + 360
				if tam.mineCount == 0 then
					mdx, mdy = vectorFromAngle(wang,tam.triggerDistance)
					Mine():setPosition(tam.originX+mdx,tam.originY+mdy)
				else
					mdx, mdy = vectorFromAngle(wang+tam.mineCount,tam.triggerDistance)
					Mine():setPosition(tam.originX+mdx,tam.originY+mdy)
					mdx, mdy = vectorFromAngle(wang-tam.mineCount,tam.triggerDistance)
					Mine():setPosition(tam.originX+mdx,tam.originY+mdy)
				end
				tam.mineCount = tam.mineCount + 1
			else
				tam.deleteMe = true
			end
		else
			local tDeltax, tDeltay = vectorFromAngle(tam.travelAngle,4*difficulty)
			tam:setPosition(amx+tDeltax,amy+tDeltay)
		end
	end
	for i=1,#artMineList do
		tam = artMineList[i]
		if tam.deleteMe then
			table.remove(artMineList,i)
			tam:destroy()
		end
	end
end
function explosiveTransportCheck(delta)
	for i=1,#deadlyTransportList do
		local tdt = deadlyTransportList[i]
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local tpx, tpy = p:getPosition()
				local dtx, dty = tdt:getPosition()
				if distance(tpx, tpy, dtx, dty) < 750 then
					local tafx = Artifact():setPosition(dtx,dty)
					tafx:explode()
					p:setSystemHealth("beamweapons",-.5)
					p:setSystemHealth("missilesystem",-.5)
					tdt.deleteMe = true
					break
				end
			end
		end
	end
	for i=1,#deadlyTransportList do
		tdt = deadlyTransportList[i]
		if tdt.deleteMe then
			table.remove(deadlyTransportList,i)
			tdt:destroy()
			break
		end
	end
end
function artifactToWorm(delta)
	for i=1,#artWormList do
		local taw = artWormList[i]
		local awx, awy = taw:getPosition()
		if distance(taw,taw.originX,taw.originY) > taw.triggerDistance then
			taw.deleteMe = true
			local wdx, wdy = vectorFromAngle(random(0,360),100000)
			WormHole():setPosition(awx,awy):setTargetPosition(awx+wdx,awy+wdy)
		else
			local tDeltax, tDeltay = vectorFromAngle(taw.travelAngle,4*difficulty)
			taw:setPosition(awx+tDeltax,awy+tDeltay)
		end	
	end
	for i=1,#artWormList do
		taw = artWormList[i]
		if taw.deleteMe then
			table.remove(artWormList,i)
			taw:explode()
			break
		end
	end
end
function enemyDefenseZoneCheck(delta)
	for i=1,#defensiveZoneList do
		tz = defensiveZoneList[i]
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if tz:isInside(p) then
					local systemHit = math.random(1,3)
					p:setSystemHealth(tz.system[systemHit], p:getSystemHealth(tz.system[systemHit])*adverseEffect)
				end
			end
		end
		if tz.revealDelay < 0 then
			if tz.color == nil then
				tz:setColor(0,255,0)
				tz.color = true
			end
		else
			tz.revealDelay = tz.revealDelay - delta
		end
	end
end
function spawnDroneFleet(originX, originY, droneCount, faction)
	if faction == nil then
		faction = "Kraylor"
	end
	local fleetList = {}
	local deploySpacing = random(300,800)
	local deployConfig = random(1,100)
	for i=1,droneCount do
		ship = CpuShip():setFaction(faction):setTemplate("Ktlitan Drone"):orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		if faction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + 4
			ship:onDestruction(enemyVesselDestroyed)
		elseif faction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + 4
			ship:onDestruction(friendlyVesselDestroyed)
		end
		if deployConfig < 50 then
			ship:setPosition(originX+fleetPosDelta1x[i]*deploySpacing,originY+fleetPosDelta1y[i]*deploySpacing)
		else
			ship:setPosition(originX+fleetPosDelta2x[i]*deploySpacing,originY+fleetPosDelta2y[i]*deploySpacing)
		end
		table.insert(fleetList,ship)
	end
	return fleetList, droneCount*4
end
function spawnFighterFleet(originX, originY, fighterCount, faction)
	if faction == nil then
		faction = "Kraylor"
	end
	--Ship Template Name List
	local fighterNames  = {"MT52 Hornet","MU52 Hornet","WX-Lindworm","Fighter","Ktlitan Fighter"}
	--Ship Template Score List
	local fighterScores = {5            ,5            ,7            ,6        ,6}
	local fleetList = {}
	local fleetPower = 0
	local deploySpacing = random(300,800)
	local deployConfig = random(1,100)
	for i=1,fighterCount do
		local shipTemplateType = math.random(1,#fighterNames)
		fleetPower = fleetPower + fighterScores[shipTemplateType]
		ship = CpuShip():setFaction(faction):setTemplate(fighterNames[shipTemplateType]):orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		if faction == "Kraylor" then
			rawKraylorShipStrength = rawKraylorShipStrength + fighterScores[shipTemplateType]
			ship:onDestruction(enemyVesselDestroyed)
		elseif faction == "Human Navy" then
			rawHumanShipStrength = rawHumanShipStrength + fighterScores[shipTemplateType]
			ship:onDestruction(friendlyVesselDestroyed)
		end
		if deployConfig < 50 then
			ship:setPosition(originX+fleetPosDelta1x[i]*deploySpacing,originY+fleetPosDelta1y[i]*deploySpacing)
		else
			ship:setPosition(originX+fleetPosDelta2x[i]*deploySpacing,originY+fleetPosDelta2y[i]*deploySpacing)
		end
		table.insert(fleetList,ship)
	end
	return fleetList, fleetPower
end
function spawnJammerFleet(originX, originY)
	faction = "Kraylor"
	local shipSpawnCount = 2
	if difficulty < 1 then
		shipSpawnCount = 1
	elseif difficulty > 1 then
		shipSpawnCount = 3
	end
	--Ship Template Name List
	local jammerNames  = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Fighter","Ktlitan Fighter","Ktlitan Drone","Ktlitan Scout"}
	--Ship Template Score List
	local jammerScores = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,6        ,6                ,4              ,8              }
	local fleetList = {}
	local fleetPower = 0
	local deploySpacing = random(300,800)
	local deployConfig = random(1,100)
	for i=1,shipSpawnCount do
		local shipTemplateType = math.random(1,#jammerNames)
		fleetPower = fleetPower + jammerScores[shipTemplateType]
		ship = CpuShip():setFaction(faction):setTemplate(jammerNames[shipTemplateType]):orderRoaming():setCommsScript(""):setCommsFunction(commsShip)
		rawKraylorShipStrength = rawKraylorShipStrength + jammerScores[shipTemplateType]
		ship:onDestruction(enemyVesselDestroyed)
		if deployConfig < 50 then
			ship:setPosition(originX+fleetPosDelta1x[i]*deploySpacing,originY+fleetPosDelta1y[i]*deploySpacing)
		else
			ship:setPosition(originX+fleetPosDelta2x[i]*deploySpacing,originY+fleetPosDelta2y[i]*deploySpacing)
		end
		table.insert(fleetList,ship)
	end
	return fleetList, fleetPower
end
function personalAmbush(delta)
	if playWithTimeLimit then
		if paDiagnostic then
			paTriggerTime = 120
		else
			paTriggerTime = random(700,1000)
		end
		paTriggerTime = gameTimeLimit - paTriggerTime
		if paDiagnostic then print("using timer as initial trigger: " .. paTriggerTime) end
		plotPA = personalAmbushTimeCheck
	else
		if paDiagnostic then
			paTriggerEval = 98
		else
			midDestruct = (enemyDestructionVictoryCondition + 100)/2
			paTriggerEval = random(midDestruct-4,midDestruct+4)
		end
		if paDiagnostic then print("using eval as initial trigger: " .. paTriggerEval) end
		paDestructInterval = 15
		paDestructTimer = paDestructInterval
		plotPA = personalAmbushDestructCheck
	end
end
function personalAmbushDestructCheck(delta)
	paDestructTimer = paDestructTimer - delta
	if paDestructTimer < 0 then
		if initialAssetsEvaluated then
			if paDiagnostic then print("paDestruct check") end
			friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2, friendlyShipSurvivedValue, fpct, enemyShipSurvivedValue, epct = listStatuses()
			if friendlySurvivedCount == nil then
				return
			end
			local evalEnemy = epct2*enemyStationComponentWeight + epct*enemyShipComponentWeight
			if evalEnemy < paTriggerEval then
				if paDiagnostic then print("met paDestruct criteria") end
				local candidate = nil
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() and p.sprung == nil then
						local nebulaHuntList = p:getObjectsInRange(20000)
						for _, obj in ipairs(nebulaHuntList) do
							if obj.typeName == "Nebula" then
								if distance(p,obj) > 6000 then
									if paDiagnostic then print("found a nebula in " .. obj:getSectorName()) end
									candidate = obj
									break
								end
							end					
						end
					end
					if candidate ~= nil then
						break
					end
				end
				paTriggerTime = gameTimeLimit - random(30,90)
				plotPA = personalAmbushTimeCheck
				if candidate ~= nil then
					local efx, efy = candidate:getPosition()
					enemyAmbushFleet = spawnEnemies(efx,efy,1,"Kraylor")
					for _, enemy in ipairs(enemyAmbushFleet) do
						enemy:orderAttack(p)
					end
					table.insert(enemyFleetList,enemyAmbushFleet)
					p.sprung = true
					if paDiagnostic then print("sprung on " .. p:getCallSign()) end
				else
					if paDiagnostic then print("no candidate found for ambush") end
				end
			end
		end
		paDestructTimer = delta + paDestructInterval		
	end
end
function personalAmbushTimeCheck(delta)
	if gameTimeLimit < paTriggerTime then
		if paDiagnostic then print("paGame Time check passed") end
		candidate = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.sprung == nil then
				nebulaHuntList = p:getObjectsInRange(20000)
				for _, obj in ipairs(nebulaHuntList) do
					if obj.typeName == "Nebula" then
						if distance(p,obj) > 6000 then
							if paDiagnostic then print("found a nebula in " .. obj:getSectorName()) end
							candidate = obj
							break
						end
					end					
				end
			end
			if candidate ~= nil then
				break
			end
		end
		paTriggerTime = gameTimeLimit - random(30,90)
		if candidate ~= nil then
			efx, efy = candidate:getPosition()
			enemyAmbushFleet = spawnEnemies(efx,efy,1,"Kraylor")
			for _, enemy in ipairs(enemyAmbushFleet) do
				enemy:orderAttack(p)
			end
			table.insert(enemyFleetList,enemyAmbushFleet)
			p.sprung = true
			if paDiagnostic then print("sprung on " .. p:getCallSign()) end
		else
			if paDiagnostic then print("no candidate found for ambush") end
		end
	end
end
--[[-----------------------------------------------------------------
    Plot PB player border zone checks
-----------------------------------------------------------------]]--
function playerBorderCheck(delta)
	if treaty then
		tbz = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				playerOutOfBounds = false
				tbz = outerZone
				if tbz:isInside(p) then
					playerOutOfBounds = true
					break
				end
				for i=1,#borderZone do
					tbz = borderZone[i]
					if tbz:isInside(p) then
						playerOutOfBounds = true
						break
					end
				end
				if playerOutOfBounds then
					break
				end
			end
		end
		if tbz ~= nil then
			if playerOutOfBounds then
				if tbz.playerDetected == nil then
					tbz.playerDetected = 1
				else
					if tbz.playerDetected >= 10 then
						missionVictory = false
						finalTimer = 2
						plotPB = displayDefeatResults
					else
						tbz.playerDetected = tbz.playerDetected + 1
					end
				end
			else
				if tbz.playerDetected == nil then
					tbz.playerDetected = 0
				else
					if tbz.playerDetected <= 0 then
						tbz.playerDetected = 0
					else
						tbz.playerDetected = tbz.playerDetected - 1
					end
				end
			end
		end
	end
end
function displayDefeatResults(delta)
	finalTimer = finalTimer - delta
	if finalTimer < 0 then
		missionCompleteReason = "Player violated treaty terms by crossing neutral border zone"
		endStatistics()
		victory("Kraylor")
	end
end
function playerWarCrimeCheck(delta)
	if not treaty and not targetKraylorStations and initialAssetsEvaluated then
		local friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2 = stationStatus()
		if friendlySurvivedCount == nil then
			return
		end
		if epct2 < 100 then
			missionVictory = false
			missionCompleteReason = "Player committed war crimes by destroying civilians aboard Kraylor station"
			endStatistics()
			victory("Kraylor")
		end
	end
end
--[[-----------------------------------------------------------------
    Plot EB enemy border zone checks
-----------------------------------------------------------------]]--
function enemyBorderCheck(delta)
	local tempEnemy
	enemyBorderCheckTimer = enemyBorderCheckTimer - delta
	if enemyBorderCheckTimer < 0 then
		enemyBorderCheckTimer = delta + enemyBorderCheckInterval
		for i=1,13 do
			local tbz = borderZone[i]
			local enemyDetected = false
			for j=1,#enemyFleetList do
				local tempFleet = enemyFleetList[j]
				for _, tempEnemy in ipairs(tempFleet) do
					if tempEnemy ~= nil and tempEnemy:isValid() then
						if tbz:isInside(tempEnemy) then
							enemyDetected = true
							enemyEverDetected = true
							break
						end
					end
				end
				if enemyDetected then
					break
				end
			end
			if enemyDetected then
				if tbz.detect >= 2 then
					tbz:setColor(255,255,0)
				else
					tbz.detect = tbz.detect + 1
				end
			else
				if tbz.detect <= 0 then
					if treaty then
						tbz:setColor(0,0,255)
					else
						tbz:setColor(255,0,0)
					end
				else
					tbz.detect = tbz.detect - 1
				end
			end
		end
	end
end
--[[-----------------------------------------------------------------
    Dynamic game master buttons
-----------------------------------------------------------------]]--
function dynamicGameMasterButtons(delta)
	if treaty then
		if treatyTimer ~= nil and treatyTimer > 0 then
			if GMBelligerentKraylors == nil then
				GMBelligerentKraylors = "belligerent"
				addGMFunction(GMBelligerentKraylors,belligerentKraylors)
			end
		else
			if treatyStressTimer ~= nil and treatyStressTimer > 0 then
				if GMLimitedWar == nil then
					GMLimitedWar = "Limited War"
					addGMFunction(GMLimitedWar,limitedWarByGM)
				end
			end
		end
	else
		if GMBelligerentKraylors ~= nil then
			removeGMFunction(GMBelligerentKraylors)
		end
		GMBelligerentKraylors = nil
		if GMLimitedWar ~= nil then
			removeGMFunction(GMLimitedWar)
		end
		GMLimitedWar = nil
		if limitedWarTimer ~= nil and limitedWarTimer > 0 then
			if GMFullWar == nil then
				GMFullWar = "Full War"
				addGMFunction(GMFullWar,fullWarByGM)
			end
		end
	end
end
function belligerentKraylors()
	treatyTimer = 0
	if GMBelligerentKraylors ~= nil then
		removeGMFunction(GMBelligerentKraylors)
	end
	GMBelligerentKraylors = nil
end
function limitedWarByGM()
	treatyStressTimer = 0
	if GMLimitedWar ~= nil then
		removeGMFunction(GMLimitedWar)
	end
	GMLimitedWar = nil
end
function fullWarByGM()
	limitedWarTimer = 0
	if GMFullWar ~= nil then
		removeGMFunction(GMFullWar)
	end
	GMFullWar = nil
end
--[[-----------------------------------------------------------------
    Plot end of war checks
-----------------------------------------------------------------]]--
function endWar(delta)
	endWarTimer = endWarTimer - delta
	if endWarTimer < 0 then
		endWarTimer = delta + endWarTimerInterval
		friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2, friendlyShipSurvivedValue, fpct, enemyShipSurvivedValue, epct = listStatuses()
		if friendlySurvivedCount == nil then
			return
		end
		local evalEnemy = epct2*enemyStationComponentWeight + epct*enemyShipComponentWeight
		if evalEnemy < enemyDestructionVictoryCondition then
			missionVictory = true
			missionCompleteReason = string.format("Enemy reduced to less than %i%% strength",enemyDestructionVictoryCondition)
			endStatistics()
			victory("Human Navy")
		end
		local evalFriendly = fpct2*friendlyStationComponentWeight + npct2*neutralStationComponentWeight + fpct*friendlyShipComponentWeight
		if evalFriendly < friendlyDestructionDefeatCondition then
			missionVictory = false
			missionCompleteReason = string.format("Human Navy reduced to less than %i%% strength",friendlyDestructionDefeatCondition)
			endStatistics()
			victory("Kraylor")
		end
		if evalEnemy - evalFriendly > destructionDifferenceEndCondition then
			missionVictory = false
			missionCompleteReason = string.format("Enemy strength exceeded ours by %i percentage points",destructionDifferenceEndCondition)
			endStatistics()
			victory("Kraylor")
		end
		if evalFriendly - evalEnemy > destructionDifferenceEndCondition then
			missionVictory = true
			missionCompleteReason = string.format("Our strength exceeded enemy strength by %i percentage points",destructionDifferenceEndCondition)
			endStatistics()
			victory("Human Navy")
		end
	end
end
function setSecondaryOrders()
	friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2, friendlyShipSurvivedValue, fpct, enemyShipSurvivedValue, epct = listStatuses()
	if friendlySurvivedCount == nil then
		secondaryOrders = ""
		return
	end
	secondaryOrders = ""
	--secondaryOrders = string.format("\nStations: Friendly: %.1f%%, Enemy: %.1f%%, Neutral: %.1f%%",fpct2,epct2,npct2)
	--secondaryOrders = secondaryOrders .. string.format("\nShips: Friendly: %.1f%%, Enemy: %.1f%%",fpct, epct)
	evalFriendly = fpct2*friendlyStationComponentWeight + npct2*neutralStationComponentWeight + fpct*friendlyShipComponentWeight
	secondaryOrders = secondaryOrders .. string.format("\n\nFriendly evaluation: %.1f%%. Below %.1f%% = defeat",evalFriendly,friendlyDestructionDefeatCondition)
	evalEnemy = epct2*enemyStationComponentWeight + epct*enemyShipComponentWeight
	secondaryOrders = secondaryOrders .. string.format("\nEnemy evaluation: %.1f%%. Below %.1f%% = victory",evalEnemy,enemyDestructionVictoryCondition)
	secondaryOrders = secondaryOrders .. string.format("\n\nGet behind by %.1f%% = defeat. Get ahead by %.1f%% = victory",destructionDifferenceEndCondition,destructionDifferenceEndCondition)
end
function detailedStats()
	print("Friendly")
	print("  Stations")
	print("    Survived")
	local friendlySurvivalValue = 0
	for _, station in ipairs(stationList) do
		if station:isFriendly(getPlayerShip(-1)) then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				friendlySurvivalValue = friendlySurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of friendly stations that survived",friendlySurvivalValue))
	print("    Destroyed")
	local friendlyDestructionValue = 0
	for i=1,#friendlyStationDestroyedNameList do
		print(string.format("      %2d %s",friendlyStationDestroyedValue[i],friendlyStationDestroyedNameList[i]))
		friendlyDestructionValue = friendlyDestructionValue + friendlyStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of friendly stations that were destroyed",friendlyDestructionValue))
	print("  Military vessels")
	print("    Survived")
	local friendlyShipSurvivedValue = 0
	for j=1,#friendlyFleetList do
		tempFleet = friendlyFleetList[j]
		for _, tempFriend in ipairs(tempFleet) do
			if tempFriend ~= nil and tempFriend:isValid() then
				for k=1,#stnl do
					if tempFriend:getTypeName() == stnl[k] then
						print(string.format("      %3d %s %s",stsl[k],tempFriend:getCallSign(),tempFriend:getTypeName()))
						friendlyShipSurvivedValue = friendlyShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	print(string.format("     %3d = total value of friendly military vessels that survived",friendlyShipSurvivedValue))
	print("    Destroyed")
	local friendlyShipDestroyedValue = 0
	for i=1,#friendlyVesselDestroyedNameList do
		print(string.format("     %3d %s %s",friendlyVesselDestroyedValue[i],friendlyVesselDestroyedNameList[i],friendlyVesselDestroyedType[i]))
		friendlyShipDestroyedValue = friendlyShipDestroyedValue + friendlyVesselDestroyedValue[i]
	end
	print(string.format("     %3d = total value of friendly military vessels that were destoyed",friendlyShipDestroyedValue))
	print("Independent")
	print("  Stations")
	print("    Survived")
	local neutralSurvivalValue = 0
	for _, station in ipairs(stationList) do
		if not station:isFriendly(getPlayerShip(-1)) and not station:isEnemy(getPlayerShip(-1))then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				neutralSurvivalValue = neutralSurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of neutral stations that survived",neutralSurvivalValue))
	print("    Destroyed")
	local neutralDestroyedValue = 0
	for i=1,#neutralStationDestroyedNameList do
		print(string.format("      %2d %s",neutralStationDestroyedValue[i],neutralStationDestroyedNameList[i]))
		neutralDestroyedValue = neutralDestroyedValue + neutralStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of neutral stations that were destoyed",neutralDestroyedValue))
	print("Enemy")
	print("  Stations")
	print("    Survived")
	local enemySurvivalValue = 0
	for _, station in ipairs(stationList) do
		if station:isEnemy(getPlayerShip(-1))then
			if station:isValid() then
				print(string.format("      %2d %s",station.strength,station:getCallSign()))
				enemySurvivalValue = enemySurvivalValue + station.strength
			end
		end
	end
	print(string.format("     %3d = Total value of enemy stations that survived",enemySurvivalValue))
	print("    Destroyed")
	local enemyDestroyedValue = 0
	for i=1,#enemyStationDestroyedNameList do
		print(string.format("      %2d %s",enemyStationDestroyedValue[i],enemyStationDestroyedNameList[i]))
		enemyDestroyedValue = enemyDestroyedValue + enemyStationDestroyedValue[i]
	end
	print(string.format("     %3d = Total value of enemy stations that were destroyed",enemyDestroyedValue))
	print("  Military vessels")
	print("    Survived")
	local enemyShipSurvivedValue = 0
	for j=1,#enemyFleetList do
		tempFleet = enemyFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				for k=1,#stnl do
					if tempEnemy:getTypeName() == stnl[k] then
						print(string.format("      %3d %s %s",stsl[k],tempEnemy:getCallSign(),tempEnemy:getTypeName()))
						enemyShipSurvivedValue = enemyShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	print(string.format("     %3d = total value of enemy military vessels that survived",enemyShipSurvivedValue))
	print("    Destroyed")
	local enemyShipDestroyedValue = 0
	for i=1,#enemyVesselDestroyedNameList do
		print(string.format("     %3d %s %s",enemyVesselDestroyedValue[i],enemyVesselDestroyedNameList[i],enemyVesselDestroyedType[i]))
		enemyShipDestroyedValue = enemyShipDestroyedValue + enemyVesselDestroyedValue[i]
	end
	print(string.format("     %3d = total value of enemy military vessels that were destroyed",enemyShipDestroyedValue))
end
function enemyVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(enemyVesselDestroyedNameList,self:getCallSign())
	table.insert(enemyVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(enemyVesselDestroyedValue,stsl[k])
		end
	end
end
function friendlyVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(friendlyVesselDestroyedNameList,self:getCallSign())
	table.insert(friendlyVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(friendlyVesselDestroyedValue,stsl[k])
		end
	end
end
function friendlyStationDestroyed(self, instigator)
	table.insert(friendlyStationDestroyedNameList,self:getCallSign())
	table.insert(friendlyStationDestroyedValue,self.strength)
end
function enemyStationDestroyed(self, instigator)
	table.insert(enemyStationDestroyedNameList,self:getCallSign())
	table.insert(enemyStationDestroyedValue,self.strength)
end
function neutralStationDestroyed(self, instigator)
	table.insert(neutralStationDestroyedNameList,self:getCallSign())
	table.insert(neutralStationDestroyedValue,self.strength)
end
function listStatuses()
	local friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2 = stationStatus()
	if friendlySurvivedCount == nil then
		return nil
	end
	--ship information
	local enemyShipSurvivedCount = 0
	local enemyShipSurvivedValue = 0
	for j=1,#enemyFleetList do
		local tempFleet = enemyFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				enemyShipSurvivedCount = enemyShipSurvivedCount + 1
				for k=1,#stnl do
					if tempEnemy:getTypeName() == stnl[k] then
						enemyShipSurvivedValue = enemyShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	local friendlyShipSurvivedCount = 0
	local friendlyShipSurvivedValue = 0
	for j=1,#friendlyFleetList do
		tempFleet = friendlyFleetList[j]
		for _, tempFriend in ipairs(tempFleet) do
			if tempFriend ~= nil and tempFriend:isValid() then
				friendlyShipSurvivedCount = friendlyShipSurvivedCount + 1
				for k=1,#stnl do
					if tempFriend:getTypeName() == stnl[k] then
						friendlyShipSurvivedValue = friendlyShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	local fpct = friendlyShipSurvivedValue/rawHumanShipStrength*100
	local epct = enemyShipSurvivedValue/rawKraylorShipStrength*100
	return friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2, friendlyShipSurvivedValue, fpct, enemyShipSurvivedValue, epct
end
function stationStatus()
	tp = getPlayerShip(-1)
	if tp == nil then
		return nil
	end
	local friendlySurvivedCount = 0
	local friendlySurvivedValue = 0
	local enemySurvivedCount = 0
	local enemySurvivedValue = 0
	local neutralSurvivedCount = 0
	local neutralSurvivedValue = 0
	for _, station in pairs(stationList) do
		if tp ~= nil then
			if station:isFriendly(tp) then
				if station:isValid() then
					friendlySurvivedCount = friendlySurvivedCount + 1
					friendlySurvivedValue = friendlySurvivedValue + station.strength
				end
			elseif station:isEnemy(tp) then
				if station:isValid() then
					enemySurvivedCount = enemySurvivedCount + 1
					enemySurvivedValue = enemySurvivedValue + station.strength
				end
			else
				if station:isValid() then
					neutralSurvivedCount = neutralSurvivedCount + 1
					neutralSurvivedValue = neutralSurvivedValue + station.strength
				end
			end
		end
	end
	if originalHumanStationCount == nil then
		originalHumanStationCount = #humanStationList
	end
	if originalHumanStationValue == nil then
		originalHumanStationValue = humanStationStrength
	end
	if originalKraylorStationCount == nil then
		originalKraylorStationCount = #kraylorStationList
	end
	if originalKraylorStationValue == nil then
		originalKraylorStationValue = kraylorStationStrength
	end
	if originalNeutralStationCount == nil then
		originalNeutralStationCount = #neutralStationList
	end
	if originalNeutralStationValue == nil then
		originalNeutralStationValue = neutralStationStrength
	end
	local fpct1 = friendlySurvivedCount/originalHumanStationCount*100
	local fpct2 = friendlySurvivedValue/originalHumanStationValue*100
	local epct1 = enemySurvivedCount/originalKraylorStationCount*100
	local epct2 = enemySurvivedValue/originalKraylorStationValue*100
	local npct1 = neutralSurvivedCount/originalNeutralStationCount*100
	local npct2 = neutralSurvivedValue/originalNeutralStationValue*100
	return friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2
end
--final page for victory or defeat on main streen
function endStatistics()
	if endStatDiagnostic then print("starting end statistics") end
	friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2, friendlyShipSurvivedValue, fpct, enemyShipSurvivedValue, epct = listStatuses()
	if friendlySurvivedCount == nil then
		globalMessage("statistics unavailable")
		return
	end
	if endStatDiagnostic then print("got statuses")	end
	local gMsg = ""
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Friendly stations: %i out of %i survived (%.1f%%), strength: %i out of %i (%.1f%%)\n",friendlySurvivedCount,originalHumanStationCount,fpct1,friendlySurvivedValue,originalHumanStationValue,fpct2)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Enemy stations: %i out of %i survived (%.1f%%), strength: %i out of %i (%.1f%%)\n",enemySurvivedCount,originalKraylorStationCount,epct1,enemySurvivedValue,originalKraylorStationValue,epct2)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Neutral stations: %i out of %i survived (%.1f%%), strength: %i out of %i (%.1f%%)\n\n\n\n",neutralSurvivedCount,originalNeutralStationCount,npct1,neutralSurvivedValue,originalNeutralStationValue,npct2)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	--ship information
	gMsg = gMsg .. string.format("Friendly ships: strength: %i out of %i (%.1f%%)\n",friendlyShipSurvivedValue,rawHumanShipStrength,fpct)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Enemy ships: strength: %i out of %i (%.1f%%)\n",enemyShipSurvivedValue,rawKraylorShipStrength,epct)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	if endStatDiagnostic then print("set raw stats") end
	local friendlyStationComponent = friendlySurvivedValue/originalHumanStationValue
	local enemyStationComponent = 1-enemySurvivedValue/originalKraylorStationValue
	local neutralStationComponent = neutralSurvivedValue/originalNeutralStationValue
	local friendlyShipComponent = friendlyShipSurvivedValue/rawHumanShipStrength
	local enemyShipComponent = 1-enemyShipSurvivedValue/rawKraylorShipStrength
	local evalFriendly = fpct2*friendlyStationComponentWeight + npct2*neutralStationComponentWeight + fpct*friendlyShipComponentWeight
	gMsg = gMsg .. string.format("Friendly evaluation strength: %.1f%%, weights: friendly station: %.1f, neutral station: %.1f, friendly ship: %.1f\n",evalFriendly, friendlyStationComponentWeight, neutralStationComponentWeight, friendlyShipComponentWeight)
	local evalEnemy = epct2*enemyStationComponentWeight + epct*enemyShipComponentWeight
	gMsg = gMsg .. string.format("Enemy evaluation strength: %.1f%%, weights: enemy station: %.1f, enemy ship: %.1f\n",evalEnemy, enemyStationComponentWeight, enemyShipComponentWeight)
	local rankVal = friendlyStationComponent*.4 + friendlyShipComponent*.2 + enemyStationComponent*.2 + enemyShipComponent*.1 + neutralStationComponent*.1 
	if endStatDiagnostic then print("calculated ranking stats") end
	if endStatDiagnostic then print("rank value: " .. rankVal) end
	if missionCompleteReason ~= nil then
		gMsg = gMsg .. "Mission ended because " .. missionCompleteReason .. "\n"
		if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	end
	if endStatDiagnostic then print("built reason for end") end
	if missionVictory then
		if endStatDiagnostic then print("mission victory true") end
		if rankVal < .7 then
			rank = "Ensign"
		elseif rankVal < .8 then
			rank = "Lieutenant"
		elseif rankVal < .9 then
			rank = "Commander"
		elseif rankVal < .95 then
			rank = "Captain"
		else
			rank = "Admiral"
		end
		gMsg = gMsg .. "Earned rank: " .. rank
		if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	else
		if endStatDiagnostic then print("mission victory false") end
		if rankVal < .6 then
			rank = "Ensign"
		elseif rankVal < .7 then
			rank = "Lieutenant"
		elseif rankVal < .8 then
			rank = "Commander"
		elseif rankVal < .9 then
			rank = "Captain"
		else
			rank = "Admiral"
		end
		if missionCompleteReason == "Player violated treaty terms by crossing neutral border zone" then
			gMsg = gMsg .. "Rank after court martial and imprisonment: " .. rank
			if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
		elseif missionCompleteReason == "Player committed war crimes by destroying civilians aboard Kraylor station" then
			gMsg = gMsg .. "Rank after being stripped of ship responsibilities: " .. rank
			if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
		else
			gMsg = gMsg .. "Rank after military reductions due to ignominious defeat: " .. rank
			if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
		end
	end
	if endStatDiagnostic then print(gMsg) end
	globalMessage(gMsg)
	if endStatDiagnostic then print("seng to the global message function") end
	if printDetailedStats then
		detailedStats()
		if endStatDiagnostic then print("executed detalied stats function") end
	end
end
function update(delta)
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if updateDiagnostic then print("plot1") end
	if plot1 ~= nil then	--war/peace
		plot1(delta)
	end
	if updateDiagnostic then print("plot2") end
	if plot2 ~= nil then	--timed game
		plot2(delta)
	end
	if updateDiagnostic then print("plotEW") end
	if plotEW ~= nil then	--end war checks
		plotEW(delta)
	end
	if updateDiagnostic then print("plotPB") end
	if plotPB ~= nil then	--player border
		plotPB(delta)
	end
	if updateDiagnostic then print("plotPWC") end
	if plotPWC ~= nil then	--player war crime check
		plotPWC(delta)
	end
	if updateDiagnostic then print("plotED") end
	if plotED ~= nil then	--enemy defense
		plotED(delta)
	end
	if updateDiagnostic then print("plotDZ") end
	if plotDZ ~= nil then	--enemy defense zone
		plotDZ(delta)
	end
	if updateDiagnostic then print("plotExpTrans") end
	if plotExpTrans ~= nil then		--exploding transport
		plotExpTrans(delta)
	end
	if updateDiagnostic then print("plotAW") end
	if plotAW ~= nil then	--artifact to worm
		plotAW(delta)
	end
	if updateDiagnostic then print("plotWJ") end
	if plotWJ ~= nil then	--artifact to worm
		plotWJ(delta)
	end
	if updateDiagnostic then print("plotAM") end
	if plotAM ~= nil then	--artifact to mine
		plotAM(delta)
	end
	if updateDiagnostic then print("plotWP") end
	if plotWP ~= nil then	--weapons platform
		plotWP(delta)
	end
	if updateDiagnostic then print("plotWPO") end
	if plotWPO ~= nil then	--weapons platform orbit
		plotWPO(delta)
	end
	if updateDiagnostic then print("plotH") end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if updateDiagnostic then print("plot3") end
	if plot3 ~= nil then	--kraylor attacks
		plot3(delta)
	end
	if updateDiagnostic then print("plotFT") end
	if plotFT ~= nil then	--friendly transport plot
		plotFT(delta)
	end
	if updateDiagnostic then print("plotIT") end
	if plotIT ~= nil then	--independent transport plot
		plotIT(delta)
	end
	if updateDiagnostic then print("plotKT") end
	if plotKT ~= nil then	--kraylor transport plot
		plotKT(delta)
	end
	if updateDiagnostic then print("plotEB") end
	if plotEB ~= nil then	--enemy border
		plotEB(delta)
	end
	if updateDiagnostic then print("plotPA") end
	if plotPA ~= nil then	--personal ambush
		plotPA(delta)
	end
	if updateDiagnostic then print("plotCI") end
	if plotCI ~= nil then	--coolant automation for fighters
		plotCI(delta)
	end
	if updateDiagnostic then print("plotC") end
	if plotC ~= nil then	--coolant automation for fighters
		plotC(delta)
	end
	if updateDiagnostic then print("plotDGM") end
	if plotDGM ~= nil then
		plotDGM(delta)
	end
end