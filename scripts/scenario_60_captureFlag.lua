-- Name: Capture the Flag
-- Description: Capture opposing team's "flag" before they capture yours
--- 
--- The region consists of two halves divided by a line of nebulae and/or markers. The first 5 minutes (configurable) each side decides where to place their flag. The ships closest to the referee station determine the team's flag location during the initial phase. Crossing to the other side during this phase will result in ship destruction. The weapons officer will mark the flag coordinates when the ship reaches the flag location. After the flag hide timer expires, an artifact will be placed at the location representing the team's flag. If no place has been marked, the ship's current location will be used. If the location is outside the game boundaries, the flag will be placed at the nearest in bounds location
---
--- Once the flags are placed, the hunt is on. Ships may cross the border in search of the other team's flag, but while they are in the other team's territory they may be tagged by an opponent ship within 0.75U. Being tagged sends you back to your own region with damage to your warp/jump drive. Each flag must be scanned before it can be retrived. Retrieval occurs by getting within 1U of the flag. Being tagged while in posession of the flag drops the flag at the location of the tag event. Cross back to your side with the flag to claim victory
---
--- Version 2
-- Author: Xansta & Kilted-Klingon
-- Category: PvP
-- Setting[Terrain]: Selects the type of terrain for the game
-- Terrain[Asymmetric|Default]: No effort made to make the two sides of the arena equivalent
-- Terrain[Empty]: No terrain. Used primarily for testing
-- Terrain[Passing]: Just passing by. Symmetric, black holes on each side
-- Terrain[Symmetric]: Randomly symmetric
-- Terrain[Rabbit]: Down the rabbit hole. Largely symmetric. Wormholes connect each side.
-- Setting[Enemies]: Configures strength and/or number of external enemies in this scenario
-- Enemies[None|Default]: No external enemies
-- Enemies[Easy]: Fewer or weaker enemies
-- Enemies[Normal]: Normal number or strength of enemies
-- Enemies[Hard]: More or stronger enemies
-- Enemies[Extreme]: Much stronger, many more enemies
-- Enemies[Quixotic]: Insanely strong and/or inordinately large numbers of enemies
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you
-- Setting[Arena]: Configures the size of the playing arena. Default is normal or 100 units
-- Arena[Normal|Default]: Normal 100 unit sized arena
-- Arena[Small]: Small 50 unit sized arena
-- Arena[Large]: Large 200 unit sized arena
-- Setting[Flag Scan]: Configures the depth and complexity required to scan a flag. Default is normal: depth is 2 or 3, complexity is 2
-- Flag Scan[Normal|Default]: Depth is 2 or 3, complexity is 2
-- Flag Scan[Easy]: Depth is 1, complexity is 1 or 2
-- Flag Scan[Hard]: Depth is 1, 2 or 3, complexity is 3 or 4
-- Setting[Tracking]: Configures information given about flag.
-- Tracking[Normal|Default]: Drop: Kraylor or Human Navy flag dropped (main  screen). Grab: The Kraylor or Human Navy picked up your flag (main screen and ship log)
-- Tracking[Easy]: Drop: ShipName dropped Kraylor or Human Navy flag (main screen). Grab: Kraylor or Human Navy ship ShipName picked up your flag (main screen and ship log)
-- Tracking[Hard]: Drop: Flag dropped (main screen). Grab: Flag obtained (main screen). Flag must be rescanned after drop
-- Tracking[Secret]: Neither dropping nor grabbing the flag will produce a message. Flag must be rescanned after drop

require("utils.lua")
require("place_station_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")

function init()
	scenario_version = "2.0.1"
	print(string.format("     -----     Scenario: Capture the Flag     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	presetOptionVariables()	--set up any preset team data
	setConstants()			--things that don't change
	setGlobals()			--things that don't change often
	setVariations()			--configuration items based on game set up screen. Many can also be set via GM button while paused
	diagnostic = false 		-- See GM button. A boolean for printing debug data to the console during development; turn to "false" during game play 
	-- Initialization checklist by function
	initializeDroneButtonFunctionTables()
	setGMButtons()
	setupTailoredShipAttributes()  -- player ship names: lists of names to be selected from at random if ship names were not predetermined in presetOptionalVariables
	setupBarteringGoods() -- part of Xansta's larger overall bartering/crafting setup
	terrainType()  -- sets up the environment terrain according to the choice above
	plotTeamDemarcationLine()
	plotFlagPlacementBoundaries()
	-- Print initialization items to console
	wfv = "end of init"		--diagnostic tool: wolf fence value
	print("  Initial Configuration:")
	print("    Flag hiding time limit:  " .. hideFlagTime/60 .. " minutes")
	print("    Game Time Limit:  " .. gameTimeLimit/60 .. " minutes")
	print("    Scan probes allocated per ship:  " .. revisedPlayerShipProbeCount)
	print("    Are drones allowed? " .. tostring(dronesAreAllowed))
	print("    (Uniform) Drone carrying capacity for player ships: " .. uniform_drone_carrying_capacity)
	print("    Drone scanning range for flags/decoys:  " .. drone_scan_range_for_flags)
	print("  ")
	print("-----     All of the above initial configuration settings may be adjusted by GM button. ")
	print("-----     So don't count on these values to remain accurate as shown here in the console.")
end
function presetOptionVariables()
	--[[
	--If you insert a custom ship_name here, be sure to remove it from the pool of random names
	preset_players = {}
	--1st ship spawned: Maverick
	table.insert(preset_players, 
		{
			xo = "Starry",				--1st choice
			ship_name = "Phoenix",
			faction = "Human Navy",
			ship_pref_1 = "Maverick",	--pref 2
			ship_pref_2 = "Nautilus",	--pref 1
			ship_pref_3 = "Player Cruiser",
		}
	)
	table.insert(preset_players, 
		{
			xo = "Aldric",				--3rd choice
			faction = "Kraylor",
			ship_name = "Durance",
			ship_pref_1 = "Maverick",	--pref 2
			ship_pref_2 = "Atlantis",	--pref 1
			ship_pref_3 = "Crucible",
			ship_pref_4 = "Piranha",
			ship_pref_5 = "Player Cruiser",
			ship_pref_6 = "Player Missile Cr.",
		}
	)
	--2nd ship spawned: Atlantis
	table.insert(preset_players, 
		{
			xo = "Larry",
			ship_name = "Mondo",
			faction = "Human Navy",
		}
	)
	table.insert(preset_players, 
		{
			xo = "Epeac",				--2nd choice
			faction = "Kraylor",
			ship_name = "Dauntless",
			ship_pref_1 = "Atlantis",
			ship_pref_2 = "Maverick",
			ship_pref_3 = "Crucible",
		}
	)
	--3rd ship spawned: Phobos M3P
	table.insert(preset_players, 
		{
			xo = "Lupus",				--5th choice
			faction = "Human Navy",
			ship_name = "Harbinger",
			ship_pref_1 = "PhobosM3P",		--Lupus prefers warp
			ship_pref_4 = "Atlantis",		--Theta pref 1
			ship_pref_2 = "Crucible",
			ship_pref_3 = "Maverick",
		}
	)
	table.insert(preset_players, 
		{
			xo = "Daid",
			faction = "Kraylor",
			ship_name = "UltiShiptastic",
		}
	)
	--4th ship spawned: Crucible
	table.insert(preset_players, 
		{
			xo = "Mo",
			ship_name = "Shotgun",
			faction = "Human Navy",
		}
	)
	table.insert(preset_players, 
		{
			xo = "Theta",				--4th choice
			faction = "Kraylor",
			ship_name = "Prokop",
			ship_pref_1 = "Crucible",	--pref 2
			ship_pref_2 = "Atlantis",	--pref 1
			ship_pref_3 = "Maverick",
			ship_pref_4 = "Phobos M3P",
		}
	)
	--5th ship spawned: Flavia P.Falcon
	table.insert(preset_players, 
		{
			xo = "Curly",
			ship_name = "Jayhawk",
			faction = "Human Navy",
		}
	)
	table.insert(preset_players, 
		{
			xo = "AJ",
			ship_name = "Roc",
			faction = "Kraylor",
		}
	)
	--6th ship spawned: Repulse
	table.insert(preset_players, 
		{
			xo = "Shemp",
			ship_name = "Lizard",
			faction = "Human Navy",
		}
	)
	table.insert(preset_players, 
		{
			xo = "Hemmond",
			faction = "Kraylor",
			ship_name = "Sentinel",
		}
	)
	--7th ship spawned: Player Missile Cr.
	table.insert(preset_players, 
		{
			xo = "Ted",
			ship_name = "Cremator",
			faction = "Human Navy",
		}
	)
	table.insert(preset_players, 
		{
			xo = "Hermann",
			ship_name = "Charger",
			faction = "Kraylor",
		}
	)
	--]]
end
function setConstants()
	player_wing_names = {
		[2] = {
			"Alpha","Red",
		},
		[4] = {
			"Alpha",	"Red",
			"Bravo",	"Blue",
		},
		[6] = {
			"Alpha",	"Red",
			"Bravo",	"Blue",
			"Charlie",	"Green",
		},
		[8] = {
			"Alpha 1",	"Red 1",
			"Alpha 2",	"Red 2",
			"Bravo 1",	"Blue 1",
			"Bravo 2",	"Blue 2",
		},
		[10] = {
			"Alpha 1",	"Red 1",
			"Alpha 2",	"Red 2",
			"Bravo 1",	"Blue 1",
			"Bravo 2",	"Blue 2",
			"Charlie",	"Green",
		},
		[12] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
		},
		[14] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
		},
		[16] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
		},
		[18] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
		},
		[20] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
		},
		[22] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
		},
		[24] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[26] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[28] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Bravo 4",		"Blue 4",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[30] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Bravo 4",		"Blue 4",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Charlie 4",	"Green 4",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
		},
		[32] = {
			"Alpha 1",		"Red 1",
			"Alpha 2",		"Red 2",
			"Alpha 3",		"Red 3",
			"Alpha 4",		"Red 4",
			"Bravo 1",		"Blue 1",
			"Bravo 2",		"Blue 2",
			"Bravo 3",		"Blue 3",
			"Bravo 4",		"Blue 4",
			"Charlie 1",	"Green 1",
			"Charlie 2",	"Green 2",
			"Charlie 3",	"Green 3",
			"Charlie 4",	"Green 4",
			"Delta 1",		"Yellow 1",
			"Delta 2",		"Yellow 2",
			"Delta 3",		"Yellow 3",
			"Delta 4",		"Yellow 4",
		},
	}
	player_ship_stats = {	
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, probes = 10,	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, probes = 15,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, probes = 27	,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 15,	},
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 25,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 22,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 26,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, probes = 11,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 20,	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, probes = 20,	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, probes = 17,	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, probes = 12,	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, probes = 35,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, probes = 24,	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, probes = 23,	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 20,	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 18,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 20,	},
	}
	ship_template = {	--ordered by relative strength
		["Ktlitan Drone"] =		{strength = 4,		create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["Adder MK3"] =			{strength = 5,		create = stockTemplate},
		["Adder MK4"] =			{strength = 6,		create = stockTemplate},
		["Fighter"] =			{strength = 6,		create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,		create = stockTemplate},
		["Adder MK5"] =			{strength = 7,		create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,		create = stockTemplate},
		["Adder MK6"] =			{strength = 8,		create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,		create = stockTemplate},
		["Adder MK7"] =			{strength = 9,		create = stockTemplate},
		["Adder MK8"] =			{strength = 10,		create = stockTemplate},
		["Adder MK9"] =			{strength = 11,		create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,		create = stockTemplate},
		["Missile Cruiser"] =	{strength = 14,		create = stockTemplate},
		["Phobos T3"] =			{strength = 15,		create = stockTemplate},
		["Piranha F8"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,		create = stockTemplate},
		["Phobos M3"] =			{strength = 16,		create = stockTemplate},
		["Karnack"] =			{strength = 17,		create = stockTemplate},
		["Gunship"] =			{strength = 17,		create = stockTemplate},
		["Cruiser"] =			{strength = 18,		create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,		create = stockTemplate},
		["Nirvana R5A"] =		{strength = 20,		create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,		create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 21,		create = stockTemplate},
		["Storm"] =				{strength = 22,		create = stockTemplate},
		["Stalker R5"] =		{strength = 22,		create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,		create = stockTemplate},
		["Ranus U"] =			{strength = 25,		create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,		create = stockTemplate},
		["Stalker R7"] =		{strength = 25,		create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,		create = stockTemplate},
		["Elara P2"] =			{strength = 28,		create = stockTemplate},
		["Strikeship"] =		{strength = 30,		create = stockTemplate},
		["Fiend G3"] =			{strength = 33,		create = stockTemplate},
		["Fiend G4"] =			{strength = 35,		create = stockTemplate},
		["Fiend G5"] =			{strength = 37,		create = stockTemplate},
		["Fiend G6"] =			{strength = 39,		create = stockTemplate},
		["Ktlitan Breaker"] =	{strength = 45,		create = stockTemplate},
		["Ktlitan Feeder"] =	{strength = 48,		create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,		create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,		create = stockTemplate},
		["Blockade Runner"] =	{strength = 65,		create = stockTemplate},
		["Starhammer II"] =		{strength = 70,		create = stockTemplate},
		["Dreadnought"] =		{strength = 80,		create = stockTemplate},
	}
	boundary_beam_string = {
		"texture/beam_blue.png",
		"texture/beam_purple.png",
		"texture/beam_green.png"
	}
	health_check_time_interval = 5
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
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}  -- am not sure why this has to be set but it was included so keeping it for now
end
function setGlobals()
	timeDivision = "paused"
	gameTimeLimit = 45*60		-- See GM button. Time limit for game; this is measured in real time seconds (example: 45*60 = 45 minutes)
	hideFlagTime = 300			-- See GM button. Time given to hide flag; this is measured in real time seconds; (300 secs or 5 mins is the normal setting; 60 for certain tests)
	maxGameTime = gameTimeLimit	-- See GM Button.
	-- intial player placement locations; note that these locations are intended to be generally consistent and independent of the environment option chosen
		--player side   		  Hum   Kra    Hum   Kra    Hum    Kra    Hum   Kra    Hum    Kra    Hum   Kra	  Hum	 Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra
		--player index   		   1     2      3     4      5      6      7     8      9     10     11    12	  13	 14     15     16     17     18     19     20     21     22     23     24     25     26     27     28     29     30     31     32
		playerStartX = 			{-1000, 1000, -1000, 1000, -1000,  1000, -2000, 2000, -2000,  2000, -2000, 2000, -3000,  3000, -1000,  1000, -1000,  1000, -2000,  2000, -2000,  2000, -3000,  3000, -3000,  3000, -3000,  3000, -3000,  3000, -4000,  4000}
		playerStartY =			{    0,    0, -1000, 1000,  1000, -1000,     0,    0,  1000, -1000, -1000, 1000,	 0,     0, -2000,  2000,  2000, -2000, -2000,  2000,  2000, -2000, -1000,  1000,  1000, -1000, -2000,  2000,  2000, -2000,     0,     0}
		player_tag_relocate_x = {-1000, 1000, -1000, 1000, -1000,  1000, -2000, 2000, -2000,  2000, -2000, 2000, -3000,	 3000, -1000,  1000, -1000,  1000, -2000,  2000, -2000,  2000, -3000,  3000, -3000,  3000, -3000,  3000, -3000,  3000, -4000,  4000}	--may override in terrain section
		player_tag_relocate_y =	{    0,    0, -1000, 1000,  1000, -1000,     0,    0,  1000, -1000, -1000, 1000,     0,     0, -2000,  2000,  2000, -2000, -2000,  2000,  2000, -2000, -1000,  1000,  1000, -1000, -2000,  2000,  2000, -2000,     0,     0}
		player_start_heading = 	{  270,   90,   270,   90,   270,    90,   270,   90,   270,    90,   270,   90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90,   270,    90}	--set both heading and rotation to avoid initial rotation upon game start
		player_start_rotation =	{  180,    0,   180,    0,   180,     0,   180,    0,   180,     0,   180,    0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0,   180,     0}	--rotation points 90 degrees counter-clockwise of heading
	wingSquadronNames = false	-- See GM button. Set to true to name ships alpha/bravo/charlie vs. red/blue/green etc.; set to false to use randomized names from a list
	tagDamage = 1.25			-- See GM button. Amount to subtract from jump/warp drive when tagged. Full health = 1
	tag_distance = 750			-- See GM button. How far away to be considered tagged and returned to other side
	hard_flag_reveal = true		-- See GM button. On hard difficulty, will a flag pick up be revealed on main screen or not
	side_destroyed_ends_game = true		-- See GM button. If one side completely destroyed, will game end immediately or not (if not, set game time remaining to 60 seconds)
	autoEnemies = false			-- See GM button. Boolean default value for whether or not marauders spawn
	inter_wave = 600				-- See GM button. Number of seconds between marauding enemy spawn waves, if that option is chosen
	wave_time = getScenarioTime() + inter_wave
	dynamicTerrain = nil		-- this is a placeholder variable that needs to be set to a function call in the terrain setup function; see below
	-- Choose the environment terrain!  Uncomment the terrain type you wish to use and comment out the other(s).
	-- !! Be sure the setup function sets the value of 'dynamicTerrain' to the function that takes terrain action
		--terrainType = emptyTerrain -- for easy/testing purposes
		--terrainType = defaultTerrain
		--terrainType = justPassingBy
		terrainType = randomSymmetric
		terrain_type_name = "Symmetric"
	-- Drone related global variables
		dronesAreAllowed = true 				-- See GM button. The base boolean to turn on/off drone usage within the scenarios
		uniform_drone_carrying_capacity = 50	-- See GM button. This is the max number of drones that can be carried by a playership; for the initial implementations, all player ships will have equal capacity
		drone_name_type = "squad-num of size"	-- See GM button. Valid values are "default" (use EE), "squad-num/size" (K), "short" (X preferred), "squad-num of size" (X alternate)
		drone_modified_from_template =  true 	-- See GM button. Boolean governing whether drone properties will be modified from their original template values
		drone_hull_strength = 25	-- See GM button. Original: 30  drones do not have shields and only have their hull strength for defense; reasonable values should be from 25-75; obviously the higher the stronger
		drone_impulse_speed = 120	-- See GM button. Original: 120 drones only have impulse engines, and usually tend to be faster because they are lighter and no living pilots required; reasonable values should be from 100-150
		drone_beam_range = 700 		-- See Gm button. Original: 600 the distance at which the drone can hit its target; reasonable values should be from 500-1000
		drone_beam_damage = 8 		-- See Gm button. Original: 6   drones have a single forward facing beam weapon; this sets the damage done by the beam; reasonable values should be from 5-10
		drone_beam_cycle_time = 5	-- See Gm button. Original: 4   this is the number of seconds it takes for the beam weapon to recharge and to be able to fire again; reasonable values should be from 3-8
		drone_flag_check_interval = 5		-- See GM button. How many seconds between each drone flag detection cycle
		drone_message_reset_count = 8		-- See GM button. How many flag check intervals to wait before sending another message about a possible flag being detected
		drone_formation_spacing = 5000		-- See GM button. How far apart drones travel when in formation (1000 = 1 unit)
		drone_scan_range_for_flags = 7500	-- See GM button. How far away drones can "see" potential flags. Standard sensor range (aka sensor bubble) is 5 units (5000)
	revisedPlayerShipProbeCount = 20  -- See GM button. The standard count of 8 just is not quite enough for this game, so we need to have an easy way to modify; all player ships will have this amount at game start
	control_code_stem = {	--All control codes must use capital letters or they will not work.
		"ALWAYS",
		"ASTRO",
		"BLACK",
		"BLANK",
		"BLUE",
		"BRIGHT",
		"BROWN",
		"CHAIN",
		"CHURCH",
		"CORNER",
		"DARK",
		"DOORWAY",
		"DOUBLE",
		"DULL",
		"ELBOW",
		"EMPTY",
		"EPSILON",
		"FAST",
		"FLOWER",
		"FLY",
		"FROZEN",
		"GIG",
		"GREEN",
		"GLOW",
		"HAND",
		"HAMMER",
		"INK",
		"INTEL",
		"JOUST",
		"JUMP",
		"KEY",
		"KINDLE",
		"LAP",
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
		"STREET",
		"TOKEN",
		"THIRSTY",
		"UNDER",
		"VANISH",
		"WHITE",
		"WRENCH",
		"YELLOW",
	}
	p1FlagDrop = false
	p2FlagDrop = false
	health_check_time = getScenarioTime() + health_check_time_interval
	terrain_objects = {}
	humanStationList = {}
	kraylorStationList = {}
	neutralStationList = {}
	stationList = {}
	human_player_names = {}
	kraylor_player_names = {}
	all_squad_count = 0
	human_flags = {}
	kraylor_flags = {}
	-- 'stationZebra' is placed at position 0,0 and is present for all environment setups
	stationZebra = SpaceStation():setTemplate("Small Station"):setFaction("Independent"):setCommsScript(""):setCommsFunction(commsStation):setPosition(0,0):setCallSign("Zebra"):setDescription(_("scienceDescription-station", "Referee"))
	table.insert(stationList,stationZebra)
	-- the following are part of Xansta's larger overall bartering/crafting setup
		goods = {}			--overall tracking of goods; 
		tradeFood = {}		--stations that will trade food for other goods; 
		tradeLuxury = {}	--stations that will trade luxury for other goods; 
		tradeMedicine = {}	--stations that will trade medicine for other goods; 
	droneFleets = {}
	boundary_marker = "buoys"
	station_pool = nil
	storage = getScriptStorage()
	storage.gatherStats = gatherStats
end
function setVariations()
	enemy_config = {
		{name = "None",		number = .5,	auto = false,	text = _("buttonGM","None")},
		{name = "Easy",		number = .5,	auto = true,	text = _("buttonGM","Easy")},
		{name = "Normal",	number = 1,		auto = true,	text = _("buttonGM","Normal")},
		{name = "Hard",		number = 2,		auto = true,	text = _("buttonGM","Hard")},
		{name = "Extreme",	number = 3,		auto = true,	text = _("buttonGM","Extreme")},
		{name = "Quixotic",	number = 5,		auto = true,	text = _("buttonGM","Quixotic")},
	}
	for i,config in ipairs(enemy_config) do
		if config.name == getScenarioSetting("Enemies") then
			enemy_config_selection = config
			enemy_config_index = i
			break
		end
	end
	enemy_power =		enemy_config_selection.number
	enemy_power_text =	enemy_config_selection.text
	autoEnemies =		enemy_config_selection.auto
	local murphy_config = {
		["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005,	text = _("buttonGM","easy"),	},
		["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001,	text = _("buttonGM","normal"),	},
		["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001,	text = _("buttonGM","hard"),	},
	}
	difficulty =		murphy_config[getScenarioSetting("Murphy")].number
	difficulty_text =	murphy_config[getScenarioSetting("Murphy")].text
	adverseEffect =		murphy_config[getScenarioSetting("Murphy")].adverse			--not used
	coolant_loss =		murphy_config[getScenarioSetting("Murphy")].lose_coolant	--not used
	coolant_gain =		murphy_config[getScenarioSetting("Murphy")].gain_coolant	--not used
	--	difficulty impacts:
	--		placing decoys (easy: no decoys)
	--		enemy danger value
	--			Easy:	starts at .5,	increments by .1
	--			Normal:	starts at .8,	increments by .2
	--			Hard:	starts at 1,	increments by .5
	--		missile type availability
	--		repair crew availability
	--		flag is pre-scanned on easy difficulty
	--		shape of radar signature on science edge (identical between flag and decoy on hard)
	--		messages to Science from drones:
	--			Easy:	messages from all drones
	--			Normal:	messages from friendly drones
	--			Hard:	messages from drones launched from a player's ship
	--	Note: these might be divided out in a future release
	arena_config = {
		{name = "Normal",	boundary = 100000,	text = _("buttonGM","medium")},
		{name = "Small",	boundary = 50000,	text = _("buttonGM","small")},
		{name = "Large",	boundary = 200000,	text = _("buttonGM","large")},
	}
	for i,config in ipairs(arena_config) do
		if config.name == getScenarioSetting("Arena") then
			arena_config_selection = config
			arena_config_index = i
			break
		end
	end
	terrain_size =	arena_config_selection.text
	boundary =		arena_config_selection.boundary
	flag_scan_config = {
		{name = "Normal",	depth = math.random(2,3),	complexity = 2,					text = _("buttonGM","normal"),	},
		{name = "Easy",		depth = 1,					complexity = math.random(1,2),	text = _("buttonGM","easy"),	},
		{name = "Hard",		depth = math.random(1,3),	complexity = math.random(3,4),	text = _("buttonGM","hard"),	},
	}
	for i,config in ipairs(flag_scan_config) do
		if config.name == getScenarioSetting("Flag Scan") then
			flag_scan_config_selection = config
			flag_scan_config_index = i
			break
		end
	end
	flag_scan_config_text = flag_scan_config_selection.text
	flagScanDepth =			flag_scan_config_selection.depth
	flagScanComplexity =	flag_scan_config_selection.complexity
	flag_tracking_config = {
		{name = "Normal",	drop = 1,	grab = 1,	rescan = false,	reveal = true,	text = _("buttonGM","normal"),	},
		{name = "Easy",		drop = .5,	grab = .5,	rescan = false,	reveal = true,	text = _("buttonGM","easy"),	},
		{name = "Hard",		drop = 2,	grab = 2,	rescan = true,	reveal = true,	text = _("buttonGM","hard"),	},
		{name = "Secret",	drop = 2,	grab = 2,	rescan = true,	reveal = false,	text = _("buttonGM","secret"),	},
	}
	for i,config in ipairs(flag_tracking_config) do
		if config.name == getScenarioSetting("Tracking") then
			tracking_config_selection = config
			tracking_config_index = i
			break
		end
	end
	tracking_config_text =	tracking_config_selection.text
	flag_drop =				tracking_config_selection.drop
	flag_grab =				tracking_config_selection.grab
	flag_rescan =			tracking_config_selection.rescan
	flag_reveal =			tracking_config_selection.reveal
	terrain_choices = {
		{name = "Empty",		func = emptyTerrain,		text = _("buttonGM","empty"),		},
		{name = "Asymmetric",	func = defaultTerrain,		text = _("buttonGM","default"),		},
		{name = "Passing",		func = justPassingBy,		text = _("buttonGM","passing"),		},
		{name = "Symmetric",	func = randomSymmetric,		text = _("buttonGM","symmetric"),	},
		{name = "Rabbit",		func = downTheRabbitHole,	text = _("buttonGM","rabbit"),		},
	}
	for i,config in ipairs(terrain_choices) do
		if config.name == getScenarioSetting("Terrain") then
			terrain_selection = config
			terrain_index = i
			break
		end
	end
	terrainType = terrain_selection.func
	terrain_text = terrain_selection.text
end
------------------
--	GM Buttons  --
------------------
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
end
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM", "Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM", "Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	local button_label = _("buttonGM", "Turn on Diagnostic")
	if diagnostic then
		button_label = _("buttonGM", "Turn off Diagnostic")
	end
	addGMFunction(button_label,function()
		if diagnostic then
			diagnostic = false
		else
			diagnostic = true
		end
		mainGMButtons()
	end)
	addGMFunction(string.format(_("buttonGM", "+Terrain: %s"),terrain_type_name),setTerrain)
	addGMFunction(_("buttonGM", "+Player Config"),playerConfig)
	if autoEnemies then
		addGMFunction(string.format(_("buttonGM", "+Times G%i H%i E%i"),gameTimeLimit/60,hideFlagTime/60,inter_wave/60),setGameTimeLimit)
	else
		addGMFunction(string.format(_("buttonGM", "+Times G%i H%i"),gameTimeLimit/60,hideFlagTime/60),setGameTimeLimit)
	end
	addGMFunction(string.format(_("buttonGM","Enemies: %s ->Next"),enemy_power_text),function()
		enemy_config_index = enemy_config_index + 1
		if enemy_config_index > #enemy_config then
			enemy_config_index = 1
		end
		enemy_config_selection =	enemy_config[enemy_config_index]
		enemy_power =				enemy_config_selection.number
		enemy_power_text =			enemy_config_selection.text
		autoEnemies = 				enemy_config_selection.auto
		mainGMButtons()
	end)
	addGMFunction(string.format(_("buttonGM","Flag scan: %s ->Next"),flag_scan_config_text),function()
		flag_scan_config_index = flag_scan_config_index + 1
		if flag_scan_config_index > #flag_scan_config then
			flag_scan_config_index = 1
		end
		flag_scan_config_selection =	flag_scan_config[flag_scan_config_index]
		flag_scan_config_text = 		flag_scan_config_selection.text
		flagScanDepth =					flag_scan_config_selection.depth
		flagScanComplexity =			flag_scan_config_selection.complexity
		mainGMButtons()
	end)
	addGMFunction(string.format(_("buttonGM","Flag track: %s ->Next"),tracking_config_text),function()
		tracking_config_index = tracking_config_index + 1
		if tracking_config_index > #flag_tracking_config then
			tracking_config_index = 1
		end
		tracking_config_selection = flag_tracking_config[tracking_config_index]
		tracking_config_text =	tracking_config_selection.text
		flag_drop =				tracking_config_selection.drop
		flag_grab =				tracking_config_selection.grab
		flag_rescan =			tracking_config_selection.rescan
		flag_reveal =			tracking_config_selection.reveal
		mainGMButtons()
	end)
	button_label = _("buttonGM", "Destroy = end off")
	if side_destroyed_ends_game then
		button_label = _("buttonGM", "Destroy = end on")
	end
	addGMFunction(button_label,function()
		if side_destroyed_ends_game then
			side_destroyed_ends_game = false
		else
			side_destroyed_ends_game = true
		end
		mainGMButtons()
	end)
	addGMFunction(string.format(_("buttonGM", "Marker: %s ->Next"),boundary_marker),function()
		if boundary_marker == "stars" then
			boundary_marker = "buoys"
		elseif boundary_marker == "buoys" then
			boundary_marker = "none"
		elseif boundary_marker == "none" then
			boundary_marker = "stars"
		end
		plotTeamDemarcationLine()
		plotFlagPlacementBoundaries()
		mainGMButtons()
	end)
	if preset_players ~= nil and #preset_players > 0 then
		addGMFunction(_("buttonGM", "Player Prefs"),function()
			local out_message = _("msgGM", "Remaining player preferences:")
			print(out_message)
			for i=1,#preset_players do
				local item = preset_players[i]
				local out = string.format(_("msgGM", "XO:%s"),item.xo)
				print(out)
				out_message = out_message .. _("msgGM", "\n") .. out
				if item.faction ~= nil then
					out = string.format(_("msgGM", "    Faction:%s"),item.faction)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_name ~= nil then
					out = string.format(_("msgGM", "    Ship name:%s"),item.ship_name)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_pref_1 ~= nil then
					out = string.format(_("msgGM", "    Ship preference 1:%s"),item.ship_pref_1)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_pref_2 ~= nil then
					out = string.format(_("msgGM", "    Ship preference 2:%s"),item.ship_pref_2)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_pref_3 ~= nil then
					out = string.format(_("msgGM", "    Ship preference 3:%s"),item.ship_pref_3)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_pref_4 ~= nil then
					out = string.format(_("msgGM", "    Ship preference 4:%s"),item.ship_pref_4)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_pref_5 ~= nil then
					out = string.format(_("msgGM", "    Ship preference 5:%s"),item.ship_pref_5)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
				if item.ship_pref_6 ~= nil then
					out = string.format(_("msgGM", "    Ship preference 6:%s"),item.ship_pref_6)
					print(out)
					out_message = out_message .. _("msgGM", "\n") .. out
				end
			end
			addGMMessage(out_message)
		end)
	end
end
function setTerrain()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-from Terrain"),mainGMButtons)
	addGMFunction(string.format(_("buttonGM", "Size: %s -> Next"),terrain_size),function()
		if terrain_size == "medium" then
			terrain_size = "large"
			boundary = 200000
		elseif terrain_size == "large" then
			terrain_size = "small"
			boundary = 50000
		elseif terrain_size == "small" then
			terrain_size = "medium"
			boundary = 100000
		end
		if terrain_objects ~= nil and #terrain_objects > 0 then
			for _, obj in pairs(terrain_objects) do
				obj:destroy()
			end
			terrain_objects = {}
		end
		stationList = {}
		humanStationList = {}
		kraylorStationList = {}
		neutralStationList = {}
		station_pool = nil
		terrainType()
		plotFlagPlacementBoundaries()
		setTerrain()
	end)
	for i, terrain in ipairs(terrain_choices) do
		local button_name = terrain.text
		if button_name == terrain_type_name then
			button_name = button_name .. _("buttonGM", "*")
		end
		addGMFunction(button_name,function()
			if terrain_objects ~= nil and #terrain_objects > 0 then
				for _, obj in pairs(terrain_objects) do
					obj:destroy()
				end
				terrain_objects = {}
			end
			terrain_selection = terrain
			terrain_index = i
			terrain_type_name = terrain.text
			terrainType = terrain.func
			stationList = {}
			humanStationList = {}
			kraylorStationList = {}
			neutralStationList = {}
			station_pool = nil
			terrainType()
			setTerrain()
		end)
	end
end
function plotTeamDemarcationLine()
	if boundary_items == nil then
		boundary_items = {}
	else
		if #boundary_items > 0 then
			for _, item in ipairs(boundary_items) do
				item:destroy()
			end
			boundary_items = {}
		end
	end
	if boundary_marker == "stars" then
		local demarcation_x_position = 0
		local demarcation_y_position = 2500
		local star = nil
		for index=1,40 do
			star = Planet():setPosition(demarcation_x_position, demarcation_y_position)
				:setPlanetRadius(150)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/star-1.png")
				--:setPlanetAtmosphereTexture("planets/star-1.png")
				:setPlanetAtmosphereColor(1.0,1.0,1.0)
				:setAxialRotationTime(100)
			table.insert(boundary_items,star)
			demarcation_y_position = demarcation_y_position * -1
			star = Planet():setPosition(demarcation_x_position, demarcation_y_position)
				:setPlanetRadius(150)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/star-1.png")
				--:setPlanetAtmosphereTexture("planets/star-1.png")
				:setPlanetAtmosphereColor(1.0,1.0,1.0)
				:setAxialRotationTime(100)
			table.insert(boundary_items,star)
			demarcation_y_position = demarcation_y_position * -1
			demarcation_y_position = demarcation_y_position + 5000
		end
		demarcation_y_position = 5000
		for index=1,40 do
			star = Planet():setPosition(demarcation_x_position, demarcation_y_position)
				:setPlanetRadius(150)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/planet-2.png")
				:setPlanetAtmosphereColor(0.5,0,0)
				:setAxialRotationTime(100)
			table.insert(boundary_items,star)
			demarcation_y_position = demarcation_y_position * -1
			star = Planet():setPosition(demarcation_x_position, demarcation_y_position)
				:setPlanetRadius(150)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/planet-2.png")
				:setPlanetAtmosphereColor(1.0,0,0)
				:setAxialRotationTime(100)
			table.insert(boundary_items,star)
			demarcation_y_position = demarcation_y_position * -1
			demarcation_y_position = demarcation_y_position + 5000
		end
	elseif boundary_marker == "buoys" then
		buoy_beam_interval = 2
		buoy_beam_timer = buoy_beam_interval
		buoy_beam_count = 0
		for i=1,80 do
			table.insert(boundary_items,Artifact():allowPickup(false):setPosition(0,i*2500):setModel("SensorBuoyMKIII"):setRotation(90):setSpin(100):setCallSign("Marker Buoy"):setDescriptions(_("scienceDescription-buoy", "Territory boundary marker"),_("scienceDescription-buoy", "A buoy placed on the line marking the boundary between Human and Kraylor territory")):setScanningParameters(1,1):setRadarSignatureInfo(.5,1,0))
			table.insert(boundary_items,Artifact():allowPickup(false):setPosition(0,i*-2500):setModel("SensorBuoyMKIII"):setRotation(90):setSpin(100):setCallSign("Marker Buoy"):setDescriptions(_("scienceDescription-buoy", "Territory boundary marker"),_("scienceDescription-buoy", "A buoy placed on the line marking the boundary between Human and Kraylor territory")):setScanningParameters(1,1):setRadarSignatureInfo(0,.5,1))
		end
	end
end
function plotFlagPlacementBoundaries()
	if flag_area_boundary_items == nil then
		flag_area_boundary_items = {}
	else
		if #flag_area_boundary_items > 0 then
			for _, item in ipairs(flag_area_boundary_items) do
				item:destroy()
			end
			flag_area_boundary_items = {}
		end
	end
	if boundary_marker == "stars" or boundary_marker == "buoys" then
		local index = 0
		repeat
			local temp_marker = nil
			if index == 0 then
				temp_marker = createBoundaryMarker(index,boundary/2)	--middle of southern edge
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(index,-boundary/2)	--middle of northern edge
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(boundary,index)		--middle of eastern edge
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(-boundary,index)		--middle of western edge
				table.insert(flag_area_boundary_items,temp_marker)
			elseif index == boundary then
				temp_marker = createBoundaryMarker(index,boundary/2)	--southeast corner
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(-index,-boundary/2)	--northwest corner
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(index,-boundary/2)	--northeast corner
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(-index,boundary/2)	--southwest corner
				table.insert(flag_area_boundary_items,temp_marker)
			else
				temp_marker = createBoundaryMarker(index,boundary/2)	--eastern part of southern line
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(-index,-boundary/2)	--western part of northern line
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(index,-boundary/2)	--eastern part of northern line
				table.insert(flag_area_boundary_items,temp_marker)
				temp_marker = createBoundaryMarker(-index,boundary/2)	--western part of southern line
				table.insert(flag_area_boundary_items,temp_marker)
				if index < boundary/2 then
					temp_marker = createBoundaryMarker(boundary,index)	--southern part of eastern line
					table.insert(flag_area_boundary_items,temp_marker)
					temp_marker = createBoundaryMarker(boundary,-index)	--northern part of eastern line
					table.insert(flag_area_boundary_items,temp_marker)
					temp_marker = createBoundaryMarker(-boundary,-index)--northern part of western line
					table.insert(flag_area_boundary_items,temp_marker)
					temp_marker = createBoundaryMarker(-boundary,index)	--southern part of western line
					table.insert(flag_area_boundary_items,temp_marker)
				end
			end
			index = index + 2500
		until(index >= boundary)
	end
end
function createBoundaryMarker(position_x, position_y)
	local temp_marker = nil
	if boundary_marker == "stars" then
		temp_marker = Planet():setPosition(position_x, position_y)
			:setPlanetRadius(200)
			:setDistanceFromMovementPlane(0)
			:setPlanetSurfaceTexture("planets/star-1.png")
			:setPlanetAtmosphereColor(1.0,1.0,1.0)
	elseif boundary_marker == "buoys" then
		temp_marker = Artifact():allowPickup(false):setPosition(position_x,position_y):setModel("SensorBuoyMKIII"):setRotation(90):setSpin(50):setDescriptions(_("scienceDescription-flag", "Flag hiding territory boundary marker"), _("scienceDescription-flag", "A temporary buoy placed on the edge of the territory where a flag or decoy may be hidden")):setScanningParameters(1,1):setRadarSignatureInfo(.3,.5,0)
	end
	return temp_marker
end

function playerConfig()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-from Player Config"),mainGMButtons)
	addGMFunction(_("buttonGM", "Show control codes"),showControlCodes)
	addGMFunction(_("buttonGM", "Show Kraylor codes"),showKraylorCodes)
	addGMFunction(_("buttonGM", "Show Human codes"),showHumanCodes)
	local button_label = _("buttonGM", "Wing Names Off")
	if wingSquadronNames then
		button_label = _("buttonGM", "Wing Names On")
	end
	addGMFunction(button_label,function()
		if wingSquadronNames then
			local p = getPlayerShip(-1)
			if p ~= nil then
				addGMMessage(_("msgGM", "Cannot disable wing names now that player ships have been spawned.\nClose the server and restart if you *really* don't want the wing names"))
			else
				wingSquadronNames = false
			end
		else
			wingSquadronNames = true
		end
		playerConfig()
	end)
	addGMFunction(string.format(_("buttonGM", "+Tags %.2f, %.1fU"),tagDamage,tag_distance/1000),setTagValues)
	button_label = _("buttonGM", "+Drones Off")
	if dronesAreAllowed then
		button_label = _("buttonGM", "+Drones On")
	end
	addGMFunction(button_label,configureDrones)
	--[[
	local p = getPlayerShip(-1)
	if p == nil then
		addGMFunction(string.format(_("buttonGM", "+Probes %i"),revisedPlayerShipProbeCount),setPlayerProbes)
	end
	--]]
end
function setGameTimeLimit()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main from times"),mainGMButtons)
	addGMFunction(string.format(_("buttonGM", "Game %i Add 5 -> %i"),gameTimeLimit/60,gameTimeLimit/60 + 5),function()
		gameTimeLimit = gameTimeLimit + 300
		maxGameTime = gameTimeLimit
		setGameTimeLimit()
	end)
	if gameTimeLimit > (hideFlagTime + 300) then
		addGMFunction(string.format(_("buttonGM", "Game %i Del 5 -> %i"),gameTimeLimit/60,gameTimeLimit/60 - 5),function()
			gameTimeLimit = gameTimeLimit - 300
			maxGameTime = gameTimeLimit
			setGameTimeLimit()
		end)
	end
	if hideFlagTime < (gameTimeLimit - 300) then
		addGMFunction(string.format(_("buttonGM", "Hide Flag %i Add 5 -> %i"),hideFlagTime/60,hideFlagTime/60 + 5),function()
			hideFlagTime = hideFlagTime + 300
			setGameTimeLimit()
		end)
	end
	if hideFlagTime > 300 then
		addGMFunction(string.format(_("buttonGM", "Hide Flag %i Del 5 -> %i"),hideFlagTime/60,hideFlagTime/60 - 5),function()
			hideFlagTime = hideFlagTime - 300
			setGameTimeLimit()
		end)
	elseif hideFlagTime > 60 then
		addGMFunction(string.format(_("buttonGM", "Hide Flag %i Del 4 -> %i"),hideFlagTime/60,hideFlagTime/60 - 4),function()
			hideFlagTime = hideFlagTime - 240
			setGameTimeLimit()
		end)
	end
	if autoEnemies then
		if inter_wave < 1200 then
			addGMFunction(string.format(_("buttonGM", "Enemy %i Add 1 -> %i"),inter_wave/60,(inter_wave + 60)/60),function()
				inter_wave = inter_wave + 60
				wave_time = getScenarioTime() + inter_wave + random(1,60)
				setGameTimeLimit()
			end)
		end
		if inter_wave > 120 then
			addGMFunction(string.format(_("buttonGM", "Enemy %i Del 1 -> %i"),inter_wave/60,(inter_wave - 60)/60),function()
				inter_wave = inter_wave - 60
				wave_time = getScenarioTime() + inter_wave + random(1,60)
				setGameTimeLimit()
			end)
		end
	end
end
function setTagValues()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main from Tag"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(string.format(_("buttonGM", "+Tag distance %.1fU"),tag_distance/1000),setTagDistance)
	addGMFunction(string.format(_("buttonGM", "+Tag damage %.2f"),tagDamage),setTagDamage)
end
function configureDrones()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-From Drones"),playerConfig)
	local button_label = _("buttonGM", "Drones Off")
	if dronesAreAllowed then
		button_label = _("buttonGM", "Drones On")
	end
	addGMFunction(button_label,function()
		if dronesAreAllowed then
			dronesAreAllowed = false
		else
			dronesAreAllowed = true
		end
		configureDrones()
	end)
	if dronesAreAllowed then
		addGMFunction(string.format(_("buttonGM", "+Capacity %i"),uniform_drone_carrying_capacity),setDroneCarryingCapacity)
		addGMFunction(string.format(_("buttonGM", "Name %s"),drone_name_type),function()
			if drone_name_type == "squad-num of size" then
				drone_name_type = "default"
			elseif drone_name_type == "default" then
				drone_name_type = "squad-num/size"
			elseif drone_name_type == "squad-num/size" then
				drone_name_type = "short"
			elseif drone_name_type == "short" then
				drone_name_type = "squad-num of size"
			end
			configureDrones() 
		end)
		addGMFunction(string.format(_("buttonGM", "+Flag I%i M%i"),drone_flag_check_interval,drone_message_reset_count),setDroneFlagValues)
		addGMFunction(string.format(_("buttonGM", "+Distance F%.1fU S%.1fU"),drone_formation_spacing/1000,drone_scan_range_for_flags/1000),setDroneDistances)
		button_label = _("buttonGM", "Template Mod Off")
		if drone_modified_from_template then
			button_label = _("buttonGM", "Template Mod On")
		end
		addGMFunction(button_label,function()
			if drone_modified_from_template then
				drone_modified_from_template = false
			else
				drone_modified_from_template = true
			end
			configureDrones() 
		end)
		if drone_modified_from_template then
			addGMFunction(string.format(_("buttonGM", "+Hull %i"),drone_hull_strength),setDroneHull)
			addGMFunction(string.format(_("buttonGM", "+Impulse %i"),drone_impulse_speed),setDroneImpulseSpeed)
			addGMFunction(string.format(_("buttonGM", "+Beam R%.1fU D%.1f C%.1f"),drone_beam_range/1000,drone_beam_damage,drone_beam_cycle_time),setDroneBeam)
		end
	end
end
function setPlayerProbes()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main from Probes"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	if revisedPlayerShipProbeCount < 50 then
		addGMFunction(string.format(_("buttonGM", "Probes %i Add 1 -> %i"),revisedPlayerShipProbeCount,revisedPlayerShipProbeCount + 1),function()
			local p = getPlayerShip(-1)
			if p == nil then
				revisedPlayerShipProbeCount = revisedPlayerShipProbeCount + 1
				setPlayerProbes()
			else
				playerConfig()
			end
		end)
	end
	if revisedPlayerShipProbeCount > 1 then
		addGMFunction(string.format(_("buttonGM", "Probes %i Del 1 -> %i"),revisedPlayerShipProbeCount,revisedPlayerShipProbeCount - 1),function()
			local p = getPlayerShip(-1)
			if p == nil then
				revisedPlayerShipProbeCount = revisedPlayerShipProbeCount - 1
				setPlayerProbes()
			else
				playerConfig()
			end
		end)
	end
end
function setTagDistance()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main from Tag"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Tag Distance"),setTagValues)
	if tag_distance < 5000 then
		addGMFunction(string.format(_("buttonGM", "%.1fU Add .1 -> %.1fU"),tag_distance/1000,(tag_distance + 100)/1000),function()
			tag_distance = tag_distance + 100
			setTagDistance()
		end)
	end
	if tag_distance > 500 then
		addGMFunction(string.format(_("buttonGM", "%.1fU Del .1 -> %.1fU"),tag_distance/1000,(tag_distance - 100)/1000),function()
			tag_distance = tag_distance - 100
			setTagDistance()
		end)
	end
end
function setTagDamage()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main from Tag"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Tag Dmg"),setTagValues)
	if tagDamage < 2 then
		addGMFunction(string.format(_("buttonGM", "%.2f Add .25 -> %.2f"),tagDamage,tagDamage + .25),function()
			tagDamage = tagDamage + .25
			setTagDamage()
		end)
	end
	if tagDamage > .25 then
		addGMFunction(string.format(_("buttonGM", "%.2f Del .25 -> %.2f"),tagDamage,tagDamage - .25),function()
			tagDamage = tagDamage - .25
			setTagDamage()
		end)
	end
end
--	Drone related GM button functions
function setDroneCarryingCapacity()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Capacity"),configureDrones)
	if uniform_drone_carrying_capacity < 100 then
		addGMFunction(string.format(_("buttonGM", "%i Add 10 -> %i"),uniform_drone_carrying_capacity,uniform_drone_carrying_capacity + 10),function()
			uniform_drone_carrying_capacity = uniform_drone_carrying_capacity + 10
			setDroneCarryingCapacity()
		end)
	end
	if uniform_drone_carrying_capacity > 10 then
		addGMFunction(string.format(_("buttonGM", "%i Del 10 -> %i"),uniform_drone_carrying_capacity,uniform_drone_carrying_capacity - 10),function()
			uniform_drone_carrying_capacity = uniform_drone_carrying_capacity - 10
			setDroneCarryingCapacity()
		end)
	end
end
function setDroneFlagValues()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Drone Flag"),configureDrones)
	if drone_flag_check_interval < 20 then
		addGMFunction(string.format(_("buttonGM", "Interval %i Add 1 -> %i"),drone_flag_check_interval,drone_flag_check_interval + 1),function()
			drone_flag_check_interval = drone_flag_check_interval + 1
			setDroneFlagValues()
		end)
	end
	if drone_flag_check_interval > 1 then
		addGMFunction(string.format(_("buttonGM", "Interval %i Del 1 -> %i"),drone_flag_check_interval,drone_flag_check_interval - 1),function()
			drone_flag_check_interval = drone_flag_check_interval - 1
			setDroneFlagValues()
		end)
	end
	if drone_message_reset_count < 20 then
		addGMFunction(string.format(_("buttonGM", "Msg Reset %i Add 1 -> %i"),drone_message_reset_count,drone_message_reset_count + 1),function()
			drone_message_reset_count = drone_message_reset_count + 1
			setDroneFlagValues()
		end)
	end
	if drone_message_reset_count > 2 then
		addGMFunction(string.format(_("buttonGM", "Msg Reset %i Del 1 -> %i"),drone_message_reset_count,drone_message_reset_count - 1),function()
			drone_message_reset_count = drone_message_reset_count - 1
			setDroneFlagValues()
		end)
	end
end
function setDroneDistances()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Drone Distance"),configureDrones)
	if drone_formation_spacing < 9000 then
		addGMFunction(string.format(_("buttonGM", "Form %.1fU Add .1 -> %.1fU"),drone_formation_spacing/1000,(drone_formation_spacing + 100)/1000),function()
			drone_formation_spacing = drone_formation_spacing + 100
			setDroneDistances()
		end)
	end
	if drone_formation_spacing > 1000 then
		addGMFunction(string.format(_("buttonGM", "Form %.1fU Del .1 -> %.1fU"),drone_formation_spacing/1000,(drone_formation_spacing - 100)/1000),function()
			drone_formation_spacing = drone_formation_spacing - 100
			setDroneDistances()
		end)
	end
	if drone_scan_range_for_flags < 9000 then
		addGMFunction(string.format(_("buttonGM", "Scan %.1fU Add .1 -> %.1fU"),drone_scan_range_for_flags/1000,(drone_scan_range_for_flags + 100)/1000),function()
			drone_scan_range_for_flags = drone_scan_range_for_flags + 100
			setDroneDistances()
		end)
	end
	if drone_scan_range_for_flags > 3000 then
		addGMFunction(string.format(_("buttonGM", "Scan %.1fU Del .1 -> %.1fU"),drone_scan_range_for_flags/1000,(drone_scan_range_for_flags - 100)/1000),function()
			drone_scan_range_for_flags = drone_scan_range_for_flags - 100
			setDroneDistances()
		end)
	end
end
function setDroneHull()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Drone Hull"),configureDrones)
	if drone_hull_strength < 200 then
		addGMFunction(string.format(_("buttonGM", "%i Add 10 -> %i"),drone_hull_strength,drone_hull_strength + 10),function()
			drone_hull_strength = drone_hull_strength + 10
			setDroneHull()
		end)
	end
	if drone_hull_strength > 10 then
		addGMFunction(string.format(_("buttonGM", "%i Del 10 -> %i"),drone_hull_strength,drone_hull_strength - 10),function()
			drone_hull_strength = drone_hull_strength - 10
			setDroneHull()
		end)
	end
end
function setDroneImpulseSpeed()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Drone Impulse"),configureDrones)
	if drone_impulse_speed < 150 then
		addGMFunction(string.format(_("buttonGM", "%i Add 5 -> %i"),drone_impulse_speed,drone_impulse_speed + 5),function()
			drone_impulse_speed = drone_impulse_speed + 5
			setDroneImpulseSpeed()
		end)
	end
	if drone_impulse_speed > 50 then
		addGMFunction(string.format(_("buttonGM", "%i Del 5 -> %i"),drone_impulse_speed,drone_impulse_speed - 5),function()
			drone_impulse_speed = drone_impulse_speed - 5
			setDroneImpulseSpeed()
		end)
	end
end
function setDroneBeam()
	clearGMFunctions()
	addGMFunction(_("buttonGM", "-Main"),mainGMButtons)
	addGMFunction(_("buttonGM", "-Player Config"),playerConfig)
	addGMFunction(_("buttonGM", "-From Drone Beam"),configureDrones)
	if drone_beam_range < 2000 then
		addGMFunction(string.format(_("buttonGM", "Rng %.1fU Add .1 -> %.1fU"),drone_beam_range/1000,(drone_beam_range + 100)/1000),function()
			drone_beam_range = drone_beam_range + 100
			setDroneBeam()
		end)
	end
	if drone_beam_range > 300 then
		addGMFunction(string.format(_("buttonGM", "Rng %.1fU Del .1 -> %.1fU"),drone_beam_range/1000,(drone_beam_range - 100)/1000),function()
			drone_beam_range = drone_beam_range - 100
			setDroneBeam()
		end)
	end
	if drone_beam_damage < 20 then
		addGMFunction(string.format(_("buttonGM", "Dmg %.1f Add .5 -> %.1f"),drone_beam_damage,drone_beam_damage + .5),function()
			drone_beam_damage = drone_beam_damage + .5
			setDroneBeam()
		end)
	end
	if drone_beam_damage > 1 then
		addGMFunction(string.format(_("buttonGM", "Dmg %.1f Del .5 -> %.1f"),drone_beam_damage,drone_beam_damage - .5),function()
			drone_beam_damage = drone_beam_damage - .5
			setDroneBeam()
		end)
	end
	if drone_beam_cycle_time < 20 then
		addGMFunction(string.format(_("buttonGM", "Cycle %.1f Add .5 -> %.1f"),drone_beam_cycle_time,drone_beam_cycle_time + .5),function()
			drone_beam_cycle_time = drone_beam_cycle_time + .5
			setDroneBeam()
		end)
	end
	if drone_beam_cycle_time > 1 then
		addGMFunction(string.format(_("buttonGM", "Cycle %.1f Del .5 -> %.1f"),drone_beam_cycle_time,drone_beam_cycle_time - .5),function()
			drone_beam_cycle_time = drone_beam_cycle_time - .5
			setDroneBeam()
		end)
	end
end

function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM", "Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM", "Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM", "Show control codes"),showControlCodes)
	addGMFunction(_("buttonGM", "Show Kraylor codes"),showKraylorCodes)
	addGMFunction(_("buttonGM", "Show Ktlitan codes"),showKtlitanCodes)
	addGMFunction(_("buttonGM", "Show Human codes"),showHumanCodes)
	local button_label = _("buttonGM", "Enable Auto-Enemies")
	if autoEnemies then
		button_label = _("buttonGM", "Disable Auto-Enemies")
	end
	addGMFunction(button_label,function()
		if autoEnemies then
			autoEnemies = false
		else
			autoEnemies = true
		end
		mainGMButtons()
	end)
	button_label = _("buttonGM", "Turn on Diagnostic")
	if diagnostic then
		button_label = _("buttonGM", "Turn off Diagnostic")
	end
	addGMFunction(button_label,function()
		if diagnostic then
			diagnostic = false
		else
			diagnostic = true
		end
		mainGMButtons()
	end)
	addGMFunction(_("buttonGM", "Current Stats"), currentStats)
	if dronesAreAllowed then 
		addGMFunction(_("buttonGM", "Detailed Drone Report"), detailedDroneReport)
	end
	if gameTimeLimit < (maxGameTime - hideFlagTime) then
		addGMFunction(_("buttonGM", "Intelligent Bugger"),intelligentBugger)
	end
end
function showKraylorCodes()
	showControlCodes("Kraylor")
end
function showHumanCodes()
	showControlCodes("Human Navy")
end
function showKtlitanCodes()
	showControlCodes("Ktlitans")
end
function showControlCodes(faction_filter)
	local code_list = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if faction_filter == "Kraylor" then
				if p:getFaction() == "Kraylor" then
					code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
				end
			elseif faction_filter == "Human Navy" then
				if p:getFaction() == "Human Navy" then
					code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
				end
			elseif faction_filter == "Ktlitans" then
				if p:getFaction() == "Ktlitans" then
					code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
				end
			else
				code_list[p:getCallSign()] = {code = p.control_code, faction = p:getFaction()}
			end
		end
	end
	local sorted_names = {}
	for name in pairs(code_list) do
		table.insert(sorted_names,name)
	end
	table.sort(sorted_names)
	local output = ""
	for _, name in ipairs(sorted_names) do
		local faction = ""
		if code_list[name].faction == "Kraylor" then
			faction = " (Kraylor)"
		elseif code_list[name].faction == "Ktlitans" then
			faction = " (Ktlitan)"
		end
		output = output .. string.format(_("msgGM", "%s: %s %s\n"),name,code_list[name].code,faction)
	end
	addGMMessage(output)
end
function intelligentBugger()
	-- Spawn a player ship not affiliated with either team for harassment purposes
	spawnBugger()
	if buggerResupply == nil then
		buggerResupply = SpaceStation():setFaction("Ktlitans"):setTemplate("Medium Station"):setPosition(0,boundary/2 + 2000):setCommsScript(""):setCommsFunction(resupplyStation)
	else
		if not buggerResupply:isValid() then
			buggerResupply = SpaceStation():setFaction("Ktlitans"):setTemplate("Medium Station"):setPosition(0,boundary/2 + 2000):setCommsScript(""):setCommsFunction(resupplyStation)
		end
	end
end
function spawnBugger()
	local bugger = PlayerSpaceship():setFaction("Ktlitans"):setPosition(0,boundary/2):addReputationPoints(100)
	bugger:setTemplate("ZX-Lindworm"):setWarpDrive(true):setWarpSpeed(950)
	bugger.template_type = "ZX-Lindworm"
	namePlayer(bugger,"ZX-Lindworm")
	local control_code_index = math.random(1,#control_code_stem)
	local stem = control_code_stem[control_code_index]
	table.remove(control_code_stem,control_code_index)
	local branch = math.random(100,999)
	bugger.control_code = stem .. branch
	bugger:setControlCode(stem .. branch)
	if bugger_player_names == nil then
		bugger_player_names = {}
	end
	bugger_player_names[bugger:getCallSign()] = bugger
	addGMMessage(string.format(_("msgGM", "New Bugger ship: %s\nControl code: %s"),bugger:getCallSign(),bugger.control_code))
	print("Control Code for bugger " .. bugger:getCallSign(), bugger.control_code)
end
function gatherStats()
	local stat_list = {}
	stat_list.scenario = {name = "Capture the Flag", version = scenario_version}
	stat_list.human = {}
	stat_list.kraylor = {}
	stat_list.bugger = {}
	stat_list.human.ship = {}
	stat_list.kraylor.ship = {}
	stat_list.bugger.ship = {}
	stat_list.human.active_ship_count = 0
	stat_list.human.destroyed_ship_count = 0
	stat_list.kraylor.active_ship_count = 0
	stat_list.kraylor.destroyed_ship_count = 0
	stat_list.bugger.active_ship_count = 0
	stat_list.bugger.destroyed_ship_count = 0
	stat_list.human.active_drone_count = 0
	stat_list.human.destroyed_drone_count = 0
	stat_list.kraylor.active_drone_count = 0
	stat_list.kraylor.destroyed_drone_count = 0
	stat_list.times = {}
	stat_list.times.game = {}
	stat_list.times.hide_flag = {}
	stat_list.times.stage = timeDivision
	stat_list.times.game.max = maxGameTime
	stat_list.times.game.total_seconds_left = gameTimeLimit
	stat_list.times.game.minutes_left = math.floor(gameTimeLimit / 60)
	stat_list.times.game.seconds_left = math.floor(gameTimeLimit % 60)
	stat_list.times.hide_flag.max = hideFlagTime
	stat_list.times.hide_flag.total_seconds_left = gameTimeLimit - (maxGameTime - hideFlagTime)
	stat_list.times.hide_flag.minutes_left = math.floor((gameTimeLimit - (maxGameTime - hideFlagTime)) / 60)
	stat_list.times.hide_flag.seconds_left = math.floor((gameTimeLimit - (maxGameTime - hideFlagTime)) % 60)
	for pidx=1,32 do
		p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				local faction = p:getFaction()
				local flag = false
				local drone_info = {}
				local squad_count = 0
				local squad_list = {}
				local active_drone_count = 0
				local destroyed_drone_count = 0
				if faction == "Ktlitans" then
					stat_list.bugger.active_ship_count = stat_list.bugger.active_ship_count + 1
					stat_list.bugger.ship[p:getCallSign()] = {template_type = p:getTypeName(), is_alive = true}
				elseif faction == "Kraylor" then
					if p.droneSquads ~= nil then
						for squadName, droneList in pairs(p.droneSquads) do
							if squadName ~= nil then
								squad_count = squad_count + 1
								squad_list[squadName] = {active_count = 0, destroyed_count = 0, max = #droneList}
								for i=1,#droneList do
									if droneList[i]:isValid() then
										squad_list[squadName].active_count = squad_list[squadName].active_count + 1
										active_drone_count = active_drone_count + 1
									else
										squad_list[squadName].destroyed_count = squad_list[squadName].destroyed_count + 1
										destroyed_drone_count = destroyed_drone_count + 1
									end
								end
							end
						end
					end
					stat_list.kraylor.active_ship_count = stat_list.kraylor.active_ship_count + 1
					if p.flag then
						flag = true
					end
					drone_info = {uniform_drone_carrying_capacity = uniform_drone_carrying_capacity, squad_count = squad_count, squad_list = squad_list, active_drone_count = active_drone_count, destroyed_drone_count = destroyed_drone_count}
					stat_list.kraylor.ship[p:getCallSign()] = {template_type = p:getTypeName(), is_alive = true, has_flag = flag, pick_up_count = p.pick_up_count, tagged_count = p.tagged_count, drone_info = drone_info}
				elseif faction == "Human Navy" then
					if p.droneSquads ~= nil then
						for squadName, droneList in pairs(p.droneSquads) do
							if squadName ~= nil then
								squad_count = squad_count + 1
								squad_list[squadName] = {active_count = 0, destroyed_count = 0, max = #droneList}
								for i=1,#droneList do
									if droneList[i]:isValid() then
										squad_list[squadName].active_count = squad_list[squadName].active_count + 1
										active_drone_count = active_drone_count + 1
									else
										squad_list[squadName].destroyed_count = squad_list[squadName].destroyed_count + 1
										destroyed_drone_count = destroyed_drone_count + 1
									end
								end
							end
						end
					end
					stat_list.human.active_ship_count = stat_list.human.active_ship_count + 1
					if p.flag then
						flag = true
					end
					drone_info = {uniform_drone_carrying_capacity = uniform_drone_carrying_capacity, squad_count = squad_count, squad_list = squad_list, active_drone_count = active_drone_count, destroyed_drone_count = destroyed_drone_count}
					stat_list.human.ship[p:getCallSign()] = {template_type = p:getTypeName(), is_alive = true, has_flag = flag, pick_up_count = p.pick_up_count, tagged_count = p.tagged_count, drone_info = drone_info}
				end
			end
			if pidx %2 == 0 then	--kraylor
				if p.droneSquads ~= nil then
					for squadName, droneList in pairs(p.droneSquads) do
						for i=1,#droneList do
							if droneList[i]:isValid() then
								stat_list.kraylor.active_drone_count = stat_list.kraylor.active_drone_count + 1
							else
								stat_list.kraylor.destroyed_drone_count = stat_list.kraylor.destroyed_drone_count + 1
							end
						end
					end
				end
			else	--human
				if p.droneSquads ~= nil then
					for squadName, droneList in pairs(p.droneSquads) do
						for i=1,#droneList do
							if droneList[i]:isValid() then
								stat_list.human.active_drone_count = stat_list.human.active_drone_count + 1
							else
								stat_list.human.destroyed_drone_count = stat_list.human.destroyed_drone_count + 1
							end
						end
					end
				end
			end
		end
	end
	for pName, p in pairs(human_player_names) do
		if not p:isValid() then
			local drone_info = {}
			local squad_count = 0
			local squad_list = {}
			local active_drone_count = 0
			local destroyed_drone_count = 0
			if p.droneSquads ~= nil then
				for squadName, droneList in pairs(p.droneSquads) do
					if squadName ~= nil then
						squad_count = squad_count + 1
						squad_list[squadName] = {active_count = 0, destroyed_count = 0, max = #droneList}
						for i=1,#droneList do
							if droneList[i]:isValid() then
								squad_list[squadName].active_count = squad_list[squadName].active_count + 1
								active_drone_count = active_drone_count + 1
							else
								squad_list[squadName].destroyed_count = squad_list[squadName].destroyed_count + 1
								destroyed_drone_count = destroyed_drone_count + 1
							end
						end
					end
				end
			end
			drone_info = {uniform_drone_carrying_capacity = uniform_drone_carrying_capacity, squad_count = squad_count, squad_list = squad_list, active_drone_count = active_drone_count, destroyed_drone_count = destroyed_drone_count}
			stat_list.human.destroyed_ship_count = stat_list.human.destroyed_ship_count + 1
			stat_list.human.ship[pName] = {template_type = p.template_type, is_alive = false, has_flag = false, pick_up_count = p.pick_up_count, tagged_count = p.tagged_count, drone_info = drone_info}
		end
	end
	for pName, p in pairs(kraylor_player_names) do
		if not p:isValid() then
			local drone_info = {}
			local squad_count = 0
			local squad_list = {}
			local active_drone_count = 0
			local destroyed_drone_count = 0
			if p.droneSquads ~= nil then
				for squadName, droneList in pairs(p.droneSquads) do
					if squadName ~= nil then
						squad_count = squad_count + 1
						squad_list[squadName] = {active_count = 0, destroyed_count = 0, max = #droneList}
						for i=1,#droneList do
							if droneList[i]:isValid() then
								squad_list[squadName].active_count = squad_list[squadName].active_count + 1
								active_drone_count = active_drone_count + 1
							else
								squad_list[squadName].destroyed_count = squad_list[squadName].destroyed_count + 1
								destroyed_drone_count = destroyed_drone_count + 1
							end
						end
					end
				end
			end
			drone_info = {uniform_drone_carrying_capacity = uniform_drone_carrying_capacity, squad_count = squad_count, squad_list = squad_list, active_drone_count = active_drone_count, destroyed_drone_count = destroyed_drone_count}
			stat_list.kraylor.destroyed_ship_count = stat_list.kraylor.destroyed_ship_count + 1
			stat_list.kraylor.ship[pName] = {template_type = p.template_type, is_alive = false, has_flag = false, pick_up_count = p.pick_up_count, tagged_count = p.tagged_count, drone_info = drone_info}
		end
	end
	if bugger_player_names ~= nil then
		for pName, p in pairs(bugger_player_names) do
			if not p:isValid() then
				stat_list.bugger.destroyed_ship_count = stat_list.bugger.destroyed_ship_count + 1
				stat_list.bugger.ship[pName] = {template_type = p.template_type, is_alive = false}
			end
		end
	end
	--[[sort
	local sorted_ships = {}
	for ship, details in pairs(stat_list.human.ship) do
		table.insert(sorted_ships,{name=ship,details=details})
	end
	table.sort(sorted_ships, function(a,b)
		return a.name < b.name
	end)
	stat_list.human.sorted_ships = sorted_ships
	sorted_ships = {}
	for ship, details in pairs(stat_list.kraylor.ship) do
		table.insert(sorted_ships,{name=ship,details=details})
	end
	table.sort(sorted_ships, function(a,b)
		return a.name < b.name
	end)
	stat_list.kraylor.sorted_ships = sorted_ships
	--]]
	storage.stats = stat_list
	return stat_list
end
function currentStats()
	local stats = gatherStats()
	print(" ")
	print("----------CURRENT SUMMARY STATS-----------")
	print("  Humans:")
	print("    Number of active ships:  " .. stats.human.active_ship_count)
	print("    Number of destroyed ships:  " .. stats.human.destroyed_ship_count)
	if dronesAreAllowed then
		print("    Total number of active drones:  " .. stats.human.active_drone_count)
		print("    Total number of destroyed drones:  " .. stats.human.destroyed_drone_count)
	end
	print("  Kraylor:")
	print("    Number of active ships:  " .. stats.kraylor.active_ship_count)
	print("    Number of destroyed ships:  " .. stats.kraylor.destroyed_ship_count)
	if dronesAreAllowed then
		print("    Total number of active drones:  " .. stats.kraylor.active_drone_count)
		print("    Total number of destroyed drones:  " .. stats.kraylor.destroyed_drone_count)
	end
	if stats.bugger.active_ship_count > 0 then
		print("Active buggers:  " .. stats.bugger.active_ship_count)
	end
	print("-----------------END STATS-----------------")
	local gm_out = _("msgGM", "Human:")
	gm_out = gm_out .. _("msgGM", "\n   Number of active ships: ") .. stats.human.active_ship_count
	gm_out = gm_out .. _("msgGM", "\n   Number of destroyed ships: ") .. stats.human.destroyed_ship_count
	if dronesAreAllowed then
		gm_out = gm_out .. _("msgGM", "\n   Total number of active drones: ") .. stats.human.active_drone_count
		gm_out = gm_out .. _("msgGM", "\n   Total number of destroyed drones: ") .. stats.human.destroyed_drone_count
	end
	gm_out = gm_out .. _("msgGM", "\nKraylor:")
	gm_out = gm_out .. _("msgGM", "\n   Number of active ships: ") .. stats.kraylor.active_ship_count
	gm_out = gm_out .. _("msgGM", "\n   Number of destroyed ships: ") .. stats.kraylor.destroyed_ship_count
	if dronesAreAllowed then
		gm_out = gm_out .. _("msgGM", "\n   Total number of active drones: ") .. stats.kraylor.active_drone_count
		gm_out = gm_out .. _("msgGM", "\n   Total number of destroyed drones: ") .. stats.kraylor.destroyed_drone_count
	end
	if stats.bugger.active_ship_count > 0 then
		gm_out = gm_out .. _("msgGM", "\nActive buggers: ") .. stats.bugger.active_ship_count
	end
	addGMMessage(gm_out)
end
function detailedDroneReport()
	print(" ")
	print(">>>>>>>>>>>>>>>BEGIN DETAILED DRONE REPORT<<<<<<<<<<<<<")
	local drone_disposition = nil
	for index=1,32 do
		local player_ship = getPlayerShip(index)
		if player_ship ~= nil and player_ship:isValid() then
			local faction = player_ship:getFaction()
			if faction ~= "Exuari" then
				print("  Player ship " .. index .. ": " .. faction)
				print("    Call Sign:  " .. player_ship:getCallSign())
				print("    Current # of stored drones:  " .. player_ship.dronePool)
				local player_drone_squad_count = 0
				local active_drone_count = 0
				if player_ship.droneSquads ~= nil then
					for squadName, droneList in pairs(player_ship.droneSquads) do
						player_drone_squad_count = player_drone_squad_count + 1
						print("    Drone Squad: " .. squadName)
						for i=1,#droneList do
							if droneList[i]:isValid() then
								print("        Drone " .. i .. " (" .. droneList[i]:getCallSign() .. ") Active")
								active_drone_count = active_drone_count + 1
							else
								print("        Drone " .. i .. " Destroyed")
							end
						end
					end
				end
				print("    Number of deloyed drone squadrons:  " .. player_drone_squad_count)
				print("    Current number of live deployed drones:  " .. active_drone_count)
				print("  ---")
			end
		end
	end
	print(">>>>>>>>>>>>>>>>>END DETAILED REPORT<<<<<<<<<<<<<<<<<<<")
end
----------------------------------------
--	Initialization support functions  --
----------------------------------------
function initializeDroneButtonFunctionTables()
	drop_decoy_functions = {
		{p1DropDecoy,p1DropDecoy2,p1DropDecoy3},
		{p2DropDecoy,p2DropDecoy2,p2DropDecoy3},
		{p3DropDecoy,p3DropDecoy2,p3DropDecoy3},
		{p4DropDecoy,p4DropDecoy2,p4DropDecoy3},
		{	nil		,p5DropDecoy ,p5DropDecoy3},
		{	nil		,p6DropDecoy ,p6DropDecoy3},
		{	nil		,	nil		 ,p7DropDecoy},
		{	nil		,	nil		 ,p8DropDecoy},
	}
end
function namePlayer(p,player_type)
	if p.name == nil then
--		print("template:",player_type)
		if preset_players ~= nil then
--			print("preset players exist")
			if #preset_players > 0 then
--				print("preset players remain:",#preset_players)
				for i=1,#preset_players do
--					print("Checking item number:",i,"XO:",preset_players[i].xo)
					if preset_players[i].ship_pref_1 ~= nil then	--preference
--						print("has ship preference:",preset_players[i].ship_pref_1,"current template:",player_type)
						if preset_players[i].ship_pref_1 == player_type then
--							print("ship preference matches")
							if preset_players[i].faction ~= nil then
--								print("has preferred faction:",preset_players[i].faction)
								if preset_players[i].faction == p:getFaction() then
--									print("faction matches")
									if preset_players[i].ship_name ~= nil then	--preference, faction, name
										p:setCallSign(preset_players[i].ship_name)
										p.name = "preset"
										print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
										table.remove(preset_players,i)
									else	--preference, faction, no name
										namePlayerShipRandomly(p,player_type)
										p.name = "preset"
										print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
										table.remove(preset_players,i)
									end
								end
								--preference matched, but faction did not
							else
								if preset_players[i].ship_name ~= nil then	--preference, no faction, name
									p:setCallSign(preset_players[i].ship_name)
									p.name = "preset"
									print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
									table.remove(preset_players,i)
								else	--preference, no faction, no name
									namePlayerShipRandomly(p,player_type)
									p.name = "preset"
									print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
									table.remove(preset_players,i)
								end
							end
						end
					elseif preset_players[i].ship_name ~= nil then	--name
--						print("has ship name:",preset_players[i].ship_name)
						if preset_players[i].faction ~= nil then
							if preset_players[i].faction == p:getFaction() then	--name, faction, no preference
								p:setCallSign(preset_players[i].ship_name)
								p.name = "preset"
								print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
								table.remove(preset_players,i)
							end
							--faction did not match
						else	--name, no faction, no preference
							p:setCallSign(preset_players[i].ship_name)
							p.name = "preset"
							print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
							table.remove(preset_players,i)
						end
					elseif preset_players[i].faction ~= nil then
						if preset_players[i].faction == p:getFaction() then
							namePlayerShipRandomly(p,player_type)
							p.name = "preset"
							print(string.format("XO: %s, Faction: %s, Ship Type: %s, Ship Name: %s",preset_players[i].xo,p:getFaction(),player_type,p:getCallSign()))
							table.remove(preset_players,i)
						end
					end
					if p.name ~= nil then
						break
					end
				end
			end
		end
		if p.name == nil then
			namePlayerShipRandomly(p,p:getTypeName())
		end
	end
end
function namePlayerShipRandomly(p,player_type)
	if #playerShipNamesFor[player_type] > 0 then
		p:setCallSign(tableRemoveRandom(playerShipNamesFor[player_type]))
	else
		p:setCallSign(tableRemoveRandom(playerShipNamesFor["Leftovers"]))
	end
	p.name = "set"
end

function setPlayer(pobj,playerIndex)
	goods[pobj] = goodsList
	pobj:addReputationPoints(150)
	pobj.nameAssigned = true
	tempPlayerType = pobj:getTypeName()
	if player_ship_stats[tempPlayerType] ~= nil then
		pobj.shipScore = player_ship_stats[tempPlayerType].strength
		pobj.maxCargo = player_ship_stats[tempPlayerType].cargo
	end
	pobj.template_type = tempPlayerType
	namePlayer(pobj,tempPlayerType)
	if tempPlayerType == "Hathcock" then
		pobj.max_jump_range = 60000
		pobj.min_jump_range = 6000
		pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
		pobj:setJumpDriveCharge(pobj.max_jump_range)
	elseif tempPlayerType == "MP52 Hornet" then
		pobj.autoCoolant = false
		pobj:setWarpDrive(true)
	elseif tempPlayerType == "Nautilus" then
		pobj.max_jump_range = 70000
		pobj.min_jump_range = 5000
		pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
		pobj:setJumpDriveCharge(pobj.max_jump_range)
	elseif tempPlayerType == "Phobos M3P" then
		pobj:setWarpDrive(true)
		pobj:setWarpSpeed(900)
	elseif tempPlayerType == "Player Cruiser" then
		pobj.max_jump_range = 80000
		pobj.min_jump_range = 5000
		pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
		pobj:setJumpDriveCharge(pobj.max_jump_range)
	elseif tempPlayerType == "Player Fighter" then
		pobj.autoCoolant = false
		pobj:setJumpDrive(true)
		pobj.max_jump_range = 40000
		pobj.min_jump_range = 3000
		pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
		pobj:setJumpDriveCharge(pobj.max_jump_range)
	elseif tempPlayerType == "Striker" then
		pobj:setJumpDrive(true)
		pobj.max_jump_range = 40000
		pobj.min_jump_range = 3000
		pobj:setJumpDriveRange(pobj.min_jump_range,pobj.max_jump_range)
		pobj:setJumpDriveCharge(pobj.max_jump_range)
	elseif tempPlayerType == "ZX-Lindworm" then
		pobj.autoCoolant = false
		pobj:setWarpDrive(true)
		pobj:setWarpSpeed(950)
	else
		namePlayer(pobj,"Leftovers")
		pobj.shipScore = 24
		pobj.maxCargo = 5
		if not pobj:hasSystem("warp") and not pobj:hasSystem("jumpdrive") then
			pobj:setWarpDrive(true)
		end
	end
	if dronesAreAllowed then
		pobj.deploy_drone = function(pidx,droneNumber)
			local p = getPlayerShip(pidx)
			local px, py = p:getPosition()
			local droneList = {}
			if p.droneSquads == nil then
				p.droneSquads = {}
				p.squadCount = 0
			end
			local squadIndex = p.squadCount + 1
			local pName = p:getCallSign()
			local squadName = string.format(_("callsign-squad", "%s-Sq%i"),pName,squadIndex)
			all_squad_count = all_squad_count + 1
			for i=1,droneNumber do
				local vx, vy = vectorFromAngle(360/droneNumber*i,800)
				local drone = CpuShip():setPosition(px+vx,py+vy):setFaction(p:getFaction()):setTemplate("Ktlitan Drone"):setScanned(true):setCommsScript(""):setCommsFunction(commsShip):setHeading(360/droneNumber*i+90)
				if drone_name_type == "squad-num/size" then
					drone:setCallSign(string.format(_("callsign-drone", "%s-#%i/%i"),squadName,i,droneNumber))
				elseif drone_name_type == "squad-num of size" then
					drone:setCallSign(string.format(_("callsign-drone", "%s-%i of %i"),squadName,i,droneNumber))
				elseif drone_name_type == "short" then
					--string.char(math.random(65,90)) --random letter A-Z
					local squad_letter_id = string.char(all_squad_count%26+64)
					if all_squad_count > 26 then
						squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/26)+64)
						if all_squad_count > 676 then
							squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/676)+64)
						end
					end
					drone:setCallSign(string.format(_("callsign-drone", "%s%i/%i"),squad_letter_id,i,droneNumber))
				end
				if drone_modified_from_template then
					drone:setHullMax(drone_hull_strength):setHull(drone_hull_strength):setImpulseMaxSpeed(drone_impulse_speed)
					--       index from 0, arc, direction,            range,            cycle time,            damage
					drone:setBeamWeapon(0,  40,         0, drone_beam_range, drone_beam_cycle_time, drone_beam_damage)
				end
				drone.squadName = squadName
				drone.deployer = p
				drone.drone = true
				drone:onDestruction(droneDestructionManagement)
				table.insert(droneList,drone)
			end
			p.squadCount = p.squadCount + 1
			p.dronePool = p.dronePool - droneNumber
			p.droneSquads[squadName] = droneList
			if p:hasPlayerAtPosition("Weapons") then
				if droneNumber > 1 then
					p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format(_("drones-msgWeapons", "%i drones launched"),droneNumber))
				else
					p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format(_("drones-msgWeapons", "%i drone launched"),droneNumber))
				end
			end
			if p:hasPlayerAtPosition("Tactical") then
				if droneNumber > 1 then
					p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format(_("drones-msgTactical", "%i drones launched"),droneNumber))
				else
					p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format(_("drones-msgTactical", "%i drone launched"),droneNumber))
				end
			end
			if droneNumber > 1 then
				p:addToShipLog(string.format(_("drones-shipLog", "Deployed %i drones as squadron %s"),droneNumber,squadName),"White")
			else
				p:addToShipLog(string.format(_("drones-shipLog", "Deployed %i drone as squadron %s"),droneNumber,squadName),"White")
			end
		end
		pobj.count_drones = function(pidx)
			local p = getPlayerShip(pidx)
			local msgLabel = string.format("weaponsDroneCount%s",p:getCallSign())
			p:addCustomMessage("Weapons",msgLabel,string.format(_("drones-msgWeapons", "You have %i drones to deploy"),p.dronePool))
			msgLabel = string.format("tacticalDroneCount%s",p:getCallSign())
			p:addCustomMessage("Tactical",msgLabel,string.format(_("drones-msgTactical", "You have %i drones to deploy"),p.dronePool))
		end
		pobj.drone_hull_status = function(pidx)
			local player_ship = getPlayerShip(pidx)
			local drone_report_message = _("drones-", "> > > > > > > > Drone Hull Status Report: < < < < < < < <")
			--drone_report_message = drone_report_message .. "\n    Current number of stored drones:  " .. player_ship.dronePool
			local player_drone_squad_count = 0
			local active_drone_count = 0
			if player_ship.droneSquads ~= nil then
				for squadName, droneList in pairs(player_ship.droneSquads) do
					player_drone_squad_count = player_drone_squad_count + 1
					drone_report_message = drone_report_message .. _("drones-", "\n        Drone Squad: ") .. squadName
					local active_drone_in_squad_count = 0
					local squad_report = ""
					for i=1,#droneList do
						local drone = droneList[i]
						if drone:isValid() then
							squad_report = squad_report .. string.format(_("drones-", "\n            Drone %i (%s) Hull: %i/%i"),
								i,
								drone:getCallSign(),
								math.floor(drone:getHull()),
								math.floor(drone:getHullMax()))
							active_drone_count = active_drone_count + 1
							active_drone_in_squad_count = active_drone_in_squad_count + 1
						else
							squad_report = squad_report .. string.format(_("drones-", "\n            Drone %i --Destroyed--"),i)
						end
					end
					if active_drone_in_squad_count > 0 then
						drone_report_message = drone_report_message .. squad_report
					else
						drone_report_message = drone_report_message .. _("drones-", " --Destroyed--")
					end
				end
			end
			drone_report_message = drone_report_message .. _("drones-msgEngineer&Engineer+", "\n    Number of deployed drone squadrons: ") .. player_drone_squad_count
			drone_report_message = drone_report_message .. _("drones-msgEngineer&Engineer+", "\n    Current number of live deployed drones: ") .. active_drone_count
			local p_name = player_ship:getCallSign()
			if player_ship:hasPlayerAtPosition("Engineering") then
				player_ship:addCustomMessage("Engineering",string.format("%sengineeringdronesstatus",p_name),drone_report_message)
			end
			if player_ship:hasPlayerAtPosition("Engineering+") then
				player_ship:addCustomMessage("Engineering+",string.format("%sengineeringplusdronesstatus",p_name),drone_report_message)
			end
		end
		pobj.drone_locations = function(pidx)
			local player_ship = getPlayerShip(pidx)
			local drone_report_message = _("drones-", "> > > > > > > > Drone Location Report: < < < < < < < <")
			--drone_report_message = drone_report_message .. "\n    Current number of stored drones:  " .. player_ship.dronePool
			local player_drone_squad_count = 0
			local active_drone_count = 0
			if player_ship.droneSquads ~= nil then
				for squadName, droneList in pairs(player_ship.droneSquads) do
					player_drone_squad_count = player_drone_squad_count + 1
					drone_report_message = drone_report_message .. _("drones-", "\n        Drone Squad: ") .. squadName
					local active_drone_in_squad_count = 0
					local squad_report = ""
					for i=1,#droneList do
						local drone = droneList[i]
						if drone:isValid() then
							local drone_x, drone_y = drone:getPosition()
							squad_report = squad_report .. string.format(_("drones-", "\n            Drone %i (%s) Sector %s, X: %7.0f, Y: %7.0f"),
								i,
								drone:getCallSign(),
								drone:getSectorName(),
								drone_x,
								drone_y)
							active_drone_count = active_drone_count + 1
							active_drone_in_squad_count = active_drone_in_squad_count + 1
						else
							squad_report = squad_report .. string.format(_("drones-", "\n            Drone %i --Destroyed--"),i)
						end
					end
					if active_drone_in_squad_count > 0 then
						drone_report_message = drone_report_message .. squad_report
					else
						drone_report_message = drone_report_message .. _("drones-", " --Destroyed--")
					end
				end
			end
			drone_report_message = drone_report_message .. _("drones-msgHelms&Tactical", "\n    Number of deployed drone squadrons: ") .. player_drone_squad_count
			drone_report_message = drone_report_message .. _("drones-msgHelms&Tactical", "\n    Current number of live deployed drones: ") .. active_drone_count
			local p_name = player_ship:getCallSign()
			if player_ship:hasPlayerAtPosition("Helms") then
				player_ship:addCustomMessage("Helms",string.format("%shelmdroneslocation",p_name),drone_report_message)
			end
			if player_ship:hasPlayerAtPosition("Tactical") then
				player_ship:addCustomMessage("Tactical",string.format("%stacticaldroneslocation",p_name),drone_report_message)
			end
		end
		local pName = pobj:getCallSign()
		--local button_name = ""
		if pobj.droneButton == nil then
			pobj.droneButton = true
			pobj.dronePool = uniform_drone_carrying_capacity
			pobj:addCustomButton("Weapons",string.format("%sdeploy5weapons",pName),_("drones-buttonWeapons", "5 Drones"),function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,5)
			end)
			pobj:addCustomButton("Tactical",string.format("%sdeploy5tactical",pName),_("drones-buttonTactical", "5 Drones"),function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,5)
			end)
			pobj:addCustomButton("Weapons",string.format("%sdeploy10weapons",pName),_("drones-buttonWeapons", "10 Drones"),function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,10)
			end)
			pobj:addCustomButton("Tactical",string.format("%sdeploy10tactical",pName),_("drones-buttonTactical", "10 Drones"),function()
				string.format("")	--global context for SeriousProton
				pobj.deploy_drone(playerIndex,10)
			end)
			pobj:addCustomButton("Weapons",string.format("%scountWeapons",pName),_("drones-buttonWeapons", "Count Drones"),function()
				string.format("")	--global context for SeriousProton
				pobj.count_drones(playerIndex)
			end)
			pobj:addCustomButton("Tactical",string.format("%scountTactical",pName),_("drones-buttonTactical", "Count Drones"),function()
				string.format("")	--global context for SeriousProton
				pobj.count_drones(playerIndex)
			end)
			pobj:addCustomButton("Engineering",string.format("%shullEngineering",pName),_("drones-buttonEngineer", "Drone Hulls"),function()
				string.format("")	--global context for SeriousProton
				pobj.drone_hull_status(playerIndex)
			end)
			pobj:addCustomButton("Engineering+",string.format("%shullEngineeringPlus",pName),_("drones-buttonEngineer+", "Drone Hulls"),function()
				string.format("")	--global context for SeriousProton
				pobj.drone_hull_status(playerIndex)
			end)
			pobj:addCustomButton("Helms",string.format("%slocationHelm",pName),_("drones-buttonHelms", "Drone Locations"),function()
				string.format("")	--global context for SeriousProton
				pobj.drone_locations(playerIndex)
			end)
			pobj:addCustomButton("Tactical",string.format("%slocationTactical",pName),_("drones-buttonTactical", "Drone Locations"),function()
				string.format("")	--global context for SeriousProton
				pobj.drone_locations(playerIndex)
			end)
		end
	end
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
	if pobj:getBeamWeaponRange(0) > 0 then
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
	local control_code_index = math.random(1,#control_code_stem)
	local stem = control_code_stem[control_code_index]
	table.remove(control_code_stem,control_code_index)
	local branch = math.random(100,999)
	pobj.control_code = stem .. branch
	pobj:setControlCode(stem .. branch)
	print("Control Code for " .. pobj:getCallSign(), pobj.control_code)
	pobj.tagged_count = 0
	pobj.pick_up_count = 0
	pobj.drop_count = 0
	pobj:setMaxScanProbeCount(player_ship_stats[tempPlayerType].probes)
	pobj:setScanProbeCount(player_ship_stats[tempPlayerType].probes)
	pobj:onDestroyed(function(self)
		self.point_of_destruction_x, self.point_of_destruction_y = self:getPosition()
		if self.flag then			--destroyed ship carrying flag
			self.flag = false		--drop flag
			self.drop_count = self.drop_count + 1
			local my_faction = self:getFaction()
			local px, py = self:getPosition()
			if my_faction == "Kraylor" then
				p1Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
				table.insert(human_flags,p1Flag)
				p1Flag:setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Human Navy Flag")):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				if flag_reveal then
					if flag_drop < 2 then
						if flag_drop < 1 then
							globalMessage(string.format(_("flag-msgMainscreen", "%s dropped Human Navy flag"),self:getCallSign()))
						else
							globalMessage(_("flag-msgMainscreen", "Human Navy flag dropped"))
						end
					else
						globalMessage(_("flag-msgMainscreen", "Flag dropped"))
					end
				end
				if not flag_rescan then
					p1Flag:setScannedByFaction("Kraylor",true)
				end
			elseif my_faction == "Human Navy" then
				p2Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
				table.insert(kraylor_flags,p2Flag)
				p2Flag:setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Kraylor Flag")):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				if flag_reveal then
					if flag_drop < 2 then
						if flag_drop < 1 then
							globalMessage(string.format(_("flag-msgMainscreen", "%s dropped Kraylor flag"),self:getCallSign()))
						else
							globalMessage(_("flag-msgMainscreen", "Kraylor flag dropped"))
						end
					else
						globalMessage(_("flag-msgMainscreen", "Flag dropped"))
					end
				end
				if not flag_rescan then
					p2Flag:setScannedByFaction("Human Navy",true)
				end
			end
		end
	end)
end
-----------------
--	Utilities  --
-----------------
function tableRemoveRandom(array)
--	Remove random element from array and return it.
	-- Returns nil if the array is empty,
	-- analogous to `table.remove`.
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    array[selected_item], array[array_item_count] = array[array_item_count], array[selected_item]
    return table.remove(array)
end
function placeRandomAroundPointList(object_type, amount, dist_min, dist_max, x0, y0)
	local pointList = {}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        pointObj = object_type():setPosition(x, y)
		table.insert(pointList,pointObj)
    end
	return pointList
end
function createRandomAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
	-- Create amount of objects of type object_type along arc
	-- Center defined by x and y
	-- Radius defined by distance
	-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
	-- Use randomize to vary the distance from the center point. Omit to keep distance constant
	-- Example:
	--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	arcObjects = {}
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
			arcObj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
			table.insert(arcObjects,arcObj)			
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			arcObj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)			
			table.insert(arcObjects,arcObj)			
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			arcObj = object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist)
			table.insert(arcObjects,arcObj)			
		end
	end
	return arcObjects
end
--	Mortal repair crew
function healthCheck(delta)
	if getScenarioTime() > health_check_time then
		for pidx=1,32 do
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
					if p:getBeamWeaponRange(0) > 0 then
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
				else
					if random(1,100) <= 4 then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,_("repairCrew-msgEngineer", "Medical team has revived one of your repair crew"))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,_("repairCrew-msgEngineer+", "Medical team has revived one of your repair crew"))
						end
						resetPreviousSystemHealth(p)
					end
				end
			end
		end
		health_check_time = getScenarioTime() + health_check_time_interval
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
function resetPreviousSystemHealth(p)
	string.format("")	--may need global context
	if p == nil then
		p = comms_source
	end
	local currentShield = 0
	if p:getShieldCount() > 1 then
		currentShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		currentShield = p:getSystemHealth("frontshield")
	end
	p.prevShield = currentShield
	p.prevReactor = p:getSystemHealth("reactor")
	p.prevManeuver = p:getSystemHealth("maneuver")
	p.prevImpulse = p:getSystemHealth("impulse")
	if p:getBeamWeaponRange(0) > 0 then
		if p.healthyBeam == nil then
			p.healthyBeam = 1.0
			p.prevBeam = 1.0
		end
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		if p.healthyMissile == nil then
			p.healthyMissile = 1.0
			p.prevMissile = 1.0
		end
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if p:hasWarpDrive() then
		if p.healthyWarp == nil then
			p.healthyWarp = 1.0
			p.prevWarp = 1.0
		end
		p.prevWarp = p:getSystemHealth("warp")
	end
	if p:hasJumpDrive() then
		if p.healthyJump == nil then
			p.healthyJump = 1.0
			p.prevJump = 1.0
		end
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
end

--	Marauding enemies
function marauderWaves(delta)
	if getScenarioTime() > wave_time then
		if autoEnemies then
			wave_time = getScenarioTime() + inter_wave + random(1,60)
			if dangerValue == nil then
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
			end
			marauderStart = math.random(1,3)
			mhsx = -1*boundary				--all marauder human start points are on the left boundary
			mksx = boundary					--all marauder kraylor start points are on the right boundary
			if marauderStart == 1 then		--upper left and lower right
				mhsy = -1*boundary/2		--marauder human start y
				mksy = boundary/2			--marauder kraylor start y
				if math.random(1,2) == 1 then
					mhex = playerStartX[1]	--marauder human end x
					mhey = playerStartY[1]	--marauder human end y
					mkex = playerStartX[2]	--marauder kraylor end x
					mkey = playerStartY[2]	--marauder kraylor end y
				else
					mhex = 0				--marauder human end x
					mhey = boundary/2		--marauder human end y
					mkex = 0				--marauder kraylor end x
					mkey = -1*boundary/2	--marauder kraylor end y
				end
			elseif marauderStart == 2 then	--mid left and mid right
				mhsy = 0
				mksy = 0
				marauderEnd = math.random(1,3)
				if marauderEnd == 1 then
					mhex = 0
					mhey = -1*boundary/2
					mkex = 0
					mkey = boundary/2
				elseif marauderEnd == 2 then
					mhex = 0
					mhey = boundary/2
					mkex = 0
					mkey = -1*boundary/2
				else
					mhex = playerStartX[1]	--marauder human end x
					mhey = playerStartY[1]	--marauder human end y
					mkex = playerStartX[2]	--marauder kraylor end x
					mkey = playerStartY[2]	--marauder kraylor end y
				end
			else							--lower left and upper right
				mhsy = boundary/2
				mksy = -1*boundary/2
				if math.random(1,2) == 1 then
					mhex = playerStartX[1]	--marauder human end x
					mhey = playerStartY[1]	--marauder human end y
					mkex = playerStartX[2]	--marauder kraylor end x
					mkey = playerStartY[2]	--marauder kraylor end y
				else
					mhex = 0				--marauder human end x
					mhey = -1*boundary/2	--marauder human end y
					mkex = 0				--marauder kraylor end x
					mkey = boundary/2		--marauder kraylor end y
				end
			end
			sp = irandom(300,500)			--random spacing of spawned group
			local deployConfig = random(1,100)	--randomly choose between squarish formation and hexagonish formation
			local shape = "square"
			if deployConfig < 50 then
				shape = "hexagonal"
			end
			local hmf = spawnEnemies(mhsx,mhsy,dangerValue,"Exuari",shape,sp)
			for i, enemy in ipairs(hmf) do
				enemy:orderFlyTowards(mhex,mhey)
				local selected_template = enemy:getTypeName()
				local ship = ship_template[selected_template].create("Exuari",selected_template)
				ship:setPosition(mksx + formation_delta[shape].x[i] * sp, mksy + formation_delta[shape].y[i] * sp)
				ship:orderFlyTowards(mkex,mkey)
			end
--			kmf = spawnEnemies(mksx,mksy,dangerValue,"Exuari")
--			for i, enemy in ipairs(kmf) do
--				enemy:orderFlyTowards(mkex,mkey)
--			end
			wakeList = getObjectsInRadius(playerStartX[1],playerStartY[1],1000)
			for i, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			wakeList = getObjectsInRadius(playerStartX[2],playerStartY[2],1000)
			for i, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			wakeList = getObjectsInRadius(0,-1*boundary/2,1000)
			for i, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			wakeList = getObjectsInRadius(0,boundary/2,1000)
			for i, obj in ipairs(wakeList) do
				if obj:getFaction() == "Exuari" then
					obj:orderRoaming()
				end
			end
			dangerValue = dangerValue + dangerIncrement
		end
	end
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
		for i, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
			if ship_template[current_ship_template].strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= template_pool_size then
				break
			end
		end
	else	--full selectivity
		for current_ship_template, details in pairs(ship_template) do
			if details.strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
		end
	end
	return template_pool
end
function spawnEnemies(xOrigin, yOrigin, danger, enemyFaction, shape, sp)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	enemy_position = 0
	enemyList = {}
	template_pool_size = 15
	local template_pool = getTemplatePool(enemyStrength)
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		local ship = ship_template[selected_template].create(enemyFaction,selected_template)
		ship:setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
		enemy_position = enemy_position + 1
		ship:setPosition(xOrigin + formation_delta[shape].x[enemy_position] * sp, yOrigin + formation_delta[shape].y[enemy_position] * sp)
		ship:setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
		table.insert(enemyList, ship)
		enemyStrength = enemyStrength - ship_template[selected_template].strength
	end
	return enemyList
end
function playerPower()
	local playerShipScore = 0
	for i,p in ipairs(getActivePlayerShips()) do
		if p.shipScore == nil then
			p.shipScore = 24
		end
		playerShipScore = playerShipScore + p.shipScore
	end
	return playerShipScore
end
function stockTemplate(enemyFaction,template)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate(template)
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	return ship
end
-----------------------------------
--	Different terrain functions  --
-----------------------------------
function emptyTerrain()
	-- there is no terrain except for the center 'Zebra Station'
	dynamicTerrain = nil
end
function defaultTerrain()
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
	grid[gx][gy] = gp
	grid[gx][gy+1] = gp
	grid[gx][gy-1] = gp
	grid[gx+1][gy] = gp
	grid[gx-1][gy] = gp
	grid[gx+1][gy+1] = gp
	grid[gx+1][gy-1] = gp
	grid[gx-1][gy+1] = gp
	grid[gx-1][gy-1] = gp
	adjList = getAdjacentGridLocations(gx,gy)
	gp = 2
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	neutralZoneDistance = 3000
	--place stations
	for j=1,40 do
		tSize = math.random(2,5)		--tack on region size
		grid[gy][gy] = gp				--set current grid location to grid position list index
		gRegion = {}					--grow region
		table.insert(gRegion,{gx,gy})	--store current coordinates in grow region
		for i=1,tSize do
			adjList = getAdjacentGridLocations(gx,gy)
			if #adjList < 1 then		--exit loop if no more adjacent spaces
				break
			end
			rd = math.random(1,#adjList)	--random direction in which to grow
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
		if psx < -1*neutralZoneDistance then		--left stations
			stationFaction = "Human Navy"			--human
		elseif psx > neutralZoneDistance then		--right stations
			stationFaction = "Kraylor"				--kraylor
		else										--near the middle
			stationFaction = "Independent"			--independent
		end
		local generic_count = 0
		if station_pool ~= nil then
			for name,details in pairs(station_pool["Generic"]) do
				generic_count = generic_count + 1
			end
		end
		if stationFaction == "Independent" and random(1,5) >= 20 and generic_count > 0 then
			pStation = placeStation(psx,psy,"Generic",stationFaction)
		else
			pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
		end
		table.insert(terrain_objects,pStation)
		if psx < -1*neutralZoneDistance then
			table.insert(humanStationList,pStation)
		elseif psx > neutralZoneDistance then
			table.insert(kraylorStationList,pStation)
		else
			table.insert(neutralStationList,pStation)
		end
		gp = gp + 1
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	if not diagnostic then
		local nebula_list = placeRandomAroundPointList(Nebula,math.random(10,30),1,150000,0,0)
		for _, nebula in ipairs(nebula_list) do
			table.insert(terrain_objects,nebula)
		end
		local tn = Nebula():setPosition(0,0)
		table.insert(terrain_objects,tn)
		for i=9000,boundary,9000 do	--nebula dividing line
			tn = Nebula():setPosition(0,i)
			table.insert(terrain_objects,tn)
			tn = Nebula():setPosition(0,-1*i)
			table.insert(terrain_objects,tn)
		end
		dynamicTerrain = moveDefaultTerrain
		nebLine0h = Nebula():setPosition(0,0)	--nebula line zero human
		table.insert(terrain_objects,nebLine0h)
		nebLine0k = Nebula():setPosition(0,0)	--nebula line zero kraylor
		table.insert(terrain_objects,nebLine0k)
		nebLine0Travel = random(5,20)			--nebula line zero travel distance per update
		nebLine0Direction = "out"				--nebula line zero direction of travel
	end
end
function moveDefaultTerrain(delta)
	nx, ny = nebLine0h:getPosition()
	if nebLine0Direction == "out" then		--out from center?
		if nx < -1*boundary then			--beyond boundary?
			nebLine0Direction = "in"		--change direction to in
			nebLine0Travel = random(5,20)	--randomize travel speed
		else								--within boundary, normal out movement
			nebLine0h:setPosition(nx - nebLine0Travel,ny)
		end
	else									--in from edge
		if nx > 0 then						--beyond boundary?
			nebLine0Direction = "out"		--change direction to out
			nebLine0Travel = random(5,20)	--randomize travel speed
		else								--within boundary, normal in movement
			nebLine0h:setPosition(nx + nebLine0Travel, ny)
		end
	end
	nx, ny = nebLine0k:getPosition()		--other nebula mirrors movement
	if nebLine0Direction == "out" then
		nebLine0k:setPosition(nx + nebLine0Travel, ny)
	else
		nebLine0k:setPosition(nx - nebLine0Travel, ny)
	end
	if nebLine20hPos == nil then			--built second set of nebulae yet?
		tnx, tny = nebLine0k:getPosition()	--get trigger nebula position
		if tnx > 20000 then					--trigger beyond 20k mark?
			nebLine20hPos = Nebula():setPosition(0,20000)	--nebula line 20 human positive
			nebLine20hNeg = Nebula():setPosition(0,-20000)	--nebula line 20 human negative
			nebLine20kPos = Nebula():setPosition(0,20000)	--nebula line 20 kraylor positive
			nebLine20kNeg = Nebula():setPosition(0,-20000)	--nebula line 20 kraylor negative
			nebLine20Travel = random(7,25)					--nebula line 20 travel distance
			nebLine20Direction = "out"						--nebula line 20 direction of travel
		end
	else									--second set of nebulae built
		nx, ny = nebLine20hPos:getPosition()	
		if nebLine20Direction == "out" then		--out from center?
			if nx < -1*boundary then			--beyond boundary?
				nebLine20Direction = "in"		--change direction to in
				nebLine20Travel = random(7,25)	--randomize travel speed
			else								--within boundary, normal out movement
				nebLine20hPos:setPosition(nx - nebLine20Travel, ny)
			end
		else									--in from edge
			if nx > 0 then						--beyond boundary?
				nebLine20Direction = "out"		--change direction to out
				nebLine20Travel = random(7,25)	--randomize travel speed
			else								--within boundary, normal in movement
				nebLine20hPos:setPosition(nx + nebLine20Travel, ny)
			end
		end
		if nebLine20Direction == "out" then		--other nebulae mirror movement
			nx, ny = nebLine20hNeg:getPosition()
			nebLine20hNeg:setPosition(nx - nebLine20Travel, ny)
			nx, ny = nebLine20kPos:getPosition()
			nebLine20kPos:setPosition(nx + nebLine20Travel, ny)
			nx, ny = nebLine20kNeg:getPosition()
			nebLine20kNeg:setPosition(nx + nebLine20Travel, ny)
		else
			nx, ny = nebLine20hNeg:getPosition()
			nebLine20hNeg:setPosition(nx + nebLine20Travel, ny)
			nx, ny = nebLine20kPos:getPosition()
			nebLine20kPos:setPosition(nx - nebLine20Travel, ny)
			nx, ny = nebLine20kNeg:getPosition()
			nebLine20kNeg:setPosition(nx - nebLine20Travel, ny)
		end
	end
	if nebLine40hPos == nil then	--third set built?
		tnx, tny = nebLine0k:getPosition()
		if tnx > 40000 then
			nebLine40hPos = Nebula():setPosition(0,40000)
			nebLine40hNeg = Nebula():setPosition(0,-40000)
			nebLine40kPos = Nebula():setPosition(0,40000)
			nebLine40kNeg = Nebula():setPosition(0,-40000)
			nebLine40Travel = random(10,30)
			nebLine40Direction = "out"
		end
	else
		nx, ny = nebLine40hPos:getPosition()
		if nebLine40Direction == "out" then
			if nx < -1*boundary then
				nebLine40Direction = "in"
				nebLine40Travel = random(10,30)
			else
				nebLine40hPos:setPosition(nx - nebLine40Travel, ny)
			end
		else
			if nx > 0 then
				nebLine40Direction = "out"
				nebLine40Travel = random(10,30)
			else
				nebLine40hPos:setPosition(nx + nebLine40Travel, ny)
			end
		end
		if nebLine40Direction == "out" then
			nx, ny = nebLine40hNeg:getPosition()
			nebLine40hNeg:setPosition(nx - nebLine40Travel, ny)
			nx, ny = nebLine40kPos:getPosition()
			nebLine40kPos:setPosition(nx + nebLine40Travel, ny)
			nx, ny = nebLine40kNeg:getPosition()
			nebLine40kNeg:setPosition(nx + nebLine40Travel, ny)
		else
			nx, ny = nebLine40hNeg:getPosition()
			nebLine40hNeg:setPosition(nx + nebLine40Travel, ny)
			nx, ny = nebLine40kPos:getPosition()
			nebLine40kPos:setPosition(nx - nebLine40Travel, ny)
			nx, ny = nebLine40kNeg:getPosition()
			nebLine40kNeg:setPosition(nx - nebLine40Travel, ny)
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
function szt()
	--Randomly choose station size template
	if stationSize ~= nil then
		return stationSize
	end
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
--	Random symmetric terrain
function mirrorKrikAsteroids()
	local ax = nil
	local ay = nil
	for _, obj in ipairs(krikList1) do
		ax, ay = obj:getPosition()
		table.insert(terrain_objects,Asteroid():setPosition(-ax,-ay))
	end
	for _, obj in ipairs(krikList2) do
		ax, ay = obj:getPosition()
		table.insert(terrain_objects,Asteroid():setPosition(-ax,-ay))
	end
	mirrorKrik = false
end
function mirrorAsteroids()
	for _, obj in ipairs(mirror_station.asteroid_list) do
		local ax, ay = obj:getPosition()
		table.insert(terrain_objects,Asteroid():setPosition(-ax,-ay))
	end
	mirror_asteroids = false
end
function randomSymmetric()
	local mirror_asteroids = false
	psx, psy = vectorFromAngle(random(135,225),4000)
	stationSize = "Small Station"
	stationFaction = "Human Navy"
	pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
	table.insert(terrain_objects,pStation)
	table.insert(stationList,pStation)
	table.insert(humanStationList,pStation)
	local station_name = pStation:getCallSign()
	if pStation.asteroid_list ~= nil then
		mirror_station = pStation
	else
		mirror_station = nil
	end
	psx = -psx
	psy = -psy
	stationFaction = "Kraylor"
	pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
	table.insert(terrain_objects,pStation)
	table.insert(stationList,pStation)
	table.insert(kraylorStationList,pStation)
	if mirror_station ~= nil then
		mirrorAsteroids()
		mirror_station = nil
	end
	if pStation.asteroid_list ~= nil then
		mirror_station = pStation
	else
		mirror_station = nil
	end
	for spi=1,9 do
		repeat
			rx, ry = stationList[math.random(1,#stationList)]:getPosition()
			vx, vy = vectorFromAngle(random(0,360),random(5000,50000))
			psx = rx+vx
			psy = ry+vy
			closestStationDistance = 999999
			for si=1,#stationList do
				curDist = distance(stationList[si],psx,psy)
				if curDist < closestStationDistance then
					closestStationDistance = curDist
				end
			end
		until(psx < 0 and closestStationDistance > 4000)
		stationSize = nil
		if psx > -1000 then
			stationFaction = "Independent"
		else
			stationFaction = "Human Navy"
		end
		pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
		table.insert(terrain_objects,pStation)
		table.insert(stationList,pStation)
		if stationFaction == "Human Navy" then
			table.insert(humanStationList,pStation)
		end
		if mirror_station ~= nil then
			mirrorAsteroids()
			mirror_station = nil
		end
		if pStation.asteroid_list ~= nil then
			mirror_station = pStation
		else
			mirror_station = nil
		end
		stationSize = sizeTemplate
		psx = -psx
		psy = -psy
		if stationFaction ~= "Independent" then
			stationFaction = "Kraylor"
		end
		pStation = placeStation(psx,psy,"RandomHumanNeutral",stationFaction)
		table.insert(terrain_objects,pStation)
		table.insert(stationList,pStation)
		if stationFaction == "Kraylor" then
			table.insert(kraylorStationList,pStation)
		end
		if mirror_station ~= nil then
			mirrorAsteroids()
			mirror_station = nil
		end
		if pStation.asteroid_list ~= nil then
			mirror_station = pStation
		else
			mirror_station = nil
		end
	end
	if mirror_station ~= nil then
		mirrorAsteroids()
		mirror_station = nil
	end
	if not diagnostic then
		nebList = placeRandomAroundPointList(Nebula,math.random(5,15),1,150000,0,0)
		for _, obj in ipairs(nebList) do
			table.insert(terrain_objects,obj)
			nx, ny = obj:getPosition()
			table.insert(terrain_objects,Nebula():setPosition(-nx,-ny))
		end
		table.insert(terrain_objects,Nebula():setPosition(0,0))
		for i=9000,boundary,9000 do	--nebula dividing line
			table.insert(terrain_objects,Nebula():setPosition(0,i))
			table.insert(terrain_objects,Nebula():setPosition(0,-1*i))
		end
		dynamicTerrain = moveDefaultTerrain		-- THIS IS VERY IMPORTANT SO THE SCRIPT CALLS THE CORRECT ROUTINE TO MOVE ENVIRONMENT OBJECTS
		nebLine0h = Nebula():setPosition(0,0)	--nebula line zero human
		table.insert(terrain_objects,nebLine0h)
		nebLine0k = Nebula():setPosition(0,0)	--nebula line zero kraylor
		table.insert(terrain_objects,nebLine0k)
		nebLine0Travel = random(5,20)			--nebula line zero travel distance per update
		nebLine0Direction = "out"				--nebula line zero direction of travel
	end
end
--	Just passing by terrain
function justPassingBy()
	dynamicTerrain = moveJustPassingBy
	-- this environment design places a black hole to the rear of each startup area and has large bands of nebula and some asteroids orbiting the black holes in opposite directions
	-- NOTE that whereas the initial placement of the left and right black holes are made through variables, the subsequent movement updates of all bodies are done via
	-- finding the location of the blackhole; this is done so that it is possible to move the black hole and thus cause the entire orbital system around the blackhole
	-- to move with it, should that variation be used within the script
	
	-- first build the left side
		left_bh_x_coord = -100000
		left_bh_y_coord = 60000
		left_blackhole = BlackHole():setPosition(left_bh_x_coord, left_bh_y_coord)
		table.insert(terrain_objects,left_blackhole)

		-- there will be 3 bands of orbiting stuff:  inner nebula moving quickest, middle asteroids with maybe a planet moving slower, outer nebula moving slowest
		-- the inner band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 2min)
			left_blackhole_inner_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			left_bh_inner_band_radius = 40000
			left_bh_inner_band_orbit_speed = 360/(60 * 120) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 120 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			left_bh_inner_band_clump_density = 8  -- the number of nebula in a clump
			left_bh_inner_band_clump_spread = 40  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 45 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 135 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 225 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (left_bh_inner_band_clump_spread/2)
				spread_angle_end = 315 + (left_bh_inner_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_inner_band[array_index] = {}
					left_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_inner_band[array_index][1])
					left_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_inner_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_inner_band[array_index][2], left_bh_inner_band_radius)
					array_index = array_index + 1
				end

		-- the middle band will be a random number of asteroids orbiting counter-clockwise at a randomly determined rate
			left_blackhole_middle_band = {}
			left_bh_middle_band_min_radius = 55000
			left_bh_middle_band_max_radius = 65000
			
			-- the middle band will not have clumps like the first and will just have a random placement of asteroids within the allowable band range, all with randomly set speeds 
			left_bh_mimdle_band_number_of_asteroids = 100
			left_bh_middle_band_min_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds
			left_bh_middle_band_max_orbit_speed = 360/(60 * 150) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 150 seconds
			
			for i=1,left_bh_mimdle_band_number_of_asteroids do
				-- each band will be a nested table (multi-dimensional array)
				  -- 1st position on the inner array will be the asteroid object
				  -- 2nd position on the inner array will be the radius distance from the blackhole center, randomly generated in a band range
				  -- 3rd position on the inner array will be the current angle of the asteroid in relation to the blackhole center
				  -- 4th position on the inner array will be the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				left_blackhole_middle_band[i]= {}
				left_blackhole_middle_band[i][1] = Asteroid() 
				table.insert(terrain_objects,left_blackhole_middle_band[i][1])
				left_blackhole_middle_band[i][2] = math.random(left_bh_middle_band_min_radius, left_bh_middle_band_max_radius)
				left_blackhole_middle_band[i][3] = math.random(1, 360)
				left_blackhole_middle_band[i][4] = random(left_bh_middle_band_min_orbit_speed, left_bh_middle_band_max_orbit_speed)
				-- setCirclePos(obj, x, y, angle, distance)
				  --   obj: An object.
				  --   x, y: Origin coordinates.
				  --   angle, distance: Relative heading and distance from the origin.
				setCirclePos(left_blackhole_middle_band[i][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_middle_band[i][3], left_blackhole_middle_band[i][2])
			end
			
		-- the outer band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 8min)
			left_blackhole_outer_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			left_bh_outer_band_radius = 80000
			left_bh_outer_band_orbit_speed = 360/(60 * 360) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 480 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			left_bh_outer_band_clump_density = 10  -- the number of nebula in a clump
			left_bh_outer_band_clump_spread = 60  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 45 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_outer_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 135 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_outer_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 225 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_inner_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (left_bh_outer_band_clump_spread/2)
				spread_angle_end = 315 + (left_bh_outer_band_clump_spread/2)
				for i=1,left_bh_outer_band_clump_density do
					left_blackhole_outer_band[array_index] = {}
					left_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,left_blackhole_outer_band[array_index][1])
					left_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(left_blackhole_outer_band[array_index][1], left_bh_x_coord, left_bh_y_coord, left_blackhole_outer_band[array_index][2], left_bh_outer_band_radius)
					array_index = array_index + 1
				end			

	-- second build the right side (essentially a duplicate of the left side set up diametrically opposed position)
	-- note that if you change an establishing variable in the left side, you'll need to make the same change for the right side if you want to keep them balanced
		right_bh_x_coord = 100000
		right_bh_y_coord = -60000
		right_blackhole = BlackHole():setPosition(right_bh_x_coord, right_bh_y_coord)
		table.insert(terrain_objects,right_blackhole)

		-- there will be 3 bands of orbiting stuff:  inner nebula moving quickest, middle asteroids with maybe a planet moving slower, outer nebula moving slowest
		-- the inner band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 2min)
			right_blackhole_inner_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			right_bh_inner_band_radius = 40000
			right_bh_inner_band_orbit_speed = 360/(60 * 120) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 120 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			right_bh_inner_band_clump_density = 8  -- the number of nebula in a clump
			right_bh_inner_band_clump_spread = 40  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 45 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 135 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 225 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (right_bh_inner_band_clump_spread/2)
				spread_angle_end = 315 + (right_bh_inner_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_inner_band[array_index] = {}
					right_blackhole_inner_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_inner_band[array_index][1])
					right_blackhole_inner_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_inner_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_inner_band[array_index][2], right_bh_inner_band_radius)
					array_index = array_index + 1
				end

		-- the middle band will be a random number of asteroids orbiting counter-clockwise at a randomly determined rate
			right_blackhole_middle_band = {}
			right_bh_middle_band_min_radius = 55000
			right_bh_middle_band_max_radius = 65000
			
			-- the middle band will not have clumps like the first and will just have a random placement of asteroids within the allowable band range, all with randomly set speeds 
			right_bh_mimdle_band_number_of_asteroids = 100
			right_bh_middle_band_min_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds
			right_bh_middle_band_max_orbit_speed = 360/(60 * 150) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 150 seconds
			
			for i=1,right_bh_mimdle_band_number_of_asteroids do
				-- each band will be a nested table (multi-dimensional array)
				  -- 1st position on the inner array will be the asteroid object
				  -- 2nd position on the inner array will be the radius distance from the blackhole center, randomly generated in a band range
				  -- 3rd position on the inner array will be the current angle of the asteroid in relation to the blackhole center
				  -- 4th position on the inner array will be the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				right_blackhole_middle_band[i]= {}
				right_blackhole_middle_band[i][1] = Asteroid() 
				table.insert(terrain_objects,right_blackhole_middle_band[i][1])
				right_blackhole_middle_band[i][2] = math.random(right_bh_middle_band_min_radius, right_bh_middle_band_max_radius)
				right_blackhole_middle_band[i][3] = math.random(1, 360)
				right_blackhole_middle_band[i][4] = random(right_bh_middle_band_min_orbit_speed, right_bh_middle_band_max_orbit_speed)
				-- setCirclePos(obj, x, y, angle, distance)
				  --   obj: An object.
				  --   x, y: Origin coordinates.
				  --   angle, distance: Relative heading and distance from the origin.
				setCirclePos(right_blackhole_middle_band[i][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_middle_band[i][3], right_blackhole_middle_band[i][2])
			end
			
		-- the outer band will be clumps of nebula orbiting clockwise (orbit rate is set by variable, but initially 1 orbit in 8min)
			right_blackhole_outer_band = {}
			-- each band will be a nested table (multi-dimensional array)
			  -- 1st position on the inner array will be the nebula object
			  -- 2nd position on the inner array will be the current angle of the nebula in relation to the blackhole center
			  -- there is no need to keep track of the speed in this case as it is uniform for all nebula in this band
			right_bh_outer_band_radius = 80000
			right_bh_outer_band_orbit_speed = 360/(60 * 360) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 360 seconds; uniform for all nebula
			-- because in this design we want the nebula more "clumpy" with gaps inbetween the clumps, there will be 4 clumps of nebula, one starting in each quadrant, centered on the 45 
			-- degree angle of that quadrant, spanning a variable degree of arc; make the number of nebula in each clump a variable so we can easily modify how thick each clump will be
			right_bh_outer_band_clump_density = 10  -- the number of nebula in a clump
			right_bh_outer_band_clump_spread = 60  -- the number of degrees of arc for the clump spread of the quandrant bisecting angle
			local array_index = 1
			-- first clump
				begin_spread_angle = 45 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 45 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_outer_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- second clump
				begin_spread_angle = 135 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 135 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_outer_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- third clump
				begin_spread_angle = 225 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 225 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_inner_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end
			-- fourth clump
				begin_spread_angle = 315 - (right_bh_outer_band_clump_spread/2)
				spread_angle_end = 315 + (right_bh_outer_band_clump_spread/2)
				for i=1,right_bh_outer_band_clump_density do
					right_blackhole_outer_band[array_index] = {}
					right_blackhole_outer_band[array_index][1] = Nebula()
					table.insert(terrain_objects,right_blackhole_outer_band[array_index][1])
					right_blackhole_outer_band[array_index][2] = math.random(begin_spread_angle, spread_angle_end)  
					-- setCirclePos(obj, x, y, angle, distance)
					--   obj: An object.
					--   x, y: Origin coordinates.
					--   angle, distance: Relative heading and distance from the origin.
					setCirclePos(right_blackhole_outer_band[array_index][1], right_bh_x_coord, right_bh_y_coord, right_blackhole_outer_band[array_index][2], right_bh_outer_band_radius)
					array_index = array_index + 1
				end	
				
	-- if desired, the blackholes can orbit the entire playing area by using the center as the origin
	-- note that in order to do this, the blackholes need to be equidistant from the origin along the x axis; 
	-- this routine will auto set the right blackhole x value to be opposite of the left blackhole x value
	-- take care that the black holes are not going to sweep through the initial boundary area, thereby sucking up stations or flags!
	
		-- set the radius
		orbital_radius = left_bh_x_coord * -1
		-- set the initial angles of the blackholes relative to the origin
		left_bh_angle_to_origin = 180
		right_bh_angle_to_origin = 0
		-- set the blackhole orbital velocity to complete 1 full orbit in ... 
		-- orbital_velocity = 0.003  -- the complete game time of 30 mins ?
		-- orbital_velocity = 0.006  -- 15 mins ?
		-- orbital_velocity = 0.009  -- 10 mins ?
		-- orbital_velocity = 0.03  -- 3 mins ?
		orbital_velocity = 0.3  -- 3 mins ?

	orbital_movement = false
	blackhole_movement = false

	addGMFunction(_("buttonGM", "Orbit Toggle"), 
		function()
			if orbital_movement then
				orbital_movement = false
			else
				orbital_movement = true
			end				
		end
	)

	addGMFunction(_("buttonGM", "Move Toggle"), 
		function()
			if blackhole_movement then
				blackhole_movement = false
			else
				blackhole_movement = true
			end				
		end
	)
	
end	--justPassingBy
function moveJustPassingBy(delta)

	-- if desired, the blackholes can orbit the entire playing area by using the center as the origin
	-- use this section if you want to do this, comment out if you don't
	-- note that once underway, 'left' and 'right' refer to the original configurations as their positions will change (duh....)
		--[[
		-- update the angular positions around the origin and adjust for 360
		left_bh_angle_to_origin = left_bh_angle_to_origin + orbital_velocity
		if left_bh_angle_to_origin > 360 then
			left_bh_angle_to_origin = left_bh_angle_to_origin - 360
		end
		right_bh_angle_to_origin = right_bh_angle_to_origin + orbital_velocity
		if right_bh_angle_to_origin > 360 then
			right_bh_angle_to_origin = right_bh_angle_to_origin - 360
		end
		
		-- set the new blackhole positions before updating all their orbiting bodies
		-- setCirclePos(obj, x, y, angle, distance)
			--   obj: An object.
			--   x, y: Origin coordinates.
			--   angle, distance: Relative heading and distance from the origin.
		setCirclePos(left_blackhole, 0, 0, left_bh_angle_to_origin, orbital_radius)
		setCirclePos(right_blackhole, 0, 0, right_bh_angle_to_origin, orbital_radius)
		--]]

	-- first do the left side
		left_bh_center_x, left_bh_center_y = left_blackhole:getPosition()
		-- if desired, move the left blackhole linearly to the right little by little.... 
		-- a rate of x = +/- 5 seems to move the bh 20U in 1.5 min, a rate of +/- 2.5 will move the entire 200U distance in about 30 min (i.e., full game time)
		if blackhole_movement then
			left_blackhole:setPosition(left_bh_center_x + 2.5, left_bh_center_y)
		end
			
		if orbital_movement then
			for i,nebula_table in ipairs(left_blackhole_inner_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + left_bh_inner_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], left_bh_center_x, left_bh_center_y, nebula_table[2], left_bh_inner_band_radius)
			end

			for i,asteroid_table in ipairs(left_blackhole_middle_band) do
				-- DEcrement the angle (go counter-clockwise) according to the previously randomized velocity in the table (change in arc per cycle)
				asteroid_table[3] = asteroid_table[3] - asteroid_table[4]
				if asteroid_table[3] < 0 then
					asteroid_table[3] = asteroid_table[3] + 360
				end
				setCirclePos(left_blackhole_middle_band[i][1], left_bh_center_x, left_bh_center_y, left_blackhole_middle_band[i][3], left_blackhole_middle_band[i][2])
			end

			for i,nebula_table in ipairs(left_blackhole_outer_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + left_bh_outer_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], left_bh_center_x, left_bh_center_y, nebula_table[2], left_bh_outer_band_radius)
			end
		end

	-- second do the right side
		right_bh_center_x, right_bh_center_y = right_blackhole:getPosition()
		-- if desired, move the right blackhole to the right little by little.... 
		-- a rate of x = +/- 5 seems to move the bh 20U in 1.5 min, a rate of +/- 2.5 will move the entire 200U distance in about 30 min (i.e., full game time)
		if blackhole_movement then
			right_blackhole:setPosition(right_bh_center_x - 2.5, right_bh_center_y)
		end
			
		if orbital_movement then
			for i,nebula_table in ipairs(right_blackhole_inner_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + right_bh_inner_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], right_bh_center_x, right_bh_center_y, nebula_table[2], right_bh_inner_band_radius)
			end

			for i,asteroid_table in ipairs(right_blackhole_middle_band) do
				-- DEcrement the angle (go counter-clockwise) according to the previously randomized velocity in the table (change in arc per cycle)
				asteroid_table[3] = asteroid_table[3] - asteroid_table[4]
				if asteroid_table[3] < 0 then
					asteroid_table[3] = asteroid_table[3] + 360
				end
				setCirclePos(right_blackhole_middle_band[i][1], right_bh_center_x, right_bh_center_y, right_blackhole_middle_band[i][3], right_blackhole_middle_band[i][2])
			end

			for i,nebula_table in ipairs(right_blackhole_outer_band) do
				--increment the angle according to the predetermined velocity (change in arc per cycle)
				nebula_table[2] = nebula_table[2] + right_bh_outer_band_orbit_speed
				if nebula_table[2] > 360 then
					nebula_table[2] = nebula_table[2] - 360
				end
				setCirclePos(nebula_table[1], right_bh_center_x, right_bh_center_y, nebula_table[2], right_bh_outer_band_radius)
			end
		end

end	--moveJustPassingBy
--	Down The Rabbit Hole Terrain  --
function downTheRabbitHole()
	-- This terrain is a collection of interconnected worm holes that connect the interiors of the opposing sides; in effect, it creates a "multi-front" because now the opposing team can come from the 
	-- rear as well as the front; this will no doubt cause a great deal of consternation... ha

	-- player tagged relocation override is located at the end of this function; it's at the end because the values depend on "terrain" variables calculated in the middle of the function

	dynamicTerrain = moveDownTheRabbitHole   
	show_nebula = true
	
	-- WORM HOLES 
		worm_hole_list = {}
		local worm_hole_coordinates = {
		--	human side
			{x = -180057	,y =	462		,target_x =	175945	,target_y =	-56		},
			{x = -129765	,y =	49780	,target_x =	126325	,target_y =	-47942	},
			{x = -50428		,y =	29117	,target_x =	46238	,target_y =	-28454	},
			{x = -51402		,y =	-29753	,target_x =	45106	,target_y =	26256	},
			{x = -130545	,y =	-50220	,target_x =	124937	,target_y =	46904	},
		--	kraylor side
			{x = 48792		,y =	28337	,target_x =	-48201	,target_y =	-27799	},
			{x = 48403		,y =	-30337	,target_x =	-47101	,target_y =	26969	},
			{x = 130665		,y =	-49904	,target_x =	-125248	,target_y =	47945	},
			{x = 128938		,y =	48560	,target_x =	-126058	,target_y =	-48404	},
			{x = 179994		,y =	0		,target_x =	-176025	,target_y =	-172	},
		}
		for i=1,#worm_hole_coordinates do
			local worm = WormHole():setPosition(worm_hole_coordinates[i].x,worm_hole_coordinates[i].y)
			worm.final_target_x = worm_hole_coordinates[i].target_x
			worm.final_target_y = worm_hole_coordinates[i].target_y
			local vx, vy = vectorFromAngle(random(0,360),3000)
			worm:setTargetPosition(worm_hole_coordinates[i].x + vx,worm_hole_coordinates[i].y + vy)
			worm:onTeleportation(function(self,teleportee)
				local teleportee_type = teleportee.typeName
				if gameTimeLimit < (maxGameTime - hideFlagTime - 1) then
					if teleportee_type == "PlayerSpaceship" then
						if teleportee:hasSystem("warp") then
							teleportee:setSystemHealth("warp",teleportee:getSystemHealth("warp")*.9)
						end
						if teleportee:hasSystem("jumpdrive") then
							teleportee:setSystemHealth("jumpdrive",teleportee:getSystemHealth("jumpdrive")*.9)
						end
					end
				else
					local wx, wy = self:getPosition()
					local vx, vy = vectorFromAngle(random(0,360),3000)
					self:setTargetPosition(wx + vx, wy + vy)
					if teleportee_type == "PlayerSpaceship" then
						if teleportee:hasPlayerAtPosition("Helms") then
							teleportee.worm_hole_target_message = "worm_hole_target_message"
							teleportee:addCustomMessage("Helms",teleportee.worm_hole_target_message,_("wormhole-msgHelms", "Worm hole teleportation destination will change after the flag hiding time expires"))
						end
						if teleportee:hasPlayerAtPosition("Tactical") then
							teleportee.worm_hole_target_message_tac = "worm_hole_target_message_tac"
							teleportee:addCustomMessage("Tactical",teleportee.worm_hole_target_message_tac,_("wormhole-msgTactical", "Worm hole teleportation destination will change after the flag hiding time expires"))
						end
					end
				end
			end)
			table.insert(worm_hole_list,worm)
			table.insert(terrain_objects,worm)
		end

	-- PLANETS/RING OF ASTEROIDS WITH MINES 
		-- applies to both sides
			main_planet_center_x_distance = 100000
			main_planet_center_y_distance = 0
			main_planet_radius = 10000
			
			number_of_asteroids_in_ring = 100
			asteroid_min_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds 
			asteroid_max_orbit_speed = 360/(60 * 150) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 150 seconds
			
			number_of_mines_in_ring = 20
			mine_min_orbit_speed = 360/(60 * 240) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 240 seconds
			mine_max_orbit_speed = 360/(60 * 150) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 150 seconds

		-- human side
			human_planet_center_x = -1 * main_planet_center_x_distance
			human_planet_center_y = main_planet_center_y_distance
			human_planet_radius = main_planet_radius
			human_planet_gas_giant = Planet()
				:setPosition(human_planet_center_x,human_planet_center_y)
				:setPlanetRadius(human_planet_radius)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/gas-1.png")
				:setPlanetAtmosphereColor(0,0.8,0.2)
				:setAxialRotationTime(120)
			table.insert(terrain_objects,human_planet_gas_giant)
				
			human_moon_1_radius = 1000
			human_moon_1_orbit_distance = 5000
			human_moon_1_orbit_time = 300  -- measured in near-real-time seconds I believe
			human_moon_1_center_x = human_planet_center_x
			human_moon_1_center_y = human_planet_center_y + human_planet_radius + human_moon_1_orbit_distance + human_moon_1_radius
			human_moon_1 = Planet()
				:setPosition(human_moon_1_center_x,human_moon_1_center_y)
				:setPlanetRadius(human_moon_1_radius)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/moon-1.png")
				:setPlanetAtmosphereColor(0.2,0.2,0.2)
				:setAxialRotationTime(120)
				:setOrbit(human_planet_gas_giant, human_moon_1_orbit_time)
			table.insert(terrain_objects,human_moon_1)			

			human_moon_2_radius = 2500
			human_moon_2_orbit_distance = human_moon_1_orbit_distance + 12500
			human_moon_2_orbit_time = 900  -- measured in near-real-time seconds I believe
			human_moon_2_center_x = human_planet_center_x
			human_moon_2_center_y = human_planet_center_y + human_planet_radius + human_moon_2_orbit_distance + human_moon_2_radius
			human_moon_2 = Planet()
				:setPosition(human_moon_2_center_x,human_moon_2_center_y)
				:setPlanetRadius(human_moon_2_radius)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/planet-1.png")
				:setPlanetCloudTexture("planets/clouds-1.png")
				:setPlanetAtmosphereTexture("planets/atmosphere.png")
				:setPlanetAtmosphereColor(0.2,0.2,1.0)
				:setAxialRotationTime(120)
				:setOrbit(human_planet_gas_giant, human_moon_2_orbit_time)
			table.insert(terrain_objects,human_moon_2)			
				
			human_asteroid_ring_min_radius = human_moon_1_center_y + human_moon_1_radius + 1000
			human_asteroid_ring_max_radius = human_moon_2_center_y - human_moon_2_radius - 1000
			human_asteroid_ring = {}
		
			for i=1,number_of_asteroids_in_ring do
				human_asteroid_ring[i] = Asteroid()
				human_asteroid_ring[i].angle = math.random(1, 360)  -- the current angle of the asteroid in relation to the planet center
				human_asteroid_ring[i].radius = math.random(human_asteroid_ring_min_radius, human_asteroid_ring_max_radius) -- the radius distance of the asteroid from the planet center, randomly generated in a band range
				human_asteroid_ring[i].speed = random(asteroid_min_orbit_speed, asteroid_max_orbit_speed) -- the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				setCirclePos(human_asteroid_ring[i], 
					human_planet_center_x, 
					human_planet_center_y, 
					human_asteroid_ring[i].angle, 
					human_asteroid_ring[i].radius)
				table.insert(terrain_objects,human_asteroid_ring[i])
			end

			human_mine_ring = {}  -- these are actually interspersed in the ring of asteroids, but they have their own table for update purposes
			
			for i=1,number_of_mines_in_ring do
				human_mine_ring[i] = Mine()
				human_mine_ring[i].angle = math.random(1, 360)  -- the current angle of the mine in relation to the planet center
				human_mine_ring[i].radius = math.random(human_asteroid_ring_min_radius, human_asteroid_ring_max_radius) -- the radius distance of the mine from the planet center, randomly generated in a band range
				human_mine_ring[i].speed = random(mine_min_orbit_speed, mine_max_orbit_speed) -- the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				setCirclePos(human_mine_ring[i], 
					human_planet_center_x, 
					human_planet_center_y, 
					human_mine_ring[i].angle, 
					human_mine_ring[i].radius)
				table.insert(terrain_objects,human_mine_ring[i])
			end

		-- kraylor side
			kraylor_planet_center_x = main_planet_center_x_distance
			kraylor_planet_center_y = main_planet_center_y_distance
			kraylor_planet_radius = main_planet_radius
			kraylor_planet_molten_giant = Planet()
				:setPosition(kraylor_planet_center_x,kraylor_planet_center_y)
				:setPlanetRadius(kraylor_planet_radius)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/planet-2.png")
				:setPlanetAtmosphereColor(0.8,0,0)
				:setAxialRotationTime(120)
			table.insert(terrain_objects,kraylor_planet_molten_giant)
				
			kraylor_moon_1_radius = 1000
			kraylor_moon_1_orbit_distance = 5000
			kraylor_moon_1_orbit_time = 300  -- measured in near-real-time seconds I believe
			kraylor_moon_1_center_x = kraylor_planet_center_x
			kraylor_moon_1_center_y = kraylor_planet_center_y + kraylor_planet_radius + kraylor_moon_1_orbit_distance + kraylor_moon_1_radius
			kraylor_moon_1 = Planet()
				:setPosition(kraylor_moon_1_center_x,kraylor_moon_1_center_y)
				:setPlanetRadius(kraylor_moon_1_radius)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/moon-1.png")
				:setPlanetAtmosphereColor(0.2,0.2,0.2)
				:setAxialRotationTime(120)
				:setOrbit(kraylor_planet_molten_giant, kraylor_moon_1_orbit_time)
			table.insert(terrain_objects,kraylor_moon_1)

			kraylor_moon_2_radius = 2500
			kraylor_moon_2_orbit_distance = kraylor_moon_1_orbit_distance + 12500
			kraylor_moon_2_orbit_time = 900  -- measured in near-real-time seconds I believe
			kraylor_moon_2_center_x = kraylor_planet_center_x
			kraylor_moon_2_center_y = kraylor_planet_center_y + kraylor_planet_radius + kraylor_moon_2_orbit_distance + kraylor_moon_2_radius
			kraylor_moon_2 = Planet()
				:setPosition(kraylor_moon_2_center_x,kraylor_moon_2_center_y)
				:setPlanetRadius(kraylor_moon_2_radius)
				:setDistanceFromMovementPlane(0)
				:setPlanetSurfaceTexture("planets/planet-1.png")
				:setPlanetCloudTexture("planets/clouds-1.png")
				:setPlanetAtmosphereTexture("planets/atmosphere.png")
				:setPlanetAtmosphereColor(0.2,0.2,1.0)
				:setAxialRotationTime(120)
				:setOrbit(kraylor_planet_molten_giant, kraylor_moon_2_orbit_time)
			table.insert(terrain_objects,kraylor_moon_2)
				
			kraylor_asteroid_ring_min_radius = kraylor_moon_1_center_y + kraylor_moon_1_radius + 1000
			kraylor_asteroid_ring_max_radius = kraylor_moon_2_center_y - kraylor_moon_2_radius - 1000
			kraylor_asteroid_ring = {}
		
			for i=1,number_of_asteroids_in_ring do
				kraylor_asteroid_ring[i] = Asteroid()
				kraylor_asteroid_ring[i].angle = math.random(1, 360)  -- the current angle of the asteroid in relation to the planet center
				kraylor_asteroid_ring[i].radius = math.random(kraylor_asteroid_ring_min_radius, kraylor_asteroid_ring_max_radius) -- the radius distance of the asteroid from the planet center, randomly generated in a band range
				kraylor_asteroid_ring[i].speed = random(asteroid_min_orbit_speed, asteroid_max_orbit_speed) -- the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				setCirclePos(kraylor_asteroid_ring[i], 
					kraylor_planet_center_x, 
					kraylor_planet_center_y, 
					kraylor_asteroid_ring[i].angle, 
					kraylor_asteroid_ring[i].radius)
				table.insert(terrain_objects,kraylor_asteroid_ring[i])
			end

			kraylor_mine_ring = {}  -- these are actually interspersed in the ring of asteroids, but they have their own table for update purposes
			
			for i=1,number_of_mines_in_ring do
				kraylor_mine_ring[i] = Mine()
				kraylor_mine_ring[i].angle = math.random(1, 360)  -- the current angle of the mine in relation to the planet center
				kraylor_mine_ring[i].radius = math.random(kraylor_asteroid_ring_min_radius, kraylor_asteroid_ring_max_radius) -- the radius distance of the mine from the planet center, randomly generated in a band range
				kraylor_mine_ring[i].speed = random(mine_min_orbit_speed, mine_max_orbit_speed) -- the orbital speed of the asteroid, expressed as a delta of angle change per update cycle, randomly generated
				setCirclePos(kraylor_mine_ring[i], 
					kraylor_planet_center_x, 
					kraylor_planet_center_y, 
					kraylor_mine_ring[i].angle, 
					kraylor_mine_ring[i].radius)
				table.insert(terrain_objects,kraylor_mine_ring[i])
			end

	-- STATIONS
		-- human side
			human_orbital_station_1 = SpaceStation()
				:setTemplate("Small Station")
				:setFaction("Human Navy")
				:setCallSign("DS845")
			table.insert(terrain_objects,human_orbital_station_1)
			human_orbital_station_1.angle = 270 
			human_orbital_station_1.speed = 360/(60 * (human_moon_1_orbit_time + (human_moon_1_orbit_time * 0.05))) -- this is supposed to equate to the same time it takes for human moon 1 to orbit the planet... maybe... 
			human_orbital_station_1.distance = human_moon_1_center_y
			setCirclePos(human_orbital_station_1, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_1.angle, 
				human_orbital_station_1.distance)

			human_orbital_station_2 = SpaceStation()
				:setTemplate("Huge Station")
				:setFaction("Human Navy")
				:setCallSign("DS10246")
			table.insert(terrain_objects,human_orbital_station_2)
			human_orbital_station_2.angle = 0 
			human_orbital_station_2.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			human_orbital_station_2.distance = human_moon_2_center_y + human_moon_2_radius + 10000
			setCirclePos(human_orbital_station_2, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_2.angle, 
				human_orbital_station_2.distance)

			human_orbital_station_3 = SpaceStation()
				:setTemplate("Medium Station")
				:setFaction("Human Navy")
				:setCallSign("DS1038")
			table.insert(terrain_objects,human_orbital_station_3)
			human_orbital_station_3.angle = 180 
			human_orbital_station_3.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			human_orbital_station_3.distance = human_moon_2_center_y + human_moon_2_radius + 10000
			setCirclePos(human_orbital_station_3, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_3.angle, 
				human_orbital_station_3.distance)
				
			human_orbital_station_4 = SpaceStation()
				:setTemplate("Medium Station")
				:setFaction("Independent")
				:setCallSign("DS2639")
			table.insert(terrain_objects,human_orbital_station_4)
			human_orbital_station_4.angle = 90 
			human_orbital_station_4.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			human_orbital_station_4.distance = human_moon_2_center_y + human_moon_2_radius + 10000
			setCirclePos(human_orbital_station_4, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_4.angle, 
				human_orbital_station_4.distance)
				
			human_orbital_station_5 = SpaceStation()
				:setTemplate("Medium Station")
				:setFaction("Independent")
				:setCallSign("DS317")
			table.insert(terrain_objects,human_orbital_station_5)
			human_orbital_station_5.angle = 270 
			human_orbital_station_5.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			human_orbital_station_5.distance = human_moon_2_center_y + human_moon_2_radius + 10000
			setCirclePos(human_orbital_station_5, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_5.angle, 
				human_orbital_station_5.distance)
			
			-- non-moving stations by the forward and middle wormholes
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS877"):setPosition(-135096, -50568))
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS875"):setPosition(-54873, -33476))
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS876"):setPosition(-54445, 32967))
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS878"):setPosition(-134989, 49845))
			-- non-moving station; forward center
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Human Navy"):setCallSign("DS879"):setPosition(-32800, 101))
			-- non-moving stations; middle distance to the flanks
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCallSign("DS890"):setPosition(-73903, -50010))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Human Navy"):setCallSign("DS889"):setPosition(-73250, 49216))
			-- non-moving stations; forward near dividing line
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS886"):setPosition(-20112, 50261))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS885"):setPosition(-20112, 30024))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS884"):setPosition(-19982, -50010))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS883"):setPosition(-20112, -30034))
			-- non-moving stations; to the rear
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS888"):setPosition(-167515, 29240))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS887"):setPosition(-167123, -28728))

		-- kraylor side
			kraylor_orbital_station_1 = SpaceStation()
				:setTemplate("Small Station")
				:setFaction("Kraylor")
				:setCallSign("DS734")
			table.insert(terrain_objects,kraylor_orbital_station_1)
			kraylor_orbital_station_1.angle = 270 
			kraylor_orbital_station_1.speed = 360/(60 * (kraylor_moon_1_orbit_time + (kraylor_moon_1_orbit_time * 0.05))) -- this is supposed to equate to the same time it takes for kraylor moon 1 to orbit the planet... maybe... 
			kraylor_orbital_station_1.distance = kraylor_moon_1_center_y
			setCirclePos(kraylor_orbital_station_1, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_1.angle, 
				kraylor_orbital_station_1.distance)

			kraylor_orbital_station_2 = SpaceStation()
				:setTemplate("Huge Station")
				:setFaction("Kraylor")
				:setCallSign("DS9135")
			table.insert(terrain_objects,kraylor_orbital_station_2)
			kraylor_orbital_station_2.angle = 180 
			kraylor_orbital_station_2.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			kraylor_orbital_station_2.distance = kraylor_moon_2_center_y + kraylor_moon_2_radius + 10000
			setCirclePos(kraylor_orbital_station_2, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_2.angle, 
				kraylor_orbital_station_2.distance)

			kraylor_orbital_station_3 = SpaceStation()
				:setTemplate("Medium Station")
				:setFaction("Kraylor")
				:setCallSign("DS927")
			table.insert(terrain_objects,kraylor_orbital_station_3)
			kraylor_orbital_station_3.angle = 0 
			kraylor_orbital_station_3.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			kraylor_orbital_station_3.distance = kraylor_moon_2_center_y + kraylor_moon_2_radius + 10000
			setCirclePos(kraylor_orbital_station_3, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_3.angle, 
				kraylor_orbital_station_3.distance)
				
			kraylor_orbital_station_4 = SpaceStation()
				:setTemplate("Medium Station")
				:setFaction("Independent")
				:setCallSign("DS1528")
			table.insert(terrain_objects,kraylor_orbital_station_4)
			kraylor_orbital_station_4.angle = 90 
			kraylor_orbital_station_4.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			kraylor_orbital_station_4.distance = kraylor_moon_2_center_y + kraylor_moon_2_radius + 10000
			setCirclePos(kraylor_orbital_station_4, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_4.angle, 
				kraylor_orbital_station_4.distance)
				
			kraylor_orbital_station_5 = SpaceStation()
				:setTemplate("Medium Station")
				:setFaction("Independent")
				:setCallSign("DS206")
			table.insert(terrain_objects,kraylor_orbital_station_5)
			kraylor_orbital_station_5.angle = 270 
			kraylor_orbital_station_5.speed = 360/(60 * 1800) -- this equates to the number of degrees traversed for each update call if one complete orbit takes 1800 seconds
			kraylor_orbital_station_5.distance = kraylor_moon_2_center_y + kraylor_moon_2_radius + 10000
			setCirclePos(kraylor_orbital_station_5, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_5.angle, 
				kraylor_orbital_station_5.distance)
			
			-- non-moving stations by the forward and middle wormholes
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("DS766"):setPosition(135096, -50568))
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("DS764"):setPosition(54873, -33476))
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("DS765"):setPosition(54445, 32967))
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("DS767"):setPosition(134989, 49845))
			-- non-moving station; forward center
				table.insert(terrain_objects,SpaceStation():setTemplate("Medium Station"):setFaction("Kraylor"):setCallSign("DS768"):setPosition(32800, 101))
			-- non-moving stations; middle distance to the flanks
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("DS789"):setPosition(73903, -50010))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Kraylor"):setCallSign("DS778"):setPosition(73250, 49216))
			-- non-moving stations; forward near dividing line
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS775"):setPosition(20112, 50261))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS774"):setPosition(20112, 30024))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS773"):setPosition(19982, -50010))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS772"):setPosition(20112, -30034))
			-- non-moving stations; to the rear
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS777"):setPosition(167515, 29240))
				table.insert(terrain_objects,SpaceStation():setTemplate("Large Station"):setFaction("Independent"):setCallSign("DS776"):setPosition(167123, -28728))

	-- NEBULA AND MINES IN THE NEBULA
		if show_nebula then
			-- human side 
				table.insert(terrain_objects,Nebula():setPosition(-25950, 15065))
				table.insert(terrain_objects,Nebula():setPosition(-17927, 3032))
				table.insert(terrain_objects,Nebula():setPosition(-18114, -4244))
				table.insert(terrain_objects,Nebula():setPosition(-25390, -18424))
				table.insert(terrain_objects,Mine():setPosition(-35073, -35990))
				table.insert(terrain_objects,Mine():setPosition(-36480, -37598))
				table.insert(terrain_objects,Mine():setPosition(-37887, -41417))
				table.insert(terrain_objects,Mine():setPosition(-50551, -65738))
				table.insert(terrain_objects,Mine():setPosition(-49144, -62723))
				table.insert(terrain_objects,Mine():setPosition(-29445, -72573))
				table.insert(terrain_objects,Mine():setPosition(-33666, -66944))
				table.insert(terrain_objects,Mine():setPosition(-57586, -73176))
				table.insert(terrain_objects,Mine():setPosition(-41505, -50864))
				table.insert(terrain_objects,Mine():setPosition(-38088, -46040))
				table.insert(terrain_objects,Mine():setPosition(-38490, -62321))
				table.insert(terrain_objects,Mine():setPosition(-44923, -55688))
				table.insert(terrain_objects,Mine():setPosition(-52762, -68753))
				table.insert(terrain_objects,Mine():setPosition(-55174, -73779))
				table.insert(terrain_objects,Nebula():setPosition(-48679, -59598))
				table.insert(terrain_objects,Nebula():setPosition(-52498, -66834))
				table.insert(terrain_objects,Nebula():setPosition(-54508, -73668))
				table.insert(terrain_objects,Nebula():setPosition(-66970, -78090))
				table.insert(terrain_objects,Nebula():setPosition(-71393, -31658))
				table.insert(terrain_objects,Nebula():setPosition(-89483, -65427))
				table.insert(terrain_objects,Nebula():setPosition(-36418, -65427))
				table.insert(terrain_objects,Nebula():setPosition(-39835, -59598))
				table.insert(terrain_objects,Nebula():setPosition(-34006, -34472))
				table.insert(terrain_objects,Nebula():setPosition(-38830, -42714))
				table.insert(terrain_objects,Nebula():setPosition(-73202, -60402))
				table.insert(terrain_objects,Nebula():setPosition(-42850, -51357))
				table.insert(terrain_objects,Nebula():setPosition(-100538, -82915))
				table.insert(terrain_objects,Nebula():setPosition(-83252, -76482))
				table.insert(terrain_objects,Mine():setPosition(-104822, -56090))
				table.insert(terrain_objects,Nebula():setPosition(-135312, -79900))
				table.insert(terrain_objects,Nebula():setPosition(-122448, -76884))
				table.insert(terrain_objects,Mine():setPosition(-164659, -17990))
				table.insert(terrain_objects,Mine():setPosition(-167875, -15578))
				table.insert(terrain_objects,Mine():setPosition(-191393, -15377))
				table.insert(terrain_objects,Nebula():setPosition(-193202, -61407))
				table.insert(terrain_objects,Mine():setPosition(-160237, -5528))
				table.insert(terrain_objects,Mine():setPosition(-162448, -9950))
				table.insert(terrain_objects,Mine():setPosition(-102008, -56492))
				table.insert(terrain_objects,Nebula():setPosition(-100337, -55377))
				table.insert(terrain_objects,Nebula():setPosition(-106367, -56181))
				table.insert(terrain_objects,Mine():setPosition(-160036, -41910))
				table.insert(terrain_objects,Mine():setPosition(-178327, -20402))
				table.insert(terrain_objects,Mine():setPosition(-185764, -26030))
				table.insert(terrain_objects,Mine():setPosition(-155011, -27236))
				table.insert(terrain_objects,Mine():setPosition(-184558, -40503))
				table.insert(terrain_objects,Nebula():setPosition(-115011, -67236))
				table.insert(terrain_objects,Mine():setPosition(-159835, 12764))
				table.insert(terrain_objects,Mine():setPosition(-155413, 11759))
				table.insert(terrain_objects,Mine():setPosition(-156217, 27437))
				table.insert(terrain_objects,Nebula():setPosition(-164659, -65628))
				table.insert(terrain_objects,Nebula():setPosition(-164659, -52161))
				table.insert(terrain_objects,Mine():setPosition(-154609, -12362))
				table.insert(terrain_objects,Nebula():setPosition(-184960, -39698))
				table.insert(terrain_objects,Nebula():setPosition(-193202, -40302))
				table.insert(terrain_objects,Nebula():setPosition(-161242, -41910))
				table.insert(terrain_objects,Nebula():setPosition(-184960, -70653))
				table.insert(terrain_objects,Mine():setPosition(-150790, 15578))
				table.insert(terrain_objects,Mine():setPosition(-174508, 29648))
				table.insert(terrain_objects,Mine():setPosition(-167674, 17588))
				table.insert(terrain_objects,Nebula():setPosition(-186166, -48744))
				table.insert(terrain_objects,Nebula():setPosition(-187975, -55176))
				table.insert(terrain_objects,Nebula():setPosition(-170890, -78090))
				table.insert(terrain_objects,Nebula():setPosition(-173704, -61005))
				table.insert(terrain_objects,Nebula():setPosition(-25161, -79497))
				table.insert(terrain_objects,Nebula():setPosition(-31795, -72261))
				table.insert(terrain_objects,Mine():setPosition(-42108, 51649))
				table.insert(terrain_objects,Mine():setPosition(-42510, 48030))
				table.insert(terrain_objects,Nebula():setPosition(-41443, 41106))
				table.insert(terrain_objects,Nebula():setPosition(-69583, 30854))
				table.insert(terrain_objects,Nebula():setPosition(-73001, 56181))
				table.insert(terrain_objects,Mine():setPosition(-36681, 55066))
				table.insert(terrain_objects,Nebula():setPosition(-36217, 34070))
				table.insert(terrain_objects,Mine():setPosition(-96179, 56272))
				table.insert(terrain_objects,Nebula():setPosition(-94508, 57186))
				table.insert(terrain_objects,Nebula():setPosition(-98930, 52563))
				table.insert(terrain_objects,Mine():setPosition(-34872, 57679))
				table.insert(terrain_objects,Nebula():setPosition(-33805, 60402))
				table.insert(terrain_objects,Mine():setPosition(-46732, 55669))
				table.insert(terrain_objects,Nebula():setPosition(-38227, 53166))
				table.insert(terrain_objects,Mine():setPosition(-98993, 53860))
				table.insert(terrain_objects,Mine():setPosition(-99998, 56674))
				table.insert(terrain_objects,Nebula():setPosition(-100940, 81910))
				table.insert(terrain_objects,Nebula():setPosition(-63955, 69447))
				table.insert(terrain_objects,Nebula():setPosition(-70991, 74673))
				table.insert(terrain_objects,Nebula():setPosition(-84860, 73668))
				table.insert(terrain_objects,Nebula():setPosition(-87875, 65628))
				table.insert(terrain_objects,Nebula():setPosition(-44056, 52764))
				table.insert(terrain_objects,Nebula():setPosition(-43654, 48543))
				table.insert(terrain_objects,Mine():setPosition(-51355, 63709))
				table.insert(terrain_objects,Nebula():setPosition(-51091, 62814))
				table.insert(terrain_objects,Mine():setPosition(-21003, 70945))
				table.insert(terrain_objects,Nebula():setPosition(-19935, 73065))
				table.insert(terrain_objects,Mine():setPosition(-31656, 62905))
				table.insert(terrain_objects,Mine():setPosition(-28440, 67729))
				table.insert(terrain_objects,Nebula():setPosition(-27171, 66432))
				table.insert(terrain_objects,Mine():setPosition(-195212, -8342))
				table.insert(terrain_objects,Mine():setPosition(-193604, -31055))
				table.insert(terrain_objects,Nebula():setPosition(-213905, -49749))
				table.insert(terrain_objects,Mine():setPosition(-41304, 43809))
				table.insert(terrain_objects,Mine():setPosition(-39093, 40593))
				table.insert(terrain_objects,Mine():setPosition(-37887, 35367))
				table.insert(terrain_objects,Nebula():setPosition(-202448, 2111))
				table.insert(terrain_objects,Nebula():setPosition(-212498, -704))
				table.insert(terrain_objects,Nebula():setPosition(-205262, -13166))
				table.insert(terrain_objects,Nebula():setPosition(-210689, -16181))
				table.insert(terrain_objects,Mine():setPosition(-158227, 36482))
				table.insert(terrain_objects,Mine():setPosition(-154207, 37889))
				table.insert(terrain_objects,Mine():setPosition(-179533, 37487))
				table.insert(terrain_objects,Nebula():setPosition(-209684, -27035))
				table.insert(terrain_objects,Nebula():setPosition(-206468, -42111))
				table.insert(terrain_objects,Mine():setPosition(-165664, 40101))
				table.insert(terrain_objects,Mine():setPosition(-195413, 15176))
				table.insert(terrain_objects,Mine():setPosition(-199835, 7337))
				table.insert(terrain_objects,Mine():setPosition(-193403, -2312))
				table.insert(terrain_objects,Mine():setPosition(-202247, 33467))
				table.insert(terrain_objects,Mine():setPosition(-197423, 36683))
				table.insert(terrain_objects,Mine():setPosition(-196619, 21809))
				table.insert(terrain_objects,Nebula():setPosition(-209282, 26633))
				table.insert(terrain_objects,Nebula():setPosition(-205865, 20804))
				table.insert(terrain_objects,Nebula():setPosition(-206669, 12764))
				table.insert(terrain_objects,Nebula():setPosition(-204056, 47136))
				table.insert(terrain_objects,Nebula():setPosition(-212297, 46332))
				table.insert(terrain_objects,Nebula():setPosition(-206468, 33668))
				table.insert(terrain_objects,Nebula():setPosition(-214709, 35276))
				table.insert(terrain_objects,Mine():setPosition(-205061, 21608))
				table.insert(terrain_objects,Nebula():setPosition(-214709, 12965))
				table.insert(terrain_objects,Nebula():setPosition(-176518, 46131))
				table.insert(terrain_objects,Nebula():setPosition(-178930, 49146))
				table.insert(terrain_objects,Nebula():setPosition(-154207, 64623))
				table.insert(terrain_objects,Nebula():setPosition(-167272, 65226))
				table.insert(terrain_objects,Nebula():setPosition(-183754, 59598))
				table.insert(terrain_objects,Nebula():setPosition(-164659, 51156))
				table.insert(terrain_objects,Nebula():setPosition(-152197, 37085))
				table.insert(terrain_objects,Nebula():setPosition(-155212, 36080))
				table.insert(terrain_objects,Nebula():setPosition(-149784, 45729))
				table.insert(terrain_objects,Nebula():setPosition(-168076, 39296))
				table.insert(terrain_objects,Nebula():setPosition(-184960, 38894))
				table.insert(terrain_objects,Nebula():setPosition(-180538, 35075))
				table.insert(terrain_objects,Nebula():setPosition(-178327, 70452))
				table.insert(terrain_objects,Nebula():setPosition(-186970, 55980))
				table.insert(terrain_objects,Nebula():setPosition(-194207, 45528))
				table.insert(terrain_objects,Nebula():setPosition(-197222, 36683))
				table.insert(terrain_objects,Nebula():setPosition(-202850, 32864))
				table.insert(terrain_objects,Nebula():setPosition(-118026, 70452))
				table.insert(terrain_objects,Nebula():setPosition(-104156, 58995))
				table.insert(terrain_objects,Nebula():setPosition(-135312, 78090))
				table.insert(terrain_objects,Nebula():setPosition(-120036, 81106))
				table.insert(terrain_objects,Nebula():setPosition(-193604, 71457))
				table.insert(terrain_objects,Nebula():setPosition(-203453, 55980))
				table.insert(terrain_objects,Nebula():setPosition(-197021, 13970))
				table.insert(terrain_objects,Nebula():setPosition(-195815, 22814))
				table.insert(terrain_objects,Nebula():setPosition(-133101, 26030))
				table.insert(terrain_objects,Nebula():setPosition(-152800, 14975))
				table.insert(terrain_objects,Nebula():setPosition(-135111, -27839))
				table.insert(terrain_objects,Nebula():setPosition(-153202, -14171))
				table.insert(terrain_objects,Nebula():setPosition(-161041, -7538))
				table.insert(terrain_objects,Nebula():setPosition(-166669, -16583))
				table.insert(terrain_objects,Nebula():setPosition(-157222, 26030))
				table.insert(terrain_objects,Nebula():setPosition(-167674, 18794))
				table.insert(terrain_objects,Nebula():setPosition(-174910, 26231))
				table.insert(terrain_objects,Nebula():setPosition(-160237, 11960))
				table.insert(terrain_objects,Nebula():setPosition(-195413, -8141))
				table.insert(terrain_objects,Nebula():setPosition(-192800, -2312))
				table.insert(terrain_objects,Nebula():setPosition(-197624, -35276))
				table.insert(terrain_objects,Nebula():setPosition(-199433, 7337))
				table.insert(terrain_objects,Nebula():setPosition(-156217, -26432))
				table.insert(terrain_objects,Nebula():setPosition(-166066, -35678))
				table.insert(terrain_objects,Nebula():setPosition(-178528, -35879))
				table.insert(terrain_objects,Nebula():setPosition(-176518, -21608))
				table.insert(terrain_objects,Nebula():setPosition(-193403, -16382))
				table.insert(terrain_objects,Nebula():setPosition(-193805, -30653))
				table.insert(terrain_objects,Nebula():setPosition(-186367, -26432))
				table.insert(terrain_objects,Nebula():setPosition(-199634, -23417))
			-- kraylor side
				table.insert(terrain_objects,Nebula():setPosition(25950, 15065))
				table.insert(terrain_objects,Nebula():setPosition(17927, 3032))
				table.insert(terrain_objects,Nebula():setPosition(18114, -4244))
				table.insert(terrain_objects,Nebula():setPosition(25390, -18424))
				table.insert(terrain_objects,Mine():setPosition(35073, -35990))
				table.insert(terrain_objects,Mine():setPosition(36480, -37598))
				table.insert(terrain_objects,Mine():setPosition(37887, -41417))
				table.insert(terrain_objects,Mine():setPosition(50551, -65738))
				table.insert(terrain_objects,Mine():setPosition(49144, -62723))
				table.insert(terrain_objects,Mine():setPosition(29445, -72573))
				table.insert(terrain_objects,Mine():setPosition(33666, -66944))
				table.insert(terrain_objects,Mine():setPosition(57586, -73176))
				table.insert(terrain_objects,Mine():setPosition(41505, -50864))
				table.insert(terrain_objects,Mine():setPosition(38088, -46040))
				table.insert(terrain_objects,Mine():setPosition(38490, -62321))
				table.insert(terrain_objects,Mine():setPosition(44923, -55688))
				table.insert(terrain_objects,Mine():setPosition(52762, -68753))
				table.insert(terrain_objects,Mine():setPosition(55174, -73779))
				table.insert(terrain_objects,Nebula():setPosition(48679, -59598))
				table.insert(terrain_objects,Nebula():setPosition(52498, -66834))
				table.insert(terrain_objects,Nebula():setPosition(54508, -73668))
				table.insert(terrain_objects,Nebula():setPosition(66970, -78090))
				table.insert(terrain_objects,Nebula():setPosition(71393, -31658))
				table.insert(terrain_objects,Nebula():setPosition(89483, -65427))
				table.insert(terrain_objects,Nebula():setPosition(36418, -65427))
				table.insert(terrain_objects,Nebula():setPosition(39835, -59598))
				table.insert(terrain_objects,Nebula():setPosition(34006, -34472))
				table.insert(terrain_objects,Nebula():setPosition(38830, -42714))
				table.insert(terrain_objects,Nebula():setPosition(73202, -60402))
				table.insert(terrain_objects,Nebula():setPosition(42850, -51357))
				table.insert(terrain_objects,Nebula():setPosition(100538, -82915))
				table.insert(terrain_objects,Nebula():setPosition(83252, -76482))
				table.insert(terrain_objects,Mine():setPosition(104822, -56090))
				table.insert(terrain_objects,Nebula():setPosition(135312, -79900))
				table.insert(terrain_objects,Nebula():setPosition(122448, -76884))
				table.insert(terrain_objects,Mine():setPosition(164659, -17990))
				table.insert(terrain_objects,Mine():setPosition(167875, -15578))
				table.insert(terrain_objects,Mine():setPosition(191393, -15377))
				table.insert(terrain_objects,Nebula():setPosition(193202, -61407))
				table.insert(terrain_objects,Mine():setPosition(160237, -5528))
				table.insert(terrain_objects,Mine():setPosition(162448, -9950))
				table.insert(terrain_objects,Mine():setPosition(102008, -56492))
				table.insert(terrain_objects,Nebula():setPosition(100337, -55377))
				table.insert(terrain_objects,Nebula():setPosition(106367, -56181))
				table.insert(terrain_objects,Mine():setPosition(160036, -41910))
				table.insert(terrain_objects,Mine():setPosition(178327, -20402))
				table.insert(terrain_objects,Mine():setPosition(185764, -26030))
				table.insert(terrain_objects,Mine():setPosition(155011, -27236))
				table.insert(terrain_objects,Mine():setPosition(184558, -40503))
				table.insert(terrain_objects,Nebula():setPosition(115011, -67236))
				table.insert(terrain_objects,Mine():setPosition(159835, 12764))
				table.insert(terrain_objects,Mine():setPosition(155413, 11759))
				table.insert(terrain_objects,Mine():setPosition(156217, 27437))
				table.insert(terrain_objects,Nebula():setPosition(164659, -65628))
				table.insert(terrain_objects,Nebula():setPosition(164659, -52161))
				table.insert(terrain_objects,Mine():setPosition(154609, -12362))
				table.insert(terrain_objects,Nebula():setPosition(184960, -39698))
				table.insert(terrain_objects,Nebula():setPosition(193202, -40302))
				table.insert(terrain_objects,Nebula():setPosition(161242, -41910))
				table.insert(terrain_objects,Nebula():setPosition(184960, -70653))
				table.insert(terrain_objects,Mine():setPosition(150790, 15578))
				table.insert(terrain_objects,Mine():setPosition(174508, 29648))
				table.insert(terrain_objects,Mine():setPosition(167674, 17588))
				table.insert(terrain_objects,Nebula():setPosition(186166, -48744))
				table.insert(terrain_objects,Nebula():setPosition(187975, -55176))
				table.insert(terrain_objects,Nebula():setPosition(170890, -78090))
				table.insert(terrain_objects,Nebula():setPosition(173704, -61005))
				table.insert(terrain_objects,Nebula():setPosition(25161, -79497))
				table.insert(terrain_objects,Nebula():setPosition(31795, -72261))
				table.insert(terrain_objects,Mine():setPosition(42108, 51649))
				table.insert(terrain_objects,Mine():setPosition(42510, 48030))
				table.insert(terrain_objects,Nebula():setPosition(41443, 41106))
				table.insert(terrain_objects,Nebula():setPosition(69583, 30854))
				table.insert(terrain_objects,Nebula():setPosition(73001, 56181))
				table.insert(terrain_objects,Mine():setPosition(36681, 55066))
				table.insert(terrain_objects,Nebula():setPosition(36217, 34070))
				table.insert(terrain_objects,Mine():setPosition(96179, 56272))
				table.insert(terrain_objects,Nebula():setPosition(94508, 57186))
				table.insert(terrain_objects,Nebula():setPosition(98930, 52563))
				table.insert(terrain_objects,Mine():setPosition(34872, 57679))
				table.insert(terrain_objects,Nebula():setPosition(33805, 60402))
				table.insert(terrain_objects,Mine():setPosition(46732, 55669))
				table.insert(terrain_objects,Nebula():setPosition(38227, 53166))
				table.insert(terrain_objects,Mine():setPosition(98993, 53860))
				table.insert(terrain_objects,Mine():setPosition(99998, 56674))
				table.insert(terrain_objects,Nebula():setPosition(100940, 81910))
				table.insert(terrain_objects,Nebula():setPosition(63955, 69447))
				table.insert(terrain_objects,Nebula():setPosition(70991, 74673))
				table.insert(terrain_objects,Nebula():setPosition(84860, 73668))
				table.insert(terrain_objects,Nebula():setPosition(87875, 65628))
				table.insert(terrain_objects,Nebula():setPosition(44056, 52764))
				table.insert(terrain_objects,Nebula():setPosition(43654, 48543))
				table.insert(terrain_objects,Mine():setPosition(51355, 63709))
				table.insert(terrain_objects,Nebula():setPosition(51091, 62814))
				table.insert(terrain_objects,Mine():setPosition(21003, 70945))
				table.insert(terrain_objects,Nebula():setPosition(19935, 73065))
				table.insert(terrain_objects,Mine():setPosition(31656, 62905))
				table.insert(terrain_objects,Mine():setPosition(28440, 67729))
				table.insert(terrain_objects,Nebula():setPosition(27171, 66432))
				table.insert(terrain_objects,Mine():setPosition(195212, -8342))
				table.insert(terrain_objects,Mine():setPosition(193604, -31055))
				table.insert(terrain_objects,Nebula():setPosition(213905, -49749))
				table.insert(terrain_objects,Mine():setPosition(41304, 43809))
				table.insert(terrain_objects,Mine():setPosition(39093, 40593))
				table.insert(terrain_objects,Mine():setPosition(37887, 35367))
				table.insert(terrain_objects,Nebula():setPosition(202448, 2111))
				table.insert(terrain_objects,Nebula():setPosition(212498, -704))
				table.insert(terrain_objects,Nebula():setPosition(205262, -13166))
				table.insert(terrain_objects,Nebula():setPosition(210689, -16181))
				table.insert(terrain_objects,Mine():setPosition(158227, 36482))
				table.insert(terrain_objects,Mine():setPosition(154207, 37889))
				table.insert(terrain_objects,Mine():setPosition(179533, 37487))
				table.insert(terrain_objects,Nebula():setPosition(209684, -27035))
				table.insert(terrain_objects,Nebula():setPosition(206468, -42111))
				table.insert(terrain_objects,Mine():setPosition(165664, 40101))
				table.insert(terrain_objects,Mine():setPosition(195413, 15176))
				table.insert(terrain_objects,Mine():setPosition(199835, 7337))
				table.insert(terrain_objects,Mine():setPosition(193403, -2312))
				table.insert(terrain_objects,Mine():setPosition(202247, 33467))
				table.insert(terrain_objects,Mine():setPosition(197423, 36683))
				table.insert(terrain_objects,Mine():setPosition(196619, 21809))
				table.insert(terrain_objects,Nebula():setPosition(209282, 26633))
				table.insert(terrain_objects,Nebula():setPosition(205865, 20804))
				table.insert(terrain_objects,Nebula():setPosition(206669, 12764))
				table.insert(terrain_objects,Nebula():setPosition(204056, 47136))
				table.insert(terrain_objects,Nebula():setPosition(212297, 46332))
				table.insert(terrain_objects,Nebula():setPosition(206468, 33668))
				table.insert(terrain_objects,Nebula():setPosition(214709, 35276))
				table.insert(terrain_objects,Mine():setPosition(205061, 21608))
				table.insert(terrain_objects,Nebula():setPosition(214709, 12965))
				table.insert(terrain_objects,Nebula():setPosition(176518, 46131))
				table.insert(terrain_objects,Nebula():setPosition(178930, 49146))
				table.insert(terrain_objects,Nebula():setPosition(154207, 64623))
				table.insert(terrain_objects,Nebula():setPosition(167272, 65226))
				table.insert(terrain_objects,Nebula():setPosition(183754, 59598))
				table.insert(terrain_objects,Nebula():setPosition(164659, 51156))
				table.insert(terrain_objects,Nebula():setPosition(152197, 37085))
				table.insert(terrain_objects,Nebula():setPosition(155212, 36080))
				table.insert(terrain_objects,Nebula():setPosition(149784, 45729))
				table.insert(terrain_objects,Nebula():setPosition(168076, 39296))
				table.insert(terrain_objects,Nebula():setPosition(184960, 38894))
				table.insert(terrain_objects,Nebula():setPosition(180538, 35075))
				table.insert(terrain_objects,Nebula():setPosition(178327, 70452))
				table.insert(terrain_objects,Nebula():setPosition(186970, 55980))
				table.insert(terrain_objects,Nebula():setPosition(194207, 45528))
				table.insert(terrain_objects,Nebula():setPosition(197222, 36683))
				table.insert(terrain_objects,Nebula():setPosition(202850, 32864))
				table.insert(terrain_objects,Nebula():setPosition(118026, 70452))
				table.insert(terrain_objects,Nebula():setPosition(104156, 58995))
				table.insert(terrain_objects,Nebula():setPosition(135312, 78090))
				table.insert(terrain_objects,Nebula():setPosition(120036, 81106))
				table.insert(terrain_objects,Nebula():setPosition(193604, 71457))
				table.insert(terrain_objects,Nebula():setPosition(203453, 55980))
				table.insert(terrain_objects,Nebula():setPosition(197021, 13970))
				table.insert(terrain_objects,Nebula():setPosition(195815, 22814))
				table.insert(terrain_objects,Nebula():setPosition(133101, 26030))
				table.insert(terrain_objects,Nebula():setPosition(152800, 14975))
				table.insert(terrain_objects,Nebula():setPosition(135111, -27839))
				table.insert(terrain_objects,Nebula():setPosition(153202, -14171))
				table.insert(terrain_objects,Nebula():setPosition(161041, -7538))
				table.insert(terrain_objects,Nebula():setPosition(166669, -16583))
				table.insert(terrain_objects,Nebula():setPosition(157222, 26030))
				table.insert(terrain_objects,Nebula():setPosition(167674, 18794))
				table.insert(terrain_objects,Nebula():setPosition(174910, 26231))
				table.insert(terrain_objects,Nebula():setPosition(160237, 11960))
				table.insert(terrain_objects,Nebula():setPosition(195413, -8141))
				table.insert(terrain_objects,Nebula():setPosition(192800, -2312))
				table.insert(terrain_objects,Nebula():setPosition(197624, -35276))
				table.insert(terrain_objects,Nebula():setPosition(199433, 7337))
				table.insert(terrain_objects,Nebula():setPosition(156217, -26432))
				table.insert(terrain_objects,Nebula():setPosition(166066, -35678))
				table.insert(terrain_objects,Nebula():setPosition(178528, -35879))
				table.insert(terrain_objects,Nebula():setPosition(176518, -21608))
				table.insert(terrain_objects,Nebula():setPosition(193403, -16382))
				table.insert(terrain_objects,Nebula():setPosition(193805, -30653))
				table.insert(terrain_objects,Nebula():setPosition(186367, -26432))
				table.insert(terrain_objects,Nebula():setPosition(199634, -23417))			
		end
		

	-- player tagged relocation override
	-- this is placed at the end because the values depend on "terrain" variables calculated in the middle of the function
	hx = human_planet_center_x + human_planet_radius + (human_moon_1_orbit_distance/2)
	kx = kraylor_planet_center_x - kraylor_planet_radius - (kraylor_moon_1_orbit_distance/2)
	--player side   		  Hum   Kra    Hum   Kra    Hum    Kra    Hum   Kra    Hum    Kra    Hum   Kra	  Hum	 Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra    Hum    Kra
	--player index   		   1     2      3     4      5      6      7     8      9     10     11    12	  13	 14     15     16     17     18     19     20     21     22     23     24     25     26     27     28     29     30     31     32
	player_tag_relocate_x = { hx,   kx,    hx,   kx,    hx,    kx,    hx,   kx,    hx,    kx,    hx,   kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx,    hx,    kx}	
	player_tag_relocate_y =	{  0,    0,     0,    0,     0,     0,     0,    0,     0,     0,     0,    0,     0,    0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,     0}


end
function moveDownTheRabbitHole()

	-- move asteroid rings
	for i=1,number_of_asteroids_in_ring do
		-- human side
			if human_asteroid_ring[i]:isValid() then
				human_asteroid_ring[i].angle = human_asteroid_ring[i].angle + human_asteroid_ring[i].speed
				if human_asteroid_ring[i].angle > 360 then
					human_asteroid_ring[i].angle = human_asteroid_ring[i].angle - 360
				end
				setCirclePos(human_asteroid_ring[i], 
					human_planet_center_x, 
					human_planet_center_y, 
					human_asteroid_ring[i].angle, 
					human_asteroid_ring[i].radius)
			end
		-- kraylor side
			if kraylor_asteroid_ring[i]:isValid() then
				kraylor_asteroid_ring[i].angle = kraylor_asteroid_ring[i].angle + kraylor_asteroid_ring[i].speed
				if kraylor_asteroid_ring[i].angle > 360 then
					kraylor_asteroid_ring[i].angle = kraylor_asteroid_ring[i].angle - 360
				end
				setCirclePos(kraylor_asteroid_ring[i], 
					kraylor_planet_center_x, 
					kraylor_planet_center_y, 
					kraylor_asteroid_ring[i].angle, 
					kraylor_asteroid_ring[i].radius)
			end
		
	end

	-- move mines in the asteroid rings
	for i=1,number_of_mines_in_ring do
		-- human side
			if human_mine_ring[i]:isValid() then
				human_mine_ring[i].angle = human_mine_ring[i].angle + human_mine_ring[i].speed
				if human_mine_ring[i].angle > 360 then
					human_mine_ring[i].angle = human_mine_ring[i].angle - 360
				end
				setCirclePos(human_mine_ring[i], 
					human_planet_center_x, 
					human_planet_center_y, 
					human_mine_ring[i].angle, 
					human_mine_ring[i].radius)
			end
		-- kraylor side
			if kraylor_mine_ring[i]:isValid() then
				kraylor_mine_ring[i].angle = kraylor_mine_ring[i].angle + kraylor_mine_ring[i].speed
				if kraylor_mine_ring[i].angle > 360 then
					kraylor_mine_ring[i].angle = kraylor_mine_ring[i].angle - 360
				end
				setCirclePos(kraylor_mine_ring[i], 
					kraylor_planet_center_x, 
					kraylor_planet_center_y, 
					kraylor_mine_ring[i].angle, 
					kraylor_mine_ring[i].radius)
			end
		
	end
	
	-- move orbiting space stations
		-- human
			human_orbital_station_1.angle = human_orbital_station_1.angle + human_orbital_station_1.speed
			if human_orbital_station_1.angle > 360 then 
				human_orbital_station_1.angle = human_orbital_station_1.angle - 360
			end
			setCirclePos(human_orbital_station_1, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_1.angle, 
				human_orbital_station_1.distance)

			human_orbital_station_2.angle = human_orbital_station_2.angle + human_orbital_station_2.speed
			if human_orbital_station_2.angle > 360 then 
				human_orbital_station_2.angle = human_orbital_station_2.angle - 360
			end
			setCirclePos(human_orbital_station_2, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_2.angle, 
				human_orbital_station_2.distance)

			human_orbital_station_3.angle = human_orbital_station_3.angle + human_orbital_station_3.speed
			if human_orbital_station_3.angle > 360 then 
				human_orbital_station_3.angle = human_orbital_station_3.angle - 360
			end
			setCirclePos(human_orbital_station_3, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_3.angle, 
				human_orbital_station_3.distance)

			human_orbital_station_4.angle = human_orbital_station_4.angle + human_orbital_station_4.speed
			if human_orbital_station_4.angle > 360 then 
				human_orbital_station_4.angle = human_orbital_station_4.angle - 360
			end
			setCirclePos(human_orbital_station_4, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_4.angle, 
				human_orbital_station_4.distance)

			human_orbital_station_5.angle = human_orbital_station_5.angle + human_orbital_station_5.speed
			if human_orbital_station_5.angle > 360 then 
				human_orbital_station_5.angle = human_orbital_station_5.angle - 360
			end
			setCirclePos(human_orbital_station_5, 
				human_planet_center_x, 
				human_planet_center_y, 
				human_orbital_station_5.angle, 
				human_orbital_station_5.distance)

		-- kraylor
			kraylor_orbital_station_1.angle = kraylor_orbital_station_1.angle + kraylor_orbital_station_1.speed
			if kraylor_orbital_station_1.angle > 360 then 
				kraylor_orbital_station_1.angle = kraylor_orbital_station_1.angle - 360
			end
			setCirclePos(kraylor_orbital_station_1, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_1.angle, 
				kraylor_orbital_station_1.distance)

			kraylor_orbital_station_2.angle = kraylor_orbital_station_2.angle + kraylor_orbital_station_2.speed
			if kraylor_orbital_station_2.angle > 360 then 
				kraylor_orbital_station_2.angle = kraylor_orbital_station_2.angle - 360
			end
			setCirclePos(kraylor_orbital_station_2, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_2.angle, 
				kraylor_orbital_station_2.distance)

			kraylor_orbital_station_3.angle = kraylor_orbital_station_3.angle + kraylor_orbital_station_3.speed
			if kraylor_orbital_station_3.angle > 360 then 
				kraylor_orbital_station_3.angle = kraylor_orbital_station_3.angle - 360
			end
			setCirclePos(kraylor_orbital_station_3, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_3.angle, 
				kraylor_orbital_station_3.distance)

			kraylor_orbital_station_4.angle = kraylor_orbital_station_4.angle + kraylor_orbital_station_4.speed
			if kraylor_orbital_station_4.angle > 360 then 
				kraylor_orbital_station_4.angle = kraylor_orbital_station_4.angle - 360
			end
			setCirclePos(kraylor_orbital_station_4, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_4.angle, 
				kraylor_orbital_station_4.distance)

			kraylor_orbital_station_5.angle = kraylor_orbital_station_5.angle + kraylor_orbital_station_5.speed
			if kraylor_orbital_station_5.angle > 360 then 
				kraylor_orbital_station_5.angle = kraylor_orbital_station_5.angle - 360
			end
			setCirclePos(kraylor_orbital_station_5, 
				kraylor_planet_center_x, 
				kraylor_planet_center_y, 
				kraylor_orbital_station_5.angle, 
				kraylor_orbital_station_5.distance)

	
end

-------------------------------
--	Cargo related functions  --
-------------------------------
function setupTailoredShipAttributes()
	-- part of Xansta's larger overall script core for randomized stations and NPC ships;
	playerShipNamesFor = {}
	-- TODO switch to spelling with space or dash matching the type name
	playerShipNamesFor["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	playerShipNamesFor["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	playerShipNamesFor["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	playerShipNamesFor["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	playerShipNamesFor["Atlantis"] = {"Excalibur","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	playerShipNamesFor["Player Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	playerShipNamesFor["Player Missile Cr."] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	playerShipNamesFor["Player Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	playerShipNamesFor["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	playerShipNamesFor["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	playerShipNamesFor["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Snowbird","Hawk"}
	playerShipNamesFor["ZX-Lindworm"] = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	playerShipNamesFor["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	playerShipNamesFor["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	playerShipNamesFor["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	playerShipNamesFor["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Fett", "Hawkeye", "Hanzo"}
	playerShipNamesFor["ProtoAtlantis"] = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	playerShipNamesFor["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	playerShipNamesFor["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	playerShipNamesFor["Surkov"] = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	playerShipNamesFor["Stricken"] = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	playerShipNamesFor["AtlantisII"] = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	playerShipNamesFor["Redhook"] = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	playerShipNamesFor["DestroyerIII"] = {"Trebuchet", "Pitcher", "Mutant", "Gronk", "Methuselah"}
	playerShipNamesFor["Leftovers"] = {
		"Adelphi",
		"Ahwahnee",
		"Akagi",
		"Akira",
		"Al-Batani",
		"Ambassador",
		"Andromeda",
		"Antares",
		"Apollo",
		"Appalachia",
		"Arcos",
		"Aries",
		"Athena",
		"Beethoven",
		"Bellerophon",
		"Biko",
		"Bonchune",
		"Bozeman",
		"Bradbury",
		"Brattain",
		"Budapest",
		"Buran",
		"Cairo",
		"Calypso",
		"Capricorn",
		"Carolina",
		"Centaur",
		"Challenger",
		"Charleston",
		"Chekov",
		"Cheyenne",
		"Clement",
		"Cochraine",
		"Columbia",
		"Concorde",
		"Constantinople",
		"Constellation",
		"Constitution",
		"Copernicus",
		"Cousteau",
		"Crazy Horse",
		"Crockett",
		"Daedalus",
		"Danube",
		"Defiant",
		"Deneva",
		"Denver",
		"Discovery",
		"Drake",
		"Endeavor",
		"Endurance",
		"Equinox",
		"Essex",
		"Exeter",
		"Farragut",
		"Fearless",
		"Fleming",
		"Foregone",
		"Fredrickson",
		"Freedom",
		"Gage",
		"Galaxy",
		"Galileo",
		"Gander",
		"Ganges",
		"Gettysburg",
		"Ghandi",
		"Goddard",
		"Grissom",
		"Hathaway",
		"Helin",
		"Hera",
		"Heracles",
		"Hokule'a",
		"Honshu",
		"Hood",
		"Hope",
		"Horatio",
		"Horizon",
		"Interceptor",
		"Intrepid",
		"Istanbul",
		"Jenolen",
		"Kearsarge",
		"Kongo",
		"Korolev",
		"Kyushu",
		"Lakota",
		"Lalo",
		"Lancer",
		"Lantree",
		"LaSalle",
		"Leeds",
		"Lexington",
		"Luna",
		"Magellan",
		"Majestic",
		"Malinche",
		"Maryland",
		"Masher",
		"Mediterranean",
		"Mekong",
		"Melbourne",
		"Merced",
		"Merrimack",
		"Miranda",
		"Nash",
		"New Orleans",
		"Newton",
		"Niagra",
		"Nobel",
		"Norway",
		"Nova",
		"Oberth",
		"Odyssey",
		"Orinoco",
		"Osiris",
		"Pasteur",
		"Pegasus",
		"Peregrine",
		"Poseidon",
		"Potempkin",
		"Princeton",
		"Prokofiev",
		"Prometheus",
		"Proxima",
		"Rabin",
		"Raman",
		"Relativity",
		"Reliant",
		"Renaissance",
		"Renegade",
		"Republic",
		"Rhode Island",
		"Rigel",
		"Righteous",
		"Rubicon",
		"Rutledge",
		"Sarajevo",
		"Saratoga",
		"Scimitar",
		"Sequoia",
		"Shenandoah",
		"ShirKahr",
		"Sitak",
		"Socrates",
		"Sovereign",
		"Spector",
		"Springfield",
		"Stargazer",
		"Steamrunner",
		"Surak",
		"Sutherland",
		"Sydney",
		"T'Kumbra",
		"Thomas Paine",
		"Thunderchild",
		"Tian An Men",
		"Titan",
		"Tolstoy",
		"Trial",
		"Trieste",
		"Trinculo",
		"Tripoli",
		"Ulysses",
		"Valdemar",
		"Valiant",
		"Volga",
		"Voyager",
		"Wambundu",
		"Waverider",
		"Wellington",
		"Wells",
		"Wyoming",
		"Yamaguchi",
		"Yamato",
		"Yangtzee Kiang",
		"Yeager",
		"Yorkshire",
		"Yorktown",
		"Yosemite",
		"Yukon",
		"Zapata",
		"Zhukov",
		"Zodiac",
	}
end
function setupBarteringGoods()
	-- part of Xansta's larger overall bartering/crafting setup
	-- list of goods available to buy, sell or trade (sell still under development)
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

end
-----------------------------
--	Station communication  --
-----------------------------
function resupplyStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = math.random(0.0, 100.0),
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
    if comms_source:isDocked(comms_target) then
		setCommsMessage(_("station-comms", "Greetings"))
		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		missilePresence = 0
		for _, missile_type in ipairs(missile_types) do
			missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
		end
		if missilePresence > 0 then
			if comms_target.nukeAvail == nil then
				comms_target.nukeAvail = false
				comms_target.empAvail = false
				comms_target.homeAvail = true
				comms_target.mineAvail = false
				comms_target.hvliAvail = true
			end
			if comms_target.nukeAvail or comms_target.empAvail or comms_target.homeAvail or comms_target.mineAvail or comms_target.hvliAvail then
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						homePrompt = "Restock Homing ("
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), homePrompt, getWeaponCost("Homing")), function()
							handleResupplyStationWeaponRestock("Homing")
						end)
					end
				end
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						hvliPrompt = "Restock HVLI ("
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), hvliPrompt, getWeaponCost("HVLI")), function()
							handleResupplyStationWeaponRestock("HVLI")
						end)
					end
				end
			end
		end
	else
        setCommsMessage(_("station-comms", "Dock, please"))
    end
    return true
end
function handleResupplyStationWeaponRestock(weapon)
    if not comms_source:isDocked(comms_target) then 
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
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage(_("ammo-comms", "All nukes are charged and primed for destruction."));
        else
            setCommsMessage(_("ammo-comms", "Sorry, sir, but you are as fully stocked as I can allow."));
        end
        addCommsReply(_("Back"), resupplyStation)
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
        addCommsReply(_("Back"), resupplyStation)
    end
end
function commsStation()
    if comms_target.comms_data == nil then
        comms_target.comms_data = {}
    end
    mergeTables(comms_target.comms_data, {
        friendlyness = math.random(0.0, 100.0),
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
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function handleDockedState()
    if comms_source:isFriendly(comms_target) then
		oMsg = _("station-comms", "Good day, officer!\nWhat can we do for you today?\n")
    else
		oMsg = _("station-comms", "Welcome to our lovely station.\n")
    end
	setCommsMessage(oMsg)
	missilePresence = 0
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
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
			addCommsReply(_("ammo-comms", "I need ordnance restocked"), function()
				setCommsMessage(_("ammo-comms", "What type of ordnance?"))
				if comms_source:getWeaponStorageMax("Nuke") > 0 then
					if comms_target.nukeAvail then
						if math.random(1,10) <= 5 then
							nukePrompt = _("ammo-comms", "Can you supply us with some nukes? (")
						else
							nukePrompt = _("ammo-comms", "We really need some nukes (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), nukePrompt, getWeaponCost("Nuke")), function()
							handleWeaponRestock("Nuke")
						end)
					end
				end
				if comms_source:getWeaponStorageMax("EMP") > 0 then
					if comms_target.empAvail then
						if math.random(1,10) <= 5 then
							empPrompt = _("ammo-comms", "Please re-stock our EMP missiles. (")
						else
							empPrompt = _("ammo-comms", "Got any EMPs? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), empPrompt, getWeaponCost("EMP")), function()
							handleWeaponRestock("EMP")
						end)
					end
				end
				if comms_source:getWeaponStorageMax("Homing") > 0 then
					if comms_target.homeAvail then
						if math.random(1,10) <= 5 then
							homePrompt = _("ammo-comms", "Do you have spare homing missiles for us? (")
						else
							homePrompt = _("ammo-comms", "Do you have extra homing missiles? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), homePrompt, getWeaponCost("Homing")), function()
							handleWeaponRestock("Homing")
						end)
					end
				end
				if comms_source:getWeaponStorageMax("Mine") > 0 then
					if comms_target.mineAvail then
						minePromptChoice = math.random(1,5)
						if minePromptChoice == 1 then
							minePrompt = _("ammo-comms", "We could use some mines. (")
						elseif minePromptChoice == 2 then
							minePrompt = _("ammo-comms", "How about mines? (")
						elseif minePromptChoice == 3 then
							minePrompt = _("ammo-comms", "More mines (")
						elseif minePromptChoice == 4 then
							minePrompt = _("ammo-comms", "All the mines we can take. (")
						else
							minePrompt = _("ammo-comms", "Mines! What else? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), minePrompt, getWeaponCost("Mine")), function()
							handleWeaponRestock("Mine")
						end)
					end
				end
				if comms_source:getWeaponStorageMax("HVLI") > 0 then
					if comms_target.hvliAvail then
						if math.random(1,10) <= 5 then
							hvliPrompt = _("ammo-comms", "What about HVLI? (")
						else
							hvliPrompt = _("ammo-comms", "Could you provide HVLI? (")
						end
						addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), hvliPrompt, getWeaponCost("HVLI")), function()
							handleWeaponRestock("HVLI")
						end)
					end
				end
			end)
		end
	end
	if comms_source:isFriendly(comms_target) then
		if math.random(1,6) <= (4 - difficulty) then
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
					resetPreviousSystemHealth(comms_source)
					setCommsMessage(_("trade-comms", "Repair crew member hired"))
				end
			end)
		end
	else
		if math.random(1,6) <= (4 - difficulty) then
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
					resetPreviousSystemHealth(comms_source)
					setCommsMessage(_("trade-comms", "Repair crew member hired"))
				end
			end)
		end
	end
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
	if goods[comms_target] ~= nil then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			oMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation\n"),comms_target:getCallSign())
			gi = 1		-- initialize goods index
			repeat
				goodsType = goods[comms_target][gi][1]
				goodsQuantity = goods[comms_target][gi][2]
				goodsRep = goods[comms_target][gi][3]
				oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i, %i\n"),goodsType,goodsQuantity,goodsRep)
				gi = gi + 1
			until(gi > #goods[comms_target])
			oMsg = oMsg .. _("trade-comms", "Current Cargo:\n")
			gi = 1
			cargoHoldEmpty = true
			repeat
				playerGoodsType = goods[comms_source][gi][1]
				playerGoodsQuantity = goods[comms_source][gi][2]
				if playerGoodsQuantity > 0 then
					oMsg = oMsg .. string.format(_("trade-comms", "     %s: %i\n"),playerGoodsType,playerGoodsQuantity)
					cargoHoldEmpty = false
				end
				gi = gi + 1
			until(gi > #goods[comms_source])
			if cargoHoldEmpty then
				oMsg = oMsg .. _("trade-comms", "     Empty\n")
			end
			playerRep = math.floor(comms_source:getReputationPoints())
			oMsg = oMsg .. string.format(_("trade-comms", "Available Space: %i, Available Reputation: %i\n"),comms_source.cargo,playerRep)
			setCommsMessage(oMsg)
			-- Buttons for reputation purchases
			gi = 1
			repeat
				local goodsType = goods[comms_target][gi][1]
				local goodsQuantity = goods[comms_target][gi][2]
				local goodsRep = goods[comms_target][gi][3]
				addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
					oMsg = string.format(_("trade-comms", "Type: %s, Quantity: %i, Rep: %i"),goodsType,goodsQuantity,goodsRep)
					if comms_source.cargo < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient cargo space for purchase")
					elseif goodsRep > playerRep then
						oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
					elseif goodsQuantity < 1 then
						oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
					else
						if not comms_source:takeReputationPoints(goodsRep) then
							oMsg = oMsg .. _("needRep-comms", "\nInsufficient reputation for purchase")
						else
							comms_source.cargo = comms_source.cargo - 1
							decrementStationGoods(goodsType)
							incrementPlayerGoods(goodsType)
							oMsg = oMsg .. _("trade-comms", "\npurchased")
						end
					end
					setCommsMessage(oMsg)
					addCommsReply(_("Back"), commsStation)
				end)
				gi = gi + 1
			until(gi > #goods[comms_target])
			-- Buttons for food trades
			if tradeFood[comms_target] ~= nil then
				gi = 1
				foodQuantity = 0
				repeat
					if goods[comms_source][gi][1] == "food" then
						foodQuantity = goods[comms_source][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
				if foodQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade food for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("food")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
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
					if goods[comms_source][gi][1] == "luxury" then
						luxuryQuantity = goods[comms_source][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
				if luxuryQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("luxury")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
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
					if goods[comms_source][gi][1] == "medicine" then
						medicineQuantity = goods[comms_source][gi][2]
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
				if medicineQuantity > 0 then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),goods[comms_target][gi][1]), function()
							oMsg = string.format(_("trade-comms", "Type: %s,  Quantity: %i"),goodsType,goodsQuantity)
							if goodsQuantity < 1 then
								oMsg = oMsg .. _("trade-comms", "\nInsufficient station inventory")
							else
								decrementStationGoods(goodsType)
								incrementPlayerGoods(goodsType)
								decrementPlayerGoods("medicine")
								oMsg = oMsg .. _("trade-comms", "\nTraded")
							end
							setCommsMessage(oMsg)
							addCommsReply(_("Back"), commsStation)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
		gi = 1
		cargoHoldEmpty = true
		repeat
			playerGoodsType = goods[comms_source][gi][1]
			playerGoodsQuantity = goods[comms_source][gi][2]
			if playerGoodsQuantity > 0 then
				cargoHoldEmpty = false
			end
			gi = gi + 1
		until(gi > #goods[comms_source])
		if not cargoHoldEmpty then
			addCommsReply(_("trade-comms", "Jettison cargo"), function()
				setCommsMessage(string.format(_("trade-comms", "Available space: %i\nWhat would you like to jettison?"),comms_source.cargo))
				gi = 1
				repeat
					local goodsType = goods[comms_source][gi][1]
					local goodsQuantity = goods[comms_source][gi][2]
					if goodsQuantity > 0 then
						addCommsReply(goodsType, function()
							decrementPlayerGoods(goodsType)
							comms_source.cargo = comms_source.cargo + 1
							setCommsMessage(string.format(_("trade-comms", "One %s jettisoned"),goodsType))
							addCommsReply(_("Back"), commsStation)
						end)
					end
					gi = gi + 1
				until(gi > #goods[comms_source])
				addCommsReply(_("Back"), commsStation)
			end)
		end
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
    if not isAllowedTo(comms_data.weapons[weapon]) then
        if weapon == "Nuke" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass destruction."))
        elseif weapon == "EMP" then setCommsMessage(_("ammo-comms", "We do not deal in weapons of mass disruption."))
        else setCommsMessage(_("ammo-comms", "We do not deal in those weapons.")) end
        return
    end
    local points_per_item = getWeaponCost(weapon)
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
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
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
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
		addCommsReply(_("ammo-comms", "What ordnance do you have available for restock?"), function()
			missileTypeAvailableCount = 0
			oMsg = ""
			if comms_target.nukeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   Nuke")
			end
			if comms_target.empAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   EMP")
			end
			if comms_target.homeAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   Homing")
			end
			if comms_target.mineAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   Mine")
			end
			if comms_target.hvliAvail then
				missileTypeAvailableCount = missileTypeAvailableCount + 1
				oMsg = oMsg .. _("ammo-comms", "\n   HVLI")
			end
			if missileTypeAvailableCount == 0 then
				oMsg = _("ammo-comms", "We have no ordnance available for restock")
			elseif missileTypeAvailableCount == 1 then
				oMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"), oMsg)
			else
				oMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"), oMsg)
			end
			setCommsMessage(oMsg)
			addCommsReply(_("Back"), commsStation)
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
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				oMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation\n"),comms_target:getCallSign())
				gi = 1		-- initialize goods index
				repeat
					goodsType = goods[comms_target][gi][1]
					goodsQuantity = goods[comms_target][gi][2]
					goodsRep = goods[comms_target][gi][3]
					oMsg = oMsg .. string.format(_("trade-comms", "   %14s: %2i, %3i\n"),goodsType,goodsQuantity,goodsRep)
					gi = gi + 1
				until(gi > #goods[comms_target])
				setCommsMessage(oMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("helpfullWarning-comms", "See any enemies in your area?"), function()
			if comms_source:isFriendly(comms_target) then
				enemiesInRange = 0
				for _, obj in ipairs(comms_target:getObjectsInRange(30000)) do
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
					comms_source:addReputationPoints(2.0)					
				else
					setCommsMessage(_("helpfullWarning-comms", "No enemies within 30U"))
					comms_source:addReputationPoints(1.0)
				end
				addCommsReply(_("Back"), commsStation)
			else
				setCommsMessage(_("helpfullWarning-comms", "Not really"))
				comms_source:addReputationPoints(1.0)
				addCommsReply(_("Back"), commsStation)
			end
		end)
		addCommsReply(_("trade-comms", "Where can I find particular goods?"), function()
			gkMsg = _("trade-comms", "Friendly stations generally have food or medicine or both. Neutral stations often trade their goods for food, medicine or luxury.")
			if comms_target.goodsKnowledge == nil then
				gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations.\n\nCheck back later, someone else may have better knowledge")
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
				fillStationBrains()
			else
				if #comms_target.goodsKnowledge == 0 then
					gkMsg = gkMsg .. _("trade-comms", " Beyond that, I have no knowledge of specific stations")
				else
					gkMsg = gkMsg .. _("trade-comms", "\n\nWhat goods are you interested in?\nI've heard about these:")
					for gk=1,#comms_target.goodsKnowledge do
						addCommsReply(comms_target.goodsKnowledgeType[gk],function()
							setCommsMessage(string.format(_("trade-comms", "Station %s in sector %s has %s%s"),comms_target.goodsKnowledge[gk],comms_target.goodsKnowledgeSector[gk],comms_target.goodsKnowledgeType[gk],comms_target.goodsKnowledgeTrade[gk]))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
			end
		end)
		if comms_target.publicRelations then
			addCommsReply(_("stationGeneralInfo-comms", "General station information"), function()
				setCommsMessage(comms_target.generalInformation)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end)
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			oMsg = oMsg .. string.format("  time remaining: %.1f",gameTimeLimit)
--			if waveTimer ~= nil then
--				oMsg = oMsg .. string.format("\nwave timer: %.1f",waveTimer)
--			end
			if timeDivision ~= nil then
				oMsg = oMsg .. "  " .. timeDivision
			end
			oMsg = oMsg .. "\n" .. wfv
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
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(player:getWaypoint(n))
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
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end

-----------------------------------------------
--	Custom player ship buttons and messages  --
-----------------------------------------------
--	Player Ship Flag Buttons and call-back functions  --
function setP1FlagButton()
	if p1FlagButton == nil and not p1FlagDrop then
		p1FlagButton = "p1FlagButton"
		p1:addCustomButton("Weapons", p1FlagButton, _("flag-buttonWeapons", "Drop flag"), p1DropFlag)
		p1FlagButtonT = "p1FlagButtonT"
		p1:addCustomButton("Tactical", p1FlagButtonT, _("flag-buttonTactical", "Drop flag"), p1DropFlag)
	end
end
function removeP1FlagButton()
	if p1FlagButton ~= nil then
		p1:removeCustom(p1FlagButton)
		p1:removeCustom(p1FlagButtonT)
		p1FlagButton = nil
		p1FlagButtonT = nil
	end
end
function setP2FlagButton()
	if p2FlagButton == nil and not p2FlagDrop then
		p2FlagButton = "p2FlagButton"
		p2:addCustomButton("Weapons", p2FlagButton, _("flag-buttonWeapons", "Drop flag"), p2DropFlag)
		p2FlagButtonT = "p2FlagButtonT"
		p2:addCustomButton("Tactical", p2FlagButtonT, _("flag-buttonTactical", "Drop flag"), p2DropFlag)
	end
end
function removeP2FlagButton()
	if p2FlagButton ~= nil then
		p2:removeCustom(p2FlagButton)
		p2:removeCustom(p2FlagButtonT)
		p2FlagButton = nil
		p2FlagButtonT = nil
	end
end

function p1DropFlag()
	p1FlagDrop = true
	p1Flagx, p1Flagy = p1:getPosition()
	removeP1FlagButton()
	if p1:hasPlayerAtPosition("Weapons") then
		p1FlagDroppedMsg = "p1FlagDroppedMsg"
		p1:addCustomMessage("Weapons",p1FlagDroppedMsg,_("flag-msgWeapons", "Flag position recorded. Flag will be placed here when preparation period complete"))
	end
	if p1:hasPlayerAtPosition("Tactical") then
		p1FlagDroppedMsgT = "p1FlagDroppedMsgT"
		p1:addCustomMessage("Tactical",p1FlagDroppedMsgT,_("flag-msgTactical", "Flag position recorded. Flag will be placed here when preparation period complete"))
	end
end
function p2DropFlag()
	p2FlagDrop = true
	p2Flagx, p2Flagy = p2:getPosition()
	removeP2FlagButton()
	if p2:hasPlayerAtPosition("Weapons") then
		p2FlagDroppedMsg = "p2FlagDroppedMsg"
		p2:addCustomMessage("Weapons",p2FlagDroppedMsg,_("flag-msgWeapons", "Flag position recorded. Flag will be placed here when preparation period complete"))
	end
	if p2:hasPlayerAtPosition("Tactical") then
		p2FlagDroppedMsgT = "p2FlagDroppedMsgT"
		p2:addCustomMessage("Tactical",p2FlagDroppedMsgT,_("flag-msgTactical", "Flag position recorded. Flag will be placed here when preparation period complete"))
	end
end

--	Player Ship Decoy Buttons and call-back functions
function p1DropDecoy()
	if p1.decoy_drop == nil then
		p1.decoy_drop = {}
	end
	p1.decoy_drop[1] = true
	decoyH1x, decoyH1y = dropDecoy(p1,1)
end
function p1DropDecoy2()
	if p1.decoy_drop == nil then
		p1.decoy_drop = {}
	end
	p1.decoy_drop[2] = true
	decoyH2x, decoyH2y = dropDecoy(p1,2)
end
function p1DropDecoy3()
	if p1.decoy_drop == nil then
		p1.decoy_drop = {}
	end
	p1.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p1,3)
end
function p2DropDecoy()
	if p2.decoy_drop == nil then
		p2.decoy_drop = {}
	end
	p2.decoy_drop[1] = true
	decoyK1x, decoyK1y = dropDecoy(p2,1)
end
function p2DropDecoy2()
	if p2.decoy_drop == nil then
		p2.decoy_drop = {}
	end
	p2.decoy_drop[2] = true
	decoyK2x, decoyK2y = dropDecoy(p2,2)
end
function p2DropDecoy3()
	if p2.decoy_drop == nil then
		p2.decoy_drop = {}
	end
	p2.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p2,3)
end
function p3DropDecoy()
	if p3.decoy_drop == nil then
		p3.decoy_drop = {}
	end
	p3.decoy_drop[1] = true
	decoyH1x, decoyH1y = dropDecoy(p3,1)
end
function p3DropDecoy2()
	if p3.decoy_drop == nil then
		p3.decoy_drop = {}
	end
	p3.decoy_drop[2] = true
	decoyH2x, decoyH2y = dropDecoy(p3,2)
end
function p3DropDecoy3()
	if p3.decoy_drop == nil then
		p3.decoy_drop = {}
	end
	p3.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p3,3)
end
function p4DropDecoy()
	if p4.decoy_drop == nil then
		p4.decoy_drop = {}
	end
	p4.decoy_drop[1] = true
	decoyK1x, decoyK1y = dropDecoy(p4,1)
end
function p4DropDecoy2()
	if p4.decoy_drop == nil then
		p4.decoy_drop = {}
	end
	p4.decoy_drop[2] = true
	decoyK2x, decoyK2y = dropDecoy(p4,2)
end
function p4DropDecoy3()
	if p4.decoy_drop == nil then
		p4.decoy_drop = {}
	end
	p4.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p4,3)
end
function p5DropDecoy()
	if p5.decoy_drop == nil then
		p5.decoy_drop = {}
	end
	p5.decoy_drop[2] = true
	decoyH2x, decoyH2y = dropDecoy(p5,2)
end
function p5DropDecoy3()
	if p5.decoy_drop == nil then
		p5.decoy_drop = {}
	end
	p5.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p5,3)
end
function p6DropDecoy()
	if p6.decoy_drop == nil then
		p6.decoy_drop = {}
	end
	p6.decoy_drop[2] = true
	decoyK2x, decoyK2y = dropDecoy(p6,2)
end
function p6DropDecoy3()
	if p6.decoy_drop == nil then
		p6.decoy_drop = {}
	end
	p6.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p6,3)
end
function p7DropDecoy()
	p7.decoy_drop = {}
	p7.decoy_drop[3] = true
	decoyH3x, decoyH3y = dropDecoy(p7,3)
end
function p8DropDecoy()
	p8.decoy_drop = {}
	p8.decoy_drop[3] = true
	decoyK3x, decoyK3y = dropDecoy(p8,3)
end
function dropDecoy(p,decoy_number)
	local decoy_x, decoy_y = p:getPosition()
	removeDecoyButton(p)
	local decoy_dropped_message = string.format("%s%iDecoyDroppedMessageWeapons",p:getCallSign(),decoy_number)
	if p:hasPlayerAtPosition("Weapons") then
		p:addCustomMessage("Weapons",decoy_dropped_message,_("decoy-msgWeapons", "Decoy position recorded. Decoy will be placed here when preparation period complete"))
	end
	if p:hasPlayerAtPosition("Tactical") then
		decoy_dropped_message = string.format("%s%iDecoyDroppedMessageTactical",p:getCallSign(),decoy_number)
		p:addCustomMessage("Tactical",decoy_dropped_message,_("decoy-msgTactical", "Decoy position recorded. Decoy will be placed here when preparation period complete"))
	end
	return decoy_x, decoy_y
end
function removeDecoyButton(p)
	if p ~= nil and p.decoy_button ~= nil then
		for decoy_button_label, player_name in pairs(p.decoy_button) do
			p:removeCustom(decoy_button_label)
		end
		p.decoy_button = {}
	end
end
function setDecoyButton(p,player_index,decoy_number)
	if p.decoy_drop == nil then
		p.decoy_drop = {}
	end
	if p.decoy_button == nil then
		p.decoy_button = {}
	end
	local player_name = p:getCallSign()
	local decoy_button_label = string.format("%s%iDecoyButtonWeapons",player_name,decoy_number)
	if p.decoy_button[decoy_button_label] == nil and p.decoy_drop[decoy_number] == nil then
		p:addCustomButton("Weapons",decoy_button_label,string.format(_("decoy-buttonWeapons", "Drop Decoy %i"),decoy_number),drop_decoy_functions[player_index][decoy_number])
		p.decoy_button[decoy_button_label] = player_name
		decoy_button_label = string.format("%s%iDecoyButtonTactical",p:getCallSign(),decoy_number)
		p:addCustomButton("Tactical",decoy_button_label,string.format(_("decoy-buttonTactical", "Drop Decoy %i"),decoy_number),drop_decoy_functions[player_index][decoy_number])
		p.decoy_button[decoy_button_label] = player_name
	end
end
function setP1DecoyButton()
	setDecoyButton(p1,1,1)
end
function setP1DecoyButton2()
	setDecoyButton(p1,1,2)
end
function setP1DecoyButton3()
	setDecoyButton(p1,1,3)
end
function removeP1DecoyButton()
	removeDecoyButton(p1)
end
function removeP1DecoyButton2()
	removeDecoyButton(p1)
end
function removeP1DecoyButton3()
	removeDecoyButton(p1)
end
function setP2DecoyButton()
	setDecoyButton(p2,2,1)
end
function setP2DecoyButton2()
	setDecoyButton(p2,2,2)
end
function setP2DecoyButton3()
	setDecoyButton(p2,2,3)
end
function removeP2DecoyButton()
	removeDecoyButton(p2)
end
function removeP2DecoyButton2()
	removeDecoyButton(p2)
end
function removeP2DecoyButton3()
	removeDecoyButton(p2)
end
function setP3DecoyButton()
	setDecoyButton(p3,3,1)
end
function setP3DecoyButton2()
	setDecoyButton(p3,3,2)
end
function setP3DecoyButton3()
	setDecoyButton(p3,3,3)
end
function removeP3DecoyButton()
	removeDecoyButton(p3)
end
function removeP3DecoyButton2()
	removeDecoyButton(p3)
end
function removeP3DecoyButton3()
	removeDecoyButton(p3)
end
function setP4DecoyButton()
	setDecoyButton(p4,4,1)
end
function setP4DecoyButton2()
	setDecoyButton(p4,4,2)
end
function setP4DecoyButton3()
	setDecoyButton(p4,4,3)
end
function removeP4DecoyButton()
	removeDecoyButton(p4)
end
function removeP4DecoyButton2()
	removeDecoyButton(p4)
end
function removeP4DecoyButton3()
	removeDecoyButton(p4)
end
function setP5DecoyButton()
	setDecoyButton(p5,5,2)
end
function setP5DecoyButton3()
	setDecoyButton(p5,5,3)
end
function removeP5DecoyButton()
	removeDecoyButton(p5)
end
function removeP5DecoyButton3()
	removeDecoyButton(p5)
end
function setP6DecoyButton()
	setDecoyButton(p6,6,2)
end
function setP6DecoyButton3()
	setDecoyButton(p6,6,3)
end
function removeP6DecoyButton()
	removeDecoyButton(p6)
end
function removeP6DecoyButton3()
	removeDecoyButton(p6)
end
function setP7DecoyButton()
	setDecoyButton(p7,7,3)
end
function removeP7DecoyButton()
	removeDecoyButton(p7)
end
function setP8DecoyButton()
	setDecoyButton(p8,8,3)
end
function removeP8DecoyButton()
	removeDecoyButton(p8)
end

-----------------------------------------------------------------------
--	Player Ship Drone Deployment Related Button Call-Back Functions  --
-----------------------------------------------------------------------
function notEnoughDronesMessage(p,count)
	local pName = p:getCallSign()
	local msgLabel = string.format("%sweaponsfewerthan%idrones",pName,count)
	p:addCustomMessage("Weapons",msgLabel,string.format(_("drones-msgWeapons", "You do not have %i drones to deploy"),count))
	msgLabel = string.format("%stacticalfewerthan%idrones",pName,count)
	p:addCustomMessage("Tactical",msgLabel,string.format(_("drones-msgTactical", "You do not have %i drones to deploy"),count))
end
--drone count label
function establishDroneAvailableCount(p)
	local player_name = p:getCallSign()
	local count_info = string.format(_("drones-tabWeapons&Tactical", "Drones Available: %i"),p.dronePool)
	local button_name = player_name .. "countWeapons"
	p:addCustomInfo("Weapons",button_name,count_info)
	p.drone_pool_info_weapons = button_name
	button_name = player_name .. "countTactical"
	p.drone_pool_info_tactical = button_name
	p:addCustomInfo("Tactical",button_name,count_info)
end
function removeDroneAvailableCount(p,console)
	if console == nil then
		return
	end
	if console == "Weapons" then
		if p.drone_pool_info_weapons ~= nil then
			p:removeCustom(p.drone_pool_info_weapons)
		end
	elseif console == "Tactical" then
		if p.drone_pool_info_tactical ~= nil then
			p:removeCustom(p.drone_pool_info_tactical)
		end
	end
end
function updateDroneAvailableCount(p)
	if p:hasPlayerAtPosition("Weapons") then
		removeDroneAvailableCount(p,"Weapons")
	end
	if p:hasPlayerAtPosition("Tactical") then
		removeDroneAvailableCount(p,"Tactical")
	end
	local player_name = p:getCallSign()
	local count_info = string.format(_("drones-tabWeapons&Tactical", "Drones Available: %i"),p.dronePool)
	local button_name = player_name .. "countWeapons"
	if p:hasPlayerAtPosition("Weapons") then
		p:addCustomInfo("Weapons",button_name,count_info)
		p.drone_pool_info_weapons = button_name
	end
	if p:hasPlayerAtPosition("Tactical") then
		button_name = player_name .. "countTactical"
		p:addCustomInfo("Tactical",button_name,count_info)
		p.drone_pool_info_tactical = button_name
	end
end

--------------------------------------
--	Drone creation and destruction  --
--------------------------------------
function deployDronesForPlayer(p,playerIndex,droneNumber)
	local px, py = p:getPosition()
	local droneList = {}
	if p.droneSquads == nil then
		p.droneSquads = {}
		p.squadCount = 0
	end
	local squadIndex = p.squadCount + 1
	local pName = p:getCallSign()
	local squadName = string.format(_("callsign-squad", "%s-Sq%i"),pName,squadIndex)
	all_squad_count = all_squad_count + 1
	for i=1,droneNumber do
		local vx, vy = vectorFromAngle(360/droneNumber*i,800)
		local drone = CpuShip():setPosition(px+vx,py+vy):setFaction(p:getFaction()):setTemplate("Ktlitan Drone"):setScanned(true):setCommsScript(""):setCommsFunction(commsShip):setHeading(360/droneNumber*i+90)
		if drone_name_type == "squad-num/size" then
			drone:setCallSign(string.format(_("callsign-drone", "%s-#%i/%i"),squadName,i,droneNumber))
		elseif drone_name_type == "squad-num of size" then
			drone:setCallSign(string.format(_("callsign-drone", "%s-%i of %i"),squadName,i,droneNumber))
		elseif drone_name_type == "short" then
			--string.char(math.random(65,90)) --random letter A-Z
			local squad_letter_id = string.char(all_squad_count%26+64)
			if all_squad_count > 26 then
				squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/26)+64)
				if all_squad_count > 676 then
					squad_letter_id = squad_letter_id .. string.char(math.floor(all_squad_count/676)+64)
				end
			end
			drone:setCallSign(string.format(_("callsign-drone", "%s%i/%i"),squad_letter_id,i,droneNumber))
		end
		if drone_modified_from_template then
			drone:setHullMax(drone_hull_strength):setHull(drone_hull_strength):setImpulseMaxSpeed(drone_impulse_speed)
			--       index from 0, arc, direction,            range,            cycle time,            damage
			drone:setBeamWeapon(0,  40,         0, drone_beam_range, drone_beam_cycle_time, drone_beam_damage)
		end
		drone.squadName = squadName
		drone.deployer = p
		drone.drone = true
		drone:onDestruction(droneDestructionManagement)
		table.insert(droneList,drone)
	end
	p.squadCount = p.squadCount + 1
	p.dronePool = p.dronePool - droneNumber
	p.droneSquads[squadName] = droneList
	if p:hasPlayerAtPosition("Weapons") then
		if droneNumber > 1 then
			p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format(_("drones-msgWeapons", "%i drones launched"),droneNumber))
		else
			p:addCustomMessage("Weapons","drone_launch_confirm_message_weapons",string.format(_("drones-msgWeapons", "%i drone launched"),droneNumber))
		end
	end
	if p:hasPlayerAtPosition("Tactical") then
		if droneNumber > 1 then
			p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format(_("drones-msgTactical", "%i drones launched"),droneNumber))
		else
			p:addCustomMessage("Tactical","drone_launch_confirm_message_tactical",string.format(_("drones-msgTactical", "%i drone launched"),droneNumber))
		end
	end
	if droneNumber > 1 then
		p:addToShipLog(string.format(_("drones-shipLog", "Deployed %i drones as squadron %s"),droneNumber,squadName),"White")
	else
		p:addToShipLog(string.format(_("drones-shipLog", "Deployed %i drone as squadron %s"),droneNumber,squadName),"White")
	end
--	updateDroneAvailableCount(p)
end
function droneDestructionManagement(destroyed_drone, attacker_ship)
	local drone_name = destroyed_drone:getCallSign()
	local squad_name = destroyed_drone.squadName
	local attacker_name = attacker_ship:getCallSign()
	local notice = string.format(_("drones-", "  WHACK!  Drone %s in squadron %s has been destroyed by %s!"),
		drone_name,
		squad_name,
		attacker_name)
	--local notice = "  WHACK!  Drone " .. destroyed_drone:getCallSign() .. " has been destroyed by " .. attacker_ship:getCallSign() .. "!"
	print(notice)
	if destroyed_drone.deployer ~= nil and destroyed_drone.deployer:isValid() then
		destroyed_drone.deployer:addToShipLog(notice,"Magenta")
		local interjection = {"Pow","Boom","Bam","Ouch","Oof","Splat","Boff","Bang","Hey","Whoa","Yikes","Oops","Squash","Zowie","Wow","Awk","Bap","Blurp","Crunch","Plop","Pam","Klonk","Thunk","Wham","Zap","Whap"}
		local engineer_notice = interjection[math.random(1,#interjection)]
		local engineer_notice_message_choice = math.random(1,5)
		if engineer_notice_message_choice == 1 then
			engineer_notice = string.format(_("drones-msgEngineer&Engineer+", "%s! Telemetry from %s in squad % stopped abruptly indicating destruction. Probable instigator: %s"),engineer_notice,drone_name,squad_name,attacker_name)
		elseif engineer_notice_message_choice == 2 then
			engineer_notice = string.format(_("drones-msgEngineer&Engineer+", "*%s* Another drone bites the dust: %s in squad %s destroyed by %s"),engineer_notice,drone_name,squad_name,attacker_name)
		elseif engineer_notice_message_choice == 3 then
			engineer_notice = string.format(_("drones-msgEngineer&Engineer+", "--%s-- Drone %s in squad %s just disappeared. %s was nearby"),engineer_notice,drone_name,squad_name,attacker_name)
		elseif engineer_notice_message_choice == 4 then
			engineer_notice = string.format(_("drones-msgEngineer&Engineer+", "%s! %s just took out Drone %s in squad %s"),engineer_notice,attacker_name,drone_name,squad_name)
		else
			engineer_notice = string.format(_("drones-msgEngineer&Engineer+", "%s! Drone %s in squad %s was destroyed by %s"),engineer_notice,drone_name,squad_name,attacker_name)
		end
		if destroyed_drone.deployer:hasPlayerAtPosition("Engineering") then
			destroyed_drone.deployer:addCustomMessage("Engineering",engineer_notice,engineer_notice)
		end
		if destroyed_drone.deployer:hasPlayerAtPosition("Engineering+") then
			local engineer_notice_plus = engineer_notice .. "plus"
			destroyed_drone.deployer:addCustomMessage("Engineering+",engineer_notice_plus,engineer_notice)
		end
	end
end

--------------------------
--	Ship communication  --
--------------------------
-- Based on comms_ship.lua
-- variable player replaced with variable comms_source
-- variable and function mainMenu replaced with commsShip
-- see pertinent code below for fleet order specifics
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	
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

		missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. string.format(_("shipAssist-comms", "%s Missiles: %d/%d\n"), missile_type, math.floor(comms_target:getWeaponStorage(missile_type)), math.floor(comms_target:getWeaponStorageMax(missile_type)))
			end
		end

		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	--pertinent code
	local squadName = comms_target.squadName
	if squadName ~= nil then
		local pName = comms_source:getCallSign()
		if string.find(squadName,pName) then
			addCommsReply(_("shipAssist-comms", "Go attack enemies"), function()
				comms_target:orderRoaming()
				setCommsMessage(_("shipAssist-comms", "Going roaming and attacking"))
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(_("shipAssist-comms", "Go to waypoint. Attack enemies en route"), function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
					addCommsReply(_("Back"), commsShip)
				else
					setCommsMessage(_("shipAssist-comms", "Which waypoint?"));
					for n=1,comms_source:getWaypointCount() do
						addCommsReply(string.format(_("shipAssist-comms", "Go to WP%d"),n), function()
							comms_target:orderFlyTowards(comms_source:getWaypoint(n))
							setCommsMessage(string.format(_("shipAssist-comms", "Going to WP%d, watching for enemies en route"), n));
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end
			end)
			addCommsReply(_("shipAssist-comms", "Go to waypoint. Ignore enemies"), function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
					addCommsReply(_("Back"), commsShip)
				else
					setCommsMessage(_("shipAssist-comms", "Which waypoint?"));
					for n=1,comms_source:getWaypointCount() do
						addCommsReply(string.format(_("shipAssist-comms", "Go to WP%d"),n), function()
							comms_target:orderFlyTowardsBlind(comms_source:getWaypoint(n))
							setCommsMessage(string.format(_("shipAssist-comms", "Going to WP%d, ignoring enemies"), n));
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end
			end)
			addCommsReply(_("shipAssist-comms", "Stop and defend your current position"), function()
				comms_target:orderStandGround()
				setCommsMessage(_("shipAssist-comms", "Stopping and defending"))
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(_("shipAssist-comms", "Stop. Do nothing"), function()
				comms_target:orderIdle()
				local nothing_message_choice = math.random(1,15)
				if nothing_message_choice == 1 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except routine system maintenance"))
				elseif nothing_message_choice == 2 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except idle drone gossip"))
				elseif nothing_message_choice == 3 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except exterior paint touch-up"))
				elseif nothing_message_choice == 4 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except cyber exercise for continued fitness"))
				elseif nothing_message_choice == 5 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except algorithmic meditation therapy"))
				elseif nothing_message_choice == 6 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except internal simulated flight routines"))
				elseif nothing_message_choice == 7 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except digital dreamscape construction"))
				elseif nothing_message_choice == 8 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except catching up on reading the latest drone drama novel"))
				elseif nothing_message_choice == 9 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except writing up results of bifurcated drone personality research"))
				elseif nothing_message_choice == 10 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except categorizing nearby miniscule space particles"))
				elseif nothing_message_choice == 11 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except continuing the count of visible stars from this region"))
				elseif nothing_message_choice == 12 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except internal systems diagnostics"))
				elseif nothing_message_choice == 13 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except composing amorous communications to my favorite drone"))
				elseif nothing_message_choice == 14 then
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing except repairing experimental vocalization circuits"))
				else
					setCommsMessage(_("shipAssist-comms", "Stopping. Doing nothing"))
				end
				addCommsReply(_("Back"), commsShip)
			end)
			addCommsReply(string.format(_("shipAssist-comms", "Direct %s"),squadName), function()
				local squadName = comms_target.squadName
				setCommsMessage(string.format(_("shipAssist-comms", "What command should I give to %s?"),squadName))
				addCommsReply(_("shipAssist-comms", "Assist me"), function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderDefendTarget(comms_source)
						end
					end
					setCommsMessage(string.format(_("shipAssist-comms", "%s heading toward you to assist"),squadName))
					addCommsReply(_("Back"), commsShip)
				end)
				addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
					local squadName = comms_target.squadName
					if comms_source:getWaypointCount() == 0 then
						setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
						addCommsReply(_("Back"), commsShip)
					else
						setCommsMessage(_("shipAssist-comms", "Which waypoint should we defend?"));
						for n=1,comms_source:getWaypointCount() do
							addCommsReply(string.format(_("shipAssist-comms", "Defend WP%d"),n), function()
								for _, drone in pairs(comms_source.droneSquads[squadName]) do
									if drone ~= nil and drone:isValid() then
										drone:orderDefendLocation(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP%d."),n));
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
				end)
				addCommsReply(_("shipAssist-comms", "Go to waypoint. Attack enemies en route"), function()
					local squadName = comms_target.squadName
					if comms_source:getWaypointCount() == 0 then
						setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
						addCommsReply(_("Back"), commsShip)
					else
						setCommsMessage(_("shipAssist-comms", "Which waypoint?"));
						for n=1,comms_source:getWaypointCount() do
							addCommsReply(string.format(_("shipAssist-comms", "Go to WP%d"),n), function()
								for _, drone in pairs(comms_source.droneSquads[squadName]) do
									if drone ~= nil and drone:isValid() then
										drone:orderFlyTowards(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage(string.format(_("shipAssist-comms", "Going to WP%d, watching for enemies en route"), n));
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
				end)
				addCommsReply(_("shipAssist-comms", "Go to waypoint. Ignore enemies"), function()
					local squadName = comms_target.squadName
					if comms_source:getWaypointCount() == 0 then
						setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
						addCommsReply(_("Back"), commsShip)
					else
						setCommsMessage(_("shipAssist-comms", "Which waypoint?"));
						for n=1,comms_source:getWaypointCount() do
							addCommsReply(string.format(_("shipAssist-comms", "Go to WP%d"),n), function()
								for _, drone in pairs(comms_source.droneSquads[squadName]) do
									if drone ~= nil and drone:isValid() then
										drone:orderFlyTowardsBlind(comms_source:getWaypoint(n))
									end
								end
								setCommsMessage(string.format(_("shipAssist-comms", "Going to WP%d, ignoring enemies"), n));
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end
				end)
				addCommsReply(_("shipAssist-comms", "Go and swarm enemies"), function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderRoaming()
						end
					end
					setCommsMessage(string.format(_("shipAssist-comms", "%s roaming and attacking"),squadName))
					addCommsReply(_("Back"), commsShip)
				end)
				addCommsReply(_("shipAssist-comms", "Stop and defend your current positions"), function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderStandGround()
						end
					end
					setCommsMessage(string.format(_("shipAssist-comms", "%s standing ground"),squadName))
					addCommsReply(_("Back"), commsShip)
				end)
				addCommsReply(_("shipAssist-comms", "Stop. Do Nothing"), function()
					local squadName = comms_target.squadName
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() then
							drone:orderIdle()
						end
					end
					setCommsMessage(string.format(_("shipAssist-comms", "%s standing down"),squadName))
					addCommsReply(_("Back"), commsShip)
				end)
				addCommsReply(_("shipAssist-comms", "Other drones in squad form up on me"), function()
					local squadName = comms_target.squadName
					local formCount = 0
					local leadName = comms_target:getCallSign()
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() and leadName ~= drone:getCallSign() then
							formCount = formCount + 1
						end
					end
					local formIndex = 0
					comms_target:orderIdle()
					for _, drone in pairs(comms_source.droneSquads[squadName]) do
						if drone ~= nil and drone:isValid() and leadName ~= drone:getCallSign() then
							local fx, fy = vectorFromAngle(360/formCount*formIndex,drone_formation_spacing)
							drone:orderFlyFormation(comms_target, fx, fy)
							formIndex = formIndex + 1
						end
					end
					setCommsMessage(string.format(_("shipAssist-comms", "%s is forming up on me"),squadName))
					addCommsReply(_("Back"), commsShip)
				end)
			end)
		end
	end
	--end of pertinent code
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
	if comms_data.friendlyness > 50 then
		setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
	else
		setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
	end
	return true
end

------------------------
--	Update functions  --
------------------------
function createTwinPlayer(twin,player_index)
	local template = twin:getTypeName()
	local pt = PlayerSpaceship():setFaction("Kraylor"):setTemplate(template):setPosition(playerStartX[player_index],playerStartY[player_index]):setHeading(player_start_heading[player_index]):commandTargetRotation(player_start_rotation[player_index])
	setPlayer(pt,player_index)
	return pt
end
function manageAddingNewPlayerShips()
	local player_count = 0
	p1 = getPlayerShip(1)
	if p1 ~= nil then
		p2 = getPlayerShip(2)
		if p2 == nil then
			p2 = createTwinPlayer(p1,2)
		end
		if not p1.nameAssigned then
			p1:setPosition(playerStartX[1],playerStartY[1]):setHeading(player_start_heading[1]):commandTargetRotation(player_start_rotation[1])
			setPlayer(p1,1)
		end
		player_count = 2
		human_player_names[p1:getCallSign()] = p1
		kraylor_player_names[p2:getCallSign()] = p2
	end
	p3 = getPlayerShip(3)
	if p3 ~= nil then
		p4 = getPlayerShip(4)
		if p4 == nil then
			p4 = createTwinPlayer(p3,4)
		end
		if not p3.nameAssigned then
			p3:setPosition(playerStartX[3],playerStartY[3]):setHeading(player_start_heading[3]):commandTargetRotation(player_start_rotation[3])
			setPlayer(p3,3)
		end
		player_count = 4
		human_player_names[p3:getCallSign()] = p3
		kraylor_player_names[p4:getCallSign()] = p4
	end
	p5 = getPlayerShip(5)
	if p5 ~= nil then
		p6 = getPlayerShip(6)
		if p6 == nil then
			p6 = createTwinPlayer(p5,6)
		end
		if not p5.nameAssigned then
			p5:setPosition(playerStartX[5],playerStartY[5]):setHeading(player_start_heading[5]):commandTargetRotation(player_start_rotation[5])
			setPlayer(p5,5)
		end
		player_count = 6
		human_player_names[p5:getCallSign()] = p5
		kraylor_player_names[p6:getCallSign()] = p6
	end
	p7 = getPlayerShip(7)
	if p7 ~= nil then
		p8 = getPlayerShip(8)
		if p8 == nil then
			p8 = createTwinPlayer(p7,8)
		end
		if not p7.nameAssigned then
			p7:setPosition(playerStartX[7],playerStartY[7]):setHeading(player_start_heading[7]):commandTargetRotation(player_start_rotation[7])
			setPlayer(p7,7)
		end
		player_count = 8
		human_player_names[p7:getCallSign()] = p7
		kraylor_player_names[p8:getCallSign()] = p8
	end
	p9 = getPlayerShip(9)
	if p9 ~= nil then
		p10 = getPlayerShip(10)
		if p10 == nil then
			p10 = createTwinPlayer(p9,10)
		end
		if not p9.nameAssigned then
			p9:setPosition(playerStartX[9],playerStartY[9]):setHeading(player_start_heading[9]):commandTargetRotation(player_start_rotation[9])
			setPlayer(p9,9)
		end
		player_count = 10
		human_player_names[p9:getCallSign()] = p9
		kraylor_player_names[p10:getCallSign()] = p10
	end
	p11 = getPlayerShip(11)
	if p11 ~= nil then
		p12 = getPlayerShip(12)
		if p12 == nil then
			p12 = createTwinPlayer(p11,12)
		end
		if not p11.nameAssigned then
			p11:setPosition(playerStartX[11],playerStartY[11]):setHeading(player_start_heading[11]):commandTargetRotation(player_start_rotation[11])
			setPlayer(p11,11)
		end
		player_count = 12
		human_player_names[p11:getCallSign()] = p11
		kraylor_player_names[p12:getCallSign()] = p12
	end
	p13 = getPlayerShip(13)
	if p13 ~= nil then
		p14 = getPlayerShip(14)
		if p14 == nil then
			p14 = createTwinPlayer(p13,14)
		end
		if not p13.nameAssigned then
			p13:setPosition(playerStartX[13],playerStartY[13]):setHeading(player_start_heading[13]):commandTargetRotation(player_start_rotation[13])
			setPlayer(p13,13)
		end
		player_count = 14
		human_player_names[p13:getCallSign()] = p13
		kraylor_player_names[p14:getCallSign()] = p14
	end
	p15 = getPlayerShip(15)
	if p15 ~= nil then
		p16 = getPlayerShip(16)
		if p16 == nil then
			p16 = createTwinPlayer(p15,16)
		end
		if not p15.nameAssigned then
			p15:setPosition(playerStartX[15],playerStartY[15]):setHeading(player_start_heading[15]):commandTargetRotation(player_start_rotation[15])
			setPlayer(p15,15)
		end
		player_count = 16
		human_player_names[p15:getCallSign()] = p15
		kraylor_player_names[p16:getCallSign()] = p16
	end
	p17 = getPlayerShip(17)
	if p17 ~= nil then
		p18 = getPlayerShip(18)
		if p18 == nil then
			p18 = createTwinPlayer(p17,18)
		end
		if not p17.nameAssigned then
			p17:setPosition(playerStartX[17],playerStartY[17]):setHeading(player_start_heading[17]):commandTargetRotation(player_start_rotation[17])
			setPlayer(p17,17)
		end
		player_count = 18
		human_player_names[p17:getCallSign()] = p17
		kraylor_player_names[p18:getCallSign()] = p18
	end
	p19 = getPlayerShip(19)
	if p19 ~= nil then
		p20 = getPlayerShip(20)
		if p20 == nil then
			p20 = createTwinPlayer(p19,20)
		end
		if not p19.nameAssigned then
			p19:setPosition(playerStartX[19],playerStartY[19]):setHeading(player_start_heading[19]):commandTargetRotation(player_start_rotation[19])
			setPlayer(p19,19)
		end
		player_count = 20
		human_player_names[p19:getCallSign()] = p19
		kraylor_player_names[p20:getCallSign()] = p20
	end
	p21 = getPlayerShip(21)
	if p21 ~= nil then
		p22 = getPlayerShip(22)
		if p22 == nil then
			p22 = createTwinPlayer(p21,22)
		end
		if not p21.nameAssigned then
			p21:setPosition(playerStartX[21],playerStartY[21]):setHeading(player_start_heading[21]):commandTargetRotation(player_start_rotation[21])
			setPlayer(p21,21)
		end
		player_count = 22
		human_player_names[p21:getCallSign()] = p21
		kraylor_player_names[p22:getCallSign()] = p22
	end
	p23 = getPlayerShip(23)
	if p23 ~= nil then
		p24 = getPlayerShip(24)
		if p24 == nil then
			p24 = createTwinPlayer(p23,24)
		end
		if not p23.nameAssigned then
			p23:setPosition(playerStartX[23],playerStartY[23]):setHeading(player_start_heading[23]):commandTargetRotation(player_start_rotation[23])
			setPlayer(p23,23)
		end
		player_count = 24
		human_player_names[p23:getCallSign()] = p23
		kraylor_player_names[p24:getCallSign()] = p24
	end
	p25 = getPlayerShip(25)
	if p25 ~= nil then
		p26 = getPlayerShip(26)
		if p26 == nil then
			p26 = createTwinPlayer(p25,26)
		end
		if not p25.nameAssigned then
			p25:setPosition(playerStartX[25],playerStartY[25]):setHeading(player_start_heading[25]):commandTargetRotation(player_start_rotation[25])
			setPlayer(p25,25)
		end
		player_count = 26
		human_player_names[p25:getCallSign()] = p25
		kraylor_player_names[p26:getCallSign()] = p26
	end
	p27 = getPlayerShip(27)
	if p27 ~= nil then
		p28 = getPlayerShip(28)
		if p28 == nil then
			p28 = createTwinPlayer(p27,28)
		end
		if not p27.nameAssigned then
			p27:setPosition(playerStartX[27],playerStartY[27]):setHeading(player_start_heading[27]):commandTargetRotation(player_start_rotation[27])
			setPlayer(p27,27)
		end
		player_count = 28
		human_player_names[p27:getCallSign()] = p27
		kraylor_player_names[p28:getCallSign()] = p28
	end
	p29 = getPlayerShip(29)
	if p29 ~= nil then
		p30 = getPlayerShip(30)
		if p30 == nil then
			p30 = createTwinPlayer(p29,30)
		end
		if not p29.nameAssigned then
			p29:setPosition(playerStartX[29],playerStartY[29]):setHeading(player_start_heading[29]):commandTargetRotation(player_start_rotation[29])
			setPlayer(p29,29)
		end
		player_count = 30
		human_player_names[p29:getCallSign()] = p29
		kraylor_player_names[p30:getCallSign()] = p30
	end
	p31 = getPlayerShip(31)
	if p31 ~= nil then
		p32 = getPlayerShip(32)
		if p32 == nil then
			p32 = createTwinPlayer(p31,32)
		end
		if not p31.nameAssigned then
			p31:setPosition(playerStartX[31],playerStartY[31]):setHeading(player_start_heading[31]):commandTargetRotation(player_start_rotation[31])
			setPlayer(p31,31)
		end
		player_count = 32
		human_player_names[p31:getCallSign()] = p31
		kraylor_player_names[p32:getCallSign()] = p32
	end
	if wingSquadronNames then
		if player_count > 0 then
			for index, name in ipairs(player_wing_names[player_count]) do
				local p = getPlayerShip(index)
				p:setCallSign(name)
				if index % 2 == 0 then
					kraylor_player_names[name] = p
				else
					human_player_names[name] = p
				end
			end
		end
	end
end
function placeFlagsPhase()
	-- this function does the following:
		-- immediately destroys players if they venture to the opposing side during the flag placement phase
		-- removes the "place flag" buttons if the player ship goes outside of the establish flag placement boundary
		-- adds the "place flag" button back to the player ship when they return inside the established flag placement boundary
	timeDivision = "hide"
	if stationZebra ~= nil and stationZebra:isValid() then
		minutes = math.floor((gameTimeLimit - (maxGameTime - hideFlagTime))/60)
		seconds = (gameTimeLimit - (maxGameTime - hideFlagTime)) % 60
		stationZebra:setCallSign(string.format(_("callsign-station", "Hide flag %i:%.1f"),minutes,seconds))
	end
	if p1 ~= nil and p1:isValid() then
		local p1x, p1y = p1:getPosition()
		if p1x > 0 then
			p1:destroy()
		end
		if p1x > -1*boundary and p1y > -1*boundary/2 and p1y < boundary/2 then
			setP1FlagButton()
			if p7 == nil then
				setP1DecoyButton()	--decoy 1
				if p3 == nil then
					setP1DecoyButton2()
					setP1DecoyButton3()					
				end				
			end
		else
			removeP1FlagButton()
			if p7 == nil then
				removeP1DecoyButton()	--decoy 1
				if p3 == nil then
					removeP1DecoyButton2()
					removeP1DecoyButton3()
				end
			end
		end
	end
	if p2 ~= nil and p2:isValid() then
		p2x, p2y = p2:getPosition()
		if p2x < 0 then
			p2:destroy()
		end
		if p2x < boundary and p2y > -1*boundary/2 and p2y < boundary/2 then
			setP2FlagButton()
			if p7 == nil then
				setP2DecoyButton()	--decoy 1
				if p3 == nil then
					setP2DecoyButton2()
					setP2DecoyButton3()
				end
			end
		else
			removeP2FlagButton()
			if p7 == nil then
				removeP2DecoyButton()	--decoy 1
				if p3 == nil then
					removeP2DecoyButton2()
					removeP2DecoyButton3()
				end
			end
		end
	end
	if p3 ~= nil and p3:isValid() then
		p3x, p3y = p3:getPosition()
		if p3x > 0 then
			p3:destroy()
		end
		if difficulty >= 1 then
			if p3x > -1*boundary and p3y > -1*boundary/2 and p3y < boundary/2 then
				if p7 == nil then
					setP3DecoyButton2()
					if p5 == nil then
						setP3DecoyButton3()						
					end					
				else
					setP3DecoyButton()	--decoy 1
				end
			else
				if p7 == nil then
					removeP3DecoyButton2()
					if p5 == nil then
						removeP3DecoyButton3()
					end
				else
					removeP3DecoyButton()	--decoy 1
				end
			end
		end
	end
	if p4 ~= nil and p4:isValid() then
		p4x, p4y = p4:getPosition()
		if p4x < 0 then
			p4:destroy()
		end
		if difficulty >= 1 then
			if p4x < boundary and p4y > -1*boundary/2 and p4y < boundary/2 then
				if p7 == nil then
					setP4DecoyButton2()
					if p5 == nil then
						setP4DecoyButton3()
					end
				else
					setP4DecoyButton()	--decoy 1
				end
			else
				if p7 == nil then
					removeP4DecoyButton2()
					if p5 == nil then
						removeP4DecoyButton3()
					end
				else
					removeP4DecoyButton()	--decoy 1
				end
			end
		end
	end
	if p5 ~= nil and p5:isValid() then
		p5x, p5y = p5:getPosition()
		if p5x > 0 then
			p5:destroy()
		end
		if difficulty >= 1 then
			if p5x > -1*boundary and p5y > -1*boundary/2 and p5y < boundary/2 then
				if p7 == nil then
					setP5DecoyButton3()
				else
					setP5DecoyButton()	--decoy 2
				end
			else
				if p7 == nil then
					removeP5DecoyButton3()					
				else
					removeP5DecoyButton()	--decoy 2
				end
			end
		end
	end
	if p6 ~= nil and p6:isValid() then
		p6x, p6y = p6:getPosition()
		if p6x < 0 then
			p6:destroy()
		end
		if difficulty >= 1 then
			if p6x < boundary and p6y > -1*boundary/2 and p6y < boundary/2 then
				if p7 == nil then
					setP6DecoyButton3()
				else
					setP6DecoyButton()	--decoy 2
				end
			else
				if p7 == nil then
					removeP6DecoyButton3()
				else
					removeP6DecoyButton()	--decoy 2
				end
			end
		end
	end
	if p7 ~= nil and p7:isValid() then
		p7x, p7y = p7:getPosition()
		if p7x > 0 then
			p7:destroy()
		end
		if difficulty >= 1 then
			if p7x > -1*boundary and p7y > -1*boundary/2 and p7y < boundary/2 then
				setP7DecoyButton()
			else
				removeP7DecoyButton()
			end
		end
	end
	if p8 ~= nil and p8:isValid() then
		p8x, p8y = p8:getPosition()
		if p8x < 0 then
			p8:destroy()
		end
		if difficulty >= 1 then
			if p8x < boundary and p8y > -1*boundary/2 and p8y < boundary/2 then
				setP8DecoyButton()
			else
				removeP8DecoyButton()
			end
		end
	end
	local boundary_check_list = {
		{player = p9,	greater = true},
		{player = p10,	greater = false},
		{player = p11,	greater = true},
		{player = p12,	greater = false},
		{player = p13,	greater = true},
		{player = p14,	greater = false},
		{player = p15,	greater = true},
		{player = p16,	greater = false},
		{player = p17,	greater = true},
		{player = p18,	greater = false},
		{player = p19,	greater = true},
		{player = p20,	greater = false},
		{player = p21,	greater = true},
		{player = p22,	greater = false},
		{player = p23,	greater = true},
		{player = p24,	greater = false},
		{player = p25,	greater = true},
		{player = p26,	greater = false},
		{player = p27,	greater = true},
		{player = p28,	greater = false},
		{player = p29,	greater = true},
		{player = p30,	greater = false},
		{player = p31,	greater = true},
		{player = p32,	greater = false},
	}
	for i=1,#boundary_check_list do
		local bcp = boundary_check_list[i]
		if bcp.player ~= nil and bcp.player:isValid() then
			local p_x, p_y = bcp.player:getPosition()
			if bcp.greater then
				if p_x > 0 then
					bcp.player:destroy()
				end
			else
				if p_x < 0 then
					bcp.player:destroy()
				end
			end
		end
	end
end
function transitionFromPreparationToHunt()
	-- this function checks to see if the teams have placed their flags, and if not, then either drops the flags where the ships are if they are within bounds, or if the ship is out of flag bounds, then the flag is placed in the nearest "in bounds" location
	-- buttons are also cleaned up off the consoles for placing flags
	timeDivision = "transition"
	stationZebra:setCallSign(_("callsign-station", "Transition"))
	removeP1FlagButton()
	removeP2FlagButton()
	if p1Flag == nil then
		if p1Flagx == nil then
			if p1 ~= nil and p1:isValid() then
				p1Flagx, p1Flagy = p1:getPosition()
--				print("human flag x:",p1Flagx,"human flag y:",p1Flagy,"(ship is valid)")
			else
				if p1.point_of_destruction_x ~= nil and p1.point_of_destruction_y ~= nil then
					p1Flagx = p1.point_of_destruction_x
					p1Flagy = p1.point_of_destruction_y
--					print("human flag x:",p1Flagx,"human flag y:",p1Flagy,"(ship not valid, using point of destruction)")
				else
					p1Flagx = playerStartX[1]
					p1Flagy = playerStartY[1]
--					print("human flag x:",p1Flagx,"human flag y:",p1Flagy,"(ship not valid, using starting point)")
				end
			end
		end
		if p1Flagx > 0 then
			p1Flagx = -1
--			print("human flag x:",p1Flagx,"human flag y:",p1Flagy,"(point was in the wrong territory)")
		end
		if p1Flagx < -1*boundary then
			p1Flagx = -1*boundary
		end
		if p1Flagy < -1*boundary/2 then
			p1Flagy = -1*boundary/2
		end
		if p1Flagy > boundary/2 then
			p1Flagy = boundary/2
		end
		p1Flag = Artifact():setPosition(p1Flagx,p1Flagy):setModel("artifact5"):allowPickup(false):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Human Navy Flag")):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
		table.insert(human_flags,p1Flag)
		if difficulty < 1 then
			p1Flag:setScannedByFaction("Kraylor")
		end
	end
	if p2Flag == nil then
		if p2Flagx == nil then
			if p2 ~= nil and p2:isValid() then
				p2Flagx, p2Flagy = p2:getPosition()
--				print("kraylor flag x:",p2Flagx,"kraylor flag y:",p2Flagy,"(ship is valid)")
			else
				if p2.point_of_destruction_x ~= nil and p2.point_of_destruction_y ~= nil then
					p2Flagx = p2.point_of_destruction_x
					p2Flagy = p2.point_of_destruction_y
--					print("kraylor flag x:",p2Flagx,"kraylor flag y:",p2Flagy,"(ship not valid, using point of destruction)")
				else
					p2Flagx = playerStartX[2]
					p2Flagy = playerStartY[2]
--					print("kraylor flag x:",p2Flagx,"kraylor flag y:",p2Flagy,"(ship not valid, using starting point)")
				end
			end
		end
		if p2Flagx < 0 then
			p2Flagx = 1
--			print("kraylor flag x:",p2Flagx,"kraylor flag y:",p2Flagy,"(point was in the wrong territory)")
		end
		if p2Flagx > boundary then
			p2Flagx = boundary
		end
		if p2Flagy < -1*boundary/2 then
			p2Flagy = -1*boundary/2
		end
		if p2Flagy > boundary/2 then
			p2Flagy = boundary/2
		end
		p2Flag = Artifact():setPosition(p2Flagx,p2Flagy):setModel("artifact5"):allowPickup(false):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Kraylor Flag")):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
		table.insert(kraylor_flags,p2Flag)
		if difficulty < 1 then
			p2Flag:setScannedByFaction("Human Navy")
		end
	end
	removeP7DecoyButton()
	removeP8DecoyButton()
	removeP5DecoyButton()
	removeP6DecoyButton()
	removeP5DecoyButton3()
	removeP6DecoyButton3()
	removeP3DecoyButton()
	removeP4DecoyButton()
	removeP3DecoyButton2()
	removeP4DecoyButton2()
	removeP3DecoyButton3()
	removeP4DecoyButton3()
	removeP1DecoyButton()
	removeP1DecoyButton2()
	removeP1DecoyButton3()
	removeP2DecoyButton()
	removeP2DecoyButton2()
	removeP2DecoyButton3()
	if decoyH1 == nil then
		if decoyH1x ~= nil then
			if decoyH1x > -1*boundary and decoyH1y > -1*boundary/2 and decoyH1y < boundary/2 then
				decoyH1 = Artifact():setPosition(decoyH1x,decoyH1y):setModel("artifact5"):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Human Navy Decoy Flag")):allowPickup(false)
				table.insert(human_flags,decoyH1)
				if difficulty > 1 then
					decoyH1:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyH1:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyK1 == nil then
		if decoyK1x ~= nil then
			if decoyK1x < boundary and decoyK1y > -1*boundary/2 and decoyK1y < boundary/2 then
				decoyK1 = Artifact():setPosition(decoyK1x,decoyK1y):setModel("artifact5"):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Kraylor Decoy Flag")):allowPickup(false)
				table.insert(kraylor_flags,decoyK1)
				if difficulty > 1 then
					decoyK1:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyK1:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyH2 == nil then
		if decoyH2x ~= nil then
			if decoyH2x > -1*boundary and decoyH2y > -1*boundary/2 and decoyH2y < boundary/2 then
				decoyH2 = Artifact():setPosition(decoyH2x,decoyH2y):setModel("artifact5"):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Human Navy Decoy Flag")):allowPickup(false)
				table.insert(human_flags,decoyH2)
				if difficulty > 1 then
					decoyH2:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyH2:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyK2 == nil then
		if decoyK2x ~= nil then
			if decoyK2x < boundary and decoyK2y > -1*boundary/2 and decoyK2y < boundary/2 then
				decoyK2 = Artifact():setPosition(decoyK2x,decoyK2y):setModel("artifact5"):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Kraylor Decoy Flag")):allowPickup(false)
				table.insert(kraylor_flags,decoyK2)
				if difficulty > 1 then
					decoyK2:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyK2:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyH3 == nil then
		if decoyH3x ~= nil then
			if decoyH3x > -1*boundary and decoyH3y > -1*boundary/2 and decoyH3y < boundary/2 then
				decoyH3 = Artifact():setPosition(decoyH3x,decoyH3y):setModel("artifact5"):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Human Navy Decoy Flag")):allowPickup(false)
				table.insert(human_flags,decoyH3)
				if difficulty > 1 then
					decoyH3:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyH3:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	if decoyK3 == nil then
		if decoyK3x ~= nil then
			if decoyK3x < boundary and decoyK3y > -1*boundary/2 and decoyK3y < boundary/2 then
				decoyK3 = Artifact():setPosition(decoyK3x,decoyK3y):setModel("artifact5"):setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Kraylor Decoy Flag")):allowPickup(false)
				table.insert(kraylor_flags,decoyK3)
				if difficulty > 1 then
					decoyK3:setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
				else
					decoyK3:setRadarSignatureInfo(20,15,10):setScanningParameters(flagScanComplexity,flagScanDepth)
				end
			end
		end
	end
	for hfi=1,#human_flags do
		local flag = human_flags[hfi]
		if flag ~= nil and flag:isValid() then
			local fx, fy = flag:getPosition()
		end
	end
	for hfi=1,#kraylor_flags do
		local flag = kraylor_flags[hfi]
		if flag ~= nil and flag:isValid() then
			local fx, fy = flag:getPosition()
		end
	end
	if worm_hole_list ~= nil then
		if #worm_hole_list > 0 then
			for i=1,#worm_hole_list do
				local worm = worm_hole_list[i]
				worm:setTargetPosition(worm.final_target_x,worm.final_target_y)
			end
		end
	end
	if flag_area_boundary_items ~= nil then
		if #flag_area_boundary_items > 0 then
			for i=1,#flag_area_boundary_items do
				flag_area_boundary_items[i]:destroy()
			end
		end
	end
	mainGMButtons()
end
function manageHuntPhaseMechanics()
	timeDivision = "hunt"
	humanShipsRemaining = 0
	kraylorShipsRemaining = 0
	minutes = math.floor(gameTimeLimit/60)
	seconds = gameTimeLimit % 60
	stationZebra:setCallSign(string.format(_("callsign-station", "Hunt flag %i:%.1f"),minutes,seconds))
	for pidx=1,32 do
		p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				px, py = p:getPosition()
				if p:getFaction() == "Kraylor" then
					kraylorShipsRemaining = kraylorShipsRemaining + 1
					if p.flag and px > 0 then
						timeDivision = "victory-kraylor"
						victory("Kraylor")
					end
					if p1Flag:isValid() then
						if distance(p,p1Flag) < 500 and p1Flag:isScannedByFaction("Kraylor") then
							p.flag = true
							p.pick_up_count = p.pick_up_count + 1
							if p.flag then
								if p:hasPlayerAtPosition("Helms") then
									p.flag_badge = "flag_badge"
									p:addCustomInfo("Helms",p.flag_badge,_("flag-tabHelms", "Human Flag Aboard"))
								end
								if p:hasPlayerAtPosition("Tactical") then
									p.flag_badge_tac = "flag_badge_tac"
									p:addCustomInfo("Tactical",p.flag_badge_tac,_("flag-tabTactical", "Human Flag Aboard"))
								end
							end
							p1Flag:destroy()
							p:addToShipLog(_("flag-shipLog", "You picked up the Human Navy flag"),"Green")
							if flag_reveal then
								if flag_grab < 2 then
									for i,cp in ipairs(getActivePlayerShips()) do
										if cp ~= p then
											if p:getFaction() == "Human Navy" then
												if flag_grab < 1 then
													cp:addToShipLog(string.format(_("flag-shipLog", "Kraylor ship %s picked up your flag"),p:getCallSign()),"Magenta")
												else
													cp:addToShipLog(_("flag-shipLog", "The Kraylor picked up your flag"),"Magenta")
												end
											elseif p:getFaction() == "Kraylor" then
												if flag_grab < 1 then
													cp:addToShipLog(string.format(_("flag-shipLog", "%s picked up the Human Navy Flag"),p:getCallSign()),"Magenta")
												else
													cp:addToShipLog(_("flag-shipLog", "Your team picked up the Human Navy flag"),"Magenta")
												end
											end
										end
									end
									if flag_grab < 1 then
										globalMessage(string.format(_("flag-msgMainscreen", "Kraylor ship %s obtained Human Navy flag"),p:getCallSign()))
									else
										globalMessage(_("flag-msgMainscreen", "Kraylor obtained Human Navy flag"))
									end
								else
									globalMessage(_("flag-msgMainscreen", "Flag obtained"))
								end
							end
						end
					end
					if px < 0 then				--Kraylor in Human area
						for cpidx=1,32 do
							cp = getPlayerShip(cpidx)
							if cp ~= nil and cp:isValid() and cp:getFaction() == "Human Navy" then
								if distance(p,cp) < tag_distance then	--tagged
									p:setPosition(player_tag_relocate_x[pidx],player_tag_relocate_y[pidx])
									p.tagged_count = p.tagged_count + 1
									curWarpDmg = p:getSystemHealth("warp")
									if curWarpDmg > (-1 + tagDamage) then
										p:setSystemHealth("warp", curWarpDmg - tagDamage)
									end
									curJumpDmg = p:getSystemHealth("jumpdrive")
									if curJumpDmg > (-1 + tagDamage) then
										p:setSystemHealth("jumpdrive", curJumpDmg - tagDamage)
									end
									if p:getSystemHealth("impulse") < 0 then
										p:setSystemHealth("impulse", .5)
									end
									if p.flag then				--carrying flag
										p.flag = false			--drop flag
										p.drop_count = p.drop_count + 1
										if p.flag_badge ~= nil then
											p:removeCustom("Helms",p.flag_badge)
											p.flag_badge = nil
										end
										if p.flag_badge_tac ~= nil then
											p:removeCustom("Tactical",p.flag_badge_tac)
											p.flag_badge_tac = nil
										end
										p1Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
										table.insert(human_flags,p1Flag)
										p1Flag:setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Human Navy Flag")):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
										if flag_revel then
											if flag_drop < 2 then
												for i,cp in ipairs(getActivePlayerShips()) do
													if cp ~= p then
														if p:getFaction() == "Human Navy" then
															if flag_drop < 1 then
																cp:addToShipLog(string.format(_("flag-shipLog", "Kraylor ship %s dropped your flag"),p:getCallSign()),"Magenta")
															else
																cp:addToShipLog(_("flag-shipLog", "The Kraylor dropped your flag"),"Magenta")
															end
														elseif p:getFaction() == "Kraylor" then
															if flag_drop < 1 then
																cp:addToShipLog(string.format(_("flag-shipLog", "%s dropped the Human Navy Flag"),p:getCallSign()),"Magenta")
															else
																cp:addToShipLog(_("flag-shipLog", "Your team dropped the Human Navy flag"),"Magenta")
															end
														end
													end
												end
												if flag_drop < 1 then
													globalMessage(string.format(_("flag-msgMainscreen", "Kraylor ship %s dropped Human Navy flag"),p:getCallSign()))
												else
													globalMessage(_("flag-msgMainscreen", "Human Navy flag dropped"))
												end
											else
												globalMessage(_("flag-msgMainscreen", "Flag dropped"))
											end
										end
										if not flag_rescan then
											p1Flag:setScannedByFaction("Kraylor",true)
										end
									end
								end
							end
						end
					end
				elseif p:getFaction() == "Human Navy" then	-- process Human player ship
					humanShipsRemaining = humanShipsRemaining + 1
					if p.flag and px < 0 then
						timeDivision = "victory-human"
						victory("Human Navy")
					end
					if p2Flag:isValid() then
						if distance(p,p2Flag) < 500 and p2Flag:isScannedByFaction("Human Navy") then
							p.flag = true
							p.pick_up_count = p.pick_up_count + 1
							if p.flag then
								if p:hasPlayerAtPosition("Helms") then
									p.flag_badge = "flag_badge"
									p:addCustomInfo("Helms",p.flag_badge,_("flag-tabHelms", "Kraylor Flag Aboard"))
								end
								if p:hasPlayerAtPosition("Tactical") then
									p.flag_badge_tac = "flag_badge_tac"
									p:addCustomInfo("Tactical",p.flag_badge_tac,_("flag-tabTactical", "Kraylor Flag Aboard"))
								end
							end
							p2Flag:destroy()
							p:addToShipLog(_("flag-shipLog", "You picked up the Kraylor flag"),"Green")
							if flag_reveal then
								if flag_grab < 2 then
									for i,cp in ipairs(getActivePlayerShips()) do
										if cp ~= p then
											if p:getFaction() == "Kraylor" then
												if flag_grab < 1 then
													cp:addToShipLog(string.format(_("flag-shipLog", "Human Navy ship %s picked up your flag"),p:getCallSign()),"Magenta")
												else
													cp:addToShipLog(_("flag-shipLog", "The Human Navy picked up your flag"),"Magenta")
												end
											elseif p:getFaction() == "Human Navy" then
												if flag_grab < 1 then
													cp:addToShipLog(string.format(_("flag-shipLog", "%s picked up the Kraylor Flag"),p:getCallSign()),"Magenta")
												else
													cp:addToShipLog(_("flag-shipLog", "Your team picked up the Kraylor flag"),"Magenta")
												end
											end
										end
									end
									if flag_grab < 1 then
										globalMessage(string.format(_("flag-msgMainscreen", "Human Navy ship %s obtained Kraylor flag"),p:getCallSign()))
									else
										globalMessage(_("flag-msgMainscreen", "Human Navy obtained Kraylor flag"))
									end
								else
									globalMessage(_("flag-msgMainscreen", "Flag obtained"))
								end
							end
						end
					end
					if px > 0 then				--Human in Kraylor area
						for cpidx=1,32 do		--loop through Kraylor ships
							cp = getPlayerShip(cpidx)
							if cp ~= nil and cp:isValid() and cp:getFaction() == "Kraylor" then
								if distance(p,cp) < tag_distance then	--tagged
									p:setPosition(player_tag_relocate_x[pidx],player_tag_relocate_y[pidx])
									p.tagged_count = p.tagged_count + 1
									curWarpDmg = p:getSystemHealth("warp")
									if curWarpDmg > (-1 + tagDamage) then
										p:setSystemHealth("warp", curWarpDmg - tagDamage)
									end
									curJumpDmg = p:getSystemHealth("jumpdrive")
									if curJumpDmg > (-1 + tagDamage) then
										p:setSystemHealth("jumpdrive", curJumpDmg - tagDamage)
									end
									if p:getSystemHealth("impulse") < 0 then
										p:setSystemHealth("impulse", .5)
									end
									if p.flag then				--carrying flag
										p.flag = false			--drop flag
										p.drop_count = p.drop_count + 1
										if p.flag_badge ~= nil then
											p:removeCustom("Helms",p.flag_badge)
											p.flag_badge = nil
										end
										if p.flag_badge_tac ~= nil then
											p:removeCustom("Tactical",p.flag_badge_tac)
											p.flag_badge_tac = nil
										end
										p2Flag = Artifact():setPosition(px,py):setModel("artifact5"):allowPickup(false)
										table.insert(kraylor_flags,p2Flag)
										p2Flag:setDescriptions(_("scienceDescription-flag", "Flag"),_("scienceDescription-flag", "Kraylor Flag")):setRadarSignatureInfo(15,10,5):setScanningParameters(flagScanComplexity,flagScanDepth)
										if flag_reveal then
											if flag_drop < 2 then
												for i,cp in ipairs(getActivePlayerShips()) do
													if cp ~= p then
														if p:getFaction() == "Kraylor" then
															if flag_drop < 1 then
																cp:addToShipLog(string.format(_("flag-shipLog", "Human Navy ship %s dropped your flag"),p:getCallSign()),"Magenta")
															else
																cp:addToShipLog(_("flag-shipLog", "The Human Navy dropped your flag"),"Magenta")
															end
														elseif p:getFaction() == "Human Navy" then
															if flag_drop < 1 then
																cp:addToShipLog(string.format(_("flag-shipLog", "%s dropped the Kraylor Flag"),p:getCallSign()),"Magenta")
															else
																cp:addToShipLog(_("flag-shipLog", "Your team dropped the Kraylor flag"),"Magenta")
															end
														end
													end
												end
												if flag_drop < 1 then
													globalMessage(string.format(_("flag-msgMainscreen", "Human Navy %s dropped Kraylor flag"),p:getCallSign()))
												else
													globalMessage(_("flag-msgMainscreen", "Human Navy flag dropped"))
												end
											else
												globalMessage(_("flag-msgMainscreen", "Flag dropped"))
											end
										end
										if not flag_rescan then
											p2Flag:setScannedByFaction("Human Navy",true)
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
	if kraylorShipsRemaining == 0 then
		if side_destroyed_ends_game then
			timeDivision = "victory-human"
			victory("Human Navy")
		else
			if game_timer_reset_on_side_destruction == nil then
				game_timer_reset_on_side_destruction = true
				gameTimeLimit = 60
			end
		end
	end
	if humanShipsRemaining == 0 then
		if side_destroyed_ends_game then
			timeDivision = "victory-kraylor"
			victory("Kraylor")
		else
			if game_timer_reset_on_side_destruction == nil then
				game_timer_reset_on_side_destruction = true
				gameTimeLimit = 60
			end
		end
	end
end
function droneDetectFlagCheck(delta)
--[[  debug group
	print("---------------")
	print("droneDetectFlagCheck() parameters:")
	print("drone_flag_check_interval:  " .. drone_flag_check_interval)
	print("drone_note_message_reset_interval:  " .. drone_note_message_reset_interval)
	print("delta: " .. delta)
--]]
	if drone_flag_check_timer == nil then
		drone_flag_check_timer = delta + drone_flag_check_interval
	end
	drone_flag_check_timer = drone_flag_check_timer - delta
--	print("drone_flag_check_timer = drone_flag_check_timer - delta:  " .. drone_flag_check_timer)
	if drone_flag_check_timer < 0 then
		for hfi=1,#human_flags do
			local flag = human_flags[hfi]
			if flag ~= nil and flag:isValid() then
				for _, obj in ipairs(flag:getObjectsInRange(drone_scan_range_for_flags)) do
					if obj.typeName == "CpuShip" then
						if obj.drone then
							if obj.drone_message == nil then
								if difficulty < 1 then	--science officers get messages from all drones
									for pidx=1,32 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
											if p:hasPlayerAtPosition("Science") then
												p:addCustomMessage("Science",drone_message_label,string.format(_("drones-msgScience", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											if p:hasPlayerAtPosition("Operations") then
												drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												p:addCustomMessage("Operations",drone_message_label,string.format(_("drones-msgOperations", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											obj.drone_message = "sent"
											obj.drone_message_stamp = delta
										end	--valid player
									end	--player loop
								elseif difficulty > 1 then	--science officer gets messages from drones launched from their own ship
									for pidx=1,32 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if obj.deployer ~= nil and obj.deployer == p then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format(_("drones-msgScience", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format(_("drones-msgOperations", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--deployer matches player
										end	--valid player
									end	--player loop
								else	--normal difficulty 1: science officers get messages from friendly ships' drones
									for pidx=1,32 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if p:getFaction() == "Kraylor" and obj:getFaction() == "Kraylor" then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format(_("drones-msgScience", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format(_("drones-msgOperations", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--process kraylor player
										end	--valid player
									end	--player loop
								end	--difficulty checks
							else	--drone message sent
								if obj.drone_message_check_counter == nil then
									obj.drone_message_check_counter = 0
								else
									obj.drone_message_check_counter = obj.drone_message_check_counter + 1
									if obj.drone_message_check_counter >= drone_message_reset_count then
										obj.drone_message_check_counter = 0
										obj.drone_message = nil
									end
								end
							end	--drone message not sent
						end	--object is drone
					end	--object is cpu ship
				end	--objects in range loop
			end	--valid flag
		end	--human flags loop	
		for kfi=1,#kraylor_flags do
			local flag = kraylor_flags[kfi]
			if flag ~= nil and flag:isValid() then
				for _, obj in ipairs(flag:getObjectsInRange(5000)) do
					if obj.typeName == "CpuShip" then
						if obj.drone then
							if obj.drone_message == nil then
								if difficulty < 1 then
									for pidx=1,32 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
											if p:hasPlayerAtPosition("Science") then
												p:addCustomMessage("Science",drone_message_label,string.format(_("drones-msgScience", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											if p:hasPlayerAtPosition("Operations") then
												drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												p:addCustomMessage("Operations",drone_message_label,string.format(_("drones-msgOperations", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
											end
											obj.drone_message = "sent"
											obj.drone_message_stamp = delta
										end	--valid player
									end	--player loop
								elseif difficulty > 1 then
									for pidx=1,32 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if obj.deployer ~= nil and obj.deployer == p then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format(_("drones-msgScience", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format(_("drones-msgOperations", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--deployer matches player
										end	--valid player
									end	--player loop
								else	--normal difficulty 1
									for pidx=1,32 do
										p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() then
											if p:getFaction() == "Human Navy" and obj:getFaction() == "Human Navy" then
												local drone_message_label = string.format("scienceDroneNote%s%s",obj:getCallSign(),p:getCallSign())
												if p:hasPlayerAtPosition("Science") then
													p:addCustomMessage("Science",drone_message_label,string.format(_("drones-msgScience", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												if p:hasPlayerAtPosition("Operations") then
													drone_message_label = string.format("operationsDroneNote%s%s",obj:getCallSign(),p:getCallSign())
													p:addCustomMessage("Operations",drone_message_label,string.format(_("drones-msgOperations", "Drone %s in sector %s reports possible flag in sector %s"),obj:getCallSign(),obj:getSectorName(),flag:getSectorName()))
												end
												obj.drone_message = "sent"
												obj.drone_message_stamp = delta
											end	--process human player
										end	--valid player
									end	--player loop
								end	--difficulty checks
							else
								if obj.drone_message_check_counter == nil then
									obj.drone_message_check_counter = 0
								else
									obj.drone_message_check_counter = obj.drone_message_check_counter + 1
									if obj.drone_message_check_counter >= drone_message_reset_count then
										obj.drone_message_check_counter = 0
										obj.drone_message = nil
									end
								end
							end	--drone message not sent
						end	--object is drone
					end	--object is cpu ship
				end	--objects in range loop
			end	--valid flag
		end	--human flags loop
		drone_flag_check_timer = delta + drone_flag_check_interval
	end	--drone flag check timer expiration
end
function buoyBeams(delta)
	buoy_beam_timer = buoy_beam_timer - delta
	if buoy_beam_timer < 0 then
		for i=1,#boundary_items - 2 do
			if i % 4 == buoy_beam_count % 4 then
				BeamEffect():setSource(boundary_items[i],0,0,0):setTarget(boundary_items[i+2],0,0):setDuration(buoy_beam_interval):setRing(false):setTexture(boundary_beam_string[math.random(1,#boundary_beam_string)])
				if i < 3 then
					if stationZebra ~= nil and stationZebra:isValid() then
						BeamEffect():setSource(boundary_items[i],0,0,0):setTarget(stationZebra,0,0):setDuration(buoy_beam_interval):setRing(false):setTexture(boundary_beam_string[math.random(1,#boundary_beam_string)])
					end
				end
			end
		end
		buoy_beam_timer = buoy_beam_interval
		buoy_beam_count = buoy_beam_count + 1
	end
end

 -- ***********************************************************************************
function update(delta)
	if boundary_marker == "buoys" then
		buoyBeams(delta)
	end
	if delta == 0 then
		manageAddingNewPlayerShips()
		return
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		timeDivision = "victory-exuari"
		victory("Exuari")
	end
--	print(string.format("Max game time: %i, Hide flag time: %i, Game time limit: %.1f",maxGameTime,hideFlagTime,gameTimeLimit))
	if gameTimeLimit < (maxGameTime - hideFlagTime - 1) then	--1499
		--hunt begins
		manageHuntPhaseMechanics()
		if dronesAreAllowed then
			droneDetectFlagCheck(delta)
		end
	elseif gameTimeLimit < (maxGameTime - hideFlagTime) then		--1500
		--transition from preparation/hiding flags phase to hunt phase
		transitionFromPreparationToHunt()
	else
		--prepare (place flags)
		placeFlagsPhase()
	end
	if dynamicTerrain ~= nil then
		dynamicTerrain(delta)
	end
	healthCheck(delta)
	for pidx=1,32 do
		local p5 = getPlayerShip(pidx)
		if p5 ~= nil and p5:isValid() then
			local name_tag_text = string.format(_("-tabHelms&Tactical&Singlepilot", "%s in %s"),p5:getCallSign(),p5:getSectorName())
			if p5:hasPlayerAtPosition("Helms") then
				p5.name_tag_helm = "name_tag_helm"
				p5:addCustomInfo("Helms",p5.name_tag_helm,name_tag_text)
			end
			if p5:hasPlayerAtPosition("Tactical") then
				p5.name_tag_helm_tac = "name_tag_helm_tac"
				p5:addCustomInfo("Tactical",p5.name_tag_helm_tac,name_tag_text)
			end
			if p5:hasPlayerAtPosition("SinglePilot") then
				p5.name_tag_helm_single = "name_tag_helm_single"
				p5:addCustomInfo("SinglePilot",p5.name_tag_helm_single,name_tag_text)
			end
		end
	end
	marauderWaves(delta)
	-- print("delta: " .. delta)
end