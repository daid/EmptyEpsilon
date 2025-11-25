-- Name: Rescue
-- Description: Rescue research scientist from the clutches of the Kraylor. Any number of player ships supported.
---
--- With the default settings, the scenario should run for thirty minutes to an hour. Terrain differs each scenario run. Scenario difficulty: low to medium with default settings.
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Mission
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
-- Setting[Reputation]: Amount of reputation to start with. Default: 20
-- Reputation[Unknown]: Zero reputation - nobody knows anything about you
-- Reputation[Nice|Default]: 20 reputation - you've had a small positive influence on the local community
-- Reputation[Hero]: 50 reputation - you helped important people or lots of people
-- Reputation[Major Hero]: 100 reputation - you're well known by nearly everyone as a force for good
-- Reputation[Super Hero]: 200 reputation - everyone knows you and relies on you for help

require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("comms_scenario_utility.lua")

--	Initialization
function init()
	scenario_version = "0.0.1"
	scenario_name = "Rescue"
	getScriptStorage():set("scenario_name", scenario_name)
	ee_version = "2024.12.08"
	print(string.format("    ----    Scenario: %s    ----    Version %s    ----    Tested with EE version %s    ----",scenario_name,scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	setConstants()
	setGlobals()
	setVariations()
	primary_orders = _("orders-comms","Rescue exotic weapons research scientist, Hans Gestalt")
	constructEnvironment()
	onNewPlayerShip(setPlayers)
	missionMaintenance = startInitialMission
end
function setConstants()
	relative_strength = 1
	max_repeat_loop = 100
	ordnance_types = {"Homing", "Nuke", "Mine", "EMP", "HVLI"}
	system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
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
end
function setGlobals()
	ambush_sprung = false
	barrier_ships_exhausted = false
	what_we_want = false
	scientist_aboard = false
	switch_to_kraylor = false
	switch_to_independent = false
	current_orders_button = true
	stations_improve_ships = true
	sensor_impact = 1
	player_respawns = false
	player_respawn_max = 0
	deployed_player_count = 0
	deployed_players = {}
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
	stations = {}
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
	star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			info = {
				{
					name = "Gamma Piscium",
					unscanned = _("scienceDescription-star","Yellow,\nspectral type G8 III"),
					scanned = _("scienceDescription-star","Yellow,\nspectral type G8 III,\ngiant,\nsurface temperature 4,833 K,\n11 solar radii"),
				},
				{
					name = "Beta Leporis",
					unscanned = _("scienceDescription-star","Classification G5 II"),
					scanned = _("scienceDescription-star","Classification G5 II,\nbright giant,\nbinary"),
				},
				{
					name = "Sigma Draconis",
					unscanned = _("scienceDescription-star","Classification K0 V or G9 V"),
					scanned = _("scienceDescription-star","Classification K0 V or G9 V,\nmain sequence dwarf,\n84% of Sol mass"),
				},
				{
					name = "Iota Carinae",
					unscanned = _("scienceDescription-star","Classification A7 lb"),
					scanned = _("scienceDescription-star","Classification A7 lb,\nsupergiant,\ntemperature 7,500 K,\n7xSol mass"),
				},
				{
					name = "Theta Arietis",
					unscanned = _("scienceDescription-star","Classification A1 Vn"),
					scanned = _("scienceDescription-star","Classification A1 Vn,\ntype A main sequence,\nnebulous"),
				},
				{
					name = "Epsilon Indi",
					unscanned = _("scienceDescription-star","Classification K5V"),
					scanned = _("scienceDescription-star","Classification K5V,\norange,\ntemperature 4,649 K"),
				},
				{
					name = "Beta Hydri",
					unscanned = _("scienceDescription-star","Classification G2 IV"),
					scanned = _("scienceDescription-star","Classification G2 IV,\n113% of Sol mass,\n185% Sol radius"),
				},
				{
					name = "Acamar",
					unscanned = _("scienceDescription-star","Classification A3 IV-V"),
					scanned = _("scienceDescription-star","Classification A3 IV-V,\n2.6xSol mass"),
				},
				{
					name = "Bellatrix",
					unscanned = _("scienceDescription-star","Classification B2 III or B2 V"),
					scanned = _("scienceDescription-star","Classification B2 III or B2 V,\n8.6xSol mass,\ntemperature 22,000 K"),
				},
				{
					name = "Castula",
					unscanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5"),
					scanned = _("scienceDescription-star","Classification G8 IIIb Fe-0.5,\nyellow,\nred clump giant"),
				},
				{
					name = "Dziban",
					unscanned = _("scienceDescription-star","Classification F5 IV-V"),
					scanned = _("scienceDescription-star","Classification F5 IV-V,\nF-type subgiant\nF-type main sequence"),
				},
				{
					name = "Elnath",
					unscanned = _("scienceDescription-star","Classification B7 III"),
					scanned = _("scienceDescription-star","Classification B7 III,\nB-class giant,\n5xSol mass"),
				},
				{
					name = "Flegetonte",
					unscanned = _("scienceDescription-star","Classification K0"),
					scanned = _("scienceDescription-star","Classification K0,\norange-red,\ntemperature ~4,000 K"),
				},
				{
					name = "Geminga",
					unscanned = _("scienceDescription-star","Pulsar or Neutron star"),
					scanned = _("scienceDescription-star","Pulsar or Neutron star,\ngamma ray source"),
				},
				{	
					name = "Helvetios",	
					unscanned = _("scienceDescription-star","Classification G2V"),
					scanned = _("scienceDescription-star","Classification G2V,\nyellow,\ntemperature 5,571 K"),
				},
				{	
					name = "Inquill",	
					unscanned = _("scienceDescription-star","Classification G1V(w)"),
					scanned = _("scienceDescription-star","Classification G1V(w),\n1.24xSol mass,n7th magnitude G-type main sequence"),
				},
				{	
					name = "Jishui",	
					unscanned = _("scienceDescription-star","Classification F3 III"),
					scanned = _("scienceDescription-star","Classification F3 III,\nF-type giant,\ntemperature 6,309 K"),
				},
				{	
					name = "Kaus Borealis",	
					unscanned = _("scienceDescription-star","Classification K1 IIIb"),
					scanned = _("scienceDescription-star","Classification K1 IIIb,\ngiant,\ntemperature 4,768 K"),
				},
				{	
					name = "Liesma",	
					unscanned = _("scienceDescription-star","Classification G0V"),
					scanned = _("scienceDescription-star","Classification G0V,\nG-type giant, \ntemperature 5,741 K"),
				},
				{	
					name = "Macondo",	
					unscanned = _("scienceDescription-star","Classification K2IV-V or K3V"),
					scanned = _("scienceDescription-star","Classification K2IV-V or K3V,\norange,\nK-type main sequence,\ntemperature 5,030 K"),
				},
				{	
					name = "Nikawiy",	
					unscanned = _("scienceDescription-star","Classification G5"),
					scanned = _("scienceDescription-star","Classification G5,\nyellow,\nluminosity 7.7"),
				},
				{	
					name = "Orkaria",	
					unscanned = _("scienceDescription-star","Classification M4.5"),
					scanned = _("scienceDescription-star","Classification M4.5,\nRed Dwarf,\nluminosity .0035,\ntemperature 3,111 K"),
				},
				{	
					name = "Poerava",	
					unscanned = _("scienceDescription-star","Classification F7V"),
					scanned = _("scienceDescription-star","Classification F7V,\nyellow-white,\nluminosity 1.9,\ntemperature 6,440 K"),
				},
				{	
					name = "Stribor",	
					unscanned = _("scienceDescription-star","Classification F8V"),
					scanned = _("scienceDescription-star","Classification F8V,\nluminosity 2.9,\ntemperature 6,122 K"),
				},
				{	
					name = "Taygeta",	
					unscanned = _("scienceDescription-star","Classification B"),
					scanned = _("scienceDescription-star","Classification B-type subgiant, blue-white, luminosity 600, temperature 13,696 K"),
				},
				{	
					name = "Tuiren",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G,\nmagnitude 12.26,\ntemperature 5,580 K"),
				},
				{	
					name = "Ukdah",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification K2.5 III,\nK-type giant,\ntemperature 4,244 K"),
				},
				{	
					name = "Wouri",	
					unscanned = _("scienceDescription-star","Classification K"),
					scanned = _("scienceDescription-star","Classification 5V,\nK-type main sequence,\ntemperature 4,782 K"),
				},
				{	
					name = "Xihe",	
					unscanned = _("scienceDescription-star","Classification G"),
					scanned = _("scienceDescription-star","Classification G8 III,\nevolved G-type giant,\ntemperature 4,790 K"),
				},
				{	
					name = "Yildun",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A1 Van,\nwhite hued,\nA-type main sequence,\ntemperature 9,911 K"),
				},
				{	
					name = "Zosma",	
					unscanned = _("scienceDescription-star","Classification A"),
					scanned = _("scienceDescription-star","Classification A4 V,\nwhite hued,\nA-type main sequence,\ntemperature 8,296 K"),
				},
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
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Jovian, source for hydrogen and helium and a large variety of exotic gasses"),
			texture = {
				surface = "planets/gas-1.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Neptunian, source for hydrogen helium, ammonia, methane, water"),
			texture = {
				surface = "planets/gas-2.png"
			},
			radius = random(4000,7500),
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			unscanned = _("scienceDescription-planet","Class J"),
			scanned = _("scienceDescription-planet","Class J, Neptunian, composed of hydrogen, helium, methane, water"),
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
	moon_list = {
		{
			name = {"Ganymede", "Europa", "Deimos", "Luna"},
			texture = {
				surface = "planets/moon-1.png"
			},
			radius = random(1000,3000),
		},
		{
			name = {"Myopia", "Zapata", "Lichen", "Fandango"},
			texture = {
				surface = "planets/moon-2.png"
			},
			radius = random(1000,3000),
		},
		{
			name = {"Scratmat", "Tipple", "Dranken", "Calypso"},
			texture = {
				surface = "planets/moon-3.png"
			},
			radius = random(1000,3000),
		},
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
		["Easy"] =		{number = .5,	rm = 1},
		["Normal"] =	{number = 1,	rm = 1},
		["Hard"] =		{number = 2,	rm = 1.1},
		["Extreme"] =	{number = 3,	rm = 1.2},
		["Quixotic"] =	{number = 5,	rm = 1.5},
	}
	difficulty =		murphy_config[getScenarioSetting("Murphy")].number
	range_multiplier =	murphy_config[getScenarioSetting("Murphy")].rm
	local respawn_config = {
		["None"] =		{respawn = false,	max = 0},
		["One"] =		{respawn = true,	max = 1},
		["Two"] =		{respawn = true,	max = 2},
		["Three"] =		{respawn = true,	max = 3},
		["Infinite"] =	{respawn = true,	max = 999},	--I know, it's not infinite, but come on, after 999, it should stop
	}
	player_respawns = respawn_config[getScenarioSetting("Respawn")].respawn
	player_respawn_max = respawn_config[getScenarioSetting("Respawn")].max
	local reputation_config = {
		["Unknown"] = 		0,
		["Nice"] = 			20,
		["Hero"] = 			50,
		["Major Hero"] =	100,
		["Super Hero"] =	200,
	}
	reputation_start_amount = reputation_config[getScenarioSetting("Reputation")]
end
--	Terrain
function constructEnvironment()
	center_x = random(100000,200000)
	center_y = random(50000,100000)
	inner_space = {}
	stations = {}
	inner_stations = {}
	transports = {}
	--	central star
	local radius = random(600,1400)
	central_star = Planet():setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5):setPosition(center_x, center_y)
	if random(1,100) < 43 then
		central_star:setDistanceFromMovementPlane(radius*.5)
	end
	local star_item = tableRemoveRandom(star_list[1].info)
	central_star:setCallSign(star_item.name)
	if star_item.unscanned ~= nil then
		central_star:setDescriptions(star_item.unscanned,star_item.scanned)
		central_star:setScanningParameters(1,2)
	end
	central_star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
	table.insert(inner_space,{obj=central_star,dist=radius,shape="circle"})
	--	player start
	local player_start_angle = random(0,360)
	player_spawn_x, player_spawn_y = vectorFromAngle(player_start_angle,random(radius + 3500,5000),true)
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	multiple_player_spawn = {
		{x = player_spawn_x,		y = player_spawn_y},		--1
		{x = player_spawn_x + 500,	y = player_spawn_y},		--2
		{x = player_spawn_x,		y = player_spawn_y + 500},	--3
		{x = player_spawn_x - 500,	y = player_spawn_y},		--4
		{x = player_spawn_x,		y = player_spawn_y - 500},	--5
		{x = player_spawn_x + 500,	y = player_spawn_y - 500},	--6
		{x = player_spawn_x - 500,	y = player_spawn_y + 500},	--7
		{x = player_spawn_x + 500,	y = player_spawn_y + 500},	--8
		{x = player_spawn_x - 500,	y = player_spawn_y - 500},	--9
		{x = player_spawn_x - 1000,	y = player_spawn_y},		--10
		{x = player_spawn_x,		y = player_spawn_y - 1000},	--11
		{x = player_spawn_x + 1000,	y = player_spawn_y},		--12
		{x = player_spawn_x,		y = player_spawn_y + 1000},	--13
		{x = player_spawn_x + 1000,	y = player_spawn_y + 1000},	--14
		{x = player_spawn_x - 1000,	y = player_spawn_y - 1000},	--15
		{x = player_spawn_x + 1000,	y = player_spawn_y - 1000},	--16
		{x = player_spawn_x - 1000,	y = player_spawn_y + 1000},	--17
		{x = player_spawn_x + 1000,	y = player_spawn_y + 500},	--18
		{x = player_spawn_x + 1000,	y = player_spawn_y - 500},	--19
		{x = player_spawn_x - 1000,	y = player_spawn_y + 500},	--20
		{x = player_spawn_x - 1000,	y = player_spawn_y - 500},	--21
		{x = player_spawn_x + 500,	y = player_spawn_y + 1000},	--22
		{x = player_spawn_x + 500,	y = player_spawn_y - 1000},	--23
		{x = player_spawn_x - 500,	y = player_spawn_y + 1000},	--24
		{x = player_spawn_x - 500,	y = player_spawn_y - 1000},	--25
		{x = player_spawn_x + 1500,	y = player_spawn_y},		--26
		{x = player_spawn_x,		y = player_spawn_y + 1500},	--27
		{x = player_spawn_x - 1500,	y = player_spawn_y},		--28
		{x = player_spawn_x,		y = player_spawn_y - 1500},	--29
		{x = player_spawn_x - 1500,	y = player_spawn_y - 1500},	--30
		{x = player_spawn_x + 1500,	y = player_spawn_y + 1500},	--31
		{x = player_spawn_x + 1500,	y = player_spawn_y - 1500},	--32
	}
	table.insert(inner_space,{obj=VisualAsteroid():setPosition(player_spawn_x,player_spawn_y),dist=2000,shape="circle"})
	--	home station
	player_faction = "Human Navy"
	local psx, psy = vectorFromAngle(player_start_angle + 90,random(2500,5000),true)
	home_station = placeStation(psx + player_spawn_x, psy + player_spawn_y,"RandomHumanNeutral","Human Navy")
	home_station:setShortRangeRadarRange(10000 + random(0,5000))
	local missile_available_count = 0
	if home_station.comms_data.weapon_available.Homing then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.Nuke then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.Mine then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.EMP then
		missile_available_count = missile_available_count + 1
	end
	if home_station.comms_data.weapon_available.HVLI then
		missile_available_count = missile_available_count + 1
	end
	if missile_available_count == 0 then
		home_station.comms_data.weapon_available.Homing = true
		home_station.comms_data.weapon_available.Nuke = true
		home_station.comms_data.weapon_available.Mine = true
		home_station.comms_data.weapon_available.EMP = true
		home_station.comms_data.weapon_available.HVLI = true
	end
	table.insert(stations,home_station)
	table.insert(inner_stations,home_station)
	table.insert(inner_space,{obj=home_station,dist=4000,shape="circle"})
	--	band planet
	local band_angle = random(0,360)
	local bp_x, bp_y = vectorFromAngle(band_angle,75000,true)
	local band_planet_item = tableRemoveRandom(planet_list)
	local band_planet_radius = band_planet_item.radius
	band_planet = Planet():setPosition(bp_x + center_x,bp_y + center_y):setPlanetRadius(band_planet_radius)
	band_planet:setDistanceFromMovementPlane(band_planet_radius*-.3)
	band_planet:setCallSign(tableSelectRandom(band_planet_item.name))
	band_planet:setPlanetSurfaceTexture(band_planet_item.texture.surface)
	rotation_time = random(300,500)
	if band_planet_item.texture.atmosphere ~= nil then
		rotation_time = rotation_time * .65
		band_planet:setPlanetAtmosphereTexture(band_planet_item.texture.atmosphere)
	end
	if band_planet_item.texture.cloud ~= nil then
		band_planet:setPlanetCloudTexture(band_planet_item.texture.cloud)
	end
	if band_planet_item.color ~= nil then
		band_planet:setPlanetAtmosphereColor(band_planet_item.color.red,band_planet_item.color.green,band_planet_item.color.blue)
	end
	band_planet:setAxialRotationTime(rotation_time)
	band_planet:setOrbit(central_star,2300)
	if band_planet_item.unscanned ~= nil then
		band_planet:setDescriptions(band_planet_item.unscanned,band_planet_item.scanned)
		band_planet:setScanningParameters(1,2)
	end
	--	band moon
	band_angle = random(0,360)
	local bm_x, bm_y = vectorFromAngle(band_angle,band_planet_radius + 8000)
	local band_moon_item = tableRemoveRandom(moon_list)
	local band_moon_radius = band_moon_item.radius
	band_moon = Planet():setPosition(bm_x + bp_x + center_x,bm_y + bp_y + center_y):setPlanetRadius(band_moon_radius)
	band_moon:setDistanceFromMovementPlane(band_moon_radius*.25)
	band_moon:setCallSign(tableSelectRandom(band_moon_item.name))
	band_moon:setPlanetSurfaceTexture(band_moon_item.texture.surface)
	band_moon:setAxialRotationTime(random(400,600))
	band_moon:setOrbit(band_planet,random(100,300))
	--	inner stations
	local station_angle = random(0,360)
	local psx, psy = vectorFromAngle(station_angle,random(15000,45000),true)
	local placed_station = placeStation(psx + center_x,psy + center_y,"RandomHumanNeutral","Independent")
	table.insert(stations,placed_station)
	table.insert(inner_stations,placed_station)
	table.insert(inner_space,{obj=placed_station,dist=4000,shape="circle"})
	local a_station_angle = station_angle + random(90,150)
	psx, psy = vectorFromAngle(a_station_angle,random(15000,45000),true)
	placed_station = placeStation(psx + center_x,psy + center_y,"RandomHumanNeutral","Independent")
	table.insert(stations,placed_station)
	table.insert(inner_stations,placed_station)
	table.insert(inner_space,{obj=placed_station,dist=4000,shape="circle"})
	a_station_angle = station_angle - random(90,150)
	psx, psy = vectorFromAngle(a_station_angle,random(15000,45000),true)
	placed_station = placeStation(psx + center_x,psy + center_y,"RandomHumanNeutral","Independent")
	table.insert(stations,placed_station)
	table.insert(inner_stations,placed_station)
	table.insert(inner_space,{obj=placed_station,dist=4000,shape="circle"})
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
	placement_areas = {
		["Inner Torus"] = {
			stations = inner_stations,
			transports = transports, 
			space = inner_space,
			shape = "torus",
			center_x = center_x, 
			center_y = center_y, 
			inner_radius = radius + 4000, 
			outer_radius = 50000,
		},
	}
	local terrain = {
--		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Star",	obj = Planet,		desc = "Star",		},
--		{chance = 4,	count = 0,	max = math.random(1,2),		radius = "Hole",	obj = BlackHole,						},
		{chance = 7,	count = 0,	max = -1,					radius = "Tiny",	obj = ScanProbe,						},
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
--		{chance = 4,	count = 0,	max = 10,					radius = "Trans",	obj = CpuShip,		desc = "Transport",	},
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
	until(objects_placed_count >= 75)
	--	target station
	target_station_angle = random(0,360)
	local target_station_x, target_station_y = vectorFromAngle(target_station_angle,150000,true)
	target_station_x = target_station_x + center_x
	target_station_y = target_station_y + center_y
	target_station = placeStation(target_station_x,target_station_y,"Science","Independent")
	sorted_inner_stations = {}
	for i,station in ipairs(inner_stations) do
		table.insert(sorted_inner_stations,{station=station,dist=distance(home_station,station)})
	end
	table.sort(sorted_inner_stations, function(a,b)
		return a.dist < b.dist
	end)
	local relations = {
		_("station-comms","brother"),
		_("station-comms","sister"),
		_("station-comms","cousin"),
		_("station-comms","spouse")
	}
	for i,si in ipairs(sorted_inner_stations) do
		ksi = sorted_inner_stations[i+1]
		if ksi == nil then
			ksi = {station=target_station,dist=distance(home_station,target_station)}
		end
		si.station.station_knowledge = string.format(_("station-comms","I know of station %s in sector %s because my %s is there. It's ~%sU from %s."),ksi.station:getCallSign(),ksi.station:getSectorName(),tableRemoveRandom(relations),math.floor(ksi.dist/1000),home_station:getCallSign())
	end
	local wj_count = 20
	warp_jammer_ring = {}
	for i=1,wj_count do
		local wj_x, wj_y = vectorFromAngle(i*(360/wj_count),25000,true)
		local wj = WarpJammer():setPosition(wj_x + target_station_x, wj_y + target_station_y)
		wj:setRange(7700):setFaction("Kraylor")
		if difficulty > 1 then
			wj:onDestruction(function()
				for j,wjri in ipairs(warp_jammer_ring) do
					if wjri ~= nil and wjri:isValid() then
						wjri:setRange(wjri:getRange()*range_multiplier)
					end
				end
			end)
		end
		table.insert(warp_jammer_ring,wj)
	end
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
		if placement_area == "Inner Torus" or placement_area == "Region 2 Torus" or placement_area == "Region 3 Torus" or placement_area == "Region 4 Torus" then
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
	if placement_area == "Inner Torus" or placement_area == "Region 2 Torus" or placement_area == "Region 3 Torus" or placement_area == "Region 4 Torus" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	end
	if eo_x ~= nil then
		if terrain.obj == WormHole then
			local we_x, we_y = nil
			local count_repeat_loop = 0
			repeat
				if placement_area == "Region 2 Torus" or placement_area == "Region 3 Torus" or placement_area == "Region 4 Torus" then
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
			local hi_range = 70000
			local lo_impact = 10000
			local hi_impact = 60000
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
					object:setLifetime(20*60):setOwner(owner):setTarget(eo_x,eo_y):setPosition(s_x,s_y)
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
--	Sensor jammer functions
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
--	Players
function setPlayers()
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			updatePlayerSoftTemplate(p)
			deployed_player_count = deployed_player_count + 1
			if difficulty < 1 then
				p:addToShipLog(string.format(_("goal-shipLog","Hans Gestalt, a noted exotic weapons research scientist, sent us an encrypted message. He's being held by the Kraylor against his will in his research facility on station %s in sector %s. Your mission is to dock with %s, retrieve him and bring him to %s."),target_station:getCallSign(),target_station:getSectorName(),target_station:getCallSign(),home_station:getCallSign()),"Magenta") 
			else
				p:addToShipLog(string.format(_("goal-shipLog","Hans Gestalt, a noted exotic weapons research scientist, sent us an encrypted message. He's being held by the Kraylor against his will in his research facility on station %s. Your mission is to dock with %s, retrieve him and bring him to %s."),target_station:getCallSign(),target_station:getCallSign(),home_station:getCallSign()),"Magenta") 
			end
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
		if p:getReputationPoints() == 0 then
			p:setReputationPoints(reputation_start_amount)
		end
	end
end
function updatePlayerSoftTemplate(p)
	--set defaults for those ships not found in the list
	local pidx = 1
	for i,ap in ipairs(getActivePlayerShips()) do
		if ap == p then
			pidx = i
			break
		end
	end
	p:setPosition(multiple_player_spawn[pidx].x, multiple_player_spawn[pidx].y)
	local initial_harasser_templates = {"Shepherd","Touchy"}
	local selected_template = tableSelectRandom(initial_harasser_templates)
	local ship = ship_template[selected_template].create("Kraylor",selected_template)
	ship:setCallSign(generateCallSign(nil,"Kraylor"))
	local es_x, es_y = vectorFromAngle(target_station_angle,8000,true)
	ship:setPosition(multiple_player_spawn[pidx].x + es_x, multiple_player_spawn[pidx].y + es_y)
	ship:orderAttack(p)
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	p:setFaction("Human Navy")
	p:onDestroyed(playerDestroyed)
	p:onDestruction(playerDestruction)
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
			if temp_type_name == "MP52 Hornet" then
				p:setWarpDrive(true)
				p:setWarpSpeed(900)
			elseif temp_type_name == "ZX-Lindworm" then
				p:setWarpDrive(true)
				p:setWarpSpeed(850)
			elseif temp_type_name == "Striker" then
				p:setJumpDrive(true)
				p:setJumpDriveRange(3000,40000)
				p:setImpulseMaxSpeed(90)
			elseif temp_type_name == "Phobos M3P" then
				p:setWarpDrive(true)
				p:setWarpSpeed(800)
			elseif temp_type_name == "Player Fighter" then
				p:setJumpDrive(true)
				p:setJumpDriveRange(3000,40000)
			end
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
end
function playerDestroyed()
	string.format("")
end
function playerDestruction(self,instigator)
	string.format("")
	if self.scientist_aboard then
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","Rescue the scientist, don't get him killed!\n%s"),msg))
		victory("Kraylor")
	end
	for i,dp in ipairs(deployed_players) do
		if self == dp.p then
			if dp.count > player_respawn_max then
				globalMessage(string.format(_("msgMainscreen","%s has been destroyed."),self:getCallSign()))
			else
				local respawned_player = PlayerSpaceship():setTemplate(self:getTypeName()):setFaction("Human Navy")
				dp.p = respawned_player
				dp.count = dp.count + 1
				respawned_player:setCallSign(string.format("%s %i",dp.name,dp.count))
				respawned_player.name_set = true
				respawned_player.individual_mission = self.individual_mission
				updatePlayerSoftTemplate(respawned_player)
				globalMessage(string.format(_("msgMainscreen","The Human Navy has respawned %s to replace %s."),respawned_player:getCallSign(),self:getCallSign()))
				self:transferPlayersToShip(respawned_player)
			end
			break
		end
	end
end
--	Missions
function startInitialMission()
	local target_station_x, target_station_y = target_station:getPosition()
	local home_station_x, home_station_y = home_station:getPosition()
	local enemy_angle = angleHeading(home_station_x,home_station_y,target_station_x,target_station_y)
	local enemy_x, enemy_y = vectorFromAngle(enemy_angle,60000,true)
	local fleet = spawnRandomArmed(enemy_x + home_station_x, enemy_y + home_station_y)
	for i,ship in ipairs(fleet) do
		ship:orderFlyTowards(home_station_x, home_station_y)
	end
	fleet = spawnRandomArmed(target_station_x,target_station_y)
	for i,ship in ipairs(fleet) do
		ship:orderDefendTarget(target_station)
	end
	playSoundFile("audio/scenario/22/sa_22_RescueHans.ogg")
	missionMaintenance = approachBarrier
end
function approachBarrier()
	if not barrier_ships_exhausted then
		for i,wj in ipairs(warp_jammer_ring) do
			if wj ~= nil and wj:isValid() then
				for j,p in ipairs(getActivePlayerShips()) do
					local pw_dist = distance(p,wj)
					if pw_dist < 5500 then
						if p.wj_trigger == nil and wj.trigger == nil then
							p.wj_trigger = true
							wj.trigger = true
							local wj_x, wj_y = wj:getPosition()
							local fleet = spawnRandomArmed(wj_x,wj_y)
							local wj_next = i+1
							if wj_next > #warp_jammer_ring then
								wj_next = 1
							end
							if warp_jammer_ring[wj_next] ~= nil and warp_jammer_ring[wj_next]:isValid() then
								if warp_jammer_ring[wj_next].trigger == nil then
									warp_jammer_ring[wj_next].trigger = true
									wj_x, wj_y = warp_jammer_ring[wj_next]:getPosition()
									fleet = spawnRandomArmed(wj_x,wj_y)
								end
							end
							local wj_prev = i-1
							if wj_prev < 1 then
								wj_prev = #warp_jammer_ring
							end
							if warp_jammer_ring[wj_prev] ~= nil and warp_jammer_ring[wj_prev]:isValid() then
								if warp_jammer_ring[wj_prev].trigger == nil then
									warp_jammer_ring[wj_prev].trigger = true
									wj_x, wj_y = warp_jammer_ring[wj_prev]:getPosition()
									fleet = spawnRandomArmed(wj_x,wj_y)
								end
							end
						end
					end
				end
			end
		end
		if switch_to_independent then
			for i,p in ipairs(getActivePlayerShips()) do
				if p.inform_engineering_button_sci ~= nil then
					p:removeCustom(p.inform_engineering_button_sci)
					p.inform_engineering_button_sci = nil
				end
				if p.inform_relay_button_sci ~= nil then
					p:removeCustom(p.inform_relay_button_sci)
					p.inform_relay_button_sci = nil
				end
				if p.inform_engineering_button_ops ~= nil then
					p:removeCustom(p.inform_engineering_button_ops)
					p.inform_engineering_button_ops = nil
				end
				if p.inform_relay_button_ops ~= nil then
					p:removeCustom(p.inform_relay_button_ops)
					p.inform_relay_button_ops = nil
				end
				if p.fabricate_component_eng ~= nil then
					p:removeCustom(p.fabricate_component_eng)
					p.fabricate_component_eng = nil
				end
				if p.fabricate_component_epl ~= nil then
					p:removeCustom(p.fabricate_component_epl)
					p.fabricate_component_epl = nil
				end
				if p.program_component_rel ~= nil then
					p:removeCustom(p.program_component_rel)
					p.program_component_rel = nil
				end
				if p.program_component_ops ~= nil then
					p:removeCustom(p.program_component_ops)
					p.program_component_ops = nil
				end
				if p.scientist_aboard and distance(p,target_station) > 25000 then
					for j,wj in ipairs(warp_jammer_ring) do
						if wj ~= nil and wj:isValid() then
							if wj.trigger == nil then
								wj.trigger = true
								local wj_x, wj_y = wj:getPosition()
								local fleet = spawnRandomArmed(wj_x,wj_y)
								local hs_x, hs_y = home_station:getPosition()
								for k,ship in ipairs(fleet) do
									ship:orderFlyTowards(hs_x, hs_y)
								end
								if not what_we_want then
									if availableForComms(p) then
										fleet[1]:sendCommsMessage(p,string.format(_("Kraylor-incCall","You have stolen what we want. Return what you have stolen, %s, or suffer the consequences!"),p:getCallSign()))
									end
									p:addToShipLog(_("Kraylor-shipLog","[Kraylor Commander] You have stolen what we want. Return what you have stolen"),"Red")
									playSoundFile("audio/scenario/22/sa_22_ReturnStolen.ogg")
									what_we_want = true
								end
							end
							wj:setRange(500)
						end
					end
					barrier_ships_exhausted = true
					player_with_scientist = p
				end
			end
		end
	end
	missionMaintenance = lastGasp
end
function lastGasp()
	if barrier_ships_exhausted and not ambush_sprung then
		if player_with_scientist ~= nil and player_with_scientist:isValid() then
			local home_dist = distance(player_with_scientist,home_station)
			if home_dist < 75000 and ambush_warning == nil then
				if availableForComms(player_with_scientist) then
					home_station:sendCommsMessage(player_with_scientist,_("warning-incCall","Keep your eyes open. The Kraylor probably have another strategy to get Hans Gestalt or kill him."))
					ambush_warning = "sent"
				end
				if audio_ambush_warning == nil then
					playSoundFile("audio/scenario/22/sa_22_KraylorTrick.ogg")
					audio_ambush_warning = "sent"
				end
			end
			if home_dist < 60000 then
				local pws_x, pws_y = player_with_scientist:getPosition()
				local hs_x, hs_y = home_station:getPosition()
				local ambush_angle = angleHeading(pws_x, pws_y, hs_x, hs_y)
				local c_x, c_y = vectorFromAngle(ambush_angle,6000,true)
				c_x = c_x + pws_x
				c_y = c_y + pws_y
				WarpJammer():setPosition(c_x,c_y):setRange(20000)
				local fleet = spawnRandomArmed(c_x,c_y)
				for i,ship in ipairs(fleet) do
					ship:setHeading(ambush_angle + 180)
				end
				local a_ambush_angle = ambush_angle + 60
				local a_x, a_y = vectorFromAngle(a_ambush_angle,6000,true)
				a_x = a_x + pws_x
				a_y = a_y + pws_y
				WarpJammer():setPosition(a_x,a_y):setRange(20000)
				fleet = spawnRandomArmed(a_x,a_y)
				for i,ship in ipairs(fleet) do
					ship:setHeading(a_ambush_angle + 180)
				end
				a_ambush_angle = ambush_angle - 60
				a_x, a_y = vectorFromAngle(a_ambush_angle,6000,true)
				a_x = a_x + pws_x
				a_y = a_y + pws_y
				WarpJammer():setPosition(a_x,a_y):setRange(20000)
				fleet = spawnRandomArmed(a_x,a_y)
				for i,ship in ipairs(fleet) do
					ship:setHeading(a_ambush_angle + 180)
				end
				a_x, a_y = vectorFromAngle(ambush_angle,12000,true)
				a_x = a_x + pws_x
				a_y = a_y + pws_y
				WarpJammer():setPosition(a_x,a_y):setRange(20000)
				fleet = spawnRandomArmed(a_x,a_y)
				for i,ship in ipairs(fleet) do
					ship:setHeading(ambush_angle + 180)
				end
				ambush_sprung = true
			end
		end
	end
	missionMaintenance = dockWithTargetStation
end
function dockWithTargetStation()
	if target_station ~= nil and target_station:isValid() then
		local player_ships_docked_count = 0
		for i,p in ipairs(getActivePlayerShips()) do
			if p:isDocked(target_station) then
				player_ships_docked_count = player_ships_docked_count + 1
				if p.dock_time == nil then
					p.dock_time = getScenarioTime() + 60
					p:addToShipLog(string.format(_("goal-shipLog","A small team of marines has been deployed from %s to board station %s to retrieve the exotic weapons research scientist. They should take about a minute to complete their mission."),p:getCallSign(),target_station:getCallSign()),"Magenta")
				end
				if getScenarioTime() > p.dock_time then
					p:removeCustom(p.dock_timer_banner_rel)
					p:removeCustom(p.dock_timer_banner_ops)
					if not scientist_aboard then
						p.scientist_aboard = true
						scientist_aboard = true
						p:addToShipLog(string.format(_("goal-shipLog","The marine team has returned to %s from station %s with the exotic weapons research scientist. Dock with station %s."),p:getCallSign(),target_station:getCallSign(),home_station:getCallSign()),"Magenta")
						for j,op in ipairs(getActivePlayerShips()) do
							if op ~= p then
								if op:isDocked(target_station) then
									op:addToShipLog(string.format(_("goal-shipLog","%s got the exotic weapons research scientist. The marines %s deployed have returned from station %s. %s needs to dock with station %s."),p:getCallSign(),op:getCallSign(),target_station:getCallSign(),p:getCallSign(),home_station:getCallSign()),"Magenta")
									op:removeCustom(p.dock_timer_banner_rel)
									op:removeCustom(p.dock_timer_banner_ops)
								else
									op:addToShipLog(string.format(_("goal-shipLog","%s got the exotic weapons research scientist. %s needs to dock with station %s."),p:getCallSign(),p:getCallSign(),home_station:getCallSign()),"Magenta")
								end
							end
						end
					end
				else
					if not scientist_aboard then
						p.dock_timer_banner_rel = "dock_timer_banner_rel"
						p:addCustomInfo("Relay",p.dock_timer_banner_rel,string.format(_("timer-tabRelay","Getting scientist %s"),formatTime(p.dock_time - getScenarioTime())),2)
						p.dock_timer_banner_ops = "dock_timer_banner_ops"
						p:addCustomInfo("Operations",p.dock_timer_banner_ops,string.format(_("timer-tabOperations","Getting scientist %s"),formatTime(p.dock_time - getScenarioTime())),2)
					end
				end
				if p.iff_switch_time == nil then
					p.iff_switch_time = getScenarioTime() + 30
				end
			else
				if p.dock_timer_banner_rel ~= nil then
					p:removeCustom(p.dock_timer_banner_rel)
				end
				if p.dock_timer_banner_ops ~= nil then
					p:removeCustom(p.dock_timer_banner_ops)
				end
			end
		end
		if player_ships_docked_count > 0 then
			if switch_to_kraylor then
				if not switch_to_independent then
					if target_station:getFaction() == "Independent" then
						target_station:setFaction("Kraylor")
						for i,p in ipairs(getActivePlayerShips()) do
							if p:isDocked(target_station) then
								p:setCanDock(false)
								p:addCustomMessage("Helms","kraylor_control_message_hlm",string.format(_("msgHelms","The Kraylor have gained control of station %s. They have engaged the docking clamps so that %s cannot undock."),target_station:getCallSign(),p:getCallSign()))
								p:addCustomMessage("Tactical","kraylor_control_message_tac",string.format(_("msgTactical","The Kraylor have gained control of station %s. They have engaged the docking clamps so that %s cannot undock."),target_station:getCallSign(),p:getCallSign()))
							else
								p:addToShipLog(string.format(_("goal-shipLog","The Kraylor have gained control of station %s."),target_station:getCallSign()),"Red")
							end
						end
					else
						if brainstorm_time == nil then
							brainstorm_time = getScenarioTime() + 8
						end
						if getScenarioTime() > brainstorm_time then
							if science_idea_message == nil then
								science_idea_message = "sent"
								for i,p in ipairs(getActivePlayerShips()) do
									p:addCustomMessage("Science","hack_idea_message_sci",string.format(_("msgScience","Your analysis of station %s and the Kraylor takeover mechanism suggests a way to switch %s back to Independent control. It would require component fabrication by Engineering and hacking programming by Relay to create and attach a device to the docking clamps. Then several consoles would have to simultaneously activate the hacking routine to complete the switchover.\n\nClick the buttons to send the plans to Engineering and Relay. If you don't see the buttons, look under the 'Scanning' widget."),target_station:getCallSign(),target_station:getCallSign()))
									p:addCustomMessage("Operations","hack_idea_message_ops",string.format(_("msgOperations","Your analysis of station %s and the Kraylor takeover mechanism suggests a way to switch %s back to Independent control. It would require component fabrication by Engineering and hacking programming by Relay to create and attach a device to the docking clamps. Then several consoles would have to simultaneously activate the hacking routine to complete the switchover.\n\nClick the buttons to send the plans to Engineering and Relay. If you don't see the buttons, look under the 'Scanning' widget."),target_station:getCallSign(),target_station:getCallSign()))
									p.inform_engineering_button_sci = "inform_engineering_button_sci"
									p:addCustomButton("Science",p.inform_engineering_button_sci,_("buttonScience","Inform Engineering"),function()
										string.format("")
										informEngineering(p)
									end)
									p.inform_relay_button_sci = "inform_relay_button_sci"
									p:addCustomButton("Science",p.inform_relay_button_sci,_("buttonScience","Inform Relay"),function()
										string.format("")
										informRelay(p)
									end)
									p.inform_engineering_button_ops = "inform_engineering_button_ops"
									p:addCustomButton("Operations",p.inform_engineering_button_ops,_("buttonOperations","Inform Engineering"),function()
										string.format("")
										informEngineering(p)
									end)
									p.inform_relay_button_ops = "inform_relay_button_ops"
									p:addCustomButton("Operations",p.inform_relay_button_ops,_("buttonOperations","Inform Relay"),function()
										string.format("")
										informRelay(p)
									end)
								end
							end
							local activate_hack_times = {}
							for i,p in ipairs(getActivePlayerShips()) do
								if p.component_fabricated and p.component_programmed then
									if p.activate_hack_hlm == nil then
										p.activate_hack_hlm = "activate_hack_hlm"
										p:addCustomButton("Helms",p.activate_hack_hlm,_("buttonHelms","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Helms",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_hlm)
										end)
									end
									if p.activate_hack_wea == nil then
										p.activate_hack_wea = "activate_hack_wea"
										p:addCustomButton("Weapons",p.activate_hack_wea,_("buttonWeapons","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Weapons",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_wea)
										end)
									end
									if p.activate_hack_eng == nil then
										p.activate_hack_eng = "activate_hack_eng"
										p:addCustomButton("Engineering",p.activate_hack_eng,_("buttonEngineering","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Engineering",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_eng)
										end)
									end
									if p.activate_hack_sci == nil then
										p.activate_hack_sci = "activate_hack_sci"
										p:addCustomButton("Science",p.activate_hack_sci,_("buttonScience","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Science",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_sci)
										end)
									end
									if p.activate_hack_rel == nil then
										p.activate_hack_rel = "activate_hack_rel"
										p:addCustomButton("Relay",p.activate_hack_rel,_("buttonRelay","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Relay",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_rel)
										end)
									end
									if p.activate_hack_tac == nil then
										p.activate_hack_tac = "activate_hack_tac"
										p:addCustomButton("Tactical",p.activate_hack_tac,_("buttonTactical","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Tactical",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_tac)
										end)
									end
									if p.activate_hack_ops == nil then
										p.activate_hack_ops = "activate_hack_ops"
										p:addCustomButton("Operations",p.activate_hack_ops,_("buttonOperations","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Operations",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_ops)
										end)
									end
									if p.activate_hack_epl == nil then
										p.activate_hack_epl = "activate_hack_epl"
										p:addCustomButton("Engineering+",p.activate_hack_epl,_("buttonEngineering+","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="Engineering+",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_epl)
										end)
									end
									if p.activate_hack_dmg == nil then
										p.activate_hack_dmg = "activate_hack_dmg"
										p:addCustomButton("DamageControl",p.activate_hack_dmg,_("buttonDamageControl","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="DamageControl",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_dmg)
										end)
									end
									if p.activate_hack_pwr == nil then
										p.activate_hack_pwr = "activate_hack_pwr"
										p:addCustomButton("PowerManagement",p.activate_hack_pwr,_("buttonPowerManagement","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="PowerManagement",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_pwr)
										end)
									end
									if p.activate_hack_map == nil then
										p.activate_hack_map = "activate_hack_map"
										p:addCustomButton("AltRelay",p.activate_hack_map,_("buttonStrategicMap","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="AltRelay",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_map)
										end)
									end
									if p.activate_hack_log == nil then
										p.activate_hack_log = "activate_hack_log"
										p:addCustomButton("ShipLog",p.activate_hack_log,_("buttonShipLog","Activate Hack"),function()
											string.format("")
											if p.activate_hack_times == nil then
												p.activate_hack_times = {}
											end
											table.insert(p.activate_hack_times,{console="ShipLog",time=getScenarioTime()})
											p:removeCustom(p.activate_hack_log)
										end)
									end
									--more synchro buttons here
									if p.activate_hack_times ~= nil and #p.activate_hack_times >= 3 then
										for j,aht in ipairs(p.activate_hack_times) do
											table.insert(activate_hack_times,aht)
										end
									end
								end
							end
--							if #activate_hack_times >= (player_ships_docked_count * 3) then
							if #activate_hack_times >= 3 then
								table.sort(activate_hack_times, function(a,b)
									return a.time < b.time
								end)
								local variance = math.abs(activate_hack_times[#activate_hack_times].time - activate_hack_times[1].time)
								print("Simultaneity variance:",variance)
								for i,p in ipairs(getActivePlayerShips()) do
									if p.activate_hack_hlm ~= nil then
										p:removeCustom(p.activate_hack_hlm)
										p.activate_hack_hlm = nil
									end
									if p.activate_hack_wea ~= nil then
										p:removeCustom(p.activate_hack_wea)
										p.activate_hack_wea = nil
									end
									if p.activate_hack_eng ~= nil then
										p:removeCustom(p.activate_hack_eng)
										p.activate_hack_eng = nil
									end
									if p.activate_hack_sci ~= nil then
										p:removeCustom(p.activate_hack_sci)
										p.activate_hack_sci = nil
									end
									if p.activate_hack_rel ~= nil then
										p:removeCustom(p.activate_hack_rel)
										p.activate_hack_rel = nil
									end
									if p.activate_hack_tac ~= nil then
										p:removeCustom(p.activate_hack_tac)
										p.activate_hack_tac = nil
									end
									if p.activate_hack_ops ~= nil then
										p:removeCustom(p.activate_hack_ops)
										p.activate_hack_ops = nil
									end
									if p.activate_hack_epl ~= nil then
										p:removeCustom(p.activate_hack_epl)
										p.activate_hack_epl = nil
									end
									if p.activate_hack_dmg ~= nil then
										p:removeCustom(p.activate_hack_dmg)
										p.activate_hack_dmg = nil
									end
									if p.activate_hack_pwr ~= nil then
										p:removeCustom(p.activate_hack_pwr)
										p.activate_hack_pwr = nil
									end
									if p.activate_hack_map ~= nil then
										p:removeCustom(p.activate_hack_map)
										p.activate_hack_map = nil
									end
									if p.activate_hack_log then
										p:removeCustom(p.activate_hack_log)
										p.activate_hack_log = nil
									end
									p.activate_hack_times = {}
								end
								if variance > 1 then
									for i,p in ipairs(getActivePlayerShips()) do
										if p.component_programmed then
											p:addToShipLog(_("goal-shipLog","Hack activation was not simulataneous. Variance exceeded one second. The component needs to be reprogrammed for another attempt to activate the hack simulataneously."),"Yellow")
											p.component_programmed = false
											p:addCustomButton("Relay",p.program_component_rel,_("buttonRelay","Program Component"),function()
												string.format("")
												programComponent(p)
											end)
											p:addCustomButton("Operations",p.program_component_ops,_("buttonOperations","Program Component"),function()
												string.format("")
												programComponent(p)
											end)
										end
									end
									local wj = nil
									local select_wj_count = 0
									repeat
										wj = tableSelectRandom(warp_jammer_ring)
										select_wj_count = select_wj_count + 1
									until(not tableSelectRandom(warp_jammer_ring).trigger or select_wj_count > max_repeat_loop)
									local wj_x, wj_y = wj:getPosition()
									local fleet = spawnRandomArmed(wj_x,wj_y)
									for i,ship in ipairs(fleet) do
--										ship:setPosition(wj_x,wj_y)
										ship:orderDefendTarget(target_station)
									end
								else
									for i,p in ipairs(getActivePlayerShips()) do
										p:setCanDock(true)
										p:addToShipLog(string.format(_("goal-shipLog","%s has been returned to Independent control. The docking clamps no longer restrain %s."),target_station:getCallSign(),p:getCallSign()),"Magenta")
									end
									switch_to_independent = true
									if target_station:getFaction() == "Kraylor" then
										target_station:setFaction("Independent")
									end
								end
							end
						end
					end
				end
			else
				for i,p in ipairs(getActivePlayerShips()) do
					if p.iff_switch_time ~= nil then
						if getScenarioTime() > p.iff_switch_time then
							switch_to_kraylor = true
						end
					end
				end
			end
		end
	else
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","Rescue the exotic weapons research scientist AND preserve the research.\n%s"),msg))
		victory("Kraylor")
	end
	missionMaintenance = approachBarrier
end
function informEngineering(p)
	string.format("")
	p:removeCustom(p.inform_engineering_button_sci)
	p:removeCustom(p.inform_engineering_button_ops)
	p:addCustomMessage("Engineering","fabricate_component_message_eng",string.format(_("msgEngineering","Science just sent you the details on what is required to interface with station %s to switch the systems back to Independent control. You will need to fabricate a component to attach to the docking clamp."),target_station:getCallSign()))
	p:addCustomMessage("Engineering+","fabricate_component_message_epl",string.format(_("msgEngineering+","Science just sent you the details on what is required to interface with station %s to switch the systems back to Independent control. You will need to fabricate a component to attach to the docking clamp."),target_station:getCallSign()))
	p.fabricate_component_eng = "fabricate_component_eng"
	p:addCustomButton("Engineering",p.fabricate_component_eng,_("buttonEngineering","Fabricate Component"),function()
		string.format("")
		fabricateComponent(p)
	end)
	p.fabricate_component_epl = "fabricate_component_epl"
	p:addCustomButton("Engineering+",p.fabricate_component_epl,_("buttonEngineering+","Fabricate Component"),function()
		string.format("")
		fabricateComponent(p)
	end)
end
function informRelay(p)
	string.format("")
	p:removeCustom(p.inform_relay_button_sci)
	p:removeCustom(p.inform_relay_button_ops)
	p:addCustomMessage("Relay","program_component_message_rel",string.format(_("msgRelay","Science just sent you the details on what is required to interface with station %s to switch the systems back to Independent control. You will need to program the component to hack the systems when it interfaces to the station through the docking clamp."),target_station:getCallSign()))
	p:addCustomMessage("Operations","program_component_message_ops",string.format(_("msgRelay","Science just sent you the details on what is required to interface with station %s to switch the systems back to Independent control. You will need to program the component to hack the systems when it interfaces to the station through the docking clamp."),target_station:getCallSign()))
	p.program_component_rel = "program_component_rel"
	p:addCustomButton("Relay",p.program_component_rel,_("buttonRelay","Program Component"),function()
		string.format("")
		programComponent(p)
	end)
	p.program_component_ops = "program_component_ops"
	p:addCustomButton("Operations",p.program_component_ops,_("buttonOperations","Program Component"),function()
		string.format("")
		programComponent(p)
	end)
end
function fabricateComponent(p)
	string.format("")
	p.component_fabricated = true
	p:removeCustom(p.fabricate_component_eng)
	p:removeCustom(p.fabricate_component_epl)
end
function programComponent(p)
	string.format("")
	p.component_programmed = true
	p:removeCustom(p.program_component_rel)
	p:removeCustom(p.program_component_ops)
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
--	Messaging
function scenarioShipEnhancements()
	if comms_source.probe_upgrade == nil then
		addCommsReply(_("upgrade-comms","Check on probe capacity upgrade availability"),function()
			setCommsMessage(_("upgrade-comms","Our scan probe system specialist, Felix Heavier, has been experimenting with probe storage systems and has some potential upgrades available."))
			if comms_target.probe_storage_upgrades == nil then
				comms_target.probe_storage_upgrades = {
					{bump = 6,	power = 1},
					{bump = 8,	power = .9},
					{bump = 12,	power = .8},
				}
			end
			addCommsReply(_("upgrade-comms","Tell me about the Tetris Mark 4 probe storage upgrade"),function()
				if comms_target.tetris == nil then
					comms_target.tetris = tableRemoveRandom(comms_target.probe_storage_upgrades)
				end
				if comms_target.tetris.power == 1 then
					setCommsMessage(string.format(_("upgrade-comms","The Tetris Mark 4 probe storage upgrade increases your probe storage capacity by %i"),comms_target.tetris.bump))
				else
					setCommsMessage(string.format(_("upgrade-comms","The Tetris Mark 4 probe storage upgrade increases your probe storage capacity by %i but reduces your battery capacity to %i."),comms_target.tetris.bump,math.floor(comms_target.tetris.power * comms_source:getMaxEnergy())))
				end
				addCommsReply(_("upgrade-comms","Please install the Tetris Mark 4 probe storage upgrade"),function()
					comms_source.probe_upgrade = true
					comms_source:setMaxScanProbeCount(comms_source:getMaxScanProbeCount() + comms_target.tetris.bump)
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*comms_target.tetris.power)
					setCommsMessage(_("upgrade-comms","Felix installed the Tetris Mark 4 probe storage upgrade."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Tell me about the Jenga VI probe storage upgrade"),function()
				if comms_target.jenga == nil then
					comms_target.jenga = tableRemoveRandom(comms_target.probe_storage_upgrades)
				end
				if comms_target.jenga.power == 1 then
					setCommsMessage(string.format(_("upgrade-comms","The Jenga VI probe storage upgrade increases your probe storage capacity by %i"),comms_target.jenga.bump))
				else
					setCommsMessage(string.format(_("upgrade-comms","The Jenga VI probe storage upgrade increases your probe storage capacity by %i but reduces your battery capacity to %i."),comms_target.jenga.bump,math.floor(comms_target.jenga.power * comms_source:getMaxEnergy())))
				end
				addCommsReply(_("upgrade-comms","Please install the Jenga VI probe storage upgrade"),function()
					comms_source.probe_upgrade = true
					comms_source:setMaxScanProbeCount(comms_source:getMaxScanProbeCount() + comms_target.jenga.bump)
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*comms_target.jenga.power)
					setCommsMessage(_("upgrade-comms","Felix installed the Jenga VI probe storage upgrade."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Tell me about the Ikea Mea 3 probe storage upgrade"),function()
				if comms_target.ikea == nil then
					comms_target.ikea = tableRemoveRandom(comms_target.probe_storage_upgrades)
				end
				if comms_target.ikea.power == 1 then
					setCommsMessage(string.format(_("upgrade-comms","The Ikea Mea 3 probe storage upgrade increases your probe storage capacity by %i"),comms_target.ikea.bump))
				else
					setCommsMessage(string.format(_("upgrade-comms","The Ikea Mea 3 probe storage upgrade increases your probe storage capacity by %i but reduces your battery capacity to %i."),comms_target.ikea.bump,math.floor(comms_target.ikea.power * comms_source:getMaxEnergy())))
				end
				addCommsReply(_("upgrade-comms","Please install the Ikea Mea 3 probe storage upgrade"),function()
					comms_source.probe_upgrade = true
					comms_source:setMaxScanProbeCount(comms_source:getMaxScanProbeCount() + comms_target.ikea.bump)
					comms_source:setMaxEnergy(comms_source:getMaxEnergy()*comms_target.ikea.power)
					setCommsMessage(_("upgrade-comms","Felix installed the Ikea Mea 3 probe storage upgrade."))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
	if not comms_source.sensor_upgrade then
		addCommsReply(_("upgrade-comms","Check on long range sensor upgrade availability"),function()
			setCommsMessage(string.format(_("upgrade-comms","Our quartermaster, Sylvia Trondheim, has several spare long range sensor upgrade packages. They were scheduled to be installed on exploration vessels coming into the region, but those exploration missions were cancelled or repurposed. She's willing to install one on %s"),comms_source:getCallSign()))
			if comms_target.sensor_upgrades == nil then
				comms_target.sensor_upgrades = {
					{long = 40000, short = 5000},
					{long = 50000, short = 4500},
					{long = 60000, short = 4000},
				}
			end
			addCommsReply(_("upgrade-comms","Tell me about the Richter version 7 sensor upgrade."),function()
				if comms_target.richter == nil then
					comms_target.richter = tableRemoveRandom(comms_target.sensor_upgrades)
				end
				if comms_target.richter.long > comms_source.normal_long_range_radar then
					setCommsMessage(string.format(_("upgrade-comms","The Richter version 7 sets your long range sensor range to %i units and your short range sensor range to %.1f units."),comms_target.richter.long/1000,comms_target.richter.short/1000))
					addCommsReply(_("upgrade-comms","Please install the Richter version 7 sensor upgrade"),function()
						comms_source.sensor_upgrade = true
						comms_source.normal_long_range_radar = comms_target.richter.long
						comms_source.normal_short_range_radar = comms_target.richter.short
						comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar)
						comms_source:setShortRangeRadarRange(comms_source.normal_short_range_radar)
						setCommsMessage(_("upgrade-comms","Sylvia has installed the Richter version 7 sensor upgrade"))
						addCommsReply(_("Back"), commsStation)
					end)
				else
					setCommsMessage(_("upgrade-comms","The Richter version 7 would not add any sensor range benefit"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","What about the Omniscient Mark 4 sensor upgrade?"),function()
				if comms_target.omniscient == nil then
					comms_target.omniscient = tableRemoveRandom(comms_target.sensor_upgrades)
				end
				if comms_target.omniscient.long > comms_source.normal_long_range_radar then
					setCommsMessage(string.format(_("upgrade-comms","The Omniscient Mark 4 sets your long range sensor range to %i units and your short range sensor range to %.1f units."),comms_target.omniscient.long/1000,comms_target.omniscient.short/1000))
					addCommsReply(_("upgrade-comms","Please install the Omniscient Mark 4 sensor upgrade"),function()
						comms_source.sensor_upgrade = true
						comms_source.normal_long_range_radar = comms_target.omniscient.long
						comms_source.normal_short_range_radar = comms_target.omniscient.short
						comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar)
						comms_source:setShortRangeRadarRange(comms_source.normal_short_range_radar)
						setCommsMessage(_("upgrade-comms","Sylvia has installed the Omniscient Mark 4 sensor upgrade"))
						addCommsReply(_("Back"), commsStation)
					end)
				else
					setCommsMessage(_("upgrade-comms","The Omniscient Mark 4 would not add any sensor range benefit"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("upgrade-comms","Please provide details on the Voriax II sensor upgrade."),function()
				if comms_target.voriax == nil then
					comms_target.voriax = tableRemoveRandom(comms_target.sensor_upgrades)
				end
				if comms_target.voriax.long > comms_source.normal_long_range_radar then
					setCommsMessage(string.format(_("upgrade-comms","The Voriax II sets your long range sensor range to %i units and your short range sensor range to %.1f units."),comms_target.voriax.long/1000,comms_target.voriax.short/1000))
					addCommsReply(_("upgrade-comms","Please install the Voriax II sensor upgrade"),function()
						comms_source.sensor_upgrade = true
						comms_source.normal_long_range_radar = comms_target.voriax.long
						comms_source.normal_short_range_radar = comms_target.voriax.short
						comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar)
						comms_source:setShortRangeRadarRange(comms_source.normal_short_range_radar)
						setCommsMessage(_("upgrade-comms","Sylvia has installed the Voriax II sensor upgrade"))
						addCommsReply(_("Back"), commsStation)
					end)
				else
					setCommsMessage(_("upgrade-comms","The Voriax II would not add any sensor range benefit"))
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function scenarioInformation()
	if comms_target.station_knowledge ~= nil then
		addCommsReply("What do you know about stations around here?",function()
			setCommsMessage(comms_target.station_knowledge)
			addCommsReply(_("Back"), commsStation)
		end)
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
		addCommsReply(_("orders-comms","Get background on Hans Gestalt"),function()
			setCommsMessage(string.format(_("orders-comms","Hans Gestalt is a noted exotic weapons research scientist. For years, several factions have tried to enlist or convert him so that they could be the sole beneficiary of his research and thus gain an advantage over enemy factions. He always refuses. He remains independent and sells his research to any faction except for the Exuari (who usually just steal it after it's sold). Needless to say, he's rich. This time, though, the Kraylor have insidiously put barriers on Independent station %s to prevent Hans Gestalt from interacting with any other faction. He's being held against his will in his own research facilities. He managed to communicate with us to indicate that he needs rescuing. We also believe that the Kraylor have put up a barrier around %s to prevent any rescue attempt."),target_station:getCallSign(),target_station:getCallSign()))
			addCommsReply(_("Back"), commsStation)
		end)
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
function finalStats()
	local final_message = ""
	if deployed_player_count > 1 then
		final_message = string.format(_("msgMainscreen","%s\nDeployed %s player ships."),final_message,deployed_player_count)
	else
		final_message = string.format(_("msgMainscreen","%s\nDeployed one player ship."),final_message)
	end
	if scientist_aboard then
		final_message = string.format(_("msgMainscreen","%s\nScientist retrieved from station."),final_message)
	end
	final_message = string.format(_("msgMainscreen","%s\nTime spent in scenario: %s"),final_message,formatTime(getScenarioTime()))
	final_message = string.format(_("msgMainscreen","%s\nEnemies:%s Murphy:%s"),final_message,getScenarioSetting("Enemies"),getScenarioSetting("Murphy"))
	return final_message
end
--	General
function update(delta)
	if delta == 0 then
		if deployed_players ~= nil then
			for i,dp in ipairs(deployed_players) do
				for j,p in ipairs(getActivePlayerShips()) do
					if p == dp.p then
						dp.name = p:getCallSign()
					end
				end
			end
		end
		return	--because the scenario is paused
	end
	for i,p in ipairs(getActivePlayerShips()) do
		updatePlayerLongRangeSensors(delta,p)
		local name_banner = string.format(_("nameSector-tabRelay&Ops&Helm&Tactical","%s in %s"),p:getCallSign(),p:getSectorName())
		p.name_banner_rel = "name_banner_rel"
		p:addCustomInfo("Relay",p.name_banner_rel,name_banner,1)
		p.name_banner_ops = "name_banner_ops"
		p:addCustomInfo("Operations",p.name_banner_ops,name_banner,1)
		p.name_banner_hlm = "name_banner_hlm"
		p:addCustomInfo("Helms",p.name_banner_hlm,name_banner,1)
		p.name_banner_tac = "name_banner_tac"
		p:addCustomInfo("Tactical",p.name_banner_tac,name_banner,1)
	end
	if missionMaintenance ~= nil then
		missionMaintenance()
	end
	if home_station ~= nil and home_station:isValid() then
		for i,p in ipairs(getActivePlayerShips()) do
			if p.scientist_aboard and p:isDocked(home_station) then
				local msg = finalStats()
				globalMessage(string.format(_("msgMainscreen","You rescued Hans Gestalt. Congratulations!\n%s"),msg))
				victory("Human Navy")
			end
		end
	else
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","Rescue the exotic weapons research scientist AND preserve your home station.\n%s"),msg))
		victory("Kraylor")
	end
	if #getActivePlayerShips() == 0 then
		local msg = finalStats()
		globalMessage(string.format(_("msgMainscreen","All available player ships destroyed.\n%s"),msg))
		victory("Kraylor")		
	end
end