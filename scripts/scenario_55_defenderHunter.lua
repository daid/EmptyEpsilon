-- Name: Defender Hunter
-- Description: Defend home station and hunt down enemies
--- 
--- Initially, you're tasked with defending your home base.  Over time, you'll discover more about the enemies harassing you and you'll be ordered to find and destroy the enemies responsible.  There may be various missions given along the way, but the enemy harassment will continue.  You must balance your two missions.
---
--- Designed for 1-8 cooperating player ships.  Randomization makes many details different for each game, but the primary goals remain the same.  Untimed variations can take an hour or longer for full mission completion.  Different sub-missions may be chosen by the players or will be chosen at random.  Achieving victory in a timed hunter variation is quite a challenge.  Like the Waves scenario, the enemies get harder over time.
---
--- Features: 
--- - Randomly selected player ship names based on type (not just the default call sign generation)
--- - Simple mix of variations based on time and difficulty
--- - Named stations with cargo type often related to name
--- - Some cargo based missions
--- - Mortal but replaceable at station repair crew
--- - Asteroids and nebulae in motion
--- - Intense pacing
--- - Player fighters may activate auto-cooling in engineering
---
--- Version 8 - 6Oct2018
-- Type: Replayable mission
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies
-- Variation[Timed Defender]: Victory if home station survives after 30 minutes
-- Variation[Timed Hunter]: Victory if target enemy base destroyed in 30 minutes
-- Variation[Easy Timed Defender]: Easy goals and/or enemies, victory if home station survives after 30 minutes
-- Variation[Easy Timed Hunter]: Easy goals and/or enemies, victory if target enemy base destroyed in 30 minutes
-- Variation[Hard Timed Defender]: Hard goals and/or enemies, victory if home station survives after 30 minutes
-- Variation[Hard Timed Hunter]: Hard goals and/or enemies, victory if target enemy base destroyed in 30 minutes

-- typical colors used in ship log
-- 	"Red"			Red									Enemies spotted
--	"Blue"			Blue
--	"Yellow"		Yellow								Maria Shrivner
--	"Magenta"		Magenta								Headquarters
--	"Green"			Green
--	"Cyan"			Cyan
--	"Black"			Black
--	"#555555"		Dark gray			"55,55,55"
--	"#ff4500"		Orange red			"255,69,0"		HMS Bounty
--	"#ff7f50"		Coral				"255,127,80"
--	"#5f9ea0"		Cadet blue			"95,158,160"	Paul Straight
--	"#4169e1"		Royal blue			"65,105,225"
--	"#8a2be2"		Blue violet			"138,43,226"
--	"#ba55d3"		Medium orchid		"186,85,211"	Maria's station
--	"#a0522d"		Sienna				"160,82,45"
--	"#b29650"		Arbitrary			"178,150,80"
--	"#556b2f"		Dark olive green	"85,107,47"		Home station
--	"#228b22"		Forest green		"34,139,34"
--	"#b22222"		Firebrick			"178,34,34"

require("utils.lua")

--[[-------------------------------------------------------------------
	Initialization routines
--]]-------------------------------------------------------------------
function init()
	wfv = "nowhere"		--wolf fence value - used for debugging
	setVariations()
	setMovingAsteroids()
	setMovingNebulae()
	setWormArt()
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
	GMDiagnosticOn = "Turn On Diagnostic"
	addGMFunction(GMDiagnosticOn,turnOnDiagnostic)
	interWave = 280			
	GMDelayNormalToSlow = "Delay normal to slow"
	addGMFunction(GMDelayNormalToSlow,delayNormalToSlow)
	goods = {}					--overall tracking of goods
	stationList = {}			--friendly and neutral stations
	friendlyStationList = {}	
	enemyStationList = {}
	tradeFood = {}				--stations that will trade food for other goods
	tradeLuxury = {}			--stations that will trade luxury for other goods
	tradeMedicine = {}			--stations that will trade medicine for other goods
	totalStations = 0
	friendlyStations = 0
	neutralStations = 0
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
	--gossip will have meaning for a future mission addition. Right now, it's just color
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
	homeDelivery = false
	infoPromised = false
	baseIntelligenceAvailable = false
	spinUpgradeAvailable = false
	hullUpgradeAvailable = false
	rotateUpgradeAvailable = false
	beamTimeUpgradeAvailable = false
	missionLength = 1
	initialOrderTimer = 3
	plot1 = initialOrders
	transportSpawnDelay = 10
	plotT = transportPlot
	plotH = healthCheck
	plotC = autoCoolant
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	healthCheckCount = 0
	plot4choices = {}
	table.insert(plot4choices,stationShieldDelay)
	table.insert(plot4choices,repairBountyDelay)
	table.insert(plot4choices,insertAgentDelay)
	wfv = "end of init"
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
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
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
-- dynamic universe functions: asteroids and nebulae in motion
function setMovingNebulae()
	movingNebulae = {}
	upperNeb = math.random(5,10)
	for nidx=1,upperNeb do
		xNeb = random(-100000,100000)
		yNeb = random(-100000,100000)
		mNeb = Nebula():setPosition(xNeb, yNeb)
		mNeb.angle = random(0,360)
		mNeb.travel = random(1,100)
		table.insert(movingNebulae,mNeb)
	end
	plotN = moveNebulae
end

function moveNebulae(delta)
	for nidx=1,#movingNebulae do
		mnx, mny = movingNebulae[nidx]:getPosition()
		angleChange = false
		if mnx < -100000 then
			angleChange = true
			movingNebulae[nidx].angle = random(0,180) + 270
		end
		if mnx > 100000 then
			angleChange = true
			movingNebulae[nidx].angle = random(90,270)
		end
		if mny < -100000 then
			angleChange = true
			movingNebulae[nidx].angle = random(0,180)
		end
		if mny > 100000 then
			angleChange = true
			movingNebulae[nidx].angle = random(180,360)
		end
		if angleChange then
			deltaNebx, deltaNeby = vectorFromAngle(movingNebulae[nidx].angle, movingNebulae[nidx].travel/10+20)
			movingNebulae[nidx]:setPosition(mnx+deltaNebx, mny+deltaNeby)
			movingNebulae.travel = random(1,100)
		else
			deltaNebx, deltaNeby = vectorFromAngle(movingNebulae[nidx].angle, movingNebulae[nidx].travel/10)
			movingNebulae[nidx]:setPosition(mnx+deltaNebx, mny+deltaNeby)
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
-- Organically (simulated asymetrically) grow stations from a central grid location
-- Order of creation: friendlies, planet, neutrals, black hole, generic enemies, leading enemies
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
		if #gossipSnippets > 0 then
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
	end
	--insert a planet
	tSize = 7
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
		if random(1,5) >= 2 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	aldx = (gRegion[sri][1] - (gbHigh/2))*gSize
	aldy = (gRegion[sri][2] - (gbHigh/2))*gSize
	alderaan= Planet():setPosition(aldx,aldy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription("Lush planet with only mild seasonal variations")
	stationAnet = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	stationAnet:setPosition(aldx,aldy+3000):setCallSign("ANet"):setDescription("Alderaan communications network hub")
	stationAnet.angle = 90
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	--place independent stations
	stationFaction = "Independent"
	fb = gp	--set faction boundary (between friendly and neutral)
	for j=1,30 do
		tSize = math.random(2,5)	--tack on to region size
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
	--insert a black hole
	tSize = 7
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
		if random(1,5) >= 2 then
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
	--place enemy stations (from generic pool)
	stationFaction = "Kraylor"
	fb = gp	--set faction boundary (between neutral and enemy)
	for j=1,5 do
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
	stationFaction = "Kraylor"
	fb = gp	--set faction boundary (between enemy and enemy leadership)
	for j=1,2 do
		tSize = math.random(4,6)	--tack on to region size
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
			if diagnostic then
				pStation:setCallSign(pStation:getCallSign() .. " Target")
			end
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--show adjacent list with a bunch of small stations for testing result purposes
	--[[--
	if #adjList >= 1 then
		for i=1,#adjList do
			tsix = adjList[i][1]
			tsiy = adjList[i][2]
			tsx = (tsix - 250)*gSize
			tsy = (tsiy - 250)*gSize
			SpaceStation():setTemplate("Small Station"):setCallSign(string.format("%i i:%i x:%i y:%i",sPool,i,tsix,tsiy)):setPosition(tsx,tsy)
		end
	end
	--]]--
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
	if comms_target == homeStation then
		if homeDelivery then
			if plot2name == "easyDelivery" or plot4name == "randomDelivery" then
				easyCargoAboard = false
				randomCargoAboard = false
				gi = 1
				repeat
					if goods[player][gi][1] == easyDeliverGood then
						if goods[player][gi][2] > 0 then
							easyCargoAboard = true
						end
					end
					if goods[player][gi][1] == randomDeliverGood then
						if goods[player][gi][2] > 0 then
							randomCargoAboard = true
						end
					end
					gi = gi + 1
				until(gi > #goods[player])
				if easyCargoAboard or randomCargoAboard then
					addCommsReply("Provide cargo", function()
						setCommsMessage("Do you have something for us?")
						if easyCargoAboard then
							homeStationEasyDelivery()					
						end
						if randomCargoAboard then
							homeStationRandomDelivery()
						end
					end)
				end
			end
		end
		if infoPromised then
			if spinUpgradeAvailable or beamTimeUpgradeAvailable or rotateUpgradeAvailable or baseIntelligenceAvailable or hullUpgradeAvailable then
				addCommsReply("Request promised information", function()
					setCommsMessage("Remind me what information I promised")
					if spinUpgradeAvailable then
						homeStationSpinUpgrade()
					end
					if beamTimeUpgradeAvailable then
						homeStationBeamTimeUpgrade()
					end
					if rotateUpgradeAvailable then
						homeStationRotateUpgrade()
					end
					if baseIntelligenceAvailable then
						homeStationBaseIntelligence()
					end
					if hullUpgradeAvailable then
						homeStationHullUpgrade()
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if comms_target == spinBase then
		spinStation()
	end
	if comms_target == beamTimeBase then
		beamTimeStation()
	end
	if comms_target == rotateBase then
		rotateStation()
	end
	if comms_target == baseInt1 then
		intelligenceStation()
	end
	if comms_target == baseInt2 then
		secondIntelligenceStation()
	end
	if comms_target == hullBase then
		hullStation()
	end
	if comms_target == shieldExpertStation then
		shieldExpertBase()
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

function homeStationEasyDelivery()
	addCommsReply(string.format("Provide %s as requested",easyDeliverGood), function()
		decrementPlayerGoods(easyDeliverGood)
		player.cargo = player.cargo + 1
		player:addReputationPoints(30)
		setCommsMessage("Thanks, we really needed that.\n\nI have some information for you. Decide which one you want")
		addCommsReply("Ship maneuver upgrade", function()
			plot2 = spinUpgradeStart
			setCommsMessage("Check back shortly and I'll tell you all about it")
		end)
		addCommsReply("Intelligence", function()
			plot2 = enemyBaseInfoStart
			setCommsMessage("Check back shortly and I'll tell you all about it")
		end)
	end)
end

function homeStationRandomDelivery()
	addCommsReply(string.format("Give %s as requested",randomDeliverGood), function()
		decrementPlayerGoods(randomDeliverGood)
		player.cargo = player.cargo + 1
		player:addReputationPoints(35)
		setCommsMessage(string.format("Thanks, we needed that %s.\n\nI have information for you. Decide which one you want",randomDeliverGood))
		addCommsReply(string.format("Upgrade %s to auto-rotate",homeStation:getCallSign()), function()
			plot4 = rotateUpgradeStart
			setCommsMessage("Check back in a bit and I'll tell you all about it")
		end)
		addCommsReply("Upgrade beam weapon cycle time", function()
			plot4 = beamTimeUpgradeStart
			setCommsMessage("Check back in a bit and I'll tell you all about it")
		end)
		addCommsReply("Upgrade hull damage capacity", function()
			plot4 = hullUpgradeStart
			setCommsMessage("Check back in a bit and I'll tell you all about it")
		end)
	end)
end

function homeStationSpinUpgrade()
	addCommsReply("What about that maneuver upgrade information you promised?", function()
		setCommsMessage(string.format("I hear %s can upgrade your maneuverability, but they need %s to do the job",spinBase:getCallSign(),spinGood))
		if spinReveal < 1 then spinReveal = 1 end
		addCommsReply(string.format("Where is %s?",spinBase:getCallSign()), function()
			setCommsMessage(string.format("%s is in sector %s",spinBase:getCallSign(),spinBase:getSectorName()))
			if spinReveal < 2 then spinReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply(string.format("Where might I find some %s?",spinGood), function()
			setCommsMessage(string.format("I think %s might have some",spinGoodBase:getCallSign()))
			if spinReveal < 3 then spinReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format("And where the heck is %s?",spinGoodBase:getCallSign()), function()
					setCommsMessage(string.format("My, my, you're quite inquisitive.\n%s is in sector %s",spinGoodBase:getCallSign(),spinGoodBase:getSectorName()))
					if spinReveal < 4 then spinReveal = 4 end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
	end)
end

function homeStationBeamTimeUpgrade()
	addCommsReply("You mentioned a beam weapon cycle time upgrade...", function()
		setCommsMessage(string.format("Station %s can do that for %s",beamTimeBase:getCallSign(),beamTimeGood))
		if beamTimeReveal < 1 then beamTimeReveal = 1 end
		addCommsReply(string.format("I've never heard of %s. Where is %s?",beamTimeBase:getCallSign(),beamTimeBase:getCallSign()), function()
			setCommsMessage(string.format("You haven't? I'm surprised. %s is in %s",beamTimeBase:getCallSign(),beamTimeBase:getSectorName()))
			if beamTimeReveal < 2 then beamTimeReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply(string.format("Can you direct me to a station with %s?",beamTimeGood), function()
			setCommsMessage(string.format("%s has %s *and* they have the best indigenous Kraylor honey you've ever tasted",beamTimeGoodBase:getCallSign(),beamTimeGood))
			if beamTimeReveal < 3 then beamTimeReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format("Sounds tasty. Where is %s?",beamTimeGoodBase:getCallSign()), function()
					setCommsMessage(string.format("It's in %s",beamTimeGoodBase:getSectorName()))
					if beamTimeReveal < 4 then beamTimeReveal = 4 end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
	end)
end

function homeStationRotateUpgrade()
	addCommsReply("Where's that station rotation upgrade information?", function()
		setCommsMessage(string.format("station %s has the technical knowledge but lacks the %s",rotateBase:getCallSign(),rotateGood))
		if rotateReveal < 1 then rotateReveal = 1 end
		addCommsReply(string.format("Where is station %s?",rotateBase:getCallSign()), function()
			setCommsMessage(string.format("%s is in %s",rotateBase:getCallSign(),rotateBase:getSectorName()))
			if rotateReveal < 2 then rotateReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		if difficulty < 2 then
			addCommsReply(string.format("Where could I get %s?",rotateGood), function()
				setCommsMessage(string.format("%s should have %s",rotateGoodBase:getCallSign(),rotateGood))
				if rotateReveal < 3 then rotateReveal = 3 end
				if difficulty < 1 then
					addCommsReply(string.format("Do you know where %s is located?",rotateGoodBase:getCallSign()), function()
						setCommsMessage(string.format("Yes, it's in %s",rotateGoodBase:getSectorName()))
						if rotateReveal < 4 then rotateReveal = 4 end
						addCommsReply("Back", commsStation)
					end)
				end
				addCommsReply("Back", commsStation)
			end)
		end
		addCommsReply("Back", commsStation)
	end)
end

function homeStationBaseIntelligence()
	addCommsReply("What about that intelligence information you promised?", function()
		setCommsMessage(string.format("I hear Marcy Sorenson just got back from an enemy scouting expedition. She was talking about enemy bases. She can probably tell you where some of these bases are located. She's based on %s",baseInt1:getCallSign()))
		plot2reminder = string.format("Talk with Marcy Sorenson on %s",baseInt1:getCallSign())
		addCommsReply("Back", commsStation)
	end)
end

function homeStationHullUpgrade()
	addCommsReply("Remember, you promised some ship hull upgrade information?", function()
		setCommsMessage(string.format("Oh yes, %s can upgrade your hull, but they want %s to do the job",hullBase:getCallSign(),hullGood))
		if hullReveal < 1 then hullReveal = 1 end
		addCommsReply(string.format("So, where is %s?",hullBase:getCallSign()), function()
			setCommsMessage(string.format("%s is in sector %s",hullBase:getCallSign(),hullBase:getSectorName()))
			if hullReveal < 2 then hullReveal = 2 end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply(string.format("Where could I find some %s?",hullGood), function()
			setCommsMessage(string.format("I think %s may have some",hullGoodBase:getCallSign()))
			if hullReveal < 3 then hullReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format("And just where is %s?",hullGoodBase:getCallSign()), function()
					setCommsMessage(string.format("If you must know, %s is in sector %s",hullGoodBase:getCallSign(),hullGoodBase:getSectorName()))
					if hullReveal < 4 then hullReveal = 4 end
					addCommsReply("Back", commsStation)
				end)
			end
			addCommsReply("Back", commsStation)
		end)
		addCommsReply("Back", commsStation)
	end)
end

function spinStation()
	if spinUpgradeAvailable then
		if not player.spinUpgrade then
			addCommsReply("Upgrade maneuverability", function()
				gi = 1
				spinUpgradePartQuantity = 0
				repeat
					if goods[player][gi][1] == spinGood then
						spinUpgradePartQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if spinUpgradePartQuantity > 0 then
					player.spinUpgrade = true
					decrementPlayerGoods(spinGood)
					player.cargo = player.cargo + 1
					player:setRotationMaxSpeed(player:getRotationMaxSpeed()*1.5)
					setCommsMessage("Upgraded maneuverability")
				else
					setCommsMessage(string.format("You need to bring some %s for the upgrade",spinGood))
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end

function beamTimeStation()
	if beamTimeUpgradeAvailable then
		if not player.beamTimeUpgrade then
			addCommsReply("Upgrade beam cycle time", function()
				tempBeam = psb[player:getTypeName()]
				if tempBeam == nil then
					setCommsMessage("Your ship type does not support a beam weapon upgrade.")
				else
					gi = 1
					beamTimeUpgradePartQuantity = 0
					repeat
						if goods[player][gi][1] == beamTimeGood then
							beamTimeUpgradePartQuantity = goods[player][gi][2]
						end
						gi = gi + 1
					until(gi > #goods[player])
					if beamTimeUpgradePartQuantity > 0 then
						player.beamTimeUpgrade = true
						decrementPlayerGoods(beamTimeGood)
						player.cargo = player.cargo + 1					
						for b=0,tempBeam-1 do
							tempRange = player:getBeamWeaponRange(b)
							newCycle = player:getBeamWeaponCycleTime(b) * .8
							tempDamage = player:getBeamWeaponDamage(b)
							tempArc = player:getBeamWeaponArc(b)
							tempDirection = player:getBeamWeaponDirection(b)
							player:setBeamWeapon(b,tempArc,tempDirection,tempRange,newCycle,tempDamage)
						end
						setCommsMessage("Beam cycle time reduced by 20%")
					else
						setCommsMessage(string.format("We require %s before we can upgrade your beam weapons",beamTimeGood))
					end
				end
			end)
		end
	end
end

function rotateStation()
	if rotateUpgradeAvailable then
		if not homeStationRotationEnabled then
			addCommsReply(string.format("Upgrade %s to auto-rotate",homeStation:getCallSign()), function()
				gi = 1
				rotateUpgradePartQuantity = 0
				repeat
					if goods[player][gi][1] == rotateGood then
						rotateUpgradePartQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if rotateUpgradePartQuantity > 0 then
					homeStationRotationEnabled = true
					decrementPlayerGoods(rotateGood)
					player.cargo = player.cargo + 1
					setCommsMessage(string.format("%s was just what we needed. The technical details have been transmitted to %s. The auto-rotation has begun",rotateGood,homeStation:getCallSign()))
				else
					setCommsMessage(string.format("You need to bring some %s for the upgrade",rotateGood))
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end

function intelligenceStation()
	addCommsReply("May I speak with Marcy Sorenson?", function()
		baseInt1Visit = true
		if baseInt2 ~= nil then
			setCommsMessage(string.format("She transferred to %s",baseInt2:getCallSign()))
			plot2reminder = string.format("Talk with Marcy Sorenson on %s",baseInt2:getCallSign())
			addCommsReply(string.format("Where exactly is %s?",baseInt2:getCallSign()), function()
				setCommsMessage(string.format("%s is in %s",baseInt2:getCallSign(),baseInt2:getSectorName()))
				plot2reminder = string.format("Talk with Marcy Sorenson on %s in %s",baseInt2:getCallSign(),baseInt2:getSectorName())
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		else
			setCommsMessage("This is Marcy. Whatcha want?")
			addCommsReply("Please tell me about the enemy bases found", function()
				for i=1,#enemyStationList do
					if enemyStationList[i]:isValid() then
						if enemyInt1 == nil then
							enemyInt1 = enemyStationList[i]
						elseif enemyInt2 == nil then
							enemyInt2 = enemyStationList[i]
							break
						end
					end
				end
				setCommsMessage(string.format("Sure. We found a couple of enemy stations in %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName()))
				plot2reminder = string.format("Investigate enemy bases in %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName())
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)
		end
	end)
end

function secondIntelligenceStation()
	if baseInt1Visit then
		addCommsReply("May I speak with Marcy Sorenson, please?", function()
			setCommsMessage("This is Marcy. Whatcha want?")
			addCommsReply("Please tell me about the enemy bases found", function()
				for i=1,#enemyStationList do
					if enemyStationList[i]:isValid() then
						if enemyInt1 == nil then
							enemyInt1 = enemyStationList[i]
						elseif enemyInt2 == nil then
							enemyInt2 = enemyStationList[i]
						elseif enemyInt3 == nil then
							enemyInt3 = enemyStationList[i]
						end
					end
				end
				setCommsMessage(string.format("Sure. We found some enemy stations in %s, %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName(),enemyInt3:getSectorName()))
				plot2reminder = string.format("Investigate enemy bases in %s, %s and %s",enemyInt1:getSectorName(),enemyInt2:getSectorName(),enemyInt3:getSectorName())
				addCommsReply("Back", commsStation)
			end)
			addCommsReply("Back", commsStation)				
		end)
	end
end

function hullStation()
	if hullUpgradeAvailable then
		if not player.hullUpgrade then
			addCommsReply("Upgrade hull damage capacity", function()
				gi = 1
				hullUpgradePartQuantity = 0
				repeat
					if goods[player][gi][1] == hullGood then
						hullUpgradePartQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if hullUpgradePartQuantity > 0 then
					player.hullUpgrade = true
					decrementPlayerGoods(hullGood)
					player.cargo = player.cargo + 1
					player:setHullMax(player:getHullMax() * 1.2)
					setCommsMessage("Upgraded hull capacity for damage by 20%")
				else
					setCommsMessage(string.format("We won't upgrade your hull until we have %s",hullGood))
				end
				addCommsReply("Back", commsStation)
			end)
		end
	end
end

function shieldExpertBase()
	if plot4 == giftForBeau then
		addCommsReply("Offer gift on behalf of Maria Shrivner", function()
			gi = 1
			giftQuantity = 0
			giftList = {}
			repeat
				if goods[player][gi][1] == "gold" then
					giftQuantity = giftQuantity + goods[player][gi][2]
					table.insert(giftList,"gold")
				end
				if goods[player][gi][1] == "platinum" then
					giftQuantity = giftQuantity + goods[player][gi][2]
					table.insert(giftList,"platinum")
				end
				if goods[player][gi][1] == "dilithium" then
					giftQuantity = giftQuantity + goods[player][gi][2]
					table.insert(giftList,"dilithium")
				end
				if goods[player][gi][1] == "tritanium" then
					giftQuantity = giftQuantity + goods[player][gi][2]
					table.insert(giftList,"tritanium")
				end
				if goods[player][gi][1] == "cobalt" then
					giftQuantity = giftQuantity + goods[player][gi][2]
					table.insert(giftList,"cobalt")
				end
				gi = gi + 1
			until(gi > #goods[player])
			if giftQuantity > 0 then
				beauGift = true
				gifti = math.random(1,#giftList)
				decrementPlayerGoods(giftList[gifti])
				player.Cargo = player.Cargo + 1
				setCommsMessage("Thanks. He's impressed with the gift to such a degree that he's speechless")
			else
				setCommsMessage("I know this couple (or former couple). Only gold, platinum, dilithium, tritanium or cobolt will work as a gift")
			end
			addCommsReply("Back", commsStation)
		end)
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
			addCommsReply("Back", commsStation)
		end)
	end
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format(" Time remaining: %.2f",gameTimeLimit)
			else
				oMsg = oMsg .. " no time limit"
			end
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
				oMsg = oMsg .. string.format(" wavetimer: %.2f danger value: %.1f",waveTimer,dangerValue)
			end
			if plot2name == nil or plot2 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot2: " .. plot2name
				if plot2name == "destroyef2" then
					oMsg = oMsg .. string.format(" ef2count: %i",ef2Count)
				end
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
				oMsg = oMsg .. string.format(" helpful warning timer: %.2f",helpfulWarningTimer)
			end
			if plotWname == nil or plotW == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplotw: " .. plotWname
			end
			if infoPromised then
				oMsg = oMsg .. "\nInfo promised"
				if spinUpgradeAvailable then
					oMsg = oMsg .. ", spin upgrade available"
				end
				if baseIntelligenceAvailable then
					oMsg = oMsg .. ", base intelligence available"
				end
				if hullUpgradeAvailable then
					oMsg = oMsg .. ", hull upgrade available"
				end
				if rotateUpgradeAvailable then
					oMsg = oMsg .. ", rotate upgrade available"
				end
				if beamTimeUpgradeAvailable then
					oMsg = oMsg .. ", beam time upgrade available"
				end
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
			oMsg = oMsg .. string.format("\nSupply drop: %s",comms_target.comms_data.services.supplydrop)
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
      First plot line
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
					p:addToShipLog(string.format("You are to protect your home base, %s, against enemy attack. Respond to other requests as you see fit",homeStation:getCallSign()),"Magenta")
					primaryOrders = string.format("Protect %s",homeStation:getCallSign())
					playSoundFile("sa_55_Commander1.wav")
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
			ntf = spawnEnemies(defx,defy,1.5,enemyStationList[i]:getFaction())
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
			enemy:orderAttack(p)
		end
		plot4 = destroyef4
	end
	helpfulWarningTimer = 90
	plot5 = helpfulWarning
	waveTimer = interWave
	if difficulty < 1 then
		dangerValue = .5
		dangerIncrement = .1
	elseif difficulty > 1 then
		dangerValue = 1
		dangerIncrement = .5
	else
		dangerValue = .8
		dangerIncrement = .2
	end
	plot1 = pressureWaves
end

function pressureWaves(delta)
	plot1name = "pressureWaves"
	if not homeStation:isValid() then
		missionVictory = false
		endStatistics()
		victory("Kraylor")
		return
	end
	if not targetEnemyStation:isValid() then
		missionVictory = true
		endStatistics()
		victory("Human Navy")
		return
	end
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		waveSpawned = false
		dangerValue = dangerValue + dangerIncrement
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if random(1,5) <= 2 then
					esx, esy = enemyStationList[i]:getPosition()
					ntf = spawnEnemies(esx,esy,dangerValue,enemyStationList[i]:getFaction())
					waveSpawned = true
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
			waveSpawned = true
			if random(1,5) >= 4 then
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(homeStation)
				end
			end
		end
		if random(1,5) <= 3 then
			p = closestPlayerTo(targetEnemyStation)
			esx, esy = targetEnemyStation:getPosition()
			px, py = p:getPosition()
			ntf = spawnEnemies((esx+px)/2,(esy+py)/2,dangerValue/2,targetEnemyStation:getFaction())
			waveSpawned = true
			if random(1,5) <= 2 then
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if random(1,5) <= 2 then
			p = closestPlayerTo(targetEnemyStation)
			px, py = p:getPosition()
			spx, spy = vectorFromAngle(random(0,360), random(30000, 40000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue/2, targetEnemyStation:getFaction())
			waveSpawned = true
			for _, enemy in ipairs(ntf) do
				enemy:orderAttack(p)
			end
		end
		if random(1,5) <= 1 then
			hsx, hsy = homeStation:getPosition()
			spx, spy = vectorFromAngle(random(0,360),random(30000,40000))
			ntf = spawnEnemies(hsx+spx,hsy+spy,dangerValue,targetEnemyStation:getFaction())
			waveSpawned = true
			if random(1,5) <= 3 then
				for _, enemy in ipairs(ntf) do
					enemy:orderFlyTowards(hsx,hsy)
				end
			end
		end
		if random(1,5) <= 1 then
			p = closestPlayerTo(targetEnemyStation)
			px, py = p:getPosition()
			nol = getObjectsInRadius(px, py, 30000)
			nearbyNebulae = {}
			for _, obj in ipairs(nol) do
				if string.find(obj:getTypeName(),"Nebula") then
					table.insert(nearbyNebulae,obj)
				end
			end
			if #nearbyNebulae > 0 then
				nx, ny = nearbyNebulae[math.random(1,#nearbyNebulae)]:getPosition()
				ntf = spawnEnemies(nx,ny,dangerValue,targetEnemyStation:getFaction())
				waveSpawned = true
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if not waveSpawned then
			p = closestPlayerTo(targetEnemyStation)
			px, py = p:getPosition()
			spawnAngle = random(0,360)
			spx, spy = vectorFromAngle(spawnAngle, random(15000,20000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
			spawnAngle = spawnAngle + random(60,180)
			spx, spy = vectorFromAngle(spawnAngle, random(20000,25000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
			for _, enemy in ipairs(ntf) do
				enemy:orderFlyTowards(px, py)
			end
			spawnAngle = spawnAngle + random(60,120)
			spx, spy = vectorFromAngle(spawnAngle, random(25000,30000))
			ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
			for _, enemy in ipairs(ntf) do
				enemy:orderAttack(p)
			end
		end
		waveTimer = delta + interWave + dangerValue*10 + random(1,60)
	end
end
--[[-----------------------------------------------------------------
    Plot 2 Easy delivery, improve maneuverability or get base intelligence
-----------------------------------------------------------------]]--
function destroyef2(delta)
	plot2name = "destroyef2"
	ef2Count = 0
	for _, enemy in ipairs(ef2) do
		if enemy:isValid() then
			ef2Count = ef2Count + 1
		end
	end
	if ef2Count == 0 then
		easyDeliveryTimer = 15
		plot2 = easyDelivery
		homeDelivery = true
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end
--required cargo should be easy to find, if expensive in reputation to get
function easyDelivery(delta)
	plot2name = "easyDelivery"
	easyDeliveryTimer = easyDeliveryTimer - delta
	if easyDeliveryTimer < 0 then
		if easyDeliveryMsg == nil then
			p = closestPlayerTo(homeStation)
			if #goods[homeStation] > 0 then
				for i=2,#stationList do
					easyStation = stationList[i]
					gi = 1
					repeat
						easyDeliverGood = goods[easyStation][gi][1]
						gj = 1
						matchAway = false
						repeat			
							if easyDeliverGood == goods[homeStation][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[homeStation])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[easyStation])
					if not matchAway then break end
				end
			else
				matchAway = false
			end
			if matchAway then
				plot2 = nil
				plot2reminder = nil
			else
				p:addToShipLog(string.format("[%s] We need some goods of type %s. Can you help? I hear %s has some",homeStation:getCallSign(),easyDeliverGood,easyStation:getCallSign()),"85,107,47")
				plot2reminder = string.format("Bring %s to %s. Possible source: %s",easyDeliverGood,homeStation:getCallSign(),easyStation:getCallSign())
				playSoundFile("sa_55_Manager1.wav")
			end
			easyDeliveryMsg = "sent"
		end
	end
end

function spinUpgradeStart(delta)
	plot2name = "spinUpgradeStart"
	infoPromised = true
	spinUpgradeAvailable = false
	plot2reminder = "Get ship maneuver upgrade"
	if pickSpinBase == nil then
		p = closestPlayerTo(homeStation)
		for i=13,#stationList do
			if stationList[i]:isValid() then
				candidate = stationList[i]
				if #goods[candidate] > 0 then
					gi = 1
					repeat
						if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
							spinBase = candidate	--last valid station in list without food or medicine
						end
						gi = gi + 1
					until(gi > #goods[candidate])
				end
			end
		end
		if diagnostic then
			p:addToShipLog(string.format("Final choice: %s previous: %s",spinBase:getCallSign(),candidate:getCallSign()),"Blue")
		end
		pickSpinBase = "done"
		plot2 = pickSpinGood
	end
end

function pickSpinGood(delta)
	plot2name = "pickSpinGood"
	if pickSpinGoodBase == nil then
		p = closestPlayerTo(homeStation)
		for i=14,#stationList do
			if stationList[i]:isValid() then
				candidate = stationList[i]
				if diagnostic then
					p:addToShipLog(string.format("valid: %s index: %i",candidate:getCallSign(),i),"Blue")
				end
				if #goods[candidate] > 0 then
					spinGoodBase = candidate
					if diagnostic then
						p:addToShipLog(string.format("has %i goods",#goods[candidate]),"Blue")
					end
					gi = 1
					repeat
						spinGood = goods[spinGoodBase][gi][1]
						if diagnostic then
							p:addToShipLog(string.format("top of spin good base good loop. gi: %i good: %s",gi,spinGood),"Blue")
						end
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
					if not matchAway then break end
				end
			end
		end
		if diagnostic then
			p:addToShipLog(string.format("spin base: %s spin good base: %s spin good: %s",spinBase:getCallSign(),spinGoodBase:getCallSign(),spinGood),"Blue")
		end
		plot2 = cleanupSpinners
		spinReveal = 0
		spinUpgradeAvailable = true
		pickSpinGoodBase = "done"
	end
end

function cleanupSpinners(delta)
	plot2name = "cleanupSpinners"
	noSpinCount = 0
	for pidx=1,8 do
		pc = getPlayerShip(pidx)
		if pc ~= nil and pc:isValid() then
			if not pc.spinUpgrade then
				noSpinCount = noSpinCount + 1
			end
		end
	end
	if noSpinCount == 0 then
		plot2reminder = nil
		plot2 = warpJamLineStart
		warpJamLineTimer = 300
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function enemyBaseInfoStart(delta)
	plot2name = "enemyBaseInfoStart"
	baseIntelligenceAvailable = true
	infoPromised = true
	rvfCount = 0
	rvnCount = 0
	baseInt1Visit = false
	for i=4,12 do
		if stationList[i]:isValid() then
			rvfCount = rvfCount + 1
		end
	end
	for i=13,30 do
		if stationList[i]:isValid() then
			rvnCount = rvnCount + 1
		end
	end
	if rvfCount > 0 then
		repeat
			baseInt1 = stationList[math.random(4,12)]
		until(baseInt1:isValid())
		if rvnCount > 1 then
			repeat
				baseInt2 = stationList[math.random(13,30)]
			until(baseInt2:isValid())
		end
	end
	plot2reminder = nil
	plot2 = warpJamLineStart
	warpJamLineTimer = 300
end

function warpJamLineStart(delta)
	plot2name = "warpJamLineStart"
	warpJamLineTimer = warpJamLineTimer - delta
	if warpJamLineTimer < 0 then
		p = closestPlayerTo(targetEnemyStation)
		esx, esy = targetEnemyStation:getPosition()
		cpx, cpy = p:getPosition()
		wjCenter = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderFlyTowardsBlind(cpx,cpy)
		wjP1 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderFlyTowardsBlind(cpx+20000,cpy+20000)
		wjP2 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderFlyTowardsBlind(cpx-20000,cpy-20000)
		wjP3 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderFlyTowardsBlind(cpx+20000,cpy-20000)
		wjP4 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderFlyTowardsBlind(cpx-20000,cpy+20000)
		wjCenterE1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjP1E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP2E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP3E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP4E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		plot2 = warpJamLineSpring
	end
end

function warpJamLineSpring(delta)
	plot2name = "warpJamLineSpring"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() and wjCenter:isValid() then
			if distance(p,wjCenter) < 10000 then
				plot2 = warpJamLineRelease
				break
			end
		end
	end
	if wjCenter:isValid() then
		if distance(wjCenter,homeStation) < 10000 then
			plot2 = warpJamLineRelease
		end
	else
		plot2 = warpJamLineRelease
	end
end

function warpJamLineRelease(delta)
	plot2name = "warpJamLineRelease"
	if wjCenter:isValid() then
		wx, wy = wjCenter:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjCenter:orderStandGround()
	end
	if wjP1:isValid() then
		wx, wy = wjP1:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP1:orderStandGround()
	end
	if wjP2:isValid() then
		wx, wy = wjP2:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP2:orderStandGround()
	end
	if wjP3:isValid() then
		wx, wy = wjP3:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP3:orderStandGround()
	end
	if wjP4:isValid() then
		wx, wy = wjP4:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP4:orderStandGround()
	end
	startAngle = random(0,360)
	hsx, hsy = homeStation:getPosition()
	wjAdvx, wjAdvy = vectorFromAngle(startAngle,random(25000,30000))
	wjAdv1ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	angle2 = startAngle + random(60,120)
	wjAdvx, wjAdvy = vectorFromAngle(angle2,random(30000,35000))
	wjAdv2ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	angle3 = angle2 + random(60,120)
	wjAdvx, wjAdvy = vectorFromAngle(angle3,random(35000,40000))
	wjAdv3ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	for _, enemy in ipairs(wjAdv2ef) do
		enemy:orderAttack(homeStation)
	end
	for _, enemy in ipairs(wjAdv3ef) do
		enemy:orderFlyTowards(hsx, hsy)
	end
	plot2name = nil
	plot2 = nil
end
--[[-----------------------------------------------------------------
    Plot 3 Development of intelligence over time
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
		hunterTransition1Timer = timedIntelligenceInterval
		plot3 = hunterTransition1
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function hunterTransition1(delta)
	plot3name = "hunterTransition1"
	hunterTransition1Timer = hunterTransition1Timer - delta
	if hunterTransition1Timer < 0 then
		iuMsg = string.format("The enemy activity has been traced back to enemy bases nearby. Find these bases and stop these incursions. Threat Assessment: %.1f",dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Find enemy bases. Stop enemy incursions. TA:%.1f",dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v2
	end
end

function destroyef3v2(delta)
	plot3name = "destroyef3v2"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition2Timer = timedIntelligenceInterval
		plot3 = hunterTransition2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function hunterTransition2(delta)
	plot3name = "hunterTransition2"
	hunterTransition2Timer = hunterTransition2Timer - delta
	if hunterTransition2Timer < 0 then
		iuMsg = string.format("Kraylor prefect Ghalontor has moved to one of the enemy stations. Destroy that station and the Kraylor incursion will crumble. Threat Assessment: %.1f",dangerValue)
		playSoundFile("sa_55_Commander2.wav")
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base with Prefect Ghalontor aboard. TA:%.1f",dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v3
	end
end

function destroyef3v3(delta)
	plot3name = "destroyef3v3"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition3Timer = timedIntelligenceInterval
		plot3 = hunterTransition3
	end
end

function hunterTransition3(delta)
	plot3name = "hunterTransition3"
	hunterTransition3Timer = hunterTransition3Timer - delta
	if hunterTransition3Timer < 0 then
		for i=4,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt4 == nil then
					enemyInt4 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt4 == nil then
			enemyInt4 = targetEnemyStation
		end
		iuMsg = string.format("Enemy base located in %s. Others expected nearby. Threat Assessment: %.1f",enemyInt4:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s with Prefect Ghalontor aboard. TA:%.1f",enemyInt4:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v4
	end
end

function destroyef3v4(delta)
	plot3name = "destroyef3v4"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition4Timer = timedIntelligenceInterval
		plot3 = hunterTransition4
	end
end

function hunterTransition4(delta)
	plot3name = "hunterTransition4"
	hunterTransition4Timer = hunterTransition4Timer - delta
	if hunterTransition4Timer < 0 then
		for i=5,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt5 == nil then
					enemyInt5 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt5 == nil then
			enemyInt5 = targetEnemyStation
		end
		iuMsg = string.format("Another enemy base located in %s. Others expected nearby. Threat Assessment: %.1f",enemyInt5:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s or %s with Prefect Ghalontor aboard. TA:%.1f",enemyInt4:getSectorName(),enemyInt5:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v5
	end
end

function destroyef3v5(delta)
	plot3name = "destroyef3v5"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition5Timer = timedIntelligenceInterval
		plot3 = hunterTransition5
	end
end

function hunterTransition5(delta)
	plot3name = "hunterTransition5"
	hunterTransition5Timer = hunterTransition5Timer - delta
	if hunterTransition5Timer < 0 then
		for i=6,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt6 == nil then
					enemyInt6 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt6 == nil then
			enemyInt6 = targetEnemyStation
		end
		iuMsg = string.format("Another enemy base located in %s. Others expected nearby. Threat Assessment: %.1f",enemyInt6:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s, %s or %s with Prefect Ghalontor aboard. TA:%.1f",enemyInt4:getSectorName(),enemyInt5:getSectorName(),enemyInt6:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v6
	end
end

function destroyef3v6(delta)
	plot3name = "destroyef3v6"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition6Timer = timedIntelligenceInterval
		plot3 = hunterTransition6
	end
end

function hunterTransition6(delta)
	plot3name = "hunterTransition6"
	hunterTransition6Timer = hunterTransition6Timer - delta
	if hunterTransition6Timer < 0 then
		iuMsg = string.format("Another enemy base located in %s. Others expected nearby: Threat Assessment: %.1f",targetEnemyStation:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base possibly near %s, %s, %s or %s with Prefect Ghalontor aboard. TA:%.1f",targetEnemyStation:getSectorName(),enemyInt4:getSectorName(),enemyInt5:getSectorName(),enemyInt6:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v7
	end
end

function destroyef3v7(delta)
	plot3name = "destroyef3v7"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition7Timer = timedIntelligenceInterval
		plot3 = hunterTransition7
	end
end

function hunterTransition7(delta)
	plot3name = "hunterTransition7"
	hunterTransition7Timer = hunterTransition7Timer - delta
	if hunterTransition7Timer < 0 then
		iuMsg = string.format("We confirmed Prefect Ghalontor is aboard enemy station %s in %s. Threat Assessment: %.1f",targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName(),dangerValue)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format("Destroy enemy base %s in %s. TA:%.1f",targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v8
	end
end

function destroyef3v8(delta)
	plot3namename = "destroyef3v8"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		plot3 = nil
	end
end
--[[-----------------------------------------------------------------
    Plot 4 station rotate upgrade or beam time upgrade or hull upgrade
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
		randomDeliveryTimer = 45
		plot4 = randomDelivery
		homeDelivery = true
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end

function randomDelivery(delta)
	plot4name = "randomDelivery"
	randomDeliveryTimer = randomDeliveryTimer - delta
	if randomDeliveryTimer < 0 then
		if randomDeliveryMsg == nil then
			p = closestPlayerTo(homeStation)
			if #goods[homeStation] > 0 then
				repeat
					repeat
						randomDeliverStation = stationList[math.random(6,#stationList)]
					until(randomDeliverStation:isValid())
					gi = 1
					repeat
						randomDeliverGood = goods[randomDeliverStation][gi][1]
						gj = 1
						matchAway = false
						repeat			
							if randomDeliverGood == goods[homeStation][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[homeStation])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[randomDeliverStation])
				until(not matchAway)
			else
				matchAway = false
			end
			if matchAway then
				plot4reminder = nil
				plot4delay = 100
				plot4 = delayef4v2
			else
				p:addToShipLog(string.format("[%s] We are running low on goods of type %s. Can you help? %s in %s should have some",homeStation:getCallSign(),randomDeliverGood,randomDeliverStation:getCallSign(),randomDeliverStation:getSectorName()),"85,107,47")
				plot4reminder = string.format("Bring %s to %s. Possible source: %s in %s",randomDeliverGood,homeStation:getCallSign(),randomDeliverStation:getCallSign(),randomDeliverStation:getSectorName())
				playSoundFile("sa_55_Manager2.wav")
			end
			randomDeliveryMsg = "sent"
		end
	end
end

function rotateUpgradeStart(delta)
	plot4name = "rotateUpgradeStart"
	infoPromised = true
	homeStationRotationEnabled = false
	rotateUpgradeAvailable = false
	plot4reminder = string.format("Upgrade %s to rotate",homeStation:getCallSign())
	if pickRotateBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				if #goods[candidate] > 0 then
					gi = 1
					repeat
						if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
							rotateBase = candidate
						end
						gi = gi + 1
					until(gi > #goods[candidate])
				end
			end
		until(rotateBase ~= nil)
		pickRotateBase = "done"
		plot4 = pickRotateGood
	end
end

function pickRotateGood(delta)
	plot4name = "pickRotateGood"
	if pickRotateGoodBase == nil then
		matchAway = true
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= rotateBase then
				if #goods[candidate] > 0 then
					rotateGoodBase = candidate
					gi = 1
					repeat
						rotateGood = goods[rotateGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if rotateGood == "food" or rotateGood == "medicine" or rotateGood == goods[rotateBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[rotateBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[rotateGoodBase])
				end
			end
		until(not matchAway)
		plot4delay = 100
		plot4 = delayef4v2
		rotateReveal = 0
		rotateUpgradeAvailable = true
		pickRotateGoodBase = "done"
	end
end

function beamTimeUpgradeStart(delta)
	plot4name = "beamTimeUpgradeStart"
	infoPromised = true
	beamTimeUpgradeAvailable = false
	plot4reminder = "Get beam cycle time upgrade"
	if pickBeamTimeBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
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
		until(beamTimeBase ~= nil)
		pickBeamTimeBase = "done"
		plot4 = pickBeamTimeGood
	end
end

function pickBeamTimeGood(delta)
	plot4name = "pickBeamTimeGood"
	if pickBeamTimeGoodBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
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
		until(not matchAway)
		plot4 = cleanUpBeamTimers
		beamTimeReveal = 0
		beamTimeUpgradeAvailable = true
		pickBeamTimeGoodBase = "done"
	end
end

function cleanUpBeamTimers(delta)
	plot4name = "cleanUpBeamTimers"
	noBeamTimeCount = 0
	for pidx=1,8 do
		pc = getPlayerShip(pidx)
		if pc ~= nil and pc:isValid() then
			if not pc.beamTimeUpgrade then
				noBeamTimeCount = noBeamTimeCount + 1
			end
		end
	end
	if noBeamTimeCount == 0 then
		plot4reminder = nil
		plot4name = nil
		plot4delay = 100
		plot4 = delayef4v2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end	
end

function hullUpgradeStart(delta)
	plot4name = "hullUpgradeStart"
	infoPromised = true
	hullUpgradeAvailable = false
	plot4reminder = "Get hull upgrade"
	if pickHullBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				if #goods[candidate] > 0 then
					gi = 1
					repeat
						if goods[candidate][gi][1] ~= "food" and goods[candidate][gi][1] ~= "medicine" then
							hullBase = candidate
						end
						gi = gi + 1
					until(gi > #goods[candidate])
				end
			end
		until(hullBase ~= nil)
		pickHullBase = "done"
		plot4 = pickHullGood
	end
end

function pickHullGood(delta)
	plot4name = "pickHullGood"
	if pickHullGoodBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= hullBase then
				if #goods[candidate] > 0 then
					hullGoodBase = candidate
					gi = 1
					repeat
						hullGood = goods[hullGoodBase][gi][1]
						matchAway = false
						gj = 1
						repeat
							if hullGood == "food" or hullGood == "medicine" or hullGood == goods[hullBase][gj][1] then
								matchAway = true
								break
							end
							gj = gj + 1
						until(gj > #goods[hullBase])
						if not matchAway then break end
						gi = gi + 1
					until(gi > #goods[hullGoodBase])
				end
			end
		until(not matchAway)
		plot4 = cleanUpHullers
		hullReveal = 0
		hullUpgradeAvailable = true
		pickhullGoodBase = "done"
	end
end

function cleanUpHullers(delta)
	plot4name = "cleanUpHullers"
	noHullCount = 0
	for pidx=1,8 do
		pc = getPlayerShip(pidx)
		if pc ~= nil and pc:isValid() then
			if not pc.hullUpgrade then
				noHullCount = noHullCount + 1
			end
		end
	end
	if noHullCount == 0 then
		plot4reminder = nil
		plot4delay = 100
		plot4 = delayef4v2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end	
end

function delayef4v2(delta)
	plot4name = "delayef4v2"
	plot4delay = plot4delay - delta
	if plot4delay < 0 then
		p = closestPlayerTo(targetEnemyStation)
		px, py = p:getPosition()
		ambushAngle = random(0,360)
		a1x, a1y = vectorFromAngle(ambushAngle,random(30000,40000))
		ef4v2 = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ef4v2) do
			enemy:orderAttack(p)
		end
		a1x, a1y = vectorFromAngle(ambushAngle+random(60,120),random(30000,40000))
		ntf = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(p)
			table.insert(ef4v2,enemy)
		end
		a1x, a1y = vectorFromAngle(ambushAngle+random(180,300),random(30000,40000))
		ntf = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(p)
			table.insert(ef4v2,enemy)
		end
		plot4 = destroyef4v2
	end
end
-- random plot 4 development after enemy fleet for plot 4 version 2 is destroyed
function destroyef4v2(delta)
	plot4name = "destroyef4v2"
	ef4Count = 0
	for _, enemy in ipairs(ef4v2) do
		if enemy:isValid() then
			ef4Count = ef4Count + 1
		end
	end
	if ef4Count == 0 then
		choooseNextPlot4line()
	end
end

function choooseNextPlot4line()
	plot4reminder = nil
	if #plot4choices > 0 then
		p4c = math.random(1,#plot4choices)
		plot4 = plot4choices[p4c]
		table.remove(plot4choices,p4c)
		plot4delayTimer = random(40,120)
	else
		plot4 = nil
	end
end

function insertAgentDelay(delta)
	plot4name = "insertAgentDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Agent Paul Straight has information on enemies in the area and a proposal. Pick him and his equipment up at station %s",homeStation:getCallSign()),"Magenta")
				plot4reminder = string.format("Get Paul Straight at station %s",homeStation:getCallSign())
			end
		end
		plot4 = getAgentStraight
	end
end

function getAgentStraight(delta)
	plot4name = "getAgentStraight"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() and p:isDocked(homeStation) then
			p.straight = true
			if #enemyStationList > 0 then
				for eidx=1,#enemyStationList do
					if enemyStationList[eidx]:isValid() then
						insertEnemyStation = enemyStationList[eidx]
						break
					end
				end
			end
			p:addToShipLog(string.format("[Paul Straight] I've been studying enemy station %s in %s: traffic patterns, communication traffic, energy signature, etc. I've built a specialized short range transporter that should be able to beam me onto the station through their shields. I need to get refined readings from 20 units or closer for final calibration. Please take me to within 20 units of %s",insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName(),insertEnemyStation:getCallSign()),"#5f9ea0")
			plot4reminder = string.format("Take Paul Straight to within 20U of %s in %s",insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName())
			plot4 = scanEnemyStation
			break
		end
	end
end

function scanEnemyStation(delta)
	plot4name = "scanEnemyStation"
	if insertEnemyStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if distance(p,insertEnemyStation) <= 20000 then
					insertRunDelayTimer = 15
					p:addToShipLog("[Paul Straight] I've got my readings. Let me calibrate the transporter","#5f9ea0")
					if p:hasPlayerAtPosition("Helms") then
						inRangeMsg = "inRangeMsg"
						p:addCustomMessage("Helms",inRangeMsg,"[Paul Straight] The ship is in range. I completed my scans. Thank you")
					end
					if p:hasPlayerAtPosition("Tactical") then
						inRangeMsgTactical = "inRangeMsgTactical"
						p:addCustomMessage("Tactical",inRangeMsgTactical,"[Paul Straight] The ship is in range. I completed my scans. Thank you")
					end
					plot4 = insertRunDelay
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				p:addToShipLog("[Paul Straight] It's too bad the station was destroyed","#5f9ea0")
				choooseNextPlot4line()
				break
			end
		end
	end
end

function insertRunDelay(delta)
	plot4name = "insertRunDelay"
	insertRunDelayTimer = insertRunDelayTimer - delta
	if insertRunDelayTimer < 0 then
		if insertEnemyStation:isValid() then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.straight then
					p:addToShipLog(string.format("[Paul Straight] My transporter is ready. I've disguised myself as a Kraylor technician. I need you to take the ship within 2.5U of %s. You don't need to defeat any patrols, but there might be some enemy interest in your ship flying so close to the station. After I am aboard %s, I will gether intelligence and transmit it back. I'm ready to proceed",insertEnemyStation:getCallSign(),insertEnemyStation:getCallSign()),"#5f9ea0")
					plot4reminder = string.format("Get ship within 2.5U of %s in %s to secretly transport Paul Straight",insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName())
					plot4 = insertRun
					break
				end
			end
		else
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.straight then
					p:addToShipLog("[Paul Straight] It's too bad the station was destroyed","#5f9ea0")
					choooseNextPlot4line()
					break
				end
			end
		end
	end
end

function insertRun(delta)
	plot4name = "insertRun"
	if insertEnemyStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if distance(p,insertEnemyStation) <= 2500 then
					if p:hasPlayerAtPosition("Science") then
						straightTransportedMsg = "straightTransportedMsg"
						p:addCustomMessage("Science",straightTransportedMsg,string.format("Paul Straight has transported aboard %s",insertEnemyStation:getCallSign()))
					end
					if p:hasPlayerAtPosition("Operations") then
						straightTransportedMsgOps = "straightTransportedMsgOps"
						p:addCustomMessage("Operations",straightTransportedMsgOps,string.format("Paul Straight has transported aboard %s",insertEnemyStation:getCallSign()))
					end
					plot4 = resultDelay
					plot4reminder = string.format("Await intelligence results from Paul Straight on %s",insertEnemyStation:getCallSign())
					resultDelayTimer = random(30,60)
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				p:addToShipLog("[Paul Straight] It's too bad the station was destroyed","#5f9ea0")
				choooseNextPlot4line()
				break
			end
		end
	end
end

function resultDelay(delta)
	plot4name = "resultDelay"
	if insertEnemyStation:isValid() then
		resultDelayTimer = resultDelayTimer - delta
		if resultDelayTimer < 0 then
			locationResultMsg = "[Paul Straight] I discovered the location of the enemy bases in the area:"
			for eidx=1,#enemyStationList do
				if enemyStationList[eidx]:isValid() then
					locationResultMsg = locationResultMsg .. string.format("\n%s in %s",enemyStationList[eidx]:getCallSign(),enemyStationList[eidx]:getSectorName())
				end
			end
			p = closestPlayerTo(insertEnemyStation)
			p:addToShipLog(locationResultMsg,"#5f9ea0")
			resultDelay2Timer = random(120,240)
			plot4 = resultDelay2
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function resultDelay2(delta)
	plot4name = "resultDelay2"
	if insertEnemyStation:isValid() then
		resultDelay2Timer = resultDelay2Timer - delta
		if resultDelay2Timer < 0 then
			p = closestPlayerTo(insertEnemyStation)
			p:addToShipLog(string.format("[Paul Straight] Prefect Ghalantor is on station %s. Wait, someone is coming...",targetEnemyStation:getCallSign()),"#5f9ea0")
			straightExecutionTimer = random(40,80)
			plot4 = straightExecution
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function straightExecution(delta)
	plot4name = "straightExecution"
	if insertEnemyStation:isValid() then
		straightExecutionTimer = straightExecutionTimer - delta
		if straightExecutionTimer < 0 then
			p = closestPlayerTo(insertEnemyStation)
			insertEnemyStation:sendCommsMessage(p,"We discovered your perfidious spy aboard our station. He will be executed for his treasonous activities")
			plot4 = agentDemise
			agentDemiseTimer = random (40,80)
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function agentDemise(delta)
	plot4name = "agentDemise"
	if insertEnemyStation:isValid() then
		agentDemiseTimer = agentDemiseTimer - delta
		if agentDemiseTimer < 0 then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() and p.straight then
					if p:hasPlayerAtPosition("Science") then
						fatalMsg = "fatalMsg"
						p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
					end
					if p:hasPlayerAtPosition("Operations") then
						fatalMsgOps = "fatalMsgOps"
						p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
					end
				end
			end
			choooseNextPlot4line()
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,"Lifesign telemetry from Paul Straight's equipment has ceased")
				end
			end
		end
		choooseNextPlot4line()
	end
end

function repairBountyDelay(delta)
	plot4name = "repairBountyDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		hx, hy = homeStation:getPosition()
		ex, ey = targetEnemyStation:getPosition()
		bx, by = vectorFromAngle(random(0,360),6000)
		hmsBounty = CpuShip():setFaction("Human Navy"):setTemplate("Stalker Q7"):setScanned(true)
		hmsBounty:setSystemHealth("warp", -0.5):setCommsScript(""):setCommsFunction(commsShip)
		hmsBounty:setSystemHealth("impulse", 0.5):setCallSign("HMS Bounty"):orderStandGround()
		hmsBounty:setSystemHealth("jumpdrive", -0.5):setPosition(((hx+ex)/2)+bx,((hy+ey)/2)+by)
		hmsBounty.repaired = false
		p = closestPlayerTo(hmsBounty)
		p:addToShipLog(string.format("[HMS Bounty] We stole a Kraylor ship, but were damaged during the escape. Can you help? We are in %s",hmsBounty:getSectorName()),"#ff4500")
		plot4reminder = string.format("Help HMS Bounty in %s",hmsBounty:getSectorName())
		ntf = spawnEnemies((hx+ex)/2,(hy+ey)/2,dangerValue,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(hmsBounty)
		end
		plot4 = repairBounty
	end
end

function repairBounty(delta)
	p = closestPlayerTo(hmsBounty)
	if hmsBounty:isValid() then
		if distance(p,hmsBounty) < 2500 then
			p:addToShipLog("[HMS Bounty] Please ask your engineer to transport a spare repair technician to help with repairs","#ff4500")
			if p:hasPlayerAtPosition("Engineering") then
				transportRepairTechnicianButton = "transportRepairTechnicianButton"
				p:addCustomButton("Engineering",transportRepairTechnicianButton,"Transport technician",transportRepairTechnician)
			end
			if p:hasPlayerAtPosition("Engineering+") then
				transportRepairTechnicianButtonPlus = "transportRepairTechnicianButtonPlus"
				p:addCustomButton("Engineering+",transportRepairTechnicianButtonPlus,"Transport technician",transportRepairTechnician)
			end
			p.transportButton = true
			plot4 = nil
		end
	else
		p:addToShipLog("HMS Bounty has been destroyed","Magenta")
		plot4 = nil
		plot4reminder = nil
	end
end

function transportRepairTechnician()
	hmsBounty:setSystemHealth("warp",1)
	hmsBounty:setSystemHealth("impulse",1)
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.transportButton then
				if transportRepairTechnicianButton ~= nil then
					p:removeCustom(transportRepairTechnicianButton)
				end
				if transportRepairTechnicianButtonPlus ~= nil then
					p:removeCustom(transportRepairTechnicianButtonPlus)
				end
				p:addToShipLog("[HMS Bounty] Our engines have been repaired. We stand ready to assist","#ff4500")
			end
		end
	end
	choooseNextPlot4line()
end

function stationShieldDelay(delta)
	plot4name = "stationShieldDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				shieldExpertStation = candidate
			end
		until(shieldExpertStation ~= nil)
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("Intelligence analysis shows research on the network that could double the shield strength of station %s. The analysis shows that the technical expert can be found on station %s in sector %s",homeStation:getCallSign(),shieldExpertStation:getCallSign(),shieldExpertStation:getSectorName()),"Magenta")
			end
		end
		playSoundFile("sa_55_Commander3.wav")
		plot4reminder = string.format("Find shield expert at station %s in %s",shieldExpertStation:getCallSign(),shieldExpertStation:getSectorName())
		plot4 = visitShieldExpertStation
	end
end

function visitShieldExpertStation(delta)
	plot4name = "visitShieldExpertStation"
	if shieldExpertTransport == nil then
		repeat
			candidate = transportList[math.random(1,#transportList)]
			if candidate ~= nil and candidate:isValid() then
				shieldExpertTransport = candidate
			end
		until(shieldExpertTransport ~= nil)
	end
	if shieldExpertStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:isDocked(shieldExpertStation) then
					p:addToShipLog(string.format("We heard you were looking for our former shield maintenance technician, Maria Shrivner who's been publishing hints about advances in shield technology. We've been looking for her. We only just found out that she left the station after a severe romantic breakup with her supervisor. She took a job on a freighter %s which was last reported in %s",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName()),"#ba55d3")
					plot4 = meetShieldExportTransportHeartbroken
					plot4reminder = string.format("Meet transport %s last reported in %s to find Maria Shrivner",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName())
					playSoundFile("sa_55_BaseChief.wav")
				end
			end
		end
	else
		if shieldExpertTransport:isValid() then
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format("We received word that station %s has been destroyed. However, in some of their final records we see that Maria Shrivner left the station to take a job on freighter %s which was last reported in %s",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName()),"Magenta")
					plot4 = meetShieldExportTransport
					plot4reminder = stringFormat("Meet transport %s last reported in %s to find Maria Shrivner",shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName())
				end
			end
		else
			for pidx=1,8 do
				p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					p:addToShipLog("Station %s has been destroyed leaving no hints for shield upgrade followup","Magenta")
				end
			end
			choooseNextPlot4line()
		end
	end
end

function meetShieldExportTransport(delta)
	plot4name = "meetShieldExportTransport"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if distance(p,shieldExpertTransport) < 500 then
				p.shieldExpert = true
				p:addToShipLog(string.format("[Maria Shrivner] It was tragic that %s was destroyed. Bring me to %s and I'll double %s's shield effectiveness",shieldExpertStation:getCallSign(),homeStation:getCallSign(),homeStation:getCallSign()),"Yellow")
				playSoundFile("sa_55_Maria1.wav")
				plot4 = returnHomeForShields
				plot4reminder = "Return to home base with Maria Shrivner to double shield capacity"
				break
			end
		end
	end
end

function meetShieldExportTransportHeartbroken(delta)
	plot4name = "meetShieldExportTransportHeartbroken"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if distance(p,shieldExpertTransport) < 500 then
				p.shieldExpert = true
				p:addToShipLog(string.format("[Maria Shrivner] I should not have broken up with him, it was all a misunderstanding. Help me get him some rare material as a gift and I'll double %s's shield effectiveness",homeStation:getCallSign()),"Yellow")
				playSoundFile("sa_55_Maria2.wav")
				plot4 = giftForBeau
				beauGift = false
				plot4reminder = string.format("Get gold, platinum, dilithium, tritanium or cobalt and bring it and Maria Shrivner to %s",shieldExpertStation:getCallSign())
				break
			end
		end
	end
end

function giftForBeau(delta)
	plot4name = "giftForBeau"
	if shieldExpertStation:isValid() then
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				if p:isDocked(shieldExpertStation) then
					if p.shieldExpert then
						if beauGift then
							p:addToShipLog(string.format("[Maria Shrivner] Well, he's at least thinking about it. He liked the gift. Take me to %s and let's get those shields upgraded",homeStation:getCallSign()),"Yellow")
							playSoundFile("sa_55_Maria3.wav")
							plot4 = returnHomeForShields
							plot4reminder = "Return to home base with Maria Shrivner to double shield capacity"
						end
					end
				end
			end
		end
	else
		for pidx=1,8 do
			p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format("We were just notified that station %s has been destroyed",shieldExpertStation:getCallSign()),"Magenta")
				if p.shieldExpert then
					p:addToShipLog(string.format("[Maria Shrivner] Oh no! I'm too late! Now we'll never be reconciled. *sniff* Well, the least I can do is upgrade %s's shields. Take me there and I'll double %s's shield capacity",homeStation:getCallSign(),homeStation:getCallSign()),"Yellow")
					playSoundFile("sa_55_Maria4.wav")
					plot4 = returnHomeForShields
					plot4reminder = "Return to home base with Maria Shrivner to double shield capacity"
				end
			end
		end
	end
end

function returnHomeForShields(delta)
	plot4name = "returnHomeForShields"
	for pidx=1,8 do
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p:isDocked(homeStation) then
				if homeStation.shieldUpgrade == nil then
					if p.shieldExpert then
						newMax = homeStation:getShieldMax(0)*2
						if homeStation:getShieldCount() == 1 then
							homeStation:setShieldsMax(newMax)
						end
						if homeStation:getShieldCount() == 3 then
							homeStation:setShieldsMax(newMax,newMax,newMax)
						end
						if homeStation:getShieldCount() == 4 then
							homeStation:setShieldsMax(newMax,newMax,newMax,newMax)
						end
					end
					p:addToShipLog(string.format("[Maria Shrivner] %s's shield capacity has been doubled. They should charge up to their new capacity eventually",homeStation:getCallSign()),"Yellow")
					playSoundFile("sa_55_Maria5.wav")
					choooseNextPlot4line()
					homeStation.shieldUpgrade = true
				end
			end
		end
	end
end
--[[-----------------------------------------------------------------
    Plot 5 Helpful warnings
-----------------------------------------------------------------]]--
function helpfulWarning(delta)
	plot5name = "helpfulWarning"
	helpfulWarningTimer = helpfulWarningTimer - delta
	if helpfulWarningTimer < 0 then
		warningProvided = false
		for i=1,#stationList do
			if stationList[i]:isValid() then
				p = closestPlayerTo(stationList[i])
				for _, obj in ipairs(stationList[i]:getObjectsInRange(30000)) do
					if obj:isEnemy(p) then
						if not string.find(obj:getTypeName(),"Station") then
							wMsg = string.format("[%s] Our sensors detect enemies nearby",stationList[i]:getCallSign())
							if diagnostic or difficulty < 1 then
								wMsg = wMsg .. string.format(" - Type: %s",obj:getTypeName())
							end
							if i == 1 then
								stationShields = homeStation:getShieldCount()
								shieldsDamaged = false
								if stationShields == 1 then
									sl = homeStation:getShieldLevel(0)
									sm = homeStation:getShieldMax(0)
									if sl < sm then
										sdMsg = sdMsg .. string.format("\n   Shield: %i% (%.1f/%i) ",math.floor(sl/sm*100),sl,sm)
										shieldsDamaged = true
									end
								else
									sdMsg = string.format("\n   Shield count: %i ",stationShields)
									for j=1,stationShields do
										sl = homeStation:getShieldLevel(j-1)
										sm = homeStation:getShieldMax(j-1)
										if sl < sm then
											sdMsg = sdMsg .. string.format("\n      Shield %i: %i% (%.1f/%i) ",j,math.floor(sl/sm*100),sl,sm)
											shieldsDamaged = true
										end
									end
								end
								if shieldsDamaged then
									wMsg = wMsg .. "\nStation status:" .. sdMsg
								end
								hl = homeStation:getHull()
								hm = homeStation:getHullMax()
								if hl < hm then
									if shieldsDamaged then
										wMsg = wMsg .. string.format("\n   Hull: %i% (%.1f/%i)",math.floor(hl/hm*100),hl,hm)
									else
										wMsg = wMsg .. "\nStation status:" .. string.format("\n   Hull: %i% (%.1f/%i)",math.floor(hl/hm*100),hl,hm)										
									end
								end
							end
							p:addToShipLog(wMsg,"Red")
							warningProvided = true
							break
						end
					end
				end
			end
			if warningProvided then
				break
			end
		end
		helpfulWarningTimer = delta + random(90,200)
	end
end
--[[-----------------------------------------------------------------
    Plot 6 Timed Game
-----------------------------------------------------------------]]--
function timedGame(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		if string.find(getScenarioVariation(),"Defender") then
			missionVictory = true
			endStatistics()
			victory("Human Navy")
		else
			missionVictory = false
			endStatistics()
			victory("Kraylor")
		end
	end
end
--[[-----------------------------------------------------------------
      Plot W - wormhole starts as an artifact in unusual motion
-----------------------------------------------------------------]]--
function setWormArt()
	wormArt = Artifact():setPosition(random(-90000,90000),random(-90000,90000)):setModel("artifact4"):allowPickup(false):setScanningParameters(2,5)
	wormArt:setDescriptions("sprightly unassuming object","Object shows rapidly building energy"):setRadarSignatureInfo(50,10,5)
	wormArt.travelAngle = random(0,360)
	wormArt.tempAngle = -90
	wormArt.travel = 5
	plotW = moveWormArt
end

function moveWormArt(delta)
	plotWname = "moveWormArt"
	if wormArt:isScannedByFaction("Human Navy") then
		wormDelayTimer = 5
		plotW = wormBirth
	end
	p = closestPlayerTo(wormArt)
	if distance(p,wormArt) > 5000 then
		wax, way = wormArt:getPosition()
		angleChange = false
		if wax < -100000 then
			angleChange = true
			wormArt.travelAngle = random(0,180) + 270
		end
		if wax > 100000 then
			angleChange = true
			wormArt.travelAngle = random(90,270)
		end
		if way < -100000 then
			angleChange = true
			wormArt.travelAngle = random(0,180)
		end
		if way > 100000 then
			angleChange = true
			wormArt.travelAngle = random(180,360)
		end
		if angleChange then
			wadx, wady = vectorFromAngle(wormArt.travelAngle,wormArt.travel+20)
			wormArt:setPosition(wax+wadx,way+wady)
		else
			wadx, wady = vectorFromAngle(wormArt.travelAngle + wormArt.tempAngle,wormArt.travel)
			wormArt:setPosition(wax+wadx,way+wady)
			wormArt.tempAngle = wormArt.tempAngle + 1
			if wormArt.tempAngle > 90 then
				wormArt.tempAngle = -90
			end
		end
	end
end

function wormBirth(delta)
	plotWname = "wormBirth"
	wormDelayTimer = wormDelayTimer - delta
	if wormDelayTimer < 0 then
		wax, way = wormArt:getPosition()
		wormArt:explode()
		plotW = wormBirth2
		wormDelayTimer2 = 5
	end
end

function wormBirth2(delta)
	plotWname = "wormBirth2"
	wormDelayTimer2 = wormDelayTimer2 - delta
	if wormDelayTimer2 < 0 then
		ElectricExplosionEffect():setPosition(wax,way):setSize(5000)
		wormDelayTimer3 = 5
		plotW = wormBirth3
	end
end

function wormBirth3(delta)
	plotWname = "wormBirth3"
	wormDelayTimer3 = wormDelayTimer3 - delta
	if wormDelayTimer3 < 0 then
		wdx, wdy = vectorFromAngle(random(0,360),random(200000,300000))
		WormHole():setPosition(wax,way):setTargetPosition(wax+wdx,way+wdy)
		plotW = nil
	end
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
				pobj:addReputationPoints(180-(difficulty*6))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				pobj.spinUpgrade = false
				pobj.beamTimeUpgrade = false
				pobj.hullUpgrade = false
				tempPlayerType = pobj:getTypeName()
				if tempPlayerType == "MP52 Hornet" then
					if #playerShipNamesForMP52Hornet > 0 then
						ni = math.random(1,#playerShipNamesForMP52Hornet)
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
		p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.autoCoolant ~= nil then
				if p:hasPlayerAtPosition("Engineering") then
					if p.autoCoolButton == nil then
						tbi = "enableAutoCool" .. p:getCallSign()
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
	p = getPlayerShip(1)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool1()
	p = getPlayerShip(1)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool2()
	p = getPlayerShip(2)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool2()
	p = getPlayerShip(2)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool3()
	p = getPlayerShip(3)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool3()
	p = getPlayerShip(3)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool4()
	p = getPlayerShip(4)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool4()
	p = getPlayerShip(4)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool5()
	p = getPlayerShip(5)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool5()
	p = getPlayerShip(5)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool6()
	p = getPlayerShip(6)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool6()
	p = getPlayerShip(6)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool7()
	p = getPlayerShip(7)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool7()
	p = getPlayerShip(7)
	p:setAutoCoolant(false)
	p.autoCoolant = false
end
function enableAutoCool8()
	p = getPlayerShip(8)
	p:setAutoCoolant(true)
	p.autoCoolant = true
end
function disableAutoCool8()
	p = getPlayerShip(8)
	p:setAutoCoolant(false)
	p.autoCoolant = false
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
		if p ~= nil then
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
	if difficultySpecificSetup == nil then
		difficultySpecificSetup = "done"
		if difficulty >= 1 then
			tesx, tesy = targetEnemyStation:getPosition()
			wpRadius = 3000
			wpAngle = random(0,360)
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp9 = CpuShip():setCallSign("WP-9"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp15 = CpuShip():setCallSign("WP-15"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp46 = CpuShip():setCallSign("WP-46"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp20 = CpuShip():setCallSign("WP-20"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
		end
		if difficulty > 1 then
			tesx, tesy = targetEnemyStation:getPosition()
			wp66cpos = 0
			rx, ry = vectorFromAngle(wp66cpos,6000)
			wp66 = CpuShip():setCallSign("WP-66"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
		end		
	end
	if difficulty > 1 then
		if wp66:isValid() then
			wp66cpos = wp66cpos + .1
			if wp66cpos >= 360 then
				wp66cpos = 0
			end
			rx, ry = vectorFromAngle(wp66cpos, 6000)
			wp66:setPosition(tesx+rx,tesy+ry)
		end
	end
	if homeStation:isValid() then
		if homeStationRotationEnabled then
			homeStation:setRotation(homeStation:getRotation()+.1)
			if homeStation:getRotation() >= 360 then
				homeStation:setRotation(0)
			end
		end
	end
	anetx, anety = vectorFromAngle(stationAnet.angle,3000)
	stationAnet:setPosition(aldx+anetx,aldy+anety):setRotation(stationAnet.angle)
	stationAnet.angle = stationAnet.angle + .05
	if stationAnet.angle >= 360 then
		stationAnet.angle = 0
	end
	if plot6 ~= nil then	--timed game
		plot6(delta)
	end
	if plot1 ~= nil then	--initial and primary plot
		plot1(delta)
	end
	if plot2 ~= nil then	--delivery, spin upgrade, base intelligence, warp jam
		plot2(delta)
	end
	if plot4 ~= nil then	--deliver, base rotate, beam time/hull upgrades
		plot4(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotA ~= nil then	--asteroids in motion
		plotA(delta)
	end
	if plotN ~= nil then	--nebulae in motion
		plotN(delta)
	end
	if plotT ~= nil then	--transports
		plotT(delta)
	end
	if plot3 ~= nil then	--intelligence over time
		plot3(delta)
	end
	if plotW ~= nil then	--worm artifact
		plotW(delta)
	end
	if plotC ~= nil then	--coolant automation for fighters
		plotC(delta)
	end
	if plot5 ~= nil then	--helpful warning
		plot5(delta)
	end
end