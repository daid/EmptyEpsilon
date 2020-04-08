-- Name: Borderline Fever
-- Description: War temperature rises along the border between Human Navy space and Kraylor space. The treaty holds for now, but the diplomats and intelligence operatives fear the Kraylors are about to break the treaty. We must maintain the treaty despite provocation until war is formally declared.
---
--- Version 4 updated enemy ship interactions including continuum weapon
-- Type: Replayable Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Timed]: Victory if some human navy stations and player ships survive for 30 minutes
-- Variation[Timed Easy]: Victory if some human navy stations and player ships survive for 30 minutes, Easy goals and/or enemies
-- Variation[Timed Hard]: Victory if some human navy stations and player ships survive for 30 minutes, Hard goals and/or enemies

-- to do items:

-- Station warning of enemies in area (helpful warnings - shuffle stations)

require("utils.lua")

--------------------
-- Initialization --
--------------------
function init()
	print(_VERSION)
	defaultGameTimeLimitInMinutes = 30	--final: 30 (lowered for test)
	rawKraylorShipStrength = 0
	rawHumanShipStrength = 0
	prefix_length = 0
	suffix_index = 0
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
	muckDiagnostic = false
	stationCommsDiagnostic = false
	shipCommsDiagnostic = false
	optionalMissionDiagnostic = false
	paDiagnostic = false
	plot3diagnostic = false
	plot1Diagnostic = false
	updateDiagnostic = false
	healthDiagnostic = false
	plot2diagnostic = false
	endStatDiagnostic = false
	printDetailedStats = true
	change_enemy_order_diagnostic = false
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	repeat
		setGossipSnippets()
		setListOfStations()
		setBorderZones()	--establish neutral border zone and other zones
		buildStationsPlus()	--put stations and other things in and out of the neutral border zone
		if initDiagnostic then print("weird zone adjustment count: " .. wzac) end
		--be sure initial spawn point (0,0) is inside the inner zone defining human territory
		spawnInInnerZone = false
		spawnMarker = VisualAsteroid():setPosition(0,0)
		spawnInInnerZone = innerZone:isInside(spawnMarker)
		spawnMarker:destroy()
		--be sure each side has at least a minimal number of stations
		if wzac > 0 or #kraylorStationList < 5 or #humanStationList < 5 or not spawnInInnerZone then
			resetStationsPlus()
		end
	until(wzac < 1 and #kraylorStationList >= 5 and #humanStationList >= 5 and spawnInInnerZone)
	if not diagnostic then	--get rid of temporary set up zones
		for i=1,#innerZoneList do
			innerZoneList[i]:destroy()
		end
		for i=1,#outerZoneList do
			outerZoneList[i]:destroy()
		end
	end
	setFleets()						--give each side some ships
	setEnemyStationDefenses()		--give enemy stations defensive mechanisms
	setOptionalMissions()			--scatter upgrade missions around the stations
	setCharacterNames()				--add decoy character names to stations
	plot1 = treatyHolds				--start main plot with the treaty in place
	treaty = true
	initialAssetsEvaluated = false
	plotC = autoCoolant				--enable buttons for turning on and off automated cooling
	plotCI = cargoInventory			--manage button on relay/operations to show cargo inventory
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	plotPB = playerBorderCheck		--monitor players positions relative to neutral border zone
	plotPWC = playerWarCrimeCheck	--be sure players do not commit war crimes
	plotED = enemyDefenseCheck		
	plotEB = enemyBorderCheck
	plotER = enemyReinforcements
	plotMF = muckAndFlies
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
	plotCN = coolantNebulae
	plotSS = spinalShip
	plotExDk = expediteDockCheck
	plotShowPlayerInfo = showPlayerInfoOnConsole
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
	enemy_reverts = {}
	revert_timer_interval = 7
	revert_timer = revert_timer_interval
	plotRevert = revertWait
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	mainGMButtons()
end
function setVariations()
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
		adverseEffect = .999
		coolant_loss = .99999
		coolant_gain = .01
		ersAdj = 10
		enemyDestructionVictoryCondition = enemyDestructionVictoryCondition*1.1
		friendlyDestructionDefeatCondition = friendlyDestructionDefeatCondition*.9
		destructionDifferenceEndCondition = destructionDifferenceEndCondition*1.1
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
		adverseEffect = .99
		coolant_loss = .9999
		coolant_gain = .0001
		ersAdj = -5
		enemyDestructionVictoryCondition = enemyDestructionVictoryCondition*.9
		friendlyDestructionDefeatCondition = friendlyDestructionDefeatCondition*1.1
		destructionDifferenceEndCondition = destructionDifferenceEndCondition*.9
	else
		difficulty = 1		--default (normal)
		adverseEffect = .995
		coolant_loss = .99995
		coolant_gain = .001
		ersAdj = 0
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
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6}
	--						Template, 					strength
	playerShipStrength = {	["MP52 Hornet"] =			7,
							["Piranha"] = 				16,
							["Flavia P.Falcon"] =		13,
							["Phobos M3P"] =			19,
							["Atlantis"] =				52,
							["Player Cruiser"] =		40,
							["Player Missile Cr."] =	45,
							["Player Fighter"] =		7,
							["Benedict"] =				10,
							["Kiriya"] =				10,
							["Striker"] =				8,
							["ZX-Lindworm"] =			8,
							["Repulse"] =				14,
							["Ender"] =					100,
							["Nautilus"] =				12,
							["Hathcock"] =				30,
							["Maverick"] =				45,
							["Crucible"] =				45,
							["Proto-Atlantis"] =		40,
							["Surkov"] =				35,
							["Stricken"] =				40,
							["Atlantis II"] =			60,
							["Destroyer III"] =			25,
							["Redhook"] =				18	}
	--						Template				maximum cargo space
	playerShipCargo = 	{	["MP52 Hornet"] =			3,
							["Piranha"] = 				8,
							["Flavia P.Falcon"] =		15,
							["Phobos M3P"] =			10,
							["Atlantis"] =				6,
							["Player Cruiser"] =		6,
							["Player Missile Cr."] =	8,
							["Player Fighter"] =		3,
							["Benedict"] =				9,
							["Kiriya"] =				9,
							["Striker"] =				4,
							["ZX-Lindworm"] =			3,
							["Repulse"] =				12,
							["Ender"] =					20,
							["Nautilus"] =				7,
							["Hathcock"] =				6,
							["Maverick"] =				5,
							["Crucible"] =				5,
							["Proto-Atlantis"] =		4,
							["Surkov"] =				6,
							["Stricken"] =				4,
							["Atlantis II"] =			5,
							["Destroyer III"] =			7,
							["Redhook"] =				8	}
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
	playerShipNamesForProtoAtlantis = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	playerShipNamesForMaverick = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesForCrucible = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesForSurkov = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	playerShipNamesForStricken = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	playerShipNamesForAtlantisII = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesForRedhook = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	playerShipNamesForDestroyerIII = {"Trebuchet", "Pitcher", "Mutant", "Gronk", "Methuselah"}
	playerShipNamesForLeftovers = {"Foregone","Righteous","Masher"}
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
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
	--minutes and danger
	enemyReinforcementSchedule = {
		{30, 1},
		{20, 1},
		{15, 2},
		{12, 2},
		{15, 3},
		{15, 3},
		{20, 4}
	}
	cargoInventoryList = {}
	table.insert(cargoInventoryList,cargoInventory1)
	table.insert(cargoInventoryList,cargoInventory2)
	table.insert(cargoInventoryList,cargoInventory3)
	table.insert(cargoInventoryList,cargoInventory4)
	table.insert(cargoInventoryList,cargoInventory5)
	table.insert(cargoInventoryList,cargoInventory6)
	table.insert(cargoInventoryList,cargoInventory7)
	table.insert(cargoInventoryList,cargoInventory8)
	get_coolant_function = {}
	table.insert(get_coolant_function,getCoolant1)
	table.insert(get_coolant_function,getCoolant2)
	table.insert(get_coolant_function,getCoolant3)
	table.insert(get_coolant_function,getCoolant4)
	table.insert(get_coolant_function,getCoolant5)
	table.insert(get_coolant_function,getCoolant6)
	table.insert(get_coolant_function,getCoolant7)
	table.insert(get_coolant_function,getCoolant8)
	show_player_info = true
	show_only_player_name = true
	info_choice = 0
	info_choice_max = 5
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
		if curStation.comms_data.character == nil then
			if #characterNames > 0 then
				nameChoice = math.random(1,#characterNames)
				curStation.comms_data.character = characterNames[nameChoice]
				table.remove(characterNames,nameChoice)
			end
		end
	end
end
-- Terrain and environment creation functions
function setBorderZones()
	local borderStartAngle = random(0,360)	--gross orientation of default spawn point to neutral border zone
	local borderStartX, borderStartY = vectorFromAngle(borderStartAngle,random(3500,4900))
	local halfLength = random(8000,15000)
	local zoneLimit = 150000
	borderZone = {}
	innerZoneList = {}
	outerZoneList = {}
	local bzi = 1		--border zone index
	--Note: "left" and "right" refer to someone standing on the 2D board at the spawn point (0,0) looking at the zones being added;
	--		"inner" means closer to the spawn point, "outer" means further away from the spawn point
	local borderZoneLeftInnerX = {}
	local borderZoneLeftInnerY = {}
	local borderZoneRightInnerX = {}
	local borderZoneRightInnerY = {}
	local borderZoneLeftOuterX = {}
	local borderZoneLeftOuterY = {}
	local borderZoneRightOuterX = {}
	local borderZoneRightOuterY = {}
	local bzsx, bzsy = vectorFromAngle(borderStartAngle+270,halfLength)	--border zone start x and y coordinates
	table.insert(borderZoneLeftInnerX, borderStartX+bzsx)
	table.insert(borderZoneLeftInnerY, borderStartY+bzsy)
	bzsx, bzsy = vectorFromAngle(borderStartAngle+90,halfLength)	--border sone start x and y coordinates
	table.insert(borderZoneRightInnerX, borderStartX+bzsx)
	table.insert(borderZoneRightInnerY, borderStartY+bzsy)
	local bendAngle = random(1,30)	--inner and outer edges are parallel, connecting edges are bent
	local negativeBendCount = 0
	local positiveBendCount = 0
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
	local borderZoneWidth = random(10000,15000)
	bzsx, bzsy = vectorFromAngle(bendAngle,borderZoneWidth)		--border zone start x and y coordinates
	table.insert(borderZoneLeftOuterX,borderZoneLeftInnerX[bzi]+bzsx)
	table.insert(borderZoneLeftOuterY,borderZoneLeftInnerY[bzi]+bzsy)
	table.insert(borderZoneRightOuterX,borderZoneRightInnerX[bzi]+bzsx)
	table.insert(borderZoneRightOuterY,borderZoneRightInnerY[bzi]+bzsy)
	local cbz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],		--current border zone
						   borderZoneLeftOuterX[bzi],borderZoneLeftOuterY[bzi],
						   borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi])
		cbz:setColor(0,0,255)
	cbz.detect = 0
	table.insert(borderZone,cbz)
	intelGatherArtifacts = {}
	local igax, igay = vectorFromAngle(borderStartAngle+180,borderZoneWidth*2+random(1,30000))
	local iga = Artifact():setPosition(borderStartX+igax,borderStartY+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
	table.insert(intelGatherArtifacts,iga)
	local ilx, ily = vectorFromAngle(borderStartAngle+210,zoneLimit)		--inner left x and y coordinates
	local irx, iry = vectorFromAngle(borderStartAngle+150,zoneLimit)		--inner right x and y coordinates
	local ciz = Zone():setPoints(borderZoneLeftInnerX[bzi],borderZoneLeftInnerY[bzi],		--current inner zone
						   borderZoneRightInnerX[bzi],borderZoneRightInnerY[bzi],
						   borderZoneRightInnerX[bzi]+irx,borderZoneRightInnerY[bzi]+iry,
						   borderZoneLeftInnerX[bzi]+ilx,borderZoneLeftInnerY[bzi]+ily)
	if initDiagnostic then ciz:setColor(50,50,50) end
	table.insert(innerZoneList,ciz)
	local olx, oly = vectorFromAngle(borderStartAngle+330,zoneLimit)		--outer left x and y coordinates
	local orx, ory = vectorFromAngle(borderStartAngle+30,zoneLimit)		--outer right x and y coordinates
	local coz = Zone():setPoints(borderZoneRightOuterX[bzi],borderZoneRightOuterY[bzi],	--current outer zone
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
	local bzx, bzy = vectorFromAngle(bendAngle+270,random(20000,30000))		--border zone x and y corrdinates
	table.insert(borderZoneLeftInnerX,borderZoneRightInnerX[bzi]+bzx)
	table.insert(borderZoneLeftInnerY,borderZoneRightInnerY[bzi]+bzy)
	local upBound = 2 + negativeBendCount + positiveBendCount
	local cutOff = math.min(positiveBendCount,negativeBendCount)
	local newBend = random(1,30)
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
	igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
	iga = Artifact():setPosition((borderZoneLeftInnerX[2]+borderZoneRightInnerX[2])/2+igax,(borderZoneLeftInnerY[2]+borderZoneRightInnerY[2])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
	table.insert(intelGatherArtifacts,iga)
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
	igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
	iga = Artifact():setPosition((borderZoneLeftInnerX[3]+borderZoneRightInnerX[3])/2+igax,(borderZoneLeftInnerY[3]+borderZoneRightInnerY[3])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
	table.insert(intelGatherArtifacts,iga)
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
		if i == 1 then
			igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
			iga = Artifact():setPosition((borderZoneLeftInnerX[4]+borderZoneRightInnerX[4])/2+igax,(borderZoneLeftInnerY[4]+borderZoneRightInnerY[4])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
			table.insert(intelGatherArtifacts,iga)
		end
		if i == 2 then
			igax, igay = vectorFromAngle(bendAngle+180,borderZoneWidth*2+random(1,30000))
			iga = Artifact():setPosition((borderZoneLeftInnerX[5]+borderZoneRightInnerX[5])/2+igax,(borderZoneLeftInnerY[5]+borderZoneRightInnerY[5])/2+igay):setScanningParameters(difficulty*2,difficulty*2):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII"):setCallSign("Sensor Buoy"):setFaction("Human Navy")
			table.insert(intelGatherArtifacts,iga)
		end
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
	local bzlx, bzly = vectorFromAngle(borderStartAngle+225,900000)
	local bzrx, bzry = vectorFromAngle(borderStartAngle+135,900000)
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
	local planet1 = false
	local blackHole1 = false
	local planet2 = false
	local blackHole2 = false
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
		local gRegion = {}			--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then	--exit loop if there are no more adjacent spaces available
				break
			end
			local rd = math.random(1,#adjList)	--random direction to grow from adjacent list
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
		local sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		local ta = VisualAsteroid():setPosition(psx,psy)
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
				pStation.comms_data.gossip = gossipSnippets[ni]
				table.remove(gossipSnippets,ni)
			end
		end
		gp = gp + 1						--set next station number
		local rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	until(not neutralStationsRemain or not humanStationsRemain or not kraylorStationsRemain)
	if diagnostic then print(string.format("Human stations: %i, Kraylor stations: %i, Neutral stations: %i",#humanStationList,#kraylorStationList,#neutralStationList)) end
	if not diagnostic then
		local nebula_count = math.random(7,25)
		local nebula_list = placeRandomListAroundPoint(Nebula,nebula_count,1,150000,0,0)
		local nebula_index = 0
		for i=1,#nebula_list do
			nebula_list[i].lose = false
			nebula_list[i].gain = false
		end
		coolant_nebula = {}
		for i=1,math.random(math.floor(nebula_count/2)) do
			nebula_index = math.random(1,#nebula_list)
			table.insert(coolant_nebula,nebula_list[nebula_index])
			table.remove(nebula_list,nebula_index)
			if math.random(1,100) < 50 then
				coolant_nebula[#coolant_nebula].lose = true
			else
				coolant_nebula[#coolant_nebula].gain = true
			end
		end
	end
end
function insertPlanet1()
	local tSize = 15
	grid[gx][gy] = gp
	local gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		local rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	end
	local sri = math.random(1,#gRegion)
	local bwx = (gRegion[sri][1] - (gbHigh/2))*gSize
	local bwy = (gRegion[sri][2] - (gbHigh/2))*gSize
	planetBespin = Planet():setPosition(bwx,bwy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Bespin")
	planetBespin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription("Mining and Gambling")
	gp = gp + 1
	local rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function insertPlanet2()
	local tSize = 15
	grid[gx][gy] = gp
	local gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		local rd = math.random(1,#adjList)
		grid[adjList[rd][1]][adjList[rd][2]] = gp
		table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
	end
	adjList = getAdjacentGridLocations(gx,gy)
	if #adjList < 1 then
		adjList = getAllAdjacentGridLocations(gx,gy)	
	end
	local sri = math.random(1,#gRegion)
	local msx = (gRegion[sri][1] - (gbHigh/2))*gSize
	local msy = (gRegion[sri][2] - (gbHigh/2))*gSize
	planetHel = Planet():setPosition(msx,msy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Helicon")
	planetHel:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	planetHel:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	planetHel:setAxialRotationTime(400.0):setDescription("M class planet")
	gp = gp + 1
	local rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function insertBlackHole()
	local tSize = 22
	grid[gx][gy] = gp
	local gRegion = {}
	table.insert(gRegion,{gx,gy})
	for i=1,tSize do
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			break
		end
		local rd = math.random(1,#adjList)
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
	local sri = math.random(1,#gRegion)
	local bhx = (gRegion[sri][1] - (gbHigh/2))*gSize
	local bhy = (gRegion[sri][2] - (gbHigh/2))*gSize
	BlackHole():setPosition(bhx,bhy)
	gp = gp + 1
	local rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function placeInner()
	if stationFaction ~= "Human Navy" then
		fb = gp									--set faction boundary
	end
	stationFaction = "Human Navy"				--set station faction
	local si = 0
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
	local si = 0
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
	local si = 0
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
function getFactionAdjacentGridLocations(lx,ly)
--adjacent empty grid locations around the grid locations of the currently building faction
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
function getFactionAdjacentGridLocationsSkip(dSkip,lx,ly)
--adjacent empty grid locations around the grid locations of the currently building faction, skip check as requested
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
function getAllAdjacentGridLocations(lx,ly)
--adjacent empty grid locations around all occupied locations
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
function getAllAdjacentGridLocationsSkip(dSkip,lx,ly)
--adjacent empty grid locations around all occupied locations, skip as requested
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
function getAdjacentGridLocations(lx,ly)
--adjacent empty grid locations around the most recently placed item
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
function getAdjacentGridLocationsSkip(dSkip,lx,ly)
--adjacent empty grid locations around the most recently placed item, skip as requested
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
---------------------------
-- Game Master functions --
---------------------------
function mainGMButtons()
	clearGMFunctions()
	local playerShipCount = 0
	local highestPlayerIndex = 0
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				playerShipCount = playerShipCount + 1
			end
			highestPlayerIndex = pidx
		end
	end
	addGMFunction(string.format("+Player ships %i/%i",playerShipCount,highestPlayerIndex),playerShip)
	addGMFunction("+Set Time Limit",setGameTimeLimit)
	addGMFunction("+Show Player Info",setShowPlayerInfo)
	GMBelligerentKraylors = nil
	GMLimitedWar = nil
	GMFullWar = nil
end
function setShowPlayerInfo()
	clearGMFunctions()
	addGMFunction("-From Player Info",mainGMButtons)
	local button_label = "Show Info"
	if show_player_info then
		button_label = string.format("%s*",button_label)
	end
	addGMFunction(button_label,function()
		show_player_info = true
		setShowPlayerInfo()
	end)
	button_label = "Omit Info"
	if not show_player_info then
		button_label = string.format("%s*",button_label)
	end
	addGMFunction(button_label,function()
		show_player_info = false
		setShowPlayerInfo()
	end)
	button_label = "Only Name"
	if show_only_player_name then
		button_label = string.format("%s*",button_label)
	end
	addGMFunction(button_label,function()
		show_only_player_name = true
		setShowPlayerInfo()
	end)
	button_label = "More than Name"
	if not show_only_player_name then
		button_label = string.format("%s*",button_label)
	end
	addGMFunction(button_label,function()
		show_only_player_name = false
		setShowPlayerInfo()
	end)
	if show_player_info then
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local player_name = p:getCallSign()
				if p.show_name_helm == nil then
					p.show_name_helm = true
				end
				if p.show_name_helm then
					button_label = string.format("%s Helm*",player_name)
				else
					button_label = string.format("%s Helm",player_name)
				end
				addGMFunction(button_label,function()
					if p.show_name_helm then
						p.show_name_helm = false
					else
						p.show_name_helm = true
					end
					setShowPlayerInfo()
				end)
				if p.show_name_weapons then
					button_label = string.format("%s Weapons*",player_name)
				else
					button_label = string.format("%s Weapons",player_name)
				end
				addGMFunction(button_label,function()
					if p.show_name_weapons then
						p.show_name_weapons = false
					else
						p.show_name_weapons = true
					end
					setShowPlayerInfo()
				end)
				if p.show_name_engineer then
					button_label = string.format("%s Engineer*",player_name)
				else
					button_label = string.format("%s Engineer",player_name)
				end
				addGMFunction(button_label,function()
					if p.show_name_engineer then
						p.show_name_engineer = false
					else
						p.show_name_engineer = true
					end
					setShowPlayerInfo()
				end)
			end
		end
	end
end
function showPlayerInfoOnConsole(delta)
	if show_player_info then
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local player_name = p:getCallSign()
				if p.player_info_timer == nil then
					p.player_info_timer = delta + 5
				end
				p.player_info_timer = p.player_info_timer - delta
				if p.player_info_timer < 0 then
					if show_only_player_name then
						if p.show_name_helm then
							if p:hasPlayerAtPosition("Helms") then
								p.name_helm = "name_helm"
								p:addCustomInfo("Helms",p.name_helm,player_name)
							end
						else
							if p.name_helm ~= nil then
								p:removeCustom(p.name_helm)
								p.name_helm = nil
							end
						end
						if p.show_name_weapons then
							if p:hasPlayerAtPosition("Weapons") then
								p.name_weapons = "name_weapons"
								p:addCustomInfo("Weapons",p.name_weapons,player_name)
							end
						else
							if p.name_weapons ~= nil then
								p:removeCustom(p.name_weapons)
								p.name_weapons = nil
							end
						end
						if p.show_name_engineer then
							if p:hasPlayerAtPosition("Engineering") then
								p.name_engineer = "name_engineer"
								p:addCustomInfo("Engineering",p.name_engineer,player_name)
							end
						else
							if p.name_engineer ~= nil then
								p:removeCustom(p.name_engineer)
								p.name_engineer = nil
							end
						end
						p.player_info_timer = delta + 5
					else	--show player name and other info
						if p.name_toggle == nil then
							p.name_toggle = true
						end
						if p.name_toggle then	--show player name
							if p.show_name_helm then
								if p:hasPlayerAtPosition("Helms") then
									p.name_helm = "name_helm"
									p:addCustomInfo("Helms",p.name_helm,player_name)
								end
							else
								if p.name_helm ~= nil then
									p:removeCustom(p.name_helm)
									p.name_helm = nil
								end
							end
							if p.show_name_weapons then
								if p:hasPlayerAtPosition("Weapons") then
									p.name_weapons = "name_weapons"
									p:addCustomInfo("Weapons",p.name_weapons,player_name)
								end
							else
								if p.name_weapons ~= nil then
									p:removeCustom(p.name_weapons)
									p.name_weapons = nil
								end
							end
							if p.show_name_engineer then
								if p:hasPlayerAtPosition("Engineering") then
									p.name_engineer = "name_engineer"
									p:addCustomInfo("Engineering",p.name_engineer,player_name)
								end
							else
								if p.name_engineer ~= nil then
									p:removeCustom(p.name_engineer)
									p.name_engineer = nil
								end
							end
							p.name_toggle = false
							p.player_info_timer = delta + 5
						else	--show other info
							local ship_info = ""
							info_choice = info_choice + 1
							if info_choice > info_choice_max then
								info_choice = 1
							end
							if info_choice == 1 then
								ship_info = string.format("Repair Crew: %i",p:getRepairCrewCount())
								if p.maxRepairCrew ~= nil then
									ship_info = string.format("%s/%i",ship_info,p.maxRepairCrew)
								end
							elseif info_choice == 2 then
								ship_info = string.format("Hull: %i/%i",math.floor(p:getHull()),math.floor(p:getHullMax()))
							elseif info_choice == 3 then
								ship_info = "Shield: "
								if p:getShieldCount() == 1 then
									ship_info = string.format("%s%i/%i",ship_info,math.floor(p:getShieldLevel(0)),math.floor(p:getShieldMax(0)))
								else
									ship_info = string.format("%sF:%i/%i R:%i/%i",ship_info,math.floor(p:getShieldLevel(0)),math.floor(p:getShieldMax(0)),math.floor(p:getShieldLevel(1)),math.floor(p:getShieldMax(1)))
								end
							elseif info_choice == 4 then
								local beam_count = 0
								for i=0,15 do
									if p:getBeamWeaponRange(i) > 0 then
										beam_count = beam_count + 1
									end
								end
								ship_info = string.format("Beams: %i, Tubes: %i",beam_count,p:getWeaponTubeCount())
							else
								ship_info = p:getTypeName()
								print(ship_info)
								if ship_info == nil then
									ship_info = string.format("Repair Crew: %i",p:getRepairCrewCount())
								else
									ship_info = string.format("Type: %s",ship_info)
								end
							end
							if p.show_name_helm then
								if p:hasPlayerAtPosition("Helms") then
									p.name_helm = "name_helm"
									p:addCustomInfo("Helms",p.name_helm,ship_info)
								end
							else
								if p.name_helm ~= nil then
									p:removeCustom(p.name_helm)
									p.name_helm = nil
								end
							end
							if p.show_name_weapons then
								if p:hasPlayerAtPosition("Weapons") then
									p.name_weapons = "name_weapons"
									p:addCustomInfo("Weapons",p.name_weapons,ship_info)
								end
							else
								if p.name_weapons ~= nil then
									p:removeCustom(p.name_weapons)
									p.name_weapons = nil
								end
							end
							if p.show_name_engineer then
								if p:hasPlayerAtPosition("Engineering") then
									p.name_engineer = "name_engineer"
									p:addCustomInfo("Engineering",p.name_engineer,ship_info)
								end
							else
								if p.name_engineer ~= nil then
									p:removeCustom(p.name_engineer)
									p.name_engineer = nil
								end
							end
							p.name_toggle = true
							p.player_info_timer = delta + 3
						end
					end
				end
			end
		end
	else	--not show player info
		for pidx=1,8 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.name_helm ~= nil then
					p:removeCustom(p.name_helm)
					p.name_helm = nil
				end
				if p.name_weapons ~= nil then
					p:removeCustom(p.name_weapons)
					p.name_weapons = nil
				end
				if p.name_engineer ~= nil then
					p:removeCustom(p.name_engineer)
					p.name_engineer = nil
				end
			end
		end
	end
end
function playerShip()
	clearGMFunctions()
	addGMFunction("-From Player ships",mainGMButtons)
	addGMFunction("+Describe stock",describeStockPlayerShips)
	addGMFunction("+Describe special",describeSpecialPlayerShips)
	if playerNarsil == nil then
		addGMFunction("Narsil",createPlayerShipNarsil)
	end
	if playerHeadhunter == nil then
		addGMFunction("Headhunter",createPlayerShipHeadhunter)
	end
	if playerBlazon == nil then
		addGMFunction("Blazon",createPlayerShipBlazon)
	end
	if playerSting == nil then
		addGMFunction("Sting",createPlayerShipSting)
	end
	if playerSpyder == nil then
		addGMFunction("Spyder",createPlayerShipSpyder)
	end
	if playerSpinstar == nil then
		addGMFunction("Spinstar",createPlayerShipSpinstar)
	end
	if playerSimian == nil then
		addGMFunction("Simian",createPlayerShipSimian)
	end
end
function describeSpecialPlayerShips()
	clearGMFunctions()
	addGMFunction("-Back",playerShip)
	addGMFunction("Simian",function()
		addGMMessage("Destroyer III(Simian):   Hull:100   Shield:110,70   Size:200   Repair Crew:3   Cargo:7   R.Strength:25\nDefault advanced engine:Jump (2U - 20U)   Speeds: Impulse:60   Spin:8   Accelerate:15   C.Maneuver: Boost:450 Strafe:150\nBeam:1 Turreted Speed:0.2\n   Arc:270   Direction:0   Range:0.8   Cycle:5   Damage:6\nTubes:5   Load Speed:8   Front:2   Side:2   Back:1\n   Direction:  0   Type:Exclude Mine\n   Direction:  0   Type:Exclude Mine\n   Direction:-90   Type:Homing Only\n   Direction: 90   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      10 Homing\n      04 Nuke\n      06 Mine\n      05 EMP\n      10 HVLI\nBased on player missile cruiser: short jump drive (no warp), weaker hull, added one turreted beam, fewer tubes on side, fewer homing, nuke, EMP, mine and added HVLI")
	end)	
	--[[	ships not present yet
	addGMFunction("Cobra",function()
		addGMMessage("Striker LX(Cobra): Starfighter, Patrol   Hull:120   Shield:100,100   Size:200   Repair Crew:2   Cargo:4   R.Strength:15\nDefault advanced engine:Jump (2U - 20U)   Speeds: Impulse:65   Spin:15   Accelerate:30   C.Maneuver: Boost:250 Strafe:150   Energy:800\nBeams:2 Turreted Speed:0.1\n   Arc:100   Direction:-15   Range:1   Cycle:6   Damage:6\n   Arc:100   Direction: 15   Range:1   Cycle:6   Damage:6\nTubes:2 Rear:2\n   Direction:180   Type:Any\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      2 Nuke\n      3 Mine\n      3 EMP\n      6 HVLI\nBased on Striker: stronger shields, more energy, jump drive (vs none), faster impulse, slower turret, two rear tubes (vs none)")
	end)
	addGMFunction("Holmes",function()
		addGMMessage("Holmes: Corvette, Popper   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo Space:6   R.Strength:35\nDefault advanced engine:Warp (750)   Speeds: Impulse:70   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:4 Broadside\n   Arc:60   Direction:-85   Range:1   Cycle:6   Damage:5\n   Arc:60   Direction:-95   Range:1   Cycle:6   Damage:5\n   Arc:60   Direction: 85   Range:1   Cycle:6   Damage:5\n   Arc:60   Direction: 95   Range:1   Cycle:6   Damage:5\nTubes:4   Load Speed:8   Front:3   Back:1\n   Direction:   0   Type:Homing Only - Small\n   Direction:   0   Type:Homing Only\n   Direction:   0   Type:Homing Only - Large\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      06 Mine\nBased on Crucible: Slower impulse, broadside beams, no side tubes, front tubes homing only")
	end)
	addGMFunction("Rattler",function()
		addGMMessage("MX-Lindworm (Rattler): Starfighter, Bomber   Hull:75   Shield:40   Size:100   Repair Crew:2   Cargo:3   R.Strength:10\nDefault advanced engine:Jump (3U - 20U)   Speeds: Impulse:85   Spin:15   Accelerate:25   C.Maneuver: Boost:250 Strafe:150   Energy:400\nBeam:1 Turreted Speed:1\n   Arc:270   Direction:180   Range:0.7   Cycle:6   Damage:2\nTubes:3   Load Speed:10   Front:3 (small)\n   Direction: 0   Type:Any - small\n   Direction: 1   Type:HVLI Only - small\n   Direction:-1   Type:HVLI Only - small\n   Ordnance stock and type:\n      03 Homing\n      12 HVLI\nBased on ZX-Lindworm: More repair crew, faster impulse, jump drive, slower turret")
	end)
	addGMFunction("Rogue",function()
		addGMMessage("Maverick XP(Rogue): Corvette, Gunner   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo:5   R.Strength:23\nDefault advanced engine:Jump (2U - 20U)   Speeds: Impulse:65   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:1 Turreted Speed:0.1   5X heat   5X energy\n   Arc:270   Direction:  0   Range:1.8   Cycle:18   Damage:18\nTubes:3   Load Speed:8   Side:2   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      06 Homing\n      02 Nuke\n      02 Mine\n      04 EMP\n      10 HVLI\nBased on Maverick: slower impulse, jump (no warp), one heavy slow turreted beam (not 6 beams)")
	end)
	--]]	
end
function describeStockPlayerShips()
	clearGMFunctions()
	addGMFunction("-Back",playerShip)
	addGMFunction("Atlantis",function()
		addGMMessage("Atlantis: Corvette, Destroyer   Hull:250   Shield:200,200   Size:400   Repair Crew:3   Cargo:6   R.Strength:52\nDefault advanced engine:Jump   Speeds: Impulse:90   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:100   Direction:-20   Range:1.5   Cycle:6   Damage:8\n   Arc:100   Direction: 20   Range:1.5   Cycle:6   Damage:8\nTubes:5   Load Speed:10   Side:4   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      04 Nuke\n      08 Mine\n      06 EMP\n      20 HVLI\nA refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.")
	end)
	addGMFunction("Benedict",function()
		addGMMessage("Benedict: Corvette, Freighter/Carrier   Hull:200   Shield:70,70   Size:400   Repair Crew:3   Cargo Space:9   R.Strength:10\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette\nDefault advanced engine:Jump (5U - 90U)   Speeds: Impulse:60   Spin:6   Accelerate:8   C.Maneuver: Boost:400 Strafe:250\nBeams:2 Turreted Speed:6\n   Arc:90   Direction:  0   Range:1.5   Cycle:6   Damage:4\n   Arc:90   Direction:180   Range:1.5   Cycle:6   Damage:4\nBenedict is an improved version of the Jump Carrier")
	end)
	addGMFunction("Crucible",function()
		addGMMessage("Crucible: Corvette, Popper   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo Space:5   R.Strength:45\nDefault advanced engine:Warp (750)   Speeds: Impulse:80   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:70   Direction:-30   Range:1   Cycle:6   Damage:5\n   Arc:70   Direction: 30   Range:1   Cycle:6   Damage:5\nTubes:6   Load Speed:8   Front:3   Side:2   Back:1\n   Direction:   0   Type:HVLI Only - Small\n   Direction:   0   Type:HVLI Only\n   Direction:   0   Type:HVLI Only - Large\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      08 Homing\n      04 Nuke\n      06 Mine\n      06 EMP\n      24 HVLI\nA number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis")
	end)
	addGMFunction("Ender",function()
		addGMMessage("Ender: Dreadnaught, Battlecruiser   Hull:100   Shield:1200,1200   Size:2000   Repair Crew:8   Cargo Space:20   R.Strength:100\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette   Energy:1200\nDefault advanced engine:Jump   Speeds: Impulse:30   Spin:2   Accelerate:6   C.Maneuver: Boost:800 Strafe:500\nBeams:12 6 left, 6 right turreted Speed:6\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.1   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.0   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.8   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.3   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:5.9   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.4   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.7   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:5.6   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:6.6   Damage:4\n   Arc:120   Direction:-90   Range:2.5   Cycle:5.5   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.5   Damage:4\n   Arc:120   Direction: 90   Range:2.5   Cycle:6.2   Damage:4\nTubes:2   Load Speed:8   Front:1   Back:1\n   Direction:   0   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      6 Homing\n      6 Mine")
	end)
	addGMFunction("Flavia P.Falcon",function()
		addGMMessage("Flavia P.Falcon: Frigate, Light Transport   Hull:100   Shield:70,70   Size:200   Repair Crew:8   Cargo Space:15   R.Strength:13\nDefault advanced engine:Warp (500)   Speeds: Impulse:60   Spin:10   Accelerate:10   C.Maneuver: Boost:250 Strafe:150\nBeams:2 rear facing\n   Arc:40   Direction:170   Range:1.2   Cycle:6   Damage:6\n   Arc:40   Direction:190   Range:1.2   Cycle:6   Damage:6\nTubes:1   Load Speed:20   Back:1\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      3 Homing\n      1 Nuke\n      1 Mine\n      5 HVLI\nThe Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.")
	end)
	addGMFunction("Hathcock",function()
		addGMMessage("Hathcock: Frigate, Cruiser: Sniper   Hull:120   Shield:70,70   Size:200   Repair Crew:2   Cargo Space:6   R.Strength:30\nDefault advanced engine:Jump   Speeds: Impulse:50   Spin:15   Accelerate:8   C.Maneuver: Boost:200 Strafe:150\nBeams:4 front facing\n   Arc:04   Direction:0   Range:1.4   Cycle:6   Damage:4\n   Arc:20   Direction:0   Range:1.2   Cycle:6   Damage:4\n   Arc:60   Direction:0   Range:1.0   Cycle:6   Damage:4\n   Arc:90   Direction:0   Range:0.8   Cycle:6   Damage:4\nTubes:2   Load Speed:15   Side:2\n   Direction:-90   Type:Any\n   Direction: 90   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      1 Nuke\n      2 EMP\n      8 HVLI\nLong range narrow beam and some point defense beams, broadside missiles. Agile for a frigate")
	end)
	addGMFunction("Kiriya",function()
		addGMMessage("Kiriya: Corvette, Freighter/Carrier   Hull:200   Shield:70,70   Size:400   Repair Crew:3   Cargo Space:9   R.Strength:10\nShip classes that may dock with Benedict:Starfighter, Frigate, Corvette\nDefault advanced engine:Warp (750)   Speeds: Impulse:60   Spin:6   Accelerate:8   C.Maneuver: Boost:400 Strafe:250\nBeams:2 Turreted Speed:6\n   Arc:90   Direction:  0   Range:1.5   Cycle:6   Damage:4\n   Arc:90   Direction:180   Range:1.5   Cycle:6   Damage:4\nKiriya is an improved warp drive version of the Jump Carrier")
	end)
	addGMFunction("MP52 Hornet",function()
		addGMMessage("MP52 Hornet: Starfighter, Interceptor   Hull:70   Shield:60   Size:100   Repair Crew:1   Cargo:3   R.Strength:7\nDefault advanced engine:None   Speeds: Impulse:125   Spin:32   Accelerate:40   C.Maneuver: Boost:600   Energy:400\nBeams:2\n   Arc:30   Direction: 5   Range:.9   Cycle:4   Damage:2.5\n   Arc:30   Direction:-5   Range:.9   Cycle:4   Damage:2.5\nThe MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon.")
	end)
	addGMFunction("Maverick",function()
		addGMMessage("Maverick: Corvette, Gunner   Hull:160   Shield:160,160   Size:200   Repair Crew:4   Cargo:5   R.Strength:45\nDefault advanced engine:Warp (800)   Speeds: Impulse:80   Spin:15   Accelerate:40   C.Maneuver: Boost:400 Strafe:250\nBeams:6   3 forward, 2 side, 1 back (turreted speed .5)\n   Arc:10   Direction:  0   Range:2.0   Cycle:6   Damage:6\n   Arc: 90   Direction:-20   Range:1.5   Cycle:6   Damage:8\n   Arc: 90   Direction: 20   Range:1.5   Cycle:6   Damage:8\n   Arc: 40   Direction:-70   Range:1.0   Cycle:4   Damage:6\n   Arc: 40   Direction: 70   Range:1.0   Cycle:4   Damage:6\n   Arc:180   Direction:180   Range:0.8   Cycle:6   Damage:4   (turreted speed: .5)\nTubes:3   Load Speed:8   Side:2   Back:1\n   Direction:-90   Type:Exclude Mine\n   Direction: 90   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      06 Homing\n      02 Nuke\n      02 Mine\n      04 EMP\n      10 HVLI\nA number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis")
	end)
	addGMFunction("Nautilus",function()
		addGMMessage("Nautilus: Frigate, Mine Layer   Hull:100   Shield:60,60   Size:200   Repair Crew:4   Cargo:7   R.Strength:12\nDefault advanced engine:Jump   Speeds: Impulse:100   Spin:10   Accelerate:15   C.Maneuver: Boost:250 Strafe:150\nBeams:2 Turreted Speed:6\n   Arc:90   Direction: 35   Range:1   Cycle:6   Damage:6\n   Arc:90   Direction:-35   Range:1   Cycle:6   Damage:6\nTubes:3   Load Speed:10   Back:3\n   Direction:180   Type:Mine Only\n   Direction:180   Type:Mine Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Mine\nSmall mine laying vessel with minimal armament, shields and hull")
	end)
	addGMFunction("Phobos MP3",function()
		addGMMessage("Phobos MP3: Frigate, Cruiser   Hull:200   Shield:100,100   Size:200   Repair Crew:3   Cargo:10   R.Strength:19\nDefault advanced engine:None   Speeds: Impulse:80   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:90   Direction:-15   Range:1.2   Cycle:8   Damage:6\n   Arc:90   Direction: 15   Range:1.2   Cycle:8   Damage:6\nTubes:3   Load Speed:10   Front:2   Back:1\n   Direction: -1   Type:Exclude Mine\n   Direction:  1   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      10 Homing\n      02 Nuke\n      04 Mine\n      03 EMP\n      20 HVLI\nPlayer variant of the Phobos M3, not as strong as the atlantis, but has front firing tubes, making it an easier to use ship in some scenarios.")
	end)
	addGMFunction("Piranha",function()
		addGMMessage("Piranha: Frigate, Cruiser: Light Artillery   Hull:120   Shield:70,70   Size:200   Repair Crew:2   Cargo:8   R.Strength:16\nDefault advanced engine:None   Speeds: Impulse:60   Spin:10   Accelerate:8   C.Maneuver: Boost:200 Strafe:150\nTubes:8   Load Speed:8   Side:6   Back:2\n   Direction:-90   Type:HVLI and Homing Only\n   Direction:-90   Type:Any\n   Direction:-90   Type:HVLI and Homing Only\n   Direction: 90   Type:HVLI and Homing Only\n   Direction: 90   Type:Any\n   Direction: 90   Type:HVLI and Homing Only\n   Direction:170   Type:Mine Only\n   Direction:190   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      06 Nuke\n      08 Mine\n      20 HVLI\nThis combat-specialized Piranha F12 adds mine-laying tubes, combat maneuvering systems, and a jump drive.")
	end)	
	addGMFunction("Player Cruiser",function()
		addGMMessage("Player Cruiser:   Hull:200   Shield:80,80   Size:400   Repair Crew:3   Cargo:6   R.Strength:40\nDefault advanced engine:Jump   Speeds: Impulse:90   Spin:10   Accelerate:20   C.Maneuver: Boost:400 Strafe:250\nBeams:2\n   Arc:90   Direction:-15   Range:1   Cycle:6   Damage:10\n   Arc:90   Direction: 15   Range:1   Cycle:6   Damage:10\nTubes:3   Load Speed:8   Front:2   Back:1\n   Direction: -5   Type:Exclude Mine\n   Direction:  5   Type:Exclude Mine\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      12 Homing\n      04 Nuke\n      08 Mine\n      06 EMP")
	end)
	addGMFunction("Player Fighter",function()
		addGMMessage("Player Fighter:   Hull:60   Shield:40   Size:100   Repair Crew:3   Cargo:3   R.Strength:7\nDefault advanced engine:None   Speeds: Impulse:110   Spin:20   Accelerate:40   C.Maneuver: Boost:600   Energy:400\nBeams:2\n   Arc:40   Direction:-10   Range:1   Cycle:6   Damage:8\n   Arc:40   Direction: 10   Range:1   Cycle:6   Damage:8\nTube:1   Load Speed:10   Front:1\n   Direction:0   Type:HVLI Only\n   Ordnance stock and type:\n      4 HVLI")
	end)
	addGMFunction("Player Missile Cr.",function()
		addGMMessage("Player Missile Cr.:   Hull:200   Shield:110,70   Size:200   Repair Crew:3   Cargo:8   R.Strength:45\nDefault advanced engine:Warp (800)   Speeds: Impulse:60   Spin:8   Accelerate:15   C.Maneuver: Boost:450 Strafe:150\nTubes:7   Load Speed:8   Front:2   Side:4   Back:1\n   Direction:  0   Type:Exclude Mine\n   Direction:  0   Type:Exclude Mine\n   Direction: 90   Type:Homing Only\n   Direction: 90   Type:Homing Only\n   Direction:-90   Type:Homing Only\n   Direction:-90   Type:Homing Only\n   Direction:180   Type:Mine Only\n   Ordnance stock and type:\n      30 Homing\n      08 Nuke\n      12 Mine\n      10 EMP")
	end)	
	addGMFunction("Repulse",function()
		addGMMessage("Repulse: Frigate, Armored Transport   Hull:120   Shield:80,80   Size:200   Repair Crew:8   Cargo:12   R.Strength:14\nDefault advanced engine:Jump   Speeds: Impulse:55   Spin:9   Accelerate:10   C.Maneuver: Boost:250 Strafe:150\nBeams:2 Turreted Speed:5\n   Arc:200   Direction: 90   Range:1.2   Cycle:6   Damage:5\n   Arc:200   Direction:-90   Range:1.2   Cycle:6   Damage:5\nTubes:2   Load Speed:20   Front:1   Back:1\n   Direction:  0   Type:Any\n   Direction:180   Type:Any\n   Ordnance stock and type:\n      4 Homing\n      6 HVLI\nJump/Turret version of Flavia Falcon")
	end)
	addGMFunction("Striker",function()
		addGMMessage("Striker: Starfighter, Patrol   Hull:120   Shield:50,30   Size:200   Repair Crew:2   Cargo:4   R.Strength:8\nDefault advanced engine:None   Speeds: Impulse:45   Spin:15   Accelerate:30   C.Maneuver: Boost:250 Strafe:150   Energy:500\nBeams:2 Turreted Speed:6\n   Arc:100   Direction:-15   Range:1   Cycle:6   Damage:6\n   Arc:100   Direction: 15   Range:1   Cycle:6   Damage:6\nThe Striker is the predecessor to the advanced striker, slow but agile, but does not do an extreme amount of damage, and lacks in shields")
	end)
	addGMFunction("ZX-Lindworm",function()
		addGMMessage("ZX-Lindworm: Starfighter, Bomber   Hull:75   Shield:40   Size:100   Repair Crew:1   Cargo:3   R.Strength:8\nDefault advanced engine:None   Speeds: Impulse:70   Spin:15   Accelerate:25   C.Maneuver: Boost:250 Strafe:150   Energy:400\nBeam:1 Turreted Speed:4\n   Arc:270   Direction:180   Range:0.7   Cycle:6   Damage:2\nTubes:3   Load Speed:10   Front:3 (small)\n   Direction: 0   Type:Any - small\n   Direction: 1   Type:HVLI Only - small\n   Direction:-1   Type:HVLI Only - small\n   Ordnance stock and type:\n      03 Homing\n      12 HVLI")
	end)
end
function setGameTimeLimit()
	clearGMFunctions()
	addGMFunction("-From time limit",mainGMButtons)
	addGMFunction("15 minutes", function()
		gameTimeLimit = 15*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 15 minutes")
	end)
	addGMFunction("20 minutes", function()
		gameTimeLimit = 20*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 20 minutes")
	end)
	addGMFunction("25 minutes", function()
		gameTimeLimit = 25*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 25 minutes")
	end)
	addGMFunction("30 minutes", function()
		gameTimeLimit = 30*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 30 minutes")
	end)
	addGMFunction("40 minutes", function()
		gameTimeLimit = 40*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 40 minutes")
	end)
	addGMFunction("45 minutes", function()
		gameTimeLimit = 45*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 45 minutes")
	end)
	addGMFunction("50 minutes", function()
		gameTimeLimit = 50*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 50 minutes")
	end)
	addGMFunction("55 minutes", function()
		gameTimeLimit = 55*60
		plot2 = timedGame
		playWithTimeLimit = true
		addGMMessage("Game time limit set to 55 minutes")
	end)
end
-- Dynamic game master buttons --
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
-- New player ship types via GM button
function createPlayerShipNarsil()
	playerNarsil = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Narsil")
	playerNarsil:setTypeName("Proto-Atlantis")
	playerNarsil:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerNarsil:setImpulseMaxSpeed(70)					--slower impulse max (vs 90)
	playerNarsil:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerNarsil:setJumpDrive(false)					--no Jump
	playerNarsil:setWarpDrive(true)						--add warp
	playerNarsil:setHullMax(200)						--weaker hull (vs 250)
	playerNarsil:setHull(200)							
	playerNarsil:setShieldsMax(150,150)					--weaker shields (vs 200)
	playerNarsil:setShields(150,150)
	playerNarsil:setWeaponTubeCount(6)					--one more forward tube, less flexible ordnance
	playerNarsil:setWeaponTubeDirection(0,0)			--front facing
	playerNarsil:setWeaponTubeExclusiveFor(0,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(1,-90)			--left facing
	playerNarsil:weaponTubeDisallowMissle(1,"Mine")		--all but mine
	playerNarsil:setWeaponTubeDirection(2,-90)			--left facing
	playerNarsil:setWeaponTubeExclusiveFor(2,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(3,90)			--right facing
	playerNarsil:weaponTubeDisallowMissle(3,"Mine")		--all but mine
	playerNarsil:setWeaponTubeDirection(4,90)			--right facing
	playerNarsil:setWeaponTubeExclusiveFor(4,"HVLI")	--HVLI only
	playerNarsil:setWeaponTubeDirection(5,180)			--rear facing
	playerNarsil:setWeaponTubeExclusiveFor(5,"Mine")	--Mine only
	playerNarsil:addReputationPoints(50)
	removeGMFunction("Narsil")
end
function createPlayerShipHeadhunter()
	playerHeadhunter = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Headhunter")
	playerHeadhunter:setTypeName("Redhook")
	playerHeadhunter:setRepairCrewCount(4)						--more repair crew (vs 2)
	playerHeadhunter:setJumpDriveRange(2000,25000)				--shorter jump drive range (vs 5-50)
	playerHeadhunter:setHullMax(140)							--stronger hull (vs 120)
	playerHeadhunter:setHull(140)
	playerHeadhunter:setShieldsMax(100, 100)					--stronger shields (vs 70, 70)
	playerHeadhunter:setShields(100, 100)
	playerHeadhunter:setBeamWeapon(0, 10, 0, 1200.0, 4.0, 4)	--one beam (vs 0)
	playerHeadhunter:setBeamWeaponTurret(0, 80, 0, 1)			--slow turret 
	playerHeadhunter:setWeaponTubeCount(7)						--one fewer mine tube, but EMPs added
	playerHeadhunter:setWeaponTubeDirection(6, 180)				--mine tube points straight back
	playerHeadhunter:setWeaponTubeExclusiveFor(0,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(1,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(2,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(3,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(4,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(5,"HVLI")
	playerHeadhunter:setWeaponTubeExclusiveFor(6,"Mine")
	playerHeadhunter:weaponTubeAllowMissle(1,"Homing")
	playerHeadhunter:weaponTubeAllowMissle(1,"EMP")
	playerHeadhunter:weaponTubeAllowMissle(1,"Nuke")
	playerHeadhunter:weaponTubeAllowMissle(4,"Homing")
	playerHeadhunter:weaponTubeAllowMissle(4,"EMP")
	playerHeadhunter:weaponTubeAllowMissle(4,"Nuke")
	playerHeadhunter:setWeaponStorageMax("Mine",4)				--fewer mines (vs 8)
	playerHeadhunter:setWeaponStorage("Mine", 4)				
	playerHeadhunter:setWeaponStorageMax("EMP",4)				--more EMPs (vs 0)
	playerHeadhunter:setWeaponStorage("EMP", 4)					
	playerHeadhunter:setWeaponStorageMax("Nuke",4)				--fewer Nukes (vs 6)
	playerHeadhunter:setWeaponStorage("Nuke", 4)				
	playerHeadhunter:addReputationPoints(50)
	removeGMFunction("Headhunter")
end
function createPlayerShipBlazon()
	playerBlazon = PlayerSpaceship():setTemplate("Striker"):setFaction("Human Navy"):setCallSign("Blazon")
	playerBlazon:setTypeName("Stricken")
	playerBlazon:setRepairCrewCount(2)				
	playerBlazon:setImpulseMaxSpeed(105)			--vs 45		
	playerBlazon:setRotationMaxSpeed(35)			--vs 15
	playerBlazon:setShieldsMax(80,50)				--vs 50,30
	playerBlazon:setShields(80,50)
	playerBlazon:setBeamWeaponTurret(0,60,-15,2)	--vs arc width of 100 & turret speed of 6
	playerBlazon:setBeamWeaponTurret(1,60, 15,2)
	playerBlazon:setBeamWeapon(2,20,0,1200,6,5)		--vs only 2 turret beams (this is a 3rd beam)
	playerBlazon:setWeaponTubeCount(3)				--vs no tubes
	playerBlazon:setWeaponTubeDirection(0,-60)
	playerBlazon:setWeaponTubeDirection(1,60)
	playerBlazon:setWeaponTubeDirection(2,180)
	playerBlazon:weaponTubeDisallowMissle(0,"Mine")
	playerBlazon:weaponTubeDisallowMissle(1,"Mine")
	playerBlazon:setWeaponTubeExclusiveFor(2,"Mine")
	playerBlazon:setWeaponStorageMax("Homing",6)
	playerBlazon:setWeaponStorage("Homing",6)
	playerBlazon:setWeaponStorageMax("EMP",2)
	playerBlazon:setWeaponStorage("EMP",2)
	playerBlazon:setWeaponStorageMax("Nuke",2)
	playerBlazon:setWeaponStorage("Nuke",2)
	playerBlazon:setWeaponStorageMax("Mine",4)
	playerBlazon:setWeaponStorage("Mine",4)
	playerBlazon:addReputationPoints(50)
	removeGMFunction("Blazon")
end
function createPlayerShipSimian()
	playerSimian = PlayerSpaceship():setTemplate("Player Missile Cr."):setFaction("Human Navy"):setCallSign("Simian")
	playerSimian:setTypeName("Destroyer III")
	playerSimian:setWarpDrive(false)
	playerSimian:setJumpDrive(true)
	playerSimian:setJumpDriveRange(2000,20000)						--shorter than typical jump drive range (vs 5-50)
	playerSimian:setHullMax(100)									--weaker hull (vs 200)
	playerSimian:setHull(100)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerSimian:setBeamWeapon(0,  8,   0, 800.0,         5, 6)		--turreted beam (vs none)
--									    Arc, Dir, Rotate speed
	playerSimian:setBeamWeaponTurret(0, 270,   0, .2)				--slow turret
	playerSimian:setWeaponTubeCount(5)								--fewer (vs 7)
	playerSimian:setWeaponTubeDirection(2, -90)						--left (vs right)
	playerSimian:setWeaponTubeDirection(4, 180)						--rear (vs left)
	playerSimian:setWeaponTubeExclusiveFor(4,"Mine")
	playerSimian:setWeaponStorageMax("Homing",10)					--less (vs 30)
	playerSimian:setWeaponStorage("Homing", 10)				
	playerSimian:setWeaponStorageMax("Nuke",4)						--less (vs 8)
	playerSimian:setWeaponStorage("Nuke", 4)				
	playerSimian:setWeaponStorageMax("EMP",5)						--less (vs 10)
	playerSimian:setWeaponStorage("EMP", 5)				
	playerSimian:setWeaponStorageMax("Mine",6)						--less (vs 12)
	playerSimian:setWeaponStorage("Mine", 6)				
	playerSimian:setWeaponStorageMax("HVLI",10)						--more (vs 0)
	playerSimian:setWeaponStorage("HVLI", 10)				
	playerSimian:addReputationPoints(50)
	playerShip()
end
function createPlayerShipSting()
	playerSting = PlayerSpaceship():setTemplate("Hathcock"):setFaction("Human Navy"):setCallSign("Sting")
	playerSting:setTypeName("Surkov")
	playerSting:setRepairCrewCount(3)	--more repair crew (vs 2)
	playerSting:setImpulseMaxSpeed(60)	--faster impulse max (vs 50)
	playerSting:setJumpDrive(false)		--no jump
	playerSting:setWarpDrive(true)		--add warp
	playerSting:setWeaponTubeCount(3)	--one more tube for mines, no heavy ordnance
	playerSting:setWeaponTubeDirection(0, -90)
	playerSting:weaponTubeDisallowMissle(0,"Mine")
	playerSting:weaponTubeDisallowMissle(0,"Nuke")
	playerSting:weaponTubeDisallowMissle(0,"EMP")
	playerSting:setWeaponStorageMax("Mine",3)
	playerSting:setWeaponStorage("Mine",3)
	playerSting:setWeaponStorageMax("Nuke",0)
	playerSting:setWeaponStorage("Nuke",0)
	playerSting:setWeaponStorageMax("EMP",0)
	playerSting:setWeaponStorage("EMP",0)
	playerSting:setWeaponTubeDirection(1, 90)
	playerSting:weaponTubeDisallowMissle(1,"Mine")
	playerSting:weaponTubeDisallowMissle(1,"Nuke")
	playerSting:weaponTubeDisallowMissle(1,"EMP")
	playerSting:setWeaponTubeDirection(2,180)
	playerSting:setWeaponTubeExclusiveFor(2,"Mine")
	playerSting:addReputationPoints(50)
	removeGMFunction("Sting")
end
function createPlayerShipSpyder()
	playerSpyder = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Spyder")
	playerSpyder:setTypeName("Atlantis II")
	playerSpyder:setRepairCrewCount(4)					--more repair crew (vs 3)
	playerSpyder:setImpulseMaxSpeed(80)					--slower impulse max (vs 90)
	playerSpyder:setWeaponTubeCount(6)					--one more tube
	playerSpyder:setWeaponTubeDirection(5,0)			--front facing
	playerSpyder:weaponTubeDisallowMissle(5,"Mine")		--no Mine
	playerSpyder:weaponTubeDisallowMissle(5,"EMP")		--no EMP
	playerSpyder:weaponTubeDisallowMissle(5,"Nuke")		--no Nuke
	playerSpyder:setWeaponTubeDirection(0,-60)			--left front facing
	playerSpyder:setWeaponTubeDirection(1,-120)			--left rear facing
	playerSpyder:setWeaponTubeDirection(2,60)			--right front facing
	playerSpyder:setWeaponTubeDirection(3,120)			--right rear facing
	playerSpyder:addReputationPoints(50)
	removeGMFunction("Spyder")
end
function createPlayerShipSpinstar()
	playerSpinStar = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Spinstar")
	playerSpinStar:setTypeName("Proto-Atlantis")
	playerSpinStar.spine_request = false
	playerSpinStar.spine_charge = true
	playerSpinStar:setRepairCrewCount(4)				--more repair crew (vs 3)
	playerSpinStar:setImpulseMaxSpeed(70)				--slower impulse max (vs 90)
	playerSpinStar:setRotationMaxSpeed(14)				--faster spin (vs 10)
	playerSpinStar:setJumpDrive(false)					--no Jump
	playerSpinStar:setWarpDrive(true)					--add warp
	playerSpinStar:setHullMax(200)						--weaker hull (vs 250)
	playerSpinStar:setHull(200)							
	playerSpinStar:setShieldsMax(150,150)				--weaker shields (vs 200)
	playerSpinStar:setShields(150,150)
	playerSpinStar:setWeaponTubeCount(3)				--fewer tubes
	playerSpinStar:setWeaponTubeDirection(0,-90)		--one left
	playerSpinStar:weaponTubeDisallowMissle(0,"Mine")	--no broadside mine
	playerSpinStar:setWeaponTubeDirection(1,90)			--one right
	playerSpinStar:weaponTubeDisallowMissle(1,"Mine")	--no broadside mine
	playerSpinStar:setWeaponTubeDirection(2,180)		--one back
	playerSpinStar:setWeaponTubeExclusiveFor(2,"Mine")	--Mine only
	playerSpinStar:addReputationPoints(50)
	removeGMFunction("Spinstar")
end
function spinalAddBeamNow()
	playerSpinStar.spine_request = true
	playerSpinStar:setBeamWeapon(4, 5, 0, 2500.0, 0.1, 8)
end
function spinalShip(delta)
	local spine_status_info = "Spine"
	if playerSpinStar ~= nil and playerSpinStar:isValid() then
		if playerSpinStar.spine_request then	--the button has been clicked
			if playerSpinStar.spinal_countdown == nil then	
				playerSpinStar.spinal_countdown = delta + 5	--set firing time limit
			end
			if playerSpinStar.spine_button ~= nil then	--remove button while firing
				playerSpinStar:removeCustom(playerSpinStar.spine_button)
				playerSpinStar.spine_button = nil
			end
			if playerSpinStar.spine_button_tactical ~= nil then
				playerSpinStar:removeCustom(playerSpinStar.spine_button_tactical)
				playerSpinStar.spine_button_tactical = nil
			end
			playerSpinStar.spinal_countdown = playerSpinStar.spinal_countdown - delta
			if playerSpinStar.spinal_countdown < 0 then	--firing time limit expired
				playerSpinStar:setBeamWeapon(4, 5, 0, 0.0, 0.1, 8)
				playerSpinStar.spine_request = false
				playerSpinStar.spine_charge = false
				playerSpinStar.spinal_countdown = nil
			else	--show firing time limit on weapons or tactical consoles
				spine_status_info = string.format("%s: %i",spine_status_info,math.ceil(playerSpinStar.spinal_countdown))
				if playerSpinStar:hasPlayerAtPosition("Weapons") then
					playerSpinStar.spine_status_info = "spine_status_info"
					playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info,spine_status_info)
				end
				if playerSpinStar:hasPlayerAtPosition("Tactical") then
					playerSpinStar.spine_status_info_tactical = "spine_status_info_tactical"
					playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info_tactical,spine_status_info)
				end
			end
		else	--the button has not been clicked
			if playerSpinStar.spine_charge then	--weapon is charged up
				if playerSpinStar.spine_status_info ~= nil then	--remove charge status
					playerSpinStar:removeCustom(playerSpinStar.spine_status_info)
					playerSpinStar.spine_status_info = nil
				end
				if playerSpinStar.spine_status_info_tactical ~= nil then
					playerSpinStar:removeCustom(playerSpinStar.spine_status_info_tactical)
					playerSpinStar.spine_status_info_tactical = nil
				end
				if playerSpinStar.spine_button == nil then	--add fire button to weapons and/or tactical consoles
					if playerSpinStar:hasPlayerAtPosition("Weapons") then
						playerSpinStar.spine_button = "spine_button"
						playerSpinStar:addCustomButton("Weapons",playerSpinStar.spine_button,"Spinal Beam", spinalAddBeamNow)
					end
				end
				if playerSpinStar.spine_button_tactical == nil then
					if playerSpinStar:hasPlayerAtPosition("Tactical") then
						playerSpinStar.spine_button_tactical = "spine_button_tactical"
						playerSpinStar:addCustomButton("Tactical",playerSpinStar.spine_button_tactical,"Spinal Beam", spinalAddBeamNow)
					end
				end
			else	--weapon is not charged
				if playerSpinStar.charge_countdown == nil then	
					playerSpinStar.charge_countdown = delta + 30	--set charge time
				end
				playerSpinStar.charge_countdown = playerSpinStar.charge_countdown - delta
				if playerSpinStar.charge_countdown < 0 then	--charge time completed
					playerSpinStar.spine_charge = true
					playerSpinStar.charge_countdown = nil
				else	--show charge time on weapons or tactical consoles
					spine_status_info = string.format("%s Charging: %i",spine_status_info,math.ceil(playerSpinStar.charge_countdown))
					if playerSpinStar:hasPlayerAtPosition("Weapons") then
						playerSpinStar.spine_status_info = "spine_status_info"
						playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info,spine_status_info)
					end
					if playerSpinStar:hasPlayerAtPosition("Tactical") then
						playerSpinStar.spine_status_info_tactical = "spine_status_info_tactical"
						playerSpinStar:addCustomInfo("Weapons",playerSpinStar.spine_status_info_tactical,spine_status_info)
					end
				end	--countdown handling
			end	--spine weapon charge handling
		end	--spine button handling
	end	--valid player ship handling
end
--------------------------------
-- Station creation functions --
--------------------------------
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
function szt()
--Randomly choose station size template
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
function randomMineral(exclude)
	local good = mineralGoods[math.random(1,#mineralGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = mineralGoods[math.random(1,#mineralGoods)]
		until(good ~= exclude)
		return good
	end
end
function randomComponent(exclude)
	local good = componentGoods[math.random(1,#componentGoods)]
	if exclude == nil then
		return good
	else
		repeat
			good = componentGoods[math.random(1,#componentGoods)]
		until(good ~= exclude)
		return good
	end
end
--	Human and neutral stations to be placed (all need some kind of goods)
function placeAlcaleica()
	--Alcaleica
	stationAlcaleica = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAlcaleica:setPosition(psx,psy):setCallSign("Alcaleica"):setDescription("Optical Components")
    stationAlcaleica.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic = {quantity = 5,	cost = 66} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We make and supply optic components for various station and ship systems",
    	history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company"
	}
	if stationFaction == "Human Navy" then
		stationAlcaleica.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAlcaleica.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationAlcaleica.comms_data.trade.medicine = true
		end
	else
		stationAlcaleica.comms_data.trade.medicine = true
		stationAlcaleica.comms_data.trade.food = true
	end
	return stationAlcaleica
end
function placeAnderson()
	--Anderson 
	stationAnderson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(psx,psy):setCallSign("Anderson"):setDescription("Battery and software engineering")
    stationAnderson.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	battery =	{quantity = 5,	cost = 66},
        			software =	{quantity = 5,	cost = 115} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide high quality high capacity batteries and specialized software for all shipboard systems",
    	history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"
	}
	if stationFaction == "Human Navy" then
		stationAnderson.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAnderson.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationAnderson
end
function placeArcher()
	--Archer 
	stationArcher = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArcher:setPosition(psx,psy):setCallSign("Archer"):setDescription("Shield and Armor Research")
    stationArcher.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "The finest shield and armor manufacturer in the quadrant",
    	history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer"
	}
	if stationFaction == "Human Navy" then
		stationArcher.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArcher.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationArcher.comms_data.trade.medicine = true
		end
	else
		stationArcher.comms_data.trade.medicine = true
	end
	return stationArcher
end
function placeArchimedes()
	--Archimedes
	stationArchimedes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArchimedes:setPosition(psx,psy):setCallSign("Archimedes"):setDescription("Energy and particle beam components")
    stationArchimedes.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We fabricate general and specialized components for ship beam systems",
    	history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it"
	}
	if stationFaction == "Human Navy" then
		stationArchimedes.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArchimedes.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationArchimedes.comms_data.trade.medicine = true
		end
	else
		stationArchimedes.comms_data.trade.food = true
	end
	return stationArchimedes
end
function placeArmstrong()
	--Armstrong
	stationArmstrong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArmstrong:setPosition(psx,psy):setCallSign("Armstrong"):setDescription("Warp and Impulse engine manufacturing")
    stationArmstrong.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp =		{quantity = 5,	cost = 77},
        			repulsor =	{quantity = 5,	cost = 62} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis",
    	history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."
	}
	if stationFaction == "Human Navy" then
		stationArmstrong.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationArmstrong.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationArmstrong
end
function placeAsimov()
	--Asimov
	stationAsimov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAsimov:setCallSign("Asimov"):setDescription("Training and Coordination"):setPosition(psx,psy)
    stationAsimov.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 48} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector",
    	history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"
	}
	if stationFaction == "Human Navy" then
		stationAsimov.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationAsimov.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationAsimov
end
function placeBarclay()
	--Barclay
	stationBarclay = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(psx,psy):setCallSign("Barclay"):setDescription("Communication components")
    stationBarclay.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	communication =	{quantity = 5,	cost = 58} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We provide a range of communication equipment and software for use aboard ships",
    	history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station"
	}
	if stationFaction == "Human Navy" then
		stationBarclay.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationBarclay.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationBarclay.comms_data.trade.medicine = true
		end
	else
		stationBarclay.comms_data.trade.medicine = true
	end
	return stationBarclay
end
function placeBethesda()
	--Bethesda 
	stationBethesda = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBethesda:setPosition(psx,psy):setCallSign("Bethesda"):setDescription("Medical research")
    stationBethesda.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,					cost = 36},
        			medicine =	{quantity = 5,					cost = 5},
        			food =		{quantity = math.random(5,10),	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and treat exotic medical conditions",
    	history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century"
	}
	return stationBethesda
end
function placeBroeck()
	--Broeck
	stationBroeck = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBroeck:setPosition(psx,psy):setCallSign("Broeck"):setDescription("Warp drive components")
    stationBroeck.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp =	{quantity = 5,	cost = 36} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 62 },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We provide warp drive engines and components",
    	history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"
	}
	if stationFaction == "Human Navy" then
		stationBroeck.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationBroeck.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationBroeck.comms_data.trade.medicine = random(1,100) < 53
		end
	else
		stationBroeck.comms_data.trade.medicine = random(1,100) < 53
		stationBroeck.comms_data.trade.food = random(1,100) < 14
	end
	return stationBroeck
end
function placeCalifornia()
	--California
	stationCalifornia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalifornia:setPosition(psx,psy):setCallSign("California"):setDescription("Mining station")
    stationCalifornia.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	gold =		{quantity = 5,	cost = 90},
        			dilithium =	{quantity = 2,	cost = 25} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	if stationFaction == "Human Navy" then
		stationCalifornia.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCalifornia.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationCalifornia
end
function placeCalvin()
	--Calvin 
	stationCalvin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(psx,psy):setCallSign("Calvin"):setDescription("Robotic research")
    stationCalvin.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	robotic =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomComponent("robotic")] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and provide robotic systems and components",
    	history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"
	}
	if stationFaction == "Human Navy" then
		stationCalvin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCalvin.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationCalvin.comms_data.trade.food = random(1,100) < 8
	end
	return stationCalvin
end
function placeCavor()
	--Cavor 
	stationCavor = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCavor:setPosition(psx,psy):setCallSign("Cavor"):setDescription("Advanced Material components")
    stationCavor.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 42} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction",
    	history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite"
	}
	if stationFaction == "Human Navy" then
		stationCavor.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCavor.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationCavor.comms_data.trade.luxury = random(1,100) < 33
		else
			if random(1,100) < 50 then
				stationCavor.comms_data.trade.medicine = true
			else
				stationCavor.comms_data.trade.luxury = true
			end
		end
	else
		local whatTrade = random(1,100)
		if whatTrade < 33 then
			stationCavor.comms_data.trade.medicine = true
		elseif whatTrade > 66 then
			stationCavor.comms_data.trade.food = true
		else
			stationCavor.comms_data.trade.luxury = true
		end
	end
	return stationCavor
end
function placeChatuchak()
	--Chatuchak
	stationChatuchak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationChatuchak:setPosition(psx,psy):setCallSign("Chatuchak"):setDescription("Trading station")
    stationChatuchak.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here",
    	history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"
	}
	if stationFaction == "Human Navy" then
		stationChatuchak.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationChatuchak.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationChatuchak
end
function placeCoulomb()
	--Coulomb
	stationCoulomb = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCoulomb:setPosition(psx,psy):setCallSign("Coulomb"):setDescription("Shielded circuitry fabrication")
    stationCoulomb.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	circuit =	{quantity = 5,	cost = 50} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 82 },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference",
    	history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"
	}
	if stationFaction == "Human Navy" then
		stationCoulomb.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCoulomb.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationCoulomb.comms_data.trade.medicine = random(1,100) < 27
		end
	else
		stationCoulomb.comms_data.trade.medicine = random(1,100) < 27
		stationCoulomb.comms_data.trade.food = random(1,100) < 16
	end
	return stationCoulomb
end
function placeCyrus()
	--Cyrus
	stationCyrus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCyrus:setPosition(psx,psy):setCallSign("Cyrus"):setDescription("Impulse engine components")
    stationCyrus.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	impulse =	{quantity = 5,	cost = 124} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 78 },
        public_relations = true,
        general_information = "We supply high quality impulse engines and parts for use aboard ships",
    	history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"
	}
	if stationFaction == "Human Navy" then
		stationCyrus.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationCyrus.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationCyrus.comms_data.trade.medicine = random(1,100) < 34
		end
	else
		stationCyrus.comms_data.trade.medicine = random(1,100) < 34
		stationCyrus.comms_data.trade.food = random(1,100) < 13
	end
	return stationCyrus
end
function placeDeckard()
	--Deckard
	stationDeckard = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeckard:setPosition(psx,psy):setCallSign("Deckard"):setDescription("Android components")
    stationDeckard.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	android =	{quantity = 5,	cost = 73} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "Supplier of android components, programming and service",
    	history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids"
	}
	if stationFaction == "Human Navy" then
		stationDeckard.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationDeckard.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationDeckard.comms_data.goods.medicine.cost = 5
		end
	else
		stationDeckard.comms_data.trade.food = true
	end
	return stationDeckard
end
function placeDeer()
	--Deer
	stationDeer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationDeer:setPosition(psx,psy):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
    stationDeer.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 90},
        			repulsor =	{quantity = 5,	cost = 95} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We can meet all your pushing and pulling needs with specialized equipment custom made",
    	history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products"
	}
	if stationFaction == "Human Navy" then
		stationDeer.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		stationDeer.comms_data.goods.food.cost = 1
		if random(1,5) <= 1 then
			stationDeer.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationDeer.comms_data.trade.medicine = true
		end
	else
		stationDeer.comms_data.trade.medicine = true
		stationDeer.comms_data.trade.food = true
	end
	return stationDeer
end
function placeErickson()
	--Erickson
	stationErickson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationErickson:setPosition(psx,psy):setCallSign("Erickson"):setDescription("Transporter components")
    stationErickson.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	transporter =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide transporters used aboard ships as well as the components for repair and maintenance",
    	history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy"
	}
	if stationFaction == "Human Navy" then
		stationErickson.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationErickson.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationErickson.comms_data.trade.medicine = true
		end
	else
		stationErickson.comms_data.trade.medicine = true
		stationErickson.comms_data.trade.food = true
	end
	return stationErickson
end
function placeEvondos()
	--Evondos
	stationEvondos = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationEvondos:setPosition(psx,psy):setCallSign("Evondos"):setDescription("Autodoc components")
    stationEvondos.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 56} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 41 },
        public_relations = true,
        general_information = "We provide components for automated medical machinery",
    	history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland"
	}
	if stationFaction == "Human Navy" then
		stationEvondos.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationEvondos.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationEvondos.comms_data.trade.medicine = true
		end
	else
		stationEvondos.comms_data.trade.medicine = true
	end
	return stationEvondos
end
function placeFeynman()
	--Feynman 
	stationFeynman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationFeynman:setPosition(psx,psy):setCallSign("Feynman"):setDescription("Nanotechnology research")
    stationFeynman.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	software =	{quantity = 5,	cost = 115},
        			nanites =	{quantity = 5,	cost = 79} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide nanites and software for a variety of ship-board systems",
    	history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman"
	}
	if stationFaction == "Human Navy" then
		stationFeynman.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationFeynman.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationFeynman.comms_data.trade.medicine = true
		stationFeynman.comms_data.trade.food = random(1,100) < 26
	end
	return stationFeynman
end
function placeGrasberg()
	--Grasberg
	placeRandomAsteroidsAroundPoint(15,1,15000,psx,psy)
	stationGrasberg = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationGrasberg:setPosition(psx,psy):setCallSign("Grasberg"):setDescription("Mining")
    stationGrasberg.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomComponent()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We mine nearby asteroids for precious minerals and process them for sale",
    	history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids"
	}
	if stationFaction == "Human Navy" then
		stationGrasberg.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationGrasberg.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationGrasberg.comms_data.trade.food = true
	end
	local grasbergGoods = random(1,100)
	if grasbergGoods < 20 then
		stationGrasberg.comms_data.goods.gold = {quantity = 5, cost = 25}
		stationGrasberg.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	elseif grasbergGoods < 40 then
		stationGrasberg.comms_data.goods.gold = {quantity = 5, cost = 25}
	elseif grasbergGoods < 60 then
		stationGrasberg.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	else
		stationGrasberg.comms_data.goods.nickel = {quantity = 5, cost = 47}
	end
	return stationGrasberg
end
function placeHayden()
	--Hayden
	stationHayden = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHayden:setPosition(psx,psy):setCallSign("Hayden"):setDescription("Observatory and stellar mapping")
    stationHayden.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nanites =	{quantity = 5,	cost = 65} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding",
    	history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century"
	}
	if stationFaction == "Human Navy" then
		stationHayden.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationHayden.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationHayden
end
function placeHeyes()
	--Heyes
	stationHeyes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHeyes:setPosition(psx,psy):setCallSign("Heyes"):setDescription("Sensor components")
    stationHeyes.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	sensor =	{quantity = 5,	cost = 72} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and manufacture sensor components and systems",
    	history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility"
	}
	if stationFaction == "Human Navy" then
		stationHeyes.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationHeyes.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationHeyes
end
function placeHossam()
	--Hossam
	stationHossam = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHossam:setPosition(psx,psy):setCallSign("Hossam"):setDescription("Nanite supplier")
    stationHossam.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nanites =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 63 },
        public_relations = true,
        general_information = "We provide nanites for various organic and non-organic systems",
    	history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel"
	}
	if stationFaction == "Human Navy" then
		stationHossam.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationHossam.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationHossam.comms_data.trade.medicine = random(1,100) < 44
		end
	else
		stationHossam.comms_data.trade.medicine = random(1,100) < 44
		stationHossam.comms_data.trade.food = random(1,100) < 24
	end
	return stationHossam
end
function placeImpala()
	--Impala
	placeRandomAsteroidsAroundPoint(15,1,15000,psx,psy)
	stationImpala = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationImpala:setPosition(psx,psy):setCallSign("Impala"):setDescription("Mining")
    stationImpala.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = true },
		buy =	{	[randomComponent()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We mine nearby asteroids for precious minerals"
	}
	local impalaGoods = random(1,100)
	if impalaGoods < 20 then
		stationImpala.comms_data.goods.gold = {quantity = 5, cost = 25}
		stationImpala.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	elseif impalaGoods < 40 then
		stationImpala.comms_data.goods.gold = {quantity = 5, cost = 25}
	elseif impalaGoods < 60 then
		stationImpala.comms_data.goods.cobalt = {quantity = 4, cost = 50}
	else
		stationImpala.comms_data.goods.tritanium = {quantity = 5, cost = 42}
	end
	if stationFaction == "Human Navy" then
		stationImpala.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationImpala.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationImpala.comms_data.trade.medicine = random(1,100) < 28
		end
	else
		stationImpala.comms_data.trade.food = true
	end
	return stationImpala
end
function placeKomov()
	--Komov
	stationKomov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKomov:setPosition(psx,psy):setCallSign("Komov"):setDescription("Xenopsychology training")
    stationKomov.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 46} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We provide classes and simulation to help train diverse species in how to relate to each other",
    	history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles"
	}
	if stationFaction == "Human Navy" then
		stationKomov.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationKomov.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationKomov.comms_data.trade.medicine = random(1,100) < 44
		end
	else
		stationKomov.comms_data.trade.medicine = random(1,100) < 44
		stationKomov.comms_data.trade.food = random(1,100) < 24
	end
	return stationKomov
end
function placeKrak()
	--Krak
	stationKrak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrak:setPosition(psx,psy):setCallSign("Krak"):setDescription("Mining station")
    stationKrak.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = 20} },
        trade = {	food = random(1,100) < 50, medicine = true, luxury = random(1,100) < 50 },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local posAxisKrak = random(0,360)
	local posKrak = random(10000,60000)
	local negKrak = random(10000,60000)
	local spreadKrak = random(4000,7000)
	local negAxisKrak = posAxisKrak + 180
	local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
	local posKrakEnd = random(30,70)
	createRandomAsteroidAlongArc(30+posKrakEnd, psx+xPosAngleKrak, psy+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
	local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
	local negKrakEnd = random(40,80)
	createRandomAsteroidAlongArc(30+negKrakEnd, psx+xNegAngleKrak, psy+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	local krakGoods = random(1,100)
	if krakGoods < 10 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 20 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 30 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 40 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 50 then
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	elseif krakGoods < 60 then
		stationKrak.comms_data.goods.platinum = {quantity = 5, cost = 70}
	elseif krakGoods < 70 then
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 80 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.tritanium = {quantity = 5, cost = 50}
	elseif krakGoods < 90 then
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
		stationKrak.comms_data.goods.dilithium = {quantity = 5, cost = 52}
	else
		stationKrak.comms_data.goods.gold = {quantity = 5, cost = 50}
	end
	return stationKrak
end
function placeKruk()
	--Kruk
	stationKruk = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKruk:setPosition(psx,psy):setCallSign("Kruk"):setDescription("Mining station")
    stationKruk.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = math.random(25,35)} },
        trade = {	food = random(1,100) < 50, medicine = random(1,100) < 50, luxury = true },
		buy =	{	[randomComponent()] = math.random(40,200)	}
	}
	local posAxisKruk = random(0,360)
	local posKruk = random(10000,60000)
	local negKruk = random(10000,60000)
	local spreadKruk = random(4000,7000)
	local negAxisKruk = posAxisKruk + 180
	local xPosAngleKruk, yPosAngleKruk = vectorFromAngle(posAxisKruk, posKruk)
	local posKrukEnd = random(30,70)
	createRandomAsteroidAlongArc(30+posKrukEnd, psx+xPosAngleKruk, psy+yPosAngleKruk, posKruk, negAxisKruk, negAxisKruk+posKrukEnd, spreadKruk)
	local xNegAngleKruk, yNegAngleKruk = vectorFromAngle(negAxisKruk, negKruk)
	local negKrukEnd = random(40,80)
	createRandomAsteroidAlongArc(30+negKrukEnd, psx+xNegAngleKruk, psy+yNegAngleKruk, negKruk, posAxisKruk, posAxisKruk+negKrukEnd, spreadKruk)
	local krukGoods = random(1,100)
	if krukGoods < 10 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 20 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 30 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 40 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 50 then
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 60 then
		stationKruk.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
	elseif krukGoods < 70 then
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 80 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krukGoods < 90 then
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
		stationKruk.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	else
		stationKruk.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
	end
	return stationKruk
end
function placeLipkin()
	--Lipkin
	stationLipkin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(psx,psy):setCallSign("Lipkin"):setDescription("Autodoc components")
    stationLipkin.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We build and repair and provide components and upgrades for automated facilities designed for ships where a doctor cannot be a crew member (commonly called autodocs)",
    	history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth"
	}
	if stationFaction == "Human Navy" then
		stationLipkin.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationLipkin.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationLipkin.comms_data.trade.food = true
	end
	return stationLipkin
end
function placeMadison()
	--Madison
	stationMadison = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMadison:setPosition(psx,psy):setCallSign("Madison"):setDescription("Zero gravity sports and entertainment")
    stationMadison.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come take in a game or two or perhaps see a show",
    	history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"
	}
	if stationFaction == "Human Navy" then
		stationMadison.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMadison.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMadison.comms_data.trade.medicine = true
		end
	else
		stationMadison.comms_data.trade.medicine = true
	end
	return stationMadison
end
function placeMaiman()
	--Maiman
	stationMaiman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaiman:setPosition(psx,psy):setCallSign("Maiman"):setDescription("Energy beam components")
    stationMaiman.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and manufacture energy beam components and systems",
    	history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth"
	}
	if stationFaction == "Human Navy" then
		stationMaiman.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMaiman.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMaiman.comms_data.trade.medicine = true
		end
	else
		stationMaiman.comms_data.trade.medicine = true
	end
	return stationMaiman
end
function placeMarconi()
	--Marconi 
	stationMarconi = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMarconi:setPosition(psx,psy):setCallSign("Marconi"):setDescription("Energy Beam Components")
    stationMarconi.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	beam =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We manufacture energy beam components",
    	history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon"
	}
	if stationFaction == "Human Navy" then
		stationMarconi.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMarconi.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationMarconi.comms_data.trade.medicine = true
		end
	else
		stationMarconi.comms_data.trade.medicine = true
		stationMarconi.comms_data.trade.food = true
	end
	return stationMarconi
end
function placeMayo()
	--Mayo
	stationMayo = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMayo:setPosition(psx,psy):setCallSign("Mayo"):setDescription("Medical Research")
    stationMayo.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	autodoc =	{quantity = 5,	cost = 128},
        			food =		{quantity = 5,	cost = 1},
        			medicine = 	{quantity = 5,	cost = 5} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research exotic diseases and other human medical conditions",
    	history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth"
	}
	return stationMayo
end
function placeMiller()
	--Miller
	stationMiller = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMiller:setPosition(psx,psy):setCallSign("Miller"):setDescription("Exobiology research")
    stationMiller.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We study recently discovered life forms not native to Earth",
    	history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"
	}
	if stationFaction == "Human Navy" then
		stationMiller.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMiller.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationMiller
end
function placeMuddville()
	--Muddville 
	stationMudd = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMudd:setPosition(psx,psy):setCallSign("Muddville"):setDescription("Trading station")
    stationMudd.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 60} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come to Muddvile for all your trade and commerce needs and desires",
    	history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman"
	}
	if stationFaction == "Human Navy" then
		stationMudd.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationMudd.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationMudd
end
function placeNexus6()
	--Nexus-6
	stationNexus6 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNexus6:setPosition(psx,psy):setCallSign("Nexus-6"):setDescription("Android components")
    stationNexus6.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	android =	{quantity = 5,	cost = 93} },
        trade = {	food = false, medicine = false, luxury = false },
		buy =	{	[randomMineral()] = math.random(40,200),
					[randomComponent("android")] = math.random(40,200)	},
        public_relations = true,
        general_information = "We research and manufacture android components and systems. Our design our androids to maximize their likeness to humans",
    	history = "We named the station after the ground breaking android model produced by the Tyrell corporation"
	}
	if stationFaction == "Human Navy" then
		stationNexus6.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationNexus6.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationNexus6.comms_data.trade.medicine = true
		end
	else
		stationNexus6.comms_data.trade.medicine = true
	end
	return stationNexus6
end
function placeOBrien()
	--O'Brien
	stationOBrien = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOBrien:setPosition(psx,psy):setCallSign("O'Brien"):setDescription("Transporter components")
    stationOBrien.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	transporter =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and fabricate high quality transporters and transporter components for use aboard ships",
    	history = "Miles O'Brien started this business after his experience as a transporter chief"
	}
	if stationFaction == "Human Navy" then
		stationOBrien.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOBrien.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOBrien.comms_data.trade.medicine = random(1,100) < 34
		end
	else
		stationOBrien.comms_data.trade.medicine = true
		stationOBrien.comms_data.trade.food = random(1,100) < 13
	end
	stationOBrien.comms_data.trade.luxury = random(1,100) < 43
	return stationOBrien
end
function placeOlympus()
	--Olympus
	stationOlympus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOlympus:setPosition(psx,psy):setCallSign("Olympus"):setDescription("Optical components")
    stationOlympus.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic =	{quantity = 5,	cost = 66} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components",
    	history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"
	}
	if stationFaction == "Human Navy" then
		stationOlympus.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOlympus.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOlympus.comms_data.trade.medicine = true
		end
	else
		stationOlympus.comms_data.trade.medicine = true
		stationOlympus.comms_data.trade.food = true
	end
	return stationOlympus
end
function placeOrgana()
	--Organa
	stationOrgana = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOrgana:setPosition(psx,psy):setCallSign("Organa"):setDescription("Diplomatic training")
    stationOrgana.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 96} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "The premeire academy for leadership and diplomacy training in the region",
    	history = "Established by the royal family so critical during the political upheaval era"
	}
	return stationOrgana
end
function placeOutpost15()
	--Outpost 15
	stationOutpost15 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost15:setPosition(psx,psy):setCallSign("Outpost-15"):setDescription("Mining and trade")
    stationOutpost15.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = true, medicine = false, luxury = false }
	}
	local outpost15Goods = random(1,100)
	if outpost15Goods < 20 then
		stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	elseif outpost15Goods < 40 then
		stationOutpost15.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
	elseif outpost15Goods < 60 then
		stationOutpost15.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	else
		stationOutpost15.comms_data.goods.platinum = {quantity = 4, cost = math.random(55,65)}
	end
	if stationFaction == "Human Navy" then
		stationOutpost15.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOutpost15.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOutpost15.comms_data.trade.medicine = true		
		end
	else
		stationOutpost15.comms_data.trade.food = true
	end
	placeRandomAsteroidsAroundPoint(15,1,15000,psx,psy)
	return stationOutpost15
end
function placeOutpost21()
	--Outpost 21
	stationOutpost21 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost21:setPosition(psx,psy):setCallSign("Outpost-21"):setDescription("Mining and gambling")
    stationOutpost21.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = true }
	}
	placeRandomAsteroidsAroundPoint(15,1,15000,psx,psy)
	local outpost21Goods = random(1,100)
	if outpost21Goods < 20 then
		stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
		stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	elseif outpost21Goods < 40 then
		stationOutpost21.comms_data.goods.gold = {quantity = 5, cost = math.random(22,30)}
	elseif outpost21Goods < 60 then
		stationOutpost21.comms_data.goods.cobalt = {quantity = 4, cost = math.random(45,55)}
	else
		stationOutpost21.comms_data.goods.dilithium = {quantity = 4, cost = math.random(45,55)}
	end
	if stationFaction == "Human Navy" then
		stationOutpost21.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOutpost21.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
		end
	else
		stationOutpost21.comms_data.trade.food = true
		stationOutpost21.comms_data.trade.medicine = random(1,100) < 50
	end
	return stationOutpost21
end
function placeOwen()
	--Owen
	stationOwen = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOwen:setPosition(psx,psy):setCallSign("Owen"):setDescription("Load lifters and components")
    stationOwen.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	lifter =	{quantity = 5,	cost = 61} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide load lifters and components for various ship systems",
    	history = "The station is named after Lars Owen. After his extensive eperience with tempermental machinery on Tatooine, he used his subject matter expertise to expand into building and manufacturing the equipment adding innovations based on his years of experience using load lifters and their relative cousins, moisture vaporators"
	}
	if stationFaction == "Human Navy" then
		stationOwen.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationOwen.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationOwen.comms_data.trade.food = true
	end
	return stationOwen
end
function placePanduit()
	--Panduit
	stationPanduit = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPanduit:setPosition(psx,psy):setCallSign("Panduit"):setDescription("Optic components")
    stationPanduit.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	optic =	{quantity = 5,	cost = 79} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We provide optic components for various ship systems",
    	history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"
	}
	if stationFaction == "Human Navy" then
		stationPanduit.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationPanduit.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationPanduit.comms_data.trade.medicine = random(1,100) < 33
		end
	else
		stationPanduit.comms_data.trade.medicine = random(1,100) < 33
		stationPanduit.comms_data.trade.food = random(1,100) < 27
	end
	return stationPanduit
end
function placeRipley()
	--Ripley
	stationRipley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(psx,psy):setCallSign("Ripley"):setDescription("Load lifters and components")
    stationRipley.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	lifter =	{quantity = 5,	cost = 82} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 47 },
        public_relations = true,
        general_information = "We provide load lifters and components",
    	history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"
	}
	if stationFaction == "Human Navy" then
		stationRipley.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationRipley.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationRipley.comms_data.trade.medicine = true
		end
	else
		stationRipley.comms_data.trade.food = random(1,100) < 17
		stationRipley.comms_data.trade.medicine = true
	end
	return stationRipley
end
function placeRutherford()
	--Rutherford
	stationRutherford = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRutherford:setPosition(psx,psy):setCallSign("Rutherford"):setDescription("Shield components and research")
    stationRutherford.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = random(1,100) < 43 },
        public_relations = true,
        general_information = "We research and fabricate components for ship shield systems",
    	history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"
	}
	if stationFaction == "Human Navy" then
		stationRutherford.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationRutherford.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationRutherford.comms_data.trade.medicine = true
		end
	else
		stationRutherford.comms_data.trade.food = true
		stationRutherford.comms_data.trade.medicine = true
	end
	return stationRutherford
end
function placeScience7()
	--Science 7
	stationScience7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience7:setPosition(psx,psy):setCallSign("Science-7"):setDescription("Observatory")
    stationScience7.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =	{quantity = 2,	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationScience7
end
function placeShawyer()
	--Shawyer
	stationShawyer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShawyer:setPosition(psx,psy):setCallSign("Shawyer"):setDescription("Impulse engine components")
    stationShawyer.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	impulse =	{quantity = 5,	cost = 100} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We research and manufacture impulse engine components and systems",
    	history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century"
	}
	if stationFaction == "Human Navy" then
		stationShawyer.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationShawyer.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationShawyer.comms_data.trade.medicine = true
		end
	else
		stationShawyer.comms_data.trade.medicine = true
	end
	return stationShawyer
end
function placeShree()
	--Shree
	stationShree = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShree:setPosition(psx,psy):setCallSign("Shree"):setDescription("Repulsor and tractor beam components")
    stationShree.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	tractor =	{quantity = 5,	cost = 90},
        			repulsor =	{quantity = 5,	cost = math.random(85,95)} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We make ship systems designed to push or pull other objects around in space",
    	history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"
	}
	if stationFaction == "Human Navy" then
		stationShree.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationShree.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationShree.comms_data.trade.medicine = true
		end
	else
		stationShree.comms_data.trade.medicine = true
		stationShree.comms_data.trade.food = true
	end
	return stationShree
end
function placeSoong()
	--Soong 
	stationSoong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSoong:setPosition(psx,psy):setCallSign("Soong"):setDescription("Android components")
    stationSoong.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	android =	{quantity = 5,	cost = 73} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We create androids and android components",
    	history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"
	}
	if stationFaction == "Human Navy" then
		stationSoong.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationSoong.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	else
		stationSoong.comms_data.trade.food = true
	end
	return stationSoong
end
function placeTiberius()
	--Tiberius
	stationTiberius = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTiberius:setPosition(psx,psy):setCallSign("Tiberius"):setDescription("Logistics coordination")
    stationTiberius.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =	{quantity = 5,	cost = 1} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We support the stations and ships in the area with planning and communication services",
    	history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name"
	}
	return stationTiberius
end
function placeTokra()
	--Tokra
	stationTokra = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTokra:setPosition(psx,psy):setCallSign("Tokra"):setDescription("Advanced material components")
    stationTokra.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	filament =	{quantity = 5,	cost = 42} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We create multiple types of advanced material components. Our most popular products are our filaments",
    	history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them"
	}
	local whatTrade = random(1,100)
	if stationFaction == "Human Navy" then
		stationTokra.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationTokra.comms_data.goods.medicine = {quantity = 5, cost = 5}
			stationTokra.comms_data.trade.luxury = true
		else
			if whatTrade < 50 then
				stationTokra.comms_data.trade.medicine = true
			else
				stationTokra.comms_data.trade.luxury = true
			end
		end
	else
		if whatTrade < 33 then
			stationTokra.comms_data.trade.food = true
		elseif whatTrade > 66 then
			stationTokra.comms_data.trade.medicine = true
		else
			stationTokra.comms_data.trade.luxury = true
		end
	end
	return stationTokra
end
function placeToohie()
	--Toohie
	stationToohie = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationToohie:setPosition(psx,psy):setCallSign("Toohie"):setDescription("Shield and armor components and research")
    stationToohie.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We research and make general and specialized components for ship shield and ship armor systems",
    	history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."
	}
	if stationFaction == "Human Navy" then
		stationToohie.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationToohie.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationToohie.comms_data.trade.medicine = random(1,100) < 25
		end
	else
		stationToohie.comms_data.trade.medicine = random(1,100) < 25
	end
	return stationToohie
end
function placeUtopiaPlanitia()
	--Utopia Planitia
	stationUtopiaPlanitia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationUtopiaPlanitia:setPosition(psx,psy):setCallSign("Utopia Planitia"):setDescription("Ship building and maintenance facility")
    stationUtopiaPlanitia.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp =	{quantity = 5,	cost = 167} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel"
	}
	if stationFaction == "Human Navy" then
		stationUtopiaPlanitia.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationUtopiaPlanitia.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationUtopiaPlanitia
end
function placeVactel()
	--Vactel
	stationVactel = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVactel:setPosition(psx,psy):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
    stationVactel.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	circuit =	{quantity = 5,	cost = 50} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We specialize in circuitry shielded from external hacking suitable for ship systems",
    	history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips"
	}
	if stationFaction == "Human Navy" then
		stationVactel.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationVactel.comms_data.goods.medicine = {quantity = 5, cost = 5}
		end
	end
	return stationVactel
end
function placeVeloquan()
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(psx,psy):setCallSign("Veloquan"):setDescription("Sensor components")
    stationVeloquan.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	sensor =	{quantity = 5,	cost = 68} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use",
    	history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"
	}
	if stationFaction == "Human Navy" then
		stationVeloquan.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationVeloquan.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationVeloquan.comms_data.trade.medicine = true
		end
	else
		stationVeloquan.comms_data.trade.medicine = true
		stationVeloquan.comms_data.trade.food = true
	end
	return stationVeloquan
end
function placeZefram()
	--Zefram
	stationZefram = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(psx,psy):setCallSign("Zefram"):setDescription("Warp engine components")
    stationZefram.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	warp =	{quantity = 5,	cost = 140} },
        trade = {	food = false, medicine = false, luxury = true },
        public_relations = true,
        general_information = "We specialize in the esoteric components necessary to make warp drives function properly",
    	history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"
	}
	if stationFaction == "Human Navy" then
		stationZefram.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,5) <= 1 then
			stationZefram.comms_data.goods.medicine = {quantity = 5, cost = 5}
		else
			stationZefram.comms_data.trade.medicine = random(1,100) < 27
		end
	else
		stationZefram.comms_data.trade.medicine = random(1,100) < 27
		stationZefram.comms_data.trade.food = random(1,100) < 16
	end
	return stationZefram
end
-- Generic stations to be placed
function placeJabba()
	--Jabba
	stationJabba = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationJabba:setPosition(psx,psy):setCallSign("Jabba"):setDescription("Commerce and gambling")
    stationJabba.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Come play some games and shop. House take does not exceed 4 percent"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationJabba.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationJabba.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationJabba.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationJabba
end
function placeKrik()
	--Krik
	stationKrik = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationKrik:setPosition(psx,psy):setCallSign("Krik"):setDescription("Mining station")
    stationKrik.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	nickel =	{quantity = 5,	cost = 20} },
        trade = {	food = true, medicine = true, luxury = random(1,100) < 50 }
	}
	local posAxisKrik = random(0,360)
	local posKrik = random(30000,80000)
	local negKrik = random(20000,60000)
	local spreadKrik = random(5000,8000)
	local negAxisKrik = posAxisKrik + 180
	local xPosAngleKrik, yPosAngleKrik = vectorFromAngle(posAxisKrik, posKrik)
	local posKrikEnd = random(40,90)
	createRandomAsteroidAlongArc(30+posKrikEnd, psx+xPosAngleKrik, psy+yPosAngleKrik, posKrik, negAxisKrik, negAxisKrik+posKrikEnd, spreadKrik)
	local xNegAngleKrik, yNegAngleKrik = vectorFromAngle(negAxisKrik, negKrik)
	local negKrikEnd = random(30,60)
	createRandomAsteroidAlongArc(30+negKrikEnd, psx+xNegAngleKrik, psy+yNegAngleKrik, negKrik, posAxisKrik, posAxisKrik+negKrikEnd, spreadKrik)
	local krikGoods = random(1,100)
	if krikGoods < 10 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 20 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 30 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 40 then
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 50 then
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 60 then
		stationKrik.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
	elseif krikGoods < 70 then
		stationKrik.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
	elseif krikGoods < 80 then
		stationKrik.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
	else
		stationKrik.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
		stationKrik.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
	end
	return stationKrik
end
function placeLando()
	--Lando
	stationLando = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLando:setPosition(psx,psy):setCallSign("Lando"):setDescription("Casino and Gambling")
    stationLando.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	shield =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationLando.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationLando.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationLando.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationLando
end
function placeMaverick()
	--Maverick
	stationMaverick = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaverick:setPosition(psx,psy):setCallSign("Maverick"):setDescription("Gambling and resupply")
    stationMaverick.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Relax and meet some interesting players"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationMaverick.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
	elseif stationGoodChoice == 2 then
		stationMaverick.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
	else
		stationMaverick.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
	end
	return stationMaverick
end
function placeNefatha()
	--Nefatha
	stationNefatha = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNefatha:setPosition(psx,psy):setCallSign("Nefatha"):setDescription("Commerce and recreation")
    stationNefatha.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 70} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationNefatha
end
function placeOkun()
	--Okun
	stationOkun = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOkun:setPosition(psx,psy):setCallSign("Okun"):setDescription("Xenopsychology research")
    stationOkun.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = false
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationOkun.comms_data.goods.optic = {quantity = 5, cost = math.random(52,65)}
	elseif stationGoodChoice == 2 then
		stationOkun.comms_data.goods.filament = {quantity = 5, cost = math.random(55,67)}
	else
		stationOkun.comms_data.goods.lifter = {quantity = 5, cost = math.random(48,69)}
	end
	return stationOkun
end
function placeOutpost7()
	--Outpost 7
	stationOutpost7 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost7:setPosition(psx,psy):setCallSign("Outpost-7"):setDescription("Resupply")
    stationOutpost7.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 80} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationOutpost7
end
function placeOutpost8()
	--Outpost 8
	stationOutpost8 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost8:setPosition(psx,psy):setCallSign("Outpost-8")
    stationOutpost8.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationOutpost8.comms_data.goods.impulse = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationOutpost8.comms_data.goods.tractor = {quantity = 5, cost = math.random(55,67)}
	else
		stationOutpost8.comms_data.goods.beam = {quantity = 5, cost = math.random(61,69)}
	end
	return stationOutpost8
end
function placeOutpost33()
	--Outpost 33
	stationOutpost33 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost33:setPosition(psx,psy):setCallSign("Outpost-33"):setDescription("Resupply")
    stationOutpost33.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 75} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationOutpost33
end
function placePrada()
	--Prada
	stationPrada = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPrada:setPosition(psx,psy):setCallSign("Prada"):setDescription("Textiles and fashion")
    stationPrada.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationPrada.comms_data.goods.luxury = {quantity = 5, cost = math.random(69,75)}
	elseif stationGoodChoice == 2 then
		stationPrada.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,67)}
	else
		stationPrada.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,69)}
	end
	return stationPrada
end
function placeResearch11()
	--Research-11
	stationResearch11 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(psx,psy):setCallSign("Research-11"):setDescription("Stress Psychology Research")
    stationResearch11.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationResearch11.comms_data.goods.warp = {quantity = 5, cost = math.random(85,120)}
	elseif stationGoodChoice == 2 then
		stationResearch11.comms_data.goods.repulsor = {quantity = 5, cost = math.random(62,75)}
	else
		stationResearch11.comms_data.goods.robotic = {quantity = 5, cost = math.random(75,89)}
	end
	return stationResearch11
end
function placeResearch19()
	--Research-19
	stationResearch19 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch19:setPosition(psx,psy):setCallSign("Research-19"):setDescription("Low gravity research")
    stationResearch19.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationResearch19.comms_data.goods.transporter = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationResearch19.comms_data.goods.sensor = {quantity = 5, cost = math.random(62,75)}
	else
		stationResearch19.comms_data.goods.communication = {quantity = 5, cost = math.random(55,89)}
	end
	return stationResearch19
end
function placeRubis()
	--Rubis
	stationRubis = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRubis:setPosition(psx,psy):setCallSign("Rubis"):setDescription("Resupply")
    stationRubis.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 76} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Get your energy here! Grab a drink before you go!"
	}
	return stationRubis
end
function placeScience2()
	--Science 2
	stationScience2 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience2:setPosition(psx,psy):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
    stationScience2.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationScience2.comms_data.goods.autodoc = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationScience2.comms_data.goods.android = {quantity = 5, cost = math.random(62,75)}
	else
		stationScience2.comms_data.goods.nanites = {quantity = 5, cost = math.random(55,89)}
	end
	return stationScience2
end
function placeScience4()
	--Science 4
	stationScience4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(psx,psy):setCallSign("Science-4"):setDescription("Biotech research")
    stationScience4.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationScience4.comms_data.goods.software = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationScience4.comms_data.goods.circuit = {quantity = 5, cost = math.random(62,75)}
	else
		stationScience4.comms_data.goods.battery = {quantity = 5, cost = math.random(55,89)}
	end
	return stationScience4
end
function placeSkandar()
	--Skandar
	stationSkandar = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSkandar:setPosition(psx,psy):setCallSign("Skandar"):setDescription("Routine maintenance and entertainment")
    stationSkandar.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 87} },
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars",
    	history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax"
	}
	return stationSkandar
end
function placeSpot()
	--Spot
	stationSpot = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSpot:setPosition(psx,psy):setCallSign("Spot"):setDescription("Observatory")
    stationSpot.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false }
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationSpot.comms_data.goods.optic = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationSpot.comms_data.goods.software = {quantity = 5, cost = math.random(62,75)}
	else
		stationSpot.comms_data.goods.sensor = {quantity = 5, cost = math.random(55,89)}
	end
	return stationSpot
end
function placeStarnet()
	--Starnet 
	stationStarnet = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationStarnet:setPosition(psx,psy):setCallSign("Starnet"):setDescription("Automated weapons systems")
    stationStarnet.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "We research and create automated weapons systems to improve ship combat capability"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationStarnet.comms_data.goods.shield = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationStarnet.comms_data.goods.beam = {quantity = 5, cost = math.random(62,75)}
	else
		stationStarnet.comms_data.goods.lifter = {quantity = 5, cost = math.random(55,89)}
	end
	return stationStarnet
end
function placeTandon()
	--Tandon
	stationTandon = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTandon:setPosition(psx,psy):setCallSign("Tandon"):setDescription("Biotechnology research")
    stationTandon.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {},
        trade = {	food = false, medicine = false, luxury = false },
        public_relations = true,
        general_information = "Merging the organic and inorganic through research",
    	history = "Continued from the Tandon school of engineering started on Earth in the early 21st century"
	}
	local stationGoodChoice = math.random(1,3)
	if stationGoodChoice == 1 then
		stationTandon.comms_data.goods.autodoc = {quantity = 5, cost = math.random(85,94)}
	elseif stationGoodChoice == 2 then
		stationTandon.comms_data.goods.robotic = {quantity = 5, cost = math.random(62,75)}
	else
		stationTandon.comms_data.goods.android = {quantity = 5, cost = math.random(55,89)}
	end
	return stationTandon
end
function placeVaiken()
	--Vaiken
	stationVaiken = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVaiken:setPosition(psx,psy):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
    stationVaiken.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food =		{quantity = 10,	cost = 1},
        			medicine =	{quantity = 5,	cost = 5} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationVaiken
end
function placeValero()
	--Valero
	stationValero = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationValero:setPosition(psx,psy):setCallSign("Valero"):setDescription("Resupply")
    stationValero.comms_data = {
    	friendlyness = random(0,100),
        weapons = 			{Homing = "neutral",					HVLI = "neutral", 						Mine = "neutral",						Nuke = "friend", 						EMP = "friend"},
        weapon_available = 	{Homing = random(1,10)<=(8-difficulty),	HVLI = random(1,10)<=(9-difficulty),	Mine = random(1,10)<=(7-difficulty),	Nuke = random(1,10)<=(5-difficulty),	EMP = random(1,10)<=(6-difficulty)},
        service_cost = 		{supplydrop = math.random(80,120), reinforcements = math.random(125,175)},
        reputation_cost_multipliers = {friend = 1.0, neutral = 3.0},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	luxury =	{quantity = 5,	cost = 90} },
        trade = {	food = false, medicine = false, luxury = false }
	}
	return stationValero
end
-- Enemy stations to be placed
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
--------------------------------------
-- Set up enemy and friendly fleets --
--------------------------------------
function setFleets()
	--enemy defensive fleets
	local enemyResource = 300 + difficulty*200
	enemyFleetList = {}
	enemyDefensiveFleetList = {}
	enemyFleet1base = kraylorStationList[math.random(1,#kraylorStationList)]
	local f1bx, f1by = enemyFleet1base:getPosition()
	local enemyFleet1, enemyFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130))
	for _, enemy in ipairs(enemyFleet1) do
		enemy:orderDefendTarget(enemyFleet1base)
	end
	table.insert(enemyFleetList,enemyFleet1)
	table.insert(enemyDefensiveFleetList,enemyFleet1)
	intelGatherArtifacts[1]:setDescriptions("Scan to gather intelligence",string.format("Enemy fleet detected in sector %s",enemyFleet1base:getSectorName()))
	intelGatherArtifacts[1].startSector = enemyFleet1base:getSectorName()
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
	local f2bx, f2by = enemyFleet2base:getPosition()
	enemyFleet2, enemyFleet2Power = spawnEnemyFleet(f2bx, f2by, enemyFleet2Power)
	for _, enemy in ipairs(enemyFleet2) do
		enemy:orderDefendTarget(enemyFleet2base)
	end
	table.insert(enemyFleetList,enemyFleet2)
	table.insert(enemyDefensiveFleetList,enemyFleet2)
	intelGatherArtifacts[2]:setDescriptions("Scan to gather intelligence",string.format("Enemy fleet detected in sector %s",enemyFleet2base:getSectorName()))
	intelGatherArtifacts[2].startSector = enemyFleet2base:getSectorName()
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
	local f3bx, f3by = enemyFleet3base:getPosition()
	enemyFleet3, enemyFleet3Power = spawnEnemyFleet(f3bx, f3by, enemyFleet3Power)
	for _, enemy in ipairs(enemyFleet3) do
		enemy:orderDefendTarget(enemyFleet3base)
	end
	table.insert(enemyFleetList,enemyFleet3)
	table.insert(enemyDefensiveFleetList,enemyFleet3)
	intelGatherArtifacts[3]:setDescriptions("Scan to gather intelligence",string.format("Enemy fleet detected in sector %s",enemyFleet3base:getSectorName()))
	intelGatherArtifacts[3].startSector = enemyFleet3base:getSectorName()
	enemyResource = enemyResource - enemyFleet3Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base and candidate ~= enemyFleet3base then
			enemyFleet4base = candidate
		end
	until(enemyFleet4base ~= nil)
	local f4bx, f4by = enemyFleet4base:getPosition()
	enemyFleet4, enemyFleet4Power = spawnEnemyFleet(f4bx, f4by, enemyResource/2)
	for _, enemy in ipairs(enemyFleet4) do
		enemy:orderDefendTarget(enemyFleet4base)
	end
	table.insert(enemyFleetList,enemyFleet4)
	table.insert(enemyDefensiveFleetList,enemyFleet4)
	intelGatherArtifacts[4]:setDescriptions("Scan to gather intelligence",string.format("Enemy fleet detected in sector %s",enemyFleet4base:getSectorName()))
	intelGatherArtifacts[4].startSector = enemyFleet4base:getSectorName()
	enemyResource = enemyResource - enemyFleet4Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= enemyFleet1base and candidate ~= enemyFleet2base and candidate ~= enemyFleet3base and candidate ~= enemyFleet4base then
			enemyFleet5base = candidate
		end
	until(enemyFleet5base ~= nil)
	local f5bx, f5by = enemyFleet5base:getPosition()
	enemyFleet5, enemyFleet5Power = spawnEnemyFleet(f5bx, f5by, enemyResource)
	for _, enemy in ipairs(enemyFleet5) do
		enemy:orderDefendTarget(enemyFleet5base)
	end
	table.insert(enemyFleetList,enemyFleet5)
	table.insert(enemyDefensiveFleetList,enemyFleet5)
	intelGatherArtifacts[5]:setDescriptions("Scan to gather intelligence",string.format("Enemy fleet detected in sector %s",enemyFleet5base:getSectorName()))
	intelGatherArtifacts[5].startSector = enemyFleet5base:getSectorName()
	
	--friendly defensive fleets
	
	local friendlyResource = 500
	friendlyFleetList = {}
	friendlyHelperFleet = {}
	friendlyDefensiveFleetList = {}
	table.insert(friendlyFleetList,friendlyHelperFleet)
	friendlyFleet1base = humanStationList[math.random(1,#humanStationList)]
	f1bx, f1by = friendlyFleet1base:getPosition()
	local fleetName = friendlyFleet1base:getCallSign() .. " defensive fleet"
	local friendlyFleet1, friendlyFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130), 1, "Human Navy", fleetName)
	for _, enemy in ipairs(friendlyFleet1) do
		enemy:orderDefendTarget(friendlyFleet1base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet1)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet1
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
	fleetName = friendlyFleet2base:getCallSign() .. " defensive fleet"
	friendlyFleet2, friendlyFleet2Power = spawnEnemyFleet(f2bx, f2by, friendlyFleet2Power, 1, "Human Navy", fleetName)
	for _, enemy in ipairs(friendlyFleet2) do
		enemy:orderDefendTarget(friendlyFleet2base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet2)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet2
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
	fleetName = friendlyFleet3base:getCallSign() .. " defensive fleet"
	friendlyFleet3, friendlyFleet3Power = spawnEnemyFleet(f3bx, f3by, friendlyFleet3Power, 1, "Human Navy", fleetName)
	for _, enemy in ipairs(friendlyFleet3) do
		enemy:orderDefendTarget(friendlyFleet3base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet3)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet3
	friendlyResource = friendlyResource - friendlyFleet3Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base and candidate ~= friendlyFleet3base then
			friendlyFleet4base = candidate
		end
	until(friendlyFleet4base ~= nil)
	f4bx, f4by = friendlyFleet4base:getPosition()
	fleetName = friendlyFleet4base:getCallSign() .. " defensive fleet"
	friendlyFleet4, friendlyFleet4Power = spawnEnemyFleet(f4bx, f4by, friendlyResource/2, 1, "Human Navy", fleetName)
	for _, enemy in ipairs(friendlyFleet4) do
		enemy:orderDefendTarget(friendlyFleet4base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet4)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet4
	friendlyResource = friendlyResource - friendlyFleet4Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= friendlyFleet1base and candidate ~= friendlyFleet2base and candidate ~= friendlyFleet3base and candidate ~= friendlyFleet4base then
			friendlyFleet5base = candidate
		end
	until(friendlyFleet5base ~= nil)
	f5bx, f5by = friendlyFleet5base:getPosition()
	fleetName = friendlyFleet5base:getCallSign() .. " defensive fleet"
	friendlyFleet5, friendlyFleet5Power = spawnEnemyFleet(f5bx, f5by, friendlyResource, 1, "Human Navy", fleetName)
	for _, enemy in ipairs(friendlyFleet5) do
		enemy:orderDefendTarget(friendlyFleet5base):setScanned(true)
	end
	table.insert(friendlyFleetList,friendlyFleet5)
	friendlyDefensiveFleetList[fleetName] = friendlyFleet5
end
function spawnEnemyFleet(xOrigin, yOrigin, power, danger, enemyFaction, fleetName)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	local enemyStrength = math.max(power * danger * difficulty, 5)
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	local fleetPower = 0
	local prefix = generateCallSignPrefix(1)
	while enemyStrength > 0 do
		local shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end
		fleetPower = fleetPower + stsl[shipTemplateType]
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
		if fleetName ~= nil then
			ship.fleet = fleetName
		end
		table.insert(enemyList, ship)
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	fleetPower = math.max(fleetPower/danger/difficulty, 5)
	return enemyList, fleetPower
end
--------------------------------------------------
-- Optional mission initialization and routines --
--------------------------------------------------
function chooseUpgradeBase()
	local upgradeBase = nil
	local candidate = humanStationList[math.random(1,#humanStationList)]
	local ctd = candidate.comms_data
	local goodCount = 0
	local missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		ctd = candidate.comms_data
		if candidate ~= nil and candidate:isValid() and not inUpgradeList(candidate) then
			for good, goodData in pairs(ctd.goods) do
				goodCount = goodCount + 1
			end
			if goodCount > 0 then
				for good, goodData in pairs(ctd.goods) do
					if good ~= "food" and good ~= "medicine" then
						upgradeBase = candidate
					end
				end
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(upgradeBase ~= nil or missionAttemptCount > repeatExitBoundary)
	if upgradeBase ~= nil then
		table.insert(upgradeBaseList,upgradeBase)
	end
	return upgradeBase
end
function inUpgradeList(station)
	if #upgradeBaseList < 1 then
		return false
	else
		for i=1,#upgradeBaseList do
			if station == upgradeBaseList[i] then
				return true
			end
		end
		return false
	end
end
function chooseUpgradeGoodBase(upgradeBase)
	if optionalMissionDiagnostic then print("in upgrade good base") end
	if optionalMissionDiagnostic then print("upgrade base: " .. upgradeBase:getCallSign()) end
	local upgradeGoodBase = nil
	local upgradeGood = nil
	local matchAway = nil
	local candidate = humanStationList[math.random(1,#humanStationList)]
	local ctd = candidate.comms_data
	local goodCount = 0
	local missionAttemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if optionalMissionDiagnostic then print("candidate: " .. candidate:getCallSign()) end
		ctd = candidate.comms_data
		if candidate ~= nil and candidate:isValid() and candidate ~= upgradeBase then
			if optionalMissionDiagnostic then print("valid candidate") end
			goodCount = 0
			for good, goodData in pairs(ctd.goods) do
				goodCount = goodCount + 1
			end
			if goodCount > 0 then
				if optionalMissionDiagnostic then print("candidate has goods") end
				upgradeGoodBase = candidate
				for good, goodData in pairs(ctd.goods) do
					upgradeGood = good
					matchAway = false
					if good == "food" or good == "medicine" then
						if optionalMissionDiagnostic then print("skip food or medicine") end
						matchAway = true
					else
						for upgradeBaseGood, upgradeBaseGoodData in pairs(upgradeBase.comms_data.goods) do
							print(string.format("upgrade base good: %s",upgradeBaseGood))
							if good == upgradeBaseGood then
								if optionalMissionDiagnostic then print("matched upgrade base good, exit loop") end
								matchAway = true
								break
							end
						end
					end
					if not matchAway then 
						if optionalMissionDiagnostic then print("base and good qualifies: is not food or medicine and does not match upgrade base") end
						break 
					end
				end
			end
		end
		missionAttemptCount = missionAttemptCount + 1
	until(not matchAway or missionAttemptCount > repeatExitBoundary)
	if matchAway then
		if optionalMissionDiagnostic then print("did not find qualifying good and base") end
		return nil
	else
		if optionalMissionDiagnostic then print("found qualifying good and base") end
		return upgradeGood, upgradeGoodBase
	end
end
function setOptionalMissions()
	--	faster beams
	local missionAttemptCount = 0
	local goodCount = 0
	local matchAway = false
	local candidate = humanStationList[math.random(1,#humanStationList)]
	local ctd = candidate.comms_data
	upgradeBaseList = {}
	beamTimeBase = chooseUpgradeBase()
	if beamTimeBase ~= nil then
		beamTimeGood, beamTimeGoodBase = chooseUpgradeGoodBase(beamTimeBase)
		beamTimeBase.comms_data.character = "Horace Grayson"
		beamTimeBase.comms_data.characterDescription = "He dabbles in ship system innovations. He's been working on improving beam weapons by reducing the amount of time between firing. I hear he's already installed some improvements on ships that have docked here previously"
		beamTimeBase.comms_data.characterFunction = "shrinkBeamCycle"
		if beamTimeGood == nil then
			beamTimeBase.comms_data.characterGood = "gold pressed latinum"			
		else
			beamTimeBase.comms_data.characterGood = beamTimeGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("I heard there's a guy named %s that can fix ship beam systems up so that they shoot faster. He lives out on %s in %s. He won't charge you much, but it won't be free.",beamTimeBase.comms_data.character,beamTimeBase:getCallSign(),beamTimeBase:getSectorName())
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
	spinBase = chooseUpgradeBase()
	if spinBase ~= nil then
		spinGood, spinGoodBase = chooseUpgradeGoodBase(spinBase)
		spinBase.comms_data.character = "Emily Patel"
		spinBase.comms_data.characterDescription = "She tinkers with ship systems like engines and thrusters. She's consulted with the military on tuning spin time by increasing thruster power. She's got prototypes that are awaiting formal military approval before installation"
		spinBase.comms_data.characterFunction = "increaseSpin"
		if spinGood == nil then
			spinBase.comms_data.characterGood = "gold pressed latinum"			
		else
			spinBase.comms_data.characterGood = spinGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= spinBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("My friend, %s recently quit her job as a ship maintenance technician to set up this side gig. She's been improving ship systems and she's pretty good at it. She set up shop on %s in %s. I hear she's even lining up a contract with the navy for her improvements.",spinBase.comms_data.character,spinBase:getCallSign(),spinBase:getSectorName())
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
	auxTubeBase = chooseUpgradeBase()
	if auxTubeBase ~= nil then
		auxTubeGood, auxTubeGoodBase = chooseUpgradeGoodBase(auxTubeBase)
		auxTubeBase.comms_data.character = "Fred McLassiter"
		auxTubeBase.comms_data.characterDescription = "He specializes in miniaturization of weapons systems. He's come up with a way to add a missile tube and some missiles to any ship regardless of size or configuration"
		auxTubeBase.comms_data.characterFunction = "addAuxTube"
		if auxTubeGood == nil then
			auxTubeBase.comms_data.characterGood = "gold pressed latinum"			
		else
			auxTubeBase.comms_data.characterGood = auxTubeGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= auxTubeBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("There's this guy, %s out on %s in %s that can add a missile tube to your ship. He even added one to my cousin's souped up freighter. You should see the new paint job: amusingly phallic",auxTubeBase.comms_data.character,auxTubeBase:getCallSign(),auxTubeBase:getSectorName())
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
	coolBeamBase = chooseUpgradeBase()
	if coolBeamBase ~= nil then
		coolBeamGood, coolBeamGoodBase = chooseUpgradeGoodBase(coolBeamBase)
		coolBeamBase.comms_data.character = "Dorothy Ly"
		coolBeamBase.comms_data.characterDescription = "She developed this technique for cooling beam systems so that they can be fired more often without burning out"
		coolBeamBase.comms_data.characterFunction = "coolBeam"
		if coolBeamGood == nil then
			coolBeamBase.comms_data.characterGood = "gold pressed latinum"			
		else
			coolBeamBase.comms_data.characterGood = coolBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= coolBeamBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("There's this girl on %s in %s. She is hot. Her name is %s. When I say she is hot, I mean she has a way of keeping your beam weapons from excessive heat.",coolBeamBase:getCallSign(),coolBeamBase:getSectorName(),coolBeamBase.comms_data.character)
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
	longerBeamBase = chooseUpgradeBase()
	if longerBeamBase ~= nil then
		longerBeamGood, longerBeamGoodBase = chooseUpgradeGoodBase(longerBeamBase)
		longerBeamBase.comms_data.character = "Gerald Cook"
		longerBeamBase.comms_data.characterDescription = "He knows how to modify beam systems to extend their range"
		longerBeamBase.comms_data.characterFunction = "longerBeam"
		if longerBeamGood == nil then
			longerBeamBase.comms_data.characterGood = "gold pressed latinum"			
		else
			longerBeamBase.comms_data.characterGood = longerBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= longerBeamBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("Do you know about %s? He can extend the range of your beam weapons. He's on %s in %s",longerBeamBase.comms_data.character,longerBeamBase:getCallSign(),longerBeamBase:getSectorName())
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
	damageBeamBase = chooseUpgradeBase()
	if damageBeamBase ~= nil then
		damageBeamGood, damageBeamGoodBase = chooseUpgradeGoodBase(damageBeamBase)
		damageBeamBase.comms_data.character = "Sally Jenkins"
		damageBeamBase.comms_data.characterDescription = "She can make your beams hit harder"
		damageBeamBase.comms_data.characterFunction = "damageBeam"
		if damageBeamGood == nil then
			damageBeamBase.comms_data.characterGood = "gold pressed latinum"			
		else
			damageBeamBase.comms_data.characterGood = damageBeamGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= damageBeamBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("You should visit %s in %s. There's a specialist in beam technology that can increase the damage done by your beams. Her name is %s",damageBeamBase:getCallSign(),damageBeamBase:getSectorName(),damageBeamBase.comms_data.character)
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
	moreMissilesBase = chooseUpgradeBase()
	if moreMissilesBase ~= nil then
		moreMissilesGood, moreMissilesGoodBase = chooseUpgradeGoodBase(moreMissilesBase)
		moreMissilesBase.comms_data.character = "Anh Dung Ly"
		moreMissilesBase.comms_data.characterDescription = "He can fit more missiles aboard your ship"
		moreMissilesBase.comms_data.characterFunction = "moreMissiles"
		if moreMissilesGood == nil then
			moreMissilesBase.comms_data.characterGood = "gold pressed latinum"			
		else
			moreMissilesBase.comms_data.characterGood = moreMissilesGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= moreMissilesBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("Want to store more missiles on your ship? Talk to %s on station %s in %s. He can retrain your missile loaders and missile storage automation such that you will be able to store more missiles",moreMissilesBase.comms_data.character,moreMissilesBase:getCallSign(),moreMissilesBase:getSectorName())
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
	fasterImpulseBase = chooseUpgradeBase()
	if fasterImpulseBase ~= nil then
		fasterImpulseGood, fasterImpulseGoodBase = chooseUpgradeGoodBase(fasterImpulseBase)
		fasterImpulseBase.comms_data.character = "Doralla Ognats"
		fasterImpulseBase.comms_data.characterDescription = "She can soup up your impulse engines"
		fasterImpulseBase.comms_data.characterFunction = "fasterImpulse"
		if fasterImpulseGood == nil then
			fasterImpulseBase.comms_data.characterGood = "gold pressed latinum"			
		else
			fasterImpulseBase.comms_data.characterGood = fasterImpulseGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= fasterImpulseBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("%s, an engineer/mechanic who knows propulsion systems backwards and forwards has a bay at the shipyard on %s in %s. She can give your impulse engines a significant boost to their top speed",fasterImpulseBase.comms_data.character,fasterImpulseBase:getCallSign(),fasterImpulseBase:getSectorName())
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
	strongerHullBase = chooseUpgradeBase()
	if strongerHullBase ~= nil then
		strongerHullGood, strongerHullGoodBase = chooseUpgradeGoodBase(strongerHullBase)
		strongerHullBase.comms_data.character = "Maduka Lawal"
		strongerHullBase.comms_data.characterDescription = "He can strengthen your hull"
		strongerHullBase.comms_data.characterFunction = "strongerHull"
		if strongerHullGood ~= nil then
			strongerHullBase.comms_data.characterGood = "gold pressed latinum"			
		else
			strongerHullBase.comms_data.characterGood = strongerHullGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= strongerHullBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("I know of a materials specialist on %s in %s named %s. He can strengthen the hull on your ship",strongerHullBase:getCallSign(),strongerHullBase:getSectorName(),strongerHullBase.comms_data.character)
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
	efficientBatteriesBase = chooseUpgradeBase()
	if efficientBatteriesBase ~= nil then
		efficientBatteriesGood, efficientBatteriesGoodBase = chooseUpgradeGoodBase(efficientBatteriesBase)
		efficientBatteriesBase.comms_data.character = "Susil Tarigan"
		efficientBatteriesBase.comms_data.characterDescription = "She knows how to increase your maximum energy capacity by improving battery efficiency"
		efficientBatteriesBase.comms_data.characterFunction = "efficientBatteries"
		if efficientBatteriesGood == nil then
			efficientBatteriesBase.comms_data.characterGood = "gold pressed latinum"			
		else
			efficientBatteriesBase.comms_data.characterGood = efficientBatteriesGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= efficientBatteriesBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("Have you heard about %s? She's on %s in %s and she can give your ship greater energy capacity by improving your battery efficiency",efficientBatteriesBase.comms_data.character,efficientBatteriesBase:getCallSign(),efficientBatteriesBase:getSectorName())
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
	strongerShieldsBase = chooseUpgradeBase()
	if strongerShieldsBase ~= nil then
		strongerShieldsGood, strongerShieldsGoodBase = chooseUpgradeGoodBase(strongerShieldsBase)
		strongerShieldsBase.comms_data.character = "Paulo Silva"
		strongerShieldsBase.comms_data.characterDescription = "He can strengthen your shields"
		strongerShieldsBase.comms_data.characterFunction = "strongerShields"
		if strongerShieldsGood == nil then
			strongerShieldsBase.comms_data.characterGood = "gold pressed latinum"			
		else
			strongerShieldsBase.comms_data.characterGood = strongerShieldsGood
			clueStation = nil
			missionAttemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= strongerShieldsBase and candidate.comms_data.gossip == nil then
					clueStation = candidate
				end
				missionAttemptCount = missionAttemptCount + 1
			until(clueStation ~= nil or missionAttemptCount > repeatExitBoundary)
			if clueStation ~= nil then
				clueStation.comms_data.gossip = string.format("If you stop at %s in %s, you should talk to %s. He can strengthen your shields. Trust me, it's always good to have stronger shields",strongerShieldsBase:getCallSign(),strongerShieldsBase:getSectorName(),strongerShieldsBase.comms_data.character)
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
function payForUpgrade()
	if	(difficulty == 1 and treaty) or 
		(difficulty < 1 and treaty and treatyTimer > 0) or
		(difficulty > 1 and treaty) or
		(difficulty > 1 and not treaty and not targetKraylorStations) then
		return true
	else
		return false
	end
end
function shrinkBeamCycle()
	if comms_source.shrinkBeamCycleUpgrade == nil then
		addCommsReply("Reduce beam cycle time", function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if	payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.shrinkBeamCycleUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .75,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage("After accepting your gift, he reduced your Beam cycle time by 25%%")
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",ctd.character,ctd.characterGood))
					end
				else
					comms_source.shrinkBeamCycleUpgrade = "done"
					bi = 0
					repeat
						tempArc = comms_source:getBeamWeaponArc(bi)
						tempDir = comms_source:getBeamWeaponDirection(bi)
						tempRng = comms_source:getBeamWeaponRange(bi)
						tempCyc = comms_source:getBeamWeaponCycleTime(bi)
						tempDmg = comms_source:getBeamWeaponDamage(bi)
						comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .75,tempDmg)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s reduced your Beam cycle time by 25%% at no cost in trade with the message, 'Go get those Kraylors.'",ctd.character))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function increaseSpin()
	if comms_source.increaseSpinUpgrade == nil then
		addCommsReply("Increase spin speed", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.increaseSpinUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
					setCommsMessage(string.format("Ship spin speed increased by 50%% after you gave %s to %s",ctd.characterGood,ctd.character))
				else
					setCommsMessage(string.format("%s requires %s for the spin upgrade",ctd.character,ctd.characterGood))
				end
			else
				comms_source.increaseSpinUpgrade = "done"
				comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
				setCommsMessage(string.format("%s: I increased the speed your ship spins by 50%%. Normally, I'd require %s, but seeing as you're going out to take on the Kraylors, we worked it out",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function addAuxTube()
	if comms_source.auxTubeUpgrade == nil then
		addCommsReply("Add missle tube", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local luxQuantity = 0
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
					luxQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 and luxQuantity > 0 then
					comms_source.auxTubeUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
					comms_source.cargo = comms_source.cargo + 2
					local originalTubes = comms_source:getWeaponTubeCount()
					local newTubes = originalTubes + 1
					comms_source:setWeaponTubeCount(newTubes)
					comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
					comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
					comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
					setCommsMessage(string.format("%s thanks you for the %s and the luxury and installs a homing missile tube for you",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("%s requires %s and luxury for the missile tube",ctd.character,ctd.characterGood))
				end
			else
				comms_source.auxTubeUpgrade = "done"
				originalTubes = comms_source:getWeaponTubeCount()
				newTubes = originalTubes + 1
				comms_source:setWeaponTubeCount(newTubes)
				comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
				comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
				comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
				setCommsMessage(string.format("%s installs a homing missile tube for you. The %s required was requisitioned from wartime contingency supplies",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function coolBeam()
	if comms_source.coolBeamUpgrade == nil then
		addCommsReply("Reduce beam heat", function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.coolBeamUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage("Beam heat generation reduced by 50%%")
					else
						setCommsMessage(string.format("%s says she needs %s before she can cool your beams",ctd.character,ctd.characterGood))
					end
				else
					comms_source.coolBeamUpgrade = "done"
					bi = 0
					repeat
						comms_source:setBeamWeaponHeatPerFire(bi,comms_source:getBeamWeaponHeatPerFire(bi) * 0.5)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s: Beam heat generation reduced by 50%%, no %s necessary. Go shoot some Kraylors for me",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function longerBeam()
	if comms_source.longerBeamUpgrade == nil then
		addCommsReply("Extend beam range", function()
			if optionalMissionDiagnostic then print("extending beam range") end
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if optionalMissionDiagnostic then print("ship qualifies") end
				if payForUpgrade() then
					if optionalMissionDiagnostic then print("treaty still in force") end
					local partQuantity = 0
					if comms_source.goods ~= nil then
						if comms_source.goods[ctd.characterGood] ~= nil then
							if comms_source.goods[ctd.characterGood] > 0 then
								partQuantity = comms_source.goods[ctd.characterGood]
							end
						end
					end
					if partQuantity > 0 then
						if optionalMissionDiagnostic then print("player has enough of the right goods") end
						comms_source.longerBeamUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng * 1.25,tempCyc,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						if optionalMissionDiagnostic then print("beam range extended") end
						setCommsMessage(string.format("%s extended your beam range by 25%% and says thanks for the %s",ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",ctd.character,ctd.characterGood))
					end
				else
					if optionalMissionDiagnostic then print("war declared") end
					comms_source.longerBeamUpgrade = "done"
					bi = 0
					repeat
						tempArc = comms_source:getBeamWeaponArc(bi)
						tempDir = comms_source:getBeamWeaponDirection(bi)
						tempRng = comms_source:getBeamWeaponRange(bi)
						tempCyc = comms_source:getBeamWeaponCycleTime(bi)
						tempDmg = comms_source:getBeamWeaponDamage(bi)
						comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng * 1.25,tempCyc,tempDmg)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					if optionalMissionDiagnostic then print("beam range extended for free") end
					setCommsMessage(string.format("%s increased your beam range by 25%% without the usual %s from your ship",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function damageBeam()
	if comms_source.damageBeamUpgrade == nil then
		addCommsReply("Increase beam damage", function()
			local ctd = comms_target.comms_data
			if comms_source:getBeamWeaponRange(0) > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.damageBeamUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(string.format("%s increased your beam damage by 20%% and stores away the %s",ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format("%s requires %s for the upgrade",ctd.character,ctd.characterGood))
					end
				else
					comms_source.damageBeamUpgrade = "done"
					bi = 0
					repeat
						tempArc = comms_source:getBeamWeaponArc(bi)
						tempDir = comms_source:getBeamWeaponDirection(bi)
						tempRng = comms_source:getBeamWeaponRange(bi)
						tempCyc = comms_source:getBeamWeaponCycleTime(bi)
						tempDmg = comms_source:getBeamWeaponDamage(bi)
						comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
						bi = bi + 1
					until(comms_source:getBeamWeaponRange(bi) < 1)
					setCommsMessage(string.format("%s increased your beam damage by 20%%, waiving the usual %s requirement",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a beam weapon upgrade.")				
			end
		end)
	end
end
function moreMissiles()
	if comms_source.moreMissilesUpgrade == nil then
		addCommsReply("Increase missile storage capacity", function()
			local ctd = comms_target.comms_data
			if comms_source:getWeaponTubeCount() > 0 then
				if payForUpgrade() then
					local partQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
						partQuantity = comms_source.goods[ctd.characterGood]
					end
					if partQuantity > 0 then
						comms_source.moreMissilesUpgrade = "done"
						comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						for _, missile_type in ipairs(missile_types) do
							comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
						end
						setCommsMessage(string.format("%s: You can now store at least 25%% more missiles. I appreciate the %s",ctd.character,ctd.characterGood))
					else
						setCommsMessage(string.format("%s needs %s for the upgrade",ctd.character,ctd.characterGood))
					end
				else
					comms_source.moreMissilesUpgrade = "done"
					missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
					for _, missile_type in ipairs(missile_types) do
						comms_source:setWeaponStorageMax(missile_type, math.ceil(comms_source:getWeaponStorageMax(missile_type)*1.25))
					end
					setCommsMessage(string.format("%s: You can now store at least 25%% more missiles. I found some spare %s on the station. Go launch those missiles at those perfidious treaty-breaking Kraylors",ctd.character,ctd.characterGood))
				end
			else
				setCommsMessage("Your ship type does not support a missile storage capacity upgrade.")				
			end
		end)
	end
end
function fasterImpulse()
	if comms_source.fasterImpulseUpgrade == nil then
		addCommsReply("Speed up impulse engines", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.fasterImpulseUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
					setCommsMessage(string.format("%s: Your impulse engines now push you up to 25%% faster. Thanks for the %s",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("You need to bring %s to %s for the upgrade",ctd.characterGood,ctd.character))
				end
			else
				comms_source.fasterImpulseUpgrade = "done"
				comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
				setCommsMessage(string.format("%s: Your impulse engines now push you up to 25%% faster. I didn't need %s after all. Go run circles around those blinking Kraylors",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function strongerHull()
	if comms_source.strongerHullUpgrade == nil then
		addCommsReply("Strengthen hull", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerHullUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setHullMax(comms_source:getHullMax()*1.5)
					comms_source:setHull(comms_source:getHullMax())
					setCommsMessage(string.format("%s: Thank you for the %s. Your hull is 50%% stronger",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("%s: I need %s before I can increase your hull strength",ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerHullUpgrade = "done"
				comms_source:setHullMax(comms_source:getHullMax()*1.5)
				comms_source:setHull(comms_source:getHullMax())
				setCommsMessage(string.format("%s: I made your hull 50%% stronger. I scrounged some %s from around here since you are on the Kraylor offense team",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function efficientBatteries()
	if comms_source.efficientBatteriesUpgrade == nil then
		addCommsReply("Increase battery efficiency", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.efficientBatteriesUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
					comms_source:setEnergy(comms_source:getMaxEnergy())
					setCommsMessage(string.format("%s: I appreciate the %s. You have a 25%% greater energy capacity due to increased battery efficiency",ctd.character,ctd.characterGood))
				else
					setCommsMessage(string.format("%s: You need to bring me some %s before I can increase your battery efficiency",ctd.character,ctd.characterGood))
				end
			else
				comms_source.efficientBatteriesUpgrade = "done"
				comms_source:setMaxEnergy(comms_source:getMaxEnergy()*1.25)
				comms_source:setEnergy(comms_source:getMaxEnergy())
				setCommsMessage(string.format("%s increased your battery efficiency by 25%% without the need for %s due to the pressing military demands on your ship",ctd.character,ctd.characterGood))
			end
		end)
	end
end
function strongerShields()
	if comms_source.strongerShieldsUpgrade == nil then
		addCommsReply("Strengthen shields", function()
			local ctd = comms_target.comms_data
			if payForUpgrade() then
				local partQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[ctd.characterGood] ~= nil and comms_source.goods[ctd.characterGood] > 0 then
					partQuantity = comms_source.goods[ctd.characterGood]
				end
				if partQuantity > 0 then
					comms_source.strongerShieldsUpgrade = "done"
					comms_source.goods[ctd.characterGood] = comms_source.goods[ctd.characterGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					if comms_source:getShieldCount() == 1 then
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
					else
						comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
					end
					setCommsMessage(string.format("%s: I've raised your shield maximum by 20%%, %s. Thanks for bringing the %s",ctd.character,comms_source:getCallSign(),ctd.characterGood))
				else
					setCommsMessage(string.format("%s: You need to provide %s before I can raise your shield strength",ctd.character,ctd.characterGood))
				end
			else
				comms_source.strongerShieldsUpgrade = "done"
				if comms_source:getShieldCount() == 1 then
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2)
				else
					comms_source:setShieldsMax(comms_source:getShieldMax(0)*1.2,comms_source:getShieldMax(1)*1.2)
				end
				setCommsMessage(string.format("%s: Congratulations, %s, your shields are 20%% stronger. Don't worry about the %s. Go kick those Kraylors outta here",ctd.character,comms_source:getCallSign(),ctd.characterGood))
			end
		end)
	end
end
---------------------------
-- Station communication --
---------------------------
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
            preorder = "friend"
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
    if comms_source:isEnemy(comms_target) then
        return false
    end
    if comms_target:areEnemiesInRange(5000) then
        setCommsMessage("We are under attack! No time for chatting!");
        return true
    end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function handleDockedState()
	local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
    	if ctd.friendlyness > 66 then
    		oMsg = string.format("Greetings %s!\nHow may we help you today?",comms_source:getCallSign())
    	elseif ctd.friendlyness > 33 then
			oMsg = "Good day, officer!\nWhat can we do for you today?"
		else
			oMsg = "Hello, may I help you?"
		end
    else
		oMsg = "Welcome to our lovely station."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nForgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply("I need ordnance restocked", function()
				local ctd = comms_target.comms_data
				if stationCommsDiagnostic then print("in restock function") end
				setCommsMessage("What type of ordnance?")
				if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if stationCommsDiagnostic then print("player can fire nukes") end
					if ctd.weapon_available.Nuke then
						if stationCommsDiagnostic then print("station has nukes available") end
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						if stationCommsDiagnostic then print("nuke prompt: " .. nukePrompt) end
						addCommsReply(nukePrompt .. getWeaponCost("Nuke") .. " rep each)", function()
							if stationCommsDiagnostic then print("going to handle weapon restock function") end
							handleWeaponRestock("Nuke")
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if ctd.weapon_available.EMP then
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
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if ctd.weapon_available.Homing then
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
				if comms_source:getWeaponStorageMax("Mine") > 0 then
					if ctd.weapon_available.Mine then
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
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if ctd.weapon_available.HVLI then
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
	if ctd.public_relations then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			addCommsReply("General information", function()
				setCommsMessage(ctd.general_information)
				addCommsReply("Back", commsStation)
			end)
			if ctd.history ~= nil then
				addCommsReply("Station history", function()
					setCommsMessage(ctd.history)
					addCommsReply("Back", commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if ctd.gossip ~= nil then
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply("Gossip", function()
							setCommsMessage(ctd.gossip)
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
	if ctd.character ~= nil then
		addCommsReply(string.format("Tell me about %s",ctd.character), function()
			if ctd.characterDescription ~= nil then
				setCommsMessage(ctd.characterDescription)
			else
				if ctd.characterDeadEnd == nil then
					local deadEndChoice = math.random(1,5)
					if deadEndChoice == 1 then
						ctd.characterDeadEnd = "Never heard of " .. ctd.character
					elseif deadEndChoice == 2 then
						ctd.characterDeadEnd = ctd.character .. " died last week. The funeral was yesterday"
					elseif deadEndChoice == 3 then
						ctd.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",ctd.character,ctd.character,ctd.character)
					elseif deadEndChoice == 4 then
						ctd.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",ctd.character)
					else
						ctd.characterDeadEnd = string.format("I think %s moved away",ctd.character)
					end
				end
				setCommsMessage(ctd.characterDeadEnd)
			end
			if ctd.characterFunction == "shrinkBeamCycle" then
				shrinkBeamCycle()
			end
			if ctd.characterFunction == "increaseSpin" then
				increaseSpin()
			end
			if ctd.characterFunction == "addAuxTube" then
				addAuxTube()
			end
			if ctd.characterFunction == "coolBeam" then
				coolBeam()
			end
			if ctd.characterFunction == "longerBeam" then
				longerBeam()
			end
			if ctd.characterFunction == "damageBeam" then
				damageBeam()
			end
			if ctd.characterFunction == "moreMissiles" then
				moreMissiles()
			end
			if ctd.characterFunction == "fasterImpulse" then
				fasterImpulse()
			end
			if ctd.characterFunction == "strongerHull" then
				strongerHull()
			end
			if ctd.characterFunction == "efficientBatteries" then
				efficientBatteries()
			end
			if ctd.characterFunction == "strongerShields" then
				strongerShields()
			end
			addCommsReply("Back", commsStation)
		end)
	end
	if comms_source:isFriendly(comms_target) then
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
			local hireCost = math.random(45,90)
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(45,90)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(30,60)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	else
		if math.random(1,5) <= (3 - difficulty) then
			local hireCost = math.random(60,120)
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(60,120)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(45,90)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	addCommsReply("Visit cartography office", function()
		if comms_target.cartographer_description == nil then
			local clerk_choice = math.random(1,3)
			if clerk_choice == 1 then
				comms_target.cartographer_description = "The clerk behind the desk looks up briefly at you then goes back to filing her nails."
			elseif clerk_choice == 2 then
				comms_target.cartographer_description = "The clerk behind the desk examines you then returns to grooming her tentacles."
			else
				comms_target.cartographer_description = "The clerk behind the desk glances at you then returns to preening her feathers."
			end
		end
		setCommsMessage(string.format("%s\n\nYou can examine the brochure on the coffee table, talk to the apprentice cartographer or talk to the master cartographer",comms_target.cartographer_description))
		addCommsReply("What's the difference between the apprentice and the master?", function()
			setCommsMessage("The clerk responds in a bored voice, 'The apprentice knows the local area and is learning the broader area. The master knows the local and the broader area but can't be bothered with the local area'")
			addCommsReply("Back",commsStation)
		end)
		addCommsReply(string.format("Examine brochure (%i rep)",getCartographerCost()),function()
			if comms_source:takeReputationPoints(getCartographerCost()) then
				setCommsMessage("The brochure has a list of nearby stations and has a list of goods nearby")
				addCommsReply(string.format("Examine station list (%i rep)",getCartographerCost()), function()
					if comms_source:takeReputationPoints(getCartographerCost()) then
						local brochure_stations = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for _, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
									if brochure_stations == "" then
										brochure_stations = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									else
										brochure_stations = string.format("%s\n%s %s %s",brochure_stations,obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									end
								end
							end
						end
						setCommsMessage(brochure_stations)
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back",commsStation)
				end)
				addCommsReply(string.format("Examine goods list (%i rep)",getCartographerCost()), function()
					if comms_source:takeReputationPoints(getCartographerCost()) then
						local brochure_goods = ""
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,30000)
						for _, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.goods ~= nil then
										for good, good_data in pairs(obj.comms_data.goods) do
											if brochure_goods == "" then
												brochure_goods = string.format("Good, quantity, cost, station:\n%s, %i, %i, %s",good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											else
												brochure_goods = string.format("%s\n%s, %i, %i, %s",brochure_goods,good,good_data["quantity"],good_data["cost"],obj:getCallSign())
											end
										end
									end
								end
							end
						end
						setCommsMessage(brochure_goods)
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back",commsStation)
				end)
				if ctd.character_brochure == nil then
					local upgrade_stations = {}
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,30000)
					for _, obj in ipairs(nearby_objects) do
						if obj.typeName == "SpaceStation" then
							if not obj:isEnemy(comms_target) then
								if obj.comms_data.characterDescription ~= nil then
									local sd = distance(obj,sx, sy)
									if random(0,1) < (1 - (sd/30000)) then
										table.insert(upgrade_stations,obj)
									end
								end
							end
						end
					end
					ctd.character_brochure = upgrade_stations
				end
				if #ctd.character_brochure > 0 then
					addCommsReply(string.format("Examine upgrades list (%i rep)",getCartographerCost()), function()
						if comms_source:takeReputationPoints(getCartographerCost()) then
							local brochure_upgrades = ""
							for i=1,#ctd.character_brochure do
								local upgrade_station = ctd.character_brochure[i]
								if brochure_upgrades == "" then
									brochure_upgrades = string.format("%s: %s: %s",upgrade_station:getCallSign(),upgrade_station.comms_data.character,upgrade_station.comms_data.characterDescription)
								else
									brochure_upgrades = string.format("%s\n%s: %s: %s",brochure_upgrades,upgrade_station:getCallSign(),upgrade_station.comms_data.character,upgrade_station.comms_data.characterDescription)
								end
							end
							setCommsMessage(brochure_upgrades)
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back",commsStation)
					end)
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply(string.format("Talk to apprentice cartographer (%i rep)",getCartographerCost("apprentice")), function()
			if comms_source:takeReputationPoints(1) then
				if ctd.character_apprentice == nil then
					local upgrade_stations = {}
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,30000)
					for _, obj in ipairs(nearby_objects) do
						if obj.typeName == "SpaceStation" then
							if not obj:isEnemy(comms_target) then
								if obj.comms_data.characterDescription ~= nil then
									table.insert(upgrade_stations,obj)
								end
							end
						end
					end
					ctd.character_apprentice = upgrade_stations
				end
				if #ctd.character_apprentice > 0 then
					setCommsMessage("Hi, would you like for me to locate a station, some goods or some upgrades for you?")
				else
					setCommsMessage("Hi, would you like for me to locate a station or some goods for you?")
				end
				addCommsReply("Locate station", function()
					setCommsMessage("These are stations I have learned")
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,50000)
					local stations_known = 0
					for _, obj in ipairs(nearby_objects) do
						if obj.typeName == "SpaceStation" then
							if not obj:isEnemy(comms_target) then
								stations_known = stations_known + 1
								addCommsReply(obj:getCallSign(),function()
									local station_details = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
									if obj.comms_data.goods ~= nil then
										station_details = string.format("%s\nGood, quantity, cost",station_details)
										for good, good_data in pairs(obj.comms_data.goods) do
											station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
										end
									end
									if obj.comms_data.general_information ~= nil then
										station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
									end
									if obj.comms_data.history ~= nil then
										station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
									end
									if obj.comms_data.gossip ~= nil then
										station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
									end
									if obj.comms_data.characterDescription ~= nil then
										station_details = string.format("%s\n%s:\n   %s",station_details,obj.comms_data.character,obj.comms_data.characterDescription)
									end
									setCommsMessage(station_details)
									addCommsReply("Back",commsStation)
								end)
							end
						end
					end
					if stations_known == 0 then
						setCommsMessage("I have learned of no stations yet")
					end
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Locate goods", function()
					setCommsMessage("These are the goods I know about")
					local sx, sy = comms_target:getPosition()
					local nearby_objects = getObjectsInRadius(sx,sy,50000)
					local button_count = 0
					local by_goods = {}
					for _, obj in ipairs(nearby_objects) do
						if obj.typeName == "SpaceStation" then
							if not obj:isEnemy(comms_target) then
								if obj.comms_data.goods ~= nil then
									for good, good_data in pairs(obj.comms_data.goods) do
										by_goods[good] = obj
									end
								end
							end
						end
					end
					for good, obj in pairs(by_goods) do
						addCommsReply(good, function()
							local station_details = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
							if obj.comms_data.goods ~= nil then
								station_details = string.format("%s\nGood, quantity, cost",station_details)
								for good, good_data in pairs(obj.comms_data.goods) do
									station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
								end
							end
							if obj.comms_data.general_information ~= nil then
								station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
							end
							if obj.comms_data.history ~= nil then
								station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
							end
							if obj.comms_data.gossip ~= nil then
								station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
							end
							if obj.comms_data.characterDescription ~= nil then
								station_details = string.format("%s\n%s:\n   %s",station_details,obj.comms_data.character,obj.comms_data.characterDescription)
							end
							setCommsMessage(station_details)
							addCommsReply("Back",commsStation)
						end)
						button_count = button_count + 1
						if button_count >= 20 then
							break
						end
					end
					addCommsReply("Back",commsStation)
				end)
				if #ctd.character_apprentice > 0 then
					addCommsReply("Locate upgrade station", function()
						setCommsMessage("These are stations I have learned that have upgrades")
						local sx, sy = comms_target:getPosition()
						local nearby_objects = getObjectsInRadius(sx,sy,50000)
						local stations_known = 0
						for _, obj in ipairs(nearby_objects) do
							if obj.typeName == "SpaceStation" then
								if not obj:isEnemy(comms_target) then
									if obj.comms_data.characterDescription ~= nil then
										stations_known = stations_known + 1
										addCommsReply(obj:getCallSign(), function()
											local station_details = string.format("%s %s %s",obj:getSectorName(),obj:getFaction(),obj:getCallSign())
											if obj.comms_data.goods ~= nil then
												station_details = string.format("%s\nGood, quantity, cost",station_details)
												for good, good_data in pairs(obj.comms_data.goods) do
													station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
												end
											end
											if obj.comms_data.general_information ~= nil then
												station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
											end
											if obj.comms_data.history ~= nil then
												station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
											end
											if obj.comms_data.gossip ~= nil then
												station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
											end
											if obj.comms_data.characterDescription ~= nil then
												station_details = string.format("%s\n%s:\n   %s",station_details,obj.comms_data.character,obj.comms_data.characterDescription)
											end
											setCommsMessage(station_details)
											addCommsReply("Back",commsStation)
										end)
									end
								end
							end
						end
						if stations_known == 0 then
							setCommsMessage("I have learned of no upgrade stations yet")
						end
					end)
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply(string.format("Talk to master cartographer (%i rep)",getCartographerCost("master")), function()
			if comms_source:getWaypointCount() >= 9 then
				setCommsMessage("The clerk clears her throat:\n\nMy indicators show you have zero available waypoints. To get the most from the master cartographer, you should delete one or more so that he can update your systems appropriately.\n\nI just want you to get the maximum benefit for the time you spend with him")
				addCommsReply("Continue to Master Cartographer", masterCartographer)
			else
				masterCartographer()
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Back",commsStation)
	end)
	local goodCount = 0
	for good, goodData in pairs(ctd.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format("Current cargo aboard %s:\n",comms_source:getCallSign())
			local cargoHoldEmpty = true
			local player_good_count = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					player_good_count = player_good_count + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if player_good_count < 1 then
				goodsReport = goodsReport .. "     Empty\n"
			end
			goodsReport = goodsReport .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
				addCommsReply(string.format("Buy one %s for %i reputation",good,goodData["cost"]), function()
					local goodTransactionMessage = string.format("Type: %s, Quantity: %i, Rep: %i",good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient cargo space for purchase"
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
					else
						if comms_source:takeReputationPoints(goodData["cost"]) then
							comms_source.cargo = comms_source.cargo - 1
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							goodTransactionMessage = goodTransactionMessage .. "\npurchased"
						else
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient reputation for purchase"
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply("Back", commsStation)
				end)
			end
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
					if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format("Sell one %s for %i reputation",good,price), function()
							local goodTransactionMessage = string.format("Type: %s,  Reputation price: %i",good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. "\nOne sold"
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply("Back", commsStation)
						end)
					end
				end
			end
			if ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format("Trade food for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
						else
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["food"] = comms_source.goods["food"] - 1
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format("Trade medicine for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
						else
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["medicine"] = comms_source.goods["medicine"] - 1
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format("Trade luxury for %s",good), function()
						local goodTransactionMessage = string.format("Type: %s,  Quantity: %i",good,goodData["quantity"])
						if goodData[quantity] < 1 then
							goodTransactionMessage = goodTransactionMessage .. "\nInsufficient station inventory"
						else
							goodData["quantity"] = goodData["quantity"] - 1
							if comms_source.goods == nil then
								comms_source.goods = {}
							end
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
							goodTransactionMessage = goodTransactionMessage .. "\nTraded"
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			addCommsReply("Back", commsStation)
		end)
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, goodQuantity in pairs(comms_source.goods) do
				player_good_count = player_good_count + 1
			end
		end
		if player_good_count > 0 then
			addCommsReply("Jettison cargo", function()
				setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
				for good, good_quantity in pairs(comms_source.goods) do
					if good_quantity > 0 then
						addCommsReply(good, function()
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format("One %s jettisoned",good))
							addCommsReply("Back", commsStation)
						end)
					end
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("No tutorial covered goods or cargo. Explain", function()
			setCommsMessage("Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)")
			addCommsReply("Back", commsStation)
		end)
	end
end	--end of handleDockedState function
function masterCartographer()
	local ctd = comms_target.comms_data
	if comms_source:takeReputationPoints(getCartographerCost("master")) then
		if ctd.character_master == nil then
			local upgrade_stations = {}
			local nearby_objects = getAllObjects()
			local station_distance = 0
			for _, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_target) then
						station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							if obj.comms_data.characterDescription ~= nil then
								table.insert(upgrade_stations,obj)
							end
						end
					end
				end
			end
			ctd.character_master = upgrade_stations
		end
		if #ctd.character_master > 0 then
			setCommsMessage("Greetings,\nMay I help you find a station, goods or an upgrade?")
		else
			setCommsMessage("Greetings,\nMay I help you find a station or goods?")
		end
		addCommsReply("Find station",function()
			setCommsMessage("What station?")
			local nearby_objects = getAllObjects()
			local stations_known = 0
			local station_distance = 0
			for _, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_target) then
						station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							stations_known = stations_known + 1
							addCommsReply(obj:getCallSign(),function()
								local station_details = string.format("%s %s %s Distance:%.1fU",obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
								if obj.comms_data.goods ~= nil then
									station_details = string.format("%s\nGood, quantity, cost",station_details)
									for good, good_data in pairs(obj.comms_data.goods) do
										station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
									end
								end
								if obj.comms_data.general_information ~= nil then
									station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
								end
								if obj.comms_data.history ~= nil then
									station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
								end
								if obj.comms_data.gossip ~= nil then
									station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
								end
								if obj.comms_data.characterDescription ~= nil then
									station_details = string.format("%s\n%s:\n   %s",station_details,obj.comms_data.character,obj.comms_data.characterDescription)
								end
								local dsx, dsy = obj:getPosition()
								comms_source:commandAddWaypoint(dsx,dsy)
								station_details = string.format("%s\nAdded waypoint %i to your navigation system for %s",station_details,comms_source:getWaypointCount(),obj:getCallSign())
								setCommsMessage(station_details)
								addCommsReply("Back",commsStation)
							end)
						end
					end
				end
			end
			if stations_known == 0 then
				setCommsMessage("Try the apprentice, I'm tired")
			end
			addCommsReply("Back",commsStation)
		end)
		addCommsReply("Find Goods", function()
			setCommsMessage("What goods are you looking for?")
			local nearby_objects = getAllObjects()
			local by_goods = {}
			for _, obj in ipairs(nearby_objects) do
				if obj.typeName == "SpaceStation" then
					if not obj:isEnemy(comms_target) then
						local station_distance = distance(comms_target,obj)
						if station_distance > 50000 then
							if obj.comms_data.goods ~= nil then
								for good, good_data in pairs(obj.comms_data.goods) do
									by_goods[good] = obj
								end
							end
						end
					end
				end
			end
			for good, obj in pairs(by_goods) do
				addCommsReply(good, function()
					local station_distance = distance(comms_target,obj)
					local station_details = string.format("%s %s %s Distance:%.1fU",obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
					if obj.comms_data.goods ~= nil then
						station_details = string.format("%s\nGood, quantity, cost",station_details)
						for good, good_data in pairs(obj.comms_data.goods) do
							station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
						end
					end
					if obj.comms_data.general_information ~= nil then
						station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
					end
					if obj.comms_data.history ~= nil then
						station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
					end
					if obj.comms_data.gossip ~= nil then
						station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
					end
					if obj.comms_data.characterDescription ~= nil then
						station_details = string.format("%s\n%s:\n   %s",station_details,obj.comms_data.character,obj.comms_data.characterDescription)
					end
					local dsx, dsy = obj:getPosition()
					comms_source:commandAddWaypoint(dsx,dsy)
					station_details = string.format("%s\nAdded waypoint %i to your navigation system for %s",station_details,comms_source:getWaypointCount(),obj:getCallSign())
					setCommsMessage(station_details)
					addCommsReply("Back",commsStation)
				end)
			end
			addCommsReply("Back",commsStation)
		end)
		if #ctd.character_master > 0 then
			addCommsReply("Find Upgrade Station", function()
				setCommsMessage("What station?")
				for i=1,#ctd.character_master do
					local obj = ctd.character_master[i]
					station_distance = distance(comms_target,obj)
					addCommsReply(obj:getCallSign(), function()
						local station_details = string.format("%s %s %s Distance:%.1fU",obj:getSectorName(),obj:getFaction(),obj:getCallSign(),station_distance/1000)
						if obj.comms_data.goods ~= nil then
							station_details = string.format("%s\nGood, quantity, cost",station_details)
							for good, good_data in pairs(obj.comms_data.goods) do
								station_details = string.format("%s\n   %s, %i, %i",station_details,good,good_data["quantity"],good_data["cost"])
							end
						end
						if obj.comms_data.general_information ~= nil then
							station_details = string.format("%s\nGeneral Information:\n   %s",station_details,obj.comms_data.general_information)
						end
						if obj.comms_data.history ~= nil then
							station_details = string.format("%s\nHistory:\n   %s",station_details,obj.comms_data.history)
						end
						if obj.comms_data.gossip ~= nil then
							station_details = string.format("%s\nGossip:\n   %s",station_details,obj.comms_data.gossip)
						end
						if obj.comms_data.characterDescription ~= nil then
							station_details = string.format("%s\n%s:\n   %s",station_details,obj.comms_data.character,obj.comms_data.characterDescription)
						end
						local dsx, dsy = obj:getPosition()
						comms_source:commandAddWaypoint(dsx,dsy)
						station_details = string.format("%s\nAdded waypoint %i to your navigation system for %s",station_details,comms_source:getWaypointCount(),obj:getCallSign())
						setCommsMessage(station_details)
						addCommsReply("Back",commsStation)
					end)
				end
			end)
		end
	else
		setCommsMessage("Insufficient Reputation")
	end
end
function getCartographerCost(service)
	local base_cost = 1
	if service == "apprentice" then
		base_cost = 5
	elseif service == "master" then
		base_cost = 10
	end
	return math.ceil(base_cost * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function setOptionalOrders()
	optionalOrders = ""
end
function isAllowedTo(state)
    if state == "friend" and comms_source:isFriendly(comms_target) then
        return true
    end
    if state == "neutral" and not comms_source:isEnemy(comms_target) then
        return true
    end
    return false
end
function handleWeaponRestock(weapon)
    if not comms_source:isDocked(comms_target) then 
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
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", commsStation)
    else
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use.")
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage("You can't afford as much as I'd like to give you")
				addCommsReply("Get just one", function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
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
    local ctd = comms_target.comms_data
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
	if isAllowedTo(ctd.services.preorder) then
		addCommsReply("Expedite Dock",function()
			if comms_source.expedite_dock == nil then
				comms_source.expedite_dock = false
			end
			if comms_source.expedite_dock then
				--handle expedite request already present
				local existing_expedite = "Docking crew is standing by"
				if comms_target == comms_source.expedite_dock_station then
					existing_expedite = existing_expedite .. ". Current preorders:"
					local preorders_identified = false
					if comms_source.preorder_hvli ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   HVLIs: %i",comms_source.preorder_hvli)
					end
					if comms_source.preorder_homing ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Homings: %i",comms_source.preorder_homing)						
					end
					if comms_source.preorder_mine ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Mines: %i",comms_source.preorder_mine)						
					end
					if comms_source.preorder_emp ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   EMPs: %i",comms_source.preorder_emp)						
					end
					if comms_source.preorder_nuke ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Nukes: %i",comms_source.preorder_nuke)						
					end
					if comms_source.preorder_repair_crew ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   One repair crew"						
					end
					if comms_source.preorder_coolant ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   Coolant"						
					end
					if preorders_identified then
						existing_expedite = existing_expedite .. "\nWould you like to preorder anything else?"
					else
						existing_expedite = existing_expedite .. " none.\nWould you like to preorder anything?"						
					end
					preorder_message = existing_expedite
					preOrderOrdnance()
				else
					existing_expedite = existing_expedite .. string.format(" on station %s (not this station, %s).",comms_source.expedite_dock_station:getCallSign(),comms_target:getCallSign())
					setCommsMessage(existing_expedite)
				end
				addCommsReply("Back",commsStation)
			else
				setCommsMessage("If you would like to speed up the addition of resources such as energy, ordnance, etc., please provide a time frame for your arrival. A docking crew will stand by until that time, after which they will return to their normal duties")
				preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
				addCommsReply("One minute (5 rep)", function()
					if comms_source:takeReputationPoints(5) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 60
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Two minutes (10 Rep)", function()
					if comms_source:takeReputationPoints(10) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 120
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Three minutes (15 Rep)", function()
					if comms_source:takeReputationPoints(15) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 180
						preOrderOrdnance()
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
	end	
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
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Nuke"
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   EMP"
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Homing"
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   Mine"
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. "\n   HVLI"
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = "We have no ordnance available for restock"
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = "We have the following type of ordnance available for restock:" .. ordnanceListMsg
			else
				ordnanceListMsg = "We have the following types of ordnance available for restock:" .. ordnanceListMsg
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply("Back", commsStation)
		end)
		local goodsAvailable = false
		if ctd.goods ~= nil then
			for good, goodData in pairs(ctd.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply("What goods do you have available for sale or trade?", function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("Where can I find particular goods?", function()
			local ctd = comms_target.comms_data
			gkMsg = "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury."
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#humanStationList do
					local station = humanStationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						for good, goodData in pairs(station.comms_data.goods) do
							if random(1,100) <= brainCheckChance then
								local stationCallSign = station:getCallSign()
								local stationSector = station:getSectorName()
								ctd.goodsKnowledge[good] =	{	station = stationCallSign,
																sector = stationSector,
																cost = goodData["cost"] }
								knowledgeCount = knowledgeCount + 1
								if knowledgeCount >= knowledgeMax then
									break
								end
							end
						end
					end
					if knowledgeCount >= knowledgeMax then
						break
					end
				end
			end
			local goodsKnowledgeCount = 0
			for good, goodKnowledge in pairs(ctd.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local ctd = comms_target.comms_data
					local stationName = ctd.goodsKnowledge[good]["station"]
					local sectorName = ctd.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = ctd.goodsKnowledge[good]["cost"]
					setCommsMessage(string.format("Station %s in sector %s has %s for %i reputation",stationName,sectorName,goodName,goodCost))
					addCommsReply("Back", commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. "\n\nWhat goods are you interested in?\nI've heard about these:"
			else
				gkMsg = gkMsg .. " Beyond that, I have no knowledge of specific stations"
			end
			setCommsMessage(gkMsg)
			addCommsReply("Back", commsStation)
		end)
		if ctd.public_relations then
			addCommsReply("Tell me more about your station", function()
				setCommsMessage("What would you like to know?")
				addCommsReply("General information", function()
					setCommsMessage(ctd.general_information)
					addCommsReply("Back", commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply("Station history", function()
						setCommsMessage(ctd.history)
						addCommsReply("Back", commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if ctd.gossip ~= nil then
						if random(1,100) < 50 then
							addCommsReply("Gossip", function()
								setCommsMessage(ctd.gossip)
								addCommsReply("Back", commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if ctd.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
				addCommsReply(string.format("Tell me about %s",ctd.character), function()
					if ctd.characterDescription ~= nil then
						setCommsMessage(ctd.characterDescription)
					else
						if ctd.characterDeadEnd == nil then
							local deadEndChoice = math.random(1,5)
							if deadEndChoice == 1 then
								ctd.characterDeadEnd = "Never heard of " .. ctd.character
							elseif deadEndChoice == 2 then
								ctd.characterDeadEnd = ctd.character .. " died last week. The funeral was yesterday"
							elseif deadEndChoice == 3 then
								ctd.characterDeadEnd = string.format("%s? Who's %s? There's nobody here named %s",ctd.character,ctd.character,ctd.character)
							elseif deadEndChoice == 4 then
								ctd.characterDeadEnd = string.format("We don't talk about %s. They are gone and good riddance",ctd.character)
							else
								ctd.characterDeadEnd = string.format("I think %s moved away",ctd.character)
							end
						end
						setCommsMessage(ctd.characterDeadEnd)
					end
				end)
			end
		end
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
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
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
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if treaty then
							local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
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
								if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
									local ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
									ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
									table.insert(friendlyHelperFleet,ship)
									setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at WP" .. n);
								else
									setCommsMessage("Not enough reputation!");
								end
							end
							tempAsteroid:destroy()
						else
							if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
								ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
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
function preOrderOrdnance()
	setCommsMessage(preorder_message)
	local ctd = comms_target.comms_data
	local hvli_count = math.floor(comms_source:getWeaponStorageMax("HVLI") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("HVLI")
	if ctd.weapon_available.HVLI and isAllowedTo(ctd.weapons["HVLI"]) and hvli_count > 0 then
		local hvli_prompt = ""
		local hvli_cost = getWeaponCost("HVLI")
		if hvli_count > 1 then
			hvli_prompt = string.format("%i HVLIs * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		else
			hvli_prompt = string.format("%i HVLI * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		end
		addCommsReply(hvli_prompt,function()
			if comms_source:takeReputationPoints(hvli_count*hvli_cost) then
				comms_source.preorder_hvli = hvli_count
				if hvli_count > 1 then
					setCommsMessage(string.format("%i HVLIs preordered",hvli_count))
				else
					setCommsMessage(string.format("%i HVLI preordered",hvli_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local homing_count = math.floor(comms_source:getWeaponStorageMax("Homing") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Homing")
	if ctd.weapon_available.Homing and isAllowedTo(ctd.weapons["Homing"]) and homing_count > 0 then
		local homing_prompt = ""
		local homing_cost = getWeaponCost("Homing")
		if homing_count > 1 then
			homing_prompt = string.format("%i Homings * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		else
			homing_prompt = string.format("%i Homing * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		end
		addCommsReply(homing_prompt,function()
			if comms_source:takeReputationPoints(homing_count*homing_cost) then
				comms_source.preorder_homing = homing_count
				if homing_count > 1 then
					setCommsMessage(string.format("%i Homings preordered",homing_count))
				else
					setCommsMessage(string.format("%i Homing preordered",homing_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local mine_count = math.floor(comms_source:getWeaponStorageMax("Mine") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Mine")
	if ctd.weapon_available.Mine and isAllowedTo(ctd.weapons["Mine"]) and mine_count > 0 then
		local mine_prompt = ""
		local mine_cost = getWeaponCost("Mine")
		if mine_count > 1 then
			mine_prompt = string.format("%i Mines * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		else
			mine_prompt = string.format("%i Mine * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		end
		addCommsReply(mine_prompt,function()
			if comms_source:takeReputationPoints(mine_count*mine_cost) then
				comms_source.preorder_mine = mine_count
				if mine_count > 1 then
					setCommsMessage(string.format("%i Mines preordered",mine_count))
				else
					setCommsMessage(string.format("%i Mine preordered",mine_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local emp_count = math.floor(comms_source:getWeaponStorageMax("EMP") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("EMP")
	if ctd.weapon_available.EMP and isAllowedTo(ctd.weapons["EMP"]) and emp_count > 0 then
		local emp_prompt = ""
		local emp_cost = getWeaponCost("EMP")
		if emp_count > 1 then
			emp_prompt = string.format("%i EMPs * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		else
			emp_prompt = string.format("%i EMP * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		end
		addCommsReply(emp_prompt,function()
			if comms_source:takeReputationPoints(emp_count*emp_cost) then
				comms_source.preorder_emp = emp_count
				if emp_count > 1 then
					setCommsMessage(string.format("%i EMPs preordered",emp_count))
				else
					setCommsMessage(string.format("%i EMP preordered",emp_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	local nuke_count = math.floor(comms_source:getWeaponStorageMax("Nuke") * ctd.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Nuke")
	if ctd.weapon_available.Nuke and isAllowedTo(ctd.weapons["Nuke"]) and nuke_count > 0 then
		local nuke_prompt = ""
		local nuke_cost = getWeaponCost("Nuke")
		if nuke_count > 1 then
			nuke_prompt = string.format("%i Nukes * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		else
			nuke_prompt = string.format("%i Nuke * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		end
		addCommsReply(nuke_prompt,function()
			if comms_source:takeReputationPoints(nuke_count*nuke_cost) then
				comms_source.preorder_nuke = nuke_count
				if nuke_count > 1 then
					setCommsMessage(string.format("%i Nukes preordered",nuke_count))
				else
					setCommsMessage(string.format("%i Nuke preordered",nuke_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",preOrderOrdnance)
		end)
	end
	if comms_source.preorder_repair_crew == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
					hireCost = math.random(30,60)
				else
					hireCost = math.random(45,90)
				end
				addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
					if not comms_source:takeReputationPoints(hireCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source.preorder_repair_crew = 1
						setCommsMessage("Repair crew hired on your behalf. They will board when you dock")
					end				
					preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
					addCommsReply("Back",preOrderOrdnance)
				end)
			end
		end
	end
	if comms_source.preorder_coolant == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source.initialCoolant ~= nil then
					local coolant_cost = math.random(45,90)
					if comms_source:getMaxCoolant() < comms_source.initialCoolant then
						coolant_cost = math.random(30,60)
					end
					addCommsReply(string.format("Set aside coolant for %i reputation",coolant_cost), function()
						if comms_source:takeReputationPoints(coolant_cost) then
							comms_source.preorder_coolant = 2
							setCommsMessage("Coolant set aside for you. It will be loaded when you dock")
						else
							setCommsMessage("Insufficient reputation")
						end
						preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
						addCommsReply("Back",preOrderOrdnance)
					end)
				end
			end
		end
	end
end
function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
    return math.ceil(comms_data.service_cost[service])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
------------------------
-- Ship communication --
------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		comms_data.goods = {}
		comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
		local shipType = comms_target:getTypeName()
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				repeat
					comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
					local goodCount = 0
					for good, goodData in pairs(comms_data.goods) do
						goodCount = goodCount + 1
					end
				until(goodCount >= 3)
			end
		end
	end
	setPlayers()
	if comms_source:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
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
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					if treaty then
						local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
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
							comms_target:orderDefendLocation(comms_source:getWaypoint(n))
							setCommsMessage("We are heading to assist at WP" .. n ..".");
						end
						tempAsteroid:destroy()
					else
						comms_target:orderDefendLocation(comms_source:getWaypoint(n))
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
			comms_target:orderDefendTarget(comms_source)
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
	if comms_target.fleet ~= nil and initialAssetsEvaluated then
		addCommsReply(string.format("Direct %s",comms_target.fleet), function()
			setCommsMessage(string.format("What command should be given to %s?",comms_target.fleet))
			addCommsReply("Report hull and shield status", function()
				msg = "Fleet status:"
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
						msg = msg .. "\n    Hull: " .. math.floor(fleetShip:getHull() / fleetShip:getHullMax() * 100) .. "%"
						local shields = fleetShip:getShieldCount()
						if shields == 1 then
							msg = msg .. "\n    Shield: " .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "%"
						else
							msg = msg .. "\n    Shields: "
							if shields == 2 then
								msg = msg .. "Front:" .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "% Rear:" .. math.floor(fleetShip:getShieldLevel(1) / fleetShip:getShieldMax(1) * 100) .. "%"
							else
								for n=0,shields-1 do
									msg = msg .. " " .. n .. ":" .. math.floor(fleetShip:getShieldLevel(n) / fleetShip:getShieldMax(n) * 100) .. "%"
								end
							end
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Report missile status", function()
				msg = "Fleet missile status:"
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
						local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
						missileMsg = ""
						for _, missile_type in ipairs(missile_types) do
							if fleetShip:getWeaponStorageMax(missile_type) > 0 then
								missileMsg = missileMsg .. "\n      " .. missile_type .. ": " .. math.floor(fleetShip:getWeaponStorage(missile_type)) .. "/" .. math.floor(fleetShip:getWeaponStorageMax(missile_type))
							end
						end
						if missileMsg ~= "" then
							msg = msg .. "\n    Missiles: " .. missileMsg
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Assist me", function()
				for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
					if fleetShip ~= nil and fleetShip:isValid() then
						fleetShip:orderDefendTarget(comms_source)
					end
				end
				setCommsMessage(string.format("%s heading toward you to assist",comms_target.fleet))
				addCommsReply("Back", commsShip)
			end)
			addCommsReply("Defend a waypoint", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", commsShip)
				else
					setCommsMessage("Which waypoint should we defend?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Defend WP" .. n, function()
							if treaty then
								local tempAsteroid = VisualAsteroid():setPosition(comms_source:getWaypoint(n))
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
									for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
										if fleetShip ~= nil and fleetShip:isValid() then
											fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
										end
									end
									setCommsMessage("We are heading to assist at WP" .. n ..".");
								end
								tempAsteroid:destroy()
							else
								for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
									if fleetShip ~= nil and fleetShip:isValid() then
										fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage("We are heading to assist at WP" .. n ..".");
							end
							addCommsReply("Back", commsShip)
						end)
					end
				end
			end)
			if not treaty and limitedWarTimer <= 0 then
				addCommsReply("Go offensive, attack all enemy targets", function()
					for _, fleetShip in ipairs(friendlyDefensiveFleetList[comms_target.fleet]) do
						if fleetShip ~= nil and fleetShip:isValid() then
							fleetShip:orderRoaming()
						end
					end
					setCommsMessage(string.format("%s is on an offensive rampage",comms_target.fleet))
					addCommsReply("Back", commsShip)
				end)
			end
		end)
	end
	if shipCommsDiagnostic then print("done with fleet buttons") end
	local shipType = comms_target:getTypeName()
	if shipCommsDiagnostic then print("got ship type") end
	if shipType:find("Freighter") ~= nil then
		if shipCommsDiagnostic then print("it's a freighter") end
		if distance(comms_source, comms_target) < 5000 then
			if shipCommsDiagnostic then print("close enough to trade or sell") end
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				addCommsReply("Jettison cargo", function()
					setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format("One %s jettisoned",good))
								addCommsReply("Back", commsShip)
							end)
						end
					end
					addCommsReply("Back", commsShip)
				end)
			end
			if comms_data.friendlyness > 66 then
				if shipCommsDiagnostic then print("friendliest branch") end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if shipCommsDiagnostic then print("goods or equipment freighter") end
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						if shipCommsDiagnostic then print("player has luxury to trade") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter goods loop") end
							if goodData.quantity > 0 and good ~= "luxury" then
								if shipCommsDiagnostic then print("has something other than luxury") end
								addCommsReply(string.format("Trade luxury for %s",good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format("Traded your luxury for %s from %s",good,comms_target:getCallSign()))
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room to purchase") end
					for good, goodData in pairs(comms_data.goods) do
						if shipCommsDiagnostic then print("in freighter goods loop") end
						if goodData.quantity > 0 then
							if shipCommsDiagnostic then print("found something to sell") end
							addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
								if comms_source:takeReputationPoints(goodData.cost) then
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.cargo = comms_source.cargo - 1
									setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
								else
									setCommsMessage("Insufficient reputation for purchase")
								end
								addCommsReply("Back", commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if shipCommsDiagnostic then print("average frienliness branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room to purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment type freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("Found something to sell") end
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						if shipCommsDiagnostic then print("not a goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end
				end	--player has room for cargo branch
			else	--least friendly
				if shipCommsDiagnostic then print("least friendly branch") end
				if comms_source.cargo > 0 then
					if shipCommsDiagnostic then print("player has room for purchase") end
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						if shipCommsDiagnostic then print("goods or equipment freighter") end
						for good, goodData in pairs(comms_data.goods) do
							if shipCommsDiagnostic then print("in freighter cargo loop") end
							if goodData.quantity > 0 then
								if shipCommsDiagnostic then print("found something to sell") end
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			addCommsReply("Do you have cargo you might sell?", function()
				local goodCount = 0
				local cargoMsg = "We've got "
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						if goodCount > 0 then
							cargoMsg = cargoMsg .. ", " .. good
						else
							cargoMsg = cargoMsg .. good
						end
					end
					goodCount = goodCount + goodData.quantity
				end
				if goodCount == 0 then
					cargoMsg = cargoMsg .. "nothing"
				end
				setCommsMessage(cargoMsg)
				addCommsReply("Back", commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		if faction == "Kraylor" then
			taunt_threshold = 35
			immolation_threshold = 6
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
			taunt_threshold = 25
			immolation_threshold = 4
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		elseif faction == "TSN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage("State your business")
		elseif faction == "USN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage("What do you want? (not that we care)")
		elseif faction == "CUF" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage("Don't waste our time")
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then
				local current_order = comms_target:getOrder()
				print("order: " .. current_order)
				--Possible order strings returned:
				--Roaming
				--Fly towards
				--Attack
				--Stand Ground
				--Idle
				--Defend Location
				--Defend Target
				--Fly Formation (?)
				--Fly towards (ignore all)
				--Dock
				if comms_target.original_order == nil then
					comms_target.original_faction = faction
					comms_target.original_order = current_order
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					comms_target.taunt_may_expire = true	--change to conditional in future refactoring
					table.insert(enemy_reverts,comms_target)
				end
				comms_target:orderAttack(comms_source)	--consider alternative options besides attack in future refactoring
				setCommsMessage(taunt_success_reply);
			else
				--possible alternative consequences when taunt fails
				if random(1,100) < (immolation_threshold + difficulty) then	--final: immolation_threshold (set to 100 for testing)
					setCommsMessage("Subspace and time continuum disruption authorized")
					comms_source.continuum_target = true
					comms_source.continuum_initiator = comms_target
					plotContinuum = checkContinuum
				else
					setCommsMessage(taunt_failed_reply);
				end
			end
		end)
		tauntable = true
	end
	local enemy_health = getEnemyHealth(comms_target)
	if change_enemy_order_diagnostic then print(string.format("   enemy health:    %.2f",enemy_health)) end
	if change_enemy_order_diagnostic then print(string.format("   friendliness:    %.1f",comms_data.friendlyness)) end
	if comms_data.friendlyness >= 66 or enemy_health < .5 then	--final: 66, .5
		--amenable logic
		local amenable_chance = comms_data.friendlyness/3 + (1 - enemy_health)*30
		if change_enemy_order_diagnostic then print(string.format("   amenability:     %.1f",amenable_chance)) end
		addCommsReply("Stop your actions",function()
			local amenable_roll = random(1,100)
			if change_enemy_order_diagnostic then print(string.format("   amenable roll:   %.1f",amenable_roll)) end
			if amenable_roll < amenable_chance then
				local current_order = comms_target:getOrder()
				if comms_target.original_order == nil then
					comms_target.original_order = current_order
					comms_target.original_faction = faction
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					table.insert(enemy_reverts,comms_target)
				end
				comms_target.amenability_may_expire = true		--set up conditional in future refactoring
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage("Just this once, we'll take your advice")
			else
				setCommsMessage("No")
			end
		end)
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		amenable = true
	end
	if tauntable or amenable then
		return true
	else
		return false
	end
end
function getEnemyHealth(enemy)
	local enemy_health = 0
	local enemy_shield = 0
	local enemy_shield_count = enemy:getShieldCount()
	local faction = enemy:getFaction()
	if change_enemy_order_diagnostic then print(string.format("%s statistics:",enemy:getCallSign())) end
	if change_enemy_order_diagnostic then print(string.format("   shield count:    %i",enemy_shield_count)) end
	if enemy_shield_count > 0 then
		local total_shield_level = 0
		local max_shield_level = 0
		for i=1,enemy_shield_count do
			total_shield_level = total_shield_level + enemy:getShieldLevel(i-1)
			max_shield_level = max_shield_level + enemy:getShieldMax(i-1)
		end
		enemy_shield = total_shield_level/max_shield_level
	else
		enemy_shield = 1
	end
	if change_enemy_order_diagnostic then print(string.format("   shield health:   %.1f",enemy_shield)) end
	local enemy_hull = enemy:getHull()/enemy:getHullMax()
	if change_enemy_order_diagnostic then print(string.format("   hull health:     %.1f",enemy_hull)) end
	local enemy_reactor = enemy:getSystemHealth("reactor")
	if change_enemy_order_diagnostic then print(string.format("   reactor health:  %.1f",enemy_reactor)) end
	local enemy_maneuver = enemy:getSystemHealth("maneuver")
	if change_enemy_order_diagnostic then print(string.format("   maneuver health: %.1f",enemy_maneuver)) end
	local enemy_impulse = enemy:getSystemHealth("impulse")
	if change_enemy_order_diagnostic then print(string.format("   impulse health:  %.1f",enemy_impulse)) end
	local enemy_beam = 0
	if enemy:getBeamWeaponRange(0) > 0 then
		enemy_beam = enemy:getSystemHealth("beamweapons")
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f",enemy_beam)) end
	else
		enemy_beam = 1
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f (no beams)",enemy_beam)) end
	end
	local enemy_missile = 0
	if enemy:getWeaponTubeCount() > 0 then
		enemy_missile = enemy:getSystemHealth("missilesystem")
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f",enemy_missile)) end
	else
		enemy_missile = 1
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f (no missile system)",enemy_missile)) end
	end
	local enemy_warp = 0
	if enemy:hasWarpDrive() then
		enemy_warp = enemy:getSystemHealth("warp")
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f",enemy_warp)) end
	else
		enemy_warp = 1
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f (no warp drive)",enemy_warp)) end
	end
	local enemy_jump = 0
	if enemy:hasJumpDrive() then
		enemy_jump = enemy:getSystemHealth("jumpdrive")
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f",enemy_jump)) end
	else
		enemy_jump = 1
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f (no jump drive)",enemy_jump)) end
	end
	if change_enemy_order_diagnostic then print(string.format("   faction:         %s",faction)) end
	if faction == "Kraylor" then
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .03	+
			enemy_jump		* .03
	elseif faction == "Arlenians" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .45	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .04	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .02	+
			enemy_jump		* .02	
	elseif faction == "Exuari" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .2 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "Ghosts" then
		enemy_health = 
			enemy_shield 	* .25	+
			enemy_hull		* .25	+
			enemy_reactor	* .25 	+
			enemy_maneuver	* .04	+
			enemy_impulse	* .05	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .04	+
			enemy_jump		* .04	
	elseif faction == "Ktlitans" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .1	+
			enemy_jump		* .1	
	elseif faction == "TSN" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .35	+
			enemy_reactor	* .08 	+
			enemy_maneuver	* .01	+
			enemy_impulse	* .02	+
			enemy_beam		* .02	+
			enemy_missile	* .01	+
			enemy_warp		* .08	+
			enemy_jump		* .08	
	elseif faction == "USN" then
		enemy_health = 
			enemy_shield 	* .38	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .02	+
			enemy_impulse	* .03	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "CUF" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .06	+
			enemy_jump		* .04	
	else
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .06 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .05	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	end
	return enemy_health
end
function revertWait(delta)
	revert_timer = revert_timer - delta
	if revert_timer < 0 then
		revert_timer = delta + revert_timer_interval
		plotRevert = revertCheck
	end
end
function revertCheck(delta)
	if enemy_reverts ~= nil then
		for _, enemy in ipairs(enemy_reverts) do
			if enemy ~= nil and enemy:isValid() then
				local expiration_chance = 0
				local enemy_faction = enemy:getFaction()
				if enemy.taunt_may_expire then
					if enemy_faction == "Kraylor" then
						expiration_chance = 4.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 7
					elseif enemy_faction == "Exuari" then
						expiration_chance = 2.5
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 8.5
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 5.5
					elseif enemy_faction == "TSN" then
						expiration_chance = 3
					elseif enemy_faction == "USN" then
						expiration_chance = 3.5
					elseif enemy_faction == "CUF" then
						expiration_chance = 4
					else
						expiration_chance = 6
					end
				elseif enemy.amenability_may_expire then
					local enemy_health = getEnemyHealth(enemy)
					if enemy_faction == "Kraylor" then
						expiration_chance = 2.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 3.25
					elseif enemy_faction == "Exuari" then
						expiration_chance = 6.6
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 3.2
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 4.8
					elseif enemy_faction == "TSN" then
						expiration_chance = 3.5
					elseif enemy_faction == "USN" then
						expiration_chance = 2.8
					elseif enemy_faction == "CUF" then
						expiration_chance = 3
					else
						expiration_chance = 4
					end
					expiration_chance = expiration_chance + enemy_health*5
				end
				local expiration_roll = random(1,100)
				if expiration_roll < expiration_chance then
					local oo = enemy.original_order
					local otx = enemy.original_target_x
					local oty = enemy.original_target_y
					local ot = enemy.original_target
					if oo ~= nil then
						if oo == "Attack" then
							if ot ~= nil and ot:isValid() then
								enemy:orderAttack(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Dock" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDock(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Target" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDefendTarget(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowards(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Location" then
							if otx ~= nil and oty ~= nil then
								enemy:orderDefendLocation(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards (ignore all)" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowardsBlind(otx,oty)
							else
								enemy:orderRoaming()
							end
						else
							enemy:orderRoaming()
						end
					else
						enemy:orderRoaming()
					end
					if enemy.original_faction ~= nil then
						enemy:setFaction(enemy.original_faction)
					end
					enemy.taunt_may_expire = false
					enemy.amenability_may_expire = false
				end
			end
		end
	end
	plotRevert = revertWait
end
function checkContinuum(delta)
	local continuum_count = 0
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.continuum_target then
				continuum_count = continuum_count + 1
				if p.continuum_timer == nil then
					p.continuum_timer = delta + 30
				end
				p.continuum_timer = p.continuum_timer - delta
				if p.continuum_timer < 0 then
					if p.continuum_initiator ~= nil and p.continuum_initiator:isValid() then
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("frontshield",(p:getSystemHealth("frontshield") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("rearshield",(p:getSystemHealth("rearshield") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("reactor",(p:getSystemHealth("reactor") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("maneuver",(p:getSystemHealth("maneuver") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("impulse",(p:getSystemHealth("impulse") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("beamweapons",(p:getSystemHealth("beamweapons") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("missilesystem",(p:getSystemHealth("missilesystem") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("warp",(p:getSystemHealth("warp") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("jumpdrive",(p:getSystemHealth("jumpdrive") - 1)/2) end
						local ex, ey = p.continuum_initiator:getPosition()
						p.continuum_initiator:destroy()
						ExplosionEffect():setPosition(ex,ey):setSize(3000)
						resetContinuum(p)
					else
						resetContinuum(p)
					end
				else
					local timer_display = string.format("Disruption %i",math.floor(p.continuum_timer))
					if p:hasPlayerAtPosition("Relay") then
						p.continuum_timer_display = "continuum_timer_display"
						p:addCustomInfo("Relay",p.continuum_timer_display,timer_display)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.continuum_timer_display_ops = "continuum_timer_display_ops"
						p:addCustomInfo("Operations",p.continuum_timer_display_ops,timer_display)
					end
				end
			else
				resetContinuum(p)
			end
		end
	end
end
function resetContinuum(p)
	p.continuum_target = nil
	p.continuum_timer = nil
	p.continuum_initiator = nil
	if p.continuum_timer_display ~= nil then
		p:removeCustom("Relay",p.continuum_timer_display)
		p.continuum_timer_display = nil
	end
	if p.continuum_timer_display_ops ~= nil then
		p:removeCustom("Operations",p.continuum_timer_display_ops)
		p.continuum_timer_display_ops = nil
	end
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage("Yes?")
		addCommsReply("Do you have cargo you might sell?", function()
			local goodCount = 0
			local cargoMsg = "We've got "
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. ", " .. good
					else
						cargoMsg = cargoMsg .. good
					end
				end
				goodCount = goodCount + goodData.quantity
			end
			if goodCount == 0 then
				cargoMsg = cargoMsg .. "nothing"
			end
			setCommsMessage(cargoMsg)
		end)
		if distance(comms_source,comms_target) < 5000 then
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
				end
			end
			if goodCount > 0 then
				addCommsReply("Jettison cargo", function()
					setCommsMessage(string.format("Available space: %i\nWhat would you like to jettison?",comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format("One %s jettisoned",good))
								addCommsReply("Back", commsShip)
							end)
						end
					end
					addCommsReply("Back", commsShip)
				end)
			end
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				elseif comms_data.friendlyness > 33 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				else	--least friendly
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
										goodData.quantity = goodData.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										comms_source.cargo = comms_source.cargo - 1
										setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
									else
										setCommsMessage("Insufficient reputation for purchase")
									end
									addCommsReply("Back", commsShip)
								end)
							end
						end	--freighter goods loop
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
-----------------------
-- Utility functions --
-----------------------
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
        Asteroid():setPosition(x, y):setSize(asteroid_size)
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
function createRandomAsteroidAlongArc(amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of asteroids along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAsteroidAlongArc(100, 500, 3000, 65, 120, 450)
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
    local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
		end
	end
end
function placeRandomListAroundPoint(object_type, amount, dist_min, dist_max, x0, y0)
-- create amount of object_type, at a distance between dist_min and dist_max around the point (x0, y0) 
-- save in a list that is returned to caller
	local object_list = {}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        table.insert(object_list,object_type():setPosition(x, y))
    end
    return object_list
end
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
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
function nearStations(nobj, compareStationList)
--nobj = named object for comparison purposes (stations, players, etc)
--compareStationList = list of stations to compare against
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
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * difficulty * playerPower(),5)
	end
	local enemyPosition = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	local enemyList = {}
	local prefix = generateCallSignPrefix(1)
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
		ship:setCallSign(generateCallSign(nil,enemyFaction))
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
function playerPower()
--evaluate the players for enemy strength and size spawning purposes
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
function setPlayers()
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
	concurrentPlayerCount = 0
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if pobj.goods == nil then
				pobj.goods = {}
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
					if pobj:getImpulseMaxSpeed() == 45 then
						pobj:setImpulseMaxSpeed(90)
					end
					if pobj:getBeamWeaponCycleTime(0) == 6 then
						local bi = 0
						repeat
							local tempArc = pobj:getBeamWeaponArc(bi)
							local tempDir = pobj:getBeamWeaponDirection(bi)
							local tempRng = pobj:getBeamWeaponRange(bi)
							local tempDmg = pobj:getBeamWeaponDamage(bi)
							pobj:setBeamWeapon(bi,tempArc,tempDir,tempRng,5,tempDmg)
							bi = bi + 1
						until(pobj:getBeamWeaponRange(bi) < 1)
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
				elseif tempPlayerType == "Proto-Atlantis" then
					if #playerShipNamesForProtoAtlantis > 0 then
						ni = math.random(1,#playerShipNamesForProtoAtlantis)
						pobj:setCallSign(playerShipNamesForProtoAtlantis[ni])
						table.remove(playerShipNamesForProtoAtlantis,ni)
					end
					pobj.shipScore = 40
					pobj.maxCargo = 4
				elseif tempPlayerType == "Maverick" then
					if #playerShipNamesForMaverick > 0 then
						ni = math.random(1,#playerShipNamesForMaverick)
						pobj:setCallSign(playerShipNamesForMaverick[ni])
						table.remove(playerShipNamesForMaverick,ni)
					end
					pobj.shipScore = 45
					pobj.maxCargo = 5
				elseif tempPlayerType == "Crucible" then
					if #playerShipNamesForCrucible > 0 then
						ni = math.random(1,#playerShipNamesForCrucible)
						pobj:setCallSign(playerShipNamesForCrucible[ni])
						table.remove(playerShipNamesForCrucible,ni)
					end
					pobj.shipScore = 45
					pobj.maxCargo = 5
				elseif tempPlayerType == "Atlantis II" then
					if #playerShipNamesForAtlantisII > 0 then
						ni = math.random(1,#playerShipNamesForAtlantisII)
						pobj:setCallSign(playerShipNamesForAtlantisII[ni])
						table.remove(playerShipNamesForAtlantisII,ni)
					end
					pobj.shipScore = 60
					pobj.maxCargo = 5
				elseif tempPlayerType == "Surkov" then
					if #playerShipNamesForSurkov > 0 then
						ni = math.random(1,#playerShipNamesForSurkov)
						pobj:setCallSign(playerShipNamesForSurkov[ni])
						table.remove(playerShipNamesForSurkov,ni)
					end
					pobj.shipScore = 35
					pobj.maxCargo = 6
				elseif tempPlayerType == "Stricken" then
					if #playerShipNamesForStricken > 0 then
						ni = math.random(1,#playerShipNamesForStricken)
						pobj:setCallSign(playerShipNamesForStricken[ni])
						table.remove(playerShipNamesForStricken,ni)
					end
					pobj.shipScore = 40
					pobj.maxCargo = 4
				elseif tempPlayerType == "Redhook" then
					if #playerShipNamesForRedhook > 0 then
						ni = math.random(1,#playerShipNamesForRedhook)
						pobj:setCallSign(playerShipNamesForRedhook[ni])
						table.remove(playerShipNamesForRedhook,ni)
					end
					pobj.shipScore = 18
					pobj.maxCargo = 8
				elseif tempPlayerType == "Destroyer III" then
					if #playerShipNamesForDestroyerIII > 0 then
						ni = math.random(1,#playerShipNamesForDestroyerIII)
						pobj:setCallSign(playerShipNamesForDestroyerIII[ni])
						table.remove(playerShipNamesForDestroyerIII,ni)
					end
					pobj.shipScore = 25
					pobj.maxCargo = 7
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
			pobj.initialCoolant = pobj:getMaxCoolant()
		end
	end
end
function expediteDockCheck(delta)
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.expedite_dock then
				if p.expedite_dock_timer == nil then
					p.expedite_dock_timer = p.expedite_dock_timer_max + delta
				end
				p.expedite_dock_timer = p.expedite_dock_timer - delta
				if p.expedite_dock_timer < 0 then
					if p.expedite_dock_timer < -1 then
						if p.expedite_dock_timer_info ~= nil then
							p:removeCustom(p.expedite_dock_timer_info)
							p.expedite_dock_timer_info = nil
						end
						if p.expedite_dock_timer_info_ops ~= nil then
							p:removeCustom(p.expedite_dock_timer_info_ops)
							p.expedite_dock_timer_info_ops = nil
						end
						p.expedite_dock = nil
						p:addToShipLog(string.format("Docking crew of station %s returned to their normal duties",p.expedite_doc_station:getCallSign()),"Yellow")
						p.expedite_timer = nil
						p.expedite_dock_station = nil
						p.preorder_hvli = nil
						p.preorder_homing = nil
						p.preorder_emp = nil
						p.preorder_nuke = nil
						p.preorder_repair_crew = nil
						p.preorder_coolant = nil
					else
						if p:hasPlayerAtPosition("Relay") then
							p.expedite_dock_timer_info = "expedite_dock_timer_info"
							p:addCustomInfo("Relay",p.expedite_dock_timer_info,"Fast Dock Expired")						
						end
						if p:hasPlayerAtPosition("Operations") then
							p.expedite_dock_timer_info_ops = "expedite_dock_timer_info_ops"
							p:addCustomInfo("Relay",p.expedite_dock_timer_info_ops,"Fast Dock Expired")						
						end
					end
				else	--timer not expired
					local expedite_dock_timer_status = "Fast Dock"
					local expedite_dock_timer_minutes = math.floor(p.expedite_dock_timer / 60)
					local expedite_dock_timer_seconds = math.floor(p.expedite_dock_timer % 60)
					if expedite_dock_timer_minutes <= 0 then
						expedite_dock_timer_status = string.format("%s %i",expedite_dock_timer_status,expedite_dock_timer_seconds)
					else
						expedite_dock_timer_status = string.format("%s %i:%.2i",expedite_dock_timer_status,expedite_dock_timer_minutes,expedite_dock_timer_seconds)
					end
					if p:hasPlayerAtPosition("Relay") then
						p.expedite_dock_timer_info = "expedite_dock_timer_info"
						p:addCustomInfo("Relay",p.expedite_dock_timer_info,expedite_dock_timer_status)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.expedite_dock_timer_info_ops = "expedite_dock_timer_info_ops"
						p:addCustomInfo("Operations",p.expedite_dock_timer_info_ops,expedite_dock_timer_status)
					end					
				end
				if p.expedite_dock_station ~= nil and p.expedite_dock_station:isValid() then
					if p:isDocked(p.expedite_dock_station) then
						p:setEnergy(p:getMaxEnergy())
						p:setScanProbeCount(p:getMaxScanProbeCount())
						if p.preorder_hvli ~= nil then
							local new_amount = math.min(p:getWeaponStorage("HVLI") + p.preorder_hvli,p:getWeaponStorageMax("HVLI"))
							p:setWeaponStorage("HVLI",new_amount)
						end
						if p.preorder_homing ~= nil then
							new_amount = math.min(p:getWeaponStorage("Homing") + p.preorder_homing,p:getWeaponStorageMax("Homing"))
							p:setWeaponStorage("Homing",new_amount)
						end
						if p.preorder_mine ~= nil then
							new_amount = math.min(p:getWeaponStorage("Mine") + p.preorder_mine,p:getWeaponStorageMax("Mine"))
							p:setWeaponStorage("Mine",new_amount)
						end
						if p.preorder_emp ~= nil then
							new_amount = math.min(p:getWeaponStorage("EMP") + p.preorder_emp,p:getWeaponStorageMax("EMP"))
							p:setWeaponStorage("EMP",new_amount)
						end
						if p.preorder_nuke ~= nil then
							new_amount = math.min(p:getWeaponStorage("Nuke") + p.preorder_nuke,p:getWeaponStorageMax("Nuke"))
							p:setWeaponStorage("Nuke",new_amount)
						end
						if p.preorder_repair_crew ~= nil then
							p:setRepairCrewCount(p:getRepairCrewCount() + 1)
							resetPreviousSystemHealth(p)
						end
						if p.preorder_coolant ~= nil then
							p:setMaxCoolant(p:getMaxCoolant() + 2)
						end
						if p.expedite_dock_timer_info ~= nil then
							p:removeCustom(p.expedite_dock_timer_info)
							p.expedite_dock_timer_info = nil
						end
						if p.expedite_dock_timer_info_ops ~= nil then
							p:removeCustom(p.expedite_dock_timer_info_ops)
							p.expedite_dock_timer_info_ops = nil
						end
						p:addToShipLog(string.format("Docking crew at station %s completed replenishment as requested",p.expedite_dock_station:getCallSign()),"Yellow")
						p.expedite_dock = nil
						p.expedite_timer = nil
						p.expedite_dock_station = nil
						p.preorder_hvli = nil
						p.preorder_homing = nil
						p.preorder_emp = nil
						p.preorder_nuke = nil
						p.preorder_repair_crew = nil
						p.preorder_coolant = nil
					end
				end
			end

		end
	end
end
--		Mortal repair crew functions. Includes coolant loss as option to losing repair crew
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
				else	--no repair crew left
					if random(1,100) <= (4 - difficulty) then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,"Medical team has revived one of your repair crew")
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,"Medical team has revived one of your repair crew")
						end
						resetPreviousSystemHealth(p)
					end
				end
				if p.initialCoolant ~= nil then
					local current_coolant = p:getMaxCoolant()
					if current_coolant < 10 then
						if random(1,100) <= 4 then
							p:setMaxCoolant(current_coolant + ((current_coolant + 10)/2))
							if p:hasPlayerAtPosition("Engineering") then
								local coolant_recovery = "coolant_recovery"
								p:addCustomMessage("Engineering",coolant_recovery,"Automated systems have recovered some coolant")
							end
							if p:hasPlayerAtPosition("Engineering+") then
								local coolant_recovery_plus = "coolant_recovery_plus"
								p:addCustomMessage("Engineering+",coolant_recovery_plus,"Automated systems have recovered some coolant")
							end
							resetPreviousSystemHealth(p)
						end
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
		local friendlySurvivedCount, friendlySurvivedValue, fpct1, fpct2, enemySurvivedCount, enemySurvivedValue, epct1, epct2, neutralSurvivedCount, neutralSurvivedValue, npct1, npct2, friendlyShipSurvivedValue, fpct, enemyShipSurvivedValue, epct = listStatuses()
		if friendlySurvivedCount ~= nil then
			local evalFriendly = fpct2*friendlyStationComponentWeight + npct2*neutralStationComponentWeight + fpct*friendlyShipComponentWeight
			local evalEnemy = epct2*enemyStationComponentWeight + epct*enemyShipComponentWeight
			local eval_status = string.format("F:%.1f%% E:%.1f%% D:%.1f%%",evalFriendly,evalEnemy,evalFriendly-evalEnemy)
			for pidx=1,8 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if p:hasPlayerAtPosition("Relay") then
						p.eval_status = "eval_status"
						p:addCustomInfo("Relay",p.eval_status,eval_status)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.eval_status_operations = "eval_status_operations"
						p:addCustomInfo("Operations",p.eval_status_operations,eval_status)
					end
				end
			end
		end
	end
end
function resetPreviousSystemHealth(p)
	if p:getShieldCount() > 1 then
		p.prevShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		p.prevShield = p:getSystemHealth("frontshield")
	end
	p.prevReactor = p:getSystemHealth("reactor")
	p.prevManeuver = p:getSystemHealth("maneuver")
	p.prevImpulse = p:getSystemHealth("impulse")
	if p:getBeamWeaponRange(0) > 0 then
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if p:hasWarpDrive() then
		p.prevWarp = p:getSystemHealth("warp")
	end
	if p:hasJumpDrive() then
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		if p.initialCoolant == nil then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
			end
		else
			if random(1,100) < 50 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
				end
			else
				local current_coolant = p:getMaxCoolant()
				if current_coolant >= 10 then
					p:setMaxCoolant(p:getMaxCoolant()*.5)
				else
					p:setMaxCoolant(p:getMaxCoolant()*.8)
				end
				if p:hasPlayerAtPosition("Engineering") then
					local coolantLoss = "coolantLoss"
					p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
				end
			end
		end
	end
end
--      Inventory button and functions for relay/operations 
function cargoInventory(delta)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local cargoHoldEmpty = true
			if p.goods ~= nil then
				for good, quantity in pairs(p.goods) do
					if quantity ~= nil and quantity > 0 then
						cargoHoldEmpty = false
						break
					end
				end
			end
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
function cargoInventoryGivenShip(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local cargoHoldEmpty = true
	if p.goods ~= nil then
		for good, quantity in pairs(p.goods) do
			if quantity ~= nil and quantity > 0 then
				p:addToShipLog(string.format("     %s: %i",good,math.floor(quantity)),"Yellow")
				cargoHoldEmpty = false
			end
		end
	end
	if cargoHoldEmpty then
		p:addToShipLog("     Empty\n","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
end
function cargoInventory1()
	local p = getPlayerShip(1)
	cargoInventoryGivenShip(p)
end
function cargoInventory2()
	local p = getPlayerShip(2)
	cargoInventoryGivenShip(p)
end
function cargoInventory3()
	local p = getPlayerShip(3)
	cargoInventoryGivenShip(p)
end
function cargoInventory4()
	local p = getPlayerShip(4)
	cargoInventoryGivenShip(p)
end
function cargoInventory5()
	local p = getPlayerShip(5)
	cargoInventoryGivenShip(p)
end
function cargoInventory6()
	local p = getPlayerShip(6)
	cargoInventoryGivenShip(p)
end
function cargoInventory7()
	local p = getPlayerShip(7)
	cargoInventoryGivenShip(p)
end
function cargoInventory8()
	local p = getPlayerShip(8)
	cargoInventoryGivenShip(p)
end
--      Enable and disable auto-cooling on a ship functions
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
--		Gain or lose coolant from nebula functions
function coolantNebulae(delta)
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local inside_gain_coolant_nebula = false
			for i=1,#coolant_nebula do
				if distance(p,coolant_nebula[i]) < 5000 then
					if coolant_nebula[i].lose then
						p:setMaxCoolant(p:getMaxCoolant()*coolant_loss)
						if p:getMaxCoolant() > 50 and random(1,100) <= 13 then
							local engine_choice = math.random(1,3)
							if engine_choice == 1 then
								p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverseEffect)
							elseif engine_choice == 2 then
								if p:hasWarpDrive() then
									p:setSystemHealth("warp",p:getSystemHealth("warp")*adverseEffect)
								end
							else
								if p:hasJumpDrive() then
									p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverseEffect)
								end
							end
						end
					end
					if coolant_nebula[i].gain then
						inside_gain_coolant_nebula = true
					end
				end
			end
			if inside_gain_coolant_nebula then
				if p.get_coolant then
					if p.coolant_trigger then
						updateCoolantGivenPlayer(p, delta)
					end
				else
					if p:hasPlayerAtPosition("Engineering") then
						p.get_coolant_button = "get_coolant_button"
						p:addCustomButton("Engineering",p.get_coolant_button,"Get Coolant",get_coolant_function[pidx])
						p.get_coolant = true
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p.get_coolant_button_plus = "get_coolant_button_plus"
						p:addCustomButton("Engineering+",p.get_coolant_button_plus,"Get Coolant",get_coolant_function[pidx])
						p.get_coolant = true
					end
				end
			else
				p.get_coolant = false
				p.coolant_trigger = false
				p.configure_coolant_timer = nil
				p.deploy_coolant_timer = nil
				if p:hasPlayerAtPosition("Engineering") then
					if p.get_coolant_button ~= nil then
						p:removeCustom(p.get_coolant_button)
						p.get_coolant_button = nil
					end
					if p.gather_coolant ~= nil then
						p:removeCustom(p.gather_coolant)
						p.gather_coolant = nil
					end
				end
				if p:hasPlayerAtPosition("Engineering+") then
					if p.get_coolant_button_plus ~= nil then
						p:removeCustom(p.get_coolant_button_plus)
						p.get_coolant_button_plus = nil
					end
					if p.gather_coolant_plus ~= nil then
						p:removeCustom(p.gather_coolant_plus)
						p.gather_coolant_plus = nil
					end
				end
			end
		end
	end
end
function updateCoolantGivenPlayer(p, delta)
	if p.configure_coolant_timer == nil then
		p.configure_coolant_timer = delta + 5
	end
	p.configure_coolant_timer = p.configure_coolant_timer - delta
	if p.configure_coolant_timer < 0 then
		if p.deploy_coolant_timer == nil then
			p.deploy_coolant_timer = delta + 5
		end
		p.deploy_coolant_timer = p.deploy_coolant_timer - delta
		if p.deploy_coolant_timer < 0 then
			gather_coolant_status = "Gathering Coolant"
			p:setMaxCoolant(p:getMaxCoolant() + coolant_gain)
			if p:getMaxCoolant() > 50 and random(1,100) <= 13 then
				local engine_choice = math.random(1,3)
				if engine_choice == 1 then
					p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverseEffect)
				elseif engine_choice == 2 then
					if p:hasWarpDrive() then
						p:setSystemHealth("warp",p:getSystemHealth("warp")*adverseEffect)
					end
				else
					if p:hasJumpDrive() then
						p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverseEffect)
					end
				end
			end
		else
			gather_coolant_status = string.format("Deploying Collectors %i",math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format("Configuring Collectors %i",math.ceil(p.configure_coolant_timer - delta))
	end
	if p:hasPlayerAtPosition("Engineering") then
		p.gather_coolant = "gather_coolant"
		p:addCustomInfo("Engineering",p.gather_coolant,gather_coolant_status)
	end
	if p:hasPlayerAtPosition("Engineering+") then
		p.gather_coolant_plus = "gather_coolant_plus"
		p:addCustomInfo("Engineering",p.gather_coolant_plus,gather_coolant_status)
	end
end
function getCoolantGivenPlayer(p)
	if p:hasPlayerAtPosition("Engineering") then
		if p.get_coolant_button ~= nil then
			p:removeCustom(p.get_coolant_button)
			p.get_coolant_button = nil
		end
	end
	if p:hasPlayerAtPosition("Engineering+") then
		if p.get_coolant_button_plus ~= nil then
			p:removeCustom(p.get_coolant_button_plus)
			p.get_coolant_button_plus = nil
		end
	end
	p.coolant_trigger = true
end
function getCoolant1()
	local p = getPlayerShip(1)
	getCoolantGivenPlayer(p)
end
function getCoolant2()
	local p = getPlayerShip(2)
	getCoolantGivenPlayer(p)
end
function getCoolant3()
	local p = getPlayerShip(3)
	getCoolantGivenPlayer(p)
end
function getCoolant4()
	local p = getPlayerShip(4)
	getCoolantGivenPlayer(p)
end
function getCoolant5()
	local p = getPlayerShip(5)
	getCoolantGivenPlayer(p)
end
function getCoolant6()
	local p = getPlayerShip(6)
	getCoolantGivenPlayer(p)
end
function getCoolant7()
	local p = getPlayerShip(7)
	getCoolantGivenPlayer(p)
end
function getCoolant8()
	local p = getPlayerShip(8)
	getCoolantGivenPlayer(p)
end
--		Generate call sign functions
function generateCallSign(prefix,faction)
	if faction == nil then
		if prefix == nil then
			prefix = generateCallSignPrefix()
		end
	else
		if prefix == nil then
			prefix = getFactionPrefix(faction)
		else
			prefix = string.format("%s %s",getFactionPrefix(faction),prefix)
		end
	end
	suffix_index = suffix_index + math.random(1,3)
	if suffix_index > 999 then 
		suffix_index = 1
	end
	return string.format("%s%i",prefix,suffix_index)
end
function generateCallSignPrefix(length)
	if call_sign_prefix_pool == nil then
		call_sign_prefix_pool = {}
		prefix_length = prefix_length + 1
		if prefix_length > 3 then
			prefix_length = 1
		end
		fillPrefixPool()
	end
	if length == nil then
		length = prefix_length
	end
	local prefix_index = 0
	local prefix = ""
	for i=1,length do
		if #call_sign_prefix_pool < 1 then
			fillPrefixPool()
		end
		prefix_index = math.random(1,#call_sign_prefix_pool)
		prefix = prefix .. call_sign_prefix_pool[prefix_index]
		table.remove(call_sign_prefix_pool,prefix_index)
	end
	return prefix
end
function fillPrefixPool()
	for i=1,26 do
		table.insert(call_sign_prefix_pool,string.char(i+64))
	end
end
function getFactionPrefix(faction)
	local faction_prefix = nil
	if faction == "Kraylor" then
		if kraylor_names == nil then
			setKraylorNames()
		else
			if #kraylor_names < 1 then
				setKraylorNames()
			end
		end
		local kraylor_name_choice = math.random(1,#kraylor_names)
		faction_prefix = kraylor_names[kraylor_name_choice]
		table.remove(kraylor_names,kraylor_name_choice)
	end
	if faction_prefix == nil then
		faction_prefix = generateCallSignPrefix()
	end
	return faction_prefix
end
function setKraylorNames()		
	kraylor_names = {}
	table.insert(kraylor_names,"Abroten")
	table.insert(kraylor_names,"Ankwar")
	table.insert(kraylor_names,"Bakrik")
	table.insert(kraylor_names,"Belgor")
	table.insert(kraylor_names,"Benkop")
	table.insert(kraylor_names,"Blargvet")
	table.insert(kraylor_names,"Bloktarg")
	table.insert(kraylor_names,"Bortok")
	table.insert(kraylor_names,"Bredjat")
	table.insert(kraylor_names,"Chankret")
	table.insert(kraylor_names,"Chatork")
	table.insert(kraylor_names,"Chokarp")
	table.insert(kraylor_names,"Cloprak")
	table.insert(kraylor_names,"Coplek")
	table.insert(kraylor_names,"Cortek")
	table.insert(kraylor_names,"Daltok")
	table.insert(kraylor_names,"Darpik")
	table.insert(kraylor_names,"Dastek")
	table.insert(kraylor_names,"Dotark")
	table.insert(kraylor_names,"Drambok")
	table.insert(kraylor_names,"Duntarg")
	table.insert(kraylor_names,"Earklat")
	table.insert(kraylor_names,"Ekmit")
	table.insert(kraylor_names,"Fakret")
	table.insert(kraylor_names,"Fapork")
	table.insert(kraylor_names,"Fawtrik")
	table.insert(kraylor_names,"Fenturp")
	table.insert(kraylor_names,"Feplik")
	table.insert(kraylor_names,"Figront")
	table.insert(kraylor_names,"Floktrag")
	table.insert(kraylor_names,"Fonkack")
	table.insert(kraylor_names,"Fontreg")
	table.insert(kraylor_names,"Foondrap")
	table.insert(kraylor_names,"Frotwak")
	table.insert(kraylor_names,"Gastonk")
	table.insert(kraylor_names,"Gentouk")
	table.insert(kraylor_names,"Gonpruk")
	table.insert(kraylor_names,"Gortak")
	table.insert(kraylor_names,"Gronkud")
	table.insert(kraylor_names,"Hewtang")
	table.insert(kraylor_names,"Hongtag")
	table.insert(kraylor_names,"Hortook")
	table.insert(kraylor_names,"Indrut")
	table.insert(kraylor_names,"Iprant")
	table.insert(kraylor_names,"Jakblet")
	table.insert(kraylor_names,"Jonket")
	table.insert(kraylor_names,"Jontot")
	table.insert(kraylor_names,"Kandarp")
	table.insert(kraylor_names,"Kantrok")
	table.insert(kraylor_names,"Kiptak")
	table.insert(kraylor_names,"Kortrant")
	table.insert(kraylor_names,"Krontgat")
	table.insert(kraylor_names,"Lobreck")
	table.insert(kraylor_names,"Lokrant")
	table.insert(kraylor_names,"Lomprok")
	table.insert(kraylor_names,"Lutrank")
	table.insert(kraylor_names,"Makrast")
	table.insert(kraylor_names,"Moklahft")
	table.insert(kraylor_names,"Morpug")
	table.insert(kraylor_names,"Nagblat")
	table.insert(kraylor_names,"Nokrat")
	table.insert(kraylor_names,"Nomek")
	table.insert(kraylor_names,"Notark")
	table.insert(kraylor_names,"Ontrok")
	table.insert(kraylor_names,"Orkpent")
	table.insert(kraylor_names,"Peechak")
	table.insert(kraylor_names,"Plogrent")
	table.insert(kraylor_names,"Pokrint")
	table.insert(kraylor_names,"Potarg")
	table.insert(kraylor_names,"Prangtil")
	table.insert(kraylor_names,"Quagbrok")
	table.insert(kraylor_names,"Quimprill")
	table.insert(kraylor_names,"Reekront")
	table.insert(kraylor_names,"Ripkort")
	table.insert(kraylor_names,"Rokust")
	table.insert(kraylor_names,"Rontrait")
	table.insert(kraylor_names,"Saknep")
	table.insert(kraylor_names,"Sengot")
	table.insert(kraylor_names,"Skitkard")
	table.insert(kraylor_names,"Skopgrek")
	table.insert(kraylor_names,"Sletrok")
	table.insert(kraylor_names,"Slorknat")
	table.insert(kraylor_names,"Spogrunk")
	table.insert(kraylor_names,"Staklurt")
	table.insert(kraylor_names,"Stonkbrant")
	table.insert(kraylor_names,"Swaktrep")
	table.insert(kraylor_names,"Tandrok")
	table.insert(kraylor_names,"Takrost")
	table.insert(kraylor_names,"Tonkrut")
	table.insert(kraylor_names,"Torkrot")
	table.insert(kraylor_names,"Trablok")
	table.insert(kraylor_names,"Trokdin")
	table.insert(kraylor_names,"Unkelt")
	table.insert(kraylor_names,"Urjop")
	table.insert(kraylor_names,"Vankront")
	table.insert(kraylor_names,"Vintrep")
	table.insert(kraylor_names,"Volkerd")
	table.insert(kraylor_names,"Vortread")
	table.insert(kraylor_names,"Wickurt")
	table.insert(kraylor_names,"Xokbrek")
	table.insert(kraylor_names,"Yeskret")
	table.insert(kraylor_names,"Zacktrope")
end
--------------------
-- Plot functions --
--------------------
-- Transport plot 
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
function randomNearStation(pool,nobj,partialStationList)
--pool = number of nearest stations to randomly choose from
--nobj = named object for comparison purposes
--partialStationList = list of station to compare against
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
				obj:orderDock(obj.target)
				x, y = obj.target:getPosition()
				xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
				obj:setPosition(x + xd, y + yd)
				table.insert(friendlyTransportList, obj)
			end
		end
	end
end
-- Plot 1 peace/treaty/war states
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
-- Plot 2 timed game
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
-- Plot 3 kraylor attack scheme
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
			if attackAngle ~= nil then
				pincerAngle = attackAngle
			else
				pincerAngle = angleFromVector(kraylorCentroidX, kraylorCentroidY, humanCentroidX, humanCentroidY)
				if pincerAngle == nil then
					pincerAngle = random(0,360)
					print("Nil angle observed. Choosing random angle: %.1f",pincerAngle)
				end
			end
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
			local edfi = 0
			repeat
				edfi = math.random(1,#enemyDefensiveFleetList)
				local candidate = enemyDefensiveFleetList[edfi]
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
			intelGatherArtifacts[edfi]:setDescriptions("Scan to gather intelligence",string.format("Enemy fleet in sector %s is on the move",intelGatherArtifacts[edfi].startSector))
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
-- Plot enemy defenses check
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
	local shipSpawnCount = 3
	if difficulty < 1 then
		shipSpawnCount = 2
	elseif difficulty > 1 then
		shipSpawnCount = 4
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
-- Plot PB player border zone checks
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
-- Plot EB enemy border zone checks
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
-- Plot ER enemy reinforcements
function enemyReinforcements(delta)
	if #enemyReinforcementSchedule > 0 then
		if enemyReinforcementTimer == nil then
			enemyReinforcementTimer = delta + enemyReinforcementSchedule[1][1]*60 + ersAdj*60 + random(1,100)
		else
			enemyReinforcementTimer = enemyReinforcementTimer - delta
			if enemyReinforcementTimer < 0 then
				local ta = VisualAsteroid():setPosition(kraylorCentroidX,kraylorCentroidY)
				local p = closestPlayerTo(ta)
				ta:destroy()
				if p == nil then
					for pidx=1,8 do
						p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							break
						end
					end
				end
				if p ~= nil then
					local dirx, diry = vectorFromAngle(random(0,360),random(15000,25000))
					local fpx, fpy = p:getPosition()
					local tempFleet = spawnEnemies(fpx+dirx,fpy+diry,enemyReinforcementSchedule[1][2],"Kraylor")
					for _, enemy in ipairs(tempFleet) do
						enemy:orderAttack(p)
					end
					table.insert(enemyFleetList,tempFleet)
					table.remove(enemyReinforcementSchedule,1)
				end
				enemyReinforcementTimer = nil
			end
		end
	end
end
-- Plot MF muck and flies
function muckAndFlies(delta)
	if muckFlyCounter == nil then
		local upper_counter = difficulty*2 + 2
		muckFlyCounter = math.random(1,upper_counter)
	end
	if muckFlyTimer == nil then
--		muckFlyTimer = 10
		muckFlyTimer = delta + 400 - difficulty * 90 + random(1,200)	--final: 400, 90 and 200
	end
	muckFlyTimer = muckFlyTimer - delta
	if muckFlyTimer < 0 then
		if treaty and treatyTimer > 0 then
			muckFlyTimer = delta + 800 - difficulty * 90 + random(1,200)	--final: 800, 90 and 200
			return
		end
		local victimList = {}
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				table.insert(victimList,p)
			end
		end
		if #victimList > 0 then
			local p = victimList[math.random(1,#victimList)]
			local px, py = p:getPosition()
			local jamAngle = random(0,360)
			local jamDistance = random(6000,9000)
			local jx, jy = vectorFromAngle(jamAngle,jamDistance)
			muck = WarpJammer():setRange(jamDistance*1.7):setPosition(px+jx,py+jy):setFaction("Kraylor"):onDestruction(armoredWarpJammer)
			muck.jamRange = jamDistance*1.7
			if difficulty < 1 then
				muck.lifeCount = 0
			elseif difficulty > 1 then
				muck.lifeCount = 2
			else
				muck.lifeCount = 1
			end
			local flies = {}
			local flyCount = 2 * difficulty + math.random(1,3)
			for i=1,flyCount do
				local ship = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Drone"):setPosition(px+jx,py+jy):orderDefendLocation(px+jx,py+jy):onDestruction(enemyVesselDestroyed):setCommsScript(""):setCommsFunction(commsShip)
				ship:setCallSign(string.format("F%s%i%i",string.char(math.random(65,90)),muckFlyCounter,i))
				table.insert(flies,ship)
				rawKraylorShipStrength = rawKraylorShipStrength + 4
			end
			table.insert(enemyFleetList,flies)
			local stx, sty = vectorFromAngle(jamAngle,jamDistance * .8)
			local playerShipScore = 24
			if p.shipScore ~= nil then
				playerShipScore = p.ShipScore
			end
			local stench = spawnEnemies(px+stx,py+sty,1,"Kraylor",playerShipScore)
			for i, enemy in ipairs(stench) do
				enemy:orderAttack(p):setCallSign(string.format("MS%s%i%i",string.char(math.random(65,90)),i,muckFlyCounter))
			end
			table.insert(enemyFleetList,stench)
			if difficulty >= 1 then
				local attemptCount = 0
				local validCandidate = false
				local candidate = nil
				repeat 
					candidate = humanStationList[math.random(1,#humanStationList)]
					attemptCount = attemptCount + 1
					if candidate ~= nil then
						if candidate:isValid() then
							if distance(candidate,px+jx,py+jy) > (jamDistance*3 + 10000) then
								validCandidate = true
							end
						end
					end
				until(validCandidate or attemptCount > repeatExitBoundary)
				if validCandidate then
					local dix, diy = candidate:getPosition()
					if dix ~= nil then
						local tempFleet = spawnEnemies(dix+500,diy+500,1,"Kraylor")
						for i, enemy in ipairs(tempFleet) do
							enemy:setCallSign(string.format("D%s%i%i",string.char(math.random(65,90)),muckFlyCounter,i))
						end
						table.insert(enemyFleetList,tempFleet)
					end
				end
			end
			if difficulty > 1 then
				attemptCount = 0
				validCandidate = false
				repeat 
					candidate = humanStationList[math.random(1,#humanStationList)]
					attemptCount = attemptCount + 1
					if candidate ~= nil then
						if candidate:isValid() then
							if distance(candidate,px+jx,py+jy) > (jamDistance*3 + 10000) then
								validCandidate = true
							end
						end
					end
				until(validCandidate or attemptCount > repeatExitBoundary)
				if validCandidate then
					local dix, diy = candidate:getPosition()
					if dix ~= nil then
						local tempFleet = spawnEnemies(dix+500,diy+500,1,"Kraylor")
						for i, enemy in ipairs(tempFleet) do
							enemy:setCallSign(string.format("D%s%i%i",string.char(math.random(65,90)),muckFlyCounter,i))
						end
						table.insert(enemyFleetList,tempFleet)
					end
				end
			end
		end
		muckFlyCounter = muckFlyCounter - 1
		if muckFlyCounter <= 0 then
			plotMF = nil
		else
			muckFlyTimer = nil
		end
	end
end
function armoredWarpJammer(self, instigator)
	if self.lifeCount < 1 then
		return
	end
	local tempx, tempy = self:getPosition()
	local redoMuck = WarpJammer():setRange(self.jamRange):setPosition(tempx,tempy):setFaction("Kraylor"):onDestruction(armoredWarpJammer)
	redoMuck.jamRange = self.jamRange
	redoMuck.lifeCount = self.lifeCount - 1
	if difficulty < 1 then
		instigator:setHull(instigator:getHull()*.9)
	elseif difficulty > 1 then
		instigator:setHull(instigator:getHull()*.7)
	else
		instigator:setHull(instigator:getHull()*.8)
	end
end
-- Plot end of war checks and functions
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
			missionCompleteReason = string.format("Enemy reduced to less than %i%% strength",math.floor(enemyDestructionVictoryCondition))
			endStatistics()
			victory("Human Navy")
		end
		local evalFriendly = fpct2*friendlyStationComponentWeight + npct2*neutralStationComponentWeight + fpct*friendlyShipComponentWeight
		if evalFriendly < friendlyDestructionDefeatCondition then
			missionVictory = false
			missionCompleteReason = string.format("Human Navy reduced to less than %i%% strength",math.floor(friendlyDestructionDefeatCondition))
			endStatistics()
			victory("Kraylor")
		end
		if evalEnemy - evalFriendly > destructionDifferenceEndCondition then
			missionVictory = false
			missionCompleteReason = string.format("Enemy strength exceeded ours by %i percentage points",math.floor(destructionDifferenceEndCondition))
			endStatistics()
			victory("Kraylor")
		end
		if evalFriendly - evalEnemy > destructionDifferenceEndCondition then
			missionVictory = true
			missionCompleteReason = string.format("Our strength exceeded enemy strength by %i percentage points",math.floor(destructionDifferenceEndCondition))
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
---------------------------
-- Statistical functions --
---------------------------
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
function endStatistics()
--final page for victory or defeat on main streen
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
	gMsg = gMsg .. string.format("Friendly evaluation strength: %.1f%%\n",evalFriendly)
	gMsg = gMsg .. string.format("   Weights: friendly station: %.2f, neutral station: %.2f, friendly ship: %.2f\n", friendlyStationComponentWeight, neutralStationComponentWeight, friendlyShipComponentWeight)
	local evalEnemy = epct2*enemyStationComponentWeight + epct*enemyShipComponentWeight
	gMsg = gMsg .. string.format("Enemy evaluation strength: %.1f%%\n",evalEnemy)
	gMsg = gMsg .. string.format("   Weights: enemy station: %.2f, enemy ship: %.2f\n", enemyStationComponentWeight, enemyShipComponentWeight)
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
	setPlayers()
--	if updateDiagnostic then print("plot1") end
	if plot1 ~= nil then	--war/peace
		plot1(delta)
	end
--	if updateDiagnostic then print("plot2") end
	if plot2 ~= nil then	--timed game
		plot2(delta)
	end
--	if updateDiagnostic then print("plotEW") end
	if plotEW ~= nil then	--end war checks
		plotEW(delta)
	end
--	if updateDiagnostic then print("plotPB") end
	if plotPB ~= nil then	--player border
		plotPB(delta)
	end
--	if updateDiagnostic then print("plotPWC") end
	if plotPWC ~= nil then	--player war crime check
		plotPWC(delta)
	end
--	if updateDiagnostic then print("plotED") end
	if plotED ~= nil then	--enemy defense
		plotED(delta)
	end
--	if updateDiagnostic then print("plotDZ") end
	if plotDZ ~= nil then	--enemy defense zone
		plotDZ(delta)
	end
--	if updateDiagnostic then print("plotExpTrans") end
	if plotExpTrans ~= nil then		--exploding transport
		plotExpTrans(delta)
	end
--	if updateDiagnostic then print("plotAW") end
	if plotAW ~= nil then	--artifact to worm
		plotAW(delta)
	end
--	if updateDiagnostic then print("plotWJ") end
	if plotWJ ~= nil then	--artifact to worm
		plotWJ(delta)
	end
--	if updateDiagnostic then print("plotAM") end
	if plotAM ~= nil then	--artifact to mine
		plotAM(delta)
	end
--	if updateDiagnostic then print("plotWP") end
	if plotWP ~= nil then	--weapons platform
		plotWP(delta)
	end
--	if updateDiagnostic then print("plotWPO") end
	if plotWPO ~= nil then	--weapons platform orbit
		plotWPO(delta)
	end
--	if updateDiagnostic then print("plotH") end
	if plotH ~= nil then	--health
		plotH(delta)
	end
--	if updateDiagnostic then print("plot3") end
	if plot3 ~= nil then	--kraylor attacks
		plot3(delta)
	end
--	if updateDiagnostic then print("plotFT") end
	if plotFT ~= nil then	--friendly transport plot
		plotFT(delta)
	end
--	if updateDiagnostic then print("plotIT") end
	if plotIT ~= nil then	--independent transport plot
		plotIT(delta)
	end
--	if updateDiagnostic then print("plotKT") end
	if plotKT ~= nil then	--kraylor transport plot
		plotKT(delta)
	end
--	if updateDiagnostic then print("plotEB") end
	if plotEB ~= nil then	--enemy border
		plotEB(delta)
	end
--	if updateDiagnostic then print("plotPA") end
	if plotPA ~= nil then	--personal ambush
		plotPA(delta)
	end
--	if updateDiagnostic then print("plotCI") end
	if plotCI ~= nil then	--cargo inventory
		plotCI(delta)
	end
--	if updateDiagnostic then print("plotC") end
	if plotC ~= nil then	--coolant automation for fighters
		plotC(delta)
	end
--	if updateDiagnostic then print("plotDGM") end
	if plotDGM ~= nil then	--dynamic GM buttons
		plotDGM(delta)
	end
--	if updateDiagnostic then print("plotER") end
	if plotER ~= nil then	--enemy resupply
		plotER(delta)
	end
--	if updateDiagnostic then print("plotMF") end
	if plotMF ~= nil then	--muck and flies
		plotMF(delta)
	end
	if plotCN ~= nil then	--coolant via nebula
		plotCN(delta)
	end
	if plotSS ~= nil then	--spinal ship
		plotSS(delta)
	end
	if plotRevert ~= nil then
		plotRevert(delta)
	end
	if plotContinuum ~= nil then
		plotContinuum(delta)
	end
	if plotExDk ~= nil then	--expedite dock
		plotExDk(delta)
	end
	if plotShowPlayerInfo ~= nil then
		plotShowPlayerInfo(delta)
	end
end