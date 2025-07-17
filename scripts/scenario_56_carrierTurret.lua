-- Name: Carrier and Fighters
-- Description: Three player ships: a carrier and two fighters docked with the carrier. Objective: search out and destroy the designated enemy station. Use the carrier to travel long distances. Fighters have automatic coolant and repair management. Carrier provides energy and hull repair to fighters. The scenario randomizes the terrain and the mini mission order for each run.
---
--- Version 2 (formerly entitled Carriers and Turrets)
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Mission
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Very Easy]: The least number of or the weakest enemies
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Very Easy]: Random factors are very much in your favor
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Setting[Timed]: Configures whether or not the scenario has a time limit
-- Timed[None|Default]: Game has no time limit
-- Timed[1]: Game has a 1 minute time limit (used for testing)
-- Timed[30]: Game has a 30 minute time limit
-- Timed[60]: Game has a 60 minute time limit
-- Timed[90]: Game has a 90 minute time limit
-- Setting[Carrier]: Configures the carrier deployed as a player ship
-- Carrier[Random|Default]: A carrier type will be selected at random
-- Carrier[Benedict]: The carrier deployed will be of type Benedict with a jump drive
-- Carrier[Kiriya]: The carrier deployed will be of type Kiriya with a warp drive
-- Carrier[Saipan]: The carrier deployed will be of type Saipan with a jump drive 
-- Setting[Fighter1]: Configures the first fighter type deployed as a player ship
-- Fighter1[Random|Default]: Fighter 1 type will be selected at random
-- Fighter1[Striker]: Fighter 1 will be of type Striker
-- Fighter1[Formax]: Fighter 1 will be of type Formax
-- Fighter1[Foil]: Fighter 1 will be of type Foil
-- Setting[Fighter2]: Configures the second fighter type deployed as a player ship
-- Fighter2[Random|Default]: Fighter 2 type will be selected at random
-- Fighter2[ZX-Lindworm]: Fighter 2 will be of type ZX-Lindworm
-- Fighter2[MP52 Hornet]: Fighter 2 will be of type MP52 Hornet
-- Fighter2[Red Jacket]: Fighter 2 will be of type Red Jacket

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
require("place_station_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")

function init()
	ECS = false
	if createEntity then
		ECS = true
	end
	mission_diagnostic = false
	diagnostic = false
	fleet_id_diagnostic = false
	setConstants()
	setGlobals()
	setVariations()
	GMStartPlot2upgradeShipSpin = _("buttonGM", "P2 upgrade spin")
	GMStartPlot2locateTargetEnemyBase = _("buttonGM", "P2 locate enemy base")
	GMStartPlot2rescueDyingScientist = _("buttonGM", "P2 rescue scientist")
	GMStartPlot3upgradeBeamDamage = _("buttonGM", "P3 upgrade beam dmg")
	GMStartPlot3tractorDisabledShip = _("buttonGM", "P3 tractor ship")
	GMStartPlot3addTubeToShip = _("buttonGM", "P3 add tube")
	setGMButtons()
	buildStations()
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	transportList = {}
	transportSpawnDelay = 30
	healthCheckTimerInterval = 5
	initialOrderTimer = getScenarioTime() + 3
	plot1 = initialOrders
	startx = 0
	starty = 0
	offsetList = getObjectsInRadius(startx,starty,1500)
	if #offsetList > 0 then
		local start_count = 0
		repeat
			jx, jy = vectorFromAngle(random(0,360),1600)
			nox, noy = offsetList[1]:getPosition()
			startx = nox+jx
			starty = noy+jy
			offsetList = getObjectsInRadius(startx,starty,1500)
			start_count = start_count + 1
		until(#offsetList < 1 or start_count > max_repeat_loop)
		if start_count > max_repeat_loop then
			print("exceeded max repeat loop when counting starting positions in init function")
		end
	end
	carrier_template = getScenarioSetting("Carrier")
	if carrier_template == "Random" then
		local carriers = {"Benedict","Kiriya","Saipan"}
		carrier_template = tableSelectRandom(carriers)
	end
	playerCarrier = PlayerSpaceship():setFaction("Human Navy"):setTemplate(carrier_template)
	playerCarrier:setPosition(startx,starty):setRotation(-90):commandTargetRotation(-90):setRepairDocked(true)
	if diagnostic then		--make carrier ridiculously powerful for mission diagnostic test purposes
		playerCarrier:setBeamWeapon(0, 10,   0, 1500.0, 1.0, 104):setBeamWeapon(1, 10, 180, 1500.0, 1.0, 104):setBeamWeaponHeatPerFire(0,playerCarrier:getBeamWeaponHeatPerFire(0)*.01):setBeamWeaponHeatPerFire(1,playerCarrier:getBeamWeaponHeatPerFire(1)*.01)
		playerCarrier:setBeamWeaponTurret(0,270,0,6):setBeamWeaponTurret(1,270,180,6):setBeamWeaponEnergyPerFire(0,1):setBeamWeaponEnergyPerFire(1,1)
	end
	if carrier_template == "Benedict" then
		playerCarrier:setJumpDriveCharge(90000)
	end
	fighter_template = getScenarioSetting("Fighter1")
	if fighter_template == "Random" then
		local fighters = {"Striker","Formax","Foil"}
		fighter_template = tableSelectRandom(fighters)
	end
	if fighter_template == "Formax" then
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Striker"):setJumpDrive(false):setWarpDrive(false)
		playerBlade:setTypeName("Formax")
		playerBlade:setImpulseMaxSpeed(90)
		playerBlade:setBeamWeaponTurret(0,60,-15,2)			-- 60: narrower than default 100, 
		playerBlade:setBeamWeaponTurret(1,60, 15,2)			-- 2: slower than default 6
		playerBlade:setWeaponTubeCount(2)
		playerBlade:setWeaponTubeDirection(0,  0):setTubeLoadTime(0,10):setWeaponTubeExclusiveFor(0,"HVLI"):setTubeSize(0,"small")
		playerBlade:setWeaponTubeDirection(1,180):setTubeLoadTime(1,15):setWeaponTubeExclusiveFor(1,"Mine")
		playerBlade:setWeaponStorageMax("HVLI",9):setWeaponStorage("HVLI",9)
		playerBlade:setWeaponStorageMax("Mine",3):setWeaponStorage("Mine",3)
	elseif fighter_template == "Foil" then
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Striker"):setJumpDrive(false):setWarpDrive(false)
		playerBlade:setTypeName("Foil")
		playerBlade:setImpulseMaxSpeed(95)
		playerBlade:setBeamWeaponTurret(0,60,-15,2)			-- 60: narrower than default 100, 
		playerBlade:setBeamWeaponTurret(1,60, 15,2)			-- 2: slower than default 6
		playerBlade:setBeamWeapon(2,20,0,1200,6,5)	
		playerBlade:setRepairCrewCount(4)
		playerBlade:setWeaponTubeCount(1)
		playerBlade:setWeaponTubeDirection(0,180):setTubeLoadTime(0,20):setWeaponTubeExclusiveFor(0,"Mine")
		playerBlade:setWeaponStorageMax("Mine",1):setWeaponStorage("Mine",1)
	else
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate(fighter_template):setJumpDrive(false):setWarpDrive(false)
	end
	playerBlade:setPosition(startx-240,starty):commandDock(playerCarrier):setRotation(-180):commandTargetRotation(-180)
	playerBlade:setLongRangeRadarRange(10000):setAutoCoolant(true):commandSetAutoRepair(true)
	playerBlade.normal_long_range_radar = 10000
	playerBlade:addCustomButton("Tactical","shield",_("buttonTactical","Shield"),function()
		if playerBlade:getShieldsActive() then
			playerBlade:commandSetShields(false)
		else
			playerBlade:commandSetShields(true)
		end
	end)
	if fighter_template == "Striker" then
		playerBlade:setImpulseMaxSpeed(90)
	end
	fighter_template_2 = getScenarioSetting("Fighter2")
	if fighter_template_2 == "Random" then
		local fighters = {"ZX-Lindworm","MP52 Hornet","Red Jacket"}
		fighter_template_2 = tableSelectRandom(fighters)
	end
	if fighter_template_2 == "Red Jacket" then
		playerPoint = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setJumpDrive(false):setWarpDrive(false)
		playerPoint:setTypeName("Red Jacket")
		playerPoint:setImpulseMaxSpeed(100)
		playerPoint:setWeaponTubeCount(1)
		playerPoint:setWeaponTubeDirection(0,180):setTubeLoadTime(0,20):setWeaponTubeExclusiveFor(0,"Mine")
		playerPoint:setWeaponStorageMax("Mine",1):setWeaponStorage("Mine",1)
	else
		playerPoint = PlayerSpaceship():setFaction("Human Navy"):setTemplate(fighter_template_2):setJumpDrive(false):setWarpDrive(false)
	end
	playerPoint:setPosition(startx+125,starty):commandDock(playerCarrier):setRotation(0):commandTargetRotation(0)
	playerPoint:setLongRangeRadarRange(10000):setAutoCoolant(true):commandSetAutoRepair(true)
	playerPoint.normal_long_range_radar = 10000
	playerPoint:addCustomButton("Tactical","shield",_("buttonTactical","Shield"),function()
		if playerPoint:getShieldsActive() then
			playerPoint:commandSetShields(false)
		else
			playerPoint:commandSetShields(true)
		end
	end)
	setPlayers()
	setMovingAsteroids()
	plot2choices = {upgradeShipSpin,locateTargetEnemyBase,rescueDyingScientist}
	plot3choices = {upgradeBeamDamage,tractorDisabledShip,addTubeToShip}
	--plot 4 choices will come eventually, just not with this release
	wfv = "end of init"
end
function setConstants()
	max_repeat_loop = 50
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	--Ship Template Name List
	stnl = {"MT52 Hornet","MU52 Hornet","Adder MK5","Adder MK4","WX-Lindworm","Adder MK6","Phobos T3","Phobos M3","Piranha F8","Piranha F12","Ranus U","Nirvana R5A","Stalker Q7","Stalker R7","Atlantis X23","Starhammer II","Odin","Fighter","Karnack MK2","Missile Cruiser","Strikeship","Adv. Striker","Dreadnought","Battlestation","Blockade Runner","Ktlitan Fighter","Ktlitan Breaker","Ktlitan Worker","Ktlitan Drone","Ktlitan Feeder","Ktlitan Scout","Ktlitan Destroyer","Storm"}
	--Ship Template Score List
	stsl = {5            ,5            ,7          ,6          ,7            ,8          ,15         ,16         ,15          ,15           ,25       ,20           ,25          ,25          ,50            ,70             ,250   ,6        ,18       ,14               ,30          ,27            ,80           ,100            ,65               ,6                ,45               ,40              ,4              ,48              ,8              ,50                 ,22}
	-- square grid deployment
	fleetPosDelta1x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1}
	fleetPosDelta1y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2}
	-- rough hexagonal deployment
	fleetPosDelta2x = {0,2,-2,1,-1, 1, 1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5}
	fleetPosDelta2y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1}
	transport_factions = {"Independent","Kraylor","Ktlitans","Ghosts","Arlenians","Independent"}
	player_ship_stats = {	--taken from sandbox. Not all are used. Not all characteristics are used.
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Atlantis MK2"]		= { strength = 55,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Corsair"]				= { strength = 50,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 12,	pods = 6,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Formax"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 6,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Foil"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 6,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = true,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Red Jacket"] 			= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Saipan"]				= { strength = 35,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 6,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
	--	Custom player ships	
		["Amalgam"]				= { strength = 42,	cargo = 7,	distance = 400,	long_range_radar = 36000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 11,	pods = 3,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 11,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Barrow"]				= { strength = 9,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 12,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 2,	},
		["Bermuda"]				= { strength = 30,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 14,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Butler"]				= { strength = 20,	cargo = 6,	distance = 200,	long_range_radar = 30000, short_range_radar = 5500, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Caretaker"]			= { strength = 23,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Chavez"]				= { strength = 21,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 0,	epjam = 1,	},
		["Crab"]				= { strength = 20,	cargo = 6,	distance = 200,	long_range_radar = 30000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Destroyer IV"]		= { strength = 22,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Eldridge"]			= { strength = 20,	cargo = 7,	distance = 200,	long_range_radar = 24000, short_range_radar = 8000, tractor = false,	mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 3,	epjam = 0,	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 9,	epjam = 3,	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = true,	patrol_probe = 1.25,prox_scan = 0,	epjam = 0,	},
		["Fowl"]				= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 3,	},
		["Fray"]				= { strength = 22,	cargo = 5,	distance = 200,	long_range_radar = 23000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 7,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Fresnel"]				= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 9,	epjam = 0,	},
		["Gadfly"]				= { strength = 9,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 3.6,	prox_scan = 9,	epjam = 0,	},
		["Glass Cannon"]		= { strength = 15,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Gull"]				= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 4,	prox_scan = 0,	epjam = 0,	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Interlock"]			= { strength = 19,	cargo = 12,	distance = 200,	long_range_radar = 35000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Kludge"]				= { strength = 22,	cargo = 9,	distance = 200,	long_range_radar = 35000, short_range_radar = 3500, tractor = false,	mining = true,	probes = 20,	pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Lurker"]				= { strength = 18,	cargo = 3,	distance = 100,	long_range_radar = 21000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Mantis"]				= { strength = 30,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 2,	turbo_torp = true,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 10,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	},
		["Midian"]				= { strength = 30,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 9,	epjam = 0,	},
		["Noble"]				= { strength = 33,	cargo = 6,	distance = 400,	long_range_radar = 27000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Nusret"]				= { strength = 16,	cargo = 7,	distance = 200,	long_range_radar = 25000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 10,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 3,	},
		["Orca"]				= { strength = 19,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 1,	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 1,	epjam = 0,	},
		["Peacock"]				= { strength = 30,	cargo = 9,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phargus"]				= { strength = 15,	cargo = 6,	distance = 200,	long_range_radar = 20000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 5,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phobos T2.2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 5,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Phoenix"]				= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Porcupine"]			= { strength = 30,	cargo = 6,	distance = 400,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Proto-Atlantis 2"]	= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Raven"]				= { strength = 30,	cargo = 5,	distance = 400,	long_range_radar = 25000, short_range_radar = 6000, tractor = true,		mining = false,	probes = 7,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Redhook"]				= { strength = 12,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 6,		pods = 2,	turbo_torp = false,	patrol_probe = 2.5,	prox_scan = 9,	epjam = 0,	},
		["Roc"]					= { strength = 25,	cargo = 6,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 6,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 1,	},
		["Rodent"]				= { strength = 23,	cargo = 8,	distance = 200,	long_range_radar = 40000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Rook"]				= { strength = 15,	cargo = 12,	distance = 200,	long_range_radar = 41000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 13,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Rotor"]				= { strength = 35,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 4000, tractor = true,		mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Safari"]				= { strength = 15,	cargo = 10,	distance = 200,	long_range_radar = 33000, short_range_radar = 4500, tractor = true,		mining = false,	probes = 9,		pods = 3,	turbo_torp = false,	patrol_probe = 3.5,	prox_scan = 0,	epjam = 0,	},
		["Scatter"]				= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 28000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Skray"]				= { strength = 15,	cargo = 3,	distance = 200, long_range_radar = 30000, short_range_radar = 7500, tractor = false,	mining = false,	probes = 25,	pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 3,	epjam = 0,	},
		["Sloop"]				= { strength = 20,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 4500, tractor = true,		mining = true,	probes = 9,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 2,	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, tractor = false,	mining = false,	probes = 7,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 9,	epjam = 0,	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 7,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 8,		pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Twister"]				= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 23000, short_range_radar = 5500, tractor = false,	mining = true,	probes = 15,	pods = 2,	turbo_torp = false,	patrol_probe = 3,	prox_scan = 1,	epjam = 0,	},
		["Torch"]				= { strength = 9,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4000, tractor = false,	mining = false,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Vermin"]				= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 22000, short_range_radar = 4000, tractor = false,	mining = true,	probes = 4,		pods = 1,	turbo_torp = false,	patrol_probe = 3.6,	prox_scan = 0,	epjam = 1,	},
		["Windmill"]			= { strength = 19,	cargo = 11,	distance = 200,	long_range_radar = 33000, short_range_radar = 5000, tractor = false,	mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Wombat"]				= { strength = 18,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 2,	},
		["Wrocket"]				= { strength = 19,	cargo = 8,	distance = 200,	long_range_radar = 32000, short_range_radar = 5500, tractor = false,	mining = false,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["XR-Lindworm"]			= { strength = 12,	cargo = 3,	distance = 100,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 5,		pods = 1,	turbo_torp = false,	patrol_probe = 3.9,	prox_scan = 9,	epjam = 0,	},
	}
end
function setGlobals()
	mission_milestones = 0
	interWave = 280	
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	good_desc = {
		["food"] =			_("trade-comms","food"),
		["medicine"] =		_("trade-comms","medicine"),
		["luxury"] =		_("trade-comms","luxury"),
		["cobalt"] =		_("trade-comms","cobalt"),
		["dilithium"] =		_("trade-comms","dilithium"),
		["gold"] =			_("trade-comms","gold"),
		["nickel"] =		_("trade-comms","nickel"),
		["platinum"] =		_("trade-comms","platinum"),
		["tritanium"] =		_("trade-comms","tritanium"),
		["autodoc"] =		_("trade-comms","autodoc"),
		["android"] =		_("trade-comms","android"),
		["battery"] =		_("trade-comms","battery"),
		["beam"] =			_("trade-comms","beam"),
		["circuit"] =		_("trade-comms","circuit"),
		["communication"] =	_("trade-comms","communication"),
		["filament"] =		_("trade-comms","filament"),
		["impulse"] =		_("trade-comms","impulse"),
		["lifter"] =		_("trade-comms","lifter"),
		["nanites"] =		_("trade-comms","nanites"),
		["optic"] =			_("trade-comms","optic"),
		["repulsor"] =		_("trade-comms","repulsor"),
		["robotic"] =		_("trade-comms","robotic"),
		["sensor"] =		_("trade-comms","sensor"),
		["shield"] =		_("trade-comms","shield"),
		["software"] =		_("trade-comms","software"),
		["tractor"] =		_("trade-comms","tractor"),
		["transporter"] =	_("trade-comms","transporter"),
		["warp"] =			_("trade-comms","warp"),
	}		
	goods = {}
	stationList = {}
	friendlyStationList = {}
	enemyStationList = {}
	tradeFood = {}
	tradeLuxury = {}
	tradeMedicine = {}
	--Player ship name lists to supplant standard randomized call sign generation
	player_ship_names_for = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Atlantis II"] =		{"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Foil"] =				{"Slice","Cut","Flay","Slash","Parry","Riposte","Lunge"},
		["Formax"] =			{"Sonic","Screech","Pidgeon","Dragon","Nevermore","Hammer","Leverage","Intrepid"},
		["Hathcock"] =			{"Hayha","Waldron","Plunkett","Mawhinney","Furlong","Zaytsev","Pavlichenko","Pegahmagabow","Fett","Hawkeye","Hanzo"},
		["Kiriya"] =			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["Maverick"] =			{"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Nautilus"] =			{"October","Abdiel","Manxman","Newcon","Nusret","Pluton","Amiral","Amur","Heinkel","Dornier"},
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Proto-Atlantis"] =	{"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"},
		["Red Jacket"] =		{"Buzzer","Hopper","Lash","Welt","Pelt","Pierce","Puncture","Stab","Slit"},
		["Redhook"] =			{"Headhunter", "Thud", "Troll", "Scalper", "Shark"},
		["Repulse"] =			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Saipan"] =			{"Atlas", "Bernard", "Alexander", "Retribution", "Sulaco", "Conestoga", "Saratoga", "Pegasus"},
		["Stricken"] =			{"Blazon", "Streaker", "Pinto", "Spear", "Javelin"},
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["Surkov"] =			{"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Leftovers"] =			{"Foregone","Righteous","Scandalous"},
	}
end
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
end
function setVariations()
	local enemy_config = {
		["Very Easy"] =	{number = .25},
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Very Easy"] =	{number = .25,	rep = 80},
		["Easy"] =		{number = .5,	rep = 50},
		["Normal"] =	{number = 1,	rep = 20},
		["Hard"] =		{number = 2,	rep = 10},
	}
	difficulty =	murphy_config[getScenarioSetting("Murphy")].number
	rep_bump =		murphy_config[getScenarioSetting("Murphy")].rep
	local time_config = {
		["None"] =	{limit = false,	length = 0,		intel = 300,	plot = nil,			},
		["1"] =		{limit = true,	length = 1,		intel = 200,	plot = timedGame,	},
		["30"] =	{limit = true,	length = 30,	intel = 200,	plot = timedGame,	},
		["60"] =	{limit = true,	length = 60,	intel = 250,	plot = timedGame,	},
		["90"] =	{limit = true,	length = 90,	intel = 300,	plot = timedGame,	},
	}
	playWithTimeLimit = time_config[getScenarioSetting("Timed")].limit
	timedIntelligenceInterval = time_config[getScenarioSetting("Timed")].intel
	gameTimeLimit = getScenarioTime() + time_config[getScenarioSetting("Timed")].length*60
	plot6 = time_config[getScenarioSetting("Timed")].plot
end
function mainGMButtonsDuringPause()
	clearGMFunctions()
	local button_label = _("buttonGM", "Turn On Diagnostic")
	if diagnostic then
		button_label = _("buttonGM", "Turn Off Diagnostic")
	end
	addGMFunction(button_label,function()
		if diagnostic then
			diagnostic = false
		else
			diagnostic = true
		end
		mainGMButtons()
	end)
------- In game GM buttons to change the delay between waves -------
-- Default is normal, so the fist button switches from a normal delay to a slow delay.
-- The slow delay is used for typical mission testing when the tester does not wish to
-- spend all their time fighting off enemies.
-- The second button switches from slow to fast. This facilitates testing the enemy
-- spawning routines. The third button goes from fast to normal. 
--translate variations into a numeric difficulty value
	local delay_config = {
		["slow"] = 600,
		["normal"] = 280,
		["fast"] = 20,
	}
	button_label = _("buttonGM", "Delay normal to slow")
	if interWave == delay_config["slow"] then
		button_label = _("buttonGM", "Delay slow to fast")
	elseif interWave == delay_config["fast"] then
		_("buttonGM", "Delay fast to normal")
	end
	addGMFunction(button_label,function()
		if interWave == delay_config["normal"] then
			interWave = delay_config["slow"]
		elseif interWave == delay_config["slow"] then
			interWave = delay_config["fast"]
		else
			interWave = delay_config["normal"]
		end
		mainGMButtons()
	end)
	addGMFunction(_("buttonGM","+Select Plot"),GMSelectPlot)
end
function mainGMButtonsAfterPause()
	clearGMFunctions()
	local button_label = _("buttonGM", "Turn On Diagnostic")
	if diagnostic then
		button_label = _("buttonGM", "Turn Off Diagnostic")
	end
	addGMFunction(button_label,function()
		if diagnostic then
			diagnostic = false
		else
			diagnostic = true
		end
		mainGMButtons()
	end)
	local delay_config = {
		["slow"] = 600,
		["normal"] = 280,
		["fast"] = 20,
	}
	button_label = _("buttonGM", "Delay normal to slow")
	if interWave == delay_config["slow"] then
		button_label = _("buttonGM", "Delay slow to fast")
	elseif interWave == delay_config["fast"] then
		_("buttonGM", "Delay fast to normal")
	end
	addGMFunction(button_label,function()
		if interWave == delay_config["normal"] then
			interWave = delay_config["slow"]
		elseif interWave == delay_config["slow"] then
			interWave = delay_config["fast"]
		else
			interWave = delay_config["normal"]
		end
		mainGMButtons()
	end)
	addGMFunction(_("buttonGM","+Select Plot"),GMSelectPlot)
	addGMFunction(_("buttonGM", "Spawn Enemies"),GMSpawnsEnemies)
end
function GMSelectPlot()
	clearGMFunctions()
	addGMFunction("-Main",mainGMButtons)
	if GMStartPlot2upgradeShipSpin ~= nil then
		addGMFunction(GMStartPlot2upgradeShipSpin,function()
			local match = false
			for i,plot in ipairs(plot2choices) do
				if plot == upgradeShipSpin then
					match = true
					break
				end
			end
			if match then
				nextPlot2 = upgradeShipSpin
			else
				addGMMessage(_("msgGM","The upgrade ship spin plot is not available."))
			end
			GMStartPlot2upgradeShipSpin = nil
			mainGMButtons()
		end)
	end
	if GMStartPlot2locateTargetEnemyBase ~= nil then
		addGMFunction(GMStartPlot2locateTargetEnemyBase,function()
			local match = false
			for i,plot in ipairs(plot2choices) do
				if plot == locateTargetEnemyBase then
					match = true
					break
				end
			end
			if match then
				nextPlot2 = locateTargetEnemyBase
			else
				addGMMessage(_("msgGM","The locate target enemy base plot is no longer available."))
			end
			GMStartPlot2locateTargetEnemyBase = nil
			mainGMButtons()
		end)
	end
	if GMStartPlot2rescueDyingScientist ~= nil then
		addGMFunction(GMStartPlot2rescueDyingScientist,function()
			local match = false
			for i,plot in ipairs(plot2choices) do
				if plot == rescueDyingScientist then
					match = true
					break
				end
			end
			if match then
				nextPlot2 = rescueDyingScientist
			else
				addGMMessage(_("msgGM","The rescue dying scientist plot is no longer available."))
			end
			GMStartPlot2rescueDyingScientist = nil
			mainGMButtons()
		end)
	end
	if GMStartPlot3upgradeBeamDamage ~= nil then
		addGMFunction(GMStartPlot3upgradeBeamDamage,function()
			local match = false
			for i,plot in ipairs(plot3choices) do
				if plot == upgradeBeamDamage then
					match = true
					break
				end
			end
			if match then
				nextPlot3 = upgradeBeamDamage
			else
				addGMMessage(_("msgGM","The upgrade beam damage plot is no longer available."))
			end
			GMStartPlot3upgradeBeamDamage = nil
			mainGMButtons()
		end)
	end
	if GMStartPlot3tractorDisabledShip ~= nil then
		addGMFunction(GMStartPlot3tractorDisabledShip,function()
			local match = false
			for i,plot in ipairs(plot3choices) do
				if plot == tractorDisabledShip then
					match = true
					break
				end
			end
			if match then
				nextPlot3 = tractorDisabledShip
			else
				addGMMessage(_("msgGM","The tractor disabled ship plot is no longer available."))
			end
			GMStartPlot3tractorDisabledShip = nil
			mainGMButtons()
		end)
	end
	if GMStartPlot3addTubeToShip ~= nil then
		addGMFunction(GMStartPlot3addTubeToShip,function()
			local match = false
			for i,plot in ipairs(plot3choices) do
				if plot == addTubeToShip then
					match = true
					break
				end
			end
			if match then
				nextPlot3 = addTubeToShip
			else
				addGMMessage(_("msgGM","The add tube to ship plot is no longer available."))
			end
			GMStartPlot3addTubeToShip = nil
			mainGMButtons()
		end)
	end
end
function GMSpawnsEnemies()
	gmPlayer = nil
	gmSelected = false
	gmSelect = getGMSelection()
	for idx, obj in ipairs(gmSelect) do
		local player_spaceship = false
		if ECS then
			if obj.components.player_control then
				player_spaceship = true
			end
		else
			if obj.typeName == "PlayerSpaceship" then
				player_spaceship = true
			end
		end
		if player_spaceship then
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
	for idx, enemy in ipairs(ntf) do
		enemy:orderAttack(gmPlayer)
	end
end
--	Set up terrain
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
end
function moveAsteroids()
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
function buildStations()
-- Organically (simulated asymetrically) grow stations from a central grid location
-- Order of creation: friendlies, neutrals, generic enemies, leading enemies
-- Statistically, the enemy stations typically end up on the edge, a fair distance away, but not always
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
	--place friendly stations
	stationFaction = "Human Navy"
	starting_friendly_station_count = 12
	for j=1,starting_friendly_station_count do
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
		local pStation = placeCTStation(psx,psy,"RandomHumanNeutral",stationFaction)
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
	starting_independent_station_count = 30
	local independent_stations = {}
	for j=1,starting_independent_station_count do
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
		local pStation = placeCTStation(psx,psy,"RandomHumanNeutral",stationFaction)
		table.insert(stationList,pStation)
		table.insert(independent_stations,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place enemy stations (from generic pool)
	stationFaction = "Ktlitans"
	fb = gp	--set faction boundary (between neutral and enemy)
	starting_ktlitan_station_count = 5
	for j=1,starting_ktlitan_station_count do
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
		local pStation = placeCTStation(psx,psy,"Generic",stationFaction)
		table.insert(enemyStationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place enemy stations (from enemy pool)
	stationFaction = "Ktlitans"
	fb = gp	--set faction boundary (between enemy and enemy leadership)
	starting_critical_ktlitan_station_count = 2
	for j=1,starting_critical_ktlitan_station_count do
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
		local pStation = placeCTStation(psx,psy,"Sinister",stationFaction)
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
	--mission related stations
	local station_candidate_pool = {}
	for i,station in ipairs(independent_stations) do
		if station:isValid() then
			table.insert(station_candidate_pool,station)
		end
	end
	spinScientistStation = tableRemoveRandom(station_candidate_pool)
	friendlyClueStation = tableRemoveRandom(station_candidate_pool)
	scientistStation = tableRemoveRandom(station_candidate_pool)
	addTubeStation = tableRemoveRandom(station_candidate_pool)
	tractorStation = tableRemoveRandom(station_candidate_pool)
	local friendly_candidate_stations = {}
	for i,station in ipairs(friendlyStationList) do
		table.insert(friendly_candidate_stations,station)
	end
	doctorStation = tableRemoveRandom(friendly_candidate_stations)
	beamDamageStation = tableRemoveRandom(friendly_candidate_stations)
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
function placeCTStation(x,y,name,faction,size)
	if faction == nil then
		if stationFaction ~= nil then
			faction = stationFaction
		else
			faction = "Independent"
		end
	end
	station_template_chance = {
		["Small Station"] = 0,
		["Medium Station"] = 20,
		["Large Station"] = 30,
		["Huge Station"] = 40,
	}
	faction_station_service_chance = {
		["Human Navy"] = 20,
		["Kraylor"] = 0,
		["Independent"] = 0,
		["Arlenians"] = 0,
		["Ghosts"] = 0,
		["Ktlitans"] = 0,
		["Exuari"] = 0,
		["TSN"] = 0,
		["USN"] = 0,
		["CUF"] = 0,
	}
	local station = placeStation(x,y,name,faction,size)
	if station == nil then
		return nil
	end
--	station.comms_data.system_repair = {}
--	station.comms_data.coolant_pump_repair = {}
	local station_name = station:getCallSign()
	local chosen_goods = random(1,100)
	if station_name == "Grasberg" or station_name == "Impala" or station_name == "Outpost-15" or station_name == "Outpost-21" then
		placeRandomAsteroidsAroundPoint(15,1,15000,x,y)
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
		createRandomAsteroidAlongArc(30+posKrakEnd, x+xPosAngleKrak, y+yPosAngleKrak, posKrak, negAxisKrak, negAxisKrak+posKrakEnd, spreadKrak)
		local xNegAngleKrak, yNegAngleKrak = vectorFromAngle(negAxisKrak, negKrak)
		createRandomAsteroidAlongArc(30+negKrakEnd, x+xNegAngleKrak, y+yNegAngleKrak, negKrak, posAxisKrak, posAxisKrak+negKrakEnd, spreadKrak)
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
	local radialPoint = 0
	if amount > arcLen then
		for ndex=1,arcLen do
			radialPoint = startArc+ndex
			for i=1,3 do
				local pointDist = distance + random(-randomize,randomize)
				asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
				if i == 1 then
					Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				else
					VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				end
			end
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			for i=1,3 do
				pointDist = distance + random(-randomize,randomize)
				asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
				if i == 1 then
					Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				else
					VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				end
			end
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			for i=1,3 do
				pointDist = distance + random(-randomize,randomize)
				asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
				if i == 1 then
					Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				else
					VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
				end
			end
		end
	end
end
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
    	for i=1,3 do
			local r = random(0, 360)
			local distance = random(dist_min, dist_max)
			x = x0 + math.cos(r / 180 * math.pi) * distance
			y = y0 + math.sin(r / 180 * math.pi) * distance
			local asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			if i == 1 then
				Asteroid():setPosition(x, y):setSize(asteroid_size)
			else
				VisualAsteroid():setPosition(x,y):setSize(asteroid_size)
			end
		end
    end
end
function randomStation()
	local clean_list = true
	local clean_count = 0
	repeat
		for i,station in ipairs(stationList) do
			if not station:isValid() then
				stationList[i] = stationList[#stationList]
				stationList[#stationList] = nil
				clean_list = false
				break
			end
		end
		clean_count = clean_count + 1
	until(clean_list or clean_count > max_repeat_loop)
	if clean_count > max_repeat_loop then
		print("exceeded max repeat loop in randomStation function")
	end
	return tableSelectRandom(stationList)
end
function nearStations(obj, compareStationList)
	local remaining_stations = {}	
	local clean_list = true
	local clean_count = 0
	repeat
		for i,station in ipairs(compareStationList) do
			if not station:isValid() then
				compareStationList[i] = compareStationList[#compareStationList]
				compareStationList[#compareStationList] = nil
				clean_list = false
				break
			end
		end
		clean_count = clean_count + 1
	until(clean_list or clean_count > max_repeat_loop)
	if clean_count > max_repeat_loop then
		print("exceeded max repeat loop in nearStations function")
	end
	local closest = compareStationList[1]
	for i,station in ipairs(compareStationList) do
		if station ~= obj then
			table.insert(remaining_stations,station)
			if distance(station,obj) < distance(obj,closest) then
				closest = station
			end
		end
	end
	for i,station in ipairs(remaining_stations) do
		if station == closest then
			remaining_stations[i] = remaining_stations[#remaining_stations]
			remaining_stations[#remaining_stations] = nil
			break
		end
	end
	return closest, remaining_stations
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
	return tableSelectRandom(distanceStations)
end
function goodsOnShip(comms_target)
	if comms_target.comms_data == nil then
		comms_target.comms_data = {}
	end
	comms_target.comms_data.goods = {}
	comms_target.comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
			local count_repeat_loop = 0
			repeat
				comms_target.comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
				local goodCount = 0
				for good, goodData in pairs(comms_target.comms_data.goods) do
					goodCount = goodCount + 1
				end
				count_repeat_loop = count_repeat_loop + 1
			until(goodCount >= 3 or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times when setting up goods for freighter")
			end
		end
	end
end
function transportPlot()
	if transport_spawn_time == nil then
		transport_spawn_time = getScenarioTime() + transportSpawnDelay + random(5,45)
	end
	if getScenarioTime() > transport_spawn_time then
		transport_spawn_time = nil
		local clean_list = true
		local clean_count = 0
		repeat
			for i, obj in ipairs(transportList) do
				if obj:isValid() then
					if obj:isDocked(obj.target) then
						if obj.undock_time == nil then
							obj.undock_time = getScenarioTime() + random(15,45)
						end
						if getScenarioTime() > obj.undock_time then
							obj.undock_time = nil
							obj.target = randomNearStation5(obj)
							obj:orderDock(obj.target)
						end
					end
				else
					transportList[i] = transportList[#transportList]
					transportList[#transportList] = nil
					clean_list = false
					break
				end
			end
			clean_count = clean_count + 1
		until(clean_list or clean_count > max_repeat_loop)
		if clean_count > max_repeat_loop then
			print("exceeded max repeat loop when check for clean list in transportPlot function")
		end
		if clean_list and #transportList < #stationList then
			local target = randomStation()
			local transport_types = {"Personnel","Goods","Garbage","Equipment","Fuel"}
			local name = tableSelectRandom(transport_types)
			if random(1,100) < 30 then
				name = name .. " Jump Freighter " .. math.random(3, 5)
			else
				name = name .. " Freighter " .. math.random(1, 5)
			end
			local transport_faction = tableSelectRandom(transport_factions)
			local transport = CpuShip():setTemplate(name):setFaction(transport_faction):setCommsFunction(commsShip):setCallSign(generateCallSign(nil,transport_faction))
			goodsOnShip(transport)
			local enemy_count = 0
			repeat
				target = randomStation()
				enemy_count = enemy_count + 1
			until(not target:isEnemy(transport) or enemy_count > max_repeat_loop)
			if enemy_count > max_repeat_loop then
				print("exceeded max repeat loop when picking random station in transportPlot function")
			end
			transport.target = target
			transport:orderDock(transport.target)
			local tx, ty = transport.target:getPosition()
			local ox, oy = vectorFromAngle(random(0,360),random(25000,40000),true)
			transport:setPosition(tx + ox, ty + oy)
			table.insert(transportList,transport)
		end
	end
end
function friendlyDefense()
	for i,station in ipairs(stationList) do
		if station ~= nil and station:isValid() then
			if station:areEnemiesInRange(10000) then
				if station.defense_fleet == nil then
					local fx, fy = station:getPosition()
					local fleet = spawnEnemies(fx,fy,1,station:getFaction())
					for i,ship in ipairs(fleet) do
						ship:orderDefendTarget(station):setCommsFunction(commsDefendShip)
						ship.my_station = station
						if ship:isFriendly(getPlayerShip(-1)) then
							ship:setScanStateByFaction("Human Navy","simplescan")
						end
					end
					station.defense_fleet = fleet
				else
					if #station.defense_fleet > 0 then
						for j,ship in ipairs(station.defense_fleet) do
							if ship ~= nil and ship:isValid() then
								if ship.self_preservation_decision_time == nil then
									ship.self_preservation_decision_time = getScenarioTime() + random(4,9)
								end
								if getScenarioTime() > ship.self_preservation_decision_time then
									ship.self_preservation_decision_time = nil
									if ship.my_station ~= nil and ship.my_station:isValid() then
										local function shipHealthy(ship)
											if ship:getHull() < ship:getHullMax() then return false end
											if ship:getSystemHealth("reactor") <  ship:getSystemHealthMax("reactor")  then return false end
											if ship:getSystemHealth("impulse") <  ship:getSystemHealthMax("impulse")  then return false end
											if ship:getSystemHealth("maneuver") < ship:getSystemHealthMax("maneuver") then return false end
											if ship:getBeamWeaponRange(0) > 0 then
												if ship:getSystemHealth("beamweapons") <  ship:getSystemHealthMax("beamweapons") then return false end
											end
											if ship:getWeaponTubeCount() > 0 then
												if ship:getSystemHealth("missilesystem") <  ship:getSystemHealthMax("missilesystem") then return false end
											end
											if ship:hasWarpDrive() then
												if ship:getSystemHealth("warp") <  ship:getSystemHealthMax("warp") then return false end
											end
											if ship:hasJumpDrive() then
												if ship:getSystemHealth("jumpdrive") <  ship:getSystemHealthMax("jumpdrive") then return false end
											end
											if ship:getShieldCount() > 0 then
												if ship:getSystemHealth("frontshield") <  ship:getSystemHealthMax("frontshield") then return false end
											end
											if ship:getShieldCount() > 1 then
												if ship:getSystemHealth("rearshield") <  ship:getSystemHealthMax("rearshield") then return false end
											end
											return true
										end
										local function shipFull(ship)
											if ship:getWeaponTubeCount() > 0 then
												if ship:getWeaponStorage("Homing") < ship:getWeaponStorageMax("Homing") then return false end
												if ship:getWeaponStorage("HVLI") <   ship:getWeaponStorageMax("HVLI") then return false end
												if ship:getWeaponStorage("EMP") <    ship:getWeaponStorageMax("EMP") then return false end
												if ship:getWeaponStorage("Nuke") <   ship:getWeaponStorageMax("Nuke") then return false end
											end
											return true
										end
										local ship_healthy = shipHealthy(ship)
										local ship_full = shipFull(ship)
										if ship:isDocked(ship.my_station) then
											if ship.my_station:areEnemiesInRange(10000) then
												ship:orderDefendTarget(ship.my_station)
											else
												if ship_healthy and ship_full then
													ship:orderDefendTarget(ship.my_station)
												end
											end
										else
											if ship.my_station:areEnemiesInRange(10000) then
												if ship:getOrder() ~= "Defend Target" then
													ship:orderDefendTarget(ship.my_station)
												end
											else
												if not ship_healthy then
													if ship:getOrder() ~= "Dock" then
														ship:orderDock(ship.my_station)
													end
												else
													if not ship_full then
														if not ship.my_station:areEnemiesInRange(15000) then
															if ship:getOrder() ~= "Dock" then
																ship:orderDock(ship.my_station)
															end
														end
													end
												end
											end
										end
									end
								end
							else	--ship destroyed
								station.defense_fleet[j] = station.defense_fleet[#station.defense_fleet]
								station.defense_fleet[#station.defense_fleet] = nil
								break
							end
						end
					else	--defense fleet spent
						if station.respawn_defense_fleet_time == nil then
							station.respawn_defense_fleet_time = getScenarioTime() + 120 + random(1,60)
						end
						if getScenarioTime() > station.respawn_defense_fleet_time then
							station.respawn_defense_fleet_time = nil
							station.defense_fleet = nil
						end
					end
				end
			end
		else	--station destroyed
			stationList[i] = stationList[#stationList]
			stationList[#stationList] = nil
			break
		end
	end
end
--	Station communication
function availableForComms(p)
	if not p:isCommsInactive() then
		return false
	end
	if p:isCommsOpening() then
		return false
	end
	if p:isCommsBeingHailed() then
		return false
	end
	if p:isCommsBeingHailedByGM() then
		return false
	end
	if p:isCommsChatOpen() then
		return false
	end
	if p:isCommsChatOpenToGM() then
		return false
	end
	if p:isCommsChatOpenToPlayer() then
		return
	end
	if p:isCommsScriptOpen() then
		return false
	end
	return true
end
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
	setPlayers()
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
function respawnFighter1()
	if fighter_template == "Formax" then
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Striker"):setJumpDrive(false):setWarpDrive(false)
		playerBlade:setTypeName("Formax")
		playerBlade:setImpulseMaxSpeed(90)
		playerBlade:setBeamWeaponTurret(0,60,-15,2)			-- 60: narrower than default 100, 
		playerBlade:setBeamWeaponTurret(1,60, 15,2)			-- 2: slower than default 6
		playerBlade:setWeaponTubeCount(2)
		playerBlade:setWeaponTubeDirection(0,  0):setTubeLoadTime(0,10):setWeaponTubeExclusiveFor(0,"HVLI"):setTubeSize(0,"small")
		playerBlade:setWeaponTubeDirection(1,180):setTubeLoadTime(1,15):setWeaponTubeExclusiveFor(1,"Mine")
		playerBlade:setWeaponStorageMax("HVLI",9):setWeaponStorage("HVLI",9)
		playerBlade:setWeaponStorageMax("Mine",3):setWeaponStorage("Mine",3)
	elseif fighter_template == "Foil" then
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Striker"):setJumpDrive(false):setWarpDrive(false)
		playerBlade:setTypeName("Foil")
		playerBlade:setImpulseMaxSpeed(95)
		playerBlade:setBeamWeaponTurret(0,60,-15,2)			-- 60: narrower than default 100, 
		playerBlade:setBeamWeaponTurret(1,60, 15,2)			-- 2: slower than default 6
		playerBlade:setBeamWeapon(2,20,0,1200,6,5)	
		playerBlade:setRepairCrewCount(4)
		playerBlade:setWeaponTubeCount(1)
		playerBlade:setWeaponTubeDirection(0,180):setTubeLoadTime(1,20):setWeaponTubeExclusiveFor(0,"Mine")
		playerBlade:setWeaponStorageMax("Mine",1):setWeaponStorage("Mine",1)
	else
		playerBlade = PlayerSpaceship():setFaction("Human Navy"):setTemplate(fighter_template):setJumpDrive(false):setWarpDrive(false)
	end
	local respawn_x, respawn_y = comms_target:getPosition()
	playerBlade:setPosition(respawn_x, respawn_y)
	playerBlade:setLongRangeRadarRange(10000):setAutoCoolant(true):commandSetAutoRepair(true)
	playerBlade.normal_long_range_radar = 10000
	playerBlade:addCustomButton("Tactical","shield",_("buttonTactical","Shield"),function()
		if playerBlade:getShieldsActive() then
			playerBlade:commandSetShields(false)
		else
			playerBlade:commandSetShields(true)
		end
	end)
	if fighter_template == "Striker" then
		playerBlade:setImpulseMaxSpeed(90)
	end
end
function respawnFighter2()
	if fighter_template_2 == "Red Jacket" then
		playerPoint = PlayerSpaceship():setFaction("Human Navy"):setTemplate("MP52 Hornet"):setJumpDrive(false):setWarpDrive(false)
		playerPoint:setTypeName("Red Jacket")
		playerPoint:setImpulseMaxSpeed(100)
		playerPoint:setWeaponTubeCount(1)
		playerPoint:setWeaponTubeDirection(0,180):setTubeLoadTime(0,20):setWeaponTubeExclusiveFor(0,"Mine")
		playerPoint:setWeaponStorageMax("Mine",1):setWeaponStorage("Mine",1)
	else
		playerPoint = PlayerSpaceship():setFaction("Human Navy"):setTemplate(fighter_template_2):setJumpDrive(false):setWarpDrive(false)
	end
	local respawn_x, respawn_y = comms_target:getPosition()
	playerPoint:setPosition(respawn_x, respawn_y)
	playerPoint:setLongRangeRadarRange(10000):setAutoCoolant(true):commandSetAutoRepair(true)
	playerPoint.normal_long_range_radar = 10000
	playerPoint:addCustomButton("Tactical","shield",_("buttonTactical","Shield"),function()
		if playerPoint:getShieldsActive() then
			playerPoint:commandSetShields(false)
		else
			playerPoint:commandSetShields(true)
		end
	end)
end
function respawnCarrier()
	playerCarrier = PlayerSpaceship():setFaction("Human Navy"):setTemplate(carrier_template)
	local respawn_x, respawn_y = comms_target:getPosition()
	playerCarrier:setPosition(respawn_x, respawn_y):setRepairDocked(true)
end
function handleDockedState()
    if comms_source:isFriendly(comms_target) then
		oMsg = _("station-comms", "Good day, officer!\nWhat can we do for you today?\n")
    else
		oMsg = _("station-comms", "Welcome to our lovely station.\n")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "Forgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
	end
	setCommsMessage(oMsg)
	missilePresence = 0
	for idx, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		addCommsReply(_("ammo-comms", "I need ordnance restocked"), function()
			setCommsMessage(_("ammo-comms", "What type of ordnance?"))
			for idx, missile_type in ipairs(missile_types) do
				if comms_source:getWeaponStorageMax(missile_type) > 0 then
					addCommsReply(string.format(_("ammo-comms", "%s (%d rep each)"), missile_type, getWeaponCost(missile_type)), function()
						handleWeaponRestock(missile_type)
					end)
				end
			end
		end)
	end
	if comms_source == playerCarrier then
		if not playerBlade:isValid() then
			local replacement_cost = 250
			if comms_source:isFriendly(comms_target) then
				replacement_cost = 200
				if homeStation:isValid() and comms_target == homeStation then
					replacement_cost = 150
				end
			end
			addCommsReply(string.format(_("station-comms","Get replacement %s fighter (%i reputation)"),fighter_template,replacement_cost),function()
				if comms_source:takeReputationPoints(replacement_cost) then
					respawnFighter1()
					setPlayers()
					setCommsMessage(_("station-comms","A replacement fighter has been provided"))
				else
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				end
			end)
		end
		if not playerPoint:isValid() then
			local replacement_cost = 250
			if comms_source:isFriendly(comms_target) then
				replacement_cost = 200
				if homeStation:isValid() and comms_target == homeStation then
					replacement_cost = 150
				end
			end
			addCommsReply(string.format(_("station-comms","Get replacement %s fighter (%i reputation)"),fighter_template_2,replacement_cost),function()
				if comms_source:takeReputationPoints(replacement_cost) then
					respawnFighter2()
					setPlayers()
					setCommsMessage(_("station-comms","A replacement fighter has been provided"))
				else
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				end
			end)
		end
	end
	if comms_source == playerBlade or comms_source == playerPoint then
		if not playerCarrier:isValid() then
			local replacement_cost = 350
			if comms_source:isFriendly(comms_target) then
				replacement_cost = 300
				if homeStation:isValid() and comms_target == homeStation then
					replacement_cost = 250
				end
			end
			addCommsReply(string.format(_("station-comms","Get replacement %s carrier (%i reputation)"),carrier_template,replacement_cost),function()
				if comms_source:takeReputationPoints(replacement_cost) then
					respawnCarrier()
					setPlayers()
					setComsMessage(_("station-comms","A replacement carrier has been provided"))
				else
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				end
			end)
		end
	end
	if comms_source:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		if random(1,5) <= (3 - difficulty) then
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage(_("trade-comms", "Repair crew member hired"))
				end
			end)
		end
	else
		if random(1,5) <= (3 - difficulty) then
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(45,90)
			else
				hireCost = math.random(60,120)
			end
			addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage(_("needRep-comms", "Insufficient reputation"))
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					setCommsMessage(_("trade-comms", "Repair crew member hired"))
				end
			end)
		end
	end
	commsMissionChanges()
	if comms_target.publicRelations then
		addCommsReply(_("station-comms", "Tell me more about your station"), function()
			setCommsMessage(_("station-comms", "What would you like to know?"))
			addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply(_("Back"), commsStation)
			end)
			if comms_target.stationHistory ~= nil then
				addCommsReply(_("stationStory-comms", "Station history"), function()
					setCommsMessage(comms_target.stationHistory)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if comms_target.gossip ~= nil then
					if random(1,100) < 50 then
						addCommsReply(_("gossip-comms", "Gossip"), function()
							setCommsMessage(comms_target.gossip)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
		end)
	end
	local goodCount = 0
	if comms_target.comms_data.goods ~= nil then
		for good, goodData in pairs(comms_target.comms_data.goods) do
			if goodData.quantity > 0 then
				goodCount = goodCount + 1
			end
		end
	end
	if goodCount > 0 then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			local oMsg = string.format(_("forSaleTrade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
			for good,good_data in pairs(comms_target.comms_data.goods) do
				oMsg = string.format(_("forSaleTrade-comms","%s\n     %s: %i, %i"),oMsg,good_desc[good],good_data.quantity,good_data.cost)
			end
			oMsg = string.format(_("onBoardTrade-comms","%s\nCurrent Cargo:"),oMsg)
			local cargo_hold_empty = true
			if comms_source.goods ~= nil then
				for good,quantity in pairs(comms_source.goods) do
					if quantity > 0 then
						cargo_hold_empty = false
						oMsg = string.format(_("onBoardTrade-comms","%s\n     %s: %s"),oMsg,good_desc[good],quantity)
					end
				end
			end
			if cargo_hold_empty then
				oMsg = string.format(_("onBoardTrade-comms","%s\n     Empty"),oMsg)
			end
			local playerRep = math.floor(comms_source:getReputationPoints())
			oMsg = string.format(_("trade-comms", "%s\nAvailable Space: %i, Available Reputation: %i\n"),oMsg,comms_source.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			for good,good_data in pairs(comms_target.comms_data.goods) do
				if good_data.quantity > 0 then
					addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],good_data.cost),function()
						local oMsg = string.format(_("trade-comms","Type: %s, Quantity: %i, Reputation: %i"),good_desc[good],good_data.quantity,good_data.cost)
						if comms_source.cargo < 1 then
							oMsg = string.format(_("trade-comms","%s\nInsufficient cargo space for purchase"),oMsg)
						elseif good_data.cost > playerRep then
							oMsg = string.format(_("trade-comms","%s\nInsufficient reputation for purchase"),oMsg)
						elseif good_data.quantity < 1 then
							oMsg = string.format(_("trade-comms","%s\nInsufficient station inventory"),oMsg)
						else
							if comms_source:takeReputationPoints(good_data.cost) then
								comms_source.cargo = comms_source.cargo - 1
								good_data["quantity"] = good_data["quantity"] - 1
								if comms_source.goods == nil then
									comms_source.goods = {}
								end
								if comms_source.goods[good] == nil then
									comms_source.goods[good] = 0
								end
								comms_source.goods[good] = comms_source.goods[good] + 1
								oMsg = string.format(_("trade-comms","%s\nOne %s purchased"),oMsg,good_desc[good])
							else
								oMsg = string.format(_("trade-comms","%s\nInsufficient reputation for purchase"),oMsg)
							end
						end
						setCommsMessage(oMsg)
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.trade ~= nil and comms_target.comms_data.trade.food ~= nil and comms_target.comms_data.trade.food and comms_source.goods ~= nil and comms_source.goods.food ~= nil and comms_source.goods.food > 0 then
				for good,good_data in pairs(comms_target.comms_data.goods) do
					if good_data.quantity > 0 then
						addCommsReply(string.format(_("trade-comms","Trade food for %s"),good_desc[good]),function()
							local oMsg = string.format(_("trade-comms","Type: %s, Quantity: %i"),good_desc[good],good_data.quantity)
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["food"] = comms_source.goods["food"] - 1
							oMsg = string.format(_("trade-comms","%s\nTraded one %s for one %s"),oMsg,good_desc["food"],good_desc[good])
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			if comms_target.comms_data.trade ~= nil and comms_target.comms_data.trade.luxury ~= nil and comms_target.comms_data.trade.luxury and comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
				for good,good_data in pairs(comms_target.comms_data.goods) do
					if good_data.quantity > 0 then
						addCommsReply(string.format(_("trade-comms","Trade luxury for %s"),good_desc[good]),function()
							local oMsg = string.format(_("trade-comms","Type: %s, Quantity: %i"),good_desc[good],good_data.quantity)
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
							oMsg = string.format(_("trade-comms","%s\nTraded one %s for one %s"),oMsg,good_desc["luxury"],good_desc[good])
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			if comms_target.comms_data.trade ~= nil and comms_target.comms_data.trade.medicine ~= nil and comms_target.comms_data.trade.medicine and comms_source.goods ~= nil and comms_source.goods.medicine ~= nil and comms_source.goods.medicine > 0 then
				for good,good_data in pairs(comms_target.comms_data.goods) do
					if good_data.quantity > 0 then
						addCommsReply(string.format(_("trade-comms","Trade medicine for %s"),good_desc[good]),function()
							local oMsg = string.format(_("trade-comms","Type: %s, Quantity: %i"),good_desc[good],good_data.quantity)
							if comms_source.goods[good] == nil then
								comms_source.goods[good] = 0
							end
							comms_source.goods[good] = comms_source.goods[good] + 1
							comms_source.goods["medicine"] = comms_source.goods["medicine"] - 1
							oMsg = string.format(_("trade-comms","%s\nTraded one %s for one %s"),oMsg,good_desc["medicine"],good_desc[good])
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		local cargo_hold_empty = true
		if comms_source.goods ~= nil then
			for good,quantity in pairs(comms_source.goods) do
				if quantity > 0 then
					cargo_hold_empty = false
				end
			end
		end
		if not cargo_hold_empty then
			addCommsReply(_("trade-comms","Jettison cargo"),function()
				string.format("")
				setCommsMessage(string.format(_("trade-comms","Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
				for good,quantity in pairs(comms_source.goods) do
					if quantity > 0 then
						addCommsReply(good_desc[good],function()
							string.format("")
							quantity = quantity - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format(_("trade-comms","One %s jettisoned"),good_desc[good]))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end)
			for i,p in ipairs(getActivePlayerShips()) do
				if p == comms_target and comms_source:isDocked(p) and p.cargo > 0 then
					addCommsReply(string.format(_("trade-comms","Transfer cargo to %s"),p:getCallSign()),function()
						setCommsMessage(_("trade-comms","What would you like to transfer?"))
						for good,quantity in pairs(comms_source.goods) do
							if quantity > 0 then
								addCommsReply(good_desc[good],function()
									quantity = quantity - 1
									if p.goods == nil then
										p.goods = {}
									end
									if p.goods[good] == nil then
										p.goods[good] = 0
									end
									p.goods[good] = p.goods[good] + 1
									p.cargo = p.cargo - 1
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(string.format(_("trade-comms","One %s transferred to %s"),good_desc[good],p:getCallSign()))
									p:addToShipLog(string.format(_("trade-comms","One %s transferred from %s"),good_desc[good],comms_source:getCallSign()),"#228b22")
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
					end)
					break
				end
			end
		end
	end
end
function setOptionalOrders()
	optionalOrders = "\n"
	ifs = _("orders-comms","Optional:\n")
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
		setCommsMessage(_("station-comms", "You need to stay docked for that action."))
		return
	end
    if not isAllowedTo(comms_target.comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms", "We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms", "All nukes are charged and primed for destruction."));
        else
            setCommsMessage(_("ammo-comms", "Sorry, sir, but you are as fully stocked as I can allow."));
        end
        addCommsReply(_("Back"), commsStation)
    else
        if not comms_source:takeReputationPoints(points_per_item * item_amount) then
            setCommsMessage(_("needRep-comms", "Not enough reputation."))
            return
        end
        comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
        if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
        else
            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
        end
        addCommsReply(_("Back"), commsStation)
    end
end
function getWeaponCost(weapon)
    return math.ceil(comms_target.comms_data.weapon_cost[weapon] * comms_target.comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = string.format(_("station-comms", "%s\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."),oMsg)
	end
	setCommsMessage(oMsg)
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		goodsQuantityAvailable = 0
		if comms_target.comms_data.goods ~= nil then
			for good,good_data in pairs(comms_target.comms_data.goods) do
				if good_data.quantity > 0 then
					goodsQuantityAvailable = goodsQuantityAvailable + 1
					break
				end
			end
		end
		if goodsQuantityAvailable > 0 then
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				local oMsg = string.format(_("forSaleTrade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
				for good,good_data in pairs(comms_target.comms_data.goods) do
					if good_data.quantity > 0 then
						oMsg = string.format(_("forSaleTrade-comms","%s\n  %s: %i, %i"),oMsg,good_desc[good],good_data.quantity,good_data.cost) 
					end
				end
				setCommsMessage(oMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("helpfullWarning-comms", "See any enemies in your area?"), function()
			if comms_source:isFriendly(comms_target) then
				enemiesInRange = 0
				for idx, obj in ipairs(comms_target:getObjectsInRange(30000)) do
					if obj:isEnemy(comms_source) then
						enemiesInRange = enemiesInRange + 1
					end
				end
				if enemiesInRange > 0 then
					if enemiesInRange > 1 then
						setCommsMessage(string.format(_("helpfullWarning-comms", "Yes, we see %i enemies within 30U"),enemiesInRange))
					else
						setCommsMessage(_("helpfullWarning-comms", "Yes, we see one enemy within 30U"))						
					end
					comms_source:addReputationPoints(2)					
				else
					setCommsMessage(_("helpfullWarning-comms", "No enemies within 30U"))
					comms_source:addReputationPoints(1)
				end
				addCommsReply(_("Back"), commsStation)
			else
				setCommsMessage(_("helpfullWarning-comms", "Not really"))
				comms_source:addReputationPoints(1)
				addCommsReply(_("Back"), commsStation)
			end
		end)
		addCommsReply(_("trade-comms", "Where can I find particular goods?"), function()
			gkMsg = _("trade-comms", "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
			if comms_target.comms_data.goodsKnowledge == nil then
				comms_target.comms_data.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i,station in ipairs(stationList) do
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
						if station.comms_data.goods ~= nil then
							for good, goodData in pairs(station.comms_data.goods) do
								if random(1,100) <= brainCheckChance then
									local stationCallSign = station:getCallSign()
									local stationSector = station:getSectorName()
									comms_target.comms_data.goodsKnowledge[good] =	{	station = stationCallSign,
																	sector = stationSector,
																	cost = goodData["cost"] }
									knowledgeCount = knowledgeCount + 1
									if knowledgeCount >= knowledgeMax then
										break
									end
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
			for good, goodKnowledge in pairs(comms_target.comms_data.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good_desc[good], function()
					local stationName = comms_target.comms_data.goodsKnowledge[good]["station"]
					local sectorName = comms_target.comms_data.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = comms_target.comms_data.goodsKnowledge[good]["cost"]
					setCommsMessage(string.format(_("trade-comms", "Station %s in sector %s has %s for %i reputation"),stationName,sectorName,good_desc[goodName],goodCost))
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if goodsKnowledgeCount > 0 then
				gkMsg = string.format(_("trade-comms", "%s\n\nWhat goods are you interested in?\nI've heard about these:"),gkMsg)
			else
				gkMsg = string.format(_("trade-comms", "%s Beyond that, I have no knowledge of specific stations"),gkMsg)
			end
			setCommsMessage(gkMsg)
			addCommsReply(_("Back"), commsStation)
		end)		
		if comms_target.publicRelations then
			addCommsReply(_("stationGeneralInfo-comms", "General station information"), function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end)
	if comms_source:isFriendly(comms_target) then
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			ordMsg = primaryOrders .. "\n" .. secondaryOrders .. optionalOrders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	commsMissionChanges()
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format("Time remaining: %.2f",gameTimeLimit)
			else
				oMsg = oMsg .. " no time limit"
			end
			oMsg = oMsg .. string.format("\nBase transport spawn delay: %i",transportSpawnDelay)
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
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost("supplydrop")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"),n), function()
                        if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = comms_source:getWaypoint(n)
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
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request reinforcements."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we dispatch the reinforcements?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"),n), function()
                        if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"),ship:getCallSign(),n))
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
	cargoHoldEmpty = true
	if comms_source.goods ~= nil then
		for good,quantity in pairs(comms_source.goods) do
			if quantity > 0 then
				cargoHoldEmpty = false
				break
			end
		end
	end
	if not cargoHoldEmpty then
		addCommsReply(_("trade-comms", "Jettison cargo"), function()
			setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
			for good,quantity in pairs(comms_source.goods) do
				if quantity > 0 then
					addCommsReply(good_desc[good],function()
						quantity = quantity - 1
						comms_source.cargo = comms_source.cargo + 1
						setCommsMessage(_("trade-comms","One %s jettisoned"),good_desc[good])
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		for i,p in ipairs(getActivePlayerShips()) do
			if p == comms_target and distance(p,comms_source) < 1500 and p.cargo > 0 then
				addCommsReply(string.format(_("trade-comms","Transfer cargo to %s"),p:getCallSign()),function()
					setCommsMessage(_("trade-comms","What would you like to transfer?"))
					for good,quantity in pairs(comms_source.goods) do
						if quantity > 0 then
							addCommsReply(good_desc[good],function()
								quantity = quantity - 1
								if p.goods == nil then
									p.goods = {}
								end
								if p.goods[good] == nil then
									p.goods[good] = 0
								end
								p.goods[good] = p.goods[good] + 1
								p.cargo = p.cargo - 1
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(string.format(_("trade-comms","One %s transferred to %s"),good_desc[good],p:getCallSign()))
								p:addToShipLog(string.format(_("trade-comms","One %s transferred from %s"),good_desc[good],comms_source:getCallSign()),"#228b22")
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end)
				break
			end
		end		
	end
end
function commsMissionChanges()
	if plot3name == "awaitingTractor" then
		if comms_target == tractorStation and comms_source == playerCarrier and distance(comms_source,comms_target) < 2000 then
			addCommsReply(_("upgrade-comms","Install tractor equipment"), function()
				if playerCarrier:hasPlayerAtPosition("Engineering") then
					tractorIntegrationMsg = "tractorIntegrationMsg"
					playerCarrier:addCustomMessage("Engineering",tractorIntegrationMsg,string.format(_("-msgEngineer", "The tractor equipment has been transported aboard %s. You need to make the final connections for full installation"),playerCarrier:getCallSign()))
				end
				if playerCarrier:hasPlayerAtPosition("Engineering+") then
					tractorIntegrationMsgPlus = "tractorIntegrationMsgPlus"
					playerCarrier:addCustomMessage("Engineering+",tractorIntegrationMsgPlus,string.format(_("-msgEngineer+", "The tractor equipment has been transported aboard %s. You need to make the final connections for full installation"),playerCarrier:getCallSign()))
				end
				mission_milestones = mission_milestones + 1
				tractorIntegrationButton = "tractorIntegrationButton"
				playerCarrier:addCustomButton("Engineering",tractorIntegrationButton,_("-buttonEngineer", "Connect Tractor"),connectTractor)
				tractorIntegrationButtonPlus = "tractorIntegrationButtonPlus"
				playerCarrier:addCustomButton("Engineering+",tractorIntegrationButtonPlus,_("-buttonEngineer+", "Connect Tractor"),connectTractor)
				setCommsMessage(_("upgrade-comms","Tractor equipment transferred to engine room"))
			end)
		end
	end
	if plot3name == "tubeOfficer" then
		if comms_target == addTubeStation and distance(comms_source,comms_target) < 1500 then
			tubePartQuantity = 0
			if comms_source.goods ~= nil then
				for good,quantity in pairs(comms_source.goods) do
					if good == tubePart then
						tubePartQuantity = quantity
					end
				end
			end
			if tubePartQuantity > 0 then
				addCommsReply(string.format(_("upgrade-comms","Give %s to Boris Eggleston for additional tube"),good_desc[tubePart]), function()
					if comms_source.tubeAdded then
						setCommsMessage(_("upgrade-comms","You already have the extra tube"))
					else
						setCommsMessage(_("upgrade-comms","I can install it point to the front or to the rear. Which would you prefer?"))
						addCommsReply(_("upgrade-comms","Front"), function()
							comms_source.goods[tubePart] = comms_source.goods[tubePart] - 1
							comms_source.cargo = comms_source.cargo + 1
							comms_source.tubeAdded = true
							originalTubes = comms_source:getWeaponTubeCount()
							newTubes = originalTubes + 1
							comms_source:setWeaponTubeCount(newTubes)
							comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
							comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
							setCommsMessage(_("upgrade-comms","You now have an additional homing torpedo tube pointing forward"))
							mission_milestones = mission_milestones + 1
							local tube_count = comms_source:getWeaponTubeCount()
							if tube_count > 0 then
								comms_source.tube_size = ""
								for i=1,tube_count do
									local tube_size = comms_source:getTubeSize(i-1)
									if tube_size == "small" then
										comms_source.tube_size = comms_source.tube_size .. "S"
									end
									if tube_size == "medium" then
										comms_source.tube_size = comms_source.tube_size .. "M"
									end
									if tube_size == "large" then
										comms_source.tube_size = p.tube_size .. "L"
									end
								end
							end
						end)
						addCommsReply(_("upgrade-comms","Rear"), function()
							comms_source.goods[tubePart] = comms_source.goods[tubePart] - 1
							comms_source.cargo = comms_source.cargo + 1
							comms_source.tubeAdded = true
							originalTubes = comms_source:getWeaponTubeCount()
							newTubes = originalTubes + 1
							comms_source:setWeaponTubeCount(newTubes)
							comms_source:setWeaponTubeExclusiveFor(originalTubes, "Homing")
							comms_source:setWeaponStorageMax("Homing", comms_source:getWeaponStorageMax("Homing") + 2)
							comms_source:setWeaponStorage("Homing", comms_source:getWeaponStorage("Homing") + 2)
							comms_source:setWeaponTubeDirection(originalTubes, 180)
							setCommsMessage(_("upgrade-comms","You now have an additional homing torpedo tube pointing to the rear"))
							mission_milestones = mission_milestones + 1
							local tube_count = comms_source:getWeaponTubeCount()
							if tube_count > 0 then
								comms_source.tube_size = ""
								for i=1,tube_count do
									local tube_size = comms_source:getTubeSize(i-1)
									if tube_size == "small" then
										comms_source.tube_size = comms_source.tube_size .. "S"
									end
									if tube_size == "medium" then
										comms_source.tube_size = comms_source.tube_size .. "M"
									end
									if tube_size == "large" then
										comms_source.tube_size = p.tube_size .. "L"
									end
								end
							end
						end)
					end
				end)
			else
				addCommsReply(_("upgrade-comms","May I speak with Boris Eggleston?"), function()
					setCommsMessage(_("upgrade-comms","[Boris Eggleston]\nHello, what can I do for you?"))
					addCommsReply(_("upgrade-comms","Can you really add another weapons tube to our ship?"), function()
						setCommsMessage(string.format(_("upgrade-comms","Definitely. But I'll need %s before I can do it"),good_desc[tubePart]))
						addCommsReply(_("Back"),commsStation)
					end)
				end)
			end
		end
	end
	if plot3name == "beamPhysicist" then
		if comms_target == beamDamageStation and distance(comms_source,comms_target) < 1500 then
			beamPart1Quantity = 0
			beamPart2Quantity = 0
			if comms_source.goods ~= nil then
				for good,quantity in pairs(comms_source.goods) do
					if good == beamPart1 then
						beamPart1Quantity = quantity
					end
					if good == beamPart2 then
						beamPart2Quantity = quantity
					end
				end
			end
			if beamPart1Quantity > 0 and beamPart2Quantity > 0 then
				addCommsReply(string.format(_("upgrade-comms","Give %s and %s to Frederico Booker for upgrade"),good_desc[beamPart1],good_desc[beamPart2]), function()
					if comms_source.beamDamageUpgrade then
						setCommsMessage(_("upgrade-comms","You already have the upgrade"))
					else
						if comms_source:getBeamWeaponRange(0) > 0 then
							comms_source.goods[beamPart1] = comms_source.goods[beamPart1] - 1
							comms_source.goods[beamPart2] = comms_source.goods[beamPart2] - 1
							comms_source.cargo = comms_source.cargo + 2
							bi = 0	--beam index
							repeat
								tempArc = comms_source:getBeamWeaponArc(bi)
								tempDir = comms_source:getBeamWeaponDirection(bi)
								tempRng = comms_source:getBeamWeaponRange(bi)
								tempCyc = comms_source:getBeamWeaponCycleTime(bi)
								tempDmg = comms_source:getBeamWeaponDamage(bi)
								comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.5)
								bi = bi + 1
							until(comms_source:getBeamWeaponRange(bi) < 1)
							comms_source.beamDamageUpgrade = true
							setCommsMessage(_("upgrade-comms","Your ship beam weapons now deal 50% more damage"))
							mission_milestones = mission_milestones + 1
						else
							setCommsMessage(_("upgrade-comms","Your ship has no beam weapons to upgrade"))
						end
					end
				end)
			else
				addCommsReply(_("upgrade-comms","Talk to Frederico Booker"), function()
					setCommsMessage(string.format(_("upgrade-comms","[Frederico Booker]\nGreetings, %s. What brings you to %s to talk to me?"),comms_source:getCallSign(),beamDamageStation:getCallSign()))
					addCommsReply(_("upgrade-comms","Can you upgrade our beam weapons systems?"), function()
						setCommsMessage(string.format(_("upgrade-comms","[Frederico Booker]\nOh, you've heard about my research and the practical results? I can certainly upgrade the damage dealt by your beam weapons systems, but you'll need to provide me with %s and %s before I can complete the job"),good_desc[beamPart1],good_desc[beamPart2]))
						addCommsReply(_("Back"), commsStation)
					end)
				end)
			end
		end
	end
	if plot2name == "spinScientist" then
		if comms_target == spinScientistStation  and not spinUpgradeAvailable then
			addCommsReply(_("upgrade-comms","Speak with Paulina Lindquist"), function()
				setCommsMessage(string.format(_("upgrade-comms","Greetings, %s, what can I do for you?"),comms_source:getCallSign()))
				addCommsReply(_("upgrade-comms","Do you want to apply your engine research?"), function()
					setCommsMessage(_("upgrade-comms","Over the years, I've discovered that research does not pay very well. Do you have some kind of compensation in mind? Gold, platinum or luxury would do nicely."))
					local giftQuantity = 0
					if comms_source.goods ~= nil then
						for good,quantity in pairs(comms_source.goods) do
							if good == "gold" then
								giftQuantity = giftQuantity + quantity
							end
							if good == "platinum" then
								giftQuantity = giftQuantity + quantity
							end
							if good == "luxury" then
								giftQuantity = giftQuantity + quantity
							end
						end
					end
					if giftQuantity > 0 then
						addCommsReply(_("upgrade-comms","Offer compensation from cargo aboard"), function()
							local giftList = {}
							for good,quantity in pairs(comms_source.goods) do
								if good == "gold" and quantity > 0 then
									table.insert(giftList,good)
								end
								if good == "platinum" and quantity > 0 then
									table.insert(giftList,good)
								end
								if good == "luxury" and quantity > 0 then
									table.insert(giftList,good)
								end
							end
							local gift = tableSelectRandom(giftList)
							comms_source.goods[gift] = comms_source.goods[gift] - 1
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format(_("upgrade-comms","Thanks for the %s. I've transmitted instructions on conducting the upgrade. Any friendly station can do the upgrade, but you'll need to provide impulse cargo for the upgrade"),good_desc[gift]))
							spinUpgradeAvailable = true
							plot2reminder = _("orders-comms","Get spin upgrade from friendly station for impulse")
							mission_milestones = mission_milestones + 1
						end)
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if plot2name == "friendlyClue" then
		if comms_target == friendlyClueStation then
			addCommsReply(_("intelligence-comms","Speak with Herbert Long"), function()
				setCommsMessage(string.format(_("intelligence-comms","Well, if it isn't the good ship, %s! What brings you to %s?"),comms_source:getCallSign(),friendlyClueStation:getCallSign()))
				addCommsReply(_("intelligence-comms","Please share your enemy base information"), function()
					setCommsMessage(string.format(_("intelligence-comms","That's old news. Wouldn't you rather know about %s's leadership woes or the latest readings on unique stellar phenomenae in the area?"),friendlyClueStation:getCallSign()))
					addCommsReply(_("intelligence-comms","No, I just want to know about the enemy base"), function()
						setCommsMessage(string.format(_("intelligence-comms","Well, that's easy. The name of the base is %s. Enjoy your stay on %s!"),targetEnemyStation:getCallSign(),friendlyClueStation:getCallSign()))
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(string.format(_("intelligence-comms","What is %s struggling with?"),friendlyClueStation:getCallSign()), function()
						setCommsMessage(string.format(_("intelligence-comms","There are so many requests for transfers, %s may be understaffed by next week."),friendlyClueStation:getCallSign()))
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("intelligence-comms","What kind of unique stellar phenomenae?"), function()
						setCommsMessage(string.format(_("intelligence-comms","While we were in %s spying on %s, we picked up readings in a nebula hinting at the formation of a new star."),targetEnemyStation:getSectorName(),targetEnemyStation:getCallSign()))
						primaryOrders = string.format(_("orders-comms","Destroy enemy station %s in %s"),targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName())
						mission_milestones = mission_milestones + 1
						betweenPlot2fleet()
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if spinUpgradeAvailable and comms_source:isFriendly(comms_target) and distance(comms_source,comms_target) < 2000 then
		impulseQuantity = 0
		if comms_source.goods ~= nil then
			for good,quantity in pairs(comms_source.goods) do
				if good == "impulse" then
					impulseQuantity = quantity
				end
			end
		end
		if impulseQuantity > 0 then
			addCommsReply(_("upgrade-comms","Upgrade ship maneuverability for impulse"), function()
				if comms_source.spinUpgrade then
					setCommsMessage(_("upgrade-comms","You already have the upgrade"))
				else
					comms_source.spinUpgrade = true
					comms_source.goods["impulse"] = comms_source.goods["impulse"] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
					setCommsMessage(_("upgrade-comms","Maneuverability upgraded by 50%"))
					mission_milestones = mission_milestones + 1
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
end
function getServiceCost(service)
-- Return the number of reputation points that a specified service costs for
-- the current player.
    return math.ceil(comms_target.comms_data.service_cost[service])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function addCommandLogButton(p)
	p.command_log_button_rel = "command_log_button_rel"
	p:addCustomButton("Relay",p.command_log_button_rel,_("buttonRelay","Command Log"),function()
		string.format("")
		showPlayerCommandLog(p,"Relay")
	end,7)
	p.command_log_button_ops = "command_log_button_ops"
	p:addCustomButton("Operations",p.command_log_button_ops,_("buttonOperations","Command Log"),function()
		string.format("")
		showPlayerCommandLog(p,"Operations")
	end,7)
end
function showPlayerCommandLog(p,console)
	local out = string.format(_("msgRelay","Command log for %s (clock - message):"),p:getCallSign())
	local sorted_log = {}
	for i,log in pairs(p.command_log) do
		if log.received then
			table.insert(sorted_log,log)
		end
	end
	table.sort(sorted_log,function(a,b)
		return a.stamp < b.stamp
	end)
	for i,log in pairs(sorted_log) do
		local timestamp = formatTime(log.stamp)
		out = string.format(_("msgRelay","%s\n%s - %s"),out,timestamp,log.short)
	end
	p.show_player_command_log_msg = string.format("show_player_command_log_msg_%s",console)
	p:addCustomMessage(console,p.show_player_command_log_msg,out)
end
function missionMessages()
	if message_stations == nil then
		message_stations = {}
		for i,station in ipairs(stationList) do
			table.insert(message_stations,station)
		end
		selected_message_station = homeStation
	end
	if command_log == nil then
		command_log = {
			{
				name = "initial orders",
				long = string.format(_("goal-incCall","The Ktlitans keep sending harassing ships. We've decrypted some of their communications - enough to identify their primary base by name if not by location. Find and destroy Ktlitan station %s. Respond to other requests from stations in the area if you wish, but your primary goal is do destroy %s. It is in your best interest to protect your carrier since it will significantly shorten the duration of your mission. Station %s has been designated your home station."),targetEnemyStation:getCallSign(),targetEnemyStation:getCallSign(),homeStation:getCallSign()),
				short = string.format(_("msgRelay","Ktlitans are harassing us. Destroy their primary station, %s. Respond to other requests if desired. Protect carrier to reduce mission duration. Home station is %s."),targetEnemyStation:getCallSign(),homeStation:getCallSign()),
				time = 3,
				sent = false,
				received = false,
				method = "hail",
			},
			{
				name = "spin scientist",
				long = string.format(_("goal-incCall","Paulina Lindquist, a noted research engineer recently published her latest theories on engine design. We believe her theories have practical applications to our ship maneuvering systems. You may want to talk to her about putting her theories into practice on our naval vessels. She's currently stationed on %s in %s."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),
				short = string.format(_("msgRelay","Visit Paulina Lindquist on station %s in sector %s regarding ship spin upgrade."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),
				time = 0,
				sent = false,
				received = false,
				trigger = spinScientist,
				method = "hail",
			},
			{
				name = "friendly clue",
				long = string.format(_("goal-incCall","Herbert Long believes he has a lead on some information about the enemy base that has been the source of the harassing ships. He's stationed on %s in %s."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),
				short = string.format(_("msgRelay","Talk to Herbert Long on %s in %s regarding enemy base."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),
				time = 0,
				sent = false,
				received = false,
				trigger = friendlyClue,
				method = "hail",
			},
			{
				name = "rescue scientist",
				long = string.format(_("goal-incCall","[%s in %s] Medical emergency: Engineering research scientist Terrence Forsythe has contracted a rare medical condition. After contacting nearly every station in the area, we found that doctor Geraldine Polaski on %s has the expertise and facilities to help. However, we don't have the necessary transport to get Terrence there in time - he has only a few minutes left to live. Can you take Terrence to %s?"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign(),doctorStation:getCallSign()),
				short = string.format(_("msgRelay","Transport Terrence Forsythe from %s in %s to %s before he dies"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign()),
				time = 0,
				sent = false,
				received = false,
				trigger = getSickScientist,
				method = "hail",
			},
			{
				name = "add missile tube",
				long = string.format(_("goal-incCall","Retired naval officer, Boris Eggleston has taken his expertise in miniaturization and come up with a way to add a missile tube to naval vessels. He's vacationing on %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName()),
				short = string.format(_("msgRelay","Get extra weapons tube from Boris Eggleston on %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName()),
				time = 0,
				sent = false,
				received = false,
				trigger = tubeOfficer,
				method = "hail",
			},
			{
				name = "increase beam damage",
				long = string.format(_("goal-incCall","There's a physicist turned maintenance technician named Frederico Booker that has developed some innovative beam weapon technology that could increase the damage produced by our beam weapons. He's based on %s in %s"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),
				short = string.format(_("msgRelay","Talk to Frederico Booker on %s in %s about a beam upgrade"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),
				time = 0,
				sent = false,
				received = false,
				trigger = beamPhysicist,
				method = "hail",
			},
		}
	end
	for i,log in ipairs(command_log) do
		if getScenarioTime() > log.time then
			if not log.sent then
				local players_got_message = true
				for j,p in ipairs(getActivePlayerShips()) do
					if p.command_log == nil then
						p.command_log = {}
						for w,log_item in ipairs(command_log) do
							table.insert(p.command_log,{
								long = log_item.long,
								short = log_item.short,
								time = log_item.time,
								sent = log_item.sent,
								received = log_item.received,
								trigger = log_item.trigger,
								method = log_item.method,
							})
						end
						addCommandLogButton(p)
					end
					local met = true
					if log.trigger ~= nil then
						met = log.trigger(p)
					end
					if met then
						if p.command_log ~= nil and p.command_log[i] ~= nil and not p.command_log[i].received then
							if log.method == "relay" then
								local long_msg = log.long
								p:addCustomMessage("Relay","command_log_message_rel",long_msg)
								p:addCustomMessage("Operations","command_log_message_ops",long_msg)
								addCommandLogButton(p)
								p.command_log[i].received = true
								p.command_log[i].stamp = getScenarioTime()
							else	--hail method
								if availableForComms(p) then
									if selected_message_station == nil then
										for k,station in ipairs(message_stations) do
											if station ~= nil and station:isValid() then
												selected_message_station = station
												break
											else
												message_stations[k] = message_stations[#message_stations]
												message_stations[#message_stations] = nil
												break
											end
										end
									end
									if selected_message_station ~= nil then
										local long_msg = log.long
										if i == 3 then
											long_msg = string.format(_("centralcommand-incCall","%s (%s until intersection)"),long_msg,p.nova_demo_time_remaining)
										end
										selected_message_station:sendCommsMessage(p,long_msg)
										addCommandLogButton(p)
										p.command_log[i].received = true
										p.command_log[i].stamp = getScenarioTime()
									else
										players_got_message = false
									end
								else
									players_got_message = false
								end
							end
						end
					else
						players_got_message = false
					end
				end
				if players_got_message then
					log.sent = true
				end
			end
		end
	end
end
--	Ship communication 
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if comms_target.comms_data.goods == nil then
		comms_target.comms_data.goods = {}
		comms_target.comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = math.random(1,3), cost = random(20,80)}
		local shipType = comms_target:getTypeName()
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				local good_count = 0
				repeat
					comms_target.comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = math.random(1,3), cost = random(20,80)}
					local goodCount = 0
					for good, goodData in pairs(comms_target.comms_data.goods) do
						goodCount = goodCount + 1
					end
					good_count = good_count + 1
				until(goodCount >= 3 or good_count > max_repeat_loop)
				if good_count > max_repeat_loop then
					print("exceeded max repeat loop when counting goods in commsShip function")
				end
			end
		end
	end
	setPlayers()
	if comms_source:isFriendly(comms_target) then
		return friendlyComms()
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms()
	end
	return neutralComms()
end
function friendlyComms()
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		freighterComms()
	else
		if comms_target.comms_data.friendlyness < 20 then
			setCommsMessage(_("shipAssist-comms", "What do you want?"));
		else
			setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
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
		if comms_target.comms_data.friendlyness > 0.2 then
			addCommsReply(_("shipAssist-comms", "Assist me"), function()
				setCommsMessage(_("shipAssist-comms", "Heading toward you to assist."));
				comms_target:orderDefendTarget(comms_source)
				addCommsReply(_("Back"), commsShip)
			end)
		end
		addCommsReply(_("shipAssist-comms", "Report status"), function()
			local msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
			shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = string.format(_("shipAssist-comms", "%sShield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			elseif shields == 2 then
				msg = string.format(_("shipAssist-comms", "%sFront Shield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
				msg = string.format(_("shipAssist-comms", "%sRear Shield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
			else
				for n=0,shields-1 do
					msg = string.format(_("shipAssist-comms", "%sShield %s: %d%%\n"),msg, n, math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
				end
			end
			missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
			for i, missile_type in ipairs(missile_types) do
				if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = string.format(_("shipAssist-comms", "%s%s Missiles: %d/%d\n"),msg, missile_type, math.floor(comms_target:getWeaponStorage(missile_type)), math.floor(comms_target:getWeaponStorageMax(missile_type)))
				end
			end
			setCommsMessage(msg);
			addCommsReply(_("Back"), commsShip)
		end)
		for idx, obj in ipairs(comms_target:getObjectsInRange(5000)) do
			local space_station = false
			if ECS then
				if obj.components.docking_bay and obj.components.physics and obj.components.physics.type == "static" then
					space_station = true
				end
			else
				if obj.typeName == "SpaceStation" then
					space_station = true
				end
			end
			if space_station and not comms_target:isEnemy(obj) then
				addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
					setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
					comms_target:orderDock(obj)
					addCommsReply(_("Back"), commsShip)
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
			addCommsReply(_("shipAssist-comms", "Attack nearby enemy target"), function()
				localTargetCount = 0
				enemyTargetList = {}
				etlCount = 0
				for idx, obj in ipairs(comms_target:getObjectsInRange(15000)) do
					if comms_target:isEnemy(obj) then
						addCommsReply(obj:getCallSign(), function()
							setCommsMessage(string.format(_("shipAssist-comms", "Attacking %s"),obj:getCallSign()))
							comms_target:orderAttack(obj)
							addCommsReply(_("Back"), commsShip)
						end)
						localTargetCount = localTargetCount + 1
						if localTargetCount > 9 then
							break
						end
					end
				end
				if localTargetCount == 0 then
					setCommsMessage(_("shipAssist-comms", "No enemy targets nearby"))
				else
					setCommsMessage(_("shipAssist-comms", "Which enemy target?"))
				end
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	return true
end
function enemyComms()
	if comms_target.comms_data.friendlyness > 50 then
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
		comms_target.comms_data.friendlyness = comms_target.comms_data.friendlyness - random(0, 10)
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
function freighterComms()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {}
	end
	if comms_target.comms_data.friendlyness == nil then
		comms_target.comms_data.friendlyness = random(1,100)
	end
	if comms_target.comms_data.friendlyness > 66 then
		setCommsMessage(_("trade-comms", "Yes?"))
		-- Offer destination information
		addCommsReply(_("trade-comms", "Where are you headed?"), function()
			setCommsMessage(comms_target.target:getCallSign())
			addCommsReply(_("Back"), commsShip)
		end)
		-- Offer to trade goods if goods or equipment freighter
		if distance(comms_source,comms_target) < 5000 then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				luxuryQuantity = 0
				if comms_source.goods ~= nil then
					for good,quantity in pairs(comms_source.goods) do
						if good == "luxury" then
							luxuryQuantity = quantity
						end
					end
				end
				if luxuryQuantity > 0 then
					if comms_target.comms_data.goods ~= nil then
						for good,good_data in pairs(comms_target.comms_data.goods) do
							if good_data.quantity > 0 then
								addCommsReply(string.format("Trade luxury for %s",good_desc[good]),function()
									good_data.quantity = good_data.quantity - 1
									comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									setCommsMessage(string.format("Traded a luxury for a %s",good_desc[good]))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end
					end
				end
			else
				-- Offer to sell goods
				if comms_target.goods ~= nil then
					for good,good_data in pairs(comms_target.goods) do
						if good_data.quantity > 0 then
							addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good_desc[good],good_data.cost),function()
								if comms_source.cargo < 1 then
									setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
								else
									if comms_source:takeReputationPoints(good_data.cost) then
										comms_source.cargo = comms_source.cargo - 1
										good_data.quantity = good_data.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										setCommsMessage(string.format(_("trade-comms","One %s purchased"),good_desc[good]))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
									end
								end
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
				end
			end
		else
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				goodsQuantity = 0
				if comms_target.comms_data.goods ~= nil then
					for good,good_data in pairs(comms_target.goods) do
						if good_data.quantity > 0 then
							goodsQuantity = goodsQuantity + good_data.quantity
						end
					end
				end
				if goodsQuantity > 0 then
					addCommsReply(_("trade-comms", "What kind of cargo are you carrying?"), function()
						local gMsg = _("trade-comms","Goods aboard:")
						for good,good_data in pairs(comms_target.comms_data.goods) do
							if good_data.quantity > 0 then
								gMsg = string.format(_("trade-comms","%s\n%s"),gMsg,good_desc[good])
							end
						end
						setCommsMessage(gMsg)
						addCommsReply(_("Back"), commsShip)
					end)
				end
			end
		end
	elseif comms_target.comms_data.friendlyness > 33 then
		setCommsMessage(_("shipAssist-comms", "What do you want?"))
		-- Offer to sell destination information
		local destRep = math.random(1,5)
		addCommsReply(string.format(_("trade-comms", "Where are you headed? (cost: %i reputation)"),destRep), function()
			if not comms_source:takeReputationPoints(destRep) then
				setCommsMessage(_("needRep-comms", "Insufficient reputation"))
			else
				setCommsMessage(comms_target.target:getCallSign())
			end
			addCommsReply(_("Back"), commsShip)
		end)
		-- Offer to sell goods if goods or equipment freighter
		if distance(comms_source,comms_target) < 5000 then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				if comms_target.comms_data.goods ~= nil then
					for good,good_data in pairs(comms_target.comms_data.goods) do
						if good_data.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good_desc[good],good_data.cost),function()
								if comms_source.cargo < 1 then
									setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
								else
									if comms_source:takeReputationPoints(good_data.cost) then
										comms_source.cargo = comms_source.cargo - 1
										good_data.quantity = good_data.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										setCommsMessage(string.format("One %s purchased.",good_desc[good]))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
									end
								end
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
				end
			else
				-- Offer to sell goods double price
				if comms_target.comms_data.goods ~= nil then
					for good,good_data in pairs(comms_target.comms_data.goods) do
						if good_data.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good_desc[good],good_data.cost*2),function()
								if comms_source.cargo < 1 then
									setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
								else
									if comms_source:takeReputationPoints(good_data.cost*2) then
										comms_source.cargo = comms_source.cargo - 1
										good_data.quantity = good_data.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										setCommsMessage(string.format("One %s purchased.",good_desc[good]))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
									end
								end
							end)
						end
					end
				end
			end
		else
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				goodsQuantity = 0
				if comms_target.comms_data.goods ~= nil then
					for good,good_data in pairs(comms_target.comms_data.goods) do
						goodsQuantity = goodsQuantity + good_data.quantity
					end
				end
				if goodsQuantity > 0 then
					addCommsReply(_("trade-comms", "What kind of cargo are you carrying?"), function()
						local gMsg = _("trade-comms","Goods aboard:")
						for good,good_data in pairs(comms_target.comms_data.goods) do
							if good_data.quantity > 0 then
								gMsg = string.format(_("trade-comms","%s\n%s"),gMsg,good_desc[good])
							end
						end
						setCommsMessage(gMsg)
						addCommsReply(_("Back"), commsShip)
					end)
				end
			end
		end
	else
		setCommsMessage(_("trade-comms", "Why are you bothering me?"))
		-- Offer to sell goods if goods or equipment freighter double price
		if distance(comms_source,comms_target) < 5000 then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				if comms_target.comms_data.goods ~= nil then
					for good,good_data in pairs(comms_target.comms_data.goods) do
						if good_data.quantity > 0 then
							addCommsReply(string.format("Buy one %s for %i reputation",good_desc[good],good_data.cost*2),function()
								if comms_source.cargo < 1 then
									setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
								else
									if comms_source:takeReputationPoints(good_data.cost*2) then
										comms_source.cargo = comms_source.cargo - 1
										good_data.quantity = good_data.quantity - 1
										if comms_source.goods == nil then
											comms_source.goods = {}
										end
										if comms_source.goods[good] == nil then
											comms_source.goods[good] = 0
										end
										comms_source.goods[good] = comms_source.goods[good] + 1
										setCommsMessage(string.format("One %s purchased.",good_desc[good]))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
									end
								end
							end)
						end
					end
				end
			end
		else
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				goodsQuantity = 0
				if comms_target.comms_data.goods ~= nil then
					for good,good_data in pairs(comms_target.comms_data.goods) do
						goodsQuantity = goodsQuantity + good_data.quantity
					end
				end
				if goodsQuantity > 0 then
					addCommsReply(_("trade-comms", "What kind of cargo are you carrying?"), function()
						local gMsg = _("trade-comms","Goods aboard:")
						for good,good_data in pairs(comms_target.comms_data.goods) do
							if good_data.quantity > 0 then
								gMsg = string.format(_("trade-comms","%s\n%s"),gMsg,good_desc[good])
							end
						end
						setCommsMessage(gMsg)
						addCommsReply(_("Back"), commsShip)
					end)
				end
			end
		end
	end
end
function neutralComms()
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		freighterComms()
	else
		if comms_target.comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
		else
			setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
		end
	end
	return true
end
--	Defend ship communication --
function commsDefendShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyDefendComms()
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyDefendComms()
	end
	return neutralDefendComms()
end
function friendlyDefendComms()
	if comms_target.comms_data.friendlyness < 20 then
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		local msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = string.format(_("shipAssist-comms", "%sShield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
		elseif shields == 2 then
			msg = string.format(_("shipAssist-comms", "%sFront Shield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			msg = string.format(_("shipAssist-comms", "%sRear Shield: %d%%\n"),msg, math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100))
		else
			for n=0,shields-1 do
				msg = string.format(_("shipAssist-comms", "Shield %s: %d%%\n"),msg, n, math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
				msg = string.format(_("shipAssist-comms", "%s%s Missiles: %d/%d\n"),msg, missile_type, math.floor(comms_target:getWeaponStorage(missile_type)), math.floor(comms_target:getWeaponStorageMax(missile_type)))
			end
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsDefendShip)
	end)
	return true
end
function enemyDefendComms()
    if comms_target.comms_data.friendlyness > 50 then
        local faction = comms_target:getFaction()
        local taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
        local taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
        local taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
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
        comms_target.comms_data.friendlyness = comms_target.comms_data.friendlyness - random(0, 10)
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
function neutralDefendComms()
    if comms_target.comms_data.friendlyness > 50 then
        setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
    else
        setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
    end
    return true
end
--	Cargo management 
function cargoTransfer()
	if playerCarrier:isValid() and playerCarrier.cargo > 0 and playerBlade:isValid() and playerBlade:isDocked(playerCarrier) and playerBlade.cargo < playerBlade.maxCargo then
		if bladeTransferButton == nil then
			bladeTransferButton = "bladeTransferButton"
			playerBlade:addCustomButton("Relay", bladeTransferButton, _("-buttonRelay", "Transfer Cargo"), bladeCargoTransfer)
			bladeTransferButtonOp = "bladeTransferButtonOp"
			playerBlade:addCustomButton("Operations", bladeTransferButtonOp, _("-buttonOperations", "Transfer Cargo"), bladeCargoTransfer)
		end
	else
		if bladeTransferButton ~= nil then
			if playerBlade:isValid() then
				playerBlade:removeCustom(bladeTransferButton)
				playerBlade:removeCustom(bladeTransferButtonOp)
				bladeTransferButton = nil
				bladeTransferButtonOp = nil
			end
		end
	end
	if playerCarrier:isValid() and playerCarrier.cargo > 0 and playerPoint:isValid() and playerPoint:isDocked(playerCarrier) and playerPoint.cargo < playerPoint.maxCargo then
		if pointTransferButton == nil then
			pointTransferButton = "pointTransferButton"
			playerPoint:addCustomButton("Relay", pointTransferButton, _("-buttonRelay", "Transfer Cargo"), pointCargoTransfer)
			pointTransferButtonOp = "pointTransferButtonOp"
			playerPoint:addCustomButton("Operations", pointTransferButtonOp, _("-buttonOperations", "Transfer Cargo"), pointCargoTransfer)
		end
	else
		if pointTransferButton ~= nil then
			if playerPoint:isValid() then
				playerPoint:removeCustom(pointTransferButton)
				playerPoint:removeCustom(pointTransferButtonOp)
				pointTransferButton = nil
				pointTransferButtonOp = nil
			end
		end
	end
	if playerBlade:isValid() and playerBlade.cargo > 0 and playerCarrier:isValid() and playerBlade:isDocked(playerCarrier) and playerCarrier.cargo < playerCarrier.maxCargo then
		if carrier2bladeTransferButton == nil and carrier2bladeTransferButtonList == nil then
			carrier2bladeTransferButton = "carrier2bladeTransferButton"
			playerCarrier:addCustomButton("Relay",carrier2bladeTransferButton,string.format("+Cargo to %s",playerBlade:getCallSign()),carrier2bladeTransfer,50)
			carrier2bladeTransferButtonOps = "carrier2bladeTransferButtonOps"
			playerCarrier:addCustomButton("Operations",carrier2bladeTransferButtonOps,string.format("+Cargo to %s",playerBlade:getCallSign()),carrier2bladeTransfer,50)
		end
		if carrier2bladeTransferButtonList ~= nil then
			carrier2bladeTransfer()
		end
	else
		if carrier2bladeTransferButton ~= nil then
			playerCarrier:removeCustom(carrier2bladeTransferButton)
			playerCarrier:removeCustom(carrier2bladeTransferButtonOps)
			carrier2bladeTransferButton = nil
		end
		if carrier2bladeTransferButtonList ~= nil then
			for i,good in ipairs(carrier2bladeTransferButtonList) do
				playerCarrier:removeCustom(string.format("blade_good%s",good))
				playerCarrier:removeCustom(string.format("blade_good%sops",good))			
			end
		end
		playerCarrier:removeCustom("exitBladeCargoTransfer")
		playerCarrier:removeCustom("exitBladeCargoTransferOps")
	end
	if playerPoint:isValid() and playerPoint.cargo > 0 and playerCarrier:isValid() and playerPoint:isDocked(playerCarrier) and playerCarrier.cargo < playerCarrier.maxCargo then
		if carrier2pointTransferButton == nil and carrier2pointTransferButtonList == nil then
			carrier2pointTransferButton = "carrier2pointTransferButton"
			playerCarrier:addCustomButton("Relay",carrier2pointTransferButton,string.format("+Cargo to %s",playerPoint:getCallSign()),carrier2pointTransfer,60)
			carrier2pointTransferButtonOps = "carrier2pointTransferButtonOps"
			playerCarrier:addCustomButton("Operations",carrier2pointTransferButtonOps,string.format("+Cargo to %s",playerPoint:getCallSign()),carrier2pointTransfer,60)
		end
		if carrier2pointTransferButtonList ~= nil then
			carrier2pointTransfer()
		end
	else
		if carrier2pointTransferButton ~= nil then
			playerCarrier:removeCustom(carrier2pointTransferButton)
			playerCarrier:removeCustom(carrier2pointTransferButtonOps)
			carrier2pointTransferButton = nil
		end
		if carrier2pointTransferButtonList ~= nil then
			for i,good in ipairs(carrier2pointTransferButtonList) do
				playerCarrier:removeCustom(string.format("point_good%s",good))
				playerCarrier:removeCustom(string.format("point_good%sops",good))			
			end
		end
		playerCarrier:removeCustom("exitPointCargoTransfer")
		playerCarrier:removeCustom("exitPointCargoTransferOps")
	end
end
function carrier2bladeTransfer()
	string.format("")
	if carrier2bladeTransferButton ~= nil then
		playerCarrier:removeCustom(carrier2bladeTransferButton)
		playerCarrier:removeCustom(carrier2bladeTransferButtonOps)
	end
	carrier2bladeTransferButton = nil
	if carrier2bladeTransferButtonList ~= nil then
		for i,good in ipairs(carrier2bladeTransferButtonList) do
			playerCarrier:removeCustom(string.format("blade_good%s",good))
			playerCarrier:removeCustom(string.format("blade_good%sops",good))			
		end
	end
	carrier2bladeTransferButtonList = {}
	local good_button_index = 0
	for good,quantity in pairs(playerCarrier.goods) do
		if quantity > 0 then
			good_button_index = good_button_index + 1
			table.insert(carrier2bladeTransferButtonList,good)
			playerCarrier:addCustomButton("Relay",string.format("blade_good%s",good),string.format("%s to %s",good_desc[good],playerBlade:getCallSign()),function()
				string.format("")
				carrier2bladeTransferGood(good)
			end,50+good_button_index)
			playerCarrier:addCustomButton("Operations",string.format("blade_good%sops",good),string.format("%s to %s",good_desc[good],playerBlade:getCallSign()),function()
				string.format("")
				carrier2bladeTransferGood(good)
			end,50+good_button_index)
		end
	end
	playerCarrier:addCustomButton("Relay","exitBladeCargoTransfer",string.format("-%s Cargo",playerBlade:getCallSign()),function()
		if carrier2bladeTransferButtonList ~= nil then
			for i,good in ipairs(carrier2bladeTransferButtonList) do
				playerCarrier:removeCustom(string.format("blade_good%s",good))
				playerCarrier:removeCustom(string.format("blade_good%sops",good))			
			end
		end
		carrier2bladeTransferButtonList = nil
		playerCarrier:removeCustom("exitBladeCargoTransfer")
		playerCarrier:removeCustom("exitBladeCargoTransferOps")
	end,50)
	playerCarrier:addCustomButton("Operations","exitBladeCargoTransferOps",string.format("-%s Cargo",playerBlade:getCallSign()),function()
		if carrier2bladeTransferButtonList ~= nil then
			for i,good in ipairs(carrier2bladeTransferButtonList) do
				playerCarrier:removeCustom(string.format("blade_good%s",good))
				playerCarrier:removeCustom(string.format("blade_good%sops",good))			
			end
		end
		carrier2bladeTransferButtonList = nil
		playerCarrier:removeCustom("exitBladeCargoTransfer")
		playerCarrier:removeCustom("exitBladeCargoTransferOps")
	end,50)
end
function carrier2bladeTransferGood(good)
	if playerCarrier.goods[good] > 0 then
		if playerBlade.cargo > 0 then
			if playerBlade.goods == nil then
				playerBlade.goods = {}
			end
			if playerBlade.goods[good] == nil then
				playerBlade.goods[good] = 0
			end
			playerBlade.goods[good] = playerBlade.goods[good] + 1
			playerBlade.cargo = playerBlade.cargo - 1
			playerCarrier.goods[good] = playerCarrier.goods[good] - 1
			playerCarrier.cargo = playerCarrier.cargo + 1
		end
	end
	playerCarrier:addCustomMessage("Relay","blade_cargo_transfer_msg_rel",string.format("One %s transferred from %s to %s.",good_desc[good],playerCarrier:getCallSign(),playerBlade:getCallSign()))
	playerCarrier:addCustomMessage("Operations","blade_cargo_transfer_msg_ops",string.format("One %s transferred from %s to %s.",good_desc[good],playerCarrier:getCallSign(),playerBlade:getCallSign()))
end
function carrier2pointTransfer()
	string.format("")
	if carrier2pointTransferButton ~= nil then
		playerCarrier:removeCustom(carrier2pointTransferButton)
		playerCarrier:removeCustom(carrier2pointTransferButtonOps)
	end
	carrier2pointTransferButton = nil
	if carrier2pointTransferButtonList ~= nil then
		for i,good in ipairs(carrier2pointTransferButtonList) do
			playerCarrier:removeCustom(string.format("point_good%s",good))
			playerCarrier:removeCustom(string.format("point_good%sops",good))			
		end
	end
	carrier2pointTransferButtonList = {}
	local good_button_index = 0
	for good,quantity in pairs(playerCarrier.goods) do
		if quantity > 0 then
			good_button_index = good_button_index + 1
			table.insert(carrier2pointTransferButtonList,good)
			playerCarrier:addCustomButton("Relay",string.format("point_good%s",good),string.format("%s to %s",good_desc[good],playerPoint:getCallSign()),function()
				string.format("")
				carrier2pointTransferGood(good)
			end,60+good_button_index)
			playerCarrier:addCustomButton("Operations",string.format("point_good%sops",good),string.format("%s to %s",good_desc[good],playerPoint:getCallSign()),function()
				string.format("")
				carrier2pointTransferGood(good)
			end,60+good_button_index)
		end
	end
	playerCarrier:addCustomButton("Relay","exitPointCargoTransfer",string.format("-%s Cargo",playerPoint:getCallSign()),function()
		if carrier2pointTransferButtonList ~= nil then
			for i,good in ipairs(carrier2pointTransferButtonList) do
				playerCarrier:removeCustom(string.format("point_good%s",good))
				playerCarrier:removeCustom(string.format("point_good%sops",good))			
			end
		end
		carrier2pointTransferButtonList = nil
		playerCarrier:removeCustom("exitPointCargoTransfer")
		playerCarrier:removeCustom("exitPointCargoTransferOps")
	end,60)
	playerCarrier:addCustomButton("Operations","exitPointCargoTransferOps",string.format("-%s Cargo",playerPoint:getCallSign()),function()
		if carrier2pointTransferButtonList ~= nil then
			for i,good in ipairs(carrier2pointTransferButtonList) do
				playerCarrier:removeCustom(string.format("point_good%s",good))
				playerCarrier:removeCustom(string.format("point_good%sops",good))			
			end
		end
		carrier2pointTransferButtonList = nil
		playerCarrier:removeCustom("exitPointCargoTransfer")
		playerCarrier:removeCustom("exitPointCargoTransferOps")
	end,60)
end
function carrier2pointTransferGood(good)
	if playerCarrier.goods[good] > 0 then
		if playerPoint.cargo > 0 then
			if playerPoint.goods == nil then
				playerPoint.goods = {}
			end
			if playerPoint.goods[good] == nil then
				playerPoint.goods[good] = 0
			end
			playerPoint.goods[good] = playerPoint.goods[good] + 1
			playerPoint.cargo = playerPoint.cargo - 1
			playerCarrier.goods[good] = playerCarrier.goods[good] - 1
			playerCarrier.cargo = playerCarrier.cargo + 1
		end
	end
	playerCarrier:addCustomMessage("Relay","point_cargo_transfer_msg_rel",string.format("One %s transferred from %s to %s.",good_desc[good],playerCarrier:getCallSign(),playerPoint:getCallSign()))
	playerCarrier:addCustomMessage("Operations","point_cargo_transfer_msg_ops",string.format("One %s transferred from %s to %s.",good_desc[good],playerCarrier:getCallSign(),playerPoint:getCallSign()))
end
function bladeCargoTransfer()
	quantityToTransfer = 0
	if playerBlade.goods ~= nil then
		for good,quantity in pairs(playerBlade.goods) do
			quantityToTransfer = quantityToTransfer + quantity
		end
	end
	if quantityToTransfer <= playerCarrier.cargo then
		for good,quantity in pairs(playerBlade.goods) do
			if quantity > 0 then
				if playerCarrier.goods == nil then
					playerCarrier.goods = {}
				end
				if playerCarrier.goods[good] == nil then
					playerCarrier.goods[good] = 0
				end
				playerCarrier.goods[good] = playerCarrier.goods[good] + quantity
				playerCarrier.cargo = playerCarrier.cargo - quantity
				playerBlade.cargo = playerBlade.cargo + quantity
				playerBlade.goods[good] = 0
			end
		end
		if playerBlade:hasPlayerAtPosition("Relay") then
			bladeCargoTransferredMsg = "bladeCargoTransferredMsg"
			playerBlade:addCustomMessage("Relay",bladeCargoTransferredMsg,string.format(_("-msgRelay", "Cargo aboard %s transferred to %s"),playerBlade:getCallSign(),playerCarrier:getCallSign()))
		end
		if playerBlade:hasPlayerAtPosition("Operations") then
			bladeCargoTransferredMsgOp = "bladeCargoTransferredMsgOp"
			playerBlade:addCustomMessage("Operations",bladeCargoTransferredMsgOp,string.format(_("-msgOperations", "Cargo aboard %s transferred to %s"),playerBlade:getCallSign(),playerCarrier:getCallSign()))
		end
		playerCarrier:addToShipLog(string.format("Cargo transferred from %s",playerBlade:getCallSign()),"Magenta")
	else
		if playerBlade:hasPlayerAtPosition("Relay") then
			insufficientCarrierCargoSpaceMsg = "insufficientCarrierCargoSpaceMsg"
			playerBlade:addCustomMessage("Relay",insufficientCarrierCargoSpaceMsg,string.format(_("-msgRelay", "Insufficient space on %s to accept your cargo transfer"),playerCarrier:getCallSign()))
		end
		if playerBlade:hasPlayerAtPosition("Operations") then
			insufficientCarrierCargoSpaceMsgOp = "insufficientCarrierCargoSpaceMsgOp"
			playerBlade:addCustomMessage("Operations",insufficientCarrierCargoSpaceMsgOp,string.format(_("-msgOperations", "Insufficient space on %s to accept your cargo transfer"),playerCarrier:getCallSign()))
		end
	end
end
function pointCargoTransfer()
	quantityToTransfer = 0
	if playerPoint.goods ~= nil then
		for good,quantity in pairs(playerPoint.goods) do
			quantityToTransfer = quantityToTransfer + quantity
		end
	end
	if quantityToTransfer <= playerCarrier.cargo then
		for good,quantity in pairs(playerPoint.goods) do
			if quantity > 0 then
				if playerCarrier.goods == nil then
					playerCarrier.goods = {}
				end
				if playerCarrier.goods[good] == nil then
					playerCarrier.goods[good] = 0
				end
				playerCarrier.goods[good] = playerCarrier.goods[good] + quantity
				playerCarrier.cargo = playerCarrier.cargo - quantity
				playerPoint.cargo = playerPoint.cargo + quantity
				playerPoint.goods[good] = 0
			end
		end
		if playerPoint:hasPlayerAtPosition("Relay") then
			pointCargoTransferredMsg = "pointCargoTransferredMsg"
			playerPoint:addCustomMessage("Relay",pointCargoTransferredMsg,string.format(_("-msgRelay", "Cargo aboard %s transferred to %s"),playerPoint:getCallSign(),playerCarrier:getCallSign()))
		end
		if playerPoint:hasPlayerAtPosition("Operations") then
			pointCargoTransferredMsgOp = "pointCargoTransferredMsgOp"
			playerPoint:addCustomMessage("Operations",pointCargoTransferredMsgOp,string.format(_("-msgOperations", "Cargo aboard %s transferred to %s"),playerPoint:getCallSign(),playerCarrier:getCallSign()))
		end
		playerCarrier:addToShipLog(string.format("Cargo transferred from %s",playerPoint:getCallSign()),"Magenta")
	else
		if playerPoint:hasPlayerAtPosition("Relay") then
			insufficientCarrierCargoSpaceMsg = "insufficientCarrierCargoSpaceMsg"
			playerPoint:addCustomMessage("Relay",insufficientCarrierCargoSpaceMsg,string.format(_("-msgRelay", "Insufficient space on %s to accept your cargo transfer"),playerCarrier:getCallSign()))
		end
		if playerPoint:hasPlayerAtPosition("Operations") then
			insufficientCarrierCargoSpaceMsgOp = "insufficientCarrierCargoSpaceMsgOp"
			playerPoint:addCustomMessage("Operations",insufficientCarrierCargoSpaceMsgOp,string.format(_("-msgOperations", "Insufficient space on %s to accept your cargo transfer"),playerCarrier:getCallSign()))
		end
	end
end
function updatePlayerInventoryButton(p)
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
		end
	end
	if goodCount > 0 then		--add inventory button when cargo acquired
		p:addCustomButton("Relay","inventory_button_rel",_("inventory-buttonRelay","Inventory"),function() 
			string.format("")
			local out = playerShipCargoInventory(p) 
			p:addCustomMessage("Relay","inventory_message",out)
		end,23)
		p:addCustomButton("Operations","inventory_button_ops",_("inventory-buttonOperations","Inventory"), function()
			string.format("")
			local out = playerShipCargoInventory(p) 
			p:addCustomMessage("Operations","inventory_message",out)
		end,23)
		p:addCustomButton("Single","inventory_button_pil",_("inventory-buttonPilot","Inventory"), function()
			string.format("")
			local out = playerShipCargoInventory(p) 
			p:addCustomMessage("Operations","inventory_message",out)
		end,23)
	end
end
function playerShipCargoInventory(p)
	local out = string.format(_("inventory-msgRelay","%s Current cargo:"),p:getCallSign())
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			out = string.format(_("inventory-msgRelay","%s\n     %s: %i"),out,good_desc[good],goodQuantity)
		end
	end
	if goodCount < 1 then
		out = string.format(_("inventory-msgRelay","%s\n     Empty"),out)
	end
	out = string.format(_("inventory-msgRelay","%s\nAvailable space: %i"),out,p.cargo)
	return out
end
--	First plot line. Mission briefing, spawn other plots, wave handling
function initialOrders()
	plot1name = "initialOrders"
	if getScenarioTime() > initialOrderTimer then
		if initialOrdersMsg == nil then
			initialOrdersMsg = "sent"
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","The Ktlitans keep sending harassing ships. We've decrypted some of their communications - enough to identify their primary base by name if not by location. Find and destroy Ktlitan station %s. Respond to other requests from stations in the area if you wish, but your primary goal is do destroy %s. It is in your best interest to protect your carrier since it will significantly shorten the duration of your mission. Station %s has been designated your home station."),targetEnemyStation:getCallSign(),targetEnemyStation:getCallSign(),homeStation:getCallSign()),"Magenta")
			end
			primaryOrders = string.format(_("orders-comms","Destroy %s"),targetEnemyStation:getCallSign())
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
			for idx, enemy in ipairs(ntf) do
				enemy:orderDefendTarget(enemyStationList[i])
			end
		end
		plot1 = threadedPursuit
	end
end
function threadedPursuit(delta)
	plot1name = "threadedPursuit"
	local p = closestPlayerTo(targetEnemyStation)
	local scx, scy = p:getPosition()
	local cpx, cpy = vectorFromAngle(random(0,360),random(20000,30000))
	if ef2 == nil then
		ef2 = spawnEnemies(scx+cpx,scy+cpy,.8)
		for idx, enemy in ipairs(ef2) do
			if fleet_id_diagnostic then
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
		for idx, enemy in ipairs(ef3) do
			if fleet_id_diagnostic then
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
		for idx, enemy in ipairs(ef4) do
			if fleet_id_diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef4")
			end
			enemy:orderAttack(p)
		end
		plot4 = destroyef4
	end
	waveTimer = getScenarioTime() + interWave
	dangerValue = .5
	dangerIncrement = .2
	plot1 = pressureWaves
end
function pressureWaves(delta)
	plot1name = "pressureWaves"
	if not targetEnemyStation:isValid() then
		missionVictory = true
		mission_milestones = mission_milestones + 1
		endStatistics()
		victory("Human Navy")
		return
	end
	if getScenarioTime() > waveTimer then
		waveTimer = getScenarioTime() + interWave + dangerValue*10 + random(1,60)
		dangerValue = dangerValue + dangerIncrement
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if random(1,5) <= 1 then
					local esx, esy = enemyStationList[i]:getPosition()
					ntf = spawnEnemies(esx,esy,dangerValue,enemyStationList[i]:getFaction())
					if random(1,5) <= 3 then
						local p = closestPlayerTo(enemyStationList[i])
						for idx, enemy in ipairs(ntf) do
							enemy:orderAttack(p)
						end
					else
						for idx, enemy in ipairs(ntf) do
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
					for idx, enemy in ipairs(ntf) do
						enemy:orderAttack(homeStation)
					end
				end
			end
		end
		if random(1,5) <= 3 then
			local p = closestPlayerTo(targetEnemyStation)
			local esx, esy = targetEnemyStation:getPosition()
			local px, py = p:getPosition()
			ntf = spawnEnemies((esx+px)/2,(esy+py)/2,dangerValue,targetEnemyStation:getFaction())
			if random(1,5) <= 2 then
				for idx, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if random(1,5) <= 1 then
			local hsx, hsy = targetEnemyStation:getPosition()
			if homeStation:isValid() then
				hsx, hsy = homeStation:getPosition()
			end
			local spx, spy = vectorFromAngle(random(0,360),random(30000,40000))
			ntf = spawnEnemies(hsx+spx,hsy+spy,dangerValue,targetEnemyStation:getFaction())
			if random(1,5) <= 3 then
				if homeStation:isValid() then
					for idx, enemy in ipairs(ntf) do
						enemy:orderFlyTowards(hsx,hsy)
					end
				end
			end
		end
	end
end
--	Plot 2 
function destroyef2(delta)
	plot2name = "destroyef2"
	for i,ship in ipairs(ef2) do
		if not ship:isValid() then
			ef2[i] = ef2[#ef2]
			ef2[#ef2] = nil
			break
		end
	end
	if #ef2 < 1 then
		mission_milestones = mission_milestones + 1
		getPlayerShip(-1):addReputationPoints(rep_bump)
		plot2 = chooseNextPlot2line
	end
	if mission_diagnostic then
		if md_time == nil then
			md_time = getScenarioTime() + 10
			print("destroyef2 - ef2 count:",#ef2,"clock:",getScenarioTime())
			for i,ship in ipairs(ef2) do
				if ship:isValid() then
					print(" ",ship:getCallSign(),ship:getTypeName())
				end
			end
		end
		if getScenarioTime() > md_time then
			md_time = nil
		end
	end
end
function chooseNextPlot2line(delta)
	plot2name = "chooseNextPlot2line"
	plot2reminder = nil
	if nextPlot2 == nil then
		plot2 = tableRemoveRandom(plot2choices)
		if plot2 ~= nil then
			plot2DelayTimer = getScenarioTime() + random(40,120)
			if mission_diagnostic then
				print("plot 2 selected:",plot2,"plot 2 delay timer:",plot2DelayTimer)
			end
		end
	else
		plot2 = nextPlot2
		for i,plot in ipairs(plot2choices) do
			if plot == plot2 then
				plot2choices[i] = plot2choices[#plot2choices]
				plot2choices[#plot2choices] = nil
				plot2DelayTimer = getScenarioTime() + random(40,120)
				break
			end
		end
		if mission_diagnostic then
			print("plot 2 taken from next plot 2:",plot2,"plot 2 delay timer:",plot2DelayTimer)
		end
		nextPlot2 = nil
	end
end
function betweenPlot2fleet()
	if mission_diagnostic then
		print("between plot 2 fleet - ef2 count:",#ef2,"clock:",getScenarioTime())
	end
	local p = closestPlayerTo(targetEnemyStation)
	p:addReputationPoints(rep_bump)
	mission_milestones = mission_milestones + 1
	local scx, scy = p:getPosition()
	local cpx, cpy = vectorFromAngle(random(0,360),random(30000,35000))
	ef2 = spawnEnemies(scx+cpx,scy+cpy,dangerValue)
	for idx, enemy in ipairs(ef2) do
		if fleet_id_diagnostic then
			enemy:setCallSign(enemy:getCallSign() .. "ef2")
		end
		enemy:orderAttack(p)
	end
	plot2reminder = nil
	plot2 = destroyef2
	plot2name = "destroyef2"
	if mission_diagnostic then
		for i,ship in ipairs(ef2) do
			if ship:isValid() then
				print(" ",ship:getCallSign(),ship:getTypeName())
			end
		end
	end
end
function upgradeShipSpin(delta)
-- upgrade ship spin functions
	plot2name = "upgradeShipSpin"
	if getScenarioTime() > plot2DelayTimer then
		if spinScientistStation == nil or not spinScientistStation:isValid() then
			local station_candidate_pool = {}
			for i,station in ipairs(stationList) do
				local tp = nil
				for i,p in ipairs(getActivePlayerShips()) do
					tp = p
					break
				end
				if station:isValid() and not station:isFriendly(tp) and not station:isEnemy(tp) then
					table.insert(station_candidate_pool,station)
				end
			end
			spinScientistStation = tableSelectRandom(station_candidate_pool)
			if spinScientistStation == nil then
				print("nil spin scientist station. candidate pool size:",#station_candidate_pool)
			end
			for i,item in ipairs(command_log) do
				if item.name == "spin scientist" then
					item.long = string.format(_("goal-incCall","Paulina Lindquist, a noted research engineer recently published her latest theories on engine design. We believe her theories have practical applications to our ship maneuvering systems. You may want to talk to her about putting her theories into practice on our naval vessels. She's currently stationed on %s in %s."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName())
					item.short = string.format(_("msgRelay","Visit Paulina Lindquist on station %s in sector %s regarding ship spin upgrade."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName())
					break
				end
			end
		end
		for i,p in ipairs(getActivePlayerShips()) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format(_("goal-shipLog","Paulina Lindquist, a noted research engineer recently published her latest theories on engine design. We believe her theories have practical applications to our ship maneuvering systems. You may want to talk to her about putting her theories into practice on our naval vessels. She's currently stationed on %s in %s."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),"Magenta")
			end
		end
		plot2reminder = string.format(_("orders-comms","Visit Paulina Lindquist on %s in %s regarding ship spin upgrade."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName())
		plot2name = "spinScientist"
		plot2 = spinScientist
		getPlayerShip(-1):addReputationPoints(rep_bump)
		spinUpgradeAvailable = false
		if mission_diagnostic then
			print("upgrade ship spin (plot 2), switch to spin scientist - plot 2 delay timer expired")
		end
	else
		if mission_diagnostic then
			if md_time_upgrade_spin == nil then
				md_time_upgrade_spin = getScenarioTime() + 10
				print("upgrade ship spin (plot 2), switch to spin scientist - plot 2 delay timer not yet expired")
			end
			if getScenarioTime() > md_time_upgrade_spin then
				md_time_upgrade_spin = nil
			end
		end
	end
end
function spinScientist(delta)
	if mission_diagnostic then
		if md_time_spin == nil then
			md_time_spin = getScenarioTime() + 10
			if spinUpgradeAvailable then
				print("spin scientist upgrade available - waiting for all players to get the upgrade")
			else
				print("spin scientist upgrade not yet available")
			end
		end
		if getScenarioTime() > md_time_spin then
			md_time_spin = nil
		end
	end
	validPlayers = 0
	spinPlayers = 0
	if spinUpgradeAvailable then
		for i,p in ipairs(getActivePlayerShips()) do
			if p.spinUpgrade then
				spinPlayers = spinPlayers + 1
			end
		end
		if spinPlayers == #getActivePlayerShips() or not spinScientistStation:isValid() then
			betweenPlot2fleet()
			getPlayerShip(-1):addReputationPoints(rep_bump)
		end
	else
		if not spinScientistStation:isValid() then
			spinScientistStation = nil
			local station_candidate_pool = {}
			for i,station in ipairs(stationList) do
				local tp = nil
				for i,p in ipairs(getActivePlayerShips()) do
					tp = p
					break
				end
				if station:isValid() and not station:isFriendly(tp) and not station:isEnemy(tp) then
					table.insert(station_candidate_pool,station)
				end
			end
			spinScientistStation = tableSelectRandom(station_candidate_pool)
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","Paulina Lindquist, has been reassigned to station %s in %s."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),"Magenta")
			end
			plot2reminder = string.format(_("orders-comms","Visit Paulina Lindquist on %s in %s regarding ship spin upgrade."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName())
			table.insert(command_log,{
				name = "spin scientist reassignment",
				long = string.format(_("goal-incCall","Paulina Lindquist, has been reassigned to station %s in %s"),spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),
				short = string.format(_("msgRelay","Visit Paulina Lindquist on %s in %s regarding ship spin upgrade."),spinScientistStation:getCallSign(),spinScientistStation:getSectorName()),
				time = getScenarioTime() + random(3,5),
				trigger = spinScientist,
				method = "hail",
			})
		end
	end
	if plot2 == spinScientist then
		return true
	end
end
function locateTargetEnemyBase(delta)
-- Locate target enemy base functions
	plot2name = "locateTargetEnemyBase"
	if getScenarioTime() > plot2DelayTimer then
		if friendlyClueStation == nil or not friendlyClueStation:isValid() then
			local station_candidate_pool = {}
			for i,station in ipairs(stationList) do
				local tp = nil
				for i,p in ipairs(getActivePlayerShips()) do
					tp = p
					break
				end
				if station:isValid() and station:isFriendly(tp) then
					table.insert(station_candidate_pool,station)
				end
			end
			friendlyClueStation = tableSelectRandom(station_candidate_pool)
			for i,item in ipairs(command_log) do
				if item.name == "friendly clue" then
					item.long = string.format(_("goal-incCall","Herbert Long believes he has a lead on some information about the enemy base that has been the source of the harassing ships. He's stationed on %s in %s."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName())
					item.short = string.format(_("msgRelay","Talk to Herbert Long on %s in %s regarding enemy base."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName())
					break
				end
			end
		end
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Herbert Long believes he has a lead on some information about the enemy base that has been the source of the harassing ships. He's stationed on %s in %s"),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),"Magenta")
		end
		plot2reminder = string.format(_("orders-comms","Talk to Herbert Long on %s in %s regarding enemy base"),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName())
		plot2name = "friendlyClue"
		plot2 = friendlyClue
		getPlayerShip(-1):addReputationPoints(rep_bump)
		if mission_diagnostic then
			print("locate target enemy base - plot 2 delay timer expired")
		end
	else
		if mission_diagnostic then
			if md_time_locate_target_enemy_base == nil then
				md_time_locate_target_enemy_base = getScenarioTime() + 10
				print("locate target enemy base - plot 2 delay timer not yet expired")
			end
			if getScenarioTime() > md_time_locate_target_enemy_base then
				md_time_locate_target_enemy_base = nil
			end
		end
	end
end
function friendlyClue(delta)
	if mission_diagnostic then
		if md_friendly_clue_time == nil then
			md_friendly_clue_time = getScenarioTime() + 10
			print("friendly clue for plot 2 - check for station validity")
		end
		if getScenarioTime() > md_friendly_clue_time then
			md_friendly_clue_time = nil
		end
	end
	if not friendlyClueStation:isValid() then
		friendlyClueStation = nil
		local station_candidate_pool = {}
		for i,station in ipairs(stationList) do
			local tp = nil
			for i,p in ipairs(getActivePlayerShips()) do
				tp = p
				break
			end
			if station:isValid() and station:isFriendly(tp) then
				table.insert(station_candidate_pool,station)
			end
		end
		friendlyClueStation = tableSelectRandom(station_candidate_pool)
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Herbert Long has been reassigned to station %s in %s."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),"Magenta")
		end
		plot2reminder = string.format(_("orders-comms","Visit Herbert Long on %s in %s regarding enemy base."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName())
		table.insert(command_log,{
			name = "friendly clue reassignment",
			long = string.format(_("goal-incCall","Herbert Long has been reassigned to station %s in %s"),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),
			short = string.format(_("msgRelay","Visit Herbert Long on %s in %s regarding enemy base."),friendlyClueStation:getCallSign(),friendlyClueStation:getSectorName()),
			time = getScenarioTime() + random(3,5),
			trigger = friendlyClue,
			method = "hail",
		})
		if mission_diagnostic then
			print("friendly clue for plot 2 - establish new friendly clue station:",friendlyClueStation:getCallSign())
		end
	end
	if plot2 == friendlyClue then
		return true
	end
end
function rescueDyingScientist(delta)
-- Rescue dying scientist functions
	plot2name = "rescueDyingScientist"
	if mission_diagnostic then
		print("rescue dying scientist (plot 2)")
	end
	scientistDeathTimer = getScenarioTime() + 420 + (120 - difficulty*120)
	local candidate_pool = {}
	if scientistStation == nil or not scientistStation:isValid() then
		candidate_pool = {}
		local tp = nil
		for i,p in ipairs(getActivePlayerShips()) do
			tp = p
			break
		end
		for i,station in ipairs(stationList) do
			if station:isValid() and not station:isFriendly(tp) and not station:isEnemy(tp) then
				table.insert(candidate_pool,station)
			end
		end
		scientistStation = tableSelectRandom(candidate_pool)
		for i,item in ipairs(command_log) do
			if item.name == "rescue scientist" then
				item.long = string.format(_("goal-incCall","[%s in %s] Medical emergency: Engineering research scientist Terrence Forsythe has contracted a rare medical condition. After contacting nearly every station in the area, we found that doctor Geraldine Polaski on %s has the expertise and facilities to help. However, we don't have the necessary transport to get Terrence there in time - he has only a few minutes left to live. Can you take Terrence to %s?"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign(),doctorStation:getCallSign())
				item.short = string.format(_("msgRelay","Transport Terrence Forsythe from %s in %s to %s before he dies"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign())
				break
			end
		end
	end
	if doctorStation == nil or not doctorStation:isValid() then
		candidate_pool = {}
		local tp = nil
		for i,p in ipairs(getActivePlayerShips()) do
			tp = p
			break
		end
		for i,station in ipairs(stationList) do
			if station:isValid() and station:isFriendly(tp) then
				table.insert(candidate_pool,station)
			end
		end
		doctorStation = tableSelectRandom(candidate_pool)
		for i,item in ipairs(command_log) do
			if item.name == "rescue scientist" then
				item.long = string.format(_("goal-incCall","[%s in %s] Medical emergency: Engineering research scientist Terrence Forsythe has contracted a rare medical condition. After contacting nearly every station in the area, we found that doctor Geraldine Polaski on %s has the expertise and facilities to help. However, we don't have the necessary transport to get Terrence there in time - he has only a few minutes left to live. Can you take Terrence to %s?"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign(),doctorStation:getCallSign())
				item.short = string.format(_("msgRelay","Transport Terrence Forsythe from %s in %s to %s before he dies"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign())
				break
			end
		end
	end
	local asx, asy = scientistStation:getPosition()
	local wx, wy = vectorFromAngle(random(0,360),random(2500,3500))
	hullArtifact = Artifact():setPosition(asx+wx,asy+wy):setModel("artifact2"):allowPickup(false):setScanningParameters(3,2)
	hullArtifact:setDescriptions(_("scienceDescription-artifact", "Artificially manufactured object of unknown purpose"),_("scienceDescription-artifact","Prototype device intended for ship system integration")):setRadarSignatureInfo(10,50,5)
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(string.format(_("goal-shipLog","[%s in %s] Medical emergency: Engineering research scientist Terrence Forsythe has contracted a rare medical condition. After contacting nearly every station in the area, we found that doctor Geraldine Polaski on %s has the expertise and facilities to help. However, we don't have the necessary transport to get Terrence there in time - he has only a few minutes left to live. Can you take Terrence to %s?"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign(),doctorStation:getCallSign()),"95,158,160")
	end
	plot2reminder = string.format(_("orders-comms","Transport Terrence Forsythe from %s in %s to %s before he dies"),scientistStation:getCallSign(),scientistStation:getSectorName(),doctorStation:getCallSign())
	plot2name = "getSickScientist"
	plot2 = getSickScientist
	if mission_diagnostic then
		print("rescue dying scientist (plot 2) - scientist station established:",scientistStation:getCallSign())
	end
end
function getSickScientist(delta)
	if plot2 == getSickScientist then
		if getScenarioTime() > scientistDeathTimer then
			scientistDies()
		else
			if mission_diagnostic then
				if md_time_get_sick_scientist == nil then
					md_time_get_sick_scientist = getScenarioTime() + 10
					print("get sick scientist (plot 2) - check for scientist death, scientist station validity, and player proximity to scientist station")
				end
				if getScenarioTime() > md_time_get_sick_scientist then
					md_time_get_sick_scientist = nil
				end
			end
		end
		if scientistStation:isValid() then
			for i,p in ipairs(getActivePlayerShips()) do
				if distance(p,scientistStation) < 1500 then
					playerWithScientist = p
					pickupMsg = string.format(_("goal-shipLog","[%s] Terrence Forsythe has been transported aboard your ship. Please take him to Dr. Polaski on %s. "),scientistStation:getCallSign(),doctorStation:getCallSign())
					minutesToLive = math.floor((scientistDeathTimer - getScenarioTime())/60)
					if minutesToLive == 0 then
						pickupMsg = string.format(_("goal-shipLog","%sWe believe he has less than a minute to live."),pickupMsg)
					elseif minutesToLive == 1 then
						pickupMsg = string.format(_("goal-shipLog","%sWe think he has about a minute before he dies"),pickupMsg)
					else
						pickupMsg = string.format(_("goal-shipLog","%sHe probably has about %i minutes to live"),pickupMsg,minutesToLive)
					end
					p:addToShipLog(pickupMsg,"95,158,160")
					table.insert(command_log,{
						name = "picked up sick scientist",
						long = string.format(_("goal-incCall","Terrence Forsythe transported aboard %s from station %s to be transported quickly to Dr. Polaski on station %s."),playerWithScientist:getCallSign(),scientistStation:getCallSign(),doctorStation:getCallSign()),
						short = string.format(_("msgRelay","%s should take dying scientist to Dr. Polaski on station %s in %s"),playerWithScientist:getCallSign(),doctorStation:getCallSign(),doctorStation:getSectorName()),
						time = 0,
						sent = false,
						received = false,
						trigger = deliverSickScientist,
						method = "hail",
					})
					plot2name = "deliverSickScientist"
					plot2 = deliverSickScientist
					getPlayerShip(-1):addReputationPoints(rep_bump)
					mission_milestones = mission_milestones + 1
					if mission_diagnostic then
						print("player ship close enough to get doctor")
					end
					break
				end
			end
			if pickupMsg ~= nil then
				for i,p in ipairs(getActivePlayerShips()) do
					if p ~= playerWithScientist then
						p:addToShipLog(string.format(_("goal-shipLog","Terrence Forsyth aboard %s"),playerWithScientist:getCallSign()),"Magenta")
					end
				end
			end
		else
			if mission_diagnostic then
				print("station scientist destroyed")
			end
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(_("goal-shipLog","The station with Dr. Polaski aboard has been destroyed."),"Magenta")
			end
			scientistDies()
		end
		return true
	end
end
function deliverSickScientist(delta)
	if plot2 == deliverSickScientist then
		if getScenarioTime() > scientistDeathTimer then
			scientistDies()
		end
		if doctorStation:isValid() then
			if playerWithScientist ~= nil and playerWithScientist:isValid() then
				if distance(playerWithScientist,doctorStation) < 1500 then
					playerWithScientist:addToShipLog(string.format(_("goal-shipLog","[%s] We have received your emergency medical transport of research scientist Terrence Forsythe. Doctor Geraldine Polaski has stabalized his condition."),doctorStation:getCallSign()),"138,43,226")
					plot2name = "keyToArtifact"
					plot2reminder = nil
					scientistRecoveryTimer = getScenarioTime() + 90
					plot2 = keyToArtifact
					getPlayerShip(-1):addReputationPoints(rep_bump)
					mission_milestones = mission_milestones + 1
					table.insert(command_log,{
						name = "delivered scientist",
						long = string.format(_("goal-incCall","[%s] We have received your emergency medical transport of research scientist Terrence Forsythe. Doctor Geraldine Polaski has stabalized his condition."),doctorStation:getCallSign()),
						short = string.format(_("msgRelay","Terrence Forsythe delivered to Dr. Polaski on station %s"),doctorStation:getCallSign()),
						time = 0,
						sent = false,
						received = false,
						trigger = keyToArtifact,
						method = "hail",
					})
				end
			else
				scientistDies()
			end
		else
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","%s has been destroyed"),doctorStation:getCallSign()),"Magenta")
			end
			scientistDies()
		end
		return true
	end
end
function keyToArtifact(delta)
	if getScenarioTime() > scientistRecoveryTimer then
		keyMsg = string.format(_("goal-shipLog","[Terrence Forsythe] I can never repay you for saving my life. However, you might be able to use the practical results of my latest research. Near %s in %s you'll find a prototype for ship system integration. This prototype allows for the rapid and semi-automated repair of hull damage as directed by your Engineer. I have transmitted the key to allow you to use this prototype."),scientistStation:getCallSign(),scientistStation:getSectorName())
		for i,p in ipairs(getActivePlayerShips()) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(keyMsg,"138,43,226")
			end
		end
		plot2name = "recoverHullArtifact"
		plot2reminder = string.format(_("orders-comms","Recover hull repair prototype near %s in %s."),scientistStation:getCallSign(),scientistStation:getSectorName())
		plot2 = recoverHullArtifact
		table.insert(command_log,{
			name = "grateful recovered scientist",
			long = string.format(_("goal-incCall","[Terrence Forsythe] I can never repay you for saving my life. However, you might be able to use the practical results of my latest research. Near %s in %s you'll find a prototype for ship system integration. This prototype allows for the rapid and semi-automated repair of hull damage as directed by your Engineer. I have transmitted the key to allow you to use this prototype."),scientistStation:getCallSign(),scientistStation:getSectorName()),
			short = string.format(_("msgRelay","Recover hull repair prototype near %s in %s."),scientistStation:getCallSign(),scientistStation:getSectorName()),
			time = 0,
			sent = false,
			received = false,
			trigger = recoverHullArtifact,
			method = "hail",
		})
	end
	if plot2 == keyToArtifact then
		return true
	end
end
function recoverHullArtifact(delta)
-- Semi-automated hull repair functions
	for i,p in ipairs(getActivePlayerShips()) do
		tempPlayerType = p:getTypeName()
		if tempPlayerType == "Benedict" or tempPlayerType == "Kiriya" or tempPlayerType == "Saipan" then
			if distance(p,hullArtifact) < 1500 then
				playerWithAutoHullRepair = p
				installAutoHullRepair()
				hullArtifact:destroy()
				betweenPlot2fleet()
				mission_milestones = mission_milestones + 1
				break
			end
		else
			if distance(p,hullArtifact) < 500 then
				playerWithAutoHullRepair = p
				installAutoHullRepair()
				hullArtifact:destroy()
				betweenPlot2fleet()
				mission_milestones = mission_milestones + 1
				break
			end
		end
	end
	if plot2 == recoverHullArtifact then
		return true
	end
end
function installAutoHullRepair()
	repairHullUses = 5
	hullUseMsg = "hullUseMsg"
	playerWithAutoHullRepair:addCustomMessage("Engineering",hullUseMsg,string.format(_("-msgEngineer", "Hull repair prototype installed. Limited to %i uses"),repairHullUses))
	hullUseMsgPlus = "hullUseMsgPlus"
	playerWithAutoHullRepair:addCustomMessage("Engineering+",hullUseMsgPlus,string.format(_("-msgEngineer+", "Hull repair prototype installed. Limited to %i uses"),repairHullUses))
	repairHullButton = string.format("repairHullButton%i",repairHullUses)
	playerWithAutoHullRepair:addCustomButton("Engineering",repairHullButton,string.format(_("-buttonEngineer", "Repair Hull (%i)"),repairHullUses),repairHull)
	repairHullButtonPlus = string.format("repairHullButtonPlus%i",repairHullUses)
	playerWithAutoHullRepair:addCustomButton("Engineering+",repairHullButtonPlus,string.format(_("-buttonEngineer+", "Repair Hull (%i)"),repairHullUses),repairHull)
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
			playerWithAutoHullRepair:addCustomButton("Engineering",repairHullButton,string.format(_("-buttonEngineer", "Repair Hull (%i)"),repairHullUses),repairHull)
			repairHullButtonPlus = string.format("repairHullButtonPlus%i",repairHullUses)
			playerWithAutoHullRepair:addCustomButton("Engineering+",repairHullButtonPlus,string.format(_("-buttonEngineer+", "Repair Hull (%i)"),repairHullUses),repairHull)
		end
	end
end
function scientistDies()
	for i,p in ipairs(getActivePlayerShips()) do
		p:addToShipLog(_("goal-shipLog","Terrence Forsythe has perished"),"Magenta")
	end
	betweenPlot2fleet()
end
--	Plot 3 
function destroyef3(delta)
	plot3name = "destroyef3"
	for i,ship in ipairs(ef3) do
		if not ship:isValid() then
			ef3[i] = ef3[#ef3]
			ef3[#ef3] = nil
			break
		end
	end
	if #ef3 < 1 then
		mission_milestones = mission_milestones + 1
		getPlayerShip(-1):addReputationPoints(rep_bump)
		plot3 = chooseNextPlot3line
	end
end
function chooseNextPlot3line(delta)
	plot3name = "chooseNextPlot3line"
	plot3reminder = nil
	if nextPlot3 == nil then
		plot3 = tableRemoveRandom(plot3choices)
		if plot3 ~= nil then
			plot3DelayTimer = getScenarioTime() + random(40,120)
		end
	else
		plot3 = nextPlot3
		for i,plot in ipairs(plot3choices) do
			if plot == plot3 then
				plot3choices[i] = plot3choices[#plot3choices]
				plot3choices[#plot3choices] = nil
				break
			end
		end
		nextPlot3 = nil
	end
end
function betweenPlot3fleet()
	local p = closestPlayerTo(targetEnemyStation)
	if p ~= nil and p:isValid() then
		p:addReputationPoints(rep_bump)
		local scx, scy = p:getPosition()
		local cpx, cpy = vectorFromAngle(random(0,360),random(30000,35000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,dangerValue)
		for idx, enemy in ipairs(ef3) do
			if fleet_id_diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef3")
			end
			enemy:orderAttack(p)
		end
	end
	plot3reminder = nil
	plot3 = destroyef3
	plot3name = "destroyef3"
end
function addTubeToShip(delta)
-- plot 3 add homing missile weapons tube to ship
	plot3name = "addTubeToShip"
	if getScenarioTime() > plot3DelayTimer then
		if addTubeStation == nil or not addTubeStation:isValid() then
			local candidate_stations = {}
			local tp = nil
			for i,p in ipairs(getActivePlayerShips()) do
				tp = p
				break
			end
			for i,station in ipairs(stationList) do
				if station:isValid() and not station:isFriendly(tp) and not station:isEnemy(tp) then
					table.insert(candidate_stations,station)
				end
			end
			addTubeStation = tableSelectRandom(candidate_stations)
		end
		local tube_cargo = {"lifter","circuit","nanites"}
		local available_tube_cargo = {}
		for i,station in ipairs(stationList) do
			if station ~= nil and station:isValid() then
				if station.comms_data ~= nil then
					if station.comms_data.goods ~= nil then
						for j,good in ipairs(tube_cargo) do
							if station.comms_data.goods[good] ~= nil and station.comms_data.goods[good].quantity > 0 then
								available_tube_cargo[good] = true
							end
						end
					end				
				end
			end
		end
		tube_cargo = {}
		for good,present in pairs(available_tube_cargo) do
			table.insert(tube_cargo,good)
		end
		tubePart = tableSelectRandom(tube_cargo)
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Retired naval officer, Boris Eggleston has taken his expertise in miniaturization and come up with a way to add a missile tube to naval vessels. He's vacationing on %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName()),"Magenta")
		end
		plot3reminder = string.format(_("orders-comms","Get extra weapons tube from Boris Eggleston on %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName())
		plot3name = "tubeOfficer"
		plot3 = tubeOfficer
	end
end
function tubeOfficer(delta)
	if addTubeStation:isValid() then
		tubePlayers = 0
		for i,p in ipairs(getActivePlayerShips()) do
			if p.tubeAdded then
				tubePlayers = tubePlayers + 1
			end
		end
		if tubePlayers == #getActivePlayerShips() then
			betweenPlot3fleet()
		end
	else
		addTubeStation = nil
		local candidate_stations = {}
		local tp = nil
		for i,p in ipairs(getActivePlayerShips()) do
			tp = p
			break
		end
		for i,station in ipairs(stationList) do
			if station:isValid() and not station:isFriendly(tp) and not station:isEnemy(tp) then
				table.insert(candidate_stations,station)
			end
		end
		addTubeStation = tableSelectRandom(candidate_stations)
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Boris Eggleston changed his vacation spot to %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName()),"Magenta")
		end
		plot3reminder = string.format(_("orders-comms","Get extra weapons tube from Boris Eggleston on %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName())
		table.insert(command_log,{
			name = "different vacation destination",
			long = string.format(_("goal-incCall","Boris Eggleston changed his vacation spot to %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName()),
			short = string.format(_("msgRelay","Get extra weapons tube from Boris Eggleston on %s in %s"),addTubeStation:getCallSign(),addTubeStation:getSectorName()),
			time = getScenarioTime() + random(3,5),
			trigger = tubeOfficer,
			sent = false,
			received = false,
			method = "hail",
		})
	end
	if plot3 == tubeOfficer then
		return true
	end
end
function upgradeBeamDamage(delta)
-- plot 3 upgrade the amount of damage done by beam weapons
	plot3name = "upgradeBeamDamage"
	if getScenarioTime() > plot3DelayTimer then
		if beamDamageStation == nil or not beamDamageStation:isValid() then
			local candidate_pool = {}
			local tp = nil
			for i,p in ipairs(getActivePlayerShips()) do
				tp = p
				break
			end
			for i,station in ipairs(stationList) do
				if station:isValid() and station:isFriendly(tp) then
					table.insert(candidate_pool,station)
				end
			end
			beamDamageStation = tableSelectRandom(candidate_pool)
		end
		local beam_cargo = {"gold","platinum","tritanium","dilithium","cobalt"}
		local available_beam_cargo = {}
		for i,station in ipairs(stationList) do
			if station ~= nil and station:isValid() then
				if station.comms_data ~= nil then
					if station.comms_data.goods ~= nil then
						for j,good in ipairs(beam_cargo) do
							if station.comms_data.goods[good] ~= nil and station.comms_data.goods[good].quantity > 0 then
								available_beam_cargo[good] = true
							end
						end
					end				
				end
			end
		end
		beam_cargo = {}
		for good,present in pairs(available_beam_cargo) do
			table.insert(beam_cargo,good)
		end
		beamPart1 = tableSelectRandom(beam_cargo)
		beam_cargo = {"beam","optic","filament","battery","robotic"}
		available_beam_cargo = {}
		for i,station in ipairs(stationList) do
			if station ~= nil and station:isValid() then
				if station.comms_data ~= nil then
					if station.comms_data.goods ~= nil then
						for j,good in ipairs(beam_cargo) do
							if station.comms_data.goods[good] ~= nil and station.comms_data.goods[good].quantity > 0 then
								available_beam_cargo[good] = true
							end
						end
					end				
				end
			end
		end
		beam_cargo = {}
		for good,present in pairs(available_beam_cargo) do
			table.insert(beam_cargo,good)
		end
		beamPart2 = tableSelectRandom(beam_cargo)
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","There's a physicist turned maintenance technician named Frederico Booker that has developed some innovative beam weapon technology that could increase the damage produced by our beam weapons. He's based on %s in %s"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),"Magenta")
		end
		plot3reminder = string.format(_("orders-comms","Talk to Frederico Booker on %s in %s about a beam upgrade"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName())
		plot3name = "beamPhysicist"
		plot3 = beamPhysicist
	end
end
function beamPhysicist(delta)
	if beamDamageStation:isValid() then
		beamPlayers = 0
		beam_upgrade_players = 0
		for i,p in ipairs(getActivePlayerShips()) do
			if p:getBeamWeaponRange(0) > 0 then
				beam_upgrade_players = beam_upgrade_players + 1
				if p.beamDamageUpgrade then
					beamPlayers = beamPlayers + 1
				end
			end
		end
		if beamPlayers == beam_upgrade_players then
			getPlayerShip(-1):addReputationPoints(rep_bump)
			betweenPlot3fleet()
		end
	else
		local candidate_pool = {}
		local tp = nil
		for i,p in ipairs(getActivePlayerShips()) do
			tp = p
			break
		end
		for i,station in ipairs(stationList) do
			if station:isValid() and station:isFriendly(tp) then
				table.insert(candidate_pool,station)
			end
		end
		beamDamageStation = tableSelectRandom(candidate_pool)
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","Frederico Booker has moved to station %s in %s"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),"Magenta")
		end
		plot3reminder = string.format(_("orders-comms","Talk to Frederico Booker on %s in %s about a beam upgrade"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName())
		table.insert(command_log,{
			name = "move beam damage station",
			long = string.format(_("goal-incCall","Frederico Booker has moved to station %s in %s"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),
			short = string.format(_("msgRelay","Talk to Frederico Booker on %s in %s about a beam upgrade"),beamDamageStation:getCallSign(),beamDamageStation:getSectorName()),
			time = getScenarioTime() + random(3,5),
			trigger = beamPhysicist,
			sent = false,
			received = false,
			method = "hail",
		})
	end
	if plot3 == beamPhysicist then
		return true
	end
end
function tractorDisabledShip(delta)
-- plot 3 tractor ship in for repairs
	plot3name = "tractorDisabledShip"
	if getScenarioTime() > plot3DelayTimer then
		if playerCarrier:isValid() then
			if tractorStation == nil or not tractorStation:isValid() then
				local candidate_pool = {}
				local tp = nil
				for i,p in ipairs(getActivePlayerShips()) do
					tp = p
					break
				end
				for i,station in ipairs(stationList) do
					if station:isValid() and not station:isFriendly(tp) and not station:isEnemy(tp) then
						table.insert(candidate_pool,station)
					end
				end
				tractorStation = tableSelectRandom(candidate_pool)
			end
			local p = farthestPlayerFrom(homeStation)
			local ppx, ppy = p:getPosition()
			local tpx, tpy = vectorFromAngle(random(0,360),random(40000,45000))
			local strikeShipNames = {"Cropper","Dunner","Forthwith","Stellar","Trammel","Greeble"}
			tractorShip = CpuShip():setTemplate("Strikeship"):setFaction("Human Navy"):setPosition(ppx+tpx,ppy+tpy):setScanned(true)
			tractorShip:setSystemHealth("warp",-.5):setSystemHealth("jumpdrive",-.5):orderStandGround():setCallSign(tableSelectRandom(strikeShipNames))
			for i,p in ipairs(getActivePlayerShips()) do
				p:addToShipLog(string.format(_("goal-shipLog","[%s] Help requested: Our engines are damaged beyond our ability to repair. We are located in %s."),tractorShip:getCallSign(),tractorShip:getSectorName()),"#556b2f")
			end
			plot3name = "confirmRescue"
			confirmRescueTimer = getScenarioTime() + 40
			plot3 = confirmRescue
			table.insert(command_log,{
				name = "disabled ship needs help",
				long = string.format(_("goal-incCall","%s requests help stating: Our engines are damaged beyond our ability to repair. We are located in sector %s."),tractorShip:getCallSign(),tractorShip:getSectorName()),
				short = string.format(_("msgRelay","Help %s in sector %s with their damaged engines"),tractorShip:getCallSign(),tractorShip:getSectorName()),
				time = 0,
				trigger = confirmRescue,
				sent = false,
				received = false,
				method = "hail",
			})
		else
			betweenPlot3fleet()
		end
	end
end
function confirmRescue(delta)
	if getScenarioTime() > confirmRescueTimer then
		if playerCarrier:isValid() then
			playerCarrier:addToShipLog(string.format(_("goal-shipLog","Station %s in %s has tractor equipment you can use to tractor %s in for repairs"),tractorStation:getCallSign(),tractorStation:getSectorName(),tractorShip:getCallSign()),"Magenta") 
			plot3reminder = string.format(_("orders-comms","Install tractor equipment in %s from station %s in %s"),playerCarrier:getCallSign(),tractorStation:getCallSign(),tractorStation:getSectorName())
			plot3name = "awaitingTractor"
			plot3 = awaitingTractor
			table.insert(command_log,{
				name = "a station with tractor",
				long = string.format(_("goal-incCall","Station %s in %s has tractor equipment you can use to tractor %s in for repairs"),tractorStation:getCallSign(),tractorStation:getSectorName(),tractorShip:getCallSign()),
				short = string.format(_("msgRelay","Install tractor equipment in %s from station %s in %s"),playerCarrier:getCallSign(),tractorStation:getCallSign(),tractorStation:getSectorName()),
				time = 0,
				sent = false,
				received = false,
				trigger = awaitingTractor,
				method = "hail",
			})
		else
			betweenPlot3fleet()
		end
	end
	if plot3 == confirmRescue then
		return true
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
							playerCarrier:addCustomMessage("Weapons",tractorPlayerDockMsg,string.format(_("-msgWeapons", "%s has been tractored to %s and is now docked"),tractorShip:getCallSign(),playerCarrier:getCallSign()))
						end
						if playerCarrier:hasPlayerAtPosition("Tactical") then
							playerCarrier:addCustomMessage("Tactical",tractorPlayerDockMsg,string.format(_("-msgTactical", "%s has been tractored to %s and is now docked"),tractorShip:getCallSign(),playerCarrier:getCallSign()))
						end
					end
				else
					if tractorPlayerDockMsg ~= nil then
						tractorPlayerDockMsg = nil
					end
					if repairStation == nil then
						validFriendlyStations = 0
						local candidate_pool = {}
						local tp = nil
						for i,p in ipairs(getActivePlayerShips()) do
							tp = p
							break
						end
						for i,station in ipairs(stationList) do
							if station:isValid() and station:isFriendly(tp) then
								table.insert(candidate_pool,station)
							end
						end
						repairStation = tableSelectRandom(candidate_pool)
						if repairStation ~= nil then
							playerCarrier:addToShipLog(string.format(_("goal-shipLog","Tractor %s to %s to be repaired"),tractorShip:getCallSign(),repairStation:getCallSign()),"Magenta")
							plot3reminder = string.format(_("orders-comms","Tractor %s to %s"),tractorShip:getCallSign(),repairStation:getCallSign())
							table.insert(command_log,{
								name = "tractor in disabled ship",
								long = string.format(_("goal-incCall","Tractor %s to %s to be repaired"),tractorShip:getCallSign(),repairStation:getCallSign()),
								short = string.format(_("msgRelay","Tractor %s to %s"),tractorShip:getCallSign(),repairStation:getCallSign()),
								time = 0,
								trigger = awaitingTractor,
								sent = false,
								received = false,
								method = "hail",
							})
						else
							disableTractorOff()
							disableTractorOn()
							betweenPlot3fleet()
						end
					else
						if repairStation:isValid() then
							if tractorShip:isValid() then
								if distance(repairStation,tractorShip) < 1500 or playerCarrier:getDockedWith() == repairStation then
									playerCarrier:addToShipLog(string.format(_("goal-shipLog","Station %s says: Thanks for bringing %s in for repairs, %s. We'll take it from here"),repairStation:getCallSign(),tractorShip:getCallSign(),playerCarrier:getCallSign()),"178,150,80")
									tractorShip:orderDock(repairStation)
									disableTractorOff()
									disableTractorOn()
									repairDelayTimer = getScenarioTime() + 60
									plot3name = "awaitRepairs"
									plot3reminder = nil
									plot3 = awaitRepairs
									getPlayerShip(-1):addReputationPoints(rep_bump)
									table.insert(command_log,{
										name = "awaiting repairs",
										long = string.format(_("goal-incCall","Station %s says: Thanks for bringing %s in for repairs, %s. We'll take it from here"),repairStation:getCallSign(),tractorShip:getCallSign(),playerCarrier:getCallSign()),
										short = string.format(_("msgRelay","%s turned over to %s for repairs."),tractorShip:getCallSign(),repairStation:getCallSign()),
										time = 0,
										trigger = awaitRepairs,
										method = "hail",
									})
								else
									if bringCloser == nil and distance(tractorShip, repairStation) < 5000 then
										playerCarrier:addToShipLog(string.format(_("goal-shipLog","[%s] Greetings, %s. You'll need to tractor %s to within 1.5U before we can start repairs"),repairStation:getCallSign(),playerCarrier:getCallSign(),tractorShip:getCallSign()),"178,150,80")
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
	if plot3 == awaitingTractor then
		return true
	end
end
function enableTractorOn()
	if tractorOnButton == nil then
		tractorOnButton = "tractorOnButton"
		playerCarrier:addCustomButton("Weapons",tractorOnButton,_("-buttonWeapons", "Tractor On"),simulateTractorOn)
		tractorOnButtonTac = "tractorOnButtonTac"
		playerCarrier:addCustomButton("Tactical",tractorOnButtonTac,_("-buttonTactical", "Tractor On"),simulateTractorOn)
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
		playerCarrier:addCustomButton("Weapons",tractorOffButton,_("-buttonWeapons", "Tractor Off"),simulateTractorOff)
		tractorOffButtonTac = "tractorOffButtonTac"
		playerCarrier:addCustomButton("Tactical",tractorOffButtonTac,_("-buttonTactical", "Tractor Off"),simulateTractorOff)
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
	tractorShip:orderStandGround()
	disableTractorOff()
	enableTractorOn()
end
function connectTractor()
	playerCarrier:removeCustom(tractorIntegrationButton)
	playerCarrier:removeCustom(tractorIntegrationButtonPlus)
	if playerCarrier:hasPlayerAtPosition("Engineering") then
		tractorConfirmationMsg = "tractorConfirmationMsg"
		playerCarrier:addCustomMessage("Engineering",tractorConfirmationMsg,_("-msgEngineer", "The tractor equipment has been fully integrated with ship systems. It is ready for the weapons officer to activate at the appropriate time"))
	end
	if playerCarrier:hasPlayerAtPosition("Engineering+") then
		tractorConfirmationMsgPlus = "tractorConfirmationMsgPlus"
		playerCarrier:addCustomMessage("Engineering+",tractorConfirmationMsgPlus,_("-msgEngineer+", "The tractor equipment has been fully integrated with ship systems. It is ready for the weapons officer to activate at the appropriate time"))
	end
	if playerCarrier:hasPlayerAtPosition("Weapons") then
		wTractorConfirmationMsg = "wTractorConfirmationMsg"
		playerCarrier:addCustomMessage("Weapons",wTractorConfirmationMsg,string.format(_("-msgWeapons", "Tractor equipment installed.\nWhen %s is in range of the disabled ship, %s, You can engage the tractor system via the (Tractor On) button. This system works with %s's on board systems to draw and maneuver %s to %s until it is docked"),playerCarrier:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),playerCarrier:getCallSign()))
	end
	if playerCarrier:hasPlayerAtPosition("Tactical") then
		tTractorConfirmationMsg = "tTractorConfirmationMsg"
		playerCarrier:addCustomMessage("Tactical",tTractorConfirmationMsg,string.format(_("-msgTactical", "Tractor equipment installed.\nWhen %s is in range of the disabled ship, %s, You can engage the tractor system via the (Tractor On) button. This system works with %s's on board systems to draw and maneuver %s to %s until it is docked"),playerCarrier:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),tractorShip:getCallSign(),playerCarrier:getCallSign()))
	end
	tractorInstalled = true
end
function awaitRepairs(delta)
	if getScenarioTime() > repairDelayTimer then
		tractorShip:setSystemHealth("warp",1):setSystemHealth("jumpdrive",1)
		for i,p in ipairs(getActivePlayerShips()) do
			p:addToShipLog(string.format(_("goal-shipLog","[%s] Our engines have been repaired and we stand ready to assist"),tractorShip:getCallSign()),"#556b2f")
		end
		mission_milestones = mission_milestones + 1
		table.insert(command_log,{
			name = "friendly ship ready to help",
			long = string.format(_("goal-incCall","[From %s] Our engines have been repaired and we stand ready to assist"),tractorShip:getCallSign()),
			short = string.format(_("msgRelay","%s is ready to help us in our mission."),tractorShip:getCallSign()),
			time = 0,
			sent = false,
			received = false,
			method = "hail",
		})
		betweenPlot3fleet()
	end
	if plot3 == awaitRepairs then
		return true
	end
end
--	Plot 4 - more depth to plot 4 to come in a later revision
function destroyef4(delta)
	plot4name = "destroyef4"
	for i,ship in ipairs(ef4) do
		if not ship:isValid() then
			ef4[i] = ef4[#ef4]
			ef4[#ef4] = nil
			break
		end
	end
	if #ef4 < 1 then
		mission_milestones = mission_milestones + 1
		plot4 = doNotPush
	end
end
function doNotPush(delta)
	alienHack = false
	doNotPushButton = "doNotPushButton"
	playerCarrier:addCustomButton("Weapons",doNotPushButton,_("-buttonWeapons", "Do Not Push"),pushed)
	doNotPushButtonTac = "doNotPushButtonTac"
	playerCarrier:addCustomButton("Tactical",doNotPushButtonTac,_("-buttonTactical", "Do Not Push"),pushed)
	if playerCarrier:hasPlayerAtPosition("Science") then
		alienHackMsg = "alienHackMsg"
		playerCarrier:addCustomMessage("Science",alienHackMsg,_("-msgScience", "Internal security sensors indicate ship systems hacked by unknown source. For a moment I thought I heard evil laughter"))
	end
	if playerCarrier:hasPlayerAtPosition("Operations") then
		alienHackMsgOp = "alienHackMsgOp"
		playerCarrier:addCustomMessage("Operations",alienHackMsgOp,_("-msgOperations", "Internal security sensors indicate ship systems hacked by unknown source. For a moment I thought I heard evil laughter"))
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
function tableSelectRandom(array)
	local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
	return array[math.random(1,#array)]	
end
function setPlayers()
--	Give player ships defaults for this script. Called at the start 
--	while paused & each time a ship's relay officer interacts with a station
	for i,pobj in ipairs(getActivePlayerShips()) do
		if pobj.initialRep == nil then
			pobj:addReputationPoints(43-(difficulty*6))
			pobj.initialRep = true
		end
		if not pobj.nameAssigned then
			pobj.nameAssigned = true
			tempPlayerType = pobj:getTypeName()
			if tempPlayerType == "Striker" or tempPlayerType == "MP52 Hornet" or tempPlayerType == "ZX-Lindworm" then
				pobj:addCustomButton("Tactical","shield",_("buttonTactical","Shield"),function()
					if pobj:getShieldsActive() then
						pobj:commandSetShields(false)
					else
						pobj:commandSetShields(true)
					end
				end)
			end
			local ship_name = tableRemoveRandom(player_ship_names_for[tempPlayerType])
			if ship_name ~= nil then
				pobj:setCallSign(ship_name)
			else
				pobj:setCallSign(tableSelectRandom(player_ship_names_for["Leftovers"]))
				pobj.shipScore = 24
				pobj.maxCargo = 5
			end
			pobj.shipScore = player_ship_stats[tempPlayerType].strength
			pobj.maxCargo = player_ship_stats[tempPlayerType].cargo
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
				if pobj:getBeamWeaponRange(0) > 1 then
					pobj.healthyBeam = 1.0
					pobj.prevBeam = 1.0
				end
				if pobj:getWeaponTubeCount() > 0 then
					pobj.healthyMissile = 1.0
					pobj.prevMissile = 1.0
					pobj.tube_size = ""
					for i=1,pobj:getWeaponTubeCount() do
						local tube_size = pobj:getTubeSize(i-1)
						if tube_size == "small" then
							pobj.tube_size = pobj.tube_size .. "S"
						end
						if tube_size == "medium" then
							pobj.tube_size = pobj.tube_size .. "M"
						end
						if tube_size == "large" then
							pobj.tube_size = pobj.tube_size .. "L"
						end
					end
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
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
	if obj ~= nil and obj:isValid() then
		local closest_player = nil
		for i,p in ipairs(getActivePlayerShips()) do
			if closest_player == nil then
				closest_player = p
			else
				if distance(p,obj) < distance(obj,closest_player) then
					closest_player = p
				end
			end
		end
		return closest_player
	else
		return nil
	end
end
function farthestPlayerFrom(obj)
-- Return the player ship farthest from the passed object parameter
	if obj ~= nil and obj:isValid() then
		local farthest_player = nil
		for i,p in ipairs(getActivePlayerShips()) do
			if farthest_player == nil then
				farthest_player = p
			else
				if distance(p,obj) > distance(obj,farthest_player) then
					farthest_player = p
				end
			end
		end
		return farthest_player
	else
		return nil
	end
end
function closestStationTo(obj)
-- Return station closest to object
	if obj ~= nil and obj :isValid() then
		local closest_station = nil
		for i,station in ipairs(stationList) do
			if station:isValid() then
				if closest_station == nil then
					closest_station = station
				else
					if distance(station,obj) < distance(obj,closest_station) then
						closest_station = station
					end
				end
			end
		end
		return closest_station
	else
		return nil
	end
end
function farthestStationTo(obj)
-- Return the station farthest from object
	if obj ~= nil and obj :isValid() then
		local farthest_station = nil
		for i,station in ipairs(stationList) do
			if station:isValid() then
				if farthest_station == nil then
					farthest_station = station
				else
					if distance(station,obj) > distance(obj,farthest_station) then
						farthest_station = station
					end
				end
			end
		end
		return farthest_station
	else
		return nil
	end
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction)
-- spawn enemies based on player strength
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * enemy_power * playerPower(),5)
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
		ship = CpuShip():setFaction(enemyFaction):setTemplate(stnl[shipTemplateType]):setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
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
--evaluate the players for enemy strength and size spawning purposes
	local playerShipScore = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			playerShipScore = playerShipScore + 24
		else
			playerShipScore = playerShipScore + p.shipScore
		end
	end
	return playerShipScore
end
--	Care and maintenance of repair crew directed by engineer or damage control
function healthCheck()
	if health_check_time == nil then
		health_check_time = getScenarioTime() + healthCheckTimerInterval
	end
	if getScenarioTime() > health_check_time then
		health_check_time = nil
		for i,p in ipairs(getActivePlayerShips()) do
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
				if p:getBeamWeaponRange(0) > 1 then
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
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
		p:setRepairCrewCount(p:getRepairCrewCount() - 1)
		if p:hasPlayerAtPosition("Engineering") then
			repairCrewFatality = "repairCrewFatality"
			p:addCustomMessage("Engineering",repairCrewFatality,_("repairCrew-msgEngineer", "One of your repair crew has perished"))
		end
		if p:hasPlayerAtPosition("Engineering+") then
			repairCrewFatalityPlus = "repairCrewFatalityPlus"
			p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("repairCrew-msgEngineer+", "One of your repair crew has perished"))
		end
	end
end
function endStatistics()
--final page for victory or defeat on main streen. Station stats only for now
	local tp = getPlayerShip(-1)
	local friendly_station_count = 0
	local neutral_station_count = 0
	local enemy_station_count = 0
	for i,station in ipairs(stationList) do
		if station:isValid() then
			if station:isFriendly(tp) then
				friendly_station_count = friendly_station_count + 1
			else
				neutral_station_count = neutral_station_count + 1
			end
		end
	end
	for i,station in ipairs(enemyStationList) do
		if station:isValid() then
			enemy_station_count = enemy_station_count + 1
		end
	end
	gMsg = string.format(_("msgMainscreen","%i out of %i friendly stations survived."),friendly_station_count,startingFriendlyStations)
	gMsg = string.format(_("msgMainscreen","%s\n%i out of %i neutral stations survived."),gMsg,neutral_station_count,startingNeutralStations)
	gMsg = string.format(_("msgMainscreen","%s\n%i out of %i enemy stations survived."),gMsg,enemy_station_count,startingEnemyStations)
	gMsg = string.format(_("msgMainscreen","%s\nMission milestones completed:%i"),gMsg,mission_milestones)
	rankVal = friendly_station_count/startingFriendlyStations*.6 + neutral_station_count/startingNeutralStations*.2 + (1 - enemy_station_count/startingEnemyStations)*.2
	if missionVictory then
		if rankVal < .6 then
			rank = _("msgMainscreen", "Cadet")
		elseif rankVal < .7 then
			rank = _("msgMainscreen", "Ensign")
		elseif rankVal < .8 then
			rank = _("msgMainscreen", "Lieutenant")
		elseif rankVal < .9 then
			rank = _("msgMainscreen", "Commander")
		elseif rankVal < .95 then
			rank = _("msgMainscreen", "Captain")
		else
			rank = _("msgMainscreen", "Admiral")
		end
		gMsg = string.format(_("msgMainscreen","%s\nEarned rank: %s"),gMsg,rank)
	else
		if rankVal < .5 then
			rank = "Cadet"
		elseif rankVal < .6 then
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
		gMsg = string.format(_("msgMainscreen","%s\nRank after several military leaders disappeared: %s"),gMsg,rank)
	end
		-- Yes, the ranking is more forgiving when defeated for these reasons:
		-- 1) With so many deaths on the station, leadership roles have opened up
		--    1a) Harder to get promoted when you succeed with so many surviving competing officers
		-- 2) Simulation of whacky military promotion politics
		-- 3) Incentive to play the mission again
	gMsg = string.format(_("msgMainscreen","%s\nGame duration: %s"),gMsg,formatTime(getScenarioTime()))
	gMsg = string.format(_("msgMainscreen","%s\nSelected difficulty options: Enemy power: %s, Murphy: %s"),gMsg,getScenarioSetting("Enemies"),getScenarioSetting("Murphy"))
	gMsg = string.format(_("msgMainscreen","%s\nCarrier type: %s"),gMsg,getScenarioSetting("Carrier"))
	if getScenarioSetting("Carrier") == "Random" then
		gMsg = string.format(_("msgMainscreen","%s (%s)"),gMsg,carrier_template)
	end
	gMsg = string.format(_("msgMainscreen","%s\nFighter type 1: %s"),gMsg,getScenarioSetting("Fighter1"))
	if getScenarioSetting("Fighter1") == "Random" then
		gMsg = string.format(_("msgMainscreen","%s (%s)"),gMsg,fighter_template)
	end
	gMsg = string.format(_("msgMainscreen","%s\nFighter type 2: %s"),gMsg,getScenarioSetting("Fighter2"))
	if getScenarioSetting("Fighter2") == "Random" then
		gMsg = string.format(_("msgMainscreen","%s (%s)"),gMsg,fighter_template_2)
	end
	globalMessage(gMsg)
end
function update(delta)
	setPlayers()
	if delta == 0 then
		--game paused
		return
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	missionMessages()
	healthCheck()			--health of repair crew
	transportPlot()			--transports
	moveAsteroids()			--asteroids
	friendlyDefense()
	for i,p in ipairs(getActivePlayerShips()) do
		updatePlayerInventoryButton(p)
		if p.tube_size ~= nil then
			local tube_size_banner = string.format(_("tabWeaponsTacticalSingle","%s tubes: %s"),p:getCallSign(),p.tube_size)
			if #p.tube_size == 1 then
				tube_size_banner = string.format(_("tabWeaponsTacticalSingle","%s tube: %s"),p:getCallSign(),p.tube_size)
			end
			p:addCustomInfo("Weapons","tube_sizes_wea",tube_size_banner,2)
			p:addCustomInfo("Tactical","tube_sizes_tac",tube_size_banner,2)
			p:addCustomInfo("Single","tube_sizes_pil",tube_size_banner,2)
		end
		p:addCustomInfo("Helms","name_tag_hlm",string.format(_("tabHelm","%s in %s"),p:getCallSign(),p:getSectorName()),1)
		p:addCustomInfo("Tactical","name_tag_tac",string.format(_("tabTactical","%s in %s"),p:getCallSign(),p:getSectorName()),1)
		p:addCustomInfo("Single","name_tag_pil",string.format(_("tabSingle","%s in %s"),p:getCallSign(),p:getSectorName()),1)
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
	cargoTransfer()			-- cargo transfer
	if playWithTimeLimit then
		if getScenarioTime() > gameTimeLimit then
			missionVictory = false
			endStatistics()
			victory("Ktlitans")
		end
	end
end
