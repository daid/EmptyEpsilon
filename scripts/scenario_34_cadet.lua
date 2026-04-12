-- Name: Cadet Patrol
-- Description: One Phobos class player ship, full of fresh academy graduates assigned to patrol duty.
--- Beginner's mission. Player can save and restore if they can remember their key. The terrain differs each time the scenario runs.
--- Duration: 1 - 2 hours
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
---
--- Voice actors:
--- Andrew "Snow" Kenny
--- Bart K7AAY
--- SANTAtheGREY
--- Xansta
---
--- Version 1 Mar 2025
-- Type: Basic
-- Author: Xansta
require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")

function init()
	scenario_version = "1.0.0"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Cadet Patrol    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	ECS = false
	if createEntity then
		ECS = true
	end
	store = getScriptStorage()
	store_name = "Cadet"
	store_cadet = unStringStore()
	setConstants()
	setGlobals()
	mainGMButtons()
	player = PlayerSpaceship():setTemplate("Phobos M3P"):setPosition(player_spawn_x,player_spawn_y)
	allowNewPlayerShips(false)
	player:setCanCombatManeuver(false):setCanHack(false):setCanSelfDestruct(false)
	player:setCanLaunchProbe(false):setLongRangeRadarRange(20000):setCanDock(false)
	player.normal_long_range_radar = 20000
	player:setTypeName("Phobos M5P")
	player:setWeaponTubeCount(4)
	player:setWeaponTubeDirection(0,  5):setWeaponTubeExclusiveFor(0,"HVLI"):weaponTubeAllowMissle(0,"Homing")
	player:setWeaponTubeDirection(1, -5):setWeaponTubeExclusiveFor(1,"HVLI"):weaponTubeAllowMissle(1,"Homing")
	player:setWeaponTubeDirection(2,  0):setWeaponTubeExclusiveFor(2,"HVLI"):setTubeSize(2,"small")
	player:setWeaponTubeDirection(3,180):setWeaponTubeExclusiveFor(3,"Mine")
	player:setWeaponStorageMax("Nuke",0):setWeaponStorage("Nuke",0)
	player:setWeaponStorageMax("EMP", 0):setWeaponStorage("EMP", 0)
	missions = {
		{
			level =		0,		
			enemy =		true,	
			desc =		"enemy group 1",		
			fleet =		nil,	
			strength =	10,
			lo =		20000,
			hi =		21000,
			faction =	"Exuari",		
			comp =		"Beamers", 
			result =	player.enemy_group_1_destroyed,
		},
		{
			level = 	1,		
			enemy = 	false,	
			desc = 		"get EMPs",
		},
		{
			level = 	2,		
			enemy = 	true,	
			desc = 		"enemy group 2",		
			fleet = 	nil,
			strength =	15,
			lo =		20000,
			hi =		21000,
			faction =	"Kraylor",	
			comp = 		"Beamers", 
			result = 	player.enemy_group_2_destroyed,
		},
		{
			level = 	3,		
			enemy = 	false,	
			desc = 		"greater sensor reach",
		},
		{
			level = 	4,		
			enemy = 	true,	
			desc = 		"enemy group 3",		
			fleet = 	nil,	
			strength =	20,
			lo =		30000,
			hi =		31000,
			faction = 	"Ktlitans",		
			comp = 		"Beamers", 
			result = 	player.enemy_group_3_destroyed,
		},
		{
			level = 	5,		
			enemy = 	false,	
			desc = 		"enable combat maneuver",
		},
		{
			level = 	6,		
			enemy = 	true,	
			desc = 		"enemy group 4",		
			fleet = 	nil,
			strength =	25,
			lo =		30000,
			hi =		31000,
			faction = 	"Ghosts",		
			comp = 		"Random", 
			result = 	player.enemy_group_4_destroyed,
		},
		{
			level = 	7,		
			enemy = 	false,	
			desc = 		"add jump drive",
		},
		{
			level = 	8,		
			enemy = 	true,	
			desc = 		"enemy group 5",	
			fleet = 	nil,
			strength =	30,	
			lo =		30000,
			hi =		31000,
			faction = 	"Kraylor",		
			comp = 		"Random", 
			result = 	player.enemy_group_5_destroyed, 
		},
		{
			level = 	9,	
			enemy = 	false,	
			desc = 		"rescue freighter", 
			result = 	player.rescued_freighter,
		},
		{
			level = 	10,		
			enemy = 	false,	
			desc = 		"get nukes"
		},
		{
			level = 	11,	
			enemy = 	false,	
			desc = 		"get cargo",		
			result = 	player.provided_cargo_to_home_station,
		},
		{
			level = 	12,	
			enemy = 	false,	
			desc = 		"enable probes",
		},
		{
			level =		13,
			enemy =		true,
			desc =		"enemy group 6",
			fleet =		nil,
			strength =	35,
			lo =		31000,
			hi =		35000,
			faction =	"Exuari",
			comp =		"Random",
			result =	player.enemy_group_6_destroyed,
		},
		{
			level =		14,
			enemy =		false,
			desc =		"enable hacking",
		},
		{
			level =		15,
			enemy =		true,
			desc =		"enemy group 7",
			fleet =		nil,
			strength =	40,
			lo =		31000,
			hi =		35000,
			faction =	"Ktlitans",
			comp =		"Random",
			result =	player.enemy_group_7_destroyed,
		},
	}
	constructEnvironment()
end
function setConstants()
	voice_clips = {
		["EnemyVesselsDetected"] =			1.36,
		["HostileShips"] =					1.5,
		["IncomingEnemyVessels"] =			1.331,
		["MakeSureThatFreighterGetsHere"] =	3.159,	
		["SupplyRun"] =						2.049,	
		["WarshipsIdentified"] =			3.326,
		["WarWithTheKraylor"] =				12.728,	
		["WelcomeToTiberius"] =				23.011,	
	}
	center_x = 130000 + random(-15000,15000)
	center_y = 130000 + random(-15000,15000)
	player_spawn_x, player_spawn_y = vectorFromAngle(random(0,360),random(2500,4000))
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	max_repeat_loop = 50
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
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
	transport_factions = {"Independent","Kraylor","Ktlitans","Ghosts","Arlenians","Independent"}
	stems = {
		"ALWAYS",
		"BLACK",
		"BLUE",
		"BRIGHT",
		"BROWN",
		"CHAIN",
		"CHURCH",
		"DOORWAY",
		"DULL",
		"ELBOW",
		"EMPTY",
		"EPSILON",
		"FLOWER",
		"FLY",
		"FROZEN",
		"GREEN",
		"GLOW",
		"HAMMER",
		"HORIZON",
		"INK",
		"JUMP",
		"KEY",
		"LETTER",
		"LIST",
		"MORNING",
		"NEXT",
		"OPEN",
		"ORANGE",
		"OUTSIDE",
		"PURPLE",
		"QUARTER",
		"QUIET",
		"RED",
		"SHINE",
		"SIGMA",
		"STAR",
		"STARSHIP",
		"STREET",
		"TOKEN",
		"THIRSTY",
		"UNDER",
		"VANISH",
		"WHITE",
		"WRENCH",
		"YELLOW",
	}
	fleet_group = {
		["adder"] = "Adders",
		["Adders"] = "adder",
		["missiler"] = "Missilers",
		["Missilers"] = "missiler",
		["beamer"] = "Beamers",
		["Beamers"] = "beamer",
		["frigate"] = "Frigates",
		["Frigates"] = "frigate",
		["chaser"] = "Chasers",
		["Chasers"] = "chaser",
		["fighter"] = "Fighters",
		["Fighters"] = "fighter",
		["drone"] = "Drones",
		["Drones"] = "drone",
	}
	ship_template = {	--ordered by relative strength
		-- normal ships that are part of the fleet spawn process
		["Gnat"] =				{strength = 2,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true,		drone = true,	unusual = false,	base = false,	short_range_radar = 4500,	hop_angle = 0,	hop_range = 580,	create = gnat},
		["Lite Drone"] =		{strength = 3,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 880,	create = stockTemplate},
		["Dagger"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = hornetMV52},
		["MT55 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = hornetMT55},
		["Adder MK4"] =			{strength = 6,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Shepherd"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2880,	create = shepherd},
		["Ktlitan Fighter"] =	{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Touchy"] =			{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 2000,	create = touchy},
		["Blade"] =				{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunner"] =			{strength = 7,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k3fighter},
		["Shooter"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Jagger"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adder MK6"] =			{strength = 8,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK8"] =			{strength = 10,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = waddle5},
		["Jade 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = jade5},
		["Phobos T3"] =			{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Guard"] =				{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco3},
		["Farco 5"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1180,	create = farco5},
		["Karnack"] =			{strength = 17,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunship"] =			{strength = 17,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos T4"] =			{strength = 18,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = phobosT4},
		["Nirvana R5"] =		{strength = 19,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 8"] =			{strength = 19,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco8},
		["Nirvana R5A"] =		{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 90,	hop_range = 580,	create = stockTemplate},
		["Piranha F10"] =		{strength = 21,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = piranhaF10},
		["Farco 11"] =			{strength = 21,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco11},
		["Storm"] =				{strength = 22,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Warden"] =			{strength = 22,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Racer"] =				{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stalkerR5},
		["Stalker Q5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stalkerQ5},
		["Strike"] =			{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Dash"] =				{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Farco 13"] =			{strength = 24,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = farco13},
		["Sentinel"] =			{strength = 24,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Ranus U"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Flash"] =				{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Ranger"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Buster"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Whirlwind"] =			{strength = 26,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = whirlwind},
		["Hunter"] =			{strength = 26,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Elara P2"] =			{strength = 28,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = elaraP2},
		["Tempest"] =			{strength = 30,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = tempest},
		["Strikeship"] =		{strength = 30,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = fiendG3},
		["Maniapak"] =			{strength = 34,	adder = true,	missiler = false,	beamer = false,	frigate = false, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = maniapak},
		["Fiend G4"] =			{strength = 35,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = fiendG4},
		["Cucaracha"] =			{strength = 36,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = cucaracha},
		["Fiend G5"] =			{strength = 37,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = fiendG5},
		["Fiend G6"] =			{strength = 39,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = fiendG6},
		["Barracuda"] =			{strength = 40,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = barracuda},
		["Ryder"] =				{strength = 41, adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 90,	hop_range = 1180,	create = stockTemplate},
		["Predator"] =			{strength = 42,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7500,	hop_angle = 0,	hop_range = 980,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = stockTemplate},
		["Hurricane"] =			{strength = 46,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 15,	hop_range = 2500,	create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = k2breaker},
		["Atlantis Y42"] =		{strength = 60,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 63,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 1480,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer III"] =	{strength = 85,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 12000,	hop_angle = 0,	hop_range = 1480,	create = starhammerIII},
		["Starhammer V"] =		{strength = 90,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 15000,	hop_angle = 0,	hop_range = 1480,	create = starhammerV},
		["Battlestation"] =		{strength = 100,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2480,	create = stockTemplate},
		["Fortress"] =			{strength = 130,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2380,	create = stockTemplate},
		["Tyr"] =				{strength = 150,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9500,	hop_angle = 90,	hop_range = 2480,	create = tyr},
		["Odin"] =				{strength = 250,adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 20000,	hop_angle = 0,	hop_range = 3180,	create = stockTemplate},
	}
	formation_delta = {
		["square"] = {
			x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4},
			y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5},
		},
		["hexagonal"] = {
			x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0},
			y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6},
		},
		["pyramid"] = {
			[1] = {
				{angle =  0, distance = 0},
			},
			[2] = {
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
			},
			[3] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},				
			},
			[4] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle =  0, distance = 2},	
			},
			[5] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
			},
			[6] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
			},
			[7] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
			},
			[8] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
			},
			[9] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -4, distance = 4},
				{angle =  4, distance = 4},
			},
			[10] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -2, distance = 3},
				{angle =  2, distance = 3},
			},
			[11] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -4, distance = 4},
				{angle =  4, distance = 4},
				{angle = -3, distance = 4},
				{angle =  3, distance = 4},
			},
			[12] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle = -2, distance = 3},
				{angle =  2, distance = 3},
				{angle = -1, distance = 3},
				{angle =  1, distance = 3},
			},
			[13] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 3},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
			[14] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 4},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
			[15] = {
				{angle =  0, distance = 0},
				{angle = -1, distance = 1},
				{angle =  1, distance = 1},
				{angle = -2, distance = 2},
				{angle =  2, distance = 2},
				{angle =  0, distance = 2},	
				{angle = -3, distance = 3},
				{angle =  3, distance = 3},
				{angle =  0, distance = 3},
				{angle =  0, distance = 4},
				{angle = -2, distance = 4},
				{angle =  2, distance = 4},
				{angle = -1, distance = 5},
				{angle =  1, distance = 5},
				{angle =  0, distance = 6},
			},
		},
	}
	station_spacing = {
		["Small Station"] =		{touch = 300,	defend = 2600,	platform = 1200,	outer_platform = 7500},
		["Medium Station"] =	{touch = 1200,	defend = 4000,	platform = 2400,	outer_platform = 9100},
		["Large Station"] =		{touch = 1400,	defend = 4600,	platform = 2800,	outer_platform = 9700},
		["Huge Station"] =		{touch = 2000,	defend = 4960,	platform = 3500,	outer_platform = 10100},
	}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
end
function setGlobals()
	server_voices = true
	voice_queue = {}
	voice_played = {}
	clean_up_messages = {}
	build_defense_platforms = {}
	sensor_impact = 1	--normal
	player_ship_names_for = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Atlantis II"] =		{"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Hathcock"] =			{"Hayha","Waldron","Plunkett","Mawhinney","Furlong","Zaytsev","Pavlichenko","Pegahmagabow","Fett","Hawkeye","Hanzo"},
		["Kiriya"] =			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["Maverick"] =			{"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Nautilus"] =			{"October","Abdiel","Manxman","Newcon","Nusret","Pluton","Amiral","Amur","Heinkel","Dornier"},
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Phobos M5P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde","Rage","Cogitate","Thrust","Coyote"},
		["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Proto-Atlantis"] =	{"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"},
		["Redhook"] =			{"Headhunter", "Thud", "Troll", "Scalper", "Shark"},
		["Repulse"] =			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Saipan"] =			{"Atlas", "Bernard", "Alexander", "Retribution", "Sulaco", "Conestoga", "Saratoga", "Pegasus"},
		["Stricken"] =			{"Blazon", "Streaker", "Pinto", "Spear", "Javelin"},
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["Surkov"] =			{"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Leftovers"] =			{"Foregone","Righteous","Scandalous"},
	}
	fleetComposition = "Random"
	template_pool_size = 10
	advertising_billboards = {
		_("scienceDescription-buoy","Come to Billy Bob's for the best food in the sector"),
		_("scienceDescription-buoy","It's never too late to buy life insurance"),
		_("scienceDescription-buoy","You'll feel better in an Adder Mark 9"),
		_("scienceDescription-buoy","Melinda's Mynock Management service: excellent rates, satisfaction guaranteed"),
		_("scienceDescription-buoy","Visit Repulse shipyards for the best deals"),
		_("scienceDescription-buoy","Fresh fish! We catch, you buy!"),
		_("scienceDescription-buoy","Get your fuel cells at Mariana's Market"),
		_("scienceDescription-buoy","Find a special companion. All species available"),
		_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
		_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
		_("scienceDescription-buoy","Be sure to drink your Ovaltine"),
		_("scienceDescription-buoy","Need a personal upgrade? Contact Celine's Cybernetic Implants"),
		_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
		_("scienceDescription-buoy","Best tasting water in the quadrant at Willy's Waterway"),
		_("scienceDescription-buoy","Amazing shows every night at Lenny's Lounge"),
		_("scienceDescription-buoy","Get all your vaccinations at Fred's Pharmacy. Pick up some snacks, too"),
		_("scienceDescription-buoy","Tip: make lemons an integral part of your diet"),
	}
	artifact_number = 0
	sensor_jammer_list = {}
	warp_jammer_list = {}
	warp_jammer_info = {
		["Human Navy"] =	{id = "H", count = 0},
		["Independent"] =	{id = "I", count = 0},
		["Kraylor"] =		{id = "K", count = 0},
		["Arlenians"] =		{id = "A", count = 0},
		["Exuari"] =		{id = "E", count = 0},
		["Ghosts"] =		{id = "G", count = 0},
		["Ktlitans"] =		{id = "B", count = 0},
		["TSN"] =			{id = "T", count = 0},
		["USN"] =			{id = "U", count = 0},
		["CUF"] =			{id = "C", count = 0},
		["Mehklar"] =		{id = "M", count = 0},
	}
	star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			name = {
				"Gamma Piscium",
				"Beta Lyporis",
				"Sigma Draconis",
				"Iota Carinae",
				"Theta Arietis",
				"Epsilon Indi",
				"Beta Hydri",
				"Acamar",
				"Bellatrix",
				"Castula",
				"Dziban",
				"Elnath",
				"Flegetonte",
				"Geminga",
				"Helvetios",
				"Inquill",
				"Jishui",
				"Kaus Borealis",
				"Liesma",
				"Macondo",
				"Nikawiy",
				"Orkaria",
				"Poerava",
				"Stribor",
				"Taygeta",
				"Tuiren",
				"Ukdah",
				"Wouri",
				"Xihe",
				"Yildun",
				"Zosma",
			},
			color = {
				red = random(0.5,1), green = random(0.5,1), blue = random(0.5,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
end
function isObjectType(obj,typ)
	if obj ~= nil and obj:isValid() then
		if typ ~= nil then
			if ECS then
				if typ == "SpaceStation" then
					return obj.components.docking_bay and obj.components.physics and obj.components.physics.type == "static"
				elseif typ == "PlayerSpaceship" then
					return obj.components.player_control
				elseif typ == "ScanProbe" then
					return obj.components.allow_radar_link
				elseif typ == "CpuShip" then
					return obj.components.ai_controller
				elseif typ == "Asteroid" then
					return obj.components.mesh_render and string.sub(obj.components.mesh_render.mesh, 7) == "Astroid"
				else
					return false
				end
			else
				return obj.typeName == typ
			end
		else
			return false
		end
	else
		return false
	end
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
	local store_slot_count = 0
	for i,exp in pairs(store_cadet) do
		store_slot_count = store_slot_count + 1
	end
	if store_slot_count > 0 then
		addGMFunction(_("buttonGM","Stored ships"),function()
			local out = _("msgGM","These are the ships encrypted in storage:")
			for i,exp in pairs(store_cadet) do
				out = string.format(_("msgGM","%s\nKey:%s Name:%s Level:%s"),out,i,exp.name,exp.level)
			end
			addGMMessage(out)
		end)
		addGMFunction(_("buttonGM","Delete storage"),function()
			local ship_number = 0
			local out = _("msgGM","Deleted these encrypted ships:")
			for i,exp in pairs(store_cadet) do
				store:set(string.format(_("msgGM","%s-%s-name"),store_name,i),"")
				store:set(string.format(_("msgGM","%s-%s-level"),store_name,i),"")
				ship_number = ship_number + 1
				store:set(ship_number,"")
				out = string.format(_("msgGM","%s\n%s"),out,i)
			end
			addGMMessage(out)
			mainGMButtons()
		end)
	end
end
function constructEnvironment()
	inner_space = {}
	inner_stations = {}
	home_station = placeStation(center_x,center_y,"Tiberius","Human Navy","Large Station")
	home_station.comms_data = {}
	home_station.comms_data.friendlyness = random(50,100)
	home_station.comms_data.weapon_available = {}
	home_station.comms_data.weapon_available.Nuke = true
	home_station.comms_data.weapon_available.EMP = true
	home_station.comms_data.weapon_available.Homing = true
	home_station.comms_data.weapon_available.Mine = true
	home_station.comms_data.weapon_available.HVLI = true
	table.insert(inner_space,{obj=home_station,dist=station_spacing[home_station:getTypeName()].outer_platform,shape="circle"})
	table.insert(inner_stations,home_station)
	local approach_angle = random(0,360)
	local ax, ay = vectorFromAngle(approach_angle,random(3000,6000))
	local builder = CpuShip():setTemplate("Equipment Freighter 4"):setPosition(center_x + ax,center_y + ay):setScanStateByFaction("Human Navy","simplescan"):setFaction("Independent"):setCallSign(generateCallSign(nil,"Independent"))
	table.insert(build_defense_platforms,{freighter=builder,station=home_station,angle=approach_angle,cur=1,prefix="TDP"})
	nemesis_angle = random(0,360)
	local nx, ny = vectorFromAngle(nemesis_angle,random(18000,28000),true)
	nx = nx + center_x
	ny = ny + center_y
	Nebula():setPosition(nx,ny)
	local nlx, nly = vectorFromAngle((nemesis_angle + 90 + random(-25,40))%360,random(7000,9500),true)
	nlx = nlx + nx
	nly = nly + ny
	Nebula():setPosition(nlx,nly)
	local nrx, nry = vectorFromAngle((nemesis_angle - 90 + 360 + random(-40,25))%360,random(7000,9500),true)
	nrx = nrx + nx
	nry = nry + ny
	Nebula():setPosition(nrx,nry)
	local nemesis_dist = random(50000,80000)
	local psx, psy = vectorFromAngle((nemesis_angle + random(-8,8) + 360)%360,nemesis_dist,true)
	nemesis_station = placeStation(psx + center_x, psy + center_y,"Sinister","Kraylor","Large Station")
	table.insert(inner_space,{obj=nemesis_station,dist=station_spacing[nemesis_station:getTypeName()].outer_platform,shape="circle"})
	table.insert(inner_stations,nemesis_station)
	local sjx, sjy = vectorFromAngle(nemesis_angle,nemesis_dist - 10000,true)
	local lo_range = 20000
	local hi_range = 40000
	local lo_impact = 20000
	local hi_impact = 40000
	local range_increment = (hi_range - lo_range)/8
	local impact_increment = (hi_impact - lo_impact)/4
--	local mix = math.random(2,10 - (4 - (2)))	--	2-8
	local mix = math.random(6,8)	--	6-8
	sensor_jammer_scan_complexity = 1 
	sensor_jammer_scan_depth = 1
	if mix > 5 then
		sensor_jammer_scan_depth = math.min(math.random(mix-4,mix),8)
		sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
	else
		sensor_jammer_scan_depth = math.random(1,mix)
		sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
	end
	sensor_jammer_range = lo_range + (sensor_jammer_scan_depth*range_increment)
	sensor_jammer_impact = lo_impact + (sensor_jammer_scan_complexity*impact_increment)
	local sj = sensorJammer(sjx + center_x, sjy + center_y)
	table.insert(inner_space,{obj=sj,dist=200,shape="circle"})
	ax, ay = vectorFromAngle(approach_angle,random(3000,6000))
	builder = CpuShip():setTemplate("Equipment Freighter 4"):setPosition(center_x + ax + psx,center_y + ay + psy):setFaction("Independent"):setCallSign(generateCallSign(nil,"Independent"))
	table.insert(build_defense_platforms,{freighter=builder,station=nemesis_station,angle=approach_angle,cur=1,prefix="KDP"})
	local factions = {"Human Navy","TSN","USN","CUF","Ghosts","Independent","Arlenians","Exuari","Ktlitans"}
	local enemy_factions = {
		["Ghosts"] = true,
		["Exuari"] = true,
		["Kraylor"] = true,
		["Ktlitans"] = true,
	}
	distort_bell = {
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},	
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},
		{lo = 1000,	hi = 8000},	
		{lo = 1000,	hi = 8000},
	}
	for i,faction in ipairs(factions) do
		local psx, psy = findClearSpot(inner_space,"bell torus",center_x,center_y,100000,distort_bell,nil,12000,true)
		if psx ~= nil then
			local station_name = "RandomHumanNeutral"
			if enemy_factions[faction] then
				station_name = "Sinister"
			end
			local station = placeStation(psx,psy,station_name,faction)
			table.insert(inner_space,{obj=station,dist=station_spacing[station:getTypeName()].outer_platform,shape="circle"})
			table.insert(inner_stations,station)
		else
			print(string.format("could not find a place for a %s station",faction))
		end
	end
	distort_bell = {
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},	
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},
		{lo = 1000,	hi = 12000},	
		{lo = 1000,	hi = 12000},
	}
	table.insert(factions,"Kraylor")
	for i,faction in ipairs(factions) do
		local psx, psy = findClearSpot(inner_space,"bell torus",center_x,center_y,120000,distort_bell,nil,12000,true)
		if psx ~= nil then
			local station_name = "RandomHumanNeutral"
			if enemy_factions[faction] then
				station_name = "Sinister"
			end
			local station = placeStation(psx,psy,station_name,faction)
			table.insert(inner_space,{obj=station,dist=station_spacing[station:getTypeName()].outer_platform,shape="circle"})
			table.insert(inner_stations,station)
		else
			print(string.format("could not find a place for a %s station",faction))
		end
	end
	for i=1,5 do
		local psx, psy = findClearSpot(inner_space,"bell torus",center_x,center_y,120000,distort_bell,nil,12000,true)
		if psx ~= nil then
			local station_name = "RandomHumanNeutral"
			local station = placeStation(psx,psy,station_name,"Independent")
			table.insert(inner_space,{obj=station,dist=station_spacing[station:getTypeName()].outer_platform,shape="circle"})
			table.insert(inner_stations,station)
		else
			print("Could not find a place for an Independent station")
		end
	end
	transport_list = {}
	placement_areas = {
		["Circle Region"] = {
			stations = inner_stations,
			transports = transport_list, 
			space = inner_space,
			shape = "bell torus", 
			center_x = center_x, 
			center_y = center_y, 
			radius = 120000,
		},
	}
	local terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
		{chance = 4,	count = 0,	max = math.random(7,15),	radius = "Tiny",	obj = WarpJammer,						},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Tiny",	obj = Artifact,		desc = "Jammer",	},
		{chance = 3,	count = 0,	max = math.random(1,3),		radius = "Hole",	obj = WormHole,							},
		{chance = 6,	count = 0,	max = math.random(1,2),		radius = "Tiny",	obj = Artifact,		desc = "Sensor",	},
		{chance = 8,	count = 0,	max = -1,					radius = "Tiny",	obj = Artifact,		desc = "Ad",		},
		{chance = 8,	count = 0,	max = -1,					radius = "Neb",		obj = Nebula,							},
		{chance = 5,	count = 0,	max = -1,					radius = "Mine",	obj = Mine,								},
		{chance = 5,	count = 0,	max = math.random(3,9),		radius = "Circ",	obj = Mine,			desc = "Circle",	},
		{chance = 5,	count = 0,	max = math.random(3,9),		radius = "Rect",	obj = Mine,			desc = "Rectangle",	},
		{chance = 5,	count = 0,	max = math.random(2,5),		radius = "Field",	obj = Asteroid,		desc = "Field",		},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Blob",	obj = Asteroid,		desc = "Blob",		},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Blob",	obj = Mine,			desc = "Blob",		},
		{chance = 4,	count = 0,	max = 10,					radius = "Trans",	obj = CpuShip,		desc = "Transport",	},
	}
	local objects_placed_count = 0
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			local placement_result = false
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					placement_result = placeTerrain("Circle Region",terrain_object)
				else
					placement_result = placeTerrain("Circle Region",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				end
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
				break
			elseif i == #terrain then
				placement_result = placeTerrain("Circle Region",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 100)
end
function findClearSpot(objects,area_shape,area_point_x,area_point_y,area_distance,area_distance_2,area_angle,new_buffer,placing_station)
	--area distance 2 is only required for torus areas, bell torus areas and rectangle areas
	--area angle is only required for rectangle areas
	assert(type(objects)=="table",string.format("function findClearSpot expects an object list table as the first parameter, but got a %s instead",type(objects)))
	assert(type(area_shape)=="string",string.format("function findClearSpot expects an area shape string as the second parameter, but got a %s instead",type(area_shape)))
	assert(type(area_point_x)=="number",string.format("function findClearSpot expects an area point X coordinate number as the third parameter, but got a %s instead",type(area_point_x)))
	assert(type(area_point_y)=="number",string.format("function findClearSpot expects an area point Y coordinate number as the fourth parameter, but got a %s instead",type(area_point_y)))
	assert(type(area_distance)=="number",string.format("function findClearSpot expects an area distance number as the fifth parameter, but got a %s instead",type(area_distance)))
	local valid_shapes = {"circle","torus","rectangle"}
	assert(valid_shapes[area_shape] == nil,string.format("function findClearSpot expects a valid shape in the second parameter, but got %s instead",area_shape))
	assert(type(new_buffer)=="number",string.format("function findClearSpot expects a new item buffer distance number as the eighth parameter, but got a %s instead",type(new_buffer)))
	local valid_table_item_shapes = {"circle","zone"}
	local far_enough = true
	local current_loop_count = 0
	local cx, cy = 0	--candidate x and y coordinates
	if area_shape == "circle" then
		repeat
			current_loop_count = current_loop_count + 1
			cx, cy = vectorFromAngle(random(0,360),random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table" or type(item.obj)=="userdata",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
				if item.shape == "zone" then
					assert(type(item.obj)=="table" or type(item.obj)=="userdata",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ta = Artifact():setPosition(cx,cy)
					if item.obj:isInside(ta) then
						far_enough = false
					end
					ta:destroy()
					if not far_enough then
						break
					end
				end
			end
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "bell torus" then
		assert(type(area_distance_2)=="table",string.format("function findClearSpot expects a table of random range parameters as the sixth parameter when the shape is bell torus, but got a %s instead",type(area_distance_2)))
		repeat
			local lo = 0
			local hi = 0
			for i,dist in ipairs(area_distance_2) do
				lo = lo + dist.lo
				hi = hi + dist.hi
			end
			cx, cy = vectorFromAngle(random(0,360),random(lo,hi),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table" or type(item.obj)=="userdata",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "torus" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number as the sixth parameter when the shape is torus, but got a %s instead",type(area_distance_2)))
		repeat
			cx, cy = vectorFromAngle(random(0,360),random(area_distance,area_distance_2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table" or type(item.obj)=="userdata",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "central rectangle" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(-area_distance/2,area_distance/2),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table" or type(item.obj)=="userdata",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	elseif area_shape == "rectangle" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number (width) as the sixth parameter when the shape is rectangle, but got a %s instead",type(area_distance_2)))
		assert(type(area_angle)=="number",string.format("function findClearSpot expects an area angle number as the seventh parameter when the shape is rectangle, but got a %s instead",type(area_angle)))
		repeat
			cx, cy = vectorFromAngle(area_angle,random(0,area_distance),true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngle(area_angle + 90,random(-area_distance_2/2,area_distance_2/2),true)
			cx = cx + px
			cy = cy + py
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table" or type(item.obj)=="userdata",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil and placing_station and isObjectType(item.obj,"SpaceStation") then
						comparison_dist = 12000
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
			end
			current_loop_count = current_loop_count + 1
		until(far_enough or current_loop_count > max_repeat_loop)
		if current_loop_count > max_repeat_loop then
			return
		else
			return cx, cy
		end
	end
end
function placeTerrain(placement_area,terrain)
	local function getStationPool(placement_area)
		local station_pool = {}
		if placement_areas[placement_area].stations ~= nil and #placement_areas[placement_area].stations > 0 then
			for i,station in ipairs(placement_areas[placement_area].stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		return station_pool
	end
	local function placeAsteroid(placement_area)
		local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
		local area = placement_areas[placement_area]
		local eo_x, eo_y = nil
		if placement_area == "Circle Region" then
			if asteroid_size == nil then print("1280 asteroid size is nil") end
			eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,distort_bell,nil,asteroid_size)
		end
		if eo_x ~= nil then
			local ta = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
			table.insert(area.space,{obj=ta,dist=asteroid_size,shape="circle"})
			local tether = random(asteroid_size + 10,800)
			local v_angle = random(0,360)
			local vx, vy = vectorFromAngle(v_angle,tether,true)
			vx = vx + eo_x
			vy = vy + eo_y
			local vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
			tether = random(asteroid_size + 10, asteroid_size + 800)
			v_angle = (v_angle + random(120,240)) % 360
			local vx, vy = vectorFromAngle(v_angle,tether,true)
			vx = vx + eo_x
			vy = vy + eo_x
			vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
			return true
		else
			return false
		end
	end
	local radii = {
		["Blob"] =	random(1500,4500),
		["Star"] =	random(600,1400),
		["Hole"] =	6000,
		["Tiny"] = 	200,
		["Neb"] =	3000,
		["Mine"] =	1000,
		["Rect"] =	random(4000,10000),
		["Circ"] =	4000,
		["Field"] =	random(2000,8000),
		["Trans"] =	600,
	}
	local area = placement_areas[placement_area]
	local radius = radii[terrain.radius]
	if radius == nil then
		radius = 200
	end
	local eo_x, eo_y = nil
	--	exceptions to a simple radius for findClearSpot
	local field_size = 0
	if terrain.desc == "Circle" then
		field_size = math.random(1,3)
		radius = radius + (field_size * 1500)
	elseif terrain.desc == "Field" then
		field_size = radius
		radius = radius + 500 
	end
	if placement_area == "Circle Region" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,distort_bell,nil,radius)
	end
	if eo_x ~= nil then
		if terrain.obj == WormHole then
			local we_x, we_y = nil
			local count_repeat_loop = 0
			repeat
				if placement_area == "Circle Region" then
					we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,distort_bell,nil,500)
				end
				count_repeat_loop = count_repeat_loop + 1
			until((we_x ~= nil and distance(eo_x, eo_y, we_x, we_y) > 50000) or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times while placing a wormhole")
				print("eo_x:",eo_x,"eo_y:",eo_y,"we_x:",we_x,"we_y:",we_y)
			end
			if we_x ~= nil then
				local wh = WormHole():setPosition(eo_x, eo_y):setTargetPosition(we_x, we_y)
				wh:onTeleportation(function(self,transportee)
					string.format("")
					if transportee ~= nil and transportee:isValid() and isObjectType(transportee,"PlayerSpaceship") then
						transportee:setEnergy(transportee:getMaxEnergy()/2)	--reduces if more than half, increases if less than half
					end
				end)
				local va_exit = VisualAsteroid():setPosition(we_x, we_y)
				table.insert(area.space,{obj=wh,dist=6000,shape="circle"})
				table.insert(area.space,{obj=va_exit,dist=500,shape="circle"})
				return true
			else
				placeAsteroid(placement_area)
				return false
			end
		elseif terrain.desc == "Jammer" then
			local lo_range = 10000
			local hi_range = 30000
			local lo_impact = 10000
			local hi_impact = 20000
			local range_increment = (hi_range - lo_range)/8
			local impact_increment = (hi_impact - lo_impact)/4
		--	local mix = math.random(2,10 - (4 - (2*math.floor(difficulty))))	--	2-6, 2-8, 2-10
			local mix = math.random(2,10 - (4 - (2)))	--	2-8
			sensor_jammer_scan_complexity = 1 
			sensor_jammer_scan_depth = 1
			if mix > 5 then
				sensor_jammer_scan_depth = math.min(math.random(mix-4,mix),8)
				sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
			else
				sensor_jammer_scan_depth = math.random(1,mix)
				sensor_jammer_scan_complexity = math.max(mix - sensor_jammer_scan_depth,1)
			end
			sensor_jammer_range = lo_range + (sensor_jammer_scan_depth*range_increment)
			sensor_jammer_impact = lo_impact + (sensor_jammer_scan_complexity*impact_increment)
			local sj = sensorJammer(eo_x, eo_y)
			table.insert(area.space,{obj=sj,dist=radius,shape="circle"})
			return true
		elseif terrain.desc == "Circle" then
			local mine_circle = {
				{inner_count = 4,	mid_count = 10,		outer_count = 15},	--1
				{inner_count = 9,	mid_count = 15,		outer_count = 20},	--2
				{inner_count = 15,	mid_count = 20,		outer_count = 25},	--3
			}
			--	field_size randomized earlier (1 to 3)
			local angle = random(0,360)
			local mine_x, mine_y = 0
			for i=1,mine_circle[field_size].inner_count do
				mine_x, mine_y = vectorFromAngle(angle,field_size * 1000)
				local m = Mine():setPosition(eo_x + mine_x, eo_y + mine_y)
				table.insert(area.space,{obj=m,dist=1000,shape="circle"})
				angle = (angle + (360/mine_circle[field_size].inner_count)) % 360
			end
			for i=1,mine_circle[field_size].mid_count do
				mine_x, mine_y = vectorFromAngle(angle,field_size * 1000 + 1200)
				local m = Mine():setPosition(eo_x + mine_x, eo_y + mine_y)
				table.insert(area.space,{obj=m,dist=1000,shape="circle"})
				angle = (angle + (360/mine_circle[field_size].mid_count)) % 360
			end
			if random(1,100) < 50 then
				local n_x, n_y = vectorFromAngle(random(0,360),random(50,2000))
				Nebula():setPosition(eo_x + n_x, eo_y + n_y)
			end
			return true
		elseif terrain.desc == "Field" then	--asteroid field
			local asteroid_field = {}
			for n=1,math.floor(field_size/random(300,500)) do
				local asteroid_size = 0
				for s=1,4 do
					asteroid_size = asteroid_size + random(2,200)
				end
				local dist = random(100,field_size)
				local x,y = findClearSpot(asteroid_field,"bell torus",eo_x,eo_y,field_size,distort_bell,nil,asteroid_size)
				if x ~= nil then
					local ast = Asteroid():setPosition(x,y):setSize(asteroid_size)
					table.insert(area.space,{obj=ast,dist=asteroid_size,shape="circle"})
					table.insert(asteroid_field,{obj=ast,dist=asteroid_size,shape="circle"})
					local tether = random(asteroid_size + 10,800)
					local v_angle = random(0,360)
					local vx, vy = vectorFromAngle(v_angle,tether,true)
					vx = vx + x
					vy = vy + y
					local vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
					tether = random(asteroid_size + 10, asteroid_size + 800)
					v_angle = (v_angle + random(120,240)) % 360
					local vx, vy = vectorFromAngle(v_angle,tether,true)
					vx = vx + x
					vy = vy + y
					vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
				else
					break
				end
			end
			return true
		elseif terrain.desc == "Transport" then
			local ship, ship_size = randomTransportType()
			if transport_faction_list == nil or #transport_faction_list == 0 then
				transport_faction_list = {}
				for i,faction in pairs(transport_factions) do
					table.insert(transport_faction_list,faction)
				end
			end
			ship:setPosition(eo_x, eo_y):setFaction(tableRemoveRandom(transport_faction_list))
			ship:setCallSign(generateCallSign(nil,ship:getFaction()))
			table.insert(area.space,{obj=ship,dist=600,shape="circle"})
			table.insert(transport_list,ship)
			return true
		else
			local object = terrain.obj():setPosition(eo_x,eo_y)
			local dist = radius
			if terrain.desc == "Blob" or terrain.desc == "Rectangle" then
				local objects = {}
				table.insert(objects,object)
				local reached_the_edge = false
				local object_space = 1400
				if terrain.desc == "Blob" then
					local asteroid_size = 0
					if terrain.obj == Asteroid then
						asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
						object:setSize(asteroid_size)
					end
					repeat
						local overlay = false
						local new_obj_x, new_obj_y = nil
						repeat
							overlay = false
							local base_obj_index = math.random(1,#objects)
							local base_object = objects[base_obj_index]
							local base_obj_x, base_obj_y = base_object:getPosition()
							local angle = random(0,360)
							if terrain.obj == Asteroid then
								asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
								object_space = (base_object:getSize() + asteroid_size) * random(1.05,1.25)
							end
							new_obj_x, new_obj_y = vectorFromAngle(angle,object_space,true)
							new_obj_x = new_obj_x + base_obj_x
							new_obj_y = new_obj_y + base_obj_y
							for i,obj in ipairs(objects) do
								if i ~= base_obj_index then
									local compare_obj_x, compare_obj_y = obj:getPosition()
									local obj_dist = distance(compare_obj_x,compare_obj_y,new_obj_x,new_obj_y)
									if obj_dist < object_space then
										overlay = true
										break
									end
								end
							end
						until(not overlay)
						object = terrain.obj():setPosition(new_obj_x, new_obj_y)
						if terrain.obj == Asteroid then
							object:setSize(asteroid_size)
						end
						table.insert(objects,object)
						if distance(eo_x, eo_y, new_obj_x, new_obj_y) > radius then
							reached_the_edge = true
						end
					until(reached_the_edge)
				elseif terrain.desc == "Rectangle" then
					local long_axis = random(0,360)
					local reach_index = 0
					local new_mine_x, new_mine_y = 0
					repeat
						reach_index = reach_index + 1
						new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
						new_obj_x = new_obj_x + eo_x
						new_obj_y = new_obj_y + eo_y
						if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
							reached_the_edge = true
						else
							if random(1,100) < 77 then
								table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
							end
							new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
							new_obj_x = new_obj_x + eo_x
							new_obj_y = new_obj_y + eo_y
							if random(1,100) < 77 then
								table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
							end
						end
					until(reached_the_edge)
					if random(1,100) < 69 then
						reach_index = 0
						reached_the_edge = false
						local new_line_x, new_line_y = vectorFromAngle((long_axis + 90) % 360,object_space,true)
						new_line_x = new_line_x + eo_x
						new_line_y = new_line_y + eo_y
						table.insert(objects,Mine():setPosition(new_line_x, new_line_y))
						repeat
							reach_index = reach_index + 1
							new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
							new_obj_x = new_obj_x + new_line_x
							new_obj_y = new_obj_y + new_line_y
							if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
								reached_the_edge = true
							else
								if random(1,100) < 77 then
									table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
								end
								new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
								new_obj_x = new_obj_x + new_line_x
								new_obj_y = new_obj_y + new_line_y
								if random(1,100) < 77 then
									table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
								end
							end
						until(reached_the_edge)
						if random(1,100) < 28 then
							reach_index = 0
							reached_the_edge = false
							new_line_x, new_line_y = vectorFromAngle((long_axis + 270) % 360,object_space,true)
							new_line_x = new_line_x + eo_x
							new_line_y = new_line_y + eo_y
							table.insert(objects,Mine():setPosition(new_line_x, new_line_y))
							repeat
								reach_index = reach_index + 1
								new_obj_x, new_obj_y = vectorFromAngle(long_axis,object_space * reach_index,true)
								new_obj_x = new_obj_x + new_line_x
								new_obj_y = new_obj_y + new_line_y
								if distance(new_obj_x,new_obj_y,eo_x,eo_y) > radius then
									reached_the_edge = true
								else
									if random(1,100) < 77 then
										table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
									end
									new_obj_x, new_obj_y = vectorFromAngle((long_axis + 180) % 360,object_space * reach_index,true)
									new_obj_x = new_obj_x + new_line_x
									new_obj_y = new_obj_y + new_line_y
									if random(1,100) < 77 then
										table.insert(objects,Mine():setPosition(new_obj_x, new_obj_y))
									end
								end
							until(reached_the_edge)
						end
					end
				end
				for i,object in ipairs(objects) do
					dist = object_space
					if isObjectType(object,"Asteroid") then
						dist = object:getSize()
						local tether_x, tether_y = object:getPosition()
						local tether_length = random(dist + 10, 800)
						local vis_ast_angle = random(0,360)
						local vx, vy = vectorFromAngle(vis_ast_angle,tether_length,true)
						vx = vx + tether_x
						vy = vy + tether_y
						VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether_length))
						tether_length = random(dist + 10, dist + 800)
						vis_ast_angle = (vis_ast_angle + random(120,240)) % 360
						vx, vy = vectorFromAngle(vis_ast_angle,tether_length,true)
						vx = vx + tether_x
						vy = vy + tether_y
						VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether_length))
					end
					table.insert(area.space,{obj=object,dist=dist,shape="circle"})
				end
				return true
			else	--not blob or rectangle
				if terrain.desc == "Star" then
					object:setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5)
					if random(1,100) < 43 then
						object:setDistanceFromMovementPlane(radius*.5)
					end
					object:setCallSign(tableRemoveRandom(star_list[1].name))
					object:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
					dist = radius + 1000
				elseif terrain.obj == ScanProbe then
					local station_pool = getStationPool(placement_area)
					local owner = tableSelectRandom(station_pool)
					local s_x, s_y = owner:getPosition()
					object:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y):setPosition(s_x,s_y)
					object = VisualAsteroid():setPosition(eo_x,eo_y)
				elseif terrain.obj == WarpJammer then
					local closest_station_distance = 999999
					local closest_station = nil
					local station_pool = getStationPool(placement_area)
					for i, station in ipairs(station_pool) do
						local current_distance = distance(station, eo_x, eo_y)
						if current_distance < closest_station_distance then
							closest_station_distance = current_distance
							closest_station = station
						end
					end
					local selected_faction = closest_station:getFaction()
					local warp_jammer_range = 0
					for i=1,5 do
						warp_jammer_range = warp_jammer_range + random(1000,4000)
					end
					object:setRange(warp_jammer_range):setFaction(selected_faction)
					warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
					object:setCallSign(string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count))
					object.range = warp_jammer_range
					table.insert(warp_jammer_list,object)
				elseif terrain.desc == "Sensor" then
					object:setScanningParameters(math.random(1,2),math.random(1,2)):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
					local buoy_type_list = {}
					local buoy_type = ""
					local station_pool = getStationPool(placement_area)
					local out = ""
					if #station_pool > 0 then
						table.insert(buoy_type_list,"station")
					end
					if transport_list ~= nil and #transport_list > 0 then
						table.insert(buoy_type_list,"transport")
					end
					if #buoy_type_list > 0 then
						buoy_type = tableSelectRandom(buoy_type_list)
						if buoy_type == "station" then
							local selected_stations = {}
							for i, station in ipairs(station_pool) do
								table.insert(selected_stations,station)
							end
							for i=1,3 do
								if #selected_stations > 0 then
									local station = tableRemoveRandom(selected_stations)
									if out == "" then
										out = string.format(_("scienceDescription-buoy","Sensor Record: %s station %s in %s"),station:getFaction(),station:getCallSign(),station:getSectorName())
									else
										out = string.format(_("scienceDescription-buoy","%s, %s station %s in %s"),out,station:getFaction(),station:getCallSign(),station:getSectorName())
									end
								else
									break
								end
							end
						end
						if buoy_type == "transport" then
							local selected_transports = {}
							for i, transport in ipairs(transport_list) do
								table.insert(selected_transports,transport)
							end
							for i=1,3 do
								if #selected_transports > 0 then
									local transport = tableRemoveRandom(selected_transports)
									if transport.comms_data == nil then
										transport.comms_data = {friendlyness = random(0.0, 100.0)}
									end
									if transport.comms_data.goods == nil then
										goodsOnShip(transport,transport.comms_data)
									end
									local goods_carrying = ""
									for good, goodData in pairs(transport.comms_data.goods) do
										if goods_carrying == "" then
											goods_carrying = good
										else
											goods_carrying = string.format("%s, %s",goods_carrying,good)
										end
									end
									if out == "" then
										out = string.format(_("scienceDescription-buoy","Sensor Record: %s %s %s in %s carrying %s"),transport:getFaction(),transport:getTypeName(),transport:getCallSign(),transport:getSectorName(),goods_carrying)
									else
										out = string.format(_("scienceDescription-buoy","%s; %s %s %s in %s carrying %s"),out,transport:getFaction(),transport:getTypeName(),transport:getCallSign(),transport:getSectorName(),goods_carrying)
									end
								else
									break
								end
							end
						end
					else
						out = _("scienceDescription-buoy","No data recorded")
					end
					object:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),out)
				elseif terrain.desc == "Ad" then
					object:setScanningParameters(2,1):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
					if billboards == nil then
						billboards = {}
					end
					if #billboards < 1 then
						for i,ad in ipairs(advertising_billboards) do
							table.insert(billboards,ad)
						end
					end
					object:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),tableRemoveRandom(billboards))
				elseif terrain.obj == Nebula then
					dist = 1500
					if random(1,100) < 77 then
						local n_angle = random(0,360)
						local n_x, n_y = vectorFromAngle(n_angle,random(5000,10000))
						Nebula():setPosition(eo_x + n_x, eo_y + n_y)
						if random(1,100) < 37 then
							local n2_angle = (n_angle + random(120,240)) % 360
							n_x, n_y = vectorFromAngle(n2_angle,random(5000,10000))
							eo_x = eo_x + n_x
							eo_y = eo_y + n_y
							Nebula():setPosition(eo_x, eo_y)
							if random(1,100) < 22 then
								local n3_angle = (n2_angle + random(120,240)) % 360
								n_x, n_y = vectorFromAngle(n3_angle,random(5000,10000))
								Nebula():setPosition(eo_x + n_x, eo_y + n_y)
							end
						end
					end
				elseif terrain.obj == BlackHole or terrain.obj == Mine then
					--black hole, mine; no more action needed
				else	--default to asteroid
					placeAsteroid(placement_area)
					return false
				end
				table.insert(area.space,{obj=object,dist=dist,shape="circle"})
				return true
			end
		end
	else
		placeAsteroid(placement_area)
		return false
	end
end
--	Transport utilities
function goodsOnShip(comms_target,comms_data)
	comms_data.goods = {}
	comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
			local count_repeat_loop = 0
			repeat
				comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
				local goodCount = 0
				for good, goodData in pairs(comms_data.goods) do
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
function randomTransportType()
	local transport_type = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local freighter_engine = "Freighter"
	local freighter_size = math.random(1,5)
	if random(1,100) < 30 then
		freighter_engine = "Jump Freighter"
		freighter_size = math.random(3,5)
	end
	local transport_template = string.format("%s %s %i",tableSelectRandom(transport_type),freighter_engine,freighter_size)
	return CpuShip():setTemplate(transport_template):setCommsScript(""):setCommsFunction(commsShip), freighter_size
end
function maintainTransports()
	if transport_list ~= nil then
		local clean_list = true
		for i,transport in ipairs(transport_list) do
			if not transport:isValid() then
				transport_list[i] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				clean_list = false
				break
			end
		end
		if clean_list then
			for i,transport in ipairs(transport_list) do
				if transport ~= nil and transport:isValid() then
					if transport:getDockedWith() ~= nil then
						if transport.dock_time == nil then
							transport.dock_time = getScenarioTime() + random(5,30)
						end
					elseif transport:getOrder() ~= "Dock" then
						if transport.dock_time == nil then
							transport.dock_time = getScenarioTime() + random(5,30)
						end						
					elseif transport:getOrder() == "Dock" then
						if transport:getOrderTarget() == nil or not transport:getOrderTarget():isValid() then
							if transport.dock_time == nil then
								transport.dock_time = getScenarioTime() + random(5,30)
							end						
						end
					end
				end
				if transport.dock_time ~= nil and getScenarioTime() > transport.dock_time then
					local transport_station_pool = {}
					for j,station in ipairs(inner_stations) do
						if station ~= nil then
							if station:isValid() then
								if not transport:isEnemy(station) then
									table.insert(transport_station_pool,station)
								end
							else
								inner_stations[j] = inner_stations[#inner_stations]
								inner_stations[#inner_stations] = nil
								clean_list = false
								break
							end
						else
							inner_stations[j] = inner_stations[#inner_stations]
							inner_stations[#inner_stations] = nil
							clean_list = false
							break
						end
					end
					if clean_list and #transport_station_pool > 0 then
						local dock_station = tableSelectRandom(transport_station_pool)
						transport:orderDock(dock_station)
						transport.dock_time = nil
					end
				end
			end
		end
	end
end
--	Sensor jammer utilities
function sensorJammerPickupProcess(self,retriever)
	string.format("")
	local jammer_call_sign = self:getCallSign()
	sensor_jammer_list[jammer_call_sign] = nil
	if not self:isScannedBy(retriever) then
		retriever:setCanScan(false)
		retriever.scanner_dead = "scanner_dead"
		retriever:addCustomMessage("Science",retriever.scanner_dead,_("msgScience","The unscanned artifact we just picked up has fried our scanners"))
		retriever.scanner_dead_ops = "scanner_dead_ops"
		retriever:addCustomMessage("Operations",retriever.scanner_dead_ops,_("msgOperations","The unscanned artifact we just picked up has fried our scanners"))
	end
	may_explain_sensor_jammer = true
end
function sensorJammer(x,y)
	artifact_number = artifact_number + math.random(1,4)
	local random_suffix = string.char(math.random(65,90))
	local jammer_call_sign = string.format("SJ%i%s",artifact_number,random_suffix)
	local scanned_description = string.format(_("scienceDescription-artifact","Source of emanations interfering with long range sensors. Range:%.1fu Impact:%.1fu"),sensor_jammer_range/1000,sensor_jammer_impact/1000)
	local sensor_jammer = Artifact():setPosition(x,y):setScanningParameters(sensor_jammer_scan_complexity,sensor_jammer_scan_depth):setRadarSignatureInfo(.2,.4,.1):setModel("SensorBuoyMKIII"):setDescriptions(_("scienceDescription-artifact","Source of unusual emanations"),scanned_description):setCallSign(jammer_call_sign)
	sensor_jammer:onPickUp(sensorJammerPickupProcess)
	sensor_jammer_list[jammer_call_sign] = sensor_jammer
	sensor_jammer.jam_range = sensor_jammer_range
	sensor_jammer.jam_impact = sensor_jammer_impact
	sensor_jammer.jam_impact_units = sensor_jammer_power_units
	return sensor_jammer
end
--	Storage
function clearStore()
	local i = 1
	while(store:get(i) ~= "") do
		local ship = store:get(i)
		local name_key = string.format("%s-%s-name",store_name,ship)
		store:set(name_key,"")
		local level_key = string.format("%s-%s-level",store_name,ship)
		store:set(level_key,"")
		store:set(i,"")
		i = i + 1
	end
end
function stringStore()
	local ship_number = 0
	for i,exp in pairs(store_cadet) do
		store:set(string.format("%s-%s-name",store_name,i),exp.name)
		store:set(string.format("%s-%s-level",store_name,i),exp.level)
		ship_number = ship_number + 1
		store:set(ship_number,i)
	end
end
function unStringStore()
	local i = 1
	local sc = {}
	while(store:get(i) ~= "") do
		local ship = store:get(i)
		if not ship then break end
		local name_key = string.format("%s-%s-name",store_name,ship)
		local name = store:get(name_key)
		local level_key = string.format("%s-%s-level",store_name,ship)
		local level = store:get(level_key)
		sc[ship] = {name = name, level = level}
		i = i + 1
	end
	return sc
end
function getShipEncryptionKey(nextFunction)
	setCommsMessage(_("crypto-comms","Select alphabetic prefix"))
	local ship_key = ""
	for i,stem in ipairs(stems) do
		addCommsReply(stem,function()
			setCommsMessage(string.format(_("crypto-comms","Key: %s\nEnter first digit"),stem))
			for j=0,9 do
				addCommsReply(string.format(_("crypto-comms","First digit is %i"),j),function()
					setCommsMessage(string.format(_("crypto-comms","Key: %s%i\nEnter second digit"),stem,j))
					for k=0,9 do
						addCommsReply(string.format(_("crypto-comms","Second digit is %i"),k),function()
							setCommsMessage(string.format(_("crypto-comms","Key: %s%i%i\nEnter third digit"),stem,j,k))
							for l=0,9 do
								addCommsReply(string.format(_("crypto-comms","Third digit is %i"),l),function()
									string.format("")
									ship_key = string.format("%s%i%i%i",stem,j,k,l)
									setCommsMessage(string.format(_("crypto-comms","Key provided: %s"),ship_key))
									local success = true
									if store_cadet[ship_key] == nil then
										success = false
									end
									nextFunction(success,ship_key)
								end)
							end
						end)
					end
				end)
			end
		end)
	end
end
function generateShipEncryptionKey()
	local key_pool = {}
	for i,stem in ipairs(stems) do
		if store_cadet[stem] == nil then
			table.insert(key_pool,stem)
		end
	end
	local stem = tableSelectRandom(key_pool)
	local branch = math.random(100,999)
	return string.format("%s%i",stem,branch)
end
function encryptNewShip()
	local ship_key = generateShipEncryptionKey()
	store_cadet[ship_key] = {name = player:getCallSign(), level = player.level}
	stringStore()
	setCommsMessage(string.format(_("crypto-comms","Current ship state encrypted and stored using new key %s"),ship_key))
end
function encryptExistingShip(success,ship_key)
	if success then
		store_cadet[ship_key] = {name = player:getCallSign(), level = player.level}
		stringStore()
		setCommsMessage(string.format(_("crypto-comms","Current ship state encrypted and stored using key provided %s"),ship_key))
	else
		setCommsMessage(string.format(_("crypto-comms","No ship stored with encryption key %s"),ship_key))
	end
end
function decryptShip(success,ship_key)
	if success then
		player:setCallSign(store_cadet[ship_key].name)
		player.level = tonumber(store_cadet[ship_key].level)
		if player.level >= 1 then
			player.enemy_group_1_destroyed = true
			player:addReputationPoints(math.random(5,9))
		end
		if player.level >= 2 then
			player:setWeaponStorageMax("EMP", 3):setWeaponStorage("EMP", 3)
			player:weaponTubeAllowMissle(0,"EMP"):weaponTubeAllowMissle(1,"EMP")
			player:addReputationPoints(math.random(3,5))
		end
		if player.level >= 3 then
			player.enemy_group_2_destroyed = true
			player:addReputationPoints(math.random(3,5))
		end
		if player.level >= 4 then
			player:setLongRangeRadarRange(30000)
			player.normal_long_range_radar = 30000
			player:addReputationPoints(3)
		end
		if player.level >= 5 then
			player.enemy_group_3_destroyed = true
			player:addReputationPoints(3)
		end
		if player.level >= 6 then
			player:setCanCombatManeuver(true)
			player:addReputationPoints(3)
		end
		if player.level >= 7 then
			player.enemy_group_4_destroyed = true
			player:addReputationPoints(3)
		end
		if player.level >= 8 then
			player:setJumpDrive(true)
			player.max_jump_range = 30000						--shorter than typical (vs 50)
			player.min_jump_range = 3000						--shorter than typical (vs 5)
			player:setJumpDriveRange(player.min_jump_range,player.max_jump_range)
			player:setJumpDriveCharge(player.max_jump_range)
			player:addReputationPoints(3)
		end
		if player.level >= 9 then
			player.enemy_group_5_destroyed = true
			player:addReputationPoints(3)
		end
		if player.level >= 10 then
			player.rescued_freighter = true
			player:addReputationPoints(3)
		end
		if player.level >= 11 then
			player:setWeaponStorageMax("Nuke", 2):setWeaponStorage("Nuke", 2)
			player:weaponTubeAllowMissle(0,"Nuke"):weaponTubeAllowMissle(1,"Nuke")
			player:addReputationPoints(3)
		end
		if player.level >= 12 then
			player.provided_cargo_to_home_station = true
			home_station.defensive_rotation = true
			player:addReputationPoints(3)
		end
		if player.level >= 13 then
			player:setCanLaunchProbe(true)
			player:addReputationPoints(3)
		end
		if player.level >= 14 then
			player.enemy_group_6_destroyed = true
			player:addReputationPoints(3)
		end
		if player.level >= 15 then
			player:setCanHack(true)
			player:addReputationPoints(3)
		end
		if player.level >= 16 then
			player.enemy_group_7_destroyed = true
			player:addReputationPoints(3)
		end
		setCommsMessage(_("crypto-comms","Ship has been decrypted and restored"))
	else
		setCommsMessage(string.format(_("crypto-comms","No ship stored with encryption key %s"),ship_key))
	end
end
--	Communication
function scenarioMissionsUndocked()
	if not player:getCanDock() then
		addCommsReply(_("station-comms","Request permission to dock"),function()
			local response = _("station-comms","Permission granted")
			local store_slot_count = 0
			for i,exp in pairs(store_cadet) do
				store_slot_count = store_slot_count + 1
			end
			if store_slot_count > 0 then
				response = string.format(_("station-comms","%s\nYou have the option to restore a previously encrypted ship when docked."),response)
			end
			setCommsMessage(response)
			comms_source:setCanDock(true)
		end)
	end
end
function scenarioMissions()
	--	save levels
	--	0	ship name
	--	1	enemy ship group 1 destroyed
	--	2	ship has EMP capability
	--	3	enemy ship group 2 destroyed
	--	4	long range sensors out to 30u
	--	5	enemy ship group 3 destroyed
	--	6	combat maneuver
	--	7	enemy ship group 4 destroyed
	--	8	jump drive
	--	9	enemy ship group 5 destroyed
	--	10	rescued freighter from enemy group 5
	--	11	ship has Nuke capability
	--	12	picked up cargo for home station
	--	13	probe launch capability
	local presented = 0
	if comms_target:isFriendly(comms_source) then
		presented = commsEncryptDecrypt()
		if player.level == nil then
			addCommsReply(_("station-comms","Ready for our first patrol mission"),function()
				local ship_name = tableRemoveRandom(player_ship_names_for["Phobos M5P"])
				player:setCallSign(ship_name)
				player.level = 0
				setCommsMessage(string.format(_("station-comms","Your call sign is now %s. You will be contacted for your first mission shortly."),player:getCallSign()))
			end)
		end
		presented = presented + commsMissionUpgrades()
	end
	return presented
end
function commsEncryptDecrypt()
	local presented = 0
	local store_slot_count = 0
	for i,exp in pairs(store_cadet) do
		store_slot_count = store_slot_count + 1
	end
	if store_slot_count == 0 then
		local ship_name = tableRemoveRandom(player_ship_names_for["Phobos M5P"])
		player:setCallSign(ship_name)
		player.level = 0
	end
	if store_slot_count <= 5 then
		presented = presented + 1
		addCommsReply(_("crypto-comms","Encrypt ship state for future retrieval"),function()
			setCommsMessage(_("crypto-comms","How would you like to encrypt the ship state for future retrieval?"))
			if store_slot_count > 0 then
				addCommsReply(_("crypto-comms","Reuse existing encryption key"),function()
					getShipEncryptionKey(encryptExistingShip)
				end)
			end
			if store_slot_count == 5 then
				addCommsReply(_("crypto-comms","Discard all encryption keys and create a new key"),function()
					clearStore()
					store_cadet = {}
					encryptNewShip()
				end)
			else
				addCommsReply(_("crypto-comms","Create a new encryption key"),function()
					encryptNewShip()
				end)
			end
		end)
	end
	if store_slot_count > 0 then
		presented = presented + 1
		addCommsReply(_("crypto-comms","Retrieve and decrypt ship state from storage"),function()
			getShipEncryptionKey(decryptShip)
		end)
	end
	return presented
end
function commsMissionUpgrades()
	local presented = 0
	if player.level == 1 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Install EMPs"),function()
			setCommsMessage(string.format(_("upgrade-comms","The shipyard weapons specialists on %s have installed EMPs on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgHelms","EMP stands for Electro-Magnetic Pulse. These missiles have a blast radius of one unit. Your ship can get caught in the blast if you fire too close to an enemy, but you can avoid shield damage if you lower the shields since EMPs only damage shields.")
			player.emp_install_msg_epl = "emp_install_msg_epl"
			player:addCustomMessage("Engineering+",player.emp_install_msg_epl,out)
			table.insert(clean_up_messages,{msg=player.emp_install_msg_epl,expire=getScenarioTime() + 90})
			player.emp_install_msg_hlm = "emp_install_msg_hlm"
			player:addCustomMessage("Helms",player.emp_install_msg_hlm,out)
			table.insert(clean_up_messages,{msg=player.emp_install_msg_hlm,expire=getScenarioTime() + 90})
			player.emp_install_msg_wea = "emp_install_msg_wea"
			player:addCustomMessage("Weapons",player.emp_install_msg_wea,out)
			table.insert(clean_up_messages,{msg=player.emp_install_msg_wea,expire=getScenarioTime() + 90})
			player.emp_install_msg_tac = "emp_install_msg_tac"
			player:addCustomMessage("Tactical",player.emp_install_msg_tac,out)
			table.insert(clean_up_messages,{msg=player.emp_install_msg_tac,expire=getScenarioTime() + 90})
			player.emp_install_msg_pil = "emp_install_msg_pil"
			player:addCustomMessage("Single",player.emp_install_msg_pil,out)
			table.insert(clean_up_messages,{msg=player.emp_install_msg_pil,expire=getScenarioTime() + 90})
			player:setWeaponStorageMax("EMP", 3):setWeaponStorage("EMP", 3)
			player:weaponTubeAllowMissle(0,"EMP"):weaponTubeAllowMissle(1,"EMP")
			player:addReputationPoints(10)
			player.level = 2
		end)
	end
	if player.level == 3 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Increase long range sensor range"),function()
			setCommsMessage(string.format(_("upgrade-comms","The science technicians on %s have increased the long range sensor range on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgScience","The reach of your sensors is now 30 units instead of 20 units. Use the zoom control in the lower right hand corner of your screen to see more or less of the surrounding area.")
			player.extend_sensor_range_msg_sci = "extend_sensor_range_msg_sci"
			player:addCustomMessage("Science",player.extend_sensor_range_msg_sci,out)
			table.insert(clean_up_messages,{msg=player.extend_sensor_range_msg_sci,expire=getScenarioTime() + 90})
			player.extend_sensor_range_msg_ops = "extend_sensor_range_msg_ops"
			player:addCustomMessage("Operations",player.extend_sensor_range_msg_ops,out)
			table.insert(clean_up_messages,{msg=player.extend_sensor_range_msg_ops,expire=getScenarioTime() + 90})
			player:setLongRangeRadarRange(30000)
			player.normal_long_range_radar = 30000
			player:addReputationPoints(10)
			player.level = 4
		end)
	end
	if player.level == 5 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Install combat maneuver"),function()
			setCommsMessage(string.format(_("upgrade-comms","The %s shipyard workers have installed combat maneuver on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgHelms","Use combat maneuver by dragging the solid white circle on the right hand side of your screen sideways or forwards or both. This makes the ship move sideways or forwards in the direction of the motion of the white circle. Taking this action adds heat to the impulse and maneuvering systems, so don't over use it. Combat maneuver can help you dodge dangerous missiles.")
			player.enable_combat_maneuver_msg_hlm = "enable_combat_maneuver_msg_hlm"
			player:addCustomMessage("Helms",player.enable_combat_maneuver_msg_hlm,out)
			table.insert(clean_up_messages,{msg=player.enable_combat_maneuver_msg_hlm,expire=getScenarioTime() + 90})
			player.enable_combat_maneuver_msg_tac = "enable_combat_maneuver_msg_tac"
			player:addCustomMessage("Tactical",player.enable_combat_maneuver_msg_tac,out)
			table.insert(clean_up_messages,{msg=player.enable_combat_maneuver_msg_tac,expire=getScenarioTime() + 90})
			player.enable_combat_maneuver_msg_pil = "enable_combat_maneuver_msg_pil"
			player:addCustomMessage("Single",player.enable_combat_maneuver_msg_pil,out)
			table.insert(clean_up_messages,{msg=player.enable_combat_maneuver_msg_pil,expire=getScenarioTime() + 90})
			out = _("msgEngineer","With combat maneuver installed, heat will be added to maneuver and impulse when helm or tactical uses it. Be prepared.")
			player.enable_combat_maneuver_msg_eng = "enable_combat_maneuver_msg_eng"
			player:addCustomMessage("Engineering",player.enable_combat_maneuver_msg_eng,out)
			table.insert(clean_up_messages,{msg=player.enable_combat_maneuver_msg_eng,expire=getScenarioTime() + 90})
			player.enable_combat_maneuver_msg_epl = "enable_combat_maneuver_msg_epl"
			player:addCustomMessage("Engineering+",player.enable_combat_maneuver_msg_epl,out)
			table.insert(clean_up_messages,{msg=player.enable_combat_maneuver_msg_epl,expire=getScenarioTime() + 90})
			player:setCanCombatManeuver(true)
			player:addReputationPoints(10)
			player.level = 6
		end)
	end
	if player.level == 7 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Install jump drive"),function()
			setCommsMessage(string.format(_("upgrade-comms","The %s shipyard workers have installed a jump drive on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgHelms","The jump drive can get you to far distances much faster than your impulse engines. Get bearing and distance to your destination from Science or Relay. Steer the ship to the proper bearing. Use the distance slider above the jump button to set how far you will jump. Once those are set, use the jump button to activate the jump drive. There will be a countdown to jump.")
			if player:hasPlayerAtPosition("Operations") then
				if not player:hasPlayerAtPosition("Science") and not player:hasPlayerAtPosition("Relay") then
					out = _("msgHelms","The jump drive can get you to far distances much faster than your impulse engines. Get bearing and distance to your destination from Operations. Steer the ship to the proper bearing. Use the distance slider above the jump button to set how far you will jump. Once those are set, use the jump button to activate the jump drive. There will be a countdown to jump.")
				end
			end
			player.add_jump_drive_msg_hlm = "add_jump_drive_msg_hlm"
			player:addCustomMessage("Helms",player.add_jump_drive_msg_hlm,out)
			table.insert(clean_up_messages,{msg=player.add_jump_drive_msg_hlm,expire=getScenarioTime() + 90})
			player.add_jump_drive_msg_tac = "add_jump_drive_msg_tac"
			player:addCustomMessage("Tactical",player.add_jump_drive_msg_tac,out)
			table.insert(clean_up_messages,{msg=player.add_jump_drive_msg_tac,expire=getScenarioTime() + 90})
			player.add_jump_drive_msg_pil = "add_jump_drive_msg_pil"
			player:addCustomMessage("Single",player.add_jump_drive_msg_pil,out)			
			table.insert(clean_up_messages,{msg=player.add_jump_drive_msg_pil,expire=getScenarioTime() + 90})
			out = _("msgEngineer","The jump drive uses lots of energy. Each time the jump drive is activated, there will be heat added to the jump drive system. Adding coolant to the jump drive system can address the heat. If the jump drive is damaged or the power provided falls below about 25%, the jump drive will gradually lose its charge. If the ship needs to travel further than the jump drive range, you may be asked to boost power to the jump drive to make it charge faster between jumps.")
			player.add_jump_drive_msg_eng = "add_jump_drive_msg_eng"
			player:addCustomMessage("Engineering",player.add_jump_drive_msg_eng,out)			
			table.insert(clean_up_messages,{msg=player.add_jump_drive_msg_eng,expire=getScenarioTime() + 90})
			player.add_jump_drive_msg_epl = "add_jump_drive_msg_epl"
			player:addCustomMessage("Engineering+",player.add_jump_drive_msg_epl,out)			
			table.insert(clean_up_messages,{msg=player.add_jump_drive_msg_epl,expire=getScenarioTime() + 90})
			player:setJumpDrive(true)
			player.max_jump_range = 30000						--shorter than typical (vs 50)
			player.min_jump_range = 3000						--shorter than typical (vs 5)
			player:setJumpDriveRange(player.min_jump_range,player.max_jump_range)
			player:setJumpDriveCharge(player.max_jump_range)
			player:addReputationPoints(10)
			player.level = 8
		end)
	end
	if player.level == 10 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Install nuclear weapons"),function()
			setCommsMessage(string.format(_("upgrade-comms","The %s shipyard weapons specialists have installed nukes on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgHelms","Nukes have a blast radius of one unit. It is very easy to accidentally blow yourself up or your friendly ships and stations with the accidental discharge of a nuclear weapon. Make sure the missile has a clear path to the intended target and that you or any friendly ships are not close to the blast when it detonates.")
			player.add_nukes_msg_hlm = "add_nukes_msg_hlm"
			player:addCustomMessage("Helms",player.add_nukes_msg_hlm,out)
			table.insert(clean_up_messages,{msg=player.add_nukes_msg_hlm,expire=getScenarioTime() + 90})
			player.add_nukes_msg_wea = "add_nukes_msg_wea"
			player:addCustomMessage("Weapons",player.add_nukes_msg_wea,out)
			table.insert(clean_up_messages,{msg=player.add_nukes_msg_wea,expire=getScenarioTime() + 90})
			player.add_nukes_msg_tac = "add_nukes_msg_tac"
			player:addCustomMessage("Tactical",player.add_nukes_msg_tac,out)
			table.insert(clean_up_messages,{msg=player.add_nukes_msg_tac,expire=getScenarioTime() + 90})
			player.add_nukes_msg_pil = "add_nukes_msg_pil"
			player:addCustomMessage("Single",player.add_nukes_msg_pil,out)
			table.insert(clean_up_messages,{msg=player.add_nukes_msg_pil,expire=getScenarioTime() + 90})
			player:setWeaponStorageMax("Nuke", 2):setWeaponStorage("Nuke", 2)
			player:weaponTubeAllowMissle(0,"Nuke"):weaponTubeAllowMissle(1,"Nuke")
			player:addReputationPoints(10)
			player.level = 11
		end)
	end
	if player.level == 11 and comms_target == home_station and comms_source.goods ~= nil and comms_source.goods[mission_cargo] > 0 then
		presented = presented + 1
		addCommsReply(string.format(_("goal-comms","Provide %s to %s"),mission_cargo,comms_target:getCallSign()),function()
			setCommsMessage(_("goal-comms","Thanks! We can now enable our defensive rotational thrusters."))
			comms_target.defensive_rotation = true
			player.goods[mission_cargo] = player.goods[mission_cargo] - 1
			player:addReputationPoints(10)
			player.level = 12
		end)
	end
	if player.level == 12 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Install scan proble launch system"),function()
			setCommsMessage(string.format(_("upgrade-comms","The science and shipyard propulsion miniaturization specialists on %s have installed a probe launch system and probes on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgRelay","Probes give you a 5 unit radius circle of scanner information around the probe. Once a probe reaches its destination, you can link it to Science who can then scan things within the 5 unit range of the probe. Some stations automatically, but gradually restock your probes when docked. A probe within 5 units of a neutral station can be used to open communications with the neutral station. To launch a probe, click the launch probe button, then click on the map where you want the probe to go. Probes run out of energy in about ten minutes. They can also be shot down by enemies.")
			player.add_probes_msg_rel = "add_probes_msg_rel"
			player:addCustomMessage("Relay",player.add_probes_msg_rel,out)
			table.insert(clean_up_messages,{msg=player.add_probes_msg_rel,expire=getScenarioTime() + 90})
			player:setCanLaunchProbe(true)
			player:addReputationPoints(10)
			player.level = 13
		end)
	end
	if player.level == 14 then
		presented = presented + 1
		addCommsReply(_("upgrade-comms","Install hacking system"),function()
			setCommsMessage(string.format(_("upgrade-comms","The cyber security technicians on %s installed a hacking system on %s."),comms_target:getCallSign(),comms_source:getCallSign()))
			local out = _("msgRelay","Your newly installed hacking system allows you to degrade the performance of ships within communication range. Click the enemy ship, click the start hacking button, select a subsystem on the right side of the window that pops up, and then complete the mini hacking game (mine sweeper or lights out). Each successful hack reduces the reported system effectiveness by 50%. Even when hacking is reported as 100% effective, the hacked enemy system is still running at 25%. An enemy ship with hacked systems is much easier to destroy.")
			player.enable_hacking_msg_rel = "enable_hacking_msg_rel"
			player:addCustomMessage("Relay",player.enable_hacking_msg_rel,out)
			table.insert(clean_up_messages,{msg=player.enable_hacking_msg_rel,expire=getScenarioTime() + 90})
			player:setCanHack(true)
			player:addReputationPoints(10)
			player.level = 15
		end)
	end
	return presented
end
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
--	Spawning
function getTemplatePool(max_strength)
	local function getStrengthSort(tbl, sortFunction)
		local keys = {}
		for key in pairs(tbl) do
			table.insert(keys,key)
		end
		table.sort(keys, function(a,b)
			return sortFunction(tbl[a], tbl[b])
		end)
		return keys
	end
	local ship_template_by_strength = getStrengthSort(ship_template, function(a,b)
		return a.strength > b.strength
	end)
	local template_pool = {}
	if pool_selectivity == "less/heavy" then
		for _, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= max_strength then
				if fleetComposition == "Non-DB" then
					if ship_template[current_ship_template].create ~= stockTemplate then
						table.insert(template_pool,current_ship_template)
					end
				elseif fleetComposition == "Random" then
					table.insert(template_pool,current_ship_template)
				else
					if ship_template[current_ship_template].fleet_group[fleetComposition] then
						table.insert(template_pool,current_ship_template)							
					end
				end
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
			if ship_template[current_ship_template].strength <= max_strength then
				if fleetComposition == "Non-DB" then
					if ship_template[current_ship_template].create ~= stockTemplate then
						table.insert(template_pool,current_ship_template)
					end
				elseif fleetComposition == "Random" then
					table.insert(template_pool,current_ship_template)
				else
					if ship_template[current_ship_template].fleet_group[fleetComposition] then
						table.insert(template_pool,current_ship_template)							
					end
				end
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	else	--full
		for current_ship_template, details in pairs(ship_template) do
			if details.strength <= max_strength then
				if fleetComposition == "Non-DB" then
					if ship_template[current_ship_template].create ~= stockTemplate then
						table.insert(template_pool,current_ship_template)
					end
				elseif fleetComposition == "Random" then
					table.insert(template_pool,current_ship_template)
				else
					if ship_template[current_ship_template][fleet_group[fleetComposition]] then
						table.insert(template_pool,current_ship_template)							
					end
				end
			end
		end
	end
	return template_pool
end
function spawnRandomArmed(x, y, enemy_strength, template_pool)
--x and y are central spawn coordinates
--fleetIndex is the number of the fleet to be spawned
--spawn_distance optional - used for ambush or pyramid
--spawn_angle optional - used for ambush or pyramid
--px and py are the player coordinates or the pyramid fly towards point coordinates
	if enemy_strength == nil then
		if player.shipScore == nil then
			player.shipScore = 20
		end
		enemy_strength = math.max(5,player.shipScore)
	end
	local sp = random(500,1000)			--random spacing of spawned group
	local shape = "square"
	if random(1,100) < 50 then
		shape = "hexagonal"
	end
	local enemy_position = 0
	local enemyList = {}
	--print("in spawn random armed function about to call get template pool function")
	if template_pool == nil then
		template_pool = getTemplatePool(enemy_strength)
	end
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList
	end
	local fleet_prefix = generateCallSignPrefix()
	if fleetSpawnFaction == nil then
		fleetSpawnFaction = "Kraylor"
	end
	while enemy_strength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
--		print("selected template:",selected_template)
		local ship = ship_template[selected_template].create(fleetSpawnFaction,selected_template)
		ship:setCallSign(generateCallSign(fleet_prefix))
		ship:orderRoaming()
		enemy_position = enemy_position + 1
		ship:setPosition(x + formation_delta[shape].x[enemy_position] * sp, y + formation_delta[shape].y[enemy_position] * sp)
		table.insert(enemyList, ship)
		enemy_strength = enemy_strength - ship_template[selected_template].strength
	end
	return enemyList
end
--	Missions
function nonCombatMissions(m)
	if player.level == 11 then
		if player.get_cargo_message == nil then
			if availableForComms(player) then
				local station_pool = {}
				for i,station in ipairs(inner_stations) do
					if not station:isEnemy(player) and not station:isFriendly(player) then
						if station.comms_data ~= nil then
							if station.comms_data.goods ~= nil then
								for good,good_data in pairs(station.comms_data.goods) do
									if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
										if good_data.quantity > 0 then
											table.insert(station_pool,{station=station,good=good})
										end
									end
								end
							end
						end
					end
				end
				if #station_pool > 0 then
					local sgi = tableSelectRandom(station_pool)
					mission_cargo = sgi.good
					mission_station = sgi.station
				else
					print("no qualifying goods on any neutral stations")
				end
				local out = string.format(_("goal-comms","We need you to get %s for us. You can get it from %s in sector %s."),good_desc[mission_cargo],mission_station:getCallSign(),mission_station:getSectorName())
				playVoice("SupplyRun")
				home_station:sendCommsMessage(player,out)
				player.get_cargo_message = "sent"
				stations_sell_goods = true
				stellar_cartography_button = true
			end
		end
	end
end
function missionAgainstEnemies(enemy_mission)
	if enemy_mission.fleet == nil then
		local spawn_angle = random(0,360)
		local fx, fy = vectorFromAngle(spawn_angle,random(enemy_mission.lo,enemy_mission.hi),true)
		local sx, sy = home_station:getPosition()
		fleetComposition = enemy_mission.comp
		enemy_mission.fleet = spawnRandomArmed(sx + fx, sy + fy, enemy_mission.strength)
		enemy_mission.spawn_angle = spawn_angle
		for i,ship in ipairs(enemy_mission.fleet) do
			ship:setFaction(enemy_mission.faction):orderFlyTowards(center_x,center_y)
		end
		if player.level == 8 then
			fx, fy = vectorFromAngle(spawn_angle,15000,true)
			enemy_mission.freighter = CpuShip():setPosition(fx + sx, fy + sy):setTemplate("Goods Freighter 5"):setScanStateByFaction("Human Navy","simplescan")
			enemy_mission.freighter:setFaction("Arlenians"):orderDock(home_station):setCallSign(getFactionPrefix("Arlenians"))
		end
	else
		if #enemy_mission.fleet > 0 then
			for i,ship in ipairs(enemy_mission.fleet) do
				if not ship:isValid() then
					enemy_mission.fleet[i] = enemy_mission.fleet[#enemy_mission.fleet]
					enemy_mission.fleet[#enemy_mission.fleet] = nil
					break
				end
			end
		else
			if player.level == 8 then
				if enemy_mission.freighter:isValid() then
					if distance(enemy_mission.freighter,home_station) < 1500 then
						enemy_mission.fleet = nil
						enemy_mission.result = true
						player.level = player.level + 2
						player.rescued_freighter = true
					else
						local fx, fy = vectorFromAngle(enemy_mission.spawn_angle,40000,true)
						local sx, sy = home_station:getPosition()
						fleetComposition = "Chasers"
						enemy_mission.fleet = spawnRandomArmed(sx + fx, sy + fy, 15)
						for i,ship in ipairs(enemy_mission.fleet) do
							ship:setFaction(enemy_mission.faction):orderFlyTowards(center_x,center_y)
						end
					end
				else
					globalMessage(_("msgMainscreen","Arlenian resupply freighter destroyed"))
					victory("Kraylor")
				end
			else
				enemy_mission.fleet = nil
				enemy_mission.result = true
				player.level = player.level + 1
			end
		end
	end
	if enemy_mission.message == nil then
		if availableForComms(player) then
			local out = string.format(_("centralcommandGoal-incCall","Our sensors detect one or more ships approaching from bearing %.1f. Please investigate."),enemy_mission.spawn_angle)
			if player.level == 0 then
				out = string.format(_("centralcommandGoal-incCall","Welcome to your first patrol mission, cadets.\n%s"),out)
			elseif player.level == 8 then
				out = string.format(_("centralcommandGoal-incCall","%s\nMake sure Arlenian freighter %s arrives safely. They have critical supplies for us."),out,enemy_mission.freighter:getCallSign())
				playVoice("MakeSureThatFreighterGetsHere")
			else
				if incoming_voices == nil or #incoming_voices == 0 then
					incoming_voices = {"EnemyVesselsDetected","HostileShips","IncomingEnemyVessels","WarshipsIdentified"}
				end
				playVoice(tableRemoveRandom(incoming_voices))
			end
			home_station:sendCommsMessage(player,out)
			enemy_mission.message = "sent"
		end
	end
end
function formalWar()
	if attack_fleet == nil then
		local spawn_angle = angleHeading(nemesis_station,home_station)
		local afx, afy = vectorFromAngle(spawn_angle,10000)
		local sx, sy = nemesis_station:getPosition()
		fleetComposition = "Random"
		if fleet_strength == nil then
			fleet_strength = 35
		else
			fleet_strength = fleet_strength + 5
		end
		attack_fleet = spawnRandomArmed(sx + afx, sy + afy, fleet_strength)
		for i,ship in ipairs(attack_fleet) do
			ship:setFaction("Kraylor"):orderFlyTowards(center_x,center_y)
		end
	else
		local next_fleet = false
		if #attack_fleet > 0 then
			local clean_list = true
			local missiler_count = 0
			for i,ship in ipairs(attack_fleet) do
				if ship:isValid() then
					if ship_template[ship:getTypeName()].missiler then
						missiler_count = missiler_count + 1
					end
				else
					attack_fleet[i] = attack_fleet[#attack_fleet]
					attack_fleet[#attack_fleet] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				if missiler_count == #attack_fleet then
					local has_stock = false
					for i,ship in ipairs(attack_fleet) do
						for j,missile in ipairs(missile_types) do
							if ship:getWeaponStorageMax(missile) > 0 then
								if ship:getWeaponStorage(missile) > 0 then
									has_stock = true
									break
								end
							end
						end
						if has_stock then
							break
						end
					end
					if not has_stock then
						next_fleet = true
						for i,ship in ipairs(attack_fleet) do
							for j,missile in ipairs(missile_types) do
								if ship:getWeaponStorageMax(missile) > 0 then
									if ship:getWeaponStorage(missile) < 1 then
										ship:setWeaponStorage(missile,getWeaponStorageMax(missile))
									end
								end
							end
						end
					end
				end
			end
		else
			next_fleet = true
		end
		if next_fleet then
			if respite_time == nil then
				respite_time = getScenarioTime() + 120 + fleet_strength
			end
			if getScenarioTime() > respite_time then
				respite_time = nil
				local spawn_angle = angleHeading(nemesis_station,home_station)
				local afx, afy = vectorFromAngle(spawn_angle,10000)
				local sx, sy = nemesis_station:getPosition()
				fleetComposition = "Random"
				if fleet_strength == nil then
					fleet_strength = 35
				else
					fleet_strength = fleet_strength + 5
				end
				local temp_fleet = spawnRandomArmed(sx + afx, sy + afy, fleet_strength)
				for i,ship in ipairs(temp_fleet) do
					ship:setFaction("Kraylor"):orderFlyTowards(center_x,center_y)
					table.insert(attack_fleet,ship)
				end
			end
		end
	end
end
function cleanUpMessages()
	for i,msg in ipairs(clean_up_messages) do
		if getScenarioTime() > msg.expire then
			player:removeCustom(msg.msg)
			clean_up_messages[i] = clean_up_messages[#clean_up_messages]
			clean_up_messages[#clean_up_messages] = nil
			break
		end
	end
end
function buildDefensePlatforms()
	for i,def in ipairs(build_defense_platforms) do
		if def.freighter:isValid() and def.station:isValid() then
			local fx, fy = def.freighter:getPosition()
			local sx, sy = def.station:getPosition()
			if def.freighter.task == nil then
				def.freighter.task = "gather"
				def.freighter:orderDock(def.station)
			end
			if def.freighter.task == "gather" then
				if distance(def.freighter,def.station) < 1500 then
					if def.freighter.delay_time == nil then
						def.freighter.delay_time = getScenarioTime() + 30
					end
					if getScenarioTime() > def.freighter.delay_time then
						def.freighter.delay_time = nil
						local build_angle = (def.angle + 60 * def.cur)%360
						local build_dist = station_spacing[def.station:getTypeName()].platform
--						print("build angle:",build_angle,"build dist:",build_dist)
						local cx, cy = vectorFromAngle(build_angle,build_dist,true)
						def.freighter.task = "build"
						def.freighter:orderFlyTowards(cx + sx, cy + sy)
					end
				end
			end
			if def.freighter.task == "build" then
				local cx, cy = vectorFromAngle((def.angle + 60 * def.cur)%360,station_spacing[def.station:getTypeName()].platform,true)
				cx = cx + sx
				cy = cy + sy
				if distance(fx, fy, cx, cy) < 500 then
					if def.freighter.delay_time == nil then
						def.freighter.delay_time = getScenarioTime() + 30
					end
				end
				if def.freighter.delay_time ~= nil then
					if getScenarioTime() > def.freighter.delay_time then
						def.freighter.delay_time = nil
						CpuShip():setTemplate("Defense platform"):setFaction(def.station:getFaction()):setPosition(cx,cy):orderStandGround():setScanStateByFaction(def.station:getFaction(),"simplescan"):setCallSign(string.format("%s%s",def.prefix,def.cur))
						def.cur = def.cur + 1
						if def.cur <= 6 then
							def.freighter.task = "gather"
							def.freighter:orderDock(def.station)
						else
							table.insert(transport_list,def.freighter)
							build_defense_platforms[i] = build_defense_platforms[#build_defense_platforms]
							build_defense_platforms[#build_defense_platforms] = nil
							break
						end
					end
				end
			end
		else
			build_defense_platforms[i] = build_defense_platforms[#build_defense_platforms]
			build_defense_platforms[#build_defense_platforms] = nil
			break
		end
	end
end
function updatePlayerLongRangeSensors(delta,p)
	local free_sensor_boost = false
	local sensor_boost_present = false
	local sensor_boost_amount = 0
	if p.station_sensor_boost == nil then
		local station_pool = {}
		for i,station in ipairs(inner_stations) do
			if station ~= nil and station:isValid() then
				table.insert(station_pool,station)
			end
		end
		for i,sensor_station in ipairs(station_pool) do
			if sensor_station:isValid() and p:isDocked(sensor_station) then
				if sensor_station.comms_data.sensor_boost ~= nil then
					sensor_boost_present = true
					if sensor_station.comms_data.sensor_boost.cost < 1 then
						free_sensor_boost = true
						p.station_sensor_boost = sensor_station.comms_data.sensor_boost.value
						break
					end
					sensor_boost_amount = sensor_station.comms_data.sensor_boost.value
				end
			end
		end
	end
	local base_range = p.normal_long_range_radar
	if p.station_sensor_boost ~= nil then
		base_range = base_range + p.station_sensor_boost
	end
	if p:getDockedWith() == nil then
		base_range = p.normal_long_range_radar
		p.station_sensor_boost = nil
	end
	if p.power_sensor_interval ~= nil and p.power_sensor_interval > 0 and p:getEnergyLevel() > p:getEnergyLevelMax()*.05 then
		if p.power_sensor_state == nil then
			p.power_sensor_state = "disabled"
		end
		if p.power_sensor_state == "disabled" then
			p.power_sensor_state = "standby"
			updatePowerSensorButtons(p)
		elseif p.power_sensor_state == "enabled" then
			base_range = base_range + (1000 * p.power_sensor_interval * p.power_sensor_level)
			local power_decrement = delta*p.power_sensor_level*2
--			print("boost sensor power drain value:",power_decrement,"before energy:",p:getEnergyLevel())
			p:setEnergyLevel(p:getEnergyLevel() - power_decrement)
--			print("after:",p:getEnergyLevel())
		end
	else
		if p.power_sensor_state ~= nil then
			p.power_sensor_state = "disabled"
			updatePowerSensorButtons(p)
		end
	end
	local impact_range = math.max(base_range*sensor_impact,p:getShortRangeRadarRange())
	local sensor_jammer_impact = 0
	for jammer_name, sensor_jammer in pairs(sensor_jammer_list) do
		if sensor_jammer ~= nil and sensor_jammer:isValid() then
			local jammer_distance = distance(p,sensor_jammer)
			if jammer_distance < sensor_jammer.jam_range then
				if sensor_jammer.jam_impact_units then
					sensor_jammer_impact = math.max(sensor_jammer_impact,sensor_jammer.jam_impact*(1-(jammer_distance/sensor_jammer.jam_range)))
				else
					sensor_jammer_impact = math.max(sensor_jammer_impact,impact_range*sensor_jammer.jam_impact/100000*(1-(jammer_distance/sensor_jammer.jam_range)))
				end
			end
		else
			sensor_jammer_list[jammer_name] = nil
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range - sensor_jammer_impact)
	local probe_scan_boost_impact = 0
	if boost_probe_list ~= nil then
		for boost_probe_index, boost_probe in ipairs(boost_probe_list) do
			if boost_probe ~= nil and boost_probe:isValid() then
				if specialty_probe_diagnostic then
					print("Processing specialty probe in list, index:",boost_probe_index,"player:",p:getCallSign())
				end
				if distance_diagnostic then
					print("distance_diagnostic 24 boost_probe:",boost_probe,"p:",p)
				end		
				local boost_probe_distance = distance(boost_probe,p)
				if boost_probe_distance < boost_probe.range*1000 then
					if boost_probe_distance < boost_probe.range*1000/2 then
						if specialty_probe_diagnostic then
							print("current probe scan impact:",probe_scan_boost_impact)
						end
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,boost_probe.boost*1000)
					else
						local best_boost = boost_probe.boost*1000
						local adjusted_range = boost_probe.range*1000
						local half_adjusted_range = adjusted_range/2
						local raw_scan_gradient = boost_probe_distance/half_adjusted_range
						local scan_gradient = 2 - raw_scan_gradient
						if specialty_probe_diagnostic then
							print("boost:",boost_probe.boost,"distance:",boost_probe_distance,"range:",boost_probe.range)
							print("best boost:",best_boost,"adjusted range:",adjusted_range,"half adjusted range:",half_adjusted_range,"raw scan gradient:",raw_scan_gradient,"scan gradient:",scan_gradient)
							print("current probe scan impact:",probe_scan_boost_impact)
						end
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,best_boost * scan_gradient)
					end
					if specialty_probe_diagnostic then
						print("In range. Range:",boost_probe.range*1000,"distance:",boost_probe_distance,"new probe scan impact:",probe_scan_boost_impact)
					end
				end
			else
				boost_probe_list[boost_probe_index] = boost_probe_list[#boost_probe_list]
				boost_probe_list[#boost_probe_list] = nil
				if specialty_probe_diagnostic then
					print("Specialty probe deleted from list. Index:",boost_probe_index)
				end
				break
			end
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range + probe_scan_boost_impact)
	p:setLongRangeRadarRange(impact_range)
end
function playVoice(clip)
	if server_voices then
		if not voice_played[clip] then
			table.insert(voice_queue,clip)
			voice_played[clip] = true
		end
	end
end
function handleVoiceQueue()
	if #voice_queue > 0 then
		if voice_play_time == nil then
			playSoundFile(string.format("audio/scenario/34/sa_34_%s.ogg",voice_queue[1]))
			if voice_clips[voice_queue[1]] == nil then
				print("In the voice clips list,",voice_queue[1],"comes up as nil. Setting play gap to 20")
				voice_play_time = getScenarioTime() + 20
			else
				voice_play_time = getScenarioTime() + voice_clips[voice_queue[1]] + 1
			end
			table.remove(voice_queue,1)
		elseif getScenarioTime() > voice_play_time then
			voice_play_time = nil
		end
	end
end
function update(delta)
	if delta == 0 then
		return
	end
	--	game is no longer paused
	if player.opening_message == nil then
		if availableForComms(player) then
			home_station:sendCommsMessage(player,string.format(_("centralcommandGoal-incCall","You have been assigned patrol duty to the region in and around %s. Request permission to dock with %s and then dock with %s to get started. Redock with %s periodically to get your next assignment from the dispatch office."),home_station:getCallSign(),home_station:getCallSign(),home_station:getCallSign(),home_station:getCallSign()))
			playVoice("WelcomeToTiberius")
			player.opening_message = "sent"
		end
	end
	if player.level ~= nil then
		if player.level > missions[#missions].level then
			if player.final_mission_message == nil and #build_defense_platforms < 1 then
				if availableForComms(player) then
					home_station:sendCommsMessage(player,string.format(_("centralcommandGoal-incCall","The Kraylor finally communicated a formal declaration of war against the Human Navy. Your task is no longer a simple patrol mission. Your task is to destroy their primary military station %s located in sector %s while at the same time protect %s in sector %s. Good luck."),nemesis_station:getCallSign(),nemesis_station:getSectorName(),home_station:getCallSign(),home_station:getSectorName()))
					playVoice("WarWithTheKraylor")
					player.final_mission_message = "sent"
				end
			end
			formalWar()
		else
			for i,em in ipairs(missions) do
				if player.level == em.level then
					if not em.enemy then
						nonCombatMissions(em)
					else
						missionAgainstEnemies(em)
						break
					end
				end
			end
		end
	end
	if home_station:isValid() then
		if home_station.defensive_rotation then
			home_station:setRotation((home_station:getRotation() + .1)%360)
		end
	else
		globalMessage(_("msgMainscreen","Your home station has been destroyed"))
		victory("Kraylor")
	end
	if not nemesis_station:isValid() then
		globalMessage(_("msgMainscreen","You have destroyed the Kraylor primary military station"))
		victory("Human Navy")
	end
	updatePlayerLongRangeSensors(delta,player)
	maintainTransports()
	buildDefensePlatforms()
	cleanUpMessages()
	handleVoiceQueue()
end
