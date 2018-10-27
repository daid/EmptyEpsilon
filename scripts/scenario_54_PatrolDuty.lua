-- Name: Delta quadrant patrol duty
-- Description: Patrol between three stations in the Delta quadrant to protect from enemies
---
--- Version 4
-- Type: Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Self-destructive]: Extremely difficult goals and/or enemies
-- Variation[Short]: Fewer mission goals or shorter mission goals, shorter time taken
-- Variation[Timed 15]: End in 15 minutes
-- Variation[Timed 30]: End in 30 minutes
-- Variation[Short Easy]: Shorter time taken, easy goals and/or enemies
-- Variation[Timed 15 Easy]: End in 15 minutes, easy goals and/or enemies
-- Variation[Timed 30 Easy]: End in 30 minutes, easy goals and/or enemies
-- Variation[Short Hard]: Shorter time taken, hard goals and/or enemies
-- Variation[Timed 15 Hard]: End in 15 minutes, hard goals and/or enemies
-- Variation[Timed 30 Hard]: End in 30 minutes, hard goals and/or enemies
-- Variation[Short Self-destructive]: Shorter time taken, extremely difficult goals and/or enemies
-- Variation[Timed 15 Self-destructive]: End in 15 minutes, extremely difficult goals and/or enemies
-- Variation[Timed 30 Self-destructive]: End in 30 minutes, extremely difficult goals and/or enemies
-- Variation[Long]: More mission goals, longer time taken
-- Variation[Long Easy]: Longer time taken, easy goals and/or enemies
-- Variation[Long Hard]: Longer time taken, hard goals and/or enemies
-- Variation[Long Self-destructive]: Longer time taken, extremely difficult goals and/or enemies
-- Variation[Extended]: Longer missions than the long variation, longest time taken
-- Variation[Extended Easy]: Longest time taken, easy goals and/or enemies
-- Variation[Extended Hard]: Longest time taken, hard goals and/or enemies
-- Variation[Extended Self-destructive]: Longest time taken, extremely difficult goals and/or enemies

require("utils.lua")

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

-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships
function closestPlayerTo(obj)
	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		closestPlayer = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
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
--[[-----------------------------------------------------------------
      Initialization 
-----------------------------------------------------------------]]--
function init()
	-- Difficulty setting: 1 = normal, .5 is easy, 2 is hard, 5 is ridiculously hard
	difficultyList = {.5, 1, 2, 5}
	difficultySettingList = {"Easy", "Normal", "Hard", "Self-Destructive"}
	difficultyIndex = 2		--default to normal difficulty
	difficulty = difficultyList[difficultyIndex]
	setVariations()
	playerCount = 0
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	--Player Ship Beams
	psb = {}
	psb["MP52 Hornet"] = 2
	psb["Phobos M3P"] = 2
	psb["Flavia P.Falcon"] = 2
	psb["Atlantis"] = 2
	psb["Player Cruiser"] = 2
	psb["Player Fighter"] = 2
	psb["Striker"] = 2
	psb["ZX-Lindworm"] = 1
	psb["Ender"] = 12
	psb["Repulse"] = 2
	psb["Benedict"] = 2
	psb["Kiriya"] = 2
	psb["Nautilus"] = 2
	psb["Hathcock"] = 4
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	transportList = {}
	transportSpawnDelay = 10	--30
	-- 27 types of goods so far
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
	wfv = "nowhere"		--wolf fence value - used for debugging
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
	posseShipNames = {"Bubba","George","Winifred","Daniel","Darla","Stephen","Bob","Porky","Sally","Tommy","Jenny","Johnny","Lizzy","Billy"}
	goods = {}
	setPlayers()
	generateStaticWorld()
	primaryOrders = "Patrol Asimov, Utopia Planitia and Armstrong stations. Defend if enemies attack. Dock with each station at the end of each patrol leg"
	secondaryOrders = ""
	optionalOrders = ""
	highestPatrolLeg = 0
	highestConcurrentPlayerCount = 0
	setConcurrentPlayerCount = 0
	plot1 = initialOrderMessage
	plotT = transportPlot
	plotTname = "transportPlot"
	plotArt = unscannedAnchors
	plotH = healthCheck
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	jumpStartTimer = random(30,90)
	patrolComplete = false
	sporadicHarassInterval = 360
	sporadicHarassTimer = 360
	GMInitiatePlot2 = "Start plot 2 sick Kojak"
	GMInitiatePlot3 = "Start p 3 McNabbit ride"
	GMInitiatePlot4 = "St p4 Lisbon's stowaway"
	GMInitiatePlot5 = "Start plot 5"
	GMInitiatePlot8 = "Strt plot 8 Sheila dies"
	GMInitiatePlot9 = "Start plot 9 ambush"
	GMInitiatePlot10 = "Start plot 10 ambush"
	GMSkipToDefend = "Skip to defend U.P."
	GMSkipToDestroy = "Skip to destroy S.C."
	addGMFunction(GMInitiatePlot2,initiatePlot2)
	addGMFunction(GMInitiatePlot3,initiatePlot3)
	addGMFunction(GMInitiatePlot4,initiatePlot4)
	addGMFunction(GMInitiatePlot5,initiatePlot5)
	addGMFunction(GMInitiatePlot8,initiatePlot8)
	addGMFunction(GMInitiatePlot9,initiatePlot9)
	addGMFunction(GMInitiatePlot10,initiatePlot10)
	addGMFunction(GMSkipToDefend,skipToDefendUP)
	addGMFunction(GMSkipToDestroy,skipToDestroySC)
end

function setVariations()
	if string.find(getScenarioVariation(),"Short") or string.find(getScenarioVariation(),"Timed") then
		patrolGoal = 6			--short and timed missions get a patrol goal of 6
		missionLength = 1		--short and timed missions are categorized as mission length 1
	else
		patrolGoal = 9			--normal, long and extended get a patrol goal of 9
		if string.find(getScenarioVariation(),"Long") then
			missionLength = 3	--long missions are categorized as mission length 3
		elseif string.find(getScenarioVariation(),"Extended") then
			missionLength = 4	--extended missions are categorized as mission length 4
		else
			missionLength = 2	--normal missions are categorized as mission length 2
		end
	end
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5			--easy missions get a .5 difficulty
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2			--hard missions get a difficulty of 2
	elseif string.find(getScenarioVariation(),"Self-destructive") then
		difficulty = 5			--self destructive missions get a difficulty of 5
	else
		difficulty = 1			--default: normal mission difficulty of 1
	end
	playWithTimeLimit = false	--assume no time limit
	if string.find(getScenarioVariation(),"15") then
		gameTimeLimit = 15		--set 15 minute time limit
	elseif string.find(getScenarioVariation(),"30") then
		gameTimeLimit = 30		--set 30 minute time limit
	else
		gameTimeLimit = 0		--default: set no time limit
	end
	if gameTimeLimit > 0 then
		gameTimeLimit = gameTimeLimit*60	--convert minutes to seconds for time limit countdown
		ambushTime = gameTimeLimit/2		--set halfway point for ambush in timed scenarios
		playWithTimeLimit = true			--set time limit boolean
		plot7 = beforeAmbush				--use time limit plot
	end
end

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
			if pobj.patrolLegAsimov == nil then pobj.patrolLegAsimov = 0 end
			if pobj.patrolLegUtopiaPlanitia == nil then pobj.patrolLegUtopiaPlanitia = 0 end
			if pobj.patrolLegArmstrong == nil then pobj.patrolLegArmstrong = 0 end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				tempPlayerType = pobj:getTypeName()
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesForMP52Hornet > 0 then
						ni = math.random(1,#playerShipNamesForMP52Hornet)
						pobj:setCallSign(playerShipNamesForMP52Hornet[ni])
						table.remove(playerShipNamesForMP52Hornet,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
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
--Randomly choose station size template unless overridden
function szt()
	if stationSize ~= nil then
		sizeTemplate = stationSize
		return sizeTemplate
	end
	stationSizeRandom = random(1,100)
	if stationSizeRandom < 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom < 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom < 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end

function generateStaticWorld()
	stationList = {}
	patrolStationList = {}
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
	
	createRandomAlongArc(Asteroid,30,70000,160000,100000,180,225,3000)
	createRandomAlongArc(Asteroid,30,-70000,20000,100000,0,45,3000)
	createRandomAlongArc(Asteroid,40,160000,20000,130000,180,225,3000)
	placeRandomAroundPoint(Asteroid,25,1,15000,150000,-30000)
	
	createRandomAlongArc(Nebula,30,150000,0,150000,110,220,30000)
	createRandomAlongArc(Nebula,30,50000,200000,200000,200,300,40000)
	
	artAnchor1 = Artifact():setPosition(150000,-30000):setScanningParameters(3,2):setRadarSignatureInfo(random(2,8),random(22,87),random(2,8))
	artAnchor1:setModel("artifact3"):allowPickup(false):setDescriptions("Unusual object","Potential object of scientific research")
	artAnchor2 = Artifact():setPosition(random(0,100000),random(70000,100000)):setScanningParameters(2,3):setRadarSignatureInfo(random(2,8),random(22,87),random(2,8))
	artAnchor2:setModel("artifact5"):allowPickup(false):setDescriptions("Object outside of normal parameters","Good research material")
--	artTube = Artifact():setPosition(random(-50000,-20500),random(100000,199500)):setScanningParameters(1,4):setRadarSignatureInfo(random(30,100),random(5,25),random(40,60))
--	artTube:setModeel("artifact6"):allowPickup(false):setDescriptions("Strange looking object","Object with unusual subatomic characteristics")

	stationFaction = "Human Navy"
	stationSize = "Medium Station"

	--Asimov
	asimovx = random(500,9500)
	asimovy = random(-19500,19500)
	psx = asimovx
	psy = asimovy
	stationAsimov = placeAsimov()
	table.insert(stationList,stationAsimov)
	table.insert(patrolStationList,stationAsimov)
	friendlyStations = friendlyStations + 1
	--Utopia Planitia
	
	stationSize = "Large Station"
	utopiaPlanitiax = random(120500,139500)
	utopiaPlanitiay = random(-4500,44500)
	psx = utopiaPlanitiax
	psy = utopiaPlanitiay
	stationUtopiaPlanitia = placeUtopiaPlanitia()
	table.insert(stationList,stationUtopiaPlanitia)
	table.insert(patrolStationList,stationUtopiaPlanitia)
	friendlyStations = friendlyStations + 1
	--Armstrong
	
	stationSize = "Huge Station"
	armstrongx = random(10500,69500)
	armstrongy = random(140500,159500)
	psx = armstrongx
	psy = armstrongy
	stationArmstrong = placeArmstrong()
	table.insert(stationList,stationArmstrong)
	table.insert(patrolStationList,stationArmstrong)
	friendlyStations = friendlyStations + 1

	stationSize = "Medium Station"

	--Bethesda (first of three around larger secondary circle of stations)
	bethesdaAngle = random(0,360)
	xBethesda, yBethesda = vectorFromAngle(bethesdaAngle, random(35000,40000))
	psx = 40000+xBethesda
	psy = 150000+yBethesda
	stationBethesda = placeBethesda()
	table.insert(stationList,stationBethesda)
	friendlyStations = friendlyStations + 1
	
	stationSize = "Small Station"
	stationFaction = "Independent"
	--Feynman (second of three around larger secondary circle of stations)
	feynmanAngle = bethesdaAngle + random(60,180)
	xFeynman, yFeynman = vectorFromAngle(feynmanAngle, random(35000,40000))
	psx = 40000+xFeynman
	psy = 150000+yFeynman
	stationFeynman = placeFeynman()
	table.insert(stationList,stationFeynman)
	neutralStations = neutralStations + 1

	stationSize = "Medium Station"
	--Calvin (third of three around larger secondary circle of stations)
	calvinAngle = feynmanAngle + random(60,120)
	xCalvin, yCalvin = vectorFromAngle(calvinAngle, random(35000,40000))
	psx = 40000+xCalvin
	psy = 150000+yCalvin
	stationCalvin = placeCalvin()
	table.insert(stationList,stationCalvin)
	neutralStations = neutralStations + 1
	
	stationSize = "Small Station"

	--Zefram (first of four around the zero-centered circle of stations)
	zeframAngle = random(0,360)
	xZefram, yZefram = vectorFromAngle(zeframAngle,random(42000,50000))
	psx = xZefram
	psy = yZefram
	stationZefram = placeZefram()
	table.insert(stationList,stationZefram)
	friendlyStations = friendlyStations + 1
	
	stationFaction = "Independent"
	--Coulomb (second of four around the zero-centered circle of stations)
	coulombAngle = zeframAngle + random(60,120)
	xCoulomb, yCoulomb = vectorFromAngle(coulombAngle,random(42000,50000))
	psx = xCoulomb
	psy = yCoulomb
	stationCoulomb = placeCoulomb()
	table.insert(stationList,stationCoulomb)
	neutralStations = neutralStations + 1
	--Shree (third of four around the zero-centered circle of stations)
	shreeAngle = coulombAngle + random(60,120)
	xShree, yShree = vectorFromAngle(shreeAngle,random(42000,50000))
	psx = xShree
	psy = yShree
	stationShree = placeShree()
	table.insert(stationList,stationShree)
	neutralStations = neutralStations + 1
	--Veloquan (fourth of four around the zero-centered circle of stations)
	veloquanAngle = shreeAngle + random(60,90)
	xVeloquan, yVeloquan = vectorFromAngle(veloquanAngle,random(42000,50000))
	psx = xVeloquan
	psy = yVeloquan
	stationVeloquan = placeVeloquan()
	table.insert(stationList,stationVeloquan)
	neutralStations = neutralStations + 1

	stationFaction = "Human Navy"
	
	--Soong (first of three around smaller secondary circle of stations)
	soongAngle = random(0,360)
	xSoong, ySoong = vectorFromAngle(soongAngle, random(30000,35000))
	psx = 130000+xSoong
	psy = 20000+ySoong
	stationSoong = placeSoong()
	table.insert(stationList,stationSoong)
	friendlyStations = friendlyStations + 1
	
	stationFaction = "Independent"
	--Starnet (second of three around smaller secondary circle of stations)
	starnetAngle = soongAngle + random(60,180)
	xStarnet, yStarnet = vectorFromAngle(starnetAngle, random(30000,35000))
	psx = 130000+xStarnet
	psy = 20000+yStarnet
	stationStarnet = placeStarnet()
	table.insert(stationList,stationStarnet)
	neutralStations = neutralStations + 1
	--Anderson (third of three around smaller secondary circle of stations)
	andersonAngle = starnetAngle + random(60,120)
	xAnderson, yAnderson = vectorFromAngle(andersonAngle, random(30000,35000))
	psx = 130000+xAnderson
	psy = 20000+yAnderson
	stationAnderson = placeAnderson()
	table.insert(stationList,stationAnderson)
	neutralStations = neutralStations + 1
	
	stationFaction = "Independent"
	stationSize = "Small Station"
	
	--Spot
	psx = random(-50000,9500)
	psy = random(200500,210000)
	stationSpot = placeSpot()
	table.insert(stationList,stationSpot)
	neutralStations = neutralStations + 1
	--Rutherford
	psx = random(-9500,9500)
	psy = random(175000,199500)
	stationRutherford = placeRutherford()
	table.insert(stationList,stationRutherford)
	neutralStations = neutralStations + 1
	--Evondos
	psx = random(10500,29500)
	psy = random(190000,210000)
	stationEvondos = placeEvondos()
	table.insert(stationList,stationEvondos)
	neutralStations = neutralStations + 1
	--Tandon
	psx = random(30500,100000)
	psy = random(200500,220000)
	stationTandon = placeTandon()
	table.insert(stationList,stationTandon)
	neutralStations = neutralStations + 1
	--Ripley
	psx = random(70000,110000)
	psy = random(180500,199500)
	stationRipley = placeRipley()
	table.insert(stationList,stationRipley)
	neutralStations = neutralStations + 1
	--Okun
	psx = random(80500,100000)
	psy = random(120000,179500)
	stationOkun = placeOkun()
	table.insert(stationList,stationOkun)
	neutralStations = neutralStations + 1
	--Prada
	psx = random(110000,120000)
	psy = random(60000,100000)
	stationPrada = placePrada()
	table.insert(stationList,stationPrada)
	neutralStations = neutralStations + 1
	--Broeck
	psx = random(130000,149500)
	psy = random(60000,100000)
	stationBroeck = placeBroeck()
	table.insert(stationList,stationBroeck)
	neutralStations = neutralStations + 1
	--Panduit
	psx = random(150500,200000)
	psy = random(50500,70000)
	stationPanduit = placePanduit()
	table.insert(stationList,stationPanduit)
	neutralStations = neutralStations + 1
	--Research-19
	psx = random(100000,170000)
	psy = random(-9500,49500)
	stationResearch19 = placeResearch19
	table.insert(stationList,stationResearch19)
	neutralStations = neutralStations + 1
	--Grasberg
	psx = random(100000,149500)
	psy = random(-60000,-20000)
	stationGrasberg = placeGrasberg()
	table.insert(stationList,stationGrasberg)
	neutralStations = neutralStations + 1
	--Impala
	psx = random(150500,190000)
	psy = random(-50000,-10500)
	stationImpala = placeImpala()
	table.insert(stationList,stationImpala)
	neutralStations = neutralStations + 1
	
	if random(1,100) < 50 then
		goods[stationGrasberg] = {{"luxury",5,70},{"gold",5,25}}
		goods[stationImpala] = {{"cobalt",4,50}}
	else
		goods[stationImpala] = {{"luxury",5,70},{"gold",5,25}}
		goods[stationGrasberg] = {{"cobalt",4,50}}
	end
	
	--Cyrus
	psx = random(-20000,35000)
	psy = random(-60000,-50500)
	stationCyrus = placeCyrus()
	table.insert(stationList,stationCyrus)
	neutralStations = neutralStations + 1
	--Hossam
	psx = random(-80000,-60000)
	psy = random(-50000,19500)
	stationHossam = placeHossam()
	table.insert(stationList,stationHossam)
	neutralStations = neutralStations + 1
	--Miller
	psx = random(-80000,-50000)
	psy = random(20500,39500)
	stationMiller = placeMiller()
	table.insert(stationList,stationMiller)
	neutralStations = neutralStations + 1
	--O'Brien
	psx = random(-90000,-50500)
	psy = random(40500,70000)
	stationOBrien = placeOBrien()
	table.insert(stationList,stationOBrien)
	neutralStations = neutralStations + 1
	--Maverick
	psx = random(-49500,-20500)
	psy = random(45000,80000)
	stationMaverick = placeMaverick()
	table.insert(stationList,stationMaverick)
	neutralStations = neutralStations + 1
	--Jabba
	psx = random(20000,29500)
	psy = random(160500,180000)
	stationJabba = placeJabba()
	table.insert(stationList,stationJabba)
	neutralStations = neutralStations + 1
	--Heyes
	psx = random(30500,70000)
	psy = random(160500,170000)
	stationHeyes = placeHeyes()
	table.insert(stationList,stationHeyes)
	neutralStations = neutralStations + 1
	--Nexus-6
	psx = random(40500,60000)
	psy = random(123000,139500)
	stationNexus6 = placeNexus6()
	table.insert(stationList,stationNexus6)
	neutralStations = neutralStations + 1
	--Maiman
	psx = random(30500,39500)
	psy = random(120000,139500)
	stationMaiman = placeMaiman()
	table.insert(stationList,stationMaiman)
	neutralStations = neutralStations + 1
	--Shawyer
	psx = random(15000,29500)
	psy = random(125000,139500)
	stationShawyer = placeShawyer()
	table.insert(stationList,stationShawyer)
	neutralStations = neutralStations + 1
	--Owen
	psx = random(140500,150000)
	psy = random(30500,40000)
	stationOwen = placeOwen()
	table.insert(stationList,stationOwen)
	neutralStations = neutralStations + 1
	--Lipkin
	psx = random(140500,155000)
	psy = random(20500,29500)
	stationLipkin = placeLipkin()
	table.insert(stationList,stationLipkin)
	neutralStations = neutralStations + 1
	--Barclay
	psx = random(140500,155000)
	psy = random(5000,19500)
	stationBarclay = placeBarclay()
	table.insert(stationList,stationBarclay)
	neutralStations = neutralStations + 1
	--Erickson
	psx = random(110000,119500)
	psy = random(20500,40000)
	stationErickson = placeErickson()
	table.insert(stationList,stationErickson)
	neutralStations = neutralStations + 1
	--Hayden
	psx = random(-15000,10000)
	psy = random(-40000,-29500)
	stationHayden = placeHayden()
	table.insert(stationList,stationHayden)
	neutralStations = neutralStations + 1
	--Skandar
	psx = random(-35000,-10500)
	psy = random(500,20000)
	stationSkandar = placeSkandar()
	table.insert(stationList,stationSkandar)
	neutralStations = neutralStations + 1
	--Tokra
	psx = random(-25000,-10500)
	psy = random(-10000,-500)
	stationTokra = placeTokra()
	table.insert(stationList,stationTokra)
	neutralStations = neutralStations + 1
	--Rubis
	psx = random(10500,35000)
	psy = random(10500,25000)
	stationRubis = placeRubis()
	table.insert(stationList,stationRubis)
	neutralStations = neutralStations + 1
	--Olympus
	psx = random(10500,35000)
	psy = random(-19500,9500)
	stationOlympus = placeOlympus()
	table.insert(stationList,stationOlympus)
	neutralStations = neutralStations + 1
	--Archimedes
	psx = random(-29500,-20500)
	psy = random(50000,90000)
	stationArchimedes = placeArchimedes()
	table.insert(stationList,stationArchimedes)
	neutralStations = neutralStations + 1
	--Toohie
	psx = random(-9500,-500)
	psy = random(-19500,40000)
	stationToohie = placeToohie()
	table.insert(stationList,stationToohie)
	neutralStations = neutralStations + 1
	--Krik
	psx = random(-19500,-10500)
	psy = random(70500,179500)
	stationKrik = placeKrik()
	table.insert(stationList,stationKrik)
	neutralStations = neutralStations + 1
	--Krak
	psx = random(-19500,79500)
	psy = random(55500,69500)
	stationKrak = placeKrak()
	table.insert(stationList,stationKrak)
	neutralStations = neutralStations + 1
	--Kruk
	psx = random(80000,90000)
	psy = random(-70000,70000)
	stationKruk = placeKruk()
	table.insert(stationList,stationKruk)
	neutralStations = neutralStations + 1
	
	miningMix = math.random(1,6)
	if miningMix == 1 then
		goods[stationKrik] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationKrak] = {{"nickel",5,22},{"platinum",5,70}}
		goods[stationKruk] = {{"nickel",5,21},{"dilithium",5,50}}
		stationKrik.publicRelations = true
		stationKrik.generalInformation = "We've been able to extract nickel and tritanium from these rocks. Come get some if you want some"
		stationKrak.publicRelations = true
		stationKrak.generalInformation = "We've been able to extract nickel and platinum from these rocks. Come get some if you want some"
		stationKruk.publicRelations = true
		stationKruk.generalInformation = "We've been able to extract nickel and dilithium from these rocks. Come get some if you want some"
	elseif miningMix == 2 then
		goods[stationKrik] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationKruk] = {{"nickel",5,22},{"platinum",5,70}}
		goods[stationKrak] = {{"nickel",5,21},{"dilithium",5,50}}
		stationKrik.publicRelations = true
		stationKrik.generalInformation = "We've been able to extract nickel and tritanium from these rocks. Come get some if you want some"
		stationKrak.publicRelations = true
		stationKrak.generalInformation = "We've been able to extract nickel and dilithium from these rocks. Come get some if you want some"
		stationKruk.publicRelations = true
		stationKruk.generalInformation = "We've been able to extract nickel and platinum from these rocks. Come get some if you want some"
	elseif miningMix == 3 then
		goods[stationKrak] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationKrik] = {{"nickel",5,22},{"platinum",5,70}}
		goods[stationKruk] = {{"nickel",5,21},{"dilithium",5,50}}
		stationKrik.publicRelations = true
		stationKrik.generalInformation = "We've been able to extract nickel and platinum from these rocks. Come get some if you want some"
		stationKrak.publicRelations = true
		stationKrak.generalInformation = "We've been able to extract nickel and tritanium from these rocks. Come get some if you want some"
		stationKruk.publicRelations = true
		stationKruk.generalInformation = "We've been able to extract nickel and dilithium from these rocks. Come get some if you want some"
	elseif miningMix == 4 then
		goods[stationKruk] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationKrak] = {{"nickel",5,22},{"platinum",5,70}}
		goods[stationKrik] = {{"nickel",5,21},{"dilithium",5,50}}
		stationKrik.publicRelations = true
		stationKrik.generalInformation = "We've been able to extract nickel and dilithium from these rocks. Come get some if you want some"
		stationKrak.publicRelations = true
		stationKrak.generalInformation = "We've been able to extract nickel and platinum from these rocks. Come get some if you want some"
		stationKruk.publicRelations = true
		stationKruk.generalInformation = "We've been able to extract nickel and tritanium from these rocks. Come get some if you want some"
	elseif miningMix == 5 then
		goods[stationKrak] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationKruk] = {{"nickel",5,22},{"platinum",5,70}}
		goods[stationKrik] = {{"nickel",5,21},{"dilithium",5,50}}
		stationKrik.publicRelations = true
		stationKrik.generalInformation = "We've been able to extract nickel and dilithium from these rocks. Come get some if you want some"
		stationKrak.publicRelations = true
		stationKrak.generalInformation = "We've been able to extract nickel and tritanium from these rocks. Come get some if you want some"
		stationKruk.publicRelations = true
		stationKruk.generalInformation = "We've been able to extract nickel and platinum from these rocks. Come get some if you want some"
	else
		goods[stationKruk] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationKrik] = {{"nickel",5,22},{"platinum",5,70}}
		goods[stationKrak] = {{"nickel",5,21},{"dilithium",5,50}}
		stationKrik.publicRelations = true
		stationKrik.generalInformation = "We've been able to extract nickel and platinum from these rocks. Come get some if you want some"
		stationKrak.publicRelations = true
		stationKrak.generalInformation = "We've been able to extract nickel and dilithium from these rocks. Come get some if you want some"
		stationKruk.publicRelations = true
		stationKruk.generalInformation = "We've been able to extract nickel and tritanium from these rocks. Come get some if you want some"
	end
	
	stationSize = "Medium Station"
	
	--Chatuchak
	psx = random(-29500,20000)
	psy = random(-29500,-20500)
	stationChatuchak = placeChatuchak()
	table.insert(stationList,stationChatuchak)
	neutralStations = neutralStations + 1
	--Madison
	psx = random(110000,119500)
	psy = random(0,19500)
	stationMadison = placeMadison()
	table.insert(stationList,stationMadison)
	neutralStations = neutralStations + 1
	
	nebAx = (asimovx + armstrongx)/2
	nebAy = (asimovy + armstrongy)/2
	nebA = Nebula():setPosition(nebAx,nebAy)
	nebMx = (asimovx + utopiaPlanitiax)/2
	nebMy = (asimovy + utopiaPlanitiay)/2
	nebM = Nebula():setPosition(nebMx,nebMy)
	if math.random(1,2) == 1 then
		neb1 = nebA
		neb1x = nebAx
		neb1y = nebAy
		neb2 = nebM
		neb2x = nebMx
		neb2y = nebMy
	else
		neb1 = nebM
		neb1x = nebMx
		neb1y = nebMy
		neb2 = nebA
		neb2x = nebAx
		neb2y = nebAy
	end	
end
function placeAnderson()
	--Anderson 
	stationAnderson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(psx,psy):setCallSign("Anderson"):setDescription("Battery and software engineering")
	goods[stationAnderson] = {{"battery",5,65},{"software",5,115}}
	tradeLuxury[stationAnderson] = true
	stationAnderson.publicRelations = true
	stationAnderson.generalInformation = "We provide high quality high capacity batteries and specialized software for all shipboard systems"
	stationAnderson.stationHistory = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion"
	return stationAnderson
end
function placeArchimedes()
	--Archimedes
	stationArchimedes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationArchimedes:setPosition(psx,psy):setCallSign("Archimedes"):setDescription("Energy and particle beam components")
	goods[stationArchimedes] = {{"beam",5,80}}
	tradeFood[stationArchimedes] = true
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
	goods[stationArmstrong] = {{"food",math.random(5,10),1},{"medicine",5,5},{"impulse",5,62},{"warp",5,77}}	
	stationArmstrong.publicRelations = true
	stationArmstrong.generalInformation = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis"
	stationArmstrong.stationHistory = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems."
	return stationArmstrong
end
function placeAsimov()
	--Asimov
	stationAsimov = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationAsimov:setCallSign("Asimov"):setDescription("Training and Coordination"):setPosition(psx,psy)
	goods[stationAsimov] = {{"food",10,1}}
	stationAsimov.publicRelations = true
	stationAsimov.generalInformation = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector"
	stationAsimov.stationHistory = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region"
	return stationAsimov
end
function placeBarclay()
	--Barclay
	stationBarclay = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(psx,psy):setCallSign("Barclay"):setDescription("Communication components")
	goods[stationBarclay] = {{"communication",5,58}}
	tradeMedicine[stationBarclay] = true
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
	goods[stationBroeck] = {{"warp",5,130}}
	if random(1,100) < 53 then tradeMedicine[stationBroeck] = true end
	if random(1,100) < 14 then tradeFood[stationBroeck] = true end
	if random(1,100) < 62 then tradeLuxury[stationBroeck] = true end
	stationBroeck.publicRelations = true
	stationBroeck.generalInformation = "We provide warp drive engines and components"
	stationBroeck.stationHistory = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth"
	return stationBroeck
end
function placeCalvin()
	--Calvin 
	stationCalvin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(psx,psy):setCallSign("Calvin"):setDescription("Robotic research")
	goods[stationCalvin] = {{"robotic",5,87}}
	if random(1,100) < 8 then tradeFood[stationCalvin] = true end
	tradeLuxury[stationCalvin] = true
	stationCalvin.publicRelations = true
	stationCalvin.generalInformation = "We research and provide robotic systems and components"
	stationCalvin.stationHistory = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming"
	return stationCalvin
end
function placeChatuchak()
	--Chatuchak
	stationChatuchak = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationChatuchak:setPosition(psx,psy):setCallSign("Chatuchak"):setDescription("Trading station")
	goods[stationChatuchak] = {{"luxury",5,60}}		
	stationChatuchak.publicRelations = true
	stationChatuchak.generalInformation = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here"
	stationChatuchak.stationHistory = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind"
	return stationChatuchak
end
function placeCoulomb()
	--Coulomb
	stationCoulomb = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCoulomb:setPosition(psx,psy):setCallSign("Coulomb"):setDescription("Shielded circuitry fabrication")
	goods[stationCoulomb] = {{"circuit",5,50}}
	if random(1,100) < 82 then tradeLuxury[stationCoulomb] = true end
	if random(1,100) < 27 then tradeMedicine[stationCoulomb] = true end
	if random(1,100) < 16 then tradeFood[stationCoulomb] = true end
	stationCoulomb.publicRelations = true
	stationCoulomb.generalInformation = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference"
	stationCoulomb.stationHistory = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits"
	return stationCoulomb
end
function placeCyrus()
	--Cyrus
	stationCyrus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationCyrus:setPosition(psx,psy):setCallSign("Cyrus"):setDescription("Impulse engine components")
	goods[stationCyrus] = {{"impulse",5,124}}		
	if random(1,100) < 34 then tradeMedicine[stationCyrus] = true end
	if random(1,100) < 13 then tradeFood[stationCyrus] = true end
	if random(1,100) < 78 then tradeLuxury[stationCyrus] = true end
	stationCyrus.publicRelations = true
	stationCyrus.generalInformation = "We supply high quality impulse engines and parts for use aboard ships"
	stationCyrus.stationHistory = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne"
	return stationCyrus
end
function placeErickson()
	--Erickson
	stationErickson = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationErickson:setPosition(psx,psy):setCallSign("Erickson"):setDescription("Transporter components")
	goods[stationErickson] = {{"transporter",5,63}}		
	tradeFood[stationErickson] = true
	tradeMedicine[stationErickson] = true 
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
	goods[stationEvondos] = {{"autodoc",5,56}}		
	tradeMedicine[stationEvondos] = true 
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
	goods[stationFeynman] = {{"nanites",5,79},{"software",5,115}}
	if random(1,100) < 26 then tradeFood[stationFeynman] = true end
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
	tradeFood[stationGrasberg] = true
	return stationGrasberg
end
function placeHayden()
	--Hayden
	stationHayden = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHayden:setPosition(psx,psy):setCallSign("Hayden"):setDescription("Observatory and stellar mapping")
	goods[stationHayden] = {{"nanites",5,65}}		
	stationHayden.publicRelations = true
	stationHayden.generalInformation = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding"
	return stationHayden
end
function placeHeyes()
	--Heyes
	stationHeyes = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationHeyes:setPosition(psx,psy):setCallSign("Heyes"):setDescription("Sensor components")
	goods[stationHeyes] = {{"sensor",5,72}}		
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
	goods[stationHossam] = {{"nanites",5,48}}		
	if random(1,100) < 44 then tradeMedicine[stationHossam] = true end
	if random(1,100) < 24 then tradeFood[stationHossam] = true end
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
	return stationImpala
end
function placeJabba()
	--Jabba
	stationJabba = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationJabba:setPosition(psx,psy):setCallSign("Jabba"):setDescription("Commerce and gambling")
	goods[stationJabba] = {{"luxury",5,72}}		
	stationJabba.publicRelations = true
	stationJabba.generalInformation = "Come play some games and shop. House take does not exceed 4 percent"
	return stationJabba
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
	tradeMedicine[stationKrak] = true
	return stationKrak
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
	return stationKrik
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
	tradeLuxury[stationKruk] = true
	if random(1,100) < 50 then tradeFood[stationKruk] = true end
	if random(1,100) < 50 then tradeMedicine[stationKruk] = true end
	return stationKruk
end
function placeLipkin()
	--Lipkin
	stationLipkin = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(psx,psy):setCallSign("Lipkin"):setDescription("Autodoc components")
	goods[stationLipkin] = {{"autodoc",5,76}}		
	tradeFood[stationLipkin] = true 
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
	goods[stationMadison] = {{"luxury",5,70}}		
	stationMadison.publicRelations = true
	stationMadison.generalInformation = "Come take in a game or two or perhaps see a show"
	stationMadison.stationHistory = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment"
	return stationMadison
end
function placeMaiman()
	--Maiman
	stationMaiman = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaiman:setPosition(psx,psy):setCallSign("Maiman"):setDescription("Energy beam components")
	goods[stationMaiman] = {{"beam",5,70}}		
	tradeMedicine[stationMaiman] = true 
	stationMaiman.publicRelations = true
	stationMaiman.generalInformation = "We research and manufacture energy beam components and systems"
	stationMaiman.stationHistory = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th centuryon Earth"
	return stationMaiman
end
function placeMaverick()
	--Maverick
	stationMaverick = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMaverick:setPosition(psx,psy):setCallSign("Maverick"):setDescription("Gambling and resupply")
	stationMaverick.publicRelations = true
	stationMaverick.generalInformation = "Relax and meet some interesting players"
	return stationMaverick
end
function placeMiller()
	--Miller
	stationMiller = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationMiller:setPosition(psx,psy):setCallSign("Miller"):setDescription("Exobiology research")
	goods[stationMiller] = {{"luxury",10,91}}		
	stationMiller.publicRelations = true
	stationMiller.generalInformation = "We study recently discovered life forms not native to Earth"
	stationMiller.stationHistory = "This station was named after one the early exobiologists from mid 20th century Earth, Dr. Stanley Miller"
	return stationMiller
end
function placeNexus6()
	--Nexus-6
	stationNexus6 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationNexus6:setPosition(psx,psy):setCallSign("Nexus-6"):setDescription("Android components")
	goods[stationNexus6] = {{"android",5,93}}		
	tradeMedicine[stationNexus6] = true 
	stationNexus6.publicRelations = true
	stationNexus6.generalInformation = "We research and manufacture android components and systems. Our design our androids to maximize their likeness to humans"
	stationNexus6.stationHistory = "The station is named after the ground breaking model of android produced by the Tyrell corporation"
	return stationNexus6
end
function placeOBrien()
	--O'Brien
	stationOBrien = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOBrien:setPosition(psx,psy):setCallSign("O'Brien"):setDescription("Transporter components")
	goods[stationOBrien] = {{"transporter",5,76}}
	if random(1,100) < 34 then tradeMedicine[stationOBrien] = true end
	if random(1,100) < 13 then tradeFood[stationOBrien] = true end
	if random(1,100) < 43 then tradeLuxury[stationOBrien] = true end
	stationOBrien.publicRelations = true
	stationOBrien.generalInformation = "We research and fabricate high quality transporters and transporter components for use aboard ships"
	stationOBrien.stationHistory = "Miles O'Brien started this business after his experience as a transporter chief"
	return stationOBrien
end
function placeOkun()
	--Okun
	stationOkun = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOkun:setPosition(psx,psy):setCallSign("Okun"):setDescription("Xenopsychology research")
	return stationOkun
end
function placeOlympus()
	--Olympus
	stationOlympus = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOlympus:setPosition(psx,psy):setCallSign("Olympus"):setDescription("Optical components")
	goods[stationOlympus] = {{"optic",5,66}}		
	tradeFood[stationOlympus] = true
	tradeMedicine[stationOlympus] = true
	stationOlympus.publicRelations = true
	stationOlympus.generalInformation = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components"
	stationOlympus.stationHistory = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry"
	return stationOlympus
end
function placeOwen()
	--Owen
	stationOwen = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationOwen:setPosition(psx,psy):setCallSign("Owen"):setDescription("Load lifters and components")
	goods[stationOwen] = {{"lifter",5,61}}		
	tradeFood[stationOwen] = true 
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
	goods[stationPanduit] = {{"optic",5,79}}		
	if random(1,100) < 33 then tradeMedicine[stationPanduit] = true end
	if random(1,100) < 27 then tradeFood[stationPanduit] = true end
	tradeLuxury[stationPanduit] = true
	stationPanduit.publicRelations = true
	stationPanduit.generalInformation = "We provide optic components for various ship systems"
	stationPanduit.stationHistory = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States"
	return stationPanduit
end
function placePrada()
	--Prada
	stationPrada = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationPrada:setPosition(psx,psy):setCallSign("Prada"):setDescription("Textiles and fashion")
	return stationPrada
end
function placeResearch19()
	--Research-19
	stationResearch19 = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch19:setPosition(psx,psy):setCallSign("Research-19"):setDescription("Low gravity research")
	return stationResearch19
end
function placeRipley()
	--Ripley
	stationRipley = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(psx,psy):setCallSign("Ripley"):setDescription("Load lifters and components")
	goods[stationRipley] = {{"lifter",5,82}}		
	if random(1,100) < 17 then tradeFood[stationRipley] = true end
	tradeMedicine[stationRipley] = true 
	if random(1,100) < 47 then tradeLuxury[stationRipley] = true end
	stationRipley.publicRelations = true
	stationRipley.generalInformation = "We provide load lifters and components"
	stationRipley.stationHistory = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship"
	return stationRipley
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
function placeRutherford()
	--Rutherford
	stationRutherford = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationRutherford:setPosition(psx,psy):setCallSign("Rutherford"):setDescription("Shield components and research")
	goods[stationRutherford] = {{"shield",5,90}}		
	tradeMedicine[stationRutherford] = true
	if random(1,100) < 43 then tradeLuxury[stationRutherford] = true end
	stationRutherford.publicRelations = true
	stationRutherford.generalInformation = "We research and fabricate components for ship shield systems"
	stationRutherford.stationHistory = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century"
	return stationRutherford
end
function placeShawyer()
	--Shawyer
	stationShawyer = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationShawyer:setPosition(psx,psy):setCallSign("Shawyer"):setDescription("Impulse engine components")
	goods[stationShawyer] = {{"impulse",5,100}}		
	tradeMedicine[stationShawyer] = true 
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
	goods[stationShree] = {{"tractor",5,90},{"repulsor",5,95}}
	tradeLuxury[stationShree] = true 
	tradeMedicine[stationShree] = true 
	tradeFood[stationShree] = true 
	stationShree.publicRelations = true
	stationShree.generalInformation = "We make ship systems designed to push or pull other objects around in space"
	stationShree.stationHistory = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today"
	return stationShree
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
function placeSoong()
	--Soong 
	stationSoong = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationSoong:setPosition(psx,psy):setCallSign("Soong"):setDescription("Android components")
	goods[stationSoong] = {{"android",5,73}}		
	tradeFood[stationSoong] = true 
	tradeLuxury[stationSoong] = true 
	stationSoong.publicRelations = true
	stationSoong.generalInformation = "We create androids and android components"
	stationSoong.stationHistory = "The station is named after Dr. Noonian Soong, the famous android researcher and builder"
	return stationSoong
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
function placeTokra()
	--Tokra
	stationTokra = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationTokra:setPosition(psx,psy):setCallSign("Tokra"):setDescription("Advanced material components")
	whatTrade = random(1,100)
	goods[stationTokra] = {{"filament",5,42}}		
	if whatTrade < 33 then
		tradeFood[stationTokra] = true
	elseif whatTrade > 66 then
		tradeMedicine[stationTokra] = true
	else
		tradeLuxury[stationTokra] = true
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
	goods[stationToohie] = {{"shield",5,90}}		
	tradeLuxury[stationToohie] = true
	if random(1,100) < 25 then tradeMedicine[stationToohie] = true end
	stationToohie.publicRelations = true
	stationToohie.generalInformation = "We research and make general and specialized components for ship shield and ship armor systems"
	stationToohie.stationHistory = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."
	return stationToohie
end
function placeUtopiaPlanitia()
	--Utopia Planitia
	stationUtopiaPlanitia = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationUtopiaPlanitia:setPosition(psx,psy):setCallSign("Utopia Planitia"):setDescription("Ship building and maintenance facility")
	goods[stationUtopiaPlanitia] = {{"food",10,1},{"medicine",5,5}}
	stationUtopiaPlanitia.publicRelations = true
	stationUtopiaPlanitia.generalInformation = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel"
	return stationUtopiaPlanitia
end
function placeVeloquan()
	--Veloquan
	stationVeloquan = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(psx,psy):setCallSign("Veloquan"):setDescription("Sensor components")
	goods[stationVeloquan] = {{"sensor",5,68}}
	tradeMedicine[stationVeloquan] = true 
	tradeFood[stationVeloquan] = true 
	stationVeloquan.publicRelations = true
	stationVeloquan.generalInformation = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use"
	stationVeloquan.stationHistory = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy"
	return stationVeloquan
end
function placeZefram()
	--Zefram
	stationZefram = SpaceStation():setTemplate(szt()):setFaction(stationFaction):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(psx,psy):setCallSign("Zefram"):setDescription("Warp engine components")
	goods[stationZefram] = {{"warp",5,140},{"food",5,1}}
	if random(1,100) < 27 then tradeMedicine[stationZefram] = true end
	if random(1,100) < 16 then tradeFood[stationZefram] = true end
	tradeLuxury[stationZefram] = true
	stationZefram.publicRelations = true
	stationZefram.generalInformation = "We specialize in the esoteric components necessary to make warp drives function properly"
	stationZefram.stationHistory = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do"
	return stationZefram
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
		transportSpawnDelay = delta + random(15,45) + missionLength*8
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
			wfv = string.format("station chosen: %s",target:getCallSign())
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
			wfv = string.format("transport model: %s",name)
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
            neutral = 2.5
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

function setOptionalOrders()
	optionalOrders = ""
	optionalOrdersPresent = false
	if plot2reminder ~= nil then
		optionalOrders = "\nOptional:\n" .. plot2reminder
		optionalOrdersPresent = true
	end
	if plot3reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot3reminder
		else
			optionalOrders = "\nOptional:\n" .. plot3reminder
			optionalOrdersPresent = true
		end
	end
	if plot4reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot4reminder
		else
			optionalOrders = "\nOptional:\n" .. plot4reminder
			optionalOrdersPresent = true
		end
	end
	if plot5reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot5reminder
		else
			optionalOrders = "\nOptional:\n" .. plot5reminder
			optionalOrdersPresent = true
		end
	end
	if plot8reminder ~= nil then
		if optionalOrdersPresent then
			optionalOrders = optionalOrders .. "\n" .. plot8reminder
		else
			optionalOrders = "\nOptional:\n" .. plot8reminder
			optionalOrdersPresent = true
		end
	end
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
			if math.random(1,13) <= (7 - difficulty) then
				comms_target.nukeAvail = true
			else
				comms_target.nukeAvail = false
			end
			if math.random(1,13) <= (8 - difficulty) then
				comms_target.empAvail = true
			else
				comms_target.empAvail = false
			end
			if math.random(1,13) <= (9 - difficulty) then
				comms_target.homeAvail = true
			else
				comms_target.homeAvail = false
			end
			if math.random(1,13) <= (10 - difficulty) then
				comms_target.mineAvail = true
			else
				comms_target.mineAvail = false
			end
			if math.random(1,13) <= (11 - difficulty) then
				comms_target.hvliAvail = true
			else
				comms_target.hvliAvail = false
			end
		end
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
					end
				end
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
					end
				end
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
					end
				end
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
					end
				end
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
					end
				end
			end)
		end
	end
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			setOptionalOrders()
			ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			else
				legAverage = (player.patrolLegAsimov + player.patrolLegUtopiaPlanitia + player.patrolLegArmstrong)/3
				ordMsg = ordMsg .. string.format("\n   patrol is %.2f percent complete",legAverage/patrolGoal*100)
				if player.patrolLegArmstrong ~= player.patrolLegAsimov or player.patrolLegUtopiaPlanitia ~= player.patrolLegArmstrong then
					if player.patrolLegArmstrong == player.patrolLegAsimov then
						if player.patrolLegArmstrong > player.patrolLegUtopiaPlanitia then
							ordMsg = ordMsg .. "\n   Least patrolled station: Utopia Panitia"
						else
							ordMsg = ordMsg .. "\n   Most patrolled station: Utopia Planitia"
						end
					elseif player.patrolLegArmstrong == player.patrolLegUtopiaPlanitia then
						if player.patrolLegArmstrong > player.patrolLegAsimov then
							ordMsg = ordMsg .. "\n   Least patrolled station: Asimov"
						else
							ordMsg = ordMsg .. "\n   Most patrolled station: Asimov"
						end
					else
						if player.patrolLegAsimov > player.patrolLegArmstrong then
							ordMsg = ordMsg .. "\n   Least patrolled station: Armstrong"
						else
							ordMsg = ordMsg .. "\n   Most patrolled station: Armstrong"
						end
					end
				end
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		if math.random(1,8) <= (6 - difficulty) then
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
		if math.random(1,8) <= (6 - difficulty) then
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
	if comms_target:getCallSign() == "Utopia Planitia" then
		if minerUpgrade then
			addCommsReply("Upgrade beam weapons with Joshua Kojak's research", function()
				if player.kojakUpgrade then
					setCommsMessage("You already have the upgrade.")
				else
					tempBeam = psb[player:getTypeName()]
					if tempBeam == nil then
						setCommsMessage("Your ship type does not support a beam weapon upgrade.")
					else
						if missionLength >= 3 then
							if player.kojakPart == nil then
								kojakChoice = math.random(1,5)
								if kojakChoice == 1 then
									player.kojakPart = "dilithium"
								elseif kojakChoice == 2 then
									player.kojakPart = "beam"
								elseif kojakChoice == 3 then
									player.kojakPart = "circuit"
								elseif kojakChoice == 4 then
									player.kojakPart = "software"
								else
									player.kojakPart = "tritanium"
								end
							end
							gi = 1
							kojakPartQuantity = 0
							repeat
								if goods[player][gi][1] == player.kojakPart then
									kojakPartQuantity = goods[player][gi][2]
								end
								gi = gi + 1
							until(gi > #goods[player])
							if kojakPartQuantity > 0 then
								kojakBeamUpgrade()
								decrementPlayerGoods(player.kojakPart)
								player.cargo = player.cargo + 1
								player.kojakUpgrade = true
								setCommsMessage(string.format("Thanks for the %s. Your beam weapons now have improved range, cycle time and damage.",player.kojakPart))
							else
								setCommsMessage(string.format("We find ourselves short of %s. Please bring us some of that kind of cargo and we can upgrade your beams",player.kojakPart))
							end
						else
							kojakBeamUpgrade()
							setCommsMessage("Your beam weapons now have improved range, cycle time and damage.")
							player.kojakUpgrade = true
						end
					end
				end
			end)
		end
		if nabbitUpgrade then
			addCommsReply("Upgrade impulse engines with Dan McNabbit's tuning parameters", function()
				if player.nabbitUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					if missionLength >= 3 then
						if player.nabbitPart == nil then
							nabbitPartChoice = math.random(1,5)
							if nabbitPartChoice == 1 then
								player.nabbitPart = "nickel"
							elseif nabbitPartChoice == 2 then
								player.nabbitPart = "impulse"
							elseif nabbitPartChoice == 3 then
								player.nabbitPart = "lifter"
							elseif nabbitPartChoice == 4 then
								player.nabbitPart = "filament"
							else
								player.nabbitPart = "cobalt"
							end
						end
						gi = 1
						nabbitPartQuantity = 0
						repeat
							if goods[player][gi][1] == player.nabbitPart then
								nabbitPartQuantity = goods[player][gi][2]
							end							
							gi = gi + 1
						until(gi > #goods[player])
						if nabbitPartQuantity > 0 then
							decrementPlayerGoods(player.nabbitPart)
							player.cargo = player.cargo + 1
							player:setImpulseMaxSpeed(player:getImpulseMaxSpeed()*1.2)
							if impulseDone == nil then
								playSoundFile("sa_54_UTImpulse.wav")
								impulseDone = "played"
							end
							setCommsMessage(string.format("Thanks for the %s. Your impulse engines now have improved speed",player.nabbitPart))
							player.nabbitUpgrade = true
						else
							setCommsMessage(string.format("We're short of %s. Please bring us some of that kind of cargo and we can upgrade your impulse engines",player.nabbitPart))
						end
					else
						player:setImpulseMaxSpeed(player:getImpulseMaxSpeed()*1.2)
						if impulseDone == nil then
							playSoundFile("sa_54_UTImpulse.wav")
							impulseDone = "played"
						end
						setCommsMessage("Your impulse engines now have improved speed")
						player.nabbitUpgrade = true
					end
				end
			end)
		end
		if lisbonUpgrade then
			addCommsReply("Apply Commander Lisbon's beam cooling algorithm", function()
				if player.lisbonUpgrade then
					setCommsMessage("You already have the upgrade.")
				else
					tempBeam = psb[player:getTypeName()]
					if tempBeam == nil then
						setCommsMessage("Your ship type does not support a beam weapon upgrade.")
					else
						if missionLength >= 3 then
							if player.lisbonPart == nil then
								lisbonPartChoice = math.random(1,5)
								if lisbonPartChoice == 1 then
									player.lisbonPart = "platinum"
								elseif lisbonPartChoice == 2 then
									player.lisbonPart = "battery"
								elseif lisbonPartChoice == 3 then
									player.lisbonPart = "robotic"
								elseif lisbonPartChoice == 4 then
									player.lisbonPart = "nanites"
								else
									player.lisbonPart = "gold"
								end
							end
							gi = 1
							lisbonPartQuantity = 0
							repeat
								if goods[player][gi][1] == player.lisbonPart then
									lisbonPartQuantity = goods[player][gi][2]
								end								
								gi = gi + 1
							until(gi > #goods[player])
							if lisbonPartQuantity > 0 then
								lisbonBeamUpgrade()
								decrementPlayerGoods(player.lisbonPart)
								player.cargo = player.cargo + 1
								setCommsMessage(string.format("Thanks for bringing us %s. Your beam weapons now generate less heat when firing",player.lisbonPart))
							else
								setCommsMessage(string.format("The algorithm requires components we don't have right now. Please bring us some %s and we can apply the upgrade",player.lisbonPart))
							end
						else
							lisbonBeamUpgrade()
							setCommsMessage("Your beam weapons now generate less heat when firing.")
						end
					end
				end
			end)
		end
		if artAnchorUpgrade then
			addCommsReply("Upgrade maneuverability", function()
				if player.artAnchorUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					if missionLength >= 3 then
						if player.artifactUpgradePart == nil then
							artifactUpgradePartChoice = math.random(1,5)
							if artifactUpgradePartChoice == 1 then
								player.artifactUpgradePart = "sensor"
							elseif artifactUpgradePartChoice == 2 then
								player.artifactUpgradePart = "repulsor"
							elseif artifactUpgradePartChoice == 3 then
								player.artifactUpgradePart = "tractor"
							elseif artifactUpgradePartChoice == 4 then
								player.artifactUpgradePart = "dilithium"
							else
								player.artifactUpgradePart = "nickel"
							end
						end
						gi = 1
						artifactPartQuantity = 0
						repeat
							if goods[player][gi][1] == player.artifactUpgradePart then
								artifactPartQuantity = goods[player][gi][2]
							end													
							gi = gi + 1
						until(gi > #goods[player])
						if artifactPartQuantity > 0 then
							decrementPlayerGoods(player.artifactUpgradePart)
							player.cargo = player.cargo + 1
							artifactUpgrade()
							setCommsMessage(string.format("We needed that %2, thanks. Your maneuverability has been significantly improved",player.artifactUpgradePart))
						else
							setCommsMessage(string.format("To upgrade, we need you to bring us some %s",player.artifactUpgradePart))
						end
					else
						artifactUpgrade()
						setCommsMessage("Your maneuverability has been significantly improved")
					end
				end
			end)
		end
		if addTubeUpgrade then
			addCommsReply("Add homing missile tube upgrade", function()
				if player.addTubeUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					if player.addTubeUpgradePart1 == nil then
						randomTubeAddCargo = math.random(1,5)
						if randomTubeAddCargo == 1 then
							player.addTubeUpgradePart1 = "platinum"
						elseif randomTubeAddCargo == 2 then
							player.addTubeUpgradePart1 = "dilithium"
						elseif randomTubeAddCargo == 3 then
							player.addTubeUpgradePart1 = "tritanium"
						elseif randomTubeAddCargo == 4 then
							player.addTubeUpgradePart1 = "cobalt"
						else
							player.addTubeUpgradePart1 = "nickel"
						end
						randomTubeAddCargo = math.random(1,5)
						if randomTubeAddCargo == 1 then
							player.addTubeUpgradePart2 = "lifter"
						elseif randomTubeAddCargo == 2 then
							player.addTubeUpgradePart2 = "tractor"
						elseif randomTubeAddCargo == 3 then
							player.addTubeUpgradePart2 = "circuit"
						elseif randomTubeAddCargo == 4 then
							player.addTubeUpgradePart2 = "software"
						else
							player.addTubeUpgradePart2 = "robotic"
						end
					end
					gi = 1
					addTubePart1quantity = 0
					addTubePart2quantity = 0
					repeat
						if goods[player][gi][1] == player.addTubeUpgradePart1 then
							addTubePart1quantity = goods[player][gi][2]
						end													
						if goods[player][gi][1] == player.addTubeUpgradePart2 then
							addTubePart2quantity = goods[player][gi][2]
						end													
						gi = gi + 1
					until(gi > #goods[player])
					if addTubePart1quantity > 0 and addTubePart2quantity > 0 then
						decrementPlayerGoods(player.addTubeUpgradePart1)
						decrementPlayerGoods(player.addTubeUpgradePart2)
						player.cargo = player.cargo + 2
						player.addTubeUpgrade = true
						originalTubes = player:getWeaponTubeCount()
						newTubes = originalTubes + 1
						player:setWeaponTubeCount(newTubes)
						player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
						player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
						player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
						setCommsMessage(string.format("Thanks for the %s and %s. You now have an additional homing torpedo tube",player.addTubeUpgradePart1,player.addTubeUpgradePart2))
						player.flakyTubeCount = 0
						player.tubeFixed = true
						if plot8 ~= flakyTube then
							plot8 = flakyTube
							flakyTubeTimer = 300
						end
					else
						setCommsMessage(string.format("We're running short of supplies. To add the homing torpedo tube, we need you to bring us %s and %s",player.addTubeUpgradePart1,player.addTubeUpgradePart2))				
					end
				end
			end)
		end		
	end
end

function artifactUpgrade()
	player:setRotationMaxSpeed(player:getRotationMaxSpeed()*2)
	player.artAnchorUpgrade = true
	if maneuverDone ~= "played" then
		playSoundFile("sa_54_UTManeuver.wav")
		maneuverDone = "played"
	end	
end

function lisbonBeamUpgrade()
	for b=0,tempBeam-1 do
		player:setBeamWeaponHeatPerFire(b,player:getBeamWeaponHeatPerFire(b) * 0.5)
	end
	player.lisbonUpgrade = true
	if coolBeamsDone ~= "played" then
		playSoundFile("sa_54_UTCoolBeams.wav")
		coolBeamsDone = "played"
	end
end

function kojakBeamUpgrade()
	for b=0,tempBeam-1 do
		newRange = player:getBeamWeaponRange(b) * 1.1
		newCycle = player:getBeamWeaponCycleTime(b) * .9
		newDamage = player:getBeamWeaponDamage(b) * 1.1
		tempArc = player:getBeamWeaponArc(b)
		tempDirection = player:getBeamWeaponDirection(b)
		player:setBeamWeapon(b,tempArc,tempDirection,newRange,newCycle,newDamage)
	end
	player.kojakUpgrade = true
	if tripleBeam ~= "played" then
		playSoundFile("sa_54_UTTripleBeam.wav")
		tripleBeam = "played"
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
		if math.random(1,13) <= (7 - difficulty) then
			comms_target.nukeAvail = true
		else
			comms_target.nukeAvail = false
		end
		if math.random(1,13) <= (8 - difficulty) then
			comms_target.empAvail = true
		else
			comms_target.empAvail = false
		end
		if math.random(1,13) <= (9 - difficulty) then
			comms_target.homeAvail = true
		else
			comms_target.homeAvail = false
		end
		if math.random(1,13) <= (10 - difficulty) then
			comms_target.mineAvail = true
		else
			comms_target.mineAvail = false
		end
		if math.random(1,13) <= (11 - difficulty) then
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
			ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			else
				legAverage = (player.patrolLegAsimov + player.patrolLegUtopiaPlanitia + player.patrolLegArmstrong)/3
				ordMsg = ordMsg .. string.format("\n   patrol is %.2f percent complete",legAverage/patrolGoal*100)
				if player.patrolLegArmstrong ~= player.patrolLegAsimov or player.patrolLegUtopiaPlanitia ~= player.patrolLegArmstrong then
					if player.patrolLegArmstrong == player.patrolLegAsimov then
						if player.patrolLegArmstrong > player.patrolLegUtopiaPlanitia then
							ordMsg = ordMsg .. "\n   Least patrolled station: Utopia Panitia"
						else
							ordMsg = ordMsg .. "\n   Most patrolled station: Utopia Planitia"
						end
					elseif player.patrolLegArmstrong == player.patrolLegUtopiaPlanitia then
						if player.patrolLegArmstrong > player.patrolLegAsimov then
							ordMsg = ordMsg .. "\n   Least patrolled station: Asimov"
						else
							ordMsg = ordMsg .. "\n   Most patrolled station: Asimov"
						end
					else
						if player.patrolLegAsimov > player.patrolLegArmstrong then
							ordMsg = ordMsg .. "\n   Least patrolled station: Armstrong"
						else
							ordMsg = ordMsg .. "\n   Most patrolled station: Armstrong"
						end
					end
				end
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			if plot1name == nil or plot1 == nil then
				oMsg = ""
			else
				oMsg = "plot1: " .. plot1name
			end
			if plot2name == nil or plot2 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot2: " .. plot2name
			end
			if plot3name == nil or plot3 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot3: " .. plot3name
			end
			if plot4name == nil or plot4 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot4: " .. plot4name
			end
			if plot5name == nil or plot5 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot5: " .. plot5name
			end
			if plotArtName == nil or plotArt == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplotArt: " .. plotArtName
			end
			if plotTname == nil or plotT == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplotT: " .. plotTname
			end
			if plot7name == nil or plot7 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot7: " .. plot7name
			end
			if plot11name == nil or plot11 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot11: " .. plot11name
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					oMsg = oMsg .. string.format("\n%s variables:\n",p:getCallSign())
					pvIndent = false
					if plot1name == "patrol asimov Utopia Planitia armstrong" then
						oMsg = oMsg .. string.format("   Legs - Asimov:%i Utopia Planitia:%i Armstrong:%i\n",p.patrolLegAsimov,p.patrolLegUtopiaPlanitia,p.patrolLegArmstrong)
					end
					if minerUpgrade then
						oMsg = oMsg .. "   Kojak upgrade available, "
						if p.kojakUpgrade then
							oMsg = oMsg .. "applied\n"
						else
							oMsg = oMsg .. "not yet applied"
							if missionLength >= 3 then
								if p.kojakPart == nil then
									oMsg = oMsg .. ", need cargo\n"
								else
									oMsg = oMsg .. string.format(", need %s\n",p.kojakPart)
								end
							else
								oMsg = oMsg .. "\n"
							end
						end
					else
						if plot2 ~= nil then
							if p.sickMinerAboard then
								oMsg = oMsg .. "   Kojak aboard"
								pvIndent = true
							end
							if p.receivedMinerResearch then
								if pvIndent then
									oMsg = oMsg .. ", received research"
								else
									oMsg = oMsg .. "   Received research"
									pvIndent = true
								end
							end
							if pvIndent then
								oMsg = oMsg .. "\n"
							end
						end
					end
					pvIndent = false
					if nabbitUpgrade then
						oMsg = oMsg .. "   Nabbit upgrade available, "
						if p.nabbitUpgrade then
							oMsg = oMsg .. "applied\n"
						else
							oMsg = oMsg .. "not yet applied"
							if missionLength >= 3 then
								if p.nabbitPart == nil then
									oMsg = oMsg .. ", need cargo\n"
								else
									oMsg = oMsg .. string.format(", need %s\n",p.nabbitPart)
								end
							else
								oMsg = oMsg .. "\n"
							end
						end
					else
						if plot3 ~= nil then
							if p.nabbitAboard then
								oMsg = oMsg .. "   McNabbit aboard\n"
							end
						end
					end
					if lisbonUpgrade then
						oMsg = oMsg .. "   Lisbon upgrade available, "
						if p.lisbonUpgrade then
							oMsg = oMsg .. "applied\n"
						else
							oMsg = oMsg .. "not yet applied"
							if missionLength >= 3 then
								if p.lisbonPart == nil then
									oMsg = oMsg .. ", need cargo\n"
								else
									oMsg = oMsg .. string.format(", need %s\n",p.lisbonPart)
								end
							else
								oMsg = oMsg .. "\n"
							end
						end
					else
						if plot4 ~= nil then
							if p.francisAboard then
								oMsg = oMsg .. "   Francis aboard"
								pvIndent = true
							end
							if p.lisbonAlgorithm then
								if pvIndent then
									oMsg = oMsg .. ", received Lisbon algorithm"
								else
									oMsg = oMsg .. "   Received Lisbon algorithm"
									pvIndent = true
								end
							end
							if pvIndent then
								oMsg = oMsg .. "\n"
							end
						end
					end
					if artAnchorUpgrade then
						oMsg = oMsg .. "   Artifact upgrade available, "
						if p.artAnchorUpgrade then
							oMsg = oMsg .. "applied\n"
						else
							oMsg = oMsg .. "not yet applied"
							if missionLength >= 3 then
								if p.artifactUpgradePart == nil then
									oMsg = oMsg .. ", need cargo\n"
								else
									oMsg = oMsg .. string.format(", need %s\n",p.artifactUpgradePart)
								end
							else
								oMsg = oMsg .. "\n"
							end
						end
					else
						if plotArt ~= nil then
							pvIndent = false
							if p.artAnchor1 then
								oMsg = oMsg .. "   artifact 1"
								if artAnchor1:isValid() then
									oMsg = oMsg .. " (closest)"
								else
									oMsg = oMsg .. " (aboard)"
								end
								pvIndent = true
							end
							if p.artAnchor2 then
								if pvIndent then
									oMsg = oMsg .. ", artifact 2"
								else
									oMsg = oMsg .. "   artifact 2"
									pvIndent = true
								end
								if artAnchor2:isValid() then
									oMsg = oMsg .. " (closest)"
								else
									oMsg = oMsg .. " (aboard)"
								end
							end
							if pvIndent then
								oMsg = oMsg .. "\n"
							end
						end
					end
				end
			end
			setCommsMessage(oMsg)
			if plot7 ~= nil and plot7name ~= nil then
				addCommsReply("Plot7 details", function()
					setCommsMessage(string.format("game time: %f, ambush time: %f",gameTimeLimit,ambushTime))
					addCommsReply("Back", commsStation)
				end)
			end
			if plot1 ~= nil and plot1name ~= nil then
				addCommsReply("Plot1 details", function()
					oMsg = string.format("Patrol goal: %i  Highest patrol leg: %i  Jump start timer: %f Patrol legs:\n",patrolGoal, highestPatrolLeg, jumpStartTimer)
					for p5idx=1,8 do
						p5obj = getPlayerShip(p5idx)
						if p5obj ~= nil and p5obj:isValid() then
							oMsg = oMsg .. string.format("%s; Asimov: %i, Utopia Planitia: %i, Armstrong: %i\n",p5obj:getCallSign(),p5obj.patrolLegAsimov,p5obj.patrolLegUtopiaPlanitia,p5obj.patrolLegArmstrong)
						end
					end
					if longWave ~= nil then
						oMsg = oMsg .. string.format("long wave: %i\n",longWave)
						if longWave == 2 then
							wave1count = 0
							for _, enemy in ipairs(longWave1List) do
								if enemy:isValid() then
									wave1count = wave1count + 1
								end
							end
							wave2count = 0
							for _, enemy in ipairs(longWave2List) do
								if enemy:isValid() then
									wave2count = wave2count + 1
								end
							end
							oMsg = oMsg .. string.format("wave1count: %i\n",wave1count)
							oMsg = oMsg .. string.format("wave2count: %i\n",wave2count)
						end
						if longWave == 6 then
							wave3count = 0
							for _, enemy in ipairs(longWave3List) do
								if enemy:isValid() then
									wave3count = wave3count + 1
								end
							end
							wave4count = 0
							for _, enemy in ipairs(longWave4List) do
								if enemy:isValid() then
									wave4count = wave4count + 1
								end
							end
							wave5count = 0
							for _, enemy in ipairs(longWave5List) do
								if enemy:isValid() then
									wave5count = wave5count + 1
								end
							end
							oMsg = oMsg .. string.format("wave3count: %i\n",wave3count)
							oMsg = oMsg .. string.format("wave4count: %i\n",wave4count)
							oMsg = oMsg .. string.format("wave5count: %i\n",wave5count)
						end
						oMsg = oMsg .. string.format("Wave delay timer: %f",waveDelayTimer)
					end
					if hna == nil then
						oMsg = oMsg .. "\nhna: nil"
					else
						oMsg = oMsg .. string.format("\nhna: %f",hna)
					end
					if fhnx ~= nil then
						oMsg = oMsg .. string.format("\nfhnx: %f",fhnx)
					end
					if fhny ~= nil then
						oMsg = oMsg .. string.format("\nfhny: %f", fhny)
					end
					if stationKitmar ~= nil then
						if stationKitmar:isValid() then
							oMsg = oMsg .. string.format("\nKitmar in sector %s",stationKitmar:getSectorName())
						end
					end
					if recon1 ~= nil then
						if recon1:isValid() then
							oMsg = oMsg .. string.format("\nRecon-1 in sector %s",recon1:getSectorName())
						end
					end
					setCommsMessage(oMsg)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Skip to defend Utopia", function()
					artAnchorUpgrade = true
					longWave = 0
					minerUpgrade = true
					nabbitUpgrade = true
					lisbonUpgrade = true
					waveDelayTimer = 120
					plot1 = defendUtopia
				end)
			end
			if plot2 ~= nil and plot2name ~= nil then
				addCommsReply("plot2 details", function()
					p2Msg = string.format("sick miner timer: %f",sickMinerTimer)
					enemy_count = 0
					for _, enemy in ipairs(nuisanceList) do
						if enemy:isValid() then
							enemy_count = enemy_count + 1
						end
					end
					p2Msg = p2Msg .. string.format("\nRemaining enemies: %i",enemy_count)
					setCommsMessage(p2Msg)
					addCommsReply("Back", commsStation)
				end)
			end
			if plot3 ~= nil and plot3name ~= nil then
				enemy_count = 0
				for _, enemy in ipairs(incursionList) do
					if enemy:isValid() then
						enemy_count = enemy_count + 1
					end
				end
				if enemy_count > 0 then
					addCommsReply("Plot3 details", function()
						setCommsMessage(string.format("Remaining enemies: %i",enemy_count))
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if plot4 ~= nil and plot4name ~= nil then
				if stowawayName ~= nil then
					addCommsReply("Plot4 details", function()
						oMsg = "Stow away freighter name: " .. stowawayName .. "\n"
						for idx, p in ipairs(playerList) do
							if p:isValid() then
								oMsg = oMsg .. string.format("Player %i distance to stowaway freighter: %f\n",idx,distance(stowawayTransport,p))
							end
						end
						setCommsMessage(oMsg)
						addCommsReply("Back", commsStation)
					end)
				end
			end
			if plot4name == nil then
				addCommsReply("Initiate plot4", function()
					plot4 = attack1
				end)
			end
			if plot5 ~= nil and plot5name ~= nil then
				addCommsReply("Plot5 details", function()
					enemy_count = 0
					for _, enemy in ipairs(attack2list) do
						if enemy:isValid() then
							enemy_count = enemy_count + 1
						end
					end
					setCommsMessage(string.format("Remaining enemies: %i",enemy_count))
					addCommsReply("Back", commsStation)
				end)
			end
			if plotT ~= nil and plotTname ~= nil then
				addCommsReply("PlotT details", function()
					setCommsMessage("What details?")
					addCommsReply("Number of stations", function()
						setCommsMessage(string.format("Number of stations: %i\n",#stationList))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Number of transports", function ()
						setCommsMessage(string.format("Number of transports: %i\n",#transportList))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Transport spawn delay", function()
						setCommsMessage(string.format("Transport spawn delay: %f",transportSpawnDelay))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Transports docked, invalid and with invalid targets", function()
						transportsDocked = 0
						invalidTransports = 0
						invalidTargets = 0
						for _, obj in ipairs(transportList) do
							if obj:isValid() then
								if obj.target:isValid() then
									if obj:isDocked(obj.target) then
										transportsDocked = transportsDocked + 1
									end
								else
									invalidTargets = invalidTargets + 1
								end
							else
								invalidTransports = invalidTransports + 1
							end
						end
						setCommsMessage(string.format("Number of transports...\nDocked: %i, Invalid: %i, Invalid dock targets: %i\n",transportsDocked,invalidTransports,invalidTargets))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("last transport count", function()
						setCommsMessage(string.format("Last transport count: %i",lastTransportCount))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("All of the above", function()
						oMsg = string.format("Number of stations: %i\n",#stationList)
						oMsg = oMsg .. string.format("Number of transports: %i\n",#transportList)
						transportsDocked = 0
						invalidTransports = 0
						invalidTargets = 0
						for _, obj in ipairs(transportList) do
							if obj:isValid() then
								if obj.target:isValid() then
									if obj:isDocked(obj.target) then
										transportsDocked = transportsDocked + 1
									end
								else
									invalidTargets = invalidTargets + 1
								end
							else
								invalidTransports = invalidTransports + 1
							end
						end
						oMsg = oMsg .. string.format("Number of transports...\nDocked: %i, Invalid: %i, Invalid dock targets: %i\n",transportsDocked,invalidTransports,invalidTargets)
						oMsg = oMsg .. string.format("Transport spawn delay: %f",transportSpawnDelay)
						oMsg = oMsg .. string.format("Last transport count: %i",lastTransportCount)
						setCommsMessage(oMsg)
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Nearest stations", function()
				distanceStations = {}
				cs, rs1 = nearStations(comms_target,stationList)
				table.insert(distanceStations,cs)
				cs, rs2 = nearStations(comms_target,rs1)
				table.insert(distanceStations,cs)
				cs, rs3 = nearStations(comms_target,rs2)
				table.insert(distanceStations,cs)
				cs, rs4 = nearStations(comms_target,rs3)
				table.insert(distanceStations,cs)
				cs, rs5 = nearStations(comms_target,rs4)
				table.insert(distanceStations,cs)
				oMsg = "Nearest stations:"
				for _, obj in ipairs(distanceStations) do
					oMsg = oMsg .. "\n" .. obj:getCallSign()
				end
				setCommsMessage(oMsg)
				addCommsReply("Back", commsStation)
			end)
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
			for gi=1,#goods[stationList[sti]] do
				if math.random(1,10) == 1 then
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

		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
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
		if faction == "Kraylor" then
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
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
--[[-----------------------------------------------------------------
      First plot line - patrol between stations then defend 
-----------------------------------------------------------------]]--
function initialOrderMessage(delta)
	plot1name = "initialOrderMessage"
	plot1 = patrolAsimovUtopiaPlanitiaArmstrong
	if difficulty > .5 then
		plot11 = jumpStart
	end
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog(string.format("Welcome to the delta quadrant, %s. The independent stations in the area outnumber the human naval stations, but they all rely on us to protect them.",p:getCallSign()),"Magenta")
			p:addToShipLog("Your job is to patrol between the three major human naval stations: Asimov, Utopia Planitia and Armstrong. You'll need to dock with each of these stations. Automated systems will extract your routes and track your progress on patrolling between these stations. The primary objective of your patrol is to watch for enemy ships and intercept them, prevent them from destroying the three bases mentioned as your patrol endpoints. Enemies in the area may harass other stations in the area. Protecting the other stations is your secondary objective. Spread goodwill in this high growth, high value quadrant. Our enemies dearly wish to give us a black eye here and claim it for their own.","Magenta")
		end
	end
end

function patrolAsimovUtopiaPlanitiaArmstrong(delta)
	plot1name = "patrol asimov Utopia Planitia armstrong"
	if highestConcurrentPlayerCount > 0 then
		if not stationAsimov:isValid() then
			globalMessage("Asimov station destroyed")
			defeatTimer = 15
			plot1 = defeated
		end
		if not stationUtopiaPlanitia:isValid() then
			globalMessage("Utopia Planitia station destroyed")
			defeatTimer = 15
			plot1 = defeated
		end
		if not stationArmstrong:isValid() then
			globalMessage("Armstrong station destroyed")
			defeatTimer = 15
			plot1 = defeated
		end
	end
	patrolComplete = false
	playerCount = 0
	for p5idx=1,8 do
		p5obj = getPlayerShip(p5idx)
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj:isDocked(stationAsimov) then
				if p5obj.patrolLegAsimov < p5obj.patrolLegUtopiaPlanitia or p5obj.patrolLegAsimov < p5obj.patrolLegArmstrong then
					p5obj.patrolLegAsimov = p5obj.patrolLegAsimov + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegAsimov == p5obj.patrolLegUtopiaPlanitia and p5obj.patrolLegAsimov == p5obj.patrolLegArmstrong then
					p5obj.patrolLegAsimov = p5obj.patrolLegAsimov + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegAsimov >= patrolGoal then
					patrolComplete = true
				end
				if p5obj.patrolLegAsimov > highestPatrolLeg then
					highestPatrolLeg = p5obj.patrolLegAsimov
				end
			end
			if p5obj:isDocked(stationUtopiaPlanitia) then
				if p5obj.patrolLegUtopiaPlanitia < p5obj.patrolLegAsimov or p5obj.patrolLegUtopiaPlanitia < p5obj.patrolLegArmstrong then
					p5obj.patrolLegUtopiaPlanitia = p5obj.patrolLegUtopiaPlanitia + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegUtopiaPlanitia == p5obj.patrolLegAsimov and p5obj.patrolLegUtopiaPlanitia == p5obj.patrolLegArmstrong then
					p5obj.patrolLegUtopiaPlanitia = p5obj.patrolLegUtopiaPlanitia + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegUtopiaPlanitia >= patrolGoal then
					patrolComplete = true
				end
				if p5obj.patrolLegUtopiaPlanitia > highestPatrolLeg then
					highestPatrolLeg = p5obj.patrolLegUtopiaPlanitia
				end
			end
			if p5obj:isDocked(stationArmstrong) then
				if p5obj.patrolLegArmstrong < p5obj.patrolLegUtopiaPlanitia or p5obj.patrolLegArmstrong < p5obj.patrolLegAsimov then
					p5obj.patrolLegArmstrong = p5obj.patrolLegArmstrong + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegArmstrong == p5obj.patrolLegUtopiaPlanitia and p5obj.patrolLegArmstrong == p5obj.patrolLegAsimov then
					p5obj.patrolLegArmstrong = p5obj.patrolLegArmstrong + 1
					p5obj:addReputationPoints(1)
				end
				if p5obj.patrolLegArmstrong >= patrolGoal then
					patrolComplete = true
				end
				if p5obj.patrolLegArmstrong > highestPatrolLeg then
					highestPatrolLeg = p5obj.patrolLegArmstrong
				end
			end
			playerCount = playerCount + 1
		end
		if highestPatrolLeg == 2 then
			if nuisanceSpawned == nil then
				nuisanceSpawned = "ready"
				nuisanceTimer = random(30,90)
				plot2 = nuisance
				removeGMFunction(GMInitiatePlot2)
			end
		end
		if highestPatrolLeg == 3 and missionLength > 1then
			if attack3spawned == nil then
				attack3spawned = "ready"
				attack3Timer = random(15,40)
				plot8 = attack3
				removeGMFunction(GMInitiatePlot8)
			end
		end
		if highestPatrolLeg == 4 and missionLength > 1 then
			if attack4spawned == nil then
				attack4spawned = "ready"
				attack4Timer = random(20,50)
				plot9 = attack4
				removeGMFunction(GMInitiatePlot9)
			end
		end
		if highestPatrolLeg == 5 then
			if incursionSpawned == nil then
				incursionSpawned = "ready"
				incursionTimer = random(30,90)
				plot3 = incursion
				removeGMFunction(GMInitiatePlot3)
			end
		end
		if highestPatrolLeg == 6 and missionLength > 1 then
			if attack5spawned == nil then
				attack5spawned = "ready"
				attack5Timer = random(20,50)
				plot10 = attack5
				removeGMFunction(GMInitiatePlot10)
			end
		end
		if highestPatrolLeg == 7 then
			if attack1spawned == nil then
				attack1spawned = "ready"
				attack1Timer = random(40,120)
				plot4 = attack1
				removeGMFunction(GMInitiatePlot4)
			end
		end
		if highestPatrolLeg == 8 then
			if attack2spawned == nil then
				attack2spawned = "ready"
				plot5 = attack2
				removeGMFunction(GMInitiatePlot5)
			end		
		end
		if patrolComplete then
			plot1 = afterPatrol
		end
	end
	if playerCount == 0 and highestConcurrentPlayerCount > 0 then
		victory("Kraylor")
	end
	sporadicHarassTimer = sporadicHarassTimer - delta
	if sporadicHarassTimer < 0 then
		randomPatrolStation = patrolStationList[math.random(1,#patrolStationList)]
		p = closestPlayerTo(randomPatrolStation)
		px, py = p:getPosition()
		ox, oy = vectorFromAngle(random(0,360),getLongRangeRadarRange()+1000)
		harassFleet = spawnEnemies(px+ox,py+oy,difficulty)
		whatToDo = math.random(1,3)
		if whatToDo == 1 then
			for _, enemy in ipairs(harassFleet) do
				enemy:orderAttack(p)
			end
		elseif whatToDo == 2 then
			for _, enemy in ipairs(harassFleet) do
				enemy:orderAttack(randomPatrolStation)
			end
		else
			for _, enemy in ipairs(harassFleet) do
				enemy:orderRoaming()
			end
		end
		sporadicHarassTimer = delta + sporadicHarassInterval - (difficulty*30) - random(1,60)
	end
end

function playDefendUtopiaMsg()
	playSoundFile("sa_54_AuthMBDefend.wav")
	closestUtopiaPlayer:removeCustom(defendUtopiaMsgButton)
	closestUtopiaPlayer:removeCustom(defendUtopiaMsgButtonOps)
end

function afterPatrol(delta)
	plot1name = "afterPatrol"
	if not stationAsimov:isValid() then
		globalMessage("Asimov station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	if not stationUtopiaPlanitia:isValid() then
		globalMessage("Utopia Planitia station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	if not stationArmstrong:isValid() then
		globalMessage("Armstrong station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	nuisanceCount = 0
	for _, enemy in ipairs(nuisanceList) do
		if enemy:isValid() then
			nuisanceCount = nuisanceCount + 1
		end
	end
	incursionCount = 0
	for _, enemy in ipairs(incursionList) do
		if enemy:isValid() then
			incursionCount = incursionCount + 1
		end
	end
	attack1count = 0
	for _, enemy in ipairs(attack1list) do
		if enemy:isValid() then
			attack1count = attack1count + 1
		end
	end
	attack2count = 0
	for _, enemy in ipairs(attack2list) do
		if enemy:isValid() then
			attack2count = attack2count + 1
		end
	end
	attack3count = 0
	for _, enemy in ipairs(attack3list) do
		if enemy:isValid() then
			attack3count = attack3count + 1
		end
	end	
	if incursionCount + nuisanceCount + attack1count + attack2count + attack3count == 0 then
		if missionLength > 3 then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Stop patrol and Defend Utopia Planitia","Magenta")
				end
			end
			closestUtopiaPlayer = closestPlayerTo(stationUtopiaPlanitia)
			if closestUtopiaPlayer ~= nil then
				stationUtopiaPlanitia:sendCommsMessage(closestUtopiaPlayer, "Audio message received, auto-transcribed to log, stored for playback: UTPLNT441")
				closestUtopiaPlayer:addToShipLog("[UTPLNT441](Utopia Planitia) Our long range sensors show a number of enemy ships approaching. Cease patrolling Torrin/Duncan and defend station Utopia Planitia","Yellow")
				if defendUtopiaMsgButton == nil then
					defendUtopiaMsgButton = "defendUtopiaMsgButton"
					closestUtopiaPlayer:addCustomButton("Relay",defendUtopiaMsgButton,"|> UTPLNT441",playDefendUtopiaMsg)
					defendUtopiaMsgButtonOps = "defendUtopiaMsgButtonOps"
					closestUtopiaPlayer:addCustomButton("Operations",defendUtopiaMsgButtonOps,"|> UTPLNT441",playDefendUtopiaMsg)
				end
			end
			stationUtopiaPlanitia:sendCommsMessage(closestPlayer, "Our long range sensors show a number of enemy ships approaching. Cease patrolling Torrin/Duncan and defend station Utopia Planitia")
			primaryOrders = "Defend Utopia Planitia"
			waveDelayTimer = 120
			longWave = 0
			plot1 = defendUtopia
			removeGMFunction(GMSkipToDefend)
		else
			playSoundFile("sa_54_AuthMBVictory.wav")
			victory("Human Navy")
		end
	end
end

function playUtopiaBreakMsg()
	playSoundFile("sa_54_AuthMBBreak.wav")
	closestMidWaveUtopiaPlayer:removeCustom(utopiaBreakMsgButton)
	closestMidWaveUtopiaPlayer:removeCustom(utopiaBreakMsgButtonOps)
end

function defendUtopia(delta)
	plot1name = "defendUtopia"
	if not stationUtopiaPlanitia:isValid() then
		globalMessage("Utopia Planitia station destroyed")
		defeatTimer = 15
		plot1 = defeated
	end
	waveDelayTimer = waveDelayTimer - delta
	if longWave == 0 then
		if waveDelayTimer < 0 then
			longWave1List = spawnEnemies(utopiaPlanitiax+irandom(30000,40000),utopiaPlanitiay+irandom(-5000,5000),.5,"Kraylor")
			for _, enemy in ipairs(longWave1List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 1
		end
	end
	if longWave == 1 then
		if waveDelayTimer < 0 then
			longWave2List = spawnEnemies(utopiaPlanitiax+irandom(-40000,-30000),utopiaPlanitiay+irandom(-5000,5000),.5,"Kraylor")
			for _, enemy in ipairs(longWave2List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 2
		end
	end
	if longWave == 2 then
		if waveDelayTimer < 0 then
			wave1count = 0
			for _, enemy in ipairs(longWave1List) do
				if enemy:isValid() then
					wave1count = wave1count + 1
				end
			end
			wave2count = 0
			for _, enemy in ipairs(longWave2List) do
				if enemy:isValid() then
					wave2count = wave2count + 1
				end
			end
			if wave1count + wave2count == 0 then
				closestMidWaveUtopiaPlayer = closestPlayerTo(stationUtopiaPlanitia)
				if closestMidWaveUtopiaPlayer ~= nil then
					stationUtopiaPlanitia:sendCommsMessage(closestMidWaveUtopiaPlayer, "Audio message received, auto-transcribed to log, stored for playback: UTPLNT477")
					closestMidWaveUtopiaPlayer:addToShipLog("[UTPLNT477](Utopia Planitia) You have taken care of the closest enemies. Our extreme range sensors show more, but they should not arrive for a couple of minutes","Yellow")
					if utopiaBreakMsgButton == nil then
						utopiaBreakMsgButton = "utopiaBreakMsgButton"
						closestMidWaveUtopiaPlayer:addCustomButton("Relay",utopiaBreakMsgButton,"|> UTPLNT477",playUtopiaBreakMsg)
						utopiaBreakMsgButtonOps = "utopiaBreakMsgButtonOps"
						closestMidWaveUtopiaPlayer:addCustomButton("Operations",utopiaBreakMsgButtonOps,"|> UTPLNT477",playUtopiaBreakMsg)
					end
				end
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog("Nearest ships cleared. More to come shortly","Magenta")
					end
				end
				longWave = 3
				waveDelayTimer = delta + 120
			end
		end
	end
	if longWave == 3 then
		if waveDelayTimer < 0 then
			longWave3List = spawnEnemies(utopiaPlanitiax+irandom(-10000,10000),utopiaPlanitiay+irandom(30000,40000),1,"Kraylor")
			for _, enemy in ipairs(longWave3List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 4
		end
	end
	if longWave == 4 then
		if waveDelayTimer < 0 then
			longWave4List = spawnEnemies(utopiaPlanitiax+irandom(-10000,10000),utopiaPlanitiay+irandom(30000,40000),2,"Kraylor")
			for _, enemy in ipairs(longWave4List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 300
			longWave = 5
		end
	end
	if longWave == 5 then
		if waveDelayTimer < 0 then
			longWave5List = spawnEnemies(utopiaPlanitiax+irandom(-10000,10000),utopiaPlanitiay+irandom(30000,40000),1,"Kraylor")
			for _, enemy in ipairs(longWave5List) do
				enemy:orderFlyTowards(utopiaPlanitiax, utopiaPlanitiay)
			end
			waveDelayTimer = delta + 120
			longWave = 6
		end
	end
	if longWave == 6 then
		if waveDelayTimer < 0 then
			wave3count = 0
			for _, enemy in ipairs(longWave3List) do
				if enemy:isValid() then
					wave3count = wave3count + 1
				end
			end
			wave4count = 0
			for _, enemy in ipairs(longWave4List) do
				if enemy:isValid() then
					wave4count = wave4count + 1
				end
			end
			wave5count = 0
			for _, enemy in ipairs(longWave5List) do
				if enemy:isValid() then
					wave5count = wave5count + 1
				end
			end
			if wave3count + wave4count + wave5count == 0 then
				if difficulty > 1 then
					plot1 = destroyEnemyStronghold
					removeGMFunction(GMSkipToDestroy)
				else
					victory("Human Navy")
				end
			end
		end
	end
end

function defeated(delta)
	defeatTimer = defeatTimer - delta
	if defeatTimer < 0 then
		victory("Kraylor")
	end
end

function destroyEnemyStronghold(delta)
	if lateEnemies == nil then
		lateEnemies = "placed"
		scarletx = random(120000,200000)
		scarlety = random(120000,200000)
		stationScarletCitadel = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCommsScript(""):setCommsFunction(commsStation)
		stationScarletCitadel:setPosition(scarletx,scarlety):setCallSign("Scarlet Citadel")
		wpRadius = 3000
		x, y = vectorFromAngle(0,wpRadius)
		wp13 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-13")
		x, y = vectorFromAngle(90,wpRadius)
		wp45 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-45")
		x, y = vectorFromAngle(180,wpRadius)
		wp33 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-33")
		x, y = vectorFromAngle(270,wpRadius)
		wp57 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-57")
		if difficulty > 2 then
			x, y = vectorFromAngle(45,wpRadius)
			wp62 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-62")			
			x, y = vectorFromAngle(135,wpRadius)
			wp78 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-78")			
			x, y = vectorFromAngle(225,wpRadius)
			wp25 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-25")			
			x, y = vectorFromAngle(315,wpRadius)
			wp27 = CpuShip():setFaction("Kraylor"):setposition(scarletx+x,scarlety+y):setTemplate("Defense platform"):setCallSign("WP-27")			
		end
		strongholdDefense = spawnEnemies(scarletx-5000,scarlety-5000,1,"Kraylor")
		for _, enemy in ipairs(strongholdDefense) do
			enemy:orderDefendTarget(stationScarletCitadel)
		end
		strongholdOffense = spawnEnemies(scarletx-8000,scarlety-8000,1,"Kraylor")
		targetPlayer = closestPlayerTo(stationScarletCitadel)
		if targetPlayer:isValid() then
			for _, enemy in ipairs(strongholdOffense) do
				enemy:orderAttack(targetPlayer)
			end
			targetPlayer:addToShipLog(string.format("Enemy base nearby located in secctor %s. Fleet assembled near Utopia Planitia to assist if needed. Destroy base.",stationScarletCitadel:getSectorName()),"Magenta")
		end
		posse = spawnEnemies(utopiaPlanitiaX,utopiaPlanitiaY+8000,2,"Human Navy")
		primaryOrders = string.format("Destroy enemy base in sector %s",stationScarletCitadel:getSectorName())
		for _, friend in ipairs(posse) do
			friend:orderStandGround()
			if #posseShipNames > 0 then
				ni = math.random(1,#posseShipNames)
				friend:setCallSign(posseShipNames[ni])
				table.remove(posseShipNames,ni)
			end
		end
		scarletDanger = 1
		scarletTimer = 300
	end
	if stationScarletCitadel:isValid() then
		scarletTimer = scarletTimer - delta
		if scarletTimer < 0 then
			if scarletDanger > 0 then
				scarletTimer = delta + 300
				strongholdDefense = spawnEnemies(scarletx-5000,scarlety-5000,scarletDanger,"Kraylor")
				for _, enemy in ipairs(strongholdDefense) do
					enemy:orderDefendTarget(stationScarletCitadel)
				end
				strongholdOffense = spawnEnemies(scarletx-8000,scarlety-8000,scarletDanger,"Kraylor")
				targetPlayer = closestPlayerTo(stationScarletCitadel)
				if targetPlayer:isValid() then
					for _, enemy in ipairs(strongholdOffense) do
						enemy:orderAttack(targetPlayer)
					end
				end
				scarletDanger = scarletDanger - 0.1
			end
		end
	else
		victory("Human Navy")
	end
end
--[[-----------------------------------------------------------------
      Second plot line: small enemy fleet followed by sick miner 
-----------------------------------------------------------------]]--
function playAsimovSensorTechMessage()
	playSoundFile("sa_54_TorrinSensorTech.wav")
	closestPlayer:removeCustom(playMsgFromAsimovButton)
	closestPlayer:removeCustom(playMsgFromAsimovButtonOps)
end

function nuisance(delta)
	if minerUpgrade then
		plot2 = nil
	end
	plot2name = "nuisance"
	if nuisanceSpawned == "ready" then
		nuisanceSpawned = "done"
		asimovx, asimovy = stationAsimov:getPosition()
		nuisanceList = spawnEnemies(asimovx+irandom(20000,30000),asimovx+irandom(20000,30000),.4,"Kraylor")
		for _, enemy in ipairs(nuisanceList) do
			enemy:orderFlyTowards(asimovx, asimovy)
		end
	end
	nuisanceTimer = nuisanceTimer - delta
	if nuisanceTimer < 0 then
		if nuisanceHelp == nil then
			nuisanceHelp = "complete"
			closestPlayer = closestPlayerTo(stationAsimov)
			if closestPlayer ~= nil then
				stationAsimov:sendCommsMessage(closestPlayer, "Audio message received, auto-transcribed into log, stored for playback: ASMVSNSR003")
				closestPlayer:addToShipLog("[ASMVSNSR003](Asimov sensor technician) Our long range sensors show enemies approaching","Yellow")
				if playMsgFromAsimovButton == nil then
					playMsgFromAsimovButton = "playMsgFromAsimovButton"
					closestPlayer:addCustomButton("Relay",playMsgFromAsimovButton,"|> ASMVSNSR003",playAsimovSensorTechMessage)
					playMsgFromAsimovButtonOps = "playMsgFromAsimovButtonOps"
					closestPlayer:addCustomButton("Operations",playMsgFromAsimovButtonOps,"|> ASMVSNSR003",playAsimovSensorTechMessage)
				end		
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(nuisanceList) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		if nuisanceAward == nil then
			nuisanceAward = "done"
			closestPlayer:addReputationPoints(25.0)
			sickMinerTimer = random(90,120)
			plot2 = sickMiner
		end
	end
end

function playSickStationMessage()
	playSoundFile("sa_54_MinerSickRequest.wav")
	closestSickMinerPlayer:removeCustom(playMsgFromSickStationButton)
	closestSickMinerPlayer:removeCustom(playMsgFromSickStationButtonOps)
end

function sickMiner(delta)
	plot2name = "sickMiner"
	sickMinerTimer = sickMinerTimer - delta
	if sickMinerTimer < 0 then
		if sickMinerHelp == nil then
			sickMinerHelp = "done"
			sickMinerStationChoice = math.random(1,5)
			if sickMinerStationChoice == 1 then
				sickMinerStation = stationKrik
			elseif sickMinerStationChoice == 2 then
				sickMinerStation = stationKrak
			elseif sickMinerStationChoice == 3 then
				sickMinerStation = stationKruk
			elseif sickMinerStationChoice == 4 then
				sickMinerStation = stationGrasberg
			else
				sickMinerStation = stationImpala
			end
			plot2reminder = string.format("Pick up Joshua Kojack from %s in sector %s and take him to Bethesda",sickMinerStation:getCallSign(),sickMinerStation:getSectorName())
			closestSickMinerPlayer = closestPlayerTo(sickMinerStation)
			if closestSickMinerPlayer ~= nil then
				sickMinerStation:sendCommsMessage(closestSickMinerPlayer, "Audio message received, auto-transcribed into log, stored for playback: MINSTN014")
				closestSickMinerPlayer:addToShipLog(string.format("[MINSTN014](%s in sector %s) Joshua Kojak has come down with something our autodoc can't handle. He's supposed to be helping us mine these asteroids, but he can't do us any good while he's sick. Can you transport him to Bethesda station? I hear they've got some clever doctors there that might help.",sickMinerStation:getCallSign(),sickMinerStation:getSectorName()),"Yellow")
				if playMsgFromSickStationButton == nil then
					playMsgFromSickStationButton = "playMsgFromSickStationButton"
					closestSickMinerPlayer:addCustomButton("Relay",playMsgFromSickStationButton,"|> MINSTN014",playSickStationMessage)
					playMsgFromSickStationButtonOps = "playMsgFromSickStationButtonOps"
					closestSickMinerPlayer:addCustomButton("Operations",playMsgFromSickStationButtonOps,"|> MINSTN014",playSickStationMessage)
				end				
			end
			sickMinerState = "sick on station"
			plot2 = getSickMinerFromStation
		end
	end
end

function playSickStationMessage2()
	playSoundFile("sa_54_MinerSickAboard.wav")
	sickMinerShip:removeCustom(playMsg2FromSickStationButton)
	sickMinerShip:removeCustom(playMsg2FromSickStationButtonOps)
end

function getSickMinerFromStation(delta)
	plot2name = "getSickMinerFromStation"
	if sickMinerState == "sick on station" then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p:isDocked(sickMinerStation) then
				p.sickMinerAboard = true
				sickMinerState = "aboard player ship"
				sickMinerStation:sendCommsMessage(p,"Audio message received, auto-transcribed into log, stored for playback: MINSTN019")
				p:addToShipLog("[MINSTN019]Thanks for getting Joshua aboard. Please take him to Bethesda","Yellow")
				sickMinerShip = p
				if playMsg2FromSickStationButton == nil then
					playMsg2FromSickStationButton = "playMsg2FromSickStationButton"
					sickMinerShip:addCustomButton("Relay",playMsg2FromSickStationButton,"|> MINSTN019",playSickStationMessage2)
					playMsg2FromSickStationButtonOps = "playMsg2FromSickStationButtonOps"
					sickMinerShip:addCustomButton("Operations",playMsg2FromSickStationButtonOps,"|> MINSTN019",playSickStationMessage2)
				end
				sickMinerShip:addReputationPoints(15)
				plot2 = takeSickMinerToBethesda
			end
		end
	end
end

function playBethesdaStationMessage()
	playSoundFile("sa_54_BethesdaDoctor.wav")
	sickMinerShip:removeCustom(playMsgFromBethesdaButton)
	sickMinerShip:removeCustom(playMsgFromBethesdaButtonOps)
end

function takeSickMinerToBethesda(delta)
	plot2name = "takeSickMinerToBethesda"
	if sickMinerState == "aboard player ship" then
		if sickMinerShip:isDocked(stationBethesda) then
			sickMinerState = "at Bethesda"
			stationBethesda:sendCommsMessage(sickMinerShip,"Audio message received, auto-transcribed into log, stored for playback: BTHSDA002")
			sickMinerShip:addToShipLog("[BTHSDA002] Joshua Kojak is being treated. He shows every sign of recovering","Yellow")
			if playMsgFromBethesdaButton == nil then
				playMsgFromBethesdaButton = "playMsgFromBethesdaButton"
				sickMinerShip:addCustomButton("Relay",playMsgFromBethesdaButton,"|> BTHSDA002",playBethesdaStationMessage)
				playMsgFromBethesdaButtonOps = "playMsgFromBethesdaButtonOps"
				sickMinerShip:addCustomButton("Operations",playMsgFromBethesdaButtonOps,"|> BTHSDA002",playBethesdaStationMessage)
			end
			sickMinerShip:addReputationPoints(30)
			minerRecoveryTimer = random(90,120)
			plot2reminder = nil
			plot2 = minerRecovering
		end
	end
end

function playKojakThanksMessage()
	playSoundFile("sa_54_KojakThanks.wav")
	closestBethesdaPlayer:removeCustom(playMsgKojakButton)
	closestBethesdaPlayer:removeCustom(playMsgKojakButtonOps)
end
function minerRecovering(delta)
	plot2name = "minerRecovering"
	minerRecoveryTimer = minerRecoveryTimer - delta
	if minerRecoveryTimer < 0 then
		if sickMinerState == "at Bethesda" then
			closestBethesdaPlayer = closestPlayerTo(stationBethesda)
			if closestBethesdaPlayer == nil then
				closestBethesdaPlayer = getPlayerShip(-1)
			end
			stationBethesda:sendCommsMessage(closestBethesdaPlayer, "Audio message received, auto-transcribed into log, stored for playback: BTHSDA034")
			closestBethesdaPlayer:addToShipLog("[BTHSDA034](Joshua Kojak) Thanks for bringing me to Bethesda. I'm feeling much better. I'm transmitting my research on power systems and exotic metals. You may find it interesting. Mining leaves me lots of time for thinking","Yellow")
			if playMsgKojakButton == nil then
				playMsgKojakButton = "playMsgKojakButton"
				closestBethesdaPlayer:addCustomButton("Relay",playMsgKojakButton,"|> BTHSDA034",playKojakThanksMessage)
				playMsgKojakButtonOps = "playMsgKojakButtonOps"
				closestBethesdaPlayer:addCustomButton("Operations",playMsgKojakButtonOps,"|> BTHSDA034",playKojakThanksMessage)
			end
			closestBethesdaPlayer:addReputationPoints(15.00)
			closestBethesdaPlayer.receivedMinerResearch = true
			sickMinerState = "transmitted research"
			minerScienceDiscoveryTimer = random(90,120)
			plot2 = minerScienceDiscovery
		end
	end
end
function minerScienceDiscovery(delta)
	plot2name = "minerScienceDiscovery"
	minerScienceDiscoveryTimer = minerScienceDiscoveryTimer - delta
	if minerScienceDiscoveryTimer < 0 then
		if sickMinerState == "transmitted research" then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				sickMinerState = "sent to engineer"
				scienceSendMessage = "scienceSendMessage"
				closestBethesdaPlayer:addCustomMessage("Science",scienceSendMessage,"While reading through Joshua Kojak's research, you discover a potential application to on-board ship systems. Click the 'Send to engineer' button to submit insight to engineering. You may find the button under the 'scanning' label")
				operationsSendMessage = "operationsSendMessage"
				closestBethesdaPlayer:addCustomMessage("Operations",operationsSendMessage,"While reading through Joshua Kojak's research, you discover a potential application to on-board ship systems. Click the 'Send to engineer' button to submit insight to engineering.")
				scienceSendButton = "scienceSendButton"
				closestBethesdaPlayer:addCustomButton("Science",scienceSendButton,"Send to engineer",insightToEngineer)
				operationsSendButton = "operationsSendButton"
				closestBethesdaPlayer:addCustomButton("Operations",operationsSendButton,"Send to engineer",insightToEngineer)
				engineerEvaluateMessageTimer = 30
				plot2 = minerEngineerEvaluate
			end
		end
	end
end
function minerEngineerEvaluate(delta)
	plot2name = "minerEngineerEvaluate"
	if sickMinerState == "sent to engineer" then
		engineerEvaluateMessageTimer = engineerEvaluateMessageTimer - delta
		if engineerEvaluateMessageTimer < 0 then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				closestBethesdaPlayer:removeCustom(scienceSendMessage)
				closestBethesdaPlayer:removeCustom(operationsSendMessage)
			end
		end
	end
	if sickMinerState == "sent to weapons" then
		if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
			engineerSendMessage = "engineerSendMessage"
			closestBethesdaPlayer:addCustomMessage("Engineering",engineerSendMessage,"The science officer sent you some thoughts on Joshua Kojak's research. You think it applies to beam weapon improvement. Click the 'Send to weapons' button to suggest changes to weapons")
			engineerPlusSendMessage = "engineerPlusSendMessage"
			closestBethesdaPlayer:addCustomMessage("Engineering+",engineerPlusSendMessage,"The science officer sent you some thoughts on Joshua Kojak's research. You think it applies to beam weapon improvement. Click the 'Send to weapons' button to suggest changes to weapons")
			engineerSendToWeaponsButton = "engineerSendToWeaponsButton"
			closestBethesdaPlayer:addCustomButton("Engineering",engineerSendToWeaponsButton,"Send to weapons",insightToWeapons)
			engineerPlusSendToWeaponsButton = "engineerPlusSendToWeaponsButton"
			closestBethesdaPlayer:addCustomButton("Engineering+",engineerPlusSendToWeaponsButton,"Send to weapons",insightToWeapons)
			weaponsEvaluateMessageTimer = 30
			plot2 = minerWeaponsApply
		end
	end
end
function insightToEngineer()
	sickMinerState = "sent to weapons"
	if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
		closestBethesdaPlayer:removeCustom(scienceSendButton)
		closestBethesdaPlayer:removeCustom(operationsSendButton)
	end
end
function minerWeaponsApply(delta)
	plot2name = "minerWeaponsApply"
	if sickMinerState == "sent to weapons" then
		weaponsEvaluateMessageTimer = weaponsEvaluateMessageTimer - delta
		if weaponsEvaluateMessageTimer < 0 then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				closestBethesdaPlayer:removeCustom(engineerSendMessage)
				closestBethesdaPlayer:removeCustom(engineerPlusSendMessage)
			end
		end
	end
	if sickMinerState == "sent to base" then
		if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
			weaponsSendMessage = "weaponsSendMessage"
			closestBethesdaPlayer:addCustomMessage("Weapons",weaponsSendMessage,"The engineer sent you some thoughts on Joshua Kojak's research. You know how to apply it to the beam weapons, but lack the tools to do it immediately. Click the 'Send to Utopia Planitia' button to transmit upgrade instructions to Utopia Planitia station")
			tacticalSendMessage = "tacticalSendMessage"
			closestBethesdaPlayer:addCustomMessage("Tactical",tacticalSendMessage,"The engineer sent you some thoughts on Joshua Kojak's research. You know how to apply it to the beam weapons, but lack the tools to do it immediately. Click the 'Send to Utopia Planitia' button to transmit upgrade instructions to Utopia Planitia station")
			weaponsSendButton = "weaponsSendButton"
			closestBethesdaPlayer:addCustomButton("Weapons",weaponsSendButton,"Send to Utopia Planitia",insightToBase)
			tacticalSendButton = "tacticalSendButton"
			closestBethesdaPlayer:addCustomButton("Tactical",tacticalSendButton,"Send to Utopia Planitia",insightToBase)
			weaponsDecideMessageTimer = 30
			plot2 = minerWeaponsDecide
		end
	end
end
function insightToWeapons()
	sickMinerState = "sent to base"
	if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
		closestBethesdaPlayer:removeCustom(engineerSendToWeaponsButton)
		closestBethesdaPlayer:removeCustom(engineerPlusSendToWeaponsButton)
	end
end
function minerWeaponsDecide(delta)
	plot2name = "minerWeaponsDecide"
	if sickMinerState == "sent to base" then
		weaponsDecideMessageTimer = weaponsDecideMessageTimer - delta
		if weaponsDecideMessageTimer < 0 then
			if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
				closestBethesdaPlayer:removeCustom(weaponsSendMessage)
				closestBethesdaPlayer:removeCustom(tacticalSendMessage)
			end
		end
	end
	if sickMinerState == "base processed" then
		if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
			stationUtopiaPlanitia:sendCommsMessage(closestBethesdaPlayer,"Thanks for the information. We can upgrade you next time you dock.")
			closestBethesdaPlayer:addToShipLog("[Utopia Planitia] Thanks for the information. We can upgrade you next time you dock","Magenta")
		end
		plot2 = nil
		minerUpgrade = true
		removeGMFunction(GMInitiatePlot2)
	end
end
function insightToBase()
	sickMinerState = "base processed"
	if closestBethesdaPlayer:isValid() and closestBethesdaPlayer.receivedMinerResearch then
		closestBethesdaPlayer:removeCustom(weaponsSendButton)
		closestBethesdaPlayer:removeCustom(tacticalSendButton)
	end
end
--[[-----------------------------------------------------------------
      Third plot line: comparable fleet and Nabbit upgrade
-----------------------------------------------------------------]]--
function playUtopiaPlanitiaSensorTechMessage()
	playSoundFile("sa_54_DuncanSensorTech.wav")
	closestIncursionPlayer:removeCustom(playUtopiaPlanitiaSensorMsgButton)
	closestIncursionPlayer:removeCustom(playUtopiaPlanitiaSensorMsgButtonOps)
end

function incursion(delta)
	if nabbitUpgrade then
		plot3 = nil
	end
	plot3name = "incursion"
	if incursionSpawned == "ready" then
		incursionSpawned = "done"
		incursionList = spawnEnemies(utopiaPlanitiax+irandom(-30000,-20000),utopiaPlanitiay+irandom(20000,30000),1,"Ghosts")
	end
	incursionTimer = incursionTimer - delta
	if incursionTimer < 0 then
		if incursionHelp == nil then
			incursionHelp = "complete"
			closestIncursionPlayer = closestPlayerTo(stationUtopiaPlanitia)
			if closestIncursionPlayer == nil then
				closestIncursionPlayer = getPlayerShip(-1)
			end
			stationUtopiaPlanitia:sendCommsMessage(closestIncursionPlayer, "Audio message received, auto-transcribed into log, stored for playback: UTPLNT103")
			closestIncursionPlayer:addToShipLog("[UTPLNT103](Utopia Planitia sensor technician) Our long range sensors show enemies approaching","Yellow")
			if playUtopiaPlanitiaSensorMsgButton == nil then
				playUtopiaPlanitiaSensorMsgButton = "playUtopiaPlanitiaSensorMsgButton"
				closestIncursionPlayer:addCustomButton("Relay",playUtopiaPlanitiaSensorMsgButton,"|> UTPLNT103",playUtopiaPlanitiaSensorTechMessage)
				playUtopiaPlanitiaSensorMsgButtonOps = "playUtopiaPlanitiaSensorMsgButtonOps"
				closestIncursionPlayer:addCustomButton("Operations",playUtopiaPlanitiaSensorMsgButtonOps,"|> UTPLNT103",playUtopiaPlanitiaSensorTechMessage)
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(incursionList) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		if incursionAward == nil then
			incursionAward = "done"
			closestIncursionPlayer:addReputationPoints(50.0)
			plot3 = nabbitRideRequest
		end
	end
end

function nabbitRideRequest()
	plot3name = "nabbitRideRequest"
	nabbitStationChoice = math.random(1,5)
	if nabbitStationChoice == 1 then
		nabbitStation = stationHossam
	elseif nabbitStationChoice == 2 then
		nabbitStation = stationMaverick
	elseif nabbitStationChoice == 3 then
		nabbitStation = stationResearch19
	elseif nabbitStationChoice == 4 then
		nabbitStation = stationMadison
	else
		nabbitStation = stationShree
	end
	if nabbitStation:isValid() then
		closestNabbitPlayer = closestPlayerTo(nabbitStation)
		if closestNabbitPlayer == nil then
			closestNabbitPlayer = getPlayerShip(-1)
		end
		closestNabbitPlayer:addToShipLog(string.format("[%s in sector %s] Engineer Dan McNabbit requests a ride to Armstrong",nabbitStation:getCallSign(),nabbitStation:getSectorName()),"Magenta")
		plot3reminder = string.format("Pick up Dan McNabbit from %s in sector %s and take him to Armstrong",nabbitStation:getCallSign(),nabbitStation:getSectorName())
		plot3 = getNabbit
	else
		plot3 = nil
		removeGMFunction(GMInitiatePlot3)
	end
end

function getNabbit(delta)
	plot3name = "getNabbit"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if nabbitStation:isValid() then
				if p:isDocked(nabbitStation) then
					nabbitShip = p
					nabbitShip.nabbitAboard = true
					nabbitShip:addToShipLog("Engineer Dan McNabbit aboard and ready to go to Armstrong","Magenta")
					nabbitShip:addReputationPoints(5)
					plot3 = dropNabbit
				end
			else
				plot3 = nil
				plot3reminder = nil
				removeGMFunction(GMInitiatePlot3)
			end
		end
	end
end

function playNabbitTune()
	playSoundFile("sa_54_NabbitTune.wav")
	nabbitShip:removeCustom(playNabbitTuneMsgButton)
	nabbitShip:removeCustom(playNabbitTuneMsgButtonOps)
end

function dropNabbit(delta)
	plot3name = "dropNabbit"
	if nabbitShip:isValid() and nabbitShip.nabbitAboard and stationArmstrong:isValid() then
		if nabbitShip:isDocked(stationArmstrong) then
			stationArmstrong:sendCommsMessage(nabbitShip,"Audio message received, auto-transcribed into log, stored for playback: ASTGDN038")
			nabbitShip:addToShipLog("[ASTGDN038](Dan McNabbit) Thanks for the ride. I've tuned your impulse engines en route. I transmitted my engine tuning parameters to Utopia Planitia. Expect faster impulse speeds","Yellow")
			nabbitShip:setImpulseMaxSpeed(nabbitShip:getImpulseMaxSpeed()*1.2)
			nabbitShip.nabbitUpgrade = true
			nabbitUpgrade = true
			nabbitShip:addReputationPoints(5)
			plot3 = nil
			plot3reminder = nil
			removeGMFunction(GMInitiatePlot3)
			if playNabbitTuneMsgButton == nil then
				playNabbitTuneMsgButton = "playNabbitTuneMsgButton"
				nabbitShip:addCustomButton("Relay",playNabbitTuneMsgButton,"|> ASTGDN038",playNabbitTune)
				playNabbitTuneMsgButtonOps = "playNabbitTuneMsgButtonOps"
				nabbitShip:addCustomButton("Operations",playNabbitTuneMsgButtonOps,"|> ASTGDN038",playNabbitTune)
			end
		end
	end
end
--[[-----------------------------------------------------------------
      Fourth plot line: better than comparable fleet, return stowaway
-----------------------------------------------------------------]]--
function attack1(delta)
	if lisbonUpgrade then
		plot4 = nil
	end
	plot4name = "attack1"
	if attack1spawned == "ready" then
		attack1spawned = "done"
		attack1list = spawnEnemies(armstrongx+irandom(-5000,5000),armstrongy+irandom(-45000,-40000),1.3,"Exuari")
		for _, enemy in ipairs(attack1list) do
			enemy:orderFlyTowards(armstrongx, armstrongy)
		end
	end
	attack1Timer = attack1Timer - delta
	if attack1Timer < 0 then
		if longRangeWarning == nil then
			longRangeWarning = "complete"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Stations Asimov, Utopia Planitia and Armstrong say that their long range sensors no longer read properly beyond 30U. This implies enemy activity is preventing accurate sensor readings. We suggest you check with these stations periodically to see if their normal sensors have picked up any enemy activity","Magenta")
				end
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(attack1list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot4 = stowawayMessage
	end
end

function playLisbonRequestMessage()
	playSoundFile("sa_54_BethesdaAdmin.wav")
	closestLisbonPlayer:removeCustom(playLisbonMsgButton)
	closestLisbonPlayer:removeCustom(playLisbonMsgButtonOps)
end

function stowawayMessage()
	plot4name = "stowawayMessage"
	closestLisbonPlayer = closestPlayerTo(stationBethesda)
	if closestLisbonPlayer == nil then
		closestLisbonPlayer = getPlayerShip(-1)
	end
	farthestTransport = transportList[1]
	for _, t in ipairs(transportList) do
		if t:isValid() then
			if distance(stationBethesda, t) > distance(stationBethesda, farthestTransport) then
				farthestTransport = t
			end
		end
	end
	stowawayTransport = farthestTransport
	stowawayName = stowawayTransport:getCallSign()
	stationBethesda:sendCommsMessage(closestLisbonPlayer,"Audio message received, auto-transcribed into log, stored for playback: BTHSDA271")
	closestLisbonPlayer:addToShipLog(string.format("[BTHSDA271] Commander Lisbon reports her child stowed away on a freighter. After extensive investigation, she believes Francis is aboard %s currently in sector %s\nShe requests a rendezvous with the freighter to bring back her child",stowawayName,stowawayTransport:getSectorName()),"Yellow")
	if playLisbonMsgButton == nil then
		playLisbonMsgButton = "playLisbonMsgButton"
		closestLisbonPlayer:addCustomButton("Relay",playLisbonMsgButton,"|> BTHSDA271",playLisbonRequestMessage)
		playLisbonMsgButtonOps = "playLisbonMsgButtonOps"
		closestLisbonPlayer:addCustomButton("Operations",playLisbonMsgButtonOps,"|> BTHSDA271",playLisbonRequestMessage)
	end
	plot4 = getStowaway
	plot4reminder = string.format("Retrieve Francis from freighter %s last reported in sector %s and return child to station Bethesda",stowawayName,stowawayTransport:getSectorName())
end

function getStowaway(delta)
	plot4name = "getStowaway"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if distance(stowawayTransport,p) < 500 then
				p.francisAboard = true
				francisShip = p
				francisShip:addToShipLog("The stowaway, Francis, is aboard. Commander Lisbon awaits at Bethesda","Magenta")
				plot4reminder = string.format("%s: Return Commander Lisbon's child to station Bethesda",francisShip:getCallSign())
				plot4 = returnStowaway
			end
		end
	end
	if not stowawayTransport:isValid() then
		plot4 = nil
		plot4reminder = nil
	end
end

function returnStowaway(delta)
	plot4name = "returnStowaway"
	if francisShip:isValid() then
		if francisShip:isDocked(stationBethesda) and francisShip.francisAboard then
			francisShip:addToShipLog("[Commander Lisbon] Thanks for bringing Francis back. I am entrusting you with my beam system cooling algorithm research. Take it to station Utopia Planitia so that they can decrypt it and it may be applied to human navy ships","Magenta") 
			plot4 = deliverAlgorithm
			plot4reminder = string.format("%s: Deliver Commander Lisbon's encrypted beam system cooling algorithm to station Utopia Planitia",francisShip:getCallSign())
			francisShip.lisbonAlgorithm = true
		end
	else
		plot4 = nil
		plot4reminder = nil
	end
end

function deliverAlgorithm(delta)
	plot4name = "deliverAlgorithm"
	if francisShip:isValid() then
		if francisShip:isDocked(stationUtopiaPlanitia) then
			if francisShip.lisbonAlgorithm then
				francisShip:addToShipLog("[Utopia Planitia] Received Commander Lisbon's beam cooling research. Upgrade available to human navy ships","Magenta")
				lisbonUpgrade = true
				plot4 = nil
				plot4reminder = nil
			end
		end
	end
end
--[[-----------------------------------------------------------------
      Fifth plot line: better than comparable fleet 
-----------------------------------------------------------------]]--
function attack2(delta)
	plot5name = "atack2"
	if attack2spawned == "ready" then
		attack2list = spawnEnemies(asimovx+irandom(-45000,-40000),asimovy+irandom(-5000,5000),1.6,"Kraylor")
		attack2spawned = "done"
		for _, enemy in ipairs(attack2list) do
			enemy:orderFlyTowards(asimovx, asimovy)
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(attack2list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot5 = nil
	end
end
--[[-----------------------------------------------------------------
      Eleventh plot line: Jump start
-----------------------------------------------------------------]]--
function jumpStart(delta)
	plot11name = "jumpStart"
	jumpStartTimer = jumpStartTimer - delta
	if jumpStartTimer < 0 then
		cp = closestPlayerTo(stationAsimov)
		x, y = cp:getPosition()
		objList = getObjectsInRadius(x, y, 30000)
		nebulaList = {}
		for _, obj in ipairs(objList) do
			if obj.typeName == "Nebula" then
				table.insert(nebulaList,obj)
			end
		end
		plot11name = "jumpStart - nebula list built"
		if #nebulaList > 0 then
			dist2cp = 999999
			for nidx=1,#nebulaList do
				n2cp = distance(cp,nebulaList[nidx])
				if n2cp < dist2cp then
					nebAmbush = nebulaList[nidx]
					dist2cp = n2cp
				end
			end
			ax, ay = nebAmbush:getPosition()
			if distance(cp, nebAmbush) < 5000 then
				ax, ay = vectorFromAngle(random(0,360),15000)
				ax = x + ax
				ay = y + ay				
			end
		else
			ax, ay = vectorFromAngle(random(0,360),15000)
			ax = x + ax
			ay = y + ay
		end
		jAsimov = spawnEnemies(ax, ay, .5)
		for _, enemy in ipairs(jAsimov) do
			enemy:orderFlyTowards(asimovx,asimovy)
		end
		jPlayer = spawnEnemies(ax, ay, .5)
		for _, enemy in ipairs(jPlayer) do
			enemy:orderAttack(cp)
		end
		plot11 = nil
		plot11name = nil
	end
end
--[[-----------------------------------------------------------------
      Tenth plot line: ambush from nebula 2
-----------------------------------------------------------------]]--
function attack5(delta)
	plot10name = "atack5"
	if attack5Timer == nil then
		attack5Timer = random(20,50)
	end
	if attack5spawned == "ready" then
		attack5list = spawnEnemies(neb2x,neb2y,1.8,"Kraylor")
		attack5spawned = "done"
		for _, enemy in ipairs(attack5list) do
			enemy:orderStandGround()
		end
		plot10 = ambush5
	end
end

function ambush5(delta)
	plot10name = "ambush4"
	attack5Timer = attack5Timer - delta
	if attack5Timer < 0 then
		p = closestPlayerTo(neb2)
		if p ~= nil then
			pDist = distance(p,neb2)
			if math.random() > pDist/30000 then
				for _, enemy in ipairs(attack5list) do
					enemy:orderAttack(p)
				end
				plot10 = pursue5
			else
				attack5Timer = delta + 10
			end
		end		
		enemy_count = 0
		for _, enemy in ipairs(attack5list) do
			if enemy:isValid() then
				enemy_count = enemy_count + 1
			end
		end
		if enemy_count == 0 then
			plot10 = nil
		end
	end	
end

function pursue5()
	plot10name = "pursue4"
	enemy_count = 0
	for _, enemy in ipairs(attack5list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot10 = nil
	end
end
--[[-----------------------------------------------------------------
      Ninth plot line: ambush from nebula 1 
-----------------------------------------------------------------]]--
function attack4(delta)
	plot9name = "atack4"
	if attack4Timer == nil then
		attack4Timer = random(20,50)
	end
	if attack4spawned == "ready" then
		attack4list = spawnEnemies(neb1x,neb1y,1.6,"Kraylor")
		attack4spawned = "done"
		for _, enemy in ipairs(attack4list) do
			enemy:orderStandGround()
		end
		--eval1dist = distance(neb1,stationAsimov)
		plot9 = ambush4
	end
end

function ambush4(delta)
	plot9name = "ambush4"
	attack4Timer = attack4Timer - delta
	if attack4Timer < 0 then
		p = closestPlayerTo(neb1)
		if p ~= nil then
			pDist = distance(p,neb1)
			if math.random() > pDist/30000 then
				for _, enemy in ipairs(attack4list) do
					enemy:orderAttack(p)
				end
				plot9 = pursue4
			else
				attack4Timer = delta + 10
			end
		end		
		enemy_count = 0
		for _, enemy in ipairs(attack4list) do
			if enemy:isValid() then
				enemy_count = enemy_count + 1
			end
		end
		if enemy_count == 0 then
			plot9 = nil
		end
	end
end

function pursue4()
	plot9name = "pursue4"
	enemy_count = 0
	for _, enemy in ipairs(attack4list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot9 = nil
	end
end
--[[-----------------------------------------------------------------
      Eighth plot line: geometric fleet pincers, strap on tube
-----------------------------------------------------------------]]--
function attack3(delta)
	plot8name = "atack3"
	if attack3spawned == "ready" then
		asimovx, asimovy = stationAsimov:getPosition()
		asimovDistance = random(20000,30000)
		avx, avy = vectorFromAngle(random(0,360),asimovDistance)
		attack3list = spawnEnemies(asimovx+avx,asimovy+avy,1,"Kraylor")
		attack3spawned = "done"
		for _, enemy in ipairs(attack3list) do
			enemy:orderFlyTowards(asimovx, asimovy)
		end
		if asimov8thWarning == nil then
			asimov8thWarning = "done"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("[Asimov] Our sensors show enemies approximately %.2f units away",asimovDistance/1000),"Magenta")
				end
			end
		end
		if difficulty >= 1 then
			armstrongDistance = random(35000,45000)
			arx, ary = vectorFromAngle(random(0,360),armstrongDistance)
			temp3list = spawnEnemies(armstrongx+arx,armstrongy+ary,.667,"Ghosts")
			for _, enemy in ipairs(temp3list) do
				enemy:orderFlyTowards(armstrongx,armstrongy)
				table.insert(attack3list,enemy)
			end
			if armstrong8thWarning == nil then
				armstrong8thWarning = "done"
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("[Armstrong] Our long range sensors show enemies approximately %.2f units away",armstrongDistance/1000),"Magenta")
					end
				end
			end
		end
		if difficulty >= 2 then
			utopiaDistance = random(50000,60000)
			upx, upy = vectorFromAngle(random(0,360),utopiaDistance)
			temp4list = spawnEnemies(utopiaPlanitiax+upx,utopiaPlanitiay+upy,.5,"Ktlitans")
			for _, enemy in ipairs(temp4list) do
				table.insert(attack3list,enemy)
			end
			if utopia8thWarning == nil then
				utopia8thWarning = "done"
				for pidx=1,8 do
					p = getPlayerShip(pidx)
					if p ~= nil and p:isValid() then
						p:addToShipLog(string.format("[Utopia Planitia] Our long range sensors show enemies approximately %.2f units away",utopiaDistance/1000),"Magenta")
					end
				end
			end
		end
	end
	enemy_count = 0
	for _, enemy in ipairs(attack3list) do
		if enemy:isValid() then
			enemy_count = enemy_count + 1
		end
	end
	if enemy_count == 0 then
		plot8 = chooseTubeAddStation
	end
end

function chooseTubeAddStation()
	if tubeAddStationChoose == nil then
		tubeAddStationChoose = "done"
		randomTubeAddStation = math.random(1,5)
		if randomTubeAddStation == 1 then
			tubeAddStation = stationOBrien
		elseif randomTubeAddStation == 2 then
			tubeAddStation = stationCyrus
		elseif randomTubeAddStation == 3 then
			tubeAddStation = stationPanduit
		elseif randomTubeAddStation == 4 then
			tubeAddStation = stationOkun
		else
			tubeAddStation = stationSpot
		end
	end
	plot8 = inheritanceMessage
end

function inheritanceMessage()
	if messageOnInheritance == nil then
		messageOnInheritance = "done"
		if tubeAddStation:isValid() then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("Sheila Long, A former naval officer recenly perished. Among her personal effects she left a data store for the academy on station Asimov. Her personal effects are located on station %s in sector %s. Please dock and pick up the data store and transport it to station Asimov",tubeAddStation:getCallSign(),tubeAddStation:getSectorName()),"Magenta")
					plot8reminder = string.format("Get Sheila Long's package from %s in sector %s and take to station Asimov",tubeAddStation:getCallSign(),tubeAddStation:getSectorName())
				end
			end
			plot8 = dockWithTubeAddStation
		else
			plot8 = nil
			plot8reminder = nil
		end
	end
end

function dockWithTubeAddStation(delta)
	if tubeAddStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p:isDocked(tubeAddStation) then
				p:addToShipLog("Sheila Long's package for station Asimov is aboard","Magenta")
				p.sheilaLongPackage = true
				plot8 = dockWithAsimovForTubeAdd
				return
			end
		end
	else
		plot8 = nil
		plot8reminder = nil
	end
end

function dockWithAsimovForTubeAdd(delta)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p~= nil and p:isValid() and p:isDocked(stationAsimov) then
			p:addToShipLog("Sheila Long's package received. The archive curator discovered some research on weapons systems miniaturization in the data store. Utopia Planitia received the information and stated that they believe they can add an extra homing missile weapons tube to any ship in the fleet if the ship will dock with Utopia Planitia","Magenta")
			addTubeUpgrade = true
			plot8 = nil
			plot8reminder = nil
		end
	end
end

function flakyTube(delta)
	if resetFlakyTubeTimer then
		flakyTubeTimer = delta + random(150,450)
		resetFlakyTubeTimer = false
	end
	flakyTubeTimer = flakyTubeTimer - delta
	if flakyTubeTimer < 0 then
		if flakyTubeVictim == nil then
			lowestVictim = 999
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.addTubeUpgrade then
					if p.flakyTubeCount < lowestVictim then
						nextVictim = p
						lowestVictim = p.flakyTubeCount
					end
				end
			end
			flakyTubeVictim = nextVictim
			flakyTubeVictim.tubeFixed = false
			originalTubes = flakyTubeVictim:getWeaponTubeCount()
			newTubes = originalTubes - 1
			flakyTubeVictim:setWeaponTubeCount(newTubes)
			flakyTubeVictim.flakyTubeCount = flakyTubeVictim.flakyTubeCount + 1
			failedTubeMessage = "failedTubeMessage"
			flakyTubeVictim:addCustomMessage("Weapons",failedTubeMessage,"Automated systems removed our new weapons tube due to malfunction. Technicians investigating")
			failedTubeMessageTactical = "failedTubeMessageTactical"
			flakyTubeVictim:addCustomMessage("Tactical",failedTubeMessageTactical,"Automated systems removed our new weapons tube due to malfunction. Technicians investigating")
		else
			if fixedTubeButton == nil then
				fixedTubeMessage = "fixedTubeMessage"
				flakyTubeVictim:addCustomMessage("Weapons",fixedTubeMessage,"Technicians fixed the new tube. Click 'Redeploy' button to enable")
				fixedTubeMessageTactical = "fixedTubeMessageTactical"
				flakyTubeVictim:addCustomMessage("Tactical",fixedTubeMessageTactical,"Technicians fixed the new tube. Click 'Redeploy' button to enable")
				fixedTubeButton = "fixedTubeButton"
				flakyTubeVictim:addCustomButton("Weapons",fixedTubeButton,"Redeploy",redeployTube)
				fixedTubeButtonTactical = "fixedTubeButtonTactical"
				flakyTubeVictim:addCustomButton("Tactical",fixedTubeButtonTactical,"Redeploy",redeployTube)
			end
		end
		flakyTubeTimer = delta + random(150,450)
	end
end

function redeployTube()
	flakyTubeVictim.tubeFixed = true
	originalTubes = flakyTubeVictim:getWeaponTubeCount()
	newTubes = originalTubes + 1
	flakyTubeVictim:setWeaponTubeCount(newTubes)
	flakyTubeVictim:setWeaponTubeExclusiveFor(originalTubes, "Homing")
	flakyTubeVictim:removeCustom(fixedTubeButton)
	flakyTubeVictim:removeCustom(fixedTubeButtonTactical)
	resetFlakyTubeTimer = true
	fixedTubeButton = nil
	flakyTubeVictim = nil
end
--[[-----------------------------------------------------------------
      Seventh plot line - ambush for time constrained short game
-----------------------------------------------------------------]]--
function beforeAmbush(delta)
	plot7name = "before ambush"
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < ambushTime then
		plot7 = duringAmbush
	end
end

function duringAmbush(delta)
	plot7name = "during ambush"
	closestToAsimov = closestPlayerTo(stationAsimov)
	if closestToAsimov == nil then
		closestToAsimov = getPlayerShip(-1)
	end
	px, py = closestToAsimov:getPosition()
	ambushList = spawnEnemies(px-irandom(1000,7000),py-irandom(1000,7000),1.5,"Exuari")
	for _, enemy in ipairs(ambushList) do
		enemy:orderAttack(closestToAsimov)
	end
	plot7 = afterAmbush
end

function afterAmbush(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		playSoundFile("sa_54_AuthMBVictory.wav")
		victory("Human Navy")	
	end
end
--[[-----------------------------------------------------------------
      Anchor artifacts (plotArt): find, scan, retrieve anchor artifacts
-----------------------------------------------------------------]]--
function unscannedAnchors(delta)
	plotArtName = "unscannedAnchors"
	if artAnchor1:isScannedByFaction("Human Navy") and artAnchor2:isScannedByFaction("Human Navy") then
		artAnchor1:allowPickup(true)
		artAnchor2:allowPickup(true)		
		plotArt = scannedAnchors
	end
	trackArtAnchors()
end

function playArtSound()
	playSoundFile("sa_54_UPScienceGet.wav")
	artSoundShip:removeCustom(artSoundButton)
	artSoundShip:removeCustom(artSoundButtonOps)
end

function scannedAnchors(delta)
	plotArtName = "scannedAnchors"
	trackArtAnchors()
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.artAnchor1 or p.artAnchor2 then
				p:addToShipLog("[UTPLNT116](Utopia Planitia) Scanned artifacts show promise for ship systems improvement. Recommend retrieval","Yellow")
				plotArt = suggestRetrieveAnchors
				if artSoundButton == nil then
					artSoundButton = "artSoundButton"
					artSoundShip = p
					stationUtopiaPlanitia:sendCommsMessage(artSoundShip,"Audio message received, stored for playback: UTPLNT116")
					artSoundShip:addCustomButton("Relay",artSoundButton,"|> UTPLNT116",playArtSound)
					artSoundButtonOps = "artSoundButtonOps"
					artSoundShip:addCustomButton("Operations",artSoundButtonOps,"|> UTPLNT116",playArtSound)
				end
			end
		end
	end
end

function suggestRetrieveAnchors(delta)
	plotArtName = "suggestRetrieveAnchors"
	trackArtAnchors()
	if not artAnchor1:isValid() and not artAnchor2:isValid() then
		anchorsAboardTimer = 30
		plotArt = anchorsAboard
	end
end

function anchorsAboard(delta)
	plotArtName = "anchorsAboard"
	anchorsAboardTimer = anchorsAboardTimer - delta
	if anchorsAboardTimer < 0 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p.artAnchor1 or p.artAnchor2 then
					p:addToShipLog("[Utopia Planitia] Bring artifacts to Utopia Planitia and we can improve ship maneuverability","Magenta")
					plotArt = bringToStation
				end
			end
		end
	end
end

function bringToStation(delta)
	plotArtName = "bringToStation"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:isDocked(stationUtopiaPlanitia) and p.artAnchor1 then
				stationUtopiaPlanitia.artAnchor1 = true
			end
			if p:isDocked(stationUtopiaPlanitia) and p.artAnchor2 then
				stationUtopiaPlanitia.artAnchor2 = true
			end
		end
	end
	if stationUtopiaPlanitia.artAnchor1 and stationUtopiaPlanitia.artAnchor2 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p~= nil and p:isValid() then
				p:addToShipLog("[Utopia Planitia] We received the artifacts. We can improve ship maneuverability next time you dock","Magenta")
			end
		end
		artAnchorUpgrade = true
		plotArt = nil
	end
end

function trackArtAnchors()
	if artAnchor1:isValid() then
		closestArt1player = closestPlayerTo(artAnchor1)
		if closestArt1player == nil then
			closestArt1player = getPlayerShip(-1)
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == closestArt1player then
					p.artAnchor1 = true
				else
					p.artAnchor1 = false
				end
			end
		end
	end
	if artAnchor2:isValid() then
		closestArt2player = closestPlayerTo(artAnchor2)
		if closestArt2player == nil then
			closestArt2player = getPlayerShip(-1)
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p == closestArt2player then
					p.artAnchor2 = true
				else
					p.artAnchor2 = false
				end
			end
		end
	end
end

--[[-----------------------------------------------------------------
      Game master (GM) functions
-----------------------------------------------------------------]]--
function initiatePlot2()
	nuisanceSpawned = "ready"
	nuisanceTimer = random(30,90)
	plot2 = nuisance
	removeGMFunction(GMInitiatePlot2)
end
function initiatePlot3()
	incursionSpawned = "ready"
	incursionTimer = random(30,90)
	plot3 = incursion
	removeGMFunction(GMInitiatePlot3)
end
function initiatePlot4()
	attack1spawned = "ready"
	attack1Timer = random(40,120)
	plot4 = attack1
	removeGMFunction(GMInitiatePlot4)
end
function initiatePlot5()
	attack2spawned = "ready"
	plot5 = attack2
	removeGMFunction(GMInitiatePlot5)
end
function initiatePlot8()
	attack3spawned = "ready"
	plot8 = attack3
	removeGMFunction(GMInitiatePlot8)
end
function initiatePlot9()
	attack4spawned = "ready"
	plot9 = attack4
	removeGMFunction(GMInitiatePlot9)
end
function initiatePlot10()
	attack5spawned = "ready"
	plot10 = attack5
	removeGMFunction(GMInitiatePlot10)
end
function skipToDefendUP()
	artAnchorUpgrade = true
	longWave = 0
	minerUpgrade = true
	nabbitUpgrade = true
	lisbonUpgrade = true
	waveDelayTimer = 120
	plot1 = defendUtopia	
	removeGMFunction(GMSkipToDefend)
end
function skipToDestroySC()
	artAnchorUpgrade = true
	longWave = 0
	minerUpgrade = true
	nabbitUpgrade = true
	lisbonUpgrade = true
	waveDelayTimer = 120
	plot1 = destroyEnemyStronghold	
	removeGMFunction(GMSkipToDestroy)
end
--[[-----------------------------------------------------------------
      Generic or utility functions
-----------------------------------------------------------------]]--
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * difficulty * playerPower(),5)
	enemyPosition = 0
	sp = irandom(300,500)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		shipTemplateType = irandom(1,17)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = irandom(1,17)
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
	return playerShipScore
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

function update(delta)
	concurrentPlayerCount = 0
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
		end
	end
	if concurrentPlayerCount > highestConcurrentPlayerCount then
		highestConcurrentPlayerCount = concurrentPlayerCount
	end
	if setConcurrentPlayerCount ~= highestConcurrentPlayerCount then
		setPlayers()
	end
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if plotArt ~= nil then		--artifact plot: find, scan, retrieve anchor artifacts
		plotArt(delta)
	end
	if plot1 ~= nil then		--primary plot: patrol bases, defend Utopia then destroy Scarlet Citadel based on selected length variation
		plot1(delta)
	end
	if plot7 ~= nil then		--timed game: ambush
		plot7(delta)
	end
	if plotH ~= nil then		--health
		plotH(delta)
	end
	if plot8 ~= nil then		--patrol sub plot (not short): leg 3: attack3 enemies, Sheila death, extra flaky tube
		plot8(delta)
	end
	if plotT ~= nil then		--Transports
		plotT(delta)
	end
	if not patrolComplete then
		if plot2 ~= nil then		--patrol sub plot: leg 2: nuisance enemies, sick miner kojak, beam upgrade
			plot2(delta)
		end
		if plot9 ~= nil then		--patrol sub plot (not short): leg 4: attack4 enemies, nebula 1 ambush
			plot9(delta)
		end
		if plot10 ~= nil then		--patrol sub plot (not short): leg 5: attack5 enemies, nebula 2 ambush
			plot10(delta)
		end
		if plot3 ~= nil then		--patrol sub plot: leg 6: incursion enemies, McNabbit ride, upgrade impulse
			plot3(delta)
		end
		if plot4 ~= nil then		--patrol sub plot: leg 7: attack1 enemies, Lisbon stowaway, beam cooling upgrade
			plot4(delta)
		end
		if plot5 ~= nil then		--patrol sub plot: leg 8: attack2 enemies
			plot5(delta)
		end
		if plot11 ~= nil then		--jump start (not easy)
			plot11(delta)
		end
	end
end