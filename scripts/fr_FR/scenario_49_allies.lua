-- Name: Allies and Enemies
-- Description: The Arlenians are your allies. The Kraylors and Exuari are your enemies and will try to prevent you from completing your missions. Duration: approximately 30 minutes
---
--- Version 0
---
--- Three missions available in current version. Tested with EE version 20190910
-- Type: Replayable Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[One]: Only one mission randomly chosen from several possible missions (Default is all missions in random order)
-- Variation[Easy One]: Easy goals and/or enemies, only one mission randomly chosen from several possible missions (Default is all missions in random order)
-- Variation[Hard One]: Hard goals and/or enemies, only one mission randomly chosen from several possible missions (Default is all missions in random order)

require("utils.lua")
require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")


--[[-----------------------------------------------------------------
      Initialization 
-----------------------------------------------------------------]]--
function init()
	print(_VERSION)
	diagnostic = false
	endStatDiagnostic = false
	updateDiagnostic = false
	setPlayerDiagnostic = false
	miningConflictDiagnostic = false
	sickAdmiralDiagnostic = false
	professorDiagnostic = false
	healthDiagnostic = false
	defaultGameTimeLimitInMinutes = 30	--final: 30 (lowered for test) Drop time limit: short missions, inherent time limits
	repeatExitBoundary = 100
	setVariations()
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	local universeCreateRetryCount = 0
	repeat
		setGossipSnippets()
		setGoodsList()
		setListOfStations()
		setTerritoryZones()
		buildStationsPlus()
		if #kraylorStationList < 5 or #humanStationList < 5 or #exuariStationList < 5 or #arlenianStationList < 5 then
			resetStationsPlus()
			universeCreateRetryCount = universeCreateRetryCount + 1
		end
	until(#kraylorStationList >= 5 and #humanStationList >= 5 and #exuariStationList >= 5 and #arlenianStationList >= 5)
	if universeCreateRetryCount > 0 then
		if diagnostic then print("universe create retry count: " .. universeCreateRetryCount) end
	end
	setFleets()
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	setPlots()
	plotManager = plotDelay
	plotM = movingObjects
	plotCI = cargoInventory
	plotCN = coolantNebulae
	plotH = healthCheck		--Damage to ship can kill repair crew members
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	scarceResources = false
	doctorSearch = false
	GMMining = "Mining"
	addGMFunction(GMMining,triggerMining)
	GMAdmiral = "Admiral"
	addGMFunction(GMAdmiral,triggerAdmiral)
	GMDoomsday = "Doomsday"
	addGMFunction(GMDoomsday,triggerDoomsday)
end
function triggerMining()
	if plot1 == nil then
		plotChoice = 1
		plot1 = plotList[1]
		table.remove(plotList,1)
		plotManager = plotRun
	else 
		nextPlot = miningConflict
	end
end 
function triggerAdmiral()
	if plot1 == nil then
		if #plotList == 3 then
			plotChoice = 2
			plot1 = plotList[2]
			table.remove(plotList,2)
		else
			if plotList[1] == sickArlenianAdmiral then
				plotChoice = 1
				plot1 = plotList[1]
				table.remove(plotList,1)
			else
				plotChoice = 2
				plot1 = plotList[2]
				table.remove(plotList,2)
			end
		end
		plotManager = plotRun
	else
		nextPlot = sickArlenianAdmiral
	end
end
function triggerDoomsday()
	if plot1 == nil then
		if #plotList == 3 then
			plotChoice = 3
			plot1 = plotList[3]
			table.remove(plotList,3)
		else
			if plotList[1] == doomsday then
				plotChoice = 1
				plot1 = plotList[1]
				table.remove(plotList,1)
			else
				plotChoice = 2
				plot1 = plotList[2]
				table.remove(plotList,2)
			end
		end
		plotManager = plotRun
	else
		nextPlot = doomsday
	end
end
function setVariations()
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
		adverseEffect = .999
		coolant_loss = .99999
		coolant_gain = .01
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
		adverseEffect = .99
		coolant_loss = .9999
		coolant_gain = .0001
	else
		difficulty = 1		--default (normal)
		adverseEffect = .995
		coolant_loss = .99995
		coolant_gain = .001
	end
	if string.find(getScenarioVariation(),"One") then
		onlyOneMission = true
	else
		onlyOneMission = false
	end
	if string.find(getScenarioVariation(),"Timed") then
		playWithTimeLimit = true
		gameTimeLimit = defaultGameTimeLimitInMinutes*60		
		plotTimed = timedGame
	else
		gameTimeLimit = 0
		playWithTimeLimit = false
	end
end
function setConstants()
	missile_types = {homing, nuke, mine, emp, hvli}
	--Ship Template Name List
	stnl = {hornetMT52,hornetMU52,"Adder MK5",adderMK4,lindwormWX,adderMK6,phobosT3,phobosM3,piranhaF8,piranhaF12,ranusU,nirvanaR5A,stalkerQ7,stalkerR7,atlantisX23,starhammerII,odin,"Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer",storm}
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
	get_coolant_function = {}
	table.insert(get_coolant_function,getCoolant1)
	table.insert(get_coolant_function,getCoolant2)
	table.insert(get_coolant_function,getCoolant3)
	table.insert(get_coolant_function,getCoolant4)
	table.insert(get_coolant_function,getCoolant5)
	table.insert(get_coolant_function,getCoolant6)
	table.insert(get_coolant_function,getCoolant7)
	table.insert(get_coolant_function,getCoolant8)
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
function bendAngle(fe)
	local angleToReturn = 0
	if random(1,100) < 80 then
		angleToReturn = random(0,60+fe) + (15 - (fe/2))
	else
		for i=1,15 do
			angleToReturn = angleToReturn + random(1,5)
		end
	end
	return angleToReturn
end
function setTerritoryZones()
	borderStartAngle = random(0,360)	--shared border between Human and Arlenian
	borderStartX, borderStartY = vectorFromAngle(borderStartAngle,random(3500,4900))
	local halfLength = random(8000,15000)
	zoneLimit = 150000
	zpi = 1		--zone point index
	--Note: "left" and "right" refer to someone standing on the 2D board at the spawn point
	--		looking at the shared Human and Arlenian border;
	humanLeftX = {}
	humanLeftY = {}
	humanRightX = {}
	humanRightY = {}
	arlenianLeftX = {}
	arlenianLeftY = {}
	arlenianRightX = {}
	arlenianRightY = {}
	local szbx, szby = vectorFromAngle(borderStartAngle+270,halfLength)
	sharedZoneBorderLeftX = borderStartX + szbx
	sharedZoneBorderLeftY = borderStartY + szby
	local szbx, szby = vectorFromAngle(borderStartAngle+90,halfLength)
	sharedZoneBorderRightX = borderStartX + szbx
	sharedZoneBorderRightY = borderStartY + szby
	local firstLowerLength = 10000
	local firstUpperLength = 20000
	local ba = bendAngle(0)
	local hlx, hly = vectorFromAngle(borderStartAngle+270-ba,random(firstLowerLength,firstUpperLength))
	table.insert(humanLeftX,sharedZoneBorderLeftX + hlx)
	table.insert(humanLeftY,sharedZoneBorderLeftY + hly)
	local ba = bendAngle(0)
	local hlx, hly = vectorFromAngle(borderStartAngle+90+ba,random(firstLowerLength,firstUpperLength))
	table.insert(humanRightX,sharedZoneBorderRightX + hlx)
	table.insert(humanRightY,sharedZoneBorderRightY + hly)
	local ba = bendAngle(0)
	local hlx, hly = vectorFromAngle(borderStartAngle+270+ba,random(firstLowerLength,firstUpperLength))
	table.insert(arlenianLeftX,sharedZoneBorderLeftX + hlx)
	table.insert(arlenianLeftY,sharedZoneBorderLeftY + hly)
	local ba = bendAngle(0)
	local hlx, hly = vectorFromAngle(borderStartAngle+90-ba,random(firstLowerLength,firstUpperLength))
	table.insert(arlenianRightX,sharedZoneBorderRightX + hlx)
	table.insert(arlenianRightY,sharedZoneBorderRightY + hly)
	local lowerLength = 8000
	local upperLength = 15000
	for i=1,20 do
		local ba = bendAngle(i)
		local hlx, hly = vectorFromAngle(borderStartAngle+270-ba,random(lowerLength,upperLength))
		table.insert(humanLeftX,humanLeftX[zpi] + hlx)
		table.insert(humanLeftY,humanLeftY[zpi] + hly)
		local ba = bendAngle(i)
		local hlx, hly = vectorFromAngle(borderStartAngle+90+ba,random(lowerLength,upperLength))
		table.insert(humanRightX,humanRightX[zpi] + hlx)
		table.insert(humanRightY,humanRightY[zpi] + hly)
		local ba = bendAngle(i)
		local hlx, hly = vectorFromAngle(borderStartAngle+270+ba,random(lowerLength,upperLength))
		table.insert(arlenianLeftX,arlenianLeftX[zpi] + hlx)
		table.insert(arlenianLeftY,arlenianLeftY[zpi] + hly)
		local ba = bendAngle(i)
		local hlx, hly = vectorFromAngle(borderStartAngle+90-ba,random(lowerLength,upperLength))
		table.insert(arlenianRightX,arlenianRightX[zpi] + hlx)
		table.insert(arlenianRightY,arlenianRightY[zpi] + hly)
		zpi = zpi + 1
	end
	humanZone = Zone()
		:setPoints(humanLeftX[21],			humanLeftY[21],
				   humanLeftX[20],			humanLeftY[20],
				   humanLeftX[19],			humanLeftY[19],
				   humanLeftX[18],			humanLeftY[18],
				   humanLeftX[17],			humanLeftY[17],
				   humanLeftX[16],			humanLeftY[16],
				   humanLeftX[15],			humanLeftY[15],
				   humanLeftX[14],			humanLeftY[14],
				   humanLeftX[13],			humanLeftY[13],
				   humanLeftX[12],			humanLeftY[12],
				   humanLeftX[11],			humanLeftY[11],
				   humanLeftX[10],			humanLeftY[10],
				   humanLeftX[9],			humanLeftY[9],
				   humanLeftX[8],			humanLeftY[8],
				   humanLeftX[7],			humanLeftY[7],
				   humanLeftX[6],			humanLeftY[6],
				   humanLeftX[5],			humanLeftY[5],
				   humanLeftX[4],			humanLeftY[4],
				   humanLeftX[3],			humanLeftY[3],
				   humanLeftX[2],			humanLeftY[2],
				   humanLeftX[1],			humanLeftY[1],
				   sharedZoneBorderLeftX,	sharedZoneBorderLeftY,
				   sharedZoneBorderRightX,	sharedZoneBorderRightY,
				   humanRightX[1],			humanRightY[1],
				   humanRightX[2],			humanRightY[2],
				   humanRightX[3],			humanRightY[3],
				   humanRightX[4],			humanRightY[4],
				   humanRightX[5],			humanRightY[5],
				   humanRightX[6],			humanRightY[6],
				   humanRightX[7],			humanRightY[7],
				   humanRightX[8],			humanRightY[8],
				   humanRightX[9],			humanRightY[9],
				   humanRightX[10],			humanRightY[10],
				   humanRightX[11],			humanRightY[11],
				   humanRightX[12],			humanRightY[12],
				   humanRightX[13],			humanRightY[13],
				   humanRightX[14],			humanRightY[14],
				   humanRightX[15],			humanRightY[15],
				   humanRightX[16],			humanRightY[16],
				   humanRightX[17],			humanRightY[17],
				   humanRightX[18],			humanRightY[18],
				   humanRightX[19],			humanRightY[19],
				   humanRightX[20],			humanRightY[20],
				   humanRightX[21],			humanRightY[21])
	arlenianZone = Zone()
		:setPoints(arlenianRightX[21],		arlenianRightY[21],
				   arlenianRightX[20],		arlenianRightY[20],
				   arlenianRightX[19],		arlenianRightY[19],
				   arlenianRightX[18],		arlenianRightY[18],
				   arlenianRightX[17],		arlenianRightY[17],
				   arlenianRightX[16],		arlenianRightY[16],
				   arlenianRightX[15],		arlenianRightY[15],
				   arlenianRightX[14],		arlenianRightY[14],
				   arlenianRightX[13],		arlenianRightY[13],
				   arlenianRightX[12],		arlenianRightY[12],
				   arlenianRightX[11],		arlenianRightY[11],
				   arlenianRightX[10],		arlenianRightY[10],
				   arlenianRightX[9],		arlenianRightY[9],
				   arlenianRightX[8],		arlenianRightY[8],
				   arlenianRightX[7],		arlenianRightY[7],
				   arlenianRightX[6],		arlenianRightY[6],
				   arlenianRightX[5],		arlenianRightY[5],
				   arlenianRightX[4],		arlenianRightY[4],
				   arlenianRightX[3],		arlenianRightY[3],
				   arlenianRightX[2],		arlenianRightY[2],
				   arlenianRightX[1],		arlenianRightY[1],
				   sharedZoneBorderRightX,	sharedZoneBorderRightY,
				   sharedZoneBorderLeftX,	sharedZoneBorderLeftY,
				   arlenianLeftX[1],		arlenianLeftY[1],
				   arlenianLeftX[2],		arlenianLeftY[2],
				   arlenianLeftX[3],		arlenianLeftY[3],
				   arlenianLeftX[4],		arlenianLeftY[4],
				   arlenianLeftX[5],		arlenianLeftY[5],
				   arlenianLeftX[6],		arlenianLeftY[6],
				   arlenianLeftX[7],		arlenianLeftY[7],
				   arlenianLeftX[8],		arlenianLeftY[8],
				   arlenianLeftX[9],		arlenianLeftY[9],
				   arlenianLeftX[10],		arlenianLeftY[10],
				   arlenianLeftX[11],		arlenianLeftY[11],
				   arlenianLeftX[12],		arlenianLeftY[12],
				   arlenianLeftX[13],		arlenianLeftY[13],
				   arlenianLeftX[14],		arlenianLeftY[14],
				   arlenianLeftX[15],		arlenianLeftY[15],
				   arlenianLeftX[16],		arlenianLeftY[16],
				   arlenianLeftX[17],		arlenianLeftY[17],
				   arlenianLeftX[18],		arlenianLeftY[18],
				   arlenianLeftX[19],		arlenianLeftY[19],
				   arlenianLeftX[20],		arlenianLeftY[20],
				   arlenianLeftX[21],		arlenianLeftY[21])
	kraylorZone = Zone()
		:setPoints(arlenianLeftX[21],		arlenianLeftY[21],
				   arlenianLeftX[20],		arlenianLeftY[20],
				   arlenianLeftX[19],		arlenianLeftY[19],
				   arlenianLeftX[18],		arlenianLeftY[18],
				   arlenianLeftX[17],		arlenianLeftY[17],
				   arlenianLeftX[16],		arlenianLeftY[16],
				   arlenianLeftX[15],		arlenianLeftY[15],
				   arlenianLeftX[14],		arlenianLeftY[14],
				   arlenianLeftX[13],		arlenianLeftY[13],
				   arlenianLeftX[12],		arlenianLeftY[12],
				   arlenianLeftX[11],		arlenianLeftY[11],
				   arlenianLeftX[10],		arlenianLeftY[10],
				   arlenianLeftX[9],		arlenianLeftY[9],
				   arlenianLeftX[8],		arlenianLeftY[8],
				   arlenianLeftX[7],		arlenianLeftY[7],
				   arlenianLeftX[6],		arlenianLeftY[6],
				   arlenianLeftX[5],		arlenianLeftY[5],
				   arlenianLeftX[4],		arlenianLeftY[4],
				   arlenianLeftX[3],		arlenianLeftY[3],
				   arlenianLeftX[2],		arlenianLeftY[2],
				   arlenianLeftX[1],		arlenianLeftY[1],
				   sharedZoneBorderLeftX,	sharedZoneBorderLeftY,
				   humanLeftX[1],			humanLeftY[1],
				   humanLeftX[2],			humanLeftY[2],
				   humanLeftX[3],			humanLeftY[3],
				   humanLeftX[4],			humanLeftY[4],
				   humanLeftX[5],			humanLeftY[5],
				   humanLeftX[6],			humanLeftY[6],
				   humanLeftX[7],			humanLeftY[7],
				   humanLeftX[8],			humanLeftY[8],
				   humanLeftX[9],			humanLeftY[9],
				   humanLeftX[10],			humanLeftY[10],
				   humanLeftX[11],			humanLeftY[11],
				   humanLeftX[12],			humanLeftY[12],
				   humanLeftX[13],			humanLeftY[13],
				   humanLeftX[14],			humanLeftY[14],
				   humanLeftX[15],			humanLeftY[15],
				   humanLeftX[16],			humanLeftY[16],
				   humanLeftX[17],			humanLeftY[17],
				   humanLeftX[18],			humanLeftY[18],
				   humanLeftX[19],			humanLeftY[19],
				   humanLeftX[20],			humanLeftY[20],
				   humanLeftX[21],			humanLeftY[21])
	exuariZone = Zone()
		:setPoints(humanRightX[21],			humanRightY[21],
				   humanRightX[20],			humanRightY[20],
				   humanRightX[19],			humanRightY[19],
				   humanRightX[18],			humanRightY[18],
				   humanRightX[17],			humanRightY[17],
				   humanRightX[16],			humanRightY[16],
				   humanRightX[15],			humanRightY[15],
				   humanRightX[14],			humanRightY[14],
				   humanRightX[13],			humanRightY[13],
				   humanRightX[12],			humanRightY[12],
				   humanRightX[11],			humanRightY[11],
				   humanRightX[10],			humanRightY[10],
				   humanRightX[9],			humanRightY[9],
				   humanRightX[8],			humanRightY[8],
				   humanRightX[7],			humanRightY[7],
				   humanRightX[6],			humanRightY[6],
				   humanRightX[5],			humanRightY[5],
				   humanRightX[4],			humanRightY[4],
				   humanRightX[3],			humanRightY[3],
				   humanRightX[2],			humanRightY[2],
				   humanRightX[1],			humanRightY[1],
				   sharedZoneBorderRightX,	sharedZoneBorderRightY,
				   arlenianRightX[1],		arlenianRightY[1],
				   arlenianRightX[2],		arlenianRightY[2],
				   arlenianRightX[3],		arlenianRightY[3],
				   arlenianRightX[4],		arlenianRightY[4],
				   arlenianRightX[5],		arlenianRightY[5],
				   arlenianRightX[6],		arlenianRightY[6],
				   arlenianRightX[7],		arlenianRightY[7],
				   arlenianRightX[8],		arlenianRightY[8],
				   arlenianRightX[9],		arlenianRightY[9],
				   arlenianRightX[10],		arlenianRightY[10],
				   arlenianRightX[11],		arlenianRightY[11],
				   arlenianRightX[12],		arlenianRightY[12],
				   arlenianRightX[13],		arlenianRightY[13],
				   arlenianRightX[14],		arlenianRightY[14],
				   arlenianRightX[15],		arlenianRightY[15],
				   arlenianRightX[16],		arlenianRightY[16],
				   arlenianRightX[17],		arlenianRightY[17],
				   arlenianRightX[18],		arlenianRightY[18],
				   arlenianRightX[19],		arlenianRightY[19],
				   arlenianRightX[20],		arlenianRightY[20],
				   arlenianRightX[21],		arlenianRightY[21])
	humanZone:setColor(0,54,0):setLabel("Human")
	arlenianZone:setColor(0,0,54):setLabel("Arlenian")
	kraylorZone:setColor(54,0,0):setLabel(kraylorFaction)
	exuariZone:setColor(54,0,0):setLabel(exuariFaction)
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
	exuariStationList = {}
	exuariStationsRemain = true
	arlenianStationList = {}
	arlenianStationsRemain = true
	humanStationDestroyedNameList = {}
	humanStationDestroyedValue = {}
	kraylorStationDestroyedNameList = {}
	kraylorStationDestroyedValue = {}
	exuariStationDestroyedNameList = {}
	exuariStationDestroyedValue = {}
	arlenianStationDestroyedNameList = {}
	arlenianStationDestroyedValue = {}
	neutralStationDestroyedNameList = {}
	neutralStationDestroyedValue = {}
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
	humanStationStrength = 0
	kraylorStationStrength = 0
	neutralStationStrength = 0
	arlenianStationStrength = 0
	exuariStationStrength = 0
	repeat
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
		pStation = nil
		if humanZone:isInside(ta) then
			placeHuman()
		elseif arlenianZone:isInside(ta) then
			placeArlenian()
		elseif kraylorZone:isInside(ta) then
			placeKraylor()
		elseif exuariZone:isInside(ta) then
			placeExuari()
		else
			placeNeutral()
		end	
		ta:destroy()
		if #gossipSnippets > 0 and stationFaction == humanFaction and pStation ~= nil then
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
	until(not neutralStationsRemain or not humanStationsRemain or not kraylorStationsRemain or not exuariStationsRemain)
	local oobCount = 0
	local humanOob = 0
	local kraylorOob = 0
	local exuariOob = 0
	local arlenianOob = 0
	local neutralOob = 0
	for i=1,#stationList do
		local extractStation = stationList[i]
		local psf = extractStation:getFaction()
		if psf == humanFaction and not humanZone:isInside(extractStation) then
			oobCount = oobCount + 1
			humanOob = humanOob + 1
		end
		if psf == kraylorFaction and not kraylorZone:isInside(extractStation) then
			oobCount = oobCount + 1
			kraylorOob = kraylorOob + 1
		end
		if psf == exuariFaction and not exuariZone:isInside(extractStation) then
			oobCount = oobCount + 1
			exuariOob = exuariOob + 1
		end
		if psf == arleniansFaction and not arlenianZone:isInside(extractStation) then
			oobCount = oobCount + 1
			arlenianOob = arlenianOob + 1
		end
		if psf == neutralFaction and (humanZone:isInside(extractStation) 
								or kraylorZone:isInside(extractStation) 
								or exuariZone:isInside(extractStation) 
								or arlenianZone:isInside(extractStation)) then
			oobCount = oobCount + 1
			neutralOob = neutralOob + 1
		end
	end
	if oobCount > 0 then
		if diagnostic then print(string.format("OOB: %i, Human: %i, Kraylor: %i, Exuari: %i, Arlenian: %i, Neutral: %i",oobCount,humanOob,kraylorOob,exuariOob,arlenianOob,neutralOob)) end
	end
	if diagnostic then print(string.format("Human stations: %i, Kraylor stations: %i, Exuari stations: %i, Arlenian stations: %i, Neutral stations: %i",#humanStationList,#kraylorStationList,#exuariStationList,#arlenianStationList,#neutralStationList)) end
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
function placeHuman()
	if stationFaction ~= humanFaction then
		fb = gp									--set faction boundary
	end
	stationFaction = humanFaction				--set station faction
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
		if sizeTemplate == hugeStation then
			humanStationStrength = humanStationStrength + 10
			pStation.strength = 10
		elseif sizeTemplate == largeStation then
			humanStationStrength = humanStationStrength + 5
			pStation.strength = 5
		elseif sizeTemplate == mediumStation then
			humanStationStrength = humanStationStrength + 3
			pStation.strength = 3
		else
			humanStationStrength = humanStationStrength + 1
			pStation.strength = 1
		end
		pStation:onDestruction(humanStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(humanStationList,pStation)		--save station in friendly station list
	end
end
function placeKraylor()
	if stationFaction ~= kraylorFaction then
		fb = gp									--set faction boundary
	end
	stationFaction = kraylorFaction
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
		if sizeTemplate == hugeStation then
			kraylorStationStrength = kraylorStationStrength + 10
			pStation.strength = 10
		elseif sizeTemplate == largeStation then
			kraylorStationStrength = kraylorStationStrength + 5
			pStation.strength = 5
		elseif sizeTemplate == mediumStation then
			kraylorStationStrength = kraylorStationStrength + 3
			pStation.strength = 3
		else
			kraylorStationStrength = kraylorStationStrength + 1
			pStation.strength = 1
		end
		pStation:onDestruction(kraylorStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(kraylorStationList,pStation)	--save station in enemy station list
	end
end
function placeExuari()
	if stationFaction ~= exuariFaction then
		fb = gp									--set faction boundary
	end
	stationFaction = exuariFaction
	if #placeEnemyStation > 0 then
		si = math.random(1,#placeEnemyStation)		--station index
		pStation = placeEnemyStation[si]()			--place selected station
		table.remove(placeEnemyStation,si)			--remove station from placement list
	elseif #placeGenericStation > 0 then
		si = math.random(1,#placeGenericStation)		--station index
		pStation = placeGenericStation[si]()		--place selected station
		table.remove(placeGenericStation,si)		--remove station from placement list
	else
		exuariStationsRemain = false
	end
	if exuariStationsRemain then
		if sizeTemplate == hugeStation then
			exuariStationStrength = exuariStationStrength + 10
			pStation.strength = 10
		elseif sizeTemplate == largeStation then
			exuariStationStrength = exuariStationStrength + 5
			pStation.strength = 5
		elseif sizeTemplate == mediumStation then
			exuariStationStrength = exuariStationStrength + 3
			pStation.strength = 3
		else
			exuariStationStrength = exuariStationStrength + 1
			pStation.strength = 1
		end
		pStation:onDestruction(exuariStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(exuariStationList,pStation)	--save station in enemy station list
	end
end
function placeArlenian()
	if stationFaction ~= arleniansFaction then
		fb = gp									--set faction boundary
	end
	stationFaction = arleniansFaction				--set station faction
	if #placeStation > 0 then
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
	elseif #placeGenericStation > 0 then
		si = math.random(1,#placeGenericStation)	--station index
		pStation = placeGenericStation[si]()		--place selected station
		table.remove(placeGenericStation,si)		--remove station from placement list
	else
		arlenianStationsRemain = false
	end
	if arlenianStationsRemain then
		if sizeTemplate == hugeStation then
			pStation.strength = 10
			arlenianStationStrength = arlenianStationStrength + 10
		elseif sizeTemplate == largeStation then
			pStation.strength = 5
			arlenianStationStrength = arlenianStationStrength + 5
		elseif sizeTemplate == mediumStation then
			pStation.strength = 3
			arlenianStationStrength = arlenianStationStrength + 3
		else
			pStation.strength = 1
			arlenianStationStrength = arlenianStationStrength + 1
		end
		pStation:onDestruction(arlenianStationDestroyed)
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(arlenianStationList,pStation)	--save station in arlenian station list
	end
end
function placeNeutral()
	if stationFaction ~= neutralFaction then
		fb = gp									--set faction boundary
	end
	stationFaction = neutralFaction				--set station faction
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
		if sizeTemplate == hugeStation then
			pStation.strength = 10
			neutralStationStrength = neutralStationStrength + 10
		elseif sizeTemplate == largeStation then
			pStation.strength = 5
			neutralStationStrength = neutralStationStrength + 5
		elseif sizeTemplate == mediumStation then
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
function szt()
--Randomly choose station size template
	stationSizeRandom = random(1,100)
	if stationSizeRandom <= 8 then
		sizeTemplate = hugeStation		-- 8 percent huge
	elseif stationSizeRandom <= 24 then
		sizeTemplate = largeStation		--16 percent large
	elseif stationSizeRandom <= 50 then
		sizeTemplate = mediumStation		--26 percent medium
	else
		sizeTemplate = smallStation		--50 percent small
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	if stationFaction == humanFaction then
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
	stationMaverick:setPosition(psx,psy):setCallSign(maverick):setDescription("Gambling and resupply")
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
	rawKraylorShipStrength = 0
	rawHumanShipStrength = 0
	rawExuariShipStrength = 0
	rawArlenianShipStrength = 0
	rawNeutralShipStrength = 0
	kraylorVesselDestroyedNameList = {}
	kraylorVesselDestroyedType = {}
	kraylorVesselDestroyedValue = {}
	exuariVesselDestroyedNameList = {}
	exuariVesselDestroyedType = {}
	exuariVesselDestroyedValue = {}
	humanVesselDestroyedNameList = {}
	humanVesselDestroyedType = {}
	humanVesselDestroyedValue = {}
	arlenianVesselDestroyedNameList = {}
	arlenianVesselDestroyedType = {}
	arlenianVesselDestroyedValue = {}
	setKraylorDefensiveFleet()
	setExuariDefensiveFleet()
	setHumanDefensiveFleet()
	setArlenianDefensiveFleet()
end
function setKraylorDefensiveFleet()	
	kraylorResource = 100 + difficulty*200
	kraylorFleetList = {}
	kraylorDefensiveFleetList = {}
	kraylorFleet1base = kraylorStationList[math.random(1,#kraylorStationList)]
	local f1bx, f1by = kraylorFleet1base:getPosition()
	kraylorFleet1, kraylorFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130))
	for _, enemy in ipairs(kraylorFleet1) do
		enemy:orderDefendTarget(kraylorFleet1base)
	end
	table.insert(kraylorFleetList,kraylorFleet1)
	table.insert(kraylorDefensiveFleetList,kraylorFleet1)
	kraylorResource = kraylorResource - kraylorFleet1Power
	if kraylorResource > 120 then
		kraylorFleet2Power = random(80,120)
	else
		kraylorFleet2Power = 120
	end
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= kraylorFleet1base then
			kraylorFleet2base = candidate
		end
	until(kraylorFleet2base ~= nil)
	local f1bx, f1by = kraylorFleet2base:getPosition()
	kraylorFleet2, kraylorFleet2Power = spawnEnemyFleet(f1bx, f1by, kraylorFleet2Power)
	for _, enemy in ipairs(kraylorFleet2) do
		enemy:orderDefendTarget(kraylorFleet2base)
	end
	table.insert(kraylorFleetList,kraylorFleet2)
	table.insert(kraylorDefensiveFleetList,kraylorFleet2)
	kraylorResource = kraylorResource - kraylorFleet2Power
	if kraylorResource > 120 then
		kraylorFleet3Power = random(80,120)
	else
		kraylorFleet3Power = 120
	end
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= kraylorFleet1base and candidate ~= kraylorFleet2base then
			kraylorFleet3base = candidate
		end
	until(kraylorFleet3base ~= nil)
	local f1bx, f1by = kraylorFleet3base:getPosition()
	kraylorFleet3, kraylorFleet3Power = spawnEnemyFleet(f1bx, f1by, kraylorFleet3Power)
	for _, enemy in ipairs(kraylorFleet3) do
		enemy:orderDefendTarget(kraylorFleet3base)
	end
	table.insert(kraylorFleetList,kraylorFleet3)
	table.insert(kraylorDefensiveFleetList,kraylorFleet3)
	kraylorResource = kraylorResource - kraylorFleet3Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= kraylorFleet1base and candidate ~= kraylorFleet2base and candidate ~= kraylorFleet3base then
			kraylorFleet4base = candidate
		end
	until(kraylorFleet4base ~= nil)
	local f1bx, f1by = kraylorFleet4base:getPosition()
	kraylorFleet4, kraylorFleet4Power = spawnEnemyFleet(f1bx, f1by, kraylorResource/2)
	for _, enemy in ipairs(kraylorFleet4) do
		enemy:orderDefendTarget(kraylorFleet4base)
	end
	table.insert(kraylorFleetList,kraylorFleet4)
	table.insert(kraylorDefensiveFleetList,kraylorFleet4)
	kraylorResource = kraylorResource - kraylorFleet4Power
	repeat
		candidate = kraylorStationList[math.random(1,#kraylorStationList)]
		if candidate ~= kraylorFleet1base and candidate ~= kraylorFleet2base and candidate ~= kraylorFleet3base and candidate ~= kraylorFleet4base then
			kraylorFleet5base = candidate
		end
	until(kraylorFleet5base ~= nil)
	local f1bx, f1by = kraylorFleet5base:getPosition()
	kraylorFleet5, kraylorFleet5Power = spawnEnemyFleet(f1bx, f1by, kraylorResource)
	for _, enemy in ipairs(kraylorFleet5) do
		enemy:orderDefendTarget(kraylorFleet5base)
	end
	table.insert(kraylorFleetList,kraylorFleet5)
	table.insert(kraylorDefensiveFleetList,kraylorFleet5)
end
function setExuariDefensiveFleet()	
	exuariResource = 100 + difficulty*200
	exuariFleetList = {}
	exuariDefensiveFleetList = {}
	exuariFleet1base = exuariStationList[math.random(1,#exuariStationList)]
	local f1bx, f1by = exuariFleet1base:getPosition()
	exuariFleet1, exuariFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130), 1, exuariFaction)
	for _, enemy in ipairs(exuariFleet1) do
		enemy:orderDefendTarget(exuariFleet1base)
	end
	table.insert(exuariFleetList,exuariFleet1)
	table.insert(exuariDefensiveFleetList,exuariFleet1)
	exuariResource = exuariResource - exuariFleet1Power
	if exuariResource > 120 then
		exuariFleet2Power = random(80,120)
	else
		exuariFleet2Power = 120
	end
	repeat
		candidate = exuariStationList[math.random(1,#exuariStationList)]
		if candidate ~= exuariFleet1base then
			exuariFleet2base = candidate
		end
	until(exuariFleet2base ~= nil)
	local f1bx, f1by = exuariFleet2base:getPosition()
	exuariFleet2, exuariFleet2Power = spawnEnemyFleet(f1bx, f1by, exuariFleet2Power, 1, exuariFaction)
	for _, enemy in ipairs(exuariFleet2) do
		enemy:orderDefendTarget(exuariFleet2base)
	end
	table.insert(exuariFleetList,exuariFleet2)
	table.insert(exuariDefensiveFleetList,exuariFleet2)
	exuariResource = exuariResource - exuariFleet2Power
	if exuariResource > 120 then
		exuariFleet3Power = random(80,120)
	else
		exuariFleet3Power = 120
	end
	repeat
		candidate = exuariStationList[math.random(1,#exuariStationList)]
		if candidate ~= exuariFleet1base and candidate ~= exuariFleet2base then
			exuariFleet3base = candidate
		end
	until(exuariFleet3base ~= nil)
	local f1bx, f1by = exuariFleet3base:getPosition()
	exuariFleet3, exuariFleet3Power = spawnEnemyFleet(f1bx, f1by, exuariFleet3Power, 1, exuariFaction)
	for _, enemy in ipairs(exuariFleet3) do
		enemy:orderDefendTarget(exuariFleet3base)
	end
	table.insert(exuariFleetList,exuariFleet3)
	table.insert(exuariDefensiveFleetList,exuariFleet3)
	exuariResource = exuariResource - exuariFleet3Power
	repeat
		candidate = exuariStationList[math.random(1,#exuariStationList)]
		if candidate ~= exuariFleet1base and candidate ~= exuariFleet2base and candidate ~= exuariFleet3base then
			exuariFleet4base = candidate
		end
	until(exuariFleet4base ~= nil)
	local f1bx, f1by = exuariFleet4base:getPosition()
	exuariFleet4, exuariFleet4Power = spawnEnemyFleet(f1bx, f1by, exuariResource/2, 1, exuariFaction)
	for _, enemy in ipairs(exuariFleet4) do
		enemy:orderDefendTarget(exuariFleet4base)
	end
	table.insert(exuariFleetList,exuariFleet4)
	table.insert(exuariDefensiveFleetList,exuariFleet4)
	exuariResource = exuariResource - exuariFleet4Power
	repeat
		candidate = exuariStationList[math.random(1,#exuariStationList)]
		if candidate ~= exuariFleet1base and candidate ~= exuariFleet2base and candidate ~= exuariFleet3base and candidate ~= exuariFleet4base then
			exuariFleet5base = candidate
		end
	until(exuariFleet5base ~= nil)
	local f1bx, f1by = exuariFleet5base:getPosition()
	exuariFleet5, exuariFleet5Power = spawnEnemyFleet(f1bx, f1by, exuariResource, 1, exuariFaction)
	for _, enemy in ipairs(exuariFleet5) do
		enemy:orderDefendTarget(exuariFleet5base)
	end
	table.insert(exuariFleetList,exuariFleet5)
	table.insert(exuariDefensiveFleetList,exuariFleet5)
end
function setArlenianDefensiveFleet()	
	arlenianResource = 100 + difficulty*200
	arlenianFleetList = {}
	arlenianDefensiveFleetList = {}
	arlenianFleet1base = arlenianStationList[math.random(1,#arlenianStationList)]
	local f1bx, f1by = arlenianFleet1base:getPosition()
	arlenianFleet1, arlenianFleet1Power = spawnEnemyFleet(f1bx, f1by, random(90,130), 1, arleniansFaction)
	for _, enemy in ipairs(arlenianFleet1) do
		enemy:orderDefendTarget(arlenianFleet1base)
	end
	table.insert(arlenianFleetList,arlenianFleet1)
	table.insert(arlenianDefensiveFleetList,arlenianFleet1)
	arlenianResource = arlenianResource - arlenianFleet1Power
	if arlenianResource > 120 then
		arlenianFleet2Power = random(80,120)
	else
		arlenianFleet2Power = 120
	end
	repeat
		candidate = arlenianStationList[math.random(1,#arlenianStationList)]
		if candidate ~= arlenianFleet1base then
			arlenianFleet2base = candidate
		end
	until(arlenianFleet2base ~= nil)
	local f1bx, f1by = arlenianFleet2base:getPosition()
	arlenianFleet2, arlenianFleet2Power = spawnEnemyFleet(f1bx, f1by, arlenianFleet2Power, 1, arleniansFaction)
	for _, enemy in ipairs(arlenianFleet2) do
		enemy:orderDefendTarget(arlenianFleet2base)
	end
	table.insert(arlenianFleetList,arlenianFleet2)
	table.insert(arlenianDefensiveFleetList,arlenianFleet2)
	arlenianResource = arlenianResource - arlenianFleet2Power
	if arlenianResource > 120 then
		arlenianFleet3Power = random(80,120)
	else
		arlenianFleet3Power = 120
	end
	repeat
		candidate = arlenianStationList[math.random(1,#arlenianStationList)]
		if candidate ~= arlenianFleet1base and candidate ~= arlenianFleet2base then
			arlenianFleet3base = candidate
		end
	until(arlenianFleet3base ~= nil)
	local f1bx, f1by = arlenianFleet3base:getPosition()
	arlenianFleet3, arlenianFleet3Power = spawnEnemyFleet(f1bx, f1by, arlenianFleet3Power, 1, arleniansFaction)
	for _, enemy in ipairs(arlenianFleet3) do
		enemy:orderDefendTarget(arlenianFleet3base)
	end
	table.insert(arlenianFleetList,arlenianFleet3)
	table.insert(arlenianDefensiveFleetList,arlenianFleet3)
	arlenianResource = arlenianResource - arlenianFleet3Power
	repeat
		candidate = arlenianStationList[math.random(1,#arlenianStationList)]
		if candidate ~= arlenianFleet1base and candidate ~= arlenianFleet2base and candidate ~= arlenianFleet3base then
			arlenianFleet4base = candidate
		end
	until(arlenianFleet4base ~= nil)
	local f1bx, f1by = arlenianFleet4base:getPosition()
	arlenianFleet4, arlenianFleet4Power = spawnEnemyFleet(f1bx, f1by, arlenianResource/2, 1, arleniansFaction)
	for _, enemy in ipairs(arlenianFleet4) do
		enemy:orderDefendTarget(arlenianFleet4base)
	end
	table.insert(arlenianFleetList,arlenianFleet4)
	table.insert(arlenianDefensiveFleetList,arlenianFleet4)
	arlenianResource = arlenianResource - arlenianFleet4Power
	repeat
		candidate = arlenianStationList[math.random(1,#arlenianStationList)]
		if candidate ~= arlenianFleet1base and candidate ~= arlenianFleet2base and candidate ~= arlenianFleet3base and candidate ~= arlenianFleet4base then
			arlenianFleet5base = candidate
		end
	until(arlenianFleet5base ~= nil)
	local f1bx, f1by = arlenianFleet5base:getPosition()
	arlenianFleet5, arlenianFleet5Power = spawnEnemyFleet(f1bx, f1by, arlenianResource, 1, arleniansFaction)
	for _, enemy in ipairs(arlenianFleet5) do
		enemy:orderDefendTarget(arlenianFleet5base)
	end
	table.insert(arlenianFleetList,arlenianFleet5)
	table.insert(arlenianDefensiveFleetList,arlenianFleet5)
end
function setHumanDefensiveFleet()	
	humanResource = 300
	humanFleetList = {}
	humanHelperFleet = {}
	table.insert(humanFleetList,humanHelperFleet)
	humanFleet1base = humanStationList[math.random(1,#humanStationList)]
	local f1bx, f1by = humanFleet1base:getPosition()
	humanFleet1, humanFleet1Power = spawnEnemyFleet(f1bx, f1by, random(30,70), 1, humanFaction)
	for _, enemy in ipairs(humanFleet1) do
		enemy:orderDefendTarget(humanFleet1base):setScanned(true)
	end
	table.insert(humanFleetList,humanFleet1)
	humanResource = humanResource - humanFleet1Power
	if humanResource > 60 then
		humanFleet2Power = random(40,60)
	else
		humanFleet2Power = 60
	end
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= humanFleet1base then
			humanFleet2base = candidate
		end
	until(humanFleet2base ~= nil)
	local f1bx, f1by = humanFleet2base:getPosition()
	humanFleet2, humanFleet2Power = spawnEnemyFleet(f1bx, f1by, humanFleet2Power, 1, humanFaction)
	for _, enemy in ipairs(humanFleet2) do
		enemy:orderDefendTarget(humanFleet2base):setScanned(true)
	end
	table.insert(humanFleetList,humanFleet2)
	humanResource = humanResource - humanFleet2Power
	if humanResource > 60 then
		humanFleet3Power = random(40,60)
	else
		humanFleet3Power = 60
	end
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= humanFleet1base and candidate ~= humanFleet2base then
			humanFleet3base = candidate
		end
	until(humanFleet3base ~= nil)
	local f1bx, f1by = humanFleet3base:getPosition()
	humanFleet3, humanFleet3Power = spawnEnemyFleet(f1bx, f1by, humanFleet3Power, 1, humanFaction)
	for _, enemy in ipairs(humanFleet3) do
		enemy:orderDefendTarget(humanFleet3base):setScanned(true)
	end
	table.insert(humanFleetList,humanFleet3)
	humanResource = humanResource - humanFleet3Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= humanFleet1base and candidate ~= humanFleet2base and candidate ~= humanFleet3base then
			humanFleet4base = candidate
		end
	until(humanFleet4base ~= nil)
	local f1bx, f1by = humanFleet4base:getPosition()
	humanFleet4, humanFleet4Power = spawnEnemyFleet(f1bx, f1by, humanResource/2, 1, humanFaction)
	for _, enemy in ipairs(humanFleet4) do
		enemy:orderDefendTarget(humanFleet4base):setScanned(true)
	end
	table.insert(humanFleetList,humanFleet4)
	humanResource = humanResource - humanFleet4Power
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= humanFleet1base and candidate ~= humanFleet2base and candidate ~= humanFleet3base and candidate ~= humanFleet4base then
			humanFleet5base = candidate
		end
	until(humanFleet5base ~= nil)
	local f1bx, f1by = humanFleet5base:getPosition()
	humanFleet5, humanFleet5Power = spawnEnemyFleet(f1bx, f1by, humanResource, 1, humanFaction)
	for _, enemy in ipairs(humanFleet5) do
		enemy:orderDefendTarget(humanFleet5base):setScanned(true)
	end
	table.insert(humanFleetList,humanFleet5)
end
function spawnEnemyFleet(xOrigin, yOrigin, power, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = kraylorFaction
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
		if enemyFaction == kraylorFaction then
			rawKraylorShipStrength = rawKraylorShipStrength + stsl[shipTemplateType]
			ship:onDestruction(kraylorVesselDestroyed)
		elseif enemyFaction == humanFaction then
			rawHumanShipStrength = rawHumanShipStrength + stsl[shipTemplateType]
			ship:onDestruction(humanVesselDestroyed)
		elseif enemyFaction == exuariFaction then
			rawExuariShipStrength = rawExuariShipStrength + stsl[shipTemplateType]
			ship:onDestruction(exuariVesselDestroyed)
		elseif enemyFaction == arleniansFaction then
			rawArlenianShipStrength = rawArlenianShipStrength + stsl[shipTemplateType]
			ship:onDestruction(arlenianVesselDestroyed)
		elseif enemyFaction == neutralFaction then
			rawNeutralShipStrength = rawNeutralShipStrength + stsl[shipTemplateType]
			ship:onDestruction(neutralVesselDestroyed)
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
            reinforcements = math.random(125,175),
            phobosReinforcements = math.random(200,250),
            stalkerReinforcements = math.random(275,325)
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
	local missile_types = {homing, nuke, mine, emp, hvli}
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
				if player:getWeaponStorageMax(nuke) > 0 then
					if comms_target.nukeAvail then
						if math.random(1,10) <= 5 then
							nukePrompt = "Can you supply us with some nukes? ("
						else
							nukePrompt = "We really need some nukes ("
						end
						addCommsReply(nukePrompt .. getWeaponCost(nuke) .. " rep each)", function()
							handleWeaponRestock(nuke)
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if player:getWeaponStorageMax(emp) > 0 then
					if comms_target.empAvail then
						if math.random(1,10) <= 5 then
							empPrompt = "Please re-stock our EMP missiles. ("
						else
							empPrompt = "Got any EMPs? ("
						end
						addCommsReply(empPrompt .. getWeaponCost(emp) .. " rep each)", function()
							handleWeaponRestock(emp)
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if player:getWeaponStorageMax(homing) > 0 then
					if comms_target.homeAvail then
						if math.random(1,10) <= 5 then
							homePrompt = "Do you have spare homing missiles for us? ("
						else
							homePrompt = "Do you have extra homing missiles? ("
						end
						addCommsReply(homePrompt .. getWeaponCost(homing) .. " rep each)", function()
							handleWeaponRestock(homing)
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if player:getWeaponStorageMax(mine) > 0 then
					if comms_target.mineAvail then
						if math.random(1,10) <= 5 then
							minePrompt = "We could use some mines. ("
						else
							minePrompt = "How about mines? ("
						end
						addCommsReply(minePrompt .. getWeaponCost(mine) .. " rep each)", function()
							handleWeaponRestock(mine)
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if player:getWeaponStorageMax(hvli) > 0 then
					if comms_target.hvliAvail then
						if math.random(1,10) <= 5 then
							hvliPrompt = "What about HVLI? ("
						else
							hvliPrompt = "Could you provide HVLI? ("
						end
						addCommsReply(hvliPrompt .. getWeaponCost(hvli) .. " rep each)", function()
							handleWeaponRestock(hvli)
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
	if comms_target == professorStation then
		if professorSearch and not professorProvidedPlans then
			addCommsReply("Tell me about Gregory Unruh", function()
				setCommsMessage("He's a retired scientist here. He's on C deck if you'd like to visit")
				addCommsReply("Visit Gregory Unruh on C deck", function()
					setCommsMessage("[Gregory Unruh] What can I do for you?")
					addCommsReply("We need your plans for a doomsday device defense mechanism", function()
						setCommsMessage("Ah, I see someone is taking my research seriously. Here is my incomplete prototype along with the plans. You'll notice that certain components are still required.")
						professorProvidedPlans = true
						player.professor = true
					end)
				end)
			end)
		end
	end
	if comms_target == doctorStation then
		if doctorSearch and not doctorAssisting then
			addCommsReply("Tell me about Morrigan Thultris", function()
				setCommsMessage("She does medical research here")
				addCommsReply("May I speak with her?", function()
					setCommsMessage("She won't come to the communications nexus, but you may visit her in her quarters")
						addCommsReply("Visit Dr. Thultris", function()
							setCommsMessage("[Dr. Thultris behind closed quarters door]\nWho is it?")
							addCommsReply(string.format("I am an officer from the Human Navy ship, %s", player:getCallSign()), function()
								setCommsMessage("[Dr. Thultris behind closed quarters door]\nWhat do you want?")
								addCommsReply("We need your help", function()
									if random(1,4) + doctorRejectionCount >= 3 then
										setCommsMessage("[Dr. Thultris opens her door]\nWith what?")
										addCommsReply("Grab Dr. Thultris", function()
											if random(1,4) >= 3 then
												setCommsMessage("As you pull her down the corridor back to the ship, explaining why you've come for her, she protests initially then eventually runs back with you, convinced of the urgency of the situation")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("She slams the door in your face as you reach for her")
												doctorRejectionCount = 0
											end
										end)
										addCommsReply("A dying patient needs your expertise", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] Then let's get going to help the patient\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("People die all the time\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
										addCommsReply("An Arlenian Admiral shows symptoms like those you published", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] Take me to the admiral\n\nAs you both return to the ship, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("An Arlenian Admiral? Who cares!\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
									else
										setCommsMessage("[Dr. Thultris behind closed quarters door]\nGo away, I'm busy")
										doctorRejectionCount = doctorRejectionCount + 1
									end
								end)
								addCommsReply("Medical team suggested your research for a patient", function()
									if random(1,4) + doctorRejectionCount >= 3 then
										setCommsMessage("[Dr. Thultris opens her door]\nHow does my research apply to a patient?")
										addCommsReply("Grab Dr. Thultris", function()
											if random(1,4) >= 3 then
												setCommsMessage("As you pull her down the corridor back to the ship, explaining why you've come for her, she protests initially then eventually runs back with you, convinced of the urgency of the situation")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("She slams the door in your face as you reach for her")
												doctorRejectionCount = 0
											end
										end)
										addCommsReply("The symptoms closely correlate to your research", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] I think I can help\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("Let me know what happens with the patient\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
										addCommsReply("Your research may save an Arlenian Admiral's life", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] I would love to apply my research\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("Diplomacy and military matters bore me\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
									else
										setCommsMessage("[Dr. Thultris behind closed quarters door]\nThat's nice. Leave me alone")
										doctorRejectionCount = doctorRejectionCount + 1
									end
								end)
								addCommsReply("Arlenian with an unusual disease is near death", function()
									if random(1,4) + doctorRejectionCount >= 3 then
										setCommsMessage("[Dr. Thultris opens her door]\nWhy come to me?")
										addCommsReply("Grab Dr. Thultris", function()
											if random(1,4) >= 3 then
												setCommsMessage("As you pull her down the corridor back to the ship, explaining why you've come for her, she protests initially then eventually runs back with you, convinced of the urgency of the situation")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("She slams the door in your face as you reach for her")
												doctorRejectionCount = 0
											end
										end)
										addCommsReply("The Arlenian medical team referred us to you", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] Nice to be recognized outside of human space\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("What do the Arlenians know?\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
										addCommsReply("Your research accurately describes the symptoms", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] I would like to see the patient\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("Coincidental, I'm sure\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
									else
										setCommsMessage("[Dr. Thultris behind closed quarters door]\nMy condolences. Goodbye")
										doctorRejectionCount = doctorRejectionCount + 1
									end
								end)
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("I am an admirer of your research and have questions", function()
								setCommsMessage("[Dr. Thultris behind closed quarters door]\nReally? What is it about my research you admire?")
								addCommsReply("The depth of your most recent publication", function()
									if random(1,4) + doctorRejectionCount >= 3 then
										setCommsMessage("[Dr. Thultris opens her door]\nWhy does this research interest you?")
										addCommsReply("Grab Dr. Thultris", function()
											if random(1,4) >= 3 then
												setCommsMessage("As you pull her down the corridor back to the ship, explaining why you've come for her, she protests initially then eventually runs back with you, convinced of the urgency of the situation")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("She slams the door in your face as you reach for her")
												doctorRejectionCount = 0
											end
										end)
										addCommsReply("I know of a patient that might benefit", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] Those are rare. May I see the patient?\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("My research is unlikely to apply\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
										addCommsReply("Your research could help a sick Arlenian Admiral", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] I would like to see my research in the Arlenian context\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("I don't think it applies to Arlenians\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
									else
										setCommsMessage("[Dr. Thultris behind closed quarters door]\nPublish a review and we'll talk")
										doctorRejectionCount = doctorRejectionCount + 1
									end
								end)
								addCommsReply("The breadth of knowledge you demonstrate", function()
									if random(1,4) + doctorRejectionCount >= 3 then
										setCommsMessage("[Dr. Thultris opens her door]\nI doubt that. Why are you *really* here?")
										addCommsReply("Grab Dr. Thultris", function()
											if random(1,4) >= 3 then
												setCommsMessage("As you pull her down the corridor back to the ship, explaining why you've come for her, she protests initially then eventually runs back with you, convinced of the urgency of the situation")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("She slams the door in your face as you reach for her")
												doctorRejectionCount = 0
											end
										end)
										addCommsReply("We need your help with a dying Arlenian Admiral", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] Why didn't you say so? Of course I'll help\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("Your first story was better\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
										addCommsReply("An Arlenian medical team thinks you can help a dying patient", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] That's reasonable. Let's go\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("I'm not concerned with Arlenian patients\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
									else
										setCommsMessage("[Dr. Thultris behind closed quarters door]\nFaint praise insults me. Go away")
										doctorRejectionCount = doctorRejectionCount + 1
									end
								end)
								addCommsReply("Your superb publication presentation", function()
									if random(1,4) + doctorRejectionCount >= 3 then
										setCommsMessage("[Dr. Thultris opens her door]\nHa! Is that why you're here?")
										addCommsReply("Grab Dr. Thultris", function()
											if random(1,4) >= 3 then
												setCommsMessage("As you pull her down the corridor back to the ship, explaining why you've come for her, she protests initially then eventually runs back with you, convinced of the urgency of the situation")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("She slams the door in your face as you reach for her")
												doctorRejectionCount = 0
											end
										end)
										addCommsReply("Not really. We need your help", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] Why didn't you say so? Of course I'll help\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("I'm sorry, but I'm too busy right now\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
										addCommsReply("Of course! I've got a case study for you to examine", function()
											if random(1,4) + doctorRejectionCount >= 3 then
												setCommsMessage("[Dr. Thultris] An application for my research?! Goody Goody!\n\nAs you both return, you explain the situation to her")
												player.doctorAboard = true
												doctorAssisting = true
											else
												setCommsMessage("Sound interesteing, but not right now, thanks\n[Dr. Thultris closes her door]")
												doctorRejectionCount = doctorRejectionCount + 1
											end
										end)
									else
										setCommsMessage("[Dr. Thultris behind closed quarters door]\nGet a writing advisor and get out of here")
										doctorRejectionCount = doctorRejectionCount + 1
									end									
								end)
								addCommsReply("Back", commsStation)
							end)
							addCommsReply("Back", commsStation)
						end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		end
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
	if comms_target:getFaction() == arleniansFaction then
		if scarceResources then
			addCommsReply("Where is Bespin?", function()
				if stationCloudCity ~= nil and stationCloudCity:isValid() and stationCloudCity:areEnemiesInRange(30000) then
					setCommsMessage(string.format("Bespin is in %s and enemies are within 30U of Cloud City",planetBespin:getSectorName()))
				else
					setCommsMessage(string.format("Bespin is in %s",planetBespin:getSectorName()))
				end
				addCommsReply("Back", commsStation)
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
function setSecondaryOrders()
	secondaryOrders = ""
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
        if weapon == nuke then setCommsMessage("We do not deal in weapons of mass destruction.")
        elseif weapon == emp then setCommsMessage("We do not deal in weapons of mass disruption.")
        else setCommsMessage("We do not deal in those weapons.") end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local scarcity = 1
    scarcityMsg = " The Kraylor threat to mineral resources has reduced ordnance availablilty"
    if scarceResources then
    	scarcityMsg = ""
    	scarcity = .5
    end
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()] * scarcity) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == nuke then
            setCommsMessage("All nukes are charged and primed for destruction." .. scarcityMsg);
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow." .. scarcityMsg);
        end
        addCommsReply("Back", commsStation)
    else
		if player:getReputationPoints() > points_per_item * item_amount then
			if player:takeReputationPoints(points_per_item * item_amount) then
				player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
				if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things.")
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use." .. scarcityMsg)
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
		if comms_target:getFaction() == arleniansFaction then
			if scarceResources then
				addCommsReply("Where is Bespin?", function()
					setCommsMessage(string.format("Bespin is in %s",planetBespin:getSectorName()))
					addCommsReply("Back", commsStation)
				end)
			end
		end
		if comms_target == professorStation then
			addCommsReply("Tell me about Gregory Unruh", function()
				setCommsMessage("He's got nice retirement quarters here")
				addCommsReply("May we speak with him?", function()
					setCommsMessage("He won't talk with anyone from the Human Navy. He's still bitter over early retirement. You'll need to visit in person")
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_target == doctorStation then
			addCommsReply("Tell me about Morrigan Thultris", function()
				setCommsMessage("She does research here")
				addCommsReply("We need her skills. May I speak with her?", function()
					setCommsMessage("She refuses to come to the communications nexus except on her terms. This usually means only outgoing communications. There is a very short list of contacts she will respond to and you are not on that list. If you wish to speak with her, you will need to dock and visit in person")
						addCommsReply("The Arlenian Admiral is critically ill and she could help", function()
							setCommsMessage("There could be a deadly plague covering all of Human and Arlenian space and she would remain in her quarters tending to her research until the plague destroyed all other personnel on the station. Even then, it might take her a few days to realize everyone else was dead. You really will need to dock to talk to her")
							addCommsReply("Back", commsStation)
						end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
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
		end
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
        addCommsReply("Please send Adder MK5 reinforcements! ("..getServiceCost("reinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if player:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
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
        addCommsReply("Please send Phobos T3 reinforcements! ("..getServiceCost("phobosReinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if player:takeReputationPoints(getServiceCost("phobosReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate(phobosT3):setScanned(true):orderDefendLocation(player:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
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
        addCommsReply("Please send Stalker Q7 reinforcements! ("..getServiceCost("stalkerReinforcements").."rep)", function()
            if player:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request reinforcements.");
            else
                setCommsMessage("To which waypoint should we dispatch the reinforcements?");
                for n=1,player:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if player:takeReputationPoints(getServiceCost("stalkerReinforcements")) then
							ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate(stalkerQ7):setScanned(true):orderDefendLocation(player:getWaypoint(n))
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(humanVesselDestroyed)
							table.insert(friendlyHelperFleet,ship)
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
end
function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
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
					comms_target:orderDefendLocation(player:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
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

		local missile_types = {homing, nuke, mine, emp, hvli}
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
		if faction == kraylorFaction then
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
		elseif faction == arleniansFaction then
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == exuariFaction then
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == gitmFaction then
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == hiveFaction then
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
	if comms_target:getFaction() == arleniansFaction then
		if scarceResources then
			addCommsReply("Where is Bespin?", function()
				setCommsMessage(string.format("Bespin is in %s",planetBespin:getSectorName()))
				addCommsReply("Back", commsStation)
			end)
		end
	end
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
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = kraylorFaction
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
		if enemyFaction == kraylorFaction then
			rawKraylorShipStrength = rawKraylorShipStrength + stsl[shipTemplateType]
			ship:onDestruction(kraylorVesselDestroyed)
		elseif enemyFaction == humanFaction then
			rawHumanShipStrength = rawHumanShipStrength + stsl[shipTemplateType]
			ship:onDestruction(humanVesselDestroyed)
		elseif enemyFaction == exuariFaction then
			rawExuariShipStrength = rawExuariShipStrength + stsl[shipTemplateType]
			ship:onDestruction(exuariVesselDestroyed)
		elseif enemyFaction == arleniansFaction then
			rawArlenianShipStrength = rawArlenianShipStrength + stsl[shipTemplateType]
			ship:onDestruction(arlenianVesselDestroyed)
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
--		Coolant buttons and functions
function coolantNebulae(delta)
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local inside_gain_coolant_nebula = false
			for i=1,#coolant_nebula do
				if distance(p,coolant_nebula[i]) < 5000 then
					if coolant_nebula[i].lose then
						p:setMaxCoolant(p:getMaxCoolant()*coolant_loss)
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
--[[-----------------------------------------------------------------
    Timed game plot
-----------------------------------------------------------------]]--
function timedGame(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		missionVictory = true
		missionCompleteReason = string.format("Player survived for %i minutes",defaultGameTimeLimitInMinutes)
		endStatistics()
		victory(humanFaction)
	end
end
--[[-----------------------------------------------------------------
    Manage plots
-----------------------------------------------------------------]]--
function setPlots()
	plotList = {miningConflict, sickArlenianAdmiral, doomsday}
	maxPlotCount = #plotList
end
function plotDelay(delta)
	if plotDelayTimer == nil then
		plotDelayTimer = delta + random(10,30)
	end
	plotDelayTimer = plotDelayTimer - delta
	if plotDelayTimer < 0 then
		plotDelayTimer = nil
		plotManager = plotChoose
	end
end
function plotChoose(delta)
	if onlyOneMission then
		if #plotList < maxPlotCount then
			missionCompleteReason = string.format("Single selected mission completed",defaultGameTimeLimitInMinutes)
			missionVictory = true
			endStatistics()
			victory(humanFaction)
		else
			plotManager = plotRun
			plotChoice = math.random(1,#plotList)
			plot1 = plotList[plotChoice]
			table.remove(plotList,plotChoice)
		end
	else
		if #plotList < 1 then
			missionCompleteReason = string.format("All missions completed",defaultGameTimeLimitInMinutes)
			missionVictory = true
			endStatistics()
			victory(humanFaction)
		else
			plotManager = plotRun
			if nextPlot == nil then
				plotChoice = math.random(1,#plotList)
				plot1 = plotList[plotChoice]
				table.remove(plotList,plotChoice)
			else
				plot1 = nextPlot
				nextPlot = nil
				for i=1,#plotList do
					if plotList[i] == nextPlot then
						table.remove(plotList,i)
					end
				end
			end
		end
	end
end
function plotRun(delta)
	if plot1 == nil then
		plotManager = plotDelay
	end
end
--[[-----------------------------------------------------------------
    Doomsday device
-----------------------------------------------------------------]]--
function startDoomsday()
	setUpDoomsday = "done"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog("Intelligence tells us the Exuari have nearly completed a 'doomsday' device. Retired scientist, Gregory Unruh warned us before he retired about this possibility, but we did not take him seriously. He was working on a defense mechanism. Find professor Unruh and get the plans for his defense mechanism","Magenta")
		end
	end
	primaryOrders = "Find professor Unruh for doomsday defense mechanism plans"
	local professorStationAttemptCount = 0
	repeat
		professorStation = humanStationList[math.random(1,#humanStationList)]
		professorStationAttemptCount = professorStationAttemptCount + 1
	until((professorStation ~= nil and professorStation:isValid()) or professorStationAttemptCount > repeatExitBoundary)
	if professorStationAttemptCount > repeatExitBoundary then
		if professorDiagnostic then print("bad professor station") end
		plot1 = nil
		primaryOrders = ""
	else
		if professorDiagnostic then print("professor station set") end
		professorSearch = true
		professorProvidedPlans = false
		componentsPicked = false
		defenseDeployed = false
		doomsdayDeployed = false
	end
	for i=1,3 do
		local clueStationAttemptCount = 0
		repeat
			clueStation = humanStationList[math.random(1,#humanStationList)]
			clueStationAttemptCount = clueStationAttemptCount + 1
		until((clueStation ~= nil and clueStation:isValid() and clueStation ~= professorStation and (clueStation.character == nil or clueStation.character == "Morrigan Thultris")) or clueStationAttemptCount > repeatExitBoundary)
		if clueStationAttemptCount < repeatExitBoundary then
			clueStation.character = "Gregory Unruh"
			clueStation.characterDescription = string.format("Gregory Unruh resides on station %s",professorStation:getCallSign())
		end
	end
	if professorDiagnostic then print("done with doomsday setup") end
	removeGMFunction(GMDoomsday)
end
function doomsday(delta)
	if setUpDoomsday == nil then
		startDoomsday()
	end
	doomsdayTimer = 800 - difficulty*150
	halfDoom = doomsdayTimer/2
	quarterDoom = halfDoom/2
	plot1 = checkDoomsdayEvents
end
function checkDoomsdayEvents(delta)
	doomsdayTimer = doomsdayTimer - delta
	if doomsdayTimer < quarterDoom then
		if exuariRampage == nil then
			exuariRampage = "launched"
			for _, enemy in ipairs(exuariFleet4) do
				enemy:orderRoaming()
			end
			for _, enemy in ipairs(exuariFleet5) do
				enemy:orderRoaming()
			end
			for _, enemy in ipairs(kraylorFleet2) do
				enemy:orderRoaming()
			end
			for _, enemy in ipairs(kraylorFleet3) do
				enemy:orderRoaming()
			end
			for _, enemy in ipairs(kraylorFleet4) do
				enemy:orderRoaming()
			end
			for _, enemy in ipairs(kraylorFleet5) do
				enemy:orderRoaming()
			end
			local pillageAttempt = 0
			repeat
				humanPillageTarget = humanStationList[math.random(1,#humanStationList)]
				pillageAttempt = pillageAttempt + 1
			until((humanPillageTarget ~= nil and humanPillageTarget:isValid()) or pillageAttempt > repeatExitBoundary)
			if pillageAttempt <= repeatExitBoundary then
				local tx, ty = humanPillageTarget:getPosition()
				local ox, oy = vectorFromAngle(random(0,360),random(20000,30000))
				pillageFleet = spawnEnemies(tx+ox,ty+oy,1,exuariFaction)
				for _, enemy in ipairs(pillageFleet) do
					enemy:orderFlyTowards(tx, ty)
				end
				table.insert(exuariFleetList,pillageFleet)
				local pillageAttempt = 0
				repeat
					humanPillageTarget2 = humanStationList[math.random(1,#humanStationList)]
					pillageAttempt = pillageAttempt + 1
				until((humanPillageTarget2 ~= nil and humanPillageTarget2:isValid() and humanPillageTarget ~= humanPillageTarget2) or pillageAttempt > repeatExitBoundary)
				if pillageAttempt <= repeatExitBoundary then
					local tx, ty = humanPillageTarget2:getPosition()
					local ox, oy = vectorFromAngle(random(0,360),random(20000,30000))
					pillageFleet = spawnEnemies(tx+ox,ty+oy,1,exuariFaction)
					for _, enemy in ipairs(pillageFleet) do
						enemy:orderFlyTowards(tx, ty)
					end
					table.insert(exuariFleetList,pillageFleet)
				end
			end
		end
	end
	if doomsdayTimer < halfDoom then
		if doomsdayWarning == nil then
			doomsdayWarning = "sent"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("Intelligence estimates %i minutes remain before the Exuari deploy the doomsday device. Exuari and Kraylors both seem to be on a pillaging rampage",math.floor(doomsdayTimer/60)),"Magenta")
				end
			end
		end
	end
	if professorProvidedPlans then
		if componentsPicked then
			primaryOrders = string.format("Get %s, %s and %s to build doomsday defense mechanism",component1,component2,component3)
			if componentMessage1 == nil then
				componentMessage1 = "sent"
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() and p.professor then
						p:addToShipLog(string.format("The instructions list %s, %s and %s as necessary components",component1,component2,component3),"Magenta")
					end
				end
				notesMarker = doomsdayTimer - 30
			end
			if componentMessage2 == nil and doomsdayTimer < notesMarker then
				componentMessage2 = "sent"
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() and p.professor then
						p:addToShipLog(string.format("Further inspection of Gregory Unruh's plans reveal notes in the margin: %s on %s, %s on %s, %s on %s",component1,component1Base:getCallSign(),component2,component2Base:getCallSign(),component3,component3Base:getCallSign()),"Magenta")
					end
				end
			end
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.professor then
					local gi = 1
					local part1Quantity = 0
					local part2Quantity = 0
					local part3Quantity = 0
					if professorDiagnostic then print("check for defense goods") end
					repeat
						if goods[p][gi][1] == component1 then
							part1Quantity = goods[p][gi][2]
						end
						if goods[p][gi][1] == component2 then
							part2Quantity = goods[p][gi][2]
						end
						if goods[p][gi][1] == component3 then
							part3Quantity = goods[p][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if part1Quantity > 0 and part2Quantity > 0 and part3Quantity > 0 then
						decrementPlayerGoods(component1)
						decrementPlayerGoods(component2)
						decrementPlayerGoods(component3)
						player.cargo = player.cargo + 3
						p:addToShipLog("With all three components obtained, Engineering and Science quickly complete and deploy the doomsday device defense mechanism","magenta")
						plot1 = nil
						defenseDeployed = true
						primaryOrders = ""
						if p.doomsday_status ~= nil then
							p:removeCustom(p.doomsday_status)
							p.doomsday_status = nil
						end
						if p.doomsday_status_plus ~= nil then
							p:removeCustom(p.doomsday_status_plus)
							p.doomsday_status_plus = nil
						end
					end
				end
			end
		else
			pickComponents()		
		end
	end
	if doomsdayTimer < 0 then
		if doomsdayDeployed then
			local dTarg = doomsdayBlackHole.target
			if defenseDeployed then
				doomsdayBlackHole:destroy()
			else
				repositionDelay = repositionDelay - delta
				if repositionDelay < 0 then
					if dTarg ~= nil then
						if dTarg:isValid() then
							if distance(dTarg,doomsdayBlackHole) > 4500 then
								if professorDiagnostic then print("move doomsday device") end
								local dx, dy = doomsdayBlackHole:getPosition()
								local tx, ty = dTarg:getPosition()
								doomsdayBlackHole:setPosition((dx+tx)/2,(dy+ty)/2)
							end
						else
							getNextDoomsdayTarget()
						end
					else
						getNextDoomsdayTarget()
					end
					repositionDelay = delta + 5
				end
			end
		else
			repositionDelay = delta + 5
			if professorDiagnostic then print("deploy doomsday device") end
			doomsdayBlackHole = BlackHole()
			doomsdayBlackHole.target = humanStationList[math.random(1,#humanStationList)]
			doomsdayDeployed = true
		end
	end
	local doomsday_status = "Doomsday Device"
	if doomsdayTimer < 0 then
		doomsday_status = "Doomsday Device Built"
	else
		local doomsday_minutes = math.floor(doomsdayTimer / 60)
		local doomsday_seconds = math.floor(doomsdayTimer % 60)
		doomsday_status = "Doomsday Device"
		if doomsday_minutes <= 0 then
			doomsday_status = string.format("%s: %i",doomsday_status,doomsday_seconds)
		else
			doomsday_status = string.format("%s: %i:%.2i",doomsday_status,doomsday_minutes,doomsday_seconds)
		end
	end
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:hasPlayerAtPosition("Engineering") then
				p.doomsday_status = "doomsday_status"
				p:addCustomInfo("Engineering",p.doomsday_status,doomsday_status)
			end
			if p:hasPlayerAtPosition("Engineering+") then
				p.doomsday_status_plus = "doomsday_status_plus"
				p:addCustomInfo("Engineering+",p.doomsday_status_plus,doomsday_status)
			end
		end
	end
end
function getNextDoomsdayTarget()
	if professorDiagnostic then print("pick next doomsday target") end
	tempHumanStationList = {}
	for _, hStation in ipairs(humanStationList) do
		if hStation ~= nil and hStation:isValid() then
			table.insert(tempHumanStationList,hStation)
		end
	end
	if professorDiagnostic then print("use fresh human station list") end
	humanStationList = tempHumanStationList
	if #humanStationList < 1 then
		missionCompleteReason = "All human stations destroyed"
		missionVictory = false
		endStatistics()
		victory(exuariFaction)
	else
--		doomsdayBlackHole.target = humanStationList[math.random(1,#humanStationList)]
		doomsdayBlackHole.target = nearStations(doomsdayBlackHole,humanStationList)
	end
	if professorDiagnostic then print("done picking next doomsday target") end
end
function pickComponents()
	local attemptCount = 0
	repeat
		candidate = humanStationList[math.random(1,#humanStationList)]
		if candidate ~= nil and candidate:isValid() then
			if #goods[candidate] > 0 then
				gi = 1
				repeat
					if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" and goods[candidate][gi][1] ~= "luxury" then
						component1Base = candidate
						component1 = goods[candidate][gi][1]
						gi = #goods[candidate]	--exit repeat loop
					end
					gi = gi + 1
				until(gi > #goods[candidate])
			end
		end
		attemptCount = attemptCount + 1
	until(component1Base ~= nil or attemptCount > repeatExitBoundary)
	if component1Base ~= nil then
		local attemptCount = 0
		repeat
			candidate = humanStationList[math.random(1,#humanStationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= component1Base then
				if #goods[candidate] > 0 then
					gi = 1
					repeat
						if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" and goods[candidate][gi][1] ~= "luxury" and goods[candidate][gi][1] ~= component1 then
							component2Base = candidate
							component2 = goods[candidate][gi][1]
							gi = #goods[candidate]	--exit repeat loop
						end
						gi = gi + 1
					until(gi > #goods[candidate])
				end
			end
			attemptCount = attemptCount + 1
		until(component2Base ~= nil or attemptCount > repeatExitBoundary)
		if component2Base ~= nil then
			local attemptCount = 0
			repeat
				candidate = humanStationList[math.random(1,#humanStationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= component1Base and candidate ~= component2Base then
					if #goods[candidate] > 0 then
						gi = 1
						repeat
							if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" and goods[candidate][gi][1] ~= "luxury" and goods[candidate][gi][1] ~= component1 and goods[candidate][gi][1] ~= component2 then
								component3Base = candidate
								component3 = goods[candidate][gi][1]
								gi = #goods[candidate]	--exit repeat loop
							end
							gi = gi + 1
						until(gi > #goods[candidate])
					end
				end
				attemptCount = attemptCount + 1
			until(component3Base ~= nil or attemptCount > repeatExitBoundary)
			if component3Base ~= nil then
				componentsPicked = true
			else
				plot1 = nil
				primaryOrders = ""
				professorSearch = false
				return			
			end
		else
			plot1 = nil
			primaryOrders = ""
			professorSearch = false
			return
		end
	else
		plot1 = nil
		primaryOrders = ""
		professorSearch = false
		return
	end
end
--[[-----------------------------------------------------------------
    Sick Arlenian Admiral plot
-----------------------------------------------------------------]]--
function startSickArlenianAdmiral()
	setUpSickArlenianAdmiral = "done"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog("Our allies, the Arlenians tell us that Admiral Koshenz has contracted a severe disease. The Arlenian doctors have struggled for days with the disease with minimal change in his condition. They fear he does not have much longer to live. They have asked for assistance from any Human researchers in Arlenian disease. One of their medical team referred to a Dr. Morrigan Thultris who recently published information regarding a disease that shares symptoms and characteristics with the admiral's affliction. Dr. Thultris does not show up on our military registry implying she works in relative seclusion. Search the Human Navy stations and find her and enlist her aid if applicable. Do it quickly, Admiral Koshenz likely does not have long to live","Magenta")
		end
	end
	primaryOrders = "Find Dr. Thultris for help with Arlenian Admiral Koshenz"
	local doctorStationAttemptCount = 0
	repeat
		doctorStation = humanStationList[math.random(1,#humanStationList)]
		doctorStationAttemptCount = doctorStationAttemptCount + 1
	until((doctorStation ~= nil and doctorStation:isValid()) or doctorStationAttemptCount > repeatExitBoundary)
	if doctorStationAttemptCount > repeatExitBoundary then
		if sickAdmiralDiagnostic then print("bad doctor station") end
		plot1 = nil
		primaryOrders = ""
	else
		if sickAdmiralDiagnostic then print("doctor station set") end
		doctorSearch = true
		doctorAssisting = false
		doctorRejectionCount = 0
	end
	for i=1,3 do
		local clueStationAttemptCount = 0
		repeat
			clueStation = humanStationList[math.random(1,#humanStationList)]
			clueStationAttemptCount = clueStationAttemptCount + 1
		until((clueStation ~= nil and clueStation:isValid() and clueStation ~= doctorStation and (clueStation.character == nil or clueStation.character == "Gregory Unruh")) or clueStationAttemptCount > repeatExitBoundary)
		if clueStationAttemptCount < repeatExitBoundary then
			clueStation.character = "Morrigan Thultris"
			clueStation.characterDescription = string.format("Dr. Thultris resides on station %s",doctorStation:getCallSign())
		end
	end
	if sickAdmiralDiagnostic then print("done with sick admiral setup") end
	removeGMFunction(GMAdmiral)
end
function sickArlenianAdmiral(delta)
	if setUpSickArlenianAdmiral == nil then
		startSickArlenianAdmiral()
	end
	admiralTimeToLive = 700 - difficulty*100
	plot1 = checkSickArlenianAdmiralEvents
end
function checkSickArlenianAdmiralEvents(delta)
	admiralTimeToLive = admiralTimeToLive - delta
	if admiralTimeToLive < 0 then
		missionCompleteReason = "Arlenian Admiral Koshenz dies"
		missionVictory = false
		endStatistics()
		victory(kraylorFaction)
	end
	if admiralTimeToLive < 180 and admiralDyingWarning == nil then
		admiralDyingWarning = "sent"
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog("The Arlenians say that they think the admiral has less than three minutes to live","Magenta")
			end
		end
	end
	if admiralTimeToLive < 250 and kraylorAfterAdmiral == nil then
		kraylorAfterAdmiral = "launched"
		local kafx, kafy = vectorFromAngle(random(borderStartAngle+240,borderStartAngle+270),random(20000,30000))
		local aasx, aasy = arlenianFleet2base:getPosition()
		menaceAdmiralFleet = spawnEnemies(aasx+kafx,aasy+kafy,2,kraylorFaction)
		for _,enemy in ipairs(menaceAdmiralFleet) do
			enemy:orderFlyTowards(aasx,aasy)
		end
	end
	if admiralTimeToLive < 225 and kraylorAdmiralWarning == nil then
		kraylorAdmiralWarning = "sent"
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("The Kraylors seem to have discovered the location of Admiral Koshenz. We detect Kraylor ships en route to %s",arlenianFleet2base:getCallSign()),"Magenta")
			end
		end
	end
	if admiralTimeToLive < 200 and exuariAfterAdmiral == nil then
		exuariAfterAdmiral = "directed"
		local aasx, aasy = arlenianFleet2base:getPosition()
		for _, enemy in ipairs(exuariFleet3) do
			enemy:orderFlyTowards(aasx,aasy)
		end
	end
	if doctorAssisting then
		if admiralLocationMessage == nil then
			admiralLocationMessage = "sent"
			if arlenianFleet2base ~= nil and arlenianFleet2base:isValid() then
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("Admiral Koshenz is on %s in %s",arlenianFleet2base:getCallSign(),arlenianFleet2base:getSectorName()),"Magenta")
					end
				end
				primaryOrders = string.format("Take Dr. Thultris to %s in %s",arlenianFleet2base:getCallSign(),arlenianFleet2base:getSectorName())
			end
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.doctorAboard then
				if p:isDocked(arlenianFleet2base) then
					p:addToShipLog("Dr. Thultris applied her knowledge and Admiral Koshenz is improving","Magenta")
					plot1 = nil
					doctorSearch = false
					primaryOrders = ""
					if p.admiral_status ~= nil then
						p:removeCustom(p.admiral_status)
						p.admiral_status = nil
					end
					if p.admiral_status_operations ~= nil then
						p:removeCustom(p.admiral_status_operations)
						p.admiral_status_operations = nil
					end
				end
			end
		end
	end
	local death_minutes = math.floor(admiralTimeToLive / 60)
	local death_seconds = math.floor(admiralTimeToLive % 60)
	local admiral_status = "Koshenz Death"
	if death_minutes <= 0 then
		admiral_status = string.format("%s: %i",admiral_status,death_seconds)
	else
		admiral_status = string.format("%s: %i:%.2i",admiral_status,death_minutes,death_seconds)
	end
	for pidx=1,8 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:hasPlayerAtPosition("Science") then
				p.admiral_status = "admiral_status"
				p:addCustomInfo("Science",p.admiral_status,admiral_status)
			end
			if p:hasPlayerAtPosition("Operations") then
				p.admiral_status_operations = "admiral_status_operations"
				p:addCustomInfo("Operations",p.admiral_status_operations,admiral_status)
			end
		end
	end
end
--[[-----------------------------------------------------------------
    Mining resource conflict plot
-----------------------------------------------------------------]]--
function startMiningConflict()
	setUpMiningConflict = "done"
	removeGMFunction(GMMining)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog("Our allies, the Arlenians tell us that the Kraylors are attacking the mining facility around the planet Bespin. We rely heavily on that mineral supply for commerce and military operations. Contact the Arlenians and render assistance","Magenta")
		end
	end
	primaryOrders = "Contact Arlenians and render assistance with Kraylor attack"
	bespinX, bespinY = vectorFromAngle(random(borderStartAngle-30,borderStartAngle+30),random(100000,130000))
	planetBespin = Planet():setPosition(bespinX,bespinY):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Bespin")
	planetBespin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription("Gas giant suitable for mining")
	stationCloudCity = SpaceStation():setTemplate(smallStation):setFaction(arleniansFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCloudCity:setPosition(bespinX,bespinY+3000):setCallSign("Cloud City"):setDescription("Bespin Gas Mining")
	ccOrbitDelayInterval = 3						-- Cloud city orbit delay interval
	ccOrbitDelayTimer = ccOrbitDelayInterval		-- Cloud city orbit delay timer
	ccoa = 90										-- cloud city orbit angle
	if miningConflictDiagnostic then print("mining planet and station established") end
	local kmfx, kmfy = vectorFromAngle(random(borderStartAngle+200,borderStartAngle+250),random(30000,50000))
	menaceMiningFleet = spawnEnemies(bespinX+kmfx,bespinY+kmfy,2,kraylorFaction)
	if miningConflictDiagnostic then print("mining menace Kraylor fleet established") end
	for _, enemy in ipairs(menaceMiningFleet) do
		enemy:orderFlyTowards(bespinX,bespinY)
	end
	if miningConflictDiagnostic then print("menacing fleet in flight") end
	table.insert(kraylorFleetList,menaceMiningFleet)
	for _, ally in ipairs(arlenianFleet1) do
		ally:orderDefendTarget(stationCloudCity)
	end
	if miningConflictDiagnostic then print("Arlenian fleet in flight") end
	scarceResources = true
	if miningConflictDiagnostic then print("Done with start mining conflict function") end
	removeGMFunction(GMMining)
end
function miningConflict(delta)
	if setUpMiningConflict == nil then
		startMiningConflict()
	end
	plot1 = checkMiningConflictEvents
end
function checkMiningConflictEvents(delta)
	if stationCloudCity ~= nil and stationCloudCity:isValid() then
		if exuariMiningOpportunity == nil then
			if miningConflictDiagnostic then print("exuari mining opportunity") end
			closestToCC = closestPlayerTo(stationCloudCity)
			if miningConflictDiagnostic then print("closest player chosen") end
			if distance(closestToCC,stationCloudCity) < 30000 then
				if miningConflictDiagnostic then print("player close enough to trigger Exuari activity") end
				exuariMiningOpportunity = "done"
				exuariMiningWarningTimer = delta + 120
				local f1bx, f1by = arlenianFleet1base:getPosition()
				for _, enemy in ipairs(exuariFleet1) do
					enemy:orderFlyTowards(f1bx,f1by)
				end
				humanMiningTargetStation = nearStations(exuariFleet2base, humanStationList)
				if humanMiningTargetStation ~= nil then
					local f1bx, f1by = humanMiningTargetStation:getPosition()
					for _, enemy in ipairs(exuariFleet2) do
						enemy:orderFlyTowards(f1bx,f1by)
					end
				else
					for _, enemy in ipairs(exuariFleet2) do
						enemy:orderRoaming()
					end
				end
			end
		end
		if exuariMiningOpportunity == "done" then
			if exuari2Released == nil then
				if humanMiningTargetStation == nil then
					for _, enemy in ipairs(exuariFleet2) do
						enemy:orderRoaming()
					end
					exuari2Released = "done"
				elseif not humanMiningTargetStation:isValid() then
					for _, enemy in ipairs(exuariFleet2) do
						enemy:orderRoaming()
					end			
					exuari2Released = "done"
				end
			end
		end
		if exuariMiningWarningTimer ~= nil then
			exuariMiningWarningTimer = exuariMiningWarningTimer - delta
			if exuariMiningWarningTimer < 0 then
				if exuariMiningWarning == nil then
					exuariMiningWarning = "sent"
					for pidx=1,8 do
						p = getPlayerShip(pidx)
						if p ~= nil and p:isValid() then
							p:addToShipLog("Looks like the Exuari are taking advantage of the Kraylor mining incident by sending forces against us and the Arlenians","Magenta")
						end
					end
				end
			end
		end
		local menaceMiningFleetCount = 0
		for _, enemy in ipairs(menaceMiningFleet) do
			if enemy ~= nil and enemy:isValid() then
				menaceMiningFleetCount = menaceMiningFleetCount + 1 
			end
		end
		if menaceMiningFleetCount < 1 then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("The Arlenians thanked us for the help with the Kraylors around Cloud City","Magenta")
				end
			end
			scarceResources = false
			plot1 = nil
			primaryOrders = ""
		end
	else
		missionCompleteReason = "Mining station Cloud City destroyed"
		missionVictory = false
		endStatistics()
		victory(kraylorFaction)
	end
end 
function movingObjects(delta)
	if ccOrbitDelayTimer ~= nil then
		ccOrbitDelayTimer = ccOrbitDelayTimer - delta
		if ccOrbitDelayTimer < 0 then
			ccoa = ccoa + 1
			if ccoa >= 360 then
				ccoa = 0
			end
			orbitBx, orbitBy = vectorFromAngle(ccoa,3000)
			stationCloudCity:setPosition(bespinX+orbitBx,bespinY+orbitBy)
			ccOrbitDelayTimer = ccOrbitDelayInterval
		end	
	end
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
end--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
function setPlayers()
	local concurrentPlayerCount = 0
	if setPlayerDiagnostic then print("local concurrent player count: " .. concurrentPlayerCount) end
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			if setPlayerDiagnostic then print("valid player") end
			concurrentPlayerCount = concurrentPlayerCount + 1
			if setPlayerDiagnostic then print("incremented local count") end
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if setPlayerDiagnostic then print("set goods") end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(100-(difficulty*20))
				pobj.initialRep = true
			end
			if setPlayerDiagnostic then print("set reputation") end
			if not pobj.nameAssigned then
				if setPlayerDiagnostic then print("assigning variables for player ship") end
				pobj.nameAssigned = true
				local tempPlayerType = pobj:getTypeName()
				if tempPlayerType == hornetMP52 then
					if #playerShipNamesForMP52Hornet > 0 then
						local ni = math.random(1,#playerShipNamesForMP52Hornet)
						pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
						table.remove(playerShipNamesForMP52Hornet,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == piranha then
					if #playerShipNamesForPiranha > 0 then
						ni = math.random(1,#playerShipNamesForPiranha)
						pobj:setCallSign(playerShipNamesForPiranha[ni])
						table.remove(playerShipNamesForPiranha,ni)
					end
					pobj.shipScore = 16
					pobj.maxCargo = 8
				elseif tempPlayerType == flaviaPFalcon then
					if #playerShipNamesForFlaviaPFalcon > 0 then
						ni = math.random(1,#playerShipNamesForFlaviaPFalcon)
						pobj:setCallSign(playerShipNamesForFlaviaPFalcon[ni])
						table.remove(playerShipNamesForFlaviaPFalcon,ni)
					end
					pobj.shipScore = 13
					pobj.maxCargo = 15
				elseif tempPlayerType == phobosM3P then
					if #playerShipNamesForPhobosM3P > 0 then
						ni = math.random(1,#playerShipNamesForPhobosM3P)
						pobj:setCallSign(playerShipNamesForPhobosM3P[ni])
						table.remove(playerShipNamesForPhobosM3P,ni)
					end
					pobj.shipScore = 19
					pobj.maxCargo = 10
					pobj:setWarpDrive(true)
				elseif tempPlayerType == atlantis then
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
				elseif tempPlayerType == benedict then
					if #playerShipNamesForBenedict > 0 then
						ni = math.random(1,#playerShipNamesForBenedict)
						pobj:setCallSign(playerShipNamesForBenedict[ni])
						table.remove(playerShipNamesForBenedict,ni)
					end
					pobj.shipScore = 10
					pobj.maxCargo = 9
				elseif tempPlayerType == kiriya then
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
				elseif tempPlayerType == lindwormZX then
					if #playerShipNamesForLindworm > 0 then
						ni = math.random(1,#playerShipNamesForLindworm)
						pobj:setCallSign(playerShipNamesForLindworm[ni])
						table.remove(playerShipNamesForLindworm,ni)
					end
					pobj.shipScore = 8
					pobj.maxCargo = 3
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == repulse then
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
				elseif tempPlayerType == hathcock then
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
	return concurrentPlayerCount
end
function kraylorVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(kraylorVesselDestroyedNameList,self:getCallSign())
	table.insert(kraylorVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(kraylorVesselDestroyedValue,stsl[k])
		end
	end
end
function exuariVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(exuariVesselDestroyedNameList,self:getCallSign())
	table.insert(exuariVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(exuariVesselDestroyedValue,stsl[k])
		end
	end
end
function humanVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(humanVesselDestroyedNameList,self:getCallSign())
	table.insert(humanVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(humanVesselDestroyedValue,stsl[k])
		end
	end
end
function arlenianVesselDestroyed(self, instigator)
	tempShipType = self:getTypeName()
	table.insert(arlenianVesselDestroyedNameList,self:getCallSign())
	table.insert(arlenianVesselDestroyedType,tempShipType)
	for k=1,#stnl do
		if tempShipType == stnl[k] then
			table.insert(arlenianVesselDestroyedValue,stsl[k])
		end
	end
end
function humanStationDestroyed(self, instigator)
	table.insert(humanStationDestroyedNameList,self:getCallSign())
	table.insert(humanStationDestroyedValue,self.strength)
end
function kraylorStationDestroyed(self, instigator)
	table.insert(kraylorStationDestroyedNameList,self:getCallSign())
	table.insert(kraylorStationDestroyedValue,self.strength)
end
function exuariStationDestroyed(self, instigator)
	table.insert(exuariStationDestroyedNameList,self:getCallSign())
	table.insert(exuariStationDestroyedValue,self.strength)
end
function arlenianStationDestroyed(self, instigator)
	table.insert(arlenianStationDestroyedNameList,self:getCallSign())
	table.insert(arlenianStationDestroyedValue,self.strength)
end
function listStatuses()
	local humanCountPercentage, humanValuePercentage, kraylorCountPercentage, kraylorValuePercentage, exuariCountPercentage, exuariValuePercentage, arlenianCountPercentage, arlenianValuePercentage, neutralCountPercentage, neutralValuePercentage = stationStatus()
	if humanCountPercentage == nil then
		return nil
	end
	--ship information
	local humanMilitaryShipSurvivedCount = 0
	local humanMilitaryShipSurvivedValue = 0
	for j=1,#humanFleetList do
		local tempFleet = humanFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				humanMilitaryShipSurvivedCount = humanMilitaryShipSurvivedCount + 1
				for k=1,#stnl do
					if tempEnemy:getTypeName() == stnl[k] then
						humanMilitaryShipSurvivedValue = humanMilitaryShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	local kraylorMilitaryShipSurvivedCount = 0
	local kraylorMilitaryShipSurvivedValue = 0
	for j=1,#kraylorFleetList do
		local tempFleet = kraylorFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				kraylorMilitaryShipSurvivedCount = kraylorMilitaryShipSurvivedCount + 1
				for k=1,#stnl do
					if tempEnemy:getTypeName() == stnl[k] then
						kraylorMilitaryShipSurvivedValue = kraylorMilitaryShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	local exuariMilitaryShipSurvivedCount = 0
	local exuariMilitaryShipSurvivedValue = 0
	for j=1,#exuariFleetList do
		local tempFleet = exuariFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				exuariMilitaryShipSurvivedCount = exuariMilitaryShipSurvivedCount + 1
				for k=1,#stnl do
					if tempEnemy:getTypeName() == stnl[k] then
						exuariMilitaryShipSurvivedValue = exuariMilitaryShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	local arlenianMilitaryShipSurvivedCount = 0
	local arlenianMilitaryShipSurvivedValue = 0
	for j=1,#arlenianFleetList do
		local tempFleet = arlenianFleetList[j]
		for _, tempEnemy in ipairs(tempFleet) do
			if tempEnemy ~= nil and tempEnemy:isValid() then
				arlenianMilitaryShipSurvivedCount = arlenianMilitaryShipSurvivedCount + 1
				for k=1,#stnl do
					if tempEnemy:getTypeName() == stnl[k] then
						arlenianMilitaryShipSurvivedValue = arlenianMilitaryShipSurvivedValue + stsl[k]
					end
				end
			end
		end
	end
	local humanMilitaryShipValuePercentage = humanMilitaryShipSurvivedValue/rawHumanShipStrength*100
	local kraylorMilitaryShipValuePercentage = kraylorMilitaryShipSurvivedValue/rawKraylorShipStrength*100
	local exuariMilitaryShipValuePercentage = exuariMilitaryShipSurvivedValue/rawExuariShipStrength*100
	local arlenianMilitaryShipValuePercentage = arlenianMilitaryShipSurvivedValue/rawArlenianShipStrength*100
	return humanCountPercentage, humanValuePercentage, kraylorCountPercentage, kraylorValuePercentage, exuariCountPercentage, exuariValuePercentage, arlenianCountPercentage, arlenianValuePercentage, neutralCountPercentage, neutralValuePercentage, humanMilitaryShipValuePercentage, kraylorMilitaryShipValuePercentage, exuariMilitaryShipValuePercentage, arlenianMilitaryShipValuePercentage
end
function stationStatus()
	local humanSurvivedCount = 0
	local humanSurvivedValue = 0
	local kraylorSurvivedCount = 0
	local kraylorSurvivedValue = 0
	local exuariSurvivedCount = 0
	local exuariSurvivedValue = 0
	local arlenianSurvivedCount = 0
	local arlenianSurvivedValue = 0
	local neutralSurvivedCount = 0
	local neutralSurvivedValue = 0
	for _, station in pairs(stationList) do
		if station:isValid() then
			local tsf = station:getFaction()
			if tsf == humanFaction then
				humanSurvivedCount = humanSurvivedCount + 1
				humanSurvivedValue = humanSurvivedValue + station.strength
			elseif tsf == kraylorFaction then
				kraylorSurvivedCount = kraylorSurvivedCount + 1
				kraylorSurvivedValue = kraylorSurvivedValue + station.strength
			elseif tsf == exuariFaction then
				exuariSurvivedCount = exuariSurvivedCount + 1
				exuariSurvivedValue = exuariSurvivedValue + station.strength
			elseif tsf == arleniansFaction then
				arlenianSurvivedCount = arlenianSurvivedCount + 1
				arlenianSurvivedValue = arlenianSurvivedValue + station.strength
			else
				neutralSurvivedCount = neutralSurvivedCount + 1
				neutralSurvivedValue = neutralSurvivedValue + station.strength
			end
		end
	end
	local humanCountPercentage = humanSurvivedCount/#humanStationList*100
	local humanValuePercentage = humanSurvivedValue/humanStationStrength*100
	local kraylorCountPercentage = kraylorSurvivedCount/#kraylorStationList*100
	local kraylorValuePercentage = kraylorSurvivedValue/kraylorStationStrength*100
	local exuariCountPercentage = exuariSurvivedCount/#exuariStationList*100
	local exuariValuePercentage = exuariSurvivedValue/exuariStationStrength*100
	local arlenianCountPercentage = arlenianSurvivedCount/#arlenianStationList*100
	local arlenianValuePercentage = arlenianSurvivedValue/arlenianStationStrength*100
	if #neutralStationList > 0 then
		local neutralCountPercentage = neutralSurvivedCount/#neutralStationList*100
		local neutralValuePercentage = neutralSurvivedValue/neutralStationStrength*100
	else
		local neutralCountPercentage = -1
		local neutralValuePercentage = -1
	end
	return humanCountPercentage, humanValuePercentage, kraylorCountPercentage, kraylorValuePercentage, exuariCountPercentage, exuariValuePercentage, arlenianCountPercentage, arlenianValuePercentage, neutralCountPercentage, neutralValuePercentage
end
function endStatistics()
	if endStatDiagnostic then print("starting end statistics") end
	local humanCountPercentage, humanValuePercentage, kraylorCountPercentage, kraylorValuePercentage, exuariCountPercentage, exuariValuePercentage, arlenianCountPercentage, arlenianValuePercentage, neutralCountPercentage, neutralValuePercentage, humanMilitaryShipValuePercentage, kraylorMilitaryShipValuePercentage, exuariMilitaryShipValuePercentage, arlenianMilitaryShipValuePercentage = listStatuses()
	if humanCountPercentage == nil then
		globalMessage("statistics unavailable")
		return
	end
	if endStatDiagnostic then print("got statuses")	end
	local gMsg = ""
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Allied stations: Human: survived: %.1f%%, strength: %.1f%%; Arlenian: survived: %.1f%%, strength: %.1f%%\n",humanCountPercentage,humanValuePercentage,arlenianCountPercentage,arlenianValuePercentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Enemy stations: Kraylor: survived: %.1f%%, strength: %.1f%%; Exuari: survived: %.1f%%, strength: %.1f%%\n",kraylorCountPercentage,kraylorValuePercentage,exuariCountPercentage,exuariValuePercentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	if neutralCountPercentage  ~= nil and neutralCountPercentage > 0 then
		gMsg = gMsg .. string.format("Neutral stations: survived: %.1f%%, strength: %.1f%%",neutralCountPercentage,neutralValuePercentage)
	end
	gMsg = gMsg .. "\n\n\n\n"
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	--ship information
	gMsg = gMsg .. string.format("Allied ships: Human: strength: %.1f%%, Arlenian: strength: %.1f%%\n",humanMilitaryShipValuePercentage,arlenianMilitaryShipValuePercentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	gMsg = gMsg .. string.format("Enemy ships: Kraylor: strength: %.1f%%, Exuari: strength: %.1f%%\n",kraylorMilitaryShipValuePercentage,exuariMilitaryShipValuePercentage)
	if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	if endStatDiagnostic then print("set raw stats") end
	local alliedValue = humanValuePercentage/100*.5 + arlenianValuePercentage/100*.25 + humanMilitaryShipValuePercentage/100*.17 + arlenianMilitaryShipValuePercentage/100*.08
	local enemyValue = kraylorValuePercentage/100*.35 + exuariValuePercentage/100*.35 + kraylorMilitaryShipValuePercentage/100*.15 + exuariMilitaryShipValuePercentage/100*.15
	if endStatDiagnostic then print(string.format("Allied value: %.2f, Enemy value: %.2f",alliedValue,enemyValue)) end
	local rankVal = alliedValue*.5 + (1-enemyValue)*.5
	if endStatDiagnostic then print(string.format("rank value: %.2f",rankVal)) end
	if missionCompleteReason ~= nil then
		gMsg = gMsg .. "Mission ended because " .. missionCompleteReason .. "\n"
		if endStatDiagnostic then print("gMsg so far: " .. gMsg) end
	end
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
		if endStatDiagnostic then print("mission victory false or nil") end
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
	if endStatDiagnostic then print("sent to the global message function") end
--	if printDetailedStats then
--		detailedStats()
--		if endStatDiagnostic then print("executed detalied stats function") end
--	end
end
function update(delta)
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if updateDiagnostic then print("set players") end
	local concurrentPlayerCount = setPlayers()
	if updateDiagnostic then print("concurrent player count: " .. concurrentPlayerCount) end
	if concurrentPlayerCount < 1 then
		return
	end
	if updateDiagnostic then print("plotManager") end
	if plotManager ~= nil then
		plotManager(delta)
	end
	if updateDiagnostic then print("plot1") end
	if plot1 ~= nil then	--randomly chosen plot
		plot1(delta)
	end
	if updateDiagnostic then print("plotM") end
	if plotM ~= nil then	--moving objects
		plotM(delta)
	end
	if updateDiagnostic then print("plotCI") end
	if plotCI ~= nil then	--cargo inventory
		plotCI(delta)
	end
	if updateDiagnostic then print("plotH") end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotCN ~= nil then	--coolant via nebula
		plotCN(delta)
	end
end