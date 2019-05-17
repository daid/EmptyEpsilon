-- Name: Shoreline
-- Description: Waves of increasingly difficult enemies. At least one required mission and several optional missions randomly selected
---
--- Maximum of 8 player ships supported by scenario. More player ships may experience strange results
---
--- Version 2
-- Type: Re-playable Mission
-- Variation[Timed]: Normal difficulty with a 45 minute time limit
-- Variation[Very Easy]: Few or weak enemies
-- Variation[Very Easy Timed]: Few or weak enemies with a 45 minute time limit
-- Variation[Easy]: Fewer or less powerful enemies
-- Variation[Easy Timed]: Fewer or less powerful enemies with a 45 minute time limit
-- Variation[Hard]: More or more powerful enemies
-- Variation[Hard Timed]: More or more powerful enemies with a 45 minute time limit
-- Variation[Very Hard]: Many powerful enemies
-- Variation[Very Hard Timed]: Many powerful enemies with a 45 minute time limit

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
--[[-----------------------------------------------------------------
      Dynamic map functions 
-----------------------------------------------------------------]]--
function moveBlackHole(delta)
	mbhx, mbhy = grawp:getPosition()
	if mbhx < 67000 or mbhx > 90000 or mbhy < -21000 or mbhy > 40000 then
		if mbhx < 67000 then
			grawp.angle = random(0,180) + 270
		end
		if mbhx > 90000 then
			grawp.angle = random(90,270)
		end
		if mbhy < -21000 then
			grawp.angle = random(0,180)
		end
		if mbhy > 40000 then
			grawp.angle = random(180,360)
		end
		deltaBlackx, deltaBlacky = vectorFromAngle(grawp.angle, grawp.travel+20)
		grawp:setPosition(mbhx+deltaBlackx,mbhy+deltaBlacky)
		grawp.travel = random(1,5 + difficulty)
	else
		deltaBlackx, deltaBlacky = vectorFromAngle(grawp.angle, grawp.travel)
		grawp:setPosition(mbhx+deltaBlackx,mbhy+deltaBlacky)
	end
end

function moveAsteroids(delta)
	movingAsteroidCount = 0
	for aidx, aObj in ipairs(movingAsteroidList) do
		if aObj:isValid() then
			movingAsteroidCount = movingAsteroidCount + 1
			mAstx, mAsty = aObj:getPosition()
			if mAstx < -150000 or mAstx > 150000 or mAsty < -150000 or mAsty > 150000 then
				aObj.angle = random(0,360)
				if random(1,100) < 50 then
					curve = 0
				else
					curve = math.random()*.08
				end
				if aObj.angle < 90 then
					aObj:setPosition(random(-150000,-100000),random(-150000,-100000))
					if aObj.angle < 45 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				elseif aObj.angle < 180 then
					aObj:setPosition(random(100000,150000),random(-150000,-100000))
					if aObj.angle < 135 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				elseif aObj.angle < 270 then
					aObj:setPosition(random(100000,150000),random(100000,150000))
					if aObj.angle < 225 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				else
					aObj:setPosition(random(-150000,-100000),random(100000,150000))
					if aObj.angle < 315 then
						aObj.curve = curve
					else
						aObj.curve = -curve
					end
				end
			else
				deltaAstx, deltaAsty = vectorFromAngle(aObj.angle,aObj.travel)
				aObj:setPosition(mAstx+deltaAstx,mAsty+deltaAsty)
				aObj.angle = aObj.angle + aObj.curve
			end
		end
	end
	if movingAsteroidCount < 1 then
		setMovingAsteroids()
	end
end
--[[-----------------------------------------------------------------
      Initialization 
-----------------------------------------------------------------]]--
function init()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250}
	--Player Ship Beams
	psb = {}
	psb["MP52 Hornet"] = 2
	psb["Phobos M3P"] = 2
	psb["Flavia P.Falcon"] = 2
	psb["Atlantis"] = 2
	psb["Player Cruiser"] = 2
	psb["Player Fighter"] = 2
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	transportList = {}
	transportSpawnDelay = 30
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
					{"battery",0}	}
	diagnostic = false
	playerShipNamesForMP52Hornet = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny"}
	playerShipNamesForPiranha = {"Razor's Edge","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesForFlaviaPFalcon = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesForPhobosM3P = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesForAtlantis = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesForCruiser = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesForMissileCruiser = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesForFighter = {"Buzzer","Flitter","Zippiticus","Hopper","Molt"}
	playerShipNamesForLeftovers = {"Forgone","Righteous","Masher"}
	goods = {}
	setVariations()
	setPlayers()
	setMovingAsteroids()
	setStations()
	plotT = transportPlot
	plotB = moveBlackHole
	persistentEnemies = {}
	waveDelayCount = 0
	waveInProgress = false
	waveProgressInterval = .25
	waveProgress = 0
	plotW = monitorWaves
	helpWarnDelay = 30
	plotH = helpWarn
	primaryOrders = "Defend bases in the area (human navy and independent) from enemy attack."
	secondaryOrders = ""
	optionalOrders = ""
	undercutLocation = "station"
	requiredMissionCount = 0
	optionalMissionDelay = 60
end

function setVariations()
	if getScenarioVariation() == "Timed" or getScenarioVariation() == "Hard Timed" or getScenarioVariation() == "Easy Timed" or getScenarioVariation() == "Very Easy Timed" or getScenarioVariation() == "Very Hard Timed" then
		gameTimeLimit = 45*60
		playWithTimeLimit = true
		waveDelayCountCheck = 15
	else
		gameTimeLimit = 0
		clueMessageDelay = 30*60
		playWithTimeLimit = false
		requiredMissionDelay = 20
		waveDelayCountCheck = 30
	end
	if getScenarioVariation() == "Easy" or getScenarioVariation() == "Easy Timed" then
		difficulty = .5
		waveDelayCountCheck = waveDelayCountCheck + 6
		waveProgressInterval = .2
	elseif getScenarioVariation() == "Hard" or getScenarioVariation() == "Hard Timed" then
		difficulty = 2
		waveDelayCountCheck = waveDelayCountCheck - 6
		waveProgressInterval = .5
	elseif getScenarioVariation() == "Very Easy" or getScenarioVariation() == "Very Easy Timed" then
		difficulty = .25
		waveDelayCountCheck = waveDelayCountCheck + 9
		waveProgressInterval = .15
	elseif getScenarioVariation() == "Very Hard" or getScenarioVariation() == "Very Hard Timed" then
		difficulty = 3
		waveDelayCountCheck = waveDelayCountCheck - 9		
		waveProgressInterval = .75
	else
		difficulty = 1
	end
end

function setPlayers()
	for p1idx=1,8 do
		pobj = getPlayerShip(p1idx)
		if pobj ~= nil and pobj:isValid() then
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(25-(difficulty*6))
				pobj.initialRep = true
			end
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
					pobj.shipScore = 15
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
				end
			end
		end
	end
end

function setMovingAsteroids()
	movingAsteroidList = {}
	for aidx=1,30 do
		xAst = random(-100000,100000)
		yAst = random(-100000,100000)
		outRange = true
		for p2idx=1,8 do
			p2obj = getPlayerShip(p2idx)
			if p2obj ~= nil and p2obj:isValid() then
				if distance(p2obj,xAst,yAst) < 30000 then
					outRange = false
				end
			end
		end
		if outRange then
			mAst = Asteroid():setPosition(xAst,yAst)
			mAst.angle = random(0,360)
			mAst.travel = random(40,220)
			if random(1,100) < 50 then
				mAst.curve = 0
			else
				mAst.curve = math.random()*.16 - .08
			end
			table.insert(movingAsteroidList,mAst)
		end
	end
	plotA = moveAsteroids
end

function setStations()
	afd = 30	-- asteroid field density
	stationList = {}
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
	stationVaiken = SpaceStation():setTemplate("Huge Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationVaiken:setPosition(random(-10000,5000),random(5000,9000)):setCallSign("Vaiken"):setDescription("Ship building and maintenance facility")
	table.insert(stationList,stationVaiken)
	friendlyStations = friendlyStations + 1
	goods[stationVaiken] = {{"food",10,1},{"medicine",5,5}}
	stationZefram = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationZefram:setPosition(random(5000,8000),random(-8000,9000)):setCallSign("Zefram"):setDescription("Warp Engine Components")
	table.insert(stationList,stationZefram)
	friendlyStations = friendlyStations + 1
	goods[stationZefram] = {{"warp",5,140},{"food",5,1}}
	marconiAngle = random(0,360)
	xMarconi, yMarconi = vectorFromAngle(marconiAngle,random(12500,15000))
	stationMarconi = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationMarconi:setPosition(xMarconi,yMarconi):setCallSign("Marconi"):setDescription("Energy Beam Components")
	table.insert(stationList,stationMarconi)
	neutralStations = neutralStations + 1
	goods[stationMarconi] = {{"beam",5,80}}
	muddAngle = marconiAngle + random(60,180)
	xMudd, yMudd = vectorFromAngle(muddAngle,random(12500,15000))
	stationMudd = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationMudd:setPosition(xMudd,yMudd):setCallSign("Muddville"):setDescription("Trading station")
	table.insert(stationList,stationMudd)
	neutralStations = neutralStations + 1
	goods[stationMudd] = {{"luxury",10,60}}
	alcaleicaAngle = muddAngle + random(60,120)
	xAlcaleica, yAlcaleica = vectorFromAngle(alcaleicaAngle,random(12500,15000))
	stationAlcaleica = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationAlcaleica:setPosition(xAlcaleica,yAlcaleica):setCallSign("Alcaleica"):setDescription("Optical Components")
	table.insert(stationList,stationAlcaleica)
	neutralStations = neutralStations + 1
	goods[stationAlcaleica] = {{"optic",5,66}}
	stationCalifornia = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationCalifornia:setPosition(random(-90000,-70000),random(-15000,25000)):setCallSign("California"):setDescription("Mining station")
	table.insert(stationList,stationCalifornia)
	friendlyStations = friendlyStations + 1
	goods[stationCalifornia] = {{"food",2,1},{"gold",5,25},{"dilithium",2,25}}
	stationOutpost15 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost15:setPosition(random(35000,50000),random(52000,79000)):setCallSign("Outpost-15"):setDescription("Mining and trade")
	table.insert(stationList,stationOutpost15)
	neutralStations = neutralStations + 1
	placeRandomAroundPoint(Asteroid,25,1,15000,60000,75000)
	stationOutpost21 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost21:setPosition(random(50000,75000),random(52000,61250)):setCallSign("Outpost-21"):setDescription("Mining and gambling")
	table.insert(stationList,stationOutpost21)
	neutralStations = neutralStations + 1
	if random(1,100) < 50 then
		goods[stationOutpost15] = {{"luxury",5,70},{"gold",5,25}}
		goods[stationOutpost21] = {{"cobalt",4,50}}
	else
		goods[stationOutpost21] = {{"luxury",5,70},{"gold",5,25}}
		goods[stationOutpost15] = {{"cobalt",4,50}}
	end
	stationValero = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationValero:setPosition(random(-88000,-65000),random(36250,40000)):setCallSign("Valero"):setDescription("Resupply")
	table.insert(stationList,stationValero)
	neutralStations = neutralStations + 1
	goods[stationValero] = {{"luxury",5,77}}
	vactelAngle = random(0,360)
	xVactel, yVactel = vectorFromAngle(vactelAngle,random(50000,61250))
	stationVactel = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationVactel:setPosition(xVactel,yVactel):setCallSign("Vactel"):setDescription("Shielded Circuitry Fabrication")
	table.insert(stationList,stationVactel)
	neutralStations = neutralStations + 1
	goods[stationVactel] = {{"circuit",5,50}}
	archerAngle = vactelAngle + random(60,120)
	xArcher, yArcher = vectorFromAngle(archerAngle,random(50000,61250))
	stationArcher = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationArcher:setPosition(xArcher,yArcher):setCallSign("Archer"):setDescription("Shield and Armor Research")
	table.insert(stationList,stationArcher)
	neutralStations = neutralStations + 1
	goods[stationArcher] = {{"shield",5,90}}
	deerAngle = archerAngle + random(60,120)
	xDeer, yDeer = vectorFromAngle(deerAngle,random(50000,61250))
	stationDeer = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationDeer:setPosition(xDeer,yDeer):setCallSign("Deer"):setDescription("Repulsor and Tractor Beam Components")
	table.insert(stationList,stationDeer)
	neutralStations = neutralStations + 1
	goods[stationDeer] = {{"tractor",5,90},{"repulsor",5,95}}
	cavorAngle = deerAngle + random(60,90)
	xCavor, yCavor = vectorFromAngle(cavorAngle,random(50000,61250))
	stationCavor = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationCavor:setPosition(xCavor,yCavor):setCallSign("Cavor"):setDescription("Advanced Material components")
	table.insert(stationList,stationCavor)
	neutralStations = neutralStations + 1
	goods[stationCavor] = {{"filament",5,42}}
	stationEmory = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationEmory:setPosition(random(72000,85000),random(-50000,-26000)):setCallSign("Emory"):setDescription("Transporter Components")
	table.insert(stationList,stationEmory)
	friendlyStations = friendlyStations + 1
	goods[stationEmory] = {{"transporter",5,63},{"food",2,1}}
	stationVeloquan = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationVeloquan:setPosition(random(-25000,15000),random(27000,40000)):setCallSign("Veloquan"):setDescription("Sensor components")
	table.insert(stationList,stationVeloquan)
	neutralStations = neutralStations + 1
	goods[stationVeloquan] = {{"sensor",5,68}}
	stationBarclay = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationBarclay:setPosition(random(-20000,0),random(-45000,-25000)):setCallSign("Barclay"):setDescription("Communications components")
	table.insert(stationList,stationBarclay)
	neutralStations = neutralStations + 1
	goods[stationBarclay] = {{"communication",5,58}}
	stationLipkin = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationLipkin:setPosition(random(20000,45000),random(-25000,-15000)):setCallSign("Lipkin"):setDescription("Autodoc components")
	table.insert(stationList,stationLipkin)
	neutralStations = neutralStations + 1
	goods[stationLipkin] = {{"autodoc",5,76}}
	stationRipley = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationRipley:setPosition(random(-75000,-30000),random(55000,62150)):setCallSign("Ripley"):setDescription("Load Lifters and components")
	table.insert(stationList,stationRipley)
	neutralStations = neutralStations + 1
	goods[stationRipley] = {{"lifter",5,61}}
	stationDeckard = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationDeckard:setPosition(random(-45000,-25000),random(-25000,-14000)):setCallSign("Deckard"):setDescription("Android components")
	table.insert(stationList,stationDeckard)
	neutralStations = neutralStations + 1
	goods[stationDeckard] = {{"android",5,73}}
	stationConnor = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationConnor:setPosition(random(-10000,15000),random(15000,27000)):setCallSign("Connor"):setDescription("Weapons Automation components")
	table.insert(stationList,stationConnor)
	neutralStations = neutralStations + 1
	stationAnderson = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationAnderson:setPosition(random(15000,20000),random(-25000,48000)):setCallSign("Anderson"):setDescription("Battery and Software Engineering")
	table.insert(stationList,stationAnderson)
	neutralStations = neutralStations + 1
	goods[stationAnderson] = {{"battery",5,65},{"software",5,115}}
	stationFeynman = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationFeynman:setPosition(random(-90000,-55000),random(25000,36250)):setCallSign("Feynman"):setDescription("Nanotechnology Research")
	table.insert(stationList,stationFeynman)
	friendlyStations = friendlyStations + 1
	goods[stationFeynman] = {{"nanites",5,79},{"software",5,115},{"food",2,1}}
	stationMayo = SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationMayo:setPosition(random(-45000,-30000),random(-14000,12500)):setCallSign("Mayo"):setDescription("Medical Research")
	table.insert(stationList,stationMayo)
	friendlyStations = friendlyStations + 1
	goods[stationMayo] = {{"food",5,1},{"medicine",5,5}}
	stationNefatha = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationNefatha:setPosition(random(-10000,12500),random(-96000,-80000)):setCallSign("Nefatha"):setDescription("Commerce and recreation")
	table.insert(stationList,stationNefatha)
	neutralStations = neutralStations + 1
	goods[stationNefatha] = {{"luxury",5,70}}
	stationScience4 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationScience4:setPosition(random(-60000,-40000),random(47000,55000)):setCallSign("Science-4"):setDescription("Biotech research")
	table.insert(stationList,stationScience4)
	neutralStations = neutralStations + 1
	stationSpeculation4 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationSpeculation4:setPosition(random(-26000,-15000),random(-10000,27000)):setCallSign("Speculation-4"):setDescription("Trading post")
	table.insert(stationList,stationSpeculation4)
	neutralStations = neutralStations + 1
	goods[stationSpeculation4] = {{"luxury",5,65}}
	stationTiberius = SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationTiberius:setPosition(random(-30000,-26000),random(-14000,35000)):setCallSign("Tiberius"):setDescription("Logistics coordination")
	table.insert(stationList,stationTiberius)
	friendlyStations = friendlyStations + 1
	goods[stationTiberius] = {{"food",5,1}}
	stationResearch11 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationResearch11:setPosition(random(-75000,-55000),random(-50000,-25000)):setCallSign("Research-11"):setDescription("Low Gravity Research")
	table.insert(stationList,stationResearch11)
	neutralStations = neutralStations + 1
	stationFreena = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationFreena:setPosition(random(0,15000),irandom(-37500,-15000)):setCallSign("Freena"):setDescription("Zero gravity sports")
	table.insert(stationList,stationFreena)
	neutralStations = neutralStations + 1
	stationOutpost33 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost33:setPosition(random(15000,65000),random(-65000,-25000)):setCallSign("Outpost-33"):setDescription("Resupply")
	table.insert(stationList,stationOutpost33)
	neutralStations = neutralStations + 1
	goods[stationOutpost33] = {{"luxury",5,75}}
	stationLando = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationLando:setPosition(random(-60000,-30000),random(612500,70000)):setCallSign("Lando"):setDescription("Casino and Gambling")
	table.insert(stationList,stationLando)
	neutralStations = neutralStations + 1
	stationKomov = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationKomov:setPosition(random(-55000,-30000),random(70000,80000)):setCallSign("Komov"):setDescription("Xenopsychology research")
	table.insert(stationList,stationKomov)
	neutralStations = neutralStations + 1
	stationScience2 = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationScience2:setPosition(random(20000,35000),random(55000,70000)):setCallSign("Science-2"):setDescription("Research Lab and Observatory")
	table.insert(stationList,stationScience2)
	neutralStations = neutralStations + 1
	stationPrefect = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationPrefect:setPosition(random(-65000,-60000),random(36250,55000)):setCallSign("Prefect"):setDescription("Textile and Fashion Creation")
	table.insert(stationList,stationPrefect)
	neutralStations = neutralStations + 1
	goods[stationPrefect] = {{"luxury",5,45}}
	stationOutpost7 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost7:setPosition(random(35000,45000),random(-15000,25000)):setCallSign("Outpost-7"):setDescription("Resupply")
	table.insert(stationList,stationOutpost7)
	neutralStations = neutralStations + 1
	goods[stationOutpost7] = {{"luxury",5,80}}
	stationOrgana = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOrgana:setPosition(irandom(55000,62000),random(20000,45000)):setCallSign("Organa"):setDescription("Diplomatic training")
	table.insert(stationList,stationOrgana)
	neutralStations = neutralStations + 1
	stationGrap = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	xGrap = random(-60000,15000)
	yGrap = random(-65000,-61250)
	stationGrap:setPosition(xGrap,yGrap):setCallSign("Grap"):setDescription("Mining station")
	posAxisGrap = random(0,360)
	posGrap = random(10000,60000)
	negGrap = random(10000,60000)
	spreadGrap = random(4000,8000)
	negAxisGrap = posAxisGrap + 180
	xPosAngleGrap, yPosAngleGrap = vectorFromAngle(posAxisGrap, posGrap)
	posEnd = random(40,90)
	createRandomAlongArc(Asteroid, afd+posEnd, xGrap+xPosAngleGrap, yGrap+yPosAngleGrap, posGrap, negAxisGrap, negAxisGrap+posEnd, spreadGrap)
	xNegAngleGrap, yNegAngleGrap = vectorFromAngle(negAxisGrap, negGrap)
	negEnd = random(20,60)
	createRandomAlongArc(Asteroid, afd+negEnd, xGrap+xNegAngleGrap, yGrap+yNegAngleGrap, negGrap, posAxisGrap, posAxisGrap+negEnd, spreadGrap)
	table.insert(stationList,stationGrap)
	neutralStations = neutralStations + 1
	stationGrup = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	xGrup = random(-65000,-61250)
	yGrup = random(-25000,25000)
	stationGrup:setPosition(xGrup,yGrup):setCallSign("Grup"):setDescription("Mining station")
	axisGrup = random(0,360)
	longGrup = random(30000,60000)
	shortGrup = random(10000,30000)
	spreadGrup = random(5000,8000)
	negAxisGrup = axisGrup + 180
	xLongAngleGrup, yLongAngleGrup = vectorFromAngle(axisGrup, longGrup)
	longGrupEnd = random(30,70)
	createRandomAlongArc(Asteroid, afd+longGrupEnd, xGrup+xLongAngleGrup, yGrup+yLongAngleGrup, longGrup, negAxisGrup, negAxisGrup+longGrupEnd, spreadGrup)
	xShortAngleGrup, yShortAngleGrup = vectorFromAngle(axisGrup, shortGrup)
	shortGrupEnd = random(40,90)
	shortGrupEndQ = shortGrupEnd
	shortGrupEnd = negAxisGrup - shortGrupEnd
	if shortGrupEnd < 0 then 
		shortGrupEnd = shortGrupEnd + 360
	end
	createRandomAlongArc(Asteroid, afd+shortGrupEndQ, xGrup+xShortAngleGrup, yGrup+yShortAngleGrup, shortGrup, shortGrupEnd, negAxisGrup, spreadGrup)
	if random(1,100) < 50 then
		goods[stationGrap] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationGrup] = {{"nickel",3,22},{"dilithium",5,50},{"platinum",5,70}}
	else
		goods[stationGrup] = {{"nickel",5,20},{"tritanium",5,50}}
		goods[stationGrap] = {{"nickel",3,22},{"dilithium",5,50},{"platinum",5,70}}
	end
	table.insert(stationList,stationGrup)
	neutralStations = neutralStations + 1
	stationOutpost8 = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationOutpost8:setPosition(random(-65000,-40000),random(-61250,-50000)):setCallSign("Outpost-8")
	table.insert(stationList,stationOutpost8)
	neutralStations = neutralStations + 1
	stationScience7 = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setCommsScript(""):setCommsFunction(commsStation)
	stationScience7:setPosition(random(-25000,-20000),random(-40000,-10000)):setCallSign("Science-7"):setDescription("Observatory")
	table.insert(stationList,stationScience7)
	friendlyStations = friendlyStations + 1
	goods[stationScience7] = {{"food",2,1}}
	stationCarradine = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationCarradine:setPosition(random(20000,35000),random(-15000,40000)):setCallSign("Carradine"):setDescription("Impulse Engine Components")
	table.insert(stationList,stationCarradine)
	neutralStations = neutralStations + 1
	goods[stationCarradine] = {{"impulse",5,100}}
	stationCalvin = SpaceStation():setTemplate("Medium Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation)
	stationCalvin:setPosition(random(40000,86250),random(45000,51000)):setCallSign("Calvin"):setDescription("Robotic components")
	table.insert(stationList,stationCalvin)
	neutralStations = neutralStations + 1
	totalStations = neutralStations + friendlyStations
	goods[stationCalvin] = {{"robotic",5,87}}
	originalStationList = stationList	--save for statistics
	art1 = Artifact():setModel("artifact4"):allowPickup(false):setScanningParameters(2,2):setRadarSignatureInfo(random(4,20),random(2,12), random(7,13))
	art2 = Artifact():setModel("artifact5"):allowPickup(false):setScanningParameters(2,3):setRadarSignatureInfo(random(2,12),random(7,13), random(4,20))
	art3 = Artifact():setModel("artifact6"):allowPickup(false):setScanningParameters(3,2):setRadarSignatureInfo(random(7,13),random(4,20), random(2,12))
	art1:setPosition(random(-50000,50000),random(-80000,-70000))
	art2:setPosition(random(-90000,-75000),random(-40000,-20000))
	art3:setPosition(random(50000,75000),random(625000,80000))
	artChoice = math.random(6)
	if artChoice == 1 then
		art1:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art2:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art3:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art1.quantum = true
		art2.chroniton = true
		art3.parallel = true
	elseif artChoice == 2 then
		art1:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art3:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art2:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art1.quantum = true
		art3.chroniton = true
		art2.parallel = true
	elseif artChoice == 3 then
		art2:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art1:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art3:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art2.quantum = true
		art1.chroniton = true
		art3.parallel = true
	elseif artChoice == 4 then
		art2:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art3:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art1:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art2.quantum = true
		art3.chroniton = true
		art1.parallel = true
	elseif artChoice == 5 then
		art3:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art1:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art2:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art3.quantum = true
		art1.chroniton = true
		art2.parallel = true
	else
		art3:setDescriptions("Unusual object","Artifact with quantum biometric characteristics")
		art2:setDescriptions("Unusual object","Artifact with embedded chroniton particles")
		art1:setDescriptions("Unusual object","Artifact bridging two parallel universes")
		art3.quantum = true
		art2.chroniton = true
		art1.parallel = true
	end
	ganaldaAngle = random(0,360)
	xGanalda, yGanalda = vectorFromAngle(ganaldaAngle,random(120000,150000))
	stationGanalda = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor")
	stationGanalda:setPosition(xGanalda,yGanalda):setCallSign("Ganalda")
	empokAngle = ganaldaAngle + random(60,180)
	xEmpok, yEmpok = vectorFromAngle(empokAngle,random(120000,150000))
	stationEmpok = SpaceStation():setTemplate("Large Station"):setFaction("Exuari")
	stationEmpok:setPosition(xEmpok,yEmpok):setCallSign("Empok Nor")
	ticAngle = empokAngle + random(60,120)
	xTic, yTic = vectorFromAngle(ticAngle,random(120000,150000))
	stationTic = SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor")
	stationTic:setPosition(xTic,yTic):setCallSign("Ticonderoga")
	createRandomAlongArc(Nebula, 15, 100000, -100000, 140000, 100, 170, 25000)
	Nebula():setPosition(xGanalda,yGanalda)
	gDist = distance(stationGanalda,0,0)
	createRandomAlongArc(Nebula, 5, 0, 0, gDist,ganaldaAngle-20, ganaldaAngle+20, 9000)
	alderaan= Planet():setPosition(random(-27000,32000),random(65500,87500)):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription("Lush planet with only mild seasonal variations")
	grawp = BlackHole():setPosition(random(67000,90000),random(-21000,40000))
	grawp.angle = random(0,360)
	grawp.travel = random(1,5)
	-- determine which stations will trade food, luxury items and/or medicine for their goods
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
	tradeFood[stationGrap] = true
	if random(1,100) < 50 then tradeLuxury[stationGrap] = true end
	tradeMedicine[stationGrap] = true
	tradeFood[stationGrup] = true
	tradeLuxury[stationGrup] = true
	tradeMedicine[stationGrup] = true
	tradeFood[stationOutpost15] = true
	tradeFood[stationOutpost21] = true
	tradeLuxury[stationOutpost21] = true
	if random(1,100) < 50 then tradeMedicine[stationOutpost21] = true end
	tradeLuxury[stationCarradine] = true
	tradeMedicine[stationCarradine] = true
	tradeFood[stationZefram] = true
	tradeLuxury[stationZefram] = true
	tradeLuxury[stationArcher] = true
	tradeMedicine[stationArcher] = true
	tradeFood[stationDeer] = true
	tradeLuxury[stationDeer] = true
	tradeMedicine[stationDeer] = true
	tradeFood[stationMarconi] = true
	tradeLuxury[stationMarconi] = true
	tradeFood[stationAlcaleica] = true
	tradeMedicine[stationAlcaleica] = true
	tradeLuxury[stationCalvin] = true
	whatTrade = random(1,100)
	if whatTrade < 33 then
		tradeMedicine[stationCavor] = true
	elseif whatTrade > 66 then
		tradeFood[stationCavor] = true
	else
		tradeLuxury[stationCavor] = true
	end
	tradeFood[stationEmory] = true
	tradeLuxury[stationEmory] = true
	tradeMedicine[stationEmory] = true
	tradeFood[stationVeloquan] = true
	tradeMedicine[stationVeloquan] = true
	tradeMedicine[stationBarclay] = true
	tradeFood[stationLipkin] = true
	tradeLuxury[stationLipkin] = true
	tradeMedicine[stationLipkin] = true
	tradeFood[stationRipley] = true
	tradeLuxury[stationRipley] = true
	tradeFood[stationDeckard] = true
	tradeLuxury[stationDeckard] = true
	tradeLuxury[stationAnderson] = true
	tradeFood[stationFeynman] = true
end
--[[-----------------------------------------------------------------
      Transport ship generation and handling 
-----------------------------------------------------------------]]--
function randomStation()
	stationCount = 0
	for sidx, obj in ipairs(stationList) do
		if obj:isValid() then
			stationCount = stationCount + 1
		else
			table.remove(stationList,sidx)
		end
	end
	sidx = math.floor(random(1, #stationList + 0.99))
	return stationList[sidx]
end

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
		transportSpawnDelay = delta + random(5,15)
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
			target = randomStation()
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
			rifl = math.floor(random(1,27))	-- random item from list
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
		addCommsReply("I need ordnance restocked", function()
			setCommsMessage("What type of ordnance?")
			for _, missile_type in ipairs(missile_types) do
				if player:getWeaponStorageMax(missile_type) > 0 then
					addCommsReply(missile_type .. " (" .. getWeaponCost(missile_type) .. "rep each)", function()
						handleWeaponRestock(missile_type)
					end)
				end
			end
		end)
	end
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if goods[comms_target] ~= nil then
		addCommsReply("Buy, sell, trade", function()
			oMsg = "Goods or components available here: quantity, cost in reputation\n"
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
	end
	if sensorBase ~= nil then
		if comms_target == sensorBase then
			gi = 1
			s1PartQuantity = 0
			s2PartQuantity = 0
			s3PartQuantity = 0
			repeat
				if goods[player][gi][1] == s1part then
					s1PartQuantity = goods[player][gi][2]
				end
				if goods[player][gi][1] == s2part then
					s2PartQuantity = goods[player][gi][2]
				end
				if goods[player][gi][1] == s3part then
					s3PartQuantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if s1PartQuantity > 0 and s2PartQuantity > 0 and s3PartQuantity > 0 then
				addCommsReply(string.format("Provide %s, %s and %s for sensor upgrade",s1part,s2part,s3part), function()
					decrementPlayerGoods(s1part)
					decrementPlayerGoods(s2part)
					decrementPlayerGoods(s3part)
					player.cargo = player.cargo + 3
					if stettorTarget == nil then
						if stationGanalda:isValid() then
							stettorTarget = stationGanalda
						elseif stationTic:isValid() then
							stettorTarget = stationTic
						else
							stettorTarget = stationEmpok
						end
					end
					oMsg = string.format("Our upgraded sensors found an enemy base in sector %s",stettorTarget:getSectorName())
					player.stettor = "provided"
					setCommsMessage(oMsg)
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if plotR == horizonStationDeliver then
		if comms_target == stationEmory then
			if player.horizonComponents == nil then
				gi = 1
				hr1partQuantity = 0
				hr2partQuantity = 0
				repeat
					if goods[player][gi][1] == hr1part then
						hr1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == hr2part then
						hr2partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if hr1partQuantity > 0 and hr2partQuantity > 0 then
					addCommsReply(string.format("Provide %s and %s for black hole research",hr1part,hr2part), function()
						decrementPlayerGoods(hr1part)
						decrementPlayerGoods(hr2part)
						player.cargo = player.cargo + 2
						bhsMsg = "With the materials you supplied, we installed special sensors on your ship. "
						bhsMsg = bhsMsg .. "We need you to get close to the black hole and run sensor sweeps. "
						bhsMsg = bhsMsg .. "Your science console will have the controls when your ship is in range."
						bhsMsg = bhsMsg .. "\nThe mobile black hole was last seen in sector " .. grawp:getSectorName()
						setCommsMessage(bhsMsg)
						player.horizonComponents = "provided"
					end)
				end
			end
		end
	end
	if plotO == beamRangeUpgrade then
		if comms_target == stationMarconi then
			if player.beamComponents == nil then
				gi = 1
				br1partQuantity = 0
				br2partQuantity = 0
				br3partQuantity = 0
				repeat
					if goods[player][gi][1] == br1part then
						br1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == br2part then
						br2partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == br3part then
						br3partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if br1partQuantity > 0 and br2partQuantity > 0 and br3partQuantity > 0 then
					addCommsReply(string.format("Provide %s, %s and %s for beam research project",br1part,br2part,br3part), function()
						decrementPlayerGoods(br1part)
						decrementPlayerGoods(br2part)
						decrementPlayerGoods(br3part)
						player.cargo = player.cargo + 3
						setCommsMessage("With the goods you provided, we completed our advanced beam weapons prototype. We transmitted our research results to Vaiken. The next time you dock at Vaiken, you can have the range of your beam weapons upgraded.")
						player.beamComponents = "provided"
					end)
				end
			end
		end
	end
	if plotO == impulseSpeedUpgrade then
		if comms_target == stationCarradine then
			if player.impulseSpeedComponents == nil then
				--impulseSpeedUpgradeAvailable
				gi = 1
				is1partQuantity = 0
				is2partQuantity = 0
				repeat
					if goods[player][gi][1] == is1part then
						is1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == is2part then
						is2partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if is1partQuantity > 0 and is2partQuantity > 0 then
					addCommsReply(string.format("Provide %s and %s for impulse engine research project",is1part,is2part), function()
						decrementPlayerGoods(is1part)
						decrementPlayerGoods(is2part)
						player.cargo = player.cargo + 2
						setCommsMessage("[Nikhil Morrison] With the goods you provided, I completed the impulse engine research. I transmitted the research results to Vaiken. The next time you dock at Vaiken, you can have the speed of your impulse engines improved.")
						player.impulseSpeedComponents = "provided"
					end)
				end
			end
		end
	end
	if plotO == spinUpgrade then
		if comms_target == spinBase then
			if player.spinComponents == nil then
				gi = 1
				sp1partQuantity = 0
				sp2partQuantity = 0
				sp3partQuantity = 0
				repeat
					if goods[player][gi][1] == sp1part then
						sp1partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == sp2part then
						sp2partQuantity = goods[player][gi][2]
					end
					if goods[player][gi][1] == sp3part then
						sp3partQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if sp1partQuantity > 0 and sp2partQuantity > 0 and sp3partQuantity > 0 then
					addCommsReply(string.format("Provide %s, %s and %s for maneuver research project",sp1part,sp2part,sp3part), function()
						decrementPlayerGoods(sp1part)
						decrementPlayerGoods(sp2part)
						decrementPlayerGoods(sp3part)
						player.cargo = player.cargo + 3
						setCommsMessage("[Maneuver technician] With the goods you provided, we completed the maneuver research and transmitted the research results to Vaiken. The next time you dock at Vaiken, you can have your ship's maneuver speed improved.")
						player.spinComponents = "provided"
					end)
				end
			end
		end
	end
	if comms_target == stationVaiken then
		if beamRangeUpgradeAvailable then
			addCommsReply("Apply Marconi station beam range upgrade", function()
				if player.marconiBeamUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					tempBeam = psb[player:getTypeName()]
					if tempBeam == nil then
						setCommsMessage("Your ship type does not support a beam weapon upgrade.")
					else
						for b=0,tempBeam-1 do
							newRange = player:getBeamWeaponRange(b) * 1.25
							tempCycle = player:getBeamWeaponCycleTime(b)
							tempDamage = player:getBeamWeaponDamage(b)
							tempArc = player:getBeamWeaponArc(b)
							tempDirection = player:getBeamWeaponDirection(b)
							player:setBeamWeapon(b,tempArc,tempDirection,newRange,tempCycle,tempDamage)
						end
						player.marconiBeamUpgrade = true
						setCommsMessage("Your beam range has been improved by 25 percent")
					end
				end
			end)
		end
		if impulseSpeedUpgradeAvailable then
			addCommsReply("Apply Nikhil Morrison impulse engine upgrade", function()
				if player.morrisonUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					player:setImpulseMaxSpeed(player:getImpulseMaxSpeed()*1.25)
					player.morrisonUpgrade = true
					setCommsMessage("Your impulse engine speed has been improved by 25 percent")
				end
			end)
		end
		if spinUpgradeAvailable then
			addCommsReply("Apply maneuver upgrade", function()
				if player.spinUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					player:setRotationMaxSpeed(player:getRotationMaxSpeed()*2)
					player.spinUpgrade = true
					setCommsMessage("Your spin speed has been doubled")
				end
			end)
		end
		if shieldUpgradeAvailable then
			addCommsReply("Apply Phillip Organa shield upgrade", function()
				if player.shieldUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					frontShieldValue = player:getShieldMax(0)
					rearShieldValue = player:getShieldMax(1)
					player:setShieldsMax(frontShieldValue*1.25,rearShieldValue*1.25)
					player.shieldUpgrade = true
					setCommsMessage("Your shield capacity has been increased by 25 percent")
				end
			end)
		end
		if beamDamageUpgradeAvailable then
			addCommsReply("Apply Nefatha beam damage upgrade", function()
				if player.nefathaUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					tempBeam = psb[player:getTypeName()]
					if tempBeam == nil then
						setCommsMessage("Your ship type does not support a beam weapon upgrade.")
					else
						for b=0,tempBeam-1 do
							tempRange = player:getBeamWeaponRange(b)
							tempCycle = player:getBeamWeaponCycleTime(b)
							newDamage = player:getBeamWeaponDamage(b) * 1.25
							tempArc = player:getBeamWeaponArc(b)
							tempDirection = player:getBeamWeaponDirection(b)
							player:setBeamWeapon(b,tempArc,tempDirection,tempRange,tempCycle,newDamage)
						end
						player.nefathaUpgrade = true
						setCommsMessage("Your beam weapons damage has improved by 25 percent")
					end
				end
			end)
		end
	end
--	if comms_target == stationEmory then
--		if diagnostic then
--			addCommsReply("Turn off test script diagnostic", function()
--				diagnostic = false
--				setCommsMessage("Diagnostic turned off")
--				addCommsReply("Back", commsStation)
--			end)
--		else
--			addCommsReply("Turn on test script diagnostic", function()
--				diagnostic = true
--				setCommsMessage("Diagnostic turned on")
--				addCommsReply("Back", commsStation)
--			end)
--		end
--	end
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
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
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
					gkMsg = gkMsg .. " I've heard about these goods:"
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
	end)
	if player:isFriendly(comms_target) then
		addCommsReply("What are my current orders?", function()
			ordMsg = primaryOrders .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
	end
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			if playWithTimeLimit then
				dMsg = string.format("Game time remaining: %f",gameTimeLimit)
			else
				dMsg = string.format("Clue message time remaining: %f",clueMessageDelay)
			end
			for p12idx=1,8 do
				p12 = getPlayerShip(p12idx)
				if p12 ~= nil and p12:isValid() then
					dMsg = dMsg .. string.format("\nPlayer %i: %s in sector %s",p12idx,p12:getCallSign(),p12:getSectorName())
				end
			end
			if plotR == nil then
				addCommsReply("Choose required mission", function()
					if stettorMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 1800 then
								addCommsReply("Stettor", function()
									chooseSensorBase()
									chooseSensorParts()
									plotR = stettorOrderMessage
								end)
							end
						else
							addCommsReply("Stettor", function()
								chooseSensorBase()
								chooseSensorParts()
								plotR = stettorOrderMessage
							end)						
						end
					end
					if undercutMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 2400 then
								addCommsReply("Undercut", function()
									mPart = 1
									plotR = undercutOrderMessage
									chooseUndercutBase()
								end)
							end
						else
							addCommsReply("Undercut", function()
								mPart = 1
								plotR = undercutOrderMessage
								chooseUndercutBase()
							end)						
						end
					end
					if horizonMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 2400 then
								addCommsReply("Horizon", function()
									chooseHorizonParts()
									plotR = horizonOrderMessage
								end)
							end
						else
							addCommsReply("Horizon", function()
								chooseHorizonParts()
								plotR = horizonOrderMessage
							end)						
						end
					end
					if sporiskyMission ~= "done" then
						if playWithTimeLimit then
							if gameTimeLimit > 1700 then
								addCommsReply("Sporisky", function()
									chooseTraitorBase()
									plotR = traitorOrderMessage
								end)
							end
						else
							addCommsReply("Sporisky", function()
								chooseTraitorBase()
								plotR = traitorOrderMessage
							end)						
						end
					end
					addCommsReply("Back", commsStation)
				end)
			elseif plotR == undercutStation then
				dMsg = dMsg .. "\nUndercut station: hide base: " .. hideBase:getCallSign()
				dMsg = dMsg .. "\nundercut location: " .. undercutLocation
			elseif plotR == undercutTransport then
				dMsg = dMsg .. "\nundercut location: " .. undercutLocation
				dMsg = dMsg .. "\nhide transport: " .. hideTransport:getCallSign() .. " in sector " .. hideTransport:getSectorName()
			elseif plotR == undercutEnemyBase then
				dMsg = dMsg .. "\nundercut enemy base: " .. undercutTarget:getCallSign() .. " in sector " .. undercutTarget:getSectorName()
			elseif plotR == horizonStationDeliver then
				dMsg = dMsg .. string.format("\nhorizon station deliver part1: %s, part2: %s",hr1part,hr2part)
				if player.horizonComponents == nil then
					dMsg = dMsg .. "\nplayer horizon components: nil"
				else
					dMsg = dMsg .. "\nplayer horizon components: " .. player.horizonComponents
				end
			end
			if plotO == nil then
				addCommsReply("Choose optional mission", function()
					if beamRangePlot ~= "done" then
						addCommsReply("beam range", function()
							chooseBeamRangeParts()
							plotO = beamRangeMessage				
						end)
					end
					if impulseSpeedPlot ~= "done" then
						addCommsReply("impulse speed", function()
							impulseSpeedParts()
							plotO = impulseSpeedMessage
						end)
					end
					if spinPlot ~= "done" then
						addCommsReply("spin speed", function()
							chooseSpinBaseParts()
							plotO = spinMessage						
						end)
					end
					if quantumArtPlot ~= "done" then
						addCommsReply("quantum artifact", function()
							plotO = quantumArtMessage
						end)
					end
					if beamDamagePlot ~= "done" then
						addCommsReply("beam damage", function()
							chooseBeamDamageParts()
							plotO = beamDamageMessage
						end)
					end
					addCommsReply("Back", commsStation)
				end)
			end
			setCommsMessage(dMsg)
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
--						oMsg = "Goods or components available from freighter: quantity, cost in reputation\n"
--						gi = 1		-- initialize goods index
--						repeat
--							goodsType = goods[comms_target][gi][1]
--							goodsQuantity = goods[comms_target][gi][2]
--							goodsRep = goods[comms_target][gi][3]
--							oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--							gi = gi + 1
--						until(gi > #goods[comms_target])
--						oMsg = oMsg .. "Current Cargo:\n"
--						gi = 1
--						cargoHoldEmpty = true
--						repeat
--							playerGoodsType = goods[player][gi][1]
--							playerGoodsQuantity = goods[player][gi][2]
--							if playerGoodsQuantity > 0 then
--								oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--								cargoHoldEmpty = false
--							end
--							gi = gi + 1
--						until(gi > #goods[player])
--						if cargoHoldEmpty then
--							oMsg = oMsg .. "     Empty\n"
--						end
--						playerRep = math.floor(player:getReputationPoints())
--						oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--						setCommsMessage(oMsg)
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
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
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
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
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
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]*2
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
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
--					oMsg = "Goods or components available here: quantity, cost in reputation\n"
--					gi = 1		-- initialize goods index
--					repeat
--						goodsType = goods[comms_target][gi][1]
--						goodsQuantity = goods[comms_target][gi][2]
--						goodsRep = goods[comms_target][gi][3]*2
--						oMsg = oMsg .. string.format("     %s: %i, %i\n",goodsType,goodsQuantity,goodsRep)
--						gi = gi + 1
--					until(gi > #goods[comms_target])
--					oMsg = oMsg .. "Current Cargo:\n"
--					gi = 1
--					cargoHoldEmpty = true
--					repeat
--						playerGoodsType = goods[player][gi][1]
--						playerGoodsQuantity = goods[player][gi][2]
--						if playerGoodsQuantity > 0 then
--							oMsg = oMsg .. string.format("     %s: %i\n",playerGoodsType,playerGoodsQuantity)
--							cargoHoldEmpty = false
--						end
--						gi = gi + 1
--					until(gi > #goods[player])
--					if cargoHoldEmpty then
--						oMsg = oMsg .. "     Empty\n"
--					end
--					playerRep = math.floor(player:getReputationPoints())
--					oMsg = oMsg .. string.format("Available Space: %i, Available Reputation: %i\n",player.cargo,playerRep)
--					setCommsMessage(oMsg)
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
		if undercutLocation == "transport" then
			if distance(player,comms_target) < 5000 then
				if comms_target == hideTransport then
					addCommsReply("I need to talk to Charles Undercut", function()
						setCommsMessage("[Charles Undercut] Haven't you destroyed my life enough?")
						addCommsReply("We need the information you obtained about enemies in this region", function()
							setCommsMessage("That will cost you something more than just pretty words. Got any luxury, gold or platinum goods?")
							gi = 1
							luxuryQuantity = 0
							goldQuantity = 0
							platinumQuantity = 0
							repeat
								if goods[player][gi][1] == "luxury" then
									luxuryQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == "gold" then
									goldQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == "platinum" then
									platinumQuantity = goods[player][gi][2]
								end
								gi = gi + 1
							until(gi > #goods[player])
							if luxuryQuantity > 0 then
								addCommsReply("Trade luxury for information", function()
									decrementPlayerGoods("luxury")
									player.cargo = player.cargo + 1
									if stationGanalda:isValid() then
										undercutTarget = stationGanalda
									elseif stationEmpok:isValid() then
										undercutTarget = stationEmpok
									else
										undercutTarget = stationTic
									end
									player:addToShipLog("enemy base identified in sector " .. undercutTarget:getSectorName(),"Magenta")
									setCommsMessage("I found an enemy base in sector " .. undercutTarget:getSectorName())
									undercutLocation = "free"
								end)
							end
							if goldQuantity > 0 then
								addCommsReply("Trade gold for information", function()
									decrementPlayerGoods("gold")
									player.cargo = player.cargo + 1
									if stationEmpok:isValid() then
										undercutTarget = stationEmpok
									elseif stationGanalda:isValid() then
										undercutTarget = stationGanalda
									else
										undercutTarget = stationTic
									end
									player:addToShipLog("enemy base identified in sector " .. undercutTarget:getSectorName(),"Magenta")
									setCommsMessage("I found an enemy base in sector " .. undercutTarget:getSectorName())
									undercutLocation = "free"
								end)
							end
							if platinumQuantity > 0 then
								addCommsReply("Trade platinum for information", function()
									decrementPlayerGoods("platinum")
									player.cargo = player.cargo + 1
									if stationTic:isValid() then
										undercutTarget = stationTic
									elseif stationGanalda:isValid() then
										undercutTarget = stationGanalda
									else
										undercutTarget = stationEmpok
									end
									player:addToShipLog("enemy base identified in sector " .. undercutTarget:getSectorName(),"Magenta")
									setCommsMessage("I found an enemy base in sector " .. undercutTarget:getSectorName())
									undercutLocation = "free"
								end)
							end
							addCommsReply("Back", commsShip)
						end)
					end)
				end
			end
		end
		if plotR == sporiskyTransport then
			if comms_target == runTransport then
				if distance(player,comms_target) < 5000 then
					if sporiskyLocation ~= "aboard ship" then
						addCommsReply("We need you to hand over Annette Sporisky", function()
							asMsg = "Why should we? Despite what you may have heard, she is not related to this freighter's owner. "
							asMsg = asMsg .. "However, she's obviously valuable. I'll hand her over for something I can trade, "
							asMsg = asMsg .. "one of the following types of goods: "
							if as1part == nil then
								as1choice = math.floor(random(1,3))
								if as1choice == 1 then
									as1part = "dilithium"
								elseif as1choice == 2 then
									as1part = "platinum"
								else
									as1part = "gold"
								end
							end
							if as2part == nil then
								as2choice = math.floor(random(1,3))
								if as2choice == 1 then
									as2part = "nanites"
								elseif as2choice == 2 then
									as2part = "impulse"
								else
									as2part = "communication"
								end
							end
							if as3part == nil then
								as3choice = math.floor(random(1,3))
								if as3choice == 1 then
									as3part = "optic"
								elseif as3choice == 2 then
									as3part = "lifter"
								else
									as3part = "filament"
								end
							end
							asMsg = asMsg .. as1part .. ", " .. as2part .. " or " .. as3part
							setCommsMessage(asMsg)
							gi = 1
							as1partQuantity = 0
							as2partQuantity = 0
							as3partQuantity = 0
							repeat
								if goods[player][gi][1] == as1part then
									as1partQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == as2part then
									as2partQuantity = goods[player][gi][2]
								end
								if goods[player][gi][1] == as3part then
									as3partQuantity = goods[player][gi][2]
								end
								gi = gi + 1
							until(gi > #goods[player])
							if as1partQuantity > 0 then
								addCommsReply("Trade " .. as1part .. " for Annette Sporisky", function()
									decrementPlayerGoods(as1part)
									player.cargo = player.cargo + 1
									player.traitorBought = true
									player:addToShipLog("Annette Sporisky aboard","Magenta")
									setCommsMessage("Traded")
									sporiskyTarget = stationGanalda
									sporiskyLocation = "aboard ship"
								end)
							end
							if as2partQuantity > 0 then
								addCommsReply("Trade " .. as2part .. " for Annette Sporisky", function()
									decrementPlayerGoods(as2part)
									player.cargo = player.cargo + 1
									player.traitorBought = true
									player:addToShipLog("Annette Sporisky aboard","Magenta")
									setCommsMessage("Traded")
									sporiskyTarget = stationEmpok
									sporiskyLocation = "aboard ship"
								end)
							end
							if as3partQuantity > 0 then
								addCommsReply("Trade " .. as3part .. " for Annette Sporisky", function()
									decrementPlayerGoods(as3part)
									player.cargo = player.cargo + 1
									player.traitorBought = true
									player:addToShipLog("Annette Sporisky aboard","Magenta")
									setCommsMessage("Traded")
									sporiskyTarget = stationTic
									sporiskyLocation = "aboard ship"
								end)
							end
							addCommsReply("Back", commsShip)
						end)
					end
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
      Wave management 
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
	sp = irandom(300,500)
	deployConfig = random(1,100)
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

function launchWaves()
	waveSize = irandom(1,4)
	waveProgress = waveProgress + waveProgressInterval
	if random(1,100) < 50 then
		wave1angle = ganaldaAngle
	else
		wave1angle = ticAngle
	end
	wave1startx, wave1starty = vectorFromAngle(wave1angle,random(60000+waveProgress*10000,80000+waveProgress*10000))
	wave1list = {}
	wave1list = spawnEnemies(wave1startx, wave1starty, random(.6,3))
	waveEnemyCount = 0
	if stationVaiken:isValid() then
		svx, svy = stationVaiken:getPosition()
	else
		svx = 0
		svy = 0
	end
	for _, enemy in ipairs(wave1list) do
		enemy:orderFlyTowards(svx, svy)
		waveEnemyCount = waveEnemyCount + 1
	end
	if waveSize > 1 then
		if waveSize == 4 then
			wave2angle = wave1angle + random(60,120)
		elseif waveSize == 3 then
			wave2angle = wave1angle + random(60,180)
		else
			wave2angle = wave1angle + random(90,270)
		end
		wave2distance = random(60000+waveProgress*10000,80000+waveProgress*10000)
		wave2startx, wave2starty = vectorFromAngle(wave2angle,wave2distance)
		wave2list = {}
		wave2list = spawnEnemies(wave2startx, wave2starty, random(.5,2) + waveProgress, "Exuari")
		for _, enemy in ipairs(wave2list) do
			enemy:orderFlyTowards(svx, svy)
			waveEnemyCount = waveEnemyCount + 1
		end	
	end
	if waveSize > 2 then
		if waveSize == 4 then
			wave3angle = wave2angle + random(60,120)
		else
			wave3angle = wave2angle + random(60,180)
		end
		wave3startx, wave3starty = vectorFromAngle(wave3angle,random(60000+waveProgress*10000,80000+waveProgress*10000))
		wave3list = {}
		wave3list = spawnEnemies(wave3startx, wave3starty, random(.4,1.5) + waveProgress)
		for _, enemy in ipairs(wave3list) do
			enemy:orderFlyTowards(svx, svy)
			waveEnemyCount = waveEnemyCount + 1
		end	
	end
	if waveSize == 4 then
		wave4angle = wave3angle + random(60,120)
		wave4startx, wave4starty = vectorFromAngle(wave4angle,random(60000+waveProgress*10000,80000+waveProgress*10000))
		wave4list = {}
		wave4list = spawnEnemies(wave4startx, wave4starty, random(.3,1), "Exuari")
		for _, enemy in ipairs(wave3list) do
			enemy:orderFlyTowards(svx, svy)
			waveEnemyCount = waveEnemyCount + 1
		end	
	end
end

function monitorWaves(delta)
	if waveInProgress then
		waveCheckDelay = waveCheckDelay - delta
		if waveCheckDelay > 0 then
			return
		end
		waveRemainingEnemies = 0
		for _, enemy in ipairs(wave1list) do
			if enemy:isValid() then
				waveRemainingEnemies = waveRemainingEnemies + 1
			end
		end
		if waveSize > 1 then
			for _, enemy in ipairs(wave2list) do
				if enemy:isValid() then
					waveRemainingEnemies = waveRemainingEnemies + 1
				end
			end
		end
		if waveSize > 2 then
			for _, enemy in ipairs(wave3list) do
				if enemy:isValid() then
					waveRemainingEnemies = waveRemainingEnemies + 1
				end
			end
		end
		if waveSize == 4 then
			for _, enemy in ipairs(wave4list) do
				if enemy:isValid() then
					waveRemainingEnemies = waveRemainingEnemies + 1
				end
			end
		end
		if waveRemainingEnemies/waveEnemyCount < .12 or waveDelayCount > waveDelayCountCheck then
			for _, enemy in ipairs(wave1list) do
				if enemy:isValid() then
					table.insert(persistentEnemies,enemy)
				end
			end
			if waveSize > 1 then
				for _, enemy in ipairs(wave2list) do
					if enemy:isValid() then
						table.insert(persistentEnemies,enemy)
					end
				end
			end
			if waveSize > 2 then
				for _, enemy in ipairs(wave3list) do
					if enemy:isValid() then
						table.insert(persistentEnemies,enemy)
					end
				end
			end
			if waveSize == 4 then
				for _, enemy in ipairs(wave4list) do
					if enemy:isValid() then
						table.insert(persistentEnemies,enemy)
					end
				end
			end
			for _, enemy in ipairs(persistentEnemies) do
				pecdist = 999999	--player to enemy closest distance
				if enemy:isValid() then
					for p6idx=1,8 do
						p6obj = getPlayerShip(p6idx)
						if p6obj ~= nil and obj:isValid() then
							curdist = distance(p6obj,enemy)
							if curdist < pecdist then
								closest = p6obj
								pecdist = curdist
							end
						end
					end
					enemy:orderAttack(closest)
				end
			end
			waveInProgress = false
		end
		waveCheckDelay = delta + 20
		if playWithTimeLimit then
			waveDelayCount = waveDelayCount + 1
		end
	else
		launchWaves()
		waveDelayCount = 0
		waveInProgress = true
		waveCheckDelay = delta + 20
	end
end

function helpWarn(delta)
	helpWarnDelay = helpWarnDelay - delta
	if helpWarnDelay > 0 then
		return
	end
	helpWarnDelay = delta + 30
	waveNear(wave1list)
	if waveSize > 1 then
		waveNear(wave2list)
	end
	if waveSize > 2 then
		waveNear(wave3list)
	end
	if waveSize == 4 then
		waveNear(wave4list)
	end
end

function waveNear(enemyWaveList)
	for _, enemy in pairs(enemyWaveList) do
		if enemy:isValid() then
			playerInRange = false -- no warning if a player in range
			for p7idx=1,8 do
				p7 = getPlayerShip(p7idx)
				if p7 ~= nil and p7:isValid() and distance(p7,enemy) < 30000 then
					playerInRange = true
					break
				end
			end
			if not playerInRange then
				distToEnemy = 999999
				closestStation = nil
				for _, obj in ipairs(enemy:getObjectsInRange(30000)) do
					if obj:isValid() then
						if obj.typeName == "SpaceStation" then
							if obj:getFaction() == "Human Navy" or obj:getFaction() == "Independent" then
								curDist = distance(obj,enemy)
								if curDist < distToEnemy then
									distToEnemy = curDist
									closestStation = obj
								end
							end
						end
					end
				end
				warnFactor = (1 - distToEnemy/30000)*100
				if closestStation.comms_data.friendlyness ~= nil then
					warnFactor = warnFactor + closestStation.comms_data.friendlyness
				end
--				if random(1,100) < warnFactor then
--					closestStation = nil
--				end
				if closestStation ~= nil then
					distToPlayer = 999999
					closestPlayer = nil
					for p8idx=1,8 do
						p8 = getPlayerShip(p8idx)
						if p8 ~= nil and p8:isValid() then
							curDist = distance(p8,closestStation)
							if curDist < distToPlayer then
								distToPlayer = curDist
								closestPlayer = p8
							end
						end
					end
					if diagnostic then
						lMsg = string.format("%f ",warnFactor)
					else
						lMsg = ""
					end
					lMsg = lMsg .. "[" .. closestStation:getCallSign() .. ", Sector " .. closestStation:getSectorName() .. "] There are enemies nearby"
					closestPlayer:addToShipLog(lMsg, "Red")
					return
				end
			end
		end
	end
end

function showGameEndStatistics()
	destroyedStations = 0
	survivedStations = 0
	destroyedFriendlyStations = 0
	survivedFriendlyStations = 0
	destroyedNeutralStations = 0
	survivedNeutralStations = 0
	for _, station in pairs(originalStationList) do
		if station:isFriendly(getPlayerShip(-1)) then
			if station:isValid() then
				survivedStations = survivedStations + 1
				survivedFriendlyStations = survivedFriendlyStations + 1
			end
		else
			if station:isValid() then
				survivedStations = survivedStations + 1
				survivedNeutralStations = survivedNeutralStations + 1
			end
		end
	end
	destroyedStations = totalStations - survivedStations
	destroyedFriendlyStations = friendlyStations - survivedFriendlyStations
	destroyedNeutralStations = neutralStations - survivedNeutralStations
	gMsg = string.format("Stations: %i\t survived: %i\t destroyed: %i",totalStations,survivedStations,destroyedStations)
	gMsg = gMsg .. string.format("\nFriendly Stations: %i\t survived: %i\t destroyed: %i",friendlyStations,survivedFriendlyStations,destroyedFriendlyStations)
	gMsg = gMsg .. string.format("\nNeutral Stations: %i\t survived: %i\t destroyed: %i",neutralStations,survivedNeutralStations,destroyedNeutralStations)
	gMsg = gMsg .. string.format("\n\n\n\nRequired missions completed: %i",requiredMissionCount)
	rankVal = survivedFriendlyStations/friendlyStations*.7 + survivedNeutralStations/neutralStations*.3
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
	gMsg = gMsg .. "\nEarned rank: " .. rank
	globalMessage(gMsg)
end
--[[-----------------------------------------------------------------
      Required plot choice: Undercut leads to base destruction
-----------------------------------------------------------------]]--
function chooseUndercutBase()
	if hideChoice == nil then
		hideChoice = math.floor(random(1,4))
		if hideChoice == 1 then
			if stationOutpost21:isValid() then
				hideBase = stationOutpost21
			elseif stationOutpost33:isValid() then
				hideBase = stationOutpost33
			elseif stationLando:isValid() then
				hideBase = stationLando
			else
				hideBase = stationOutpost8
			end
		elseif hideChoice == 2 then
			if stationOutpost33:isValid() then
				hideBase = stationOutpost33
			elseif stationLando:isValid() then
				hideBase = stationLando
			elseif stationOutpost8:isValid() then
				hideBase = stationOutpost8
			else
				hideBase = stationOutpost21
			end
		elseif hideChoice == 3 then
			if stationLando:isValid() then
				hideBase = stationLando
			elseif stationOutpost8:isValid() then
				hideBase = stationOutpost8
			elseif stationOutpost21:isValid() then
				hideBase = stationOutpost21
			else
				hideBase = stationOutpost33
			end
		else
			if stationOutpost8:isValid() then
				hideBase = stationOutpost8
			elseif stationOutpost33:isValid() then
				hideBase = stationOutpost33
			elseif stationLando:isValid() then
				hideBase = stationLando
			else
				hideBase = stationOutpost21
			end
		end
	end
	hideStationName = hideBase:getCallSign()
	hideStationSector = hideBase:getSectorName()
end

function undercutOrderMessage(delta)
	mMsg = string.format("[Vaiken] As a naval operative, Charles Undercut discovered information about enemies in this region. Unfortunately, he was fired for his poor performance as a maintenance technician by his commanding officer before he could file a report. We need his information. His last known location was station %s in sector %s. Go find him and get that information",hideBase:getCallSign(),hideBase:getSectorName()) 
	for p11idx=1,8 do
		p11 = getPlayerShip(p11idx)
		if p11 ~= nil and p11:isValid() then
			p11:addToShipLog(mMsg,"Magenta")
		end
	end	
	secondaryOrders = "\nFind Charles Undercut last reported at station " .. hideStationName .. " in sector " .. hideStationSector .. " who has information on enemy activity"
	plotR = undercutStation
end

function undercutStation(delta)
	if hideBase:isValid() then
		for p9idx=1,8 do
			p9 = getPlayerShip(p9idx)
			if p9 ~= nil and p9:isValid() then
				if p9:isDocked(hideBase) then
					if p9.undercut == nil then
						if hideTransport == nil then
							farthestTransport = transportList[1]
							for _, t in ipairs(transportList) do
								if t:isValid() then
									if distance(hideBase, t) > distance(hideBase, farthestTransport) then
										farthestTransport = t
									end
								end
							end
							hideTransport = farthestTransport
						end
						p9.undercut = hideTransport
						fMsg = "[" .. hideBase:getCallSign() .. "] We haven't seen Charles Undercut in a while. He took a job as a maintenance technician aboard " .. hideTransport:getCallSign()
						fMsg = fMsg .. ".\nLast we heard, that ship was working in the " .. hideTransport:getSectorName() .. " sector. He was desperate for a job."
						p9:addToShipLog(fMsg,"Magenta")
						plotR = undercutTransport
						undercutLocation = "transport"
						undercutHelp = 30
					end
				end
			end
		end
	else
		undercutMission = "done"
		plotR = nil
	end
end

function undercutTransport(delta)
	if hideTransport:isValid() then
		if undercutLocation == "transport" then
			undercutHelp = undercutHelp - delta
			if undercutHelp < 0 then
				helpHideTransport = false
				if hideTransport:getHull() < hideTransport:getHullMax() then
					helpHideTransport = true
				end
				shields = hideTransport:getShieldCount()
				for n=0,shields-1 do
					if hideTransport:getShieldLevel(n)/hideTransport:getShieldMax(n) < .5 then
						helpHideTransport = true
					end
				end
				if helpHideTransport then
					playerDistance = 999999
					for p10idx=1,8 do
						p10 = getPlayerShip(p10idx)
						if p10 ~= nil and p10:isValid() then
							currentDistance = distance(p10,hideTransport)
							if currentDistance < playerDistance then
								closestPlayer = p10
								playerDistance = currentDistance
							end
						end
					end
					hMsg = "[" .. hideTransport:getCallSign() .. "] we need help. Our maintenance technician says you might be interested. "
					hMsg = hMsg .. "We are in sector " .. hideTransport:getSectorName() .. ". Hurry."
					closestPlayer:addToShipLog(hMsg,"Magenta")
				end
				undercutHelp = delta + 30
			end
		end
		if undercutLocation == "free" then
			secondaryOrders = "\nDestroy enemy base in sector " .. undercutTarget:getSectorName()
			plotR = undercutEnemyBase
		end
	else
		undercutMission = "done"
		plotR = nil
	end
end

function undercutEnemyBase(delta)
	if undercutBaseDefense == nil then
		undercutTargetx, undercutTargetY = undercutTarget:getPosition()
		undercutWaveDefenseList = {}
		undercutWaveDefenseList = spawnEnemies(undercutTargetx, undercutTargetY, 1, undercutTarget:getFaction())
		for _, enemy in ipairs(undercutWaveDefenseList) do
			enemy:orderDefendTarget(undercutTarget)
		end
		undercutBaseDefense = true
	end
	if not undercutTarget:isValid() then
		requiredMissionCount = requiredMissionCount + 1
		secondaryOrders = ""
		undercutMission = "done"
		for p30idx=1,8 do
			p30 = getPlayerShip(p30idx)
			if p30 ~= nil and p30:isValid() and undercutRep == nil then
				p30:addReputationPoints(100-(difficulty*5))
				undercutRep = "awarded"
			end
		end
		plotR = nil
	end
end
--[[-----------------------------------------------------------------
      Required plot choice: Stettor sensors find enemy base - destroy
-----------------------------------------------------------------]]--
function chooseSensorBase()
	if sensorBase == nil then
		sensorChoice = math.floor(random(1,4))
		if sensorChoice == 1 then
			sensorBase = stationVactel
		elseif sensorChoice == 2 then
			sensorBase = stationArcher
		elseif sensorChoice == 3 then
			sensorBase = stationDeer
		else
			sensorBase = stationCavor
		end
	end
	sensorBaseName = sensorBase:getCallSign()
	sensorBaseSector = sensorBase:getSectorName()
end

function chooseSensorParts()
	if s1part == nil then
		si1Choice = math.floor(random(1,3))
		if si1Choice == 1 then
			s1part = "dilithium"
		elseif si1Choice == 2 then
			s1part = "cobalt"
		else
			s1part = "tritanium"
		end
	end
	if s2part == nil then
		si2Choice = math.floor(random(1,3))
		if si2Choice == 1 then
			s2part = "software"
		elseif si2Choice == 2 then
			s2part = "optic"
		else
			s2part = "robotic"
		end
	end
	s3part = "sensor"
end

function stettorOrderMessage(delta)
	snsMsg = "[Vaiken] Jing Stettor's research on advanced sensor technology produced a breakthrough. To facilitate rapid deployment, we need you to gather the following:\n"
	snsMsg = snsMsg .. s1part .. "\n"
	snsMsg = snsMsg .. s2part .. "\n"
	snsMsg = snsMsg .. s3part .. "\n"
	snsMsg = snsMsg .. "and take these items to station " .. sensorBaseName .. " in sector " .. sensorBaseSector
	secondaryOrders = string.format("\nGather the following:\n%s\n%s\n%s\nand take to station %s in sector %s",s1part,s2part,s3part,sensorBaseName,sensorBaseSector)
	if sensorMessage == nil then
		for p13idx=1,8 do
			p13 = getPlayerShip(p13idx)
			if p13 ~= nil and p13:isValid() then
				p13:addToShipLog(snsMsg,"Magenta")
			end
		end	
		sensorMessage = "done"
	end
	plotR = stettorStation
end

function stettorStation(delta)
	if sensorBase:isValid() then
		for p14idx=1,8 do
			p14 = getPlayerShip(p14idx)
			if p14 ~= nil and p14:isValid() then
				if p14:isDocked(sensorBase) then
					if p14.stettor == "provided" then
						secondaryOrders = "\nDestroy enemy base in sector " .. stettorTarget:getSectorName()
						plotR = stettorEnemyBase
					end
				end
			end
		end
	else
		stettorMission = "done"
		plotR = nil
	end
end

function stettorEnemyBase(delta)
	if not stettorTarget:isValid() then
		requiredMissionCount = requiredMissionCount + 1
		secondaryOrders = ""
		stettorMission = "done"
		for p31idx=1,8 do
			p31 = getPlayerShip(p31idx)
			if p31 ~= nil and p31:isValid() and stettorRep == nil then
				p31:addReputationPoints(80-(difficulty*5))
				stettorRep = "awarded"
			end
		end
		plotR = nil
	end
end
--[[-----------------------------------------------------------------
      Required plot choice: Traitor bought identifies enemy base
-----------------------------------------------------------------]]--
function chooseTraitorBase()
	if traitorBase == nil then
		traiterBaseChoice = math.floor(random(1,3))
		if traiterBaseChoice == 1 then
			traitorBase = stationMarconi
		elseif traiterBaseChoice == 2 then
			traitorBase = stationMudd
		else
			traitorBase = stationAlcaleica
		end
	end
	traitorBaseName = traitorBase:getCallSign()
	traitorBaseSector = traitorBase:getSectorName()
end

function traitorOrderMessage(delta)
	tMsg = "[Vaiken] Intelligence observed a spy for the enemy at station " .. traitorBaseName .. " in sector " .. traitorBaseSector
	tMsg = tMsg .. ". Go find out what you can about this spy."
	secondaryOrders = string.format("\nInvestigate spy reported at station %s in sector %s",traitorBaseName,traitorBaseSector)
	if traitorMessage == nil then
		for p14idx=1,8 do
			p14 = getPlayerShip(p14idx)
			if p14 ~= nil and p14:isValid() then
				p14:addToShipLog(tMsg,"Magenta")
			end
		end	
		traitorMessage = "done"
	end
	plotR = traitorStation
end

function traitorStation(delta)
	if traitorBase:isValid() then
		for p15idx=1,8 do
			p15 = getPlayerShip(p15idx)
			if p15 ~= nil and p15:isValid() then
				if p15:isDocked(traitorBase) then
					if p15.traitor == nil then
						if runTransport == nil then
							farthestTransport = transportList[1]
							for _, t in ipairs(transportList) do
								if t:isValid() then
									if distance(traitorBase, t) > distance(traitorBase, farthestTransport) then
										farthestTransport = t
									end
								end
							end
							runTransport = farthestTransport
						end
						p15.traitor = runTransport
						trMsg = "[" .. traitorBaseName .. "] The girl you're looking for is Annette Sporisky. She boarded a freighter owned by her family: " .. runTransport:getCallSign()
						trMsg = trMsg .. ".\nLast we heard, that ship was working in the " .. runTransport:getSectorName() .. " sector."
						p15:addToShipLog(trMsg,"Magenta")
						plotR = sporiskyTransport
						secondaryOrders = string.format("\nGet the spy Annette Sporisky from transport %s and bring her to Vaiken station for questioning",runTransport:getCallSign())
					end
				end
			end
		end
	else
		sporiskyMission = "done"
		plotR = nil
	end
end

function sporiskyTransport(delta)
	if runTransport:isValid() then
		for p16idx=1,8 do
			p16 = getPlayerShip(p16idx)
			if p16 ~= nil and p16:isValid() then
				if p16.traitorBought == true then
					plotR = sporiskyQuestioned
				end
			end
		end
	else
		sporiskyMission = "done"
		plotR = nil
	end
end

function sporiskyQuestioned(delta)
	if stationVaiken:isValid() then
		for p17idx=1,8 do
			p17 = getPlayerShip(p17idx)
			if p17 ~= nil and p17:isValid() then
				if p17:isDocked(stationVaiken) then
					if p17.traitorBought then
						p17:addToShipLog("Annette Sporisky transferred to Vaiken station","Magenta")
						p17:addToShipLog("Spy identified enemy base in sector " .. sporiskyTarget:getSectorName(),"Magenta") 
						secondaryOrders = string.format("\nDestroy enemy base in sector %s",sporiskyTarget:getSectorName())
						plotR = sporiskyEnemyBase
					end
				end
			end
		end
	else
		sporiskyMission = "done"
		plotR = nil
	end
end

function sporiskyEnemyBase(delta)
	if not sporiskyTarget:isValid() then
		requiredMissionCount = requiredMissionCount + 1
		secondaryOrders = ""
		sporiskyMission = "done"
		for p32idx=1,8 do
			p32 = getPlayerShip(p32idx)
			if p32 ~= nil and p32:isValid() and sporiskyRep == nil then
				p32:addReputationPoints(80-(difficulty*5))
				sporiskyRep = "awarded"
			end
		end
		plotR = nil
	end
end
--[[-----------------------------------------------------------------
      Required plot choice: black hole horizon research
-----------------------------------------------------------------]]--
function chooseHorizonParts()
	if hr1part == nil then
		hr1Choice = math.random(3)
		if hr1Choice == 1 then
			hr1part = "communication"
		elseif hr1Choice == 2 then
			hr1part = "lifter"
		else
			hr1part = "repulsor"
		end
	end
	hr2part = "sensor"
end

function horizonOrderMessage(delta)
	if stationEmory:isValid() then
		hMsg = string.format("[Emory] After years or research, we are near a breakthrough on our mobile black hole research. We need some assistance for the next phase. Please bring us some %s and %s type goods.",hr1part,hr2part)
		secondaryOrders = string.format("\nBring %s and %s to station Emory",hr1part,hr2part)
		if horizonMessage == nil then
			for p25idx=1,8 do
				p25 = getPlayerShip(p25idx)
				if p25 ~= nil and p25:isValid() then
					p25:addToShipLog(hMsg,"Magenta")
				end
			end	
			horizonMessage = "done"
		end
		horizonScanRange = 5000 - (difficulty * 200)
		plotR = horizonStationDeliver
	else
		horizonMission = "done"
		plotR = nil
	end
end

function horizonStationDeliver(delta)
	if stationEmory:isValid() then
		for p26idx=1,8 do
			p26 = getPlayerShip(p26idx)
			if p26 ~= nil and p26:isValid() then
				if p26:isDocked(stationEmory) then
					if p26.horizonComponents == "provided" then
						secondaryOrders = "Gather sensor data from black hole by close approach"
						horizonScienceMessageStartTimer = 20
						phScan = p26
						elapsedScanTime = 0
						plotR = horizonScienceMessage					
					end
				end
			end
		end	
	else
		horizonMission = "done"
		plotR = nil
	end
end

function horizonScienceMessage(delta)
	horizonScienceMessageStartTimer = horizonScienceMessageStartTimer - delta
	if horizonScienceMessageStartTimer < 0 then
		if phScan.horizonConsoleMessage ~= "sent" then
			horizonConsoleMessage = "grawp scan instructions"
			phScan:addCustomMessage("Science",horizonConsoleMessage,"When the ship gets close enough, a button to initiate black hole scan will become available. Click it to start scanning the black hole. The ship must remain within scanning distance for a full 30 seconds to complete the scan.")
			phScan.horizonConsoleMessage = "sent"
		end
		if distance(phScan,grawp) < horizonScanRange then
			if scanGrawpButton then
				if scanGrawp then
					if elapsedScanTime == 0 then
						elapsedScanTime = delta
						elapsedScanTimeHalf = delta + 15
						elapsedScanTimeGoal = delta + 30
					else
						elapsedScanTime = elapsedScanTime + delta
					end
					if elapsedScanTime > elapsedScanTimeHalf then
						if phScan.halfScanMessage ~= "sent" then
							phScan:addToShipLog("[Scan technician] Black hole scan 50 percent complete","Blue")
							phScan.halfScanMessage = "sent"
						end
					end
					if elapsedScanTime > elapsedScanTimeGoal then
						phScan:addToShipLog("[Scan technician] Black hole scan complete","Blue")
						phScan:removeCustom(horizonScienceScanButton)
						requiredMissionCount = requiredMissionCount + 1
						secondaryOrders = ""
						horizonMission = "done"
						for p33idx=1,8 do
							p33 = getPlayerShip(p33idx)
							if p33 ~= nil and p33:isValid() and horizonRep == nil then
								p33:addReputationPoints(70-(difficulty*5))
								horizonRep = "awarded"
							end
						end
						plotR = nil
					end
				end
			else
				horizonScienceScanButton = "scan button"
				phScan:addCustomButton("Science",horizonScienceScanButton,"Scan black hole",scanBlackHole)
				scanGrawpButton = true
			end
		else
			if scanGrawpButton then
				phScan:removeCustom(horizonScienceScanButton)
				phScan:addToShipLog("[Scan technician] Black hole scan aborted before completion","Blue")
				phScan.halfScanMessage = "reset"
				elapsedScanTime = 0
				scanGrawp = false
				scanGrawpButton = false
			end
		end
	end
end

function scanBlackHole()
	scanGrawp = true
	phScan:addToShipLog("[Scan technician] Black hole scan started","Blue")
end
--[[-----------------------------------------------------------------
      Optional plot choice: Beam range upgrade
-----------------------------------------------------------------]]--
function chooseBeamRangeParts()
	if br1part == nil then
		br1partChoice = math.floor(random(1,3))
		if br1partChoice == 1 then
			br1part = "gold"
		elseif br1partChoice == 2 then
			br1part = "nickel"
		else
			br1part = "cobalt"
		end
	end
	if br2part == nil then
		br2partChoice = math.floor(random(1,3))
		if br2partChoice == 1 then
			br2part = "lifter"
		elseif br2partChoice == 2 then
			br2part = "filament"
		else
			br2part = "optic"
		end
	end
	if br3part == nil then
		br3partChoice = math.floor(random(1,3))
		if br3partChoice == 1 then
			br3part = "robotic"
		elseif br3partChoice == 2 then
			br3part = "nanites"
		else
			br3part = "battery"
		end
	end
end

function beamRangeMessage(delta)
	optionalOrders = string.format("\nOptional: Gather and bring goods to station Marconi: %s, %s, %s",br1part,br2part,br3part)
	obrMsg = string.format("[Station Marconi] Please bring us some components and materials for a project we are working on: %s, %s, %s",br1part,br2part,br3part)
	for p18idx=1,8 do
		p18 = getPlayerShip(p18idx)
		if p18 ~= nil and p18:isValid() then
			p18:addToShipLog(obrMsg,"Magenta")
		end
	end	
	plotO = beamRangeUpgrade
end

function beamRangeUpgrade(delta)
	if stationMarconi:isValid() then
		for p19idx=1,8 do
			p19 = getPlayerShip(p19idx)
			if p19 ~= nil and p19:isValid() then
				if p19:isDocked(stationMarconi) then
					if p19.beamComponents == "provided" then
						beamRangeUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						beamRangePlot = "done"
						optionalOrders = ""
						for p34idx=1,8 do
							p34 = getPlayerShip(p34idx)
							if p34 ~= nil and p34:isValid() and beamRangeRep == nil then
								p34:addReputationPoints(50-(difficulty*5))
								beamRangeRep = "awarded"
							end
						end
						plotO = nil
					end
				end
			end
		end
	else
		beamRangePlot = "done"
		plotO = nil
	end
end
--[[-----------------------------------------------------------------
      Optional plot choice: Beam damage upgrade
-----------------------------------------------------------------]]--
function beamDamageParts()
	if bd1part == nil then
		bd1partChoice = math.floor(random(1,3))
		if bd1partChoice == 1 then
			bd1part = "platinum"
		elseif bd1partChoice == 2 then
			bd1part = "tritanium"
		else
			bd1part = "dilithium"
		end
	end
	if bd2part == nil then
		bd2partChoice = math.floor(random(1,3))
		if bd2partChoice == 1 then
			bd2part = "sensor"
		elseif bd2partChoice == 2 then
			bd2part = "software"
		else
			bd2part = "android"
		end
	end
	if bd3part == nil then
		bd3partChoice = math.floor(random(1,3))
		if bd3partChoice == 1 then
			bd3part = "circuit"
		elseif bd3partChoice == 2 then
			bd3part = "repulsor"
		else
			bd3part = "transporter"
		end
	end
end

function beamDamageMessage(delta)
	optionalOrders = string.format("\nOptional: Gather and bring goods to station Nefatha: %s, %s, %s",bd1part,bd2part,bd3part)
	obdMsg = string.format("[Station Nefatha] Please bring us some components and materials for a weapons project we are working on: %s, %s, %s",bd1part,bd2part,bd3part)
	for p20idx=1,8 do
		p20 = getPlayerShip(p20idx)
		if p20 ~= nil and p20:isValid() then
			p20:addToShipLog(obdMsg,"Magenta")
		end
	end	
	plotO = beamDamageUpgrade
end

function beamDamageUpgrade(delta)
	if stationNefatha:isValid() then
		for p21idx=1,8 do
			p21 = getPlayerShip(p21idx)
			if p21 ~= nil and p21:isValid() then
				if p21:isDocked(stationNefatha) then
					if p21.beamDamageComponents == "provided" then
						beamDamageUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						beamDamagePlot = "done"
						optionalOrders = ""
						for p35idx=1,8 do
							p35 = getPlayerShip(p35idx)
							if p35 ~= nil and p35:isValid() and beamDamageRep == nil then
								p35:addReputationPoints(50-(difficulty*5))
								beamDamageRep = "awarded"
							end
						end
						plotO = nil
					end
				end
			end
		end
	else
		beamDamagePlot = "done"
		plotO = nil
	end
end
--[[-----------------------------------------------------------------
      Optional plot choice: Spin upgrade - maneuver
-----------------------------------------------------------------]]--
function chooseSpinBaseParts()
	if sp1part == nil then
		sp1partChoice = math.random(3)
		if sp1partChoice == 1 then
			sp1part = "platinum"
		elseif sp1partChoice == 2 then
			sp1part = "dilithium"
		else
			sp1part = "gold"
		end
	end
	if sp2part == nil then
		sp2partChoice = math.random(3)
		if sp2partChoice == 1 then
			sp2part = "tractor"
		elseif sp2partChoice == 2 then
			sp2part = "transporter"
		else
			sp2part = "impulse"
		end
	end
	if sp3part == nil then
		sp3partChoice = math.random(3)
		if sp3partChoice == 1 then
			sp3part = "battery"
		elseif sp3partChoice == 2 then
			sp3part = "android"
		else
			sp3part = "robotic"
		end
	end
	if spinBase == nil then
		spinBaseChoice = math.random(3)
		if spinBaseChoice == 1 then
			if stationCalifornia:isValid() then
				spinBase = stationCalifornia
			elseif stationScience2:isValid() then
				spinBase = stationScience2
			else
				spinBase = stationOutpost33
			end
		elseif spinBaseChoice == 2 then
			if stationScience2:isValid() then
				spinBase = stationScience2
			elseif stationOutpost33:isValid() then
				spinBase = stationOutpost33
			else
				spinBase = stationCalifornia
			end
		else
			if stationOutpost33:isValid() then
				spinBase = stationOutpost33
			elseif stationCalifornia:isValid() then
				spinBase = stationCalifornia
			else
				spinBase = stationScience2
			end
		end
	end
end

function spinMessage(delta)
	optionalOrders = string.format("\nOptional: Bring %s, %s and %s to station %s in sector %s",sp1part,sp2part,sp3part,spinBase:getCallSign(),spinBase:getSectorName())
	spMsg = string.format("[Station %s, sector %s] Please bring us some goods to help us with a project: %s, %s, %s",spinBase:getCallSign(),spinBase:getSectorName(),sp1part,sp2part,sp3part)
	for p28idx=1,8 do
		p28 = getPlayerShip(p28idx)
		if p28 ~= nil and p28:isValid() then
			p28:addToShipLog(spMsg,"Magenta")
		end
	end
	plotO = spinUpgrade
end

function spinUpgrade(delta)
	if spinBase:isValid() then
		for p29idx=1,8 do
			p29 = getPlayerShip(p29idx)
			if p29 ~= nil and p29:isValid() then
				if p29:isDocked(spinBase) then
					if p29.spinComponents == "provided" then
						spinUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						spinPlot = "done"
						optionalOrders = ""
						for p36idx=1,8 do
							p36 = getPlayerShip(p36idx)
							if p36 ~= nil and p36:isValid() and spinRep == nil then
								p36:addReputationPoints(50-(difficulty*5))
								spinRep = "awarded"
							end
						end
						plotO = nil
					end
				end
			end
		end
	else
		spinPlot = "done"
		plotO = nil
	end
end
--[[-----------------------------------------------------------------
      Optional plot choice: Impulse speed upgrade
-----------------------------------------------------------------]]--
function impulseSpeedParts()
	if is1part == nil then
		is1partChoice = math.floor(random(1,3))
		if is1partChoice == 1 then
			is1part = "nickel"
		elseif is1partChoice == 2 then
			is1part = "tritanium"
		else
			is1part = "cobalt"
		end
	end
	if is2part == nil then
		is2partChoice = math.floor(random(1,3))
		if is2partChoice == 1 then
			is2part = "software"
		elseif is2partChoice == 2 then
			is2part = "robotic"
		else
			is2part = "android"
		end
	end
	if morrisonBase == nil then
		morrisonBaseChoice = math.floor(random(1,3))
		if morrisonBaseChoice == 1 then
			morrisonBase = stationResearch11
		elseif morrisonBaseChoice == 2 then
			morrisonBase = stationScience4
		else
			morrisonBase = stationScience2
		end
	end
	morrisonBaseName = morrisonBase:getCallSign()
	morrisonBaseSector = morrisonBase:getSectorName()
end

function impulseSpeedMessage(delta)
	optionalOrders = string.format("\nOptional: Get Nikhil Morrison from station %s in sector %s",morrisonBaseName,morrisonBaseSector)
	oisMsg = string.format("[Station %s] Research scientist Nikhil Morrison is close to a breakthrough on his project, but needs some assistance. Dock with us if you wish to help.",morrisonBaseName)
	for p22idx=1,8 do
		p22 = getPlayerShip(p22idx)
		if p22 ~= nil and p22:isValid() then
			p22:addToShipLog(oisMsg,"Magenta")
		end
	end	
	plotO = impulseSpeedPartMessage
end

function impulseSpeedPartMessage(delta)
	if morrisonBase:isValid() then
		for p23idx=1,8 do
			p23 = getPlayerShip(p23idx)
			if p23 ~= nil and p23:isValid() then
				if p23:isDocked(morrisonBase) then
					if p23.morrison ~= "aboard" then
						p23.morrison = "aboard"
						p23:addToShipLog("Nikhil Morrison is aboard","Magenta")
						p23:addToShipLog(string.format("He requests that you get %s and %s type goods and take him to station Carradine",is1part,is2part),"Magenta")
						optionalOrders = string.format("\nOptional: Get %s and %s and transport Nikhil Morrison to station Carradine",is1part,is2part)
						plotO = impulseSpeedUpgrade
					end
				end
			end
		end
	else
		impulseSpeedPlot = "done"
		plotO = nil
	end
end

function impulseSpeedUpgrade(delta)
	if stationCarradine:isValid() then
		for p24idx=1,8 do
			p24 = getPlayerShip(p24idx)
			if p24 ~= nil and p24:isValid() then
				if p24:isDocked(stationCarradine) then
					if p24.impulseSpeedComponents == "provided" then
						impulseSpeedUpgradeAvailable = true
						optionalMissionDelay = delta + random(30,90)
						impulseSpeedPlot = "done"
						optionalOrders = ""
						for p37idx=1,8 do
							p37 = getPlayerShip(p37idx)
							if p37 ~= nil and p37:isValid() and impulseSpeedRep == nil then
								p37:addReputationPoints(50-(difficulty*5))
								impulseSpeedRep = "awarded"
							end
						end
						plotO = nil
					end
				end
			end
		end
	else
		impulseSpeedPlot = "done"
		plotO = nil
	end
end
--[[-----------------------------------------------------------------
      Optional plot choice: Get quantum biometric artifact
-----------------------------------------------------------------]]--
function quantumArtMessage(delta)
	if stationOrgana:isValid() then
		optionalOrders = string.format("\nOptional: Retrieve artifact with quantum biometric characteristics and bring to station Organa in sector %s",stationOrgana:getSectorName())
		qaMsg = string.format("[Station Organa, sector %s] Research scientist Phillip Solo of the royal research academy finished the theoretical research portion of his dissertation. He needs an artifact with quantum biometric characteristics to apply his research. Please retrieve an artifact with quantum biometric characteristics and bring it to Organa station",stationOrgana:getSectorName())
		for p40idx=1,8 do
			p40 = getPlayerShip(p40idx)
			if p40 ~= nil and p40:isValid() then
				p40:addToShipLog(qaMsg,"Magenta")
			end
		end	
		if art1.quantum then
			artQ = art1
		elseif art2.quantum then
			artQ = art2
		else
			artQ = art3
		end
		quantumArtHintDelay = 60
		plotO = quantumRetrieveArt
	else	-- station Organa destroyed
		plotO = nil
		quantumArtPlot = "done"
	end
end

function quantumRetrieveArt(delta)
	if artQ:isValid() then
		if artQ:isScannedByFaction("Human Navy") then
			artQ:allowPickup(true)
		end
		quantumArtHintDelay = quantumArtHintDelay - delta
		cptad = 999999	-- closest player to artifact distance
		for p41idx=1,8 do
			p41 = getPlayerShip(p41idx)
			if p41 ~= nil and p41:isValid() then
				clpd = distance(artQ,p41)	-- current loop player distance
				if clpd < cptad then
					cptad = clpd
					closestPlayer = p41
				end
			end
		end
		if quantumArtHintDelay < 0 then
			if quantumArtHint == nil then
				closestPlayer:addToShipLog(string.format("[Station Organa] We just received a report that an artifact with quantum biometric characteristics may have been observed in sector %s",artQ:getSectorName()),"Magenta")
				quantumArtHint = "delivered"
			end
		end
		for p42idx=1,8 do
			p42 = getPlayerShip(p42idx)
			if p42 ~= nil and p42:isValid() then
				if p42 == closestPlayer then
					p42.artQ = true
				else
					p42.artQ = false
				end
			end
		end
	else
		plotO = quantumDeliverArt
	end
end

function quantumDeliverArt(delta)
	if stationOrgana:isValid() then
		for p44idx=1,8 do
			p44 = getPlayerShip(p44idx)
			if p44.artQ then
				if p44.artQaboardMessage == nil then
					p44:addToShipLog("Artifact is aboard","Magenta")
					p44.artQaboardMessage = "sent"
				end
				if p44:isDocked(stationOrgana) then
					p44:addToShipLog("[Phillip Organa] Thanks for the artifact. I completed my research. Next time you dock with Vaiken, you can improve your shield effectiveness.","Magenta")
					shieldUpgradeAvailable = true
					p44:addReputationPoints(50-(difficulty*5))
					quantumArtPlot = "done"
					plotO = nil
				end
			end
		end
	else
		quantumArtPlot = "done"
		plotO = nil
	end
end

function update(delta)
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if playWithTimeLimit then
		gameTimeLimit = gameTimeLimit - delta
		if gameTimeLimit < 0 then
			showGameEndStatistics()
			if requiredMissionCount > 0 and plotR == nil then
				victory("Human Navy")
			else
				victory("Kraylor")
			end
		end
		-- select required mission
		if plotR == nil then
			-- timed missions
			requiredMissionChoice = math.random(4)
			if requiredMissionChoice == 1 then
				if undercutMission ~= "done" and undercutLocation ~= "free" and gameTimeLimit < 2670 and gameTimeLimit > 2400 then
					mPart = 1
					plotR = undercutOrderMessage
					chooseUndercutBase()
				end
			elseif requiredMissionChoice == 2 then
				if stettorMission ~= "done" and gameTimeLimit < 2670 and gameTimeLimit > 1800 then
					chooseSensorBase()
					chooseSensorParts()
					plotR = stettorOrderMessage
				end
			elseif requiredMissionChoice == 3 then
				if horizonMission ~= "done" and gameTimeLimit < 2670 and gameTimeLimit > 1200 then
					chooseHorizonParts()
					plotR = horizonOrderMessage
				end
			else
				if sporiskyMission ~= "done" and gameTimeLimit < 2670 and gameTimeLimit > 1700 then
					chooseTraitorBase()
					plotR = traitorOrderMessage
				end
			end
		end
	else
		clueMessageDelay = clueMessageDelay - delta
		if clueMessageDelay < 0 then
			if clueMessage ~= "delivered" then
				clMsg = "Intelligence has analyzed all the enemy activity in this area and has determined that there must be three enemy bases. Find these bases and destroy them."
				enemyBaseCount = 0
				if stationEmpok:isValid() then
					enemyBaseCount = enemyBaseCount + 1
				end
				if stationTic:isValid() then
					enemyBaseCount = enemyBaseCount + 1
				end
				if stationGanalda:isValid() then
					enemyBaseCount = enemyBaseCount + 1
				end
				if enemyBaseCount == 1 then
					clMsg = clMsg .. " You have already destroyed two of them."
				elseif enemyBaseCount == 2 then
					clMsg = clMsg .. " You have already destroyed one of them."
				end
				primaryOrders = "Defend bases in the area (human navy and independent) from enemy attack and destroy three enemy bases."
				for p43idx=1,8 do
					p43 = getPlayerShip(p43idx)
					if p43 ~= nil and p43:isValid() then
						p43:addToShipLog(clMsg,"Magenta")
					end
				end
				clueMessage = "delivered"
			end
		end
		if plotR == nil then
			requiredMissionDelay = requiredMissionDelay - delta
			if requiredMissionCount > 0 and not stationEmpok:isValid() and not stationTic:isValid() and not stationGanalda:isValid() then
				showGameEndStatistics()
				victory("Human Navy")
			end
			if requiredMissionDelay < 0 then
				requiredMissionChoice = math.random(4)
				if requiredMissionChoice == 1 then
					if undercutMission ~= "done" and undercutLocation ~= "free" then
						plotR = undercutOrderMessage
						chooseUndercutBase()
					end
				elseif requiredMissionChoice == 2 then
					if stettorMission ~= "done" then
						chooseSensorBase()
						chooseSensorParts()
						plotR = stettorOrderMessage
					end
				elseif requiredMissionChoice == 3 then
					if horizonMission ~= "done" then
						chooseHorizonParts()
						plotR = horizonOrderMessage
					end				
				else
					if sporiskyMission ~= "done" then
						chooseTraitorBase()
						plotR = traitorOrderMessage
					end
				end
				requiredMissionDelay = delta + random(10,30)
			end
		end
	end
	-- select optional mission
	if plotO == nil then
		optionalMissionDelay = optionalMissionDelay - delta
		if optionalMissionDelay < 0 then
			optionalMissionChoice = math.random(5)
			if optionalMissionChoice == 1 then
				if beamRangePlot ~= "done" then
					chooseBeamRangeParts()
					plotO = beamRangeMessage
				end
			elseif optionalMissionChoice == 2 then
				if impulseSpeedPlot ~= "done" then
					impulseSpeedParts()
					plotO = impulseSpeedMessage
				end
			elseif optionalMissionChoice == 3 then
				if spinPlot ~= "done" then
					chooseSpinBaseParts()
					plotO = spinMessage
				end
			elseif optionalMissionChoice == 4 then
				if quantumArtPlot ~= "done" then
					plotO = quantumArtMessage
				end
			else
				if beamDamagePlot ~= "done" then
					chooseBeamDamageParts()
					plotO = beamDamageMessage
				end
			end
			optionalMissionDelay = delta + random(20,40)
		end
	end
	if plotR ~= nil then
		plotR(delta)	--required mission
	end
	if plotO ~= nil then
		plotO(delta)	--optional mission
	end
	if plotA ~= nil then
		plotA(delta)	--asteroids
	end
	if plotB ~= nil then
		plotB(delta)	--black hole
	end
	if plotT ~= nil then
		plotT(delta)	--transports
	end
	if plotW ~= nil then
		plotW(delta)	--waves
	end
	if plotH ~= nil then
		plotH(delta)	--help warning
	end
end