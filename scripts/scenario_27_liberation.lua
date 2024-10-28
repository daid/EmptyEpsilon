-- Name: Liberation Day
-- Description: Let's celebrate Liberation Day, when we humans finally freed ourselves from Kraylor occupation! Wait, I wonder how the Exuari celebrate Liberation day. Do they even recognize such a human-centric holiday?
---
--- Designed for one or more player ships. The terrain differs slightly every time the scenario is run. Default length: 30 minutes. May be shortened to 15 minutes or lengthened to an hour.
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's usually one every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Author: Xansta
-- Setting[First]: Configures how long until the first major event occurs. The default is ten minutes. Shorter is harder. Longer is easier.
-- First[Seconds]: Ten seconds until the first major event occurs. This is used mainly for testing.
-- First[Five]: Five minutes until the first major event occurs.
-- First[Ten|Default]: Ten minutes until the first major event occurs.
-- First[Fifteen]: Fifteen minutes until the first major event occurs.
-- First[Twenty]: Twenty minutes until the first major event occurs.
-- Setting[Enemies]: Configures strength and/or number of enemies in this scenario
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal|Default]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Second]: Configures how long between the first event and the second event. The default is ten minutes. Shorter is harder. Longer is easier.
-- Second[Seconds]: Ten seconds between the first event and the second event. This is used mainly for testing.
-- Second[One]: One minute between the first event and the second event (test)
-- Second[Five]: Five minutes between the first event and the second event.
-- Second[Ten|Default]: Ten minutes between the first event and the second event.
-- Second[Fifteen]: Fifteen minutes between the first event and the second event.
-- Second[Twenty]: Twenty minutes between the first event and the second event.
-- Setting[Third]: Configures how long between the 2nd and 3rd events. Default: 10. Combining 1st, 2nd and 3rd gives you overall scenario length (30 - 60 minutes).
-- Third[Seconds]: Ten seconds between 2nd and 3rd events. Mainly used for testing.
-- Third[Five]: Five minutes between the 2nd and 3rd events.
-- Third[Ten|Default]: Ten minutes between the 2nd and 3rd events.
-- Third[Fifteen]: Fifteen minutes between the 2nd and 3rd events.
-- Third[Twenty]: Twenty minutes between the 2nd and 3rd events.
-- Setting[Cloak]: Degree of device cloaking mechanism
-- Cloak[None]: Device is not cloaked
-- Cloak[Partial|Default]: Device is partially cloaked
-- Cloak[Strong]: Device is mostly cloaked
-- Cloak[Full]: Device is cloaked (but it's not perfect)


---- Leftover configuration options from testing
-- First[Seconds]: Ten seconds until the first major event occurs. This is used mainly for testing.
-- Second[Seconds]: Ten seconds between the first event and the second event. This is used mainly for testing.
-- Second[One]: One minute between the first event and the second event (test)
-- Third[Seconds]: Ten seconds between 2nd and 3rd events. Mainly used for testing.
-- Cloak[None]: Device is not cloaked


require("utils.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("player_ship_upgrade_downgrade_path_scenario_utility.lua")
require("spawn_ships_scenario_utility.lua")
require("comms_scenario_utility.lua")

--	Initialization routines
function init()
	scenario_version = "1.0.0"
	ee_version = "2024.08.09"
	print(string.format("    ----    Scenario: Liberation Day    ----    Version %s    ----    Tested with EE version %s    ----",scenario_version,ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	spawn_enemy_diagnostic = false
	control_code_diagnostic = false
	setVariations()
	setConstants()
	setGlobals()
	mainGMButtons()
	constructEnvironment()
	onNewPlayerShip(setPlayers)
end
function setPlayers()
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			updatePlayerSoftTemplate(p)
		end
		local already_recorded = false
		for j,dp in ipairs(deployed_players) do
			if p == dp.p then
				already_recorded = true
				break
			end
		end
		if not already_recorded then
			table.insert(deployed_players,{p=p,name=p:getCallSign(),count=1})
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
	p:onDestroyed(playerDestroyed)
	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
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
					player_ship_name = tableRemoveRandom(player_ship_names_for["Leftovers"])
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
	local system_types = {"reactor","beamweapons","missilesystem","maneuver","impulse","warp","jumpdrive","frontshield","rearshield"}
	p.normal_coolant_rate = {}
	p.normal_power_rate = {}
	for _, system in ipairs(system_types) do
		p.normal_coolant_rate[system] = p:getSystemCoolantRate(system)
		p.normal_power_rate[system] = p:getSystemPowerRate(system)
	end
end
function setVariations()
	local nova_config = {
		["Seconds"] =	10,
		["Five"] =		5*60,
		["Ten"] =		10*60,
		["Fifteen"] =	15*60,
		["Twenty"] =	20*60,
	}
	nova_delay = nova_config[getScenarioSetting("First")]
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local hunt_config = {
		["Seconds"] =	10,
		["One"] =		60,
		["Five"] =		5*60,
		["Ten"] =		10*60,
		["Fifteen"] =	15*60,
		["Twenty"] =	20*60,
	}
	hunt_delay = hunt_config[getScenarioSetting("Second")]
	hunt_time = hunt_delay + nova_delay
	local final_nova_config = {
		["Seconds"] =	10,
		["One"] =		60,
		["Five"] =		5*60,
		["Ten"] =		10*60,
		["Fifteen"] =	15*60,
		["Twenty"] =	20*60,
	}
	final_nova_delay = final_nova_config[getScenarioSetting("Third")]
	final_nova_time = final_nova_delay + hunt_time
	local cloak_config = {
		["None"] =		-1,
		["Partial"] =	8,
		["Strong"] =	20,
		["Full"] =		0,
	}
	cloak_level = cloak_config[getScenarioSetting("Cloak")]
end
function setConstants()	--variables that don't change
	max_repeat_loop = 50
	sensor_impact = 1	--normal
	sensor_jammer_power_units = false	--false means percentage, true is units
	system_list = {
		"reactor",
		"beamweapons",
		"missilesystem",
		"maneuver",
		"impulse",
		"warp",
		"jumpdrive",
		"frontshield",
		"rearshield",
	}
	station_spacing = {
		["Small Station"] =		{touch = 300,	defend = 2600,	platform = 600,		outer_platform = 7500},
		["Medium Station"] =	{touch = 1200,	defend = 4000,	platform = 2400,	outer_platform = 9100},
		["Large Station"] =		{touch = 1400,	defend = 4600,	platform = 2800,	outer_platform = 9700},
		["Huge Station"] =		{touch = 2000,	defend = 4960,	platform = 3500,	outer_platform = 10100},
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
		["warper"] = "Warpers",
		["Warpers"] = "warper",
		["jumper"] = "Jumpers",
		["Jumpers"] = "jumper",
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
	max_pyramid_tier = 15	
	ship_template = {	--ordered by relative strength
		-- normal ships that are part of the fleet spawn process
		["Gnat"] =				{strength = 2,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true,		drone = true,	unusual = false,	base = false,	short_range_radar = 4500,	hop_angle = 0,	hop_range = 580,	create = gnat},
		["Lite Drone"] =		{strength = 3,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = stockTemplate},
		["Dagger"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = hornetMV52},
		["MT55 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 680,	create = hornetMT55},
		["Adder MK4"] =			{strength = 6,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Shepherd"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2880,	create = shepherd},
		["Ktlitan Fighter"] =	{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Touchy"] =			{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 2000,	create = touchy},
		["Blade"] =				{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Gunner"] =			{strength = 7,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = k3fighter},
		["Shooter"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Jagger"] =			{strength = 8,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adder MK6"] =			{strength = 8,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 2500,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
--		["Brush"] =				{strength = 10,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = brush},
		["Adder MK8"] =			{strength = 10,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = waddle5},
		["Jade 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = jade5},
		["Phobos T3"] =			{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Guard"] =				{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco3},
		["Farco 5"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1180,	create = farco5},
		["Gunship"] =			{strength = 17,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Phobos T4"] =			{strength = 18,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = phobosT4},
		["Cruiser"] =			{strength = 18,	adder = true,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Farco 8"] =			{strength = 19,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco8},
		["Nirvana R5A"] =		{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 90,	hop_range = 580,	create = stockTemplate},
		["Farco 11"] =			{strength = 21,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = farco11},
		["Storm"] =				{strength = 22,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Warden"] =			{strength = 22,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Racer"] =				{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Strike"] =			{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Dash"] =				{strength = 23,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Farco 13"] =			{strength = 24,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = farco13},
		["Sentinel"] =			{strength = 24,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1180,	create = stockTemplate},
		["Ranus U"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Flash"] =				{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Ranger"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Buster"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 2500,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Whirlwind"] =			{strength = 26,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = whirlwind},
		["Hunter"] =			{strength = 26,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Elara P2"] =			{strength = 28,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 90,	hop_range = 2500,	create = tempest},
		["Strikeship"] =		{strength = 30,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Maniapak"] =			{strength = 34,	adder = true,	missiler = false,	beamer = false,	frigate = false, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 0,	hop_range = 580,	create = maniapak},
		["Fiend G4"] =			{strength = 35,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Cucaracha"] =			{strength = 36,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 1480,	create = cucaracha},
		["Fiend G5"] =			{strength = 37,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Fiend G6"] =			{strength = 39,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = true,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Barracuda"] =			{strength = 40,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 1180,	create = barracuda},
		["Ryder"] =				{strength = 41, adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 8000,	hop_angle = 90,	hop_range = 1180,	create = stockTemplate},
		["Predator"] =			{strength = 42,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 7500,	hop_angle = 0,	hop_range = 980,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = stockTemplate},
		["Hurricane"] =			{strength = 46,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 6000,	hop_angle = 15,	hop_range = 2500,	create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 580,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5000,	hop_angle = 0,	hop_range = 780,	create = k2breaker},
		["Atlantis Y42"] =		{strength = 60,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 63,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 5500,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 10000,	hop_angle = 0,	hop_range = 1480,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 1480,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 0,	hop_range = 980,	create = stockTemplate},
		["Starhammer III"] =	{strength = 85,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 12000,	hop_angle = 0,	hop_range = 1480,	create = starhammerIII},
		["Starhammer V"] =		{strength = 90,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 15000,	hop_angle = 0,	hop_range = 1480,	create = starhammerV},
		["Battlestation"] =		{strength = 100,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2480,	create = stockTemplate},
		["Fortress"] =			{strength = 130,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	warper = false,	jumper = false,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9000,	hop_angle = 90,	hop_range = 2380,	create = stockTemplate},
		["Tyr"] =				{strength = 150,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 9500,	hop_angle = 90,	hop_range = 2480,	create = tyr},
		["Odin"] =				{strength = 250,adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	warper = false,	jumper = true,	fighter = false,	drone = false,	unusual = false,	base = false,	short_range_radar = 20000,	hop_angle = 0,	hop_range = 3180,	create = stockTemplate},
	}
	for template,details in pairs(ship_template) do
		if details.create == nil then
			print(template,"has no create function")
		end
	end
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
	faction_letter = {
		["Human Navy"] = "H",
		["Independent"] = "I",
		["Kraylor"] = "K",
		["Ktlitans"] = "B",
		["Exuari"] = "E",
		["Ghosts"] = "G",
		["Arlenians"] = "A",
		["TSN"] = "T",
		["CUF"] = "C",
		["USN"] = "U",
	}
end
function setGlobals()	--variables that might change
	mid_fleet_launched = false
	inner_stations = {}
	outer_stations = {}
	initial_transport_count = 10
	final_nova_artifact_created = false
	ejecta = {}
	process_ejecta = false
	reset_nova_process = false
	nova_beam_targets = {}
	jasmine_purdue_hint = false
	jasmine_purdue_answers = {
		"She studies the Exuari. She's *the* expert around here",
		"She studies the Exuari so hard that sometimes I wonder if she's got some kind of fixation.",
		"I heard that her family was killed by the Exuari. That's why she studies them so much.",
		"After studying the Exuari using our extensive resources, she took a job on a freighter to gather more data in the field.",
	}
	jasmine_freighter_hint = false
	jasmine_freighter_identified = false
	reputation_start_amount = 50
	deployed_players = {}
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
				red = random(0.8,1), green = random(0.8,1), blue = random(0.8,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}
	moon_list = {
		{
			name = {"Ganymede", "Europa", "Deimos", "Luna"},
			texture = {
				surface = "planets/moon-1.png"
			}
		},
		{
			name = {"Myopia", "Zapata", "Lichen", "Fandango"},
			texture = {
				surface = "planets/moon-2.png"
			}
		},
		{
			name = {"Scratmat", "Tipple", "Dranken", "Calypso"},
			texture = {
				surface = "planets/moon-3.png"
			}
		},
	}
	planet_list = {
		{
			name = {"Bespin","Aldea","Bersallis"},
			texture = {
				surface = "planets/gas-1.png"
			},
		},
		{
			name = {"Farius Prime","Deneb","Mordan"},
			texture = {
				surface = "planets/gas-2.png"
			},
		},
		{
			name = {"Kepler-7b","Alpha Omicron","Nelvana"},
			texture = {
				surface = "planets/gas-3.png"
			},
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
		},
	}
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(_("buttonGM","+Spawn Ship(s)"),spawnGMShips)
end
function constructEnvironment()
--	set player faction and friendly factions
	player_factions = {"Human Navy","CUF","USN","TSN"}
	player_faction = tableSelectRandom(player_factions)
	friendly_factions = {"Human Navy"}
	if player_faction == "Human Navy" then
		friendly_factions = {"CUF","USN","TSN"}
	end
	tpa = Artifact():setFaction(player_faction)	--temporary player artifact
	tsa = Artifact()	--temporary station artifact
	player_spawn_x = random(200000,800000)
	player_spawn_y = random(1000000,2000000)
	inner_space = {}
	outer_space = {}
	connecting_space = {}
	rescue_inner_space = {}
	rescue_inner_ring_space = {}
	rescue_outer_ring_space = {}
	table.insert(inner_space,{obj=VisualAsteroid():setPosition(player_spawn_x,player_spawn_y),dist=2000,shape="circle"})
	constructDoomedBodiesAndStation()
	connection_angle = random(0,360)
	constructRescueBodies()
	constructMinorEnemyTrap()
	constructOuterDoomedStations()
	constructConnectingStations()
	constructRescueStations()
	constructNemesisStation()
--	set terrain in the doomed circle
	placement_areas = {
		["Doomed Ring"] = {
			stations = outer_stations,
			space = outer_space,
			shape = "torus",
			center_x = doomed_system_x, 
			center_y = doomed_system_y, 
			inner_radius = 35000, 
			outer_radius = 60000
		},
		["Doomed Circle"] = {
			stations = inner_stations, 
			space = inner_space,
			shape = "circle", 
			center_x = doomed_system_x, 
			center_y = doomed_system_y, 
			radius = 15000
		},
	}
	transport_list = {}
	local terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	local objects_placed_count = 0
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Doomed Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Doomed Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Doomed Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 20)
--	set terrain just outside the doomed circle
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeBlackHole,		desc = "Black hole",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 4,	count = 0,	max = 10,					func = placeTransport,		desc = "Transport",			},	--13
		{chance = 5,	count = 0,	max = math.random(2,15),	func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	objects_placed_count = 0
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Doomed Ring")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Doomed Ring")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Doomed Ring")
			end
		end
		objects_placed_count = objects_placed_count + 1
		if objects_placed_count >= 100 then
			for i,ter in ipairs(terrain) do
				if ter.desc == "Transport" then
					ter.chance = 20
					break
				end
			end
		end 
	until(objects_placed_count >= 100 and #transport_list >= 10)
--	set terrain in connecting area
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeBlackHole,		desc = "Black hole",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 4,	count = 0,	max = 10,					func = placeTransport,		desc = "Transport",			},	--13
		{chance = 5,	count = 0,	max = math.random(2,15),	func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	objects_placed_count = 0
	placement_areas["Connecting Square"] = {
		stations = outer_stations,
		space = connecting_space,
		shape = "central rectangle",
		center_x = connecting_space_x,
		center_y = connecting_space_y,
		width = 40000,
		height = 40000,
	}
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Connecting Square")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Connecting Square")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Connecting Square")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 20)
--	set terrain in the rescue circle
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 5,	count = 0,	max = math.random(2,5),		func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,5),		func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	objects_placed_count = 0
	placement_areas["Rescue Circle"] = {
		stations = outer_stations,
		space = rescue_inner_space,
		shape = "circle",
		center_x = rescue_system_x,
		center_y = rescue_system_y,
		radius = 12000,
	}
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Rescue Circle")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Rescue Circle")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Rescue Circle")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 18)
--	set terrain in the area just outside the rescue circle
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 4,	count = 0,	max = 10,					func = placeTransport,		desc = "Transport",			},	--13
		{chance = 5,	count = 0,	max = math.random(2,15),	func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	objects_placed_count = 0
	placement_areas["Rescue Inner Ring"] = {
		stations = outer_stations,
		space = rescue_inner_ring_space,
		shape = "torus",
		center_x = rescue_system_x,
		center_y = rescue_system_y,
		inner_radius = 27000,
		outer_radius = 51000,
	}
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Rescue Inner Ring")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Rescue Inner Ring")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Rescue Inner Ring")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 50)
--	set terrain in the outer rescue ring
	terrain = {
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeStar,			desc = "Star",				},	--2
		{chance = 4,	count = 0,	max = math.random(1,2),		func = placeBlackHole,		desc = "Black hole",		},	--2
		{chance = 7,	count = 0,	max = -1,					func = placeProbe,			desc = "Probe",				},	--3
		{chance = 4,	count = 0,	max = math.random(7,15),	func = placeWarpJammer,		desc = "Warp jammer",		},	--4
--		{chance = 3,	count = 0,	max = math.random(2,9),		func = placeWormHole,		desc = "Worm hole",			},	--5
		{chance = 7,	count = 0,	max = math.random(6,15),	func = placeSensorJammer,	desc = "Sensor jammer",		},	--6
		{chance = 7,	count = 0,	max = -1,					func = placeSensorBuoy,		desc = "Sensor buoy",		},	--7
		{chance = 9,	count = 0,	max = -1,					func = placeAdBuoy,			desc = "Ad buoy",			},	--8
		{chance = 8,	count = 0,	max = -1,					func = placeNebula,			desc = "Nebula",			},	--9
		{chance = 5,	count = 0,	max = -1,					func = placeMine,			desc = "Mine",				},	--10
		{chance = 5,	count = 0,	max = math.random(3,9),		func = placeMineField,		desc = "Mine field",		},	--11
		{chance = 4,	count = 0,	max = 10,					func = placeTransport,		desc = "Transport",			},	--13
		{chance = 5,	count = 0,	max = math.random(2,15),	func = placeAsteroidField,	desc = "Asteroid field",	},	--12
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeAsteroidBlob,	desc = "Asteroid blob",		},	--14
		{chance = 6,	count = 0,	max = math.random(2,15),	func = placeMinefieldBlob,	desc = "Minefield blob",	},	--15
	}
	objects_placed_count = 0
	placement_areas["Rescue Outer Ring"] = {
		stations = outer_stations,
		space = rescue_outer_ring_space,
		shape = "torus",
		center_x = rescue_system_x,
		center_y = rescue_system_y,
		inner_radius = 70000,
		outer_radius = 100000,
	}
	repeat
		local roll = random(0,100)
		local object_chance = 0
		for i,terrain_object in ipairs(terrain) do
			object_chance = object_chance + terrain_object.chance
			if roll <= object_chance then
				if terrain_object.max < 0 or terrain_object.count < terrain_object.max then
					local call_function = terrain_object.func
					local placement_result = call_function("Rescue Outer Ring")
					if placement_result then
						terrain_object.count = terrain_object.count + 1
					end
				else
					placeAsteroid("Rescue Outer Ring")
				end
				break
			elseif i == #terrain then
				placeAsteroid("Rescue Outer Ring")
			end
		end
		objects_placed_count = objects_placed_count + 1
	until(objects_placed_count >= 100)
	constructNovaDemo()
	tpa:destroy()
	tsa:destroy()
end
function constructRescueBodies()
	--	80k to center of connection area
	rescue_system_x, rescue_system_y = vectorFromAngleNorth(connection_angle,200000)
	rescue_system_x = rescue_system_x + doomed_system_x
	rescue_system_y = rescue_system_y + doomed_system_y
--	set rescue star
	rescue_star_radius = random(600,2400)
	original_rescue_star_radius = rescue_star_radius
	rescue_star = Planet():setPosition(rescue_system_x, rescue_system_y):setPlanetRadius(rescue_star_radius)
	rescue_star:setCallSign(tableRemoveRandom(star_list[1].name))
	rescue_star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere)
	rescue_star:setPlanetAtmosphereColor(star_list[1].color.red,star_list[1].color.green,star_list[1].color.blue)
	rescue_star.check_boom = true
	table.insert(rescue_inner_space,{obj=rescue_star,dist=rescue_star_radius + 1000,shape="circle"})
--	set inner rescue planet
	local inner_planet_angle = random(0,360)
	local inner_rescue_planet_x, inner_rescue_planet_y = vectorFromAngleNorth(inner_planet_angle,20000)
	inner_rescue_planet_x = inner_rescue_planet_x + rescue_system_x
	inner_rescue_planet_y = inner_rescue_planet_y + rescue_system_y
	local selected_planet = tableRemoveRandom(habitable_planet_pool)
	inner_rescue_planet = Planet():setPlanetRadius(3000)
	inner_rescue_planet:setPosition(inner_rescue_planet_x, inner_rescue_planet_y)
	inner_rescue_planet:setDistanceFromMovementPlane(-700)
	inner_rescue_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
	inner_rescue_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
	inner_rescue_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
	inner_rescue_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
	inner_rescue_planet:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
	inner_rescue_planet.check_boom = true
	inner_rescue_planet:setAxialRotationTime(random(350,500))
	inner_rescue_planet:setOrbit(rescue_star,1100)	--proposed final: 1100
--	set outer rescue planet
	local outer_rescue_angle = (inner_planet_angle + random(-135,135) + 360) % 360
	local outer_rescue_planet_x, outer_rescue_planet_y = vectorFromAngleNorth(outer_rescue_angle,60000)
	outer_rescue_planet_x = outer_rescue_planet_x + rescue_system_x
	outer_rescue_planet_y = outer_rescue_planet_y + rescue_system_y
	gas_planet_pool = {}
	table.insert(gas_planet_pool,planet_list[1])
	table.insert(gas_planet_pool,planet_list[2])
	table.insert(gas_planet_pool,planet_list[3])
	selected_planet = tableRemoveRandom(gas_planet_pool)
	outer_rescue_planet = Planet():setPlanetRadius(6000)
	outer_rescue_planet:setPosition(outer_rescue_planet_x, outer_rescue_planet_y)
	outer_rescue_planet:setDistanceFromMovementPlane(-1800)
	outer_rescue_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
	outer_rescue_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
	outer_rescue_planet.check_boom = true
	outer_rescue_planet:setAxialRotationTime(random(500,700))
	local outer_orbit = 3000	--proposed final: 3000
	outer_rescue_planet:setOrbit(rescue_star,outer_orbit)
	rescue_edge_distance = distance(outer_rescue_planet,rescue_star)
--	set outer rescue binary
	outer_rescue_angle = (outer_rescue_angle + 180 + 360) % 360
	local outer_rescue_binary_x, outer_rescue_binary_y = vectorFromAngleNorth(outer_rescue_angle,60000)
	outer_rescue_binary_x = outer_rescue_binary_x + rescue_system_x
	outer_rescue_binary_y = outer_rescue_binary_y + rescue_system_y
	selected_planet = tableRemoveRandom(gas_planet_pool)
	outer_rescue_binary = Planet():setPlanetRadius(6000)
	outer_rescue_binary:setPosition(outer_rescue_binary_x, outer_rescue_binary_y)
	outer_rescue_binary:setDistanceFromMovementPlane(-1800)
	outer_rescue_binary:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
	outer_rescue_binary:setPlanetSurfaceTexture(selected_planet.texture.surface)
	outer_rescue_binary.check_boom = true
	outer_rescue_binary:setAxialRotationTime(random(500,700))
	outer_rescue_binary:setOrbit(rescue_star,outer_orbit)
end
function constructDoomedBodiesAndStation()
	local star_angle = random(0,360)
	doomed_system_x, doomed_system_y = vectorFromAngleNorth(random(0,360),8500)
	doomed_system_x = doomed_system_x + player_spawn_x
	doomed_system_y = doomed_system_y + player_spawn_y
--	set doomed star
	star_radius = random(600,2400)
	original_star_radius = star_radius
	doomed_star = Planet():setPosition(doomed_system_x, doomed_system_y):setPlanetRadius(star_radius)
	doomed_star:setCallSign(tableRemoveRandom(star_list[1].name))
	doomed_star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere)
	doomed_star:setPlanetAtmosphereColor(star_list[1].color.red,star_list[1].color.green,star_list[1].color.blue)
	doomed_star.check_boom = true
	doomed_star_name = doomed_star:getCallSign()
	table.insert(inner_space,{obj=doomed_star,dist=star_radius + 1000,shape="circle"})
	initializeNovaBeamTargets(true)
--	set doomed planet
	local planet_angle = (star_angle + random(-135,135) + 360) % 360
	local doomed_planet_x, doomed_planet_y = vectorFromAngleNorth(planet_angle,25000)
	doomed_planet_x = doomed_planet_x + doomed_system_x
	doomed_planet_y = doomed_planet_y + doomed_system_y
	habitable_planet_pool = {}
	table.insert(habitable_planet_pool,planet_list[4])
	table.insert(habitable_planet_pool,planet_list[5])
	table.insert(habitable_planet_pool,planet_list[6])
	local selected_planet = tableRemoveRandom(habitable_planet_pool)
	doomed_planet = Planet():setPlanetRadius(4000)
	doomed_planet:setPosition(doomed_planet_x,doomed_planet_y)
	doomed_planet:setDistanceFromMovementPlane(-1000)
	doomed_planet:setCallSign(selected_planet.name[math.random(1,#selected_planet.name)])
	doomed_planet:setPlanetSurfaceTexture(selected_planet.texture.surface)
	doomed_planet:setPlanetAtmosphereTexture(selected_planet.texture.atmosphere)
	doomed_planet:setPlanetCloudTexture(selected_planet.texture.cloud)
	doomed_planet:setPlanetAtmosphereColor(selected_planet.color.red,selected_planet.color.green,selected_planet.color.blue)
	doomed_planet.check_boom = true
	doomed_planet:setAxialRotationTime(random(350,500))
	doomed_planet:setOrbit(doomed_star,850)	--proposed final:850
	doomed_edge_distance = distance(doomed_star,doomed_planet)
--	set doomed moon
	local moon_angle = random(0,300)
	local doomed_moon_x, doomed_moon_y = vectorFromAngleNorth(moon_angle,6000)
	doomed_moon_x = doomed_moon_x + doomed_planet_x
	doomed_moon_y = doomed_moon_y + doomed_planet_y
	local selected_moon = tableRemoveRandom(moon_list)
	doomed_moon = Planet():setPlanetRadius(1000)
	doomed_moon:setPosition(doomed_moon_x,doomed_moon_y)
	doomed_moon:setDistanceFromMovementPlane(-500)
	doomed_moon:setCallSign(tableRemoveRandom(selected_moon.name))
	doomed_moon:setPlanetSurfaceTexture(selected_moon.texture.surface)
	doomed_moon.check_boom = true
	doomed_moon:setOrbit(doomed_planet,300)	--proposed final: 300
	doomed_moon:setAxialRotationTime(random(150,250))
--	set doomed station
	local psx, psy = vectorFromAngleNorth((star_angle + 180 + random(-135,135) + 360) % 360,random(2000,15000))
	psx = psx + doomed_system_x
	psy = psy + doomed_system_y
	doomed_station = placeStation(psx,psy,"RandomHumanNeutral",player_faction)
	local station_type = doomed_station:getTypeName()
	table.insert(inner_space,{obj=doomed_station,dist=station_spacing[station_type].touch,shape="circle"})
	table.insert(inner_stations,doomed_station)
end
function constructMinorEnemyTrap()
	minor_trap_ships = {}
	faction_pool = {}
	local enemy_factions = {}
	for faction,letter in pairs(faction_letter) do
		table.insert(faction_pool,faction)
		tsa:setFaction(faction)
		if tpa:isEnemy(tsa) then
			if faction ~= "Exuari" then
				table.insert(enemy_factions,faction)
			end
		end	
	end
	minor_enemy = tableSelectRandom(enemy_factions)
	minor_enemy_angle = random(0,360)
	local men_x, men_y = vectorFromAngleNorth((minor_enemy_angle + random(-3,3)) % 360,35000 + random(0,1500))
	men_x = men_x + doomed_system_x
	men_y = men_y + doomed_system_y
	local minor_enemy_nebula = Nebula():setPosition(men_x,men_y)
	table.insert(outer_space,{obj=minor_enemy_nebula,dist=3000,shape="circle"})
	local bwj_x, bwj_y = vectorFromAngleNorth(minor_enemy_angle,40000)
	bwj_x = bwj_x + doomed_system_x
	bwj_y = bwj_y + doomed_system_y
	local bwj = WarpJammer():setPosition(bwj_x,bwj_y):setRange(5000):setHull(100)
	table.insert(outer_space,{obj=bwj,dist=200,shape="circle"})
	minor_enemy_ambush = {}
	local center_guard = CpuShip():setTemplate("Adder MK5"):setFaction(minor_enemy)
	local cg_x, cg_y = vectorFromAngleNorth(minor_enemy_angle,35700)
	cg_x = cg_x + doomed_system_x
	cg_y = cg_y + doomed_system_y
	center_guard:setPosition(cg_x,cg_y):setHeading((minor_enemy_angle + 180) % 360):orderStandGround()
	table.insert(outer_space,{obj=center_guard,dist=100,shape="circle"})
	table.insert(minor_enemy_ambush,center_guard)
	table.insert(minor_trap_ships,center_guard)
	local guard_positions = {
		{angle = 90,	dist = 400},
		{angle = 270,	dist = 400},
		{angle = 90,	dist = 800},
		{angle = 270,	dist = 800},
	}
	for i,gp in ipairs(guard_positions) do
		local ship = CpuShip():setTemplate("Adder MK5"):setFaction(minor_enemy)
		local g_x, g_y = vectorFromAngleNorth((minor_enemy_angle + gp.angle) % 360, gp.dist)
		g_x = g_x + cg_x
		g_y = g_y + cg_y
		ship:setPosition(g_x,g_y):setHeading((minor_enemy_angle + 180) % 360):orderStandGround()
		table.insert(outer_space,{obj=ship,dist=100,shape="circle"})
		table.insert(minor_enemy_ambush,ship)
		table.insert(minor_trap_ships,ship)
	end
--	set minor enemy station
	psx, psy = vectorFromAngleNorth(minor_enemy_angle,50000)
	psx = psx + doomed_system_x
	psy = psy + doomed_system_y
	minor_enemy_station = placeStation(psx,psy,"Sinister",minor_enemy)
	local station_type = minor_enemy_station:getTypeName()
	table.insert(outer_space,{obj=minor_enemy_station,dist=station_spacing[station_type].touch,shape="circle"})
	table.insert(outer_stations,minor_enemy_station)
--	set warp side of pincer action
	right_pincer = {}
	right_pincer.angle = (minor_enemy_angle + random(25,40)) % 360
	right_pincer.distance = random(35000,40000)
	right_pincer.x, right_pincer.y = vectorFromAngleNorth(right_pincer.angle,right_pincer.distance)
	right_pincer.x = right_pincer.x + doomed_system_x
	right_pincer.y = right_pincer.y + doomed_system_y
	local left_x, left_y = vectorFromAngleNorth((right_pincer.angle + 270) % 360, 2000)
	local right_x, right_y = vectorFromAngleNorth((right_pincer.angle + 90) % 360, 2000)
	right_pincer.zone = Zone():setPoints(
		left_x + player_spawn_x,	left_y + player_spawn_y,
		left_x + right_pincer.x,	left_y + right_pincer.y,
		right_x + right_pincer.x,	right_y + right_pincer.y,
		right_x + player_spawn_x,	right_y + player_spawn_y
	)
	local vam = VisualAsteroid():setPosition(right_pincer.x,right_pincer.y)
	table.insert(inner_space,{obj=right_pincer.zone,shape="zone"})
	table.insert(outer_space,{obj=right_pincer.zone,shape="zone"})
	table.insert(outer_space,{obj=vam,dist=2000,shape="circle"})
--	set jump side of pincer action
	left_pincer = {}
	left_pincer.angle = (minor_enemy_angle - random(25,40) + 360) % 360
	left_pincer.distance = random(35000,40000)
	left_pincer.x, left_pincer.y = vectorFromAngleNorth(left_pincer.angle,left_pincer.distance)
	left_pincer.x = left_pincer.x + doomed_system_x
	left_pincer.y = left_pincer.y + doomed_system_y
	left_x, left_y = vectorFromAngleNorth((left_pincer.angle + 270) % 360, 2000)
	right_x, right_y = vectorFromAngleNorth((left_pincer.angle + 90) % 360, 2000)
	left_pincer.zone = Zone():setPoints(
		left_x + player_spawn_x,	left_y + player_spawn_y,
		left_x + left_pincer.x,		left_y + left_pincer.y,
		right_x + left_pincer.x,	right_y + left_pincer.y,
		right_x + player_spawn_x,	right_y + player_spawn_y
	)
	vam = VisualAsteroid():setPosition(left_pincer.x,left_pincer.y)
	table.insert(inner_space,{obj=left_pincer.zone,shape="zone"})
	table.insert(outer_space,{obj=left_pincer.zone,shape="zone"})
	table.insert(outer_space,{obj=vam,dist=2000,shape="circle"})
	for i,faction in ipairs(faction_pool) do
		if faction == minor_enemy then
			faction_pool[i] = faction_pool[#faction_pool]
			faction_pool[#faction_pool] = nil
			break
		end
	end
end
function constructOuterDoomedStations()
	for i,faction in ipairs(faction_pool) do
		local psx, psy = findClearSpot(outer_space,"torus",doomed_system_x,doomed_system_y,35000,60000,nil,12000,true)
		tsa:setFaction(faction)
		local named_group = "RandomHumanNeutral"
		if tpa:isEnemy(tsa) then
			named_group = "Sinister"
		end
		if psx ~= nil then
			local placed_station = placeStation(psx,psy,named_group,faction)
			if placed_station ~= nil then
				station_type = placed_station:getTypeName()
				table.insert(outer_space,{obj=placed_station,dist=station_spacing[station_type].touch,shape="circle"})
				table.insert(outer_stations,placed_station)
			end
		end
	end
end
function constructConnectingStations()
	local selected_faction = ""
	repeat
		selected_faction = tableSelectRandom(faction_pool)
		tsa:setFaction(selected_faction)
	until(tpa:isEnemy(tsa))
	connecting_space_x, connecting_space_y = vectorFromAngleNorth(connection_angle,80000)
	connecting_space_x = connecting_space_x + doomed_system_x
	connecting_space_y = connecting_space_y + doomed_system_y
	local psx, psy = findClearSpot(connecting_space,"central rectangle",connecting_space_x,connecting_space_y,40000,40000,connection_angle,12000,true)
	if psx ~= nil then
		placed_station = placeStation(psx,psy,"Sinister",selected_faction)
		if placed_station ~= nil then
			station_type = placed_station:getTypeName()
			table.insert(connecting_space,{obj=placed_station,dist=station_spacing[station_type].platform,shape="circle"})
			table.insert(outer_stations,placed_station)
		end
	end
	repeat
		selected_faction = tableSelectRandom(faction_pool)
		tsa:setFaction(selected_faction)
	until(tpa:isFriendly(tsa))
	psx, psy = findClearSpot(connecting_space,"central rectangle",connecting_space_x,connecting_space_y,40000,40000,connection_angle,12000,true)
	if psx ~= nil then
		placed_station = placeStation(psx,psy,"RandomHumanNeutral",selected_faction)
		if placed_station ~= nil then
			station_type = placed_station:getTypeName()
			table.insert(connecting_space,{obj=placed_station,dist=station_spacing[station_type].platform,shape="circle"})
			table.insert(outer_stations,placed_station)
		end
	end
	repeat
		selected_faction = tableSelectRandom(faction_pool)
		tsa:setFaction(selected_faction)
	until(not tpa:isFriendly(tsa) and not tpa:isEnemy(tsa))
	psx, psy = findClearSpot(connecting_space,"central rectangle",connecting_space_x,connecting_space_y,40000,40000,connection_angle,12000,true)
	if psx ~= nil then
		placed_station = placeStation(psx,psy,"RandomHumanNeutral",selected_faction)
		if placed_station ~= nil then
			station_type = placed_station:getTypeName()
			table.insert(connecting_space,{obj=placed_station,dist=station_spacing[station_type].platform,shape="circle"})
			table.insert(outer_stations,placed_station)
		end
	end
end
function constructRescueStations()
	faction_pool = {}
	for faction,letter in pairs(faction_letter) do
		if faction ~= player_faction then
			table.insert(faction_pool,faction)
		end
	end
--	set inner rescue station
	local psx,psy = vectorFromAngleNorth(random(0,360),random(2000,12000))
	psx = psx + rescue_system_x
	psy = psy + rescue_system_y
	central_rescue_station = placeStation(psx,psy,"RandomHumanNeutral",player_faction)
	local station_type = central_rescue_station:getTypeName()
	table.insert(rescue_inner_space,{obj=central_rescue_station,dist=station_spacing[station_type].platform,shape="circle"})
	table.insert(outer_stations,central_rescue_station)
--	set rescue inner ring stations
	for i=1,3 do
		psx, psy = findClearSpot(rescue_inner_ring_space,"torus",rescue_system_x,rescue_system_y,27000,51000,nil,12000,true)
		local selected_faction = tableRemoveRandom(faction_pool)
		tsa:setFaction(selected_faction)
		local named_group = "RandomHumanNeutral"
		if tpa:isEnemy(tsa) then
			named_group = "Sinister"
		end
		if psx ~= nil then
			local placed_station = placeStation(psx,psy,named_group,selected_faction)
			if placed_station ~= nil then
				station_type = placed_station:getTypeName()
				table.insert(rescue_inner_ring_space,{obj=placed_station,dist=station_spacing[station_type].platform,shape="circle"})
				table.insert(outer_stations,placed_station)
			end
		end
	end
--	set rescue outer ring stations
	for i,faction in ipairs(faction_pool) do
		psx, psy = findClearSpot(rescue_outer_ring_space,"torus",rescue_system_x,rescue_system_y,70000,100000,nil,12000,true)
		tsa:setFaction(faction)
		local named_group = "RandomHumanNeutral"
		if tpa:isEnemy(tsa) then
			named_group = "Sinister"
		end
		if psx ~= nil then
			local placed_station = placeStation(psx,psy,named_group,faction)
			if placed_station ~= nil then
				station_type = placed_station:getTypeName()
				table.insert(rescue_outer_ring_space,{obj=placed_station,dist=station_spacing[station_type].platform,shape="circle"})
				table.insert(outer_stations,placed_station)
			end
		end
	end
end
function constructNemesisStation()
	nemesis_angle = (connection_angle + 60) % 360
	if random(1,100) < 50 then
		nemesis_angle = (connection_angle - 60 + 360) % 360
	end
	nemesis_x, nemesis_y = vectorFromAngleNorth(nemesis_angle,200000)
	nemesis_x = nemesis_x + doomed_system_x
	nemesis_y = nemesis_y + doomed_system_y
	nemesis_station = placeStation(nemesis_x,nemesis_y,"Sinister","Exuari")
	nemesis_station_sector = nemesis_station:getSectorName()
	local defense_angle = 0
	nemesis_defense = {}
	for i=1,6 do
		local dx, dy = vectorFromAngleNorth(defense_angle,3000)
		dx = dx + nemesis_x
		dy = dy + nemesis_y
		ship = CpuShip():setTemplate("Defense platform"):setPosition(dx,dy):setFaction("Exuari")
		ship:orderStandGround():setCallSign(string.format("DP%i",i))
		ship.angle = defense_angle
		table.insert(nemesis_defense,ship)
		defense_angle = defense_angle + 60
	end
	exuari_activity_answers = {
		_("station-comms","Just the usual predatory actions: attack anything and laugh as it's destroyed or looted."),
		_("station-comms","They seemed interested in Liberation Day for some reason."),
		_("station-comms","I could not make sense of what they were saying. They seemed to be talking in riddles."),
		_("station-comms","You want to talk to Jasmine Purdue. She's been studying the Exuari."),
	}
	early_exuari_activity_answers = {
		string.format(_("station-comms","They've been setting up an isolated station for research somewhere near %s"),nemesis_station:getSectorName()),
		_("station-comms","They seem to be interested in stellar mechanics."),
		_("station-comms","When you can get them to talk, the topic of the inner workings of stars seems to be top of mind."),
		_("station-comms","They were asking us about nova causality before trying to destroy us."),
		_("station-comms","They're just attacking everything per usual."),
	}
end
function constructNovaDemo()
	nova_objects_sorted = false
	nova_objects_identified = false
	nova_objects_measured = false
	nova_objects_initialized = false
	nova_objects_index = 1
	final_nova_objects_sorted = false
	final_nova_objects_identified = false
	final_nova_objects_measured = false
	final_nova_objects_initialized = false
	final_nova_objects_index = 1
	nova_demo_angle = random(0,360)
	nda_x, nda_y = vectorFromAngleNorth(nova_demo_angle,60000)
	nda_x = nda_x + doomed_system_x
	nda_y = nda_y + doomed_system_y
	nova_demo_artifact = Artifact():setPosition(nda_x,nda_y)
	nova_demo_artifact.arrival_time = getScenarioTime() + nova_delay
	nova_demo_artifact.start_distance = distance(nova_demo_artifact, doomed_star)
	nova_demo_artifact.check_boom = true
	nova_demo_artifact.scan_cycle = {
		{grav = 0,	elec = 0,	bio = 0},
		{grav = 0,	elec = 0,	bio = 1},
		{grav = 0,	elec = 1,	bio = 0},
		{grav = 0,	elec = 1,	bio = 1},
		{grav = 1,	elec = 0,	bio = 0},
		{grav = 1,	elec = 0,	bio = 1},
		{grav = 1,	elec = 1,	bio = 0},
		{grav = 1,	elec = 1,	bio = 1},
		{grav = random(0,1),	elec = random(0,1),	bio = random(0,1)},
		{grav = 0,	elec = 0,	bio = .5},
		{grav = 0,	elec = .5,	bio = 0},
		{grav = 0,	elec = .5,	bio = .5},
		{grav = .5,	elec = 0,	bio = 0},
		{grav = .5,	elec = 0,	bio = .5},
		{grav = .5,	elec = .5,	bio = 0},
		{grav = .5,	elec = .5,	bio = .5},
	}
	nova_demo_artifact.scan_cycle_index = 1
	nova_demo_artifact:setRadarSignatureInfo(nova_demo_artifact.scan_cycle[nova_demo_artifact.scan_cycle_index].grav,nova_demo_artifact.scan_cycle[nova_demo_artifact.scan_cycle_index].elec,nova_demo_artifact.scan_cycle[nova_demo_artifact.scan_cycle_index].bio)
	nova_demo_artifact.scan_time = getScenarioTime() + 1
	if cloak_level >= 0 then
		nova_demo_artifact:setRadarTraceColor(20,20,20)
	end
	nova_demo_artifact:setCommsScript(""):setCommsFunction(commsNova)
	nova_demo_artifact:setDescriptions(_("scienceDescription-artifact","Anomalous high tech object"),_("scienceDescription-artifact","Nova Fireworks - product of the Exuari Exclamatory Enterprise"))
	nova_demo_artifact:setScanningParameters(math.random(1,2),math.random(1,2))
	nova_demo_artifact:setFaction("Exuari")
--	test code to show start location of nova demo artifact
	local nzp = {}
	local nzp_angle = 0
	for i=1,6 do
		local x, y = vectorFromAngleNorth(nzp_angle,1000)
		table.insert(nzp,{x=x+nda_x,y=y+nda_y})
		nzp_angle = nzp_angle + 60
	end
	Zone():setPoints(
		nzp[1].x, nzp[1].y,
		nzp[2].x, nzp[2].y,
		nzp[3].x, nzp[3].y,
		nzp[4].x, nzp[4].y,
		nzp[5].x, nzp[5].y,
		nzp[6].x, nzp[6].y
	)
--	end of test code showing artifact location
end
--	Utilities
function angleFromVectorNorth(p1x,p1y,p2x,p2y)
	TWOPI = 6.2831853071795865
	RAD2DEG = 57.2957795130823209
	atan2parm1 = p2x - p1x
	atan2parm2 = p2y - p1y
	theta = math.atan2(atan2parm1, atan2parm2)
	if theta < 0 then
		theta = theta + TWOPI
	end
	return (360 - (RAD2DEG * theta)) % 360
end
function vectorFromAngleNorth(angle,distance)
	if spew_function_diagnostic then print("top of vector from angle north") end
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	if spew_function_diagnostic then print("bottom (ish) of vector from angle north") end
	return x, y
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, enemyStrength, template_pool, shape, spawn_distance, spawn_angle, px, py)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	end
	local enemy_position = 0
	local sp = irandom(400,900)			--random spacing of spawned group
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
	local enemyList = {}
	if template_pool == nil then
		template_pool_size = math.random(7,12)
		local selectivity_roll = random(1,100)
		if selectivity_roll <= 10 then
			pool_selectivity = "more/light"
			template_pool_size = 15
		elseif selectivity_roll <= 30 then
			pool_selectivity = "full"
		else
			pool_selectivity = "less/heavy"
		end
		template_pool = getTemplatePool(enemyStrength)
	end
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList
	end
	while enemyStrength > 0 do
		local selected_template = tableSelectRandom(template_pool)
		if spawn_enemy_diagnostic then print("Spwn sel template:",selected_template,"Faction:",enemyFaction,"Sector:",getSectorName(xOrigin,yOrigin)) end
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		ship:setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
		enemy_position = enemy_position + 1
		if shape == "none" or shape == "pyramid" or shape == "ambush" then
			ship:setPosition(xOrigin,yOrigin)
		else
			ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		end
		ship:setCommsScript(""):setCommsFunction(commsShip)
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	return enemyList
end
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
	--print("returning template pool containing these templates:")
	--for _, template in ipairs(template_pool) do
	--	print(template)
	--end
	return template_pool
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
--	Scenario specific utilities
function minorTrapScan(p)
	for i,ship in ipairs(minor_trap_ships) do
		if ship ~= nil and ship:isValid() then
			if ship:isScannedBy(p) then
				if p.minor_enemy_station_located == nil then
					local x, y = minor_enemy_station:getPosition()
					p:commandAddWaypoint(x,y)
					p.minor_enemy_station_located = p:getWaypointCount()
				end
				return true
			end
		end
	end
	return false
end
function novaTimeRemaining(p)
	local remain = nova_delay - getScenarioTime()
	local minutes = math.floor(remain / 60)
	local seconds = math.floor(remain % 60)
	if minutes <= 0 then
		p.nova_demo_time_remaining = string.format(_("station-comms","%i seconds"),seconds)
	else
		if seconds ~= 1 then
			p.nova_demo_time_remaining = string.format(_("station-comms","%i minutes and %i seconds"),minutes,seconds)
		else
			p.nova_demo_time_remaining = string.format(_("station-comms","%i minutes and %i second"),minutes,seconds)
		end
	end
	return true
end
function novaEnd()
	if nova_demo_artifact == nil or not nova_demo_artifact:isValid() then
		return true
	end
	return false
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
function missionMessages()
	if message_stations == nil then
		message_stations = {}
		table.insert(message_stations,doomed_station)
	end
	if command_log == nil then
		command_log = {
			{
				long = string.format(_("centralcommand-incCall","Patrol orders for Liberation Day:\nHappy Liberation Day, when we celebrate our freedom from the Kraylor. Eighty-five years ago, we wrested control of the last occupied Human system from Kraylor control. Formal and informal events are planned. You will be conducting patrol operations. Don't get distracted.\n\nItems of interest:\nIntel indicates that the %s are planning an attack. Watch for them.\n\nScientists say they are picking up periodic anomalous readings from something. Last known observation was on bearing %s from %s.\n\nThe Exuari made some kind of Liberation Day press announcement where they promised 'fireworks.' No details. Keep an eye out for Exuari activity."),minor_enemy,math.floor(nova_demo_angle),doomed_star:getCallSign()),
				short = string.format(_("msgRelay","Patrol the area for Liberation Day. %s planning attack. Scientists report anomalous readings bearing %s from %s. Weird Exuari Liberation Day press release."),minor_enemy,math.floor(nova_demo_angle),doomed_star:getCallSign()),
				time = 0,
				sent = false,
				received = false,
				method = "hail",
			},
			{
				long = string.format(_("msgRelay","Now that you have scanned the approaching enemy, we are adding a waypoint to your systems for %s station %s. It's the most probable source of the approaching %s ships."),minor_enemy,minor_enemy_station:getCallSign(),minor_enemy),
				short = string.format(_("msgRelay","Waypoint added for %s station %s, the probable source of approaching %s ships."),minor_enemy,minor_enemy_station:getCallSign(),minor_enemy),
				time = 3,
				sent = false,
				received = false,
				trigger = minorTrapScan,
				method = "relay",
			},
			{
				long = string.format(_("centralcommand-incCall","We keep picking up that anomalous reading we reported earlier. Whatever it is that is generating that signal is in motion. Our analysts say it is heading for %s on a reciprocal bearing of %s from %s. Our analysts don't think it will survive contact with %s, so you'd better investigate soon or it'll be gone."),doomed_star:getCallSign(),math.floor(nova_demo_angle),doomed_star:getCallSign(),doomed_star:getCallSign()),
				short = string.format(_("msgRelay","Anomalous object headed for %s on a reciprical bearing on %s."),doomed_star:getCallSign(),math.floor(nova_demo_angle)),
				time = nova_delay/2,
				sent = false,
				received = false,
				trigger = novaTimeRemaining,
				method = "hail",
			},
			{
				long = string.format(_("centralcommand-incCall","That 'thing' just caused %s to go nova! The nova explosion did copious amounts of damage to the system including the destruction of planet %s and its moon, %s. This event is starting to resemble one of the famous Exuari macabre 'jokes.' We reviewed the Exuari Liberation Day press release and we think this nova was just the first destructive event planned. They probably have another one planned for %s star system. Drop everything else and find out anything you can about Exuari activity around here, especially as it relates to exotic research and 'humor.'\n\nFriendly stations are easy to find and talk to, but neutral stations may also have information."),doomed_star:getCallSign(),doomed_planet:getCallSign(),doomed_moon:getCallSign(),rescue_star:getCallSign()),
				short = string.format(_("msgRelay","Anomalous object induced %s to go nova also destroying %s and %s. Investigate Exuari activity, especially around %s"),doomed_star:getCallSign(),doomed_planet:getCallSign(),doomed_moon:getCallSign(),rescue_star:getCallSign()),
				time = nova_delay,
				sent = false,
				received = false,
				trigger = novaEnd,
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
							print(p:getCallSign(),w,p.command_log[w].sent,p.command_log[w].received)
						end
						addCommandLogButton(p)
					end
					local met = true
					if log.trigger ~= nil then
						met = log.trigger(p)
					end
					if met then
						if not p.command_log[i].received then
							if log.method == "relay" then
								local long_msg = log.long
								if i == 2 then
									long_msg = string.format(_("msgRelay","%s (waypoint %s)"),long_msg,p.minor_enemy_station_located)
								end
								p:addCustomMessage("Relay","command_log_message_rel",long_msg)
								p:addCustomMessage("Operations","command_log_message_ops",long_msg)
								addCommandLogButton(p)
								p.command_log[i].received = true
								p.command_log[i].stamp = getScenarioTime()
							else	--hail method
								if availableForComms(p) then
									local selected_message_station = nil
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
										populateMessageStationList(p)
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
		local minutes = log.stamp / 60
		local seconds = math.floor(log.stamp % 60)
		local hours = 0
		if minutes > 60 then
			hours = math.floor(minutes / 60)
			minutes = math.floor(minutes % 60)
		else
			minutes = math.floor(minutes)
		end
		local timestamp = seconds
		if minutes > 0 then
			if hours > 0 then
				timestamp = string.format("%i:%.2i:%.2i",hours,minutes,seconds)
			else
				timestamp = string.format("%i:%.2i",minutes,seconds)
			end
		end
		out = string.format("%s\n%s - %s",out,timestamp,log.short)
	end
	p.show_player_command_log_msg = string.format("show_player_command_log_msg_%s",console)
	p:addCustomMessage(console,p.show_player_command_log_msg,out)
end
function populateMessageStationList(p)
	if #message_stations < 1 then
		for k,station in ipairs(outer_stations) do
			if station ~= nil and station:isValid() then
				if station:isFriendly(p) then
					table.insert(message_stations,station)
				end
			end
		end
		for k,station in ipairs(outer_stations) do
			if station ~= nil and station:isValid() then
				if not station:isFriendly(p) and not station:isEnemy(p) then
					table.insert(message_stations,station)
				end
			end
		end
		if #message_stations < 1 then
			for k,ship in ipairs(transport_list) do
				if ship ~= nil and ship:isValid() then
					if ship:isFriendly(p) then
						table.insert(message_stations,ship)
					end
				end
			end
			for k,ship in ipairs(transport_list) do
				if ship ~= nil and ship:isValid() then
					if not ship:isFriendly(p) and not ship:isEnemy(p) then
						table.insert(message_stations,ship)
					end
				end
			end
			if #message_stations < 1 then
				print("Ran out of stations and ships from which to send messages")
			end
		end
	end
end
--	Construct environment utilities
function findClearSpot(objects,area_shape,area_point_x,area_point_y,area_distance,area_distance_2,area_angle,new_buffer,placing_station)
	--area distance 2 is only required for torus areas and rectangle areas
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
			cx, cy = vectorFromAngleNorth(random(0,360),random(0,area_distance))
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
					if placing_station ~= nil and placing_station and item.obj.typeName == "SpaceStation" then
						comparison_dist = 12000
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
	elseif area_shape == "torus" then
		assert(type(area_distance_2)=="number",string.format("function findClearSpot expects an area distance number as the sixth parameter when the shape is torus, but got a %s instead",type(area_distance_2)))
		repeat
			cx, cy = vectorFromAngleNorth(random(0,360),random(area_distance,area_distance_2))
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
					if placing_station ~= nil and placing_station and item.obj.typeName == "SpaceStation" then
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
			cx, cy = vectorFromAngleNorth(area_angle,random(-area_distance/2,area_distance/2))
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngleNorth(area_angle + 90,random(-area_distance_2/2,area_distance_2/2))
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
					if placing_station ~= nil and placing_station and item.obj.typeName == "SpaceStation" then
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
			cx, cy = vectorFromAngleNorth(area_angle,random(0,area_distance))
			cx = cx + area_point_x
			cy = cy + area_point_y
			local px, py = vectorFromAngleNorth(area_angle + 90,random(-area_distance_2/2,area_distance_2/2))
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
					if placing_station ~= nil and placing_station and item.obj.typeName == "SpaceStation" then
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
function placeMinefieldBlob(placement_area)
	local area = placement_areas[placement_area]
	local radius = random(1500,4500)
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,radius)
	end
	if eo_x ~= nil then
		local mine_list = {}
		table.insert(mine_list,Mine():setPosition(eo_x,eo_y))
		local reached_the_edge = false
		local mine_space = 1400
		repeat
			local overlay = false
			local nmx, nmy = nil
			repeat
				overlay = false
				local base_mine_index = math.random(1,#mine_list)
				local base_mine = mine_list[base_mine_index]
				local bmx, bmy = base_mine:getPosition()
				local angle = random(0,360)
				nmx, nmy = vectorFromAngleNorth(angle,mine_space)
				nmx = nmx + bmx
				nmy = nmy + bmy
				for i, mine in ipairs(mine_list) do
					if i ~= base_mine_index then
						local cmx, cmy = mine:getPosition()
						local mine_distance = distance(cmx, cmy, nmx, nmy)
						if mine_distance < mine_space then
							overlay = true
							break
						end
					end
				end
			until(not overlay)
			table.insert(mine_list,Mine():setPosition(nmx,nmy))
			if distance(eo_x, eo_y, nmx, nmy) > radius then
				reached_the_edge = true
			end
		until(reached_the_edge)
		for i,mine in ipairs(mine_list) do
			table.insert(area.space,{obj=mine,dist=mine_space,shape="circle"})
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
	return mine_list
end
function placeAsteroidBlob(placement_area)
	local area = placement_areas[placement_area]
	local radius = random(1500,4500)
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,radius)
	end
	if eo_x ~= nil then
		local asteroid_list = {}
		local asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
		local a = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
		table.insert(asteroid_list,a)
		local reached_the_edge = false
		repeat
			local overlay = false
			local nax, nay = nil
			repeat
				overlay = false
				local base_asteroid_index = math.random(1,#asteroid_list)
				local base_asteroid = asteroid_list[base_asteroid_index]
				local bax, bay = base_asteroid:getPosition()
				local angle = random(0,360)
				asteroid_size = random(2,180) + random(2,180) + random(2,180) + random(2,180)
				local asteroid_space = (base_asteroid:getSize() + asteroid_size)*random(1.05,1.25)
				nax, nay = vectorFromAngleNorth(angle,asteroid_space)
				nax = nax + bax
				nay = nay + bay
				for i,asteroid in ipairs(asteroid_list) do
					if i ~= base_asteroid_index then
						local cax, cay = asteroid:getPosition()
						local asteroid_distance = distance(cax,cay,nax,nay)
						if asteroid_distance < asteroid_space then
							overlay = true
							break
						end
					end
				end
			until(not overlay)
			a = Asteroid():setPosition(nax,nay):setSize(asteroid_size)
			table.insert(asteroid_list,a)
			if distance(eo_x,eo_y,nax,nay) > radius then
				reached_the_edge = true
			end
		until(reached_the_edge)
		for i,ast in ipairs(asteroid_list) do
			asteroid_size = ast:getSize()
			local tx, ty = ast:getPosition()
			table.insert(area.space,{obj=ast,dist=asteroid_size,shape="circle"})
			local tether = random(asteroid_size + 10,800)
			local v_angle = random(0,360)
			local vx, vy = vectorFromAngleNorth(v_angle,tether)
			vx = vx + tx
			vy = vy + ty
			VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
			tether = random(asteroid_size + 10, asteroid_size + 800)
			v_angle = (v_angle + random(120,240)) % 360
			vx, vy = vectorFromAngleNorth(v_angle,tether)
			vx = vx + tx
			vy = vy + ty
			VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeStar(placement_area)
	local area = placement_areas[placement_area]
	local radius = random(600,1400)
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,radius)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,radius)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,radius)
	end
	if eo_x ~= nil then
		local star = Planet():setPosition(eo_x, eo_y):setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5)
		star:setCallSign(tableRemoveRandom(star_list[1].name))
		star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.5,1),random(0.5,1),random(0.5,1))
		table.insert(area.space,{obj=star,dist=radius + 1000,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeBlackHole(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,6000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,6000)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,6000)
	end
	if eo_x ~= nil then
		local bh = BlackHole():setPosition(eo_x, eo_y)
		table.insert(area.space,{obj=bh,dist=6000,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeProbe(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,200)
	end
	if eo_x ~= nil then
		local sp = ScanProbe():setPosition(eo_x, eo_y)
		local station_pool = {}
		if inner_stations ~= nil and #inner_stations > 0 then
			for i,station in ipairs(inner_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if outer_stations ~= nil and #outer_stations > 0 then
			for i,station in ipairs(outer_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		local owner = tableSelectRandom(station_pool)
		sp:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y)
		table.insert(area.space,{obj=sp,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeWarpJammer(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,200)
	end
	if eo_x ~= nil then
		local wj = WarpJammer():setPosition(eo_x, eo_y)
		local closest_station_distance = 999999
		local closest_station = nil
		local station_pool = {}
		if inner_stations ~= nil and #inner_stations > 0 then
			for i,station in ipairs(inner_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if outer_stations ~= nil and #outer_stations > 0 then
			for i,station in ipairs(outer_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
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
		wj:setRange(warp_jammer_range):setFaction(selected_faction)
		warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
		wj:setCallSign(string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count))
		wj.range = warp_jammer_range
		table.insert(warp_jammer_list,wj)
		table.insert(area.space,{obj=wj,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeWormHole(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,6000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,6000)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,6000)
	end
	if eo_x ~= nil then
		local we_x, we_y = nil
		local count_repeat_loop = 0
		repeat
			if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
				we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,500)
			elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
				we_x, we_y = findClearSpot(area.space,area.shape,area.center_x,area.inner_radius,area.outer_radius,nil,500)
			elseif placement_area == "Connecting Square" then
				eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,500)
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
				if transportee ~= nil and transportee:isValid() and transportee.typeName == "PlayerSpaceship" then
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
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeSensorJammer(placement_area)
	local area = placement_areas[placement_area]
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
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,200)
	end
	if eo_x ~= nil then
		local sj = sensorJammer(eo_x, eo_y)
		table.insert(area.space,{obj=sj,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeSensorBuoy(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,200)
	end
	local out = ""
	if eo_x ~= nil then
		local sb = Artifact():setPosition(eo_x, eo_y):setScanningParameters(math.random(1,difficulty*2),math.random(1,difficulty*2)):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
		local buoy_type_list = {}
		local buoy_type = ""
		local station_pool = {}
		if inner_stations ~= nil and #inner_stations > 0 then
			for i,station in ipairs(inner_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if outer_stations ~= nil and #outer_stations > 0 then
			for i,station in ipairs(outer_stations) do
				if station:isValid() then
					table.insert(station_pool,station)
				end
			end
		end
		if #station_pool > 0 then
			table.insert(buoy_type_list,"station")
		end
		if transport_list ~= nil and #transport_list > 0 then
			table.insert(buoy_type_list,"transport")
		end
		if #buoy_type_list > 0 then
			buoy_type = tableRemoveRandom(buoy_type_list)
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
		sb:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),out)
		table.insert(area.space,{obj=sb,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeAdBuoy(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,200)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,200)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,200)
	end
	if eo_x ~= nil then
		local ab = Artifact():setPosition(eo_x, eo_y):setScanningParameters(difficulty*2,1):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
		local billboards = {
			_("scienceDescription-buoy","Come to Billy Bob's for the best food in the sector"),
			_("scienceDescription-buoy","It's never too late to buy life insurance"),
			_("scienceDescription-buoy","You'll feel better in an Adder Mark 9"),
			_("scienceDescription-buoy","Melinda's Mynock Management service: excellent rates, satisfaction guaranteed"),
			_("scienceDescription-buoy","Visit Repulse shipyards for the best deals"),
			_("scienceDescription-buoy","Fresh fish! We catch, you buy!"),
			_("scienceDescription-buoy","Get your fuel cells at Melinda's Market"),
			_("scienceDescription-buoy","Find a special companion. All species available"),
			_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
			_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
			_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
			_("scienceDescription-buoy","Best tasting water in the quadrant at Willy's Waterway"),
			_("scienceDescription-buoy","Amazing shows every night at Lenny's Lounge"),
			_("scienceDescription-buoy","Get all your vaccinations at Fred's Pharmacy. Pick up some snacks, too"),
			_("scienceDescription-buoy","Tip: make lemons an integral part of your diet"),
		}
		ab:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),billboards[math.random(1,#billboards)])
		table.insert(area.space,{obj=ab,dist=200,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeNebula(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,3000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,3000)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,2000)
	end
	if eo_x ~= nil then
		local neb = Nebula():setPosition(eo_x, eo_y)
		table.insert(area.space,{obj=neb,dist=1500,shape="circle"})
		if random(1,100) < 77 then
			local n_angle = random(0,360)
			local n_x, n_y = vectorFromAngle(n_angle,random(5000,10000))
			local neb2 = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
			if random(1,100) < 37 then
				local n2_angle = (n_angle + random(120,240)) % 360
				n_x, n_y = vectorFromAngle(n2_angle,random(5000,10000))
				eo_x = eo_x + n_x
				eo_y = eo_y + n_y
				local neb3 = Nebula():setPosition(eo_x, eo_y)
				if random(1,100) < 22 then
					local n3_angle = (n2_angle + random(120,240)) % 360
					n_x, n_y = vectorFromAngle(n3_angle,random(5000,10000))
					local neb4 = Nebula():setPosition(eo_x + n_x, eo_y + n_y)
				end
			end
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeMine(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,1000)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,1000)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,1000)
	end
	if eo_x ~= nil then
		local m = Mine():setPosition(eo_x, eo_y)
		table.insert(area.space,{obj=m,dist=1000,shape="circle"})
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeMineField(placement_area)
	local area = placement_areas[placement_area]
	local field_size = math.random(1,3)
	local mine_circle = {
		{inner_count = 4,	mid_count = 10,		outer_count = 15},	--1
		{inner_count = 9,	mid_count = 15,		outer_count = 20},	--2
		{inner_count = 15,	mid_count = 20,		outer_count = 25},	--3
	}
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,4000 + (field_size*1500))
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,4000 + (field_size*1500))
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,4000 + (field_size*1500))
	end
	if eo_x ~= nil then
		local angle = random(0,360)
		local mx = 0
		local my = 0
		for i=1,mine_circle[field_size].inner_count do
			mx, my = vectorFromAngle(angle,field_size*1000)
			local m = Mine():setPosition(eo_x+mx,eo_y+my)
			table.insert(area.space,{obj=m,dist=1000,shape="circle"})
			angle = (angle + (360/mine_circle[field_size].inner_count)) % 360
		end
		for i=1,mine_circle[field_size].mid_count do
			mx, my = vectorFromAngle(angle,field_size*1000 + 1200)
			local m = Mine():setPosition(eo_x+mx,eo_y+my)
			table.insert(area.space,{obj=m,dist=1000,shape="circle"})
			angle = (angle + (360/mine_circle[field_size].mid_count)) % 360
		end
		if random(1,100) < 30 + difficulty*20 then
			local n_x, n_y = vectorFromAngle(random(0,360),random(50,2000))
			Nebula():setPosition(eo_x + n_x, eo_y + n_y)
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeAsteroidField(placement_area)
	local field_size = random(2000,8000)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,field_size + 500)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,500)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,500)
	end
	if eo_x ~= nil then
		local asteroid_field = {}
		for n=1,math.floor(field_size/random(300,500)) do
			local asteroid_size = 0
			for s=1,4 do
				asteroid_size = asteroid_size + random(2,200)
			end
			local dist = random(100,field_size)
			local x,y = findClearSpot(asteroid_field,"circle",eo_x,eo_y,field_size,nil,nil,asteroid_size)
			if x ~= nil then
				local ast = Asteroid():setPosition(x,y):setSize(asteroid_size)
				table.insert(area.space,{obj=ast,dist=asteroid_size,shape="circle"})
				table.insert(asteroid_field,{obj=ast,dist=asteroid_size,shape="circle"})
				local tether = random(asteroid_size + 10,800)
				local v_angle = random(0,360)
				local vx, vy = vectorFromAngleNorth(v_angle,tether)
				vx = vx + x
				vy = vy + y
				local vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
				tether = random(asteroid_size + 10, asteroid_size + 800)
				v_angle = (v_angle + random(120,240)) % 360
				local vx, vy = vectorFromAngleNorth(v_angle,tether)
				vx = vx + x
				vy = vy + y
				vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
			else
				break
			end
		end
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeTransport(placement_area)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,600)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,600)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,600)
	end
	if eo_x ~= nil then
		local ship, ship_size = randomTransportType()
		if transport_faction_list == nil or #transport_faction_list == 0 then
			transport_faction_list = {}
			for faction,letter in pairs(faction_letter) do
				table.insert(transport_faction_list,faction)
			end
		end
		ship:setPosition(eo_x, eo_y):setFaction(tableRemoveRandom(transport_faction_list))
		ship:setCallSign(generateCallSign(nil,ship:getFaction()))
		table.insert(area.space,{obj=ship,dist=600,shape="circle"})
		table.insert(transport_list,ship)
		return true
	else
		placeAsteroid(placement_area)
		return false
	end
end
function placeAsteroid(placement_area)
	local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
	local area = placement_areas[placement_area]
	local eo_x, eo_y = nil
	if placement_area == "Doomed Circle" or placement_area == "Rescue Circle" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.radius,nil,nil,asteroid_size)
	elseif placement_area == "Doomed Ring" or placement_area == "Rescue Inner Ring" or placement_area == "Rescue Outer Ring" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.inner_radius,area.outer_radius,nil,asteroid_size)
	elseif placement_area == "Connecting Square" then
		eo_x, eo_y = findClearSpot(area.space,area.shape,area.center_x,area.center_y,area.width,area.height,connection_angle,asteroid_size)
	end
	if eo_x ~= nil then
		local ta = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
		table.insert(area.space,{obj=ta,dist=asteroid_size,shape="circle"})
		local tether = random(asteroid_size + 10,800)
		local v_angle = random(0,360)
		local vx, vy = vectorFromAngleNorth(v_angle,tether)
		vx = vx + eo_x
		vy = vy + eo_y
		local vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
		tether = random(asteroid_size + 10, asteroid_size + 800)
		v_angle = (v_angle + random(120,240)) % 360
		local vx, vy = vectorFromAngleNorth(v_angle,tether)
		vx = vx + eo_x
		vy = vy + eo_x
		vast = VisualAsteroid():setPosition(vx,vy):setSize(random(10,tether))
		return true
	else
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
	return CpuShip():setTemplate(string.format("%s %s %i",tableSelectRandom(transport_type),freighter_engine,freighter_size)):setCommsScript(""):setCommsFunction(commsShip), freighter_size
end
function maintainTransports()
	local clean_list = true
	for i,transport in ipairs(transport_list) do
		if transport ~= nil then
			if not transport:isValid() then
				transport_list[i] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				clean_list = false
				break
			end
		else
			transport_list[i] = transport_list[#transport_list]
			transport_list[#transport_list] = nil
			clean_list = false
			break
		end
	end
	if clean_list then
		for i,transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				if transport:getDockedWith() ~= nil then	--docked
					if transport.dock_time == nil then
						transport.dock_time = getScenarioTime() + random(5,30)
					end
				elseif transport:getOrder() ~= "Dock" then	--no docking order
					if transport.dock_time == nil then
						transport.dock_time = getScenarioTime() + random(5,30)
					end
				elseif transport:getOrder() == "Dock" then	--docking order to invalid station
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
						if not station:isValid() then
							inner_stations[j] = inner_stations[#inner_stations]
							inner_stations[#inner_stations] = nil
							clean_list = false
							break
						else
							if not transport:isEnemy(station) then
								table.insert(transport_station_pool,station)
							end
						end
					else
						inner_stations[j] = inner_stations[#inner_stations]
						inner_stations[#inner_stations] = nil
						clean_list = false
						break
					end
				end
				if clean_list then
					for j,station in ipairs(outer_stations) do
						if station ~= nil then
							if not station:isValid() then
								outer_stations[j] = outer_stations[#outer_stations]
								outer_stations[#outer_stations] = nil
								clean_list = false
								break
							else
								if not transport:isEnemy(station) then
									table.insert(transport_station_pool,station)
								end
							end
						else
							outer_stations[j] = outer_stations[#outer_stations]
							outer_stations[#outer_stations] = nil
							clean_list = false
							break
						end
					end
				end				
				if clean_list and #transport_station_pool > 0 then
					local dock_station = tableSelectRandom(transport_station_pool)
					transport:orderDock(dock_station)
					transport.dock_time = nil
				end
			end
		end
		if clean_list and #transport_list < initial_transport_count then
			if transport_spawn_time == nil then
				transport_spawn_time = getScenarioTime() + random(30,60)
			end
			if getScenarioTime() > transport_spawn_time then
				if random(1,100) < 30 then
					local transport_station_spawn_pool = {}
					for i,station in ipairs(inner_stations) do
						if station ~= nil and station:isValid() then
							table.insert(transport_station_spawn_pool,station)
						end
					end
					for i,station in ipairs(outer_stations) do
						if station ~= nil and station:isValid() then
							table.insert(transport_station_spawn_pool,station)
						end
					end
					local destination_station = tableSelectRandom(transport_station_spawn_pool)
					local sx,sy = destination_station:getPosition()
					local ship, ship_size = randomTransportType()
					ship:setFaction(destination_station:getFaction())
					ship:setPosition(sx,sy)
					ship:setCallSign(generateCallSign(nil,ship:getFaction()))
					table.insert(transport_list,ship)
					ship:orderDock(destination_station)
				end
				transport_spawn_time = getScenarioTime() + random(30,60)
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
--	Nova functions
function addEjecta(start_x, start_y, lo, hi)
	local max_ejecta = math.random(lo,hi)
	local actions = {"dissipate","explode","stop"}
	for i=1,max_ejecta do
		local dist = random(5000,60000)
		local speed = random(20,200)
		local asteroid_size = 0
		for j=1,10 do
			asteroid_size = asteroid_size + random(10,50)
		end
		table.insert(ejecta, {
			obj = Asteroid():setPosition(0,0):setSize(asteroid_size),
			x = start_x,
			y = start_y,
			action = tableSelectRandom(actions),
			angle = random((i-1)*360/max_ejecta,i*360/max_ejecta),
			speed = speed,
			dist = dist,
			iterations = math.floor(dist/speed),
			del = false,
		})
		asteroid_size = 0
		for j=1,10 do
			asteroid_size = asteroid_size + random(10,90)
		end
		table.insert(ejecta, {
			obj = VisualAsteroid():setPosition(0,0):setSize(asteroid_size),
			x = start_x + random(-asteroid_size,asteroid_size),
			y = start_y + random(-asteroid_size,asteroid_size),
			action = tableSelectRandom(actions),
			angle = random((i-1)*360/max_ejecta,i*360/max_ejecta),
			speed = speed,
			dist = dist,
			iterations = math.floor(dist/speed),
			del = false,
		})
		asteroid_size = 0
		for j=1,10 do
			asteroid_size = asteroid_size + random(10,90)
		end
		table.insert(ejecta, {
			obj = VisualAsteroid():setPosition(0,0):setSize(asteroid_size),
			x = start_x + random(-asteroid_size,asteroid_size),
			y = start_y + random(-asteroid_size,asteroid_size),
			action = tableSelectRandom(actions),
			angle = random((i-1)*360/max_ejecta,i*360/max_ejecta),
			speed = speed,
			dist = dist,
			iterations = math.floor(dist/speed),
			del = false,
		})
	end
end
function processEjecta()
	local place_count = 0
	if ejecta ~= nil and #ejecta > 0 then
		for i,ej in ipairs(ejecta) do
			if ej.obj ~= nil and ej.obj:isValid() then
				if ej.placed then
					local ox, oy = ej.obj:getPosition()
					setCirclePos(ej.obj, ox, oy, ej.angle, ej.speed)
					ej.iterations = ej.iterations - 1
					if ej.iterations <= 0 then
						if ej.action == "dissipate" then
							ej.obj:destroy()
							ej.obj = nil
							ej.del = true
						elseif ej.action == "stop" then
							ej.obj = nil
							ej.del = true
						elseif ej.action == "explode" then
							local ex, ey = ej.obj:getPosition()
							ej.obj:destroy()
							ExplosionEffect():setPosition(ex,ey):setSize(random(100,10000))
							ej.obj = nil
							ej.del = true
						end
					else
						ej.speed = math.max(20,ej.speed - random(0,10))
					end
				else
					ej.obj:setPosition(ej.x,ej.y)
					ej.placed = true
					place_count = place_count + 1
					if place_count > 5 then
						break
					end
				end
			else
				ej.obj = nil
				ej.del = true
			end
		end
		for i=#ejecta,1,-1 do
			if ejecta[i].del then
				ejecta[i] = ejecta[#ejecta]
				ejecta[#ejecta] = nil
			end
		end
	else
		process_ejecta = false
		reset_nova_process = true
		ejecta = {}
		if second_star_destroyed then
			globalMessage("The Exuari really enjoyed the fireworks at your expense")
			victory("Exuari")
		end
	end
end
function initializeNovaBeamTargets(demo)
	if remove_nbt == nil then
		remove_nbt = {}
		for i=1,360 do
			local nbt_x, nbt_y = vectorFromAngleNorth(i,200000)
			if demo then
				nbt_x = nbt_x + doomed_system_x
				nbt_y = nbt_y + doomed_system_y
			else
				nbt_x = nbt_x + rescue_system_x
				nbt_y = nbt_y + rescue_system_y
			end
			local nbt = VisualAsteroid():setPosition(nbt_x,nbt_y)
			table.insert(nova_beam_targets,nbt)
			table.insert(remove_nbt,nbt)
		end
	else
		for i=1,360 do
			table.insert(nova_beam_targets,remove_nbt[i])
		end
	end
end
function finalNova()
	if final_nova_artifact ~= nil and final_nova_artifact:isValid() then
		if getScenarioTime() > final_nova_artifact.arrival_time then
			if reset_nova_process then
				finalNovaExplosion()
			end
		else
			local time_remaining = 1 - getScenarioTime()/final_nova_artifact.arrival_time
			local new_distance = final_nova_artifact.start_distance * time_remaining
			local nda_x, nda_y = vectorFromAngleNorth(final_nova_angle,new_distance)
			nda_x = nda_x + rescue_system_x
			nda_y = nda_y + rescue_system_y
			final_nova_artifact:setPosition(nda_x, nda_y)
			if getScenarioTime() > final_nova_artifact.scan_time then
				final_nova_artifact.scan_cycle_index = final_nova_artifact.scan_cycle_index + 1
				if final_nova_artifact.scan_cycle_index > #final_nova_artifact.scan_cycle then
					final_nova_artifact.scan_cycle_index = 1
				end
				final_nova_artifact:setRadarSignatureInfo(final_nova_artifact.scan_cycle[final_nova_artifact.scan_cycle_index].grav,final_nova_artifact.scan_cycle[final_nova_artifact.scan_cycle_index].elec,final_nova_artifact.scan_cycle[final_nova_artifact.scan_cycle_index].bio)
				final_nova_artifact.scan_time = getScenarioTime() + 1
			end
		end
	elseif getScenarioTime() > hunt_time and not final_nova_artifact_created then
		final_nova_angle = angleFromVectorNorth(nemesis_x,nemesis_y,rescue_system_x,rescue_system_y)
--		print("final nova angle:",final_nova_angle)
		final_nova_artifact = Artifact():setPosition(nemesis_x,nemesis_y)
		final_nova_artifact.arrival_time = getScenarioTime() + final_nova_delay
		final_nova_artifact.start_distance = distance(final_nova_artifact, rescue_star)
		final_nova_artifact.check_boom = true
		final_nova_artifact.scan_cycle = {
			{grav = 0,	elec = 0,	bio = 0},
			{grav = 0,	elec = 0,	bio = 1},
			{grav = 0,	elec = 1,	bio = 0},
			{grav = 0,	elec = 1,	bio = 1},
			{grav = 1,	elec = 0,	bio = 0},
			{grav = 1,	elec = 0,	bio = 1},
			{grav = 1,	elec = 1,	bio = 0},
			{grav = 1,	elec = 1,	bio = 1},
			{grav = random(0,1),	elec = random(0,1),	bio = random(0,1)},
			{grav = 0,	elec = 0,	bio = .5},
			{grav = 0,	elec = .5,	bio = 0},
			{grav = 0,	elec = .5,	bio = .5},
			{grav = .5,	elec = 0,	bio = 0},
			{grav = .5,	elec = 0,	bio = .5},
			{grav = .5,	elec = .5,	bio = 0},
			{grav = .5,	elec = .5,	bio = .5},
		}
		final_nova_artifact.scan_cycle_index = 1
		final_nova_artifact:setRadarSignatureInfo(final_nova_artifact.scan_cycle[final_nova_artifact.scan_cycle_index].grav,final_nova_artifact.scan_cycle[final_nova_artifact.scan_cycle_index].elec,final_nova_artifact.scan_cycle[final_nova_artifact.scan_cycle_index].bio)
		final_nova_artifact.scan_time = getScenarioTime() + 1
		if cloak_level >= 0 then
			final_nova_artifact:setRadarTraceColor(20,20,20)
		end
		final_nova_artifact:setCommsScript(""):setCommsFunction(commsNova)
		final_nova_artifact:setDescriptions(_("scienceDescription-artifact","Anomalous high tech object"),_("scienceDescription-artifact","Nova Fireworks - product of the Exuari Exclamatory Enterprise"))
		final_nova_artifact:setScanningParameters(math.random(1,3),math.random(1,3))
		final_nova_artifact:setFaction("Exuari")
		final_nova_artifact_created = true
	end
end
function finalNovaExplosion()
	if rescue_star ~= nil and rescue_star:isValid() then
		if final_nova_objects_sorted then
			rescue_star_radius = rescue_star_radius + rescue_radius_increment
			rescue_star:setPlanetRadius(rescue_star_radius)
			stagger_check = stagger_check + 1
			if stagger_check > 5 then
				stagger_check = 0
				if #nova_beam_targets < 1 then
					initializeNovaBeamTargets(true)
				end
				local nova_ray_string = {
					"texture/beam_blue.png",
					"texture/beam_green.png",
					"texture/beam_orange.png",
					"texture/beam_purple.png",
					"texture/beam_yellow.png",
				}
				BeamEffect()
					:setSource(rescue_star,random(0,5000),random(0,5000),random(-5000,5000))
					:setTarget(tableRemoveRandom(nova_beam_targets),0,0,random(-500000,500000))
					:setTexture(tableSelectRandom(nova_ray_string))
					:setDuration(random(.5,5))
					:setRing(false)
					:setBeamFireSoundPower(0)
			end
			if final_nova_objects_index < #nova_objects then
				for i=final_nova_objects_index,#nova_objects do
					local obj=nova_objects[i]
					if obj.nova_dist <= rescue_star_radius then
						if obj.check_boom == nil then
							obj.check_boom = true
							local chance = original_star_radius/rescue_star_radius
							local roll = random(0,1)
							if roll < chance then
								if obj.typeName ~= "PlayerSpaceship" then
									local ie_x, ie_y = obj:getPosition()
									ExplosionEffect():setPosition(ie_x, ie_y):setSize(random(4000,6000)):setOnRadar(true)
									if ie_x ~= nil then
										addEjecta(ie_x, ie_y, 5, 10)
										process_ejecta = true
									end
									obj:destroy()
								else
									for j,system in ipairs(system_list) do
										if obj:hasSystem(system) then
											local current_health = obj:getSystemHealth(system)
											if current_health > 0 then
												obj:setSystemHealth(system,current_health - random(.2,.8))
											else
												obj:setSystemHealth(system,current_health - random(.1,.2))
											end
										end
									end
								end
							end
						end
					else
						final_nova_objects_index = i
						break
					end
				end
			end
			if rescue_star_radius > rescue_edge_distance then
				rescue_star:destroy()
				addEjecta(rescue_system_x, rescue_system_y, 30, 50)
			end
		elseif final_nova_objects_measured then
			--sort by distance
			table.sort(nova_objects,function(a,b)
				return a.nova_dist < b.nova_dist
			end)
			final_nova_objects_sorted = true
		elseif final_nova_objects_identified then
			--measure objects
			for i,obj in ipairs(nova_objects) do
				if obj ~= nil and obj:isValid() then
					if obj.check_boom == nil then
						local ox, oy = obj:getPosition()
						obj.nova_dist = distance(rescue_system_x,rescue_system_y,ox,oy)
					else
						obj.nova_dist = rescue_edge_distance + 1000 + i
					end
				end
			end
			final_nova_objects_measured = true
		elseif final_nova_objects_initialized then
			--get objects
			nova_objects = getObjectsInRadius(rescue_system_x,rescue_system_y,rescue_edge_distance)
			final_nova_objects_identified = true
		else
			--initialize nova
			if rescue_radius_increment == nil then
				rescue_radius_increment = rescue_star_radius * .1
				stagger_check = 0
			end
			nova_objects = {}
			final_nova_objects_initialized = true
		end
	else	--rescue star is gone
		if inner_rescue_planet ~= nil and inner_rescue_planet:isValid() then
			pex_x, pex_y = inner_rescue_planet:getPosition()		--planet explosion x and y
			orpex_x, orpex_y = outer_rescue_planet:getPosition()	--outer rescue planet explosion x and y
			orbex_x, orbex_y = outer_rescue_binary:getPosition()	--outer rescue binary explosion x and y
			if orbex_x ~= nil then
				ElectricExplosionEffect():setPosition(orbex_x, orbex_y):setSize(40000):setOnRadar(true)
				addEjecta(orbex_x, orbex_y, 20, 40)
			end
			if orpex_x ~= nil then
				ElectricExplosionEffect():setPosition(orpex_x, orpex_y):setSize(40000):setOnRadar(true)
				addEjecta(orpex_x, orpex_y, 20, 40)
			end
			if pex_x ~= nil then
				ExplosionEffect():setPosition(pex_x, pex_y):setSize(20000):setOnRadar(true)
				addEjecta(pex_x, pex_y, 20, 30)
			end
			inner_rescue_planet:destroy()
			outer_rescue_planet:destroy()
			outer_rescue_binary:destroy()
			final_nova_artifact:explode()
			process_ejecta = true
			second_star_destroyed = true
			for i,nbt in ipairs(remove_nbt) do
				nbt:destroy()
			end
			remove_nbt = nil
			nova_beam_targets = {}
		end
	end
end
function novaDemoArtifact()
	if nova_demo_artifact ~= nil and nova_demo_artifact:isValid() then
		if getScenarioTime() > nova_demo_artifact.arrival_time then
			if doomed_star ~= nil and doomed_star:isValid() then
				if nova_objects_sorted then
					star_radius = star_radius + radius_increment
					doomed_star:setPlanetRadius(star_radius)
					stagger_check = stagger_check + 1
					if stagger_check > 5 then
						stagger_check = 0
						if #nova_beam_targets < 1 then
							initializeNovaBeamTargets(true)
						end
						local nova_ray_string = {
							"texture/beam_blue.png",
							"texture/beam_green.png",
							"texture/beam_orange.png",
							"texture/beam_purple.png",
							"texture/beam_yellow.png",
						}
						BeamEffect()
							:setSource(doomed_star,random(0,5000),random(0,5000),random(-5000,5000))
							:setTarget(tableRemoveRandom(nova_beam_targets),0,0,random(-500000,500000))
							:setTexture(tableSelectRandom(nova_ray_string))
							:setDuration(random(.5,5))
							:setRing(false)
							:setBeamFireSoundPower(0)
					end
					if nova_objects_index < #nova_objects then
						for i=nova_objects_index,#nova_objects do
							local obj=nova_objects[i]
							if obj.nova_dist <= star_radius then
								if obj.check_boom == nil then
									obj.check_boom = true
									local chance = original_star_radius/star_radius
									local roll = random(0,1)
									if roll < chance then
										if obj.typeName ~= "PlayerSpaceship" then
											local ie_x, ie_y = obj:getPosition()
											ExplosionEffect():setPosition(ie_x, ie_y):setSize(random(4000,6000)):setOnRadar(true)
											if ie_x ~= nil then
												addEjecta(ie_x, ie_y, 5, 10)
												process_ejecta = true
											end
											obj:destroy()
										else
											for j,system in ipairs(system_list) do
												if obj:hasSystem(system) then
													local current_health = obj:getSystemHealth(system)
													if current_health > 0 then
														obj:setSystemHealth(system,current_health - random(.2,.8))
													else
														obj:setSystemHealth(system,current_health - random(.1,.2))
													end
												end
											end
										end
									end
								end
							else
								nova_objects_index = i
								break
							end
						end
					end
					if star_radius > doomed_edge_distance then
						doomed_star:destroy()
						addEjecta(doomed_system_x, doomed_system_y, 30, 50)
					end
				elseif nova_objects_measured then
					--sort by distance
					table.sort(nova_objects,function(a,b)
						return a.nova_dist < b.nova_dist
					end)
					nova_objects_sorted = true
				elseif nova_objects_identified then
					--measure objects
					for i,obj in ipairs(nova_objects) do
						if obj ~= nil and obj:isValid() then
							if obj.check_boom == nil then
								local ox, oy = obj:getPosition()
								obj.nova_dist = distance(doomed_system_x,doomed_system_y,ox,oy)
							else
								obj.nova_dist = doomed_edge_distance + 1000 + i
							end
						end
					end
					nova_objects_measured = true
				elseif nova_objects_initialized then
					--get objects
					nova_objects = getObjectsInRadius(doomed_system_x,doomed_system_y,doomed_edge_distance)
					nova_objects_identified = true
				else
					--initialize nova
					if radius_increment == nil then
						radius_increment = star_radius * .1
						stagger_check = 0
					end
					nova_objects = {}
					nova_objects_initialized = true
				end
			else	--doomed star is gone
				if doomed_planet ~= nil and doomed_planet:isValid() then
					pex_x, pex_y = doomed_planet:getPosition()
					mex_x, mex_y = doomed_moon:getPosition()
					if mex_x ~= nil then
						ElectricExplosionEffect():setPosition(mex_x, mex_y):setSize(10000):setOnRadar(true)
						addEjecta(mex_x, mex_y, 10, 20)
					end
					if pex_x ~= nil then
						ExplosionEffect():setPosition(pex_x, pex_y):setSize(40000):setOnRadar(true)
						addEjecta(pex_x, pex_y, 20, 30)
					end
					doomed_planet:destroy()
					doomed_moon:destroy()
					nova_demo_artifact:explode()
					process_ejecta = true
					for i,nbt in ipairs(remove_nbt) do
						nbt:destroy()
					end
					remove_nbt = nil
					nova_beam_targets = {}
				end
			end
		else
			local time_remaining = 1 - getScenarioTime()/nova_demo_artifact.arrival_time
			local new_distance = nova_demo_artifact.start_distance * time_remaining
			local nda_x, nda_y = vectorFromAngleNorth(nova_demo_angle,new_distance)
			nda_x = nda_x + doomed_system_x
			nda_y = nda_y + doomed_system_y
			nova_demo_artifact:setPosition(nda_x, nda_y)
			if getScenarioTime() > nova_demo_artifact.scan_time then
				nova_demo_artifact.scan_cycle_index = nova_demo_artifact.scan_cycle_index + 1
				if nova_demo_artifact.scan_cycle_index > #nova_demo_artifact.scan_cycle then
					nova_demo_artifact.scan_cycle_index = 1
				end
				nova_demo_artifact:setRadarSignatureInfo(nova_demo_artifact.scan_cycle[nova_demo_artifact.scan_cycle_index].grav,nova_demo_artifact.scan_cycle[nova_demo_artifact.scan_cycle_index].elec,nova_demo_artifact.scan_cycle[nova_demo_artifact.scan_cycle_index].bio)
				nova_demo_artifact.scan_time = getScenarioTime() + 1
			end
		end
	end
end
--	Various communications routines specific to Liberation Day
function scenarioMissions()
	local option_count = 0
	if nova_demo_artifact ~= nil and nova_demo_artifact:isValid() then
		if nova_demo_artifact:isScannedBy(comms_source) then
			option_count = option_count + 1
			addCommsReply(_("station-comms","Investigate anomalous object"),function()
				setCommsMessage(_("station-comms","We discovered a communication interface attached to the anomalous object. We could not make sense of it. Would you like to try?"))
				addCommsReply(_("station-comms","Connect us to object"),function()
					comms_source.connect_to_nova = true
					setCommsMessage(_("station-comms","Ok. We've rigged it to contact you when you close communications with us."))
				end)
			end)
		end
	elseif final_nova_artifact ~= nil and final_nova_artifact:isValid() then
		askStationAboutExuari()
		askStationAboutJasminePurdue()
		if final_nova_artifact:isScannedBy(comms_source) then
			option_count = option_count + 1
			addCommsReply(_("station-comms","Investigate anomalous object"),function()
				setCommsMessage(_("station-comms","We discovered a communication interface attached to the anomalous object. We could not make sense of it. Would you like to try?"))
				addCommsReply(_("station-comms","Connect us to object"),function()
					comms_source.connect_to_nova = true
					setCommsMessage(_("station-comms","Ok. We've rigged it to contact you when you close communications with us."))
				end)
			end)
		end
	else
		askStationAboutExuari()
		askStationAboutJasminePurdue()
	end
	return option_count
end
function scenarioMissionsUndocked()
	if nova_demo_artifact ~= nil and nova_demo_artifact:isValid() then
		if nova_demo_artifact:isScannedBy(comms_source) then
			addCommsReply(_("station-comms","Investigate anomalous object"),function()
				setCommsMessage(_("station-comms","We discovered a communication interface attached to the anomalous object. We could not make sense of it. Would you like to try?"))
				addCommsReply(_("station-comms","Connect us to object"),function()
					comms_source.connect_to_nova = true
					setCommsMessage(_("station-comms","Ok. We've rigged it to contact you when you close communications with us."))
				end)
			end)			
		end
	elseif final_nova_artifact ~= nil and final_nova_artifact:isValid() then
		askStationAboutExuari()
		askStationAboutJasminePurdue()
		if final_nova_artifact:isScannedBy(comms_source) then
			addCommsReply(_("station-comms","Investigate anomalous object"),function()
				setCommsMessage(_("station-comms","We discovered a communication interface attached to the anomalous object. We could not make sense of it. Would you like to try?"))
				addCommsReply(_("station-comms","Connect us to object"),function()
					comms_source.connect_to_nova = true
					setCommsMessage(_("station-comms","Ok. We've rigged it to contact you when you close communications with us."))
				end)
			end)
		end
	else
		askStationAboutExuari()
		askStationAboutJasminePurdue()
	end
end
function askStationAboutExuari()
	if getScenarioTime() > nova_delay then
		addCommsReply(_("station-comms","Know anything about Exuari activity?"),function()
			if comms_target.exuari_activity == nil then
				if #early_exuari_activity_answers > 0 then
					comms_target.exuari_activity = tableRemoveRandom(early_exuari_activity_answers)
				end
				if comms_target.exuari_activity == nil then
					if getScenarioTime() > nova_delay + (hunt_delay / 2) then
						comms_target.exuari_activity = tableRemoveRandom(exuari_activity_answers)
					end
				end
				if comms_target.exuari_activity == nil then
					if getScenarioTime() > nova_delay + (hunt_delay / 2) then
						comms_target.exuari_activity = _("station-comms","Nothing unusual.")
					else
						comms_target.exuari_activity = _("station-comms","Nothing recently, but things could change.")
					end
				end
				local result = string.find(comms_target.exuari_activity,"Jasmine Purdue")
				if result ~= nil then
					jasmine_purdue_hint = true
					local logged = false
					for i,log_item in ipairs(comms_source.command_log) do
						if string.find(log_item.short,_("station-comms","discovered that Jasmine Purdue is the Exuari expert to talk to")) ~= nil then
							logged = true
							break
						end
					end
					if not logged then
						for i,p in ipairs(getActivePlayerShips()) do
							table.insert(p.command_log,{
								short = string.format(_("station-comms","%s discovered that Jasmine Purdue is the Exuari expert to talk to."),comms_source:getCallSign()),
								time = getScenarioTime(),
								stamp = getScenarioTime(),
								sent = true,
								received = true,
							})
						end
					end
				end
			end
			setCommsMessage(comms_target.exuari_activity)
			if comms_target.exuari_activity == _("station-comms","Nothing recently, but things could change.") then
				comms_target.exuari_activity = nil
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function askStationAboutJasminePurdue()
	if jasmine_purdue_hint then
		addCommsReply(_("station-comms","Know anything about Jasmine Purdue?"),function()
			if comms_target.jasmine_purdue == nil then
				comms_target.jasmine_purdue = tableRemoveRandom(jasmine_purdue_answers)
				if comms_target.jasmine_purdue == nil then
					comms_target.jasmine_purdue = _("station-comms","Never heard of her.")
				end
				if string.find(comms_target.jasmine_purdue,_("station-comms","freighter")) ~= nil then
					jasmine_freighter_hint = true
					local logged = false
					for i,log_item in ipairs(comms_source.command_log) do
						if string.find(log_item.short,_("station-comms","discovered that Jasmine Purdue is working on a freighter")) ~= nil then
							logged = true
							break
						end
					end
					if not logged then
						for i,p in ipairs(getActivePlayerShips()) do
							table.insert(p.command_log,{
								short = string.format(_("station-comms","%s discovered that Jasmine Purdue is working on a freighter."),comms_source:getCallSign()),
								time = getScenarioTime(),
								stamp = getScenarioTime(),
								sent = true,
								received = true,
							})
						end
					end
				end
			end
			setCommsMessage(comms_target.jasmine_purdue)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function scenarioShipMissions()
	if jasmine_freighter_hint then
		local ship_type = comms_target:getTypeName()
		if ship_type:find("Freighter") ~= nil then
			if comms_target:isFriendly(comms_source) then
				if comms_data.friendlyness < 20 then
					local bad_mood_greeting = {
						_("shipAssist-comms", "What do you want?"),
						_("shipAssist-comms", "Why did you contact us?"),
						_("shipAssist-comms", "What is it?"),
						_("shipAssist-comms", "Yeah?"),
					}
					setCommsMessage(tableSelectRandom(bad_mood_greeting))
				elseif comms_data.friendlyness < 70 then
					local average_mood_greeting = {
						_("shipAssist-comms", "What can I do for you?"),
						_("shipAssist-comms", "What's on your mind?"),
						string.format(_("shipAssist-comms", "What can we do for you, %s?"),comms_source:getCallSign()),
						_("shipAssist-comms", "What brings you to us?"),
					}
					setCommsMessage(tableSelectRandom(average_mood_greeting))
				else
					local good_mood_greeting = {
						_("shipAssist-comms", "Sir, how can we assist?"),
						_("shipAssist-comms", "Sir, what can we do to help you?"),
						string.format(_("shipAssist-comms", "Greetings %s, how can we assist?"),comms_source:getCallSign()),
						string.format(_("shipAssist-comms", "How can we help you, %s?"),comms_source:getCallSign()),
					}
					setCommsMessage(tableSelectRandom(good_mood_greeting))
				end
			elseif not comms_target:isEnemy(comms_source) then
				local neutral_freighter_greetings = {
					_("trade-comms","Yes?"),
					_("trade-comms","What?"),
					_("trade-comms","Hmm?"),
					_("trade-comms","State your business."),
				}
				setCommsMessage(tableSelectRandom(neutral_freighter_greetings))
			end
			if jasmine_freighter_identified then
				if jasmine_freighter ~= nil and jasmine_freighter:isValid() then
					addCommsReply(string.format(_("ship-comms","Where can I find %s?"),jasmine_freighter:getCallSign()),function()
						local freighter_target = jasmine_freighter:getOrderTarget()
						if freighter_target ~= nil then
							local tx, ty = freighter_target:getPosition()
							local fx, fy = jasmine_freighter:getPosition()
							local course = angleFromVectorNorth(tx, ty, fx, fy)
							setCommsMessage(string.format(_("ship-comms","Their latest flight plan shows they're going from %s to %s in %s. Their general heading was %s."),jasmine_freighter:getSectorName(),freighter_target:getCallSign(),freighter_target:getSectorName(),math.floor(course)))
						else
							setCommsMessage(string.format(_("ship-comms","Last we heard, they were in %s"),jasmine_freighter:getSectorName()))
						end
					end)
				else
					comms_source:addToShipLog(_("shipLog","Freighter where Jasmine Purdue was working was destroyed. She and the crew moved to another freighter."),"Yellow")
					pickJasmineFreighter()
				end
			end
			addCommsReply(_("ship-comms","What do you know about Jasmine Purdue?"),function()
				if jasmine_freighter == nil then
					pickJasmineFreighter(comms_target)
				else
					if not jasmine_freighter:isValid() then
						comms_source:addToShipLog(_("shipLog","Freighter where Jasmine Purdue was working was destroyed. She and the crew moved to another freighter."),"Yellow")
						pickJasmineFreighter(comms_target)
						if jasmine_freighter_responses == nil or #jasmine_freighter_responses < 1 then
							jasmine_freighter_responses = {
								_("ship-comms","She works on another freighter"),
								string.format(_("ship-comms","She works on freighter %s"),jasmine_freighter:getCallSign()),
							}
						end
					end
				end
				if jasmine_freighter ~= nil and jasmine_freighter:isValid() then
					if jasmine_freighter_responses == nil then
						jasmine_freighter_responses = {
							_("ship-comms","She works on another freighter"),
							string.format(_("ship-comms","She works on freighter %s"),jasmine_freighter:getCallSign()),
						}
					end
					if comms_target == jasmine_freighter then
						comms_target.jasmine_purdue = _("ship-comms","She works here")
						jasmine_freighter_identified = true
						local logged = false
						for i,log_item in ipairs(comms_source.command_log) do
							if string.find(log_item.short,_("ship-comms","discovered that Jasmine Purdue is on freighter")) ~= nil then
								logged = true
								break
							end
						end
						if not logged then
							for i,p in ipairs(getActivePlayerShips()) do
								table.insert(p.command_log,{
									short = string.format(_("ship-comms","%s discovered that Jasmine Purdue is on freighter %s."),comms_source:getCallSign(),jasmine_freighter:getCallSign()),
									time = getScenarioTime(),
									stamp = getScenarioTime(),
									sent = true,
									received = true,
								})
							end
						end
						setCommsMessage(comms_target.jasmine_purdue)
						addCommsReply(_("ship-comms","May I speak with her?"),function()
							jasmineTalksAboutExuari(_("ship-comms","One moment, I'll get her.\n[Jasmine Purdue] Yes? What can I do for you?"))
						end)
					else
						if comms_target.jasmine_purdue == nil then
							if #jasmine_freighter_responses > 0 then
								comms_target.jasmine_purdue = tableRemoveRandom(jasmine_freighter_responses)
							else
								comms_target.jasmine_purdue = _("ship-comms","I know nothing about Jasmine Purdue")
							end
						end
					end
					if string.find(comms_target.jasmine_purdue,_("ship-comms","works on freighter")) ~= nil then
						jasmine_freighter_identified = true
						local logged = false
						for i,log_item in ipairs(comms_source.command_log) do
							if string.find(log_item.short,_("ship-comms","discovered that Jasmine Purdue is on freighter")) ~= nil then
								logged = true
								break
							end
						end
						if not logged then
							for i,p in ipairs(getActivePlayerShips()) do
								table.insert(p.command_log,{
									short = string.format(_("ship-comms","%s discovered that Jasmine Purdue is on freighter %s."),comms_source:getCallSign(),jasmine_freighter:getCallSign()),
									time = getScenarioTime(),
									stamp = getScenarioTime(),
									sent = true,
									received = true,
								})
							end
						end
					end
					setCommsMessage(comms_target.jasmine_purdue)
				else
					--jasmine freighter destroyed
					comms_source:addToShipLog(_("shipLog","Freighter where Jasmine Purdue was working was destroyed. She and the crew moved to another freighter."),"Yellow")
					pickJasmineFreighter()
					jasmine_freighter_responses = nil
					setCommsMessage(_("ship-comms","Try someone else"))
				end
				--	Do not go back. Make player establish communication again
			end)
		end
	end
end
function jasmineTalksAboutExuari(jasmineTalk)
	setCommsMessage(jasmineTalk)
	if jasmineTalk == _("ship-comms","One moment, I'll get her.\n[Jasmine Purdue] Yes? What can I do for you?") then
		addCommsReply(_("ship-comms","We need to know about the Exuari around here"),function()
			setCommsMessage(_("ship-comms","What do you need to know about the Exuari?"))
			jasmineExuariConversationTopics()
		end)
	else
		jasmineExuariConversationTopics()
	end
end
function jasmineExuariConversationTopics()
	addCommsReply(_("ship-comms","What are they up to?"),function()
		exuari_research_purpose_knowledge = true
		setCommsMessage(string.format(_("ship-comms","The Exuari are conducting research at their research base in the area on humor in other species. They believe that other physical research is tangential. However, they have been chasing a tangent related to the causes of stars going nova. They built a 'humorous' device that prematurely triggers a nova. They tested it on %s. They thought it might invoke a humorous response from the %s"),doomed_star_name,player_faction))
		addCommsReply(_("ship-comms","Back to Jasmine topics of conversation"),function()
			jasmineTalksAboutExuari(_("ship-comms","Do you need to know anything else about the Exuari?"))
		end)
		addCommsReply(_("ship-comms","Back to ship communication"),commsShip)
	end)
	if exuari_research_purpose_knowledge then
		addCommsReply(_("ship-comms","Where is their research base located?"),function()
			exuari_research_base_knowledge = true
			if nemesis_station:isValid() then
				setCommsMessage(string.format(_("ship-comms","It's located in sector %s"),nemesis_station_sector))
			else
				setCommsmessage(string.format(_("ship-comms","It used to be located in sector %s, but it has since been destroyed. However, they may have launched the nova device before the station was destroyed."),nemesis_station_sector))
			end
			addCommsReply(_("ship-comms","Back to Jasmine topics of conversation"),function()
				jasmineTalksAboutExuari(_("ship-comms","Do you need to know anything else about the Exuari?"))
			end)
			addCommsReply(_("ship-comms","Back to ship communication"),commsShip)
		end)
	end
	if exuari_research_base_knowledge then
		addCommsReply(_("ship-comms","How do we stop their fireworks display?"),function()
			exuari_fireworks_knowledge = true
			setCommsMessage(_("ship-comms","1) connect to the device's communication array.\n2) Navigate through the UI to the deactivation area.\n3) Provide the numeric deactivation key pin\n\nI hear that stations in the area have figured out how to connect to the device's communication array."))
			addCommsReply(_("ship-comms","Back to Jasmine topics of conversation"),function()
				jasmineTalksAboutExuari(_("ship-comms","Do you need to know anything else about the Exuari?"))
			end)
			addCommsReply(_("ship-comms","Back to ship communication"),commsShip)
		end)
	end
	if exuari_fireworks_knowledge then
		addCommsReply(_("ship-comms","What is the key?"),function()
			if riddle_string == nil then
				print("---------- Spoiler alert, riddle solution info here ----------")
				local death_pool = {
					_("ship-comms","Skull"),
					_("ship-comms","Plague"),
					_("ship-comms","Death"),
					_("ship-comms","Sword"),
					_("ship-comms","Dagger"),
					_("ship-comms","Blade"),
				}
				local humor_pool = {
					_("ship-comms","Joke"),
					_("ship-comms","Punchline"),
					_("ship-comms","Laugh"),
					_("ship-comms","Smile"),
				}
				w_name = tableRemoveRandom(death_pool)
				x_name = tableRemoveRandom(humor_pool)
				y_name = tableRemoveRandom(death_pool)
				z_name = tableRemoveRandom(humor_pool)
				local digits = {1,2,3,4,5,6,7,8,9}
				riddle_w = tableRemoveRandom(digits)
				riddle_x = tableRemoveRandom(digits)
				riddle_y = tableRemoveRandom(digits)
				riddle_z = tableRemoveRandom(digits)
				print(string.format("%s:%s %s:%s %s:%s %s:%s",w_name,riddle_w,x_name,riddle_x,y_name,riddle_y,z_name,riddle_z))
				print("---------- End of riddle spoiler ----------")
				local puzzle_pieces = {
					{name = w_name, value = riddle_w},
					{name = x_name, value = riddle_x},
					{name = y_name, value = riddle_y},
					{name = z_name, value = riddle_z},
				}
				for i=1,4 do
					local piece = tableRemoveRandom(puzzle_pieces)
					if solution_name_string == nil then
						solution_name_string = string.format(_("ship-comms","Key: %s"),piece.name)
					else
						solution_name_string = string.format("%s, %s",solution_name_string,piece.name)
					end
					if solution_value_string == nil then
						solution_value_string = string.format("%s",piece.value)
					else
						solution_value_string = string.format("%s%s",solution_value_string,piece.value)
					end
				end
				equation_1 = string.format(_("ship-comms","%s and %s make %s."),w_name,w_name,riddle_w*2)
				if riddle_w > riddle_x then	--	lo to hi: x,w
					equation_2 = string.format(_("ship-comms","%s is %s and %s."),w_name,x_name,riddle_w - riddle_x)
					if riddle_y > riddle_w then	--	lo to hi: x,w,y
						if riddle_w + riddle_x > riddle_y then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s and %s."),w_name,x_name,(riddle_w + riddle_x) - riddle_y,y_name)
						elseif riddle_w + riddle_x < riddle_y then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s minus %s."),w_name,x_name,y_name,riddle_y - (riddle_w + riddle_x))
						else
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s."),w_name,x_name,y_name)
						end
						if riddle_z > riddle_y then	--	lo to hi: x,w,y,z
							equation_4 = string.format(_("ship-comms","%s is more than %s."),z_name,y_name)
						else
							if riddle_z > riddle_w then	--	lo to hi: x,w,z,y
								equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,w_name,y_name)
							else
								if riddle_z > riddle_x then	--	lo to hi: x,z,w,y
									equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,x_name,w_name)
								else	--	lo to hi: z,x,w,y
									equation_4 = string.format(_("ship-comms","%s is less than %s."),z_name,x_name)
								end
							end
						end
					else	--	lo to hi: y,x,w or x,y,w
						if riddle_y + riddle_x > riddle_w then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s and %s."),y_name,x_name,(riddle_y + riddle_x) - riddle_w,w_name)
						elseif riddle_y + riddle_x < riddle_w then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s minus %s."),y_name,x_name,w_name,riddle_w - (riddle_y + riddle_x))
						else
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s."),y_name,x_name,w_name)
						end
						if riddle_z > riddle_w then	--	lo to hi: y,x,w,z or x,y,w,z
							equation_4 = string.format(_("ship-comms","%s is more than %s."),z_name,w_name)
						else
							if riddle_y < riddle_x then	--	lo to hi: y,x,w
								if riddle_z > riddle_x then	--	lo to hi: y,x,z,w
									equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,x_name,w_name)
								else
									if riddle_z < riddle_y then	--	lo to hi: z,y,x,w
										equation_4 = string.format(_("ship-comms","%s is less than %s."),z_name,y_name)
									else	--	lo to hi: y,z,x,w
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,y_name,x_name)
									end
								end
							else	--	lo to hi: x,y,w
								if riddle_z < riddle_x then	--	lo to hi: z,x,y,w
									equation_4 = string.format(_("ship-comms","%s is less than %s."),z_name,x_name)
								else
									if riddle_z < riddle_y then	--	lo to hi: x,z,y,w
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,x_name,y_name)
									else	--	lo to hi: x,y,z,w
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,y_name,w_name)
									end
								end
							end
						end
					end
				else
					equation_2 = string.format(_("ship-comms","%s is %s and %s"),x_name,w_name,riddle_x - riddle_w)
					if riddle_y > riddle_x then	--	lo to hi: w,x,y
						if riddle_w + riddle_x > riddle_y then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s and %s."),w_name,x_name,(riddle_w + riddle_x) - riddle_y,y_name)
						elseif riddle_w + riddle_x < riddle_y then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s minus %s."),w_name,x_name,y_name,riddle_y - (riddle_w + riddle_x))
						else
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s."),w_name,x_name,y_name)
						end
						if riddle_z > riddle_y then
							equation_4 = string.format(_("ship-comms","%s is more than %s"),z_name,y_name)
						end
					else	--	lo to hi: y,w,x or w,y,x
						if riddle_y + riddle_w > riddle_x then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s and %s."),y_name,w_name,(riddle_y + riddle_w) - riddle_x,x_name)
						elseif riddle_y + riddle_w < riddle_x then
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s minus %s."),y_name,w_name,x_name,riddle_x - (riddle_y + riddle_w))
						else
							equation_3 = string.format(_("ship-comms","%s and %s is the same as %s."),y_name,w_name,x_name)
						end
						if riddle_z > riddle_x then	--	lo to hi: y,w,x,z or w,y,x,z
							equation_4 = string.format(_("ship-comms","%s is more than %s."),z_name,x_name)
						else
							if riddle_y > riddle_w then	--	lo to hi: w,y,x
								if riddle_z < riddle_w then	--	lo to hi: z,w,y,x
									equation_4 = string.format(_("ship-comms","%s is less than %s."),z_name,w_name)
								else
									if riddle_z < riddle_y then	--	lo to hi: w,z,y,x
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,w_name,y_name)
									else	--	lo to hi: w,y,z,x
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,y_name,x_name)
									end
								end
							else	--	lo to hi: y,w,x
								if riddle_z < riddle_y then	--	lo to hi: z,y,w,x
									equation_4 = string.format(_("ship-comms","%s is less than %s."),z_name,y_name)
								else
									if riddle_z < riddle_w then	--	lo to hi: y,z,w,x
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,y_name,w_name)
									else	--	lo to hi: y,w,z,x
										equation_4 = string.format(_("ship-comms","%s is more than %s and less than %s."),z_name,w_name,x_name)
									end
								end
							end
						end
					end
				end
				local equation_pieces = {
					equation_1,
					equation_2,
					equation_3,
					equation_4,
				}
				for i=1,4 do
					if riddle_string == nil then
						riddle_string = string.format(_("ship-comms","%s.\n%s"),solution_name_string,tableRemoveRandom(equation_pieces))
					else
						riddle_string = string.format(_("ship-comms","%s\n%s"),riddle_string,tableRemoveRandom(equation_pieces))
					end
				end
			end
			local logged = false
			for i,log_item in ipairs(comms_source.command_log) do
				if string.find(log_item.short,_("ship-comms","got riddle from Jasmine Purdue")) ~= nil then
					logged = true
					break
				end
			end
			if not logged then
				for i,p in ipairs(getActivePlayerShips()) do
					table.insert(p.command_log,{
						short = string.format(_("ship-comms","%s got riddle from Jasmine Purdue:\n%s"),comms_source:getCallSign(),riddle_string),
						time = getScenarioTime(),
						stamp = getScenarioTime(),
						sent = true,
						received = true,
					})
				end
			end
			setCommsMessage(string.format(_("ship-comms","I ran across this riddle associated to the device. I have not deciphered it yet. The solution should provide you with the control code for the Exuari device.\n\n%s"),riddle_string))
			addCommsReply(_("ship-comms","Back to Jasmine topics of conversation"),function()
				jasmineTalksAboutExuari(_("ship-comms","Do you need to know anything else about the Exuari?"))
			end)
			addCommsReply(_("ship-comms","Back to ship communication"),commsShip)
		end)
	end
end
function pickJasmineFreighter(exclude)
	local jasmine_freighter_pool = {}
	for i,transport in ipairs(transport_list) do
		if transport ~= nil and transport:isValid() then
			if exclude ~= nil and transport ~= exclude then
				if transport:isFriendly(comms_source) then
					table.insert(jasmine_freighter_pool,transport)
				elseif not transport:isEnemy(comms_source) then
					table.insert(jasmine_freighter_pool,transport)
				end
			end
		end
	end
	jasmine_freighter = tableSelectRandom(jasmine_freighter_pool)
end
function commsNova()
	local standard_greeting = _("artifact-comms","Welcome to the Nova Fireworks Display\nA fine product of the Exuari Exclamatory Enterprise")
	if comms_target == nova_demo_artifact then
		standard_greeting = string.format(_("artifact-comms","%s\nAlpha Release"),standard_greeting)
	else
		standard_greeting = string.format(_("artifact-comms","%s\nBeta Release"),standard_greeting)
	end
	setCommsMessage(standard_greeting)
	addCommsReply(_("artifact-comms","Description"),function()
		setCommsMessage(_("artifact-comms","The Nova Fireworks Display is the latest offering from the Exuari Exclamatory Enterprise. It offers the finest experience in species death and destruction humor. Set the device on its way and at the designated star and the designated time, the star will go nova wreaking hilarious havoc on hapless aliens in the area. You'll get hours of entertainment from copious amounts of death, destruction, maiming and panic - all the hallmarks of the finest amusement available to the Exuari."))
		comms_target.description_presented = true
		addCommsReply(_("artifact-comms","Back"),commsNova)
	end)
	addCommsReply(_("artifact-comms","Safety Considerations"),function()
		setCommsMessage(_("artifact-comms","The degree of hilarity induced in typical Exuari may cause excessive laughter. Symptoms include coughing, fluid from eyes (tears), sore cheek muscles and sore ribs due to extended smiling and laughing. Be aware and take the necessary precautions."))
		comms_target.safety_presented = true
		addCommsReply(_("artifact-comms","Back"),commsNova)
	end)
	if comms_target.safety_presented and comms_target.description_presented and comms_target == final_nova_artifact then
		addCommsReply(_("artifact-comms","Control Panel"),function()
			setCommsMessage(_("artifact-comms","This is where you set up your Nova Fireworks experience. If you have questions, contact your nearest Exuari Exclamatory Enterprise Executive for assistance."))
			addCommsReply(_("artifact-comms","Set Destination"),function()
				setCommsMessage(string.format(_("artifact-comms","The Nova Fireworks destination has already been set to %s"),rescue_star:getCallSign()))
				addCommsReply(_("artifact-comms","Back"),commsNova)
			end)
			addCommsReply(_("artifact-comms","Set Time"),function()
				local time_remaining = final_nova_artifact.arrival_time - getScenarioTime()
				setCommsMessage(string.format(_("artifact-comms","The Nova Fireworks time has already been set. Remaining time: %s seconds"),math.floor(time_remaining)))
				--	add timer here
				addCommsReply(_("artifact-comms","Back"),commsNova)
			end)
			addCommsReply(_("artifact-comms","Pause Nova Fireworks"),function()
				local preview = ""
				if control_code_diagnostic then
					preview = solution_value_string
				end
				setCommsMessage(string.format(_("artifact-comms","You may only pause Nova Fireworks if you enter your four digit control code.\nEnter first digit\n%s"),preview))
				for i=1,9 do
					addCommsReply(string.format(_("artifact-comms","First digit is %i"),i),function()
						setCommsMessage(string.format(_("artifact-comms","First digit entered: %s\nEnter second digit\n%s"),i,preview))
						for j=1,9 do
							addCommsReply(string.format(_("artifact-comms","Second digit is %i"),j),function()
								setCommsMessage(string.format(_("artifact-comms","Digits entered: %s%s\nEnter third digit\n%s"),i,j,preview))
								for k=1,9 do
									addCommsReply(string.format(_("artifact-comms","Third digit is %i"),k),function()
										setCommsMessage(string.format(_("artifact-comms","Digits entered: %s%s%s\nEnter fourth digit\n%s"),i,j,k,preview))
										for l=1,9 do
											addCommsReply(string.format(_("artifact-comms","Fourth digit is %i"),l),function()
												local comparison_code = string.format("%s%s%s%s",i,j,k,l)
												if comparison_code == solution_value_string then
													setCommsMessage(_("artifact-comms","Nova Fireworks paused"))
													globalMessage(_("msgMainscreen","You stopped the Exuari fireworks display (nova)"))
													victory(player_faction)
												else
													if control_code_diagnostic then
														preview = string.format("Entered:%s Control:%s",comparison_code,preview)
													end
													setCommsMessage(string.format(_("artifact-comms","Incorrect code.\nExuari Exclamatory Enterprise wishes you an amusing day.\n%s"),preview))
												end
												addCommsReply(_("artifact-comms","Back"),commsNova)
											end)
										end
										addCommsReply(_("artifact-comms","Back"),commsNova)
									end)
								end
								addCommsReply(_("artifact-comms","Back"),commsNova)
							end)
						end
						addCommsReply(_("artifact-comms","Back"),commsNova)
					end)
				end
				addCommsReply(_("artifact-comms","Back"),commsNova)
			end)
			addCommsReply(_("artifact-comms","Back"),commsNova)
		end)
	end
end
function talkToNovaDemo(p)
	if p.connect_to_nova then
		if availableForComms(p) then
			if nova_demo_artifact ~= nil and nova_demo_artifact:isValid() then
				nova_demo_artifact:setCallSign(_("artifact-comms","Anomalous object"))
				nova_demo_artifact:openCommsTo(p)
				nova_demo_artifact:setCallSign("")
			elseif final_nova_artifact ~= nil and final_nova_artifact:isValid() then
				final_nova_artifact:setCallSign(_("artifact-comms","Anomalous object"))
				final_nova_artifact:openCommsTo(p)
				final_nova_artifact:setCallSign("")
			end
			p.connect_to_nova = false
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
--	Update player ship functions
function powerSensorEnabledButtons(p)
	p.power_sensor_state = "enabled"
	updatePowerSensorButtons(p)
end
function powerSensorStandbyButtons(p)
	p.power_sensor_state = "standby"
	updatePowerSensorButtons(p)
end
function updatePowerSensorButtons(p)
	if p.power_sensor_button ~= nil then
		for console, button in pairs(p.power_sensor_button) do
			p:removeCustom(button)
		end
		p.power_sensor_button = nil
	end
	if p.power_sensor_state == "disabled" then
		--do nothing: initial loop removes buttons
	elseif p.power_sensor_state == "standby" then
		p.power_sensor_button = {}
		p:addCustomButton("Engineering","power_sensor_button_standby_eng",_("buttonEngineer","Boost Sensors"),function()
			string.format("")
			powerSensorConfigButtons(p)
		end,30)
		p.power_sensor_button["Engineering"] = "power_sensor_button_standby_eng"
		p:addCustomButton("Engineering+","power_sensor_button_standby_plus",_("buttonEngineer+","Boost Sensors"),function()
			string.format("")
			powerSensorConfigButtons(p)
		end,30)
		p.power_sensor_button["Engineering+"] = "power_sensor_button_standby_plus"
	elseif p.power_sensor_state == "configure" then
		p.power_sensor_button = {}
		for i=1,3 do
			p:addCustomButton("Engineering",string.format("power_sensor_button_config_eng%i",i),string.format(_("buttonEngineer","Sensor Boost %i"),i),function()
				string.format("")
				p.power_sensor_level = i
				powerSensorEnabledButtons(p)
			end,30 + i)
			p.power_sensor_button[string.format("Engineering %i",i)] = string.format("power_sensor_button_config_eng%i",i)
		end
		for i=1,3 do
			p:addCustomButton("Engineering+",string.format("power_sensor_button_config_plus%i",i),string.format(_("buttonEngineer+","Sensor Boost %i"),i),function()
				string.format("")
				p.power_sensor_level = i
				powerSensorEnabledButtons(p)
			end,30 + i)
			p.power_sensor_button[string.format("Engineering+ %i",i)] = string.format("power_sensor_button_config_plus%i",i)
		end
	elseif p.power_sensor_state == "enabled" then
		p.power_sensor_button = {}
		p:addCustomButton("Engineering","power_sensor_button_enabled_eng",_("buttonEngineer","Stop Sensor Boost"),function()
			string.format("")
			powerSensorStandbyButtons(p)
		end,30)
		p.power_sensor_button["Engineering"] = "power_sensor_button_enabled_eng"
		p:addCustomButton("Engineering+","power_sensor_button_enabled_plus",_("buttonEngineer+","Stop Sensor Boost"),function()
			string.format("")
			powerSensorStandbyButtons(p)
		end,30)
		p.power_sensor_button["Engineering+"] = "power_sensor_button_enabled_plus"
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
		for i,station in ipairs(outer_stations) do
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
--	Scenario specific update functions
function cloakDevice()
	if cloak_level > 0 then
		if cloak_time == nil then
			cloak_time = getScenarioTime() + cloak_level
			cloak_count = 0
		elseif getScenarioTime() > cloak_time then
			if cloak_count < 3 then
				if nova_demo_artifact ~= nil and nova_demo_artifact:isValid() then
					nova_demo_artifact:setRadarTraceColor(math.random(30,255),math.random(30,255),math.random(30,255))
				end
				if final_nova_artifact ~= nil and final_nova_artifact:isValid() then
					final_nova_artifact:setRadarTraceColor(math.random(30,255),math.random(30,255),math.random(30,255))
				end
			elseif cloak_count == 3 then
				if nova_demo_artifact ~= nil and nova_demo_artifact:isValid() then
					nova_demo_artifact:setRadarTraceColor(20,20,20)
				end
				if final_nova_artifact ~= nil and final_nova_artifact:isValid() then
					final_nova_artifact:setRadarTraceColor(20,20,20)
				end
				cloak_time = nil
			end
			cloak_count = cloak_count + 1
		end
	end
end
function proactiveExuari()
	if mid_fleet_launched then
		if mid_player_fleets ~= nil then
			local player_count = 0
			for p,val in pairs(mid_player_fleets) do
				player_count = player_count + 1
				if p:isValid() then
					if p.mid_fleet_jammed then
						mid_player_fleets[p] = nil
						break
					else
						for i,ship in ipairs(mid_player_fleets[p]) do
							if ship ~= nil and ship:isValid() then
								if distance(p,ship) < 6000 then
									local sx,sy = ship:getPosition()
									WarpJammer():setPosition(sx,sy):setRange(random(10000,15000)):setHull(random(40,90))
									p.mid_fleet_jammed = true
								end
							end
						end
					end
				else
					mid_player_fleets[p] = nil
					break
				end
			end
			if player_count < 1 then
				mid_player_fleets = nil
			end
		end
	else
		if getScenarioTime() > nova_delay + (hunt_delay / 2) then
			local mid_fleet = {}
			fleetComposition = "Warpers"
			local template_pool_strength = math.max(enemy_power * playerPower(),5)
			local enemy_pool = getTemplatePool(template_pool_strength)
			local fleet = spawnEnemies(0,0,1,"Exuari",template_pool_strength,enemy_pool)
			for i,ship in ipairs(fleet) do
				table.insert(mid_fleet,ship)
			end
			fleetComposition = "Jumpers"
			enemy_pool = getTemplatePool(template_pool_strength)
			fleet = spawnEnemies(0,0,1,"Exuari",template_pool_strength,enemy_pool)
			for i,ship in ipairs(fleet) do
				table.insert(mid_fleet,ship)
			end
			fleetComposition = "Random"
			enemy_pool = getTemplatePool(template_pool_strength)
			fleet = spawnEnemies(0,0,1,"Exuari",template_pool_strength,enemy_pool)
			for i,ship in ipairs(fleet) do
				table.insert(mid_fleet,ship)
			end
			local player_ships = {}
			for i,p in ipairs(getActivePlayerShips()) do
				local x, y = p:getPosition()
				x = (x + nemesis_x)/2
				y = (y + nemesis_y)/2
				table.insert(player_ships,{p=p,x=x,y=y})
			end
			local j=0
			mid_player_fleets = {}
			for i,ship in ipairs(mid_fleet) do
				j = j + 1
				if j > #player_ships then
					j = 1
				end
				local p = player_ships[j].p
				ship:setPosition(player_ships[j].x + formation_delta["hexagonal"].x[i] * 500,player_ships[j].y + formation_delta["hexagonal"].y[i] * 500)
				ship:orderAttack(p)
				if mid_player_fleets[p] == nil then
					mid_player_fleets[p] = {}
					p.mid_fleet_jammed = false
				end
				table.insert(mid_player_fleets[p],ship)
			end
			mid_fleet_launched = true
		end
	end
end
function nemesisDestroyed()
	if getScenarioTime() > nova_delay then
		if not final_nova_artifact_created then
			if nemesis_station ~= nil then
				if not nemesis_station:isValid() then
					globalMessage(_("msgMainscreen","You destroyed the Exuari research station before they deployed their nova fireworks device"))
					victory(player_faction)
				end
			else
				globalMessage(_("msgMainscreen","You destroyed the Exuari research station before they deployed their nova fireworks device"))
				victory(player_faction)
			end
		end
	end
end
function nemesisDefenseOrbit(delta)
	if nemesis_defense ~= nil then
		if #nemesis_defense > 0 then
			for i,dp in ipairs(nemesis_defense) do
				if dp ~= nil and dp:isValid() then
					dp.angle = (dp.angle + delta) % 360
					local dp_x, dp_y = vectorFromAngleNorth(dp.angle,3000)
					dp_x = dp_x + nemesis_x
					dp_y = dp_y + nemesis_y
					dp:setPosition(dp_x,dp_y)
				else
					nemesis_defense[i] = nemesis_defense[#nemesis_defense]
					nemesis_defense[#nemesis_defense] = nil
					break
				end
			end
		end
	end
end
--	Minor enemy attack functions
function minorTrap()
	if minor_trap_set == nil then
		fleetComposition = "Warpers"
		minor_trap_fleet = {}
		local template_pool_strength = math.max(enemy_power * playerPower(),5)
		local pincer_pool = getTemplatePool(template_pool_strength)
		local pincer_fleet = spawnEnemies(right_pincer.x,right_pincer.y,1,minor_enemy,template_pool_strength,pincer_pool)
		for i,ship in ipairs(pincer_fleet) do
			ship:orderFlyTowards(player_spawn_x,player_spawn_y)
			table.insert(minor_trap_fleet,ship)
			table.insert(minor_trap_ships,ship)
		end
		fleetComposition = "Jumpers"
		pincer_pool = getTemplatePool(math.max(enemy_power * playerPower(),5))
		pincer_fleet = spawnEnemies(left_pincer.x,left_pincer.y,1,minor_enemy,math.max(enemy_power * playerPower(),5),pincer_pool)
		for i,ship in ipairs(pincer_fleet) do
			ship:orderFlyTowards(player_spawn_x,player_spawn_y)
			table.insert(minor_trap_fleet,ship)
			table.insert(minor_trap_ships,ship)
		end
		fleetComposition = "Random"
		pincer_pool = getTemplatePool(math.max(enemy_power * playerPower(),5))
		local mes_x, mes_y = minor_enemy_station:getPosition()
		pincer_fleet = spawnEnemies(mes_x,mes_y,1,minor_enemy,math.max(enemy_power * playerPower(),5),pincer_pool)
		for i,ship in ipairs(pincer_fleet) do
			ship:orderFlyTowards(player_spawn_x,player_spawn_y)
			table.insert(minor_trap_fleet,ship)
			table.insert(minor_trap_ships,ship)
		end
		minor_trap_set = "initialized"
	elseif minor_trap_set == "initialized" then
		if minor_trap_fleet ~= nil and #minor_trap_fleet > 0 then
			local clean_list = true
			for i,ship in ipairs(minor_trap_fleet) do
				if ship == nil or not ship:isValid() then
					minor_trap_fleet[i] = minor_trap_fleet[#minor_trap_fleet]
					minor_trap_fleet[#minor_trap_fleet] = nil
					clean_list = false
					break
				end
			end
			if clean_list then
				for i,ship in ipairs(minor_trap_fleet) do
					if string.find(ship:getOrder(),"Defend") ~= nil then
						ship:orderRoaming()
						minor_trap_fleet[i] = minor_trap_fleet[#minor_trap_fleet]
						minor_trap_fleet[#minor_trap_fleet] = nil
						break
					end
				end
			end
		else
			minor_trap_set = "done"
		end
	end
end
function minorAmbush(p)
	local ambush = false
	for j,ship in ipairs(minor_enemy_ambush) do
		if ship ~= nil and ship:isValid() then
			if distance(ship,p) < 5000 then
				ambush = true
				break
			end
		end
	end
	if ambush then
		for j,ship in ipairs(minor_enemy_ambush) do
			if ship ~= nil and ship:isValid() then
				ship:orderRoaming()
			end
		end
		minor_enemy_ambush = nil
	end
end
function update(delta)
	if delta == 0 then
		--game paused
		return
	end
	minorTrap()
	novaDemoArtifact()
	missionMessages()
	maintainTransports()
	cloakDevice()
	proactiveExuari()
	if process_ejecta then
		processEjecta()
	end
	for i,p in ipairs(getActivePlayerShips()) do
		if minor_enemy_ambush ~= nil then
			minorAmbush(p)
		end
		talkToNovaDemo(p)
		updatePlayerLongRangeSensors(delta,p)
	end
	nemesisDefenseOrbit(delta)
	nemesisDestroyed()
	finalNova()
end