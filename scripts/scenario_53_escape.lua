-- Name: Escape
-- Description: Escape imprisonment and return home. 
---
--- Mission consists of one ship with a full crew. Engineer, Relay and Science will be busy; Weapons less busy.
-- Type: Mission, somewhat replayable
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies

require("utils.lua")

--[[-------------------------------------------------------------------
	Initialization routines
--]]-------------------------------------------------------------------
function init()
	wfv = "nowhere"		--wolf fence value - used for debugging
	setVariations()
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
	independentTransportSpawnDelay = 20
	independentTransportList = {}
	plotIT = independentTransportPlot
	kraylorTransportSpawnDelay = 40
	kraylorTransportList = {}
	plotKT = kraylorTransportPlot
	kraylorPatrolSpawnDelay = 60
	kraylorPatrolList = {}
	kGroup = 0
	kraylorPatrolGroupList = {}
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
    brigStation = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor"):setCallSign("DS23"):setPosition(912787, 148301)
	table.insert(enemyStationList,brigStation)
	buildNearbyStations()
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
	placeRandomAroundPoint(Nebula,math.random(10,30),1,120000,brigx,brigy)
	--Junk Yard M50 area
    Asteroid():setPosition(909643, 152314)
    Asteroid():setPosition(908697, 151087)
    Asteroid():setPosition(911713, 153208)
    Asteroid():setPosition(911918, 150729)
    Asteroid():setPosition(912046, 149758)
    Asteroid():setPosition(913036, 152491)
    Asteroid():setPosition(913696, 151396)
    Asteroid():setPosition(908036, 151340)
    Asteroid():setPosition(906375, 149283)
    Asteroid():setPosition(905979, 148528)
    Asteroid():setPosition(906281, 147698)
    Asteroid():setPosition(911413, 148623)
    Asteroid():setPosition(910262, 147944)
    Asteroid():setPosition(909903, 147302)
    Asteroid():setPosition(906130, 150170)
    Asteroid():setPosition(907961, 148916)
    Asteroid():setPosition(908696, 148182)
    Asteroid():setPosition(910870, 151302)
	--Debris
	junkYardDebrisX = {908020, 910705, 907503}
	junkYardDebrisY = {150504, 150317, 148005}
	debrisx, debrisy = pickCoordinate(junkYardDebrisX,junkYardDebrisY)
	debris1 = Artifact():setPosition(debrisx, debrisy):setModel("ammo_box"):allowPickup(true):setScanningParameters(2,1):onPickUp(function(debris, pGrab) string.format("");pGrab.debris1 = true end)
	debris1:setDescriptions("Debris","Debris: Various broken ship components. Possibly useful for engine or weapons systems repair")
	debrisx, debrisy = pickCoordinate(junkYardDebrisX,junkYardDebrisY)
	debris2 = Artifact():setPosition(debrisx, debrisy):setModel("ammo_box"):allowPickup(true):setScanningParameters(1,3):onPickUp(function(debris, pGrab) string.format("");pGrab.debris2 = true end)
	debris2:setDescriptions("Debris","Debris: Various broken ship components. Possibly useful for shield or beam systems repair")
	debrisx, debrisy = pickCoordinate(junkYardDebrisX,junkYardDebrisY)
	debris3 = Artifact():setPosition(debrisx, debrisy):setModel("ammo_box"):allowPickup(true):setScanningParameters(2,1):onPickUp(function(debris, pGrab) string.format("");pGrab.debris3 = true end)
	debris3:setDescriptions("Debris","Debris: Various broken ship components. Possibly useful for reactor or shield systems repair")
	--Signs
	junkYardSignX = {914126, 905479, 910303}
	junkYardSignY = {151100, 148728, 147102}
	junkZone = Zone():setPoints(905479, 148728, 906490, 146843, 910303, 147102, 914126, 151100, 912635, 154012, 905801, 151274)
	signx, signy = pickCoordinate(junkYardSignX, junkYardSignY)
	Sign1 = Artifact():setPosition(signx, signy):setModel("SensorBuoyMKI"):allowPickup(false):setScanningParameters(1,1)
	Sign1:setDescriptions("Space Message Buoy","Space Message Buoy reading 'Welcome to the Boris Junk Yard and Emporium' in the Kraylor language")
	signx, signy = pickCoordinate(junkYardSignX, junkYardSignY)
	Sign2 = Artifact():setPosition(signx, signy):setModel("SensorBuoyMKI"):allowPickup(false):setScanningParameters(1,1)
	Sign2:setDescriptions("Space Message Buoy","Space Message Buoy reading 'Boris Junk Yard: Browse for parts, take home an asteroid for the kids' in the Kraylor language")
	signx, signy = pickCoordinate(junkYardSignX, junkYardSignY)
	Sign3 = Artifact():setPosition(signx, signy):setModel("SensorBuoyMKI"):allowPickup(false):setScanningParameters(1,1)
	Sign3:setDescriptions("Space Message Buoy","Space Message Buoy reading 'Boris Junk Yard: Best prices in 20 sectors' in the Kraylor language")
	plotSign = billboardUpdate	
	--Initial player ship
	playerFighter = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setCallSign("Scrag"):setPosition(912035, 152062)
	playerFighter:setSystemHealth("reactor", 0.01):setSystemHealth("beamweapons",-1):setSystemHealth("maneuver",0.05):setSystemHealth("missilesystem",-1):setSystemHealth("impulse",-0.5):setSystemHealth("warp",-1):setSystemHealth("jumpdrive",-1):setSystemHealth("frontshield",.1):setSystemHealth("rearshield",.1):setHull(5):setShields(5)
	playerFighter:setScanProbeCount(0):setEnergy(50)
	playerFighter.maxCargo = 3
	playerFighter.cargo = playerFighter.maxCargo
	playerFighter.shipScore = 5
	playerFighter.maxReactor = .5
	playerFighter.maxBeam = random(-.2,-.7)
	playerFighter.maxManeuver = .5
	playerFighter.maxImpulse = .2
	playerFighter.maxFrontShield = .25
	player = playerFighter
	goods[player] = goodsList
	junkShips = {}
	--junkyard ship index 1       2       3       4       5       6       7       8       9      10      11      12      13      14      15
	junkYardShipX = {909594, 910129, 909490, 910461, 910716, 911023, 913356, 906866, 911356, 910998, 907356, 913243, 908569, 912413, 907149}
	junkYardShipY = {148578, 150090, 149528, 151061, 149068, 151854, 151717, 148094, 150167, 153234, 150170, 150698, 149988, 152981, 149132}
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkRepulse = CpuShip():setFaction("Independent"):setTemplate("Repulse"):setPosition(shipx, shipy):orderIdle():setHull(14):setShields(0.00,2.00):setWeaponStorage("HVLI",0):setWeaponStorage("Homing",1)
	table.insert(junkShips,junkRepulse)	
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkAdder = CpuShip():setFaction("Kraylor"):setTemplate("Adder MK4"):setPosition(shipx, shipy):orderIdle():setHull(9):setShields(0.00):setWeaponStorage("HVLI", 1)
	table.insert(junkShips,junkAdder)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkFreighter1 = CpuShip():setFaction("Kraylor"):setTemplate("Fuel Freighter 1"):setPosition(shipx, shipy):orderIdle():setHull(6):setShields(1.00, 0.00)
	table.insert(junkShips,junkFreighter1)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkFreighter2 = CpuShip():setFaction("Independent"):setTemplate("Goods Freighter 3"):setPosition(shipx, shipy):orderIdle():setHull(7):setShields(14.00, 0.00)
	table.insert(junkShips,junkFreighter2)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkDrone1 = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Drone"):setPosition(shipx, shipy):orderIdle():setHull(2)
	table.insert(junkShips,junkDrone1)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkDrone2 = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Drone"):setPosition(shipx, shipy):orderIdle():setHull(6)
	table.insert(junkShips,junkDrone2)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkDrone3 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Drone"):setPosition(shipx, shipy):orderIdle():setHull(2)
	table.insert(junkShips,junkDrone3)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkDrone4 = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Drone"):setPosition(shipx, shipy):orderIdle():setHull(7)
	table.insert(junkShips,junkDrone4)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkHornet1 = CpuShip():setFaction("Exuari"):setTemplate("MT52 Hornet"):setPosition(shipx, shipy):orderIdle():setHull(2):setShields(0.00)
	table.insert(junkShips,junkHornet1)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkHornet2 = CpuShip():setFaction("Ghosts"):setTemplate("MT52 Hornet"):setPosition(shipx, shipy):orderIdle():setHull(2):setShields(0.00)
	table.insert(junkShips,junkHornet2)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkHornet3 = CpuShip():setFaction("Arlenians"):setTemplate("MT52 Hornet"):setPosition(shipx, shipy):orderIdle():setHull(1):setShields(1.00)
	table.insert(junkShips,junkHornet3)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkHornet4 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition(shipx, shipy):orderIdle():setHull(2):setShields(0.00)
	table.insert(junkShips,junkHornet4)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkPhobos = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition(shipx, shipy):orderIdle():setHull(4):setShields(2.00, 1.00):setWeaponStorage("Homing", 1)
	table.insert(junkShips,junkPhobos)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkStrikeship = CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setPosition(shipx, shipy):orderIdle():setHull(0):setShields(4.00, 0.00, 30.00, 30.00)
	table.insert(junkShips,junkStrikeship)
	shipx, shipy = pickCoordinate(junkYardShipX, junkYardShipY)
    junkScout = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Scout"):setPosition(shipx, shipy):orderIdle():setHull(4)
	table.insert(junkShips,junkScout)
	for i=1,#junkShips do
		junkShips[i]:setSystemHealth("reactor", random(-.9,-.1)):setSystemHealth("beamweapons",random(-.9,-.1)):setSystemHealth("maneuver",random(-.9,-.1)):setSystemHealth("missilesystem",random(-.9,-.1)):setSystemHealth("impulse",random(-.9,-.1)):setSystemHealth("warp",random(-.9,-.1)):setSystemHealth("jumpdrive",random(-.9,-.1)):setSystemHealth("frontshield",random(-.9,-.1)):setSystemHealth("rearshield",random(-.9,-.1))
		junkShips[i].maxReactor = junkShips[i]:getSystemHealth("reactor")
		junkShips[i].maxBeam = junkShips[i]:getSystemHealth("beamweapons")
		junkShips[i].maxManeuver = junkShips[i]:getSystemHealth("maneuver")
		junkShips[i].maxMissile = junkShips[i]:getSystemHealth("missilesystem")
		junkShips[i].maxImpulse = junkShips[i]:getSystemHealth("impulse")
		junkShips[i].maxWarp = junkShips[i]:getSystemHealth("warp")
		junkShips[i].maxJump = junkShips[i]:getSystemHealth("jumpdrive")
		junkShips[i].maxFrontShield = junkShips[i]:getSystemHealth("frontshield")
		junkShips[i].maxRearShield = junkShips[i]:getSystemHealth("rearshield")
	end
	junkRepulse:setSystemHealth("jumpdrive",-1):setBeamWeapon(1,0,0,0,0,0)
	junkRepulse.maxJump = .5
    junkSupply = SupplyDrop():setFaction("Independent"):setPosition(909362, 151445):setEnergy(500):setWeaponStorage("Homing", 1):setWeaponStorage("Nuke", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
	plotH = shipHealth				--enable ship health check plot
	playerShipHealth = scragHealth	--set function to constrain player ship health
	playerFighter:addToShipLog(string.format("You escaped the brig of station %s and transported yourselves onto one of the spaceship hulks in a nearby holding area for junked spacecraft. You carry critical information for the Human Navy regarding Kraylor activity in this area. You need to make good your escape and dock with a Human Navy space station",brigStation:getCallSign()),"Magenta")
	plot1 = scanRepulse				--enable first plot mission goal
	print("end of init")
end
--pick a coordinate at random from the passed table
--remove selected coordinates and return selected coordinates
function pickCoordinate(coordinateArrayX,coordinateArrayY)
	if #coordinateArrayX > 1 then
		choice = math.random(1,#coordinateArrayX)
		rx = coordinateArrayX[choice]
		ry = coordinateArrayY[choice]
		table.remove(coordinateArrayX,choice)
		table.remove(coordinateArrayY,choice)
	else
		rx = coordinateArrayX[1]
		ry = coordinateArrayY[1]
		table.remove(coordinateArrayX,1)
		table.remove(coordinateArrayY,1)
	end
	return rx, ry
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
-- Order of creation: 	enemy stations, planet, enemy stations, planet, 
-- 						independent stations, black hole, independent stations, black hole
-- Human Navy stations (friendly stations) come later in the game after the communications get repaired.
function buildNearbyStations()
	brigx, brigy = brigStation:getPosition()
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
	--place enemy stations
	stationFaction = "Kraylor"
	for i=gx-2,gx+1 do			--reserve space for the junk yard
		for j=gy-1,gy+2 do
			grid[i][j] = gp
		end
	end
	adjList = getAdjacentGridLocations(gx,gy)
	ral = math.random(1,#adjList)	--random adjacent location
	gx = adjList[ral][1]
	gy = adjList[ral][2]
	gp = 2
	for j=1,5 do					--add enemy bases nearby
		addEnemyStations()
	end
	--insert a planet
	tSize = 11
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
	bwx = brigx + (gRegion[sri][1] - (gbHigh/2))*gSize
	bwy = brigy + (gRegion[sri][2] - (gbHigh/2))*gSize
	planetBaldwin = Planet():setPosition(bwx,bwy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Baldwin")
	planetBaldwin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription("Mining and heavy industry")
	stationWig = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor")
	stationWig:setPosition(bwx, bwy+3000):setCallSign("BOBS"):setDescription("Baldwin Observatory")
	stationWig.angle = 90
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	for j=1,6 do		--add more enemy bases nearby
		addEnemyStations()
	end
	--insert a planet
	tSize = 11
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
	msx = brigx + (gRegion[sri][1] - (gbHigh/2))*gSize
	msy = brigy + (gRegion[sri][2] - (gbHigh/2))*gSize
	planetMal = Planet():setPosition(msx,msy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Malastare")
	planetMal:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	planetMal:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	planetMal:setAxialRotationTime(400.0):setDescription("M class planet")
	stationMal = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	stationMal:setPosition(msx,msy+3000):setCallSign("MalNet"):setDescription("Malastare communications network hub")
	stationMal.angle = 90
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	--place independent stations
	stationFaction = "Independent"
	fb = gp	--set faction boundary (between enemy and neutral)
	for j=1,15 do
		addIndependentStations()
	end
	addBlackHole()
	for j=1,15 do
		addIndependentStations()
	end
	addBlackHole()
end
function addEnemyStations()
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
		if random(1,100) >= 17 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)				--select station random region index
	psx = brigx + (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
	psy = brigy + (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
	if math.random(1,100) < 50 then
		si = math.random(1,#placeEnemyStation)			--station index
		pStation = placeEnemyStation[si]()				--place selected station
		table.remove(placeEnemyStation,si)				--remove station from placement list
	else
		si = math.random(1,#placeGenericStation)
		pStation = placeGenericStation[si]()
		table.remove(placeGenericStation,si)
	end
	table.insert(enemyStationList,pStation)			--save station in general station list
	gp = gp + 1						--set next station number
	rn = math.random(1,#adjList)	--random next station start location
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function addIndependentStations()
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
		nextStationChoice = random(1,100)
		if nextStationChoice >= 56 then
			adjList = getFactionAdjacentGridLocations(gx,gy)
			if #adjList < 1 then
				adjList = getAllAdjacentGridLocations(gx,gy)
			end
		elseif nextStationChoice <= 22 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)				--select station random region index
	psx = brigx + (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
	psy = brigy + (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
	si = math.random(1,#placeStation)			--station index
	pStation = placeStation[si]()
	table.remove(placeStation,si)
	table.insert(stationList,pStation)
	gp = gp + 1						--set next station number
	rn = math.random(1,#adjList)	--random next station start location
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function addBlackHole()
	--insert a black hole
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
	else
		if random(1,100) >= 35 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	bhx = brigx + (gRegion[sri][1] - (gbHigh/2))*gSize
	bhy = brigy + (gRegion[sri][2] - (gbHigh/2))*gSize
	BlackHole():setPosition(bhx,bhy)
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
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
	if comms_target == beamFixStation then
		if playerRepulse.beamFix == nil then
			addCommsReply("Talk to Kent's brother", function()
				setCommsMessage("Kent? You made it out of the Kraylor base? We thought you were going to spend the rest of your life there. Thank you, captain, for helping Kent get out of there")
				addCommsReply("Can you help us with beam weapon repair?", function()
					setCommsMessage("For the Repulse class? Absolutely. I used to work on those all the time.")
					playerRepulse:setBeamWeapon(1, 10,-90, 1200.0, 6.0, 5)
					playerRepulse.beamFix = "done"
					fixFloodTimer = 30
					plot1 = fixFlood
					addCommsReply("Thanks", function()
						setCommsMessage("You're quite welcome. While I was in there, I fixed up your beams so they could function at maximum potential")
						playerRepulse.maxBeam = 1
						addCommsReply("Then double thanks!", function()
							playerRepulse:addReputationPoints(30)
							setCommsMessage("Thank *you* for getting my brother out of that Kraylor prison")
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
	if comms_target == missileFixStation then
		if playerRepulse.missileFix == nil then
			addCommsReply("Talk to Edwina's father", function()
				setCommsMessage("I am glad to hear that Edwina escaped that prison. We were worried about her")
				addCommsReply("Edwina says you do missile systems repair work", function()
					setCommsMessage("Should be easy enough. I'm grateful to you for helping Edwina escape.")
					playerRepulse.maxMissile = 1
					playerRepulse.missileFix = "done"
					addCommsReply("Thanks", function()
						setCommsMessage("You're quite welcome")
						playerRepulse:addReputationPoints(30)
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if comms_target == impulseFixStation then
		if playerRepulse.impulseFix == nil then
			addCommsReply("Talk to Johnny", function()
				setCommsMessage("Mom? Wow, I thought you were toast. Good to hear your voice")
				addCommsReply("Can you get our impulse drive working better", function()
					setCommsMessage("Piece of cake")
					playerRepulse.maxImpulse = 1
					playerRepulse.impulseFix = "done"
					addCommsReply("Thank you", function()
						setCommsMessage("Sure. Mom, I'll see you at Christmas")
						playerRepulse:addReputationPoints(30)
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if comms_target == jumpFixStation then
		if playerRepulse.jumpFix == nil then
			addCommsReply("Talk to Nancy's brother", function()
				setCommsMessage("Nancy! Last I heard, your ship had been captured by Kraylors and you were imprisoned. Good to know you won't be stuck there forever. What brings you here?")
				addCommsReply("Our jump drive needs some tuning", function()
					setCommsMessage("That should not be hard to do. I could probably do that in my sleep")
					playerRepulse.maxJump = 1
					playerRepulse.jumpFix = "done"
					addCommsReply("Thanks, bro", function()
						setCommsMessage("No problem. Treat your jump drive right and it'll always bring you home")
						playerRepulse:addReputationPoints(30)
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if comms_target == reactorFixStation then
		if playerRepulse.reactorFix == nil then
			addCommsReply("Talk to Manuel's cousin", function()
				setCommsMessage("Yo Manuel, why you want to scare us by getting captured, man? At least you escaped. Why you here?")
				addCommsReply("The reactor is weak... real weak", function()
					setCommsMessage("Lemme see if I can get it to charge up right.")
					playerRepulse.maxReactor = 1
					playerRepulse.reactorFix = "done"
					addCommsReply("The captain would appreciate it", function()
						setCommsMessage("You're all set. Don't overheat the reactor or you'll get a nasty surprise")
						playerRepulse:addReputationPoints(30)
						addCommsReply("Back",commsStation)
					end)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if comms_target == longRangeFixStation then
		if playerRepulse.longRangeFix == nil then
			addCommsReply("Talk to Fred's wife", function()
				setCommsMessage("Fred! You escaped! We were worried sick")
				addCommsReply("We need to connect to the Human Navy network", function()
					setCommsMessage("I can do that for you. However, that means you'll go from being Independent to being in the Human Navy")
					addCommsReply("I understand the consequences. Please proceed", function()
						playerRepulse.longRangeFix = "done"
						playerRepulse:setFaction("Human Navy")
						stationFaction = "Human Navy"
						print("switched to Human Navy")
						for j=1,8 do
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
								if random(1,100) >= 17 then
									adjList = getAllAdjacentGridLocations(gx,gy)
								end
							end
							sri = math.random(1,#gRegion)				--select station random region index
							psx = brigx + (gRegion[sri][1] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station x coordinate
							psy = brigy + (gRegion[sri][2] - (gbHigh/2))*gSize + random(-gSize/2*.95,gSize/2*.95)	--place station y coordinate
							si = math.random(1,#placeStation)			--station index
							pStation = placeStation[si]()				--place selected station
							print(string.format("placed %s in %s: %.1f, %.1f",pStation:getCallSign(),pStation:getSectorName(),psx,psy))
							table.remove(placeStation,si)				--remove station from placement list
							table.insert(stationList,pStation)			--save station in general station list
							table.insert(friendlyStationList,pStation)	
							gp = gp + 1						--set next station number
							rn = math.random(1,#adjList)	--random next station start location
							gx = adjList[rn][1]
							gy = adjList[rn][2]
						end
						plot4 = returnHome
						setCommsMessage("You're all fixed up")
						addCommsReply("Thanks", function()
							setCommsMessage("You're welcome. Fred, honey, I'll see you after you get off work")
							playerRepulse:addReputationPoints(30)
							addCommsReply("Back", commsStation)
						end)
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("I'll check with the captain and get back to you", function()
						setCommsMessage("Ok")
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back",commsStation)
				end)
				addCommsReply("Back",commsStation)
			end)
		end
	end
	if comms_target == shieldFixStation then
		if playerRepulse.frontShieldFix == nil and playerRepulse.rearShieldFix == nil then
			addCommsReply("Talk to Amir's sister", function()
				setCommsMessage(string.format("Welcome to %s! Any friend of Amir's is a friend of mine",shieldFixStation:getCallSign()))
				addCommsReply("Can you help us with our shields?", function()
					setCommsMessage("Yes, I can. However, I can only help with one: front or rear. I need more parts to do both")
					addCommsReply("Repair front shield", function()
						setCommsMessage("Your front shields are now fully operational. Your repair crew can finish the rest")
						playerRepulse.maxFrontShield = 1
						print("fixed front shield")
						playerRepulse.frontShieldFix = "done"
						print("set front shield fixed indicator")
						addCommsReply("Thanks", function()
							print("past front thanks")
							if shieldGoodBase == nil then
								print("setting shield good base")
								repeat
									print("top of shield good base set loop")
									candidate = stationList[math.random(1,#stationList)]
									print(string.format("candidate: %s",candidate:getCallSign()))
									if candidate ~= nil and candidate:isValid() and #goods[candidate] > 0 then
										print("candidate passed first checks")	--testing got to this point
										gi = 1
										repeat
											shieldGood = goods[candidate][gi][1]
											gi = gi + 1
										until(gi > #goods[candidate])
										print(string.format("Checked goods. Ended on shield good: %s",shieldGood))	--testing did not get here
										if shieldGood ~= "food" and shieldGood ~= "medicine" then
											shieldGoodBase = candidate	
											print(string.format("Decided on station %s",shieldGoodBase:getCallSign()))
										end
									end
								until(shieldGoodBase ~= nil)
								print("out of shield good base loop")
							end
							setCommsMessage(string.format("Certainly. Bring back %s to get the rear shield fixed. You might find some at %s",shieldGood,shieldGoodBase:getCallSign()))
							print("set response message")
							playerRepulse:addReputationPoints(30)
							addCommsReply("Back", commsStation)
						end)
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Repair rear shield", function()
						setCommsMessage("Your rear shields are now fully operational. Your repair crew can finish the rest")
						playerRepulse.maxRearShield = 1
						playerRepulse.rearShieldFix = "done"
						addCommsReply("Thanks", function()
							if shieldGoodBase == nil then
								repeat
									candidate = stationList[math.random(1,#stationList)]
									if candidate ~= nil and candidate:isValid() and #goods[candidate] > 0 then
										gi = 1
										repeat
											shieldGood = goods[candidate][gi][1]
											gi = gi + 1
										until(gi > #goods[candidate])
										if shieldGood ~= "food" and shieldGood ~= "medicine" then
											shieldGoodBase = candidate											
										end
									end
								until(shieldGoodBase ~= nil)
							end
							setCommsMessage(string.format("Certainly. Bring back %s to get the front shield fixed. You might find some at %s",shieldGood,shieldGoodBase:getCallSign()))
							playerRepulse:addReputationPoints(30)
							addCommsReply("Back", commsStation)
						end)
						addCommsReply("Back", commsStation)
					end)
					addCommsReply("Back", commsStation)
				end)
				addCommsReply("Back", commsStation)
			end)
		elseif playerRepulse.frontShieldFix == nil or playerRepulse.rearShieldFix == nil then
			addCommsReply("Talk to Amir's sister", function()
				setCommsMessage(string.format("Welcome back. Did you bring some %s for me to finish fixing up your shields?",shieldGood))
				gi = 1
				shieldGoodQuantity = 0
				repeat
					if goods[player][gi][1] == shieldGood then
						shieldGoodQuantity = goods[player][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[player])
				if shieldGoodQuantity > 0 then
					addCommsReply(string.format("Yes, please take the %s and fix the shields",shieldGood), function()
						decrementPlayerGoods(shieldGood)
						player.cargo = player.cargo + 1
						if playerRepulse.frontShieldFix == nil then
							playerRepulse.maxFrontShield = 1
							playerRepulse.frontShieldFix = "done"
							setCommsMessage("Front shield fully functional")
						else
							playerRepulse.maxRearShield = 1
							playerRepulse.rearShieldFix = "done"
							setCommsMessage("Rear shield fully functional")
						end
						playerRepulse:addReputationPoints(30)
						addCommsReply("Back", commsStation)
					end)
				else
					addCommsReply(string.format("Oops, no %s aboard",shieldGood), function()
						setCommsMessage("Ok, good luck")
						addCommsReply("Back", commsStation)
					end)
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
--[[	
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
--]]
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
--[[-------------------------------------------------------------------
	First Plot starts when repulse hulk is scanned
--]]-------------------------------------------------------------------
function scanRepulse(delta)
	if junkRepulse:isValid() then
		if junkRepulse:isFullyScannedBy(playerFighter) then
			hintRepulseTimer = random(30,60)
			plot1 = hintRepulse
		end
	end
end
--Engineer hints that the Repulse hulk has a jump drive that might function
function hintRepulse(delta)
	hintRepulseTimer = hintRepulseTimer - delta
	if hintRepulseTimer < 0 then
		if playerFighter:hasPlayerAtPosition("Engineering") then
			repulseHintMessage = "repulseHintMessage"
			playerFighter:addCustomMessage("Engineering",repulseHintMessage,string.format("Reading through the scan data provided by science, you see that there could be a working jump drive on %s. However, if the crew wishes to transport over there, %s will need to get very close due to the minimal amount of energy remaining in the transporters.",junkRepulse:getCallSign(),playerFighter:getCallSign()))
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			repulseHintMessageEPlus = "repulseHintMessageEPlus"
			playerFighter:addCustomMessage("Engineering",repulseHintMessageEPlus,string.format("Reading through the scan data provided by science, you see that there could be a working jump drive on %s. However, if the crew wishes to transport over there, %s will need to get very close due to the minimal amount of energy remaining in the transporters.",junkRepulse:getCallSign(),playerFighter:getCallSign()))
		end
		plot1 = hugRepulse
	end
end
--Get close enough and a transfer button will appear
function hugRepulse(delta)
	if distance(playerFighter,junkRepulse) < 500 then
		if playerFighter:hasPlayerAtPosition("Engineering") then
			repulseTransferButton = "repulseTransferButton"
			playerFighter:addCustomButton("Engineering",repulseTransferButton,"Transfer to Repulse",repulseTransfer)
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			repulseTransferButtonEPlus = "repulseTransferButtonEPlus"
			playerFighter:addCustomButton("Engineering",repulseTransferButtonEPlus,"Transfer to Repulse",repulseTransfer)
		end
		if repulseTransferButtonEPlus ~= nil or repulseTransferButton ~= nil then
			plot1 = nil
		end
	end
end
--Transfer crew and any artifacts picked up to Repulse
function repulseTransfer()
	swapx, swapy = junkRepulse:getPosition()	--save NPC ship location
	swapRotate = junkRepulse:getRotation()		--save NPC ship orientation
	junkRepulse:setPosition(500,500)			--move NPC ship away
	playerRepulse = PlayerSpaceship():setFaction("Independent"):setTemplate("Repulse"):setCallSign("HMS Plunder"):setPosition(swapx,swapy)
	playerRepulse:setRotation(swapRotate)		--set orientation that was saved
	playerRepulse:setSystemHealth("reactor", junkRepulse:getSystemHealth("reactor"))
	playerRepulse:setSystemHealth("beamweapons", junkRepulse:getSystemHealth("beamweapons"))
	playerRepulse:setSystemHealth("maneuver", junkRepulse:getSystemHealth("maneuver"))
	playerRepulse:setSystemHealth("missilesystem", junkRepulse:getSystemHealth("missilesystem"))
	playerRepulse:setSystemHealth("impulse", junkRepulse:getSystemHealth("impulse"))
	playerRepulse:setSystemHealth("warp", junkRepulse:getSystemHealth("warp"))
	playerRepulse:setSystemHealth("jumpdrive", -.2)		--Jump drive messed up more than sensors indicated
	playerRepulse:setSystemHealth("frontshield", junkRepulse:getSystemHealth("frontshield"))
	playerRepulse:setSystemHealth("rearshield", junkRepulse:getSystemHealth("rearshield"))
	playerRepulse:setHull(junkRepulse:getHull()):setEnergy(250):setRepairCrewCount(2):setScanProbeCount(1)
	junkRepulse:destroy()				--goodbye NPC repulse
	playerRepulse.maxCargo = 12			--cargo capacity
	playerRepulse.cargo = playerRepulse.maxCargo	--available capacity
	playerRepulse.shipScore = 14		--ship relative strength
	playerRepulse.maxReactor = .4		--maximum health repairable
	playerRepulse.maxBeam = .8			--maximum health repairable
	playerRepulse.maxManeuver = 1		--maximum health repairable
	playerRepulse.maxMissile = -.1		--maximum health repairable
	playerRepulse.maxImpulse = .4		--maximum health repairable
	playerRepulse.maxWarp = -.1			--maximum health repairable
	playerRepulse.maxJump = -.1			--maximum health repairable
	playerRepulse.maxFrontShield = .3	--maximum health repairable
	playerRepulse.maxRearShield = .3	--maximum health repairable
	playerRepulse:setBeamWeapon(1,0,0,0,0,0)		--severely damaged beam emplacement on one side
	playerRepulse:setWeaponStorage("Homing",1)		--one leftover homing torpedo
	playerRepulse:setWeaponStorage("HVLI",0)		--no HVLI
	swapx, swapy = playerFighter:getPosition()		--save current position
	swapRotate = playerFighter:getRotation()		--save current orientation
	playerFighter:transferPlayersToShip(playerRepulse)	--switch players from fighter to repulse
	playerFighter:setPosition(1000,1000)			--move fighter away
	junkFighter = CpuShip():setFaction("Independent"):setTemplate("MP52 Hornet"):setCallSign("Scrag"):setPosition(swapx, swapy)
	junkFighter:setHull(playerFighter:getHull())	--transfer hull statistics to NPC ship
	junkFighter:setShields(playerFighter:getShieldLevel(0))	--transfer shield statistics to NPC ship
	junkFighter:orderIdle()							--NPC ship does nothing
	junkFighter:setRotation(swapRotate)				--transfer orientation to NPC ship
	junkFighter.maxReactor = playerFighter:getSystemHealth("reactor")	--transfer repair level and fix
	junkFighter.maxBeam = playerFighter:getSystemHealth("beamweapons")	--transfer repair level and fix
	junkFighter.maxManeuver = playerFighter:getSystemHealth("maneuver")	--transfer repair level and fix
	junkFighter.maxImpulse = playerFighter:getSystemHealth("impulse")	--transfer repair level and fix
	junkFighter.maxFrontShield = playerFighter:getSystemHealth("frontshield")	--transfer repair level and fix
	playerRepulse.debris1 = playerFighter.debris1	--transfer debris record
	playerRepulse.debris2 = playerFighter.debris2	--transfer debris record
	playerRepulse.debris3 = playerFighter.debris3	--transfer debris record
	playerFighter:destroy()				--goodbye player fighter
	playerShipHealth = plunderHealth	--switch player health check function to repulse
	augmentRepairCrewTimer = 45			--time to repair crew escape
	plot1 = augmentRepairCrew
	playerRepulse:addToShipLog("Welcome aboard the Repulse class ship, rechristened HMS Plunder, currently registered as Independent","Magenta")
	player = playerRepulse
	goods[player] = goodsList
	plotKP = kraylorPatrol				--start sending out Kraylor patrols
	print("end of transfer")
end
--Former repair crew asks to be rescued to take up their jobs again
function augmentRepairCrew(delta)
	augmentRepairCrewTimer = augmentRepairCrewTimer - delta
	if augmentRepairCrewTimer < 0 then
		brigHailed = brigStation:sendCommsMessage(playerRepulse,"Need a repair crew? We used to be posted on that ship. We would be happy to return to our repair duty and get away from these Kraylors. We left the transporters locked on us, but the Kraylors destroyed our remote activator. You should find an activation switch at the weapons console")
		if brigHailed then
			if playerRepulse:hasPlayerAtPosition("Weapons") then
				if retrieveRepairCrewButton == nil then
					retrieveRepairCrewButton = "retrieveRepairCrewButton"
					playerRepulse:addCustomButton("Weapons",retrieveRepairCrewButton,"Return Transport",returnRepairCrew)
				end
			end
			if playerRepulse:hasPlayerAtPosition("Tactical") then
				if retrieveRepairCrewButtonTac == nil then
					retrieveRepairCrewButtonTac = "retrieveRepairCrewButtonTac"
					playerRepulse:addCustomButton("Tactical",retrieveRepairCrewButtonTac,"Return Transport",returnRepairCrew)
				end
			end
			plot1 = beamDamageReport
			beamDamageReportTimer = 30
		end
		augmentRepairCrewTimer = delta + 30
	end
end
--Repair crew returns
function returnRepairCrew()
	playerRepulse:setRepairCrewCount(8)
	if retrieveRepairCrewButton ~= nil then
		playerRepulse:removeCustom(retrieveRepairCrewButton)
	end
	if retrieveRepairCrewButtonTac ~= nil then
		playerRepulse:removeCustom(retrieveRepairCrewButtonTac)
	end
end
--Report on damaged beams on port side, start second plot
function beamDamageReport(delta)
	beamDamageReportTimer = beamDamageReportTimer - delta
	if beamDamageReportTimer < 0 then
		playerRepulse:addToShipLog("Repair crew reports that the port beam weapon emplacement is currently non-functional. No applicable spare parts found aboard","Magenta")
		plot1 = jumpDamageReport
		plot2 = portBeamEnable
		jumpDamageReportTimer = 30
	end
end
--Report on damaged jump drive, start third plot
function jumpDamageReport(delta)
	jumpDamageReportTimer = jumpDamageReportTimer - delta
	if jumpDamageReportTimer < 0 then
		if playerRepulse.debris1 then
			playerRepulse:addToShipLog("Repair crew reports the jump drive not operational. However, they may be able to adapt some of the space debris picked up earlier into suitable replacement parts. They are starting the fabrication process now","Magenta")
			plot3 = jumpPartFabrication
			jumpPartFabricationTimer = 60
		else
			playerRepulse:addToShipLog("Repair crew reports the jump drive inoperative. Additional parts are necessary","Magenta")
			plot3 = jumpPartGathering
		end
		plot1 = missileDamageReport
		missileDamageReportTimer = 30
	end
end
--Report on damaged missile systems
function missileDamageReport(delta)
	missileDamageReportTimer = missileDamageReportTimer - delta
	if missileDamageReportTimer < 0 then
		playerRepulse:addToShipLog("Repair crew says the missle weapons systems are not repairable with available components","Magenta")
		plot1 = damageSummaryReport
	end
end
--Report on completed repairs
function damageSummaryReport(delta)
	totalDiff = 0
	totalDiff = totalDiff + math.abs(playerRepulse.maxReactor - playerRepulse:getSystemHealth("reactor"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxBeam - playerRepulse:getSystemHealth("beamweapons"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxManeuver - playerRepulse:getSystemHealth("maneuver"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxMissile - playerRepulse:getSystemHealth("missilesystem"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxImpulse - playerRepulse:getSystemHealth("impulse"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxJump - playerRepulse:getSystemHealth("jumpdrive"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxFrontShield - playerRepulse:getSystemHealth("frontshield"))
	totalDiff = totalDiff + math.abs(playerRepulse.maxRearShield - playerRepulse:getSystemHealth("rearshield"))
	if totalDiff < .1 then
		playerRepulse:addToShipLog("Repair crew reports they have repaired as much as they can. Additional parts may be available in the junk yard. We have not been able to get long range communications online, so we are as yet unable to locate or contact any Human Navy stations.","Magenta")
		plot1 = nil
	end
end
--trigger: beam repaired 
function fixFlood(delta)
	fixFloodTimer = fixFloodTimer - delta
	if fixFloodTimer < 0 then
		if missileFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamFixStation then
					missileFixStation = candidate
				end
			until(missileFixStation ~= nil)
			fixFloodTimer = delta + 30
			return
		end
		if missileFixStation ~= nil then
			if missileFixStationMessage == nil then
				playerRepulse:addToShipLog(string.format("[Edwina (repair crew member)] My dad can fix our missile systems. He's got years of experience. He's on %s",missileFixStation:getCallSign()),"Magenta")
				missileFixStationMessage = "sent"
			end
		end
		if shieldFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamFixStation and candidate ~= missileFixStation then
					shieldFixStation = candidate
				end
			until(shieldFixStation ~= nil)
			fixFloodTimer = delta + 30
			return
		end
		if shieldFixStation ~= nil then
			if shieldFixStationMessage == nil then
				playerRepulse:addToShipLog(string.format("[Amir (repair crew member)] My sister fixes shield systems. I bet she could easily get our shields working. She works at a shop on %s",shieldFixStation:getCallSign()),"Magenta")
				shieldFixStationMessage = "sent"
			end
		end
		if impulseFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamFixStation and candidate ~= missileFixStation and candidate ~= shieldFixStation then
					impulseFixStation = candidate
				end
			until(impulseFixStation ~= nil)
			fixFloodTimer = delta + 30
			return
		end
		if impulseFixStation ~= nil then
			if impulseFixStationMessage == nil then
				playerRepulse:addToShipLog(string.format("[Janet (repair crew member)] Johnny, my son, does practical research on impulse drives. He's on %s. He can probably get our impulse engines up to full capacity",impulseFixStation:getCallSign()),"Magenta")
				impulseFixStationMessage = "sent"
			end
		end
		if longRangeFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamFixStation and candidate ~= missileFixStation and candidate ~= shieldFixStation and candidate ~= impulseFixStation then
					longRangeFixStation = candidate
				end
			until(longRangeFixStation ~= nil)
			fixFloodTimer = delta + 30
			return
		end
		if longRangeFixStation ~= nil then
			if longRangeFixStationMessage == nil then
				playerRepulse:addToShipLog(string.format("[Fred (repair crew member)] The outfit my wife works for on %s specializes in long range communication. She could probably get our systems connected back up to the Human Navy communication network",longRangeFixStation:getCallSign()),"Magenta")
				longRangeFixStationMessage = "sent"
			end
		end
		if jumpFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamFixStation and candidate ~= missileFixStation and candidate ~= shieldFixStation and candidate ~= impulseFixStation and candidate ~= longRangeFixStation then
					jumpFixStation = candidate
				end
			until(jumpFixStation ~= nil)
			fixFloodTimer = delta + 30
			return
		end
		if jumpFixStation ~= nil then
			if jumpFixStationMessage == nil then
				playerRepulse:addToShipLog(string.format("[Nancy (repair crew member)] Our jump drive needs help. My brother on %s fixes jump drives and he could get ours working",jumpFixStation:getCallSign()),"Magenta")
				jumpFixStationMessage = "sent"
			end
		end
		if reactorFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and candidate ~= beamFixStation and candidate ~= missileFixStation and candidate ~= shieldFixStation and candidate ~= impulseFixStation and candidate ~= longRangeFixStation and candidate ~= jumpFixStation then
					reactorFixStation = candidate
				end
			until(reactorFixStation ~= nil)
			fixFloodTimer = delta + 30
			return
		end
		if reactorFixStation ~= nil then
			if reactorFixStationMessage == nil then
				playerRepulse:addToShipLog(string.format("[Manuel (repair crew member)] The reactor could use some tuning. My cousin can fix us up. He does work on reactors on %s",reactorFixStation:getCallSign()),"Magenta")
				reactorFixStationMessage = "sent"
				if playerRepulse:hasPlayerAtPosition("Relay") then
					if crewFixButtonMsg == nil then
						crewFixButtonMsg = "crewFixButtonMsg"
						playerRepulse:addCustomButton("Relay",crewFixButtonMsg,"crew fixers",showCrewFixers)
					end
				end
				if playerRepulse:hasPlayerAtPosition("Operations") then
					if crewFixButtonMsgOp == nil then
						crewFixButtonMsgOp = "crewFixButtonMsgOp"
						playerRepulse:addCustomButton("Operations",crewFixButtonMsgOp,"crew fixers",showCrewFixers)
					end
				end
				plot1 = nil
			end
		end
	end
end
function showCrewFixers()
	oMsg = ""
	if not playerRepulse.missileFix then
		oMsg = oMsg .. string.format(" Missiles:%s(%s) ",missileFixStation:getCallSign(),missileFixStation:getSectorName())
	end
	if not playerRepulse.frontShieldFix and not playerRepulse.rearShieldFix then
		oMsg = oMsg .. string.format(" Shields:%s(%s) ",shieldFixStation:getCallSign(),shieldFixStation:getSectorName())
	end
	if not playerRepulse.impulseFix then
		oMsg = oMsg .. string.format(" Impulse:%s(%s) ",impulseFixStation:getCallSign(),impulseFixStation:getSectorName())
	end
	if not playerRepulse.longRangeFix then
		oMsg = oMsg .. string.format(" Communications:%s(%s) ",longRangeFixStation:getCallSign(),longRangeFixStation:getSectorName())
	end
	if not playerRepulse.jumpFix then
		oMsg = oMsg .. string.format(" Jump:%s(%s) ",jumpFixStation:getCallSign(),jumpFixStation:getSectorName())
	end
	if not playerRepulse.reactorFix then
		oMsg = oMsg .. string.format(" Reactor:%s(%s) ",reactorFixStation:getCallSign(),reactorFixStation:getSectorName())
	end
	if oMsg == nil then
		if crewFixButtonMsg ~= nil then
			playerRepulse:removeCustom(crewFixButtonMsg)
		end
		if crewFixButtonMsgOp ~= nil then
			playerRepulse:removeCustom(crewFixButtonMsgOp)		
		end
	else
		playerRepulse:addToShipLog("Repair crew suggested locations for ship fixes:","Magenta")
		playerRepulse:addToShipLog(oMsg,"Magenta")
	end
end
--[[-------------------------------------------------------------------
	Second Plot port beam repair
--]]-------------------------------------------------------------------
function portBeamEnable(delta)
	if playerRepulse:getRepairCrewCount() > 1 then
		plot2 = suggestBeamFix
		suggestBeamFixTimer = 70
	end
end
--Repair suggestion
function suggestBeamFix(delta)
	suggestBeamFixTimer = suggestBeamFixTimer - delta
	if suggestBeamFixTimer < 0 then
		if beamFixStation == nil then
			repeat
				candidate = stationList[math.random(1,#stationList)]
				if candidate ~= nil and candidate:isValid() and distance(candidate,playerRepulse) < 80000 then
					beamFixStation = candidate
				end
			until(beamFixStation ~= nil)
			playerRepulse:addToShipLog(string.format("[Kent (repair crew member)] My brother on %s in %s can fix our port side beam weapon",beamFixStation:getCallSign(),beamFixStation:getSectorName()),"Magenta")
			plot2 = chaseTrigger
		end
	end
end
--Ship gets repaired then chased
function chaseTrigger(delta)
	if plot1 == nil then
		junkYardDogTimer = 20
		plot2 = junkYardDog
	end
end
--Sic junk yard dog on player ship
function junkYardDog(delta)
	junkYardDogTimer = junkYardDogTimer - delta
	if junkYardDogTimer < 0 then
		if difficulty < 1 then
			junkYardDog = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Drone"):setPosition(brigx-50,brigy-50):orderAttack(playerRepulse):setRotation(180)
		elseif difficulty > 1 then
			junkYardDog = CpuShip():setFaction("Exuari"):setTemplate("Fighter"):setPosition(brigx-50,brigy-50):orderAttack(playerRepulse):setRotation(180)
		else
			junkYardDog = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Fighter"):setPosition(brigx-50,brigy-50):orderAttack(playerRepulse):setRotation(180)
		end
		playerRepulse:addToShipLog(string.format("[Sensor tech] Looks like %s figured out where we went and has sicced %s on us.",brigStation:getCallSign(),junkYardDog:getCallSign()),"Magenta")
		playerRepulse:addToShipLog(string.format("[Engineering tech] With our hull at %i, we better hope our shields hold",playerRepulse:getHull()),"Magenta")
		borisChaseTimer = 300
		plot2 = borisChase
	end
end
function borisChase(delta)
	borisChaseTimer = borisChaseTimer - delta
	if borisChaseTimer < 0 then
		borisChaseTimer = delta + 300 + random(1,300)
		if not junkZone:isInside(playerRepulse) then
			if junkChaser ~= nil and junkChaser:isValid() then
				chaserMsgChoice = math.random(1,3)
				if chaserMsgChoice == 1 then
					playerRepulse:addToShipLog(string.format("[%s] You won't get away so easily",junkChaser:getCallSign()),"Red")
				elseif chaserMsgChoice == 2 then
					playerRepulse:addToShipLog(string.format("[%s] You can run, but you can't hide",junkChaser:getCallSign()),"Red")
				else
					playerRepulse:addToShipLog(string.format("[%s] I will get you yet",junkChaser:getCallSign()),"Red")
				end
			else
				if difficulty < 1 then
					junkChaser = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Drone"):setPosition(brigx-100,brigy-100):orderAttack(playerRepulse):setRotation(180)
				elseif difficulty > 1 then
					junkChaser = CpuShip():setFaction("Exuari"):setTemplate("Fighter"):setPosition(brigx-100,brigy-100):orderAttack(playerRepulse):setRotation(180)
				else
					junkChaser = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Fighter"):setPosition(brigx-100,brigy-100):orderAttack(playerRepulse):setRotation(180)
				end
				junkChaser:onDestruction(resetBoris)
				chaserMsgChoice = math.random(1,3)
				if chaserMsgChoice == 1 then
					junkChaser:sendCommsMessage(playerRepulse,"You don't steal from Boris Junk Yard without consequences. I'm coming for you")
				elseif chaserMsgChoice == 2 then
					junkChaser:sendCommsMessage(playerRepulse,"I saw you steal that ship. You'll rue the day")
				else
					junkChaser:sendCommsMessage(playerRepulse,"Stealing a ship, eh? We'll just see about that")
				end
			end
		end
	end
end
function resetBoris(self, instigator)
	if borisChaseTimer < 300 then
		borisChaseTimer = 300
	end
	chaserMsgChoice = math.random(1,3)
	if chaserMsgChoice == 1 then
		playerRepulse:addToShipLog(string.format("[%s] You can't get rid of me that easily",self:getCallSign()),"Red")
	elseif chaserMsgChoice == 2 then
		playerRepulse:addToShipLog(string.format("[%s] I'll be back",self:getCallSign()),"Red")
	else
		playerRepulse:addToShipLog(string.format("[%s] I've got plenty of ships",self:getCallSign()),"Red")
	end
end
--[[-------------------------------------------------------------------
	Third Plot jump drive repair
--]]-------------------------------------------------------------------
function jumpPartGathering(delta)
	if playerRepulse.debris1 then
		plot3 = jumpPartRecognition
		jumpPartRecognitionTimer = 15
	end
end
--Identify debris as useful for repair of jump drive
function jumpPartRecognition(delta)
	jumpPartRecognitionTimer = jumpPartRecognitionTimer - delta
	if jumpPartRecognitionTimer < 0 then
		playerRepulse:addToShipLog("Repair crew thinks they can use the space debris recently acquired to make repair parts for the jump drive. They are starting the fabrication process now.","Magenta")
		plot3 = jumpPartFabrication
		jumpPartFabricationTimer = 60
	end
end
--Jump drive repairable 
function jumpPartFabrication(delta)
	jumpPartFabricationTimer = jumpPartFabricationTimer - delta
	if jumpPartFabricationTimer < 0 then
		playerRepulse:addToShipLog("Repair crew finished jump drive part fabrication. They believe the jump drive should be functional soon","Magenta")
		playerRepulse.maxJump = .5
		plot3 = nil
	end
end
--[[-------------------------------------------------------------------
	Fourth plot return home 
--]]-------------------------------------------------------------------
function returnHome(delta)
	for i=1,#friendlyStationList do
		if friendlyStationList[i] ~= nil and friendlyStationList[i]:isValid() then
			if playerRepulse:isDocked(friendlyStationList[i]) then
				victory("Human Navy")
			end
		end
	end
end
--[[-------------------------------------------------------------------
	Kraylor Patrol plot 
--]]-------------------------------------------------------------------
function kraylorPatrol(delta)
	if kraylorPatrolSpawnDelay > 0 then
		kraylorPatrolSpawnDelay = kraylorPatrolSpawnDelay - delta
	end
	if kraylorPatrolSpawnDelay < 0 then
		kraylorPatrolSpawnDelay = delta + random(5,15)
		kgr = {}	--kraylor group reconcile
		for kpidx, kpobj in ipairs(kraylorPatrolList) do
			if kpobj ~= nil and kpobj:isValid() then
				if kpobj.target ~= nil and kpobj.target:isValid() then
					if distance(kpobj, kpobj.target) < 500 then
						kpobj.target = randomStation(enemyStationList)
						ktx, kty = kpobj.target:getPosition()
						kpobj:orderFlyTowards(ktx, kty)
					end
				else
					kpobj.target = randomStation(enemyStationList)
					ktx, kty = kpobj.target:getPosition()
					kpobj:orderFlyTowards(ktx, kty)
				end
				if junkZone:isInside(kpobj) then
					ktx, kty = kpobj.target:getPosition()					
					kpobj:orderFlyTowardsBlind(ktx, kty)
				end
				kgr[kpobj.groupID] = true
			end
		end
		kraylorPatrolCount = 0
		for _, kgi in ipairs(kgr) do
			if kgi then
				kraylorPatrolCount = kraylorPatrolCount + 1
			end
		end
		if playerRepulse ~= nil and playerRepulse:isValid() and playerRepulse:getFaction() == "Human Navy" then
			kraylorAlerted = true
			patrolLimit = #enemyStationList * 2
		else
			kraylorAlerted = false
			patrolLimit = #enemyStationList
		end
		if kraylorPatrolCount < patrolLimit then
			target = nil
			repeat
				target = randomStation(enemyStationList)
			until(target ~= nil)
			--spawn patrol group
			tx, ty = target:getPosition()
			if kraylorAlerted and kraylorPatrolCount/patrolLimit*100 < random(1,100) then
				nearFriend, rest = nearStations(playerRepulse, friendlyStationList)
				nfx, nfy = nearFriend:getPosition()
				plx, ply = playerRepulse:getPosition()
				patrolGroup = spawnEnemies((nfx+plx)/2,(nfy+ply)/2,random(.8,1.2),"Kraylor")				
			else
				dx, dy = vectorFromAngle(random(0,360),random(25000,40000))
				patrolGroup = spawnEnemies(tx+dx,ty+dy,random(.8,2.2),"Kraylor")
			end
			kGroup = kGroup + 1
			for _, enemy in ipairs(patrolGroup) do
				enemy:orderFlyTowards(tx, ty)
				enemy.target = target
				enemy.groupID = kGroup
				table.insert(kraylorPatrolList,enemy)
			end
		end
	end
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * difficulty * 14, 5)	--assume player ship repulse at strength 14
	enemyPosition = 0
	sp = random(500,800)			--random spacing of spawned group
	deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
	enemyList = {}
	-- Reminder: stsl and stnl are ship template score and name list
	while enemyStrength > 0 do
		shipTemplateType = math.random(1,#stsl)
		while stsl[shipTemplateType] > enemyStrength * 1.1 + 5 do
			shipTemplateType = math.random(1,#stsl)
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
--[[-------------------------------------------------------------------
	Transport plot 
--]]-------------------------------------------------------------------
function randomStation(randomStations)
	stationCount = 0
	for sidx, obj in ipairs(randomStations) do
		if obj ~= nil and obj:isValid() then
			stationCount = stationCount + 1
		else
			table.remove(randomStations,sidx)
		end
	end
	return randomStations[math.random(1,#randomStations)]
end
--nobj = named object for comparison purposes
--compareStationList = list of stations to compare against
function nearStations(nobj, compareStationList)
	remainingStations = {}
	closestDistance = 9999999
	for ri, obj in ipairs(compareStationList) do
		if obj ~= nil and obj:isValid() and obj:getCallSign() ~= nobj:getCallSign() then
			table.insert(remainingStations,obj)
			currentDistance = distance(nobj, obj)
			if currentDistance < closestDistance then
				closest = obj
				closestDistance = currentDistance
			end
		end
	end
	for ri, obj in ipairs(remainingStations) do
		if obj:getCallSign() == closest:getCallSign() then
			table.remove(remainingStations,ri)
		end
	end
	return closest, remainingStations
end
--pool = number of nearest stations to randomly choose from
--nobj = named object for comparison purposes
--partialStationList = list of station to compare against
function randomNearStation(pool,nobj,partialStationList)
	distanceStations = {}
	rs = {}
	cs, rs[1] = nearStations(nobj,partialStationList)
	table.insert(distanceStations,cs)
	for ni=2,pool do
		cs, rs[ni] = nearStations(nobj,rs[ni-1])
		table.insert(distanceStations,cs)
	end
	return distanceStations[math.random(1,pool)]
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
							kobj.target = randomNearStation(math.random(3,7),kobj,enemyStationList)
							kobj.undock_delay = math.random(1,4)
							kobj:orderDock(kobj.target)
						end
					end
				else
					kobj.target = randomNearStation(math.random(3,7),kobj,enemyStationList)
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
		if kraylorTransportCount < #enemyStationList then
			target = nil
			repeat
				target = randomStation(enemyStationList)
			until(target ~= nil and target:isValid())
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
			if random(1,100) < 30 then
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
							obj.target = randomNearStation(math.random(4,8),obj,stationList)
							obj.undock_delay = math.random(1,4)
							obj:orderDock(obj.target)
						end
					end
				else
					obj.target = randomNearStation(math.random(4,8),obj,stationList)
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
		if independentTransportCount < #stationList then
			target = nil
			repeat
				target = randomStation(stationList)				
			until(target ~= nil and target:isValid())
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
--[[-------------------------------------------------------------------
	Junk Yard Billboard Plot 
--]]-------------------------------------------------------------------
function billboardUpdate(delta)
	signsScanned = 0
	if playerFighter ~= nil and playerFighter:isValid() then
		if Sign1:isScannedBy(playerFighter) then
			signsScanned = signsScanned + 1
		end
		if Sign2:isScannedBy(playerFighter) then
			signsScanned = signsScanned + 1
		end
		if Sign3:isScannedBy(playerFighter) then
			signsScanned = signsScanned + 1
		end
	end
	if playerRepulse ~= nil and playerRepulse:isValid() then
		if Sign1:isScannedBy(playerRepulse) then
			signsScanned = signsScanned + 1
		end
		if Sign2:isScannedBy(playerRepulse) then
			signsScanned = signsScanned + 1
		end
		if Sign3:isScannedBy(playerRepulse) then
			signsScanned = signsScanned + 1
		end
	end
	if signsScanned == 1 then
		junkZone:setColor(255,165,0)
	end
	if signsScanned == 2 then
		junkZone:setColor(128,0,128)
	end
	if signsScanned >= 3 then
		junkZone:setLabel("Boris Junk Yard")
		junkZone.color = "purple"
		flashTimer = 5
		plotSign = billboardFlash
	end
end
function billboardFlash(delta)
	flashTimer = flashTimer - delta
	if flashTimer < 0 then
		if junkZone.color == "purple" then
			junkZone:setColor(255,165,0)
			junkZone.color = "orange"
		else
			junkZone:setColor(128,0,128)
			junkZone.color = "purple"
		end
		flashTimer = delta + 5
	end
end
--[[-------------------------------------------------------------------
	Ship Health Plot 
--]]-------------------------------------------------------------------
function shipHealth(delta)
	playerShipHealth(delta)
	enemyShipHealth(delta)
end
--fighter player ship health
function scragHealth(delta)
	if playerFighter:getSystemHealth("reactor") > playerFighter.maxReactor then
		playerFighter:setSystemHealth("reactor",playerFighter.maxReactor)
	end
	if playerFighter:getSystemHealth("beamweapons") > playerFighter.maxBeam then
		playerFighter:setSystemHealth("beamweapons",playerFighter.maxBeam)
	end
	if playerFighter:getSystemHealth("maneuver") > playerFighter.maxManeuver then
		playerFighter:setSystemHealth("maneuver",playerFighter.maxManeuver)
	end
	if playerFighter:getSystemHealth("impulse") > playerFighter.maxImpulse then
		playerFighter:setSystemHealth("impulse",playerFighter.maxImpulse)
	end
	if playerFighter:getSystemHealth("frontshield") > playerFighter.maxFrontShield then
		playerFighter:setSystemHealth("frontshield",playerFighter.maxFrontShield)
	end
end
--repulse player ship health
function plunderHealth(delta)
	if playerRepulse:getSystemHealth("reactor") > playerRepulse.maxReactor then
		playerRepulse:setSystemHealth("reactor",playerRepulse.maxReactor)
	end
	if playerRepulse:getSystemHealth("beamweapons") > playerRepulse.maxBeam then
		playerRepulse:setSystemHealth("beamweapons",playerRepulse.maxBeam)
	end
	if playerRepulse:getSystemHealth("maneuver") > playerRepulse.maxManeuver then
		playerRepulse:setSystemHealth("maneuver",playerRepulse.maxManeuver)
	end
	if playerRepulse:getSystemHealth("missilesystem") > playerRepulse.maxMissile then
		playerRepulse:setSystemHealth("missilesystem",playerRepulse.maxMissile)
	end
	if playerRepulse:getSystemHealth("impulse") > playerRepulse.maxImpulse then
		playerRepulse:setSystemHealth("impulse",playerRepulse.maxImpulse)
	end
	if playerRepulse:getSystemHealth("warp") > playerRepulse.maxWarp then
		playerRepulse:setSystemHealth("warp",playerRepulse.maxWarp)
	end
	if playerRepulse:getSystemHealth("jumpdrive") > playerRepulse.maxJump then
		playerRepulse:setSystemHealth("jumpdrive",playerRepulse.maxJump)
	end
	if playerRepulse:getSystemHealth("frontshield") > playerRepulse.maxFrontShield then
		playerRepulse:setSystemHealth("frontshield",playerRepulse.maxFrontShield)
	end
	if playerRepulse:getSystemHealth("rearshield") > playerRepulse.maxRearShield then
		playerRepulse:setSystemHealth("rearshield",playerRepulse.maxRearShield)
	end
end
--other ship health
function enemyShipHealth(delta)
	for i=1,#junkShips do
		if junkShips[i]:isValid() then
			if junkShips[i]:getSystemHealth("reactor") > junkShips[i].maxReactor then
				junkShips[i]:setSystemHealth("reactor",junkShips[i].maxReactor)
			end
			if junkShips[i]:getSystemHealth("beamweapons") > junkShips[i].maxBeam then
				junkShips[i]:setSystemHealth("beamweapons",junkShips[i].maxBeam)
			end
			if junkShips[i]:getSystemHealth("maneuver") > junkShips[i].maxManeuver then
				junkShips[i]:setSystemHealth("maneuver",junkShips[i].maxManeuver)
			end
			if junkShips[i]:getSystemHealth("missilesystem") > junkShips[i].maxMissile then
				junkShips[i]:setSystemHealth("missilesystem",junkShips[i].maxMissile)
			end
			if junkShips[i]:getSystemHealth("impulse") > junkShips[i].maxImpulse then
				junkShips[i]:setSystemHealth("impulse",junkShips[i].maxImpulse)
			end
			if junkShips[i]:getSystemHealth("warp") > junkShips[i].maxWarp then
				junkShips[i]:setSystemHealth("warp",junkShips[i].maxWarp)
			end
			if junkShips[i]:getSystemHealth("jumpdrive") > junkShips[i].maxJump then
				junkShips[i]:setSystemHealth("jumpdrive",junkShips[i].maxJump)
			end
			if junkShips[i]:getSystemHealth("frontshield") > junkShips[i].maxFrontShield then
				junkShips[i]:setSystemHealth("frontshield",junkShips[i].maxFrontShield)
			end
			if junkShips[i]:getSystemHealth("rearshield") > junkShips[i].maxRearShield then
				junkShips[i]:setSystemHealth("rearshield",junkShips[i].maxRearShield)
			end
		end
	end
end

function update(delta)
	bobsx, bobsy = vectorFromAngle(stationWig.angle,3000)
	stationWig:setPosition(bwx+bobsx,bwy+bobsy):setRotation(stationWig.angle)
	stationWig.angle = stationWig.angle + .02
	malx, maly = vectorFromAngle(stationMal.angle,3000)
	stationMal:setPosition(msx+malx,msy+maly):setRotation(stationMal.angle)
	stationMal.angle = stationMal.angle + .05
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
	if plotH ~= nil then	--ship health (player and junk yard)
		plotH(delta)
	end
	if plotIT ~= nil then	--independent transport plot
		plotIT(delta)
	end
	if plotKT ~= nil then	--kraylor transport plot
		plotKT(delta)
	end
	if plotKP ~= nil then	--kraylor patrol plot
		plotKP(delta)
	end
	if plotSign ~= nil then
		plotSign(delta)
	end
end