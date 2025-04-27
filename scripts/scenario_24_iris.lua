-- Name: Iris Siege
-- Description: The system holds destructive nebulae at bay but enemies sabotage our defensive apparatus. Stop them before the system is overwhelmed.
---
---	Designed for one or more player ships. Terrain changes each time the scenario is run. Scenario inspired by aspects of a scenario written by srps.
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Murphy[Extreme]: Random factors are severely against you
-- Murphy[Quixotic]: No need for paranoia, the universe *is* out to get you
-- Setting[Respawn]: Configures whether the player ship or ships automatically respawn in game or not and how often if they do automatically respawn
-- Respawn[None|Default]: Player ships do not automatically respawn
-- Respawn[One]: Player ships will automatically respawn once
-- Respawn[Two]: Player ships will automatically respawn twice
-- Respawn[Three]: Player ships will automatically respawn thrice
-- Respawn[Infinite]: Player ships will automatically respawn forever
-- Setting[ReputationGoal]: Sets the reputation goal to win the game. Default 500 runs about an hour
-- ReputationGoal[300]: Accumulate 300 reputation points to win
-- ReputationGoal[400]: Accumulate 400 reputation points to win
-- ReputationGoal[500|Default]: Accumulate 500 reputation points to win
-- ReputationGoal[600]: Accumulate 600 reputation points to win
-- ReputationGoal[700]: Accumulate 700 reputation points to win
-- ReputationGoal[800]: Accumulate 800 reputation points to win
-- ReputationGoal[900]: Accumulate 900 reputation points to win
-- ReputationGoal[1000]: Accumulate 1000 reputation points to win
-- ReputationGoal[1100]: Accumulate 1100 reputation points to win
-- ReputationGoal[1200]: Accumulate 1200 reputation points to win

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")

function init()
	scenario_version = "1.0.0"
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: Iris Seige    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	distance_diagnostic = false
	probe_diagnostic = false
	inner_station_construction_diagnostic = false
	outer_station_construction_diagnostic = false
	setConstants()
	setGlobals()
	setVariations()
	mainGMButtons()
	constructEnvironment()
	onNewPlayerShip(setPlayers)
end
function setConstants()
	pretty_system = {
		["reactor"] = _("stationServices-comms","reactor"),
		["beamweapons"] = _("stationServices-comms","beam weapons"),
		["missilesystem"] = _("stationServices-comms","missile system"),
		["maneuver"] = _("stationServices-comms","maneuver"),
		["impulse"] = _("stationServices-comms","impulse engines"),
		["warp"] = _("stationServices-comms","warp drive"),
		["jumpdrive"] = _("stationServices-comms","jump drive"),
		["frontshield"] = _("stationServices-comms","front shield"),
		["rearshield"] = _("stationServices-comms","rear shield"),
	}
	pretty_short_system = {
		["reactor"] = _("stationServices-comms","reactor"),
		["beamweapons"] = _("stationServices-comms","beams"),
		["missilesystem"] = _("stationServices-comms","missiles"),
		["maneuver"] = _("stationServices-comms","maneuver"),
		["impulse"] = _("stationServices-comms","impulse"),
		["warp"] = _("stationServices-comms","warp"),
		["jumpdrive"] = _("stationServices-comms","jump"),
		["frontshield"] = _("stationServices-comms","front shield"),
		["rearshield"] = _("stationServices-comms","rear shield"),
	}
	system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	stations_improve_ships = true
	stations_sell_goods = true
	stations_buy_goods = true
	stations_trade_goods = true
	stations_support_transport_missions = true
	stations_support_cargo_missions = true
	current_orders_button = true
	center_x = 200000 + random(-80000,80000)
	center_y = 150000 + random(-60000,60000)
	inner_orbit = 20000
	outer_orbit = 40000
	max_repeat_loop = 100
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
		["Farco 11"] =			{strength = 21,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco11},
		["Storm"] =				{strength = 22,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Warden"] =			{strength = 22,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Racer"] =				{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
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
		["Elara P2"] =			{strength = 28,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = tempest},
		["Strikeship"] =		{strength = 30,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Maniapak"] =			{strength = 34,	adder = true,	missiler = false,	beamer = false,	frigate = false, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = maniapak},
		["Fiend G4"] =			{strength = 35,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Cucaracha"] =			{strength = 36,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = cucaracha},
		["Fiend G5"] =			{strength = 37,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G6"] =			{strength = 39,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Barracuda"] =			{strength = 40,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = barracuda},
		["Ryder"] =				{strength = 41, adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 90,	hop_range = 1180,	create = stockTemplate},
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
		["Battlestation"] =		{strength = 100,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2480,	create = stockTemplate},
		["Fortress"] =			{strength = 130,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2380,	create = stockTemplate},
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
		["Small Station"] =		{neb = 9000,	touch = 300,	defend = 2600,	platform = 1200,	outer_platform = 7500},
		["Medium Station"] =	{neb = 10800,	touch = 1200,	defend = 4000,	platform = 2400,	outer_platform = 9100},
		["Large Station"] =		{neb = 11600,	touch = 1400,	defend = 4600,	platform = 2800,	outer_platform = 9700},
		["Huge Station"] =		{neb = 12300,	touch = 2000,	defend = 4960,	platform = 3500,	outer_platform = 10100},
	}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
end
function setGlobals()
	messages = {}
	wave_enemies = {}
	wave_number = 0
	task_force_number = 0
	wave_task = {}
	defense_network = {}
	spawn_wave_time = getScenarioTime() + 10
	original_defending_stations = 0
	original_friendly_defending_stations = 0
	maintenancePlot = warpJammerMaintenance
	enemy_fleets = {}
	probe_types = {
		["Guard"] =		{cat = "patrol",		speed = 1000,	cost = math.random(0,4) + 2,	quantity = 5,	desc = "Travel at warp 1 to destination, then patrol around the ship in a hexagon outline.",	},
		["Doberman"] =	{cat = "patrol",		speed = 2000,	cost = math.random(0,4) + 7,	quantity = 5,	desc = "Travel at warp 2 to destination, then patrol around the ship in a hexagon outline.",	},
		["Radar"] =		{cat = "patrol",		speed = 3000,	cost = math.random(0,4) + 12,	quantity = 5,	desc = "Travel at warp 3 to destination, then patrol around the ship in a hexagon outline.",	},
		["Mark 3"] =	{cat = "fast",			speed = 2000,	cost = math.random(0,4) + 3,	quantity = 5,	desc = "Travel at warp 2 to destination.",	},
		["Gogo"] =		{cat = "fast",			speed = 3000,	cost = math.random(0,4) + 8,	quantity = 5,	desc = "Travel at warp 3 to destination.",	},
		["Screamer"] =	{cat = "fast",			speed = 4000,	cost = math.random(0,4) + 15,	quantity = 5,	desc = "Travel at warp 4 to destination.",	},
		["Snag"] =		{cat = "warpjam",		speed = 2500,	cost = math.random(0,4) + 4,	quantity = 5,	range = 10,	desc = "Travel at warp 2.5 to destination and drop a warp jammer of range 10 units.",	},
		["Mire"] = 		{cat = "warpjam",		speed = 2000,	cost = math.random(0,4) + 9,	quantity = 5,	range = 15,	desc = "Travel at warp 2 to destination and drop a warp jammer of range 15 units.",	},
		["Swamp"] =		{cat = "warpjam",		speed = 1500,	cost = math.random(0,4) + 14,	quantity = 5,	range = 20,	desc = "Travel at warp 1 to destination and drop a warp jammer of range 20 units.",	},
		["Spectacle"] =	{cat = "sensorboost",	speed = 1000,	cost = math.random(0,4) + 7,	quantity = 5,	range = 30,		boost = 10,	desc = "Travel at warp 1 to destination. Effectiveness range: 20 units. Boost sensor range by 10 units.",	},
		["Binoc"] =		{cat = "sensorboost",	speed = 1000,	cost = math.random(0,4) + 12,	quantity = 5,	range = 40,		boost = 20,	desc = "Travel at warp 1 to destination. Effectiveness range: 20 units. Boost sensor range by 20 units.",	},
		["Scope"] =		{cat = "sensorboost",	speed = 1000,	cost = math.random(0,4) + 17,	quantity = 5,	range = 50,		boost = 30,	desc = "Travel at warp 1 to destination. Effectiveness range: 20 units. Boost sensor range by 30 units.",	},
		["Maunakea"] =	{cat = "observatory",	speed = 1000,	cost = math.random(0,4) + 24,	quantity = 3,	range = 20,		hull = 150,	shield = 100,	desc = "Travel at warp 1 to destination then deploy observatory with a sensor range of 20 units, hull strength of 150, shield strength of 100.",	},
		["Arcetri"] =	{cat = "observatory",	speed = 1000,	cost = math.random(0,4) + 19,	quantity = 3,	range = 5,		hull = 50,	shield = 50,	desc = "Travel at warp 1 to destination then deploy observatory with a sensor range of 5 units, hull strength of 50, shield strength of 50.",	},
		["Kitt"] =		{cat = "observatory",	speed = 1000,	cost = math.random(0,4) + 25,	quantity = 3,	range = 10,		hull = 100,	shield = 150,	desc = "Travel at warp 1 to destination then deploy observatory with a sensor range of 10 units, hull strength of 100, shield strength of 150.",	},
		["Palomar"] =	{cat = "observatory",	speed = 1000,	cost = math.random(0,4) + 30,	quantity = 3,	range = 20,		hull = 150,	shield = 300,	desc = "Travel at warp 1 to destination then deploy observatory with a sensor range of 20 units, hull strength of 150, shield strength of 300.",	},
		["Tector"] =	{cat = "scan",			speed = 1000,	cost = math.random(0,4) + 4,	quantity = 3,	range = 5,		full = false,	desc = "Travel at warp 1 to destination. Automatically simple scan ships within 5 units.",	},
		["Grat"] =		{cat = "scan",			speed = 2500,	cost = math.random(0,4) + 9,	quantity = 3,	range = 5,		full = false,	desc = "Travel at warp 2.5 to destination. Automatically simple scan ships within 5 units.",	},
		["Watcher"] =	{cat = "scan",			speed = 1000,	cost = math.random(0,4) + 14,	quantity = 3,	range = 5,		full = true,	desc = "Travel at warp 1 to destination. Automatically fully scan ships within 5 units.",	},
		["007"] =		{cat = "scan",			speed = 2500,	cost = math.random(0,4) + 19,	quantity = 3,	range = 5,		full = true,	desc = "Travel at warp 2.5 to destination. Automatically fully scan ships within 5 units.",	},
		["LDSM 1.1"] =	{cat = "mine",			speed = 1000,	cost = math.random(0,4) + 33,	quantity = 3,	fetus = 1,		mines = 1,		desc = "Travel at warp 1 to destination. Deploy 1 mine.", },
		["LDSM 2.1"] =	{cat = "mine",			speed = 2000,	cost = math.random(0,4) + 38,	quantity = 3,	fetus = 1,		mines = 1,		desc = "Travel at warp 2 to destination. Deploy 1 mine.", },
		["LDSM 3.1"] =	{cat = "mine",			speed = 3000,	cost = math.random(0,4) + 43,	quantity = 3,	fetus = 1,		mines = 1,		desc = "Travel at warp 3 to destination. Deploy 1 mine.", },
		["LDSM 1.2"] =	{cat = "mine",			speed = 1000,	cost = math.random(0,4) + 35,	quantity = 3,	fetus = 2,		mines = 3,		desc = "Travel at warp 1 to destination. Deploy 3 mines.", },
		["LDSM 1.3"] =	{cat = "mine",			speed = 1000,	cost = math.random(0,4) + 40,	quantity = 3,	fetus = 3,		mines = 5,		desc = "Travel at warp 1 to destination. Deploy 5 mines.", },
		["LDSM 2.2"] =	{cat = "mine",			speed = 2000,	cost = math.random(0,4) + 45,	quantity = 3,	fetus = 2,		mines = 3,		desc = "Travel at warp 2 to destination. Deploy 3 mines.", },
		["LDSM 3.2"] =	{cat = "mine",			speed = 3000,	cost = math.random(0,4) + 50,	quantity = 3,	fetus = 2,		mines = 3,		desc = "Travel at warp 3 to destination. Deploy 3 mines.", },
	}
	boost_probe_list = {}
	mine_labor_probe_list = {}
	scan_ship_probe_list = {}
	deployed_players = {}
	deployed_player_count = 0
	sensor_impact = 1	--normal
	player_ship_stats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, probes = 8,	tractor = false,	mining = false	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, probes = 8,	tractor = false,	mining = false	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, probes = 8,	tractor = true,		mining = false	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = true	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = true	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Proto-Atlantis"]		= { strength = 40,	cargo = 4,	distance = 400,	long_range_radar = 30000, short_range_radar = 4500, probes = 8,	tractor = false,	mining = true	},
		["Saipan"]				= { strength = 30,	cargo = 4,	distance = 200,	long_range_radar = 25000, short_range_radar = 4500, probes = 10,tractor = false,	mining = false	},
		["Stricken"]			= { strength = 40,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Surkov"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Redhook"]				= { strength = 11,	cargo = 8,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Pacu"]				= { strength = 18,	cargo = 7,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = false	},
		["Wombat"]				= { strength = 13,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 6000, probes = 8,	tractor = false,	mining = false	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, probes = 8,	tractor = true,		mining = false	},
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = true	},
		["Flavia 2C"]			= { strength = 25,	cargo = 12,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = true	},
		["Destroyer IV"]		= { strength = 25,	cargo = 5,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Destroyer III"]		= { strength = 25,	cargo = 7,	distance = 200,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["MX-Lindworm"]			= { strength = 10,	cargo = 3,	distance = 100,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 8,	tractor = false,	mining = false	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, probes = 8,	tractor = true,		mining = false	},
		["Era"]					= { strength = 14,	cargo = 14,	distance = 200,	long_range_radar = 50000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
		["Squid"]				= { strength = 14,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 8,	tractor = false,	mining = false	},
		["Atlantis II"]			= { strength = 60,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 8,	tractor = true,		mining = true	},
	}
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
	fleet_composition_labels = {
		["Random"] = _("buttonGM","Random"),
		["Fighters"] = _("buttonGM","Fighters"),
		["Chasers"] = _("buttonGM","Chasers"),
		["Frigates"] = _("buttonGM","Frigates"),
		["Beamers"] = _("buttonGM","Beamers"),
		["Missilers"] = _("buttonGM","Missilers"),
		["Adders"] = _("buttonGM","Adders"),
		["Non-DB"] = _("buttonGM","Non-DB"),
		["Drones"] = _("buttonGM","Drones"),
	}
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
		_("scienceDescription-buoy","Visit the Proboscis shop for all your specialty probe needs"),
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
			info = {
				{
					name = "Gamma Piscium",
					unscanned = _("scienceDescription-star","Yellow, spectral type G8 III"),
					scanned = _("scienceDescription-star","Yellow, spectral type G8 III, giant, surface temperature 4,833 K, 11 solar radii"),
				},
				{
					name = "Beta Leporis",
					unscanned = _("scienceDescription-star","Classification G5 II"),
					scanned = _("scienceDescription-star","Classification G5 II, bright giant, possible binary"),
				},
				{
					name = "Sigma Draconis",
					unscanned = _("scienceDescription-star","Classification K0 V or G9 V"),
					scanned = _("scienceDescription-star","Classification K0 V or G9 V, main sequence dwarf, 84% of Sol mass"),
				},
				{
					name = "Iota Carinae",
					unscanned = _("scienceDescription-star","Classification A7 lb"),
					scanned = _("scienceDescription-star","Classification A7 lb, supergiant, temprature 7,500 K, 7xSol mass"),
				},
				{
					name = "Theta Arietis",
					unscanned = _("scienceDescription-star","Classification A1 Vn"),
					scanned = _("scienceDescription-star","Classification A1 Vn, type A main sequence, binary, nebulous"),
				},
				{
					name = "Epsilon Indi",
					unscanned = _("scienceDescription-star","Classification K5V"),
					scanned = _("scienceDescription-star","Classification K5V, orange, temperature 4,649 K"),
				},
				{
					name = "Beta Hydri",
					unscanned = _("scienceDescription-star","Classification G2 IV"),
					scanned = _("scienceDescription-star","Classification G2 IV, 113% of Sol mass, 185% Sol radius"),
				},
				{
					name = "Acamar",
					unscanned = _("scienceDescription-star","Classification A3 IV-V"),
					scanned = _("scienceDescription-star","Classification A3 IV-V, binary, 2.6xSol mass"),
				},
				{
					name = "Bellatrix",
					unscanned = _("scienceDescription-star","Classification B2 III or B2 V"),
					scanned = _("scienceDescription-star","Classification B2 III or B2 V, 8.6xSol mass, temperature 22,000 K"),
				},
				{
					name = "Castula",
					unscanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5"),
					scanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5, yellow, red clump giant"),
				},
				{
					name = "Dziban",
					unscanned = _("scienceDescription-star","Classification F5 IV-V"),
					scanned = _("scienceDescription-star","Classification F5 IV-V, binary, F-type subgiant and F-type main sequence"),
				},
				{
					name = "Elnath",
					unscanned = _("scienceDescription-star","Classification B7 III"),
					scanned = _("scienceDescription-star","Classification B7 III, B-class giant, double star, 5xSol mass"),
				},
				{
					name = "Flegetonte",
					unscanned = _("scienceDescription-star","Classification K0"),
					scanned = _("scienceDescription-star","Classification K0, orange-red, temperature ~4,000 K"),
				},
				{
					name = "Geminga",
					unscanned = _("scienceDescription-star","Pulsar or Neutron star"),
					scanned = _("scienceDescription-star","Pulsar or Neutron star, gamma ray source"),
				},
				{	
					name = "Helvetios",	
					unscanned = _("scienceDescription-star","Classification G2V"),
					scanned = _("scienceDescription-star","Classification G2V, yellow, temperature 5,571 K"),
				},
				{	
					name = "Inquill",	
					unscanned = _("scienceDescription-star","Classification G1V(w)"),
					scanned = _("scienceDescription-star","Classification G1V(w), 1.24xSol mass, 7th magnitude G-type main sequence"),
				},
				{	
					name = "Jishui",	
					unscanned = _("scienceDescription-star","Classification F3 III"),
					scanned = _("scienceDescription-star","Classification F3 III, F-type giant, temperature 6,309 K"),
				},
				{	
					name = "Kaus Borealis",	
					unscanned = _("scienceDescription-star","Classification K1 IIIb"),
					scanned = _("scienceDescription-star","Classification K1 IIIb, giant, temperature 4,768 K"),
				},
				{	
					name = "Liesma",	
					unscanned = _("scienceDescription-star","Classification G0V"),
					scanned = _("scienceDescription-star","Classification G0V, G-type giant, temperature 5,741 K"),
				},
				{	
					name = "Macondo",	
					unscanned = _("scienceDescription-star","Classification K2IV-V or K3V"),
					scanned = _("scienceDescription-star","Classification K2IV-V or K3V, orange, K-type main sequence, temperature 5,030 K"),
				},
				{	name = "Nikawiy",	},
				{	name = "Orkaria",	},
				{	name = "Poerava",	},
				{	name = "Stribor",	},
				{	name = "Taygeta",	},
				{	name = "Tuiren",	},
				{	name = "Ukdah",	},
				{	name = "Wouri",	},
				{	name = "Xihe",	},
				{	name = "Yildun",	},
				{	name = "Zosma",	},
			},
			color = {
				red = random(0.5,1), green = random(0.5,1), blue = random(0.5,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
	planet_list = {
		{
			name = {"Bespin","Aldea","Bersallis"},
			texture = {
				surface = "planets/gas-1.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			texture = {
				surface = "planets/gas-2.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			texture = {
				surface = "planets/gas-3.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Alderaan","Dagobah","Dantooine","Rigel"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-1.png", 
				cloud = "planets/clouds-1.png", 
				atmosphere = "planets/atmosphere.png"
			},
			radius = random(3000,5000),
		},
		{
			name = {"Pahvo","Penthara","Scalos"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-4.png", 
				cloud = "planets/clouds-3.png", 
				atmosphere = "planets/atmosphere.png"
			},
			radius = random(3000,5000),
		},
		{
			name = {"Tanuga","Vacca","Terlina","Timor"},
			color = {
				red = random(0,0.2), 
				green = random(0,0.2), 
				blue = random(0.8,1)
			},
			texture = {
				surface = "planets/planet-5.png", 
				cloud = "planets/clouds-2.png", 
				atmosphere = "planets/atmosphere.png"
			},
			radius = random(3000,5000),
		},
	}
end
function setVariations()
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	rep = 90,	bump = 20,	},
		["Normal"] =	{number = 1,	rep = 50,	bump = 10,	},
		["Hard"] =		{number = 2,	rep = 30,	bump = 5,	},
		["Extreme"] =	{number = 3,	rep = 20,	bump = 3,	},
		["Quixotic"] =	{number = 5,	rep = 10,	bump = 1,	},
	}
	difficulty =				murphy_config[getScenarioSetting("Murphy")].number
	adverseEffect =				murphy_config[getScenarioSetting("Murphy")].adverse
	coolant_loss =				murphy_config[getScenarioSetting("Murphy")].lose_coolant
	coolant_gain =				murphy_config[getScenarioSetting("Murphy")].gain_coolant
	reputation_start_amount =	murphy_config[getScenarioSetting("Murphy")].rep
	reputation_bump_amount =	murphy_config[getScenarioSetting("Murphy")].bump
	local respawn_config = {
		["None"] =		{respawn = false,	max = 0},
		["One"] =		{respawn = true,	max = 1},
		["Two"] =		{respawn = true,	max = 2},
		["Three"] =		{respawn = true,	max = 3},
		["Infinite"] =	{respawn = true,	max = 999},	--I know, it's not infinite, but come on, after 999, it should stop
	}
	player_respawns = respawn_config[getScenarioSetting("Respawn")].respawn
	player_respawn_max = respawn_config[getScenarioSetting("Respawn")].max
	reputation_goal = getScenarioSetting("ReputationGoal")
	primary_orders = string.format("Reach %s reputation before friendly station nebula defense nodes destroyed.",reputation_goal)
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
end
function setPlayers()
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			updatePlayerSoftTemplate(p)
			deployed_player_count = deployed_player_count + 1
		end
		local already_recorded = false
		for j,dp in ipairs(deployed_players) do
			if p == dp.p then
				already_recorded = true
				break
			end
		end
		if not already_recorded then
			table.insert(deployed_players,{p=p,name=p:getCallSign(),count=1,template=p:getTypeName()})
		end
	end
end
function updatePlayerSoftTemplate(p)
	p:setPosition(player_spawn_x, player_spawn_y)
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	p:setFaction(player_faction)
	p.command_log = {}
	p:onDestroyed(playerDestroyed)
	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
	end
	if p.probe_type_list == nil then
		p.probe_type_list = {}
		table.insert(p.probe_type_list,{name = "standard", count = -1})
	end
	local temp_type_name = p:getTypeName()
	if temp_type_name ~= nil then
		local p_stat = player_ship_stats[temp_type_name]
		if p_stat ~= nil then
			p.maxCargo = p_stat.cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(p_stat.probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p:setLongRangeRadarRange(player_ship_stats[temp_type_name].long_range_radar)
			p:setShortRangeRadarRange(player_ship_stats[temp_type_name].short_range_radar)
			p.normal_long_range_radar = player_ship_stats[temp_type_name].long_range_radar
			p.tractor = p_stat.tractor
			p.tractor_target_lock = false
			p.mining = p_stat.mining
			if p.name_set == nil then
				local player_ship_name_list = player_ship_names_for[temp_type_name]
				local player_ship_name = nil
				if player_ship_name_list ~= nil then
					player_ship_name = tableRemoveRandom(player_ship_name_list)
				end
				if player_ship_name == nil then
					player_ship_name = tableSelectRandom(player_ship_names_for["Leftovers"])
				end
				if player_ship_name ~= nil then
					p:setCallSign(player_ship_name)
				end
				p.name_set = true
			end
			p.score_settings_source = temp_type_name
		else
			addGMMessage(string.format("Player ship %s's template type (%s) could not be found in table player_ship_stats",p:getCallSign(),temp_type_name))
		end
	end
	p.maxRepairCrew = p:getRepairCrewCount()
	p.healthyShield = 1.0
	p.prevShield = 1.0
	p.healthyReactor = 1.0
	p.prevReactor = 1.0
	p.healthyManeuver = 1.0
	p.prevManeuver = 1.0
	p.healthyImpulse = 1.0
	p.prevImpulse = 1.0
	if p:getBeamWeaponRange(0) > 0 then
		p.healthyBeam = 1.0
		p.prevBeam = 1.0
	end
	local tube_count = p:getWeaponTubeCount()
	if tube_count > 0 then
		p.healthyMissile = 1.0
		p.prevMissile = 1.0
		local size_letter = {
			["small"] = 	"S",
			["medium"] =	"M",
			["large"] =		"L",
		}
		p.tube_size = ""
		for i=1,tube_count do
			p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
		end
	end
	if p:hasWarpDrive() then
		p.healthyWarp = 1.0
		p.prevWarp = 1.0
	end
	if p:hasJumpDrive() then
		p.healthyJump = 1.0
		p.prevJump = 1.0
	end
	p.initialCoolant = p:getMaxCoolant()
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
	p.defense_network_button_rel = "defense_network_button_rel"
	p:addCustomButton("Relay",p.defense_network_button_rel,"Defense Network",function()
		string.format("")
		showDefenseNetwork(p,"Relay")
	end)
	p.defense_network_button_ops = "defense_network_button_ops"
	p:addCustomButton("Operations",p.defense_network_button_ops,"Defense Network",function()
		string.format("")
		showDefenseNetwork(p,"Operations")
	end)
end
function playerDestroyed()
	string.format("")
end
function playerDestruction(self,instigator)
	string.format("")
	for i,dp in ipairs(deployed_players) do
		if self == dp.p then
			if dp.count > player_respawn_max then
				globalMessage(string.format(_("msgMainscreen","%s has been destroyed."),self:getCallSign()))
			else
				local respawned_player = PlayerSpaceship():setTemplate(self:getTypeName()):setFaction(player_faction)
				dp.p = respawned_player
				dp.count = dp.count + 1
				respawned_player:setCallSign(string.format("%s %i",dp.name,dp.count))
				respawned_player.name_set = true
				updatePlayerSoftTemplate(respawned_player)
				globalMessage(string.format(_("msgMainscreen","The %s has respawned %s to replace %s."),player_faction,respawned_player:getCallSign(),self:getCallSign()))
				self:transferPlayersToShip(respawned_player)
			end
			break
		end
	end
end
function constructEnvironment()
	player_spawn_angle = random(0,360)
	player_spawn_x, player_spawn_y = vectorFromAngle(player_spawn_angle,random(8500,13000),true)
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	player_factions = {"Human Navy","CUF","USN","TSN"}
	player_faction = tableSelectRandom(player_factions)
	friendly_factions = {"Human Navy",player_faction}
	if player_faction == "Human Navy" then
		friendly_factions = {"Human Navy","CUF","USN","TSN"}
	end
	friendly_lookup_factions = {}
	for i,faction in ipairs(friendly_factions) do
		friendly_lookup_factions[faction] = true
	end
	local factions = {"Independent","Human Navy","CUF","USN","TSN","Kraylor","Exuari","Ghosts","Ktlitans","Arlenians"}
	non_enemy_factions = {}
	enemy_factions = {}
	comprehensive_enemy_factions = {
		["Human Navy"] = {"Kraylor","Exuari","Ghosts","Ktlitans"},
		["CUF"] = {"Kraylor","Exuari","Ghosts"},
		["TSN"] = {"Kraylor","Arlenians","Exuari","Ktlitans","USN"},
		["USN"] = {"Exuari","Ghosts","Ktlitans","TSN"},
	}
	enemy_factions = comprehensive_enemy_factions[player_faction]
	enemy_lookup_factions = {}
	for i,faction in ipairs(enemy_factions) do
		enemy_lookup_factions[faction] = true
	end
	comprehensive_non_enemy_factions = {
		["Human Navy"] = {"Human Navy","Independent","CUF","USN","TSN","Arlenians"},
		["CUF"] = {"Human Navy","Independent","CUF","USN","TSN","Arlenians","Ktlitans"},
		["TSN"] = {"Human Navy","Independent","TSN","CUF","Ghosts"},
		["USN"] = {"Human Navy","Independent","CUF","USN","Kraylor","Arlenians"},
	}
	non_enemy_factions = comprehensive_non_enemy_factions[player_faction]
	non_enemy_lookup_factions = {}
	for i,faction in ipairs(non_enemy_factions) do
		non_enemy_lookup_factions[faction] = true
	end
	inner_space = {}
	--central planet
	local selected_planet = tableRemoveRandom(planet_list)
	region_planet = Planet():setPlanetRadius(selected_planet.radius)
	region_planet:setPosition(center_x,center_y)
	region_planet:setDistanceFromMovementPlane(selected_planet.radius * -.25)
	region_planet:setCallSign(tableSelectRandom(selected_planet.name))
	region_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
	local rotation_time = random(500,700)
	if selected_planet.texture.atmosphere ~= nil then
		rotation_time = rotation_time - 200
		region_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
	end
	if selected_planet.texture.cloud ~= nil then
		region_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
	end
	if selected_planet.color ~= nil then
		region_planet:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
	end
	region_planet:setAxialRotationTime(rotation_time)
	table.insert(inner_space,{obj=region_planet,dist=selected_planet.radius * 1.5 + 1000,shape="circle"})
	inner_stations = {}
	stations = {}
	table.insert(inner_space,{obj=VisualAsteroid():setPosition(player_spawn_x,player_spawn_y),dist=500,shape="circle"})
	local inner_station_count = math.random(4,6)
	local gap_distance = 0
	local gap_angle = 0	
	local prev_angle = nil
	for i=1,inner_station_count do
		local angle = (player_spawn_angle + (360/inner_station_count) * i + (360/inner_station_count/2)) % 360
		angle = (angle + random(-15,15) + 360) % 360
		local psx, psy = vectorFromAngle(angle,random(8500,18000),true)
		if prev_angle ~= nil then
			if angle < prev_angle then
				angle = angle + 360
			end
			local current_gap_distance = angle - prev_angle
			if current_gap_distance > gap_distance then
				gap_distance = current_gap_distance
				gap_angle = (angle + prev_angle)/2
			end
		end
		prev_angle = angle
		psx = psx + center_x
		psy = psy + center_y
		local p_station = placeStation(psx,psy,"RandomHumanNeutral",player_faction)
		p_station.comms_data = {}
		p_station.comms_data.friendlyness = random(50,100)
		p_station.comms_data.weapon_available = {}
		p_station.comms_data.weapon_available.Nuke = true
		p_station.comms_data.weapon_available.EMP = true
		p_station.comms_data.weapon_available.Homing = true
		p_station.comms_data.weapon_available.Mine = true
		p_station.comms_data.weapon_available.HVLI = true
		if random(1,100) < 38 then
			p_station.gradual_coolant_replenish = true
		end
		p_station.gradual_repair_max_health = {}
		for i,sys in ipairs(system_types) do
			if random(1,100) < 43 then
				p_station.gradual_repair_max_health[sys] = true
			else
				p_station.gradual_repair_max_health[sys] = false
			end
		end
		p_station:onDestruction(nebulaDefenseLoss)
		p_station:setDescription(string.format(_("scienceDescription-station","%s. Provides nebula defense."),p_station:getDescription()))
		p_station.nebula_defense = true
		original_defending_stations = original_defending_stations + 1
		original_friendly_defending_stations = original_friendly_defending_stations + 1
		p_station.nebula_push = station_spacing[p_station:getTypeName()].neb
		local desc = string.format("%s Station %s %s",p_station:getSectorName(),p_station:getFaction(),p_station:getCallSign())
		table.insert(defense_network,{obj=p_station,desc=desc})
		table.insert(inner_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
		table.insert(inner_stations,p_station)
		table.insert(stations,p_station)
	end
	warp_jammer_nebula_defense = {}
	local wjn_x, wjn_y = vectorFromAngle(gap_angle,18000,true)
	inner_warp_jammer_nebula_defense = WarpJammer():setPosition(wjn_x + center_x,wjn_y + center_y):setFaction(player_faction)
	inner_warp_jammer_nebula_defense:setRange(random(11300,15000))
	inner_warp_jammer_nebula_defense.range = inner_warp_jammer_nebula_defense:getRange()
	inner_warp_jammer_nebula_defense.nebula_push = 11300
	inner_warp_jammer_nebula_defense:setHull(300)
	inner_warp_jammer_nebula_defense:setScanningParameters(2,1)
	warp_jammer_info[player_faction].count = warp_jammer_info[player_faction].count + 1
	local wj_id = string.format("%sWJ%i",warp_jammer_info[player_faction].id,warp_jammer_info[player_faction].count)
	inner_warp_jammer_nebula_defense:setDescriptions(_("scienceDescription-warpJammer","Warp jammer"),string.format(_("scienceDescription-warpJammer","Warp jammer. Provides nebula defense. Identifier: %s"),wj_id))
	inner_warp_jammer_nebula_defense.identifier = wj_id
	local desc = string.format("%s Warp Jammer %s %s",inner_warp_jammer_nebula_defense:getSectorName(),inner_warp_jammer_nebula_defense:getFaction(),inner_warp_jammer_nebula_defense.identifier)
	table.insert(defense_network,{obj=inner_warp_jammer_nebula_defense,desc=desc})
	table.insert(warp_jammer_list,inner_warp_jammer_nebula_defense)
	table.insert(inner_space,{obj=inner_warp_jammer_nebula_defense,dist=200,shape="circle"})
	table.insert(warp_jammer_nebula_defense,inner_warp_jammer_nebula_defense)
	distort_bell = {
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},	
		{lo = 1000,	hi = 2250},
		{lo = 1000,	hi = 2250},
	}
	inner_station_count = math.random(3,5)
	if inner_station_construction_diagnostic then
		print("second inner station count:",inner_station_count)
	end
	for i=1,inner_station_count do
		local psx, psy = findClearSpot(inner_space,"bell torus",center_x,center_y,18000,distort_bell,nil,12000,true)
		if psx ~= nil then
			local p_station = placeStation(psx,psy,"RandomHumanNeutral",tableSelectRandom(friendly_factions))
			p_station.comms_data = {}
			p_station.comms_data.friendlyness = random(50,100)
			p_station.comms_data.weapon_available = {}
			p_station.comms_data.weapon_available.Nuke = true
			p_station.comms_data.weapon_available.EMP = true
			p_station.comms_data.weapon_available.Homing = true
			p_station.comms_data.weapon_available.Mine = true
			p_station.comms_data.weapon_available.HVLI = true
			if random(1,100) < 38 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 43 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(5000,20000))
			table.insert(inner_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(inner_stations,p_station)
			table.insert(stations,p_station)
		else
			if inner_station_construction_diagnostic then
				print("could not find a place for a friendly station in the inner region")
			end
		end
	end
	local outer_station_count = math.random(8,12)
	outer_space = {}
	outer_stations = {}
	gap_distance = 0
	gap_angle = 0	
	prev_angle = nil
	for i=1,outer_station_count do
		local angle = (player_spawn_angle + (360/outer_station_count) * i) % 360
		angle = (angle + random(-10,10) + 360) % 360
		local dist = random(32000,70000)
		local psx, psy = vectorFromAngle(angle,dist,true)
		if prev_angle ~= nil then
			if angle < prev_angle then
				angle = angle + 360
			end
			local current_gap_distance = angle - prev_angle
			if current_gap_distance > gap_distance then
				gap_distance = current_gap_distance
				gap_angle = (angle + prev_angle)/2
			end
		end
		prev_angle = angle
		psx = psx + center_x
		psy = psy + center_y
		if non_enemy_faction_pool == nil or #non_enemy_faction_pool < 1 then
			non_enemy_faction_pool = {}
			for j,faction in ipairs(non_enemy_factions) do
				table.insert(non_enemy_faction_pool,faction)
			end
		end
		local faction = tableRemoveRandom(non_enemy_faction_pool)
		local p_station = placeStation(psx,psy,"RandomHumanNeutral",faction)
		p_station.comms_data = {}
		p_station.comms_data.friendlyness = random(50,100)
		p_station.comms_data.weapon_available = {}
		p_station.comms_data.weapon_available.Nuke = true
		p_station.comms_data.weapon_available.EMP = true
		p_station.comms_data.weapon_available.Homing = true
		p_station.comms_data.weapon_available.Mine = true
		p_station.comms_data.weapon_available.HVLI = true
		if random(1,100) < 27 then
			p_station.gradual_coolant_replenish = true
		end
		p_station.gradual_repair_max_health = {}
		for i,sys in ipairs(system_types) do
			if random(1,100) < 36 then
				p_station.gradual_repair_max_health[sys] = true
			else
				p_station.gradual_repair_max_health[sys] = false
			end
		end
		p_station:onDestruction(nebulaDefenseLoss)
		p_station:setDescription(string.format(_("scienceDescription-station","%s. Provides nebula defense."),p_station:getDescription()))
		p_station.nebula_defense = true
		original_defending_stations = original_defending_stations + 1
		if friendly_lookup_factions[faction] then
			original_friendly_defending_stations = original_friendly_defending_stations + 1
		end
		p_station.nebula_push = station_spacing[p_station:getTypeName()].neb
		local desc = string.format("%s Station %s %s",p_station:getSectorName(),p_station:getFaction(),p_station:getCallSign())
		table.insert(defense_network,{obj=p_station,desc=desc})
		table.insert(outer_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
		table.insert(outer_stations,p_station)
		table.insert(stations,p_station)
	end
	wjn_x, wjn_y = vectorFromAngle(gap_angle,50000,true)
	outer_warp_jammer_nebula_defense = WarpJammer():setPosition(wjn_x + center_x,wjn_y + center_y):setFaction(player_faction)
	outer_warp_jammer_nebula_defense:setRange(random(11300,15000))
	outer_warp_jammer_nebula_defense.range = outer_warp_jammer_nebula_defense:getRange()
	outer_warp_jammer_nebula_defense.nebula_push = 11300
	outer_warp_jammer_nebula_defense:setHull(300)
	outer_warp_jammer_nebula_defense:setScanningParameters(2,1)
	warp_jammer_info[player_faction].count = warp_jammer_info[player_faction].count + 1
	wj_id = string.format("%sWJ%i",warp_jammer_info[player_faction].id,warp_jammer_info[player_faction].count)
	outer_warp_jammer_nebula_defense:setDescriptions(_("scienceDescription-warpJammer","Warp jammer"),string.format(_("scienceDescription-warpJammer","Warp jammer. Provides nebula defense. Identifier: %s"),wj_id))
	outer_warp_jammer_nebula_defense.identifier = wj_id
	local desc = string.format("%s Warp Jammer %s %s",outer_warp_jammer_nebula_defense:getSectorName(),outer_warp_jammer_nebula_defense:getFaction(),outer_warp_jammer_nebula_defense.identifier)
	table.insert(defense_network,{obj=outer_warp_jammer_nebula_defense,desc=desc})
	table.insert(warp_jammer_list,outer_warp_jammer_nebula_defense)
	table.insert(outer_space,{obj=outer_warp_jammer_nebula_defense,dist=200,shape="circle"})
	table.insert(warp_jammer_nebula_defense,outer_warp_jammer_nebula_defense)
	distort_bell = {
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},	
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
		{lo = 3000,	hi = 7000},
	}
	outer_station_count = math.random(6,12)
	if outer_station_construction_diagnostic then
		print("second outer station count:",outer_station_count)
	end
	for i=1,outer_station_count do
		local psx, psy = findClearSpot(outer_space,"bell torus",center_x,center_y,32000,distort_bell,nil,12000,true)
		if psx ~= nil then
			local p_station = placeStation(psx,psy,"RandomHumanNeutral",tableSelectRandom(friendly_factions))
			p_station.comms_data = {}
			p_station.comms_data.friendlyness = random(50,100)
			p_station.comms_data.weapon_available = {}
			p_station.comms_data.weapon_available.Nuke = true
			p_station.comms_data.weapon_available.EMP = true
			p_station.comms_data.weapon_available.Homing = true
			p_station.comms_data.weapon_available.Mine = true
			p_station.comms_data.weapon_available.HVLI = true
			if random(1,100) < 22 then
				p_station.gradual_coolant_replenish = true
			end
			p_station.gradual_repair_max_health = {}
			for i,sys in ipairs(system_types) do
				if random(1,100) < 63 then
					p_station.gradual_repair_max_health[sys] = true
				else
					p_station.gradual_repair_max_health[sys] = false
				end
			end
			p_station:setShortRangeRadarRange(random(6000,20000))
			table.insert(outer_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].outer_platform,shape="circle"})
			table.insert(outer_stations,p_station)
			table.insert(stations,p_station)
		else
			if outer_station_construction_diagnostic then
				print("could not find a place for a friendly station in the outer region")
			end
		end
	end	
	seige_nebula = {}
	nebula_impact_systems = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield","coolant","hull"}
	pretty_nebula_impact_systems = {
		["reactor"] =		_("scienceDescription-nebula","reactor"), 
		["beamweapons"] =	_("scienceDescription-nebula","beamweapons"), 
		["missilesystem"] =	_("scienceDescription-nebula","missilesystem"), 
		["maneuver"] =		_("scienceDescription-nebula","maneuver"), 
		["impulse"] =		_("scienceDescription-nebula","impulse"), 
		["warp"] =			_("scienceDescription-nebula","warp"), 
		["jumpdrive"] =		_("scienceDescription-nebula","jumpdrive"), 
		["frontshield"] =	_("scienceDescription-nebula","frontshield"), 
		["rearshield"] =	_("scienceDescription-nebula","rearshield"), 
		["coolant"] =		_("scienceDescription-nebula","coolant"), 
		["hull"] =			_("scienceDescription-nebula","hull"),
	}
	for i=1,40 do
		local neb_x, neb_y = vectorFromAngle(i*9,80000,true)
		neb_x = neb_x + center_x
		neb_y = neb_y + center_y
		local neb = Nebula():setPosition(neb_x,neb_y)
		neb.direction = "inbound"
		neb.iris_angle = i*9
		local system_pool = {}
		for j,system in ipairs(nebula_impact_systems) do
			table.insert(system_pool,system)
		end
		local impacted_system_count = math.random(3,5)
		neb.impacted_systems = {}
		for j=1,impacted_system_count do
			table.insert(neb.impacted_systems,tableRemoveRandom(system_pool))
		end
		local impact_list = _("scienceDescription-nebula","Nebula impacts these systems:")
		for j,sys in ipairs(neb.impacted_systems) do
			impact_list = string.format("%s %s",impact_list,pretty_nebula_impact_systems[sys])
		end
		neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula",impact_list))
		neb:setScanningParameters(2,1)
		neb:setRadarSignatureInfo(.5,.5,.5)
		table.insert(seige_nebula,neb)
	end
	local block_dist = 70000
	for i=1,1000 do
		local straw_neb = nil	--the nebula that broke the camel's back
		for j,neb in ipairs(seige_nebula) do
			local halt_neb = false
			local neb_x, neb_y = neb:getPosition()
			local current_distance = distance(neb_x,neb_y,center_x,center_y)
			if current_distance < 20000 then
				straw_neb = neb
				break
			end
			for k,station in ipairs(inner_stations) do
				if station.nebula_defense then
					if distance(station,neb) < station.nebula_push then
						halt_neb = true
						break
					end
				end
			end
			if not halt_neb then
				for k,station in ipairs(outer_stations) do
					if station.nebula_defense then
						if distance(station,neb) < station.nebula_push then
							halt_neb = true
							break
						end
					end
				end
			end
			if not halt_neb then
				for k,wj in ipairs(warp_jammer_nebula_defense) do
					if distance(wj,neb) < wj.nebula_push then
						halt_neb = true
						break
					end
				end
			end
			if not halt_neb then
				local new_distance = current_distance * .99
				local neb_x, neb_y = vectorFromAngle(neb.iris_angle,new_distance,true)
				neb:setPosition(neb_x + center_x,neb_y + center_y)
			end
		end
		if straw_neb ~= nil then
			local block_warp_jammer = WarpJammer()
			local bwj_x, bwj_y = vectorFromAngle(straw_neb.iris_angle,block_dist,true)
			block_warp_jammer:setPosition(bwj_x + center_x, bwj_y + center_y):setRange(random(7000,15000))
			block_warp_jammer.range = block_warp_jammer:getRange()
			block_warp_jammer.nebula_push = 11300
			block_warp_jammer:setHull(100)
			block_warp_jammer:setScanningParameters(2,1)
			warp_jammer_info[block_warp_jammer:getFaction()].count = warp_jammer_info[block_warp_jammer:getFaction()].count + 1
			local wj_id = string.format("%sWJ%i",warp_jammer_info[block_warp_jammer:getFaction()].id,warp_jammer_info[block_warp_jammer:getFaction()].count)
			block_warp_jammer.identifier = wj_id
			block_warp_jammer:setDescriptions(_("scienceDescription-warpJammer","Warp jammer"),string.format(_("scienceDescription-warpJammer","Warp jammer. Provides nebula defense. Identifier: %s"),wj_id))
			local desc = string.format("%s Warp Jammer %s %s",block_warp_jammer:getSectorName(),block_warp_jammer:getFaction(),block_warp_jammer.identifier)
			table.insert(defense_network,{obj=block_warp_jammer,desc=desc})
			table.insert(warp_jammer_list,block_warp_jammer)
			table.insert(outer_space,{obj=block_warp_jammer,dist=200,shape="circle"})
			table.insert(warp_jammer_nebula_defense,block_warp_jammer)
			block_dist = block_dist - random(5000,10000)
			if block_dist < 30000 then
				block_dist = 30000
			end
			for j,neb in ipairs(seige_nebula) do
				local neb_x, neb_y = vectorFromAngle(j*9,80000,true)
				neb_x = neb_x + center_x
				neb_y = neb_y + center_y
				neb:setPosition(neb_x,neb_y)
			end
			straw_neb = nil
		end
	end
	enemy_stations = {}
	local enemy_faction_pool = {}
	for i,faction in ipairs(enemy_factions) do
		table.insert(enemy_faction_pool,faction)
	end
	local psx, psy = findClearSpot(inner_space,"torus",center_x,center_y,8500,18000,nil,6000,true)
	if psx ~= nil then
		local p_station = placeStation(psx,psy,"Sinister",tableRemoveRandom(enemy_faction_pool))
		table.insert(inner_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].defend,shape="circle"})
		table.insert(inner_stations,p_station)
		table.insert(stations,p_station)
		table.insert(enemy_stations,p_station)
--	else
--		print("could not find place for enemy station in inner space")
	end
	for i,faction in ipairs(enemy_faction_pool) do
		psx, psy = findClearSpot(outer_space,"torus",center_x,center_y,32000,60000,nil,6000,true)
		if psx ~= nil then
			local p_station = placeStation(psx,psy,"Sinister",faction)
			table.insert(outer_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].defend,shape="circle"})
			table.insert(outer_stations,p_station)
			table.insert(stations,p_station)
			table.insert(enemy_stations,p_station)
		else
			print(string.format("could not find place for %s station in outer space",faction))
		end
	end
	peripheral_stations = {}
	for i,faction in ipairs(factions) do
		psx, psy = findClearSpot(outer_space,"torus",center_x,center_y,90000,120000,nil,12000,true)
		if psx ~= nil then
			local station_name = "RandomHumanNeutral"
			if enemy_factions[faction] ~= nil then
				station_name = "Sinister"
			end
			local p_station = placeStation(psx,psy,station_name,faction)
			if proboscis_station == nil then
				if not friendly_lookup_factions[faction] then
					if non_enemy_lookup_factions[faction] then
						proboscis_station = p_station
--						print("Proboscis:",p_station:getCallSign(),p_station:getSectorName())
					end
				end
			end
			table.insert(outer_space,{obj=p_station,dist=station_spacing[p_station:getTypeName()].defend,shape="circle"})
			table.insert(peripheral_stations,p_station)
			table.insert(stations,p_station)
			if station_name == "Sinister" then
				table.insert(enemy_stations,p_station)
			end
		else
			print(string.format("could not find a place for %s station on the periphery",faction))
		end
	end
	friendly_spike_stations = {}
	for i,station in ipairs(peripheral_stations) do
		table.insert(friendly_spike_stations,station)
	end
	station_list = {}
	for i,station in ipairs(stations) do
		table.insert(station_list,station)
	end
	orbiting_asteroids = {}
	for i=1,10 do
		local orbit_speed = random(1,20)
		for j=1,15 do
			local angle = random(0,360)
			local lo = (i-1) * 1000
			local hi = i * 1000
			local dist_interval = random(lo,hi)
			local dist = 20000 + dist_interval
			local ax, ay = vectorFromAngle(angle,dist,true)
			local a = Asteroid():setPosition(ax + center_x, ay + center_y)
			local max_size = math.min(dist_interval - lo, hi - dist_interval)
			local a_size = math.min(max_size,random(1,80) + random(1,80) + random(1,80) + random(1,80) + random(1,80) + random(1,80) + random(1,80) + random(1,80) + random(1,80) + random(1,80))
			a:setSize(a_size)
			a.angle = angle
			a.orbit_speed = orbit_speed
			a.dist = dist
			a.x = ax + center_x
			a.y = ay + center_y
			table.insert(orbiting_asteroids,a)
		end
	end
	transport_list = {}
	placement_areas = {
		["Inner Torus"] = {
			stations = inner_stations,
			transports = transport_list, 
			space = inner_space,
			shape = "torus",
			center_x = center_x, 
			center_y = center_y, 
			inner_radius = 8000, 
			outer_radius = 20000,
		},
		["Outer Torus"] = {
			stations = outer_stations,
			transports = transport_list, 
			space = outer_space,
			shape = "torus",
			center_x = center_x, 
			center_y = center_y, 
			inner_radius = 30000, 
			outer_radius = 70000,
		},
		["Peripheral Torus"] = {
			stations = peripheral_stations,
			transports = transport_list, 
			space = outer_space,
			shape = "torus",
			center_x = center_x, 
			center_y = center_y, 
			inner_radius = 90000, 
			outer_radius = 120000,
		},
	}
	local terrain = {
--		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
--		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
--		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
		{chance = 4,	count = 0,	max = math.random(7,15),	radius = "Tiny",	obj = WarpJammer,						},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Tiny",	obj = Artifact,		desc = "Jammer",	},
--		{chance = 3,	count = 0,	max = math.random(1,3),		radius = "Hole",	obj = WormHole,							},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Tiny",	obj = Artifact,		desc = "Sensor",	},
		{chance = 8,	count = 0,	max = -1,					radius = "Tiny",	obj = Artifact,		desc = "Ad",		},
		{chance = 8,	count = 0,	max = -1,					radius = "Neb",		obj = Nebula,							},
		{chance = 5,	count = 0,	max = -1,					radius = "Mine",	obj = Mine,								},
		{chance = 5,	count = 0,	max = math.random(3,7),		radius = "Circ",	obj = Mine,			desc = "Circle",	},
		{chance = 5,	count = 0,	max = math.random(3,9),		radius = "Rect",	obj = Mine,			desc = "Rectangle",	},
		{chance = 5,	count = 0,	max = math.random(2,7),		radius = "Field",	obj = Asteroid,		desc = "Field",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Asteroid,		desc = "Blob",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Mine,			desc = "Blob",		},
		{chance = 4,	count = 0,	max = 10,					radius = "Trans",	obj = CpuShip,		desc = "Transport",	},
		{chance = 4,	count = 0,	max = 10,					radius = "Tiny",	obj = SupplyDrop,						},
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
					placement_result = placeTerrain("Inner Torus",terrain_object)
				else
					placement_result = placeTerrain("Inner Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				end
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
				break
			elseif i == #terrain then
				placement_result = placeTerrain("Inner Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 30)
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
		{chance = 4,	count = 0,	max = math.random(7,15),	radius = "Tiny",	obj = WarpJammer,						},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Tiny",	obj = Artifact,		desc = "Jammer",	},
		{chance = 3,	count = 0,	max = math.random(1,3),		radius = "Hole",	obj = WormHole,							},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Tiny",	obj = Artifact,		desc = "Sensor",	},
		{chance = 8,	count = 0,	max = -1,					radius = "Tiny",	obj = Artifact,		desc = "Ad",		},
		{chance = 8,	count = 0,	max = -1,					radius = "Neb",		obj = Nebula,							},
		{chance = 5,	count = 0,	max = -1,					radius = "Mine",	obj = Mine,								},
		{chance = 5,	count = 0,	max = math.random(3,7),		radius = "Circ",	obj = Mine,			desc = "Circle",	},
		{chance = 5,	count = 0,	max = math.random(3,9),		radius = "Rect",	obj = Mine,			desc = "Rectangle",	},
		{chance = 5,	count = 0,	max = math.random(2,7),		radius = "Field",	obj = Asteroid,		desc = "Field",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Asteroid,		desc = "Blob",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Mine,			desc = "Blob",		},
		{chance = 4,	count = 0,	max = 10,					radius = "Trans",	obj = CpuShip,		desc = "Transport",	},
		{chance = 4,	count = 0,	max = 10,					radius = "Tiny",	obj = SupplyDrop,						},
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
					placement_result = placeTerrain("Outer Torus",terrain_object)
				else
					placement_result = placeTerrain("Outer Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				end
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
				break
			elseif i == #terrain then
				placement_result = placeTerrain("Outer Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 80)
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
		{chance = 4,	count = 0,	max = math.random(7,15),	radius = "Tiny",	obj = WarpJammer,						},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Tiny",	obj = Artifact,		desc = "Jammer",	},
		{chance = 3,	count = 0,	max = math.random(1,3),		radius = "Hole",	obj = WormHole,							},
		{chance = 6,	count = 0,	max = math.random(2,5),		radius = "Tiny",	obj = Artifact,		desc = "Sensor",	},
		{chance = 8,	count = 0,	max = -1,					radius = "Tiny",	obj = Artifact,		desc = "Ad",		},
		{chance = 8,	count = 0,	max = -1,					radius = "Neb",		obj = Nebula,							},
		{chance = 5,	count = 0,	max = -1,					radius = "Mine",	obj = Mine,								},
		{chance = 5,	count = 0,	max = math.random(3,7),		radius = "Circ",	obj = Mine,			desc = "Circle",	},
		{chance = 5,	count = 0,	max = math.random(3,9),		radius = "Rect",	obj = Mine,			desc = "Rectangle",	},
		{chance = 5,	count = 0,	max = math.random(2,7),		radius = "Field",	obj = Asteroid,		desc = "Field",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Asteroid,		desc = "Blob",		},
		{chance = 6,	count = 0,	max = math.random(3,9),		radius = "Blob",	obj = Mine,			desc = "Blob",		},
		{chance = 4,	count = 0,	max = 10,					radius = "Trans",	obj = CpuShip,		desc = "Transport",	},
		{chance = 4,	count = 0,	max = -1,					radius = "Tiny",	obj = SupplyDrop,						},
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
					placement_result = placeTerrain("Peripheral Torus",terrain_object)
				else
					placement_result = placeTerrain("Peripheral Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				end
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
				break
			elseif i == #terrain then
				placement_result = placeTerrain("Peripheral Torus",{obj = Asteroid, desc = "Lone", radius = "Tiny"})
				if placement_result then
					terrain_object.count = terrain_object.count + 1
				end
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 120)
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
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 1: cx, cy, ix, iy in find clear spot, circle",cx,cy,ix,iy)
					end
					if distance(cx,cy,ix,iy) < (comparison_dist + new_buffer) then
						far_enough = false
						break
					end
				end
				if item.shape == "zone" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
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
			local random_radius = 0
			for i,dist in ipairs(area_distance_2) do
				random_radius = random_radius + random(dist.lo,dist.hi)
			end
			cx, cy = vectorFromAngle(random(0,360),random_radius,true)
			cx = cx + area_point_x
			cy = cy + area_point_y
			far_enough = true
			for i,item in ipairs(objects) do
				assert(item.shape ~= nil,string.format("function findClearSpot expects an object list table where each item in the table is identified by shape, but item index %s's shape was nil",i))
				assert(valid_table_item_shapes[item.shape] == nil,string.format("function findClearSpot expects a valid shape in the object list table item index %i, but got %s instead",i,item.shape))
				if item.shape == "circle" then
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 2: cx, cy, ix, iy in find clear spot, bell torus:",cx,cy,ix,iy)
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
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 3: cx, cy, ix, iy: find clear spot, torus:",cx,cy,ix,iy)
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
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 4: cx,cy,ix,iy: find clear spot, central rectangle:",cx,cy,ix,iy)
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
					assert(type(item.obj)=="table",string.format("function findClearSpot expects a space object or table as the object in the object list table item index %i, but got a %s instead",i,type(item.obj)))
					local ix, iy = item.obj:getPosition()
					assert(type(item.dist)=="number",string.format("function findClearSpot expects a distance number as the dist value in the object list table item index %i, but got a %s instead",i,type(item.dist)))
					local comparison_dist = item.dist
					if placing_station ~= nil then
						if placing_station then
							if isObjectType(item.obj,"SpaceStation") then
								comparison_dist = 12000
							end
						end
					end
					if distance_diagnostic then
						print("distance_diagnostic 5: cx, cy, ix, iy: find clear spot, rectangle:",cx,cy,ix,iy)
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
		if placement_area == "Inner Torus" or placement_area == "Outer Torus" or placement_area == "Peripheral Torus" then
			eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,asteroid_size)
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
	if placement_area == "Inner Torus" or placement_area == "Outer Torus" or placement_area == "Peripheral Torus" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	end
	if eo_x ~= nil then
		if terrain.obj == WormHole then
			local we_x, we_y = nil
			local count_repeat_loop = 0
			repeat
				if placement_area == "Outer Torus" or placement_area == "Peripheral Torus" then
					we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,500)
				end
				count_repeat_loop = count_repeat_loop + 1
				if distance_diagnostic then
					print("distance_diagnostic 6: eo_x, eo_y, we_x, we_y: place terrain, wormhole",eo_x,eo_y,we_x,we_y)
				end
			until((we_x ~= nil and distance(eo_x, eo_y, we_x, we_y) > 50000) or count_repeat_loop > max_repeat_loop)
			if count_repeat_loop > max_repeat_loop then
				print("repeated too many times while placing a wormhole")
				print("eo_x:",eo_x,"eo_y:",eo_y,"we_x:",we_x,"we_y:",we_y)
			end
			if we_x ~= nil then
				local wh = WormHole():setPosition(eo_x, eo_y):setTargetPosition(we_x, we_y)
				wh:onTeleportation(function(self,transportee)
					string.format("")
					if transportee ~= nil then
						if transportee:isValid() then
							if isObjectType(transportee,"PlayerSpaceship") then
								transportee:setEnergy(transportee:getMaxEnergy()/2)	--reduces if more than half, increases if less than half
							end
						end
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
				local neb = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
				neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
				neb:setScanningParameters(2,1)
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
									if distance_diagnostic then
										print("distance_diagnostic 7: compare_obj_x, compare_obj_y, new_obj_x, new_obj_y: place terrain, blob:",compare_obj_x,compare_obj_y,new_obj_x,new_obj_y)
									end
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
						if distance_diagnostic then
							print("distance_diagnostic 8: eo_x, eo_y, new_obj_x, new_obj_y: place terrain, blob:",eo_x, eo_y, new_obj_x, new_obj_y)
						end
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
						if distance_diagnostic then
							print("distance_diagnostic 9: new_obj_x,new_obj_y,eo_x,eo_y: place terrain, rectangle:",new_obj_x,new_obj_y,eo_x,eo_y)
						end
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
							if distance_diagnostic then
								print("distance_diagnostic 10: new_obj_x,new_obj_y,eo_x,eo_y: place terrain, rectangle:",new_obj_x,new_obj_y,eo_x,eo_y)
							end
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
								if distance_diagnostic then
									print("distance_diagnostic 11: new_obj_x,new_obj_y,eo_x,eo_y: place terrain, rectangle:",new_obj_x,new_obj_y,eo_x,eo_y)
								end
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
					local star_item = tableRemoveRandom(star_list[1].info)
					object:setCallSign(star_item.name)
					if star_item.unscanned ~= nil then
						object:setDescriptions(star_item.unscanned,star_item.scanned)
						object:setScanningParameters(1,2)
					end
					object:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
					dist = radius + 1000
				elseif terrain.obj == SupplyDrop then
					local supply_types = {"energy", "ordnance", "coolant", "repair crew", "probes", "hull", "jump charge"}
					local supply_type = tableSelectRandom(supply_types)
					object:setScanningParameters(math.random(1,2),math.random(1,2)):setFaction(player_faction)
					if supply_type == "energy" then
						local energy_boost = random(300,800)
						object:setEnergy(energy_boost)
						object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i energy boost supply drop."),math.floor(energy_boost)))
					elseif supply_type == "ordnance" then
						local ordnance_types = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
						local restock_ranges = {
							["Homing"] =	{lo = 4, hi = 12},
							["Nuke"] = 		{lo = 1, hi = 5},
							["Mine"] =		{lo = 3, hi = 8},
							["EMP"] =		{lo = 2, hi = 8},
							["HVLI"] =		{lo = 8, hi = 20},
						}
						local ordnance_type = tableSelectRandom(ordnance_types)
						local restock_amount = math.random(restock_ranges[ordnance_type].lo,restock_ranges[ordnance_type].hi)
						object:setWeaponStorage(ordnance_type,restock_amount)
						object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i %s supply drop."),restock_amount,ordnance_type))
					else
						object:onPickUp(supplyPickupProcess)
						if supply_type == "coolant" then
							object.coolant = random(1,5)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1f%% coolant supply drop."),object.coolant*10))
						elseif supply_type == "repair crew" then
							object.repairCrew = 1
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),_("scienceDescription-supplyDrop","Robotic repair crew supply drop."))
						elseif supply_type == "probes" then
							object.probes = math.random(4,12)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%i probes supply drop."),object.probes))
						elseif supply_type == "hull" then
							object.armor = random(20,80)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1f hull repair points supply drop."),object.armor))
						elseif supply_type == "jump charge" then
							object.jump_charge = random(20000,40000)
							object:setDescriptions(_("scienceDescription-supplyDrop","Supply Drop"),string.format(_("scienceDescription-supplyDrop","%.1fK jump drive charge supply drop."),object.jump_charge/1000))
						end
					end
				elseif terrain.obj == ScanProbe then
					local station_pool = getStationPool(placement_area)
					local owner = tableSelectRandom(station_pool)
					local s_x, s_y = owner:getPosition()
					object:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y):setPosition(s_x,s_y)
					object:onExpiration(probeExpired)
					object:onDestruction(probeDestroyed)
					object = VisualAsteroid():setPosition(eo_x,eo_y)
				elseif terrain.obj == WarpJammer then
					local closest_station_distance = 999999
					local closest_station = nil
					local station_pool = getStationPool(placement_area)
					for i, station in ipairs(station_pool) do
						if distance_diagnostic then
							print("distance_diagnostic 12: station, eo_x, eo_y, place terrain, warp jammer:",station:getCallSign(), eo_x, eo_y)
						end
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
					local wj_id = string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count)
					object.identifier = wj_id
					object.range = warp_jammer_range
					object:setDescriptions(_("scienceDescription-warpJammer","Warp jammer"),string.format(_("scienceDescription-warpJammer","Warp jammer. Operated by %s. Placed by station %s. Identifier: %s"),selected_faction,closest_station:getCallSign(),wj_id))
					object:setScanningParameters(1,1)
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
						local neb = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
						neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
						neb:setScanningParameters(2,1)
						if random(1,100) < 37 then
							local n2_angle = (n_angle + random(120,240)) % 360
							n_x, n_y = vectorFromAngle(n2_angle,random(5000,10000))
							eo_x = eo_x + n_x
							eo_y = eo_y + n_y
							neb = Nebula():setPosition(eo_x, eo_y)
							neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
							neb:setScanningParameters(2,1)
							if random(1,100) < 22 then
								local n3_angle = (n2_angle + random(120,240)) % 360
								n_x, n_y = vectorFromAngle(n3_angle,random(5000,10000))
								neb = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
								neb:setDescriptions(_("scienceDescription-nebula","Nebula"),_("scienceDescription-nebula","Nebula"))
								neb:setScanningParameters(2,1)
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
function supplyPickupProcess(self, player)
	if self.repairCrew ~= nil then
		player:setRepairCrewCount(player:getRepairCrewCount() + self.repairCrew)
	end
	if self.coolant ~= nil then
		player:setMaxCoolant(player:getMaxCoolant() + self.coolant)
	end
	if self.probes ~= nil then
		player:setScanProbeCount(math.min(player:getScanProbeCount() + self.probes,player:getMaxScanProbeCount()))
	end
	if self.armor ~= nil then
		player:setHull(math.min(player:getHull() + self.armor,player:getHullMax()))
	end
	if player:hasJumpDrive() then
		if self.jump_charge ~= nil then
			player:setJumpDriveCharge(player:getJumpDriveCharge() + self.jump_charge)
		end
	end
end
--	Dynamic terrain probes
function probeExpired(self)
	if probe_respawn == nil then
		probe_respawn = {}
	end
	local station_owner = self:getOwner()
	local target_x, target_y = self:getTarget()
	table.insert(probe_respawn,{time=getScenarioTime() + random(60,240),owner=station_owner,x=target_x,y=target_y})
end
function probeDestroyed(self,instigator)
	if probe_respawn == nil then
		probe_respawn = {}
	end
	local station_owner = self:getOwner()
	local target_x, target_y = self:getTarget()
	table.insert(probe_respawn,{time=getScenarioTime() + random(60,240),owner=station_owner,x=target_x,y=target_y,instigator=instigator})
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
			p:setEnergyLevel(p:getEnergyLevel() - power_decrement)
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
			if distance_diagnostic then
				print("distance_diagnostic 13: p, sensor_jammer: update player long range sensors, sensor jammer:",p:getCallSign(),jammer_name)
			end
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
				if distance_diagnostic then
					local bp_x, bp_y = boost_probe:getPosition()
					print("distance_diagnostic 14: boost_probe, p: update player long range sensors, boost probe:",bp_x, bp_y,p:getCallSign())
				end
				local boost_probe_distance = distance(boost_probe,p)
				if boost_probe_distance < boost_probe.range*1000 then
					if boost_probe_distance < boost_probe.range*1000/2 then
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,boost_probe.boost*1000)
					else
						local best_boost = boost_probe.boost*1000
						local adjusted_range = boost_probe.range*1000
						local half_adjusted_range = adjusted_range/2
						local raw_scan_gradient = boost_probe_distance/half_adjusted_range
						local scan_gradient = 2 - raw_scan_gradient
						probe_scan_boost_impact = math.max(probe_scan_boost_impact,best_boost * scan_gradient)
					end
				end
			else
				boost_probe_list[boost_probe_index] = boost_probe_list[#boost_probe_list]
				boost_probe_list[#boost_probe_list] = nil
				break
			end
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range + probe_scan_boost_impact)
	p:setLongRangeRadarRange(impact_range)
end
--	Communication
function commsSensorObservatory()
    if comms_source:isEnemy(comms_target) then
        return false
    end
    setCommsMessage(string.format(_("observatory-comms","%s is operational.\nRange: %su"),comms_target:getCallSign(),math.floor(comms_target:getShortRangeRadarRange()/1000)))
end
function scenarioMissionsUndocked()
	local accessible_warp_jammers = {}
	if comms_target.warp_jammer_list ~= nil then
		for index, wj in ipairs (comms_target.warp_jammer_list) do
			if wj ~= nil and wj:isValid() then
				table.insert(accessible_warp_jammers,wj)
			end
		end
	end
	for i, wj in ipairs(warp_jammer_list) do
		if wj ~= nil and wj:isValid() then
			local already_accessible = false
			for j, awj in ipairs(accessible_warp_jammers) do
				if awj == wj then
					already_accessible = true
				end
			end
			if not already_accessible then
				if distance_diagnostic then
					print("distance_diagnostic 15: comms_target,wj: scenario missions undocked, warp jammer:",comms_target:getCallSign(),wj:getCallSign())
				end
				if distance(comms_target,wj) < 30000 then
					if wj:isFriendly(comms_source) or wj:isFriendly(comms_target) then
						table.insert(accessible_warp_jammers,wj)
					elseif not wj:isEnemy(comms_source) or not wj:isEnemy(comms_target) then
						table.insert(accessible_warp_jammers,wj)
					end
				end
			end
		end
	end
	if #accessible_warp_jammers > 0 then
		addCommsReply(_("station-comms","Connect to warp jammer"),function()
			setCommsMessage(_("station-comms","Which one would you like to connect to?"))
			local pay_rep = false
			for index, wj in ipairs(accessible_warp_jammers) do
				local wj_rep = 0
				if wj:isFriendly(comms_target) then
					if wj:isFriendly(comms_source) then
						wj_rep = 0
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 10
							pay_rep = true
						else
							wj_rep = 5
							pay_rep = true
						end
					end
				elseif wj:isEnemy(comms_target) then
					if wj:isFriendly(comms_source) then
						wj_rep = 15
						pay_rep = true
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 100
							pay_rep = true
						else
							wj_rep = 20
							pay_rep = true
						end
					end
				else
					if wj:isFriendly(comms_source) then
						wj_rep = 10
						pay_rep = true
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 25
							pay_rep = true
						else
							wj_rep = 20
							pay_rep = true
						end
					end
				end
				local reputation_prompt = ""
				if wj_rep > 0 then
					reputation_prompt = string.format(_("station-comms","(%i reputation)"),wj_rep)
				end
				addCommsReply(string.format("%s %s",wj.identifier,reputation_prompt),function()
					if comms_source:takeReputationPoints(wj_rep) then
						setCommsMessage(string.format(_("station-comms","%s Automated warp jammer access menu"),wj:getCallSign()))
						addCommsReply(_("station-comms","Reduce range to 1 unit for 1 minute"),function()
							wj:setRange(1000)
							wj.reset_time = getScenarioTime() + 60
							setCommsMessage(_("station-comms","Acknowledged. Range adjusted. Reset timer engaged."))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("station-comms","Reduce range by 50% for 2 minutes"),function()
							wj:setRange(wj.range/2)
							wj.reset_time = getScenarioTime() + 120
							setCommsMessage(_("station-comms","Acknowledged. Range adjusted. Reset timer engaged."))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("station-comms","Reduce range by 25% for 3 minutes"),function()
							wj:setRange(wj.range*.75)
							wj.reset_time = getScenarioTime() + 180
							setCommsMessage(_("station-comms","Acknowledged. Range adjusted. Reset timer engaged."))
							addCommsReply(_("Back"), commsStation)
						end)
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
				end)
			end
			if pay_rep then
				addCommsReply(_("station-comms", "Why do I have to pay reputation to log in to some of these warp jammers?"),function()
					setCommsMessage(string.format(_("station-comms", "It's complicated. It depends on the relationships between the warp jammer owner, us, station %s and you, %s. The farther apart the relationship, the more reputation it costs to gain access. Do you want more details?"),comms_target:getCallSign(),comms_source:getCallSign()))
					addCommsReply(_("station-comms", "Yes, please provide more details"),function()
						local out = _("station-comms","These are the cases and their reputation costs:")
						out = string.format(_("station-comms","%s\n    WJ friendly to %s and WJ is friendly to %s = no reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ friendly to %s and WJ is neutral to %s = 5 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ friendly to %s and WJ is enemy to %s = 10 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ neutral to %s and WJ is friendly to %s = 10 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ enemy to %s and WJ is friendly to %s = 15 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ neutral to %s and WJ is neutral to %s = 20 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ enemy to %s and WJ is neutral to %s = 20 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ neutral to %s and WJ is enemy to %s = 25 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ enemy to %s and WJ is enemy to %s = 100 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						setCommsMessage(out)
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function scenarioMissions()
	local presented = 0
	return presented
end
function addProbeCycleButton(p,console,string_id)
	p:addCustomButton(console,string_id,string.format(_("probeTypes-buttonRelay","Probes: %s"),p.probe_type),function()
		string.format("")
		cycleProbeType(p,nil)
	end,10)
end
function scenarioShipEnhancements()
	if comms_target.improve_long_range_sensors == nil then
		if random(1,100) < 26 then
			comms_target.improve_long_range_sensors = {
				[comms_source] = false
			}
		else
			comms_target.improve_long_range_sensors = "unavailable"
		end
	end
	if comms_target.improve_long_range_sensors ~= "unavailable" then
		if comms_target.improve_long_range_sensors[comms_source] == nil then
			comms_target.improve_long_range_sensors[comms_source] = false
		end
		if not comms_target.improve_long_range_sensors[comms_source] then
			if comms_source.improve_long_range_sensors_count == nil then
				comms_source.improve_long_range_sensors_count = 0
			end
			addCommsReply(string.format(_("upgrade-comms","Increase long range sensors by 5 units (%i rep)"),comms_source.improve_long_range_sensors_count * 10 + 10),function()
				if comms_source:takeReputationPoints(comms_source.improve_long_range_sensors_count * 10 + 10) then
					comms_source.improve_long_range_sensors_count = comms_source.improve_long_range_sensors_count + 1
					comms_source.normal_long_range_radar = comms_source.normal_long_range_radar + 5000
					comms_target.improve_long_range_sensors[comms_source] = true
					setCommsMessage(_("upgrade-comms","Sensor range improved by five units"))
				else
					setCommsMessage(_("needRep-comms","Insufficient reputation"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if comms_target == proboscis_station then
		local probe_shop_prompts = {
			_("probeShop-comms","Visit the specialty probe shop"),
			_("probeShop-comms","Visit the Proboscis Probe Shop"),
			_("probeShop-comms","Get some specialty probes"),
			_("probeShop-comms","Check out the Proboscis Probe Shop"),
		}
		addCommsReply(tableSelectRandom(probe_shop_prompts),function()
			local probe_shop_greetings = {
				_("probeShop-comms","Welcome to the Proboscis Probe Shop. I'm Calon Proboscis, owner and proprietor. How can I help you?"),
				_("probeShop-comms","Hi there, I'm Calon Proboscis, owner and proprietor of the Proboscis Probe Shop. How can I help you?"),
				_("probeShop-comms","A man comes over with a big smile and says, 'Welcome to my store, the Proboscis Probe Shop. I'm Calon Proboscis. How may I help you?'"),
				_("probeShop-comms","A guy with a name tag that says 'Calon Proboscis' greets you and says, 'We have got all kinds of scan probe enhancements here in my Proboscis Probe Shop. What are you looking for?'"),
			}
			setCommsMessage(tableSelectRandom(probe_shop_greetings))
			addCommsReply(_("probeShop-comms","Patrol probes"),function()
				local out = _("probeShop-comms","Attach these kits to your probe to make them orbit your ship in a hexagon pattern until they run out of energy. They come in batches of 5.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "patrol" then
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, cost %i"),out,name,probe.speed/1000,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "patrol" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:takeReputationPoints(probe.cost) then
								local matching_index = 0
								for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
									if probe_type_item.name == name then
										matching_index = probe_type_index
										break
									end
								end
								if matching_index == 0 then
									table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed, patrol = probe.patrol})
									matching_index = #comms_source.probe_type_list
								end
								comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
								setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
								if comms_source.probe_type == nil then
									comms_source.probe_type = "standard"
								end
								if comms_source.probe_type_button_rel == nil then
									comms_source.probe_type_button_rel = "probe_type_button_rel"
									addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
								end
								if comms_source.probe_type_button_alt == nil then
									comms_source.probe_type_button_alt = "probe_type_button_alt"
									addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
								end
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("probeShop-comms","Faster probes"),function()
				local out = _("probeShop-comms","Attach these kits to your probe to make them travel faster to their destination. They typical probe travels at warp 1. They come in batches of 5.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "fast" then
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, cost %i"),out,name,probe.speed/1000,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "fast" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:takeReputationPoints(probe.cost) then
								local matching_index = 0
								for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
									if probe_type_item.name == name then
										matching_index = probe_type_index
										break
									end
								end
								if matching_index == 0 then
									table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed})
									matching_index = #comms_source.probe_type_list
								end
								comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
								setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
								if comms_source.probe_type == nil then
									comms_source.probe_type = "standard"
								end
								if comms_source.probe_type_button_rel == nil then
									comms_source.probe_type_button_rel = "probe_type_button_rel"
									addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
								end
								if comms_source.probe_type_button_alt == nil then
									comms_source.probe_type_button_alt = "probe_type_button_alt"
									addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
								end
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("probeShop-comms","Warp Jammer probes"),function()
				local out = _("probeShop-comms","Attach these kits to your probe and when they reach their destination, they will drop a warp jammer. They come in batches of 5.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "warpjam" then
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, warp jam range: %iu, cost: %i"),out,name,probe.speed/1000,probe.range,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "warpjam" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:takeReputationPoints(probe.cost) then
								local matching_index = 0
								for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
									if probe_type_item.name == name then
										matching_index = probe_type_index
										break
									end
								end
								if matching_index == 0 then
									table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed, range = probe.range})
									matching_index = #comms_source.probe_type_list
								end
								comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
								setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
								if comms_source.probe_type == nil then
									comms_source.probe_type = "standard"
								end
								if comms_source.probe_type_button_rel == nil then
									comms_source.probe_type_button_rel = "probe_type_button_rel"
									addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
								end
								if comms_source.probe_type_button_alt == nil then
									comms_source.probe_type_button_alt = "probe_type_button_alt"
									addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
								end
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("probeShop-comms","Sensor range boosting probes"),function()
				local out = _("probeShop-comms","Attach these kits to your probe and the probe will boost your long range sensor range. They come in batches of 5.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "sensorboost" then
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, sensor boost: range: %iu, power: %iu cost: %i"),out,name,probe.speed/1000,probe.range,probe.boost,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "sensorboost" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:takeReputationPoints(probe.cost) then
								local matching_index = 0
								for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
									if probe_type_item.name == name then
										matching_index = probe_type_index
										break
									end
								end
								if matching_index == 0 then
									table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed, range = probe.range, boost = probe.boost})
									matching_index = #comms_source.probe_type_list
								end
								comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
								setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
								if comms_source.probe_type == nil then
									comms_source.probe_type = "standard"
								end
								if comms_source.probe_type_button_rel == nil then
									comms_source.probe_type_button_rel = "probe_type_button_rel"
									addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
								end
								if comms_source.probe_type_button_alt == nil then
									comms_source.probe_type_button_alt = "probe_type_button_alt"
									addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
								end
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("probeShop-comms","Observatory deployment probes"),function()
				local out = _("probeShop-comms","This kit causes the probe to deploy a friendly self powered observatory at its destination. The kit comes in batches of 3.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "observatory" then
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, range %iu, hull/shield: %i/%i, cost: %i"),out,name,probe.speed/1000,probe.range,probe.hull,probe.shield,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "observatory" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:takeReputationPoints(probe.cost) then
								local matching_index = 0
								for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
									if probe_type_item.name == name then
										matching_index = probe_type_index
										break
									end
								end
								if matching_index == 0 then
									table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed, range = probe.range, shield = probe.shield, hull = probe.hull})
									matching_index = #comms_source.probe_type_list
								end
								comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
								setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
								if comms_source.probe_type == nil then
									comms_source.probe_type = "standard"
								end
								if comms_source.probe_type_button_rel == nil then
									comms_source.probe_type_button_rel = "probe_type_button_rel"
									addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
								end
								if comms_source.probe_type_button_alt == nil then
									comms_source.probe_type_button_alt = "probe_type_button_alt"
									addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
								end
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("probeShop-comms","Automated ship scanning probes"),function()
				local out = _("probeShop-comms","Attach these kits to your probe and the probe will automatically scan ships in range. They come in batches of 3.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "scan" then
						local scan_type = _("probeShop-comms","simple scan")
						if probe.full then
							scan_type = _("probeShop-comms","full scan")
						end
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, range %iu, %s, cost: %i"),out,name,probe.speed/1000,probe.range,scan_type,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "scan" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:takeReputationPoints(probe.cost) then
								local matching_index = 0
								for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
									if probe_type_item.name == name then
										matching_index = probe_type_index
										break
									end
								end
								if matching_index == 0 then
									table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed, range = probe.range, full = probe.full})
									matching_index = #comms_source.probe_type_list
								end
								comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
								setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
								if comms_source.probe_type == nil then
									comms_source.probe_type = "standard"
								end
								if comms_source.probe_type_button_rel == nil then
									comms_source.probe_type_button_rel = "probe_type_button_rel"
									addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
								end
								if comms_source.probe_type_button_alt == nil then
									comms_source.probe_type_button_alt = "probe_type_button_alt"
									addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
								end
							else
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("probeShop-comms","Mine deployment probes"),function()
				local out = _("probeShop-comms","Attach these probe kits to your probe and when the probe reaches its destination it goes into stealth mode after 5 seconds. Once the birth period has passed, it will deploy one or more mines. These probe kits come in batches of 3.")
				for name,probe in pairs(probe_types) do
					if probe.cat == "mine" then
						out = string.format(_("probeShop-comms","%s\n%s: warp %.1f, birth: %i seconds, mines: %i, cost: %i"),out,name,probe.speed/1000,probe.fetus*5+5,probe.mines,probe.cost)
					end
				end
				setCommsMessage(out)
				for name,probe in pairs(probe_types) do
					if probe.cat == "mine" then
						addCommsReply(string.format(_("probeShop-comms","%s (%i reputation for %i)"),name,probe.cost,probe.quantity),function()
							if comms_source:getWeaponStorageMax("Mine") >= probe.mines then
								if comms_source:takeReputationPoints(probe.cost) then
									local matching_index = 0
									for probe_type_index, probe_type_item in ipairs(comms_source.probe_type_list) do
										if probe_type_item.name == name then
											matching_index = probe_type_index
											break
										end
									end
									if matching_index == 0 then
										table.insert(comms_source.probe_type_list,{name = name, count = 0, cat = probe.cat, speed = probe.speed, fetus = probe.fetus, mines = probe.mines})
										matching_index = #comms_source.probe_type_list
									end
									comms_source.probe_type_list[matching_index].count = comms_source.probe_type_list[matching_index].count + probe.quantity
									setCommsMessage(string.format(_("probeShop-comms","%i %s specialty probe kits added to your inventory."),probe.quantity,name))
									if comms_source.probe_type == nil then
										comms_source.probe_type = "standard"
									end
									if comms_source.probe_type_button_rel == nil then
										comms_source.probe_type_button_rel = "probe_type_button_rel"
										addProbeCycleButton(comms_source,"Relay",comms_source.probe_type_button_rel)
									end
									if comms_source.probe_type_button_alt == nil then
										comms_source.probe_type_button_alt = "probe_type_button_alt"
										addProbeCycleButton(comms_source,"AltRelay",comms_source.probe_type_button_alt)
									end
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation"))
								end
							else
								setCommsMessage(string.format(_("probeShop-comms","Your mine storage capacity of %i is insufficient for this LDSM probe kit which requires %i mines."),comms_source:getWeaponStorageMax("Mine"),probe.quantity))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function scenarioInformation()
	addCommsReply(_("intelligence-comms","Where are the enemy ships?"),function()
		if #wave_enemies > 0 then
			local enemy_report = string.format(_("intelligence-comms","We have reports of enemies on the following bearings from %s:"),comms_target:getCallSign())
			if #wave_enemies == 1 then
				enemy_report = string.format(_("intelligence-comms","We have a report of an enemy on this bearing from %s:"),comms_target:getCallSign())
			end
			for i,ship in ipairs(wave_enemies) do
				local heading = math.floor(angleHeading(comms_target,ship))
				enemy_report = string.format("%s\n%i",enemy_report,heading)
			end
			enemy_report = string.format(_("intelligence-comms","%s\nThis report omits distance information"),enemy_report)
			setCommsMessage(enemy_report)
		else
			setCommsMessage(_("intelligence-comms","We have no reports of enemies at this time."))
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function getCurrentOrders()
	local current_orders_prompts = {
		_("orders-comms","Current orders?"),
		_("orders-comms","What are my current orders?"),
		string.format(_("orders-comms","Current orders for %s?"),comms_source:getCallSign()),
		_("orders-comms","Remind me of our current orders, please"),
	}
	addCommsReply(tableRemoveRandom(current_orders_prompts),function()
		setOptionalOrders()
		ordMsg = primary_orders .. "\n" .. optional_orders
		setCommsMessage(ordMsg)
		addCommsReply(_("Back"), commsStation)
	end)
end
function setOptionalOrders()
	optional_orders = ""
	if comms_source.transport_mission ~= nil or comms_source.cargo_mission ~= nil then
		local optional_orders_header = {
			_("orders-comms","\nOptional:"),
			_("orders-comms","\nOptional orders:"),
			_("orders-comms","\nThese orders are optional:"),
			_("orders-comms","\nNot required:"),
		}
		optional_orders = tableRemoveRandom(optional_orders_header)
	end
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to %s station %s in %s"),optional_orders,comms_source.transport_mission.character.name,comms_source.transport_mission.destination:getFaction(),comms_source.transport_mission.destination_name,comms_source.transport_mission.destination:getSectorName())
		else
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to station %s (defunct)"),optional_orders,comms_source.transport_mission.character.name,comms_source.transport_mission.destination_name)
		end
	end
	if comms_source.cargo_mission ~= nil then
		if comms_source.cargo_mission.loaded then
			if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s in %s"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.destination:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s (defunct)"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.destination_name)
			end
		else
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s in %s"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name,comms_source.cargo_mission.origin:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s (defunct)"),optional_orders,comms_source.cargo_mission.character.name,comms_source.cargo_mission.origin_name)
			end
		end
	end
	if comms_source.restoration_mission ~= nil then
		if comms_source.restoration_mission.achievement then
			if comms_source.restoration_mission.destination ~= nil and comms_source.restoration_mission.destination:isValid() then
				optional_orders = string.format("%s\n%s",optional_orders,comms_source.restoration_mission.optional_orders_second_half)
			else
				optional_orders = string.format(_("orders-comms","%s\n%s (defunct)"),optional_orders,comms_source.restoration_mission.optional_orders_second_half)
			end
		else
			if comms_source.restoration_mission.origin ~= nil and comms_source.restoration_mission.origin:isValid() then
				optional_orders = string.format("%s\n%s",optional_orders,comms_source.restoration_mission.optional_orders_first_half)
			else
				optional_orders = string.format(_("orders-comms","%s\n%s (defunct)"),optional_orders,comms_source.restoration_mission.optional_orders_first_half)
			end
		end
	end
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
		enemy_strength = math.max(relative_strength * playerPower() * enemy_power,5)
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
		if ship_template[selected_template].create == nil then
			print("Template",selected_template,"does not have a create routine in ship_template")
		end
		local ship = ship_template[selected_template].create(fleetSpawnFaction,selected_template)
		ship:setCallSign(generateCallSign(nil,fleetSpawnFaction))
		ship:orderRoaming()
		enemy_position = enemy_position + 1
		ship:setPosition(x + formation_delta[shape].x[enemy_position] * sp, y + formation_delta[shape].y[enemy_position] * sp)
		table.insert(enemyList, ship)
		enemy_strength = enemy_strength - ship_template[selected_template].strength
	end
	return enemyList
end
function playerPower()
	local playerShipScore = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore ~= nil then
			playerShipScore = playerShipScore + p.shipScore
		else
			playerShipScore = playerShipScore + 24
		end
	end
	return playerShipScore
end
--	Maintenance
function respawnProbe()
	if probe_respawn ~= nil then
		if #probe_respawn > 0 then
			for i,info in ipairs(probe_respawn) do
				if getScenarioTime() > info.time then
					if info.instigator ~= nil and info.instigator:isValid() then
						if info.owner ~= nil and info.owner:isValid() then
							local s_x, s_y = info.owner:getPosition()
							local t_x, t_y = info.instigator:getPosition()
							local probe = ScanProbe():setLifetime(random(10,30)*60):setOwner(info.owner):setTarget(t_x,t_y):setPosition(s_x,s_y)
							probe:onExpiration(probeExpired)
							probe:onDestruction(probeDestroyed)
						end
					else
						if info.owner ~= nil and info.owner:isValid() then
							local s_x, s_y = info.owner:getPosition()
							local probe = ScanProbe():setLifetime(random(10,30)*60):setOwner(info.owner):setTarget(info.x,info.y):setPosition(s_x,s_y)
							probe:onExpiration(probeExpired)
							probe:onDestruction(probeDestroyed)
						end
					end
					probe_respawn[i] = probe_respawn[#probe_respawn]
					probe_respawn[#probe_respawn] = nil
					break
				end
			end
		end
	end
	maintenancePlot = warpJammerMaintenance
end
function warpJammerMaintenance()
	if #warp_jammer_list > 0 then
		for wj_index, wj in ipairs(warp_jammer_list) do
			if wj ~= nil and wj:isValid() then
				if wj.reset_time ~= nil then
					if getScenarioTime() > wj.reset_time then
						wj:setRange(wj.range)
						wj.reset_time = nil
					end
				end
			else
				warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
				warp_jammer_list[#warp_jammer_list] = nil
				break
			end
		end
	end
	maintenancePlot = transportCommerceMaintenance
end
function transportCommerceMaintenance()
	if cleanList(transport_list) then
		for i,transport in ipairs(transport_list) do
			local temp_faction = transport:getFaction()
			local transport_target = nil
			local docked_with = transport:getDockedWith()
			if docked_with ~= nil then
				if transport.undock_timer == nil then
					transport.undock_timer = getScenarioTime() + random(10,25)
				elseif getScenarioTime() > transport.undock_timer then
					transport.undock_timer = nil
					transport_target = pickTransportTarget(transport)
					if transport_target ~= nil then
						transport:setFaction("Independent")
						transport:orderDock(transport_target)
						transport:setFaction(temp_faction)
					end
				end
			else
				if string.find("Dock",transport:getOrder()) then
					transport_target = transport:getOrderTarget()
					if transport_target == nil or not transport_target:isValid() then
						transport_target = pickTransportTarget(transport)
						if transport_target ~= nil then
							transport:setFaction("Independent")
							transport:orderDock(transport_target)
							transport:setFaction(temp_faction)
						end
					end
				else
					transport_target = pickTransportTarget(transport)
					if transport_target ~= nil then
						transport:setFaction("Independent")
						transport:orderDock(transport_target)
						transport:setFaction(temp_faction)
					end
				end
			end
		end
		if transport_population_time == nil then
			transport_population_time = getScenarioTime() + random(60,300)
		else
			if getScenarioTime() > transport_population_time then
				if cleanList(stations) then
					transport_population_time = nil
					if #stations > #transport_list then
						local ship, ship_size = randomTransportType()
						local faction_list = {}
						for i,station in ipairs(stations) do
							local station_faction = station:getFaction()
							local already_recorded = false
							for j,faction in ipairs(faction_list) do
								if faction == station_faction then
									already_recorded = true
									break
								end
							end
							if not already_recorded then
								table.insert(faction_list,station_faction)
							end
						end
						ship:setFaction(tableSelectRandom(faction_list))
						local t_x, t_y = vectorFromAngle(random(0,360),120000)
						ship:setPosition(t_x + center_x, t_y + center_y)
						ship:setCallSign(generateCallSign(nil,ship:getFaction()))
						table.insert(transport_list,ship)
					end
				end
			end
		end
	end
	maintenancePlot = respawnProbe
end
function pickTransportTarget(transport)
	local transport_target = nil
	if cleanList(stations) then
		local station_pool = {}
		for i,station in ipairs(stations) do
			if not station:isEnemy(transport) then
				table.insert(station_pool,station)
			end
		end
		transport_target = tableSelectRandom(station_pool)
	end
	return transport_target
end
function updateAsteroidOrbits(delta)
	if cleanList(orbiting_asteroids) then
		for i,ast in ipairs(orbiting_asteroids) do
			local angle = (ast.angle + delta/ast.orbit_speed) % 360
			local ax, ay = vectorFromAngle(angle,ast.dist,true)
			ax = ax + center_x
			ay = ay + center_y
			ast:setPosition(ax, ay)
			ast.angle = angle
		end
	end
end
--	Probe maintenance
function cycleProbeType(p,probe_type)
	if probe_diagnostic then
		print("Top of cycle probe type")
	end
	if p.probe_type ~= nil then
		if probe_diagnostic then
			print("p dot probe_type is not nil:",p.probe_type)
		end
		local type_cycled = false
		if probe_type ~= nil then
			if probe_diagnostic then
				print("probe_type passed in is not nil:",probe_type)
			end
			if p.probe_type ~= probe_type then
				if probe_diagnostic then
					print("p dot probe_type is not equal probe_type passed in")
				end
				type_cycled = true
				p.probe_type = probe_type
			end
		else
			if probe_diagnostic then
				print("probe_type passed in is nil")
			end
			if p.probe_type_list == nil then
				if probe_diagnostic then
					print("p dot probe_type_list is nil. Initializing")
				end
				p.probe_type_list = {}
				table.insert(p.probe_type_list,{name = "standard", count = -1})
			end
			local matching_index = 0
			for probe_type_index, probe_type_item in ipairs(p.probe_type_list) do
				if probe_diagnostic then
					print("Looping through p dot probe_type_list. Index:",probe_type_index,"Name:",probe_type_item.name,"Count:",probe_type_item.count)
				end
				if probe_type_item.name == p.probe_type then
					if probe_diagnostic then
						print("Name matches p dot probe_type")
					end
					matching_index = probe_type_index
					break
				end
			end
			if matching_index > 0 then
				if probe_diagnostic then
					print("process matching item")
				end
				matching_index = matching_index + 1
				if matching_index > #p.probe_type_list then
					matching_index = 1
				end
				if probe_diagnostic then
					print("next matching index:",matching_index)
				end
				if p.probe_type ~= p.probe_type_list[matching_index].name then
					if probe_diagnostic then
						print("Next matching index item name does not match current p dot probe_type:",p.probe_type_list[matching_index].name,"Cycling")
					end
					p.probe_type = p.probe_type_list[matching_index].name
					type_cycled = true
				end
				if p.probe_type_list[matching_index].count == 0 then
					if probe_diagnostic then
						print("New probe type has zero count. Removing")
					end
					p.probe_type_list[mathing_index] = p.probe_type_list[#p.probe_type_list]
					p.probe_type_list[#p.probe_type_list] = nil
					if p.probe_type ~= "standard" then
						if probe_diagnostic then
							print("Cycle to standard")
						end
						p.probe_type = "standard"
						type_cycled = true
					end
				end
			else
				if probe_diagnostic then
					print("no matching item")
				end
				if p.probe_type ~= "standard" then
					if probe_diagnostic then
						print("If not standard, cycle to standard")
					end
					p.probe_type = "standard"
					type_cycled = true
				end
			end
		end
		if type_cycled then
			if probe_diagnostic then
				print("cycle occurred, remove button")
			end
			if p.probe_type_button_rel ~= nil then
				p:removeCustom(p.probe_type_button_rel)
				p.probe_type_button_rel = nil
			end
			if p.probe_type_button_alt ~= nil then
				p:removeCustom(p.probe_type_button_alt)
				p.probe_type_button_alt = nil
			end
		end
		refreshSpecialProbeButton(p)
	end
end	
function refreshSpecialProbeButton(p)
	if probe_diagnostic then
		print("Top of refresh special probe button")
	end
	if p.probe_type_list ~= nil and #p.probe_type_list > 1 then
		if probe_diagnostic then
			print("probe list present and greater than 1")
		end
		local non_standard_probes = 0
		for probe_type_index, probe_type_item in ipairs(p.probe_type_list) do
			if probe_type_item.name ~= "standard" then
				if probe_diagnostic then
					print("non-standard probe in list:",probe_type_item.name)
				end
				non_standard_probes = non_standard_probes + probe_type_item.count
			end
		end
		if non_standard_probes > 0 then
			local button_label = string.format(_("probeTypes-buttonRelay","Probes: %s"),p.probe_type)
			if p.probe_type ~= "standard" then
				local probe_quantity = 0
				for probe_type_index, probe_type_item in ipairs(p.probe_type_list) do
					if probe_type_item.name == p.probe_type then
						if probe_diagnostic then
							print("current name in probe list loop matches p dot probe type")
						end
						if probe_type_item.count ~= nil then
							if probe_diagnostic then
								print("set probe type quantity to the minimum between current probes in stock and the specialty probe count")
							end
							probe_quantity = math.min(probe_type_item.count,p:getScanProbeCount())
						end
					end
				end
				button_label = string.format("%s (%i)",button_label,probe_quantity)
			end
			p.probe_type_button_rel = "probe_type_button_rel"
			addProbeCycleButton(comms_source,"Relay",p.probe_type_button_rel)
			p.probe_type_button_alt = "probe_type_button_alt"
			addProbeCycleButton(comms_source,"AltRelay",p.probe_type_button_alt)
		end
	end
end	
function patrolProbe(self)
	string.format("")
	local p = self:getOwner()
	if p ~= nil and p:isValid() then
		local probe_x, probe_y = self:getPosition()
		local player_x, player_y = p:getPosition()
		local angle = angleHeading(player_x, player_y, probe_x, probe_y)
--		local angle = angleFromVectorNorth(probe_x, probe_y, player_x, player_y)
		local angle = (angle + 60) % 360
		if self.patrol_distance == nil then
			if distance_diagnostic then
				local s_x, s_y = self:getPosition()
				print("distance_diagnostic 18: self, p: patrol probe:",s_x, s_y, p:getCallSign())
			end
			self.patrol_distance = distance(self,p)
		end
		local npp_x, npp_y = vectorFromAngle(angle,self.patrol_distance,true)
--		local npp_x, npp_y = vectorFromAngleNorth(angle,self.patrol_distance)
		local px, py = p:getPosition()
		self:setTarget(px + npp_x, py + npp_y)
	else
		self:onArrival(nil)
	end
end
function probeWarpJammer(self,x,y)
	local selected_faction = self:getFaction()
	local wj = WarpJammer():setPosition(x,y):setRange(self.warp_jam_range):setFaction(selected_faction)
	warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
	local wj_id = string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count)
	wj.identifier = wj_id
	wj.range = self.warp_jam_range
	table.insert(warp_jammer_list,wj)
	self:onArrival(nil)
end
function probeLabor(self,x,y)
	table.insert(mine_labor_probe_list,{
		probe = self,
		x = x,
		y = y,
		mine_fetus = self.mine_fetus,
		stealth = getScenarioTime() + 5,
		birth = getScenarioTime() + 5 + (5*self.mine_fetus),
		hidden = false,
	})
end
function updateProbeLabor()
	for i,mama in ipairs(mine_labor_probe_list) do
		if mama.probe ~= nil and mama.probe:isValid() then
			if getScenarioTime() > mama.stealth then
				mama.probe:destroy()
				mama.hidden = true
			end
		else
			if mama.hidden then
				if getScenarioTime() > mama.birth then
					local angle = random(0,360)
					local mx, my = vectorFromAngle(angle,400,true)
					if mama.mine_fetus == 3 then
						for i=1,5 do
							Mine():setPosition(mama.x + mx, mama.y + my)
							angle = angle + 72
							mx, my = vectorFromAngle(angle,400,true)
						end
					elseif mama.mine_fetus == 2 then
						mx, my = vectorFromAngle(angle,200,true)
						for i=1,3 do
							Mine():setPosition(mama.x + mx, mama.y + my)
							angle = angle + 120
							mx, my = vectorFromAngle(angle,200,true)
						end
					else	--must be 1
						Mine():setPosition(mama.x,mama.y)
					end
					mine_labor_probe_list[i] = mine_labor_probe_list[#mine_labor_probe_list]
					mine_labor_probe_list[#mine_labor_probe_list] = nil
					break
				end
			else
				mine_labor_probe_list[i] = mine_labor_probe_list[#mine_labor_probe_list]
				mine_labor_probe_list[#mine_labor_probe_list] = nil
				break
			end
		end
	end
end
function probeObservatory(self,x,y)
	local ox, oy = vectorFromAngle(random(0,360),500,true)
	ox = ox + x
	oy = oy + y
	local obs = SpaceStation():setPosition(ox,oy):setTemplate("Small Station")
	obs:setShortRangeRadarRange(self.range*1000):setShieldsMax(self.shield)
	obs:setHullMax(self.hull):setRepairDocked(false):setSharesEnergyWithDocked(false)
	obs:setRestocksMissilesDocked(false)
	if named_observatory_number == nil then
		named_observatory_number = 0
	end
	named_observatory_number = named_observatory_number + math.random(1,4)
	obs:setCallSign(string.format("SO%s",named_observatory_number))
	obs:setDescription(string.format(_("scienceDescription-station","Sensor Observatory %s"),named_observatory_number))
	obs:setFaction(self:getFaction())
	obs:setCommsFunction(commsSensorObservatory)
	self:onArrival(nil)
end
function updateProbeShipScan()
	for i,probe in ipairs(scan_ship_probe_list) do
		if probe ~= nil and probe:isValid() then
			local obj_list = probe:getObjectsInRange(probe.range*1000)
			if obj_list ~= nil and #obj_list > 0 then
				for j, obj in ipairs(obj_list) do
					if obj:isValid() then
						if isObjectType(obj,"CpuShip") then
							if probe.full then
								obj:setScanStateByFaction(player_faction,"fullscan")
							else
								if not obj:isFullyScannedBy(probe:getOwner()) then
									obj:setScanStateByFaction(player_faction,"simplescan")
								end
							end
						end
					end
				end
			end
		else
			scan_ship_probe_list[i] = scan_ship_probe_list[#scan_ship_probe_list]
			scan_ship_probe_list[#scan_ship_probe_list] = nil
			break
		end
	end
end
function updatePlayerSpecialtyProbes(p)
	local matching_index = 0
	for probe_type_index, probe_type_item in ipairs(p.probe_type_list) do
		if probe_type_item.name == p.probe_type and probe_type_item.count > 0 then
			matching_index = probe_type_index
			break
		end
	end
	if matching_index > 0 then
		local object_list = p:getObjectsInRange(100)
		if object_list ~= nil then
			for _, obj in ipairs(object_list) do
				if obj ~= p then
					if isObjectType(obj,"ScanProbe") then
						if obj:getOwner() == p then
							if obj.probe_speed == nil then	--speed set indicates probe fully defined
								obj.probe_speed = p.probe_type_list[matching_index].speed
--								print("name:",p.probe_type_list[matching_index].name,
--									"cat:",p.probe_type_list[matching_index].cat,
--									"speed:",p.probe_type_list[matching_index].speed,
--									"cost:",p.probe_type_list[matching_index].cost,
--									"qty:",p.probe_type_list[matching_index].quantity,
--									"range:",p.probe_type_list[matching_index].range,
--									"fetus:",p.probe_type_list[matching_index].fetus,
--									"boost:",p.probe_type_list[matching_index].boost,
--									"hull:",p.probe_type_list[matching_index].hull,
--									"shield:",p.probe_type_list[matching_index].shield,
--									"full:",p.probe_type_list[matching_index].full)
								obj:setSpeed(obj.probe_speed)
								local mines_for_ldsm = false
								if string.find(p.probe_type_list[matching_index].name,"LDSM") then
									if p.probe_type_list[matching_index].mines <= p:getWeaponStorage("Mine") then
										p.probe_type_list[matching_index].count = p.probe_type_list[matching_index].count - 1
										p:setWeaponStorage("Mine",p:getWeaponStorage("Mine") - p.probe_type_list[matching_index].mines)
										mines_for_ldsm = true
									end
								else	--decrement available count for non-ldsm probe types
									p.probe_type_list[matching_index].count = p.probe_type_list[matching_index].count - 1
								end
								if p.probe_type_list[matching_index].cat == "patrol" then
									obj.patrol = true
									obj:onArrival(patrolProbe)
								end
								if p.probe_type_list[matching_index].cat == "warpjam" then
									obj.warp_jam_range = p.probe_type_list[matching_index].range * 1000
									obj:onArrival(probeWarpJammer)
								end
								if p.probe_type_list[matching_index].boost ~= nil then
									obj.boost = p.probe_type_list[matching_index].boost
									obj.range = p.probe_type_list[matching_index].range
									table.insert(boost_probe_list,obj)
								end
								if p.probe_type_list[matching_index].fetus ~= nil then
									if mines_for_ldsm then
										obj.mine_fetus = p.probe_type_list[matching_index].fetus
										obj:onArrival(probeLabor)
									end
								end
								if p.probe_type_list[matching_index].cat == "observatory" then
									obj.range = p.probe_type_list[matching_index].range
									obj.shield = p.probe_type_list[matching_index].shield
									obj.hull = p.probe_type_list[matching_index].hull
									obj:onArrival(probeObservatory)
								end
								if p.probe_type_list[matching_index].cat == "scan" then
									obj.range = p.probe_type_list[matching_index].range
									obj.full = p.probe_type_list[matching_index].full
									table.insert(scan_ship_probe_list,obj)
								end
								cycleProbeType(p,p.probe_type_list[matching_index].name)
							end
						end
					end
				end
			end
		end
	end
end
--	Missions
function spawnWave()
	wave_number = wave_number + 1
	wave_task[wave_number] = task_force_number
	local station_pool = {}
	for i,station in ipairs(enemy_stations) do
		if station ~= nil and station:isValid() then
			table.insert(station_pool,station)
		end
	end
	local selected_station = tableSelectRandom(station_pool)
	local angle = angleHeading(region_planet,selected_station)
	local selected_neb = nil
	for i,neb in ipairs(seige_nebula) do
		if neb.iris_angle >= angle then
			selected_neb = neb
			break
		end
	end
	local spawn_x, spawn_y = selected_neb:getPosition()
	local remaining_defending_stations = 0
	for i,station in ipairs(stations) do
		if station ~= nil and station:isValid() and station.nebula_defense then
			remaining_defending_stations = remaining_defending_stations + 1
		end
	end
	local ratio = remaining_defending_stations/original_defending_stations
	relative_strength = wave_number * ratio
	fleetSpawnFaction = selected_station:getFaction()
	wave_enemies = spawnRandomArmed(spawn_x, spawn_y)
	for i,ship in ipairs(wave_enemies) do
		ship:orderFlyTowards(center_x,center_y)
	end
end
function waveSlog()
	if wave_enemies ~= nil and #wave_enemies > 0 then
		if getScenarioTime() > slog_time then
			slog_interval = slog_interval + random(3,5)*60
			slog_time = getScenarioTime() + slog_interval
			local station_pool = {}
			for i,station in ipairs(enemy_stations) do
				if station ~= nil and station:isValid() then
					table.insert(station_pool,station)
				end
			end
			local selected_station = tableSelectRandom(station_pool)
			local spawn_x, spawn_y = selected_station:getPosition()
			local remaining_defending_stations = 0
			for i,station in ipairs(stations) do
				if station ~= nil and station:isValid() and station.nebula_defense then
					remaining_defending_stations = remaining_defending_stations + 1
				end
			end
			local ratio = remaining_defending_stations/original_defending_stations
			relative_strength = wave_number * ratio
			fleetSpawnFaction = selected_station:getFaction()
			local fleet = spawnRandomArmed(spawn_x, spawn_y)
			for i,ship in ipairs(fleet) do
				table.insert(wave_enemies,ship)
			end
			task_force_number = task_force_number + 1
			wave_task[wave_number] = task_force_number
			local player_message = string.format(_("msgMainscreen","Task force launched by %s station %s in sector %s"),selected_station:getFaction(),selected_station:getCallSign(),selected_station:getSectorName())
			globalMessage(player_message)
			table.insert(messages,{msg=player_message,list={}})
			local messages_index = #messages
			for i,p in ipairs(getActivePlayerShips()) do
				table.insert(messages[messages_index].list,p)
			end
		end
	end
end
function messagePlayers()
	if messages ~= nil and #messages > 0 then
		for i,msg in ipairs(messages) do
			if msg.list ~= nil and #msg.list > 0 then
				for j,p in ipairs(msg.list) do
					if availableForComms(p) then
						for k,station in ipairs(stations) do
							if station ~= nil and station:isValid() and station.nebula_defense then
								station:sendCommsMessage(p,msg.msg)
								break
							end
						end
						msg.list[j] = msg.list[#msg.list]
						msg.list[#msg.list] = nil
						break
					end
				end
			else
				messages[i] = messages[#messages]
				messages[#messages] = nil
			end
		end
	end
end
function showDefenseNetwork(p,console)
	local report = {}
	for i,def in ipairs(defense_network) do
		if def.obj:isValid() then
			table.insert(report,string.format("A %s",def.desc))
		else
			table.insert(report,string.format("X %s",def.desc))
		end
	end
	table.sort(report)
	local out = _("msgRelay","Defense Network Report:                    (A|X) = (Active|Destroyed) Sector Type Faction Name|ID")
	for i,line in ipairs(report) do
		if i % 2 ~= 0 then
			out = string.format("%s\n%s",out,line)
		else
			out = string.format("%s                    %s",out,line)
		end
	end
	p.defense_network_message = "defense_network_message"
	p:addCustomMessage(console,p.defense_network_message,out)
end
function nebulaDefenseLoss(self,instigator)
	string.format("")
	local player_message = string.format(_("msgMainscreen","%s station %s in sector %s lost, part of the nebula defense network."),self:getFaction(),self:getCallSign(),self:getSectorName())
	globalMessage(player_message)
	if instigator ~= nil and instigator:isValid() then
		local faction = instigator:getFaction()
		local name = instigator:getCallSign()
		if name ~= nil and faction ~= nil then
			player_message = string.format(_("goal-incCall","%s %s vessel %s delivered the final destructive blow."),player_message,faction,name)
		end
	end
	table.insert(messages,{msg=player_message,list={}})
	local messages_index = #messages
	for i,p in ipairs(getActivePlayerShips()) do
		table.insert(messages[messages_index].list,p)
	end
end
function cleanList(list)
	local clean_list = true
	if #list > 0 then
		for i,obj in ipairs(list) do
			if obj == nil or not obj:isValid() then
				list[i] = list[#list]
				list[#list] = nil
				clean_list = false
				break
			end
		end
	end
	return clean_list
end
function updateNebulaEncroachment()
	for i,neb in ipairs(seige_nebula) do
		local halt_neb = false
		for j,station in ipairs(inner_stations) do
			if station ~= nil and station:isValid() then
				if station.nebula_defense then
					if neb:isValid() then
						if distance(station,neb) < station.nebula_push then
							halt_neb = true
							break
						end
					end
				end
			end
		end
		if not halt_neb then
			for j,station in ipairs(outer_stations) do
				if station ~= nil and station:isValid() then
					if station.nebula_defense and neb:isValid() then
						if distance(station,neb) < station.nebula_push then
							halt_neb = true
							break
						end
					end
				end
			end
		end
		if not halt_neb then
			for j,wj in ipairs(warp_jammer_nebula_defense) do
				if wj:isValid() and neb:isValid() then
					if distance(wj,neb) < wj.nebula_push then
						halt_neb = true
						break
					end
				end
			end
		end
		if not halt_neb and neb:isValid() then
			local current_distance = distance(neb,center_x,center_y)
			if neb.direction == "inbound" then
				if current_distance > (region_planet:getPlanetRadius() + 5000) then
					local new_distance = current_distance * .999
					local neb_angle = angleHeading(center_x,center_y,neb)
					local neb_x, neb_y = vectorFromAngle(neb_angle,new_distance,true)
					neb:setPosition(neb_x + center_x,neb_y + center_y)
				else
					neb.direction = "outbound"
				end
			else
				if current_distance > 80000 then
					neb.direction = "inbound"
				else
					local new_distance = current_distance * 1.001
					local neb_angle = angleHeading(center_x,center_y,neb)
					local neb_x, neb_y = vectorFromAngle(neb_angle,new_distance,true)
					neb:setPosition(neb_x + center_x, neb_y + center_y)
				end
			end
		end
	end
end
function finalStats()
	local a_player = getPlayerShip(-1)
	local final_message = string.format(_("msgMainscreen","%s ended with %s reputation points (goal: %s)."),player_faction,a_player:getReputationPoints(),reputation_goal)
	local cleared_message = string.format(_("msgMainscreen","%i waves cleared."),wave_number - 1)
	if wave_number - 1 == 0 then
		cleared_message = _("msgMainscreen","No waves cleared.")
	elseif wave_number - 1 == 1 then
		cleared_message = _("msgMainscreen","One wave cleared.")
	end
	final_message = string.format("%s\n%s",final_message,cleared_message)
	if deployed_player_count > 1 then
		final_message = string.format(_("msgMainscreen","%s\nDeployed %s player ships."),final_message,deployed_player_count)
	else
		final_message = string.format(_("msgMainscreen","%s\nDeployed one player ship."),final_message)
	end
	final_message = string.format(_("msgMainscreen","%s\nTime spent: %s."),final_message,formatTime(getScenarioTime()))
	final_message = string.format(_("msgMainscreen","%s\nEnemies:%s Murphy:%s Respawn:%s"),
		final_message,getScenarioSetting("Enemies"),getScenarioSetting("Murphy"),getScenarioSetting("Respawn"))
	for i,wt in ipairs(wave_task) do
		final_message = string.format(_("msgMainscreen","%s\nWave:%i Task forces:%i"),final_message,i,wt)
	end
	return final_message
end
--	Update player ship
function updateSystemHealth(p)
	if cleanList(stations) then
		for i,station in ipairs(stations) do
			if p:isDocked(station) then
				if p:getMaxCoolant() < 10 then
					if station.gradual_coolant_replenish then
						p:setMaxCoolant(math.min(10,p:getMaxCoolant() + .001))
					end
				end
				for j,sys in ipairs(system_types) do
					if p:getSystemHealthMax(sys) < 1 then
						if station.gradual_repair_max_health then
							p:setSystemHealthMax(sys,math.min(1,p:getSystemHealthMax(sys) + .001))
						end
					end
				end
				break
			end
		end
	end
end
function updatePlayerNebulaImpact(p)
	local object_list = p:getObjectsInRange(5100)
	for i,obj in ipairs(object_list) do
		if isObjectType(obj,"Nebula") then
			if distance(p,obj) < 5000 then
				if p:getShieldsActive() then
					if p:getShieldCount() > 1 then
						local new_level_0 = math.max(0,p:getShieldLevel(0) - (p:getShieldMax(0)*.001))
						local new_level_1 = math.max(0,p:getShieldLevel(1) - (p:getShieldMax(1)*.001))
						p:setShields(new_level_0,new_level_1)
					elseif p:getShieldCount() == 1 then
						local new_level_0 = math.max(0,p:getShieldLevel(0) - (p:getShieldMax(0)*.001))
						p:setShields(new_level_0)
					end
				else
					if obj.impacted_systems ~= nil then
						for j,system in ipairs(obj.impacted_systems) do
							if system == "coolant" then
								local new_max_coolant = math.max(0,p:getMaxCoolant() - .01)
								p:setMaxCoolant(new_max_coolant)
							elseif system == "hull" then
								local new_max_hull = math.max(0,p:getHull() - (p:getHullMax()*.001))
								p:setHull(new_max_hull)
							else
								p:setSystemHealth(system,p:getSystemHealth(system) - .001)
								if p:getSystemHealth(system) < 0 then
									if random(-1,0) > p:getSystemHealth(system) then
										p:setSystemHealthMax(system,p:getSystemHealthMax(system) - .001)
									end
								else
									if random(0,1) > p:getSystemHealth(system) then
										p:setSystemHealthMax(system,p:getSystemHealthMax(system) - .001)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end
function updateWaveBanner(p)
	local wave_banner = string.format(_("tabRelay&Operations","Wave:%i Task force:%i"),wave_number,task_force_number)
	p.wave_banner_rel = "wave_banner_rel"
	p:addCustomInfo("Relay",p.wave_banner_rel,wave_banner,3)
	p.wave_banner_ops = "wave_banner_ops"
	p:addCustomInfo("Operations",p.wave_banner_ops,wave_banner,3)
end
function updateNameBanner(p)
	local name_banner = string.format(_("tabHelms-id","%s %s in %s"),p:getFaction(),p:getCallSign(),p:getSectorName())
	p.name_banner_hlm = "name_banner_hlm"
	p:addCustomInfo("Helms",p.name_banner_hlm,name_banner,1)
	p.name_banner_tac = "name_banner_tac"
	p:addCustomInfo("Tactical",p.name_banner_tac,name_banner,1)
end
function updateTubeBanner(p)
	if p.tube_size ~= nil then
		local tube_size_banner = string.format("%s tubes: %s",p:getCallSign(),p.tube_size)
		if #p.tube_size == 1 then
			local tube_size_banner = string.format("%s tube: %s",p:getCallSign(),p.tube_size)
		end
		p.tube_size_banner_wea = "tube_size_banner_wea"
		p:addCustomInfo("Weapons",p.tube_size_banner_wea,tube_size_banner,2)
		p.tube_size_banner_tac = "tube_size_banner_tac"
		p:addCustomInfo("Tactical",p.tube_size_banner_tac,tube_size_banner,2)
	end
end

function update(delta)
	if delta == 0 then
		return
	end
	--	game is no longer paused
	allowNewPlayerShips(false)
	local friendly_defense_nodes_remain = 0
	local station_faction_list = ""
	for i,station in ipairs(stations) do
		if station ~= nil and station:isValid() and station.nebula_defense then
			if friendly_lookup_factions[station:getFaction()] then
				station_faction_list = string.format("%s %s",station_faction_list,station:getFaction())
				friendly_defense_nodes_remain = friendly_defense_nodes_remain + 1
			end
		end
	end
	--	defeat because all player ships destroyed
	if #getActivePlayerShips() == 0 then
		local final_message = _("msgMainscreen","All players destroyed.")
		final_message = string.format(_("msgMainscreen","%s\n%s out of %s friendly station nebula defense nodes remain."),final_message,friendly_defense_nodes_remain,original_friendly_defending_stations)
		final_message = string.format("%s\n%s",final_message,finalStats())
		globalMessage(final_message)
		victory("Exuari")
	end
	--	defeat because all friendly stations defending against nebulae are gone
	if friendly_defense_nodes_remain < 1 then
		local final_message = string.format(_("msgMainscreen","All %i friendly station nebula defense nodes destroyed."),original_friendly_defending_stations)
		final_message = string.format("%s\n%s",final_message,finalStats())
		globalMessage(final_message)
		victory("Exuari")
	end
	--	victory because target reputation points reached
	local a_player = getPlayerShip(-1)
	if a_player ~= nil and a_player:isValid() then
		if tonumber(a_player:getReputationPoints()) >= tonumber(reputation_goal) then
			local final_message = string.format(_("msgMainscreen","%s out of %s friendly station nebula defense nodes remain."),friendly_defense_nodes_remain,original_friendly_defending_stations)
			final_message = string.format("%s\n%s",final_message,finalStats())
			globalMessage(final_message)
			victory(player_faction)
		end
	end
	--	initial message describing mission and setting goals
	if mission_message == nil then
		mission_message = "queued"
		local player_message = string.format(_("goal-incCall","Enemies of the %s have deployed destructive nebulae against the region around the planet %s. The deployment mechanism resembles a closing iris door as the nebulae converge on %s. We have created a nebula defense network. We installed the defense nodes on some friendly stations, some neutral stations and some warp jammers. Your mission is to accumulate %s reputation points before the friendly stations with the nebula defense nodes get destroyed."),player_faction,region_planet:getCallSign(),region_planet:getCallSign(),reputation_goal)
		table.insert(messages,{msg=player_message,list={}})
		local messages_index = #messages
		for i,p in ipairs(getActivePlayerShips()) do
			table.insert(messages[messages_index].list,p)
		end
	end
	if spawn_wave_time ~= nil then
		if getScenarioTime() > spawn_wave_time then
			globalMessage("")
			spawnWave()
			spawn_wave_time = nil
			slog_interval = random(3,5)*60
			slog_time = getScenarioTime() + slog_interval
		else
			if spawn_wave_time - getScenarioTime() < 5 then
				globalMessage(math.ceil(spawn_wave_time - getScenarioTime()))
			end
		end
	else
		if cleanList(wave_enemies) then
			if #wave_enemies < 1 then
				spawn_wave_time = getScenarioTime() + 10
				globalMessage(string.format(_("msgMainscreen","Wave %i cleared"),wave_number))
				task_force_number = 0
				getPlayerShip(-1):addReputationPoints(40 + wave_number * reputation_bump_amount)
			else
				for i,ship in ipairs(wave_enemies) do
					if ship:getOrder() == "Fly towards" then
						if distance(ship,region_planet) < (region_planet:getPlanetRadius() + 1000) then
							ship:orderRoaming()
						end
					end
					if ship:getOrder() == "Roaming" then
						local sx, sy = ship:getPosition()
						if sx < 60000 and sy < 60000 then
							ship:orderFlyTowards(center_x,center_y)
						end
					end
				end
			end
		end
	end
	waveSlog()	--more threats with periodic task forces
	for i,p in ipairs(getActivePlayerShips()) do
		updatePlayerLongRangeSensors(delta,p)
		updatePlayerSpecialtyProbes(p)
		updatePlayerNebulaImpact(p)
		updateSystemHealth(p)
		updateWaveBanner(p)
		updateNameBanner(p)
		updateTubeBanner(p)
	end
	if maintenancePlot ~= nil then
		maintenancePlot()
	end
	updateAsteroidOrbits(delta)
	updateNebulaEncroachment()
	updateProbeLabor()
	updateProbeShipScan()
	messagePlayers()
end
