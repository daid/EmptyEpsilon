-- Name: Escape
-- Description: Escape imprisonment and return home. 
---
--- Mission consists of one ship with a full crew. Engineer and Science will be busy
---
--- Version 4 Adds more activity for the weapons officer (6Apr2020)
-- Type: Mission, somewhat replayable
-- Variation[Easy]: Easy goals and/or enemies
-- Variation[Hard]: Hard goals and/or enemies

require("utils.lua")

-------------------------------
--	Initialization routines  --
-------------------------------
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
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
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
	setListOfStations()
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
	debris3:setDescriptions("Debris","Debris: Various broken ship components. Possibly useful for hull or reactor systems repair")
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
	--print("end of init")
end
function pickCoordinate(coordinateArrayX,coordinateArrayY)
--pick a coordinate at random from the passed table
--remove selected coordinates and return selected coordinates
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
function setVariations()
--translate variations into a numeric difficulty value
	if string.find(getScenarioVariation(),"Easy") then
		difficulty = .5
	elseif string.find(getScenarioVariation(),"Hard") then
		difficulty = 2
	else
		difficulty = 1		--default (normal)
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
function buildNearbyStations()
-- Organically (simulated asymetrically) grow stations from a central grid location
-- Order of creation: 	enemy stations, planet, enemy stations, planet, 
-- 						independent stations, black hole, independent stations, black hole
-- Human Navy stations (friendly stations) come later in the game after the communications get repaired.
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
-----------------------------
--	Station communication  --
-----------------------------
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
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
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
					if difficulty > 1 then
						if impulseFixStation.good_base == nil then
							repeat
								candidate = stationList[math.random(1,#stationList)]
								if candidate ~= nil and candidate:isValid() then
									local good_count = 0
									for good, good_data in pairs(candidate.comms_data.goods) do
										good_count = good_count + 1
									end
									if good_count > 0 then
										for good, good_data in pairs(candidate.comms_data.goods) do
											impulseFixStation.impulse_good = good
										end
									end
								end
								if impulseFixStation.impulse_good ~= "food" and impulseFixStation.impulse_good ~= "medicine" then
									impulseFixStation.good_base = candidate
								end
							until(impulseFixStation.good_base ~= nil)
						end
						local impulse_good_quantity = 0
						if comms_source.goods ~= nil and comms_source.goods[impulseFixStation.impulse_good] ~= nil and comms_source.goods[impulseFixStation.impulse_good] > 0 then
							impulse_good_quantity = comms_source.goods[impulseFixStation.impulse_good]
						end
						if impulse_good_quantity > 0 then
							setCommsMessage(string.format("Piece of cake. Thanks for the %s",impulseFixStation.impulse_good))
							playerRepulse.maxImpulse = 1
							playerRepulse.impulseFix = "done"
							comms_source.goods[impulseFixStation.impulse_good] = comms_source.goods[impulseFixStation.impulse_good] - 1
							comms_source.cargo = comms_source.cargo + 1
							addCommsReply("Thank you", function()
								setCommsMessage("Sure. Mom, I'll see you at Christmas")
								playerRepulse:addReputationPoints(30)
								addCommsReply("Back",commsStation)
							end)
						else
							setCommsMessage(string.format("Piece of cake, but I'll need %s",impulseFixStation.impulse_good))
						end
					else
						setCommsMessage("Piece of cake")
						playerRepulse.maxImpulse = 1
						playerRepulse.impulseFix = "done"
						addCommsReply("Thank you", function()
							setCommsMessage("Sure. Mom, I'll see you at Christmas")
							playerRepulse:addReputationPoints(30)
							addCommsReply("Back",commsStation)
						end)
					end
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
					if difficulty >= 1 then
						if jumpFixStation.good_base == nil then
							repeat
								candidate = stationList[math.random(1,#stationList)]
								if candidate ~= nil and candidate:isValid() then
									local good_count = 0
									for good, good_data in pairs(candidate.comms_data.goods) do
										good_count = good_count + 1
									end
									if good_count > 0 then
										for good, good_data in pairs(candidate.comms_data.goods) do
											jumpFixStation.jump_good = good
										end
									end
								end
								if jumpFixStation.jump_good ~= "food" and jumpFixStation.jump_good ~= "medicine" then
									jumpFixStation.good_base = candidate
								end
							until(jumpFixStation.good_base ~= nil)
						end
						local jump_good_quantity = 0
						if comms_source.goods ~= nil and comms_source.goods[jumpFixStation.jump_good] ~= nil and comms_source.goods[jumpFixStation.jump_good] > 0 then
							jump_good_quantity = comms_source.goods[jumpFixStation.jump_good]
						end
						if jump_good_quantity > 0 then
							setCommsMessage(string.format("That should not be hard to do. I could probably do that in my sleep. Thanks for bringing %s",jumpFixStation.jump_good))
							comms_source.goods[jumpFixStation.jump_good] = comms_source.goods[jumpFixStation.jump_good] - 1
							player.cargo = player.cargo + 1
							playerRepulse.maxJump = 1
							playerRepulse.jumpFix = "done"
							addCommsReply("Thanks, bro", function()
								setCommsMessage("No problem. Treat your jump drive right and it'll always bring you home")
								playerRepulse:addReputationPoints(30)
								addCommsReply("Back",commsStation)
							end)
						else
							setCommsMessage(string.format("That should not be hard to do. I could probably do that in my sleep. But I'll need some %s",jumpFixStation.jump_good))
						end
					else
						setCommsMessage("That should not be hard to do. I could probably do that in my sleep")
						playerRepulse.maxJump = 1
						playerRepulse.jumpFix = "done"
						addCommsReply("Thanks, bro", function()
							setCommsMessage("No problem. Treat your jump drive right and it'll always bring you home")
							playerRepulse:addReputationPoints(30)
							addCommsReply("Back",commsStation)
						end)
					end
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
						--print("switched to Human Navy")
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
							--print(string.format("placed %s in %s: %.1f, %.1f",pStation:getCallSign(),pStation:getSectorName(),psx,psy))
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
						playerRepulse.frontShieldFix = "done"
						addCommsReply("Thanks", function()
							if shieldGoodBase == nil then
								repeat
									candidate = stationList[math.random(1,#stationList)]
									if candidate ~= nil and candidate:isValid() then
										local good_count = 0
										for good, good_data in pairs(candidate.comms_data.goods) do
											good_count = good_count + 1
										end
										if good_count > 0 then
											for good, good_data in pairs(candidate.comms_data.goods) do
												shieldGood = good
											end
										end
									end
									if shieldGood ~= "food" and shieldGood ~= "medicine" then
										shieldGoodBase = candidate
									end
								until(shieldGoodBase ~= nil)
							end
							setCommsMessage(string.format("Certainly. Bring back %s to get the rear shield fixed. You might find some at %s",shieldGood,shieldGoodBase:getCallSign()))
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
									if candidate ~= nil and candidate:isValid() then
										local good_count = 0
										for good, good_data in pairs(candidate.comms_data.goods) do
											good_count = good_count + 1
										end
										if good_count > 0 then
											for good, good_data in pairs(candidate.comms_data.goods) do
												shieldGood = good
											end
										end
									end
									if shieldGood ~= "food" and shieldGood ~= "medicine" then
										shieldGoodBase = candidate
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
				local shieldGoodQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[shieldGood] ~= nil and comms_source.goods[shieldGood] > 0 then
					shieldGoodQuantity = comms_source.goods[shieldGood]
				end
				if shieldGoodQuantity > 0 then
					addCommsReply(string.format("Yes, please take the %s and fix the shields",shieldGood), function()
						comms_source.goods[shieldGood] = comms_source.goods[shieldGood] - 1
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
    local ctd = comms_target.comms_data
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
			end)	--end station info comms reply branch
		end	--end public relations if branch
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
--------------------------
--	Ship communication  --
--------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		comms_data.goods = {}
		comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
		local shipType = comms_target:getTypeName()
		local goodCount = 0
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil then
				repeat
					comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
					goodCount = 0
					for good, goodData in pairs(comms_data.goods) do
						goodCount = goodCount + 1
					end
				until(goodCount >= 3)
			elseif shipType:find("Equipment") ~= nil then
				repeat
					comms_data.goods[componentGoods[math.random(1,#componentGoods)]] = {quantity = 1, cost = random(20,80)}
					goodCount = 0
					for good, goodData in pairs(comms_data.goods) do
						goodCount = goodCount + 1
					end
				until(goodCount >= 3)
			end
		end
	end
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
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
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
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				local luxuryQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
					luxuryQuantity = comms_source.goods["luxury"]
				end
				if luxuryQuantity > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format("Trade luxury for %s",good), function()
								comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
								if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
								comms_source.goods[good] = comms_source.goods[good] + 1
								setCommsMessage("Traded")
								addCommsReply("Back", commsShip)
							end)
						end
					end
				end
			end
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				freighter_multiplier = 1
			else
				freighter_multiplier = 2
			end
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
						if comms_source.cargo > 0 then
							if comms_source:takeReputationPoints(goodData.cost) then
								goodData.quantity = goodData.quantity - 1
								if comms_source.goods == nil then comms_source.goods = {} end
								if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
								comms_source.goods[good] = comms_source.goods[good] + 1
								comms_source.cargo = comms_source.cargo - 1
								setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
							else
								setCommsMessage("Insufficient reputation for purchase")
							end
						else
							setCommsMessage("Insufficient cargo space")
						end
						addCommsReply("Back", commsShip)
					end)
				end
			end	--freighter goods loop
		end
	end
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", commsShip)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
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
				comms_target:orderAttack(comms_source)
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
		local freighter_multiplier = 1
		if comms_data.friendlyness > 66 then
			setCommsMessage("Yes?")
			-- Offer destination information
			addCommsReply("Where are you headed?", function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply("Back", commsShip)
			end)
			-- Offer to trade goods if goods or equipment freighter
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
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					local luxuryQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
						luxuryQuantity = comms_source.goods["luxury"]
					end
					if luxuryQuantity > 0 then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format("Trade luxury for %s",good), function()
									comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
									if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
									comms_source.goods[good] = comms_source.goods[good] + 1
									setCommsMessage("Traded")
									addCommsReply("Back", commsShip)
								end)
							end
						end
					end
				end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 1
				else
					freighter_multiplier = 2
				end
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
							if comms_source.cargo > 0 then
								if comms_source:takeReputationPoints(goodData.cost) then
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then comms_source.goods = {} end
									if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.cargo = comms_source.cargo - 1
									setCommsMessage(string.format("Purchased %s from %s",good,comms_target:getCallSign()))
								else
									setCommsMessage("Insufficient reputation for purchase")
								end
							else
								setCommsMessage("Insufficient cargo space")
							end
							addCommsReply("Back", commsShip)
						end)
					end
				end	--freighter goods loop
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage("What do you want?")
			-- Offer to sell destination information
			destRep = random(1,5)
			addCommsReply(string.format("Where are you headed? (cost: %f reputation)",destRep), function()
				if not comms_source:takeReputationPoints(destRep) then
					setCommsMessage("Insufficient reputation")
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply("Back", commsShip)
			end)
			-- Offer to sell goods if goods or equipment freighter
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
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 2
				else
					freighter_multiplier = 3
				end
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
							if comms_source.cargo > 0 then
								if comms_source:takeReputationPoints(goodData.cost*freighter_multiplier) then
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
							else
								setCommsMessage("Insufficient cargo space")
							end
							addCommsReply("Back", commsShip)
						end)
					end
				end	--freighter goods loop
			end
		else	--least friendly
			setCommsMessage("Why are you bothering me?")
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 3
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*freighter_multiplier)), function()
								if comms_source.cargo > 0 then
									if comms_source:takeReputationPoints(goodData.cost*freighter_multiplier) then
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
								else
									setCommsMessage("Insufficient cargo space")
								end
								addCommsReply("Back", commsShip)
							end)
						end
					end	--freighter goods loop
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
------------------------------------------------------
--	First Plot starts when repulse hulk is scanned  --
------------------------------------------------------
function scanRepulse(delta)
	if difficulty >= 1 then
		plotSuffocate = checkForSuffocationOnFighter
	end
	if junkRepulse:isValid() then
		if junkRepulse:isFullyScannedBy(playerFighter) then
			hintRepulseTimer = random(30,60)
			plot1 = hintRepulse
		end
	end
end
function checkForSuffocationOnFighter(delta)
	if air_low_timer == nil then
		if difficulty > 1 then
			air_low_timer = delta + 60*3
		else
			air_low_timer = delta + 60*5
		end
	end
	air_low_timer = air_low_timer - delta
	if air_low_timer < 0 then
		if suffocation_timer == nil then
			if difficulty > 1 then
				suffocation_timer = delta + 60*3
			else
				suffocation_timer = delta + 60*5
			end
		end
		suffocation_timer = suffocation_timer - delta
		local suffocation_label = "Suffocation"
		local suffocation_label_minutes = math.floor(suffocation_timer / 60)
		local suffocation_label_seconds = math.floor(suffocation_timer % 60)
		if suffocation_label_minutes <= 0 then
			suffocation_label = string.format("%s %i",suffocation_label,suffocation_label_seconds)
		else
			suffocation_label = string.format("%s %i:%.2i",suffocation_label,suffocation_label_minutes,suffocation_label_seconds)
		end
		if playerFighter:hasPlayerAtPosition("Engineering") then
			if playerFighter.suffocation_message == nil then
				playerFighter.suffocation_message = "suffocation_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.suffocation_message,"Environmental systems show limited air remaining")
			end
			playerFighter.suffocation_timer = "suffocation_timer"
			playerFighter:addCustomInfo("Engineering",playerFighter.suffocation_timer,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			if playerFighter.suffocation_message_eng_plus == nil then
				playerFighter.suffocation_message_eng_plus = "suffocation_message_eng_plus"
				playerFighter:addCustomMessage("Engineering+",playerFighter.suffocation_message_eng_plus,"Environmental systems show limited air remaining")
			end
			playerFighter.suffocation_timer_eng_plus = "suffocation_timer_eng_plus"
			playerFighter:addCustomInfo("Engineering+",playerFighter.suffocation_timer_eng_plus,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("Science") then
			if playerFighter.suffocation_message_science == nil then
				playerFighter.suffocation_message_science = "suffocation_message_science"
				playerFighter:addCustomMessage("Science",playerFighter.suffocation_message_science,"Environmental systems show limited air remaining")
			end
			playerFighter.suffocation_timer_science = "suffocation_timer_science"
			playerFighter:addCustomInfo("Science",playerFighter.suffocation_timer_science,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("Operations") then
			if playerFighter.suffocation_message_ops == nil then
				playerFighter.suffocation_message_ops = "suffocation_message_ops"
				playerFighter:addCustomMessage("Operations",playerFighter.suffocation_message_ops,"Environmental systems show limited air remaining")
			end
			playerFighter.suffocation_timer_ops = "suffocation_timer_ops"
			playerFighter:addCustomInfo("Operations",playerFighter.suffocation_timer_ops,suffocation_label)
		end
		if suffocation_timer < 0 then
			globalMessage("You suffocated while aboard the fighter hulk")
			victory("Kraylor")
			if playerFighter.suffocation_timer ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer)
				playerFighter.suffocation_timer = nil
			end
			if playerFighter.suffocation_timer_eng_plus ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer_eng_plus)
				playerFighter.suffocation_timer_eng_plus = nil
			end
			if playerFighter.suffocation_timer_science ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer_science)
				playerFighter.suffocation_timer_science = nil
			end
			if playerFighter.suffocation_timer_ops ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer_ops)
				playerFighter.suffocation_timer_ops = nil
			end
		end
	end
end
function hintRepulse(delta)
--Engineer hints that the Repulse hulk has a jump drive that might function
	if difficulty >= 1 then
		plotSuffocate = checkForSuffocationOnFighter
	end
	hintRepulseTimer = hintRepulseTimer - delta
	if hintRepulseTimer < 0 then
		if playerFighter:hasPlayerAtPosition("Engineering") then
			repulseHintMessage = "repulseHintMessage"
			playerFighter:addCustomMessage("Engineering",repulseHintMessage,string.format("Reading through the scan data provided by science, you see that there could be a working jump drive on %s. However, if the crew wishes to transport over there, %s will need to get very close due to the minimal amount of energy remaining in the transporters.",junkRepulse:getCallSign(),playerFighter:getCallSign()))
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			repulseHintMessageEPlus = "repulseHintMessageEPlus"
			playerFighter:addCustomMessage("Engineering+",repulseHintMessageEPlus,string.format("Reading through the scan data provided by science, you see that there could be a working jump drive on %s. However, if the crew wishes to transport over there, %s will need to get very close due to the minimal amount of energy remaining in the transporters.",junkRepulse:getCallSign(),playerFighter:getCallSign()))
		end
		plot1 = hugRepulse
	end
end
function hugRepulse(delta)
--Get close enough and a transfer button will appear
	if difficulty >= 1 then
		plotSuffocate = checkForSuffocationOnFighter
	end
	if distance(playerFighter,junkRepulse) < 500 then
		if playerFighter:hasPlayerAtPosition("Engineering") then
			repulseTransferButton = "repulseTransferButton"
			playerFighter:addCustomButton("Engineering",repulseTransferButton,"Transfer to Repulse",repulseTransfer)
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			repulseTransferButtonEPlus = "repulseTransferButtonEPlus"
			playerFighter:addCustomButton("Engineering+",repulseTransferButtonEPlus,"Transfer to Repulse",repulseTransfer)
		end
		if repulseTransferButtonEPlus ~= nil or repulseTransferButton ~= nil then
			plot1 = nil
		end
	end
end
function repulseTransfer()
--Transfer crew and any artifacts picked up to Repulse
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
	plotKP = kraylorPatrol				--start sending out Kraylor patrols
	plotSuffocate = nil
	--print("end of transfer")
end
function augmentRepairCrew(delta)
--Former repair crew asks to be rescued to take up their jobs again
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
function returnRepairCrew()
--Repair crew returns
	playerRepulse:setRepairCrewCount(8)
	if retrieveRepairCrewButton ~= nil then
		playerRepulse:removeCustom(retrieveRepairCrewButton)
	end
	if retrieveRepairCrewButtonTac ~= nil then
		playerRepulse:removeCustom(retrieveRepairCrewButtonTac)
	end
end
function beamDamageReport(delta)
--Report on damaged beams on port side, start second plot
	beamDamageReportTimer = beamDamageReportTimer - delta
	if beamDamageReportTimer < 0 then
		playerRepulse:addToShipLog("Repair crew reports that the port beam weapon emplacement is currently non-functional. No applicable spare parts found aboard","Magenta")
		plot1 = jumpDamageReport
		plot2 = portBeamEnable
		jumpDamageReportTimer = 30
	end
end
function jumpDamageReport(delta)
--Report on damaged jump drive, start third plot
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
function missileDamageReport(delta)
--Report on damaged missile systems
	missileDamageReportTimer = missileDamageReportTimer - delta
	if missileDamageReportTimer < 0 then
		playerRepulse:addToShipLog("Repair crew says the missle weapons systems are not repairable with available components","Magenta")
		hull_damage_report_timer = 80
		plot1 = hullDamageReport
	end
end
function hullDamageReport(delta)
	hull_damage_report_timer = hull_damage_report_timer - delta
	if hull_damage_report_timer < 0 then
		plot1 = damageSummaryReport
		if playerRepulse.debris3 then
			playerRepulse:setHull(playerRepulse:getHull()*2)
			playerRepulse:addToShipLog("Repair crew applied some of the parts picked up to make some repairs on the hull","Magenta")
		end
	end
end
function damageSummaryReport(delta)
--Report on completed repairs
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
function fixFlood(delta)
--trigger: beam repaired 
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
				harassment_timer = 350
				plot1 = cumulativeHarassment
			end
		end
	end
end
function cumulativeHarassment(delta)
	harassment_timer = harassment_timer - delta
	if harassment_timer < 0 then
		local total_health = playerRepulse:getSystemHealth("reactor")
		total_health = total_health + playerRepulse:getSystemHealth("beamweapons")
		total_health = total_health + playerRepulse:getSystemHealth("maneuver")
		total_health = total_health + playerRepulse:getSystemHealth("missilesystem")
		total_health = total_health + playerRepulse:getSystemHealth("impulse")
		total_health = total_health + playerRepulse:getSystemHealth("jumpdrive")
		total_health = total_health + playerRepulse:getSystemHealth("frontshield")
		total_health = total_health + playerRepulse:getSystemHealth("rearshield")
		total_health = total_health + playerRepulse:getSystemHealth("warp")
		total_health = total_health/9
		local cpx, cpy = playerRepulse:getPosition()
		local dpx, dpy = vectorFromAngle(random(0,360),playerRepulse:getLongRangeRadarRange()+500)
		local fleet = spawnEnemies(cpx+dpx,cpy+dpy,total_health,"Exuari")
		for _, enemy in ipairs(fleet) do
			enemy:orderAttack(playerRepulse)
		end
		harassment_timer = delta + 200 - (difficulty*20)
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
------------------------------------
--	Second Plot port beam repair  --
------------------------------------
function portBeamEnable(delta)
	if playerRepulse:getRepairCrewCount() > 1 then
		plot2 = suggestBeamFix
		suggestBeamFixTimer = 70
	end
end
function suggestBeamFix(delta)
--Repair suggestion
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
function chaseTrigger(delta)
--Ship gets repaired then chased
	if plot1 == nil then
		junkYardDogTimer = 20
		plot2 = junkYardDog
	end
end
function junkYardDog(delta)
--Sic junk yard dog on player ship
	junkYardDogTimer = junkYardDogTimer - delta
	if junkYardDogTimer < 0 then
		if junkZone:isInside(playerRepulse) then
			if junk_yard_dog ~= nil and junk_yard_dog:isValid() then
				junkYardDogTimer = delta + 120 - (difficulty*20)
			else
				if difficulty < 1 then
					junk_yard_dog = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Drone"):setPosition(brigx-50,brigy-50):orderAttack(playerRepulse):setRotation(180)
				elseif difficulty > 1 then
					junk_yard_dog = CpuShip():setFaction("Exuari"):setTemplate("Fighter"):setPosition(brigx-50,brigy-50):orderAttack(playerRepulse):setRotation(180)
				else
					junk_yard_dog = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Fighter"):setPosition(brigx-50,brigy-50):orderAttack(playerRepulse):setRotation(180)
				end
			end
		else
			borisChaseTimer = 300
			plot2 = borisChase
		end
		if playerRepulse.junk_yard_dog_warning == nil then
			playerRepulse:addToShipLog(string.format("[Sensor tech] Looks like %s figured out where we went and has sicced %s on us.",brigStation:getCallSign(),junk_yard_dog:getCallSign()),"Magenta")
			playerRepulse:addToShipLog(string.format("[Engineering tech] With our hull at %i, we better hope our shields hold",playerRepulse:getHull()),"Magenta")
			playerRepulse.junk_yard_dog_warning = "sent"
		end
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
------------------------------------
--	Third Plot jump drive repair  --
------------------------------------
function jumpPartGathering(delta)
	if playerRepulse.debris1 then
		plot3 = jumpPartRecognition
		jumpPartRecognitionTimer = 15
	end
end
function jumpPartRecognition(delta)
--Identify debris as useful for repair of jump drive
	jumpPartRecognitionTimer = jumpPartRecognitionTimer - delta
	if jumpPartRecognitionTimer < 0 then
		playerRepulse:addToShipLog("Repair crew thinks they can use the space debris recently acquired to make repair parts for the jump drive. They are starting the fabrication process now.","Magenta")
		plot3 = jumpPartFabrication
		jumpPartFabricationTimer = 60
	end
end
function jumpPartFabrication(delta)
--Jump drive repairable 
	jumpPartFabricationTimer = jumpPartFabricationTimer - delta
	if jumpPartFabricationTimer < 0 then
		playerRepulse:addToShipLog("Repair crew finished jump drive part fabrication. They believe the jump drive should be functional soon","Magenta")
		playerRepulse.maxJump = .5
		plot3 = nil
	end
end
-------------------------------
--	Fourth plot return home  --
-------------------------------
function returnHome(delta)
	for i=1,#friendlyStationList do
		if friendlyStationList[i] ~= nil and friendlyStationList[i]:isValid() then
			if playerRepulse:isDocked(friendlyStationList[i]) then
				victory("Human Navy")
			end
		end
	end
end
---------------------------
--	Kraylor Patrol plot  --
---------------------------
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
					if distance(kpobj, kpobj.target) < 1000 then
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
			patrolLimit = #enemyStationList * (2 + difficulty)
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
----------------------
--	Transport plot  --
----------------------
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
function nearStations(nobj, compareStationList)
--nobj = named object for comparison purposes
--compareStationList = list of stations to compare against
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
function randomNearStation(pool,nobj,partialStationList)
--pool = number of nearest stations to randomly choose from
--nobj = named object for comparison purposes
--partialStationList = list of station to compare against
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
			obj:orderDock(obj.target)
			x, y = obj.target:getPosition()
			xd, yd = vectorFromAngle(random(0, 360), random(25000, 40000))
			obj:setPosition(x + xd, y + yd)
			table.insert(independentTransportList, obj)
		end
	end
end
--------------------------------
--	Junk Yard Billboard Plot  --
--------------------------------
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
------------------------
--	Ship Health Plot  --
------------------------
function shipHealth(delta)
	playerShipHealth(delta)
	enemyShipHealth(delta)
end
function scragHealth(delta)
--fighter player ship health
	if playerFighter:getSystemHealth("reactor") > playerFighter.maxReactor then
		playerFighter:setSystemHealth("reactor",playerFighter.maxReactor)
		if playerFighter.reactor_max_message == nil then
			if playerFighter:hasPlayerAtPosition("Engineering") then
				playerFighter.reactor_max_message = "reactor_max_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.reactor_max_message,"Reached maximum repair on reactor")
			end
		end
	end
	if playerFighter:getSystemHealth("beamweapons") > playerFighter.maxBeam then
		playerFighter:setSystemHealth("beamweapons",playerFighter.maxBeam)
		if playerFighter.beamweapons_max_message == nil then
			if playerFighter:hasPlayerAtPosition("Engineering") then
				playerFighter.beamweapons_max_message = "beamweapons_max_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.beamweapons_max_message,"Reached maximum repair on beam weapons")
			end
		end
	end
	if playerFighter:getSystemHealth("maneuver") > playerFighter.maxManeuver then
		playerFighter:setSystemHealth("maneuver",playerFighter.maxManeuver)
		if playerFighter.maneuver_max_message == nil then
			if playerFighter:hasPlayerAtPosition("Engineering") then
				playerFighter.maneuver_max_message = "maneuver_max_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.maneuver_max_message,"Reached maximum repair on maneuver")
			end
		end
	end
	if playerFighter:getSystemHealth("impulse") > playerFighter.maxImpulse then
		playerFighter:setSystemHealth("impulse",playerFighter.maxImpulse)
		if playerFighter.impulse_max_message == nil then
			if playerFighter:hasPlayerAtPosition("Engineering") then
				playerFighter.impulse_max_message = "impulse_max_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.impulse_max_message,"Reached maximum repair on impulse engines")
			end
		end
	end
	if playerFighter:getSystemHealth("frontshield") > playerFighter.maxFrontShield then
		playerFighter:setSystemHealth("frontshield",playerFighter.maxFrontShield)
		if playerFighter.frontshield_max_message == nil then
			if playerFighter:hasPlayerAtPosition("Engineering") then
				playerFighter.frontshield_max_message = "frontshield_max_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.frontshield_max_message,"Reached maximum repair on shields")
			end
		end
	end
end
function plunderHealth(delta)
--repulse player ship health
	if playerRepulse ~= nil and playerRepulse:isValid() then
		if playerRepulse:getSystemHealth("reactor") > playerRepulse.maxReactor then
			playerRepulse:setSystemHealth("reactor",playerRepulse.maxReactor)
			if playerRepulse.reactor_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.reactor_max_message = "reactor_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.reactor_max_message,"Reached maximum repair on reactor")
				end
			end
		end
		if playerRepulse:getSystemHealth("beamweapons") > playerRepulse.maxBeam then
			playerRepulse:setSystemHealth("beamweapons",playerRepulse.maxBeam)
			if playerRepulse.beamweapons_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.beamweapons_max_message = "beamweapons_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.beamweapons_max_message,"Reached maximum repair on beam weapons")
				end
			end
		end
		if playerRepulse:getSystemHealth("maneuver") > playerRepulse.maxManeuver then
			playerRepulse:setSystemHealth("maneuver",playerRepulse.maxManeuver)
			if playerRepulse.maneuver_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.maneuver_max_message = "maneuver_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.maneuver_max_message,"Reached maximum repair on maneuver")
				end
			end
		end
		if playerRepulse:getSystemHealth("missilesystem") > playerRepulse.maxMissile then
			playerRepulse:setSystemHealth("missilesystem",playerRepulse.maxMissile)
			if playerRepulse.missilesystem_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.missilesystem_max_message = "missilesystem_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.missilesystem_max_message,"Reached maximum repair on missile weapons")
				end
			end
		end
		if playerRepulse:getSystemHealth("impulse") > playerRepulse.maxImpulse then
			playerRepulse:setSystemHealth("impulse",playerRepulse.maxImpulse)
			if playerRepulse.impulse_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.impulse_max_message = "impulse_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.impulse_max_message,"Reached maximum repair on impulse engines")
				end
			end
		end
		if playerRepulse:getSystemHealth("warp") > playerRepulse.maxWarp then
			playerRepulse:setSystemHealth("warp",playerRepulse.maxWarp)
			if playerRepulse.warp_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.warp_max_message = "warp_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.warp_max_message,"Reached maximum repair on warp drive")
				end
			end
		end
		if playerRepulse:getSystemHealth("jumpdrive") > playerRepulse.maxJump then
			playerRepulse:setSystemHealth("jumpdrive",playerRepulse.maxJump)
			if playerRepulse.jumpdrive_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.jumpdrive_max_message = "jumpdrive_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.jumpdrive_max_message,"Reached maximum repair on jump drive")
				end
			end
		end
		if playerRepulse:getSystemHealth("frontshield") > playerRepulse.maxFrontShield then
			playerRepulse:setSystemHealth("frontshield",playerRepulse.maxFrontShield)
			if playerRepulse.frontshield_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.frontshield_max_message = "frontshield_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.frontshield_max_message,"Reached maximum repair on front shield")
				end
			end
		end
		if playerRepulse:getSystemHealth("rearshield") > playerRepulse.maxRearShield then
			playerRepulse:setSystemHealth("rearshield",playerRepulse.maxRearShield)
			if playerRepulse.rearshield_max_message == nil then
				if playerRepulse:hasPlayerAtPosition("Engineering") then
					playerRepulse.rearshield_max_message = "rearshield_max_message"
					playerRepulse:addCustomMessage("Engineering",playerRepulse.rearshield_max_message,"Reached maximum repair on rear shield")
				end
			end
		end
	end
end
function enemyShipHealth(delta)
--other ship health
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
	--print("Update: Orbits")
	bobsx, bobsy = vectorFromAngle(stationWig.angle,3000)
	stationWig:setPosition(bwx+bobsx,bwy+bobsy):setRotation(stationWig.angle)
	stationWig.angle = stationWig.angle + .02
	malx, maly = vectorFromAngle(stationMal.angle,3000)
	stationMal:setPosition(msx+malx,msy+maly):setRotation(stationMal.angle)
	stationMal.angle = stationMal.angle + .05
	if plotSuffocate ~= nil then
		plotSuffocate(delta)
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
