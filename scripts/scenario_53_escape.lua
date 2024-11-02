-- Name: Escape
-- Description: Escape imprisonment and return home. 
--- Mission consists of one ship with a full crew. Engineer and Science will be busy.
--- Version 5 switches to the max health system, preserves some sensor data in the final phase
--- and uses the place station scenario utility.
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[Enemies]: Configures the amount/strength of enemies spawned in the scenario.
-- Enemies[Easy]: Weaker/fewer enemies.
-- Enemies[Normal|Default]: Normal enemies.
-- Enemies[Hard]: Stronger/more enemies.
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you

require("utils.lua")
require("place_station_scenario_utility.lua")

-------------------------------
--	Initialization routines  --
-------------------------------
function init()
	scenario_version = "5.0.2"
	print(string.format("     -----     Scenario: Escape     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	wfv = "nowhere"		--wolf fence value - used for debugging
	setSettings()
	addRepulseToDatabase()
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
	GMDiagnosticOn = _("buttonGM", "Turn On Diagnostic")
	addGMFunction(GMDiagnosticOn,turnOnDiagnostic)
	independentTransportSpawnDelay = 20
	independentTransportList = {}
	kraylorTransportSpawnDelay = 40
	kraylorTransportList = {}
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
	debris1:setDescriptions(_("scienceDescription-debris", "Debris"),_("scienceDescription-debris", "Debris: Various broken ship components. Possibly useful for engine or weapons systems repair"))
	debrisx, debrisy = pickCoordinate(junkYardDebrisX,junkYardDebrisY)
	debris2 = Artifact():setPosition(debrisx, debrisy):setModel("ammo_box"):allowPickup(true):setScanningParameters(1,3):onPickUp(function(debris, pGrab) string.format("");pGrab.debris2 = true end)
	debris2:setDescriptions(_("scienceDescription-debris", "Debris"),_("scienceDescription-debris", "Debris: Various broken ship components. Possibly useful for shield or beam systems repair"))
	debrisx, debrisy = pickCoordinate(junkYardDebrisX,junkYardDebrisY)
	debris3 = Artifact():setPosition(debrisx, debrisy):setModel("ammo_box"):allowPickup(true):setScanningParameters(2,1):onPickUp(function(debris, pGrab) string.format("");pGrab.debris3 = true end)
	debris3:setDescriptions(_("scienceDescription-debris", "Debris"),_("scienceDescription-debris", "Debris: Various broken ship components. Possibly useful for hull or reactor systems repair"))
	--Signs
	junkYardSignX = {914126, 905479, 910303}
	junkYardSignY = {151100, 148728, 147102}
	junkZone = Zone():setPoints(905479, 148728, 906490, 146843, 910303, 147102, 914126, 151100, 912635, 154012, 905801, 151274)
	signx, signy = pickCoordinate(junkYardSignX, junkYardSignY)
	Sign1 = Artifact():setPosition(signx, signy):setModel("SensorBuoyMKI"):allowPickup(false):setScanningParameters(1,1)
	Sign1:setDescriptions(_("scienceDescription-buoy", "Space Message Buoy"),_("scienceDescription-buoy", "Space Message Buoy reading 'Welcome to the Boris Junk Yard and Emporium' in the Kraylor language"))
	signx, signy = pickCoordinate(junkYardSignX, junkYardSignY)
	Sign2 = Artifact():setPosition(signx, signy):setModel("SensorBuoyMKI"):allowPickup(false):setScanningParameters(1,1)
	Sign2:setDescriptions(_("scienceDescription-buoy", "Space Message Buoy"),_("scienceDescription-buoy", "Space Message Buoy reading 'Boris Junk Yard: Browse for parts, take home an asteroid for the kids' in the Kraylor language"))
	signx, signy = pickCoordinate(junkYardSignX, junkYardSignY)
	Sign3 = Artifact():setPosition(signx, signy):setModel("SensorBuoyMKI"):allowPickup(false):setScanningParameters(1,1)
	Sign3:setDescriptions(_("scienceDescription-buoy", "Space Message Buoy"),_("scienceDescription-buoy", "Space Message Buoy reading 'Boris Junk Yard: Best prices in 20 sectors' in the Kraylor language"))
	plotSign = billboardUpdate	
	--Initial player ship
	scrag_system_health = {
		["reactor"] =		{initial = .01,	max = .5,				msg = _("repair-msgEngineer&+", "Reached maximum repair on reactor"),			},
		["beamweapons"] =	{initial = -1,	max = random(-.7,-.2),	msg = _("repair-msgEngineer&+", "Reached maximum repair on beam weapons"),	},
		["maneuver"] =		{initial = .05,	max = .5,				msg = _("repair-msgEngineer&+", "Reached maximum repair on maneuver"),		},
		["missilesystem"] =	{initial = -1,	},
		["impulse"] =		{initial = -.5,	max = .2,				msg = _("repair-msgEngineer&+", "Reached maximum repair on impulse engines"),	},
		["warp"] =			{initial = -1,	},
		["jumpdrive"] =		{initial = -1,	},
		["frontshield"] =	{initial = .1,	max = .25,				msg = _("repair-msgEngineer&+", "Reached maximum repair on shields"),			},
		["rearshield"] =	{initial = .1,	},
	}
	playerFighter = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setCallSign("Scrag"):setPosition(912035, 152062)
	allowNewPlayerShips(false)
	for system,health in pairs(scrag_system_health) do
		playerFighter:setSystemHealth(system,health.initial)
		if health.max ~= nil then
			playerFighter:setSystemHealthMax(system,health.max)
		end
	end
	playerFighter:onDestruction(function()
		globalMessage(_("defeat-msgMainscreen","You were destroyed. The Human Navy did not receive your Kraylor intel."))
		victory("Kraylor")
	end)
	playerFighter:setScanProbeCount(1):setEnergy(50):setHull(5):setShields(5)
	playerFighter.maxCargo = 3
	playerFighter.cargo = playerFighter.maxCargo
	playerFighter.shipScore = 5
	player = playerFighter
	junkShips = {}
	local ship_spots = {
		{x = 909594, y = 148578},	--1
		{x = 910129, y = 150090},	--2
		{x = 909490, y = 149528},	--3
		{x = 910461, y = 151061},	--4
		{x = 910716, y = 149068},	--5
		{x = 911023, y = 151854},	--6
		{x = 913356, y = 151717},	--7
		{x = 906866, y = 148094},	--8
		{x = 911356, y = 150167},	--9
		{x = 910998, y = 153234},	--10
		{x = 907356, y = 150170},	--11
		{x = 913243, y = 150698},	--12
		{x = 908569, y = 149988},	--13
		{x = 912413, y = 152981},	--14
		{x = 907149, y = 149132},	--15
	}
	local ship_spot = tableRemoveRandom(ship_spots)
    junkRepulse = CpuShip():setFaction("Independent"):setTemplate("Repulse"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(14):setShields(0.00,2.00):setWeaponStorage("HVLI",0):setWeaponStorage("Homing",1)
	table.insert(junkShips,junkRepulse)	
	ship_spot = tableRemoveRandom(ship_spots)
    junkAdder = CpuShip():setFaction("Kraylor"):setTemplate("Adder MK4"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(9):setShields(0.00):setWeaponStorage("HVLI", 1)
	table.insert(junkShips,junkAdder)
	ship_spot = tableRemoveRandom(ship_spots)
    junkFreighter1 = CpuShip():setFaction("Kraylor"):setTemplate("Fuel Freighter 1"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(6):setShields(1.00, 0.00)
	table.insert(junkShips,junkFreighter1)
	ship_spot = tableRemoveRandom(ship_spots)
    junkFreighter2 = CpuShip():setFaction("Independent"):setTemplate("Goods Freighter 3"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(7):setShields(14.00, 0.00)
	table.insert(junkShips,junkFreighter2)
	ship_spot = tableRemoveRandom(ship_spots)
    junkDrone1 = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Drone"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(2)
	table.insert(junkShips,junkDrone1)
	ship_spot = tableRemoveRandom(ship_spots)
    junkDrone2 = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Drone"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(6)
	table.insert(junkShips,junkDrone2)
	ship_spot = tableRemoveRandom(ship_spots)
    junkDrone3 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Drone"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(2)
	table.insert(junkShips,junkDrone3)
	ship_spot = tableRemoveRandom(ship_spots)
    junkDrone4 = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Drone"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(7)
	table.insert(junkShips,junkDrone4)
	ship_spot = tableRemoveRandom(ship_spots)
    junkHornet1 = CpuShip():setFaction("Exuari"):setTemplate("MT52 Hornet"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(2):setShields(0.00)
	table.insert(junkShips,junkHornet1)
	ship_spot = tableRemoveRandom(ship_spots)
    junkHornet2 = CpuShip():setFaction("Ghosts"):setTemplate("MT52 Hornet"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(2):setShields(0.00)
	table.insert(junkShips,junkHornet2)
	ship_spot = tableRemoveRandom(ship_spots)
    junkHornet3 = CpuShip():setFaction("Arlenians"):setTemplate("MT52 Hornet"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(1):setShields(1.00)
	table.insert(junkShips,junkHornet3)
	ship_spot = tableRemoveRandom(ship_spots)
    junkHornet4 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(2):setShields(0.00)
	table.insert(junkShips,junkHornet4)
	ship_spot = tableRemoveRandom(ship_spots)
    junkPhobos = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(4):setShields(2.00, 1.00):setWeaponStorage("Homing", 1)
	table.insert(junkShips,junkPhobos)
	ship_spot = tableRemoveRandom(ship_spots)
    junkStrikeship = CpuShip():setFaction("Kraylor"):setTemplate("Strikeship"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(0):setShields(4.00, 0.00, 30.00, 30.00)
	table.insert(junkShips,junkStrikeship)
	ship_spot = tableRemoveRandom(ship_spots)
    junkScout = CpuShip():setFaction("Ktlitans"):setTemplate("Ktlitan Scout"):setPosition(ship_spot.x, ship_spot.y):orderIdle():setHull(4)
	table.insert(junkShips,junkScout)
	local systems = {"reactor","beamweapons","maneuver","missilesystem","impulse","warp","jumpdrive","frontshield","rearshield"}
	for i,ship in ipairs(junkShips) do
		for j,system in ipairs(systems) do
			ship:setSystemHealth(system,random(-.9,-.1))
			ship:setSystemHealthMax(system,ship:getSystemHealth(system))
		end
	end
	plunder_system_health = {
		["reactor"] =		{max = .4,	msg = _("repair-msgEngineer", "Reached maximum repair on reactor"),			},
		["beamweapons"] =	{max = .8,	msg = _("repair-msgEngineer", "Reached maximum repair on beam weapons"),	},
		["maneuver"] =		{max = nil},
		["missilesystem"] =	{max = -.1,	msg = _("repair-msgEngineer", "Reached maximum repair on missile weapons"),	},
		["impulse"] =		{max = .4,	msg = _("repair-msgEngineer", "Reached maximum repair on impulse engines"),	},
		["warp"] =			{max = -.1,	msg = _("repair-msgEngineer", "Reached maximum repair on warp drive"),		},
		["jumpdrive"] =		{max = -.1,	msg = _("repair-msgEngineer", "Reached maximum repair on jump drive"),		},
		["frontshield"] =	{max = .3,	msg = _("repair-msgEngineer", "Reached maximum repair on front shields"),	},
		["rearshield"] =	{max = .3,	msg = _("repair-msgEngineer", "Reached maximum repair on rear shield"),		},
	}
	junkRepulse:setSystemHealth("jumpdrive",-1):setBeamWeapon(1,0,0,0,0,0)
	junkRepulse:setSystemHealthMax("jumpdrive",.5)
    junkSupply = SupplyDrop():setFaction("Independent"):setPosition(909362, 151445):setEnergy(500):setWeaponStorage("Homing", 1):setWeaponStorage("Nuke", 0):setWeaponStorage("Mine", 0):setWeaponStorage("EMP", 0)
	playerShipHealth = scragHealth	--set function to constrain player ship health
	playerFighter:addToShipLog(string.format(_("goal-shipLog", "You escaped the brig of station %s and transported yourselves onto one of the spaceship hulks in a nearby holding area for junked spacecraft. You carry critical information for the Human Navy regarding Kraylor activity in this area. You need to make good your escape and dock with a Human Navy space station"), brigStation:getCallSign()),"Magenta")
	plot1 = scanRepulse				--enable first plot mission goal
	--print("end of init")
end
function tableRemoveRandom(array)
--	Remove random element from array and return it.
	-- Returns nil if the array is empty,
	-- analogous to `table.remove`.
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    local temp = array[selected_item]
    array[selected_item] = array[array_item_count]
    array[array_item_count] = temp
    return table.remove(array)
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
function setSettings()
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	},
		["Normal"] =	{number = 1,	},
		["Hard"] =		{number = 2,	},
	}
	difficulty =			murphy_config[getScenarioSetting("Murphy")].number
end
function addRepulseToDatabase()
--------------------------------------------------------------------------------------
--	Generic station descriptions: text and details from shipTemplates_stations.lua  --
--------------------------------------------------------------------------------------
	local station_key = _("scienceDB","Stations")
	local station_db = queryScienceDatabase(station_key)
	local class_key = _("scienceDB","Class")
	local size_key = _("scienceDB","Size")
	local shield_key = _("scienceDB","Shield")
	local hull_key = _("scienceDB","Hull")
	if station_db == nil then
		station_db = ScienceDatabase():setName(station_key)
		station_db:setLongDescription(_("scienceDB","Stations are places for ships to dock, get repaired and replenished, interact with station personnel, etc. They are like oases, service stations, villages, towns, cities, etc."))
		local small_station_key = _("scienceDB","Small Station")
		station_db:addEntry(small_station_key)
		local small_station_db = queryScienceDatabase(station_key,small_station_key)
		small_station_db:setLongDescription(_("scienceDB","Stations of this size are often used as research outposts, listening stations, and security checkpoints. Crews turn over frequently in a small station's cramped accommodatations, but they are small enough to look like ships on many long-range sensors, and organized raiders sometimes take advantage of this by placing small stations in nebulae to serve as raiding bases. They are lightly shielded and vulnerable to swarming assaults."))
		small_station_db:setImage("radar/smallstation.png")
		small_station_db:setKeyValue(class_key,_("scienceDB","Small"))
		small_station_db:setKeyValue(size_key,300)
		small_station_db:setKeyValue(shield_key,300)
		small_station_db:setKeyValue(hull_key,150)
		small_station_db:setModelDataName("space_station_4")
		local medium_station_key = _("scienceDB","Medium Station")
		station_db:addEntry(medium_station_key)
		local medium_station_db = queryScienceDatabase(station_key,medium_station_key)
		medium_station_db:setLongDescription(_("scienceDB","Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly."))
		medium_station_db:setImage("radar/mediumstation.png")
		medium_station_db:setKeyValue(class_key,_("scienceDB","Medium"))
		medium_station_db:setKeyValue(size_key,1000)
		medium_station_db:setKeyValue(shield_key,800)
		medium_station_db:setKeyValue(hull_key,400)
		medium_station_db:setModelDataName("space_station_3")
		local large_station_key = _("scienceDB","Large Station")
		station_db:addEntry(large_station_key)
		local large_station_db = queryScienceDatabase(station_key,large_station_key)
		large_station_db:setLongDescription(_("scienceDB","These spaceborne communities often represent permanent bases in a sector. Stations of this size can be military installations, commercial hubs, deep-space settlements, and small shipyards. Only a concentrated attack can penetrate a large station's shields, and its hull can withstand all but the most powerful weaponry."))
		large_station_db:setImage("radar/largestation.png")
		large_station_db:setKeyValue(class_key,_("scienceDB","Large"))
		large_station_db:setKeyValue(size_key,1300)
		large_station_db:setKeyValue(shield_key,"1000/1000/1000")
		large_station_db:setKeyValue(hull_key,500)
		large_station_db:setModelDataName("space_station_2")
		local huge_station_key = _("scienceDB","Huge Station")
		station_db:addEntry(huge_station_key)
		local huge_station_db = queryScienceDatabase(station_key,huge_station_key)
		huge_station_db:setLongDescription(_("scienceDB","The size of a sprawling town, stations at this scale represent a faction's center of spaceborne power in a region. They serve many functions at once and represent an extensive investment of time, money, and labor. A huge station's shields and thick hull can keep it intact long enough for reinforcements to arrive, even when faced with an ongoing siege or massive, perfectly coordinated assault."))
		huge_station_db:setImage("radar/hugestation.png")
		huge_station_db:setKeyValue(class_key,_("scienceDB","Huge"))
		huge_station_db:setKeyValue(size_key,1500)
		huge_station_db:setKeyValue(shield_key,"1200/1200/1200/1200")
		huge_station_db:setKeyValue(hull_key,800)
		huge_station_db:setModelDataName("space_station_1")
	end
-----------------------------------------------------------------------------------
--	Template ship category descriptions: text from other shipTemplates... files  --
-----------------------------------------------------------------------------------
	local ships_key = _("scienceDB","Ships")
	local ships_db = queryScienceDatabase(ships_key)
	local starfighter_key = _("scienceDB","Starfighter")
	local fighter_db = queryScienceDatabase(ships_key,starfighter_key)
	if fighter_db ~= nil then
		fighter_db:setLongDescription(_("scienceDB","Starfighters are single to 3 person small ships. These are most commonly used as light firepower roles.\nThey are common in larger groups, and need a close by station or support ship, as they lack long time life support.\nIt's rare to see starfighters with more then one shield section.\n\nOne of the most well known starfighters is the X-Wing.\n\nStarfighters come in 3 subclasses:\n* Interceptors: Fast, low on firepower, high on manouverability\n* Gunship: Equipped with more weapons, but trades in manouverability because of it.\n* Bomber: Slowest of all starfighters, but pack a large punch in a small package. Usually come without any lasers, but the largers bombers have been known to deliver nukes."))
	end
	local frigate_key = _("scienceDB","Frigate")
	local frigate_db = queryScienceDatabase(ships_key,frigate_key)
	if frigate_db ~= nil then
		frigate_db:setLongDescription(_("scienceDB","Frigates are one size up from starfighters. They require a crew from 3 to 20 people.\nThink, Firefly, millennium falcon, slave I (Boba fett's ship).\n\nThey generally have 2 or more shield sections, but hardly ever more than 4.\n\nThis class of ships is normally not fitted with jump or warp drives. But in some cases ships are modified to include these, or for certain roles it is built in.\n\nThey are divided in 3 different sub-classes:\n* Cruiser: Weaponized frigates, focused on combat. These come in various roles.\n* Light transport: Small transports, like transporting up to 50 soldiers in spartan conditions or a few diplomats in luxury. Depending on the role it can have some weaponry.\n* Support: Support types come in many varieties. They are simply a frigate hull fitted with whatever was needed. Anything from mine-layers to science vessels."))
	end
	local corvette_key = _("scienceDB","Corvette")
	local corvette_db = queryScienceDatabase(ships_key,corvette_key)
	if corvette_db ~= nil then
		corvette_db:setLongDescription(_("scienceDB","Corvettes are the common large ships. Larger then a frigate, smaller then a dreadnaught.\nThey generally have 4 or more shield sections. Run with a crew of 20 to 250.\nThis class generally has jumpdrives or warpdrives. But lack the maneuverability that is seen in frigates.\n\nThey come in 3 different subclasses:\n* Destroyer: Combat oriented ships. No science, no transport. Just death in a large package.\n* Support: Large scale support roles. Drone carriers fall in this category, as well as mobile repair centers.\n* Freighter: Large scale transport ships. Most common here are the jump freighters, using specialized jumpdrives to cross large distances with large amounts of cargo."))
	end
	local dreadnought_key = _("scienceDB","Dreadnought")
	local dreadnought_db = queryScienceDatabase(ships_key,dreadnought_key)
	if dreadnought_db ~= nil then
		dreadnought_db:setLongDescription(_("scienceDB","Dreadnoughts are the largest ships.\nThey are so large and uncommon that every type is pretty much their own subclass.\nThey usually come with 6 or more shield sections, require a crew of 250+ to operate.\n\nThink: Stardestroyer."))
	end
---------------------------------------------------------------------
--	Cruiser (identified as Karnack MK2 in stock science database)  --
---------------------------------------------------------------------
	local cruiser_key = _("scienceDB","Cruiser")
	local cruiser_db = queryScienceDatabase(ships_key,frigate_key,cruiser_key)
	local subclass_key = _("scienceDB","Sub-class")
	local move_speed_key = _("scienceDB","Move speed")
	local turn_speed_key = _("scienceDB","Turn speed")
	if cruiser_db == nil then
		frigate_db:addEntry(cruiser_key)
		cruiser_db = queryScienceDatabase(ships_key,frigate_key,cruiser_key)
		cruiser_db:setLongDescription(_("scienceDB","Fabricated by: Repulse shipyards. The Cruiser, sometimes known as the Karnack Cruiser Mark 2, is the sucessor to the widly sucesfull mark I Karnack cruiser. This ship has several notable improvements over the original ship, including better armor, slightly improved weaponry and customization by the shipyards. The latter improvement was the most requested feature by several factions once they realized that their old surplus mark I ships were used for less savoury purposes."))
		cruiser_db:setKeyValue(class_key,frigate_key)
		cruiser_db:setKeyValue(subclass_key,cruiser_key)
		cruiser_db:setKeyValue(size_key,"100")
		cruiser_db:setKeyValue(shield_key,"40/40")
		cruiser_db:setKeyValue(hull_key,"70")
		cruiser_db:setKeyValue(move_speed_key,_("scienceDB","3.6 U/min"))	--60
		cruiser_db:setKeyValue(turn_speed_key,_("scienceDB","6 deg/sec"))
		cruiser_db:setKeyValue(_("scienceDB","Beam weapon 345:90"),_("scienceDB","Rng:1 Dmg:6 Cyc:6"))
		cruiser_db:setKeyValue(_("scienceDB","Beam weapon 15:90"),_("scienceDB","Rng:1 Dmg:6 Cyc:6"))
		cruiser_db:setImage("radar/cruiser.png")
		cruiser_db:setModelDataName("small_frigate_4")
	end
--------------------------
--	Stock player ships  --
--------------------------
	local mainstream_key = _("scienceDB","Mainstream")
	local stock_db = ships_db:addEntry(mainstream_key)
	stock_db = queryScienceDatabase(ships_key,mainstream_key)
	stock_db:setLongDescription(_("scienceDB","Mainstream ships are those ship types that are commonly available to CUF crews serving on the front lines or in well established areas under the protection of the Human Navy more generally."))
----	Frigates
	local frigate_stock_db = stock_db:addEntry(frigate_key)
	frigate_stock_db:setLongDescription(_("scienceDB","Frigates are one size up from starfighters. They require a crew from 3 to 20 people.\nThink, Firefly, millennium falcon, slave I (Boba fett's ship).\n\nThey generally have 2 or more shield sections, but hardly ever more than 4.\n\nThis class of ships is normally not fitted with jump or warp drives. But in some cases ships are modified to include these, or for certain roles it is built in.\n\nThey are divided in 3 different sub-classes:\n* Cruiser: Weaponized frigates, focused on combat. These come in various roles.\n* Light transport: Small transports, like transporting up to 50 soldiers in spartan conditions or a few diplomats in luxury. Depending on the role it can have some weaponry.\n* Support: Support types come in many varieties. They are simply a frigate hull fitted with whatever was needed. Anything from mine-layers to science vessels."))
--	Repulse
	local repulse_key = _("scienceDB","Repulse")
	frigate_stock_db:addEntry(repulse_key)
	local repulse_db = queryScienceDatabase(ships_key,mainstream_key,frigate_key,repulse_key)
	repulse_db:setLongDescription(_("scienceDB","A Flavia P. Falcon with better hull and shields, a jump drive, two turreted beams covering both sides and a forward and rear tube. The nukes and mines are gone"))
	repulse_db:setKeyValue(class_key,frigate_key)
	repulse_db:setKeyValue(subclass_key,_("scienceDB","Cruiser: Armored Transport"))
	repulse_db:setKeyValue(size_key,"80")
	repulse_db:setKeyValue(shield_key,"80/80")
	repulse_db:setKeyValue(hull_key,"120")
	repulse_db:setKeyValue(_("scienceDB","Repair Crew"),8)
	repulse_db:setKeyValue(_("scienceDB","Jump Range"),_("scienceDB","5 - 50 U"))
	repulse_db:setKeyValue(_("scienceDB","Sensor Ranges"),_("scienceDB","Long: 38 U / Short: 5 U"))
	repulse_db:setKeyValue(move_speed_key,_("scienceDB","3.3 U/min"))	--55
	repulse_db:setKeyValue(turn_speed_key,_("scienceDB","9 deg/sec"))
	repulse_db:setKeyValue(_("scienceDB","Beam weapon 90:200"),_("scienceDB","Rng:1.2 Dmg:5 Cyc:6"))
	repulse_db:setKeyValue(_("scienceDB","Beam weapon 270:200"),_("scienceDB","Rng:1.2 Dmg:5 Cyc:6"))
	repulse_db:setKeyValue(_("scienceDB","Tube 0"),_("scienceDB","20 sec"))
	repulse_db:setKeyValue(_("scienceDB","Tube 180"),_("scienceDB","20 sec"))
	repulse_db:setKeyValue(_("scienceDB","Storage Homing"),"4")
	repulse_db:setKeyValue(_("scienceDB","Storage HVLI"),"6")
	repulse_db:setImage("radar/tug.png")
	repulse_db:setModelDataName("LightCorvetteRed")
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
function placeRandomAsteroidsAroundPoint(object_type, amount, dist_min, dist_max, x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
        local obj = object_type():setPosition(x, y)
        if obj.typeName == "Asteroid" or obj.typeName == "VisualAsteroid" then
			obj:setSize(random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20))
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
	planetBaldwin:setPlanetSurfaceTexture("planets/gas-1.png"):setAxialRotationTime(300):setDescription(_("scienceDescription-planet", "Mining and heavy industry"))
	stationWig = SpaceStation():setTemplate("Small Station"):setFaction("Kraylor")
	stationWig:setPosition(bwx, bwy+3000):setCallSign("BOBS"):setDescription(_("scienceDescription-station", "Baldwin Observatory"))
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
	planetMal:setAxialRotationTime(400.0):setDescription(_("scienceDescription-planet", "M class planet"))
	stationMal = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	stationMal:setPosition(msx,msy+3000):setCallSign("MalNet"):setDescription(_("scienceDescription-station", "Malastare communications network hub"))
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
	pStation = placeEStation(psx,psy,"RandomGenericSinister",stationFaction)
	table.insert(enemyStationList,pStation)			--save station in general station list
	gp = gp + 1						--set next station number
	rn = math.random(1,#adjList)	--random next station start location
	gx = adjList[rn][1]
	gy = adjList[rn][2]
end
function placeEStation(x,y,name,faction)
	faction_station_service_chance = {
		["Human Navy"] = 20,
		["Kraylor"] = 0,
		["Independent"] = 0,
		["Arlenians"] = 0,
		["Ghosts"] = 0,
		["Ktlitans"] = 0,
		["Exuari"] = 0,
		["TSN"] = 10,
		["USN"] = 10,
		["CUF"] = 10,
	}
	local station = placeStation(x,y,name,faction)
	local station_name = station:getCallSign()
	local chosen_goods = random(1,100)
	if station_name == "Grasberg" or station_name == "Impala" or station_name == "Outpost-15" or station_name == "Outpost-21" then
		placeRandomAsteroidsAroundPoint(Asteroid,15,1,15000,x,y)
		placeRandomAsteroidsAroundPoint(VisualAsteroid,30,1,15000,x,y)
		if chosen_goods < 20 then
			station.comms_data.goods.gold = {quantity = 5, cost = 25}
			station.comms_data.goods.cobalt = {quantity = 4, cost = 50}
		elseif chosen_goods < 40 then
			station.comms_data.goods.gold = {quantity = 5, cost = 25}
		elseif chosen_goods < 60 then
			station.comms_data.goods.cobalt = {quantity = 4, cost = 50}
		else
			if station_name == "Grasberg" then
				station.comms_data.goods.nickel = {quantity = 5, cost = math.random(40,50)}
			elseif station_name == "Outpost-15" then
				station.comms_data.goods.platinum = {quantity = 5, cost = math.random(40,50)}
			elseif station_name == "Outpost-21" then
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(40,50)}
			else	--Impala
				station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(40,50)}
			end			
		end
	elseif station_name == "Jabba" or station_name == "Lando" or station_name == "Maverick" or station_name == "Okun" or station_name == "Outpost-8" or station_name == "Prada" or station_name == "Research-11" or station_name == "Research-19" or station_name == "Science-2" or station_name == "Science-4" or station_name == "Spot" or station_name == "Starnet" or station_name == "Tandon" then
		if chosen_goods < 33 then
			if station_name == "Jabba" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Okun" or station_name == "Spot" then
				station.comms_data.goods.optic = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Outpost-8" then
				station.comms_data.goods.impulse = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.warp = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Research-19" then
				station.comms_data.goods.transporter = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Science-2" or station_name == "Tandon" then
				station.comms_data.goods.autodoc = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.software = {quantity = 5, cost = math.random(68,81)}
			elseif station_name == "Starnet" then
				station.comms_data.goods.shield = {quantity = 5, cost = math.random(68,81)}
			else
				station.comms_data.goods.luxury = {quantity = 5, cost = math.random(68,81)}
			end
		elseif chosen_goods < 66 then
			if station_name == "Okun" then
				station.comms_data.goods.filament = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Outpost-8" then
				station.comms_data.goods.tractor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Prada" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.repulsor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-19" or station_name == "Spot" then
				station.comms_data.goods.sensor = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-2" or station_name == "Tandon" then
				station.comms_data.goods.android = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.circuit = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Starnet" then
				station.comms_data.goods.lifter = {quantity = 5, cost = math.random(61,77)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(61,77)}
			end
		else
			if station_name == "Okun" then
				station.comms_data.goods.lifter = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Outpost-8" or station_name == "Starnet" then
				station.comms_data.goods.beam = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Prada" then
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-11" then
				station.comms_data.goods.robotic = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Research-19" then
				station.comms_data.goods.communication = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-2" then
				station.comms_data.goods.nanites = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Science-4" then
				station.comms_data.goods.battery = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Spot" then
				station.comms_data.goods.software = {quantity = 5, cost = math.random(61,77)}
			elseif station_name == "Tandon" then
				station.comms_data.goods.robotic = {quantity = 5, cost = math.random(61,77)}
			else
				station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,79)}
			end
		end
	elseif station_name == "Krak" or station_name == "Kruk" or station_name == "Krik" then
		if chosen_goods < 10 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 20 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 30 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 40 then
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 50 then
			station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 60 then
			station.comms_data.goods.platinum = {quantity = 5, cost = math.random(65,75)}
		elseif chosen_goods < 70 then
			station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
		elseif chosen_goods < 80 then
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
				station.comms_data.goods.tritanium = {quantity = 5, cost = math.random(45,55)}
			end
		elseif chosen_goods < 90 then
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			end
		else
			if station_name == "Krik" then
				station.comms_data.goods.cobalt = {quantity = 5, cost = math.random(55,65)}
				station.comms_data.goods.dilithium = {quantity = 5, cost = math.random(45,55)}
			else
				station.comms_data.goods.gold = {quantity = 5, cost = math.random(45,55)}
			end
		end
		local posAxisKrak = random(0,360)
		local posKrak = random(10000,60000)
		local negKrak = random(10000,60000)
		local spreadKrak = random(4000,7000)
		local negAxisKrak = posAxisKrak + 180
		local xPosAngleKrak, yPosAngleKrak = vectorFromAngle(posAxisKrak, posKrak)
		local posKrakEnd = random(30,70)
		local negKrakEnd = random(40,80)
		if station_name == "Krik" then
			posKrak = random(30000,80000)
			negKrak = random(20000,60000)
			spreadKrak = random(5000,8000)
			posKrakEnd = random(40,90)
			negKrakEnd = random(30,60)
		end
		createRandomAlongArc(Asteroid,30+posKrakEnd, x+xPosAngleKrak, y+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
		createRandomAlongArc(VisualAsteroid,(30+posKrakEnd)*2, x+xPosAngleKrak, y+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
		local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
		createRandomAlongArc(Asteroid,30+negKrakEnd, x+xNegAngleKrak, y+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
		createRandomAlongArc(VisualAsteroid,(30+negKrakEnd)*2, x+xNegAngleKrak, y+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
	end
	if station_name == "Tokra" or station_name == "Cavor" then
		local what_trade = random(1,100)
		if what_trade < 33 then
			station.comms_data.trade.food = true
		elseif what_trade > 66 then
			station.comms_data.trade.medicine = true
		else
			station.comms_data.trade.luxury = true
		end
	end
	return station
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
	pStation = placeEStation(psx,psy,"RandomHumanNeutral",stationFaction)
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
        setCommsMessage(_("station-comms", "We are under attack! No time for chatting!"));
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
		oMsg = _("station-comms", "Good day, officer!\nWhat can we do for you today?\n")
    else
		oMsg = _("station-comms", "Welcome to our lovely station.\n")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	stationStatusReport()
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for idx, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + player:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(ctd.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
			(ctd.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
			(ctd.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
			(ctd.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
			(ctd.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
			addCommsReply(_("ammo-comms","I need ordnance restocked"), function()
				setCommsMessage(_("ammo-comms","What type of ordnance do you need?"))
				local prompts = {
					["Nuke"] = {
						_("ammo-comms","Can you supply us with some nukes?"),
						_("ammo-comms","We really need some nukes."),
						_("ammo-comms","Can you restock our nuclear missiles?"),
					},
					["EMP"] = {
						_("ammo-comms","Please restock our EMP missiles."),
						_("ammo-comms","Got any EMPs?"),
						_("ammo-comms","We need Electro-Magnetic Pulse missiles."),
					},
					["Homing"] = {
						_("ammo-comms","Do you have spare homing missiles for us?"),
						_("ammo-comms","Do you have extra homing missiles?"),
						_("ammo-comms","Please replenish our homing missiles."),
					},
					["Mine"] = {
						_("ammo-comms","We could use some mines."),
						_("ammo-comms","How about mines?"),
						_("ammo-comms","Got mines for us?"),
					},
					["HVLI"] = {
						_("ammo-comms","What about HVLI?"),
						_("ammo-comms","Could you provide HVLI?"),
						_("ammo-comms","We need High Velocity Lead Impactors."),
					},
				}
				for i, missile_type in ipairs(missile_types) do
					if comms_source:getWeaponStorageMax(missile_type) > 0 and comms_target.comms_data.weapon_available[missile_type] then
						addCommsReply(string.format(_("ammo-comms","%s (%d rep each)"),prompts[missile_type][math.random(1,#prompts[missile_type])],getWeaponCost(missile_type)), function()
							string.format("")
							handleWeaponRestock(missile_type)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
	if comms_target == beamFixStation then
		if playerRepulse.beamFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Kent's brother"), function()
				setCommsMessage(_("crewFriends-comms", "Kent? You made it out of the Kraylor base? We thought you were going to spend the rest of your life there. Thank you, captain, for helping Kent get out of there."))
				addCommsReply(_("crewFriends-comms", "Can you help us with beam weapon repair?"), function()
					setCommsMessage(_("crewFriends-comms", "For the Repulse class? Absolutely. I used to work on those all the time."))
					playerRepulse:setBeamWeapon(1, 10,-90, 1200.0, 6.0, 5)
					playerRepulse.beamFix = "done"
					fixFloodTimer = 30
					plot1 = fixFlood
					addCommsReply(_("crewFriends-comms", "Thanks"), function()
						setCommsMessage(_("crewFriends-comms", "You're quite welcome. While I was in there, I fixed up your beams so they could function at maximum potential."))
						playerRepulse:setSystemHealthMax("beamweapons",1)
						addCommsReply(_("crewFriends-comms", "Then double thanks!"), function()
							playerRepulse:addReputationPoints(30)
							setCommsMessage(_("crewFriends-comms", "Thank *you* for getting my brother out of that Kraylor prison."))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if comms_target == missileFixStation then
		if playerRepulse.missileFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Edwina's father"), function()
				setCommsMessage(_("crewFriends-comms", "I am glad to hear that Edwina escaped that prison. We were worried about her."))
				addCommsReply(_("crewFriends-comms", "Edwina says you do missile systems repair work"), function()
					setCommsMessage(_("crewFriends-comms", "Should be easy enough. I'm grateful to you for helping Edwina escape."))
					playerRepulse:setSystemHealthMax("missilesystem",1)
					playerRepulse.missileFix = "done"
					addCommsReply(_("crewFriends-comms", "Thanks"), function()
						setCommsMessage(_("crewFriends-comms", "You're quite welcome."))
						playerRepulse:addReputationPoints(30)
						addCommsReply(_("Back"),commsStation)
					end)
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
	if comms_target == impulseFixStation then
		if playerRepulse.impulseFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Johnny"), function()
				setCommsMessage(_("crewFriends-comms", "Mom? Wow, I thought you were toast. Good to hear your voice."))
				addCommsReply(_("crewFriends-comms", "Can you get our impulse drive working better?"), function()
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
							setCommsMessage(string.format(_("crewFriends-comms", "Piece of cake. Thanks for the %s."),impulseFixStation.impulse_good))
							playerRepulse:setSystemHealthMax("impulse",1)
							playerRepulse.impulseFix = "done"
							comms_source.goods[impulseFixStation.impulse_good] = comms_source.goods[impulseFixStation.impulse_good] - 1
							comms_source.cargo = comms_source.cargo + 1
							addCommsReply(_("crewFriends-comms", "Thank you"), function()
								setCommsMessage(_("crewFriends-comms", "Sure, Mom. I'll see you at Christmas."))
								playerRepulse:addReputationPoints(30)
								addCommsReply(_("Back"),commsStation)
							end)
						else
							setCommsMessage(string.format(_("crewFriends-comms", "Piece of cake, but I'll need %s."),impulseFixStation.impulse_good))
						end
					else
						setCommsMessage(_("crewFriends-comms", "Piece of cake."))
						playerRepulse:setSystemHealthMax("impulse",1)
						playerRepulse.impulseFix = "done"
						addCommsReply(_("crewFriends-comms", "Thank you"), function()
							setCommsMessage(_("crewFriends-comms", "Sure, Mom. I'll see you at Christmas."))
							playerRepulse:addReputationPoints(30)
							addCommsReply(_("Back"),commsStation)
						end)
					end
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
	if comms_target == jumpFixStation then
		if playerRepulse.jumpFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Nancy's brother"), function()
				setCommsMessage(_("crewFriends-comms", "Nancy! Last I heard, your ship had been captured by Kraylors and you were imprisoned. Good to know you won't be stuck there forever. What brings you here?"))
				addCommsReply(_("crewFriends-comms", "Our jump drive needs some tuning"), function()
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
							setCommsMessage(string.format(_("crewFriends-comms", "That should not be hard to do. I could probably do that in my sleep. Thanks for bringing %s."),jumpFixStation.jump_good))
							comms_source.goods[jumpFixStation.jump_good] = comms_source.goods[jumpFixStation.jump_good] - 1
							player.cargo = player.cargo + 1
							playerRepulse:setSystemHealthMax("jumpdrive",1)
							playerRepulse.jumpFix = "done"
							addCommsReply(_("crewFriends-comms", "Thanks, bro"), function()
								setCommsMessage(_("crewFriends-comms", "No problem. Treat your jump drive right and it'll always bring you home."))
								playerRepulse:addReputationPoints(30)
								addCommsReply(_("Back"),commsStation)
							end)
						else
							setCommsMessage(string.format(_("crewFriends-comms", "That should not be hard to do. I could probably do that in my sleep. But I'll need some %s."),jumpFixStation.jump_good))
						end
					else
						setCommsMessage(_("crewFriends-comms", "That should not be hard to do. I could probably do that in my sleep."))
						playerRepulse:setSystemHealthMax("jumpdrive",1)
						playerRepulse.jumpFix = "done"
						addCommsReply(_("crewFriends-comms", "Thanks, bro"), function()
							setCommsMessage(_("crewFriends-comms", "No problem. Treat your jump drive right and it'll always bring you home."))
							playerRepulse:addReputationPoints(30)
							addCommsReply(_("Back"),commsStation)
						end)
					end
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
	if comms_target == reactorFixStation then
		if playerRepulse.reactorFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Manuel's cousin"), function()
				setCommsMessage(_("crewFriends-comms", "Yo Manuel, why you want to scare us by getting captured, man? At least you escaped. Why you here?"))
				addCommsReply(_("crewFriends-comms", "The reactor is weak... real weak"), function()
					setCommsMessage(_("crewFriends-comms", "Lemme see if I can get it to charge up right."))
					playerRepulse:setSystemHealthMax("reactor",1)
					playerRepulse.reactorFix = "done"
					addCommsReply(_("crewFriends-comms", "The captain would appreciate it"), function()
						setCommsMessage(_("crewFriends-comms", "You're all set. Don't overheat the reactor or you'll get a nasty surprise."))
						playerRepulse:addReputationPoints(30)
						addCommsReply(_("Back"),commsStation)
					end)
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
	if comms_target == longRangeFixStation then
		if playerRepulse.longRangeFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Fred's wife"), function()
				setCommsMessage(_("crewFriends-comms", "Fred! You escaped! We were worried sick."))
				addCommsReply(_("crewFriends-comms", "We need to connect to the Human Navy network"), function()
					setCommsMessage(_("crewFriends-comms", "I can do that for you. However, that means you'll go from being Independent to being in the Human Navy."))
					addCommsReply(_("crewFriends-comms", "I understand the consequences. Please proceed"), function()
						playerRepulse.longRangeFix = "done"
						local px, py = playerRepulse:getPosition()
						local range = playerRepulse:getLongRangeRadarRange()
						local objects = getObjectsInRadius(px,py,range + 5000)
						local scanned_ships = {}
						local fully_scanned_ships = {}
						for i,obj in ipairs(objects) do
							if obj.typeName == "CpuShip" then
								if obj:isScannedBy(playerRepulse) then
									table.insert(scanned_ships,obj)
								end
								if obj:isFullyScannedBy(playerRepulse) then
									table.insert(fully_scanned_ships,obj)
								end
							end
						end
						playerRepulse:setFaction("Human Navy")
						for i,ship in ipairs(scanned_ships) do
							ship:setScanStateByFaction("Human Navy","simplescan")
						end
						for i,ship in ipairs(fully_scanned_ships) do
							ship:setScanStateByFaction("Human Navy","fullscan")
						end
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
							pStation = placeEStation(psx,psy,"RandomHumanNeutral",stationFaction)
							--print(string.format("placed %s in %s: %.1f, %.1f",pStation:getCallSign(),pStation:getSectorName(),psx,psy))
							table.insert(stationList,pStation)			--save station in general station list
							table.insert(friendlyStationList,pStation)	
							gp = gp + 1						--set next station number
							rn = math.random(1,#adjList)	--random next station start location
							gx = adjList[rn][1]
							gy = adjList[rn][2]
						end
						plot4 = returnHome
						setCommsMessage(_("crewFriends-comms", "You're all fixed up."))
						addCommsReply(_("crewFriends-comms", "Thanks"), function()
							setCommsMessage(_("crewFriends-comms", "You're welcome. Fred, honey, I'll see you after you get off work."))
							playerRepulse:addReputationPoints(30)
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("crewFriends-comms", "I'll check with the captain and get back to you"), function()
						setCommsMessage(_("crewFriends-comms", "Ok."))
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"),commsStation)
				end)
				addCommsReply(_("Back"),commsStation)
			end)
		end
	end
	if comms_target == shieldFixStation then
		if playerRepulse.frontShieldFix == nil and playerRepulse.rearShieldFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Amir's sister"), function()
				setCommsMessage(string.format(_("crewFriends-comms", "Welcome to %s! Any friend of Amir's is a friend of mine."),shieldFixStation:getCallSign()))
				addCommsReply(_("crewFriends-comms", "Can you help us with our shields?"), function()
					setCommsMessage(_("crewFriends-comms", "Yes, I can. However, I can only help with one: front or rear. I need more parts to do both."))
					addCommsReply(_("crewFriends-comms", "Repair front shield"), function()
						setCommsMessage(_("crewFriends-comms", "Your front shields are now fully operational. Your repair crew can finish the rest."))
						playerRepulse:setSystemHealthMax("frontshield",1)
						playerRepulse.frontShieldFix = "done"
						addCommsReply(_("crewFriends-comms", "Thanks"), function()
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
							setCommsMessage(string.format(_("crewFriends-comms", "Certainly. Bring back %s to get the rear shield fixed. You might find some at %s."),shieldGood,shieldGoodBase:getCallSign()))
							playerRepulse:addReputationPoints(30)
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("crewFriends-comms", "Repair rear shield"), function()
						setCommsMessage(_("crewFriends-comms", "Your rear shields are now fully operational. Your repair crew can finish the rest."))
						playerRepulse:setSystemHealthMax("rearshield",1)
						playerRepulse.rearShieldFix = "done"
						addCommsReply(_("crewFriends-comms", "Thanks"), function()
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
							setCommsMessage(string.format(_("crewFriends-comms", "Certainly. Bring back %s to get the front shield fixed. You might find some at %s."),shieldGood,shieldGoodBase:getCallSign()))
							playerRepulse:addReputationPoints(30)
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		elseif playerRepulse.frontShieldFix == nil or playerRepulse.rearShieldFix == nil then
			addCommsReply(_("crewFriends-comms", "Talk to Amir's sister"), function()
				setCommsMessage(string.format(_("crewFriends-comms", "Welcome back. Did you bring some %s for me to finish fixing up your shields?"),shieldGood))
				local shieldGoodQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[shieldGood] ~= nil and comms_source.goods[shieldGood] > 0 then
					shieldGoodQuantity = comms_source.goods[shieldGood]
				end
				if shieldGoodQuantity > 0 then
					addCommsReply(string.format(_("crewFriends-comms", "Yes, please take the %s and fix the shields"),shieldGood), function()
						comms_source.goods[shieldGood] = comms_source.goods[shieldGood] - 1
						player.cargo = player.cargo + 1
						if playerRepulse.frontShieldFix == nil then
							playerRepulse:setSystemHealthMax("frontshield",1)
							playerRepulse.frontShieldFix = "done"
							setCommsMessage(_("crewFriends-comms", "Front shield fully functional."))
						else
							playerRepulse:setSystemHealthMax("rearshield",1)
							playerRepulse.rearShieldFix = "done"
							setCommsMessage(_("crewFriends-comms", "Rear shield fully functional."))
						end
						playerRepulse:addReputationPoints(30)
						addCommsReply(_("Back"), commsStation)
					end)
				else
					addCommsReply(string.format(_("crewFriends-comms", "Oops, no %s aboard"),shieldGood), function()
						setCommsMessage(_("crewFriends-comms", "Ok, good luck."))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if ctd.public_relations then
		addCommsReply(_("station-comms", "Tell me more about your station"), function()
			setCommsMessage(_("station-comms", "What would you like to know?"))
			addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
				setCommsMessage(ctd.general_information)
				addCommsReply(_("Back"), commsStation)
			end)
			if ctd.history ~= nil then
				addCommsReply(_("stationStory-comms", "Station history"), function()
					setCommsMessage(ctd.history)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if ctd.gossip ~= nil then
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
						addCommsReply(_("gossip-comms", "Gossip"), function()
							setCommsMessage(ctd.gossip)
							addCommsReply(_("Back"), commsStation)
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
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			local ctd = comms_target.comms_data
			local goodsReport = string.format(_("trade-comms", "Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
			for good, goodData in pairs(ctd.goods) do
				goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i, %i\n"),good,goodData["quantity"],goodData["cost"])
			end
			if ctd.buy ~= nil then
				goodsReport = goodsReport .. _("trade-comms", "Goods or components station will buy: price in reputation\n")
				for good, price in pairs(ctd.buy) do
					goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i\n"),good,price)
				end
			end
			goodsReport = goodsReport .. string.format(_("trade-comms", "Current cargo aboard %s:\n"),comms_source:getCallSign())
			local cargoHoldEmpty = true
			local player_good_count = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					player_good_count = player_good_count + 1
					goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i\n"),good,goodQuantity)
				end
			end
			if player_good_count < 1 then
				goodsReport = goodsReport .. _("trade-comms", "     Empty\n")
			end
			goodsReport = goodsReport .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(ctd.goods) do
				addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,goodData["cost"]), function()
					local goodTransactionMessage = string.format(_("trade-comms", "Type: %s, Quantity: %i, Rep: %i"),good,goodData["quantity"],goodData["cost"])
					if comms_source.cargo < 1 then
						goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient cargo space for purchase")
					elseif goodData["cost"] > math.floor(comms_source:getReputationPoints()) then
						goodTransactionMessage = goodTransactionMessage .. _("needRep-comms", "\nInsufficient reputation for purchase")
					elseif goodData["quantity"] < 1 then
						goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\npurchased")
						else
							goodTransactionMessage = goodTransactionMessage .. _("needRep-comms", "\nInsufficient reputation for purchase")
						end
					end
					setCommsMessage(goodTransactionMessage)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if ctd.buy ~= nil then
				for good, price in pairs(ctd.buy) do
					if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
						addCommsReply(string.format(_("trade-comms", "Sell one %s for %i reputation"),good,price), function()
							local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Reputation price: %i"),good,price)
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source:addReputationPoints(price)
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nOne sold")
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(goodTransactionMessage)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			if ctd.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format(_("trade-comms", "Trade food for %s"),good), function()
						local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nTraded")
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if ctd.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),good), function()
						local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),good,goodData["quantity"])
						if goodData["quantity"] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nTraded")
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if ctd.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury.quantity > 0 then
				for good, goodData in pairs(ctd.goods) do
					addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
						local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),good,goodData["quantity"])
						if goodData[quantity] < 1 then
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nInsufficient station inventory")
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
							goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nTraded")
						end
						setCommsMessage(goodTransactionMessage)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		local player_good_count = 0
		if comms_source.goods ~= nil then
			for good, goodQuantity in pairs(comms_source.goods) do
				player_good_count = player_good_count + 1
			end
		end
		if player_good_count > 0 then
			addCommsReply(_("trade-comms", "Jettison cargo"), function()
				setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
				for good, good_quantity in pairs(comms_source.goods) do
					if good_quantity > 0 then
						addCommsReply(good, function()
							comms_source.goods[good] = comms_source.goods[good] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),good))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("explainGoods-comms", "No tutorial covered goods or cargo. Explain"), function()
			setCommsMessage(_("explainGoods-comms", "Different types of cargo or goods may be obtained from stations, freighters or other sources. They go by one word descriptions such as dilithium, optic, warp, etc. Certain mission goals may require a particular type or types of cargo. Each player ship differs in cargo carrying capacity. Goods may be obtained by spending reputation points or by trading other types of cargo (typically food, medicine or luxury)"))
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function stationStatusReport()
	addCommsReply(_("stationAssist-comms","Report status"), function()
		msg = string.format(_("stationAssist-comms","Hull:%s"),math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = string.format(_("stationAssist-comms","%s\nShield:%s"),msg,math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		else
			for n=0,shields-1 do
				msg = string.format(_("stationAssist-comms","%s\nShield %s:%s"),msg,n,math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end
		local improvements = {}
		if comms_target:getRestocksScanProbes() then
			msg = string.format(_("stationServices-comms","%s\nReplenish scan probes: nominal."),msg)
		else
			if comms_target.probe_fail_reason == nil then
				local reason_list = {
					_("stationServices-comms", "Cannot replenish scan probes due to fabrication unit failure."),
					_("stationServices-comms", "Parts shortage prevents scan probe replenishment."),
					_("stationServices-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			msg = string.format(_("stationServices-comms", "%s\n%s"),msg,comms_target.probe_fail_reason)
			table.insert(improvements,"restock_probes")
		end
		if comms_target:getRepairDocked() then
			msg = string.format(_("stationServices-comms","%s\nRepair ship hull: nominal."),msg)
		else
			if comms_target.repair_fail_reason == nil then
				reason_list = {
					_("stationServices-comms", "We're out of the necessary materials and supplies for hull repair."),
					_("stationServices-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
					_("stationServices-comms", "All hull repair technicians quarantined to quarters due to illness."),
				}
				comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			msg = string.format(_("stationServices-comms", "%s\n%s"),msg,comms_target.repair_fail_reason)
			table.insert(improvements,"hull")
		end
		if comms_target:getSharesEnergyWithDocked() then
			msg = string.format(_("stationServices-comms","%s\nRecharge ship energy stores: nominal."),msg)
		else
			if comms_target.energy_fail_reason == nil then
				reason_list = {
					_("stationServices-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
					_("stationServices-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
					_("stationServices-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
				}
				comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			msg = string.format(_("stationServices-comms", "%s\n%s"),msg,comms_target.energy_fail_reason)
			table.insert(improvements,"energy")
		end
		local provides_some_missiles = false
		local missile_provision_msg = _("ammo-comms","Ordnance available:")
		local missile_types = {
			{name = "Nuke",		desc = _("ammo-comms","nukes")},
			{name = "EMP",		desc = _("ammo-comms","EMPs")},
			{name = "Homing",	desc = _("ammo-comms","homings")},
			{name = "Mine",		desc = _("ammo-comms","mines")},
			{name = "HVLI",		desc = _("ammo-comms","HVLIs")},
		}
		for i,m_type in ipairs(missile_types) do
			if comms_target.comms_data.weapon_available[m_type.name] then
				if missile_provision_msg == _("ammo-comms","Ordnance available:") then
					missile_provision_msg = string.format(_("ammo-comms","%s %s@%i rep"),missile_provision_msg,m_type.desc,getWeaponCost(m_type.name))
				else
					missile_provision_msg = string.format(_("ammo-comms","%s, %s@%i rep"),missile_provision_msg,m_type.desc,getWeaponCost(m_type.name))
				end
			else
				table.insert(improvements,m_type.name)
			end
		end
		if missile_provision_msg == _("ammo-comms","Ordnance available:") then
			msg = string.format(_("ammo-comms","%s\nNo ordnance available."),msg)
		else
			msg = string.format(_("ammo-comms", "%s\n%s."),msg,missile_provision_msg)
		end
		setCommsMessage(msg)
		addCommsReply(_("Back"), commsStation)
	end)
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
		setCommsMessage(_("station-comms", "You need to stay docked for that action."))
		return
	end
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms", "We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(player:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - player:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms", "All nukes are charged and primed for destruction."));
        else
            setCommsMessage(_("ammo-comms", "Sorry, sir, but you are as fully stocked as I can allow."));
        end
        addCommsReply(_("Back"), commsStation)
    else
		if player:getReputationPoints() > points_per_item * item_amount then
			if player:takeReputationPoints(points_per_item * item_amount) then
				player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + item_amount)
				if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
					setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
				else
					setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
				end
			else
				setCommsMessage(_("needRep-comms", "Not enough reputation."))
				return
			end
		else
			if player:getReputationPoints() > points_per_item then
				setCommsMessage(_("ammo-comms", "You can't afford as much as I'd like to give you"))
				addCommsReply(_("ammo-comms", "Get just one"), function()
					if player:takeReputationPoints(points_per_item) then
						player:setWeaponStorage(weapon, player:getWeaponStorage(weapon) + 1)
						if player:getWeaponStorage(weapon) == player:getWeaponStorageMax(weapon) then
							setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
						else
							setCommsMessage(_("ammo-comms", "We generously resupplied you with one weapon charge.\nPut it to good use."))
						end
					else
						setCommsMessage(_("needRep-comms", "Not enough reputation."))
					end
					return
				end)
			else
				setCommsMessage(_("needRep-comms", "Not enough reputation."))
				return				
			end
		end
        addCommsReply(_("Back"), commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    local ctd = comms_target.comms_data
    if player:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
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
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		stationStatusReport()
		addCommsReply(_("ammo-comms", "What ordnance do you have available for restock?"), function()
			local ctd = comms_target.comms_data
			local missileTypeAvailableCount = 0
			local ordnanceListMsg = ""
			if ctd.weapon_available.Nuke then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Nuke")
			end
			if ctd.weapon_available.EMP then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   EMP")
			end
			if ctd.weapon_available.Homing then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Homing")
			end
			if ctd.weapon_available.Mine then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Mine")
			end
			if ctd.weapon_available.HVLI then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   HVLI")
			end
			if missileTypeAvailableCount == 0 then
				ordnanceListMsg = _("ammo-comms", "We have no ordnance available for restock")
			elseif missileTypeAvailableCount == 1 then
				ordnanceListMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"), ordnanceListMsg)
			else
				ordnanceListMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"), ordnanceListMsg)
			end
			setCommsMessage(ordnanceListMsg)
			addCommsReply(_("Back"), commsStation)
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
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				local ctd = comms_target.comms_data
				local goodsAvailableMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
				for good, goodData in pairs(ctd.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format(_("trade-comms", "\n   %14s: %2i, %3i"),good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("trade-comms", "Where can I find particular goods?"), function()
			local ctd = comms_target.comms_data
			gkMsg = _("trade-comms", "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
			if ctd.goodsKnowledge == nil then
				ctd.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i,station in ipairs(stationList) do
					if station ~= nil and station:isValid() and not station:isEnemy(comms_source) then
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
					setCommsMessage(string.format(_("trade-comms", "Station %s in sector %s has %s for %i reputation"),stationName,sectorName,goodName,goodCost))
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = gkMsg .. _("trade-comms", "\n\nWhat goods are you interested in?\nI've heard about these:")
			else
				gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations")
			end
			setCommsMessage(gkMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		if ctd.public_relations then
			addCommsReply(_("station-comms", "Tell me more about your station"), function()
				setCommsMessage(_("station-comms", "What would you like to know?"))
				addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
					setCommsMessage(ctd.general_information)
					addCommsReply(_("Back"), commsStation)
				end)
				if ctd.history ~= nil then
					addCommsReply(_("stationStory-comms", "Station history"), function()
						setCommsMessage(ctd.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
	end)
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost("supplydrop")), function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"));
                for n=1,player:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"), n), function()
                        if player:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = player:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched a supply ship toward WP %d"), n));
                        else
                            setCommsMessage(_("needRep-comms", "Not enough reputation!"));
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
        end)
    end
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
        addCommsReply(string.format(_("stationAssist-comms", "Please send reinforcements! (%d rep)"), getServiceCost("reinforcements")), function()
            if player:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,player:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"), n), function()
                        if player:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"), ship:getCallSign(), n));
                        else
                            setCommsMessage(_("needRep-comms", "Not enough reputation!"));
                        end
                        addCommsReply(_("Back"), commsStation)
                    end)
                end
            end
            addCommsReply(_("Back"), commsStation)
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
						tradeString = _("trade-comms", " and will trade it for medicine")
						stationTrades = true
					end
					if tradeFood[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. _("trade-comms", " or food")
						else
							tradeString = tradeString .. _("trade-comms", " and will trade it for food")
							stationTrades = true
						end
					end
					if tradeLuxury[stationList[sti]] ~= nil then
						if stationTrades then
							tradeString = tradeString .. _("trade-comms", " or luxury")
						else
							tradeString = tradeString .. _("trade-comms", " and will trade it for luxury")
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
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
	end
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		addCommsReply(_("trade-comms", "Do you have cargo you might sell?"), function()
			local goodCount = 0
			local cargoMsg = _("trade-comms", "We've got ")
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. _("trade-comms", ", ") .. good
					else
						cargoMsg = cargoMsg .. good
					end
				end
				goodCount = goodCount + goodData.quantity
			end
			if goodCount == 0 then
				cargoMsg = cargoMsg .. _("trade-comms", "nothing")
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
				addCommsReply(_("trade-comms", "Jettison cargo"), function()
					setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
					for good, good_quantity in pairs(comms_source.goods) do
						if good_quantity > 0 then
							addCommsReply(good, function()
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),good))
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
					addCommsReply(_("Back"), commsShip)
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
							addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
								comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
								if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
								comms_source.goods[good] = comms_source.goods[good] + 1
								setCommsMessage(_("trade-comms", "Traded"))
								addCommsReply(_("Back"), commsShip)
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
					addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*freighter_multiplier)), function()
						if comms_source.cargo > 0 then
							if comms_source:takeReputationPoints(goodData.cost) then
								goodData.quantity = goodData.quantity - 1
								if comms_source.goods == nil then comms_source.goods = {} end
								if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
								comms_source.goods[good] = comms_source.goods[good] + 1
								comms_source.cargo = comms_source.cargo - 1
								setCommsMessage(string.format(_("trade-comms", "Purchased %s from %s"),good,comms_target:getCallSign()))
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
							end
						else
							setCommsMessage(_("trade-comms", "Insufficient cargo space"))
						end
						addCommsReply(_("Back"), commsShip)
					end)
				end
			end	--freighter goods loop
		end
	end
	addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
			addCommsReply(_("Back"), commsShip)
		else
			setCommsMessage(_("shipAssist-comms", "Which waypoint should we defend?"));
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms", "Defend WP %d"), n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), n));
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms", "Assist me"), function()
			setCommsMessage(_("shipAssist-comms", "Heading toward you to assist."));
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsShip)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. string.format(_("shipAssist-comms", "Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		elseif shields == 2 then
			msg = msg .. string.format(_("shipAssist-comms", "Front Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			msg = msg .. string.format(_("shipAssist-comms", "Rear Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
		else
			for n=0,shields-1 do
				msg = msg .. string.format(_("shipAssist-comms", "Shield %s: %d%%\n"), n, math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end

		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. string.format(_("shipAssist-comms", "%s Missiles: %d/%d\n"), missile_type, math.floor(comms_target:getWeaponStorage(missile_type)), math.floor(comms_target:getWeaponStorageMax(missile_type)))
			end
		end
		
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	for idx, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	if comms_data.friendlyness > 50 then
		faction = comms_target:getFaction()
		taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
		taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
		taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
		if faction == "Kraylor" then
			setCommsMessage(_("shipEnemy-comms", "Ktzzzsss.\nYou will DIEEee weaklingsss!"));
		elseif faction == "Arlenians" then
			setCommsMessage(_("shipEnemy-comms", "We wish you no harm, but will harm you if we must.\nEnd of transmission."));
		elseif faction == "Exuari" then
			setCommsMessage(_("shipEnemy-comms", "Stay out of our way, or your death will amuse us extremely!"));
		elseif faction == "Ghosts" then
			setCommsMessage(_("shipEnemy-comms", "One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."));
			taunt_option = _("shipEnemy-comms", "EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("shipEnemy-comms", "Rogue command received. Targeting source.")
			taunt_failed_reply = _("shipEnemy-comms", "External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("shipEnemy-comms", "The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."));
			taunt_option = _("shipEnemy-comms", "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>")
			taunt_success_reply = _("shipEnemy-comms", "We do not need permission to pluck apart such an insignificant threat.")
			taunt_failed_reply = _("shipEnemy-comms", "The hive has greater priorities than exterminating pests.")
		else
			setCommsMessage(_("shipEnemy-comms", "Mind your own business!"));
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
		setCommsMessage(_("trade-comms", "Yes?"))
		addCommsReply(_("trade-comms", "Do you have cargo you might sell?"), function()
			local goodCount = 0
			local cargoMsg = _("trade-comms", "We've got ")
			for good, goodData in pairs(comms_data.goods) do
				if goodData.quantity > 0 then
					if goodCount > 0 then
						cargoMsg = cargoMsg .. _("trade-comms", ", ") .. good
					else
						cargoMsg = cargoMsg .. good
					end
				end
				goodCount = goodCount + goodData.quantity
			end
			if goodCount == 0 then
				cargoMsg = cargoMsg .. _("trade-comms", "nothing")
			end
			setCommsMessage(cargoMsg)
		end)
		local freighter_multiplier = 1
		if comms_data.friendlyness > 66 then
			setCommsMessage(_("trade-comms", "Yes?"))
			-- Offer destination information
			addCommsReply(_("trade-comms", "Where are you headed?"), function()
				setCommsMessage(comms_target.target:getCallSign())
				addCommsReply(_("Back"), commsShip)
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
					addCommsReply(_("trade-comms", "Jettison cargo"), function()
						setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								addCommsReply(good, function()
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),good))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end
						addCommsReply(_("Back"), commsShip)
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
								addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
									comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
									if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
									comms_source.goods[good] = comms_source.goods[good] + 1
									setCommsMessage(_("trade-comms", "Traded"))
									addCommsReply(_("Back"), commsShip)
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
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*freighter_multiplier)), function()
							if comms_source.cargo > 0 then
								if comms_source:takeReputationPoints(goodData.cost) then
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then comms_source.goods = {} end
									if comms_source.goods[good] == nil then comms_source.goods[good] = 0 end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.cargo = comms_source.cargo - 1
									setCommsMessage(string.format(_("trade-comms", "Purchased %s from %s"),good,comms_target:getCallSign()))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								end
							else
								setCommsMessage(_("trade-comms", "Insufficient cargo space"))
							end
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end	--freighter goods loop
			end
		elseif comms_data.friendlyness > 33 then
			setCommsMessage(_("shipAssist-comms", "What do you want?"))
			-- Offer to sell destination information
			destRep = random(1,5)
			addCommsReply(string.format(_("trade-comms", "Where are you headed? (cost: %f reputation)"),destRep), function()
				if not comms_source:takeReputationPoints(destRep) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					setCommsMessage(comms_target.target:getCallSign())
				end
				addCommsReply(_("Back"), commsShip)
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
					addCommsReply(_("trade-comms", "Jettison cargo"), function()
						setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
						for good, good_quantity in pairs(comms_source.goods) do
							if good_quantity > 0 then
								addCommsReply(good, function()
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),good))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end
						addCommsReply(_("Back"), commsShip)
					end)
				end
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 2
				else
					freighter_multiplier = 3
				end
				for good, goodData in pairs(comms_data.goods) do
					if goodData.quantity > 0 then
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*freighter_multiplier)), function()
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
									setCommsMessage(string.format(_("trade-comms", "Purchased %s from %s"),good,comms_target:getCallSign()))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								end
							else
								setCommsMessage(_("trade-comms", "Insufficient cargo space"))
							end
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end	--freighter goods loop
			end
		else	--least friendly
			setCommsMessage(_("trade-comms", "Why are you bothering me?"))
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					freighter_multiplier = 3
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost*freighter_multiplier)), function()
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
										setCommsMessage(string.format(_("trade-comms", "Purchased %s from %s"),good,comms_target:getCallSign()))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
									end
								else
									setCommsMessage(_("trade-comms", "Insufficient cargo space"))
								end
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end	--freighter goods loop
				end
			end
		end
	else
		if comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
		else
			setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
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
		if difficulty == 1 then
			if early_hint_time == nil then
				early_hint_time = getScenarioTime() + 250
			end
			if getScenarioTime() > early_hint_time then
				if hintRepulseTimer == nil or hintRepulseTimer > 0 then
					if playerFighter.early_hint_msg_eng == nil then
						playerFighter.early_hint_msg_eng = "early_hint_msg_eng"
						playerFighter:addCustomMessage("Engineering",playerFighter.early_hint_msg_eng,string.format(_("air-msgEngineer","The Repulse ship %s seems like it's in the best condition. You should ask the science officer to scan it again to check the state of its engines."),junkRepulse:getCallSign()))
					end
					if playerFighter.early_hint_msg_epl == nil then
						playerFighter.early_hint_msg_epl = "early_hint_msg_epl"
						playerFighter:addCustomMessage("Engineering+",playerFighter.early_hint_msg_epl,string.format(_("air-msgEngineer+","The Repulse ship %s seems like it's in the best condition. You should ask the science officer to scan it again to check the state of its engines."),junkRepulse:getCallSign()))
					end
				end
			end
		end
		local suffocation_label = _("airTimer-tabScience&Eng&Eng+&Ops", "Suffocation")
		local suffocation_label_minutes = math.floor(suffocation_timer / 60)
		local suffocation_label_seconds = math.floor(suffocation_timer % 60)
		if suffocation_label_minutes <= 0 then
			suffocation_label = string.format(_("airTimer-tabScience&Eng&Eng+&Ops", "%s %i"),suffocation_label,suffocation_label_seconds)
		else
			suffocation_label = string.format(_("airTimer-tabScience&Eng&Eng+&Ops", "%s %i:%.2i"),suffocation_label,suffocation_label_minutes,suffocation_label_seconds)
		end
		if playerFighter:hasPlayerAtPosition("Engineering") then
			if playerFighter.suffocation_message == nil then
				playerFighter.suffocation_message = "suffocation_message"
				playerFighter:addCustomMessage("Engineering",playerFighter.suffocation_message,_("air-msgEngineer", "Environmental systems show limited air remaining"))
			end
			playerFighter.suffocation_timer = "suffocation_timer"
			playerFighter:addCustomInfo("Engineering",playerFighter.suffocation_timer,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			if playerFighter.suffocation_message_eng_plus == nil then
				playerFighter.suffocation_message_eng_plus = "suffocation_message_eng_plus"
				playerFighter:addCustomMessage("Engineering+",playerFighter.suffocation_message_eng_plus,_("air-msgEngineer+", "Environmental systems show limited air remaining"))
			end
			playerFighter.suffocation_timer_eng_plus = "suffocation_timer_eng_plus"
			playerFighter:addCustomInfo("Engineering+",playerFighter.suffocation_timer_eng_plus,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("DamageControl") then
			if playerFighter.suffocation_message_dmg_ctl == nil then
				playerFighter.suffocation_message_dmg_ctl = "suffocation_message_dmg_ctl"
				playerFighter:addCustomMessage("DamageControl",playerFighter.suffocation_message_dmg_ctl,_("air-msgDamageControl", "Environmental systems show limited air remaining"))
			end
			playerFighter.suffocation_timer_dmg_ctl = "suffocation_timer_dmg_ctl"
			playerFighter:addCustomInfo("DamageControl",playerFighter.suffocation_timer_dmg_ctl,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("Science") then
			if playerFighter.suffocation_message_science == nil then
				playerFighter.suffocation_message_science = "suffocation_message_science"
				playerFighter:addCustomMessage("Science",playerFighter.suffocation_message_science,_("air-msgScience", "Environmental systems show limited air remaining"))
			end
			playerFighter.suffocation_timer_science = "suffocation_timer_science"
			playerFighter:addCustomInfo("Science",playerFighter.suffocation_timer_science,suffocation_label)
		end
		if playerFighter:hasPlayerAtPosition("Operations") then
			if playerFighter.suffocation_message_ops == nil then
				playerFighter.suffocation_message_ops = "suffocation_message_ops"
				playerFighter:addCustomMessage("Operations",playerFighter.suffocation_message_ops,_("air-msgOperations", "Environmental systems show limited air remaining"))
			end
			playerFighter.suffocation_timer_ops = "suffocation_timer_ops"
			playerFighter:addCustomInfo("Operations",playerFighter.suffocation_timer_ops,suffocation_label)
		end
		if suffocation_timer < 0 then
			globalMessage(_("defeat-msgMainscreen", "You suffocated while aboard the fighter hulk"))
			victory("Kraylor")
			if playerFighter.suffocation_timer ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer)
				playerFighter.suffocation_timer = nil
			end
			if playerFighter.suffocation_timer_eng_plus ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer_eng_plus)
				playerFighter.suffocation_timer_eng_plus = nil
			end
			if playerFighter.suffocation_timer_dmg_ctl ~= nil then
				playerFighter:removeCustom(playerFighter.suffocation_timer_dmg_ctl)
				playerFighter.suffocation_timer_dmg_ctl = nil
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
			playerFighter:addCustomMessage("Engineering",repulseHintMessage,string.format(_("transfer-msgEngineer", "Reading through the scan data provided by science, you see that there could be a working jump drive on %s. However, if the crew wishes to transport over there, %s will need to get very close due to the minimal amount of energy remaining in the transporters."),junkRepulse:getCallSign(),playerFighter:getCallSign()))
		end
		if playerFighter:hasPlayerAtPosition("Engineering+") then
			repulseHintMessageEPlus = "repulseHintMessageEPlus"
			playerFighter:addCustomMessage("Engineering+",repulseHintMessageEPlus,string.format(_("transfer-msgEngineer+", "Reading through the scan data provided by science, you see that there could be a working jump drive on %s. However, if the crew wishes to transport over there, %s will need to get very close due to the minimal amount of energy remaining in the transporters."),junkRepulse:getCallSign(),playerFighter:getCallSign()))
		end
		plot1 = hugRepulse
	end
end
function hugRepulse(delta)
--Get close enough and a transfer button will appear
	if difficulty >= 1 then
		plotSuffocate = checkForSuffocationOnFighter
	end
	if playerFighter ~= nil and playerFighter:isValid() then
		if distance(playerFighter,junkRepulse) < 500 then
			if playerFighter:hasPlayerAtPosition("Engineering") then
				repulseTransferButton = "repulseTransferButton"
				playerFighter:addCustomButton("Engineering",repulseTransferButton,_("crewTransfer-buttonEngineer", "Transfer to Repulse"),repulseTransfer)
			end
			if playerFighter:hasPlayerAtPosition("Engineering+") then
				repulseTransferButtonEPlus = "repulseTransferButtonEPlus"
				playerFighter:addCustomButton("Engineering+",repulseTransferButtonEPlus,_("crewTransfer-buttonEngineer+", "Transfer to Repulse"),repulseTransfer)
			end
			if playerFighter:hasPlayerAtPosition("DamageControl") then
				repulseTransferButtonDmgCtl = "repulseTransferButtonDmgCtl"
				playerFighter:addCustomButton("DamageControl",repulseTransferButtonDmgCtl,_("crewTransfer-buttonDamageControl", "Transfer to Repulse"),repulseTransfer)
			end
			if repulseTransferButtonEPlus ~= nil or repulseTransferButton ~= nil or repulseTransferButtonDmgCtl ~= nil then
				plot1 = nil
			end
		end
	else
		globalMessage(_("defeat-msgMainscreen","You were destroyed. The Human Navy did not receive your Kraylor intel."))
		victory("Kraylor")
	end
end
function repulseTransfer()
--Transfer crew and any artifacts picked up to Repulse
	swapx, swapy = junkRepulse:getPosition()	--save NPC ship location
	swapRotate = junkRepulse:getRotation()		--save NPC ship orientation
	junkRepulse:setPosition(500,500)			--move NPC ship away
	playerRepulse = PlayerSpaceship():setFaction("Independent"):setTemplate("Repulse"):setCallSign("HMS Plunder"):setPosition(swapx,swapy)
	playerRepulse:setRotation(swapRotate)		--set orientation that was saved
	for system,health in pairs(plunder_system_health) do
		playerRepulse:setSystemHealth(system,junkRepulse:getSystemHealth(system))
		if health.max ~= nil then
			playerRepulse:setSystemHealthMax(system,health.max)
		end
	end
	playerRepulse:onDestruction(function()
		globalMessage(_("defeat-msgMainscreen","You were destroyed. The Human Navy did not receive your Kraylor intel."))
		victory("Kraylor")
	end)
	playerRepulse:setSystemHealth("jumpdrive",-.2)	--jump drive more damaged than sensors indicated
	playerRepulse:setHull(junkRepulse:getHull()):setEnergy(250):setRepairCrewCount(2):setScanProbeCount(1)
	junkRepulse:destroy()				--goodbye NPC repulse
	local front_shield_level = playerRepulse:getShieldMax(0)
	local rear_shield_level = playerRepulse:getShieldMax(1)
	if difficulty > 1 then
		front_shield_level = front_shield_level/5
		rear_shield_level = rear_shield_level/5
	elseif difficulty == 1 then
		front_shield_level = front_shield_level/2
		rear_shield_level = rear_shield_level/2
	end
	playerRepulse:setShields(front_shield_level,rear_shield_level)
	playerRepulse.maxCargo = 12			--cargo capacity
	playerRepulse.cargo = playerRepulse.maxCargo	--available capacity
	playerRepulse.shipScore = 14		--ship relative strength
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
	local transfer_systems = {"reactor","beamweapons","maneuver","impulse","frontshield"}
	for i,system in ipairs(transfer_systems) do
		junkFighter:setSystemHealthMax(system,playerFighter:getSystemHealth(system))	--transfer repair level and fix
	end
	playerRepulse.debris1 = playerFighter.debris1	--transfer debris record
	playerRepulse.debris2 = playerFighter.debris2	--transfer debris record
	playerRepulse.debris3 = playerFighter.debris3	--transfer debris record
	playerFighter:destroy()				--goodbye player fighter
	playerShipHealth = plunderHealth	--switch player health check function to repulse
	augmentRepairCrewTimer = 45			--time to repair crew escape
	plot1 = augmentRepairCrew
	playerRepulse:addToShipLog(_("transfer-shipLog", "Welcome aboard the Repulse class ship, rechristened HMS Plunder, currently registered as Independent"),"Magenta")
	player = playerRepulse
	plotSuffocate = nil
end
function augmentRepairCrew(delta)
--Former repair crew asks to be rescued to take up their jobs again
	augmentRepairCrewTimer = augmentRepairCrewTimer - delta
	if augmentRepairCrewTimer < 0 then
		brigHailed = brigStation:sendCommsMessage(playerRepulse,_("crewImport-incCall", "Need a repair crew? We used to be posted on that ship. We would be happy to return to our repair duty and get away from these Kraylors. We left the transporters locked on us, but the Kraylors destroyed our remote activator. You should find an activation switch at the weapons console"))
		if brigHailed then
			if playerRepulse:hasPlayerAtPosition("Weapons") then
				if retrieveRepairCrewButton == nil then
					retrieveRepairCrewButton = "retrieveRepairCrewButton"
					playerRepulse:addCustomButton("Weapons",retrieveRepairCrewButton,_("crewTransfer-buttonWeapons", "Return Transport"),returnRepairCrew)
				end
			end
			if playerRepulse:hasPlayerAtPosition("Tactical") then
				if retrieveRepairCrewButtonTac == nil then
					retrieveRepairCrewButtonTac = "retrieveRepairCrewButtonTac"
					playerRepulse:addCustomButton("Tactical",retrieveRepairCrewButtonTac,_("crewTransfer-buttonTactical", "Return Transport"),returnRepairCrew)
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
		playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew reports that the port beam weapon emplacement is currently non-functional. No applicable spare parts found aboard"),"Magenta")
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
			playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew reports the jump drive not operational. However, they may be able to adapt some of the space debris picked up earlier into suitable replacement parts. They are starting the fabrication process now"),"Magenta")
			plot3 = jumpPartFabrication
			jumpPartFabricationTimer = 60
		else
			playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew reports the jump drive inoperative. Additional parts are necessary"),"Magenta")
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
		playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew says the missle weapons systems are not repairable with available components"),"Magenta")
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
			playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew applied some of the parts picked up to make some repairs on the hull"),"Magenta")
		end
	end
end
function damageSummaryReport(delta)
--Report on completed repairs
	local total_diff = 0
	local diff_systems = {"reactor","beamweapons","maneuver","missilesystem","impulse","jumpdrive","frontshield","rearshield"}
	for i,system in ipairs(diff_systems) do
		total_diff = total_diff + math.abs(playerRepulse:getSystemHealthMax(system) - playerRepulse:getSystemHealth(system))
	end
	if total_diff < .1 then
		playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew reports they have repaired as much as they can. Additional parts may be available in the junk yard. We have not been able to get long range communications online, so we are as yet unable to locate or contact any Human Navy stations."),"Magenta")
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
				playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Edwina (repair crew member)] My dad can fix our missile systems. He's got years of experience. He's on %s"),missileFixStation:getCallSign()),"Magenta")
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
				playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Amir (repair crew member)] My sister fixes shield systems. I bet she could easily get our shields working. She works at a shop on %s"),shieldFixStation:getCallSign()),"Magenta")
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
				playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Janet (repair crew member)] Johnny, my son, does practical research on impulse drives. He's on %s. He can probably get our impulse engines up to full capacity"),impulseFixStation:getCallSign()),"Magenta")
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
				playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Fred (repair crew member)] The outfit my wife works for on %s specializes in long range communication. She could probably get our systems connected back up to the Human Navy communication network"),longRangeFixStation:getCallSign()),"Magenta")
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
				playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Nancy (repair crew member)] Our jump drive needs help. My brother on %s fixes jump drives and he could get ours working"),jumpFixStation:getCallSign()),"Magenta")
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
				playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Manuel (repair crew member)] The reactor could use some tuning. My cousin can fix us up. He does work on reactors on %s"),reactorFixStation:getCallSign()),"Magenta")
				reactorFixStationMessage = "sent"
				if playerRepulse:hasPlayerAtPosition("Relay") then
					if crewFixButtonMsg == nil then
						crewFixButtonMsg = "crewFixButtonMsg"
						playerRepulse:addCustomButton("Relay",crewFixButtonMsg,_("crewRepairStatut-buttonRelay", "crew fixers"),showCrewFixers)
					end
				end
				if playerRepulse:hasPlayerAtPosition("Operations") then
					if crewFixButtonMsgOp == nil then
						crewFixButtonMsgOp = "crewFixButtonMsgOp"
						playerRepulse:addCustomButton("Operations",crewFixButtonMsgOp,_("crewRepairStatut-buttonOperations", "crew fixers"),showCrewFixers)
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
		for idx, enemy in ipairs(fleet) do
			enemy:orderAttack(playerRepulse)
		end
		harassment_timer = delta + 200 - (difficulty*20)
	end
end
function showCrewFixers()
	oMsg = ""
	if not playerRepulse.missileFix then
		oMsg = oMsg .. string.format(_("crewRepairStatut-msgRelay&Operations", " Missiles:%s(%s) "),missileFixStation:getCallSign(),missileFixStation:getSectorName())
	end
	if not playerRepulse.frontShieldFix and not playerRepulse.rearShieldFix then
		oMsg = oMsg .. string.format(_("crewRepairStatut-msgRelay&Operations", " Shields:%s(%s) "),shieldFixStation:getCallSign(),shieldFixStation:getSectorName())
	end
	if not playerRepulse.impulseFix then
		oMsg = oMsg .. string.format(_("crewRepairStatut-msgRelay&Operations", " Impulse:%s(%s) "),impulseFixStation:getCallSign(),impulseFixStation:getSectorName())
	end
	if not playerRepulse.longRangeFix then
		oMsg = oMsg .. string.format(_("crewRepairStatut-msgRelay&Operations", " Communications:%s(%s) "),longRangeFixStation:getCallSign(),longRangeFixStation:getSectorName())
	end
	if not playerRepulse.jumpFix then
		oMsg = oMsg .. string.format(_("crewRepairStatut-msgRelay&Operations", " Jump:%s(%s) "),jumpFixStation:getCallSign(),jumpFixStation:getSectorName())
	end
	if not playerRepulse.reactorFix then
		oMsg = oMsg .. string.format(_("crewRepairStatut-msgRelay&Operations", " Reactor:%s(%s) "),reactorFixStation:getCallSign(),reactorFixStation:getSectorName())
	end
	if oMsg == nil then
		if crewFixButtonMsg ~= nil then
			playerRepulse:removeCustom(crewFixButtonMsg)
		end
		if crewFixButtonMsgOp ~= nil then
			playerRepulse:removeCustom(crewFixButtonMsgOp)		
		end
	else
		playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew suggested locations for ship fixes:"),"Magenta")
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
			playerRepulse:addToShipLog(string.format(_("crewFriends-shipLog", "[Kent (repair crew member)] My brother on %s in %s can fix our port side beam weapon"),beamFixStation:getCallSign(),beamFixStation:getSectorName()),"Magenta")
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
		if playerRepulse.junk_yard_dog_warning == nil and junk_yard_dog ~= nil and junk_yard_dog:isValid() then
			playerRepulse:addToShipLog(string.format(_("Boris-shipLog", "[Sensor tech] Looks like %s figured out where we went and has sicced %s on us."),brigStation:getCallSign(),junk_yard_dog:getCallSign()),"Magenta")
			playerRepulse:addToShipLog(string.format(_("Boris-shipLog", "[Engineering tech] With our hull at %i, we better hope our shields hold"),playerRepulse:getHull()),"Magenta")
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
				if boris_message_log_messages == nil or #boris_message_log_messages == 0 then
					boris_message_log_messages = {
						_("Boris-shipLog", "[%s] You won't get away so easily."),
						_("Boris-shipLog", "[%s] You can run, but you can't hide."),
						_("Boris-shipLog", "[%s] I will get you yet."),
						_("Boris-shipLog", "[%s] I will hunt you down and destroy you like vermin."),
						_("Boris-shipLog", "[%s] Slow down, I promise not to destroy you immediately."),
					}
				end
				local chaser_message = tableRemoveRandom(boris_message_log_messages)
				playerRepulse:addToShipLog(string.format(chaser_message,junkChaser:getCallSign()),"Red")
			else
				if difficulty < 1 then
					junkChaser = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Drone"):setPosition(brigx-100,brigy-100):orderAttack(playerRepulse):setRotation(180)
				elseif difficulty > 1 then
					junkChaser = CpuShip():setFaction("Exuari"):setTemplate("Fighter"):setPosition(brigx-100,brigy-100):orderAttack(playerRepulse):setRotation(180)
				else
					junkChaser = CpuShip():setFaction("Exuari"):setTemplate("Ktlitan Fighter"):setPosition(brigx-100,brigy-100):orderAttack(playerRepulse):setRotation(180)
				end
				if boris_comms_messages == nil or #boris_comms_messages == 0 then
					boris_comms_messages = {
						_("Boris-incCall", "You don't steal from Boris Junk Yard without consequences. I'm coming for you."),
						_("Boris-incCall", "I saw you steal that ship. You'll rue the day."),
						_("Boris-incCall", "Stealing a ship, eh? We'll just see about that."),
						_("Boris-incCall", "You must pay for the ship you stole from Boris Junk Yard... with your life."),
					}
				end
				local chaser_comms = tableRemoveRandom(boris_comms_messages)
				junkChaser:sendCommsMessage(playerRepulse,chaser_comms)
				junkChaser:onDestruction(resetBoris)
			end
		end
	end
end
function resetBoris(self, instigator)
	if borisChaseTimer < 300 then
		borisChaseTimer = 300
	end
	if boris_expiration_messages == nil or #boris_expiration_messages == 0 then
		boris_expiration_messages = {
			_("Boris-shipLog", "[%s] You can't get rid of me that easily."),
			_("Boris-shipLog", "[%s] I'll be back."),
			_("Boris-shipLog", "[%s] I've got plenty of ships."),
			_("Boris-shipLog", "[%s] This is merely a temporary setback."),
		}
	end
	boris_expiration_message = tableRemoveRandom(boris_expiration_messages)
	playerRepulse:addToShipLog(string.format(boris_expiration_message,self:getCallSign()),"Red")
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
		playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew thinks they can use the space debris recently acquired to make repair parts for the jump drive. They are starting the fabrication process now."),"Magenta")
		plot3 = jumpPartFabrication
		jumpPartFabricationTimer = 60
	end
end
function jumpPartFabrication(delta)
--Jump drive repairable 
	jumpPartFabricationTimer = jumpPartFabricationTimer - delta
	if jumpPartFabricationTimer < 0 then
		playerRepulse:addToShipLog(_("crewRepair-shipLog", "Repair crew finished jump drive part fabrication. They believe the jump drive should be functional soon."),"Magenta")
		playerRepulse:setSystemHealthMax("jumpdrive",.5)
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
				globalMessage(_("victory-msgMainscreen","Congratulations! You escaped the Kraylor clutches and returned all your gathered data on the Kraylor to the Human Navy."))
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
		for idx, kgi in ipairs(kgr) do
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
			for idx, enemy in ipairs(patrolGroup) do
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
	enemyStrength = math.max(danger * enemy_power * 14, 5)	--assume player ship repulse at strength 14
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
			for idx, kobj in ipairs(kraylorTransportList) do
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
				name = string.format("%s Jump Freighter %d", name, irandom(3, 5))
			else
				name = string.format("%s Freighter %d", name, irandom(1, 5))
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
			for idx, obj in ipairs(independentTransportList) do
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
				name = string.format("%s Jump Freighter %d", name, irandom(3, 5))
			else
				name = string.format("%s Freighter %d", name, irandom(1, 5))
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
		junkZone:setLabel(_("ZoneLabelDescription-junk", "Boris Junk Yard"))
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
end
function scragHealth(delta)
	for system,health in pairs(scrag_system_health) do
		if health.max ~= nil then
			if playerFighter ~= nil and playerFighter:isValid() then
				if playerFighter:getSystemHealth(system) >= playerFighter:getSystemHealthMax(system) then
					if playerFighter.repair_max_msg_eng == nil then
						playerFighter.repair_max_msg_eng = {}
					end
					if playerFighter.repair_max_msg_eng[system] == nil then
						playerFighter.repair_max_msg_eng[system] = string.format("repair_max_msg_eng_%s",system)
						playerFighter:addCustomMessage("Engineering",playerFighter.repair_max_msg_eng[system],health.msg)
					end
					if playerFighter.repair_max_msg_epl == nil then
						playerFighter.repair_max_msg_epl = {}
					end
					if playerFighter.repair_max_msg_epl[system] == nil then
						playerFighter.repair_max_msg_epl[system] = string.format("repair_max_msg_epl_%s",system)
						playerFighter:addCustomMessage("Engineering+",playerFighter.repair_max_msg_epl[system],health.msg)
					end
				end
			end
		end
	end
end
function plunderHealth(delta)
	for system,health in pairs(plunder_system_health) do
		if health.max ~= nil then
			if playerRepulse ~= nil and playerRepulse:isValid() then
				if playerRepulse:getSystemHealth(system) >= playerRepulse:getSystemHealthMax(system) then
					if playerRepulse.repair_max_msg_eng == nil then
						playerRepulse.repair_max_msg_eng = {}
					end
					if playerRepulse.repair_max_msg_eng[system] == nil then
						playerRepulse.repair_max_msg_eng[system] = string.format("repair_max_msg_eng_%s",system)
						playerRepulse:addCustomMessage("Engineering",playerRepulse.repair_max_msg_eng[system],health.msg)
					end
					if playerRepulse.repair_max_msg_epl == nil then
						playerRepulse.repair_max_msg_epl = {}
					end
					if playerRepulse.repair_max_msg_epl[system] == nil then
						playerRepulse.repair_max_msg_epl[system] = string.format("repair_max_msg_epl_%s",system)
						playerRepulse:addCustomMessage("Engineering+",playerRepulse.repair_max_msg_epl[system],health.msg)
					end
				end
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
	shipHealth(delta)		--ship health (player and junk yard)
	independentTransportPlot(delta)
	kraylorTransportPlot(delta)
	kraylorPatrol(delta)
	if plotSign ~= nil then
		plotSign(delta)
	end
end