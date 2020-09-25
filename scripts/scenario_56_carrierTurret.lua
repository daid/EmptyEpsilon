-- Name: Carriers and turrets
-- Description: Three player ships: a carrier and two smaller ships docked with the carrier. Objective: search out and find the enemy. Use the carrier to travel long distances.
---
--- Carrier and several player ships with turrets available for use by the players made available with this scenario script and the associated files.
-- Type: Mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Very Easy]: Very Easy goals and/or enemies

-- If you find that your crew cannot resist the do not push button,
-- change "plot4 = doNotPush" to "plot4 = nil" in this scenario file

-- typical colors used in ship log
-- 	"Red"			Red									Enemies spotted
--	"Blue"			Blue
--	"Yellow"		Yellow								
--	"Magenta"		Magenta								Headquarters
--	"Green"			Green
--	"Cyan"			Cyan
--	"Black"			Black
--	"#555555"		Dark gray			"55,55,55"
--	"#ff4500"		Orange red			"255,69,0"		
--	"#ff7f50"		Coral				"255,127,80"	
--	"#5f9ea0"		Cadet blue			"95,158,160"	scientist station
--	"#4169e1"		Royal blue			"65,105,225"	
--	"#8a2be2"		Blue violet			"138,43,226"	doctor station
--	"#ba55d3"		Medium orchid		"186,85,211"	
--	"#a0522d"		Sienna				"160,82,45"		
--	"#b29650"		Arbitrary			"178,150,80"	repair station
--	"#556b2f"		Dark olive green	"85,107,47"		tractor ship
--	"#228b22"		Forest green		"34,139,34"
--	"#b22222"		Firebrick			"178,34,34"

require("utils.lua")

function init()
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Cruiser","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	difficulty = 1
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
	GMDiagnosticOn = "Turn On Diagnostic"
	addGMFunction(GMDiagnosticOn,turnOnDiagnostic)
	interWave = 280				
	GMDelayNormalToSlow = "Delay normal to slow"
	addGMFunction(GMDelayNormalToSlow,delayNormalToSlow)
	goods = {}
	stationList = {}
	friendlyStationList = {}
	enemyStationList = {}
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
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
	highestConcurrentPlayerCount = 0
	setConcurrentPlayerCount = 0
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	transportList = {}
	transportSpawnDelay = 10
	plotT = transportPlot
	plotC = cargoTransfer
	plotH = healthCheck
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	healthCheckCount = 0
	missionLength = 1
	initialOrderTimer = 3
	plot1 = initialOrders
	startx = 0
	starty = 0
	offsetList = getObjectsInRadius(startx,starty,1500)
	if #offsetList > 0 then
		repeat
			jx, jy = vectorFromAngle(random(0,360),1600)
			nox, noy = offsetList[1]:getPosition()
			startx = nox+jx
			starty = noy+jy
			offsetList = getObjectsInRadius(startx,starty,1500)
		until(#offsetList < 1)
	end
	if math.random() < .5 then
		playerCarrier = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Benedict")
	else
		playerCarrier = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Kiriya")
	end
	playerCarrier:setPosition(startx,starty):setRotation(-90):commandTargetRotation(-90)
	if diagnostic then		--make carrier ridiculously powerful for mission diagnostic test purposes
		playerCarrier:setBeamWeapon(0, 10,   0, 1500.0, 1.0, 104):setBeamWeapon(1, 10, 180, 1500.0, 1.0, 104):setBeamWeaponHeatPerFire(0,playerCarrier:getBeamWeaponHeatPerFire(0)*.01):setBeamWeaponHeatPerFire(1,playerCarrier:getBeamWeaponHeatPerFire(1)*.01)
		playerCarrier:setBeamWeaponTurret(0,270,0,6):setBeamWeaponTurret(1,270,180,6):setBeamWeaponEnergyPerFire(0,1):setBeamWeaponEnergyPerFire(1,1)
	end
	if math.random() < .5 then
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Striker"):setJumpDrive(false):setWarpDrive(false)
		playerBlade:setPosition(startx-240,starty):commandDock(playerCarrier):setRotation(-180):commandTargetRotation(-180)
	else
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Repulse"):setJumpDrive(false):setWarpDrive(false)
		playerBlade:setPosition(startx-240,starty):commandDock(playerCarrier):setRotation(-180):commandTargetRotation(-180)
	end
	if math.random() < .5 then
		playerPoint = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Piranha"):setJumpDrive(false):setWarpDrive(false)
		playerPoint:setPosition(startx+175,starty):commandDock(playerCarrier):setRotation(0):commandTargetRotation(0)
	else
		playerPoint = PlayerSpaceship():setFaction("Human Navy"):setTemplate("ZX-Lindworm"):setJumpDrive(false):setWarpDrive(false)
		playerPoint:setPosition(startx+175,starty):commandDock(playerCarrier):setRotation(0):commandTargetRotation(0)
	end
	plotH = healthCheck
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	healthCheckCount = 0
	setMovingAsteroids()
	plot2choices = {}
	table.insert(plot2choices,upgradeShipSpin)
	table.insert(plot2choices,locateTargetEnemyBase)
	table.insert(plot2choices,rescueDyingScientist)
	GMStartPlot2upgradeShipSpin = "P2 upgrade spin"
	GMStartPlot2locateTargetEnemyBase = "P2 locate enemy base"
	GMStartPlot2rescueDyingScientist = "P2 rescue scientist"
	addGMFunction(GMStartPlot2upgradeShipSpin,gmPlot2upgradeShipSpin)
	addGMFunction(GMStartPlot2locateTargetEnemyBase,gmPlot2locateEnemyBase)
	addGMFunction(GMStartPlot2rescueDyingScientist,gmPlot2rescueDyingScientist)
	plot3choices = {}
	table.insert(plot3choices,upgradeBeamDamage)
	table.insert(plot3choices,tractorDisabledShip)
	table.insert(plot3choices,addTubeToShip)
	GMStartPlot3upgradeBeamDamage = "P3 upgrade beam dmg"
	GMStartPlot3tractorDisabledShip = "P3 tractor ship"
	GMStartPlot3addTubeToShip = "P3 add tube"
	addGMFunction(GMStartPlot3upgradeBeamDamage,gmPlot3upgradeBeamDamage)
	addGMFunction(GMStartPlot3tractorDisabledShip,gmPlot3tractorDisabledShip)
	addGMFunction(GMStartPlot3addTubeToShip,gmPlot3addTubeToShip)
	--plot 4 choices will come eventually, just not with this release
	wfv = "end of init"
end
--plot based GM functions
function gmPlot2upgradeShipSpin()
	nextPlot2 = upgradeShipSpin
	removeGMFunction(GMStartPlot2upgradeShipSpin)
end
function gmPlot2locateEnemyBase()
	nextPlot2 = locateTargetEnemyBase
	removeGMFunction(GMStartPlot2locateTargetEnemyBase)
end
function gmPlot2rescueDyingScientist()
	nextPlot2 = rescueDyingScientist
	removeGMFunction(GMStartPlot2rescueDyingScientist)
end
function gmPlot3upgradeBeamDamage()
	nextPlot3 = upgradeBeamDamage
	removeGMFunction(GMStartPlot3upgradeBeamDamage)
end
function gmPlot3tractorDisabledShip()
	nextPlot3 = tractorDisabledShip
	removeGMFunction(GMStartPlot3tractorDisabledShip)
end
function gmPlot3addTubeToShip()
	nextPlot3 = addTubeToShip
	removeGMFunction(GMStartPlot3addTubeToShip)
end
-- Let the GM spawn a random group of enemies to attack a player
function GMSpawnsEnemies()
	gmPlayer = nil
	gmSelected = false
	gmSelect = getGMSelection()
	for _, obj in ipairs(gmSelect) do
		if obj.typeName == "PlayerSpaceship" then
			gmPlayer = obj
			break
		end
	end
	if gmPlayer == nil then
		gmPlayer = closestPlayerTo(targetEnemyStation)
	end
	px, py = gmPlayer:getPosition()
	sx, sy = vectorFromAngle(random(0,360),random(20000,30000))
	ntf = spawnEnemies(px+sx,py+sy,dangerValue,targetEnemyStation:getFaction())
	for _, enemy in ipairs(ntf) do
		enemy:orderAttack(gmPlayer)
	end
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
	interwave = 20
	removeGMFunction(GMDelaySlowToFast)
	GMDelayFastToNormal = "Delay fast to normal"
	addGMFunction(GMDelayFastToNormal,delayFastToNormal)
end
function delayFastToNormal()
	interwave = 280
	removeGMFunction(GMDelayFastToNormal)
	GMDelayNormalToSlow = "Delay normal to slow"
	addGMFunction(GMDelayNormalToSlow,delayNormalToSlow)
end
--translate variations into a numeric difficulty value
function setVariations()
	if string.find(getScenarioVariation(),"Very Easy") then
		difficulty = .2
	elseif string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1
	end
	gameTimeLimit = 0
	if string.find(getScenarioVariation(),"Timed") then
		timedIntelligenceInterval = 200
		playWithTimeLimit = true
		gameTimeLimit = 30*60
		plot6 = timedGame
	else
		timedIntelligenceInterval = 300
		playWithTimeLimit = false
	end
end

function setMovingAsteroids()
	movingAsteroidList = {}
	for aidx=1,30 do
		xAst = random(-100000,100000)
		yAst = random(-100000,100000)
		mAst = Asteroid():setPosition(xAst,yAst)
		mAst.angle = random(0,360)
		mAst.travel = random(40,220)
		if random(1,100) < 85 then
			mAst.curve = 0
		else
			mAst.curve = math.random()*.16 - .08
		end
		table.insert(movingAsteroidList,mAst)
	end
	plotA = moveAsteroids
end

function moveAsteroids(delta)
	movingAsteroidCount = 0
	for aidx, aObj in ipairs(movingAsteroidList) do
		if aObj:isValid() then
			movingAsteroidCount = movingAsteroidCount + 1
			mAstx, mAsty = aObj:getPosition()
			if mAstx < -150000 or mAstx > 150000 or mAsty < -150000 or mAsty > 150000 then
				aObj.angle = random(0,360)
				if random(1,100) < 85 then
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
-- Organically (simulated asymetrically) grow stations from a central grid location
-- Order of creation: friendlies, neutrals, generic enemies, leading enemies
-- Statistically, the enemy stations typically end up on the edge, a fair distance away, but not always
function buildStations()
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
	sPool = #placeStation		--starting station pool size (friendly and neutral)
	adjList = {}				--adjacent space on grid location list
	--place friendly stations
	stationFaction = "Human Navy"
	for j=1,12 do
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
			if random(1,5) >= 2 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()				--place selected station
		table.remove(placeStation,si)				--remove station from placement list
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(friendlyStationList,pStation)	--save station in friendly station list
		if j == 1 then								--identify first station as home station
			homeStation = pStation
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place independent stations
	stationFaction = "Independent"
	fb = gp	--set faction boundary (between friendly and neutral)
	for j=1,30 do
		tSize = math.random(3,6)	--tack on to region size
		grid[gx][gy] = gp
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getFactionAdjacentGridLocations(gx,gy)	
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		else
			nextStationChoice = random(1,5)
			if nextStationChoice >= 3 then
				adjList = getFactionAdjacentGridLocations(gx,gy)
				if #adjList < 1 then
					adjList = getAllAdjacentGridLocations(gx,gy)
				end
			elseif nextStationChoice <= 2 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		si = math.random(1,#placeStation)			--station index
		pStation = placeStation[si]()
		table.remove(placeStation,si)
		table.insert(stationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place enemy stations (from generic pool)
	stationFaction = "Ktlitans"
	fb = gp	--set faction boundary (between neutral and enemy)
	for j=1,5 do
		tSize = math.random(4,7)	--tack on to region size
		grid[gx][gy] = gp
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getFactionAdjacentGridLocations(gx,gy)	
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		else
			if random(1,5) >= 3 then
				adjList = getFactionAdjacentGridLocations(gx,gy)
				if #adjList < 1 then
					adjList = getAllAdjacentGridLocations(gx,gy)
				end
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		si = math.random(1,#placeGenericStation)			--station index
		pStation = placeGenericStation[si]()
		if diagnostic then
			pStation:setCallSign(pStation:getCallSign() .. string.format(" %i",j))
		end
		table.remove(placeGenericStation,si)
		table.insert(enemyStationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place enemy stations (from enemy pool)
	stationFaction = "Ktlitans"
	fb = gp	--set faction boundary (between enemy and enemy leadership)
	for j=1,2 do
		tSize = math.random(4,9)	--tack on to region size
		grid[gx][gy] = gp
		gRegion = {}				--grow region
		table.insert(gRegion,{gx,gy})
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				break
			end
			rd = math.random(1,#adjList)	--random direction to grow from adjacent list
			grid[adjList[rd][1]][adjList[rd][2]] = gp
			table.insert(gRegion,{adjList[rd][1],adjList[rd][2]})
		end
		--get list after done growing region
		adjList = getAdjacentGridLocations(gx,gy)
		if #adjList < 1 then
			adjList = getFactionAdjacentGridLocations(gx,gy)	
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		else
			if random(1,5) >= 3 then
				adjList = getFactionAdjacentGridLocations(gx,gy)
				if #adjList < 1 then
					adjList = getAllAdjacentGridLocations(gx,gy)
				end
			end
		end
		sri = math.random(1,#gRegion)				--select station random region index
		psx = (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
		psy = (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
		si = math.random(1,#placeEnemyStation)			--station index
		pStation = placeEnemyStation[si]()
		table.remove(placeEnemyStation,si)
		table.insert(enemyStationList,pStation)
		if j == 2 then					--identify last placed enemy station as target enemy station
			targetEnemyStation = pStation
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	if not diagnostic then
		placeRandomAroundPoint(Nebula,math.random(10,30),1,150000,0,0)
	end
	fx, fy = homeStation:getPosition()
	ex, ey = targetEnemyStation:getPosition()
	mnx = (fx+ex)/2
	mny = (fy+ey)/2
	Nebula():setPosition(mnx,mny)
	startingFriendlyStations = #friendlyStationList
	startingNeutralStations = #stationList - #friendlyStationList
	startingEnemyStations = #enemyStationList
	originalStationList = stationList	--save for statistics
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
--Randomly choose station size template unless overridden
function szt()
	if stationSize ~= nil then
		sizeTemplate = stationSize
		stationSize = nil
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
	stationMaverick:setPosition(psx,psy):setCallSign("Maverick"):setDescription("Gambling and resupply")
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
			if random(1,100) < 20 then
				tFaction = "Human Navy"
			else
				tFaction = "Independent"
			end
			obj = CpuShip():setTemplate(name):setFaction(tFaction):setCommsScript(""):setCommsFunction(commsShip)
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
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format("\n   %i Minutes remain in game",math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply("Back", commsStation)
		end)
		if random(1,5) <= (3 - difficulty) then
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
		if random(1,5) <= (3 - difficulty) then
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
	if plot2name == "spinScientist" then
		if comms_target == spinScientistStation  and not spinUpgradeAvailable then
			addCommsReply("Speak with Paulina Lindquist", function()
				setCommsMessage(string.format("Greetings, %s, what can I do for you?",player:getCallSign()))
				addCommsReply("Do you want to apply your engine research?", function()
					setCommsMessage("Over the years, I've discovered that research does not pay very well. Do you have some kind of compensation in mind? Gold, platinum or luxury would do nicely")
					gi = 1
					giftQuantity = 0
					repeat
						if goods[player][gi][1] == "gold" then
							giftQuantity = giftQuantity + goods[player][gi][2]
						end
						if goods[player][gi][1] == "platinum" then
							giftQuantity = giftQuantity + goods[player][gi][2]
						end
						if goods[player][gi][1] == "luxury" then
							giftQuantity = giftQuantity + goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if giftQuantity > 0 then
						addCommsReply("Offer compensation from cargo aboard", function()
							gi = 1
							giftList = {}
							repeat
								if goods[player][gi][1] == "gold" and goods[player][gi][2] > 0 then
									table.insert(giftList,"gold")
								end
								if goods[player][gi][1] == "platinum" and goods[player][gi][2] > 0 then
									table.insert(giftList,"platinum")
								end
								if goods[player][gi][1] == "luxury" and goods[player][gi][2] > 0 then
									table.insert(giftList,"luxury")
								end
								gi = gi + 1
							until(gi > #goods[player])
							gifti = math.random(1,#giftList)
							decrementPlayerGoods(giftList[gifti])
							player.cargo = player.cargo + 1
							setCommsMessage(string.format("Thanks for the %s. I've transmitted instructions on conducting the upgrade. Any friendly station can do the upgrade, but you'll need to provide impulse cargo for the upgrade",giftList[gifti]))
							spinUpgradeAvailable = true
							plot2reminder = "Get spin upgrade from friendly station for impulse"
						end)
					end
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		end
	end
	if plot3name == "tubeOfficer" then
		if comms_target == addTubeStation then
			gi = 1
			tubePartQuantity = 0
			repeat
				if goods[player][gi][1] == tubePart then
					tubePartQuantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if tubePartQuantity > 0 then
				addCommsReply(string.format("Give %s to Boris Eggleston for additional tube",tubePart), function()
					if player.tubeAdded then
						setCommsMessage("You already have the extra tube")
					else
						setCommsMessage("I can install it point to the front or to the rear. Which would you prefer?")
						addCommsReply("Front", function()
							decrementPlayerGoods(tubePart)
							player.cargo = player.cargo + 1
							player.tubeAdded = true
							originalTubes = player:getWeaponTubeCount()
							newTubes = originalTubes + 1
							player:setWeaponTubeCount(newTubes)
							player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
							player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
							setCommsMessage("You now have an additional homing torpedo tube pointing forward")
						end)
						addCommsReply("Rear", function()
							decrementPlayerGoods(tubePart)
							player.cargo = player.cargo + 1
							player.tubeAdded = true
							originalTubes = player:getWeaponTubeCount()
							newTubes = originalTubes + 1
							player:setWeaponTubeCount(newTubes)
							player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
							player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
							player:setWeaponTubeDirection(originalTubes, 180)
							setCommsMessage("You now have an additional homing torpedo tube pointing to the rear")
						end)
					end
				end)
			else
				addCommsReply("May I speak with Boris Eggleston?", function()
					setCommsMessage("[Boris Eggleston]\nHello, what can I do for you?")
					addCommsReply("Can you really add another weapons tube to our ship?", function()
						setCommsMessage(string.format("Definitely. But I'll need %s before I can do it",tubePart))
						addCommsReply("Back",commsStation)
					end)
				end)
			end
		end
	end
	if plot3name == "beamPhysicist" then
		if comms_target == beamDamageStation then
			gi = 1
			beamPart1Quantity = 0
			beamPart2Quantity = 0
			repeat
				if goods[player][gi][1] == beamPart1 then
					beamPart1Quantity = goods[player][gi][2]
				end
				if goods[player][gi][1] == beamPart2 then
					beamPart2Quantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if beamPart1Quantity > 0 and beamPart2Quantity > 0 then
				addCommsReply(string.format("Give %s and %s to Frederico Booker for upgrade",beamPart1,beamPart2), function()
					if player.beamDamageUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						if player:getBeamWeaponRange(0) > 0 then
							decrementPlayerGoods(beamPart1)
							decrementPlayerGoods(beamPart2)
							player.cargo = player.cargo + 2
							bi = 0	--beam index
							repeat
								tempArc = player:getBeamWeaponArc(bi)
								tempDir = player:getBeamWeaponDirection(bi)
								tempRng = player:getBeamWeaponRange(bi)
								tempCyc = player:getBeamWeaponCycleTime(bi)
								tempDmg = player:getBeamWeaponDamage(bi)
								player:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.5)
								bi = bi + 1
							until(player:getBeamWeaponRange(bi) < 1)
							player.beamDamageUpgrade = true
							setCommsMessage("Your ship beam weapons now deal 50% more damage")
						else
							setCommsMessage("Your ship has no beam weapons to upgrade")
						end
					end
				end)
			else
				addCommsReply("Talk to Frederico Booker", function()
					setCommsMessage(string.format("[Frederico Booker]\nGreetings, %s. What brings you to %s to talk to me?",player:getCallSign(),beamDamageStation:getCallSign()))
					addCommsReply("Can you upgrade our beam weapons systems?", function()
						setCommsMessage(string.format("[Frederico Booker]\nOh, you've heard about my research and the practical results? I can certainly upgrade the damage dealt by your beam weapons systems, but you'll need to provide me with %s and %s before I can complete the job",beamPart1,beamPart2))
						addCommsReply("Back", commsStation)
					end)
				end)
			end
		end
	end
	if plot2name == "friendlyClue" then
		if comms_target == friendlyClueStation then
			addCommsReply("Speak with Herbert Long", function()
				setCommsMessage(string.format("Well, if it isn't the good ship, %s! What brings you to %s?",player:getCallSign(),friendlyClueStation:getCallSign()))
				addCommsReply("Please share your enemy base information", function()
					setCommsMessage(string.format("That's old news. Wouldn't you rather know about %s's leadership woes or the latest readings on unique stellar phenomenae in the area?",friendlyClueStation:getCallSign()))
					addCommsReply("No, I just want to know about the enemy base", function()
						setCommsMessage(string.format("Well, that's easy. The name of the base is %s. Enjoy your stay on %s!",targetEnemyStation:getCallSign(),friendlyClueStation:getCallSign()))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply(string.format("What is %s struggling with?",friendlyClueStation:getCallSign()), function()
						setCommsMessage(string.format("There are so many requests for transfers, %s may be understaffed by next week",friendlyClueStation:getCallSign()))
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("What kind of unique stellar phenomenae?", function()
						setCommsMessage(string.format("While we were in %s spying on %s, we picked up readings in a nebula hinting at the formation of a new star",targetEnemyStation:getSectorName(),targetEnemyStation:getCallSign()))
						primaryOrders = string.format("Destroy enemy station %s in %s",targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName())
						betweenPlot2fleet()
					end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		end
	end
	if spinUpgradeAvailable and player:isFriendly(comms_target) then
		gi = 1
		impulseQuantity = 0
		repeat
			if goods[player][gi][1] == "impulse" then
				impulseQuantity = goods[player][gi][2]
			end
			gi = gi + 1
		until(gi > #goods[player])
		if impulseQuantity > 0 then
			addCommsReply("Upgrade ship maneuverability for impulse", function()
				if player.spinUpgrade then
					setCommsMessage("You already have the upgrade")
				else
					player.spinUpgrade = true
					decrementPlayerGoods("impulse")
					player.cargo = player.cargo + 1
					player:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
					setCommsMessage("Maneuverability upgraded by 50%")
				end
				addCommsReply("Back", commsStation)
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
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p == comms_target and player:isDocked(p) and p.cargo > 0 then
					addCommsReply(string.format("Transfer cargo to %s",p:getCallSign()), function()
						setCommsMessage("What would you like to transfer?")
						gi = 1
						repeat
							local goodsType = goods[player][gi][1]
							local goodsQuantity = goods[player][gi][2]
							if goodsQuantity > 0 then
								addCommsReply(goodsType, function()
									decrementPlayerGoods(goodsType)
									local gi2 = 1
									repeat
										if goods[p][gi2][1] == goodsType then
											goods[p][gi2][2] = goods[p][gi2][2] + 1
										end
										gi2 = gi2 + 1
									until(gi2 > #goods[p])
									player.cargo = player.cargo + 1
									p.cargo = p.cargo - 1
									setCommsMessage(string.format("One %s transferred to %s",goodsType,p:getCallSign()))
									p:addToShipLog(string.format("One %s transferred from %s",goodsType,player:getCallSign()),"#228b22")
									addCommsReply("Back", commsStation)
								end)
							end
							gi = gi + 1
						until(gi > #goods[player])
					end)
					break
				end
			end
		end
	end
end

function setOptionalOrders()
	optionalOrders = "\n"
	ifs = "Optional:\n"
	if plot2reminder ~= nil then
		optionalOrders = optionalOrders .. ifs .. plot2reminder
		ifs = "\n"
	end
	if plot3reminder ~= nil then
		optionalOrders = optionalOrders .. ifs .. plot3reminder
		ifs = "\n"
	end
	if plot4reminder ~= nil then
		optionalOrders = optionalOrders .. ifs .. plot4reminder
		ifs = "\n"
	end
	if plot5reminder ~= nil then
		optionalOrders = optionalOrders .. ifs .. plot5reminder
		ifs = "\n"
	end
	if plot6reminder ~= nil then
		optionalOrders = optionalOrders .. ifs .. plot6reminder
		ifs = "\n"
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
	setCommsMessage(oMsg)
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
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
			addCommsReply("Back", commsStation)
		end)
		if spinUpgradeAvailable and player:isFriendly(comms_target) and distance(player,comms_target) < 1000 then
			gi = 1
			impulseQuantity = 0
			repeat
				if goods[player][gi][1] == "impulse" then
					impulseQuantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if impulseQuantity > 0 then
				addCommsReply("Upgrade ship maneuverability for impulse", function()
					if player.spinUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						player.spinUpgrade = true
						decrementPlayerGoods("impulse")
						player.cargo = player.cargo + 1
						player:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
						setCommsMessage("Maneuverability upgraded by 50%")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if plot3name == "awaitingTractor" then
		if comms_target == tractorStation and player == playerCarrier and distance(player,comms_target) < 2000 then
			addCommsReply("Install tractor equipment", function()
				if playerCarrier:hasPlayerAtPosition("Engineering") then
					tractorIntegrationMsg = "tractorIntegrationMsg"
					playerCarrier:addCustomMessage("Engineering",tractorIntegrationMsg,string.format("The tractor equipment has been transported aboard %s. You need to make the final connections for full installation",playerCarrier:getCallSign()))
				end
				if playerCarrier:hasPlayerAtPosition("Engineering+") then
					tractorIntegrationMsgPlus = "tractorIntegrationMsgPlus"
					playerCarrier:addCustomMessage("Engineering+",tractorIntegrationMsgPlus,string.format("The tractor equipment has been transported aboard %s. You need to make the final connections for full installation",playerCarrier:getCallSign()))
				end
				tractorIntegrationButton = "tractorIntegrationButton"
				playerCarrier:addCustomButton("Engineering",tractorIntegrationButton,"Connect Tractor",connectTractor)
				tractorIntegrationButtonPlus = "tractorIntegrationButtonPlus"
				playerCarrier:addCustomButton("Engineering+",tractorIntegrationButtonPlus,"Connect Tractor",connectTractor)
				setCommsMessage("Tractor equipment transferred to engine room")
			end)
		end
	end
	if plot3name == "tubeOfficer" then
		if comms_target == addTubeStation and distance(player,comms_target) < 1200 then
			gi = 1
			tubePartQuantity = 0
			repeat
				if goods[player][gi][1] == tubePart then
					tubePartQuantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if tubePartQuantity > 0 then
				addCommsReply(string.format("Give %s to Boris Eggleston for additional tube",tubePart), function()
					if player.tubeAdded then
						setCommsMessage("You already have the extra tube")
					else
						setCommsMessage("I can install it point to the front or to the rear. Which would you prefer?")
						addCommsReply("Front", function()
							decrementPlayerGoods(tubePart)
							player.cargo = player.cargo + 1
							player.tubeAdded = true
							originalTubes = player:getWeaponTubeCount()
							newTubes = originalTubes + 1
							player:setWeaponTubeCount(newTubes)
							player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
							player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
							setCommsMessage("You now have an additional homing torpedo tube pointing forward")
						end)
						addCommsReply("Rear", function()
							decrementPlayerGoods(tubePart)
							player.cargo = player.cargo + 1
							player.tubeAdded = true
							originalTubes = player:getWeaponTubeCount()
							newTubes = originalTubes + 1
							player:setWeaponTubeCount(newTubes)
							player:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							player:setWeaponStorageMax("Homing", player:getWeaponStorageMax("Homing") + 2)
							player:setWeaponStorage("Homing", player:getWeaponStorage("Homing") + 2)
							player:setWeaponTubeDirection(originalTubes, 180)
							setCommsMessage("You now have an additional homing torpedo tube pointing to the rear")
						end)
					end
				end)
			else
				addCommsReply("May I speak with Boris Eggleston?", function()
					setCommsMessage("[Boris Eggleston]\nHello, what can I do for you?")
					addCommsReply("Can you really add another weapons tube to our ship?", function()
						setCommsMessage(string.format("Definitely. But I'll need %s before I can do it",tubePart))
						addCommsReply("Back",commsStation)
					end)
				end)
			end
		end
	end
	if plot3name == "beamPhysicist" then
		if comms_target == beamDamageStation and distance(player,comms_target) < 1000 then
			gi = 1
			beamPart1Quantity = 0
			beamPart2Quantity = 0
			repeat
				if goods[player][gi][1] == beamPart1 then
					beamPart1Quantity = goods[player][gi][2]
				end
				if goods[player][gi][1] == beamPart2 then
					beamPart2Quantity = goods[player][gi][2]
				end
				gi = gi + 1
			until(gi > #goods[player])
			if beamPart1Quantity > 0 and beamPart2Quantity > 0 then
				addCommsReply(string.format("Give %s and %s to Frederico Booker for upgrade",beamPart1,beamPart2), function()
					if player.beamDamageUpgrade then
						setCommsMessage("You already have the upgrade")
					else
						if player:getBeamWeaponRange(0) > 0 then
							decrementPlayerGoods(beamPart1)
							decrementPlayerGoods(beamPart2)
							player.cargo = player.cargo + 2
							bi = 0	--beam index
							repeat
								tempArc = player:getBeamWeaponArc(bi)
								tempDir = player:getBeamWeaponDirection(bi)
								tempRng = player:getBeamWeaponRange(bi)
								tempCyc = player:getBeamWeaponCycleTime(bi)
								tempDmg = player:getBeamWeaponDamage(bi)
								player:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.5)
								bi = bi + 1
							until(player:getBeamWeaponRange(bi) < 1)
							player.beamDamageUpgrade = true
							setCommsMessage("Your ship beam weapons now deal 50% more damage")
						else
							setCommsMessage("Your ship has no beam weapons to upgrade")
						end
					end
				end)
			else
				addCommsReply("Talk to Frederico Booker", function()
					setCommsMessage(string.format("[Frederico Booker]\nGreetings, %s. What brings you to %s to talk to me?",player:getCallSign(),beamDamageStation:getCallSign()))
					addCommsReply("Can you upgrade our beam weapons systems?", function()
						setCommsMessage(string.format("[Frederico Booker]\nOh, you've heard about my research and the practical results? I can certainly upgrade the damage dealt by your beam weapons systems, but you'll need to provide me with %s and %s before I can complete the job",beamPart1,beamPart2))
						addCommsReply("Back", commsStation)
					end)
				end)
			end
		end
	end
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format("Time remaining: %.2f",gameTimeLimit)
			else
				oMsg = oMsg .. " no time limit"
			end
			if plotT ~= nil then
				oMsg = oMsg .. string.format("\nTransport spawn delay: %.f",transportSpawnDelay)
			end
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
				oMsg = oMsg .. string.format("\n%s location: %s",targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName())
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
			if plot6name == nil or plot6 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot6: " .. plot6name
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
			setCommsMessage(oMsg)
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
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p == comms_target and distance(p,player) < 1000 and p.cargo > 0 then
				addCommsReply(string.format("Transfer cargo to %s",p:getCallSign()), function()
					setCommsMessage("What would you like to transfer?")
					gi = 1
					repeat
						local goodsType = goods[player][gi][1]
						local goodsQuantity = goods[player][gi][2]
						if goodsQuantity > 0 then
							addCommsReply(goodsType, function()
								decrementPlayerGoods(goodsType)
								local gi2 = 1
								repeat
									if goods[p][gi2][1] == goodsType then
										goods[p][gi2][2] = goods[p][gi2][2] + 1
									end
									gi2 = gi2 + 1
								until(gi2 > #goods[p])
								player.cargo = player.cargo + 1
								p.cargo = p.cargo - 1
								setCommsMessage(string.format("One %s transferred to %s",goodsType,p:getCallSign()))
								p:addToShipLog(string.format("One %s transferred from %s",goodsType,player:getCallSign()),"#228b22")
								addCommsReply("Back", commsStation)
							end)
						end
						gi = gi + 1
					until(gi > #goods[player])
				end)
				break
			end
		end
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
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		freighterComms(comms_data)
	else
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
		hasWeapons = false
		if comms_target:getBeamWeaponRange(0) > 0 then
			hasWeapons = true
		end
		if comms_target:getWeaponTubeCount() > 0 then
			hasWeapons = true
		end
		if hasWeapons then
			addCommsReply("Attack nearby enemy target", function()
				localTargetCount = 0
				enemyTargetList = {}
				etlCount = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(15000)) do
					if comms_target:isEnemy(obj) then
						addCommsReply(obj:getCallSign(), function()
							setCommsMessage("Attacking " .. obj:getCallSign())
							comms_target:orderAttack(obj)
							addCommsReply("Back", commsShip)
						end)
						localTargetCount = localTargetCount + 1
						if localTargetCount > 9 then
							break
						end
					end
				end
				if localTargetCount == 0 then
					setCommsMessage("No enemy targets nearby")
				else
					setCommsMessage("Which enemy target?")
				end
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

function freighterComms(comms_data)
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
		else
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				goodsQuantity = 0
				gi = 1
				repeat
					goodsQuantity = goodsQuantity + goods[comms_target][gi][2]
					gi = gi + 1
				until(gi > #goods[comms_target])
				if goodsQuantity > 0 then
					addCommsReply("What kind of cargo are you carrying?", function()
						gi = 1
						gMsg = ""
						repeat
							if goods[comms_target][gi][2] > 0 then
								gMsg = gMsg .. goods[comms_target][gi][1] .. "\n"
							end
							gi = gi + 1
						until(gi > #goods[comms_target])
						setCommsMessage(gMsg)
						addCommsReply("Back", commsShip)
					end)
				end
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
		else
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				goodsQuantity = 0
				gi = 1
				repeat
					goodsQuantity = goodsQuantity + goods[comms_target][gi][2]
					gi = gi + 1
				until(gi > #goods[comms_target])
				if goodsQuantity > 0 then
					addCommsReply("What kind of cargo are you carrying?", function()
						gi = 1
						gMsg = ""
						repeat
							if goods[comms_target][gi][2] > 0 then
								gMsg = gMsg .. goods[comms_target][gi][1] .. "\n"
							end
							gi = gi + 1
						until(gi > #goods[comms_target])
						setCommsMessage(gMsg)
						addCommsReply("Back", commsShip)
					end)
				end
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
		else
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				goodsQuantity = 0
				gi = 1
				repeat
					goodsQuantity = goodsQuantity + goods[comms_target][gi][2]
					gi = gi + 1
				until(gi > #goods[comms_target])
				if goodsQuantity > 0 then
					addCommsReply("What kind of cargo are you carrying?", function()
						gi = 1
						gMsg = ""
						repeat
							if goods[comms_target][gi][2] > 0 then
								gMsg = gMsg .. goods[comms_target][gi][1] .. "\n"
							end
							gi = gi + 1
						until(gi > #goods[comms_target])
						setCommsMessage(gMsg)
						addCommsReply("Back", commsShip)
					end)
				end
			end
		end
	end
end

function neutralComms(comms_data)
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		freighterComms(comms_data)
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

function cargoTransfer(delta)
	if playerCarrier.cargo > 0 and playerBlade:isDocked(playerCarrier) and playerBlade.cargo < playerBlade.maxCargo then
		if bladeTransferButton == nil then
			bladeTransferButton = "bladeTransferButton"
			playerBlade:addCustomButton("Relay", bladeTransferButton, "Transfer Cargo", bladeCargoTransfer)
			bladeTransferButtonOp = "bladeTransferButtonOp"
			playerBlade:addCustomButton("Operations", bladeTransferButtonOp, "Transfer Cargo", bladeCargoTransfer)
		end
	else
		if bladeTransferButton ~= nil then
			playerBlade:removeCustom(bladeTransferButton)
			playerBlade:removeCustom(bladeTransferButtonOp)
			bladeTransferButton = nil
			bladeTransferButtonOp = nil
		end
	end
	if playerCarrier.cargo > 0 and playerPoint:isDocked(playerCarrier) and playerPoint.cargo < playerPoint.maxCargo then
		if pointTransferButton == nil then
			pointTransferButton = "pointTransferButton"
			playerPoint:addCustomButton("Relay", pointTransferButton, "Transfer Cargo", pointCargoTransfer)
			pointTransferButtonOp = "pointTransferButtonOp"
			playerPoint:addCustomButton("Operations", pointTransferButtonOp, "Transfer Cargo", pointCargoTransfer)
		end
	else
		if pointTransferButton ~= nil then
			playerPoint:removeCustom(pointTransferButton)
			playerPoint:removeCustom(pointTransferButtonOp)
			pointTransferButton = nil
			pointTransferButtonOp = nil
		end
	end
end

function bladeCargoTransfer()
	quantityToTransfer = 0
	gi = 1
	repeat
		if goods[playerBlade][gi][2] > 0 then
			quantityToTransfer = quantityToTransfer + 1
		end
		gi = gi + 1
	until(gi > #goods[playerBlade])
	if quantityToTransfer <= playerCarrier.cargo then
		gi = 1
		repeat
			if goods[playerBlade][gi][2] > 0 then
				gi2 = 1
				repeat
					if goods[playerCarrier][gi2][1] == goods[playerBlade][gi][1] then
						playerCarrier.cargo = playerCarrier.cargo - 1
						goods[playerCarrier][gi2][2] = goods[playerCarrier][gi2][2] + 1
						playerBlade.cargo = playerBlade.cargo + 1
						goods[playerBlade][gi][2] = goods[playerBlade][gi][2] - 1
					end
					gi2 = gi2 + 1
				until(gi2 > #goods[playerCarrier])
			end
			gi = gi + 1
		until(gi > #goods[playerBlade])
		if playerBlade:hasPlayerAtPosition("Relay") then
			bladeCargoTransferredMsg = "bladeCargoTransferredMsg"
			playerBlade:addCustomMessage("Relay",bladeCargoTransferredMsg,string.format("One of each type of cargo aboard %s transferred to %s",playerBlade:getCallSign(),playerCarrier:getCallSign()))
		end
		if playerBlade:hasPlayerAtPosition("Operations") then
			bladeCargoTransferredMsgOp = "bladeCargoTransferredMsgOp"
			playerBlade:addCustomMessage("Operations",bladeCargoTransferredMsgOp,string.format("One of each type of cargo aboard %s transferred to %s",playerBlade:getCallSign(),playerCarrier:getCallSign()))
		end
		playerCarrier:addToShipLog(string.format("Cargo transferred from %s",playerBlade:getCallSign()),"Magenta")
	else
		if playerBlade:hasPlayerAtPosition("Relay") then
			insufficientCarrierCargoSpaceMsg = "insufficientCarrierCargoSpaceMsg"
			playerBlade:addCustomMessage("Relay",insufficientCarrierCargoSpaceMsg,string.format("Insufficient space on %s to accept your cargo transfer",playerCarrier:getCallSign()))
		end
		if playerBlade:hasPlayerAtPosition("Operations") then
			insufficientCarrierCargoSpaceMsgOp = "insufficientCarrierCargoSpaceMsgOp"
			playerBlade:addCustomMessage("Operations",insufficientCarrierCargoSpaceMsgOp,string.format("Insufficient space on %s to accept your cargo transfer",playerCarrier:getCallSign()))
		end
	end
end

function pointCargoTransfer()
	quantityToTransfer = 0
	gi = 1
	repeat
		if goods[playerPoint][gi][2] > 0 then
			quantityToTransfer = quantityToTransfer + 1
		end
		gi = gi + 1
	until(gi > #goods[playerPoint])
	if quantityToTransfer <= playerCarrier.cargo then
		gi = 1
		repeat
			if goods[playerPoint][gi][2] > 0 then
				gi2 = 1
				repeat
					if goods[playerCarrier][gi2][1] == goods[playerPoint][gi][1] then
						playerCarrier.cargo = playerCarrier.cargo - 1
						goods[playerCarrier][gi2][2] = goods[playerCarrier][gi2][2] + 1
						playerPoint.cargo = playerPoint.cargo + 1
						goods[playerPoint][gi][2] = goods[playerPoint][gi][2] - 1
					end
					gi2 = gi2 + 1
				until(gi2 > #goods[playerCarrier])
			end
			gi = gi + 1
		until(gi > #goods[playerPoint])
		if playerPoint:hasPlayerAtPosition("Relay") then
			pointCargoTransferredMsg = "pointCargoTransferredMsg"
			playerPoint:addCustomMessage("Relay",pointCargoTransferredMsg,string.format("One of each type of cargo aboard %s transferred to %s",playerPoint:getCallSign(),playerCarrier:getCallSign()))
		end
		if playerPoint:hasPlayerAtPosition("Operations") then
			pointCargoTransferredMsgOp = "pointCargoTransferredMsgOp"
			playerPoint:addCustomMessage("Operations",pointCargoTransferredMsgOp,string.format("One of each type of cargo aboard %s transferred to %s",playerPoint:getCallSign(),playerCarrier:getCallSign()))
		end
		playerCarrier:addToShipLog(string.format("Cargo transferred from %s",playerPoint:getCallSign()),"Magenta")
	else
		if playerPoint:hasPlayerAtPosition("Relay") then
			insufficientCarrierCargoSpaceMsgPoint = "insufficientCarrierCargoSpaceMsgPoint"
			playerPoint:addCustomMessage("Relay",insufficientCarrierCargoSpaceMsgPoint,string.format("Insufficient space on %s to accept your cargo transfer",playerCarrier:getCallSign()))
		end
		if playerPoint:hasPlayerAtPosition("Operations") then
			insufficientCarrierCargoSpaceMsgPointOp = "insufficientCarrierCargoSpaceMsgPointOp"
			playerPoint:addCustomMessage("Operations",insufficientCarrierCargoSpaceMsgPointOp,string.format("Insufficient space on %s to accept your cargo transfer",playerCarrier:getCallSign()))
		end
	end
end
--[[-----------------------------------------------------------------
      First plot line. Mission briefing, spawn other plots, wave handling
-----------------------------------------------------------------]]--
function initialOrders(delta)
	plot1name = "initialOrders"
	initialOrderTimer = initialOrderTimer - delta
	if initialOrderTimer < 0 then
		if initialOrdersMsg == nil then
			initialOrdersMsg = "sent"
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("The Ktlitans keep sending harassing ships. We've decrypted some of their communications - enough to identify their primary base by name if not by location. Find and destroy Ktlitan station %s. Respond to other requests from stations in the area if you wish, but your primary goal is do destroy %s. You're in control of our prototype carrier. As you know, it has minimal weapons and cannot dock with a station. It is in your best interest to protect it since it will significantly shorten the duration of your mission.",targetEnemyStation:getCallSign(),targetEnemyStation:getCallSign()),"Magenta")
					primaryOrders = string.format("Destroy %s",targetEnemyStation:getCallSign())
				end
			end
			plot1 = setEnemyDefenseFleet
		end
	end
end

function setEnemyDefenseFleet(delta)
	plot1name = "setEnemyDefenseFleet"
	if enemyDefenseFleets == nil then
		enemyDefenseFleets = "set"
		for i=1,#enemyStationList do
			defx, defy = enemyStationList[i]:getPosition()
			if i == #enemyStationList then
				ntf = spawnEnemies(defx,defy,2,enemyStationList[i]:getFaction())
			else
				ntf = spawnEnemies(defx,defy,1,enemyStationList[i]:getFaction())
			end
			for _, enemy in ipairs(ntf) do
				enemy:orderDefendTarget(enemyStationList[i])
			end
		end
		plot1 = threadedPursuit
	end
end

function threadedPursuit(delta)
	plot1name = "threadedPursuit"
	if ef2 == nil then
		p = closestPlayerTo(targetEnemyStation)
		scx, scy = p:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(20000,30000))
		ef2 = spawnEnemies(scx+cpx,scy+cpy,.8)
		for _, enemy in ipairs(ef2) do
			if diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef2")
			end
			enemy:orderFlyTowards(scx,scy)
		end
		plot2name = "destroyef2"
		plot2 = destroyef2
	end
	if ef3 == nil then
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,.8)
		for _, enemy in ipairs(ef3) do
			if diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef3")
			end
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3
	end
	if ef4 == nil then
		scx, scy = p:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(40000,50000))
		ef4 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef4) do
			if diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef4")
			end
			enemy:orderAttack(p)
		end
		plot4 = destroyef4
	end
	waveTimer = interWave
	dangerValue = .5
	dangerIncrement = .2
	plot1 = pressureWaves
end

function pressureWaves(delta)
	plot1name = "pressureWaves"
	if not targetEnemyStation:isValid() then
		missionVictory = true
		endStatistics()
		victory("Human Navy")
		return
	end
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		dangerValue = dangerValue + dangerIncrement
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if random(1,5) <= 1 then
					esx, esy = enemyStationList[i]:getPosition()
					ntf = spawnEnemies(esx,esy,dangerValue,enemyStationList[i]:getFaction())
					if random(1,5) <= 3 then
						p = closestPlayerTo(enemyStationList[i])
						for _, enemy in ipairs(ntf) do
							enemy:orderAttack(p)
						end
					else
						for _, enemy in ipairs(ntf) do
							enemy:orderDefendTarget(enemyStationList[i])
						end
					end
				end
			end
		end
		if random(1,5) <= 2 then
			ntf = spawnEnemies(mnx,mny,dangerValue,targetEnemyStation:getFaction())
			if random(1,5) >= 4 then
				if homeStation:isValid() then
					for _, enemy in ipairs(ntf) do
						enemy:orderAttack(homeStation)
					end
				end
			end
		end
		if random(1,5) <= 3 then
			p = closestPlayerTo(targetEnemyStation)
			esx, esy = targetEnemyStation:getPosition()
			px, py = p:getPosition()
			ntf = spawnEnemies((esx+px)/2,(esy+py)/2,dangerValue,targetEnemyStation:getFaction())
			if random(1,5) <= 2 then
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if random(1,5) <= 1 then
			if homeStation:isValid() then
				hsx, hsy = homeStation:getPosition()
			else
				hsx, hsy = targetEnemyStation()
			end
			spx, spy = vectorFromAngle(random(0,360),random(30000,40000))
			ntf = spawnEnemies(hsx+spx,hsy+spy,dangerValue,targetEnemyStation:getFaction())
			if random(1,5) <= 3 then
				if homeStation:isValid() then
					for _, enemy in ipairs(ntf) do
						enemy:orderFlyTowards(hsx,hsy)
					end
				end
			end
		end
		waveTimer = delta + interWave + dangerValue*10 + random(1,60)
	end
end
--[[-----------------------------------------------------------------
    Plot 2 
-----------------------------------------------------------------]]--
function destroyef2(delta)
	ef2Count = 0
	for _, enemy in ipairs(ef2) do
		if enemy:isValid() then
			ef2Count = ef2Count + 1
		end
	end
	if ef2Count == 0 then
		plot2 = chooseNextPlot2line
	end
end

function chooseNextPlot2line(delta)
	plot2name = "chooseNextPlot2line"
	plot2reminder = nil
	if nextPlot2 == nil then
		if #plot2choices > 0 then
			p2c = math.random(1,#plot2choices)
			plot2 = plot2choices[p2c]
			table.remove(plot2choices,p2c)
			plot2DelayTimer = random(40,120)
		else
			plot2 = nil
		end
	else
		plot2 = nextPlot2
		for i=1,#plot2choices do
			if plot2choices[i] == plot2 then
				table.remove(plot2choices,i)
				plot2DelayTimer = random(40,120)
				break
			end
		end
		nextPlot2 = nil
	end
end

function betweenPlot2fleet()
	p = closestPlayerTo(targetEnemyStation)
	p:addReputationPoints(20)
	scx, scy = p:getPosition()
	cpx, cpy = vectorFromAngle(random(0,360),random(30000,35000))
	ef2 = spawnEnemies(scx+cpx,scy+cpy,dangerValue)
	for _, enemy in ipairs(ef2) do
		if diagnostic then
			enemy:setCallSign(enemy:getCallSign() .. "ef2")
		end
		enemy:orderAttack(p)
	end
	plot2reminder = nil
	plot2 = destroyef2
	plot2name = "destroyef2"
end
-- upgrade ship spin functions
function upgradeShipSpin(delta)
	plot2name = "upgradeShipSpin"
	removeGMFunction(GMStartPlot2upgradeShipSpin)
	plot2DelayTimer = plot2DelayTimer - delta
	if plot2DelayTimer < 0 then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate:isValid() then
				spinScientistStation = candidate
			end
		until(spinScientistStation ~= nil)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Paulina Lindquist, a noted research engineer recently published her latest theories on engine design. We believe her theories have practical applications to our ship maneuvering systems. You may want to talk to her about putting her theories into practice on our naval vessels. She's currently stationed on %s in %s",spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),"Magenta")
			end
		end
		plot2reminder = string.format("Visit Paulina Lindquist on %s in %s regarding ship spin upgrade",spinScientistStation:getCallSign(),spinScientistStation:getSectorName())
		plot2name = "spinScientist"
		plot2 = spinScientist
		spinUpgradeAvailable = false
	end
end
function spinScientist(delta)
	validPlayers = 0
	spinPlayers = 0
	if spinUpgradeAvailable then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				validPlayers = validPlayers + 1
				if p.spinUpgrade then
					spinPlayers = spinPlayers + 1
				end
			end
		end
		if spinPlayers == validPlayers then
			betweenPlot2fleet()
		end
	else
		if not spinScientistStation:isValid() then
			spinScientistStation = nil
			repeat
				candidate = stationList[math.random(13,#stationList)]
				if candidate:isValid() then
					spinScientistStation = candidate
				end
			until(spinScientistStation ~= nil)
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("Paulina Lindquist, has been reassigned to station %s in %s",spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),"Magenta")
				end
			end
			plot2reminder = string.format("Visit Paulina Lindquist on %s in %s regarding ship spin upgrade",spinScientistStation:getCallSign(),spinScientistStation:getSectorName())
		end
	end
end
-- Locate target enemy base functions
function locateTargetEnemyBase(delta)
	plot2name = "locateTargetEnemyBase"
	removeGMFunction(GMStartPlot2locateTargetEnemyBase)
	plot2DelayTimer = plot2DelayTimer - delta
	if plot2DelayTimer < 0 then
		repeat
			candidate = stationList[math.random(1,12)]
			if candidate:isValid() then
			end
		until(friendlyClueStation ~= nil)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Herbert Long believes he has a lead on some information about the enemy base that has been the source of the harassing ships. He's stationed on %s in %s",friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),"Magenta")
			end
		end
		plot2reminder = string.format("Talk to Herbert Long on %s in %s regarding enemy base",friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName())
		plot2name = "friendlyClue"
		plot2 = friendlyClue
	end
end
function friendlyClue(delta)
end
-- Rescue dying scientist functions
function rescueDyingScientist(delta)
	plot2name = "rescueDyingScientist"
	removeGMFunction(GMStartPlot2rescueDyingScientist)
	scientistDeathTimer = 300
	pickScientistStation()
	pickDoctorStation()
	placeHullArtifact()
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog(string.format("[%s in %s] Medical emergency: Engineering research scientist Terrence Forsythe has contracted a rare medical condition. After contacting nearly every station in the area, we found that doctor Geraldine Polaski on %s has the expertise and facilities to help. However, we don't have the necessary transport to get Terrence there in time - he has only a few minutes left to live. Can you take Terrence to %s?",scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign(),doctorStation:getCallSign()),"95,158,160")
		end
	end
	plot2reminder = string.format("Transport Terrence Forsythe from %s in %s to %s before he dies",scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign())
	plot2name = "getSickScientist"
	plot2 = getSickScientist
end
function pickScientistStation()
	repeat
		candidate = stationList[math.random(13,30)]
		if candidate:isValid() then
			scientistStation = candidate
		end
	until(scientistStation ~= nil)
end
function pickDoctorStation()
	repeat
		candidate = stationList[math.random(1,12)]
		if candidate:isValid() then
			doctorStation = candidate
		end
	until(doctorStation ~= nil)
end
function placeHullArtifact()
	asx, asy = scientistStation:getPosition()
	wx, wy = vectorFromAngle(random(0,360),random(2500,3500))
	hullArtifact = Artifact():setPosition(asx+wx,asy+wy):setModel("artifact2"):allowPickup(false):setScanningParameters(3,2)
	hullArtifact:setDescriptions("Artificially manufactured object of unknown purpose","Prototype device intended for ship system integration"):setRadarSignatureInfo(10,50,5)
end
function getSickScientist(delta)
	scientistDeathTimer = scientistDeathTimer - delta
	if scientistDeathTimer < 0 then
		scientistDies()
	end
	if scientistStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and distance(p,scientistStation) < 1000 then
				playerWithScientist = p
				pickupMsg = string.format("[%s] Terrence Forsythe has been transported aboard your ship. Please take him to Dr. Polaski on %s. ",scientistStation:getCallSign(),doctorStation:getCallSign())
				minutesToLive = math.floor(scientistDeathTimer/60)
				if minutesToLive == 0 then
					pickupMsg = pickupMsg .. "We believe he has less than a minute to live"
				elseif minutesToLive == 1 then
					pickupMsg = pickupMsg .. "We think he has about a minute before he dies"
				else
					pickupMsg = pickupMsg .. string.format("He probably has about %i minutes to live",minutesToLive)
				end
				p:addToShipLog(pickupMsg,"95,158,160")
				plot2name = "deliverSickScientist"
				plot2 = deliverSickScientist
				break
			end
		end
		if pickupMsg ~= nil then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p ~= playerWithScientist then
					p:addToShipLog(string.format("Terrence Forsyth aboard %s",playerWithScientist:getCallSign()),"Magenta")
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("%s has been destroyed",scientistStation:getCallSign()),"Magenta")
			end
		end
		betweenPlot2fleet()
	end
end
function deliverSickScientist(delta)
	scientistDeathTimer = scientistDeathTimer - delta
	if scientistDeathTimer < 0 then
		scientistDies()
	end
	if doctorStation:isValid() then
		if playerWithScientist:isValid() then
			if distance(playerWithScientist,doctorStation) < 1000 then
				playerWithScientist:addToShipLog(string.format("[%s] We have received your emergency medical transport of research scientist Terrence Forsythe. Doctor Geraldine Polaski has stabalized his condition.",doctorStation:getCallSign()),"#8a2be2")
				plot2name = "keyToArtifact"
				plot2reminder = nil
				scientistRecoveryTimer = 90
				plot2 = keyToArtifact
			end
		else
			betweenPlot2fleet()
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("%s has been destroyed",doctorStation:getCallSign()),"Magenta")
			end
		end
		betweenPlot2fleet()
	end
end
function keyToArtifact(delta)
	scientistRecoveryTimer = scientistRecoveryTimer - delta
	if scientistRecoveryTimer < 0 then
		keyMsg = string.format("[Terrence Forsythe] I can never repay you for saving my life. However, you might be able to use the practical results of my latest research. Near %s in %s you'll find a prototype for ship system integration. This prototype allows for the rapid and semi-automated repair of hull damage as directed by your Engineer. I have transmitted the key to allow you to use this prototype",scientistStation:getCallSign(),scientistStation:getSectorName())
		if playerWithScientist:isValid() then
			playerWithScientist:addToShipLog(keyMsg,"#8a2be2")
		else
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(keyMsg,"#8a2be2")
				end
			end
		end
		plot2name = "recoverHullArtifact"
		plot2reminder = string.format("Recover hull repair prototype near %s in %s",scientistStation:getCallSign(),scientistStation:getSectorName())
		plot2 = recoverHullArtifact
	end
end
-- Semi-automated hull repair functions
function recoverHullArtifact(delta)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			tempPlayerType = p:getTypeName()
			if tempPlayerType == "Benedict" or tempPlayerType == "Kiriya" then
				if distance(p,hullArtifact) < 1000 then
					playerWithAutoHullRepair = p
					installAutoHullRepair()
					hullArtifact:destroy()
					betweenPlot2fleet()
					break
				end
			else
				if distance(p,hullArtifact) < 500 then
					playerWithAutoHullRepair = p
					installAutoHullRepair()
					hullArtifact:destroy()
					betweenPlot2fleet()
					break
				end
			end
		end
	end
end
function installAutoHullRepair()
	repairHullUses = 5
	if playerWithAutoHullRepair:hasPlayerAtPosition("Engineering") then
		hullUseMsg = "hullUseMsg"
		playerWithAutoHullRepair:addCustomMessage("Engineering",hullUseMsg,string.format("Hull repair prototype installed. Limited to %i uses",repairHullUses))
	end
	if playerWithAutoHullRepair:hasPlayerAtPosition("Engineering+") then
		hullUseMsgPlus = "hullUseMsgPlus"
		playerWithAutoHullRepair:addCustomMessage("Engineering+",hullUseMsgPlus,string.format("Hull repair prototype installed. Limited to %i uses",repairHullUses))
	end
	repairHullButton = string.format("repairHullButton%i",repairHullUses)
	playerWithAutoHullRepair:addCustomButton("Engineering",repairHullButton,string.format("Repair Hull (%i)",repairHullUses),repairHull)
	repairHullButtonPlus = string.format("repairHullButtonPlus%i",repairHullUses)
	playerWithAutoHullRepair:addCustomButton("Engineering+",repairHullButtonPlus,string.format("Repair Hull (%i)",repairHullUses),repairHull)
end
function repairHull()
	if playerWithAutoHullRepair:getHull() < playerWithAutoHullRepair:getHullMax() then
		playerWithAutoHullRepair:setHull(playerWithAutoHullRepair:getHullMax())
		repairHullUses = repairHullUses - 1
		playerWithAutoHullRepair:removeCustom(repairHullButton)
		playerWithAutoHullRepair:removeCustom(repairHullButtonPlus)
		repairHullButton = nil
		repairHullButtonPlus = nil
		if repairHullUses > 0 then
			repairHullButton = string.format("repairHullButton%i",repairHullUses)
			playerWithAutoHullRepair:addCustomButton("Engineering",repairHullButton,string.format("Repair Hull (%i)",repairHullUses),repairHull)
			repairHullButtonPlus = string.format("repairHullButtonPlus%i",repairHullUses)
			playerWithAutoHullRepair:addCustomButton("Engineering+",repairHullButtonPlus,string.format("Repair Hull (%i)",repairHullUses),repairHull)
		end
	end
end
function scientistDies()
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:addToShipLog("Terrence Forsythe has perished","Magenta")
		end
	end
	betweenPlot2fleet()
end
--[[-----------------------------------------------------------------
    Plot 3 
-----------------------------------------------------------------]]--
function destroyef3(delta)
	plot3name = "destroyef3"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		plot3 = chooseNextPlot3line
	end
end

function chooseNextPlot3line(delta)
	plot3name = "chooseNextPlot2line"
	plot3reminder = nil
	if nextPlot3 == nil then
		if #plot3choices > 0 then
			p3c = math.random(1,#plot3choices)
			plot3 = plot3choices[p3c]
			table.remove(plot3choices,p3c)
			plot3DelayTimer = random(40,120)
		else
			plot3 = nil
		end
	else
		plot3 = nextPlot3
		for i=1,#plot3choices do
			if plot3choices[i] == plot3 then
				table.remove(plot3choices,i)
				plot3DelayTimer = random(40,120)
				break
			end
		end
		nextPlot3 = nil
	end
end

function betweenPlot3fleet()
	p = closestPlayerTo(targetEnemyStation)
	p:addReputationPoints(20)
	scx, scy = p:getPosition()
	cpx, cpy = vectorFromAngle(random(0,360),random(30000,35000))
	ef3 = spawnEnemies(scx+cpx,scy+cpy,dangerValue)
	for _, enemy in ipairs(ef3) do
		if diagnostic then
			enemy:setCallSign(enemy:getCallSign() .. "ef3")
		end
		enemy:orderAttack(p)
	end
	plot3reminder = nil
	plot3 = destroyef3
	plot3name = "destroyef3"
end
-- plot 3 add homing missile weapons tube to ship
function addTubeToShip(delta)
	plot3name = "addTubeToShip"
	removeGMFunction(GMStartPlot3addTubeToShip)
	plot3DelayTimer = plot3DelayTimer - delta
	if plot3DelayTimer < 0 then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate:isValid() then
				addTubeStation = candidate
			end
		until(addTubeStation ~= nil)
		tubeCargoChoice = math.random(1,3)
		if tubeCargoChoice == 1 then
			tubePart = "lifter"
		elseif tubeCargoChoice == 2 then
			tubePart = "circuit"
		else
			tubePart = "nanites"
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Retired naval officer, Boris Eggleston has taken his expertise in miniaturization and come up with a way to add a missile tube to naval vessels. He's vacationing on %s in %s",addTubeStation:getCallSign(),addTubeStation:getSectorName()),"Magenta")
				
			end
		end
		plot3reminder = string.format("Get extra weapons tube from Boris Eggleston on %s in %s",addTubeStation:getCallSign(),addTubeStation:getSectorName())
		plot3name = "tubeOfficer"
		plot3 = tubeOfficer
	end
end
function tubeOfficer(delta)
	if addTubeStation:isValid() then
		validPlayers = 0
		tubePlayers = 0
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				validPlayers = validPlayers + 1
				if p.tubeAdded then
					tubePlayers = tubePlayers + 1
				end
			end
		end
		if tubePlayers == validPlayers then
			betweenPlot3fleet()
		end
	else
		addTubeStation = nil
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate:isValid() then
				addTubeStation = candidate
			end
		until(addTubeStation ~= nil)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Boris Eggleston changed his vacation spot to %s in %s",addTubeStation:getCallSign(),addTubeStation:getSectorName()),"Magenta")
			end
		end
		plot3reminder = string.format("Get extra weapons tube from Boris Eggleston on %s in %s",addTubeStation:getCallSign(),addTubeStation:getSectorName())
	end
end
-- plot 3 upgrade the amount of damage done by beam weapons
function upgradeBeamDamage(delta)
	plot3name = "upgradeBeamDamage"
	removeGMFunction(GMStartPlot3upgradeBeamDamage)
	plot3DelayTimer = plot3DelayTimer - delta
	if plot3DelayTimer < 0 then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate:isValid() then
				beamDamageStation = candidate
			end
		until(beamDamageStation ~= nil)
		beamCargoChoice = math.random(1,5)
		if beamCargoChoice == 1 then
			beamPart1 = "gold"
		elseif beamCargoChoice == 2 then
			beamPart1 = "platinum"
		elseif beamCargoChoice == 3 then
			beamPart1 = "tritanium"
		elseif beamCargoChoice == 4 then
			beamPart1 = "dilithium"
		else
			beamPart1 = "cobalt"
		end
		beamCargoChoice = math.random(1,5)
		if beamCargoChoice == 1 then
			beamPart2 = "beam"
		elseif beamCargoChoice == 2 then
			beamPart2 = "optic"
		elseif beamCargoChoice == 3 then
			beamPart2 = "filament"
		elseif beamCargoChoice == 4 then
			beamPart2 = "battery"
		else
			beamPart2 = "robotic"
		end
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("There's a physicist turned maintenance technician named Frederico Booker that has developed some innovative beam weapon technology that could increase the damage produced by our beam weapons. He's based on %s in %s",beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),"Magenta")
			end
		end
		plot3reminder = string.format("Talk to Frederico Booker on %s in %s about a beam upgrade",beamDamageStation:getCallSign(),beamDamageStation:getSectorName())
		plot3name = "beamPhysicist"
		plot3 = beamPhysicist
	end
end
function beamPhysicist(delta)
	if beamDamageStation:isValid() then
		validPlayers = 0
		beamPlayers = 0
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p:getBeamWeaponRange(0) > 0 then
				validPlayers = validPlayers + 1
				if p.beamDamageUpgrade then
					beamPlayers = beamPlayers + 1
				end
			end
		end
		if beamPlayers == validPlayers then
			betweenPlot3fleet()
		end
	else
		beamDamageStation = nil
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate:isValid() then
				beamDamageStation = candidate
			end
		until(beamDamageStation ~= nil)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Frederico Booker has moved to station %s in %s",beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),"Magenta")
			end
		end
		plot3reminder = string.format("Talk to Frederico Booker on %s in %s about a beam upgrade",beamDamageStation:getCallSign(),beamDamageStation:getSectorName())
	end
end
-- plot 3 tractor ship in for repairs
function tractorDisabledShip(delta)
	plot3name = "tractorDisabledShip"
	removeGMFunction(GMStartPlot3tractorDisabledShip)
	plot3DelayTimer = plot3DelayTimer - delta
	if plot3DelayTimer < 0 then
		if playerCarrier:isValid() then
			repeat
				candidate = stationList[math.random(13,#stationList)]
				if candidate:isValid() then
					tractorStation = candidate
				end
			until(tractorStation ~= nil)
			p = farthestPlayerFrom(homeStation)
			ppx, ppy = p:getPosition()
			tpx, tpy = vectorFromAngle(random(0,360),random(40000,45000))
			strikeShipNames = {"Cropper","Dunner","Forthwith","Stellar","Trammel","Greeble"}
			tractorShip = CpuShip():setTemplate("Strikeship"):setFaction("Human Navy"):setPosition(ppx+tpx,ppy+tpy):setScanned(true)
			tractorShip:setSystemHealth("warp",-.5):setSystemHealth("jumpdrive",-.5):orderStandGround():setCallSign(strikeShipNames[math.random(1,#strikeShipNames)])
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("[%s] Help requested: Our engines are damaged beyond our ability to repair. We are located in %s",tractorShip:getCallSign(),tractorShip:getSectorName()),"#556b2f")
				end
			end
			plot3name = "confirmRescue"
			confirmRescueTimer = 40
			plot3 = confirmRescue
		else
			betweenPlot3fleet()
		end
	end
end
function confirmRescue(delta)
	confirmRescueTimer = confirmRescueTimer - delta
	if confirmRescueTimer < 0 then
		if playerCarrier:isValid() then
			playerCarrier:addToShipLog(string.format("Station %s in %s has tractor equipment you can use to tractor %s in for repairs",tractorStation:getCallSign(),tractorStation:getSectorName(),tractorShip:getCallSign()),"Magenta") 
			plot3reminder = string.format("Install tractor equipment in %s from station %s in %s",playerCarrier:getCallSign(),tractorStation:getCallSign(),tractorStation:getSectorName())
			plot3name = "awaitingTractor"
			plot3 = awaitingTractor
		else
			betweenPlot3fleet()
		end
	end
end
function awaitingTractor(delta)
	if playerCarrier:isValid() then
		if tractorShip:isValid() then
			tractorShip:setSystemHealth("warp",-.5):setSystemHealth("jumpdrive",-.5)
			if tractorInstalled and distance(playerCarrier,tractorShip) < 5000 then
				enableTractorOn()
				enableTractorOff()
				if tractorShip:isDocked(playerCarrier) then
					if tractorPlayerDockMsg == nil then
						tractorPlayerDockMsg = "tractorPlayerDockMsg"
						if playerCarrier:hasPlayerAtPosition("Weapons") then
							playerCarrier:addCustomMessage("Weapons",tractorPlayerDockMsg,string.format("%s has been tractored to %s and is now docked",tractorShip:getCallSign(),playerCarrier:getCallSign()))
						end
						if playerCarrier:hasPlayerAtPosition("Tactical") then
							playerCarrier:addCustomMessage("Tactical",tractorPlayerDockMsg,string.format("%s has been tractored to %s and is now docked",tractorShip:getCallSign(),playerCarrier:getCallSign()))
						end
					end
				else
					if tractorPlayerDockMsg ~= nil then
						tractorPlayerDockMsg = nil
					end
					if repairStation == nil then
						validFriendlyStations = 0
						for fsi=1,12 do
							if stationList[fsi]:isValid() then
								validFriendlyStations = validFriendlyStations + 1
							end
						end
						if validFriendlyStations > 0 then
							repeat
								candidate = stationList[math.random(1,12)]
								if candidate:isValid() then
									repairStation = candidate
								end
							until(repairStation ~= nil)
							playerCarrier:addToShipLog(string.format("Tractor %s to %s to be repaired",tractorShip:getCallSign(),repairStation:getCallSign()),"Magenta")
							plot3reminder = string.format("Tractor %s to %s",tractorShip:getCallSign(),repairStation:getCallSign())
						else
							disableTractorOff()
							disableTractorOn()
							betweenPlot3fleet()
						end
					else
						if repairStation:isValid() then
							if tractorShip:isValid() then
								if distance(repairStation,tractorShip) < 1000 then
									playerCarrier:addToShipLog(string.format("Thanks for bringing %s in for repairs, %s. We'll take it from here",tractorShip:getCallSign(),playerCarrier:getCallSign()),"#b29650")
									tractorShip:orderDock(repairStation)
									disableTractorOff()
									disableTractorOn()
									repairDelayTimer = 60
									plot3name = "awaitRepairs"
									plot3reminder = nil
									plot3 = awaitRepairs
								else
									if bringCloser == nil and distance(tractorShip, repairStation) < 5000 then
										playerCarrier:addToShipLog(string.format("[%s] Greetings, %s. You'll need to tractor %s to within 1U before we can start repairs",repairStation:getCallSign(),playerCarrier:getCallSign(),tractorShip:getCallSign()),"#b29650")
										bringCloser = "messageSent"
									end
								end
							else
								disableTractorOff()
								disableTractorOn()
								betweenPlot3fleet()
							end
						else
							repairStation = nil
						end
					end
				end
			else
				disableTractorOn()
				disableTractorOff()
			end
		else
			disableTractorOn()
			disableTractorOff()
			betweenPlot3fleet()
		end
	else
		betweenPlot3fleet()
	end
end
function enableTractorOn()
	if tractorOnButton == nil then
		tractorOnButton = "tractorOnButton"
		playerCarrier:addCustomButton("Weapons",tractorOnButton,"Tractor On",simulateTractorOn)
		tractorOnButtonTac = "tractorOnButtonTac"
		playerCarrier:addCustomButton("Tactical",tractorOnButtonTac,"Tractor On",simulateTractorOn)
	end
end
function disableTractorOn()
	if tractorOnButton ~= nil then
		playerCarrier:removeCustom(tractorOnButton)
		playerCarrier:removeCustom(tractorOnButtonTac)
		tractorOnButton = nil
		tractorOnButtonTac = nil
	end
end
function simulateTractorOn()
	tractorShip:orderDock(playerCarrier)
	disableTractorOn()
	enableTractorOff()
end
function enableTractorOff()
	if tractorOffButton == nil then
		tractorOffButton = "tractorOffButton"
		playerCarrier:addCustomButton("Weapons",tractorOffButton,"Tractor Off",simulateTractorOff)
		tractorOffButtonTac = "tractorOffButtonTac"
		playerCarrier:addCustomButton("Tactical",tractorOffButtonTac,"Tractor Off",simulateTractorOff)
	end
end
function disableTractorOff()
	if tractorOffButton ~= nil then
		playerCarrier:removeCustom(tractorOffButton)
		playerCarrier:removeCustom(tractorOffButtonTac)
		tractorOffButton = nil
		tractorOffButtonTac = nil
	end
end
function simulateTractorOff()
	tlx, tly = tractorShip:getPosition()
	tractorShip:orderFlyTowards(tlx,tly)
	disableTractorOff()
	enableTractorOn()
end
function connectTractor()
	playerCarrier:removeCustom(tractorIntegrationButton)
	playerCarrier:removeCustom(tractorIntegrationButtonPlus)
	if playerCarrier:hasPlayerAtPosition("Engineering") then
		tractorConfirmationMsg = "tractorConfirmationMsg"
		playerCarrier:addCustomMessage("Engineering",tractorConfirmationMsg,"The tractor equipment has been fully integrated with ship systems. It is ready for the weapons officer to activate at the appropriate time")
	end
	if playerCarrier:hasPlayerAtPosition("Engineering+") then
		tractorConfirmationMsgPlus = "tractorConfirmationMsgPlus"
		playerCarrier:addCustomMessage("Engineering",tractorConfirmationMsgPlus,"The tractor equipment has been fully integrated with ship systems. It is ready for the weapons officer to activate at the appropriate time")
	end
	if playerCarrier:hasPlayerAtPosition("Weapons") then
		wTractorConfirmationMsg = "wTractorConfirmationMsg"
		playerCarrier:addCustomMessage("Weapons",wTractorConfirmationMsg,string.format("Tractor equipment installed.\nWhen %s is in range of the disabled ship, %s, You can engage the tractor system via the (Tractor On) button. This system works with %s's on board systems to draw and maneuver %s to %s until it is docked",playerCarrier:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),playerCarrier:getCallSign()))
	end
	if playerCarrier:hasPlayerAtPosition("Tactical") then
		tTractorConfirmationMsg = "tTractorConfirmationMsg"
		playerCarrier:addCustomMessage("Tactical",tTractorConfirmationMsg,string.format("Tractor equipment installed.\nWhen %s is in range of the disabled ship, %s, You can engage the tractor system via the (Tractor On) button. This system works with %s's on board systems to draw and maneuver %s to %s until it is docked",playerCarrier:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),playerCarrier:getCallSign()))
	end
	tractorInstalled = true
end
function awaitRepairs(delta)
	repairDelayTimer = repairDelayTimer - delta
	if repairDelayTimer < 0 then
		tractorShip:setSystemHealth("warp",1):setSystemHealth("jumpdrive",1)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("[%s] Our engines have been repaired and we stand ready to assist",tractorShip:getCallSign()),"#556b2f")
			end
		end
		betweenPlot3fleet()
	end
end
--[[-----------------------------------------------------------------
    Plot 4 - more depth to plot 4 to come in a later revision
-----------------------------------------------------------------]]--
function destroyef4(delta)
	plot4name = "destroyef4"
	ef4Count = 0
	for _, enemy in ipairs(ef4) do
		if enemy:isValid() then
			ef4Count = ef4Count + 1
		end
	end
	if ef4Count == 0 then
		plot4 = doNotPush
	end
end
function doNotPush(delta)
	alienHack = false
	doNotPushButton = "doNotPushButton"
	playerCarrier:addCustomButton("Weapons",doNotPushButton,"Do Not Push",pushed)
	doNotPushButtonTac = "doNotPushButtonTac"
	playerCarrier:addCustomButton("Tactical",doNotPushButtonTac,"Do Not Push",pushed)
	if playerCarrier:hasPlayerAtPosition("Science") then
		alienHackMsg = "alienHackMsg"
		playerCarrier:addCustomMessage("Science",alienHackMsg,"Internal security sensors indicate ship systems hacked by unknown source. For a moment I thought I heard evil laughter")
	end
	if playerCarrier:hasPlayerAtPosition("Operations") then
		alienHackMsgOp = "alienHackMsgOp"
		playerCarrier:addCustomMessage("Operations",alienHackMsgOp,"Internal security sensors indicate ship systems hacked by unknown source. For a moment I thought I heard evil laughter")
	end
	plot4 = nil
end
function pushed()
	alienHack = true
	px, py = playerCarrier:getPosition()
	bha = 0
	for i=1,8 do
		bhx, bhy = vectorFromAngle(bha,7500)
		BlackHole():setPosition(px+bhx,py+bhy)
		bha = bha + 45
	end
	sealed = WarpJammer():setPosition(px,py):setRange(10000)
	if difficulty >= 1 then
		sealed:setFaction("Human Navy")
	else
		sealed:setFaction("Kraylor")
	end
	playerCarrier:removeCustom(doNotPushButton)
	playerCarrier:removeCustom(doNotPushButtonTac)
end
--[[-----------------------------------------------------------------
      Give player ships defaults for this script. Called at the start 
	  while paused & each time a ship's relay officer interacts with a station
-----------------------------------------------------------------]]--
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
				pobj:addReputationPoints(150-(difficulty*6))
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
					pobj.shipScore = 6
					pobj.maxCargo = 3
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
				elseif tempPlayerType == "Benedict" then
					if #playerShipNamesForBenedict > 0 then
						ni = math.random(1,#playerShipNamesForBenedict)
						pobj:setCallSign(playerShipNamesForBenedict[ni])
						table.remove(playerShipNamesForBenedict,ni)
					end
					if diagnostic then
						pobj.shipScore = 1
					else
						pobj.shipScore = 10
					end
					pobj.maxCargo = 9
				elseif tempPlayerType == "Kiriya" then
					if #playerShipNamesForKiriya > 0 then
						ni = math.random(1,#playerShipNamesForKiriya)
						pobj:setCallSign(playerShipNamesForKiriya[ni])
						table.remove(playerShipNamesForKiriya,ni)
					end
					if diagnostic then
						pobj.shipScore = 1
					else
						pobj.shipScore = 10
					end
					pobj.maxCargo = 9
				elseif tempPlayerType == "Striker" then
					if #playerShipNamesForStriker > 0 then
						ni = math.random(1,#playerShipNamesForStriker)
						pobj:setCallSign(playerShipNamesForStriker[ni])
						table.remove(playerShipNamesForStriker,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 4
				elseif tempPlayerType == "ZX-Lindworm" then
					if #playerShipNamesForLindworm > 0 then
						ni = math.random(1,#playerShipNamesForLindworm)
						pobj:setCallSign(playerShipNamesForLindworm[ni])
						table.remove(playerShipNamesForLindworm,ni)
					end
					pobj.shipScore = 7
					pobj.maxCargo = 3
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
-- Return the player ship farthest from the passed object parameter
function farthestPlayerFrom(obj)
	if obj ~= nil and obj:isValid() then
		local farthestDistance = 0
		farthestPlayer = nil
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance > farthestDistance then
					farthestPlayer = p
					farthestDistance = currentDistance
				end
			end
		end
		return farthestPlayer
	else
		return nil
	end
end
-- Return station closest to object
function closestStationTo(obj)
	if obj ~= nil and obj :isValid() then
		local closestDistance = 9999999
		closestStation = nil
		for sidx=1,#stationList do
			s = stationList[sidx]
			if s ~= nil and s:isValid() and s ~= obj then
				local currentDistance = distance(s,obj)
				if currentDistance < closestDistance then
					closestStation = s
					closestDistance = currentDistance
				end
			end
		end
		return closestStation
	else
		return nil
	end
end
-- Return the station farthest from object
function farthestStationTo(obj)
	if obj ~= nil and obj :isValid() then
		local farthestDistance = 0
		farthestStation = nil
		for sidx=1,#stationList do
			s = stationList[sidx]
			if s ~= nil and s:isValid() and s ~= obj then
				local currentDistance = distance(s,obj)
				if currentDistance > farthestDistance then
					farthestStation = s
					farthestDistance = currentDistance
				end
			end
		end
		return farthestStation
	else
		return nil
	end
end

-- spawn enemies based on player strength
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
	return playerShipScore
end
--[[-----------------------------------------------------------------
      Care and maintenance of repair crew directed by engineer or damage control
-----------------------------------------------------------------]]--
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		healthCheckCount = healthCheckCount + 1
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
--final page for victory or defeat on main streen. Station stats only for now
function endStatistics()
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
	destroyedStations = (startingFriendlyStations + startingNeutralStations) - survivedStations
	destroyedFriendlyStations = startingFriendlyStations - survivedFriendlyStations
	destroyedNeutralStations = startingNeutralStations - survivedNeutralStations
	enemyStationsSurvived = 0
	for _, station in pairs(enemyStationList) do
		if station:isValid() then
			enemyStationsSurvived = enemyStationsSurvived + 1
		end
	end
	destroyedEnemyStations = startingEnemyStations - enemyStationsSurvived
	gMsg = string.format("Stations: %i\t survived: %i\t destroyed: %i",(startingFriendlyStations + startingNeutralStations),survivedStations,destroyedStations)
	gMsg = gMsg .. string.format("\nFriendly Stations: %i\t survived: %i\t destroyed: %i",startingFriendlyStations,survivedFriendlyStations,destroyedFriendlyStations)
	gMsg = gMsg .. string.format("\nNeutral Stations: %i\t survived: %i\t destroyed: %i",startingNeutralStations,survivedNeutralStations,destroyedNeutralStations)
	gMsg = gMsg .. string.format("\n\n\n\nEnemy Stations: %i\t survived: %i\t destroyed: %i",startingEnemyStations,enemyStationsSurvived,enemyStationsSurvived)
--	gMsg = gMsg .. string.format("\n\n\n\nRequired missions completed: %i",requiredMissionCount)
	rankVal = survivedFriendlyStations/startingFriendlyStations*.6 + survivedNeutralStations/startingNeutralStations*.2 + (1-enemyStationsSurvived/startingEnemyStations)*.2
	if missionVictory then
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
	else
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
		if string.find(getScenarioVariation(),"Hunter") then
			gMsg = gMsg .. "\nPost Target Enemy Base Survival Rank: ".. rank
		else
			gMsg = gMsg .. "\nPost Home Base Destruction Rank: " .. rank
		end
		-- Yes, the ranking is more forgiving when defeated for these reasons:
		-- 1) With so many deaths on the station, leadership roles have opened up
		--    1a) Reciprocal: Harder to get promoted when you succeed with so many surviving competing officers
		-- 2) Simulation of whacky military promotion politics
		-- 3) Incentive to play the mission again
	end
	globalMessage(gMsg)
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
	if GMSpawnEnemyGroup == nil then
		GMSpawnEnemyGroup = "Spawn Enemies"
		addGMFunction(GMSpawnEnemyGroup,GMSpawnsEnemies)
	end
	if plotH ~= nil then
		plotH(delta)		--health of repair crew
	end
	if plotT ~= nil then
		plotT(delta)		--transports
	end
	if plotA ~= nil then
		plotA(delta)		--asteroids
	end
	if plot1 ~= nil then	--initial sets of enemies wave generation
		plot1(delta)
	end	
	if plot2 ~= nil then	--3 random missions
		plot2(delta)
	end	
	if plot3 ~= nil then	--3 random missions
		plot3(delta)
	end	
	if plot4 ~= nil then	-- simple - awaiting more development
		plot4(delta)
	end	
	if plotC ~= nil then	-- cargo transfer
		plotC(delta)
	end
end