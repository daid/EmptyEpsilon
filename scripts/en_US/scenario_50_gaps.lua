-- Name: Close the Gaps
-- Description: Using Nautilus class mine layer, lay mines across the space lanes expected to be used by invading enemies
---
--- Mission advice: It's better to hit an asteroid than a mine
-- Type: Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Quixotic]: Practically impossible goals and/or enemies, definitely time consuming
-- Variation[Timed]: Complete the mission in less than 30 minutes
-- Variation[Timed Easy]: Easy goals and/or enemies, Complete the mission in less than 30 minutes
-- Variation[Timed Hard]: Hard goals and/or enemies, Complete the mission in less than 30 minutes
-- Variation[Timed Quixotic]: Practically impossible goals and/or enemies, Complete the mission in less than 30 minutes

require("utils.lua")
require("options.lua")
require(lang .. "/ships.lua")
require(lang .. "/factions.lua")


--[[-------------------------------------------------------------------
	Initialization routines
--]]-------------------------------------------------------------------
function init()
	setVariations()
	missile_types = {homing, nuke, mine, emp, hvli}
	--Ship Template Name List
	stnl = {hornetMT52,hornetMU52,"Adder MK5",adderMK4,lindwormWX,adderMK6,phobosT3,phobosM3,piranhaF8,piranhaF12,ranusU,nirvanaR5A,stalkerQ7,stalkerR7,atlantisX23,starhammerII,odin,"Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer",storm}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	--Player Ship Beams
	psb = {}
	psb[hornetMP52] = 2
	psb[phobosM3P] = 2
	psb[flaviaPFalcon] = 2
	psb[atlantis] = 2
	psb["Player Cruiser"] = 2
	psb["Player Fighter"] = 2
	psb["Striker"] = 2
	psb[lindwormZX] = 1
	psb["Ender"] = 12
	psb[repulse] = 2
	psb[benedict] = 2
	psb[kiriya] = 2
	psb["Nautilus"] = 2
	psb[hathcock] = 4
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
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
	diagnostic = false		
	spawnStrings = {}
	GMDiagnosticOn = "Turn On Diagnostic"
	addGMFunction(GMDiagnosticOn,turnOnDiagnostic)
	interWave = 150
	GMDelayNormalToSlow = "Delay normal to slow"
	addGMFunction(GMDelayNormalToSlow,delayNormalToSlow)
	goods = {}					--overall tracking of goods
	stationList = {}			--friendly and neutral stations
	enemyStationList = {}
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
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
	buildStations()
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
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	transportList = {}
	transportSpawnDelay = 10
	plotT = transportPlot
	plotH = healthCheck
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	px, py = vectorFromAngle(random(0,360),random(2500,3000))
	player = PlayerSpaceship():setFaction(humanFaction):setTemplate("Nautilus"):setPosition(px,py)
	ni = math.random(1,#playerShipNamesForNautilus)
	player:setCallSign(playerShipNamesForNautilus[ni])
	table.remove(playerShipNamesForNautilus,ni)
	player.nameAssigned = true
	player.shipScore = 12
	player.maxCargo = 7
	player.cargo = 7
	player.maxRepairCrew = player:getRepairCrewCount()
	player.healthyShield = 1.0
	player.prevShield = 1.0
	player.healthyReactor = 1.0
	player.prevReactor = 1.0
	player.healthyManeuver = 1.0
	player.prevManeuver = 1.0
	player.healthyImpulse = 1.0
	player.prevImpulse = 1.0
	player.healthyBeam = 1.0
	player.prevBeam = 1.0
	player.healthyMissile = 1.0
	player.prevMissile = 1.0
	player.healthyJump = 1.0
	player.prevJump = 1.0
	player.healthyWarp = 1.0
	player.prevWarp = 1.0
	goods[player] = goodsList
	player:addReputationPoints(100)
	player.initialRep = true
	plot1 = initialInstructions
	initialOrderTimer = 3
	lowerDensity = 70
	upperDensity = 150
	thickness = 2000
	--Arcs
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000,   5,  85, thickness)
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000,  95, 175, thickness)
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000, 185, 265, thickness)
	createRandomAlongArc(Asteroid, random(lowerDensity,upperDensity), 0, 0, 20000, 275, 355, thickness)
	--Bulges
	ax, ay = vectorFromAngle(random(20,70),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	ax, ay = vectorFromAngle(random(110,160),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	ax, ay = vectorFromAngle(random(200,250),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	ax, ay = vectorFromAngle(random(290,340),20000)
	placeRandomAroundPoint(Asteroid,40,1,5000,ax,ay)
	--color
	if not diagnostic then
		createRandomAlongArc(Nebula, difficulty*10, 50000, 50000, 70000, 180, 270, 35000)
	end
	northMineCount = -1
	southMineCount = -1
	eastMineCount = -1
	westMineCount = -1
	northObjCount = -1
	southObjCount = -1
	eastObjCount = -1
	westObjCount = -1
	northClosed = false
	southClosed = false
	eastClosed = false
	westClosed = false
	northMet = false
	southMet = false
	eastMet = false
	westMet = false
	wfv = "end of init"
end
-- Diagnostic enable/disable buttons on GM screen
function turnOnDiagnostic()
	diagnostic = true
	removeGMFunction(GMDiagnosticOn)
	GMDiagnosticOff = "Turn Off Diagnostic"
	addGMFunction(GMDiagnosticOff,turnOffDiagnostic)
end
function turnOffDiagnostic()
	diagnostic = false
	removeGMFunction(GMDiagnosticOff)
	GMDiagnosticOn = "Turn On Diagnostic"
	addGMFunction(GMDiagnosticOn,turnOnDiagnostic)
end
------- In game GM buttons to change the delay between waves -------
-- Default is normal, so the fist button switches from a normal delay to a slow delay.
-- The slow delay is used for typical mission testing when the tester does not wish to
-- spend all their time fighting off enemies.
-- The second button switches from slow to fast. This facilitates testing the enemy
-- spawning routines. The third button goes from fast to normal. 
function delayNormalToSlow()
	interWave = 600
	removeGMFunction(GMDelayNormalToSlow)
	GMDelaySlowToFast = "Delay slow to fast"
	addGMFunction(GMDelaySlowToFast,delaySlowToFast)
end
function delaySlowToFast()
	interWave = 20
	removeGMFunction(GMDelaySlowToFast)
	GMDelayFastToNormal = "Delay fast to normal"
	addGMFunction(GMDelayFastToNormal,delayFastToNormal)
end
function delayFastToNormal()
	interWave = 150
	removeGMFunction(GMDelayFastToNormal)
	GMDelayNormalToSlow = "Delay normal to slow"
	addGMFunction(GMDelayNormalToSlow,delayNormalToSlow)
end
--translate variations into a numeric difficulty value
function setVariations()
	missionLength = 1
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
		gapCheckDelayTimer = 5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
		gapCheckDelayTimer = 15
	elseif string.find(getScenarioVariation(),"Quixotic") then
		difficulty = 3
		gapCheckDelayTimer = 30
		missionLength = 2
	else
		difficulty = 1		--default (normal)
		gapCheckDelayTimer = 10
	end
	gapCheckInterval = gapCheckDelayTimer
	gameTimeLimit = 0
	if string.find(getScenarioVariation(),"Timed") then
		playWithTimeLimit = true
		gameTimeLimit = 30*60		
	else
		playWithTimeLimit = false
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
	if amount == nil then amount = 1 end
	arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			pointDist = distance + random(-randomize,randomize)
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

function buildStations()
	stationFaction = humanFaction
	psx = 0		--place station x coordinate
	psy = 0		--place station y coordinate
	si = math.random(1,#placeStation)	--station index
	pStation = placeStation[si]()		--place selected station
	table.remove(placeStation,si)		--remove station from placement list
	table.insert(stationList,pStation)	--save station in general station list
	homeStation = pStation				--identify home station
	stationFaction = neutralFaction
	psx = 31000
	psy = 31000
	si = math.random(1,#placeStation)	--station index
	pStation = placeStation[si]()		--place selected station
	table.remove(placeStation,si)		--remove station from placement list
	table.insert(stationList,pStation)	--save station in general station list
	psx = -31000
	psy = 31000
	si = math.random(1,#placeStation)	--station index
	pStation = placeStation[si]()		--place selected station
	table.remove(placeStation,si)		--remove station from placement list
	table.insert(stationList,pStation)	--save station in general station list
	psx = 31000
	psy = -31000
	si = math.random(1,#placeStation)	--station index
	pStation = placeStation[si]()		--place selected station
	table.remove(placeStation,si)		--remove station from placement list
	table.insert(stationList,pStation)	--save station in general station list
	psx = -31000
	psy = -31000
	si = math.random(1,#placeStation)	--station index
	pStation = placeStation[si]()		--place selected station
	table.remove(placeStation,si)		--remove station from placement list
	table.insert(stationList,pStation)	--save station in general station list
	stationFaction = kraylorFaction
	psx = 0
	psy = -60000
	si = math.random(1,#placeEnemyStation)
	pStation = placeEnemyStation[si]()
	table.remove(placeEnemyStation,si)
	table.insert(enemyStationList,pStation)
	hf = spawnEnemies(psx,psy,10,kraylorFaction)
	for _, enemy in ipairs(hf) do
		enemy:orderDefendTarget(pStation)
	end
	stationFaction = gitmFaction
	psy = 60000
	si = math.random(1,#placeEnemyStation)
	pStation = placeEnemyStation[si]()
	table.remove(placeEnemyStation,si)
	table.insert(enemyStationList,pStation)
	hf = spawnEnemies(psx,psy,10,gitmFaction)
	for _, enemy in ipairs(hf) do
		enemy:orderDefendTarget(pStation)
	end
	stationFaction = exuariFaction
	psx = 60000
	psy = 0
	si = math.random(1,#placeEnemyStation)
	pStation = placeEnemyStation[si]()
	table.remove(placeEnemyStation,si)
	table.insert(enemyStationList,pStation)
	hf = spawnEnemies(psx,psy,10,exuariFaction)
	for _, enemy in ipairs(hf) do
		enemy:orderDefendTarget(pStation)
	end
	stationFaction = "Ktlitan"
	psx = -60000
	si = math.random(1,#placeEnemyStation)
	pStation = placeEnemyStation[si]()
	table.remove(placeEnemyStation,si)
	table.insert(enemyStationList,pStation)
	hf = spawnEnemies(psx,psy,10,"Ktlitan")
	for _, enemy in ipairs(hf) do
		enemy:orderDefendTarget(pStation)
	end
end
--Randomly choose station size template
function szt()
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
	return stationLando
end

function placeMaverick()
	--Maverick
	stationMaverick = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaverick:setPosition(psx,psy):setCallSign(maverick):setDescription("Gambling and resupply")
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
	return stationPrada
end

function placeResearch11()
	--Research-11
	stationResearch11 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(psx,psy):setCallSign("Research-11"):setDescription("Stress Psychology Research")
	return stationResearch11
end

function placeResearch19()
	--Research-19
	stationResearch19 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch19:setPosition(psx,psy):setCallSign("Research-19"):setDescription("Low gravity research")
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
	return stationScience2
end

function placeScience4()
	--Science 4
	stationScience4 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(psx,psy):setCallSign("Science-4"):setDescription("Biotech research")
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
	return stationSpot
end

function placeStarnet()
	--Starnet 
	stationStarnet = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationStarnet:setPosition(psx,psy):setCallSign("Starnet"):setDescription("Automated weapons systems")
	stationStarnet.publicRelations = true
	stationStarnet.generalInformation = "We research and create automated weapons systems to improve ship combat capability"
	return stationStarnet
end

function placeTandon()
	--Tandon
	stationTandon = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTandon:setPosition(psx,psy):setCallSign("Tandon"):setDescription("Biotechnology research")
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
    Transport ship generation and handling 
-----------------------------------------------------------------]]--
function nearStations(station, compareStationList)
	remainingStations = {}
	if compareStationList[1]:isValid() then
		if station:getCallSign() ~= compareStationList[1]:getCallSign() then
			closest = compareStationList[1]
		else
			if compareStationList[2]:isValid() then
				closest = compareStationList[2]
			end
		end
	end
	for ri, obj in ipairs(compareStationList) do
		if obj:isValid() then
			if station:getCallSign() ~= obj:getCallSign() then
				table.insert(remainingStations,obj)
				if distance(station,obj) < distance(station,closest) then
					closest = obj
				end
			end
		else
			table.remove(compareStationList,ri)
		end
	end
	for ri, obj in ipairs(remainingStations) do
		if obj:getCallSign() == closest:getCallSign() then
			table.remove(remainingStations,ri)
		end
	end
	return closest, remainingStations
end

function randomNearStation5(nobj)
	distanceStations = {}
	cs, rs1 = nearStations(nobj,stationList)
	table.insert(distanceStations,cs)
	cs, rs2 = nearStations(nobj,rs1)
	table.insert(distanceStations,cs)
	cs, rs3 = nearStations(nobj,rs2)
	table.insert(distanceStations,cs)
	cs, rs4 = nearStations(nobj,rs3)
	table.insert(distanceStations,cs)
	cs, rs5 = nearStations(nobj,rs4)
	table.insert(distanceStations,cs)
	return distanceStations[irandom(1,5)]
end

function transportPlot(delta)
	if transportSpawnDelay > 0 then
		transportSpawnDelay = transportSpawnDelay - delta
	end
	if transportSpawnDelay < 0 then
		transportSpawnDelay = delta + random(5,15) + missionLength
		transportCount = 0
		for tidx, obj in ipairs(transportList) do
			if obj:isValid() then
				if obj:isDocked(obj.target) then
					if obj.undock_delay > 0 then
						obj.undock_delay = obj.undock_delay - 1
					else
						obj.target = randomNearStation5(obj)
						obj.undock_delay = irandom(1,4)
						obj:orderDock(obj.target)
					end
				end
				transportCount = transportCount + 1
			end
		end
		lastTransportCount = transportCount
		if transportCount < #transportList then
			tempTransportList = {}
			for _, obj in ipairs(transportList) do
				if obj:isValid() then
					table.insert(tempTransportList,obj)
				end
			end
			transportList = tempTransportList
		end
		if #transportList < #stationList then
			target = nil
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate:isValid() then
					target = candidate
				end
			until(target ~= nil)
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
			obj = CpuShip():setTemplate(name):setFaction(neutralFaction):setCommsScript(""):setCommsFunction(commsShip)
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
			table.insert(transportList, obj)
		end
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
	for p3idx=1,8 do
		p3obj = getPlayerShip(p3idx)
		if p3obj ~= nil and p3obj:isValid() then
			if p3obj:isCommsOpening() then
				player = p3obj
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
	missilePresence = 0
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
			if comms_target == homeStation then
				comms_target.mineAvail = true
			else
				if math.random(1,10) <= (7 - difficulty) then
					comms_target.mineAvail = true
				else
					comms_target.mineAvail = false
				end
			end
			if math.random(1,10) <= (9 - difficulty) then
				comms_target.hvliAvail = true
			else
				comms_target.hvliAvail = false
			end
		end
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
					end
				end
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
					end
				end
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
					end
				end
				if player:getWeaponStorageMax(mine) > 0 then
					if comms_target.mineAvail then
						minePromptChoice = math.random(1,5)
						if minePromptChoice == 1 then
							minePrompt = "We could use some mines. ("
						elseif minePromptChoice == 2 then
							minePrompt = "How about mines? ("
						elseif minePromptChoice == 3 then
							minePrompt = "More mines ("
						elseif minePromptChoice == 4 then
							minePrompt = "All the mines we can take. ("
						else
							minePrompt = "Mines! What else? ("
						end
						addCommsReply(minePrompt .. getWeaponCost(mine) .. " rep each)", function()
							handleWeaponRestock(mine)
						end)
					end
				end
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
					end
				end
			end)
		end
	end
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("What is a minefield?", function()
				mMsg = string.format("For the automated sensors on station %s to register a minefield as completed across a gap, it must meet the following criteria:",homeStation:getCallSign())
				mMsg = mMsg .. "\n   1. Must contain at least 12 mines: Nautilus class standard load"
				mMsg = mMsg .. "\n   2. Must be within a 1.5U radius of sector corner in gap"
				if difficulty > .5 then
					mMsg = mMsg .. "\n   3. Must be centered: 6 on one side and 6 on the other"
				end
				if difficulty > 1 then
					mMsg = mMsg .. "\n   4. Must be along 20U distance from station line connecting asteroids"
				end
				setCommsMessage(mMsg)
				if not northMet then
					addCommsReply("What do the sensors show for the north gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",northObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle on the right: %i",ndiv2s1)
							cMsg = cMsg .. string.format("\nCount near middle on the left: %i",ndiv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids on the left: %i",ndiv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids on the right: %i",ndiv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count on the right: %i",ndiv1s1)
							cMsg = cMsg .. string.format("\nCount on the left: %i",ndiv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				if not southMet then
					addCommsReply("What do the sensors show for the south gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",southObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle on the right: %i",sdiv2s1)
							cMsg = cMsg .. string.format("\nCount near middle on the left: %i",sdiv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids on the left: %i",sdiv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids on the right: %i",sdiv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count on the right: %i",sdiv1s1)
							cMsg = cMsg .. string.format("\nCount on the left: %i",sdiv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				if not eastMet then
					addCommsReply("What do the sensors show for the east gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",eastObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle below: %i",ediv2s1)
							cMsg = cMsg .. string.format("\nCount near middle above: %i",ediv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids above: %i",ediv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids below: %i",ediv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count below: %i",ediv1s1)
							cMsg = cMsg .. string.format("\nCount above: %i",ediv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				if not westMet then
					addCommsReply("What do the sensors show for the west gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",westObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle below: %i",wdiv2s1)
							cMsg = cMsg .. string.format("\nCount near middle above: %i",wdiv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids above: %i",wdiv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids below: %i",wdiv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count below: %i",wdiv1s1)
							cMsg = cMsg .. string.format("\nCount above: %i",wdiv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end)
		if math.random(1,6) <= (4 - difficulty) then
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
		if math.random(1,6) <= (4 - difficulty) then
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
		end)
	end
	if goods[comms_target] ~= nil then
		addCommsReply("Buy, sell, trade", function()
			oMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation\n",comms_target:getCallSign())
			gi = 1		-- initialize goods index
			repeat
				goodsType = goods[comms_target][gi][1]
				goodsQuantity = goods[comms_target][gi][2]
				goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. "Current Cargo:\n"
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[player][gi][1]
				playerGoodsQuantity = goods[player][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[player])
			if cargoHoldEmpty then
				oMsg = oMsg .. "     Empty\n"
			end
			playerRep = math.floor(player:getReputationPoints())
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
				end)
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				foodQuantity = 0
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for luxury trades
			if tradeLuxury[comms_target] ~= nil then
				gi = 1
				luxuryQuantity = 0
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			-- Buttons for medicine trades
			if tradeMedicine[comms_target] ~= nil then
				gi = 1
				medicineQuantity = 0
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			addCommsReply("Back", commsStation)
		end)
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
			end)
		end
	end
end

function setOptionalOrders()
	optionalOrders = ""
	optionalOrdersPresent = false
	if plot2reminder ~= nil then
		if plot2reminder == "Get ship maneuver upgrade" then
			if spinReveal == 0 then
				optionalOrders = "\nOptional:\n" .. plot2reminder
			elseif spinReveal == 1 then
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s for %s",spinBase:getCallSign(),spinGood)
			elseif spinReveal == 2 then
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s",spinBase:getCallSign(),spinBase:getSectorName(),spinGood)
			elseif spinReveal == 3 then
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s",spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign())
			else
				optionalOrders = string.format("\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s in sector %s",spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign(),spinGoodBase:getSectorName())
			end
		else
			optionalOrders = "\nOptional:\n" .. plot2reminder
		end
		optionalOrdersPresent = true
	end
	if plot4reminder ~= nil then
		if optionalOrdersPresent then
			ifs = "\n"
		else
			ifs = "\nOptional:\n"
			optionalOrdersPresent = true
		end
		if plot4reminder == string.format("Upgrade %s to rotate",homeStation:getCallSign()) then
			if rotateReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif rotateReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign())
			elseif rotateReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s in %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName()) 
			elseif rotateReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s may bave %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format("Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s in %s may bave %s",homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGoodBase:getSectorName(),rotateGood)
			end
		elseif plot4reminder == "Get beam cycle time upgrade" then
			if beamTimeReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif beamTimeReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s for %s",beamTimeBase:getCallSign(),beamTimeGood)
			elseif beamTimeReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s in %s for %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood)
			elseif beamTimeReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign())
			else
				optionalOrders = optionalOrders .. ifs .. string.format("Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s in %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign(),beamTimeGoodBase:getSectorName())
			end
		elseif plot4reminder == "Get hull upgrade" then
			if hullReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif hullReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s to upgrade hull for %s",hullBase:getCallSign(),hullGood)
			elseif hullReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s in %s to upgrade hull for %s",hullBase:getCallSign(),hullBase:getSectorName(),hullGood)
			elseif hullReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s in %s to upgrade hull for %s\n    %s might have %s",hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format("Get %s in %s to upgrade hull for %s\n    %s in %s might have %s",hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGoodBase:getSectorName(),hullGood)
			end
		else
			optionalOrders = optionalOrders .. ifs .. plot4reminder
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
		if comms_target == homeStation then
			comms_target.mineAvail = true
		else
			if math.random(1,10) <= (7 - difficulty) then
				comms_target.mineAvail = true
			else
				comms_target.mineAvail = false
			end
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
		addCommsReply("What ordnance do you have available for restock?", function()
			missileTypeAvailableCount = 0
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
		goodsQuantityAvailable = 0
		gi = 1
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
		addCommsReply("See any enemies in your area?", function()
			if player:isFriendly(comms_target) then
				enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(player) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format("Yes, we see %i enemies within 30U",enemiesInRange))
					else
						setCommsMessage("Yes, we see one enemy within 30U")						
					end
					player:addReputationPoints(2.0)					
				else
					setCommsMessage("No enemies within 30U")
					player:addReputationPoints(1.0)
				end
				addCommsReply("Back", commsStation)
			else
				setCommsMessage("Not really")
				player:addReputationPoints(1.0)
				addCommsReply("Back", commsStation)
			end
		end)
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
			addCommsReply("General station information", function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply("Back", commsStation)
			end)
		end
	end)
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("What is a minefield?", function()
				mMsg = string.format("For the automated sensors on station %s to register a minefield as completed across a gap, it must meet the following criteria:",homeStation:getCallSign())
				mMsg = mMsg .. "\n   1. Must contain at least 12 mines: Nautilus class standard load"
				mMsg = mMsg .. "\n   2. Must be within a 1.5U radius of sector corner in gap"
				if difficulty > .5 then
					mMsg = mMsg .. "\n   3. Must be centered: 6 on one side and 6 on the other"
				end
				if difficulty > 1 then
					mMsg = mMsg .. "\n   4. Must be along 20U distance from station line connecting asteroids"
				end
				setCommsMessage(mMsg)
				if not northMet then
					addCommsReply("What do the sensors show for the north gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",northObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle on the right: %i",ndiv2s1)
							cMsg = cMsg .. string.format("\nCount near middle on the left: %i",ndiv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids on the left: %i",ndiv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids on the right: %i",ndiv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count on the right: %i",ndiv1s1)
							cMsg = cMsg .. string.format("\nCount on the left: %i",ndiv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				if not southMet then
					addCommsReply("What do the sensors show for the south gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",southObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle on the right: %i",sdiv2s1)
							cMsg = cMsg .. string.format("\nCount near middle on the left: %i",sdiv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids on the left: %i",sdiv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids on the right: %i",sdiv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count on the right: %i",sdiv1s1)
							cMsg = cMsg .. string.format("\nCount on the left: %i",sdiv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				if not eastMet then
					addCommsReply("What do the sensors show for the east gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",eastObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle below: %i",ediv2s1)
							cMsg = cMsg .. string.format("\nCount near middle above: %i",ediv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids above: %i",ediv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids below: %i",ediv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count above: %i",ediv1s1)
							cMsg = cMsg .. string.format("\nCount below: %i",ediv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				if not westMet then
					addCommsReply("What do the sensors show for the west gap?", function()
						if difficulty < 1 then
							cMsg = string.format("Count within radius: %i",westObjCount)
						elseif difficulty > 1 then
							cMsg = string.format("Count near middle below: %i",wdiv2s1)
							cMsg = cMsg .. string.format("\nCount near middle above: %i",wdiv2s2)
							cMsg = cMsg .. string.format("\nCount near asteroids above: %i",wdiv2s3)
							cMsg = cMsg .. string.format("\nCount near asteroids below: %i",wdiv2s4)
							cMsg = cMsg .. "\n\nYou need three in each sensor scan area"
						else
							cMsg = string.format("Count above: %i",wdiv1s1)
							cMsg = cMsg .. string.format("\nCount below: %i",wdiv1s2)
							cMsg = cMsg .. "\n\nYou need six in each sensor scan area"
						end
						cMsg = cMsg .. string.format("\nSensors refresh every %i seconds",gapCheckInterval)
						setCommsMessage(cMsg)
						addCommsReply("Back", commsStation)
					end)
				end
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end)
	end
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format("  time remaining: %.1f",gameTimeLimit)
			end
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
				oMsg = oMsg .. string.format("\nobject count N: %i, S: %i, E: %i, W: %i",northObjCount,southObjCount,eastObjCount,westObjCount)
				oMsg = oMsg .. string.format("\nCheck Timer: %.1f wave timer: %.1f",gapCheckDelayTimer,waveTimer)
				oMsg = oMsg .. string.format("\nInterwave: %i",interWave)
			end
			oMsg = oMsg .. "\n" .. wfv
			setCommsMessage(oMsg)
			if #spawnStrings > 0 then
				addCommsReply("show spawn strings", function()
					sMsg = "spawn strings:"
					for i=1,#spawnStrings do
						sMsg = sMsg .. "\n" .. spawnStrings[i]
						if i > 20 then 
							break
						end
					end
					setCommsMessage(sMsg)
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
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
	knowledgeCount = 0
	knowledgeMax = 10
	for sti=1,#stationList do
		if stationList[sti] ~= nil and stationList[sti]:isValid() then
			if distance(comms_target,stationList[sti]) < 75000 then
				brainCheck = 3
			else
				brainCheck = 1
			end
			for gi=1,#goods[stationList[sti]] do
				if random(1,10) <= brainCheck then
					table.insert(comms_target.goodsKnowledge,stationList[sti]:getCallSign())
					table.insert(comms_target.goodsKnowledgeSector,stationList[sti]:getSectorName())
					table.insert(comms_target.goodsKnowledgeType,goods[stationList[sti]][gi][1])
					tradeString = ""
					stationTrades = false
					if tradeMedicine[stationList[sti]] ~= nil then
						tradeString = " and will trade it for medicine"
						stationTrades = true
					end
					if tradeFood[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. " or food"
						else
							tradeString = tradeString .. " and will trade it for food"
							stationTrades = true
						end
					end
					if tradeLuxury[stationList[sti]] ~= nil then
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
		p4obj = getPlayerShip(p4idx)
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
		shields = comms_target:getShieldCount()
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

		missile_types = {homing, nuke, mine, emp, hvli}
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
	return true
end

function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = "We will see to your destruction!"
		taunt_success_reply = "Your bloodline will end here!"
		taunt_failed_reply = "Your feeble threats are meaningless."
		if faction == kraylorFaction then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
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
	shipType = comms_target:getTypeName()
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
					gi = 1
					luxuryQuantity = 0
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
				else
					-- Offer to sell goods
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage("What do you want?")
			-- Offer to sell destination information
			destRep = random(1,5)
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				else
					-- Offer to sell goods double price
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
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
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end
	return true
end
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
				pobj:addReputationPoints(250-(difficulty*6))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				pobj.spinUpgrade = false
				pobj.beamTimeUpgrade = false
				pobj.hullUpgrade = false
				tempPlayerType = pobj:getTypeName()
				if tempPlayerType == hornetMP52 then
					if #playerShipNamesForMP52Hornet > 0 then
						ni = math.random(1,#playerShipNamesForMP52Hornet)
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
					if psb[pobj:getTypeName()] ~= nil then
						pobj.healthyBeam = 1.0
						pobj.prevBeam = 1.0
					end
					if pobj:getWeaponTubeCount() > 0 then
						pobj.healthyMissile = 1.0
						pobj.prevMissile = 1.0
					end
					if pobj:hasWarp() then
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

function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:getRepairCrewCount() > 0 then
					fatalityChance = 0
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if psb[p:getTypeName()] ~= nil then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
						p.prevBeam = p:getSystemHealth("beamweapons")
					end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
						p.prevWarp = p:getSystemHealth("warp")
					end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
						p.prevJump = p:getSystemHealth("jumpdrive")
					end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
					end
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
			repairCrewFatality = "repairCrewFatality"
			p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
		end
		if p:hasPlayerAtPosition("Engineering+") then
			repairCrewFatalityPlus = "repairCrewFatalityPlus"
			p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
		end
	end
end

function initialInstructions(delta)
	plot1name = "initialInstructions"
	initialOrderTimer = initialOrderTimer - delta
	if initialOrderTimer < 0 then
		player:addToShipLog(string.format("Since %s is so isolated and so close to enemy territory, we need you to lay a minefield across each gap in the surrounding asteroids",homeStation:getCallSign()),"Magenta")
		primaryOrders = "Lay minefield across each gap in surrounding asteroids."
		plot1 = checkGaps
		plot1name = "checkGaps"
		waveTimer = interWave
		plot2 = waves
		plot2name = "waves"
	end
end

function checkGaps(delta)
	gapCheckDelayTimer = gapCheckDelayTimer - delta
	if gapCheckDelayTimer < 0 then
		if not southMet then
			prevSouthClosed = southClosed
			southMineCount = 0
			southClosed = checkSouthernGap()
			if prevSouthClosed and southClosed then
				southMet = true
				player:addToShipLog(string.format("Congratulations, You've closed the gap at heading 180 from %s",homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. " South gap closed."
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if not northMet then
			prevNorthClosed = northClosed
			northMineCount = 0
			northClosed = checkNorthernGap()
			if prevNorthClosed and northClosed then
				northMet = true
				player:addToShipLog(string.format("Congratulations, You've closed the gap at heading 0 from %s",homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. " North gap closed."
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if not westMet then
			prevWestClosed = westClosed
			westMineCount = 0
			westClosed = checkWesternernGap()
			if prevWestClosed and westClosed then
				westMet = true
				player:addToShipLog(string.format("Congratulations, You've closed the gap at heading 270 from %s",homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. " West gap closed."
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if not eastMet then
			prevEastClosed = eastClosed
			eastMineCount = 0
			eastClosed = checkEasternernGap()
			if prevEastClosed and eastClosed then
				eastMet = true
				player:addToShipLog(string.format("Congratulations, You've closed the gap at heading 90 from %s",homeStation:getCallSign()),"Magenta")
				primaryOrders = primaryOrders .. " East gap closed."
				player:addReputationPoints(20-(difficulty*6))
			end
		end
		if southMet and northMet and westMet and eastMet then
			if missionLength > 1 then
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addReputationPoints(100)
						p:addToShipLog(string.format("You've closed the gaps. Now for the Quixotic part: go destroy the enemy bases surrounding us while keeping %s alive. You'll find them straight out from the gaps",homeStation:getCallSign()),"Magenta")
						primaryOrders = string.format("Protect %s. Destroy enemy bases straight out from gaps",homeStation:getCallSign())
					end
				end
				plot1name = "destroyEnemyBases"
				plot1 = destroyEnemyBases
			else
				victory(humanFaction)
			end
		end
		gapCheckDelayTimer = delta + gapCheckInterval
	end
end
function checkEasternernGap()
	gapClosed = false
	if difficulty < 1 then
		eastObjCount = 0
		eastObjs = getObjectsInRadius(20000, 0, 1500)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				eastObjCount = eastObjCount + 1
			end
		end
		if eastObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		ediv2s1 = 0	--division 2, section 1
		eastObjs = getObjectsInRadius(20000, 375, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				ediv2s1 = ediv2s1 + 1
			end
		end
		ediv2s2 = 0	--division 2, section 2
		eastObjs = getObjectsInRadius(20000, -375, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				ediv2s2 = ediv2s2 + 1
			end
		end
		ediv2s3 = 0	--division 3, section 3
		eastObjs = getObjectsInRadius(20000, -1025, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				ediv2s3 = ediv2s3 + 1
			end
		end
		ediv2s4 = 0	--division 4, section 4
		eastObjs = getObjectsInRadius(20000, 1025, 375)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				ediv2s4 = ediv2s4 + 1
			end
		end
		if ediv2s1 >= 3 and ediv2s2 >= 3 and ediv2s3 >= 3 and ediv2s4 >= 3 then
			gapClosed = true
		end
	else
		ediv1s1 = 0	--division 1, section 1
		eastObjs = getObjectsInRadius(20000, 750, 750)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				ediv1s1 = ediv1s1 + 1
			end
		end
		ediv1s2 = 0	--division 1, section 2
		eastObjs = getObjectsInRadius(20000, -750, 750)
		for _, obj in ipairs(eastObjs) do
			if obj.typeName == mine then
				ediv1s2 = ediv1s2 + 1
			end
		end
		if ediv1s1 >= 6 and ediv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
function checkWesternernGap()
	gapClosed = false
	if difficulty < 1 then
		westObjCount = 0
		westObjs = getObjectsInRadius(-20000, 0, 1500)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				westObjCount = westObjCount + 1
			end
		end
		if westObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		wdiv2s1 = 0	--division 2, section 1
		westObjs = getObjectsInRadius(-20000, 375, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				wdiv2s1 = wdiv2s1 + 1
			end
		end
		wdiv2s2 = 0	--division 2, section 2
		westObjs = getObjectsInRadius(-20000, -375, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				wdiv2s2 = wdiv2s2 + 1
			end
		end
		wdiv2s3 = 0	--division 3, section 3
		westObjs = getObjectsInRadius(-20000, -1025, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				wdiv2s3 = wdiv2s3 + 1
			end
		end
		wdiv2s4 = 0	--division 4, section 4
		westObjs = getObjectsInRadius(-20000, 1025, 375)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				wdiv2s4 = wdiv2s4 + 1
			end
		end
		if wdiv2s1 >= 3 and wdiv2s2 >= 3 and wdiv2s3 >= 3 and wdiv2s4 >= 3 then
			gapClosed = true
		end
	else
		wdiv1s1 = 0	--division 1, section 1
		westObjs = getObjectsInRadius(-20000, 750, 750)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				wdiv1s1 = wdiv1s1 + 1
			end
		end
		wdiv1s2 = 0	--division 1, section 2
		westObjs = getObjectsInRadius(-20000, -750, 750)
		for _, obj in ipairs(westObjs) do
			if obj.typeName == mine then
				wdiv1s2 = wdiv1s2 + 1
			end
		end
		if wdiv1s1 >= 6 and wdiv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
function checkNorthernGap()
	gapClosed = false
	if difficulty < 1 then
		northObjCount = 0
		northObjs = getObjectsInRadius(0, -20000, 1500)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				northObjCount = northObjCount + 1
			end
		end
		if northObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		ndiv2s1 = 0	--division 2, section 1
		northObjs = getObjectsInRadius(375, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				ndiv2s1 = ndiv2s1 + 1
			end
		end
		ndiv2s2 = 0	--division 2, section 2
		northObjs = getObjectsInRadius(-375, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				ndiv2s2 = ndiv2s2 + 1
			end
		end
		ndiv2s3 = 0	--division 3, section 3
		northObjs = getObjectsInRadius(-1025, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				ndiv2s3 = ndiv2s3 + 1
			end
		end
		ndiv2s4 = 0	--division 4, section 4
		northObjs = getObjectsInRadius(1025, -20000, 375)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				ndiv2s4 = ndiv2s4 + 1
			end
		end
		if ndiv2s1 >= 3 and ndiv2s2 >= 3 and ndiv2s3 >= 3 and ndiv2s4 >= 3 then
			gapClosed = true
		end
	else
		ndiv1s1 = 0	--division 1, section 1
		northObjs = getObjectsInRadius(750, -20000, 750)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				ndiv1s1 = ndiv1s1 + 1
			end
		end
		ndiv1s2 = 0	--division 1, section 2
		northObjs = getObjectsInRadius(-750, -20000, 750)
		for _, obj in ipairs(northObjs) do
			if obj.typeName == mine then
				ndiv1s2 = ndiv1s2 + 1
			end
		end
		if ndiv1s1 >= 6 and ndiv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
function checkSouthernGap()
	gapClosed = false
	if difficulty < 1 then
		southObjCount = 0
		southObjs = getObjectsInRadius(0, 20000, 1500)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				southObjCount = southObjCount + 1
			end
		end
		if southObjCount >= 12 then
			gapClosed = true
		end
	elseif difficulty > 1 then
		sdiv2s1 = 0	--division 2, section 1
		southObjs = getObjectsInRadius(375, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				sdiv2s1 = sdiv2s1 + 1
			end
		end
		sdiv2s2 = 0	--division 2, section 2
		southObjs = getObjectsInRadius(-375, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				sdiv2s2 = sdiv2s2 + 1
			end
		end
		sdiv2s3 = 0	--division 3, section 3
		southObjs = getObjectsInRadius(-1025, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				sdiv2s3 = sdiv2s3 + 1
			end
		end
		sdiv2s4 = 0	--division 4, section 4
		southObjs = getObjectsInRadius(1025, 20000, 375)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				sdiv2s4 = sdiv2s4 + 1
			end
		end
		if sdiv2s1 >= 3 and sdiv2s2 >= 3 and sdiv2s3 >= 3 and sdiv2s4 >= 3 then
			gapClosed = true
		end
	else
		sdiv1s1 = 0	--division 1, section 1
		southObjs = getObjectsInRadius(750, 20000, 750)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				sdiv1s1 = sdiv1s1 + 1
			end
		end
		sdiv1s2 = 0	--division 1, section 2
		southObjs = getObjectsInRadius(-750, 20000, 750)
		for _, obj in ipairs(southObjs) do
			if obj.typeName == mine then
				sdiv1s2 = sdiv1s2 + 1
			end
		end
		if sdiv1s1 >= 6 and sdiv1s2 >= 6 then
			gapClosed = true
		end
	end
	return gapClosed
end
--  Quixotic addition
function destroyEnemyBases(delta)
	if homeStation:isValid() then
		validEnemies = 0
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				validEnemies = validEnemies + 1
			end
		end
		if validEnemies == 0 then
			victory(humanFaction)
		end
	else
		victory(kraylorFaction)
	end
end
-- keep the pressure up on the players
function waves(delta)
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		waveTimer = delta + interWave + random(1,60)
		spawnCompass = math.random(1,4)
		if spawnCompass == 1 then
			hf = spawnEnemies(0,-40000,difficulty,kraylorFaction)
			if northMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		elseif spawnCompass == 2 then
			hf = spawnEnemies(0,40000,difficulty,gitmFaction)
			if southMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		elseif spawnCompass == 3 then
			hf = spawnEnemies(40000,0,difficulty,exuariFaction)
			if eastMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		else
			hf = spawnEnemies(-40000,0,difficulty,hiveFaction)
			if westMet then
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowardsBlind(0,0)
				end
				waveTimer = waveTimer - random(1,60)
			else
				for _, enemy in ipairs(hf) do
					enemy:orderFlyTowards(0,0)
				end
			end
		end
		if homeStation:areEnemiesInRange(2000) then
			wakeEnemyFleet = getObjectsInRange(2000)
			for _, enemy in ipairs(wakeEnemyFleet) do
				if enemy:isEnemy(homeStation) then
					enemy:orderRoaming()
				end
			end
		end
	end
end

function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = kraylorFaction
	end
	if danger == nil then 
		danger = 1
	end
	if difficulty == nil then 
		difficulty = 1
	end
	enemyStrength = math.max(danger * difficulty * playerPower(),5)
	enemyPosition = 0
	sp = irandom(300,500)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		shipTemplateType = irandom(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,#stsl)
		end		
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):orderRoaming()
		enemyPosition = enemyPosition + 1
		if deployConfig < 50 then
			ship:setPosition(xOrigin+fleetPosDelta1x[enemyPosition]*sp,yOrigin+fleetPosDelta1y[enemyPosition]*sp)
		else
			ship:setPosition(xOrigin+fleetPosDelta2x[enemyPosition]*sp,yOrigin+fleetPosDelta2y[enemyPosition]*sp)
		end
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - stsl[shipTemplateType]
	end
	return enemyList
end
--evaluate the players for enemy strength and size spawning purposes
function playerPower()
	playerShipScore = 0
	for p5idx=1,8 do
		p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	if playerShipScore == 0 then
		return 24
	else
		return playerShipScore
	end
end

function update(delta)
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotT ~= nil then	--transports
		plotT(delta)
	end
	if playWithTimeLimit then
		gameTimeLimit = gameTimeLimit - delta
		if gameTimeLimit < 0 then
			victory(kraylorFaction)
		end
	end
	if plot1 ~= nil then	--main plot
		plot1(delta)
	end
	if plot2 ~= nil then	--waves
		plot2(delta)
	end
end