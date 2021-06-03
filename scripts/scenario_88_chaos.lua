-- Name: Chaos of War
-- Description: Two, three or four species battle for ultimate dominion. Designed as a replayable player versus player (PVP) scenario for individuals or teams. Terrain is randomly symmetrically generated for every game. Use GM screen to adjust parameters
---
--- Version 1 (debuted 23Jan2021 for online event)
-- Type: Player vs Player with or without teams
-- Variation[Easy]: More resources, services and reputation
-- Variation[Hard]: Fewer resources, services and reputation

--------------------------------------------------------------------------------------------------------
--	Note: This script requires a version of supply_drop.lua that handles the variable jump_freighter  --
--			See pull request 1185                                                                     --
--------------------------------------------------------------------------------------------------------

require "utils.lua"

function init()
	scenario_version = "1.0.1"
	print(string.format("Scenario version %s",scenario_version))
	print(_VERSION)
	setVariations()
	setConstants()
	setStaticScienceDatabase()
	setGMButtons()
end
function setVariations()
	local svs = getScenarioVariation()	--scenario variation string
	if string.find(svs,"Easy") then
		difficulty = .5
		base_reputation = 50
	elseif string.find(svs,"Hard") then
		difficulty = 2
		base_reputation = 10
	else
		difficulty = 1		--default (normal)
		base_reputation = 20
	end
end
function setConstants()
	thresh = .2		--leading/trailing completion threshold percentage for game
	game_time_limit = 45*60	-- Time limit for game; measured in seconds (example: 45*60 = 45 minutes)
	max_game_time = game_time_limit	
	game_state = "paused"	--then moves to "terrain generated" then to "running"
	respawn_count = 0
	respawn_type = "lindworm"
	storage = getScriptStorage()
	storage.gatherStats = gatherStats
	player_team_count = 2	--default to 2. Can be 2, 3 or 4
	ships_per_team = 2		--default to 2. Max varies based on team count
	max_ships_per_team = {32,16,10,8}	--engine supports 32 player ships
	f2s = {	--faction name to short name
		["Human Navy"] = "human",
		["Kraylor"] = "kraylor",
		["Exuari"] = "exuari",
		["Ktlitans"] = "ktlitan",
	}
	terrain_generated = false
	generate_terrain_message_counter = 0
	missile_availability = "unlimited"
	defense_platform_count_index = 10
	defense_platform_count_options = {
		{count = 0, distance = 0,		player = 4500},
		{count = 3, distance = 2000,	player = 2500},
		{count = 4, distance = 2400,	player = 3000},
		{count = 5, distance = 3000,	player = 3500},
		{count = 6, distance = 4300,	player = 2500},
		{count = 8, distance = 7000,	player = 4000},
		{count = 9, distance = 7800,	player = 4500},
		{count = 10, distance = 9000,	player = 4000},
		{count = 12, distance = 10000,	player = 4500},
		{count = "random", distance = 0,	player = 0},
	}
	dp_comms_data = {	--defense platform comms data
		weapon_available = 	{
			Homing =			random(1,13)<=(3-difficulty),
			HVLI =				random(1,13)<=(6-difficulty),
			Mine =				false,
			Nuke =				false,
			EMP =				false,
		},
		services = {
			supplydrop = "friend",
			reinforcements = "friend",
			jumpsupplydrop = "friend",
		},
		service_cost = {
			supplydrop =		math.random(80,120), 
			reinforcements =	math.random(125,175),
			jumpsupplydrop =	math.random(110,140),
		},
        jump_overcharge =		false,
        probe_launch_repair =	random(1,13)<=(3-difficulty),
        hack_repair =			random(1,13)<=(3-difficulty),
        scan_repair =			random(1,13)<=(3-difficulty),
        combat_maneuver_repair=	random(1,13)<=(3-difficulty),
        self_destruct_repair =	random(1,13)<=(3-difficulty),
        tube_slow_down_repair =	random(1,13)<=(3-difficulty),
		reputation_cost_multipliers = {
			friend = 			1.0, 
			neutral = 			3.0,
		},
		goods = {},
		trade = {},
	}
	defense_fleet_list = {
		["Small Station"] = {
			{DF1 = "MT52 Hornet",DF2 = "MU52 Hornet",DF3 = "MT52 Hornet",DF4 = "MU52 Hornet",},
			{DF1 = "MT52 Hornet",DF2 = "MT52 Hornet",DF3 = "MT52 Hornet",DF4 = "MU52 Hornet",},
			{DF1 = "MT52 Hornet",DF2 = "MU52 Hornet",DF3 = "MU52 Hornet",DF4 = "Nirvana R5A",},
    	},
		["Medium Station"] = {
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "MT52 Hornet",DF4 = "Adder MK4",DF5 = "Adder MK6",},
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "Nirvana R5A",DF4 = "Adder MK4",DF5 = "Adder MK6",},
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "Nirvana R5A",DF4 = "WX-Lindworm",DF5 = "Adder MK6",},
		},
		["Large Station"] = {
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "MT52 Hornet",DF4 = "Adder MK4",DF5 = "Adder MK6",DF6 = "Phobos T3",DF7 = "Adder MK7",DF8 = "Adder MK8",},
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "Adder MK9",DF4 = "Adder MK4",DF5 = "Adder MK6",DF6 = "Phobos T3",DF7 = "Adder MK7",DF8 = "Adder MK8",},
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "Nirvana R5A",DF4 = "Adder MK4",DF5 = "Adder MK6",DF6 = "Phobos T3",DF7 = "Adder MK7",DF8 = "Adder MK8",},
		},
		["Huge Station"] = {
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "MT52 Hornet",DF4 = "Adder MK4",DF5 = "Adder MK6",DF6 = "Phobos T3",DF7 = "Adder MK7",DF8 = "Adder MK8",DF9 = "Fiend G4",DF10 = "Stalker R7",DF11 = "Stalker Q7"},
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "Nirvana R5A",DF4 = "Adder MK4",DF5 = "Adder MK6",DF6 = "Phobos T3",DF7 = "Adder MK7",DF8 = "Adder MK8",DF9 = "Fiend G4",DF10 = "Stalker R7",DF11 = "Stalker Q7"},
			{DF1 = "Adder MK5",DF2 = "MU52 Hornet",DF3 = "Phobos T3",DF4 = "Adder MK4",DF5 = "Adder MK6",DF6 = "Phobos T3",DF7 = "Adder MK7",DF8 = "Adder MK8",DF9 = "Fiend G4",DF10 = "Stalker R7",DF11 = "Stalker Q7"},
		},
	}
	station_list = {}
	station_sensor_range = 20000
	primary_station_size_index = 1
	primary_station_size_options = {"random","Small Station","Medium Station","Large Station","Huge Station"}
	primary_jammers = "random"
	player_ship_types = "default"
	custom_player_ship_type = "Heavy"
	default_player_ship_sets = {
		{"Crucible"},
		{"Maverick","Flavia P.Falcon"},
		{"Atlantis","Phobos M3P","Crucible"},
		{"Atlantis","Maverick","Phobos M3P","Flavia P.Falcon"},
		{"Atlantis","Player Cruiser","Maverick","Crucible","Phobos M3P"},
		{"Atlantis","Hathcock","Flavia P.Falcon","Player Missile Cr.","Maverick","Phobos M3P"},
		{"Atlantis","Repulse","Maverick","Player Missile Cr.","Phobos M3P","Flavia P.Falcon","Crucible"},
		{"Atlantis","Player Cruiser","Hathcock","Player Fighter","Phobos M3P","Maverick","Crucible","Flavia P.Falcon"},
		{"Atlantis","Player Cruiser","Repulse","Player Missile Cr.","Player Fighter","Phobos M3P","Crucible","Flavia P.Falcon","Maverick"},
		{"Atlantis","Player Cruiser","Piranha","Player Missile Cr.","Player Fighter","Phobos M3P","Crucible","Flavia P.Falcon","Maverick","Phobos M3P"},
		{"Atlantis","Player Cruiser","Hathcock","Repulse","Player Fighter","Player Missile Cr.","Crucible","Flavia P.Falcon","Maverick","Phobos M3P","Flavia P.Falcon"},
		{"Atlantis","Player Cruiser","Piranha","Repulse","Player Fighter","Player Missile Cr.","Crucible","Flavia P.Falcon","Maverick","Phobos M3P","Flavia P.Falcon","Phobos M3P"},
		{"Atlantis","Player Cruiser","Piranha","Hathcock","Player Fighter","Player Missile Cr.","Crucible","Flavia P.Falcon","Maverick","Phobos M3P","Flavia P.Falcon","Phobos M3P","Crucible"},
		{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Player Missile Cr.","Crucible","Flavia P.Falcon","Maverick","Phobos M3P","Flavia P.Falcon","Phobos M3P","Crucible","Player Fighter"},
		{"Atlantis","Player Cruiser","Hathcock","Repulse","Nautilus","Player Missile Cr.","Crucible","Flavia P.Falcon","Maverick","Phobos M3P","Flavia P.Falcon","Phobos M3P","Crucible","Player Fighter","MP52 Hornet"},
		{"Atlantis","Player Cruiser","Nautilus","Repulse","Piranha","Player Missile Cr.","Crucible","Flavia P.Falcon","Maverick","Phobos M3P","Flavia P.Falcon","Phobos M3P","Crucible","Player Fighter","MP52 Hornet","Maverick"},
	}
	custom_player_ship_sets = {
		["Jump"] = {
			{"Atlantis"},
			{"Atlantis","Player Cruiser"},
			{"Atlantis","Player Cruiser","Hathcock"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis","Nautilus"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis","Nautilus","Hathcock"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis","Nautilus","Hathcock","Atlantis"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis","Nautilus","Hathcock","Atlantis","Player Cruiser"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis","Nautilus","Hathcock","Atlantis","Player Cruiser","Piranha"},
			{"Atlantis","Player Cruiser","Hathcock","Repulse","Piranha","Nautilus","Repulse","Player Cruiser","Piranha","Atlantis","Nautilus","Hathcock","Atlantis","Player Cruiser","Piranha","Hathcock"},
		},
		["Warp"] = {
			{"Crucible"},
			{"Crucible","Maverick"},
			{"Crucible","Maverick","Phobos M3P"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr."},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet","Player Missile Cr."},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet","Player Missile Cr.","Flavia P.Falcon"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet","Player Missile Cr.","Flavia P.Falcon","Player Missile Cr."},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet","Player Missile Cr.","Flavia P.Falcon","Player Missile Cr.","Maverick"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet","Player Missile Cr.","Flavia P.Falcon","Player Missile Cr.","Maverick","Crucible"},
			{"Crucible","Maverick","Phobos M3P","Flavia P.Falcon","MP52 Hornet","Player Missile Cr.","Maverick","Phobos M3P","Crucible","MP52 Hornet","Player Missile Cr.","Flavia P.Falcon","Player Missile Cr.","Maverick","Crucible","Phobos M3P"},
		},
		["Heavy"] = {
			{"Maverick"},
			{"Maverick","Crucible"},
			{"Maverick","Crucible","Atlantis"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr."},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr."},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible","Player Cruiser"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible","Player Cruiser","Piranha"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible","Player Cruiser","Piranha","Crucible"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible","Player Cruiser","Piranha","Crucible","Atlantis"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible","Player Cruiser","Piranha","Crucible","Atlantis","Maverick"},
			{"Maverick","Crucible","Atlantis","Player Missile Cr.","Player Cruiser","Piranha","Maverick","Player Missile Cr.","Atlantis","Crucible","Player Cruiser","Piranha","Crucible","Atlantis","Maverick","Player Missile Cr."},
		},
		["Light"] = {
			{"Phobos M3P"},
			{"Phobos M3P","MP52 Hornet"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse","Hathcock"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse","Hathcock","Nautilus"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon","Phobos M3P"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon","Phobos M3P","MP52 Hornet"},
			{"Phobos M3P","MP52 Hornet","Flavia P.Falcon","Hathcock","Nautilus","Repulse","Flavia P. Falcon","MP52 Hornet","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon","Phobos M3P","MP52 Hornet","Repulse"},
		},
		["Custom"] = {
			{"Holmes"},
			{"Holmes","Phobos T2"},
			{"Holmes","Phobos T2","Striker LX"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse","Hathcock"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse","Hathcock","Nautilus"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon","Phobos M3P"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon","Phobos M3P","MP52 Hornet"},
			{"Holmes","Phobos T2","Striker LX","Maverick XP","Focus","Repulse","Flavia P. Falcon","Player Fighter","Phobos M3P","Repulse","Hathcock","Nautilus","Flavia P. Falcon","Phobos M3P","MP52 Hornet","Repulse"},
		}
	}
	rwc_player_ship_names = {	--rwc: random within category
		["Atlantis"] = {"Formidable","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Benedict"] = {"Elizabeth","Ford","Avenger","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Fett", "Hawkeye", "Hanzo"},
		["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"},
		["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"},
		["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Player Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Player Missile Cr."] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["ZX-Lindworm"]	= {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Unknown"] = {"Foregone","Righteous","Masher","Lancer","Horizon","Osiris","Athena","Poseidon","Heracles","Constitution","Stargazer","Horatio","Socrates","Galileo","Newton","Beethoven","Rabin","Spector","Akira","Thunderchild","Ambassador","Adelphi","Exeter","Ghandi","Valdemar","Yamaguchi","Zhukov","Andromeda","Drake","Prokofiev","Antares","Apollo","Ajax","Clement","Bradbury","Gage","Buran","Kearsarge","Cheyenne","Ahwahnee","Constellation","Gettysburg","Hathaway","Magellan","Farragut","Kongo","Lexington","Potempkin","Yorktown","Daedalus","Archon","Carolina","Essex","Danube","Gander","Ganges","Mekong","Orinoco","Rubicon","Shenandoah","Volga","Yangtzee Kiang","Yukon","Valiant","Deneva","Arcos","LaSalle","Al-Batani","Cairo","Charlseton","Crazy Horse","Crockett","Fearless","Fredrickson","Gorkon","Hood","Lakota","Malinche","Melbourne","Freedom","Concorde","Firebrand","Galaxy","Challenger","Odyssey","Trinculo","Venture","Yamato","Hokule'a","Tripoli","Hope","Nobel","Pasteur","Bellerophon","Voyager","Istanbul","Constantinople","Havana","Sarajevo","Korolev","Goddard","Luna","Titan","Mediterranean","Lalo","Wyoming","Merced","Trieste","Miranda","Brattain","Helin","Lantree","Majestic","Reliant","Saratoga","ShirKahr","Sitak","Tian An Men","Trial","Nebula","Bonchune","Capricorn","Hera","Honshu","Interceptor","Leeds","Merrimack","Prometheus","Proxima","Sutherland","T'Kumbra","Ulysses","New Orleans","Kyushu","Renegade","Rutledge","Thomas Paine","Niagra","Princeton","Wellington","Norway","Budapest","Nova","Equinox","Rhode Island","Columbia","Oberth","Biko","Cochraine","Copernicus","Grissom","Pegasus","Raman","Yosemite","Renaissance","Aries","Maryland","Rigel","Akagi","Tolstoy","Yeager","Sequoia","Sovereign","Soyuz","Bozeman","Springfield","Chekov","Steamrunner","Appalachia","Surak","Zapata","Sydney","Jenolen","Nash","Wambundu","Fleming","Wells","Relativity","Yorkshire","Denver","Zodiac","Centaur","Cortez","Republic","Peregrine","Calypso","Cousteau","Waverider","Scimitar"},
	}
	player_ship_stats = {	
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 10,	long_jump = 50,	short_jump = 5,		warp = 0,		stock = true,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 10,	long_jump = 90,	short_jump = 5,		warp = 0,		stock = true,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, probes = 9,		long_jump = 0,	short_jump = 0,		warp = 750,		stock = true,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, probes = 12,	long_jump = 50,	short_jump = 5,		warp = 0,		stock = true,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, probes = 8,		long_jump = 0,	short_jump = 0,		warp = 500,		stock = true,	},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 8,		long_jump = 60,	short_jump = 6,		warp = 0,		stock = true,	},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000, probes = 10,	long_jump = 0,	short_jump = 0,		warp = 750,		stock = true,	},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 9,		long_jump = 0,	short_jump = 0,		warp = 800,		stock = true,	},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000, probes = 5,		long_jump = 0,	short_jump = 0,		warp = 1000,	stock = true,	},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000, probes = 10,	long_jump = 70,	short_jump = 5,		warp = 0,		stock = true,	},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 6,		long_jump = 0,	short_jump = 0,		warp = 900,		stock = true,	},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000, probes = 6,		long_jump = 50,	short_jump = 5,		warp = 0,		stock = true,	},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, probes = 10,	long_jump = 80,	short_jump = 5,		warp = 0,		stock = true,	},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000, probes = 9,		long_jump = 0,	short_jump = 0,		warp = 800,		stock = true,	},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500, probes = 4,		long_jump = 40,	short_jump = 3,		warp = 0,		stock = true,	},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, probes = 8,		long_jump = 50,	short_jump = 5,		warp = 0,		stock = true,	},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000, probes = 6,		long_jump = 40,	short_jump = 3,		warp = 0,		stock = true,	},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500, probes = 4,		long_jump = 0,	short_jump = 0,		warp = 950,		stock = true,	},
	--	Stock above, custom below	
		["Focus"]				= { strength = 35,	cargo = 4,	distance = 200,	long_range_radar = 32000, short_range_radar = 5000, probes = 8,		long_jump = 25,	short_jump = 2.5,	warp = 0,		stock = false,	},
		["Holmes"]				= { strength = 35,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 4000, probes = 8,		long_jump = 0,	short_jump = 0,		warp = 750,		stock = false,	},
		["Maverick XP"]			= { strength = 23,	cargo = 5,	distance = 200,	long_range_radar = 25000, short_range_radar = 7000, probes = 10,	long_jump = 20,	short_jump = 2,		warp = 0,		stock = false,	},
		["Phobos T2"]			= { strength = 19,	cargo = 9,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000, probes = 5,		long_jump = 25,	short_jump = 2,		warp = 0,		stock = false,	},
		["Striker LX"]			= { strength = 16,	cargo = 4,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000, probes = 7,		long_jump = 20,	short_jump = 2,		warp = 0,		stock = false,	},
	}		
	npc_ships = false
	npc_lower = 30
	npc_upper = 60
	scientist_list = {}
	scientist_count = 0
	scientist_score_value = 10
	scientist_names = {	--fictional
		"Gertrude Goodall",
		"John Kruger",
		"Lisa Forsythe",
		"Ethan Williams",
		"Ameilia Martinez",
		"Felix Mertens",
		"Marie Novak",
		"Mathias Evans",
		"Clara Heikkinen",
		"Vicente Martin",
		"Catalina Fischer",
		"Marek Varga",
		"Ewa Olsen",
		"Oscar Stewart",
		"Alva Rodriguez",
		"Aiden Johansson",
		"Zoey Smith",
		"Jorge Romero",
		"Rosa Wong",
		"Julian Acharya",
		"Hannah Ginting",
		"Anton Dewala",
		"Camille Silva",
		"Aleksi Gideon",
		"Ella Dasgupta",
		"Gunnar Smirnov",
		"Telma Lozano",
		"Kaito Fabroa",
		"Misaki Kapia",
		"Ronald Sanada",
		"Janice Tesfaye",
		"Alvaro Hassan",
		"Valeria Dinh",
		"Sergei Mokri",
		"Yulia Karga",
		"Arnav Dixon",
		"Sanvi Saetan",
	}
	scientist_topics = {
		"Mathematics",
		"Miniaturization",
		"Exotic materials",
		"Warp theory",
		"Particle theory",
		"Power systems",
		"Energy fields",
		"Subatomic physics",
		"Stellar phenomena",
		"Gravity dynamics",
		"Information science",
		"Computer protocols",
	}
	upgrade_requirements = {
		"talk",			--talk
		"talk primary",	--talk then upgrade at primary station
		"meet",			--meet
		"meet primary",	--meet then upgrade at primary station
		"transport",	--transport to primary station
		"confer",		--transport to primary station, then confer with another scientist
	}
	upgrade_list = {
		{action = hullStrengthUpgrade, name = "hull strength upgrade"},
		{action = shieldStrengthUpgrade, name = "shield strength upgrade"},
		{action = missileLoadSpeedUpgrade, name = "missile load speed upgrade"},
		{action = beamDamageUpgrade, name = "beam damage upgrade"},
		{action = beamRangeUpgrade, name = "beam range upgrade"},
		{action = batteryEfficiencyUpgrade, name = "battery efficiency upgrade"},
		{action = fasterImpulseUpgrade, name = "faster impulse upgrade"},
		{action = longerSensorsUpgrade, name = "longer sensor range upgrade"},
		{action = fasterSpinUpgrade, name = "faster maneuvering speed upgrade"},
	}
	upgrade_automated_applications = {
		"single",	--automatically applied only to the player that completed the requirements
		"players",	--automatically applied to allied players
		"all",		--automatically applied to players and NPCs (where applicable)
	}
	prefix_length = 0
	suffix_index = 0
	formation_delta = {
		["square"] = {
			x = {0,1,0,-1, 0,1,-1, 1,-1,2,0,-2, 0,2,-2, 2,-2,2, 2,-2,-2,1,-1, 1,-1,0, 0,3,-3,1, 1,3,-3,-1,-1, 3,-3,2, 2,3,-3,-2,-2, 3,-3,3, 3,-3,-3,4,0,-4, 0,4,-4, 4,-4,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,5,-5,0, 0,5, 5,-5,-5,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4},
			y = {0,0,1, 0,-1,1,-1,-1, 1,0,2, 0,-2,2,-2,-2, 2,1,-1, 1,-1,2, 2,-2,-2,3,-3,0, 0,3,-3,1, 1, 3,-3,-1,-1,3,-3,2, 2, 3,-3,-2,-2,3,-3, 3,-3,0,4, 0,-4,4,-4,-4, 4, 1,-1, 2,-2, 3,-3,1,-1,2,-2,3,-3,-4,-4,-4,-4,-4,-4,4, 4,4, 4,4, 4,0, 0,5,-5,5,-5, 5,-5, 1,-1, 2,-2, 3,-3, 4,-4,1,-1,2,-2,3,-3,4,-4,-5,-5,-5,-5,-5,-5,-5,-5,5, 5,5, 5,5, 5,5, 5},
		},
		["hexagonal"] = {
			x = {0,2,-2,1,-1, 1,-1,4,-4,0, 0,2,-2,-2, 2,3,-3, 3,-3,6,-6,1,-1, 1,-1,3,-3, 3,-3,4,-4, 4,-4,5,-5, 5,-5,8,-8,4,-4, 4,-4,5,5 ,-5,-5,2, 2,-2,-2,0, 0,6, 6,-6,-6,7, 7,-7,-7,10,-10,5, 5,-5,-5,6, 6,-6,-6,7, 7,-7,-7,8, 8,-8,-8,9, 9,-9,-9,3, 3,-3,-3,1, 1,-1,-1,12,-12,6,-6, 6,-6,7,-7, 7,-7,8,-8, 8,-8,9,-9, 9,-9,10,-10,10,-10,11,-11,11,-11,4,-4, 4,-4,2,-2, 2,-2,0, 0},
			y = {0,0, 0,1, 1,-1,-1,0, 0,2,-2,2,-2, 2,-2,1,-1,-1, 1,0, 0,3, 3,-3,-3,3,-3,-3, 3,2,-2,-2, 2,1,-1,-1, 1,0, 0,4,-4,-4, 4,3,-3, 3,-3,4,-4, 4,-4,4,-4,2,-2, 2,-2,1,-1, 1,-1, 0,  0,5,-5, 5,-5,4,-4, 4,-4,3,-3, 3,-7,2,-2, 2,-2,1,-1, 1,-1,5,-5, 5,-5,5,-5, 5,-5, 0,  0,6, 6,-6,-6,5, 5,-5,-5,4, 4,-4,-4,3, 3,-3,-3, 2,  2,-2, -2, 1,  1,-1, -1,6, 6,-6,-6,6, 6,-6,-6,6,-6},
		},
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
		["Gnat"] =				{strength = 2,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true,		drone = true,	unusual = false,	base = false,	create = gnat},
		["Lite Drone"] =		{strength = 3,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = true,	unusual = false,	base = false,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = hornetMV52},
		["Adder MK4"] =			{strength = 6,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = k3fighter},
		["Adder MK6"] =			{strength = 8,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	adder = false,	missiler = true,	beamer = false,	frigate = false,	chaser = false,	fighter = true, 	drone = false,	unusual = false,	base = false,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Adder MK8"] =			{strength = 10,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = waddle5},
		["Jade 5"] =			{strength = 15,	adder = true,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = jade5},
		["Phobos T3"] =			{strength = 15,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Farco 3"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = farco3},
		["Farco 5"] =			{strength = 16,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = farco5},
		["Karnack"] =			{strength = 17,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Gunship"] =			{strength = 17,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Phobos T4"] =			{strength = 18,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = phobosT4},
		["Cruiser"] =			{strength = 18,	adder = true,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Farco 8"] =			{strength = 19,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = farco8},
		["Ktlitan Worker"] =	{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Nirvana R5A"] =		{strength = 20,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,	adder = false,	missiler = false,	beamer = false,	frigate = true,		chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Farco 11"] =			{strength = 21,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = farco11},
		["Storm"] =				{strength = 22,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Farco 13"] =			{strength = 24,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = farco13},
		["Ranus U"] =			{strength = 25,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Whirlwind"] =			{strength = 26,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = whirlwind},
		["Adv. Striker"] =		{strength = 27,	adder = false,	missiler = false,	beamer = true,	frigate = true,		chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Elara P2"] =			{strength = 28,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = tempest},
		["Strikeship"] =		{strength = 30,	adder = false,	missiler = false,	beamer = true,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Fiend G4"] =			{strength = 35,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Cucaracha"] =			{strength = 36,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = cucaracha},
		["Fiend G5"] =			{strength = 37,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Fiend G6"] =			{strength = 39,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Predator"] =			{strength = 42,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Hurricane"] =			{strength = 46,	adder = false,	missiler = true,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = k2breaker},
		["Ktlitan Destroyer"] =	{strength = 50,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Atlantis Y42"] =		{strength = 60,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 65,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	adder = false,	missiler = false,	beamer = false,	frigate = true, 	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = false,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Starhammer III"] =	{strength = 85,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = starhammerIII},
		["Starhammer V"] =		{strength = 90,	adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = starhammerV},
		["Battlestation"] =		{strength = 100,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
		["Tyr"] =				{strength = 150,adder = false,	missiler = false,	beamer = true,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = tyr},
		["Odin"] =				{strength = 250,adder = false,	missiler = false,	beamer = false,	frigate = false,	chaser = true,	fighter = false,	drone = false,	unusual = false,	base = false,	create = stockTemplate},
	}	
	control_code_stem = {	--All control codes must use capital letters or they will not work.
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
		"STREET",
		"TOKEN",
		"THIRSTY",
		"UNDER",
		"VANISH",
		"WHITE",
		"WRENCH",
		"YELLOW",
	}
	healthCheckTimerInterval = 10
	healthCheckTimer = healthCheckTimerInterval
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}	
end
function setStaticScienceDatabase()
--------------------------------------------------------------------------------------
--	Generic station descriptions: text and details from shipTemplates_stations.lua  --
--------------------------------------------------------------------------------------
	local station_db = queryScienceDatabase("Stations")
	if station_db == nil then
		station_db = ScienceDatabase():setName("Stations")
		station_db:setLongDescription("Stations are places for ships to dock, get repaired and replenished, interact with station personnel, etc. They are like oases, service stations, villages, towns, cities, etc.")
		station_db:addEntry("Small")
		local small_station_db = queryScienceDatabase("Stations","Small")
		small_station_db:setLongDescription("Stations of this size are often used as research outposts, listening stations, and security checkpoints. Crews turn over frequently in a small station's cramped accommodatations, but they are small enough to look like ships on many long-range sensors, and organized raiders sometimes take advantage of this by placing small stations in nebulae to serve as raiding bases. They are lightly shielded and vulnerable to swarming assaults.")
		small_station_db:setImage("radartrace_smallstation.png")
		small_station_db:setKeyValue("Class","Small")
		small_station_db:setKeyValue("Size",300)
		small_station_db:setKeyValue("Shield",300)
		small_station_db:setKeyValue("Hull",150)
		station_db:addEntry("Medium")
		local medium_station_db = queryScienceDatabase("Stations","Medium")
		medium_station_db:setLongDescription("Large enough to accommodate small crews for extended periods of times, stations of this size are often trading posts, refuelling bases, mining operations, and forward military bases. While their shields are strong, concerted attacks by many ships can bring them down quickly.")
		medium_station_db:setImage("radartrace_mediumstation.png")
		medium_station_db:setKeyValue("Class","Medium")
		medium_station_db:setKeyValue("Size",1000)
		medium_station_db:setKeyValue("Shield",800)
		medium_station_db:setKeyValue("Hull",400)
		station_db:addEntry("Large")
		local large_station_db = queryScienceDatabase("Stations","Large")
		large_station_db:setLongDescription("These spaceborne communities often represent permanent bases in a sector. Stations of this size can be military installations, commercial hubs, deep-space settlements, and small shipyards. Only a concentrated attack can penetrate a large station's shields, and its hull can withstand all but the most powerful weaponry.")
		large_station_db:setImage("radartrace_largestation.png")
		large_station_db:setKeyValue("Class","Large")
		large_station_db:setKeyValue("Size",1300)
		large_station_db:setKeyValue("Shield","1000/1000/1000")
		large_station_db:setKeyValue("Hull",500)
		station_db:addEntry("Huge")
		local huge_station_db = queryScienceDatabase("Stations","Huge")
		huge_station_db:setLongDescription("The size of a sprawling town, stations at this scale represent a faction's center of spaceborne power in a region. They serve many functions at once and represent an extensive investment of time, money, and labor. A huge station's shields and thick hull can keep it intact long enough for reinforcements to arrive, even when faced with an ongoing siege or massive, perfectly coordinated assault.")
		huge_station_db:setImage("radartrace_hugestation.png")
		huge_station_db:setKeyValue("Class","Huge")
		huge_station_db:setKeyValue("Size",1500)
		huge_station_db:setKeyValue("Shield","1200/1200/1200/1200")
		huge_station_db:setKeyValue("Hull",800)
	end
-----------------------------------------------------------------------------------
--	Template ship category descriptions: text from other shipTemplates... files  --
-----------------------------------------------------------------------------------
	local ships_db = queryScienceDatabase("Ships")
	local fighter_db = queryScienceDatabase("Ships","Starfighter")
	local generic_starfighter_description = "Starfighters are single to 3 person small ships. These are most commonly used as light firepower roles.\nThey are common in larger groups, and need a close by station or support ship, as they lack long time life support.\nIt's rare to see starfighters with more then one shield section.\n\nOne of the most well known starfighters is the X-Wing.\n\nStarfighters come in 3 subclasses:\n* Interceptors: Fast, low on firepower, high on manouverability\n* Gunship: Equipped with more weapons, but trades in manouverability because of it.\n* Bomber: Slowest of all starfighters, but pack a large punch in a small package. Usually come without any lasers, but the largers bombers have been known to deliver nukes."
	fighter_db:setLongDescription(generic_starfighter_description)
	local frigate_db = queryScienceDatabase("Ships","Frigate")
	local generic_frigate_description = "Frigates are one size up from starfighters. They require a crew from 3 to 20 people.\nThink, Firefly, millennium falcon, slave I (Boba fett's ship).\n\nThey generally have 2 or more shield sections, but hardly ever more than 4.\n\nThis class of ships is normally not fitted with jump or warp drives. But in some cases ships are modified to include these, or for certain roles it is built in.\n\nThey are divided in 3 different sub-classes:\n* Cruiser: Weaponized frigates, focused on combat. These come in various roles.\n* Light transport: Small transports, like transporting up to 50 soldiers in spartan conditions or a few diplomats in luxury. Depending on the role it can have some weaponry.\n* Support: Support types come in many varieties. They are simply a frigate hull fitted with whatever was needed. Anything from mine-layers to science vessels."
	frigate_db:setLongDescription(generic_frigate_description)
	local corvette_db = queryScienceDatabase("Ships","Corvette")
	local generic_corvette_description = "Corvettes are the common large ships. Larger then a frigate, smaller then a dreadnaught.\nThey generally have 4 or more shield sections. Run with a crew of 20 to 250.\nThis class generally has jumpdrives or warpdrives. But lack the maneuverability that is seen in frigates.\n\nThey come in 3 different subclasses:\n* Destroyer: Combat oriented ships. No science, no transport. Just death in a large package.\n* Support: Large scale support roles. Drone carriers fall in this category, as well as mobile repair centers.\n* Freighter: Large scale transport ships. Most common here are the jump freighters, using specialized jumpdrives to cross large distances with large amounts of cargo."
	corvette_db:setLongDescription(generic_corvette_description)
	local dreadnought_db = queryScienceDatabase("Ships","Dreadnought")
	dreadnought_db:setLongDescription("Dreadnoughts are the largest ships.\nThey are so large and uncommon that every type is pretty much their own subclass.\nThey usually come with 6 or more shield sections, require a crew of 250+ to operate.\n\nThink: Stardestroyer.")
--------------------------
--	Stock player ships  --
--------------------------
	local stock_db = ships_db:addEntry("Mainstream")
	stock_db = queryScienceDatabase("Ships","Mainstream")
	stock_db:setLongDescription("Mainstream ships are those ship types that are commonly available to crews serving on the front lines or in well established areas")
----	Starfighters
	local fighter_stock_db = stock_db:addEntry("Starfighter")
	fighter_stock_db:setLongDescription(generic_starfighter_description)
--	MP52 Hornet
	fighter_stock_db:addEntry("MP52 Hornet")
	local mp52_hornet_db = queryScienceDatabase("Ships","Mainstream","Starfighter","MP52 Hornet")
	mp52_hornet_db:setLongDescription("The MP52 Hornet is a significantly upgraded version of MU52 Hornet, with nearly twice the hull strength, nearly three times the shielding, better acceleration, impulse boosters, and a second laser cannon.")
	mp52_hornet_db:setKeyValue("Class","Starfighter")
	mp52_hornet_db:setKeyValue("Sub-class","Interceptor")
	mp52_hornet_db:setKeyValue("Size","30")
	mp52_hornet_db:setKeyValue("Shield","60")
	mp52_hornet_db:setKeyValue("Hull","70")
	mp52_hornet_db:setKeyValue("Repair Crew",1)
	mp52_hornet_db:setKeyValue("Warp Speed","60 U/min")	--1000 (added for scenario)
	mp52_hornet_db:setKeyValue("Battery Capacity",400)
	mp52_hornet_db:setKeyValue("Sensor Ranges","Long: 18 U / Short: 4 U")
	mp52_hornet_db:setKeyValue("Move speed","7.5 U/min")	--125	(value * 60 / 1000 = units per minute)
	mp52_hornet_db:setKeyValue("Turn speed","32 deg/sec")
	mp52_hornet_db:setKeyValue("Beam weapon 355:30","Rng:.9 Dmg:2.5 Cyc:4")
	mp52_hornet_db:setKeyValue("Beam weapon 5:30","Rng:.9 Dmg:2.5 Cyc:4")
	mp52_hornet_db:setImage("radar_fighter.png")
--	Player Fighter
	fighter_stock_db:addEntry("Player Fighter")
	local player_fighter_db = queryScienceDatabase("Ships","Mainstream","Starfighter","Player Fighter")
	player_fighter_db:setLongDescription("A fairly standard fighter with strong beams and a tube for HVLIs. The sensors aren't that great, but it often has a warp drive bolted on making it extraordinarily fast")
	player_fighter_db:setKeyValue("Class","Starfighter")
	player_fighter_db:setKeyValue("Size","40")
	player_fighter_db:setKeyValue("Shield","40")
	player_fighter_db:setKeyValue("Hull","60")
	player_fighter_db:setKeyValue("Repair Crew",3)
	player_fighter_db:setKeyValue("Warp Speed","60 U/min")	--1000 (added for scenario)
	player_fighter_db:setKeyValue("Battery Capacity",400)
	player_fighter_db:setKeyValue("Sensor Ranges","Long: 15 U / Short: 4.5 U")
	player_fighter_db:setKeyValue("Move speed","6.6 U/min")	--110	(value * 60 / 1000 = units per minute)
	player_fighter_db:setKeyValue("Turn speed","20 deg/sec")
	player_fighter_db:setKeyValue("Beam weapon 0:40","Rng:.5 Dmg:4 Cyc:6")	--modified for scenario: added short forward beam so others balance
	player_fighter_db:setKeyValue("Beam weapon 10:40","Rng:1 Dmg:8 Cyc:6")
	player_fighter_db:setKeyValue("Beam weapon 350:40","Rng:1 Dmg:8 Cyc:6")
	player_fighter_db:setKeyValue("Tube 0","10 sec")
	player_fighter_db:setKeyValue("Storage HVLI","4")
	player_fighter_db:setImage("radar_fighter.png")
--	Striker
	fighter_stock_db:addEntry("Striker")
	local striker_db = queryScienceDatabase("Ships","Mainstream","Starfighter","Striker")
	striker_db:setLongDescription("The Striker is the predecessor to the advanced striker, slow but agile, but does not do an extreme amount of damage, and lacks in shields")
	striker_db:setKeyValue("Class","Starfighter")
	striker_db:setKeyValue("Size","140")
	striker_db:setKeyValue("Shield","50/30")
	striker_db:setKeyValue("Hull","120")
	striker_db:setKeyValue("Repair Crew",2)
	striker_db:setKeyValue("Jump Range","3 - 40 U")	--modified for scenario
	striker_db:setKeyValue("Battery Capacity",500)
	striker_db:setKeyValue("Sensor Ranges","Long: 35 U / Short: 5 U")
	striker_db:setKeyValue("Move speed","2.7 U/min")	--45
	striker_db:setKeyValue("Turn speed","15 deg/sec")
	striker_db:setKeyValue("Beam weapon 345:100","Rng:1 Dmg:6 Cyc:6 Tur:6")
	striker_db:setKeyValue("Beam weapon 15:100","Rng:1 Dmg:6 Cyc:6 Tur:6")
	striker_db:setImage("radar_adv_striker.png")
--	ZX-Lindworm
	fighter_stock_db:addEntry("ZX-Lindworm")
	local zx_lindworm_db = queryScienceDatabase("Ships","Mainstream","Starfighter","ZX-Lindworm")
	zx_lindworm_db:setLongDescription("The ZX model is an improvement on the WX-Lindworm with stronger hull and shields, faster impulse and tubes, more missiles and a single weak, turreted beam. The 'Worm' as it's often called, is a bomber-class starfighter. While one of the least-shielded starfighters in active duty, the Worm's launchers can pack quite a punch. Its goal is to fly in, destroy its target, and fly out or be destroyed.")
	zx_lindworm_db:setKeyValue("Class","Starfighter")
	zx_lindworm_db:setKeyValue("Sub-class","Bomber")
	zx_lindworm_db:setKeyValue("Size","30")
	zx_lindworm_db:setKeyValue("Shield","40")
	zx_lindworm_db:setKeyValue("Hull","75")
	zx_lindworm_db:setKeyValue("Repair Crew",1)
	zx_lindworm_db:setKeyValue("Warp Speed","57 U/min")	--950 (added for scenario)
	zx_lindworm_db:setKeyValue("Battery Capacity",400)
	zx_lindworm_db:setKeyValue("Sensor Ranges","Long: 18 U / Short: 5.5 U")
	zx_lindworm_db:setKeyValue("Move speed","4.2 U/min")	--70	(value * 60 / 1000 = units per minute)
	zx_lindworm_db:setKeyValue("Turn speed","15 deg/sec")
	zx_lindworm_db:setKeyValue("Beam weapon 180:270","Rng:.7 Dmg:2 Cyc:6")
	zx_lindworm_db:setKeyValue("Small Tube 0","10 sec")
	zx_lindworm_db:setKeyValue("Small Tube 359","10 sec")
	zx_lindworm_db:setKeyValue("Small Tube 1","10 sec")
	zx_lindworm_db:setKeyValue("Storage Homing","3")
	zx_lindworm_db:setKeyValue("Storage HVLI","12")
	zx_lindworm_db:setImage("radar_fighter.png")
----	Frigates
	local frigate_stock_db = stock_db:addEntry("Frigate")
	frigate_stock_db:setLongDescription(generic_frigate_description)
--	Flavia P.Falcon
	frigate_stock_db:addEntry("Flavia P.Falcon")
	local flavia_p_falcon_db = queryScienceDatabase("Ships","Mainstream","Frigate","Flavia P.Falcon")
	flavia_p_falcon_db:setLongDescription("Popular among traders and smugglers, the Flavia is a small cargo and passenger transport. It's cheaper than a freighter for small loads and short distances, and is often used to carry high-value cargo discreetly.\n\nThe Flavia Falcon is a Flavia transport modified for faster flight, and adds rear-mounted lasers to keep enemies off its back.\n\nThe Flavia P.Falcon has a nuclear-capable rear-facing weapon tube and a warp drive.")
	flavia_p_falcon_db:setKeyValue("Class","Frigate")
	flavia_p_falcon_db:setKeyValue("Sub-class","Cruiser: Light Transport")
	flavia_p_falcon_db:setKeyValue("Size","80")
	flavia_p_falcon_db:setKeyValue("Shield","70/70")
	flavia_p_falcon_db:setKeyValue("Hull","100")
	flavia_p_falcon_db:setKeyValue("Repair Crew",8)
	flavia_p_falcon_db:setKeyValue("Warp Speed","30 U/min")	--500
	flavia_p_falcon_db:setKeyValue("Sensor Ranges","Long: 40 U / Short: 5 U")
	flavia_p_falcon_db:setKeyValue("Move speed","3.6 U/min")	--60
	flavia_p_falcon_db:setKeyValue("Turn speed","10 deg/sec")
	flavia_p_falcon_db:setKeyValue("Beam weapon 170:40","Rng:1.2 Dmg:6 Cyc:6")
	flavia_p_falcon_db:setKeyValue("Beam weapon 190:40","Rng:1.2 Dmg:6 Cyc:6")
	flavia_p_falcon_db:setKeyValue("Tube 180","20 sec")
	flavia_p_falcon_db:setKeyValue("Storage Homing","3")
	flavia_p_falcon_db:setKeyValue("Storage Nuke","1")
	flavia_p_falcon_db:setKeyValue("Storage Mine","1")
	flavia_p_falcon_db:setKeyValue("Storage HVLI","5")
	flavia_p_falcon_db:setImage("radar_tug.png")
--	Hathcock
	frigate_stock_db:addEntry("Hathcock")
	local hathcock_db = queryScienceDatabase("Ships","Mainstream","Frigate","Hathcock")
	hathcock_db:setLongDescription("Long range narrow beam and some point defense beams, broadside missiles. Agile for a frigate")
	hathcock_db:setKeyValue("Class","Frigate")
	hathcock_db:setKeyValue("Sub-class","Cruiser: Sniper")
	hathcock_db:setKeyValue("Size","80")
	hathcock_db:setKeyValue("Shield","70/70")
	hathcock_db:setKeyValue("Hull","120")
	hathcock_db:setKeyValue("Repair Crew",2)
	hathcock_db:setKeyValue("Jump Range","6 - 60 U")	--modified for scenario
	hathcock_db:setKeyValue("Sensor Ranges","Long: 35 U / Short: 6 U")
	hathcock_db:setKeyValue("Move speed","3 U/min")	--50
	hathcock_db:setKeyValue("Turn speed","15 deg/sec")
	hathcock_db:setKeyValue("Beam weapon 0:4","Rng:1.4 Dmg:4 Cyc:6")
	hathcock_db:setKeyValue("Beam weapon 0:20","Rng:1.2 Dmg:4 Cyc:6")
	hathcock_db:setKeyValue("Beam weapon 0:60","Rng:1.0 Dmg:4 Cyc:6")
	hathcock_db:setKeyValue("Beam weapon 0:90","Rng:0.8 Dmg:4 Cyc:6")
	hathcock_db:setKeyValue("Tube 270","15 sec")
	hathcock_db:setKeyValue("Tube 90","15 sec")
	hathcock_db:setKeyValue("Storage Homing","4")
	hathcock_db:setKeyValue("Storage Nuke","1")
	hathcock_db:setKeyValue("Storage EMP","2")
	hathcock_db:setKeyValue("Storage HVLI","8")
	hathcock_db:setImage("radar_piranha.png")
--	Nautilus
	frigate_stock_db:addEntry("Nautilus")
	local nautilus_db = queryScienceDatabase("Ships","Mainstream","Frigate","Nautilus")
	nautilus_db:setLongDescription("Small mine laying vessel with minimal armament, shields and hull")
	nautilus_db:setKeyValue("Class","Frigate")
	nautilus_db:setKeyValue("Sub-class","Mine Layer")
	nautilus_db:setKeyValue("Size","80")
	nautilus_db:setKeyValue("Shield","60/60")
	nautilus_db:setKeyValue("Hull","100")
	nautilus_db:setKeyValue("Repair Crew",4)
	nautilus_db:setKeyValue("Jump Range","5 - 70 U")	--modified for scenario
	nautilus_db:setKeyValue("Sensor Ranges","Long: 22 U / Short: 4 U")
	nautilus_db:setKeyValue("Move speed","6 U/min")	--100
	nautilus_db:setKeyValue("Turn speed","10 deg/sec")
	nautilus_db:setKeyValue("Beam weapon 35:90","Rng:1 Dmg:6 Cyc:6 Tur:6")
	nautilus_db:setKeyValue("Beam weapon 325:90","Rng:1 Dmg:6 Cyc:6 Tur:6")
	nautilus_db:setKeyValue("Tube 180","10 sec / Mine")
	nautilus_db:setKeyValue(" Tube 180","10 sec / Mine")
	nautilus_db:setKeyValue("  Tube 180","10 sec / Mine")
	nautilus_db:setKeyValue("Storage Mine","12")
	nautilus_db:setImage("radar_tug.png")
--	Phobos M3P
	frigate_stock_db:addEntry("Phobos M3P")
	local phobos_m3p_db = queryScienceDatabase("Ships","Mainstream","Frigate","Phobos M3P")
	phobos_m3p_db:setLongDescription("Player variant of the Phobos M3. Not as strong as the Atlantis, but has front firing tubes, making it an easier to use ship in some scenarios.")
	phobos_m3p_db:setKeyValue("Class","Frigate")
	phobos_m3p_db:setKeyValue("Sub-class","Cruiser")
	phobos_m3p_db:setKeyValue("Size","80")
	phobos_m3p_db:setKeyValue("Shield","100/100")
	phobos_m3p_db:setKeyValue("Hull","200")
	phobos_m3p_db:setKeyValue("Repair Crew",3)
	phobos_m3p_db:setKeyValue("Warp Speed","54 U/min")	--900 (added for scenario)
	phobos_m3p_db:setKeyValue("Sensor Ranges","Long: 25 U / Short: 5 U")
	phobos_m3p_db:setKeyValue("Move speed","4.8 U/min")	--80
	phobos_m3p_db:setKeyValue("Turn speed","10 deg/sec")
	phobos_m3p_db:setKeyValue("Beam weapon 345:90","Rng:1.2 Dmg:6 Cyc:8")
	phobos_m3p_db:setKeyValue("Beam weapon 15:90","Rng:1.2 Dmg:6 Cyc:8")
	phobos_m3p_db:setKeyValue("Tube 359","10 sec")
	phobos_m3p_db:setKeyValue("Tube 1","10 sec")
	phobos_m3p_db:setKeyValue("Tube 180","10 sec / Mine")
	phobos_m3p_db:setKeyValue("Storage Homing","10")
	phobos_m3p_db:setKeyValue("Storage Nuke","2")
	phobos_m3p_db:setKeyValue("Storage Mine","4")
	phobos_m3p_db:setKeyValue("Storage EMP","3")
	phobos_m3p_db:setKeyValue("Storage HVLI","20")
	phobos_m3p_db:setImage("radar_cruiser.png")
--	Piranha
	frigate_stock_db:addEntry("Piranha")
	local piranha_db = queryScienceDatabase("Ships","Mainstream","Frigate","Piranha")
	piranha_db:setLongDescription("This combat-specialized Piranha F12 adds mine-laying tubes, combat maneuvering systems, and a jump drive.")
	piranha_db:setKeyValue("Class","Frigate")
	piranha_db:setKeyValue("Sub-class","Cruiser: Light Artillery")
	piranha_db:setKeyValue("Size","80")
	piranha_db:setKeyValue("Shield","70/70")
	piranha_db:setKeyValue("Hull","120")
	piranha_db:setKeyValue("Repair Crew",2)
	piranha_db:setKeyValue("Jump Range","5 - 50 U")
	piranha_db:setKeyValue("Sensor Ranges","Long: 25 U / Short: 6 U")
	piranha_db:setKeyValue("Move speed","3.6 U/min")	--60
	piranha_db:setKeyValue("Turn speed","10 deg/sec")
	piranha_db:setKeyValue("Large Tube 270","8 sec / Homing,HVLI")
	piranha_db:setKeyValue("Tube 270","8 sec")
	piranha_db:setKeyValue(" LargeTube 270","8 sec / Homing,HVLI")
	piranha_db:setKeyValue("Large Tube 90","8 sec / Homing,HVLI")
	piranha_db:setKeyValue("Tube 90","8 sec")
	piranha_db:setKeyValue(" LargeTube 90","8 sec / Homing,HVLI")
	piranha_db:setKeyValue("Tube 170","8 sec / Mine")
	piranha_db:setKeyValue("Tube 190","8 sec / Mine")
	piranha_db:setKeyValue("Storage Homing","12")
	piranha_db:setKeyValue("Storage Nuke","6")
	piranha_db:setKeyValue("Storage Mine","8")
	piranha_db:setKeyValue("Storage HVLI","20")
	piranha_db:setImage("radar_piranha.png")
--	Repulse
	frigate_stock_db:addEntry("Repulse")
	local repulse_db = queryScienceDatabase("Ships","Mainstream","Frigate","Repulse")
	repulse_db:setLongDescription("A Flavia P. Falcon with better hull and shields, a jump drive, two turreted beams covering both sides and a forward and rear tube. The nukes and mines are gone")
	repulse_db:setKeyValue("Class","Frigate")
	repulse_db:setKeyValue("Sub-class","Cruiser: Armored Transport")
	repulse_db:setKeyValue("Size","80")
	repulse_db:setKeyValue("Shield","80/80")
	repulse_db:setKeyValue("Hull","120")
	repulse_db:setKeyValue("Repair Crew",8)
	repulse_db:setKeyValue("Jump Range","5 - 50 U")
	repulse_db:setKeyValue("Sensor Ranges","Long: 38 U / Short: 5 U")
	repulse_db:setKeyValue("Move speed","3.3 U/min")	--55
	repulse_db:setKeyValue("Turn speed","9 deg/sec")
	repulse_db:setKeyValue("Beam weapon 90:200","Rng:1.2 Dmg:5 Cyc:6")
	repulse_db:setKeyValue("Beam weapon 270:200","Rng:1.2 Dmg:5 Cyc:6")
	repulse_db:setKeyValue("Tube 0","20 sec")
	repulse_db:setKeyValue("Tube 180","20 sec")
	repulse_db:setKeyValue("Storage Homing","4")
	repulse_db:setKeyValue("Storage HVLI","6")
	repulse_db:setImage("radar_tug.png")
----	Corvettes
	local corvette_stock_db = stock_db:addEntry("Corvette")
	corvette_stock_db:setLongDescription(generic_corvette_description)
--	Atlantis
	corvette_stock_db:addEntry("Atlantis")
	local atlantis_db = queryScienceDatabase("Ships","Mainstream","Corvette","Atlantis")
	atlantis_db:setLongDescription("A refitted Atlantis X23 for more general tasks. The large shield system has been replaced with an advanced combat maneuvering systems and improved impulse engines. Its missile loadout is also more diverse. Mistaking the modified Atlantis for an Atlantis X23 would be a deadly mistake.")
	atlantis_db:setKeyValue("Class","Corvette")
	atlantis_db:setKeyValue("Sub-class","Destroyer")
	atlantis_db:setKeyValue("Size","200")
	atlantis_db:setKeyValue("Shield","200/200")
	atlantis_db:setKeyValue("Hull","250")
	atlantis_db:setKeyValue("Repair Crew",3)
	atlantis_db:setKeyValue("Jump Range","5 - 50 U")
	atlantis_db:setKeyValue("Sensor Ranges","Long: 30 U / Short: 5 U")
	atlantis_db:setKeyValue("Move speed","5.4 U/min")	--100
	atlantis_db:setKeyValue("Turn speed","10 deg/sec")
	atlantis_db:setKeyValue("Beam weapon 340:100","Rng:1.5 Dmg:8 Cyc:6")
	atlantis_db:setKeyValue("Beam weapon 20:100","Rng:1.5 Dmg:8 Cyc:6")
	atlantis_db:setKeyValue("Tube 270","10 sec")
	atlantis_db:setKeyValue(" Tube 270","10 sec")
	atlantis_db:setKeyValue("Tube 90","10 sec")
	atlantis_db:setKeyValue(" Tube 90","10 sec")
	atlantis_db:setKeyValue("Tube 180","10 sec / Mine")
	atlantis_db:setKeyValue("Storage Homing","12")
	atlantis_db:setKeyValue("Storage Nuke","4")
	atlantis_db:setKeyValue("Storage Mine","8")
	atlantis_db:setKeyValue("Storage EMP","6")
	atlantis_db:setKeyValue("Storage HVLI","20")
	atlantis_db:setImage("radar_dread.png")
--	Benedict
	corvette_stock_db:addEntry("Benedict")
	local benedict_db = queryScienceDatabase("Ships","Mainstream","Corvette","Benedict")
	benedict_db:setLongDescription("Benedict is Jump Carrier with a shorter range, but with stronger shields and hull and with minimal armament")
	benedict_db:setKeyValue("Class","Corvette")
	benedict_db:setKeyValue("Sub-class","Freighter/Carrier")
	benedict_db:setKeyValue("Size","200")
	benedict_db:setKeyValue("Shield","70/70")
	benedict_db:setKeyValue("Hull","200")
	benedict_db:setKeyValue("Repair Crew",6)
	benedict_db:setKeyValue("Jump Range","5 - 90 U")
	benedict_db:setKeyValue("Sensor Ranges","Long: 30 U / Short: 5 U")
	benedict_db:setKeyValue("Move speed","3.6 U/min")	--60
	benedict_db:setKeyValue("Turn speed","6 deg/sec")
	benedict_db:setKeyValue("Beam weapon 0:90","Rng:1.5 Dmg:4 Cyc:6 Tur:6")
	benedict_db:setKeyValue("Beam weapon 180:90","Rng:1.5 Dmg:4 Cyc:6 Tur:6")
	benedict_db:setImage("radar_transport.png")
--	Crucible
	corvette_stock_db:addEntry("Crucible")
	local crucible_db = queryScienceDatabase("Ships","Mainstream","Corvette","Crucible")
	crucible_db:setLongDescription("A number of missile tubes range around this ship. Beams were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis")
	crucible_db:setKeyValue("Class","Corvette")
	crucible_db:setKeyValue("Sub-class","Popper")
	crucible_db:setKeyValue("Size","80")
	crucible_db:setKeyValue("Shield","160/160")
	crucible_db:setKeyValue("Hull","160")
	crucible_db:setKeyValue("Repair Crew",4)
	crucible_db:setKeyValue("Warp Speed","45 U/min")	--750
	crucible_db:setKeyValue("Sensor Ranges","Long: 20 U / Short: 6 U")
	crucible_db:setKeyValue("Move speed","4.8 U/min")	--80
	crucible_db:setKeyValue("Turn speed","15 deg/sec")
	crucible_db:setKeyValue("Beam weapon 330:70","Rng:1 Dmg:5 Cyc:6")
	crucible_db:setKeyValue("Beam weapon 30:70","Rng:1 Dmg:5 Cyc:6")
	crucible_db:setKeyValue("Small Tube 0","8 sec / HVLI")
	crucible_db:setKeyValue("Tube 0","8 sec / HVLI")
	crucible_db:setKeyValue("Large Tube 0","8 sec / HVLI")
	crucible_db:setKeyValue("Tube 270","8 sec")
	crucible_db:setKeyValue("Tube 90","8 sec")
	crucible_db:setKeyValue("Tube 180","8 sec / Mine")
	crucible_db:setKeyValue("Storage Missiles","H:8 N:4 M:6 E:6 L:24")
	crucible_db:setImage("radar_laser.png")
--	Kiriya
	corvette_stock_db:addEntry("Kiriya")
	local kiriya_db = queryScienceDatabase("Ships","Mainstream","Corvette","Kiriya")
	kiriya_db:setLongDescription("Kiriya is Warp Carrier based on the jump carrier with stronger shields and hull and with minimal armament")
	kiriya_db:setKeyValue("Class","Corvette")
	kiriya_db:setKeyValue("Sub-class","Freighter/Carrier")
	kiriya_db:setKeyValue("Size","200")
	kiriya_db:setKeyValue("Shield","70/70")
	kiriya_db:setKeyValue("Hull","200")
	kiriya_db:setKeyValue("Repair Crew",6)
	kiriya_db:setKeyValue("Warp Speed","45 U/min")	--750
	kiriya_db:setKeyValue("Sensor Ranges","Long: 35 U / Short: 5 U")
	kiriya_db:setKeyValue("Move speed","3.6 U/min")	--60
	kiriya_db:setKeyValue("Turn speed","6 deg/sec")
	kiriya_db:setKeyValue("Beam weapon 0:90","Rng:1.5 Dmg:4 Cyc:6 Tur:6")
	kiriya_db:setKeyValue("Beam weapon 180:90","Rng:1.5 Dmg:4 Cyc:6 Tur:6")
	kiriya_db:setImage("radar_transport.png")
--	Maverick
	corvette_stock_db:addEntry("Maverick")
	local maverick_db = queryScienceDatabase("Ships","Mainstream","Corvette","Maverick")
	maverick_db:setLongDescription("A number of beams bristle from various points on this gunner. Missiles were deemed lower priority, though they are still present. Stronger defenses than a frigate, but not as strong as the Atlantis")
	maverick_db:setKeyValue("Class","Corvette")
	maverick_db:setKeyValue("Sub-class","Gunner")
	maverick_db:setKeyValue("Size","80")
	maverick_db:setKeyValue("Shield","160/160")
	maverick_db:setKeyValue("Hull","160")
	maverick_db:setKeyValue("Repair Crew",4)
	maverick_db:setKeyValue("Warp Speed","48 U/min")	--800
	maverick_db:setKeyValue("Sensor Ranges","Long: 20 U / Short: 4 U")
	maverick_db:setKeyValue("Move speed","4.8 U/min")	--80
	maverick_db:setKeyValue("Turn speed","15 deg/sec")
	maverick_db:setKeyValue("Beam weapon 0:10","Rng:2 Dmg:6 Cyc:6")
	maverick_db:setKeyValue("Beam weapon 340:90","Rng:1.5 Dmg:8 Cyc:6")
	maverick_db:setKeyValue("Beam weapon 20:90","Rng:1.5 Dmg:8 Cyc:6")
	maverick_db:setKeyValue("Beam weapon 290:40","Rng:1 Dmg:6 Cyc:4")
	maverick_db:setKeyValue("Beam weapon 70:40","Rng:1 Dmg:6 Cyc:4")
	maverick_db:setKeyValue("Beam weapon 180:180","Rng:.8 Dmg:4 Cyc:6 Tur:.5")
	maverick_db:setKeyValue("Tube 270","8 sec")
	maverick_db:setKeyValue("Tube 90","8 sec")
	maverick_db:setKeyValue("Tube 180","8 sec / Mine")
	maverick_db:setKeyValue("Storage Missiles","H:6 N:2 M:2 E:4 L:10")
	maverick_db:setImage("radar_laser.png")
--	Player Cruiser
	corvette_stock_db:addEntry("Player Cruiser")
	local player_cruiser_db = queryScienceDatabase("Ships","Mainstream","Corvette","Player Cruiser")
	player_cruiser_db:setLongDescription("A fairly standard cruiser. Stronger than average beams, weaker than average shields, farther than average jump drive range")
	player_cruiser_db:setKeyValue("Class","Corvette")
	player_cruiser_db:setKeyValue("Size","200")
	player_cruiser_db:setKeyValue("Shield","80/80")
	player_cruiser_db:setKeyValue("Hull","200")
	player_cruiser_db:setKeyValue("Repair Crew",3)
	player_cruiser_db:setKeyValue("Jump Range","5 - 80 U")	--modified for scenario
	player_cruiser_db:setKeyValue("Sensor Ranges","Long: 30 U / Short: 5 U")
	player_cruiser_db:setKeyValue("Move speed","5.4 U/min")	--90
	player_cruiser_db:setKeyValue("Turn speed","10 deg/sec")
	player_cruiser_db:setKeyValue("Beam weapon 345:90","Rng:1 Dmg:10 Cyc:6")
	player_cruiser_db:setKeyValue("Beam weapon 15:90","Rng:1 Dmg:10 Cyc:6")
	player_cruiser_db:setKeyValue("Tube 355","8 sec")
	player_cruiser_db:setKeyValue("Tube 5","8 sec")
	player_cruiser_db:setKeyValue("Tube 180","8 sec / Mine")
	player_cruiser_db:setKeyValue("Storage Homing","12")
	player_cruiser_db:setKeyValue("Storage Nuke","4")
	player_cruiser_db:setKeyValue("Storage Mine","8")
	player_cruiser_db:setKeyValue("Storage EMP","6")
	player_cruiser_db:setImage("radar_cruiser.png")
--	Player Missile Cruiser
	corvette_stock_db:addEntry("Player Missile Cr.")
	local player_missile_cruiser_db = queryScienceDatabase("Ships","Mainstream","Corvette","Player Missile Cr.")
	player_missile_cruiser_db:setLongDescription("It's all about the missiles for this model. Broadside tubes shoot homing missiles (30!), front, homing, EMP and nuke. Comparatively weak shields, especially in the rear. Sluggish impulse drive.")
	player_missile_cruiser_db:setKeyValue("Class","Corvette")
	player_missile_cruiser_db:setKeyValue("Size","100")
	player_missile_cruiser_db:setKeyValue("Shield","110/70")
	player_missile_cruiser_db:setKeyValue("Hull","200")
	player_missile_cruiser_db:setKeyValue("Repair Crew",3)
	player_missile_cruiser_db:setKeyValue("Warp Speed","48 U/min")	--800
	player_missile_cruiser_db:setKeyValue("Sensor Ranges","Long: 35 U / Short: 6 U")
	player_missile_cruiser_db:setKeyValue("Move speed","3.6 U/min")	--60
	player_missile_cruiser_db:setKeyValue("Turn speed","8 deg/sec")
	player_missile_cruiser_db:setKeyValue("Tube 0","8 sec")
	player_missile_cruiser_db:setKeyValue(" Tube 0","8 sec")
	player_missile_cruiser_db:setKeyValue("Tube 90","8 sec / Homing")
	player_missile_cruiser_db:setKeyValue(" Tube 90","8 sec / Homing")
	player_missile_cruiser_db:setKeyValue("Tube 270","8 sec / Homing")
	player_missile_cruiser_db:setKeyValue(" Tube 270","8 sec / Homing")
	player_missile_cruiser_db:setKeyValue("Tube 180","8 sec / Mine")
	player_missile_cruiser_db:setKeyValue("Storage Homing","30")
	player_missile_cruiser_db:setKeyValue("Storage Nuke","8")
	player_missile_cruiser_db:setKeyValue("Storage Mine","12")
	player_missile_cruiser_db:setKeyValue("Storage EMP","10")
	player_missile_cruiser_db:setImage("radar_cruiser.png")
---------------------------
--	Custom player ships  --
---------------------------
	local prototype_db = ships_db:addEntry("Prototype")
	prototype_db = queryScienceDatabase("Ships","Prototype")
	prototype_db:setLongDescription("Prototype ships are those that are under development or are otherwise considered experimental. Some have been through several iterations after being tested in the field. Many have been scrapped due to poor design, the ravages of space or perhaps the simple passage of time.")
	prototype_db:setImage("gui/icons/station-engineering.png")
----	Starfighters
	local fighter_prototype_db = prototype_db:addEntry("Starfighter")
	fighter_prototype_db:setLongDescription(generic_starfighter_description)
--	Striker LX
	fighter_prototype_db:addEntry("Striker LX")
	local striker_lx_db = queryScienceDatabase("Ships","Prototype","Starfighter","Striker LX")
	striker_lx_db:setLongDescription("The Striker is the predecessor to the advanced striker, slow but agile, but does not do an extreme amount of damage, and lacks in shields. The Striker LX is a modification of the Striker: stronger shields, more energy, jump drive (vs none), faster impulse, slower turret, two rear tubes (vs none)")
	striker_lx_db:setKeyValue("Class","Starfighter")
	striker_lx_db:setKeyValue("Sub-class","Patrol")
	striker_lx_db:setKeyValue("Size","140")
	striker_lx_db:setKeyValue("Shield","100/100")
	striker_lx_db:setKeyValue("Hull","100")
	striker_lx_db:setKeyValue("Repair Crew",3)
	striker_lx_db:setKeyValue("Battery Capacity",600)
	striker_lx_db:setKeyValue("Jump Range","2 - 20 U")
	striker_lx_db:setKeyValue("Sensor Ranges","Long: 20 U / Short: 4 U")
	striker_lx_db:setKeyValue("Move speed","3.9 U/min")	--65	(value * 60 / 1000 = units per minute)
	striker_lx_db:setKeyValue("Turn speed","35 deg/sec")
	striker_lx_db:setKeyValue("Beam weapon 345:100","Rng:1.1 Dmg:6.5 Cyc:6 Tur:.2")
	striker_lx_db:setKeyValue("Beam weapon 15:100","Rng:1.1 Dmg:6.5 Cyc:6 Tur:.2")
	striker_lx_db:setKeyValue("Tube 180","10 sec")
	striker_lx_db:setKeyValue(" Tube 180","10 sec")
	striker_lx_db:setKeyValue("Storage Homing","4")
	striker_lx_db:setKeyValue("Storage Nuke","2")
	striker_lx_db:setKeyValue("Storage Mine","3")
	striker_lx_db:setKeyValue("Storage EMP","3")
	striker_lx_db:setKeyValue("Storage HVLI","6")
	striker_lx_db:setImage("radar_adv_striker.png")
----	Frigates
	local frigate_prototype_db = prototype_db:addEntry("Frigate")
	frigate_prototype_db:setLongDescription(generic_frigate_description)
--	Phobos T2
	frigate_prototype_db:addEntry("Phobos T2")
	local phobos_t2_db = queryScienceDatabase("Ships","Prototype","Frigate","Phobos T2")
	phobos_t2_db:setLongDescription("Based on Phobos M3P with these differences: more repair crew, a jump drive, faster spin, stronger front shield, weaker rear shield, less maximum energy, turreted and faster beams, one fewer tube forward, and fewer missiles")
	phobos_t2_db:setKeyValue("Class","Frigate")
	phobos_t2_db:setKeyValue("Sub-class","Cruiser")
	phobos_t2_db:setKeyValue("Size","80")
	phobos_t2_db:setKeyValue("Shield","120/80")
	phobos_t2_db:setKeyValue("Hull","200")
	phobos_t2_db:setKeyValue("Repair Crew",4)
	phobos_t2_db:setKeyValue("Battery Capacity",800)
	phobos_t2_db:setKeyValue("Jump Range","2 - 25 U")
	phobos_t2_db:setKeyValue("Sensor Ranges","Long: 25 U / Short: 5 U")
	phobos_t2_db:setKeyValue("Move speed","4.8 U/min")	--80
	phobos_t2_db:setKeyValue("Turn speed","20 deg/sec")
	phobos_t2_db:setKeyValue("Beam weapon 330:40","Rng:1.2 Dmg:6 Cyc:4 Tur:.2")
	phobos_t2_db:setKeyValue("Beam weapon 30:40","Rng:1.2 Dmg:6 Cyc:4 Tur:.2")
	phobos_t2_db:setKeyValue("Tube 0","10 sec")
	phobos_t2_db:setKeyValue("Tube 180","10 sec / Mine")
	phobos_t2_db:setKeyValue("Storage Homing",8)
	phobos_t2_db:setKeyValue("Storage Nuke",2)
	phobos_t2_db:setKeyValue("Storage Mine",4)
	phobos_t2_db:setKeyValue("Storage EMP",3)
	phobos_t2_db:setKeyValue("Storage HVLI",16)
	phobos_t2_db:setImage("radar_cruiser.png")
----	Corvettes
	local corvette_prototype_db = prototype_db:addEntry("Corvette")
	corvette_prototype_db:setLongDescription(generic_corvette_description)
--	Focus
	corvette_prototype_db:addEntry("Focus")
	local focus_db = queryScienceDatabase("Ships","Prototype","Corvette","Focus")
	focus_db:setLongDescription("Adjusted Crucible: short jump drive (no warp), faster impulse and spin, weaker shields and hull, narrower beams, fewer tubes. The large tube accomodates nukes, EMPs and homing missiles")
	focus_db:setKeyValue("Class","Corvette")
	focus_db:setKeyValue("Sub-class","Popper")
	focus_db:setKeyValue("Size","200")
	focus_db:setKeyValue("Shield","100/100")
	focus_db:setKeyValue("Hull","100")
	focus_db:setKeyValue("Repair Crew",4)
	focus_db:setKeyValue("Jump Range","2.5 - 25 U")
	focus_db:setKeyValue("Sensor Ranges","Long: 32 U / Short: 5 U")
	focus_db:setKeyValue("Move speed","4.2 U/min")	--70
	focus_db:setKeyValue("Turn speed","20 deg/sec")
	focus_db:setKeyValue("Beam weapon 340:60","Rng:1 Dmg:5 Cyc:6")
	focus_db:setKeyValue("Beam weapon 20:60","Rng:1 Dmg:5 Cyc:6")
	focus_db:setKeyValue("Small Tube 0","8 sec / HVLI")
	focus_db:setKeyValue("Tube 0","8 sec / HVLI")
	focus_db:setKeyValue("Large Tube 0","8 sec")
	focus_db:setKeyValue("Tube 180","8 sec / Mine")
	focus_db:setKeyValue("Storage Homing",8)
	focus_db:setKeyValue("Storage Nuke",1)
	focus_db:setKeyValue("Storage Mine",6)
	focus_db:setKeyValue("Storage EMP",2)
	focus_db:setKeyValue("Storage HVLI",24)
	focus_db:setImage("radar_laser.png")
--	Holmes
	corvette_prototype_db:addEntry("Holmes")
	local holmes_db = queryScienceDatabase("Ships","Prototype","Corvette","Holmes")
	holmes_db:setLongDescription("Revised Crucible: weaker shields, side beams, fewer tubes, fewer missiles, EMPs and Nukes in front middle tube and large homing missiles")
	holmes_db:setKeyValue("Class","Corvette")
	holmes_db:setKeyValue("Sub-class","Popper")
	holmes_db:setKeyValue("Size","200")
	holmes_db:setKeyValue("Shield","160/160")
	holmes_db:setKeyValue("Hull","160")
	holmes_db:setKeyValue("Repair Crew",4)
	holmes_db:setKeyValue("Warp Speed","45.0 U/min")	--750
	holmes_db:setKeyValue("Sensor Ranges","Long: 35 U / Short: 4 U")
	holmes_db:setKeyValue("Move speed","4.2 U/min")	--70
	holmes_db:setKeyValue("Turn speed","15 deg/sec")
	holmes_db:setKeyValue("Beam weapon 275:50","Rng:.9 Dmg:5 Cyc:6")
	holmes_db:setKeyValue("Beam weapon 265:50","Rng:.9 Dmg:5 Cyc:6")
	holmes_db:setKeyValue("Beam weapon 85:50","Rng:.9 Dmg:5 Cyc:6")
	holmes_db:setKeyValue("Beam weapon 95:50","Rng:.9 Dmg:5 Cyc:6")
	holmes_db:setKeyValue("Small Tube 0","8 sec / Homing")
	holmes_db:setKeyValue("Tube 0","8 sec / Homing")
	holmes_db:setKeyValue("Large Tube 0","8 sec / Homing")
	holmes_db:setKeyValue("Tube 180","8 sec / Mine")
	holmes_db:setKeyValue("Storage Homing",10)
	holmes_db:setKeyValue("Storage Mine",6)
	holmes_db:setImage("radar_laser.png")
--	Maverick XP
	corvette_prototype_db:addEntry("Maverick XP")
	local maverick_xp_db = queryScienceDatabase("Ships","Prototype","Corvette","Maverick XP")
	maverick_xp_db:setLongDescription("Based on Maverick: slower impulse, jump (no warp), one heavy slow turreted beam (not 6 beams)")
	maverick_xp_db:setKeyValue("Class","Corvette")
	maverick_xp_db:setKeyValue("Sub-class","Gunner")
	maverick_xp_db:setKeyValue("Size","200")
	maverick_xp_db:setKeyValue("Shield","160/160")
	maverick_xp_db:setKeyValue("Hull","160")
	maverick_xp_db:setKeyValue("Repair Crew",4)
	maverick_xp_db:setKeyValue("Jump Range","2 - 20 U")
	maverick_xp_db:setKeyValue("Sensor Ranges","Long: 25 U / Short: 7 U")
	maverick_xp_db:setKeyValue("Move speed","3.9 U/min")	--65
	maverick_xp_db:setKeyValue("Turn speed","15 deg/sec")
	maverick_xp_db:setKeyValue("Beam weapon 0:270","Rng:1 Dmg:20 Cyc:20 Tur:.2")
	maverick_xp_db:setKeyValue("Tube 270","8 sec")
	maverick_xp_db:setKeyValue("Tube 90","8 sec")
	maverick_xp_db:setKeyValue("Tube 180","8 sec / Mine")
	maverick_xp_db:setKeyValue("Storage Homing",6)
	maverick_xp_db:setKeyValue("Storage Nuke",2)
	maverick_xp_db:setKeyValue("Storage Mine",2)
	maverick_xp_db:setKeyValue("Storage EMP",4)
	maverick_xp_db:setKeyValue("Storage HVLI",10)
	maverick_xp_db:setImage("radar_laser.png")
	
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
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	if not terrain_generated then
		addGMFunction(string.format("+Player Teams: %i",player_team_count),setPlayerTeamCount)
		addGMFunction(string.format("+Player Ships: %i (%i)",ships_per_team,ships_per_team*player_team_count),setPlayerShipCount)
		addGMFunction(string.format("+P.Ship Types: %s",player_ship_types),setPlayerShipTypes)
		local button_label = "+NPC Ships: 0"
		if npc_ships then
			button_label = string.format("+NPC Ships: %i-%i",npc_lower,npc_upper)
		end
		addGMFunction(button_label,setNPCShips)
		addGMFunction("+Terrain",setTerrainParameters)
		addGMFunction(string.format("Respawn: %s",respawn_type),function()
			if respawn_type == "lindworm" then
				respawn_type = "self"
			elseif respawn_type == "self" then
				respawn_type = "lindworm"
			end
			mainGMButtons()
		end)
	else
		addGMFunction("Show control codes",showControlCodes)
		addGMFunction("Show Human codes",showHumanCodes)
		addGMFunction("Show Kraylor codes",showKraylorCodes)
		if exuari_angle ~= nil then
			addGMFunction("Show Exuari codes",showExuariCodes)
		end
		if ktlitan_angle ~= nil then
			addGMFunction("Show Ktlitan codes",showKtlitanCodes)
		end
	end
	addGMFunction(string.format("+Stn Sensors %iU",station_sensor_range/1000),setStationSensorRange)
	addGMFunction(string.format("+Game Time %i",game_time_limit/60),setGameTimeLimit)
end
function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format("Version %s",scenario_version),function()
		local version_message = string.format("Scenario version %s\n LUA version %s",scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction("Show control codes",showControlCodes)
	addGMFunction("Show Human codes",showHumanCodes)
	addGMFunction("Show Kraylor codes",showKraylorCodes)
	if exuari_angle ~= nil then
		addGMFunction("Show Exuari codes",showExuariCodes)
	end
	if ktlitan_angle ~= nil then
		addGMFunction("Show Ktlitan codes",showKtlitanCodes)
	end
	addGMFunction("Statistics Summary",function()
		local stat_list = gatherStats()
		local out = "Current Scores:"
		out = out .. string.format("\n   Human Navy: %.2f (%.1f%%)",stat_list.human.weighted_score,stat_list.human.weighted_score/original_score["Human Navy"]*100)
		out = out .. string.format("\n   Kraylor: %.2f (%.1f%%)",stat_list.kraylor.weighted_score,stat_list.kraylor.weighted_score/original_score["Kraylor"]*100)
		if exuari_angle ~= nil then
			out = out .. string.format("\n   Exuari: %.2f (%.1f%%)",stat_list.exuari.weighted_score,stat_list.exuari.weighted_score/original_score["Exuari"]*100)
		end
		if ktlitan_angle ~= nil then
			out = out .. string.format("\n   Ktlitans: %.2f (%.1f%%)",stat_list.ktlitan.weighted_score,stat_list.ktlitan.weighted_score/original_score["Ktlitans"]*100)
		end
		local out = out .. "\nOriginal scores:"
		out = out .. string.format("\n   Human Navy: %.2f",original_score["Human Navy"])
		out = out .. string.format("\n   Kraylor: %.2f",original_score["Kraylor"])
		if exuari_angle ~= nil then
			out = out .. string.format("\n   Exuari: %.2f",original_score["Exuari"])
		end
		if ktlitan_angle ~= nil then
			out = out .. string.format("\n   Ktlitans: %.2f",original_score["Ktlitans"])
		end
		addGMMessage(out)
	end)
	addGMFunction("Statistics Details",function()
		local stat_list = gatherStats()
		out = "Human Navy:\n    Stations: (score value, type, name)"
		print("Human Navy:")
		print("    Stations: (score value, type, name)")
		for name, details in pairs(stat_list.human.station) do
			out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
			print(" ",details.score_value,details.template_type,name)
		end
		local weighted_stations = stat_list.human.station_score_total * stat_list.weight.station
		out = out .. string.format("\n            Station Total:%i Weight:%.1f Weighted total:%.2f",stat_list.human.station_score_total,stat_list.weight.station,weighted_stations)
		print("    Station Total:",stat_list.human.station_score_total,"Weight:",stat_list.weight.station,"Weighted Total:",weighted_stations)
		out = out .. "\n    Player Ships: (score value, type, name)"
		print("    Player Ships: (score value, type, name)")
		for name, details in pairs(stat_list.human.ship) do
			out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
			print(" ",details.score_value,details.template_type,name)
		end
		local weighted_players = stat_list.human.ship_score_total * stat_list.weight.ship
		out = out .. string.format("\n            Player Ship Total:%i Weight:%.1f Weighted total:%.2f",stat_list.human.ship_score_total,stat_list.weight.ship,weighted_players)
		print("    Player Ship Total:",stat_list.human.ship_score_total,"Weight:",stat_list.weight.ship,"Weighted Total:",weighted_players)
		out = out .. "\n    NPC Assets: score value, type, name (location)"
		print("    NPC Assets: score value, type, name (location)")
		for name, details in pairs(stat_list.human.npc) do
			if details.template_type ~= nil then
				out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
				print(" ",details.score_value,details.template_type,name)
			elseif details.topic ~= nil then
				out = out .. string.format("\n        %i %s %s (%s)",details.score_value,details.topic,name,details.location_name)
				print(" ",details.score_value,details.topic,name,"(" .. details.location_name .. ")")
			end
		end
		local weighted_npcs = stat_list.human.npc_score_total * stat_list.weight.npc
		out = out .. string.format("\n            NPC Asset Total:%i Weight:%.1f Weighted total:%.2f",stat_list.human.npc_score_total,stat_list.weight.npc,weighted_npcs)
		print("    NPC Asset Total:",stat_list.human.npc_score_total,"Weight:",stat_list.weight.npc,"Weighted Total:",weighted_npcs)
		out = out .. string.format("\n----Human weighted total:%.1f Original:%.1f Change:%.2f%%",stat_list.human.weighted_score,original_score["Human Navy"],stat_list.human.weighted_score/original_score["Human Navy"]*100)
		print("----Human weighted total:",stat_list.human.weighted_score,"Original:",original_score["Human Navy"],"Change:",stat_list.human.weighted_score/original_score["Human Navy"]*100 .. "%")
		out = out .. "\nKraylor:\n    Stations: (score value, type, name)"
		print("Kraylor:")
		print("    Stations: (score value, type, name)")
		for name, details in pairs(stat_list.kraylor.station) do
			out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
			print(" ",details.score_value,details.template_type,name)
		end
		local weighted_stations = stat_list.kraylor.station_score_total * stat_list.weight.station
		out = out .. string.format("\n            Station Total:%i Weight:%.1f Weighted total:%.2f",stat_list.kraylor.station_score_total,stat_list.weight.station,weighted_stations)
		print("    Station Total:",stat_list.kraylor.station_score_total,"Weight:",stat_list.weight.station,"Weighted Total:",weighted_stations)
		out = out .. "\n    Player Ships: (score value, type, name)"
		print("    Player Ships: (score value, type, name)")
		for name, details in pairs(stat_list.kraylor.ship) do
			out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
			print(" ",details.score_value,details.template_type,name)
		end
		local weighted_players = stat_list.kraylor.ship_score_total * stat_list.weight.ship
		out = out .. string.format("\n            Player Ship Total:%i Weight:%.1f Weighted total:%.2f",stat_list.kraylor.ship_score_total,stat_list.weight.ship,weighted_players)
		print("    Player Ship Total:",stat_list.kraylor.ship_score_total,"Weight:",stat_list.weight.ship,"Weighted Total:",weighted_players)
		out = out .. "\n    NPC Assets: score value, type, name (location)"
		print("    NPC Assets: score value, type, name (location)")
		for name, details in pairs(stat_list.kraylor.npc) do
			if details.template_type ~= nil then
				out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
				print(" ",details.score_value,details.template_type,name)
			elseif details.topic ~= nil then
				out = out .. string.format("\n        %i %s %s (%s)",details.score_value,details.topic,name,details.location_name)
				print(" ",details.score_value,details.topic,name,"(" .. details.location_name .. ")")
			end
		end
		local weighted_npcs = stat_list.kraylor.npc_score_total * stat_list.weight.npc
		out = out .. string.format("\n            NPC Asset Total:%i Weight:%.1f Weighted total:%.2f",stat_list.kraylor.npc_score_total,stat_list.weight.npc,weighted_npcs)
		print("    NPC Asset Total:",stat_list.kraylor.npc_score_total,"Weight:",stat_list.weight.npc,"Weighted Total:",weighted_npcs)
		out = out .. string.format("\n----Kraylor weighted total:%.1f Original:%.1f Change:%.2f%%",stat_list.kraylor.weighted_score,original_score["Kraylor"],stat_list.kraylor.weighted_score/original_score["Kraylor"]*100)
		print("----Kraylor weighted total:",stat_list.kraylor.weighted_score,"Original:",original_score["Kraylor"],"Change:",stat_list.kraylor.weighted_score/original_score["Kraylor"]*100 .. "%")
		if exuari_angle ~= nil then
			out = out .. "\nExuari:\n    Stations: (score value, type, name)"
			print("Exuari:")
			print("    Stations: (score value, type, name)")
			for name, details in pairs(stat_list.exuari.station) do
				out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
				print(" ",details.score_value,details.template_type,name)
			end
			local weighted_stations = stat_list.exuari.station_score_total * stat_list.weight.station
			out = out .. string.format("\n            Station Total:%i Weight:%.1f Weighted total:%.2f",stat_list.exuari.station_score_total,stat_list.weight.station,weighted_stations)
			print("    Station Total:",stat_list.exuari.station_score_total,"Weight:",stat_list.weight.station,"Weighted Total:",weighted_stations)
			out = out .. "\n    Player Ships: (score value, type, name)"
			print("    Player Ships: (score value, type, name)")
			for name, details in pairs(stat_list.exuari.ship) do
				out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
				print(" ",details.score_value,details.template_type,name)
			end
			local weighted_players = stat_list.exuari.ship_score_total * stat_list.weight.ship
			out = out .. string.format("\n            Player Ship Total:%i Weight:%.1f Weighted total:%.2f",stat_list.exuari.ship_score_total,stat_list.weight.ship,weighted_players)
			print("    Player Ship Total:",stat_list.exuari.ship_score_total,"Weight:",stat_list.weight.ship,"Weighted Total:",weighted_players)
			out = out .. "\n    NPC Assets: score value, type, name (location)"
			print("    NPC Assets: score value, type, name (location)")
			for name, details in pairs(stat_list.exuari.npc) do
				if details.template_type ~= nil then
					out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
					print(" ",details.score_value,details.template_type,name)
				elseif details.topic ~= nil then
					out = out .. string.format("\n        %i %s %s (%s)",details.score_value,details.topic,name,details.location_name)
					print(" ",details.score_value,details.topic,name,"(" .. details.location_name .. ")")
				end
			end
			local weighted_npcs = stat_list.exuari.npc_score_total * stat_list.weight.npc
			out = out .. string.format("\n            NPC Asset Total:%i Weight:%.1f Weighted total:%.2f",stat_list.exuari.npc_score_total,stat_list.weight.npc,weighted_npcs)
			print("    NPC Asset Total:",stat_list.exuari.npc_score_total,"Weight:",stat_list.weight.npc,"Weighted Total:",weighted_npcs)
			out = out .. string.format("\n----Exuari weighted total:%.1f Original:%.1f Change:%.2f%%",stat_list.exuari.weighted_score,original_score["Exuari"],stat_list.exuari.weighted_score/original_score["Exuari"]*100)
			print("----Exuari weighted total:",stat_list.exuari.weighted_score,"Original:",original_score["Exuari"],"Change:",stat_list.exuari.weighted_score/original_score["Exuari"]*100 .. "%")
		end
		if ktlitan_angle ~= nil then
			out = out .. "\nKtlitan:\n    Stations: (score value, type, name)"
			print("Ktlitan:")
			print("    Stations: (score value, type, name)")
			for name, details in pairs(stat_list.ktlitan.station) do
				out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
				print(" ",details.score_value,details.template_type,name)
			end
			local weighted_stations = stat_list.ktlitan.station_score_total * stat_list.weight.station
			out = out .. string.format("\n            Station Total:%i Weight:%.1f Weighted total:%.2f",stat_list.ktlitan.station_score_total,stat_list.weight.station,weighted_stations)
			print("    Station Total:",stat_list.ktlitan.station_score_total,"Weight:",stat_list.weight.station,"Weighted Total:",weighted_stations)
			out = out .. "\n    Player Ships: (score value, type, name)"
			print("    Player Ships: (score value, type, name)")
			for name, details in pairs(stat_list.ktlitan.ship) do
				out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
				print(" ",details.score_value,details.template_type,name)
			end
			local weighted_players = stat_list.ktlitan.ship_score_total * stat_list.weight.ship
			out = out .. string.format("\n            Player Ship Total:%i Weight:%.1f Weighted total:%.2f",stat_list.ktlitan.ship_score_total,stat_list.weight.ship,weighted_players)
			print("    Player Ship Total:",stat_list.ktlitan.ship_score_total,"Weight:",stat_list.weight.ship,"Weighted Total:",weighted_players)
			out = out .. "\n    NPC Assets: score value, type, name (location)"
			print("    NPC Assets: score value, type, name (location)")
			for name, details in pairs(stat_list.ktlitan.npc) do
				if details.template_type ~= nil then
					out = out .. string.format("\n        %i %s %s",details.score_value,details.template_type,name)
					print(" ",details.score_value,details.template_type,name)
				elseif details.topic ~= nil then
					out = out .. string.format("\n        %i %s %s (%s)",details.score_value,details.topic,name,details.location_name)
					print(" ",details.score_value,details.topic,name,"(" .. details.location_name .. ")")
				end
			end
			local weighted_npcs = stat_list.ktlitan.npc_score_total * stat_list.weight.npc
			out = out .. string.format("\n            NPC Asset Total:%i Weight:%.1f Weighted total:%.2f",stat_list.ktlitan.npc_score_total,stat_list.weight.npc,weighted_npcs)
			print("    NPC Asset Total:",stat_list.ktlitan.npc_score_total,"Weight:",stat_list.weight.npc,"Weighted Total:",weighted_npcs)
			out = out .. string.format("\n----Ktlitan weighted total:%.1f Original:%.1f Change:%.2f%%",stat_list.ktlitan.weighted_score,original_score["Ktlitans"],stat_list.ktlitan.weighted_score/original_score["Ktlitans"]*100)
			print("----Ktlitan weighted total:",stat_list.ktlitan.weighted_score,"Original:",original_score["Ktlitans"],"Change:",stat_list.ktlitan.weighted_score/original_score["Ktlitans"]*100 .. "%")
		end
		addGMMessage(out)
	end)
end
--	Player related GM configuration functions
function setPlayerTeamCount()
	clearGMFunctions()
	addGMFunction("-Main from Teams",mainGMButtons)
	local button_label = "2"
	if player_team_count == 2 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		player_team_count = 2
		mainGMButtons()
	end)
	local button_label = "3"
	if player_team_count == 3 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		player_team_count = 3
		if ships_per_team > max_ships_per_team[player_team_count] then
			ships_per_team = max_ships_per_team[player_team_count]
			if player_ship_types == "spawned" then
				addGMMessage("Switching player ship type to default")
				player_ship_types = "default"
			end
		end
		mainGMButtons()
	end)
	local button_label = "4"
	if player_team_count == 4 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		player_team_count = 4
		if ships_per_team > max_ships_per_team[player_team_count] then
			ships_per_team = max_ships_per_team[player_team_count]
			if player_ship_types == "spawned" then
				addGMMessage("Switching player ship type to default")
				player_ship_types = "default"
			end
		end
		mainGMButtons()
	end)
end
function setPlayerShipCount()
	clearGMFunctions()
	addGMFunction("-Main from Ships",mainGMButtons)
	if ships_per_team < max_ships_per_team[player_team_count] then
		addGMFunction(string.format("%i ships add -> %i",ships_per_team,ships_per_team + 1),function()
			ships_per_team = ships_per_team + 1
			if player_ship_types == "spawned" then
				addGMMessage("Switching player ship type to default")
				player_ship_types = "default"
			end
			setPlayerShipCount()
		end)
	end
	if ships_per_team > 1 then
		addGMFunction(string.format("%i ships del -> %i",ships_per_team,ships_per_team - 1),function()
			ships_per_team = ships_per_team - 1
			if player_ship_types == "spawned" then
				addGMMessage("Switching player ship type to default")
				player_ship_types = "default"
			end
			setPlayerShipCount()
		end)
	end
end
function setPlayerShipTypes()
	clearGMFunctions()
	addGMFunction("-Main from Ship Types",mainGMButtons)
	local button_label = "default"
	if player_ship_types == button_label then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		player_ship_types = "default"
		local player_plural = "players"
		local type_plural = "types"
		if ships_per_team == 1 then
			player_plural = "player"
			type_plural = "type"
		end
		local out = string.format("Default ship %s for a team of %i %s:",type_plural,ships_per_team,player_plural)
		for i=1,ships_per_team do
			out = out .. "\n   " .. i .. ") " .. default_player_ship_sets[ships_per_team][i]
		end
		addGMMessage(out)
		setPlayerShipTypes()
	end)
	button_label = "spawned"
	if player_ship_types == button_label then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		player_ship_types = "spawned"
		local out = "Spawned ship type(s):"
		local player_count = 0
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				player_count = player_count + 1
				out = out .. "\n   " .. player_count .. ") " .. p:getTypeName()
			end
		end
		if player_count < ships_per_team then
			if player_count == 0 then
				out = string.format("%i player ships spawned. %i are required.\n\nUsing default ship set.\n\n%s",player_count,ships_per_team,out)
			elseif player_count == 1 then
				out = string.format("Only %i player ship spawned. %i are required.\n\nUsing default ship set.\n\n%s",player_count,ships_per_team,out)
			else
				out = string.format("Only %i player ships spawned. %i are required.\n\nUsing default ship set.\n\n%s",player_count,ships_per_team,out)
			end
			player_ship_types = "default"
		elseif player_count > ships_per_team then
			if ships_per_team == 1 then
				out = string.format("%i player ships spawned. Only %i is required.\n\nUsing default ship set.\n\n%s",player_count,ships_per_team,out)
			else
				out = string.format("%i player ships spawned. Only %i are required.\n\nUsing default ship set.\n\n%s",player_count,ships_per_team,out)
			end
			player_ship_types = "default"
		end
		addGMMessage(out)
		setPlayerShipTypes()
	end)
	button_label = "custom"
	if player_ship_types == button_label then
		button_label = button_label .. "*"
	end
	addGMFunction(string.format("+%s",button_label),setCustomPlayerShipSet)
end
function setCustomPlayerShipSet()
	clearGMFunctions()
	addGMFunction("-Main from Custom",mainGMButtons)
	addGMFunction("-Ship Types",setPlayerShipTypes)
	addGMFunction("+Customize Custom",setCustomSet)
	for ship_set_type,list in pairs(custom_player_ship_sets) do
		local button_label = ship_set_type
		if ship_set_type == custom_player_ship_type then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			player_ship_types = "custom"
			custom_player_ship_type = ship_set_type
			local out = ""
			if ships_per_team == 1 then
				out = string.format("Ship type set %s for %i player:",custom_player_ship_type,ships_per_team)
			else
				out = string.format("Ship type set %s for %i players:",custom_player_ship_type,ships_per_team)
			end
			for index, ship_type in ipairs(custom_player_ship_sets[custom_player_ship_type][ships_per_team]) do
--				print("index:",index,"ship type:",ship_type)
				out = out .. "\n   " .. index .. ") " .. ship_type
			end
			addGMMessage(out)
			setCustomPlayerShipSet()
		end)
	end
end
function setCustomSet()
	clearGMFunctions()
	addGMFunction("-Main from Custom",mainGMButtons)
	addGMFunction("-Ship Types",setPlayerShipTypes)
	addGMFunction("-Custom Set",setCustomPlayerShipSet)
	if template_out == nil then
		template_out = custom_player_ship_sets["Custom"][ships_per_team][1]
	else
		local match_in_set = false
		for i=1,#custom_player_ship_sets["Custom"][ships_per_team] do
			if custom_player_ship_sets["Custom"][ships_per_team][i] == template_out then
				match_in_set = true
			end
		end
		if not match_in_set then
			template_out = custom_player_ship_sets["Custom"][ships_per_team][1]
		end
	end
	if template_in == nil then
		for name, details in pairs(player_ship_stats) do
			template_in = name
			break
		end
	end
	addGMFunction(string.format("+Out %s",template_out),setTemplateOut)
	addGMFunction(string.format("+In %s",template_in),setTemplateIn)
	addGMFunction("Swap",function()
		for i=1,#custom_player_ship_sets["Custom"][ships_per_team] do
			if custom_player_ship_sets["Custom"][ships_per_team][i] == template_out then
				custom_player_ship_sets["Custom"][ships_per_team][i] = template_in
				template_in = template_out
				template_out = custom_player_ship_sets["Custom"][ships_per_team][i]
				break
			end
		end
		setCustomSet()
	end)
end
function setTemplateOut()
	clearGMFunctions()
	table.sort(custom_player_ship_sets["Custom"][ships_per_team])
	for i=1,#custom_player_ship_sets["Custom"][ships_per_team] do
		local button_label = custom_player_ship_sets["Custom"][ships_per_team][i]
		if template_out == custom_player_ship_sets["Custom"][ships_per_team][i] then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			template_out = custom_player_ship_sets["Custom"][ships_per_team][i]
			setCustomSet()
		end)
	end
end
function setTemplateIn()
	clearGMFunctions()
	local sorted_templates = {}
	for name, details in pairs(player_ship_stats) do
		table.insert(sorted_templates,name)
	end
	table.sort(sorted_templates)
	for _, name in ipairs(sorted_templates) do
		local button_label = name
		if template_in == name then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			template_in = name
			setCustomSet()
		end)
	end
end
--	Terrain related GM configuration functions
function setTerrainParameters()
	clearGMFunctions()
	addGMFunction("-Main from Terrain",mainGMButtons)
	if generate_terrain_message_counter % 5 == 0 then
		addGMMessage("Clicking the generate button will generate the terrain based on the number of player teams selected, the number of ships on a team and the terrain parameters selected.\n\nAfter you generate the terrain, you cannot change the player ships, or the terrain unless you restart the server.")
	end
	generate_terrain_message_counter = generate_terrain_message_counter + 1
	addGMFunction(string.format("Missiles: %s",missile_availability),setMissileAvailability)
	addGMFunction("+Primary Station",setPrimaryStationParameters)
	addGMFunction("Generate",function()
		generateTerrain()
		mainGMButtons()
	end)
end
function setStationSensorRange()
	clearGMFunctions()
	local button_label = "Zero"
	if station_sensor_range == 0 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		station_sensor_range = 0
		mainGMButtons()
	end)
	button_label = "5U"
	if station_sensor_range == 5000 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		station_sensor_range = 5000
		mainGMButtons()
	end)
	button_label = "10U"
	if station_sensor_range == 10000 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		station_sensor_range = 10000
		mainGMButtons()
	end)
	button_label = "20U"
	if station_sensor_range == 20000 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		station_sensor_range = 20000
		mainGMButtons()
	end)
	button_label = "30U"
	if station_sensor_range == 30000 then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		station_sensor_range = 30000
		mainGMButtons()
	end)
end
function setPrimaryStationParameters()
	clearGMFunctions()
	addGMFunction("-Main from Prm Stn",mainGMButtons)
	addGMFunction("-Terrain",setTerrainParameters)
	if defense_platform_count_options[defense_platform_count_index].count == "random" then
		addGMFunction("+Platforms: Random",setDefensePlatformCount)
	else
		addGMFunction(string.format("+Platforms: %i",defense_platform_count_options[defense_platform_count_index].count),setDefensePlatformCount)
	end
	if primary_station_size_index == 1 then
		addGMFunction("Random Size ->",function()
			primary_station_size_index = primary_station_size_index + 1
			setPrimaryStationParameters()
		end)
	else
		addGMFunction(string.format("%s ->",primary_station_size_options[primary_station_size_index]),function()
			primary_station_size_index = primary_station_size_index + 1
			if primary_station_size_index > #primary_station_size_options then
				primary_station_size_index = 1
			end
			setPrimaryStationParameters()
		end)
	end
	addGMFunction(string.format("Jammer: %s ->",primary_jammers),function()
		if primary_jammers == "random" then
			primary_jammers = "on"
		elseif primary_jammers == "on" then
			primary_jammers = "off"
		elseif primary_jammers == "off" then
			primary_jammers = "random"
		end
		setPrimaryStationParameters()
	end)
end
function setDefensePlatformCount()
	clearGMFunctions()
	addGMFunction("-Main from Platforms",mainGMButtons)
	addGMFunction("-Terrain",setTerrainParameters)
	addGMFunction("-Primary Station",setPrimaryStationParameters)
	if defense_platform_count_index < #defense_platform_count_options then
		if defense_platform_count_options[defense_platform_count_index + 1].count == "random" then
			addGMFunction(string.format("%i Platforms + -> Rnd",defense_platform_count_options[defense_platform_count_index].count),function()
				defense_platform_count_index = defense_platform_count_index + 1
				setDefensePlatformCount()
			end)
		else
			addGMFunction(string.format("%i Platforms + -> %i",defense_platform_count_options[defense_platform_count_index].count,defense_platform_count_options[defense_platform_count_index + 1].count),function()
				defense_platform_count_index = defense_platform_count_index + 1
				setDefensePlatformCount()
			end)
		end
	end
	if defense_platform_count_index > 1 then
		if defense_platform_count_options[defense_platform_count_index].count == "random" then
			addGMFunction(string.format("Rnd Platforms - -> %i",defense_platform_count_options[defense_platform_count_index - 1].count),function()
				defense_platform_count_index = defense_platform_count_index - 1
				setDefensePlatformCount()
			end)
		else
			addGMFunction(string.format("%i Platforms - -> %i",defense_platform_count_options[defense_platform_count_index].count,defense_platform_count_options[defense_platform_count_index - 1].count),function()
				defense_platform_count_index = defense_platform_count_index - 1
				setDefensePlatformCount()
			end)
		end
	end
end
--	Display player control codes
function showKraylorCodes()
	showControlCodes("Kraylor")
end
function showExuariCodes()
	showControlCodes("Exuari")
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
			elseif faction_filter == "Exuari" then
				if p:getFaction() == "Exuari" then
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
		elseif code_list[name].faction == "Exuari" then
			faction = " (Exuari)"
		end
		output = output .. string.format("%s: %s %s\n",name,code_list[name].code,faction)
	end
	addGMMessage(output)
end
--	General configuration functions
function setGameTimeLimit()
	clearGMFunctions()
	addGMFunction("-Main from Time",mainGMButtons)
	if game_time_limit < 6000 then
		addGMFunction(string.format("%i Add 5 -> %i",game_time_limit/60,game_time_limit/60 + 5),function()
			game_time_limit = game_time_limit + 300
			max_game_time = game_time_limit
			setGameTimeLimit()
		end)
	end
	if game_time_limit > 300 then
		addGMFunction(string.format("%i Del 5 -> %i",game_time_limit/60,game_time_limit/60 - 5),function()
			game_time_limit = game_time_limit - 300
			max_game_time = game_time_limit
			setGameTimeLimit()
		end)
	end
end
function setMissileAvailability()
	clearGMFunctions()
	addGMFunction("-Main from Missiles",mainGMButtons)
	addGMFunction("-Terrain",setTerrainParameters)
	local button_label = "unlimited"
	if missile_availability == "unlimited" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		missile_availability = "unlimited"
		setMissileAvailability()
	end)
	button_label = "outer limited"
	if missile_availability == "outer limited" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		missile_availability = "outer limited"
		setMissileAvailability()
	end)
	button_label = "limited"
	if missile_availability == "limited" then
		button_label = button_label .. "*"
	end
	addGMFunction(button_label,function()
		missile_availability = "limited"
		setMissileAvailability()
	end)
end
function setNPCShips()
	clearGMFunctions()
	addGMFunction("-From NPC Strength",mainGMButtons)
	local button_label = "NPC Ships: No"
	if npc_ships then
		button_label = string.format("NPC Ships: %i-%i",npc_lower,npc_upper)
	end
	addGMFunction(button_label,function()
		if npc_ships then
			npc_ships = false
		else
			npc_ships = true
		end
		setNPCShips()
	end)
	if npc_ships then
		if npc_lower < npc_upper - 5 then
			addGMFunction(string.format("%i From Add -> %i",npc_lower,npc_lower + 5),function()
				npc_lower = npc_lower + 5
				setNPCShips()
			end)
		end
		if npc_lower > 10 then
			addGMFunction(string.format("%i From Del -> %i",npc_lower,npc_lower - 5),function()
				npc_lower = npc_lower - 5
				setNPCShips()
			end)
		end
		if npc_upper < 200 then
			addGMFunction(string.format("%i To Add -> %i",npc_upper,npc_upper + 5),function()
				npc_upper = npc_upper + 5
				setNPCShips()
			end)
		end
		if npc_upper > npc_lower + 5 then
			addGMFunction(string.format("%i To Del -> %i",npc_upper,npc_upper - 5),function()
				npc_upper = npc_upper - 5
				setNPCShips()
			end)
		end
	end
end
-------------------------------------
--	Generate terrain and stations  --
-------------------------------------
function generateTerrain()
--	Activities include:
--		Central terrain feature
--		Angle from center for each faction (used to place objects symmetrically)
--		Primary station and any defense platforms and/or defensive warp jammers
--		Positioning players around primary station
--		Placing other stations with varying capabilities and capacities
--		Wormholes, black holes, asteroids and nebulae
	if terrain_generated then
		return
	end
	terrain_generated = true
	terrain_center_x = random(200000,300000)
	terrain_center_y = random(100000,200000)
	local ta = Asteroid():setPosition(terrain_center_x,terrain_center_y)
	local terrain_center_sector = ta:getSectorName()
	addGMMessage(string.format("The center of the universe is in sector\n%s",terrain_center_sector))
	ta:destroy()
	place_ref_list = {}
	human_ref_list = {}
	
	--	decide what lives at the center of the universe
	local center_choice_list = {"Planet","Star","Black Hole"}
	local center_choice = center_choice_list[math.random(1,#center_choice_list)]
	if center_choice == "Planet" then
		local center_planet, center_radius = choosePlanet(math.random(2,3),terrain_center_x,terrain_center_y)
		table.insert(place_ref_list,center_planet)
		if random(1,100) <= 50 then
			local mx, my = vectorFromAngleNorth(random(0,360),center_radius + random(1000,2000))
			local moon = choosePlanet(4,terrain_center_x + mx,terrain_center_y + my)
			moon:setOrbit(center_planet,random(200,400))
			table.insert(place_ref_list,moon)
		end
	elseif center_choice == "Star" then
		local center_star, star_radius = choosePlanet(1,terrain_center_x,terrain_center_y)
		table.insert(place_ref_list,center_star)
		if random(1,100) <= 75 then
			local plx, ply = vectorFromAngleNorth(random(0,360),star_radius + random(8000,15000))
			local orbit_planet, orbit_radius = choosePlanet(math.random(2,3),terrain_center_x + plx,terrain_center_y + ply)
			orbit_planet:setOrbit(center_star,random(800,2000))
			table.insert(place_ref_list,orbit_planet)
			if random(1,100) <= 50 then
				local omx, omy = vectorFromAngleNorth(random(0,360),orbit_radius + random(1000,2000))
				local orbit_moon = choosePlanet(4,terrain_center_x + plx + omx,terrain_center_y + ply + omy)
				orbit_moon:setOrbit(orbit_planet,random(200,400))
				table.insert(place_ref_list,orbit_moon)
			end
		end
	elseif center_choice == "Black Hole" then
		local black_hole_names = {
			"Fornax A",
			"Sagittarius A",
			"Triangulum",
			"Cygnus X-3",
			"Messier 110",
			"Virgo A",
			"Andromeda",
			"Sombrero",
			"Great Annihilator",
		}
		table.insert(place_ref_list,BlackHole():setPosition(terrain_center_x,terrain_center_y):setCallSign(black_hole_names[math.random(1,#black_hole_names)]))
	end
	
	--	Set angles
	faction_angle = {}
	npc_fleet = {}
	npc_fleet["Human Navy"] = {}
	npc_fleet["Kraylor"] = {}
	human_angle = random(0,360)
	faction_angle["Human Navy"] = human_angle
	local replicant_increment = 360/player_team_count
	kraylor_angle = (human_angle + replicant_increment) % 360
	faction_angle["Kraylor"] = kraylor_angle
	if player_team_count > 2 then
		exuari_angle = (kraylor_angle + replicant_increment) % 360
		faction_angle["Exuari"] = exuari_angle
		npc_fleet["Exuari"] = {}
	end
	if player_team_count > 3 then
		ktlitan_angle = (exuari_angle + replicant_increment) % 360
		faction_angle["Ktlitans"] = ktlitan_angle
		npc_fleet["Ktlitans"] = {}
	end
	
	if respawn_type == "self" then
		death_penalty = {}
		death_penalty["Human Navy"] = 0
		death_penalty["Kraylor"] = 0
		if exuari_angle ~= nil then
			death_penalty["Exuari"] = 0
		end
		if ktlitan_angle ~= nil then
			death_penalty["Ktlitans"] = 0
		end
	end
	
	--	Set primary stations
	local primary_station_distance = random(50000,100000)
	local primary_station_size = primary_station_size_options[primary_station_size_index]
	if primary_station_size == "random" then
		primary_station_size = szt()
	end
	base_station_value_list = {
		["Huge Station"] 	= 10,
		["Large Station"]	= 5,
		["Medium Station"]	= 3,
		["Small Station"]	= 1,
	}
	faction_primary_station = {}
	local psx, psy = vectorFromAngleNorth(human_angle,primary_station_distance)
	station_primary_human = placeStation(terrain_center_x + psx, terrain_center_y + psy, "Random","Human Navy",primary_station_size)
	faction_primary_station["Human Navy"] = {x = terrain_center_x + psx, y = terrain_center_y + psy, station = station_primary_human}
	station_primary_human.score_value = base_station_value_list[primary_station_size] + 10
	station_list["Human Navy"] = {}
	table.insert(station_list["Human Navy"],station_primary_human)
	table.insert(place_ref_list,station_primary_human)
	table.insert(human_ref_list,station_primary_human)
	local unlimited_missiles = true
	if missile_availability == "limited" then
		unlimited_missiles = false
	end
	station_primary_human.comms_data = {
    	friendlyness = random(75,100),
        weapon_cost =		{
        	Homing =	math.random(1,6), 		
        	Nuke =		math.random(10,30),					
        	Mine =		math.random(2,25),
        	EMP =		math.random(8,20), 
        	HVLI =		math.random(1,4),				
        },
		weapon_available = 	{
			Homing =			true,
			Nuke =				true,
			Mine =				true,
			EMP =				true,
			HVLI =				true,
		},
		weapon_inventory = {
			Unlimited =	unlimited_missiles,
			Homing =	math.floor(math.random(10,50)/difficulty),
			Nuke =		math.floor(math.random(5,30)/difficulty),
			Mine =		math.floor(math.random(8,40)/difficulty),
			EMP =		math.floor(math.random(6,34)/difficulty),
			HVLI =		math.floor(math.random(15,70)/difficulty),
		},
		services = {
			supplydrop = "friend",
			reinforcements = "friend",
			jumpsupplydrop = "friend",
            sensor_boost = "neutral",
			preorder = "friend",
            activatedefensefleet = "neutral",
            jumpovercharge = "neutral",
			jumpsupplydrop = "friend",
		},
		service_cost = {
			supplydrop =		math.random(80,120), 
			reinforcements =	math.random(125,175),
			hornetreinforcements =	math.random(75,125),
			phobosreinforcements =	math.random(175,225),
			jumpsupplydrop =	math.random(110,140),
            activatedefensefleet = math.random(15,40),
            jumpovercharge =	math.random(10,20),
			jumpsupplydrop =	math.random(110,150),
		},
		jump_overcharge =		true,
		probe_launch_repair =	true,
		hack_repair =			true,
		scan_repair =			true,
		combat_maneuver_repair=	true,
		self_destruct_repair =	true,
		tube_slow_down_repair =	true,
        sensor_boost = {value = primary_station_distance-35000, cost = 0},
		reputation_cost_multipliers = {
			friend = 			1.0, 
			neutral = 			3.0,
		},
        max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
        goods = {	food = 		{quantity = 10,		cost = 1},
        			medicine =	{quantity = 10,		cost = 5}	},
        trade = {	food = false, medicine = false, luxury = false },
	}
	station_primary_human.comms_data.idle_defense_fleet = defense_fleet_list[primary_station_size][math.random(1,#defense_fleet_list[primary_station_size])]
	psx, psy = vectorFromAngleNorth(kraylor_angle,primary_station_distance)
	station_primary_kraylor = placeStation(terrain_center_x + psx, terrain_center_y + psy, "Random","Kraylor",primary_station_size)
	faction_primary_station["Kraylor"] = {x = terrain_center_x + psx, y = terrain_center_y + psy, station = station_primary_kraylor}
	station_primary_kraylor.score_value = base_station_value_list[primary_station_size] + 10
	station_list["Kraylor"] = {}
	table.insert(station_list["Kraylor"],station_primary_kraylor)
	table.insert(place_ref_list,station_primary_kraylor)
	station_primary_kraylor.comms_data = station_primary_human.comms_data
	if exuari_angle ~= nil then
		psx, psy = vectorFromAngleNorth(exuari_angle,primary_station_distance)
		station_primary_exuari = placeStation(terrain_center_x + psx, terrain_center_y + psy, "Random","Exuari",primary_station_size)
		faction_primary_station["Exuari"] = {x = terrain_center_x + psx, y = terrain_center_y + psy, station = station_primary_exuari}
		station_primary_exuari.score_value = base_station_value_list[primary_station_size] + 10
		station_list["Exuari"] = {}
		table.insert(station_list["Exuari"],station_primary_exuari)
		table.insert(place_ref_list,station_primary_exuari)
		station_primary_exuari.comms_data = station_primary_human.comms_data
	end
	if ktlitan_angle ~= nil then
		psx, psy = vectorFromAngleNorth(ktlitan_angle,primary_station_distance)
		station_primary_ktlitan = placeStation(terrain_center_x + psx, terrain_center_y + psy, "Random","Ktlitans",primary_station_size)
		faction_primary_station["Ktlitans"] = {x = terrain_center_x + psx, y = terrain_center_y + psy, station = station_primary_ktlitan}
		station_primary_ktlitan.score_value = base_station_value_list[primary_station_size] + 10
		station_list["Ktlitans"] = {}
		table.insert(station_list["Ktlitans"],station_primary_ktlitan)
		table.insert(place_ref_list,station_primary_ktlitan)
		station_primary_ktlitan.comms_data = station_primary_human.comms_data
	end
	
	--	Set defense platforms and jammers (if applicable)
	defense_platform_count = defense_platform_count_options[defense_platform_count_index].count
	defense_platform_distance = defense_platform_count_options[defense_platform_count_index].distance
	player_position_distance = defense_platform_count_options[defense_platform_count_index].player
	if defense_platform_count == "random" then
		local index = math.random(1,#defense_platform_count_options - 1)
		defense_platform_count = defense_platform_count_options[index].count
		defense_platform_distance = defense_platform_count_options[index].distance
		player_position_distance = defense_platform_count_options[index].player
	end
	if primary_jammers == "random" then
		primary_jammers = random(1,100) < 50
	else
		if primary_jammers == "on" then
			primary_jammers = true
		else
			primary_jammers = false
		end
	end
	local angle = human_angle
	local vx = 0
	local vy = 0
	unlimited_missiles = false
	if missile_availability == "unlimited" then
		unlimited_missiles = true
	end
	if defense_platform_count > 0 then
		local dp = nil
		angle = human_angle
		psx, psy = station_primary_human:getPosition()
		local dp_list = {}
		for i=1,defense_platform_count do
			vx, vy = vectorFromAngleNorth(angle,defense_platform_distance)
			dp = CpuShip():setTemplate("Defense platform"):setFaction("Human Navy"):setPosition(psx + vx,psy + vy):setScannedByFaction("Human Navy",true):setCallSign(string.format("HDP%i",i)):setDescription(string.format("%s defense platform %i",station_primary_human:getCallSign(),i)):orderRoaming()
			dp.score_value = 50
			table.insert(npc_fleet["Human Navy"],dp)
			dp:setCommsScript(""):setCommsFunction(commsDefensePlatform)
			dp.primary_station = station_primary_human
			if primary_jammers then
				vx, vy = vectorFromAngleNorth(angle,defense_platform_distance/2)
				WarpJammer():setPosition(psx + vx, psy + vy):setRange(defense_platform_distance/2 + 4000):setFaction("Human Navy")
			end
			dp.comms_data = {	--defense platform comms data
				weapon_available = 	{
					Homing =			random(1,13)<=(3-difficulty),
					HVLI =				random(1,13)<=(6-difficulty),
					Mine =				false,
					Nuke =				false,
					EMP =				false,
				},
				weapon_inventory = {
					Unlimited =	unlimited_missiles,
					Homing =	math.floor(math.random(10,50)/difficulty),
					Nuke =		0,
					Mine =		0,
					EMP =		0,
					HVLI =		math.floor(math.random(15,70)/difficulty),
				},
				services = {
					supplydrop = "friend",
					reinforcements = "friend",
					jumpsupplydrop = "friend",
				},
				service_cost = {
					supplydrop =		math.random(80,120), 
					reinforcements =	math.random(125,175),
					jumpsupplydrop =	math.random(110,140),
				},
				jump_overcharge =		false,
				probe_launch_repair =	random(1,100) <= (20 - difficulty*2.5),
				hack_repair =			random(1,100) <= (22 - difficulty*2.5),
				scan_repair =			random(1,100) <= (30 - difficulty*2.5),
				combat_maneuver_repair=	random(1,100) <= (15 - difficulty*2.5),
				self_destruct_repair =	random(1,100) <= (25 - difficulty*2.5),
				tube_slow_down_repair =	random(1,100) <= (18 - difficulty*2.5),
				reputation_cost_multipliers = {
					friend = 			1.0, 
					neutral = 			3.0,
				},
			}
			dp:setSharesEnergyWithDocked(random(1,100) <= (60 - difficulty*5))
			dp:setRepairDocked(random(1,100) <= (50 - difficulty*5))
			dp:setRestocksScanProbes(random(1,100) <= (40 - difficulty*5))
			table.insert(dp_list,dp)
			table.insert(place_ref_list,dp)
			table.insert(human_ref_list,dp)
			angle = (angle + 360/defense_platform_count) % 360
		end
		angle = kraylor_angle
		psx, psy = station_primary_kraylor:getPosition()
		for i=1,defense_platform_count do
			vx, vy = vectorFromAngleNorth(angle,defense_platform_distance)
			dp = CpuShip():setTemplate("Defense platform"):setFaction("Kraylor"):setPosition(psx + vx,psy + vy):setScannedByFaction("Kraylor",true):setCallSign(string.format("KDP%i",i)):setDescription(string.format("%s defense platform %i",station_primary_kraylor:getCallSign(),i)):orderRoaming()
			dp.score_value = 50
			table.insert(npc_fleet["Kraylor"],dp)
			dp:setCommsScript(""):setCommsFunction(commsDefensePlatform)
			dp.primary_station = station_primary_kraylor
			if primary_jammers then
				vx, vy = vectorFromAngleNorth(angle,defense_platform_distance/2)
				WarpJammer():setPosition(psx + vx, psy + vy):setRange(defense_platform_distance/2 + 4000):setFaction("Kraylor")
			end
			dp.comms_data = dp_list[i].comms_data	--replicate capabilities
			dp:setSharesEnergyWithDocked(dp_list[i]:getSharesEnergyWithDocked())
			dp:setRepairDocked(dp_list[i]:getRepairDocked())
			dp:setRestocksScanProbes(dp_list[i]:getRestocksScanProbes())
			table.insert(place_ref_list,dp)
			angle = (angle + 360/defense_platform_count) % 360
		end
		if exuari_angle ~= nil then
			angle = exuari_angle
			psx, psy = station_primary_exuari:getPosition()
			for i=1,defense_platform_count do
				vx, vy = vectorFromAngleNorth(angle,defense_platform_distance)
				dp = CpuShip():setTemplate("Defense platform"):setFaction("Exuari"):setPosition(psx + vx,psy + vy):setScannedByFaction("Exuari",true):setCallSign(string.format("EDP%i",i)):setDescription(string.format("%s defense platform %i",station_primary_exuari:getCallSign(),i)):orderRoaming()
				dp.score_value = 50
				table.insert(npc_fleet["Exuari"],dp)
				dp:setCommsScript(""):setCommsFunction(commsDefensePlatform)
				dp.primary_station = station_primary_exuari
				if primary_jammers then
					vx, vy = vectorFromAngleNorth(angle,defense_platform_distance/2)
					WarpJammer():setPosition(psx + vx, psy + vy):setRange(defense_platform_distance/2 + 4000):setFaction("Exuari")
				end
				dp.comms_data = dp_list[i].comms_data	--replicate capabilities
				dp:setSharesEnergyWithDocked(dp_list[i]:getSharesEnergyWithDocked())
				dp:setRepairDocked(dp_list[i]:getRepairDocked())
				dp:setRestocksScanProbes(dp_list[i]:getRestocksScanProbes())
				table.insert(place_ref_list,dp)
				angle = (angle + 360/defense_platform_count) % 360
			end
		end
		if ktlitan_angle ~= nil then
			angle = ktlitan_angle
			psx, psy = station_primary_ktlitan:getPosition()
			for i=1,defense_platform_count do
				vx, vy = vectorFromAngleNorth(angle,defense_platform_distance)
				dp = CpuShip():setTemplate("Defense platform"):setFaction("Ktlitans"):setPosition(psx + vx,psy + vy):setScannedByFaction("Ktlitans",true):setCallSign(string.format("BDP%i",i)):setDescription(string.format("%s defense platform %i",station_primary_ktlitan:getCallSign(),i)):orderRoaming()
				dp.score_value = 50
				table.insert(npc_fleet["Ktlitans"],dp)
				dp:setCommsScript(""):setCommsFunction(commsDefensePlatform)
				dp.primary_station = station_primary_ktlitan
				if primary_jammers then
					vx, vy = vectorFromAngleNorth(angle,defense_platform_distance/2)
					WarpJammer():setPosition(psx + vx, psy + vy):setRange(defense_platform_distance/2 + 4000):setFaction("Ktlitans")
				end
				dp.comms_data = dp_list[i].comms_data	--replicate capabilities
				dp:setSharesEnergyWithDocked(dp_list[i]:getSharesEnergyWithDocked())
				dp:setRepairDocked(dp_list[i]:getRepairDocked())
				dp:setRestocksScanProbes(dp_list[i]:getRestocksScanProbes())
				table.insert(place_ref_list,dp)
				angle = (angle + 360/defense_platform_count) % 360
			end
		end
	else	--no defense platforms
		if primary_jammers then
			local jammer_distance = 4000
			local jammer_range = 8000
			angle = human_angle
			psx, psy = station_primary_human:getPosition()
			for i=1,4 do
				vx, vy = vectorFromAngleNorth(angle,jammer_distance)
				local wj = WarpJammer():setPosition(psx + vx, psy + vy):setRange(jammer_range):setFaction("Human Navy")
				table.insert(place_ref_list,wj)
				table.insert(human_ref_list,wj)
				angle = (angle + 90) % 360
			end
			angle = kraylor_angle
			psx, psy = station_primary_kraylor:getPosition()
			for i=1,4 do
				vx, vy = vectorFromAngleNorth(angle,jammer_distance)
				table.insert(place_ref_list,WarpJammer():setPosition(psx + vx, psy + vy):setRange(jammer_range):setFaction("Kraylor"))
				angle = (angle + 90) % 360
			end
			if exuari_angle ~= nil then
				angle = exuari_angle
				psx, psy = station_primary_exuari:getPosition()
				for i=1,4 do
					vx, vy = vectorFromAngleNorth(angle,jammer_distance)
					table.insert(place_ref_list,WarpJammer():setPosition(psx + vx, psy + vy):setRange(jammer_range):setFaction("Exuari"))
					angle = (angle + 90) % 360
				end
			end
			if ktlitan_angle ~= nil then
				angle = ktlitan_angle
				psx, psy = station_primary_ktlitan:getPosition()
				for i=1,4 do
					vx, vy = vectorFromAngleNorth(angle,jammer_distance)
					table.insert(place_ref_list,WarpJammer():setPosition(psx + vx, psy + vy):setRange(jammer_range):setFaction("Ktlitans"))
					angle = (angle + 90) % 360
				end
			end
		end
	end
	
	--	Place players
	player_restart = {}
	if player_ship_types == "spawned" then
		local player_count = 0
		for pidx=1,32 do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				player_count = player_count + 1
			end
		end
		local out = ""
		if player_count < ships_per_team then
			if player_count == 0 then
				out = string.format("No player ships spawned. %i are required.\n\nUsing default ship set.",ships_per_team)
			elseif player_count == 1 then
				out = string.format("Only one player ship spawned. %i are required.\n\nUsing default ship set.",ships_per_team)
			else
				out = string.format("Only %i player ships spawned. %i are required.\n\nUsing default ship set.",player_count,ships_per_team)
			end
			player_ship_types = "default"
			addGMMessage(out)
			placeDefaultPlayerShips()
		elseif player_count > ships_per_team then
			if ships_per_team == 1 then
				out = string.format("%i player ships spawned. Only %i is required.\n\nUsing default ship set.",player_count,ships_per_team)
			else
				out = string.format("%i player ships spawned. Only %i are required.\n\nUsing default ship set.",player_count,ships_per_team)
			end
			player_ship_types = "default"
			addGMMessage(out)
			placeDefaultPlayerShips()
		end
		psx, psy = station_primary_human:getPosition()
		angle = human_angle
		for pidx=1,ships_per_team do
			local p = getPlayerShip(pidx)
			if p ~= nil and p:isValid() then
				setPlayer(p)
				startPlayerPosition(p,angle)
				local respawn_x, respawn_y = p:getPosition()
				p.respawn_x = respawn_x
				p.respawn_y = respawn_y
				player_restart[p:getCallSign()] = {self = p, template = p:getTypeName(), control_code = p.control_code, faction = p:getFaction(), respawn_x = respawn_x, respawn_y = respawn_y}
				angle = (angle + 360/ships_per_team) % 360
			else
				addGMMessage("One of the player ships spawned is not valid, switching to default ship set")
				player_ship_types = "default"
				break
			end
		end
		if player_ship_types == "default" then
			placeDefaultPlayerShips()
		else
			replicatePlayers("Kraylor")
			if exuari_angle ~= nil then
				replicatePlayers("Exuari")
			end
			if ktlitan_angle ~= nil then
				replicatePlayers("Ktlitans")
			end
		end
	elseif player_ship_types == "custom" then
		placeCustomPlayerShips()
	else	--default
		placeDefaultPlayerShips()
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			table.insert(place_ref_list,p)
			if p:getFaction() == "Human Navy" then
				table.insert(human_ref_list,p)
			end
		end
	end
	
	--	Place NPC ships (if applicable)
	local npc_fleet_count = 0
	if npc_ships then
		npc_fleet_count = math.random(1,ships_per_team)
		local fleet_index = 1
		local fleet_angle_increment = 360/npc_fleet_count
		for n=1,npc_fleet_count do
			local angle = (human_angle + n * fleet_angle_increment) % 360
			local fleet_strength = random(npc_lower,npc_upper)
			local pool_selectivity_choices = {"full","less/heavy","more/light"}
			pool_selectivity = pool_selectivity_choices[math.random(1,#pool_selectivity_choices)]
			local fleetComposition_choices = {"Random","Non-DB","Fighters","Chasers","Frigates","Beamers","Missilers","Adders","Drones"}
			fleetComposition = fleetComposition_choices[math.random(1,#fleetComposition_choices)]
			local fcx, fcy = vectorFromAngleNorth(angle,defense_platform_distance + 5000)
			psx, psy = station_primary_human:getPosition()
			local human_fleet = spawnRandomArmed(psx + fcx, psy + fcy, fleet_strength, fleet_index, nil, angle)
			fleet_index = fleet_index + 1
			for _, ship in ipairs(human_fleet) do
				ship.score_value = ship_template[ship:getTypeName()].strength
				ship:setScannedByFaction("Human Navy",true)
				table.insert(human_ref_list,ship)
				table.insert(place_ref_list,ship)
				table.insert(npc_fleet["Human Navy"],ship)
			end
			fleet_index = fleet_index + 1
			local fleet_prefix = generateCallSignPrefix()
			angle = (kraylor_angle + n * fleet_angle_increment) % 360
			for _, source_ship in ipairs(human_fleet) do
				local sx, sy = source_ship:getPosition()
				local obj_ref_angle = angleFromVectorNorth(sx, sy, terrain_center_x, terrain_center_y)
				local obj_ref_distance = distance(terrain_center_x, terrain_center_y, sx, sy)
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				local selected_template = source_ship:getTypeName()
				local ship = ship_template[selected_template].create("Kraylor",selected_template)
				ship.score_value = ship_template[selected_template].strength
				ship:setScannedByFaction("Kraylor",true)
				ship:setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
				ship:setCallSign(generateCallSign(fleet_prefix))
				ship:setCommsScript(""):setCommsFunction(commsShip)
				ship:orderIdle()
				ship:setHeading(angle)
				ship:setRotation(angle + 270)
				ship.fleetIndex = fleet_index
				table.insert(place_ref_list,ship)
				table.insert(npc_fleet["Kraylor"],ship)
			end
			if exuari_angle ~= nil then
				fleet_index = fleet_index + 1
				local fleet_prefix = generateCallSignPrefix()
				angle = (exuari_angle + n * fleet_angle_increment) % 360
				for _, source_ship in ipairs(human_fleet) do
					local sx, sy = source_ship:getPosition()
					local obj_ref_angle = angleFromVectorNorth(sx, sy, terrain_center_x, terrain_center_y)
					local obj_ref_distance = distance(terrain_center_x, terrain_center_y, sx, sy)
					obj_ref_angle = (obj_ref_angle + replicant_increment * 2) % 360
					local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
					local selected_template = source_ship:getTypeName()
					local ship = ship_template[selected_template].create("Exuari",selected_template)
					ship.score_value = ship_template[selected_template].strength
					ship:setScannedByFaction("Exuari",true)
					ship:setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
					ship:setCallSign(generateCallSign(fleet_prefix))
					ship:setCommsScript(""):setCommsFunction(commsShip)
					ship:orderIdle()
					ship:setHeading(angle)
					ship:setRotation(angle + 270)
					ship.fleetIndex = fleet_index
					table.insert(place_ref_list,ship)
					table.insert(npc_fleet["Exuari"],ship)
				end
			end
			if ktlitan_angle ~= nil then
				fleet_index = fleet_index + 1
				local fleet_prefix = generateCallSignPrefix()
				angle = (ktlitan_angle + n * fleet_angle_increment) % 360
				for _, source_ship in ipairs(human_fleet) do
					local sx, sy = source_ship:getPosition()
					local obj_ref_angle = angleFromVectorNorth(sx, sy, terrain_center_x, terrain_center_y)
					local obj_ref_distance = distance(terrain_center_x, terrain_center_y, sx, sy)
					obj_ref_angle = (obj_ref_angle + replicant_increment * 3) % 360
					local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
					local selected_template = source_ship:getTypeName()
					local ship = ship_template[selected_template].create("Ktlitans",selected_template)
					ship.score_value = ship_template[selected_template].strength
					ship:setScannedByFaction("Ktlitans",true)
					ship:setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
					ship:setCallSign(generateCallSign(fleet_prefix))
					ship:setCommsScript(""):setCommsFunction(commsShip)
					ship:orderIdle()
					ship:setHeading(angle)
					ship:setRotation(angle + 270)
					ship.fleetIndex = fleet_index
					table.insert(place_ref_list,ship)
					table.insert(npc_fleet["Ktlitans"],ship)
				end
			end
		end
	end

	--	Place stations
	local candidate_x = 0
	local candidate_y = 0
	local center_x = 0
	local center_y = 0
	local perimeter = 0
	local avg_dist = 0
	local bubble = 2500
	local team_station_count_list = {50,25,16,12}
	local stretch_bound = 0
	for i=1,team_station_count_list[player_team_count] do
		center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
		stretch_bound = 5000
		repeat
			candidate_x, candidate_y = vectorFromAngleNorth(random(0,360),random(math.min(avg_dist,5000),math.min(perimeter,50000) + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,math.max(perimeter/i,15000)))
		local sr_size = szt()
		local pStation = placeStation(candidate_x, candidate_y, "Random","Human Navy",sr_size)
		table.insert(station_list["Human Navy"],pStation)
		pStation.score_value = base_station_value_list[sr_size]
		table.insert(place_ref_list,pStation)
		table.insert(human_ref_list,pStation)
		pStation.comms_data = {
			friendlyness = random(15,100),
			weapon_cost =		{
				Homing =	math.random(2,8), 		
				Nuke =		math.random(12,30),					
				Mine =		math.random(3,28),
				EMP =		math.random(9,25), 
				HVLI =		math.random(2,5),				
			},
			weapon_available = 	{
				Homing =	random(1,13)<=(6-difficulty),
				HVLI =		random(1,13)<=(6-difficulty),
				Mine =		random(1,13)<=(5-difficulty),
				Nuke =		random(1,13)<=(4-difficulty),
				EMP =		random(1,13)<=(4-difficulty),
			},
			weapon_inventory = {
				Unlimited =	unlimited_missiles,
				Homing =	math.floor(math.random(10,40)/difficulty),
				Nuke =		math.floor(math.random(5,20)/difficulty),
				Mine =		math.floor(math.random(8,30)/difficulty),
				EMP =		math.floor(math.random(6,24)/difficulty),
				HVLI =		math.floor(math.random(15,50)/difficulty),
			},
			services = {
				supplydrop = "friend",
				reinforcements = "friend",
				jumpsupplydrop = "friend",
				sensor_boost = "neutral",
				preorder = "friend",
				activatedefensefleet = "neutral",
				jumpovercharge = "neutral",
			},
			service_cost = {
				supplydrop =		math.random(80,120), 
				reinforcements =	math.random(125,175),
				hornetreinforcements =	math.random(75,125),
				phobosreinforcements =	math.random(175,225),
				activatedefensefleet = math.random(15,40),
				jumpovercharge =	math.random(10,20),
				jumpsupplydrop =	math.random(110,140),
			},
			jump_overcharge =		random(1,100) <= (20 - difficulty*2.5),
			probe_launch_repair =	random(1,100) <= (33 - difficulty*2.5),
			hack_repair =			random(1,100) <= (42 - difficulty*2.5),
			scan_repair =			random(1,100) <= (50 - difficulty*2.5),
			combat_maneuver_repair=	random(1,100) <= (28 - difficulty*2.5),
			self_destruct_repair =	random(1,100) <= (25 - difficulty*2.5),
			tube_slow_down_repair =	random(1,100) <= (35 - difficulty*2.5),
			reputation_cost_multipliers = {
				friend = 			1.0, 
				neutral = 			3.0,
			},
			max_weapon_refill_amount = {friend = 1.0, neutral = 0.5 },
		}
		pStation.comms_data.idle_defense_fleet = defense_fleet_list[sr_size][math.random(1,#defense_fleet_list[sr_size])]
		pStation:setSharesEnergyWithDocked(random(1,100) <= (50 - difficulty*5))
		pStation:setRepairDocked(random(1,100) <= (40 - difficulty*5))
		pStation:setRestocksScanProbes(random(1,100) <= (30 - difficulty*5))
		if scientist_count < 5 then
			if random(1,100) < 20 then
				if scientist_list["Human Navy"] == nil then
					scientist_list["Human Navy"] = {}
				end
				table.insert(
					scientist_list["Human Navy"],
					{
						name = tableRemoveRandom(scientist_names), 
						topic = tableRemoveRandom(scientist_topics), 
						location = pStation, 
						location_name = pStation:getCallSign(), 
						score_value = scientist_score_value, 
						upgrade_requirement = upgrade_requirements[math.random(1,#upgrade_requirements)], 
						upgrade = tableRemoveRandom(upgrade_list),
						upgrade_automated_application = upgrade_automated_applications[math.random(1,#upgrade_automated_applications)],
					}
				)
				scientist_count = scientist_count + 1
			end
		end
		
		local obj_ref_angle = angleFromVectorNorth(candidate_x, candidate_y, terrain_center_x, terrain_center_y)
		local obj_ref_distance = distance(terrain_center_x, terrain_center_y, candidate_x, candidate_y)
		obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
		local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
		pStation = placeStation(terrain_center_x + rep_x, terrain_center_y + rep_y, "Random","Kraylor",sr_size)
		table.insert(station_list["Kraylor"],pStation)
		pStation.score_value = base_station_value_list[sr_size]
		pStation.comms_data = human_ref_list[#human_ref_list].comms_data
		pStation:setSharesEnergyWithDocked(human_ref_list[#human_ref_list]:getSharesEnergyWithDocked())
		pStation:setRepairDocked(human_ref_list[#human_ref_list]:getRepairDocked())
		pStation:setRestocksScanProbes(human_ref_list[#human_ref_list]:getRestocksScanProbes())
		table.insert(place_ref_list,pStation)
		if scientist_list["Human Navy"] ~= nil then
			if scientist_list["Kraylor"] == nil then
				scientist_list["Kraylor"] = {}
			end
			if #scientist_list["Kraylor"] < #scientist_list["Human Navy"] then
				table.insert(
					scientist_list["Kraylor"],
					{
						name = tableRemoveRandom(scientist_names), 
						topic = scientist_list["Human Navy"][#scientist_list["Human Navy"]].topic, 
						location = pStation, 
						location_name = pStation:getCallSign(), 
						score_value = scientist_score_value, 
						upgrade_requirement = upgrade_requirements[math.random(1,#upgrade_requirements)], 
						upgrade = scientist_list["Human Navy"][#scientist_list["Human Navy"]].upgrade,
						upgrade_automated_application = scientist_list["Human Navy"][#scientist_list["Human Navy"]].upgrade_automated_application,
					}
				)
			end
		end
		if exuari_angle ~= nil then
			obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
			rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
			pStation = placeStation(terrain_center_x + rep_x, terrain_center_y + rep_y, "Random","Exuari",sr_size)
			table.insert(station_list["Exuari"],pStation)
			pStation.score_value = base_station_value_list[sr_size]
			pStation.comms_data = human_ref_list[#human_ref_list].comms_data
			pStation:setSharesEnergyWithDocked(human_ref_list[#human_ref_list]:getSharesEnergyWithDocked())
			pStation:setRepairDocked(human_ref_list[#human_ref_list]:getRepairDocked())
			pStation:setRestocksScanProbes(human_ref_list[#human_ref_list]:getRestocksScanProbes())
			table.insert(place_ref_list,pStation)
			if scientist_list["Human Navy"] ~= nil then
				if scientist_list["Exuari"] == nil then
					scientist_list["Exuari"] = {}
				end
				if #scientist_list["Exuari"] < #scientist_list["Human Navy"] then
					table.insert(
						scientist_list["Exuari"],
						{
							name = tableRemoveRandom(scientist_names), 
							topic = scientist_list["Human Navy"][#scientist_list["Human Navy"]].topic, 
							location = pStation, 
							location_name = pStation:getCallSign(), 
							score_value = scientist_score_value, 
							upgrade_requirement = upgrade_requirements[math.random(1,#upgrade_requirements)], 
							upgrade = scientist_list["Human Navy"][#scientist_list["Human Navy"]].upgrade,
							upgrade_automated_application = scientist_list["Human Navy"][#scientist_list["Human Navy"]].upgrade_automated_application,
						}
					)
				end
			end
		end
		if ktlitan_angle ~= nil then
			obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
			rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
			pStation = placeStation(terrain_center_x + rep_x, terrain_center_y + rep_y, "Random","Ktlitans",sr_size)
			table.insert(station_list["Ktlitans"],pStation)
			pStation.score_value = base_station_value_list[sr_size]
			pStation.comms_data = human_ref_list[#human_ref_list].comms_data
			pStation:setSharesEnergyWithDocked(human_ref_list[#human_ref_list]:getSharesEnergyWithDocked())
			pStation:setRepairDocked(human_ref_list[#human_ref_list]:getRepairDocked())
			pStation:setRestocksScanProbes(human_ref_list[#human_ref_list]:getRestocksScanProbes())
			table.insert(place_ref_list,pStation)
			if scientist_list["Human Navy"] ~= nil then
				if scientist_list["Ktlitans"] == nil then
					scientist_list["Ktlitans"] = {}
				end
				if #scientist_list["Ktlitans"] < #scientist_list["Human Navy"] then
					table.insert(
						scientist_list["Ktlitans"],
						{
							name = tableRemoveRandom(scientist_names), 
							topic = scientist_list["Human Navy"][#scientist_list["Human Navy"]].topic, 
							location = pStation, 
							location_name = pStation:getCallSign(), 
							score_value = scientist_score_value, 
							upgrade_requirement = upgrade_requirements[math.random(1,#upgrade_requirements)], 
							upgrade = scientist_list["Human Navy"][#scientist_list["Human Navy"]].upgrade,
							upgrade_automated_application = scientist_list["Human Navy"][#scientist_list["Human Navy"]].upgrade_automated_application,
						}
					)
				end
			end
		end
	end	--station build loop
	
	--	Build some wormholes if applicable
	local hole_list = {}
	local wormhole_count = math.random(0,3)
	if wormhole_count > 0 then
		for w=1,wormhole_count do
			center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
			stretch_bound = 5000
			bubble = 6000
			repeat
--				print("wormhole candidate numbers. average distance:",avg_dist,"perimeter:",perimeter)
				candidate_x, candidate_y = vectorFromAngleNorth(random(0,360),random(math.min(avg_dist,20000),math.min(perimeter,100000) + stretch_bound))
				candidate_x = center_x + candidate_x
				candidate_y = center_y + candidate_y
				stretch_bound = stretch_bound + 500
			until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
			local wormhole = WormHole():setPosition(candidate_x,candidate_y)
			table.insert(place_ref_list,wormhole)
			table.insert(human_ref_list,wormhole)
			table.insert(hole_list,wormhole)
			center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
			stretch_bound = 5000
			local target_candidate_x = 0
			local target_candidate_y = 0
			repeat
				target_candidate_x, target_candidate_y = vectorFromAngleNorth(random(0,360),random(avg_dist,50000 + perimeter + stretch_bound))
				target_candidate_x = center_x + target_candidate_x
				target_candidate_y = center_y + target_candidate_y
				stretch_bound = stretch_bound + 500
			until(farEnough(place_ref_list,target_candidate_x,target_candidate_y,bubble))
			local ta = VisualAsteroid():setPosition(target_candidate_x,target_candidate_y)
			table.insert(place_ref_list,ta)
			table.insert(human_ref_list,ta)
			wormhole:setTargetPosition(target_candidate_x,target_candidate_y)
			
			local obj_ref_angle = angleFromVectorNorth(candidate_x, candidate_y, terrain_center_x, terrain_center_y)
			local obj_ref_distance = distance(terrain_center_x, terrain_center_y, candidate_x, candidate_y)
			obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
			local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
			wormhole = WormHole():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			table.insert(place_ref_list,wormhole)
			table.insert(hole_list,wormhole)
			local target_ref_angle = angleFromVectorNorth(target_candidate_x, target_candidate_y, terrain_center_x, terrain_center_y)
			local target_ref_distance = distance(terrain_center_x, terrain_center_y, target_candidate_x, target_candidate_y)
			target_ref_angle = (target_ref_angle + replicant_increment) % 360
			rep_x, rep_y = vectorFromAngleNorth(target_ref_angle,target_ref_distance)
			wormhole:setTargetPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			
			if exuari_angle ~= nil then
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				wormhole = WormHole():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
				table.insert(place_ref_list,wormhole)
				table.insert(hole_list,wormhole)
				target_ref_angle = (target_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(target_ref_angle,target_ref_distance)
				wormhole:setTargetPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			end
			if ktlitan_angle ~= nil then
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				wormhole = WormHole():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
				table.insert(place_ref_list,wormhole)
				table.insert(hole_list,wormhole)
				target_ref_angle = (target_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(target_ref_angle,target_ref_distance)
				wormhole:setTargetPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			end
		end
	end	--wormhole build
	
	--	Maybe sprinkle in some black holes
	local blackhole_count = math.random(0,6)
	if blackhole_count > 0 then
		for b=1,blackhole_count do
			center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
			stretch_bound = 5000
			bubble = 6000
			repeat
				candidate_x, candidate_y = vectorFromAngleNorth(random(0,360),random(math.min(avg_dist,20000),math.min(perimeter,100000) + stretch_bound))
				candidate_x = center_x + candidate_x
				candidate_y = center_y + candidate_y
				stretch_bound = stretch_bound + 500
			until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
			local blackhole = BlackHole():setPosition(candidate_x,candidate_y)
			table.insert(place_ref_list,blackhole)
			table.insert(human_ref_list,blackhole)
			table.insert(hole_list,blackhole)
			local obj_ref_angle = angleFromVectorNorth(candidate_x, candidate_y, terrain_center_x, terrain_center_y)
			local obj_ref_distance = distance(terrain_center_x, terrain_center_y, candidate_x, candidate_y)
			obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
			local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
			blackhole = BlackHole():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			table.insert(place_ref_list,blackhole)
			table.insert(hole_list,blackhole)
			if exuari_angle ~= nil then
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				blackhole = BlackHole():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
				table.insert(place_ref_list,blackhole)
				table.insert(hole_list,blackhole)
			end
			if ktlitan_angle ~= nil then
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				blackhole = BlackHole():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
				table.insert(place_ref_list,blackhole)
				table.insert(hole_list,blackhole)
			end
		end
	end	--blackhole build
	
	local mine_field_count = math.random(0,(6-player_team_count))
	local mine_field_type_list = {"line","arc"}
	if mine_field_count > 0 then
		for m=1,mine_field_count do
			center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
			stretch_bound = 5000
			bubble = 6000
			repeat
				candidate_x, candidate_y = vectorFromAngleNorth(random(0,360),random(math.min(avg_dist,20000),math.min(perimeter,100000) + stretch_bound))
				candidate_x = center_x + candidate_x
				candidate_y = center_y + candidate_y
				stretch_bound = stretch_bound + 500
			until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
			local mine_field_type = mine_field_type_list[math.random(1,#mine_field_type_list)]
			local mine_list = {}
			local mine_ref_list = {}
			if mine_field_type == "line" then
				local mle_x, mle_y = vectorFromAngleNorth(random(0,360),random(8000,30000))
				mine_list = createObjectsListOnLine(candidate_x + mle_x, candidate_y + mle_y, candidate_x, candidate_y, 1200, Mine, math.random(1,3))
				for i=1,#mine_list do
					local tm = mine_list[i]
					local mx, my = tm:getPosition()
					if farEnough(place_ref_list,mx,my,1000) and farEnough(mine_ref_list,mx,my,1000) then
						table.insert(mine_ref_list,tm)
						local obj_ref_angle = angleFromVectorNorth(mx, my, terrain_center_x, terrain_center_y)
						local obj_ref_distance = distance(terrain_center_x, terrain_center_y, mx, my)
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(mine_ref_list,Mine():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y))
						if exuari_angle ~= nil then
							obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
							rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
							table.insert(mine_ref_list,Mine():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y))
						end
						if ktlitan_angle ~= nil then
							obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
							rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
							table.insert(mine_ref_list,Mine():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y))
						end
					else
						tm:destroy()
					end
				end
				for _, tm in ipairs(mine_ref_list) do
					table.insert(place_ref_list,tm)
				end
			elseif mine_field_type == "arc" then
				local arc_radius = random(8000,25000)
				local mid_angle = random(0,360)
				local spread = random(10,30)
				local angle = (mid_angle + (180 - spread) % 360)
				local mar_x, mar_y = vectorFromAngleNorth(angle,arc_radius)
				local mar_x = mar_x + candidate_x
				local mar_y = mar_y + candidate_y
				local final_angle = (mid_angle + (180 + spread)) % 360
				local mine_count = 0
				local mx, my = vectorFromAngleNorth(angle,arc_radius)
				local tm = Mine():setPosition(mar_x + mx, mar_y + my)
				table.insert(mine_list,tm)
				local angle_increment = 0
				repeat
					angle_increment = angle_increment + 0.1
					mx, my = vectorFromAngleNorth(angle + angle_increment,arc_radius)
				until(distance(tm,mar_x + mx, mar_y + my) > 1200)
				if final_angle <= angle then
					final_angle = final_angle + 360
				end
				repeat
					angle = angle + angle_increment
					mx, my = vectorFromAngleNorth(angle,arc_radius)
					tm = Mine():setPosition(mar_x + mx, mar_y + my)
					table.insert(mine_list,tm)
				until(angle > final_angle)
				for i=1,#mine_list do
					local tm = mine_list[i]
					local mx, my = tm:getPosition()
					if farEnough(place_ref_list,mx,my,1000) and farEnough(mine_ref_list,mx,my,1000) then
						table.insert(mine_ref_list,tm)
						local obj_ref_angle = angleFromVectorNorth(mx, my, terrain_center_x, terrain_center_y)
						local obj_ref_distance = distance(terrain_center_x, terrain_center_y, mx, my)
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(mine_ref_list,Mine():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y))
						if exuari_angle ~= nil then
							obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
							rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
							table.insert(mine_ref_list,Mine():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y))
						end
						if ktlitan_angle ~= nil then
							obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
							rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
							table.insert(mine_ref_list,Mine():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y))
						end
					else
						tm:destroy()
					end
				end
				for _, tm in ipairs(mine_ref_list) do
					table.insert(place_ref_list,tm)
				end
			end
		end
	end
	
	--	Asteroid build
	local asteroid_field_count = math.random(2,(10-player_team_count))
	local asteroid_field_type_list = {"blob","line","arc"}
	for a=1,asteroid_field_count do
		center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
		stretch_bound = 5000
		bubble = 6000
		repeat
			candidate_x, candidate_y = vectorFromAngleNorth(random(0,360),random(math.min(avg_dist,20000),math.min(perimeter,100000) + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(place_ref_list,candidate_x,candidate_y,bubble))
		local asteroid_field_type = asteroid_field_type_list[math.random(1,#asteroid_field_type_list)]
		local asteroid_list = {}
		local asteroid_ref_list = {}
		if asteroid_field_type == "blob" then
			local blob_count = math.random(10,30)
--			print("blob count:",blob_count)
			asteroid_list = placeRandomListAroundPoint(Asteroid,blob_count,100,15000,candidate_x,candidate_y)
			for i=1,#asteroid_list do
				local ta = asteroid_list[i]
				local ax, ay = ta:getPosition()
				local as = asteroidSize()
				if farEnough(place_ref_list,ax,ay,as) and farEnough(asteroid_ref_list,ax,ay,as) then
					ta:setSize(as)
					table.insert(asteroid_ref_list,ta)
					local obj_ref_angle = angleFromVectorNorth(ax, ay, terrain_center_x, terrain_center_y)
					local obj_ref_distance = distance(terrain_center_x, terrain_center_y, ax, ay)
					obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
					local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
					table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					if exuari_angle ~= nil then
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					end
					if ktlitan_angle ~= nil then
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					end
				else
					ta:destroy()
				end
			end
			for _, ta in ipairs(asteroid_ref_list) do
				table.insert(place_ref_list,ta)
			end
		elseif asteroid_field_type == "line" then
--			print("asteroid line")
			local ale_x, ale_y = vectorFromAngleNorth(random(0,360),random(8000,30000))
			asteroid_list = createObjectsListOnLine(candidate_x + ale_x, candidate_y + ale_y, candidate_x, candidate_y, random(500,900), Asteroid, 7, 25, 250)
			for i=1,#asteroid_list do
				local ta = asteroid_list[i]
				local ax, ay = ta:getPosition()
				local as = asteroidSize()
				if farEnough(place_ref_list,ax,ay,as) and farEnough(asteroid_ref_list,ax,ay,as) then
					ta:setSize(as)
					table.insert(asteroid_ref_list,ta)
					local obj_ref_angle = angleFromVectorNorth(ax, ay, terrain_center_x, terrain_center_y)
					local obj_ref_distance = distance(terrain_center_x, terrain_center_y, ax, ay)
					obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
					local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
					table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					if exuari_angle ~= nil then
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					end
					if ktlitan_angle ~= nil then
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					end
				else
					ta:destroy()
				end
			end
			for _, ta in ipairs(asteroid_ref_list) do
				table.insert(place_ref_list,ta)
			end
		elseif asteroid_field_type == "arc" then
			local angle_to_radius = random(0,360)
			local radius_to_arc = random(8000,25000)
			local aar_x, aar_y = vectorFromAngleNorth(angle_to_radius,radius_to_arc)
			local spread = random(10,30)
			local number_in_arc = math.min(math.floor(spread * 2) + math.random(5,20),35)
--			print("asteroid arc number:",number_in_arc)
			asteroid_list = createRandomListAlongArc(Asteroid, number_in_arc, candidate_x + aar_x, candidate_y + aar_y, radius_to_arc, (angle_to_radius + (180-spread)) % 360, (angle_to_radius + (180+spread)) % 360, 1000)
			for i=1,#asteroid_list do
				local ta = asteroid_list[i]
				local ax, ay = ta:getPosition()
				local as = asteroidSize()
				if farEnough(place_ref_list,ax,ay,as) and farEnough(asteroid_ref_list,ax,ay,as) then
					ta:setSize(as)
					table.insert(asteroid_ref_list,ta)
					local obj_ref_angle = angleFromVectorNorth(ax, ay, terrain_center_x, terrain_center_y)
					local obj_ref_distance = distance(terrain_center_x, terrain_center_y, ax, ay)
					obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
					local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
					table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					if exuari_angle ~= nil then
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					end
					if ktlitan_angle ~= nil then
						obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
						rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
						table.insert(asteroid_ref_list,Asteroid():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y):setSize(as))
					end
				else
					ta:destroy()
				end
			end
			for _, ta in ipairs(asteroid_ref_list) do
				table.insert(place_ref_list,ta)
			end
		end
	end	--	asteroid fields build
	
	--	Nebula build
	local nebula_field_count = math.random(2,8)
	center_x, center_y, perimeter, avg_dist = analyzeBlob(human_ref_list)
	for n=1,nebula_field_count do
		stretch_bound = 5000
		bubble = 7000
		repeat
			candidate_x, candidate_y = vectorFromAngleNorth(random(0,360),random(math.min(avg_dist,20000),math.min(perimeter,100000) + stretch_bound))
			candidate_x = center_x + candidate_x
			candidate_y = center_y + candidate_y
			stretch_bound = stretch_bound + 500
		until(farEnough(hole_list,candidate_x,candidate_y,bubble))
		local neb = Nebula():setPosition(candidate_x,candidate_y)
		local nebula_field = {}
		table.insert(nebula_field,neb)
		local nebula_field_size = math.random(0,5)
		if nebula_field_size > 0 then
			for i=1,nebula_field_size do
				local na_x = 0
				local na_y = 0
				local nx = 0
				local ny = 0
				local attempts = 0
				repeat
					na_x, na_y = vectorFromAngleNorth(random(0,360),random(8000,9500))
					nx, ny = nebula_field[math.random(1,#nebula_field)]:getPosition()
					attempts = attempts + 1
				until(farEnough(hole_list, na_x + nx, na_y + ny, bubble) or attempts > 50)
				if attempts <= 50 then
					neb = Nebula():setPosition(na_x + nx, na_y + ny)
					table.insert(nebula_field,neb)
				else
					break
				end
			end
		end
		for i=1,#nebula_field do
			candidate_x, candidate_y = nebula_field[i]:getPosition()
			local obj_ref_angle = angleFromVectorNorth(candidate_x, candidate_y, terrain_center_x, terrain_center_y)
			local obj_ref_distance = distance(terrain_center_x, terrain_center_y, candidate_x, candidate_y)
			obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
			local rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
			Nebula():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			if exuari_angle ~= nil then
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				Nebula():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			end
			if ktlitan_angle ~= nil then
				obj_ref_angle = (obj_ref_angle + replicant_increment) % 360
				rep_x, rep_y = vectorFromAngleNorth(obj_ref_angle,obj_ref_distance)
				Nebula():setPosition(terrain_center_x + rep_x, terrain_center_y + rep_y)
			end
		end
	end	--	nebula field build
	game_state = "terrain generated"
	
	--	Store (then print) original values for later comparison
	local stat_list = gatherStats()
	original_score = {}
	local out = "Original scores:"
	original_score["Human Navy"] = stat_list.human.weighted_score
	out = out .. string.format("\nHuman Navy: %.2f",stat_list.human.weighted_score)
	original_score["Kraylor"] = stat_list.kraylor.weighted_score
	out = out .. string.format("\nKraylor: %.2f",stat_list.kraylor.weighted_score)
	if exuari_angle ~= nil then
		original_score["Exuari"] = stat_list.exuari.weighted_score
		out = out .. string.format("\nExuari: %.2f",stat_list.exuari.weighted_score)
	end
	if ktlitan_angle ~= nil then
		original_score["Ktlitans"] = stat_list.ktlitan.weighted_score
		out = out .. string.format("\nKtlitans: %.2f",stat_list.ktlitan.weighted_score)
	end
	allowNewPlayerShips(false)
	print(out)
	
	--	Provide summary terrain details in console log
	print("-----     Terrain Info     -----")
	print("Center:",terrain_center_sector,"featuring:",center_choice)
	print("Primary stations:",primary_station_size,"Jammers:",primary_jammers,"defense platforms:",defense_platform_count)
	local output_player_types = player_ship_types
	if player_ship_types == "custom" then
		output_player_types = output_player_types .. " (" .. custom_player_ship_type .. ")"
	end
	print("Teams:",player_team_count,"Player ships:",ships_per_team .. "(" .. ships_per_team*player_team_count .. ")","Player ship types:",output_player_types)
	print("NPC Fleets:",npc_fleet_count .. "(" .. npc_fleet_count*player_team_count .. ")")
	print("Wormholes:",wormhole_count .. "(" .. wormhole_count*player_team_count .. ")","Black holes:",blackhole_count .. "(" .. blackhole_count*player_team_count .. ")")
	print("Asteroid fields:",asteroid_field_count .. "(" .. asteroid_field_count*player_team_count .. ")","Nebula groups:",nebula_field_count .. "(" .. nebula_field_count*player_team_count .. ")")
end
function spawnRandomArmed(x, y, enemyStrength, fleetIndex, shape, angle)
--x and y are central spawn coordinates
--fleetIndex is the number of the fleet to be spawned
--sl (was) the score list, nl is the name list, bl is the boolean list
--spawn_distance optional - used for ambush or pyramid
--spawn_angle optional - used for ambush or pyramid
--px and py are the player coordinates or the pyramid fly towards point coordinates
	local sp = 1000			--spacing of spawned group
	if shape == nil then
		local shape_choices = {"square","hexagonal"}
		shape = shape_choices[math.random(1,#shape_choices)]
	end
	local enemy_position = 0
	local enemyList = {}
	local template_pool = getTemplatePool(enemyStrength)
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList
	end
	local fleet_prefix = generateCallSignPrefix()
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
--		print("selected template:",selected_template)
--		print("base:",ship_template[selected_template].base)
		local ship = ship_template[selected_template].create("Human Navy",selected_template)
		ship:setCallSign(generateCallSign(fleet_prefix))
		ship:setCommsScript(""):setCommsFunction(commsShip)
		ship:orderIdle()
		ship:setHeading(angle)
		ship:setRotation(angle + 270)
		enemy_position = enemy_position + 1
		ship:setPosition(x + formation_delta[shape].x[enemy_position] * sp, y + formation_delta[shape].y[enemy_position] * sp)
		ship.fleetIndex = fleetIndex
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
--	print("fleet composition:",fleetComposition,"fleet group sub fleet composition:",fleet_group[fleetComposition])
	if pool_selectivity == "less/heavy" then
		for _, current_ship_template in ipairs(ship_template_by_strength) do
--			print("currrent ship template:",current_ship_template,"strength:",ship_template[current_ship_template].strength,"max strength:",max_strength)
			if ship_template[current_ship_template].strength <= max_strength then
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
			if #template_pool >= 5 then
				break
			end
		end
	elseif pool_selectivity == "more/light" then
		for i=#ship_template_by_strength,1,-1 do
			local current_ship_template = ship_template_by_strength[i]
--			print("currrent ship template:",current_ship_template,"strength:",ship_template[current_ship_template].strength,"max strength:",max_strength)
			if ship_template[current_ship_template].strength <= max_strength then
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
			if #template_pool >= 20 then
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
function stockTemplate(enemyFaction,template)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate(template):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	return ship
end
--------------------------------------------------------------------------------------------
--	Additional enemy ships with some modifications from the original template parameters  --
--------------------------------------------------------------------------------------------
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Phobos R2")
	ship:setWeaponTubeCount(1)			--one tube (vs 2)
	ship:setWeaponTubeDirection(0,0)	
	ship:setImpulseMaxSpeed(55)			--slower impulse (vs 60)
	ship:setRotationMaxSpeed(15)		--faster maneuver (vs 10)
	local phobos_r2_db = queryScienceDatabase("Ships","Frigate","Phobos R2")
	if phobos_r2_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Phobos R2")
		phobos_r2_db = queryScienceDatabase("Ships","Frigate","Phobos R2")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			phobos_r2_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube",
			{
				{key = "Tube 0", value = "60 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("MV52 Hornet")
	ship:setBeamWeapon(0, 30, 0, 1000.0, 4.0, 3.0)	--longer and stronger beam (vs 700 & 3)
	ship:setRotationMaxSpeed(31)					--faster maneuver (vs 30)
	ship:setImpulseMaxSpeed(130)					--faster impulse (vs 120)
	local hornet_mv52_db = queryScienceDatabase("Ships","Starfighter","MV52 Hornet")
	if hornet_mv52_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("MV52 Hornet")
		hornet_mv52_db = queryScienceDatabase("Ships","Starfighter","MV52 Hornet")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","MT52 Hornet"),	--base ship database entry
			hornet_mv52_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The MV52 Hornet is very similar to the MT52 and MU52 models. The beam does more damage than both of the other Hornet models, it's max impulse speed is faster than both of the other Hornet models, it turns faster than the MT52, but slower than the MU52",
			nil,
			nil
		)
	end
	return ship
end
function k2fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K2 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	local k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
	if k2_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("K2 Fighter")
		k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
			k2_fighter_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is a bit weaker.",
			nil,
			nil		--jump range
		)
	end
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter"):orderRoaming()
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	local k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
	if k3_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("K3 Fighter")
		k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
			k3_fighter_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that are stronger and that cycle faster, but the hull is weaker.",
			nil,
			nil		--jump range
		)
	end
	return ship
end	
function waddle5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Waddle 5")
	ship:setWarpDrive(true)
--				   Index,  Arc,	  Dir, Range, Cycle,	Damage
	ship:setBeamWeapon(2,	70,	  -30,	 600,	5.0,	2.0)	--adjust beam direction to match starboard side (vs -35)
	local waddle_5_db = queryScienceDatabase("Ships","Starfighter","Waddle 5")
	if waddle_5_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Waddle 5")
		waddle_5_db = queryScienceDatabase("Ships","Starfighter","Waddle 5")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
			waddle_5_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function jade5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Jade 5")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)
--				   Index,  Arc,	  Dir, Range, Cycle,	Damage
	ship:setBeamWeapon(2,	70,	  -30,	 600,	5.0,	2.0)	--adjust beam direction to match starboard side (vs -35)
	local jade_5_db = queryScienceDatabase("Ships","Starfighter","Jade 5")
	if jade_5_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("Jade 5")
		jade_5_db = queryScienceDatabase("Ships","Starfighter","Jade 5")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
			jade_5_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
			},
			"5 - 35 U"		--jump range
		)
	end
	return ship
end
function droneLite(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Lite Drone")
	ship:setHullMax(20)					--weaker hull (vs 30)
	ship:setHull(20)
	ship:setImpulseMaxSpeed(130)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(20)		--faster maneuver (vs 10)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
	if drone_lite_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Lite Drone")
		drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			drone_lite_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The light drone was pieced together from scavenged parts of various damaged Ktlitan drones. Compared to the Ktlitan drone, the lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed",
			nil,
			nil
		)
	end
	return ship
end
function droneHeavy(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Heavy Drone")
	ship:setHullMax(40)					--stronger hull (vs 30)
	ship:setHull(40)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,8)	--stronger (vs 6) beam
	local drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
	if drone_heavy_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Heavy Drone")
		drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			drone_heavy_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower",
			nil,
			nil
		)
	end
	return ship
end
function droneJacket(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Jacket Drone")
	ship:setShieldsMax(20)				--stronger shields (vs none)
	ship:setShields(20)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local drone_jacket_db = queryScienceDatabase("Ships","No Class","Jacket Drone")
	if drone_jacket_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Jacket Drone")
		drone_jacket_db = queryScienceDatabase("Ships","No Class","Jacket Drone")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			drone_jacket_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield",
			nil,
			nil
		)
	end
	return ship
end
function wzLindworm(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("WX-Lindworm"):orderRoaming()
	ship:setTypeName("WZ-Lindworm")
	ship:setWeaponStorageMax("Nuke",2)		--more nukes (vs 0)
	ship:setWeaponStorage("Nuke",2)
	ship:setWeaponStorageMax("Homing",4)	--more homing (vs 1)
	ship:setWeaponStorage("Homing",4)
	ship:setWeaponStorageMax("HVLI",12)		--more HVLI (vs 6)
	ship:setWeaponStorage("HVLI",12)
	ship:setRotationMaxSpeed(12)			--slower maneuver (vs 15)
	ship:setHullMax(45)						--weaker hull (vs 50)
	ship:setHull(45)
	local wz_lindworm_db = queryScienceDatabase("Ships","Starfighter","WZ-Lindworm")
	if wz_lindworm_db == nil then
		local starfighter_db = queryScienceDatabase("Ships","Starfighter")
		starfighter_db:addEntry("WZ-Lindworm")
		wz_lindworm_db = queryScienceDatabase("Ships","Starfighter","WZ-Lindworm")
		addShipToDatabase(
			queryScienceDatabase("Ships","Starfighter","WX-Lindworm"),	--base ship database entry
			wz_lindworm_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop.",
			{
				{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Small tube 1", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Small tube -1", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function tempest(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F12"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Tempest")
	ship:setWeaponTubeCount(10)						--four more tubes (vs 6)
	ship:setWeaponTubeDirection(0, -88)				--5 per side
	ship:setWeaponTubeDirection(1, -89)				--slight angle spread
	ship:setWeaponTubeDirection(3,  88)				--3 for HVLI each side
	ship:setWeaponTubeDirection(4,  89)				--2 for homing and nuke each side
	ship:setWeaponTubeDirection(6, -91)				
	ship:setWeaponTubeDirection(7, -92)				
	ship:setWeaponTubeDirection(8,  91)				
	ship:setWeaponTubeDirection(9,  92)				
	ship:setWeaponTubeExclusiveFor(7,"HVLI")
	ship:setWeaponTubeExclusiveFor(9,"HVLI")
	ship:setWeaponStorageMax("Homing",16)			--more (vs 6)
	ship:setWeaponStorage("Homing", 16)				
	ship:setWeaponStorageMax("Nuke",8)				--more (vs 0)
	ship:setWeaponStorage("Nuke", 8)				
	ship:setWeaponStorageMax("HVLI",34)				--more (vs 20)
	ship:setWeaponStorage("HVLI", 34)
	local tempest_db = queryScienceDatabase("Ships","Frigate","Tempest")
	if tempest_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Tempest")
		tempest_db = queryScienceDatabase("Ships","Frigate","Tempest")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Piranha F12"),	--base ship database entry
			tempest_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!",
			{
				{key = "Large tube -88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -89", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Large tube -90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Large tube 88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube 89", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Large tube 90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -91", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Tube -92", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Tube 91", value = "15 sec"},		--torpedo tube direction and load speed
				{key = "Tube 92", value = "15 sec"},		--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function enforcer(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Blockade Runner"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Enforcer")
	ship:setRadarTrace("radar_ktlitan_destroyer.png")			--different radar trace
	ship:setWarpDrive(true)										--warp (vs none)
	ship:setWarpSpeed(600)
	ship:setImpulseMaxSpeed(100)								--faster impulse (vs 60)
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 15)
	ship:setShieldsMax(200,100,100)								--stronger shields (vs 100,150)
	ship:setShields(200,100,100)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	30,	  -15,	1500,		6,		10)	--narrower (vs 60), longer (vs 1000), stronger (vs 8)
	ship:setBeamWeapon(1,	30,	   15,	1500,		6,		10)
	ship:setBeamWeapon(2,	 0,	    0,	   0,		0,		 0)	--fewer (vs 4)
	ship:setBeamWeapon(3,	 0,	    0,	   0,		0,		 0)
	ship:setWeaponTubeCount(3)									--more (vs 0)
	ship:setTubeSize(0,"large")									--large (vs normal)
	ship:setWeaponTubeDirection(1,-30)				
	ship:setWeaponTubeDirection(2, 30)				
	ship:setWeaponStorageMax("Homing",18)						--more (vs 0)
	ship:setWeaponStorage("Homing", 18)
	local enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
	if enforcer_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Enforcer")
		enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Blockade Runner"),	--base ship database entry
			enforcer_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and strengthened front beams.",
			{
				{key = "Large tube 0", value = "20 sec"},	--torpedo tube direction and load speed
				{key = "Tube -30", value = "20 sec"},		--torpedo tube direction and load speed
				{key = "Tube 30", value = "20 sec"},		--torpedo tube direction and load speed
			},
			nil
		)
		enforcer_db:setImage("radar_ktlitan_destroyer.png")		--override default radar image
	end
	return ship		
end
function predator(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Predator")
	ship:setShieldsMax(100,100)									--stronger shields (vs 30,30)
	ship:setShields(100,100)					
	ship:setHullMax(80)											--stronger hull (vs 70)
	ship:setHull(80)
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 40)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,35000)			
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	    0,	1000,		6,		 4)	--more (vs 0)
	ship:setBeamWeapon(1,	90,	  180,	1000,		6,		 4)	
	ship:setWeaponTubeCount(8)									--more (vs 3)
	ship:setWeaponTubeDirection(0,-60)				
	ship:setWeaponTubeDirection(1,-90)				
	ship:setWeaponTubeDirection(2,-90)				
	ship:setWeaponTubeDirection(3, 60)				
	ship:setWeaponTubeDirection(4, 90)				
	ship:setWeaponTubeDirection(5, 90)				
	ship:setWeaponTubeDirection(6,-120)				
	ship:setWeaponTubeDirection(7, 120)				
	ship:setWeaponTubeExclusiveFor(0,"Homing")
	ship:setWeaponTubeExclusiveFor(1,"Homing")
	ship:setWeaponTubeExclusiveFor(2,"Homing")
	ship:setWeaponTubeExclusiveFor(3,"Homing")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeExclusiveFor(5,"Homing")
	ship:setWeaponTubeExclusiveFor(6,"Homing")
	ship:setWeaponTubeExclusiveFor(7,"Homing")
	ship:setWeaponStorageMax("Homing",32)						--more (vs 5)
	ship:setWeaponStorage("Homing", 32)		
	ship:setWeaponStorageMax("HVLI",0)							--less (vs 10)
	ship:setWeaponStorage("HVLI", 0)
	ship:setRadarTrace("radar_missile_cruiser.png")				--different radar trace
	local predator_db = queryScienceDatabase("Ships","Frigate","Predator")
	if predator_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Predator")
		predator_db = queryScienceDatabase("Ships","Frigate","Predator")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Piranha F8"),	--base ship database entry
			predator_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot.",
			{
				{key = "Large tube -60", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube -90", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Large tube -90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Large tube 60", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube 90", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Large tube 90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube -120", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Tube 120", value = "12 sec"},		--torpedo tube direction and load speed
			},
			"5 - 35 U"		--jump range
		)
		predator_db:setImage("radar_missile_cruiser.png")		--override default radar image
	end
	return ship		
end
function atlantisY42(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Atlantis X23"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Atlantis Y42")
	ship:setShieldsMax(300,200,300,200)							--stronger shields (vs 200,200,200,200)
	ship:setShields(300,200,300,200)					
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 3.5)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(2,	80,	  190,	1500,		6,		 8)	--narrower (vs 100)
	ship:setBeamWeapon(3,	80,	  170,	1500,		6,		 8)	--extra (vs 3 beams)
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)
	local atlantis_y42_db = queryScienceDatabase("Ships","Corvette","Atlantis Y42")
	if atlantis_y42_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Corvette")
		corvette_db:addEntry("Atlantis Y42")
		atlantis_y42_db = queryScienceDatabase("Ships","Corvette","Atlantis Y42")
		addShipToDatabase(
			queryScienceDatabase("Ships","Corvette","Atlantis X23"),	--base ship database entry
			atlantis_y42_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock",
			{
				{key = "Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
				{key = " Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
				{key = "Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
				{key = " Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
			},
			"5 - 50 U"		--jump range
		)
	end
	return ship		
end
function starhammerV(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Starhammer V")
	ship:setImpulseMaxSpeed(65)									--faster impulse (vs 35)
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 6)
	ship:setShieldsMax(450, 350, 250, 250, 350)					--stronger shields (vs 450, 350, 150, 150, 350)
	ship:setShields(450, 350, 250, 250, 350)					
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(4,	60,	  180,	1500,		8,		11)	--extra rear facing beam
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 36)
	local starhammer_v_db = queryScienceDatabase("Ships","Corvette","Starhammer V")
	if starhammer_v_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Corvette")
		corvette_db:addEntry("Starhammer V")
		starhammer_v_db = queryScienceDatabase("Ships","Corvette","Starhammer V")
		addShipToDatabase(
			queryScienceDatabase("Ships","Corvette","Starhammer II"),	--base ship database entry
			starhammer_v_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with.",
			{
				{key = "Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
				{key = " Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
			},
			"5 - 50 U"		--jump range
		)
	end
	return ship		
end
function tyr(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Battlestation"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Tyr")
	ship:setImpulseMaxSpeed(50)									--faster impulse (vs 30)
	ship:setRotationMaxSpeed(10)								--faster maneuver (vs 1.5)
	ship:setShieldsMax(400, 300, 300, 400, 300, 300)			--stronger shields (vs 300, 300, 300, 300, 300)
	ship:setShields(400, 300, 300, 400, 300, 300)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	  -60,	2500,		6,		 8)	--stronger beams, broader coverage
	ship:setBeamWeapon(1,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(2,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(3,	90,	  120,	2500,		6,		 8)
	ship:setBeamWeapon(4,	90,	  -60,	2500,		6,		 8)
	ship:setBeamWeapon(5,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(6,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(7,	90,	  120,	2500,		6,		 8)
	ship:setBeamWeapon(8,	90,	  -60,	2500,		6,		 8)
	ship:setBeamWeapon(9,	90,	 -120,	2500,		6,		 8)
	ship:setBeamWeapon(10,	90,	   60,	2500,		6,		 8)
	ship:setBeamWeapon(11,	90,	  120,	2500,		6,		 8)
	local tyr_db = queryScienceDatabase("Ships","Dreadnought","Tyr")
	if tyr_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Dreadnought")
		corvette_db:addEntry("Tyr")
		tyr_db = queryScienceDatabase("Ships","Dreadnought","Tyr")
		addShipToDatabase(
			queryScienceDatabase("Ships","Dreadnought","Battlestation"),	--base ship database entry
			tyr_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Tyr is the shipyard's answer to admiral konstatz' casual statement that the Battlestation model was too slow to be effective. The shipyards improved on the Battlestation by fitting the Tyr with more than twice the impulse speed and more than six times the turn speed. They threw in stronger shields and hull and wider beam coverage just to show that they could",
			nil,
			"5 - 50 U"		--jump range
		)
	end
	return ship
end
function gnat(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone"):orderRoaming()
	ship:setTypeName("Gnat")
	ship:setHullMax(15)					--weaker hull (vs 30)
	ship:setHull(15)
	ship:setImpulseMaxSpeed(140)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(25)		--faster maneuver (vs 10)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,   40,		0,	 600,		4,		 3)	--weaker (vs 6) beam
	local gnat_db = queryScienceDatabase("Ships","No Class","Gnat")
	if gnat_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Gnat")
		gnat_db = queryScienceDatabase("Ships","No Class","Gnat")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
			gnat_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Gnat is a nimbler version of the Ktlitan Drone. It's got half the hull, but it moves and turns faster",
			nil,
			nil		--jump range
		)
	end
	return ship
end
function cucaracha(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Tug"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Cucaracha")
	ship:setShieldsMax(200, 50, 50, 50, 50, 50)		--stronger shields (vs 20)
	ship:setShields(200, 50, 50, 50, 50, 50)					
	ship:setHullMax(100)							--stronger hull (vs 50)
	ship:setHull(100)
	ship:setRotationMaxSpeed(20)					--faster maneuver (vs 10)
	ship:setAcceleration(30)						--faster acceleration (vs 15)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	60,	    0,	1500,		6,		10)	--extra rear facing beam
	local cucaracha_db = queryScienceDatabase("Ships","No Class","Cucaracha")
	if cucaracha_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("Cucaracha")
		cucaracha_db = queryScienceDatabase("Ships","No Class","Cucaracha")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Tug"),	--base ship database entry
			cucaracha_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Cucaracha is a quick ship built around the Tug model with heavy shields and a heavy beam designed to be difficult to squash",
			nil,
			nil		--jump range
		)
	end
	return ship
end
function starhammerIII(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Starhammer III")
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(4,	60,	  180,	1500,		8,		11)	--extra rear facing beam
	ship:setTubeSize(0,"large")
	ship:setWeaponStorageMax("Homing",16)						--more (vs 4)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 36)
	local starhammer_iii_db = queryScienceDatabase("Ships","Corvette","Starhammer III")
	if starhammer_iii_db == nil then
		local corvette_db = queryScienceDatabase("Ships","Corvette")
		corvette_db:addEntry("Starhammer III")
		starhammer_iii_db = queryScienceDatabase("Ships","Corvette","Starhammer III")
		addShipToDatabase(
			queryScienceDatabase("Ships","Corvette","Starhammer II"),	--base ship database entry
			starhammer_iii_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The designers of the Starhammer III took the Starhammer II and added a rear facing beam, enlarged one of the missile tubes and added more missiles to fire",
			{
				{key = "Large tube 0", value = "10 sec"},	--torpedo tube direction and load speed
				{key = "Tube 0", value = "10 sec"},			--torpedo tube direction and load speed
			},
			"5 - 50 U"		--jump range
		)
	end
	return ship
end
function k2breaker(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Breaker"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("K2 Breaker")
	ship:setHullMax(200)							--stronger hull (vs 120)
	ship:setHull(200)
	ship:setWeaponTubeCount(3)						--more (vs 1)
	ship:setTubeSize(0,"large")						--large (vs normal)
	ship:setWeaponTubeDirection(1,-30)				
	ship:setWeaponTubeDirection(2, 30)
	ship:setWeaponTubeExclusiveFor(0,"HVLI")		--only HVLI (vs any)
	ship:setWeaponStorageMax("Homing",16)			--more (vs 0)
	ship:setWeaponStorage("Homing", 16)
	ship:setWeaponStorageMax("HVLI",8)				--more (vs 5)
	ship:setWeaponStorage("HVLI", 8)
	local k2_breaker_db = queryScienceDatabase("Ships","No Class","K2 Breaker")
	if k2_breaker_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		no_class_db:addEntry("K2 Breaker")
		k2_breaker_db = queryScienceDatabase("Ships","No Class","K2 Breaker")
		addShipToDatabase(
			queryScienceDatabase("Ships","No Class","Ktlitan Breaker"),	--base ship database entry
			k2_breaker_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The K2 Breaker designers took the Ktlitan Breaker and beefed up the hull, added two bracketing tubes, enlarged the center tube and added more missiles to shoot. Should be good for a couple of enemy ships",
			{
				{key = "Large tube 0", value = "13 sec"},	--torpedo tube direction and load speed
				{key = "Tube -30", value = "13 sec"},		--torpedo tube direction and load speed
				{key = "Tube 30", value = "13 sec"},		--torpedo tube direction and load speed
			},
			nil
		)
	end
	return ship
end
function hurricane(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Hurricane")
	ship:setJumpDrive(true)
	ship:setJumpDriveRange(5000,40000)			
	ship:setWeaponTubeCount(8)						--more (vs 3)
	ship:setWeaponTubeExclusiveFor(1,"HVLI")		--only HVLI (vs any)
	ship:setWeaponTubeDirection(1,  0)				--forward (vs -90)
	ship:setTubeSize(3,"large")						
	ship:setWeaponTubeDirection(3,-90)
	ship:setTubeSize(4,"small")
	ship:setWeaponTubeExclusiveFor(4,"Homing")
	ship:setWeaponTubeDirection(4,-15)
	ship:setTubeSize(5,"small")
	ship:setWeaponTubeExclusiveFor(5,"Homing")
	ship:setWeaponTubeDirection(5, 15)
	ship:setWeaponTubeExclusiveFor(6,"Homing")
	ship:setWeaponTubeDirection(6,-30)
	ship:setWeaponTubeExclusiveFor(7,"Homing")
	ship:setWeaponTubeDirection(7, 30)
	ship:setWeaponStorageMax("Homing",24)			--more (vs 5)
	ship:setWeaponStorage("Homing", 24)
	local hurricane_db = queryScienceDatabase("Ships","Frigate","Hurricane")
	if hurricane_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Hurricane")
		hurricane_db = queryScienceDatabase("Ships","Frigate","Hurricane")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Piranha F8"),	--base ship database entry
			hurricane_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Hurricane is designed to jump in and shower the target with missiles. It is based on the Piranha F8, but with a jump drive, five more tubes in various directions and sizes and lots more missiles to shoot",
			{
				{key = "Large tube 0", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube 0", value = "12 sec"},			--torpedo tube direction and load speed
				{key = "Large tube 90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Large tube -90", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Small tube -15", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Small tube 15", value = "12 sec"},	--torpedo tube direction and load speed
				{key = "Tube -30", value = "12 sec"},		--torpedo tube direction and load speed
				{key = "Tube 30", value = "12 sec"},		--torpedo tube direction and load speed
			},
			"5 - 40 U"		--jump range
		)
	end
	return ship
end
function phobosT4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Phobos T4")
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 10)
	ship:setShieldsMax(80,30)									--stronger shields (vs 50,40)
	ship:setShields(80,30)					
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	90,	  -15,	1500,		6,		6)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	   15,	1500,		6,		6)	
	local phobos_t4_db = queryScienceDatabase("Ships","Frigate","Phobos T4")
	if phobos_t4_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Phobos T4")
		phobos_t4_db = queryScienceDatabase("Ships","Frigate","Phobos T4")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			phobos_t4_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Phobos T4 makes some simple improvements on the Phobos T3: faster maneuver, stronger front shields, though weaker rear shields and longer and faster beam weapons",
			{
				{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function whirlwind(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Storm"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Whirlwind")
	ship:setWeaponTubeCount(9)					--more (vs 5)
	ship:setWeaponTubeDirection(0,-90)			--3 left, 3 right, 3 front (vs 5 front)	
	ship:setWeaponTubeDirection(1,-92)				
	ship:setWeaponTubeDirection(2,-88)				
	ship:setWeaponTubeDirection(3, 90)				
	ship:setWeaponTubeDirection(4, 92)				
	ship:setWeaponTubeDirection(5, 88)				
	ship:setWeaponTubeDirection(6,  0)				
	ship:setWeaponTubeDirection(7,  2)				
	ship:setWeaponTubeDirection(8, -2)				
	ship:setWeaponStorageMax("Homing",36)						--more (vs 15)
	ship:setWeaponStorage("Homing", 36)		
	ship:setWeaponStorageMax("HVLI",36)							--more (vs 15)
	ship:setWeaponStorage("HVLI", 36)
	local whirlwind_db = queryScienceDatabase("Ships","Frigate","Whirlwind")
	if whirlwind_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Whirlwind")
		whirlwind_db = queryScienceDatabase("Ships","Frigate","Whirlwind")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Storm"),	--base ship database entry
			whirlwind_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Whirlwind, another heavy artillery cruiser, takes the Storm and adds tubes and missiles. It's as if the Storm swallowed a Pirahna and grew gills. Expect to see missiles, lots of missiles",
			{
				{key = "Tube -90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -92", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube -88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  90", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  92", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  88", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube   0", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube   2", value = "15 sec"},	--torpedo tube direction and load speed
				{key = "Tube  -2", value = "15 sec"},	--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 3")
	ship:setShieldsMax(60, 40)									--stronger shields (vs 50, 40)
	ship:setShields(60, 40)					
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	local farco_3_db = queryScienceDatabase("Ships","Frigate","Farco 3")
	if farco_3_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 3")
		farco_3_db = queryScienceDatabase("Ships","Frigate","Farco 3")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_3_db,		--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 3, the beams are longer and faster and the shields are slightly stronger.",
			{
				{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 5")
	ship:setShieldsMax(60, 40)				--stronger shields (vs 50, 40)
	ship:setShields(60, 40)	
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	local farco_5_db = queryScienceDatabase("Ships","Frigate","Farco 5")
	if farco_5_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 5")
		farco_5_db = queryScienceDatabase("Ships","Frigate","Farco 5")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_5_db,		--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 5, the tubes load faster and the shields are slightly stronger.",
			{
				{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 8")
	ship:setShieldsMax(80, 50)				--stronger shields (vs 50, 40)
	ship:setShields(80, 50)	
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	local farco_8_db = queryScienceDatabase("Ships","Frigate","Farco 8")
	if farco_8_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 8")
		farco_8_db = queryScienceDatabase("Ships","Frigate","Farco 8")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_8_db,		--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 8, the beams are longer and faster, the tubes load faster and the shields are stronger.",
			{
				{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco11(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 11")
	ship:setShieldsMax(80, 50)				--stronger shields (vs 50, 40)
	ship:setShields(80, 50)	
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 10)
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setBeamWeapon(2,	20,	  0,	 1800,	5.0,	4.0)	--additional sniping beam
	local farco_11_db = queryScienceDatabase("Ships","Frigate","Farco 11")
	if farco_11_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 11")
		farco_11_db = queryScienceDatabase("Ships","Frigate","Farco 11")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_11_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 11, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam and the shields are stronger.",
			{
				{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function farco13(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3"):orderRoaming()
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Farco 13")
	ship:setShieldsMax(90, 70)				--stronger shields (vs 50, 40)
	ship:setShields(90, 70)	
	ship:setRotationMaxSpeed(15)								--faster maneuver (vs 10)
--				   Index,  Arc,	Dir,	Range, Cycle,	Damage
	ship:setBeamWeapon(0,	90,	-15,	 1500,	5.0,	6.0)	--longer (vs 1200), faster (vs 8)
	ship:setBeamWeapon(1,	90,	 15,	 1500,	5.0,	6.0)
	ship:setBeamWeapon(2,	20,	  0,	 1800,	5.0,	4.0)	--additional sniping beam
	ship:setTubeLoadTime(0,30)				--faster (vs 60)
	ship:setTubeLoadTime(0,30)				
	ship:setWeaponStorageMax("Homing",16)						--more (vs 6)
	ship:setWeaponStorage("Homing", 16)		
	ship:setWeaponStorageMax("HVLI",30)							--more (vs 20)
	ship:setWeaponStorage("HVLI", 30)
	local farco_13_db = queryScienceDatabase("Ships","Frigate","Farco 13")
	if farco_13_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		frigate_db:addEntry("Farco 13")
		farco_13_db = queryScienceDatabase("Ships","Frigate","Farco 13")
		addShipToDatabase(
			queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
			farco_13_db,	--modified ship database entry
			ship,			--ship just created, long description on the next line
			"The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 13, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam, the tubes load faster, there are more missiles and the shields are stronger.",
			{
				{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
				{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
			},
			nil		--jump range
		)
	end
	return ship
end
function addShipToDatabase(base_db,modified_db,ship,description,tube_directions,jump_range)
	modified_db:setLongDescription(description)
	modified_db:setImage(base_db:getImage())
	modified_db:setKeyValue("Class",base_db:getKeyValue("Class"))
	modified_db:setKeyValue("Sub-class",base_db:getKeyValue("Sub-class"))
	modified_db:setKeyValue("Size",base_db:getKeyValue("Size"))
	local shields = ship:getShieldCount()
	if shields > 0 then
		local shield_string = ""
		for i=1,shields do
			if shield_string == "" then
				shield_string = string.format("%i",math.floor(ship:getShieldMax(i-1)))
			else
				shield_string = string.format("%s/%i",shield_string,math.floor(ship:getShieldMax(i-1)))
			end
		end
		modified_db:setKeyValue("Shield",shield_string)
	end
	modified_db:setKeyValue("Hull",string.format("%i",math.floor(ship:getHullMax())))
	modified_db:setKeyValue("Move speed",string.format("%.1f u/min",ship:getImpulseMaxSpeed()*60/1000))
	modified_db:setKeyValue("Turn speed",string.format("%.1f deg/sec",ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		if jump_range == nil then
			local base_jump_range = base_db:getKeyValue("Jump range")
			if base_jump_range ~= nil and base_jump_range ~= "" then
				modified_db:setKeyValue("Jump range",base_jump_range)
			else
				modified_db:setKeyValue("Jump range","5 - 50 u")
			end
		else
			modified_db:setKeyValue("Jump range",jump_range)
		end
	end
	if ship:hasWarpDrive() then
		modified_db:setKeyValue("Warp Speed",string.format("%.1f u/min",ship:getWarpSpeed()*60/1000))
	end
	local key = ""
	if ship:getBeamWeaponRange(0) > 0 then
		local bi = 0
		repeat
			local beam_direction = ship:getBeamWeaponDirection(bi)
			if beam_direction > 315 and beam_direction < 360 then
				beam_direction = beam_direction - 360
			end
			key = string.format("Beam weapon %i:%i",ship:getBeamWeaponDirection(bi),ship:getBeamWeaponArc(bi))
			while(modified_db:getKeyValue(key) ~= "") do
				key = " " .. key
			end
			modified_db:setKeyValue(key,string.format("%.1f Dmg / %.1f sec",ship:getBeamWeaponDamage(bi),ship:getBeamWeaponCycleTime(bi)))
			bi = bi + 1
		until(ship:getBeamWeaponRange(bi) < 1)
	end
	local tubes = ship:getWeaponTubeCount()
	if tubes > 0 then
		if tube_directions ~= nil then
			for i=1,#tube_directions do
				modified_db:setKeyValue(tube_directions[i].key,tube_directions[i].value)
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for _, missile_type in ipairs(missile_types) do
			local max_storage = ship:getWeaponStorageMax(missile_type)
			if max_storage > 0 then
				modified_db:setKeyValue(string.format("Storage %s",missile_type),string.format("%i",max_storage))
			end
		end
	end
end
--		Generate call sign functions
function generateCallSign(prefix,faction)
	if faction == nil then
		if prefix == nil then
			prefix = generateCallSignPrefix()
		end
	else
		if prefix == nil then
			prefix = getFactionPrefix(faction)
		else
			prefix = string.format("%s %s",getFactionPrefix(faction),prefix)
		end
	end
	suffix_index = suffix_index + math.random(1,3)
	if suffix_index > 99 then 
		suffix_index = 1
	end
	return string.format("%s%i",prefix,suffix_index)
end
function generateCallSignPrefix(length)
	if call_sign_prefix_pool == nil then
		call_sign_prefix_pool = {}
		prefix_length = prefix_length + 1
		if prefix_length > 2 then
			prefix_length = 1
		end
		fillPrefixPool()
	end
	if length == nil then
		length = prefix_length
	end
	local prefix = ""
	for i=1,length do
		if #call_sign_prefix_pool < 1 then
			fillPrefixPool()
		end
		prefix = prefix .. tableRemoveRandom(call_sign_prefix_pool)
	end
	return prefix
end
function fillPrefixPool()
	for i=1,26 do
		table.insert(call_sign_prefix_pool,string.char(i+64))
	end
end
function getFactionPrefix(faction)
	--get the faction names from another scenario if desired
	local faction_prefix = nil
	if faction == "Kraylor" then
		if kraylor_names == nil then
			setKraylorNames()
		else
			if #kraylor_names < 1 then
				setKraylorNames()
			end
		end
		local kraylor_name_choice = math.random(1,#kraylor_names)
		faction_prefix = kraylor_names[kraylor_name_choice]
		table.remove(kraylor_names,kraylor_name_choice)
	end
	if faction == "Exuari" then
		if exuari_names == nil then
			setExuariNames()
		else
			if #exuari_names < 1 then
				setExuariNames()
			end
		end
		local exuari_name_choice = math.random(1,#exuari_names)
		faction_prefix = exuari_names[exuari_name_choice]
		table.remove(exuari_names,exuari_name_choice)
	end
	if faction == "Ghosts" then
		if ghosts_names == nil then
			setGhostsNames()
		else
			if #ghosts_names < 1 then
				setGhostsNames()
			end
		end
		local ghosts_name_choice = math.random(1,#ghosts_names)
		faction_prefix = ghosts_names[ghosts_name_choice]
		table.remove(ghosts_names,ghosts_name_choice)
	end
	if faction == "Independent" then
		if independent_names == nil then
			setIndependentNames()
		else
			if #independent_names < 1 then
				setIndependentNames()
			end
		end
		local independent_name_choice = math.random(1,#independent_names)
		faction_prefix = independent_names[independent_name_choice]
		table.remove(independent_names,independent_name_choice)
	end
	if faction == "Human Navy" then
		if human_names == nil then
			setHumanNames()
		else
			if #human_names < 1 then
				setHumanNames()
			end
		end
		local human_name_choice = math.random(1,#human_names)
		faction_prefix = human_names[human_name_choice]
		table.remove(human_names,human_name_choice)
	end
	if faction_prefix == nil then
		faction_prefix = generateCallSignPrefix()
	end
	return faction_prefix
end
function setGhostsNames()
	ghosts_names = {}
	table.insert(ghosts_names,"Abstract")
	table.insert(ghosts_names,"Ada")
	table.insert(ghosts_names,"Assemble")
	table.insert(ghosts_names,"Assert")
	table.insert(ghosts_names,"Backup")
	table.insert(ghosts_names,"BASIC")
	table.insert(ghosts_names,"Big Iron")
	table.insert(ghosts_names,"BigEndian")
	table.insert(ghosts_names,"Binary")
	table.insert(ghosts_names,"Bit")
	table.insert(ghosts_names,"Block")
	table.insert(ghosts_names,"Boot")
	table.insert(ghosts_names,"Branch")
	table.insert(ghosts_names,"BTree")
	table.insert(ghosts_names,"Bubble")
	table.insert(ghosts_names,"Byte")
	table.insert(ghosts_names,"Capacitor")
	table.insert(ghosts_names,"Case")
	table.insert(ghosts_names,"Chad")
	table.insert(ghosts_names,"Charge")
	table.insert(ghosts_names,"COBOL")
	table.insert(ghosts_names,"Collate")
	table.insert(ghosts_names,"Compile")
	table.insert(ghosts_names,"Control")
	table.insert(ghosts_names,"Construct")
	table.insert(ghosts_names,"Cycle")
	table.insert(ghosts_names,"Data")
	table.insert(ghosts_names,"Debug")
	table.insert(ghosts_names,"Decimal")
	table.insert(ghosts_names,"Decision")
	table.insert(ghosts_names,"Default")
	table.insert(ghosts_names,"DIMM")
	table.insert(ghosts_names,"Displacement")
	table.insert(ghosts_names,"Edge")
	table.insert(ghosts_names,"Exit")
	table.insert(ghosts_names,"Factor")
	table.insert(ghosts_names,"Flag")
	table.insert(ghosts_names,"Float")
	table.insert(ghosts_names,"Flow")
	table.insert(ghosts_names,"FORTRAN")
	table.insert(ghosts_names,"Fullword")
	table.insert(ghosts_names,"GIGO")
	table.insert(ghosts_names,"Graph")
	table.insert(ghosts_names,"Hack")
	table.insert(ghosts_names,"Hash")
	table.insert(ghosts_names,"Halfword")
	table.insert(ghosts_names,"Hertz")
	table.insert(ghosts_names,"Hexadecimal")
	table.insert(ghosts_names,"Indicator")
	table.insert(ghosts_names,"Initialize")
	table.insert(ghosts_names,"Integer")
	table.insert(ghosts_names,"Integrate")
	table.insert(ghosts_names,"Interrupt")
	table.insert(ghosts_names,"Java")
	table.insert(ghosts_names,"Lisp")
	table.insert(ghosts_names,"List")
	table.insert(ghosts_names,"Logic")
	table.insert(ghosts_names,"Loop")
	table.insert(ghosts_names,"Lua")
	table.insert(ghosts_names,"Magnetic")
	table.insert(ghosts_names,"Mask")
	table.insert(ghosts_names,"Memory")
	table.insert(ghosts_names,"Mnemonic")
	table.insert(ghosts_names,"Micro")
	table.insert(ghosts_names,"Model")
	table.insert(ghosts_names,"Nibble")
	table.insert(ghosts_names,"Octal")
	table.insert(ghosts_names,"Order")
	table.insert(ghosts_names,"Operator")
	table.insert(ghosts_names,"Parameter")
	table.insert(ghosts_names,"Pascal")
	table.insert(ghosts_names,"Pattern")
	table.insert(ghosts_names,"Pixel")
	table.insert(ghosts_names,"Point")
	table.insert(ghosts_names,"Polygon")
	table.insert(ghosts_names,"Port")
	table.insert(ghosts_names,"Process")
	table.insert(ghosts_names,"RAM")
	table.insert(ghosts_names,"Raster")
	table.insert(ghosts_names,"Rate")
	table.insert(ghosts_names,"Redundant")
	table.insert(ghosts_names,"Reference")
	table.insert(ghosts_names,"Refresh")
	table.insert(ghosts_names,"Register")
	table.insert(ghosts_names,"Resistor")
	table.insert(ghosts_names,"ROM")
	table.insert(ghosts_names,"Routine")
	table.insert(ghosts_names,"Ruby")
	table.insert(ghosts_names,"SAAS")
	table.insert(ghosts_names,"Sequence")
	table.insert(ghosts_names,"Share")
	table.insert(ghosts_names,"Silicon")
	table.insert(ghosts_names,"SIMM")
	table.insert(ghosts_names,"Socket")
	table.insert(ghosts_names,"Sort")
	table.insert(ghosts_names,"Structure")
	table.insert(ghosts_names,"Switch")
	table.insert(ghosts_names,"Symbol")
	table.insert(ghosts_names,"Trace")
	table.insert(ghosts_names,"Transistor")
	table.insert(ghosts_names,"Value")
	table.insert(ghosts_names,"Vector")
	table.insert(ghosts_names,"Version")
	table.insert(ghosts_names,"View")
	table.insert(ghosts_names,"WYSIWYG")
	table.insert(ghosts_names,"XOR")
end
function setExuariNames()
	exuari_names = {}
	table.insert(exuari_names,"Astonester")
	table.insert(exuari_names,"Ametripox")
	table.insert(exuari_names,"Bakeltevex")
	table.insert(exuari_names,"Baropledax")
	table.insert(exuari_names,"Batongomox")
	table.insert(exuari_names,"Bekilvimix")
	table.insert(exuari_names,"Benoglopok")
	table.insert(exuari_names,"Bilontipur")
	table.insert(exuari_names,"Bolictimik")
	table.insert(exuari_names,"Bomagralax")
	table.insert(exuari_names,"Buteldefex")
	table.insert(exuari_names,"Catondinab")
	table.insert(exuari_names,"Chatorlonox")
	table.insert(exuari_names,"Culagromik")
	table.insert(exuari_names,"Dakimbinix")
	table.insert(exuari_names,"Degintalix")
	table.insert(exuari_names,"Dimabratax")
	table.insert(exuari_names,"Dokintifix")
	table.insert(exuari_names,"Dotandirex")
	table.insert(exuari_names,"Dupalgawax")
	table.insert(exuari_names,"Ekoftupex")
	table.insert(exuari_names,"Elidranov")
	table.insert(exuari_names,"Fakobrovox")
	table.insert(exuari_names,"Femoplabix")
	table.insert(exuari_names,"Fibatralax")
	table.insert(exuari_names,"Fomartoran")
	table.insert(exuari_names,"Gateldepex")
	table.insert(exuari_names,"Gamutrewal")
	table.insert(exuari_names,"Gesanterux")
	table.insert(exuari_names,"Gimardanax")
	table.insert(exuari_names,"Hamintinal")
	table.insert(exuari_names,"Holangavak")
	table.insert(exuari_names,"Igolpafik")
	table.insert(exuari_names,"Inoklomat")
	table.insert(exuari_names,"Jamewtibex")
	table.insert(exuari_names,"Jepospagox")
	table.insert(exuari_names,"Kajortonox")
	table.insert(exuari_names,"Kapogrinix")
	table.insert(exuari_names,"Kelitravax")
	table.insert(exuari_names,"Kipaldanax")
	table.insert(exuari_names,"Kodendevex")
	table.insert(exuari_names,"Kotelpedex")
	table.insert(exuari_names,"Kutandolak")
	table.insert(exuari_names,"Lakirtinix")
	table.insert(exuari_names,"Lapoldinek")
	table.insert(exuari_names,"Lavorbonox")
	table.insert(exuari_names,"Letirvinix")
	table.insert(exuari_names,"Lowibromax")
	table.insert(exuari_names,"Makintibix")
	table.insert(exuari_names,"Makorpohox")
	table.insert(exuari_names,"Matoprowox")
	table.insert(exuari_names,"Mefinketix")
	table.insert(exuari_names,"Motandobak")
	table.insert(exuari_names,"Nakustunux")
	table.insert(exuari_names,"Nequivonax")
	table.insert(exuari_names,"Nitaldavax")
	table.insert(exuari_names,"Nobaldorex")
	table.insert(exuari_names,"Obimpitix")
	table.insert(exuari_names,"Owaklanat")
	table.insert(exuari_names,"Pakendesik")
	table.insert(exuari_names,"Pazinderix")
	table.insert(exuari_names,"Pefoglamuk")
	table.insert(exuari_names,"Pekirdivix")
	table.insert(exuari_names,"Potarkadax")
	table.insert(exuari_names,"Pulendemex")
	table.insert(exuari_names,"Quatordunix")
	table.insert(exuari_names,"Rakurdumux")
	table.insert(exuari_names,"Ralombenik")
	table.insert(exuari_names,"Regosporak")
	table.insert(exuari_names,"Retordofox")
	table.insert(exuari_names,"Rikondogox")
	table.insert(exuari_names,"Rokengelex")
	table.insert(exuari_names,"Rutarkadax")
	table.insert(exuari_names,"Sakeldepex")
	table.insert(exuari_names,"Setiftimix")
	table.insert(exuari_names,"Siparkonal")
	table.insert(exuari_names,"Sopaldanax")
	table.insert(exuari_names,"Sudastulux")
	table.insert(exuari_names,"Takeftebex")
	table.insert(exuari_names,"Taliskawit")
	table.insert(exuari_names,"Tegundolex")
	table.insert(exuari_names,"Tekintipix")
	table.insert(exuari_names,"Tiposhomox")
	table.insert(exuari_names,"Tokaldapax")
	table.insert(exuari_names,"Tomuglupux")
	table.insert(exuari_names,"Tufeldepex")
	table.insert(exuari_names,"Unegremek")
	table.insert(exuari_names,"Uvendipax")
	table.insert(exuari_names,"Vatorgopox")
	table.insert(exuari_names,"Venitribix")
	table.insert(exuari_names,"Vobalterix")
	table.insert(exuari_names,"Wakintivix")
	table.insert(exuari_names,"Wapaltunix")
	table.insert(exuari_names,"Wekitrolax")
	table.insert(exuari_names,"Wofarbanax")
	table.insert(exuari_names,"Xeniplofek")
	table.insert(exuari_names,"Yamaglevik")
	table.insert(exuari_names,"Yakildivix")
	table.insert(exuari_names,"Yegomparik")
	table.insert(exuari_names,"Zapondehex")
	table.insert(exuari_names,"Zikandelat")
end
function setKraylorNames()		
	kraylor_names = {}
	table.insert(kraylor_names,"Abroten")
	table.insert(kraylor_names,"Ankwar")
	table.insert(kraylor_names,"Bakrik")
	table.insert(kraylor_names,"Belgor")
	table.insert(kraylor_names,"Benkop")
	table.insert(kraylor_names,"Blargvet")
	table.insert(kraylor_names,"Bloktarg")
	table.insert(kraylor_names,"Bortok")
	table.insert(kraylor_names,"Bredjat")
	table.insert(kraylor_names,"Chankret")
	table.insert(kraylor_names,"Chatork")
	table.insert(kraylor_names,"Chokarp")
	table.insert(kraylor_names,"Cloprak")
	table.insert(kraylor_names,"Coplek")
	table.insert(kraylor_names,"Cortek")
	table.insert(kraylor_names,"Daltok")
	table.insert(kraylor_names,"Darpik")
	table.insert(kraylor_names,"Dastek")
	table.insert(kraylor_names,"Dotark")
	table.insert(kraylor_names,"Drambok")
	table.insert(kraylor_names,"Duntarg")
	table.insert(kraylor_names,"Earklat")
	table.insert(kraylor_names,"Ekmit")
	table.insert(kraylor_names,"Fakret")
	table.insert(kraylor_names,"Fapork")
	table.insert(kraylor_names,"Fawtrik")
	table.insert(kraylor_names,"Fenturp")
	table.insert(kraylor_names,"Feplik")
	table.insert(kraylor_names,"Figront")
	table.insert(kraylor_names,"Floktrag")
	table.insert(kraylor_names,"Fonkack")
	table.insert(kraylor_names,"Fontreg")
	table.insert(kraylor_names,"Foondrap")
	table.insert(kraylor_names,"Frotwak")
	table.insert(kraylor_names,"Gastonk")
	table.insert(kraylor_names,"Gentouk")
	table.insert(kraylor_names,"Gonpruk")
	table.insert(kraylor_names,"Gortak")
	table.insert(kraylor_names,"Gronkud")
	table.insert(kraylor_names,"Hewtang")
	table.insert(kraylor_names,"Hongtag")
	table.insert(kraylor_names,"Hortook")
	table.insert(kraylor_names,"Indrut")
	table.insert(kraylor_names,"Iprant")
	table.insert(kraylor_names,"Jakblet")
	table.insert(kraylor_names,"Jonket")
	table.insert(kraylor_names,"Jontot")
	table.insert(kraylor_names,"Kandarp")
	table.insert(kraylor_names,"Kantrok")
	table.insert(kraylor_names,"Kiptak")
	table.insert(kraylor_names,"Kortrant")
	table.insert(kraylor_names,"Krontgat")
	table.insert(kraylor_names,"Lobreck")
	table.insert(kraylor_names,"Lokrant")
	table.insert(kraylor_names,"Lomprok")
	table.insert(kraylor_names,"Lutrank")
	table.insert(kraylor_names,"Makrast")
	table.insert(kraylor_names,"Moklahft")
	table.insert(kraylor_names,"Morpug")
	table.insert(kraylor_names,"Nagblat")
	table.insert(kraylor_names,"Nokrat")
	table.insert(kraylor_names,"Nomek")
	table.insert(kraylor_names,"Notark")
	table.insert(kraylor_names,"Ontrok")
	table.insert(kraylor_names,"Orkpent")
	table.insert(kraylor_names,"Peechak")
	table.insert(kraylor_names,"Plogrent")
	table.insert(kraylor_names,"Pokrint")
	table.insert(kraylor_names,"Potarg")
	table.insert(kraylor_names,"Prangtil")
	table.insert(kraylor_names,"Quagbrok")
	table.insert(kraylor_names,"Quimprill")
	table.insert(kraylor_names,"Reekront")
	table.insert(kraylor_names,"Ripkort")
	table.insert(kraylor_names,"Rokust")
	table.insert(kraylor_names,"Rontrait")
	table.insert(kraylor_names,"Saknep")
	table.insert(kraylor_names,"Sengot")
	table.insert(kraylor_names,"Skitkard")
	table.insert(kraylor_names,"Skopgrek")
	table.insert(kraylor_names,"Sletrok")
	table.insert(kraylor_names,"Slorknat")
	table.insert(kraylor_names,"Spogrunk")
	table.insert(kraylor_names,"Staklurt")
	table.insert(kraylor_names,"Stonkbrant")
	table.insert(kraylor_names,"Swaktrep")
	table.insert(kraylor_names,"Tandrok")
	table.insert(kraylor_names,"Takrost")
	table.insert(kraylor_names,"Tonkrut")
	table.insert(kraylor_names,"Torkrot")
	table.insert(kraylor_names,"Trablok")
	table.insert(kraylor_names,"Trokdin")
	table.insert(kraylor_names,"Unkelt")
	table.insert(kraylor_names,"Urjop")
	table.insert(kraylor_names,"Vankront")
	table.insert(kraylor_names,"Vintrep")
	table.insert(kraylor_names,"Volkerd")
	table.insert(kraylor_names,"Vortread")
	table.insert(kraylor_names,"Wickurt")
	table.insert(kraylor_names,"Xokbrek")
	table.insert(kraylor_names,"Yeskret")
	table.insert(kraylor_names,"Zacktrope")
end
function setIndependentNames()
	independent_names = {}
	table.insert(independent_names,"Akdroft")	--faux Kraylor
	table.insert(independent_names,"Bletnik")	--faux Kraylor
	table.insert(independent_names,"Brogfent")	--faux Kraylor
	table.insert(independent_names,"Cruflech")	--faux Kraylor
	table.insert(independent_names,"Dengtoct")	--faux Kraylor
	table.insert(independent_names,"Fiklerg")	--faux Kraylor
	table.insert(independent_names,"Groftep")	--faux Kraylor
	table.insert(independent_names,"Hinkflort")	--faux Kraylor
	table.insert(independent_names,"Irklesht")	--faux Kraylor
	table.insert(independent_names,"Jotrak")	--faux Kraylor
	table.insert(independent_names,"Kargleth")	--faux Kraylor
	table.insert(independent_names,"Lidroft")	--faux Kraylor
	table.insert(independent_names,"Movrect")	--faux Kraylor
	table.insert(independent_names,"Nitrang")	--faux Kraylor
	table.insert(independent_names,"Poklapt")	--faux Kraylor
	table.insert(independent_names,"Raknalg")	--faux Kraylor
	table.insert(independent_names,"Stovtuk")	--faux Kraylor
	table.insert(independent_names,"Trongluft")	--faux Kraylor
	table.insert(independent_names,"Vactremp")	--faux Kraylor
	table.insert(independent_names,"Wunklesp")	--faux Kraylor
	table.insert(independent_names,"Yentrilg")	--faux Kraylor
	table.insert(independent_names,"Zeltrag")	--faux Kraylor
	table.insert(independent_names,"Avoltojop")		--faux Exuari
	table.insert(independent_names,"Bimartarax")	--faux Exuari
	table.insert(independent_names,"Cidalkapax")	--faux Exuari
	table.insert(independent_names,"Darongovax")	--faux Exuari
	table.insert(independent_names,"Felistiyik")	--faux Exuari
	table.insert(independent_names,"Gopendewex")	--faux Exuari
	table.insert(independent_names,"Hakortodox")	--faux Exuari
	table.insert(independent_names,"Jemistibix")	--faux Exuari
	table.insert(independent_names,"Kilampafax")	--faux Exuari
	table.insert(independent_names,"Lokuftumux")	--faux Exuari
	table.insert(independent_names,"Mabildirix")	--faux Exuari
	table.insert(independent_names,"Notervelex")	--faux Exuari
	table.insert(independent_names,"Pekolgonex")	--faux Exuari
	table.insert(independent_names,"Rifaltabax")	--faux Exuari
	table.insert(independent_names,"Sobendeyex")	--faux Exuari
	table.insert(independent_names,"Tinaftadax")	--faux Exuari
	table.insert(independent_names,"Vadorgomax")	--faux Exuari
	table.insert(independent_names,"Wilerpejex")	--faux Exuari
	table.insert(independent_names,"Yukawvalak")	--faux Exuari
	table.insert(independent_names,"Zajiltibix")	--faux Exuari
	table.insert(independent_names,"Alter")		--faux Ghosts
	table.insert(independent_names,"Assign")	--faux Ghosts
	table.insert(independent_names,"Brain")		--faux Ghosts
	table.insert(independent_names,"Break")		--faux Ghosts
	table.insert(independent_names,"Boundary")	--faux Ghosts
	table.insert(independent_names,"Code")		--faux Ghosts
	table.insert(independent_names,"Compare")	--faux Ghosts
	table.insert(independent_names,"Continue")	--faux Ghosts
	table.insert(independent_names,"Core")		--faux Ghosts
	table.insert(independent_names,"CRUD")		--faux Ghosts
	table.insert(independent_names,"Decode")	--faux Ghosts
	table.insert(independent_names,"Decrypt")	--faux Ghosts
	table.insert(independent_names,"Device")	--faux Ghosts
	table.insert(independent_names,"Encode")	--faux Ghosts
	table.insert(independent_names,"Encrypt")	--faux Ghosts
	table.insert(independent_names,"Event")		--faux Ghosts
	table.insert(independent_names,"Fetch")		--faux Ghosts
	table.insert(independent_names,"Frame")		--faux Ghosts
	table.insert(independent_names,"Go")		--faux Ghosts
	table.insert(independent_names,"IO")		--faux Ghosts
	table.insert(independent_names,"Interface")	--faux Ghosts
	table.insert(independent_names,"Kilo")		--faux Ghosts
	table.insert(independent_names,"Modify")	--faux Ghosts
	table.insert(independent_names,"Pin")		--faux Ghosts
	table.insert(independent_names,"Program")	--faux Ghosts
	table.insert(independent_names,"Purge")		--faux Ghosts
	table.insert(independent_names,"Retrieve")	--faux Ghosts
	table.insert(independent_names,"Store")		--faux Ghosts
	table.insert(independent_names,"Unit")		--faux Ghosts
	table.insert(independent_names,"Wire")		--faux Ghosts
end
function setHumanNames()
	human_names = {}
	table.insert(human_names,"Andromeda")
	table.insert(human_names,"Angelica")
	table.insert(human_names,"Artemis")
	table.insert(human_names,"Barrier")
	table.insert(human_names,"Beauteous")
	table.insert(human_names,"Bliss")
	table.insert(human_names,"Bonita")
	table.insert(human_names,"Bounty Hunter")
	table.insert(human_names,"Bueno")
	table.insert(human_names,"Capitol")
	table.insert(human_names,"Castigator")
	table.insert(human_names,"Centurion")
	table.insert(human_names,"Chakalaka")
	table.insert(human_names,"Charity")
	table.insert(human_names,"Christmas")
	table.insert(human_names,"Chutzpah")
	table.insert(human_names,"Constantine")
	table.insert(human_names,"Crystal")
	table.insert(human_names,"Dauntless")
	table.insert(human_names,"Defiant")
	table.insert(human_names,"Discovery")
	table.insert(human_names,"Dorcas")
	table.insert(human_names,"Elite")
	table.insert(human_names,"Empathy")
	table.insert(human_names,"Enlighten")
	table.insert(human_names,"Enterprise")
	table.insert(human_names,"Escape")
	table.insert(human_names,"Exclamatory")
	table.insert(human_names,"Faith")
	table.insert(human_names,"Felicity")
	table.insert(human_names,"Firefly")
	table.insert(human_names,"Foresight")
	table.insert(human_names,"Forthright")
	table.insert(human_names,"Fortitude")
	table.insert(human_names,"Frankenstein")
	table.insert(human_names,"Gallant")
	table.insert(human_names,"Gladiator")
	table.insert(human_names,"Glider")
	table.insert(human_names,"Godzilla")
	table.insert(human_names,"Grind")
	table.insert(human_names,"Happiness")
	table.insert(human_names,"Hearken")
	table.insert(human_names,"Helena")
	table.insert(human_names,"Heracles")
	table.insert(human_names,"Honorable Intentions")
	table.insert(human_names,"Hope")
	table.insert(human_names,"Hurricane")
	table.insert(human_names,"Inertia")
	table.insert(human_names,"Ingenius")
	table.insert(human_names,"Injurious")
	table.insert(human_names,"Insight")
	table.insert(human_names,"Insufferable")
	table.insert(human_names,"Insurmountable")
	table.insert(human_names,"Intractable")
	table.insert(human_names,"Intransigent")
	table.insert(human_names,"Jenny")
	table.insert(human_names,"Juice")
	table.insert(human_names,"Justice")
	table.insert(human_names,"Jurassic")
	table.insert(human_names,"Karma Cast")
	table.insert(human_names,"Knockout")
	table.insert(human_names,"Leila")
	table.insert(human_names,"Light Fantastic")
	table.insert(human_names,"Livid")
	table.insert(human_names,"Lolita")
	table.insert(human_names,"Mercury")
	table.insert(human_names,"Moira")
	table.insert(human_names,"Mona Lisa")
	table.insert(human_names,"Nancy")
	table.insert(human_names,"Olivia")
	table.insert(human_names,"Ominous")
	table.insert(human_names,"Oracle")
	table.insert(human_names,"Orca")
	table.insert(human_names,"Pandemic")
	table.insert(human_names,"Parsimonious")
	table.insert(human_names,"Personal Prejudice")
	table.insert(human_names,"Porpoise")
	table.insert(human_names,"Pristine")
	table.insert(human_names,"Purple Passion")
	table.insert(human_names,"Renegade")
	table.insert(human_names,"Revelation")
	table.insert(human_names,"Rosanna")
	table.insert(human_names,"Rozelle")
	table.insert(human_names,"Sainted Gramma")
	table.insert(human_names,"Shazam")
	table.insert(human_names,"Starbird")
	table.insert(human_names,"Stargazer")
	table.insert(human_names,"Stile")
	table.insert(human_names,"Streak")
	table.insert(human_names,"Take Flight")
	table.insert(human_names,"Taskmaster")
	table.insert(human_names,"Tempest")
	table.insert(human_names,"The Way")
	table.insert(human_names,"Tornado")
	table.insert(human_names,"Trailblazer")
	table.insert(human_names,"Trident")
	table.insert(human_names,"Triple Threat")
	table.insert(human_names,"Turnabout")
	table.insert(human_names,"Undulator")
	table.insert(human_names,"Urgent")
	table.insert(human_names,"Victoria")
	table.insert(human_names,"Wee Bit")
	table.insert(human_names,"Wet Willie")
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
    array[selected_item], array[array_item_count] = array[array_item_count], array[selected_item]
    return table.remove(array)
end

function asteroidSize()
	return random(1,160)+random(1,120)+random(1,80)+random(1,40)+random(1,20)+random(1,10)
end
function createRandomListAlongArc(object_type, amount, x, y, distance, startArc, endArcClockwise, randomize)
-- Create amount of objects of type object_type along arc
-- Center defined by x and y
-- Radius defined by distance
-- Start of arc between 0 and 360 (startArc), end arc: endArcClockwise
-- Use randomize to vary the distance from the center point. Omit to keep distance constant
-- Example:
--   createRandomAlongArc(Asteroid, 100, 500, 3000, 65, 120, 450)
	local list = {}
	if randomize == nil then randomize = 0 end
	if amount == nil then amount = 1 end
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			table.insert(list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			table.insert(list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			table.insert(list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
	end
	return list
end
function createObjectsListOnLine(x1, y1, x2, y2, spacing, object_type, rows, chance, randomize)
-- Create objects along a line between two vectors, optionally with grid
-- placement and randomization.
--
-- createObjectsOnLine(x1, y1, x2, y2, spacing, object_type, rows, chance, randomize)
--   x1, y1: Starting coordinates
--   x2, y2: Ending coordinates
--   spacing: The distance between each object.
--   object_type: The object type. Calls `object_type():setPosition()`.
--   rows (optional): The number of rows, minimum 1. Defaults to 1.
--   chance (optional): The percentile chance an object will be created,
--     minimum 1. Defaults to 100 (always).
--   randomize (optional): If present, randomize object placement by this
--     amount. Defaults to 0 (grid).
--
--   Examples: To create a mine field, run:
--     createObjectsOnLine(0, 0, 10000, 0, 1000, Mine, 4)
--   This creates 4 rows of mines from 0,0 to 10000,0, with mines spaced 1U
--   apart.
--
--   The `randomize` parameter adds chaos to the pattern. This works well for
--   asteroid fields:
--     createObjectsOnLine(0, 0, 10000, 0, 300, Asteroid, 4, 100, 800)
	local list = {}
    if rows == nil then rows = 1 end
    if chance == nil then chance = 100 end
    if randomize == nil then randomize = 0 end
    local d = distance(x1, y1, x2, y2)
    local xd = (x2 - x1) / d
    local yd = (y2 - y1) / d
    for cnt_x=0,d,spacing do
        for cnt_y=0,(rows-1)*spacing,spacing do
            local px = x1 + xd * cnt_x + yd * (cnt_y - (rows - 1) * spacing * 0.5) + random(-randomize, randomize)
            local py = y1 + yd * cnt_x - xd * (cnt_y - (rows - 1) * spacing * 0.5) + random(-randomize, randomize)
            if random(0, 100) < chance then
                table.insert(list,object_type():setPosition(px, py))
            end
        end
    end
    return list
end
function placeRandomListAroundPoint(object_type, amount, dist_min, dist_max, x0, y0)
-- create amount of object_type, at a distance between dist_min and dist_max around the point (x0, y0) 
-- save in a list that is returned to caller
	local object_list = {}
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        x = x0 + math.cos(r / 180 * math.pi) * distance
        y = y0 + math.sin(r / 180 * math.pi) * distance
        table.insert(object_list,object_type():setPosition(x, y))
    end
    return object_list
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
function choosePlanet(index,x,y)
	local planet_list = {
		{
			radius = random(500,1500), distance = -2000, 
			name = {"Gamma Piscium","Beta Lyporis","Sigma Draconis","Iota Carinae","Theta Arietis","Epsilon Indi","Beta Hydri"},
			color = {
				red = random(0.9,1), green = random(0.85,1), blue = random(0.9,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
		{
			radius = random(2500,4000), distance = -2000, rotation = random(250,350),
			name = {"Bespin","Aldea","Bersallis","Alpha Omicron","Farius Prime","Deneb","Mordan","Nelvana"},
			texture = {
				surface = "planets/gas-1.png"
			},
		},
		{
			radius = random(2000,3500), distance = -2000, rotation = random(350,450),
			name = {"Alderaan","Dagobah","Dantooine","Rigel","Pahvo","Penthara","Scalos","Tanuga","Vacca","Terlina","Timor"},
			color = {
				red = random(0.1,0.3), green = random(0.1,0.3), blue = random(0.9,1)
			},
			texture = {
				surface = "planets/planet-1.png", cloud = "planets/clouds-1.png", atmosphere = "planets/atmosphere.png"
			},
		},
		{
			radius = random(200,400), distance = -150, rotation = random(60,100),
			name = {"Adrastea","Belior","Cressida","Europa","Kyrrdis","Oberon","Pallas","Telesto","Vesta"},
			texture = {
				surface = "planets/moon-1.png"
			}
		},
	}
	local planet = Planet():setPosition(x,y):setPlanetRadius(planet_list[index].radius):setDistanceFromMovementPlane(planet_list[index].distance):setCallSign(planet_list[index].name[math.random(1,#planet_list[index].name)])
	if planet_list[index].texture.surface ~= nil then
		planet:setPlanetSurfaceTexture(planet_list[index].texture.surface)
	end
	if planet_list[index].texture.atmosphere ~= nil then
		planet:setPlanetAtmosphereTexture(planet_list[index].texture.atmosphere)
	end
	if planet_list[index].texture.cloud ~= nil then
		planet:setPlanetCloudTexture(planet_list[index].texture.cloud)
	end
	if planet_list[index].color ~= nil then
		planet:setPlanetAtmosphereColor(planet_list[index].color.red,planet_list[index].color.green,planet_list[index].color.blue)
	end
	if planet_list[index].rotation ~= nil then
		planet:setAxialRotationTime(planet_list[index].rotation)
	end
	return planet, planet_list[index].radius
end
function vectorFromAngleNorth(angle,distance)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	return x, y
end
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
function analyzeBlob(object_list)
--given a blob (list) of objects, find the center and the max perimeter and avg dist values
	local center_x = 0
	local center_y = 0
	local max_perimeter = 0
	local total_distance = 0
	local average_distance = 0
	if object_list ~= nil and #object_list > 0 then
		for i=1,#object_list do
			local obj_x, obj_y = object_list[i]:getPosition()
			center_x = center_x + obj_x
			center_y = center_y + obj_y
		end
		center_x = center_x/#object_list
		center_y = center_y/#object_list
		for i=1,#object_list do
--[[
			if distance_diagnostic then
				print("function analyzeBlob")
				if object_list[i] == nil then
					print("   object_list[i] is nil")
					print("   " .. i)
					print("   " .. object_list)
				else
					print("   " .. i,object_list[i])
				end
				if center_x == nil then
					print("   center_x is nil")
				else
					print("   center_x: " .. center_x)
				end
			end
--]]
			local current_distance = distance(object_list[i],center_x,center_y)
			total_distance = total_distance + current_distance
			if current_distance >= max_perimeter then
				max_perimeter = current_distance
			end
		end
		average_distance = total_distance/#object_list
	end
	return center_x, center_y, max_perimeter, average_distance
end
function farEnough(list,pos_x,pos_y,bubble)
	local far_enough = true
	for i=1,#list do
		local list_item = list[i]
--[[
		if distance_diagnostic then
			print("function farEnough")
			if list_item == nil then
				print("   list_item is nil")
				print("   " .. i)
				print("   " .. list)
			else
				print("   " .. i)
				print(list_item)
			end
			if pos_x == nil then
				print("   pos_x is nil")
			else
				print("   pos_x: " .. pos_x)
			end
		end
--]]
		local distance_away = distance(list_item,pos_x,pos_y)
		if distance_away < bubble then
			far_enough = false
			break
		end
		if list_item.typeName == "BlackHole" or list_item.typeName == "WormHole" then
			if distance_away < 6000 then
				far_enough = false
				break
			end
		end
		if list_item.typeName == "Planet" then
			if distance_away < 4000 then
				far_enough = false
				break
			end
		end
	end
	return far_enough
end
--	Player ship types, placement and naming functions
function placeCustomPlayerShips()
	print("place custom player ships")
	player_restart = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:destroy()
		end
	end
	local angle = human_angle
	for _, template in ipairs(custom_player_ship_sets[custom_player_ship_type][ships_per_team]) do
--		print("Human ships per team template:",template)
		local p = nil
		if player_ship_stats[template].stock then
			p = PlayerSpaceship():setTemplate(template):setFaction("Human Navy")
		else
			p = customPlayerShip(template)
			p:setFaction("Human Navy")
		end
		setPlayer(p)
		startPlayerPosition(p,angle)
		local respawn_x, respawn_y = p:getPosition()
		p.respawn_x = respawn_x
		p.respawn_y = respawn_y
		player_restart[p:getCallSign()] = {self = p, template = p:getTypeName(), control_code = p.control_code, faction = p:getFaction(), respawn_x = respawn_x, respawn_y = respawn_y}
		angle = (angle + 360/ships_per_team) % 360
	end
	replicatePlayers("Kraylor")
	if exuari_angle ~= nil then
		replicatePlayers("Exuari")
	end
	if ktlitan_angle ~= nil then
		replicatePlayers("Ktlitans")
	end
end
function customPlayerShip(custom_template,p)
	if player_ship_stats[custom_template] == nil then
		print("Invalid custom player ship template")
		return nil
	end
	if p == nil then
		p = PlayerSpaceship()
	end
	if custom_template == "Striker LX" then
		p:setTemplate("Striker")
		p:setTypeName("Striker LX")
		p:setRepairCrewCount(3)						--more (vs 2)
		p:setShieldsMax(100,100)					--stronger shields (vs 50, 30)
		p:setShields(100,100)
		p:setHullMax(100)							--weaker hull (vs 120)
		p:setHull(100)
		p:setMaxEnergy(600)							--more maximum energy (vs 500)
		p:setEnergy(600)
		p:setImpulseMaxSpeed(65)					--faster impulse max (vs 45)
	--                 	   Arc, Dir,   Range, CycleTime, Damage
		p:setBeamWeapon(0,  10, -15,	1100, 		6.0, 	6.5)	--shorter (vs 1200) more damage (vs 6.0)
		p:setBeamWeapon(1,  10,  15,	1100, 		6.0,	6.5)
	--							 Arc, Dir, Rotate speed
		p:setBeamWeaponTurret(0, 100, -15, .2)		--slower turret speed (vs 6)
		p:setBeamWeaponTurret(1, 100,  15, .2)
		p:setWeaponTubeCount(2)						--more tubes (vs 0)
		p:setWeaponTubeDirection(0,180)				
		p:setWeaponTubeDirection(1,180)
		p:setWeaponStorageMax("Homing",4)
		p:setWeaponStorage("Homing", 4)	
		p:setWeaponStorageMax("Nuke",2)	
		p:setWeaponStorage("Nuke", 2)	
		p:setWeaponStorageMax("EMP",3)	
		p:setWeaponStorage("EMP", 3)		
		p:setWeaponStorageMax("Mine",3)	
		p:setWeaponStorage("Mine", 3)	
		p:setWeaponStorageMax("HVLI",6)	
		p:setWeaponStorage("HVLI", 6)	
	elseif custom_template == "Focus" then
		p:setTemplate("Crucible")
		p:setTypeName("Focus")
		p:setImpulseMaxSpeed(70)					--slower (vs 80)
		p:setRotationMaxSpeed(20)					--faster spin (vs 15)
		p:setWarpDrive(false)						--no warp
		p:setHullMax(100)							--weaker hull (vs 160)
		p:setHull(100)
		p:setShieldsMax(100, 100)					--weaker shields (vs 160, 160)
		p:setShields(100, 100)
	--                 	   Arc, Dir,  Range,  CycleTime, Damage
		p:setBeamWeapon(0,  60, -20, 1000.0,		6.0, 5)	--narrower (vs 70)
		p:setBeamWeapon(1,  60,  20, 1000.0,		6.0, 5)	
		p:setWeaponTubeCount(4)						--fewer (vs 6)
		p:weaponTubeAllowMissle(2,"Homing")			--big tube shoots more stuff (vs HVLI)
		p:weaponTubeAllowMissle(2,"EMP")
		p:weaponTubeAllowMissle(2,"Nuke")
		p:setWeaponTubeExclusiveFor(3,"Mine")		--rear (vs left)
		p:setWeaponTubeDirection(3, 180)
		p:setWeaponStorageMax("EMP",2)				--fewer (vs 6)
		p:setWeaponStorage("EMP", 2)				
		p:setWeaponStorageMax("Nuke",1)				--fewer (vs 4)
		p:setWeaponStorage("Nuke", 1)	
	elseif custom_template == "Holmes" then
		p:setTemplate("Crucible")
		p:setTypeName("Holmes")
		p:setImpulseMaxSpeed(70)					--slower (vs 80)
	--					  Arc, Dir, Range, CycleTime, Dmg
		p:setBeamWeapon(0, 50, -85, 900.0, 		6.0, 5)	--broadside beams, narrower (vs 70)
		p:setBeamWeapon(1, 50, -95, 900.0, 		6.0, 5)	
		p:setBeamWeapon(2, 50,  85, 900.0, 		6.0, 5)	
		p:setBeamWeapon(3, 50,  95, 900.0, 		6.0, 5)	
		p:setWeaponTubeCount(4)						--fewer (vs 6)
		p:setWeaponTubeExclusiveFor(0,"Homing")		--tubes only shoot homing missiles (vs more options)
		p:setWeaponTubeExclusiveFor(1,"Homing")
		p:setWeaponTubeExclusiveFor(2,"Homing")
		p:setWeaponTubeExclusiveFor(3,"Mine")
		p:setWeaponTubeDirection(3, 180)
		p:setWeaponStorageMax("Homing",10)			--more (vs 8)
		p:setWeaponStorage("Homing", 10)				
		p:setWeaponStorageMax("HVLI",0)				--fewer
		p:setWeaponStorage("HVLI", 0)				
		p:setWeaponStorageMax("EMP",0)				--fewer
		p:setWeaponStorage("EMP", 0)				
		p:setWeaponStorageMax("Nuke",0)				--fewer
		p:setWeaponStorage("Nuke", 0)	
	elseif custom_template == "Maverick XP" then
		p:setTemplate("Maverick")
		p:setTypeName("Maverick XP")
		p:setImpulseMaxSpeed(65)				--slower impulse max (vs 80)
		p:setWarpDrive(false)					--no warp
	--					  Arc, Dir,  Range, CycleTime, Dmg
		p:setBeamWeapon(0, 10,   0, 1000.0,      20.0, 20)
	--							 Arc, Dir, Rotate speed
		p:setBeamWeaponTurret(0, 270,   0, .4)
		p:setBeamWeaponEnergyPerFire(0,p:getBeamWeaponEnergyPerFire(0)*6)
		p:setBeamWeaponHeatPerFire(0,p:getBeamWeaponHeatPerFire(0)*5)
		p:setBeamWeapon(1, 0, 0, 0, 0, 0)		--eliminate 5 beams
		p:setBeamWeapon(2, 0, 0, 0, 0, 0)				
		p:setBeamWeapon(3, 0, 0, 0, 0, 0)				
		p:setBeamWeapon(4, 0, 0, 0, 0, 0)	
		p:setBeamWeapon(5, 0, 0, 0, 0, 0)	
	elseif custom_template == "Phobos T2" then
		p:setTemplate("Phobos M3P")
		p:setTypeName("Phobos T2")
		p:setRepairCrewCount(4)					--more repair crew (vs 3)
		p:setRotationMaxSpeed(20)				--faster spin (vs 10)
		p:setShieldsMax(120,80)					--stronger front, weaker rear (vs 100,100)
		p:setShields(120,80)
		p:setMaxEnergy(800)						--less maximum energy (vs 1000)
		p:setEnergy(800)
	--					  Arc, Dir, Range, CycleTime, Dmg
		p:setBeamWeapon(0, 10, -30,  1200,         4, 6)	--split direction (30 vs 15)
		p:setBeamWeapon(1, 10,  30,  1200,         4, 6)	--reduced cycle time (4 vs 8)
	--							Arc, Dir, Rotate speed
		p:setBeamWeaponTurret(0, 60, -30, .3)	--slow turret beams
		p:setBeamWeaponTurret(1, 60,  30, .3)
		p:setWeaponTubeCount(2)					--one fewer tube (1 forward, 1 rear vs 2 forward, 1 rear)
		p:setWeaponTubeDirection(0,0)			--first tube points straight forward
		p:setWeaponTubeDirection(1,180)			--second tube points straight back
		p:setWeaponTubeExclusiveFor(1,"Mine")
		p:setWeaponStorageMax("Homing",8)		--reduce homing storage (vs 10)
		p:setWeaponStorage("Homing",8)
		p:setWeaponStorageMax("HVLI",16)		--reduce HVLI storage (vs 20)
		p:setWeaponStorage("HVLI",16)
	end
	return p
end
function placeDefaultPlayerShips()
	player_restart = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			p:destroy()
		end
	end
	angle = faction_angle["Human Navy"]
	for _, template in ipairs(default_player_ship_sets[ships_per_team]) do
		local p = PlayerSpaceship():setTemplate(template):setFaction("Human Navy")
		setPlayer(p)
		startPlayerPosition(p,angle)
		local respawn_x, respawn_y = p:getPosition()
		p.respawn_x = respawn_x
		p.respawn_y = respawn_y
		player_restart[p:getCallSign()] = {self = p, template = p:getTypeName(), control_code = p.control_code, faction = p:getFaction(), respawn_x = respawn_x, respawn_y = respawn_y}
		angle = (angle + 360/ships_per_team) % 360
	end
	replicatePlayers("Kraylor")
	if exuari_angle ~= nil then
		replicatePlayers("Exuari")
	end
	if ktlitan_angle ~= nil then
		replicatePlayers("Ktlitans")
	end
end
function startPlayerPosition(p,angle)
--	print("start player position angle:",angle)
	vx, vy = vectorFromAngleNorth(angle,player_position_distance)
	p:setPosition(faction_primary_station[p:getFaction()].x + vx, faction_primary_station[p:getFaction()].y + vy):setHeading(angle):commandTargetRotation((angle + 270) % 360)
end
function replicatePlayers(faction)
--	Replicate the Human Navy player ships to the designated faction
--	print("replicate players faction:",faction)
	local angle = faction_angle[faction]
	local temp_player_restart = {}
	for name, details in pairs(player_restart) do
--		print("player restart item faction:",details.faction)
		if details.faction == "Human Navy" then
--			print("name:",name,"details:",details,"details.template:",details.template,"faction:",faction)
			local p = PlayerSpaceship()
			if p ~= nil and p:isValid() then
				if player_ship_stats[details.template].stock then
					p:setTemplate(details.template)
				else
					customPlayerShip(details.template,p)
				end
				p:setFaction(faction)
				setPlayer(p)
				startPlayerPosition(p,angle)
				local respawn_x, respawn_y = p:getPosition()
				p.respawn_x = respawn_x
				p.respawn_y = respawn_y
				temp_player_restart[p:getCallSign()] = {self = p, template = p:getTypeName(), control_code = p.control_code, faction = p:getFaction(), respawn_x = respawn_x, respawn_y = respawn_y}
				angle = (angle + 360/ships_per_team) % 360
			else
				addGMMessage("Player creation failed")
			end
		end
	end
	for name, details in pairs(temp_player_restart) do
		player_restart[name] = {self = details.self, template = details.template, control_code = details.control_code, faction = details.faction, respawn_x = details.respawn_x, respawn_y = details.respawn_y}
	end
end
function namePlayerShip(p)
	if p.name == nil then
		if rwc_player_ship_names[template_player_type] ~= nil and #rwc_player_ship_names[template_player_type] > 0 then
			local selected_name_index = math.random(1,#rwc_player_ship_names[template_player_type])
			p:setCallSign(rwc_player_ship_names[template_player_type][selected_name_index])
			table.remove(rwc_player_ship_names[template_player_type],selected_name_index)
		else
			if rwc_player_ship_names["Unknown"] ~= nil and #rwc_player_ship_names["Unknown"] > 0 then
				selected_name_index = math.random(1,#rwc_player_ship_names["Unknown"])
				p:setCallSign(rwc_player_ship_names["Unknown"][selected_name_index])
				table.remove(rwc_player_ship_names["Unknown"],selected_name_index)
			end
		end
	end
	p.name = "set"
end
function playerDestroyed(self,instigator)
	respawn_count = respawn_count + 1
	if respawn_count > 300 then
		print("Hit respawn limit")
		return
	end
	local name = self:getCallSign()
	local faction = self:getFaction()
	local old_template = self:getTypeName()
	local p = PlayerSpaceship()
	if p ~= nil and p:isValid() then
		if respawn_type == "lindworm" then
			p:setTemplate("ZX-Lindworm")
		elseif respawn_type == "self" then
			p:setTemplate(old_template)
			death_penalty[faction] = death_penalty[faction] + self.shipScore
		end
		p:setFaction(faction)
		p.control_code = self.control_code
		p:setControlCode(p.control_code)
		local name_15 = string.lpad(p:getCallSign(),15)
		local cc_15 = string.lpad(p.control_code,15)
--		print(p:getCallSign(),"Control code:",p.control_code,"Faction:",faction)
		print(name_15,"Control code:",cc_15,"Faction:",faction)
		if respawn_type == "lindworm" then
			if old_template == "ZX-Lindworm" then
				resetPlayer(p,name)
			else
				resetPlayer(p)
			end
		elseif respawn_type == "self" then
			resetPlayer(p,name)
		end
		p:setPosition(self.respawn_x, self.respawn_y)
		p.respawn_x = self.respawn_x
		p.respawn_y = self.respawn_y
		if respawn_type == "lindworm" then
			player_restart[name] = {self = p, template = "ZX-Lindworm", control_code = p.control_code, faction = faction, respawn_x = self.respawn_x, respawn_y = self.respawn_y}
		elseif respawn_type == "self" then
			player_restart[name] = {self = p, template = old_template, control_code = p.control_code, faction = faction, respawn_x = self.respawn_x, respawn_y = self.respawn_y}
		end
	else
		respawn_countdown = 2
		if restart_queue == nil then
			restart_queue = {}
		end
		table.insert(restart_queue,name)
	end
end
function string.lpad(str, len, char)
	if char == nil then
		char = " "
	end
	return str .. string.rep(char, len - string.len(str))
end
function delayedRespawn(name)
	if name == nil then
		if restart_queue ~= nil then
			if #restart_queue > 0 then
				name = restart_queue[1]
			else
				respawn_countdown = nil
				return
			end
		else
			respawn_countdown = nil
			return
		end
	end
	if player_restart[name] ~= nil then
		local faction = player_restart[name].faction
		local old_template = player_restart[name].template
		local p = PlayerSpaceship()
		if p~= nil and p:isValid() then
			if respawn_type == "lindworm" then
				p:setTemplate("ZX-Lindworm")
			elseif respawn_type == "self" then
				p:setTemplate(old_template)
				death_penalty[faction] = death_penalty[faction] + self.shipScore
			end
			p:setFaction(faction)
			p.control_code = player_restart[name].control_code
			p:setControlCode(p.control_code)
			local name_15 = string.lpad(p:getCallSign(),15)
			local cc_15 = string.lpad(p.control_code,15)
			print(name_15,"Control code:",cc_15,"Faction:",faction)
--			print(p:getCallSign(),"Control code:",p.control_code,"Faction:",faction)
			if respawn_type == "lindworm" then
				if old_template == "ZX-Lindworm" then
					resetPlayer(p,name)
				else
					resetPlayer(p)
				end
			elseif respawn_type == "self" then
				resetPlayer(p,name)
			end
			p:setPosition(player_restart[name].respawn_x,player_restart[name].respawn_y)
			p.respawn_x = player_restart[name].respawn_x
			p.respawn_y = player_restart[name].respawn_y
			if respawn_type == "lindworm" then
				player_restart[name] = {self = p, template = "ZX-Lindworm", control_code = p.control_code, faction = faction, respawn_x = player_restart[name].respawn_x, respawn_y = player_restart[name].respawn_y}
			elseif respawn_type == "self" then
				player_restart[name] = {self = p, template = old_template, control_code = p.control_code, faction = faction, respawn_x = player_restart[name].respawn_x, respawn_y = player_restart[name].respawn_y}
			end
			if restart_queue ~= nil and #restart_queue > 0 then
				for i=1,#restart_queue do
					if restart_queue[i] == name then
						table.remove(restart_queue,i)
						respawn_countdown = nil
						break
					end
				end
			end
		else
			if restart_queue ~= nil and #restart_queue > 0 then
				respawn_countdown = 2
			end
		end
	else
		if restart_queue ~= nil then
			if #restart_queue > 0 then
				for i=1,#restart_queue do
					if restart_queue[i] == name then
						table.remove(restart_queue,i)
						print("problem with " .. name)
						break
					end
				end
			end
		end
	end
end
function resetPlayer(p,name)
	local faction = p:getFaction()
	if name == nil then
		namePlayerShip(p)
	else
		p:setCallSign(name)
		p.name = "set"
	end
	commonPlayerSet(p)
end
function commonPlayerSet(p)
	local template_player_type = p:getTypeName()
	if template_player_type == "Player Fighter" then
--						  Arc, Dir, Range, CycleTime, Dmg
		p:setBeamWeapon(0, 40,   0,   500,         6, 4)
		p:setBeamWeapon(2, 40, -10,  1000,         6, 8)
	end
	p.shipScore = player_ship_stats[template_player_type].strength
	p.maxCargo = player_ship_stats[template_player_type].cargo
	p.cargo = p.maxCargo
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
	if p:getWeaponTubeCount() > 0 then
		p.healthyMissile = 1.0
		p.prevMissile = 1.0
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
	p:setLongRangeRadarRange(player_ship_stats[template_player_type].long_range_radar)
	p:setShortRangeRadarRange(player_ship_stats[template_player_type].short_range_radar)
	p.normal_long_range_radar = p:getLongRangeRadarRange()
	p:setMaxScanProbeCount(player_ship_stats[template_player_type].probes)
	p:setScanProbeCount(p:getMaxScanProbeCount())
	if (not p:hasSystem("jumpdrive") and player_ship_stats[template_player_type].long_jump > 0) or
		(p:hasSystem("jumpdrive") and player_ship_stats[template_player_type].long_jump ~= 50) then
		p:setJumpDrive(true)
		p.max_jump_range = player_ship_stats[template_player_type].long_jump*1000
		p.min_jump_range = player_ship_stats[template_player_type].short_jump*1000
		p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
		p:setJumpDriveCharge(p.max_jump_range)
	end
	if not p:hasSystem("warp") and player_ship_stats[template_player_type].warp > 0 then
		p:setWarpDrive(true)
		p:setWarpSpeed(player_ship_stats[template_player_type].warp)
	end
	p:onDestroyed(playerDestroyed)
end
function setPlayer(p)
	local faction = p:getFaction()
	namePlayerShip(p)
--	p:addReputationPoints(1000)	--testing only
	p:addReputationPoints(base_reputation)
	local control_code_index = math.random(1,#control_code_stem)
	local stem = control_code_stem[control_code_index]
	table.remove(control_code_stem,control_code_index)
	local branch = math.random(100,999)
	p.control_code = stem .. branch
	local name_15 = string.lpad(p:getCallSign(),15)
	local cc_15 = string.lpad(p.control_code,15)
	print(name_15,"Control code:",cc_15,"Faction:",faction)
--	print(p:getCallSign(),"Control code:",p.control_code,"Faction:",faction)
	p:setControlCode(stem .. branch)
	commonPlayerSet(p)
end
--	Station placement related functions
function pickStation(name)
--	print("pick station name")
	if station_pool == nil then
		populateStationPool()
	end
	local selected_station_name = nil
	local station_selection_list = {}
	local selected_station = nil
	local station = nil
	if name == nil then
		--default to random in priority order
		for _, group in ipairs(station_priority) do
			if station_pool[group] ~= nil then
				for station, details in pairs(station_pool[group]) do
					table.insert(station_selection_list,station)
				end
				if #station_selection_list > 0 then
					if selected_station_name == nil then
						selected_station_name = station_selection_list[math.random(1,#station_selection_list)]
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station_name):setDescription(station_pool[group][selected_station_name].description)
						station.comms_data = station_pool[group][selected_station_name]
						station_pool[group][selected_station_name] = nil
						return group, station
					end
				end
			end
		end
	else
--		print("name parameter provided:",name)
		if name == "Random" then
			--random across all groups
			for group, list in pairs(station_pool) do
				for station_name, station_details in pairs(list) do
					table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomHumanNeutral" then
			for group, list in pairs(station_pool) do
				if group ~= "Generic" and group ~= "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		elseif name == "RandomGenericSinister" then
			for group, list in pairs(station_pool) do
				if group == "Generic" or group == "Sinister" then
					for station_name, station_details in pairs(list) do
						table.insert(station_selection_list,{group = group, station_name = station_name, station_details = station_details})
					end
				end
			end
			if #station_selection_list > 0 then
				selected_station = station_selection_list[math.random(1,#station_selection_list)]
				station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
				station.comms_data = selected_station.station_details
				station_pool[selected_station.group][selected_station.station_name] = nil
				return selected_station.group, station
			end
		else
--			print("not one of the generic random names")
			if station_pool[name] ~= nil then
--				print("name is a group name")
				--name is a group name
				for station_name, station_details in pairs(station_pool[name]) do
					table.insert(station_selection_list,{station_name = station_name, station_details = station_details})
				end
				if #station_selection_list > 0 then
					selected_station = station_selection_list[math.random(1,#station_selection_list)]
					station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(selected_station.station_name):setDescription(selected_station.station_details.description)
					station.comms_data = selected_station.station_details
					station_pool[name][selected_station.station_name] = nil
					return name, station
				end
			else
--				print("name is not a group name")
				for group, list in pairs(station_pool) do
					if station_pool[group][name] ~= nil then
						station = SpaceStation():setCommsScript(""):setCommsFunction(commsStation):setCallSign(name):setDescription(station_pool[group][name].description)
						station.comms_data = station_pool[group][name]
						station_pool[group][name] = nil
						return group, station
					end
				end
				--name not found in any group
				print("Name provided not found in groups or stations, nor is it an accepted specialized name, like Random, RandomHumanNeutral or RandomGenericSinister")
				return nil
			end
		end
	end
	return nil
end
function szt()
--Randomly choose station size template
	if stationSize ~= nil then
		sizeTemplate = stationSize
		return sizeTemplate
	end
	stationSizeRandom = random(1,100)
	if stationSizeRandom < 8 then
		sizeTemplate = "Huge Station"		-- 8 percent huge
	elseif stationSizeRandom < 24 then
		sizeTemplate = "Large Station"		--16 percent large
	elseif stationSizeRandom < 50 then
		sizeTemplate = "Medium Station"		--26 percent medium
	else
		sizeTemplate = "Small Station"		--50 percent small
	end
	return sizeTemplate
end
function placeStation(x,y,name,faction,size)
	--x and y are the position of the station
	--name should be the name of the station or the name of the station group
	--		omit name to get random station from groups in priority order
	--faction is the faction of the station
	--		omit and stationFaction will be used
	--size is the name of the station template to use
	--		omit and station template will be chosen at random via szt function
	if x == nil then return nil end
	if y == nil then return nil end
	local group, station = pickStation(name)
	if group == nil then return nil end
	station:setPosition(x,y)
	if faction ~= nil then
		station:setFaction(faction)
	else
		if stationFaction ~= nil then
			station:setFaction(stationFaction)
		else
			station:setFaction("Independent")
		end
	end
	if size == nil then
		station:setTemplate(szt())
	else
		local function Set(list)
			local set = {}
			for _, item in ipairs(list) do
				set[item] = true
			end
			return set
		end
		local station_size_templates = Set{"Small Station","Medium Station","Large Station","Huge Station"}
		if station_size_templates[size] then
			station:setTemplate(size)
		else
			station:setTemplate(szt())
		end
	end
	local size_matters = 0
	local station_size = station:getTypeName()
	if station_size == "Medium Station" then
		size_matters = 20
	elseif station_size == "Large Station" then
		size_matters = 30
	elseif station_size == "Huge Station" then
		size_matters = 40
	end
	station.comms_data.probe_launch_repair =	random(1,100) <= (20 + size_matters)
	station.comms_data.scan_repair =			random(1,100) <= (30 + size_matters)
	station.comms_data.hack_repair =			random(1,100) <= (10 + size_matters)
	station.comms_data.combat_maneuver_repair =	random(1,100) <= (15 + size_matters)
	station.comms_data.self_destruct_repair =	random(1,100) <= (25 + size_matters)
	station.comms_data.jump_overcharge =		random(1,100) <= (5 + size_matters)
	station:setSharesEnergyWithDocked(random(1,100) <= (50 + size_matters))
	station:setRepairDocked(random(1,100) <= (55 + size_matters))
	station:setRestocksScanProbes(random(1,100) <= (45 + size_matters))
	--specialized code for particular stations
	return station
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
function populateStationPool()
	station_pool = {
		["Science"] = {
			["Asimov"] = {
		        weapon_available = 	{
		        	Homing =			true,
		        	HVLI =				random(1,13)<=(9-difficulty),
		        	Mine =				true,
		        	Nuke =				random(1,13)<=(5-difficulty),
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop = "friend",
					reinforcements = "friend",
					jumpsupplydrop = "friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 			1.0, 
		        	neutral = 			3.0,
		        },
        		goods = {	
        			tractor = {
        				quantity =	5,	
        				cost =		48,
        			},
        			repulsor = {
        				quantity =	5,
        				cost =		48,
        			},
        		},
		        trade = {	
		        	food =			false, 
		        	medicine =		false, 
		        	luxury =		false,
		        },
				description = "Training and Coordination", 
				general = "We train naval cadets in routine and specialized functions aboard space vessels and coordinate naval activity throughout the sector", 
				history = "The original station builders were fans of the late 20th century scientist and author Isaac Asimov. The station was initially named Foundation, but was later changed simply to Asimov. It started off as a stellar observatory, then became a supply stop and as it has grown has become an educational and coordination hub for the region",
			},
			["Armstrong"] =	{
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					warp = {
						quantity =	5,	
						cost =		77,
					},
					repulsor = {
						quantity =	5,	
						cost =		62,
					},
				},
				trade = {	
					food = random(1,100) <= 45, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp and Impulse engine manufacturing", 
				general = "We manufacture warp, impulse and jump engines for the human navy fleet as well as other independent clients on a contract basis", 
				history = "The station is named after the late 19th century astronaut as well as the fictionlized stations that followed. The station initially constructed entire space worthy vessels. In time, it transitioned into specializeing in propulsion systems.",
			},
			["Broeck"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					warp = {
						quantity =	5,
						cost =		36,
					},
				},
				trade = {
					food = random(1,100) <= 14, 
					medicine = false, 
					luxury = random(1,100) < 62,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Warp drive components", 
				general = "We provide warp drive engines and components", 
				history = "This station is named after Chris Van Den Broeck who did some initial research into the possibility of warp drive in the late 20th century on Earth",
			},
			["Coulomb"] = {
		        weapon_available = 	{
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			circuit =	{
        				quantity =	5,	
        				cost =		50,
        			},
        		},
        		trade = {	
        			food = random(1,100) <= 35, 
        			medicine = false, 
        			luxury = random(1,100) < 82,
        		},
				buy =	{
					[randomMineral()] = math.random(40,200),
				},
				description = "Shielded circuitry fabrication", 
				general = "We make a large variety of circuits for numerous ship systems shielded from sensor detection and external control interference", 
				history = "Our station is named after the law which quantifies the amount of force with which stationary electrically charged particals repel or attact each other - a fundamental principle in the design of our circuits",
			},
			["Heyes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		72,
					},
				},
				trade = {
					food = random(1,100) <= 32, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Sensor components", 
				general = "We research and manufacture sensor components and systems", 
				history = "The station is named after Tony Heyes the inventor of some of the earliest electromagnetic sensors in the mid 20th century on Earth in the United Kingdom to assist blind human mobility",
			},
			["Hossam"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nanites = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) < 24, 
					medicine = random(1,100) < 44, 
					luxury = random(1,100) < 63,
				},
				description = "Nanite supplier", 
				general = "We provide nanites for various organic and non-organic systems", 
				history = "This station is named after the nanotechnologist Hossam Haick from the early 21st century on Earth in Israel",
			},
			["Maiman"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = random(1,100) <= 75, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Energy beam components", 
				general = "We research and manufacture energy beam components and systems", 
				history = "The station is named after Theodore Maiman who researched and built the first laser in the mid 20th century on Earth",
			},
			["Malthus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
    			trade = {
    				food = random(1,100) <= 65, 
    				medicine = false, 
    				luxury = false,
    			},
    			description = "Gambling and resupply",
		        general = "The oldest station in the quadrant",
		        history = "",
			},
			["Marconi"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = random(1,100) <= 53, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy Beam Components", 
				general = "We manufacture energy beam components", 
				history = "Station named after Guglielmo Marconi an Italian inventor from early 20th century Earth who, along with Nicolo Tesla, claimed to have invented a death ray or particle beam weapon",
			},
			["Miller"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = random(1,100) <= 68, 
					medicine = false, 
					luxury = false,
				},
				description = "Exobiology research", 
				general = "We study recently discovered life forms not native to Earth", 
				history = "This station was named after one of the early exobiologists from mid 20th century Earth, Dr. Stanley Miller",
			},
			["Shawyer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		100,
					},
				},
				trade = {
					food = random(1,100) <= 42, 
					medicine = false, 
					luxury = true,
				},
				description = "Impulse engine components", 
				general = "We research and manufacture impulse engine components and systems", 
				history = "The station is named after Roger Shawyer who built the first prototype impulse engine in the early 21st century",
			},
		},
		["History"] = {
			["Archimedes"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					beam = {
						quantity =	5,
						cost =		80,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				description = "Energy and particle beam components", 
				general = "We fabricate general and specialized components for ship beam systems", 
				history = "This station was named after Archimedes who, according to legend, used a series of adjustable focal length mirrors to focus sunlight on a Roman naval fleet invading Syracuse, setting fire to it",
			},
			["Chatuchak"] =	{
		        weapon_available = {
		        	Homing =				random(1,10)<=(8-difficulty),	
		        	HVLI =				random(1,10)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,10)<=(5-difficulty),	
		        	EMP =				random(1,10)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Only the largest market and trading location in twenty sectors. You can find your heart's desire here", 
				history = "Modeled after the early 21st century bazaar on Earth in Bangkok, Thailand. Designed and built with trade and commerce in mind",
			},
			["Grasberg"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general ="We mine nearby asteroids for precious minerals and process them for sale", 
				history = "This station's name is inspired by a large gold mine on Earth in Indonesia. The station builders hoped to have a similar amount of minerals found amongst these asteroids",
			},
			["Hayden"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					nanites = {
						quantity =	5,
						cost =		65,
					},
				},
				trade = {
					food = random(1,100) <= 85, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory and stellar mapping", 
				general = "We study the cosmos and map stellar phenomena. We also track moving asteroids. Look out! Just kidding", 
				history = "Station named in honor of Charles Hayden whose philanthropy continued astrophysical research and education on Earth in the early 20th century",
			},
			["Lipkin"] = {
		        weapon_available = {
		        	Homing =				random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Autodoc components", 
				general = "", 
				history = "The station is named after Dr. Lipkin who pioneered some of the research and application around robot assisted surgery in the area of partial nephrectomy for renal tumors in the early 21st century on Earth",
			},
			["Madison"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(60,70),
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				description = "Zero gravity sports and entertainment", 
				general = "Come take in a game or two or perhaps see a show", 
				history = "Named after Madison Square Gardens from 21st century Earth, this station was designed to serve similar purposes in space - a venue for sports and entertainment",
			},
			["Rutherford"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					shield = {
						quantity =	5,	
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 43,
				},
				description = "Shield components and research", 
				general = "We research and fabricate components for ship shield systems", 
				history = "This station was named after the national research institution Rutherford Appleton Laboratory in the United Kingdom which conducted some preliminary research into the feasability of generating an energy shield in the late 20th century",
			},
			["Toohie"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = random(1,100) <= 21, 
					medicine = false, 
					luxury = true,
				},
				description = "Shield and armor components and research", 
				general = "We research and make general and specialized components for ship shield and ship armor systems", 
				history = "This station was named after one of the earliest researchers in shield technology, Alexander Toohie back when it was considered impractical to construct shields due to the physics involved."},
		},
		["Pop Sci Fi"] = {
			["Anderson"] = {
		        weapon_available = {
		        	Homing = false,		
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					battery = {
						quantity =	5,
						cost =		66,
					},
        			software = {
        				quantity =	5,
        				cost =		115,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Battery and software engineering", 
				general = "We provide high quality high capacity batteries and specialized software for all shipboard systems", 
				history = "The station is named after a fictional software engineer in a late 20th century movie depicting humanity unknowingly conquered by aliens and kept docile by software generated illusion",
			},
			["Archer"] = {
		        weapon_available = {
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI = 				true,		
		        	Mine = 				random(1,13)<=(7-difficulty),	
		        	Nuke = 				random(1,13)<=(5-difficulty),	
		        	EMP = 				true
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Shield and Armor Research", 
				general = "The finest shield and armor manufacturer in the quadrant", 
				history = "We named this station for the pioneering spirit of the 22nd century Starfleet explorer, Captain Jonathan Archer",
			},
			["Barclay"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					communication =	{
						quantity =	5,
						cost =		58,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Communication components", 
				general = "We provide a range of communication equipment and software for use aboard ships", 
				history = "The station is named after Reginald Barclay who established the first transgalactic com link through the creative application of a quantum singularity. Station personnel often refer to the station as the Broccoli station",
			},
			["Calvin"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					robotic = {
						quantity =	5,	
						cost = 		90,
					},
				},
				trade = {
					food = random(1,100) <= 35, 
					medicine = false, 
					luxury = true,
				},
				buy =	{
					[randomComponent("robotic")] = math.random(40,200)
				},
				description = "Robotic research", 
				general = "We research and provide robotic systems and components", 
				history = "This station is named after Dr. Susan Calvin who pioneered robotic behavioral research and programming",
			},
			["Cavor"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced Material components", 
				general = "We fabricate several different kinds of materials critical to various space industries like ship building, station construction and mineral extraction", 
				history = "We named our station after Dr. Cavor, the physicist that invented a barrier material for gravity waves - Cavorite",
			},
			["Cyrus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					impulse = {
						quantity =	5,
						cost =		124,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 78,
				},
				description = "Impulse engine components", 
				general = "We supply high quality impulse engines and parts for use aboard ships", 
				history = "This station was named after the fictional engineer, Cyrus Smith created by 19th century author Jules Verne",
			},
			["Deckard"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "Supplier of android components, programming and service", 
				history = "Named for Richard Deckard who inspired many of the sophisticated safety security algorithms now required for all androids",
			},
			["Erickson"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		63,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Transporter components", 
				general = "We provide transporters used aboard ships as well as the components for repair and maintenance", 
				history = "The station is named after the early 22nd century inventor of the transporter, Dr. Emory Erickson. This station is proud to have received the endorsement of Admiral Leonard McCoy",
			},
			["Jabba"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and gambling", 
				general = "Come play some games and shop. House take does not exceed 4 percent", 
				history = "",
			},			
			["Komov"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		46,
					},
				},
 				trade = {
 					food = false, 
 					medicine = false, 
 					luxury = false,
 				},
				description = "Xenopsychology training", 
				general = "We provide classes and simulation to help train diverse species in how to relate to each other", 
				history = "A continuation of the research initially conducted by Dr. Gennady Komov in the early 22nd century on Venus, supported by the application of these principles",
			},
			["Lando"] = {
		        weapon_available = {
		        	Homing =			true,	
		        	HVLI =				true,	
		        	Mine =				true,	
		        	Nuke =				false,	
		        	EMP =				false,
		        },
				weapon_cost = {
					Homing = math.random(2,5),
					HVLI = 2,
					Mine = math.random(2,5),
				},
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					shield = {
						quantity =	5,
						cost =		90,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Casino and Gambling", 
				general = "", 
				history = "",
			},			
			["Muddville"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		60,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = false,
				},
				description = "Trading station", 
				general = "Come to Muddvile for all your trade and commerce needs and desires", 
				history = "Upon retirement, Harry Mudd started this commercial venture using his leftover inventory and extensive connections obtained while he traveled the stars as a salesman",
			},
			["Nexus-6"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost =		93,
					},
				},
				trade = {
					food = false, 
					medicine = true, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
					[randomComponent("android")] = math.random(40,200),
				},
				description = "Android components", 
				general = "Androids, their parts, maintenance and recylcling", 
				history = "We named the station after the ground breaking android model produced by the Tyrell corporation",
			},
			["O'Brien"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					transporter = {
						quantity =	5,
						cost =		76,
					},
				},
				trade = {
					food = random(1,100) < 13, 
					medicine = true, 
					luxury = random(1,100) < 43,
				},
				description = "Transporter components", 
				general = "We research and fabricate high quality transporters and transporter components for use aboard ships", 
				history = "Miles O'Brien started this business after his experience as a transporter chief",
			},
			["Organa"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		95,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Diplomatic training", 
				general = "The premeire academy for leadership and diplomacy training in the region", 
				history = "Established by the royal family so critical during the political upheaval era",
			},
			["Owen"] = {
		        weapon_available = {
		        	Homing =			true,			
		        	HVLI =				false,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		61,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components for various ship systems", 
				history = "Owens started off in the moisture vaporator business on Tattooine then branched out into load lifters based on acquisition of proprietary software and protocols. The station name recognizes the tragic loss of our founder to Imperial violence",
			},
			["Ripley"] = {
		        weapon_available = {
		        	Homing =			false,		
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					lifter = {
						quantity =	5,
						cost =		82,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 47,
				},
				description = "Load lifters and components", 
				general = "We provide load lifters and components", 
				history = "The station is named after Ellen Ripley who made creative and effective use of one of our load lifters when defending her ship",
			},
			["Skandar"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Routine maintenance and entertainment", 
				general = "Stop by for repairs. Take in one of our juggling shows featuring the four-armed Skandars", 
				history = "The nomadic Skandars have set up at this station to practice their entertainment and maintenance skills as well as build a community where Skandars can relax",
			},			
			["Soong"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					android = {
						quantity =	5,
						cost = 73,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Android components", 
				general = "We create androids and android components", 
				history = "The station is named after Dr. Noonian Soong, the famous android researcher and builder",
			},
			["Starnet"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	software =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Automated weapons systems", 
				general = "We research and create automated weapons systems to improve ship combat capability", 
				history = "Lost the history memory bank. Recovery efforts only brought back the phrase, 'I'll be back'",
			},			
			["Tiberius"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	5,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Logistics coordination", 
				general = "We support the stations and ships in the area with planning and communication services", 
				history = "We recognize the influence of Starfleet Captain James Tiberius Kirk in the 23rd century in our station name",
			},
			["Tokra"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					filament = {
						quantity =	5,
						cost =		42,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Advanced material components", 
				general = "We create multiple types of advanced material components. Our most popular products are our filaments", 
				history = "We learned several of our critical industrial processes from the Tokra race, so we honor our fortune by naming the station after them",
			},
			["Utopia Planitia"] = {
		        weapon_available = 	{
		        	Homing = 			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				true,		
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		167,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = false 
		        },
				description = "Ship building and maintenance facility", 
				general = "We work on all aspects of naval ship building and maintenance. Many of the naval models are researched, designed and built right here on this station. Our design goals seek to make the space faring experience as simple as possible given the tremendous capabilities of the modern naval vessel", 
				history = ""
			},
			["Vaiken"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	10,
						cost = 		1,
					},
        			medicine = {
        				quantity =	5,
        				cost = 		5,
        			},
        			impulse = {
        				quantity =	5,
        				cost = 		math.random(65,97),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Ship building and maintenance facility", 
				general = "", 
				history = "",
			},			
			["Zefram"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {	
		        	warp =	{
		        		quantity =	5,	
		        		cost =		140,
		        	},
		        },
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Warp engine components", 
				general = "We specialize in the esoteric components necessary to make warp drives function properly", 
				history = "Zefram Cochrane constructed the first warp drive in human history. We named our station after him because of the specialized warp systems work we do",
			},
		},
		["Spec Sci Fi"] = {
			["Alcaleica"] =	{
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					optic = {
						quantity =	5,
						cost =		66,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				buy = {
					[randomMineral()] = math.random(40,200),
				},
				description = "Optical Components", 
				general = "We make and supply optic components for various station and ship systems", 
				history = "This station continues the businesses from Earth based on the merging of several companies including Leica from Switzerland, the lens manufacturer and the Japanese advanced low carbon (ALCA) electronic and optic research and development company",
			},
			["Bethesda"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {	
					autodoc = {
						quantity =	5,
						cost =		36,
					},
					medicine = {
						quantity =	5,					
						cost = 		5,
					},
					food = {
						quantity =	math.random(5,10),	
						cost = 		1,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical research", 
				general = "We research and treat exotic medical conditions", 
				history = "The station is named after the United States national medical research center based in Bethesda, Maryland on earth which was established in the mid 20th century",
			},
			["Deer"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and Tractor Beam Components", 
				general = "We can meet all your pushing and pulling needs with specialized equipment custom made", 
				history = "The station name comes from a short story by the 20th century author Clifford D. Simak as well as from the 19th century developer John Deere who inspired a company that makes the Earth bound equivalents of our products",
			},
			["Evondos"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				reputation_cost_multipliers = {
					friend = 1.0, 
					neutral = 3.0,
				},
				goods = {
					autodoc = {
						quantity =	5,
						cost =		56,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = random(1,100) < 41,
				},
				description = "Autodoc components", 
				general = "We provide components for automated medical machinery", 
				history = "The station is the evolution of the company that started automated pharmaceutical dispensing in the early 21st century on Earth in Finland",
			},
			["Feynman"] = {
		        weapon_available = 	{
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				true,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
        		goods = {	
        			software = {
        				quantity = 	5,	
        				cost =		115,
        			},
        			nanites = {
        				quantity =	5,	
        				cost =		79,
        			},
        		},
		        trade = {	
		        	food = false, 
		        	medicine = false, 
		        	luxury = true,
		        },
				description = "Nanotechnology research", 
				general = "We provide nanites and software for a variety of ship-board systems", 
				history = "This station's name recognizes one of the first scientific researchers into nanotechnology, physicist Richard Feynman",
			},
			["Mayo"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					autodoc = {
						quantity =	5,
						cost =		128,
					},
        			food = {
        				quantity =	5,
        				cost =		1,
        			},
        			medicine = {
        				quantity =	5,
        				cost =		5,
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Medical Research", 
				general = "We research exotic diseases and other human medical conditions", 
				history = "We continue the medical work started by William Worrall Mayo in the late 19th century on Earth",
			},
			["Olympus"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		66,
					},
				},
				trade = {	
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Optical components", 
				general = "We fabricate optical lenses and related equipment as well as fiber optic cabling and components", 
				history = "This station grew out of the Olympus company based on earth in the early 21st century. It merged with Infinera, then bought several software comapnies before branching out into space based industry",
			},
			["Panduit"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					optic =	{
						quantity =	5,
						cost =		79,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Optic components", 
				general = "We provide optic components for various ship systems", 
				history = "This station is an outgrowth of the Panduit corporation started in the mid 20th century on Earth in the United States",
			},
			["Shree"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {	
					tractor = {
						quantity =	5,	
						cost =		90,
					},
        			repulsor = {
        				quantity =	5,
        				cost =		math.random(85,95),
        			},
        		},
				trade = {
					food = false, 
					medicine = false, 
					luxury = true,
				},
				description = "Repulsor and tractor beam components", 
				general = "We make ship systems designed to push or pull other objects around in space", 
				history = "Our station is named Shree after one of many tugboat manufacturers in the early 21st century on Earth in India. Tugboats serve a similar purpose for ocean-going vessels on earth as tractor and repulsor beams serve for space-going vessels today",
			},
			["Vactel"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		50,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Shielded Circuitry Fabrication", 
				general = "We specialize in circuitry shielded from external hacking suitable for ship systems", 
				history = "We started as an expansion from the lunar based chip manufacturer of Earth legacy Intel electronic chips",
			},
			["Veloquan"] = {
		        weapon_available = {
		        	Homing = random(1,13)<=(8-difficulty),	
		        	HVLI = random(1,13)<=(9-difficulty),	
		        	Mine = random(1,13)<=(7-difficulty),	
		        	Nuke = random(1,13)<=(5-difficulty),	
		        	EMP = random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					sensor = {
						quantity =	5,
						cost =		68,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Sensor components", 
				general = "We research and construct components for the most powerful and accurate sensors used aboard ships along with the software to make them easy to use", 
				history = "The Veloquan company has its roots in the manufacturing of LIDAR sensors in the early 21st century on Earth in the United States for autonomous ground-based vehicles. They expanded research and manufacturing operations to include various sensors for space vehicles. Veloquan was the result of numerous mergers and acquisitions of several companies including Velodyne and Quanergy",
			},
			["Tandon"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotechnology research",
				general = "Merging the organic and inorganic through research", 
				history = "Continued from the Tandon school of engineering started on Earth in the early 21st century",
			},
		},
		["Generic"] = {
			["California"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {	
					gold = {
						quantity =	5,
						cost =		90,
					},
					dilithium = {
						quantity =	2,					
						cost = 		25,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Impala"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		70,
					},
				},
				trade = {
					food = true, 
					medicine = false, 
					luxury = true,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining", 
				general = "We mine nearby asteroids for precious minerals", 
				history = "",
			},
			["Krak"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				true,		
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Krik"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = true, 
					medicine = true, 
					luxury = random(1,100) < 50,
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Kruk"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					nickel = {
						quantity =	5,
						cost =		20,
					},
				},
				trade = {
					food = random(1,100) < 50, 
					medicine = random(1,100) < 50, 
					luxury = true },
				buy = {
					[randomComponent()] = math.random(40,200),
				},
				description = "Mining station", 
				general = "", 
				history = "",
			},
			["Maverick"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Gambling and resupply", 
				general = "Relax and meet some interesting players", 
				history = "",
			},
			["Nefatha"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Commerce and recreation", 
				general = "", 
				history = "",
			},
			["Okun"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Xenopsychology research", 
				general = "", 
				history = "",
			},
			["Outpost-15"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and trade", 
				general = "", 
				history = "",
			},
			["Outpost-21"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Mining and gambling", 
				general = "", 
				history = "",
			},
			["Outpost-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Outpost-8"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "", 
				general = "", 
				history = "",
			},
			["Outpost-33"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
			["Prada"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				false,		
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Textiles and fashion", 
				general = "", 
				history = "",
			},
			["Research-11"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Stress Psychology Research", 
				general = "", 
				history = "",
			},
			["Research-19"] = {
		        weapon_available ={
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Low gravity research", 
				general = "", 
				history = "",
			},
			["Rubis"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "Get your energy here! Grab a drink before you go!", 
				history = "",
			},
			["Science-2"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					circuit = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Research Lab and Observatory", 
				general = "", 
				history = "",
			},
			["Science-4"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					medicine = {
						quantity =	5,
						cost =		math.random(30,80),
					},
					autodoc = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Biotech research", 
				general = "", 
				history = "",
			},
			["Science-7"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
				goods = {
					food = {
						quantity =	2,
						cost =		1,
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Spot"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 3.0,
		        },
		        goods = {},
		        trade = {
		        	food = false, 
		        	medicine = false, 
		        	luxury = false,
		        },
				description = "Observatory", 
				general = "", 
				history = "",
			},
			["Valero"] = {
		        weapon_available = {
		        	Homing =			random(1,13)<=(8-difficulty),	
		        	HVLI =				random(1,13)<=(9-difficulty),	
		        	Mine =				random(1,13)<=(7-difficulty),	
		        	Nuke =				random(1,13)<=(5-difficulty),	
		        	EMP =				random(1,13)<=(6-difficulty),
		        },
				services = {
					supplydrop =		"friend",
					reinforcements =	"friend",
					jumpsupplydrop =	"friend",
				},
		        service_cost = {
		        	supplydrop =		math.random(80,120), 
		        	reinforcements =	math.random(125,175),
		        	jumpsupplydrop =	math.random(110,140),
		        },
		        reputation_cost_multipliers = {
		        	friend = 1.0, 
		        	neutral = 2.0,
		        },
				goods = {
					luxury = {
						quantity =	5,
						cost =		math.random(30,80),
					},
				},
				trade = {
					food = false, 
					medicine = false, 
					luxury = false,
				},
				description = "Resupply", 
				general = "", 
				history = "",
			},
		},
		["Sinister"] = {
			["Aramanth"] =	{goods = {}, description = "", general = "", history = ""},
			["Empok Nor"] =	{goods = {}, description = "", general = "", history = ""},
			["Gandala"] =	{goods = {}, description = "", general = "", history = ""},
			["Hassenstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Kaldor"] =	{goods = {}, description = "", general = "", history = ""},
			["Magenta Mesra"] =	{goods = {}, description = "", general = "", history = ""},
			["Mos Eisley"] =	{goods = {}, description = "", general = "", history = ""},
			["Questa Verde"] =	{goods = {}, description = "", general = "", history = ""},
			["R'lyeh"] =	{goods = {}, description = "", general = "", history = ""},
			["Scarlet Citadel"] =	{goods = {}, description = "", general = "", history = ""},
			["Stahlstadt"] =	{goods = {}, description = "", general = "", history = ""},
			["Ticonderoga"] =	{goods = {}, description = "", general = "", history = ""},
		},
	}
	station_priority = {}
	table.insert(station_priority,"Science")
	table.insert(station_priority,"Pop Sci Fi")
	table.insert(station_priority,"Spec Sci Fi")
	table.insert(station_priority,"History")
	table.insert(station_priority,"Generic")
	for group, list in pairs(station_pool) do
		local already_inserted = false
		for _, previous_group in ipairs(station_priority) do
			if group == previous_group then
				already_inserted = true
				break
			end
		end
		if not already_inserted and group ~= "Sinister" then
			table.insert(station_priority,group)
		end
	end
end
------------------------------
--	Station communications  --
------------------------------
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
            EMP = "friend",
        },
        weapon_cost = {
            Homing = math.random(1,4),
            HVLI = math.random(1,3),
            Mine = math.random(2,5),
            Nuke = math.random(12,18),
            EMP = math.random(7,13),
        },
        services = {
            supplydrop = "friend",
            reinforcements = "friend",
            sensor_boost = "neutral",
			preorder = "friend",
            activatedefensefleet = "neutral",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            reinforcements = math.random(125,175),
            phobosReinforcements = math.random(200,250),
            stalkerReinforcements = math.random(275,325),
            activatedefensefleet = 20,
        },
        reputation_cost_multipliers = {
            friend = 1.0,
            neutral = 3.0,
        },
        max_weapon_refill_amount = {
            friend = 1.0,
            neutral = 0.5,
        }
    })
    comms_data = comms_target.comms_data
    if comms_source:isEnemy(comms_target) then
        return false
    end
--	if comms_target:areEnemiesInRange(5000) then
--	    setCommsMessage("We are under attack! No time for chatting!");
--		return true
--	end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function commsDefensePlatform()
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
            reinforcements = math.random(125,175),
            phobosReinforcements = math.random(200,250),
            stalkerReinforcements = math.random(275,325)
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
    --    handleDockedState()
    	setCommsMessage(string.format("Hi %s",comms_source:getCallSign()))
		restockOrdnance(commsDefensePlatform)
		completionConditions(commsDefensePlatform)
		dockingServicesStatus(commsDefensePlatform)
		repairSubsystems(commsDefensePlatform)
		stationDefenseReport(commsDefensePlatform)
		if primary_jammers then
			if comms_source:isFriendly(comms_target) then
				addCommsReply(string.format("Transfer to %s",comms_target.primary_station:getCallSign()),function()
					comms_source:commandUndock()
					local psx, psy = comms_target.primary_station:getPosition()
					local angle = comms_source:getHeading()
					local station_dock_radius = {
						["Small Station"] = 300,
						["Medium Station"] = 1000,
						["Large Station"] = 1300,
						["Huge Station"] = 1500,
					}
					local dock_distance = station_dock_radius[comms_target.primary_station:getTypeName()]
					local vx, vy = vectorFromAngleNorth(angle,dock_distance)
					comms_source:setPosition(psx + vx, psy + vy)
					comms_source:commandDock(comms_target.primary_station)
					setCommsMessage(string.format("Don't let %s forget their friends on duty at %s",comms_target.primary_station:getCallSign(),comms_target:getCallSign()))
				end)
			end
		end
	else	--undocked
		local dock_messages = {
			"Dock if you want anything",
			"You must dock before we can do anything",
			"Gotta dock first",
			"Can't do anything for you unless you dock",
			"Docking crew is standing by",
			"Dock first, then talk",
		}
		setCommsMessage(dock_messages[math.random(1,#dock_messages)])
		ordnanceAvailability(commsDefensePlatform)
		completionConditions(commsDefensePlatform)
		dockingServicesStatus(commsDefensePlatform)
		stationDefenseReport(commsDefensePlatform)
	end
	return true
end
function handleDockedState()
    if comms_source:isFriendly(comms_target) then
		oMsg = "Good day, officer!\nWhat can we do for you today?"
    else
		oMsg = "Welcome to our lovely station."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nForgive us if we seem a little distracted. We are carefully monitoring the enemies nearby."
	end
	setCommsMessage(oMsg)
	restockOrdnance(commsStation)
	completionConditions(commsStation)
	dockingServicesStatus(commsStation)
	repairSubsystems(commsStation)
	boostSensorsWhileDocked(commsStation)
	overchargeJump(commsStation)
	activateDefenseFleet(commsStation)
	for _, scientist in ipairs(scientist_list[comms_target:getFaction()]) do
		if scientist.location == comms_target then
			addCommsReply(string.format("Speak with scientist %s",scientist.name),function()
				setCommsMessage(string.format("Greetings, %s\nI've got great ideas for the war effort.\nWhat can I do for you?",comms_source:getCallSign()))
				addCommsReply("Please come aboard our ship",function()
					setCommsMessage(string.format("Certainly, %s\n\n%s boards your ship",comms_source:getCallSign(),scientist.name))
					scientist.location = comms_source
					scientist.location_name = comms_source:getCallSign()
					addCommsReply("Back", commsStation)				
				end)
				addCommsReply("Can you tell me some more about your ideas?",function()
					local rc = false
					local msg = ""
					local completed_message = ""
					local npc_message = ""
					setCommsMessage(string.format("I'd need to visit %s to proceed further",faction_primary_station[comms_target:getFaction()].station:getCallSign()))
					if string.find(scientist.upgrade_requirement,"talk") or string.find(scientist.upgrade_requirement,"meet") then
						if string.find(scientist.upgrade_requirement,"primary") then
							if faction_primary_station[comms_target:getFaction()].station ~= nil and faction_primary_station[comms_target:getFaction()].station:isValid() then
								if faction_primary_station[comms_target:getFaction()].station.available_upgrades == nil then
									faction_primary_station[comms_target:getFaction()].station.available_upgrades = {}
								end
								faction_primary_station[comms_target:getFaction()].station.available_upgrades[scientist.upgrade.name] = scientist.upgrade.action
								setCommsMessage(string.format("I just sent details on a %s to %s. With their facilities, you should be able to apply the upgrade the next time you dock there.",scientist.upgrade.name,faction_primary_station[comms_target:getFaction()].station:getCallSign()))
							else
								setCommsMessage("Without your primary station to apply my research, I'm afraid my information is useless")
							end
						else
							rc, msg = scientist.upgrade.action(comms_source)
							if rc then
								completed_message = string.format("After an extended conversation with %s and the exchange of technical information with various crew members, you apply the insight into %s gained by %s.\n\n%s",scientist.name,scientist.topic,scientist.name,msg)
								if scientist.upgrade_automated_application == "single" then
									setCommsMessage(completed_message)
								elseif scientist.upgrade_automated_application == "players" then
									for pidx=1,32 do
										local p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() and p ~= comms_source and p:getFaction() == comms_source:getFaction() then
											rc, msg = scientist.upgrade.action(p)
											if rc then
												p:addToShipLog(string.format("%s provided details from %s for an upgrade. %s",comms_source:getCallSign(),scientist.name,msg),"Magenta")
											end
										end
									end
									setCommsMessage(completed_message .. "\nThe upgrade details were also provided to the other players in your faction.")
								elseif scientist.upgrade_automated_application == "all" then
									if scientist.upgrade.action ~= longerSensorsUpgrade and scientist.upgrade.action ~= batteryEfficiencyUpgrade then
										if npc_fleet ~= nil and npc_fleet[comms_source:getFaction()] ~= nil and #npc_fleet[comms_source:getFaction()] > 0 then
											for i=1,#npc_fleet[comms_source:getFaction()] do
												local npc = npc_fleet[comms_source:getFaction()][i]
												if npc ~= nil and npc:isValid() then
													rc, msg = scientist.upgrade.action(npc)
												end
											end
											npc_message = "and npc ships "
										end
									end
									for pidx=1,32 do
										local p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() and p ~= comms_source and p:getFaction() == comms_source:getFaction() then
											rc, msg = scientist.upgrade.action(p)
											if rc then
												p:addToShipLog(string.format("%s provided details from %s for an upgrade. %s",comms_source:getCallSign(),scientist.name,msg),"Magenta")
											end
										end
									end
									setCommsMessage(string.format("%s\nThe upgrade details were also provided to the other players %sin your faction.",completed_message,npc_message))
								end
							else
								setCommsMessage(string.format("Your conversation with %s about %s was interesting, but not directly applicable.\n\n%s",scientist.name,scientist.topic,msg))
							end
						end
					elseif scientist.upgrade_requirement == "transport" then
						if comms_target == faction_primary_station[comms_target:getFaction()].station then
							rc, msg = scientist.upgrade.action(comms_source)
							if rc then
								completed_message = string.format("After an extended conversation with %s, various crew members and %s facilities managers, you apply the insight into %s gained by %s.\n\n%s",scientist.name,comms_target:getCallSign(),scientist.topic,scientist.name,msg)
								if faction_primary_station[comms_target:getFaction()].station.available_upgrades == nil then
									faction_primary_station[comms_target:getFaction()].station.available_upgrades = {}
								end
								faction_primary_station[comms_target:getFaction()].station.available_upgrades[scientist.upgrade.name] = scientist.upgrade.action
								setCommsMessage(completed_message)
								if scientist.upgrade_automated_application == "all" then
									if scientist.upgrade.action ~= longerSensorsUpgrade and scientist.upgrade.action ~= batteryEfficiencyUpgrade then
										if npc_fleet ~= nil and npc_fleet[comms_source:getFaction()] ~= nil and #npc_fleet[comms_source:getFaction()] > 0 then
											for i=1,#npc_fleet[comms_source:getFaction()] do
												local npc = npc_fleet[comms_source:getFaction()][i]
												if npc ~= nil and npc:isValid() then
													rc, msg = scientist.upgrade.action(npc)
												end
											end
											npc_message = "and npc ships "
										end
									end
									setCommsMessage(string.format("%s\nNPC ships received the upgrade as well",completed_message))
								end
							else
								setCommsMessage(string.format("Your conversation with %s about %s was interesting, but not directly applicable.\n\n%s",scientist.name,scientist.topic,msg))
								if faction_primary_station[comms_target:getFaction()].station.available_upgrades == nil then
									faction_primary_station[comms_target:getFaction()].station.available_upgrades = {}
								end
								faction_primary_station[comms_target:getFaction()].station.available_upgrades[scientist.upgrade.name] = scientist.upgrade.action
							end
						end
					elseif scientist.upgrade_requirement == "confer" then
						if comms_target == faction_primary_station[comms_target:getFaction()].station then
							local colleage_count = 0
							local conferee = nil
							for _, colleague in ipairs(scientist_list[comms_target:getFaction()]) do
								if colleague.location == comms_target and colleague ~= scientist then
									colleage_count = colleage_count + 1
									conferee = colleague
								end
							end
							if colleage_count > 0 then
								rc, msg = scientist.upgrade.action(comms_source)
								if rc then
									completed_message = string.format("After an extended conversation with %s, %s, various crew members and %s facilities managers, you apply the insight into %s and %s gained by %s.\n\n%s",scientist.name,conferee.name,comms_target:getCallSign(),scientist.topic,conferee.topic,scientist.name,msg)
									if faction_primary_station[comms_target:getFaction()].station.available_upgrades == nil then
										faction_primary_station[comms_target:getFaction()].station.available_upgrades = {}
									end
									faction_primary_station[comms_target:getFaction()].station.available_upgrades[scientist.upgrade.name] = scientist.upgrade.action
									if scientist.upgrade_automated_application == "single" then
										setCommsMessage(completed_message)
									elseif scientist.upgrade_automated_application == "players" then
										for pidx=1,32 do
											local p = getPlayerShip(pidx)
											if p ~= nil and p:isValid() and p ~= comms_source and p:getFaction() == comms_source:getFaction() then
												rc, msg = scientist.upgrade.action(p)
												if rc then
													p:addToShipLog(string.format("%s provided details from %s for an upgrade. %s",comms_source:getCallSign(),scientist.name,msg),"Magenta")
												end
											end
										end
										setCommsMessage(completed_message .. "\nThe upgrade details were also provided to the other players in your faction.")
									elseif scientist.upgrade_automated_application == "all" then
										if scientist.upgrade.action ~= longerSensorsUpgrade and scientist.upgrade.action ~= batteryEfficiencyUpgrade then
											if npc_fleet ~= nil and npc_fleet[comms_source:getFaction()] ~= nil and #npc_fleet[comms_source:getFaction()] > 0 then
												for i=1,#npc_fleet[comms_source:getFaction()] do
													local npc = npc_fleet[comms_source:getFaction()][i]
													if npc ~= nil and npc:isValid() then
														rc, msg = scientist.upgrade.action(npc)
													end
												end
												npc_message = "and npc ships "
											end
										end
										for pidx=1,32 do
											local p = getPlayerShip(pidx)
											if p ~= nil and p:isValid() and p ~= comms_source and p:getFaction() == comms_source:getFaction() then
												rc, msg = scientist.upgrade.action(p)
												if rc then
													p:addToShipLog(string.format("%s provided details from %s for an upgrade. %s",comms_source:getCallSign(),scientist.name,msg),"Magenta")
												end
											end
										end
										setCommsMessage(string.format("%s\nThe upgrade details were also provided to the other players %sin your faction.",completed_message,npc_message))
									end
								else
									setCommsMessage(string.format("Your conversation with %s and %s about %s and %s was interesting, but not directly applicable.\n\n%s",scientist.name,conferee.name,scientist.topic,conferee.topic,msg))
									if faction_primary_station[comms_target:getFaction()].station.available_upgrades == nil then
										faction_primary_station[comms_target:getFaction()].station.available_upgrades = {}
									end
									faction_primary_station[comms_target:getFaction()].station.available_upgrades[scientist.upgrade.name] = scientist.upgrade.action
								end
							else
								setCommsMessage(string.format("I've got this idea for a %s, but I just can't quite get it to crystalize. If I had another scientist here to collaborate with, I might get further along",scientist.upgrade.name))
							end
						end
					end
				end)
				addCommsReply("Back", commsStation)
			end)
		end
		if scientist.location == comms_source then
			addCommsReply(string.format("Escort %s on to %s",scientist.name,comms_target:getCallSign()),function()
				setCommsMessage(string.format("%s thanks you for your hospitality and disembarks to %s",scientist.name,comms_target:getCallSign()))
				scientist.location = comms_target
				scientist.location_name = comms_target:getCallSign()
				addCommsReply("Back", commsStation)
			end)
		end
	end
	if comms_target.available_upgrades ~= nil then
		for name, action in pairs(comms_target.available_upgrades) do
			addCommsReply(name,function()
				string.format("")	--Serious Proton needs global reference/context
				local rc, msg = action(comms_source)
				if rc then	
					setCommsMessage(string.format("Congratulations!\n%s",msg))
				else
					setCommsMessage(string.format("Sorry.\n%s",msg))
				end
			end)
		end
	end
	stationFlavorInformation(commsStation)
	if comms_source:isFriendly(comms_target) then
		if random(1,100) <= (20 - difficulty*2) then
			if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
				hireCost = math.random(30,60)
			else
				hireCost = math.random(45,90)
			end
			addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
				if not comms_source:takeReputationPoints(hireCost) then
					setCommsMessage("Insufficient reputation")
				else
					comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
					resetPreviousSystemHealth(comms_source)
					setCommsMessage("Repair crew member hired")
				end
				addCommsReply("Back", commsStation)
			end)
		end
		if comms_source.initialCoolant ~= nil then
			if math.random(1,100) <= (20 - difficulty*2) then
				local coolantCost = math.random(45,90)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(30,60)
				end
				addCommsReply(string.format("Purchase coolant for %i reputation",coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage("Additional coolant purchased")
					end
					addCommsReply("Back", commsStation)
				end)
			end
		end
	end
	if primary_jammers then
		if comms_source:isFriendly(comms_target) then
			if defense_platform_count > 0 and comms_target == faction_primary_station[comms_source:getFaction()].station then
				addCommsReply("Exit Jammer",function()
					comms_source:commandUndock()
					local psx, psy = comms_target:getPosition()
					local angle = (faction_angle[comms_source:getFaction()] + 180) % 360
					local vx, vy = vectorFromAngleNorth(angle,defense_platform_distance + 4000)
					comms_source:setPosition(psx + vx, psy + vy):setHeading(angle):commandTargetRotation((angle + 270) % 360)
					setCommsMessage("Have fun storming the castle")
				end)
			end
		end
	end
	buySellTrade(commsStation)
end	--end of handleDockedState function
function handleUndockedState()
    --Handle communications when we are not docked with the station.
    if comms_source:isFriendly(comms_target) then
        oMsg = "Good day, officer.\nIf you need supplies, please dock with us first."
    else
        oMsg = "Greetings.\nIf you want to do business, please dock with us first."
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you."
	end
	setCommsMessage(oMsg)
--	expediteDock(commsStation)		--may reinstate if time permits. Needs code in update function, player loop
 	addCommsReply("I need information", function()
		setCommsMessage("What kind of information do you need?")
		ordnanceAvailability(commsStation)
		goodsAvailabilityOnStation(commsStation)
		completionConditions(commsStation)
		dockingServicesStatus(commsStation)
		stationFlavorInformation(commsStation)
		stationDefenseReport(commsStation)
	end)
	requestSupplyDrop(commsStation)
	requestJumpSupplyDrop(commsStation)
	requestReinforcements(commsStation)
	for _, scientist in ipairs(scientist_list[comms_target:getFaction()]) do
		if scientist.location == comms_target then
			addCommsReply(string.format("Speak with scientist %s",scientist.name),function()
				setCommsMessage(string.format("Greetings, %s\nI've got great ideas for the war effort.\nWhat can I do for you?",comms_source:getCallSign()))
				addCommsReply("Can you tell me some more about your ideas?",function()
					local rc = false
					local msg = ""
					local completed_message = ""
					local npc_message = ""
					if string.find(scientist.upgrade_requirement,"talk") then
						if string.find(scientist.upgrade_requirement,"primary") then
							if faction_primary_station[comms_target:getFaction()].station ~= nil and faction_primary_station[comms_target:getFaction()].station:isValid() then
								if faction_primary_station[comms_target:getFaction()].station.available_upgrades == nil then
									faction_primary_station[comms_target:getFaction()].station.available_upgrades = {}
								end
								faction_primary_station[comms_target:getFaction()].station.available_upgrades[scientist.upgrade.name] = scientist.upgrade.action
								setCommsMessage(string.format("I just sent details on a %s to %s. With their facilities, you should be able to apply the upgrade the next time you dock there.",scientist.upgrade.name,faction_primary_station[comms_target:getFaction()].station:getCallSign()))
							else
								setCommsMessage("Without your primary station to apply my research, I'm afraid my information is useless")
							end
						else
							local rc, msg = scientist.upgrade.action(comms_source)
							if rc then
								completed_message = string.format("After an extended conversation with %s and the exchange of technical information with various crew members, you apply the insight into %s gained by %s.\n\n%s",scientist.name,scientist.topic,scientist.name,msg)
								if scientist.upgrade_automated_application == "single" then
									setCommsMessage(completed_message)
								elseif scientist.upgrade_automated_application == "players" then
									for pidx=1,32 do
										local p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() and p ~= comms_source and p:getFaction() == comms_source:getFaction() then
											rc, msg = scientist.upgrade.action(p)
											if rc then
												p:addToShipLog(string.format("%s provided details from %s for an upgrade. %s",comms_source:getCallSign(),scientist.name,msg),"Magenta")
											end
										end
									end
									setCommsMessage(completed_message .. "\nThe upgrade details were also provided to the other players in your faction.")
								elseif scientist.upgrade_automated_application == "all" then
									if scientist.upgrade.action ~= longerSensorsUpgrade and scientist.upgrade.action ~= batteryEfficiencyUpgrade then
										if npc_fleet ~= nil and npc_fleet[comms_source:getFaction()] ~= nil and #npc_fleet[comms_source:getFaction()] > 0 then
											for i=1,#npc_fleet[comms_source:getFaction()] do
												local npc = npc_fleet[comms_source:getFaction()][i]
												if npc ~= nil and npc:isValid() then
													rc, msg = scientist.upgrade.action(npc)
												end
											end
											npc_message = "and npc ships "
										end
									end
									for pidx=1,32 do
										local p = getPlayerShip(pidx)
										if p ~= nil and p:isValid() and p ~= comms_source and p:getFaction() == comms_source:getFaction() then
											rc, msg = scientist.upgrade.action(p)
											if rc then
												p:addToShipLog(string.format("%s provided details from %s for an upgrade. %s",comms_source:getCallSign(),scientist.name,msg),"Magenta")
											end
										end
									end
									setCommsMessage(string.format("%s\nThe upgrade details were also provided to the other players %sin your faction.",completed_message,npc_message))
								end
							else
								setCommsMessage(string.format("Your conversation with %s about %s was interesting, but not directly applicable.\n\n%s",scientist.name,scientist.topic,msg))
							end
							local overhear_chance = 16
							if scientist.upgrade_automated_application == "players" then
								overhear_chance = 28
							end
							if scientist.upgrade_automated_application == "all" then
								overhear_chance = 39
							end
							if random(1,100) <= overhear_chance then
								for pidx=1,32 do
									local p = getPlayerShip(pidx)
									if p ~= nil and p:isValid() then
										if p:getFaction() == comms_source:getFaction() then
											p:addToShipLog(string.format("Communication between %s and %s intercepted by enemy faction",comms_source:getCallSign(),comms_target:getCallSign()),"Magenta")
										else
											p:addToShipLog(string.format("%s conversation intercepted regarding %s. Probable military application. Suggest you contact our own scientist in the same field",comms_source:getFaction(),scientist.topic),"Magenta")
										end
									end
								end
							end
						end
					else
						setCommsMessage("I should not discuss it over an open communication line. Perhaps you should visit and we can talk")
					end
				end)
				addCommsReply("Back", commsStation)
			end)
		end
	end
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) and 
    	comms_target.comms_data.idle_defense_fleet ~= nil then
    	local defense_fleet_count = 0
    	for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    		defense_fleet_count = defense_fleet_count + 1
    	end
    	if defense_fleet_count > 0 then
    		addCommsReply("Activate station defense fleet (" .. getServiceCost("activatedefensefleet") .. " rep)",function()
    			if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
    				local out = string.format("%s defense fleet\n",comms_target:getCallSign())
    				for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    					local script = Script()
						local position_x, position_y = comms_target:getPosition()
						local station_name = comms_target:getCallSign()
						script:setVariable("position_x", position_x):setVariable("position_y", position_y)
						script:setVariable("station_name",station_name)
    					script:setVariable("name",name)
    					script:setVariable("template",template)
    					script:setVariable("faction_id",comms_target:getFactionId())
    					script:run("border_defend_station.lua")
    					out = out .. " " .. name
    					comms_target.comms_data.idle_defense_fleet[name] = nil
    				end
    				out = out .. "\nactivated"
    				setCommsMessage(out)
    			else
    				setCommsMessage("Insufficient reputation")
    			end
				addCommsReply("Back", mainMenu)
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
function getWeaponCost(weapon)
    return math.ceil(comms_data.weapon_cost[weapon] * comms_data.reputation_cost_multipliers[getFriendStatus()])
end
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
function dockingServicesStatus(return_function)
	addCommsReply("Docking services status", function()
		local service_status = string.format("Station %s docking services status:",comms_target:getCallSign())
		if comms_target:getRestocksScanProbes() then
			service_status = string.format("%s\nReplenish scan probes.",service_status)
		else
			if comms_target.probe_fail_reason == nil then
				local reason_list = {
					"Cannot replenish scan probes due to fabrication unit failure.",
					"Parts shortage prevents scan probe replenishment.",
					"Management has curtailed scan probe replenishment for cost cutting reasons.",
				}
				comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
		end
		if comms_target:getRepairDocked() then
			service_status = string.format("%s\nShip hull repair.",service_status)
		else
			if comms_target.repair_fail_reason == nil then
				reason_list = {
					"We're out of the necessary materials and supplies for hull repair.",
					"Hull repair automation unavailable while it is undergoing maintenance.",
					"All hull repair technicians quarantined to quarters due to illness.",
				}
				comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
		end
		if comms_target:getSharesEnergyWithDocked() then
			service_status = string.format("%s\nRecharge ship energy stores.",service_status)
		else
			if comms_target.energy_fail_reason == nil then
				reason_list = {
					"A recent reactor failure has put us on auxiliary power, so we cannot recharge ships.",
					"A damaged power coupling makes it too dangerous to recharge ships.",
					"An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now.",
				}
				comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
		end
		if comms_target.comms_data.jump_overcharge then
			service_status = string.format("%s\nMay overcharge jump drive",service_status)
		end
		if comms_target.comms_data.probe_launch_repair then
			service_status = string.format("%s\nMay repair probe launch system",service_status)
		end
		if comms_target.comms_data.hack_repair then
			service_status = string.format("%s\nMay repair hacking system",service_status)
		end
		if comms_target.comms_data.scan_repair then
			service_status = string.format("%s\nMay repair scanners",service_status)
		end
		if comms_target.comms_data.combat_maneuver_repair then
			service_status = string.format("%s\nMay repair combat maneuver",service_status)
		end
		if comms_target.comms_data.self_destruct_repair then
			service_status = string.format("%s\nMay repair self destruct system",service_status)
		end
		if comms_target.comms_data.tube_slow_down_repair then
			service_status = string.format("%s\nMay repair slow loading tubes",service_status)
		end
		setCommsMessage(service_status)
		addCommsReply("Back", return_function)
	end)
end
function stationFlavorInformation(return_function)
	if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or (comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") then
		addCommsReply("Tell me more about your station", function()
			setCommsMessage("What would you like to know?")
			if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
				addCommsReply("General information", function()
					setCommsMessage(comms_target.comms_data.general)
					addCommsReply("Back", return_function)
				end)
			end
			if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
				addCommsReply("Station history", function()
					setCommsMessage(comms_target.comms_data.history)
					addCommsReply("Back", return_function)
				end)
			end
		end)
	end
end
function stationDefenseReport(return_function)
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. "Shield: " .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. "Shield " .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end			
		setCommsMessage(msg);
		addCommsReply("Back", return_function)
	end)
end
function completionConditions(return_function)
	addCommsReply("What ends the war?",function()
		local out = string.format("The war ends in one of three ways:\n1) Time runs out\n2) A faction drops below half of original score\n3) A faction either leads or trails the other factions by %i%%\n",thresh*100)
		local stat_list = gatherStats()
		out = out .. string.format("\nHuman Navy Current:%.1f Original:%.1f (%.2f%%)",stat_list.human.weighted_score,original_score["Human Navy"],(stat_list.human.weighted_score/original_score["Human Navy"])*100)
		out = out .. string.format("\nKraylor Current:%.1f Original:%.1f (%.2f%%)",stat_list.kraylor.weighted_score,original_score["Kraylor"],(stat_list.kraylor.weighted_score/original_score["Kraylor"])*100)
		if exuari_angle ~= nil then
			out = out .. string.format("\nExuari Current:%.1f Original:%.1f (%.2f%%)",stat_list.exuari.weighted_score,original_score["Exuari"],(stat_list.exuari.weighted_score/original_score["Exuari"])*100)
		end
		if ktlitan_angle ~= nil then
			out = out .. string.format("\nKtlitan Current:%.1f Original:%.1f (%.2f%%)",stat_list.ktlitan.weighted_score,original_score["Ktlitans"],(stat_list.ktlitan.weighted_score/original_score["Ktlitans"])*100)
		end
		out = out .. string.format("\n\nStation weight:%i%%   Player ship weight:%i%%   NPC weight:%i%%",stat_list.weight.station*100,stat_list.weight.ship*100,stat_list.weight.npc*100)
		setCommsMessage(out)
		addCommsReply(string.format("Station values (Total:%i)",stat_list[f2s[comms_source:getFaction()]].station_score_total),function()
			local out = "Stations: (value, type, name)"
			for name, details in pairs(stat_list[f2s[comms_source:getFaction()]].station) do
				out = out .. string.format("\n   %i, %s, %s",details.score_value,details.template_type,name)
			end
			out = out .. string.format("\nTotal:%i multiplied by weight (%i%%) = weighted total:%.1f",stat_list[f2s[comms_source:getFaction()]].station_score_total,stat_list.weight.station*100,stat_list[f2s[comms_source:getFaction()]].station_score_total*stat_list.weight.station)
			setCommsMessage(out)
			addCommsReply("Back", return_function)
		end)
		addCommsReply(string.format("Player ship values (Total:%i)",stat_list[f2s[comms_source:getFaction()]].ship_score_total),function()
			local out = "Player ships: (value, type, name)"
			for name, details in pairs(stat_list[f2s[comms_source:getFaction()]].ship) do
				out = out .. string.format("\n   %i, %s, %s",details.score_value,details.template_type,name)
			end
			out = out .. string.format("\nTotal:%i multiplied by weight (%i%%) = weighted total:%.1f",stat_list[f2s[comms_source:getFaction()]].ship_score_total,stat_list.weight.ship*100,stat_list[f2s[comms_source:getFaction()]].ship_score_total*stat_list.weight.ship)
			setCommsMessage(out)
			addCommsReply("Back", return_function)
		end)
		addCommsReply(string.format("NPC ship values (Total:%i)",stat_list[f2s[comms_source:getFaction()]].npc_score_total),function()
			local out = "NPC assets: value, type, name (location)"
			for name, details in pairs(stat_list[f2s[comms_source:getFaction()]].npc) do
				if details.template_type ~= nil then
					out = out .. string.format("\n   %i, %s, %s",details.score_value,details.template_type,name)
				elseif details.topic ~= nil then
					out = out .. string.format("\n   %i, %s, %s (%s)",details.score_value,details.topic,name,details.location_name)
				end
			end
			out = out .. string.format("\nTotal:%i multiplied by weight (%i%%) = weighted total:%.1f",stat_list[f2s[comms_source:getFaction()]].npc_score_total,stat_list.weight.npc*100,stat_list[f2s[comms_source:getFaction()]].npc_score_total*stat_list.weight.npc)
			setCommsMessage(out)
			addCommsReply("Back", return_function)
		end)
		addCommsReply("Back", return_function)
	end)
end
--	Undocked actions
function getServiceCost(service)
    return math.ceil(comms_data.service_cost[service])
end
function requestSupplyDrop(return_function)
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply("Can you send a supply drop? ("..getServiceCost("supplydrop").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
							setCommsMessage("We have dispatched a supply ship toward WP" .. n);
						else
							setCommsMessage("Not enough reputation!");
						end
                        addCommsReply("Back", return_function)
                    end)
                end
            end
            addCommsReply("Back", return_function)
        end)
    end
end
function requestJumpSupplyDrop(return_function)
	if isAllowedTo(comms_target.comms_data.services.jumpsupplydrop) then
        addCommsReply("Can you send a supply drop via jump ship? ("..getServiceCost("jumpsupplydrop").."rep)", function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage("You need to set a waypoint before you can request backup.");
            else
                setCommsMessage("To which waypoint should we deliver your supplies?");
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("jumpsupplydrop")) then
							local position_x, position_y = comms_target:getPosition()
							local target_x, target_y = comms_source:getWaypoint(n)
							local script = Script()
							script:setVariable("position_x", position_x):setVariable("position_y", position_y)
							script:setVariable("target_x", target_x):setVariable("target_y", target_y)
							script:setVariable("jump_freighter","Yes")
							script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
							setCommsMessage("We have dispatched a supply ship with a jump drive toward WP" .. n);
						else
							setCommsMessage("Not enough reputation!");
						end
                        addCommsReply("Back", return_function)
                    end)
                end
            end
            addCommsReply("Back", return_function)
        end)
    end
end
function requestReinforcements(return_function)
    if isAllowedTo(comms_target.comms_data.services.reinforcements) then
    	addCommsReply("Please send reinforcements",function()
    		if comms_source:getWaypointCount() < 1 then
    			setCommsMessage("You need to set a waypoint before you can request reinforcements")
    		else
    			setCommsMessage("What kind of reinforcements would you like?")
    			addCommsReply(string.format("Standard Adder MK5 (%i Rep)",getServiceCost("reinforcements")),function()
    				if comms_source:getWaypointCount() < 1 then
    					setCommsMessage("You need to set a waypoint before you can request reinforcements")
    				else
		                setCommsMessage("To which waypoint should we dispatch the Adder MK5?");
    					for n=1,comms_source:getWaypointCount() do
    						addCommsReply("Waypoint " .. n, function()
								if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
									ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
									ship:setCommsScript(""):setCommsFunction(commsShip)
									ship.score_value = ship_template["Adder MK5"].strength
									table.insert(npc_fleet[comms_target:getFaction()],ship)
									setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at waypoint " .. n);
								else
									setCommsMessage("Not enough reputation!");
								end
								addCommsReply("Back", return_function)
    						end)
    					end
    				end
    				addCommsReply("Back", return_function)
    			end)
    			if comms_data.service_cost.hornetreinforcements ~= nil then
					addCommsReply(string.format("MU52 Hornet (%i Rep)",getServiceCost("hornetreinforcements")),function()
						if comms_source:getWaypointCount() < 1 then
							setCommsMessage("You need to set a waypoint before you can request reinforcements")
						else
							setCommsMessage("To which waypoint should we dispatch the MU52 Hornet?");
							for n=1,comms_source:getWaypointCount() do
								addCommsReply("Waypoint " .. n, function()
									if comms_source:takeReputationPoints(getServiceCost("hornetreinforcements")) then
										ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("MU52 Hornet"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
										ship:setCommsScript(""):setCommsFunction(commsShip)
										ship.score_value = ship_template["MU52 Hornet"].strength
										table.insert(npc_fleet[comms_target:getFaction()],ship)
										setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at waypoint " .. n);
									else
										setCommsMessage("Not enough reputation!");
									end
									addCommsReply("Back", return_function)
								end)
							end
						end
						addCommsReply("Back", return_function)
					end)
				end
    			if comms_data.service_cost.phobosreinforcements ~= nil then
					addCommsReply(string.format("Phobos T3 (%i Rep)",getServiceCost("phobosreinforcements")),function()
						if comms_source:getWaypointCount() < 1 then
							setCommsMessage("You need to set a waypoint before you can request reinforcements")
						else
							setCommsMessage("To which waypoint should we dispatch the Phobos T3?");
							for n=1,comms_source:getWaypointCount() do
								addCommsReply("Waypoint " .. n, function()
									if comms_source:takeReputationPoints(getServiceCost("phobosreinforcements")) then
										ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Phobos T3"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
										ship:setCommsScript(""):setCommsFunction(commsShip)
										ship.score_value = ship_template["Phobos T3"].strength
										table.insert(npc_fleet[comms_target:getFaction()],ship)
										setCommsMessage("We have dispatched " .. ship:getCallSign() .. " to assist at waypoint " .. n);
									else
										setCommsMessage("Not enough reputation!");
									end
									addCommsReply("Back", return_function)
								end)
							end
						end
						addCommsReply("Back", return_function)
					end)
				end
    		end
            addCommsReply("Back", return_function)
    	end)
    end
end
function ordnanceAvailability(return_function)
	addCommsReply("What ordnance do you have available for restock?", function()
		local missileTypeAvailableCount = 0
		local ordnanceListMsg = ""
		if comms_target.comms_data.weapon_available.Homing and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Homing > 0) then
			missileTypeAvailableCount = missileTypeAvailableCount + 1
			ordnanceListMsg = ordnanceListMsg .. "\n   Homing"
			if not comms_target.comms_data.weapon_inventory.Unlimited then
				ordnanceListMsg = ordnanceListMsg .. string.format("(%i)",math.floor(comms_target.comms_data.weapon_inventory.Homing))
			end
		end
		if comms_target.comms_data.weapon_available.Nuke and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Nuke > 0) then
			missileTypeAvailableCount = missileTypeAvailableCount + 1
			ordnanceListMsg = ordnanceListMsg .. "\n   Nuke"
			if not comms_target.comms_data.weapon_inventory.Unlimited then
				ordnanceListMsg = ordnanceListMsg .. string.format("(%i)",math.floor(comms_target.comms_data.weapon_inventory.Nuke))
			end
		end
		if comms_target.comms_data.weapon_available.Mine and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Mine > 0) then
			missileTypeAvailableCount = missileTypeAvailableCount + 1
			ordnanceListMsg = ordnanceListMsg .. "\n   Mine"
			if not comms_target.comms_data.weapon_inventory.Unlimited then
				ordnanceListMsg = ordnanceListMsg .. string.format("(%i)",math.floor(comms_target.comms_data.weapon_inventory.Mine))
			end
		end
		if comms_target.comms_data.weapon_available.EMP and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.EMP > 0) then
			missileTypeAvailableCount = missileTypeAvailableCount + 1
			ordnanceListMsg = ordnanceListMsg .. "\n   EMP"
			if not comms_target.comms_data.weapon_inventory.Unlimited then
				ordnanceListMsg = ordnanceListMsg .. string.format("(%i)",math.floor(comms_target.comms_data.weapon_inventory.EMP))
			end
		end
		if comms_target.comms_data.weapon_available.HVLI and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.HVLI > 0) then
			missileTypeAvailableCount = missileTypeAvailableCount + 1
			ordnanceListMsg = ordnanceListMsg .. "\n   HVLI"
			if not comms_target.comms_data.weapon_inventory.Unlimited then
				ordnanceListMsg = ordnanceListMsg .. string.format("(%i)",math.floor(comms_target.comms_data.weapon_inventory.HVLI))
			end
		end
		if missileTypeAvailableCount == 0 then
			ordnanceListMsg = "We have no ordnance available for restock"
		elseif missileTypeAvailableCount == 1 then
			ordnanceListMsg = "We have the following type of ordnance available for restock:" .. ordnanceListMsg
		else
			ordnanceListMsg = "We have the following types of ordnance available for restock:" .. ordnanceListMsg
		end
		setCommsMessage(ordnanceListMsg)
		addCommsReply("Back", return_function)
	end)
end
function goodsAvailabilityOnStation(return_function)
	local goodsAvailable = false
	if comms_target.comms_data.goods ~= nil then
		for good, goodData in pairs(comms_target.comms_data.goods) do
			if goodData["quantity"] > 0 then
				goodsAvailable = true
			end
		end
	end
	if goodsAvailable then
		addCommsReply("What goods do you have available for sale or trade?", function()
			local goodsAvailableMsg = string.format("Station %s:\nGoods or components available: quantity, cost in reputation",comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
			end
			setCommsMessage(goodsAvailableMsg)
			addCommsReply("Back", return_function)
		end)
	end
end
function expediteDock(return_function)
	if isAllowedTo(comms_target.comms_data.services.preorder) then
		addCommsReply("Expedite Dock",function()
			if comms_source.expedite_dock == nil then
				comms_source.expedite_dock = false
			end
			if comms_source.expedite_dock then
				--handle expedite request already present
				local existing_expedite = "Docking crew is standing by"
				if comms_target == comms_source.expedite_dock_station then
					existing_expedite = existing_expedite .. ". Current preorders:"
					local preorders_identified = false
					if comms_source.preorder_hvli ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   HVLIs: %i",comms_source.preorder_hvli)
					end
					if comms_source.preorder_homing ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Homings: %i",comms_source.preorder_homing)						
					end
					if comms_source.preorder_mine ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Mines: %i",comms_source.preorder_mine)						
					end
					if comms_source.preorder_emp ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   EMPs: %i",comms_source.preorder_emp)						
					end
					if comms_source.preorder_nuke ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. string.format("\n   Nukes: %i",comms_source.preorder_nuke)						
					end
					if comms_source.preorder_repair_crew ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   One repair crew"						
					end
					if comms_source.preorder_coolant ~= nil then
						preorders_identified = true
						existing_expedite = existing_expedite .. "\n   Coolant"						
					end
					if preorders_identified then
						existing_expedite = existing_expedite .. "\nWould you like to preorder anything else?"
					else
						existing_expedite = existing_expedite .. " none.\nWould you like to preorder anything?"						
					end
					preorder_message = existing_expedite
					preOrderOrdnance(return_function)
				else
					existing_expedite = existing_expedite .. string.format(" on station %s (not this station, %s).",comms_source.expedite_dock_station:getCallSign(),comms_target:getCallSign())
					setCommsMessage(existing_expedite)
				end
				addCommsReply("Back",return_function)
			else
				setCommsMessage("If you would like to speed up the addition of resources such as energy, ordnance, etc., please provide a time frame for your arrival. A docking crew will stand by until that time, after which they will return to their normal duties")
				preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
				addCommsReply("One minute (5 rep)", function()
					if comms_source:takeReputationPoints(5) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 60
						preOrderOrdnance(return_function)
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", return_function)
				end)
				addCommsReply("Two minutes (10 Rep)", function()
					if comms_source:takeReputationPoints(10) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 120
						preOrderOrdnance(return_function)
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", return_function)
				end)
				addCommsReply("Three minutes (15 Rep)", function()
					if comms_source:takeReputationPoints(15) then
						comms_source.expedite_dock = true
						comms_source.expedite_dock_station = comms_target
						comms_source.expedite_dock_timer_max = 180
						preOrderOrdnance(return_function)
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", return_function)
				end)
			end
			addCommsReply("Back", return_function)
		end)
	end
end
function preOrderOrdnance(return_function)
	setCommsMessage(preorder_message)
	local hvli_count = math.floor(comms_source:getWeaponStorageMax("HVLI") * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("HVLI")
	if comms_target.comms_data.weapon_available.HVLI and isAllowedTo(comms_target.comms_data.weapons["HVLI"]) and hvli_count > 0 then
		local hvli_prompt = ""
		local hvli_cost = getWeaponCost("HVLI")
		if hvli_count > 1 then
			hvli_prompt = string.format("%i HVLIs * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		else
			hvli_prompt = string.format("%i HVLI * %i Rep = %i Rep",hvli_count,hvli_cost,hvli_count*hvli_cost)
		end
		addCommsReply(hvli_prompt,function()
			if comms_source:takeReputationPoints(hvli_count*hvli_cost) then
				comms_source.preorder_hvli = hvli_count
				if hvli_count > 1 then
					setCommsMessage(string.format("%i HVLIs preordered",hvli_count))
				else
					setCommsMessage(string.format("%i HVLI preordered",hvli_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",return_function)
		end)
	end
	local homing_count = math.floor(comms_source:getWeaponStorageMax("Homing") * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Homing")
	if comms_target.comms_data.weapon_available.Homing and isAllowedTo(comms_target.comms_data.weapons["Homing"]) and homing_count > 0 then
		local homing_prompt = ""
		local homing_cost = getWeaponCost("Homing")
		if homing_count > 1 then
			homing_prompt = string.format("%i Homings * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		else
			homing_prompt = string.format("%i Homing * %i Rep = %i Rep",homing_count,homing_cost,homing_count*homing_cost)
		end
		addCommsReply(homing_prompt,function()
			if comms_source:takeReputationPoints(homing_count*homing_cost) then
				comms_source.preorder_homing = homing_count
				if homing_count > 1 then
					setCommsMessage(string.format("%i Homings preordered",homing_count))
				else
					setCommsMessage(string.format("%i Homing preordered",homing_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",return_function)
		end)
	end
	local mine_count = math.floor(comms_source:getWeaponStorageMax("Mine") * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Mine")
	if comms_target.comms_data.weapon_available.Mine and isAllowedTo(comms_target.comms_data.weapons["Mine"]) and mine_count > 0 then
		local mine_prompt = ""
		local mine_cost = getWeaponCost("Mine")
		if mine_count > 1 then
			mine_prompt = string.format("%i Mines * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		else
			mine_prompt = string.format("%i Mine * %i Rep = %i Rep",mine_count,mine_cost,mine_count*mine_cost)
		end
		addCommsReply(mine_prompt,function()
			if comms_source:takeReputationPoints(mine_count*mine_cost) then
				comms_source.preorder_mine = mine_count
				if mine_count > 1 then
					setCommsMessage(string.format("%i Mines preordered",mine_count))
				else
					setCommsMessage(string.format("%i Mine preordered",mine_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",return_function)
		end)
	end
	local emp_count = math.floor(comms_source:getWeaponStorageMax("EMP") * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("EMP")
	if comms_target.comms_data.weapon_available.EMP and isAllowedTo(comms_target.comms_data.weapons["EMP"]) and emp_count > 0 then
		local emp_prompt = ""
		local emp_cost = getWeaponCost("EMP")
		if emp_count > 1 then
			emp_prompt = string.format("%i EMPs * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		else
			emp_prompt = string.format("%i EMP * %i Rep = %i Rep",emp_count,emp_cost,emp_count*emp_cost)
		end
		addCommsReply(emp_prompt,function()
			if comms_source:takeReputationPoints(emp_count*emp_cost) then
				comms_source.preorder_emp = emp_count
				if emp_count > 1 then
					setCommsMessage(string.format("%i EMPs preordered",emp_count))
				else
					setCommsMessage(string.format("%i EMP preordered",emp_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",return_function)
		end)
	end
	local nuke_count = math.floor(comms_source:getWeaponStorageMax("Nuke") * comms_target.comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage("Nuke")
	if comms_target.comms_data.weapon_available.Nuke and isAllowedTo(comms_target.comms_data.weapons["Nuke"]) and nuke_count > 0 then
		local nuke_prompt = ""
		local nuke_cost = getWeaponCost("Nuke")
		if nuke_count > 1 then
			nuke_prompt = string.format("%i Nukes * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		else
			nuke_prompt = string.format("%i Nuke * %i Rep = %i Rep",nuke_count,nuke_cost,nuke_count*nuke_cost)
		end
		addCommsReply(nuke_prompt,function()
			if comms_source:takeReputationPoints(nuke_count*nuke_cost) then
				comms_source.preorder_nuke = nuke_count
				if nuke_count > 1 then
					setCommsMessage(string.format("%i Nukes preordered",nuke_count))
				else
					setCommsMessage(string.format("%i Nuke preordered",nuke_count))
				end
			else
				setCommsMessage("Insufficient reputation")
			end
			preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
			addCommsReply("Back",return_function)
		end)
	end
	if comms_source.preorder_repair_crew == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
					hireCost = math.random(30,60)
				else
					hireCost = math.random(45,90)
				end
				addCommsReply(string.format("Recruit repair crew member for %i reputation",hireCost), function()
					if not comms_source:takeReputationPoints(hireCost) then
						setCommsMessage("Insufficient reputation")
					else
						comms_source.preorder_repair_crew = 1
						setCommsMessage("Repair crew hired on your behalf. They will board when you dock")
					end				
					preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
					addCommsReply("Back",return_function)
				end)
			end
		end
	end
	if comms_source.preorder_coolant == nil then
		if random(1,100) <= 20 then
			if comms_source:isFriendly(comms_target) then
				if comms_source.initialCoolant ~= nil then
					local coolant_cost = math.random(45,90)
					if comms_source:getMaxCoolant() < comms_source.initialCoolant then
						coolant_cost = math.random(30,60)
					end
					addCommsReply(string.format("Set aside coolant for %i reputation",coolant_cost), function()
						if comms_source:takeReputationPoints(coolant_cost) then
							comms_source.preorder_coolant = 2
							setCommsMessage("Coolant set aside for you. It will be loaded when you dock")
						else
							setCommsMessage("Insufficient reputation")
						end
						preorder_message = "Docking crew is standing by. Would you like to pre-order anything?"
						addCommsReply("Back",return_function)
					end)
				end
			end
		end
	end
end
function activateDefenseFleet(return_function)
    if isAllowedTo(comms_target.comms_data.services.activatedefensefleet) and 
    	comms_target.comms_data.idle_defense_fleet ~= nil then
    	local defense_fleet_count = 0
    	for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    		defense_fleet_count = defense_fleet_count + 1
    	end
    	if defense_fleet_count > 0 then
    		addCommsReply("Activate station defense fleet (" .. getServiceCost("activatedefensefleet") .. " rep)",function()
    			if comms_source:takeReputationPoints(getServiceCost("activatedefensefleet")) then
    				local out = string.format("%s defense fleet\n",comms_target:getCallSign())
    				for name, template in pairs(comms_target.comms_data.idle_defense_fleet) do
    					local script = Script()
						local position_x, position_y = comms_target:getPosition()
						local station_name = comms_target:getCallSign()
						script:setVariable("position_x", position_x):setVariable("position_y", position_y)
						script:setVariable("station_name",station_name)
    					script:setVariable("name",name)
    					script:setVariable("template",template)
    					script:setVariable("faction_id",comms_target:getFactionId())
    					script:run("border_defend_station.lua")
    					out = out .. " " .. name
    					comms_target.comms_data.idle_defense_fleet[name] = nil
    				end
    				out = out .. "\nactivated"
    				setCommsMessage(out)
    			else
    				setCommsMessage("Insufficient reputation")
    			end
				addCommsReply("Back", return_function)
    		end)
		end
    end
end
--	Docked actions
function restockOrdnance(return_function)
	local missilePresence = 0
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	for _, missile_type in ipairs(missile_types) do
		missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
	end
	if missilePresence > 0 then
		if 	(comms_target.comms_data.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke")	> 0)	and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Nuke	> 0) or 
			(comms_target.comms_data.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP")	> 0)	and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.EMP		> 0) or 
			(comms_target.comms_data.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing")	> 0)	and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Homing	> 0) or 
			(comms_target.comms_data.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine")	> 0)   	and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Mine	> 0) or 
			(comms_target.comms_data.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI")	> 0)	and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.HVLI	> 0) then
			addCommsReply("I need ordnance restocked", function()
				setCommsMessage("What type of ordnance?")
				if comms_source:getWeaponStorageMax("Nuke") > 0 and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Nuke > 0) then
					if comms_target.comms_data.weapon_available.Nuke then
						local ask = {"Can you supply us with some nukes?","We really need some nukes."}
						local avail = ""
						if not comms_target.comms_data.weapon_inventory.Unlimited then
							avail = string.format(", %i avail",math.floor(comms_target.comms_data.weapon_inventory.Nuke))
						end
						local nuke_prompt = string.format("%s (%i rep each%s)",ask[math.random(1,#ask)],getWeaponCost("Nuke"),avail)
						addCommsReply(nuke_prompt, function()
							handleWeaponRestock("Nuke",return_function)
						end)
					end	--end station has nuke available if branch
				end	--end player can accept nuke if branch
				if comms_source:getWeaponStorageMax("EMP") > 0 and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.EMP > 0) then
					if comms_target.comms_data.weapon_available.EMP then
						local ask = {"Please re-stock our EMP missiles.","Got any EMPs?"}
						local avail = ""
						if not comms_target.comms_data.weapon_inventory.Unlimited then
							avail = string.format(", %i avail",math.floor(comms_target.comms_data.weapon_inventory.EMP))
						end
						local emp_prompt = string.format("%s (%i rep each%s)",ask[math.random(1,#ask)],getWeaponCost("EMP"),avail)
						addCommsReply(emp_prompt, function()
							handleWeaponRestock("EMP",return_function)
						end)
					end	--end station has EMP available if branch
				end	--end player can accept EMP if branch
				if comms_source:getWeaponStorageMax("Homing") > 0 and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Homing > 0) then
					if comms_target.comms_data.weapon_available.Homing then
						local ask = {"Do you have spare homing missiles for us?","Do you have extra homing missiles?"}
						local avail = ""
						if not comms_target.comms_data.weapon_inventory.Unlimited then
							avail = string.format(", %i avail",math.floor(comms_target.comms_data.weapon_inventory.Homing))
						end
						local homing_prompt = string.format("%s (%i rep each%s)",ask[math.random(1,#ask)],getWeaponCost("Homing"),avail)
						addCommsReply(homing_prompt, function()
							handleWeaponRestock("Homing",return_function)
						end)
					end	--end station has homing for player if branch
				end	--end player can accept homing if branch
				if comms_source:getWeaponStorageMax("Mine") > 0 and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.Mine > 0) then
					if comms_target.comms_data.weapon_available.Mine then
						local ask = {"We could use some mines.","How about mines?"}
						local avail = ""
						if not comms_target.comms_data.weapon_inventory.Unlimited then
							avail = string.format(", %i avail",math.floor(comms_target.comms_data.weapon_inventory.Mine))
						end
						local mine_prompt = string.format("%s (%i rep each%s)",ask[math.random(1,#ask)],getWeaponCost("Mine"),avail)
						addCommsReply(mine_prompt, function()
							handleWeaponRestock("Mine",return_function)
						end)
					end	--end station has mine for player if branch
				end	--end player can accept mine if branch
				if comms_source:getWeaponStorageMax("HVLI") > 0 and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory.HVLI > 0) then
					if comms_target.comms_data.weapon_available.HVLI then
						local ask = {"What about HVLI?","Could you provide HVLI?"}
						local avail = ""
						if not comms_target.comms_data.weapon_inventory.Unlimited then
							avail = string.format(", %i avail",math.floor(comms_target.comms_data.weapon_inventory.HVLI))
						end
						local hvli_prompt = string.format("%s (%i rep each%s)",ask[math.random(1,#ask)],getWeaponCost("HVLI"),avail)
						addCommsReply(hvli_prompt, function()
							handleWeaponRestock("HVLI",return_function)
						end)
					end	--end station has HVLI for player if branch
				end	--end player can accept HVLI if branch
			end)	--end player requests secondary ordnance comms reply branch
		end	--end secondary ordnance available from station if branch
	end	--end missles used on player ship if branch
end
function repairSubsystems(return_function)
	local offer_repair = false
	if comms_target.comms_data.probe_launch_repair and not comms_source:getCanLaunchProbe() then
		offer_repair = true
	end
	if not offer_repair and comms_target.comms_data.hack_repair and not comms_source:getCanHack() then
		offer_repair = true
	end
	if not offer_repair and comms_target.comms_data.scan_repair and not comms_source:getCanScan() then
		offer_repair = true
	end
	if not offer_repair and comms_target.comms_data.combat_maneuver_repair and not comms_source:getCanCombatManeuver() then
		offer_repair = true
	end
	if not offer_repair and comms_target.comms_data.self_destruct_repair and not comms_source:getCanSelfDestruct() then
		offer_repair = true
	end
	if not offer_repair and comms_target.comms_data.tube_slow_down_repair then
		local tube_load_time_slowed = false
		if comms_source.normal_tube_load_time ~= nil then
			local tube_count = comms_source:getWeaponTubeCount()
			if tube_count > 0 then
				local tube_index = 0
				repeat
					if comms_source.normal_tube_load_time[tube_index] ~= comms_source:getTubeLoadTime(tube_index) then
						tube_load_time_slowed = true
						break
					end
					tube_index = tube_index + 1
				until(tube_index >= tube_count)
			end
		end
		if tube_load_time_slowed then
			offer_repair = true
		end
	end
	if offer_repair then
		addCommsReply("Repair ship system",function()
			setCommsMessage("What system would you like repaired?")
			if comms_target.comms_data.probe_launch_repair then
				if not comms_source:getCanLaunchProbe() then
					addCommsReply("Repair probe launch system (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage("Your probe launch system has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.hack_repair then
				if not comms_source:getCanHack() then
					addCommsReply("Repair hacking system (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanHack(true)
							setCommsMessage("Your hack system has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.scan_repair then
				if not comms_source:getCanScan() then
					addCommsReply("Repair scanners (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanScan(true)
							setCommsMessage("Your scanners have been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.combat_maneuver_repair then
				if not comms_source:getCanCombatManeuver() then
					addCommsReply("Repair combat maneuver (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage("Your combat maneuver has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.self_destruct_repair then
				if not comms_source:getCanSelfDestruct() then
					addCommsReply("Repair self destruct system (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage("Your self destruct system has been repaired")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.tube_slow_down_repair then
				local tube_load_time_slowed = false
				if comms_source.normal_tube_load_time ~= nil then
					local tube_count = comms_source:getWeaponTubeCount()
					if tube_count > 0 then
						local tube_index = 0
						repeat
							if comms_source.normal_tube_load_time[tube_index] ~= comms_source:getTubeLoadTime(tube_index) then
								tube_load_time_slowed = true
								break
							end
							tube_index = tube_index + 1
						until(tube_index >= tube_count)
					end
				end
				if tube_load_time_slowed then
					addCommsReply("Repair slow tube loading (5 Rep)",function()
						if comms_source:takeReputationPoints(5) then
							local tube_count = comms_source:getWeaponTubeCount()
							local tube_index = 0
							repeat
								comms_source:setTubeLoadTime(tube_index,comms_source.normal_tube_load_time[tube_index])
								tube_index = tube_index + 1
							until(tube_index >= tube_count)
							setCommsMessage("Your tube load times have been returned to normal")
						else
							setCommsMessage("Insufficient reputation")
						end
						addCommsReply("Back", return_function)
					end)
				end
			end
			addCommsReply("Back", return_function)
		end)
	end
end
function handleWeaponRestock(weapon, return_function)
    if not comms_source:isDocked(comms_target) then 
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
    local item_amount = math.floor(comms_source:getWeaponStorageMax(weapon) * comms_data.max_weapon_refill_amount[getFriendStatus()]) - comms_source:getWeaponStorage(weapon)
    if item_amount <= 0 then
        if weapon == "Nuke" then
            setCommsMessage("All nukes are charged and primed for destruction.");
        else
            setCommsMessage("Sorry, sir, but you are as fully stocked as I can allow.");
        end
        addCommsReply("Back", return_function)
    else
		local inventory_status = ""
		if comms_source:getReputationPoints() > points_per_item * item_amount and (comms_target.comms_data.weapon_inventory.Unlimited or comms_target.comms_data.weapon_inventory[weapon] >= item_amount) then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if not comms_target.comms_data.weapon_inventory.Unlimited then
					comms_target.comms_data.weapon_inventory[weapon] = comms_target.comms_data.weapon_inventory[weapon] - item_amount
					inventory_status = string.format("\nStation inventory of %s type weapons reduced to %i",weapon,math.floor(comms_target.comms_data.weapon_inventory[weapon]))
				end
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
					setCommsMessage("You are fully loaded and ready to explode things." .. inventory_status)
				else
					setCommsMessage("We generously resupplied you with some weapon charges.\nPut them to good use." .. inventory_status)
				end
			else
				setCommsMessage("Not enough reputation.")
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage("Either you can't afford as much as I'd like to give you, or I don't have enough to fully restock you.")
				addCommsReply("Get just one", function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if not comms_target.comms_data.weapon_inventory.Unlimited then
							comms_target.comms_data.weapon_inventory[weapon] = comms_target.comms_data.weapon_inventory[weapon] - 1
							inventory_status = string.format("\nStation inventory of %s type weapons reduced to %i",weapon,math.floor(comms_target.comms_data.weapon_inventory[weapon]))
						end
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
							setCommsMessage("You are fully loaded and ready to explode things." .. inventory_status)
						else
							setCommsMessage("We generously resupplied you with one weapon charge.\nPut it to good use." .. inventory_status)
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
        addCommsReply("Back", return_function)
    end
end
function buySellTrade(return_function)
	local goodCount = 0
	if comms_target.comms_data.goods == nil then
		return
	end
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply("Buy, sell, trade", function()
			local goodsReport = string.format("Station %s:\nGoods or components available for sale: quantity, cost in reputation\n",comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsReport = goodsReport .. string.format("     %s: %i, %i\n",good,goodData["quantity"],goodData["cost"])
			end
			if comms_target.comms_data.buy ~= nil then
				goodsReport = goodsReport .. "Goods or components station will buy: price in reputation\n"
				for good, price in pairs(comms_target.comms_data.buy) do
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,price)
				end
			end
			goodsReport = goodsReport .. string.format("Current cargo aboard %s:\n",comms_source:getCallSign())
			local cargoHoldEmpty = true
			local goodCount = 0
			if comms_source.goods ~= nil then
				for good, goodQuantity in pairs(comms_source.goods) do
					goodCount = goodCount + 1
					goodsReport = goodsReport .. string.format("     %s: %i\n",good,goodQuantity)
				end
			end
			if goodCount < 1 then
				goodsReport = goodsReport .. "     Empty\n"
			end
			goodsReport = goodsReport .. string.format("Available Space: %i, Available Reputation: %i\n",comms_source.cargo,math.floor(comms_source:getReputationPoints()))
			setCommsMessage(goodsReport)
			for good, goodData in pairs(comms_target.comms_data.goods) do
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
					addCommsReply("Back", return_function)
				end)
			end
			if comms_target.comms_data.buy ~= nil then
				for good, price in pairs(comms_target.comms_data.buy) do
					if comms_source.goods ~= nil then
						if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
							addCommsReply(string.format("Sell one %s for %i reputation",good,price), function()
								local goodTransactionMessage = string.format("Type: %s,  Reputation price: %i",good,price)
								comms_source.goods[good] = comms_source.goods[good] - 1
								comms_source:addReputationPoints(price)
								goodTransactionMessage = goodTransactionMessage .. "\nOne sold"
								comms_source.cargo = comms_source.cargo + 1
								setCommsMessage(goodTransactionMessage)
								addCommsReply("Back", return_function)
							end)
						end
					end
				end
			end
			if comms_target.comms_data.trade.food and comms_source.goods["food"] > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.trade.medicine and comms_source.goods["medicine"] > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
						addCommsReply("Back", return_function)
					end)
				end
			end
			if comms_target.comms_data.trade.luxury and comms_source.goods["luxury"] > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
						addCommsReply("Back", return_function)
					end)
				end
			end
			addCommsReply("Back", return_function)
		end)
	end
end
function boostSensorsWhileDocked(return_function)
	if comms_target.comms_data.sensor_boost ~= nil then
		if comms_target.comms_data.sensor_boost.cost > 0 then
			addCommsReply(string.format("Augment scan range with station sensors while docked (%i rep)",comms_target.comms_data.sensor_boost.cost),function()
				if comms_source:takeReputationPoints(comms_target.comms_data.sensor_boost.cost) then
					if comms_source.normal_long_range_radar == nil then
						comms_source.normal_long_range_radar = comms_source:getLongRangeRadarRange()
					end
					comms_source:setLongRangeRadarRange(comms_source.normal_long_range_radar + comms_target.comms_data.sensor_boost.value)
					setCommsMessage(string.format("sensors increased by %i units",comms_target.comms_data.sensor_boost.value/1000))
				else
					setCommsMessage("Insufficient reputation")
				end
				addCommsReply("Back", return_function)
			end)
		end
	end
end
function overchargeJump(return_function)
	if comms_target.comms_data.jump_overcharge and isAllowedTo(comms_target.comms_data.services.jumpovercharge) then
		if comms_source:hasJumpDrive() then
			local max_charge = comms_source.max_jump_range
			if max_charge == nil then
				max_charge = 50000
			end
			if comms_source:getJumpDriveCharge() >= max_charge then
				addCommsReply("Overcharge Jump Drive (" .. getServiceCost("jumpovercharge") .. " rep)",function()
					if comms_source:takeReputationPoints(getServiceCost("jumpovercharge")) then
						comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
						setCommsMessage(string.format("Your jump drive has been overcharged to %ik",math.floor(comms_source:getJumpDriveCharge()/1000)))
					else
						setCommsMessage("Insufficient reputation")
					end
					addCommsReply("Back", return_function)
				end)
			end
		end
	end
end
--	Upgrades
function hullStrengthUpgrade(p)
	if p.hull_strength_upgrade == nil then
		p.hull_strength_upgrade = "done"
		p:setHullMax(p:getHullMax()*1.2)
		p:setHull(p:getHullMax())
		p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*.9)
		return true, "Your hull strength has been increased by 20%"
	else
		return false, "You already have the hull strength upgrade"
	end
end
function missileLoadSpeedUpgrade(p)
	if p.missile_load_speed_upgrade == nil then
		local tube_count = p:getWeaponTubeCount()
		if tube_count > 0 then
			local tube_index = 0
			if p.normal_tube_load_time == nil then
				p.normal_tube_load_time = {}
				repeat
					p.normal_tube_load_time[tube_index] = p:getTubeLoadTime(tube_index)
					tube_index = tube_index + 1
				until(tube_index >= tube_count)
				tube_index = 0
			end
			repeat
				p:setTubeLoadTime(tube_index,p.normal_tube_load_time[tube_index]*.8)
				p.normal_tube_load_time[tube_index] = p.normal_tube_load_time[tube_index]*.8
				tube_index = tube_index + 1				
			until(tube_index >= tube_count)
			return true, "Your missile tube load time has been reduced by 20%"
		else
			return false, "Your ship has no missile systems and thus cannot be upgraded"
		end
	else
		return false, "You already have the missile load speed upgrade"
	end
end
function shieldStrengthUpgrade(p)
	if p.shield_strength_upgrade == nil then
		if p:getShieldCount() > 0 then
			p.shield_strength_upgrade = "done"
			if p:getShieldCount() == 1 then
				p:setShieldsMax(p:getShieldMax(0)*1.2)
			else
				p:setShieldsMax(p:getShieldMax(0)*1.2,p:getShieldMax(1)*1.2)
			end
			return true, "Your ship shields are now 20% stronger. They'll need to charge to their new higher capacity"
		else
			return false, "Your ship has no shields and thus cannot be upgraded"
		end
	else
		return false, "You already have the shield upgrade"
	end
end
function beamDamageUpgrade(p)
	if p.beam_damage_upgrade == nil then
		if p:getBeamWeaponRange(0) > 0 then
			p.beam_damage_upgrade = "done"
			local bi = 0
			repeat
				local tempArc = p:getBeamWeaponArc(bi)
				local tempDir = p:getBeamWeaponDirection(bi)
				local tempRng = p:getBeamWeaponRange(bi)
				local tempCyc = p:getBeamWeaponCycleTime(bi)
				local tempDmg = p:getBeamWeaponDamage(bi)
				p:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc,tempDmg*1.2)
				p:setBeamWeaponHeatPerFire(bi,p:getBeamWeaponHeatPerFire(bi)*1.2)
				p:setBeamWeaponEnergyPerFire(bi,p:getBeamWeaponEnergyPerFire(bi)*1.2)
				bi = bi + 1
			until(p:getBeamWeaponRange(bi) < 1)
			return true, "Your ship beam weapons damage has been increased by 20%"
		else
			return false, "Your ship has no beam weapons and thus cannot be upgraded"
		end
	else
		return false, "You already have the beam damage upgrade"
	end
end
function beamRangeUpgrade(p)
	if p.beam_range_upgrade == nil then
		if p:getBeamWeaponRange(0) > 0 then
			p.beam_range_upgrade = "done"
			local bi = 0
			repeat
				local tempArc = p:getBeamWeaponArc(bi)
				local tempDir = p:getBeamWeaponDirection(bi)
				local tempRng = p:getBeamWeaponRange(bi)
				local tempCyc = p:getBeamWeaponCycleTime(bi)
				local tempDmg = p:getBeamWeaponDamage(bi)
				p:setBeamWeapon(bi,tempArc,tempDir,tempRng*1.2,tempCyc,tempDmg)
				p:setBeamWeaponHeatPerFire(bi,p:getBeamWeaponHeatPerFire(bi)*1.2)
				p:setBeamWeaponEnergyPerFire(bi,p:getBeamWeaponEnergyPerFire(bi)*1.2)
				bi = bi + 1
			until(p:getBeamWeaponRange(bi) < 1)
			return true, "Your ship beam weapons range has been increased by 20%"
		else
			return false, "Your ship has no beam weapons and thus cannot be upgraded"
		end
	else
		return false, "You already have the beam range upgrade"
	end
end
function batteryEfficiencyUpgrade(p)
	if p.battery_efficiency_upgrade == nil then
		p.battery_efficiency_upgrade = "done"
		p:setMaxEnergy(p:getMaxEnergy()*1.2)
		p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*.95)
		return true, "Your ship batteries can now store 20% more energy. You'll need to charge them longer to use their full capacity"
	else
		return false, "You already have the battery efficiency upgrade"
	end
end
function fasterImpulseUpgrade(p)
	if p.faster_impulse_upgrade == nil then
		p.faster_impulse_upgrade = "done"
		p:setImpulseMaxSpeed(p:getImpulseMaxSpeed()*1.2)
		p:setRotationMaxSpeed(p:getRotationMaxSpeed()*.95)
		return true, "Your maximum impulse top speed has been increased by 20%"
	else
		return false, "You already have an upgraded impulse engine"
	end
end
function longerSensorsUpgrade(p)
	if p.longer_sensors_upgrade == nil then
		p.longer_sensors_upgrade = "done"
		if p.normal_long_range_radar == nil then
			p.normal_long_range_radar = p:getLongRangeRadarRange()
		end
		p:setLongRangeRadarRange(p:getLongRangeRadarRange() + 10000)
		p.normal_long_range_radar = p.normal_long_range_radar + 10000
		return true, "Your ship's long range sensors have had their reach increased by 10 units"
	else
		return false, "You already have upgraded long range sensors"
	end
end
function fasterSpinUpgrade(p)
	if p.faster_spin_upgrade == nil then
		p.faster_spin_upgrade = "done"
		p:setRotationMaxSpeed(p:getRotationMaxSpeed()*1.2)
		return true, "Your maneuvering speed has been increased by 20%"
	else
		return false, "You already have upgraded maneuvering speed"
	end
end
---------------------------
--	Ship Communications  --
---------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		comms_data.goods = {}
		comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
		local shipType = comms_target:getTypeName()
		if shipType:find("Freighter") ~= nil then
			if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
				repeat
					comms_data.goods[commonGoods[math.random(1,#commonGoods)]] = {quantity = 1, cost = random(20,80)}
					local goodCount = 0
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
	shipDefendWaypoint(commsShip)
	shipFlyBlind(commsShip)
	shipAssistPlayer(comms_data,commsShip)
	shipStatusReport(commsShip)
	shipDockNearby(commsShip)
	shipRoaming(commsShip)
	shipStandGround(commsShip)
	shipIdle(commsShip)
	fleetCommunication(commsShip)
	friendlyFreighterCommunication(comms_data,commsShip)
	return true
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = "We will see to your destruction!"
		local taunt_success_reply = "Your bloodline will end here!"
		local taunt_failed_reply = "Your feeble threats are meaningless."
		local taunt_threshold = 30	--base chance of being taunted
		if faction == "Kraylor" then
			taunt_threshold = 35
			setCommsMessage("Ktzzzsss.\nYou will DIEEee weaklingsss!");
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = "We will destroy you"
				taunt_success_reply = "We think not. It is you who will experience destruction!"
			elseif kraylorTauntChoice == 2 then
				taunt_option = "You have no honor"
				taunt_success_reply = "Your insult has brought our wrath upon you. Prepare to die."
				taunt_failed_reply = "Your comments about honor have no meaning to us"
			else
				taunt_option = "We pity your pathetic race"
				taunt_success_reply = "Pathetic? You will regret your disparagement!"
				taunt_failed_reply = "We don't care what you think of us"
			end
		elseif faction == "Arlenians" then
			taunt_threshold = 25
			setCommsMessage("We wish you no harm, but will harm you if we must.\nEnd of transmission.");
		elseif faction == "Exuari" then
			taunt_threshold = 40
			setCommsMessage("Stay out of our way, or your death will amuse us extremely!");
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			setCommsMessage("One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted.");
			taunt_option = "EXECUTE: SELFDESTRUCT"
			taunt_success_reply = "Rogue command received. Targeting source."
			taunt_failed_reply = "External command ignored."
		elseif faction == "Ktlitans" then
			setCommsMessage("The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition.");
			taunt_option = "<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>"
			taunt_success_reply = "We do not need permission to pluck apart such an insignificant threat."
			taunt_failed_reply = "The hive has greater priorities than exterminating pests."
		elseif faction == "TSN" then
			taunt_threshold = 15
			setCommsMessage("State your business")
		elseif faction == "USN" then
			taunt_threshold = 15
			setCommsMessage("What do you want? (not that we care)")
		elseif faction == "CUF" then
			taunt_threshold = 15
			setCommsMessage("Don't waste our time")
		else
			setCommsMessage("Mind your own business!");
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then	--final: 30
				local current_order = comms_target:getOrder()
				print("order: " .. current_order)
				--Possible order strings returned:
				--Roaming
				--Fly towards
				--Attack
				--Stand Ground
				--Idle
				--Defend Location
				--Defend Target
				--Fly Formation (?)
				--Fly towards (ignore all)
				--Dock
				if comms_target.original_order == nil then
					comms_target.original_faction = faction
					comms_target.original_order = current_order
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					comms_target.taunt_may_expire = true	--change to conditional in future refactoring
					table.insert(enemy_reverts,comms_target)
				end
				comms_target:orderAttack(comms_source)	--consider alternative options besides attack in future refactoring
				setCommsMessage(taunt_success_reply);
			else
				setCommsMessage(taunt_failed_reply);
			end
		end)
		tauntable = true
	end
	local enemy_health = getEnemyHealth(comms_target)
	if change_enemy_order_diagnostic then print(string.format("   enemy health:    %.2f",enemy_health)) end
	if change_enemy_order_diagnostic then print(string.format("   friendliness:    %.1f",comms_data.friendlyness)) end
	if comms_data.friendlyness >= 66 or enemy_health < .5 then	--final: 66, .5
		--amenable logic
		local amenable_chance = comms_data.friendlyness/3 + (1 - enemy_health)*30
		if change_enemy_order_diagnostic then print(string.format("   amenability:     %.1f",amenable_chance)) end
		addCommsReply("Stop your actions",function()
			local amenable_roll = random(0,100)
			if change_enemy_order_diagnostic then print(string.format("   amenable roll:   %.1f",amenable_roll)) end
			if amenable_roll < amenable_chance then
				local current_order = comms_target:getOrder()
				if comms_target.original_order == nil then
					comms_target.original_order = current_order
					comms_target.original_faction = faction
					if current_order == "Fly towards" or current_order == "Defend Location" or current_order == "Fly towards (ignore all)" then
						comms_target.original_target_x, comms_target.original_target_y = comms_target:getOrderTargetLocation()
						--print(string.format("Target_x: %f, Target_y: %f",comms_target.original_target_x,comms_target.original_target_y))
					end
					if current_order == "Attack" or current_order == "Dock" or current_order == "Defend Target" then
						local original_target = comms_target:getOrderTarget()
						--print("target:")
						--print(original_target)
						--print(original_target:getCallSign())
						comms_target.original_target = original_target
					end
					table.insert(enemy_reverts,comms_target)
				end
				comms_target.amenability_may_expire = true
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage("Just this once, we'll take your advice")
			else
				setCommsMessage("No")
			end
		end)
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		amenable = true
	end
	if tauntable or amenable then
		return true
	else
		return false
	end
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil or shipType:find("Transport") ~= nil or shipType:find("Cargo") ~= nil then
		setCommsMessage("Yes?")
		shipCargoSellReport(commsShip)
		if distance(comms_source,comms_target) < 5000 then
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						shipBuyGoods(commsShip,1)
					else
						shipBuyGoods(commsShip,2)
					end
				elseif comms_data.friendlyness > 33 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						shipBuyGoods(commsShip,2)
					else
						shipBuyGoods(commsShip,3)
					end
				else	--least friendly
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						shipBuyGoods(commsShip,3)
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
		else
			setCommsMessage("We have nothing for you.\nGood day.");
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
function shipStatusReport(return_function)
	addCommsReply("Report status", function()
		msg = "Hull: " .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
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
		if comms_target:hasJumpDrive() then
			msg = msg .. "Jump drive charge: " .. comms_target:getJumpDriveCharge()
		end
		setCommsMessage(msg);
		addCommsReply("Back", return_function)
	end)
end
function shipIdle(return_function)
	addCommsReply("Stop. Do nothing.", function()
		comms_target:orderIdle()
		local idle_comment = {
			"routine system maintenance",
			"for idle ship gossip",
			"exterior paint touch-up",
			"exercise for continued fitness",
			"meditation therapy",
			"internal simulated flight routines",
			"digital dreamscape construction",
			"catching up on reading the latest war drama novel",
			"writing up results of bifurcated personality research",
			"categorizing nearby miniscule space particles",
			"continuing the count of visible stars from this region",
			"internal systems diagnostics",
		}
		setCommsMessage(string.format("Stopping. Doing nothing except %s",idle_comment[math.random(1,#idle_comment)]))
		addCommsReply("Back", return_function)
	end)
end
function shipRoaming(return_function)
	addCommsReply("Attack all enemies. Start with the nearest.", function()
		comms_target:orderRoaming()
		setCommsMessage("Searching and destroying")
		addCommsReply("Back", return_function)
	end)
end
function shipStandGround(return_function)
	addCommsReply("Stop and defned your current location", function()
		comms_target:orderStandGround()
		setCommsMessage("Stopping. Shooting any enemy that approaches")
		addCommsReply("Back", return_function)
	end)
end
function shipDefendWaypoint(return_function)
	addCommsReply("Defend a waypoint", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", return_function)
		else
			setCommsMessage("Which waypoint should we defend?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage("We are heading to assist at WP" .. n ..".");
					addCommsReply("Back", return_function)
				end)
			end
		end
	end)
end
function shipFlyBlind(return_function)
	addCommsReply("Go to waypoint, ignore enemies", function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage("No waypoints set. Please set a waypoint first.");
			addCommsReply("Back", return_function)
		else
			setCommsMessage("Which waypoint should we approach?");
			for n=1,comms_source:getWaypointCount() do
				addCommsReply("Defend WP" .. n, function()
					comms_target:orderFlyTowardsBlind(comms_source:getWaypoint(n))
					setCommsMessage("We are heading to WP" .. n ..", ignoring enemies.");
					addCommsReply("Back", return_function)
				end)
			end
		end
	end)
end
function shipAssistPlayer(comms_data,return_function)
	if comms_data.friendlyness > 0.2 then
		addCommsReply("Assist me", function()
			setCommsMessage("Heading toward you to assist.");
			comms_target:orderDefendTarget(comms_source)
			addCommsReply("Back", return_function)
		end)
	end
end
function shipDockNearby(return_function)
	for _, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		local player_carrier = false
		local template_name = ""
		if obj.typeName == "PlayerSpaceship" then
			template_name = obj:getTypeName()
			if template_name == "Benedict" or template_name == "Kiriya" then
				player_carrier = true
			end
		end
		local defense_platform = false
		if obj.typeName == "CpuShip" then
			template_name = obj:getTypeName()
			if template_name == "Defense platform" then
				defense_platform = true
			end
		end
		if (obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj)) or player_carrier or defense_platform then
			addCommsReply("Dock at " .. obj:getCallSign(), function()
				setCommsMessage("Docking at " .. obj:getCallSign() .. ".");
				comms_target:orderDock(obj)
				addCommsReply("Back", return_function)
			end)
		end
	end
end
function fleetCommunication(return_function)
	if comms_target.fleetIndex ~= nil then
		addCommsReply(string.format("Direct fleet %i",comms_target.fleetIndex), function()
			local fleet_state = string.format("Fleet %i consists of:\n",comms_target.fleetIndex)
			for _, ship in ipairs(npc_fleet[comms_target:getFaction()]) do
				if ship.fleetIndex == comms_target.fleetIndex then
					fleet_state = fleet_state .. ship:getCallSign() .. " "
				end
			end
			setCommsMessage(string.format("%s\n\nWhat command should be given to fleet %i?",fleet_state,comms_target.fleetIndex))
			addCommsReply("Report hull and shield status", function()
				msg = string.format("Fleet %i status:",comms_target.fleetIndex)
				for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
					if fleetShip.fleetIndex == comms_target.fleetIndex then
						if fleetShip ~= nil and fleetShip:isValid() then
							msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
							msg = msg .. "\n    Hull: " .. math.floor(fleetShip:getHull() / fleetShip:getHullMax() * 100) .. "%"
							local shields = fleetShip:getShieldCount()
							if shields == 1 then
								msg = msg .. "\n    Shield: " .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "%"
							else
								msg = msg .. "\n    Shields: "
								if shields == 2 then
									msg = msg .. "Front:" .. math.floor(fleetShip:getShieldLevel(0) / fleetShip:getShieldMax(0) * 100) .. "% Rear:" .. math.floor(fleetShip:getShieldLevel(1) / fleetShip:getShieldMax(1) * 100) .. "%"
								else
									for n=0,shields-1 do
										msg = msg .. " " .. n .. ":" .. math.floor(fleetShip:getShieldLevel(n) / fleetShip:getShieldMax(n) * 100) .. "%"
									end
								end
							end
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", return_function)
			end)
			addCommsReply("Report missile status", function()
				msg = string.format("Fleet %i missile status:",comms_target.fleetIndex)
				for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
					if fleetShip.fleetIndex == comms_target.fleetIndex then
						if fleetShip ~= nil and fleetShip:isValid() then
							msg = msg .. "\n  " .. fleetShip:getCallSign() .. ":"
							local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
							missileMsg = ""
							for _, missile_type in ipairs(missile_types) do
								if fleetShip:getWeaponStorageMax(missile_type) > 0 then
									missileMsg = missileMsg .. "\n      " .. missile_type .. ": " .. math.floor(fleetShip:getWeaponStorage(missile_type)) .. "/" .. math.floor(fleetShip:getWeaponStorageMax(missile_type))
								end
							end
							if missileMsg ~= "" then
								msg = msg .. "\n    Missiles: " .. missileMsg
							end
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply("Back", return_function)
			end)
			addCommsReply("Assist me", function()
				for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
					if fleetShip.fleetIndex == comms_target.fleetIndex then
						if fleetShip ~= nil and fleetShip:isValid() then
							fleetShip:orderDefendTarget(comms_source)
						end
					end
				end
				setCommsMessage(string.format("Fleet %s heading toward you to assist",comms_target.fleetIndex))
				addCommsReply("Back", return_function)
			end)
			addCommsReply("Defend a waypoint", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", return_function)
				else
					setCommsMessage("Which waypoint should we defend?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Defend WP" .. n, function()
							for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
								if fleetShip.fleetIndex == comms_target.fleetIndex then
									if fleetShip ~= nil and fleetShip:isValid() then
										fleetShip:orderDefendLocation(comms_source:getWaypoint(n))
									end
								end
							end
							setCommsMessage("We are heading to assist at WP" .. n ..".");
							addCommsReply("Back", return_function)
						end)
					end
				end
			end)
			addCommsReply("Go to waypoint. Attack enemies en route", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", return_function)
				else
					setCommsMessage("Which waypoint?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Go to WP" .. n, function()
							for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
								if fleetShip.fleetIndex == comms_target.fleetIndex then
									if fleetShip ~= nil and fleetShip:isValid() then
										fleetShip:orderFlyTowards(comms_source:getWaypoint(n))
									end
								end
							end
							setCommsMessage("Going to WP" .. n ..", watching for enemies en route");
							addCommsReply("Back", return_function)
						end)
					end
				end
			end)
			addCommsReply("Go to waypoint. Ignore enemies", function()
				if comms_source:getWaypointCount() == 0 then
					setCommsMessage("No waypoints set. Please set a waypoint first.");
					addCommsReply("Back", return_function)
				else
					setCommsMessage("Which waypoint?");
					for n=1,comms_source:getWaypointCount() do
						addCommsReply("Go to WP" .. n, function()
							for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
								if fleetShip.fleetIndex == comms_target.fleetIndex then
									if fleetShip ~= nil and fleetShip:isValid() then
										fleetShip:orderFlyTowardsBlind(comms_source:getWaypoint(n))
									end
								end
							end
							setCommsMessage("Going to WP" .. n ..", ignoring enemies");
							addCommsReply("Back", return_function)
						end)
					end
				end
			end)
			addCommsReply("Go offensive, attack all enemy targets", function()
				for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
					if fleetShip.fleetIndex == comms_target.fleetIndex then
						if fleetShip ~= nil and fleetShip:isValid() then
							fleetShip:orderRoaming()
						end
					end
				end
				setCommsMessage(string.format("Fleet %s is on an offensive rampage",comms_target.fleetIndex))
				addCommsReply("Back", return_function)
			end)
			addCommsReply("Stop and defend your current position", function()
				for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
					if fleetShip.fleetIndex == comms_target.fleetIndex then
						fleetShip:orderStandGround()
					end
				end
				setCommsMessage("Stopping and defending")
				addCommsReply("Back", return_function)
			end)
			addCommsReply("Stop and do nothing", function()
				for _, fleetShip in ipairs(npc_fleet[comms_target:getFaction()]) do
					if fleetShip.fleetIndex == comms_target.fleetIndex then
						fleetShip:orderIdle()
					end
				end
				setCommsMessage("Stopping and doing nothing")
				addCommsReply("Back", return_function)
			end)
		end)
	end
end
function friendlyFreighterCommunication(comms_data,return_function)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
			if comms_data.friendlyness > 66 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					shipTradeGoods(comms_data,return_function)
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					shipBuyGoods(comms_data,return_function,1)
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						shipBuyGoods(comms_data,return_function,1)
					else	--not goods or equipment freighter
						shipBuyGoods(comms_data,return_function,2)
					end
				end	--player has room for cargo branch
			else	--least friendly
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						shipBuyGoods(comms_data,return_function,2)
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			shipCargoSellReport(comms_data,return_function)
		end
	end
end
function shipCargoSellReport(comms_data,return_function)
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
		addCommsReply("Back", return_function)
	end)
end
function shipTradeGoods(comms_data,return_function)
	if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
		for good, goodData in pairs(comms_data.goods) do
			if goodData.quantity > 0 and good ~= "luxury" then
				addCommsReply(string.format("Trade luxury for %s",good), function()
					goodData.quantity = goodData.quantity - 1
					if comms_source.goods == nil then
						comms_source.goods = {}
					end
					if comms_source.goods[good] == nil then
						comms_source.goods[good] = 0
					end
					comms_source.goods[good] = comms_source.goods[good] + 1
					comms_source.goods.luxury = comms_source.goods.luxury - 1
					setCommsMessage(string.format("Traded your luxury for %s from %s",good,comms_target:getCallSign()))
					addCommsReply("Back", return_function)
				end)
			end
		end	--freighter goods loop
	end	--player has luxury branch
end
function shipBuyGoods(comms_data,return_function,price_multiplier)
	for good, goodData in pairs(comms_data.goods) do
		if goodData.quantity > 0 then
			addCommsReply(string.format("Buy one %s for %i reputation",good,math.floor(goodData.cost*price_multiplier)), function()
				if comms_source:takeReputationPoints(goodData.cost*price_multiplier) then
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
				addCommsReply("Back", return_function)
			end)
		end
	end	--freighter goods loop
end
-------------------------------
-- Defend ship communication --
-------------------------------
function commsDefendShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_source:isFriendly(comms_target) then
		return friendlyDefendComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyDefendComms(comms_data)
	end
	return neutralDefendComms(comms_data)
end
function friendlyDefendComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage("What do you want?");
	else
		setCommsMessage("Sir, how can we assist?");
	end
	shipStatusReport(commsDefendShip)
	return true
end
function enemyDefendComms(comms_data)
    if comms_data.friendlyness > 50 then
        local faction = comms_target:getFaction()
        local taunt_option = "We will see to your destruction!"
        local taunt_success_reply = "Your bloodline will end here!"
        local taunt_failed_reply = "Your feeble threats are meaningless."
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
function neutralDefendComms(comms_data)
    if comms_data.friendlyness > 50 then
        setCommsMessage("Sorry, we have no time to chat with you.\nWe are on an important mission.");
    else
        setCommsMessage("We have nothing for you.\nGood day.");
    end
    return true
end

function playerShipCargoInventory(p)
	p:addToShipLog(string.format("%s Current cargo:",p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog("     Empty","Yellow")
	end
	p:addToShipLog(string.format("Available space: %i",p.cargo),"Yellow")
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
function gatherStats()
	local stat_list = {}
	stat_list.scenario = {name = "Chaos of War", version = scenario_version}
	stat_list.times = {}
	stat_list.times.game = {}
	stat_list.times.stage = game_state
	stat_list.times.game.max = max_game_time
	stat_list.times.game.total_seconds_left = game_time_limit
	stat_list.times.game.minutes_left = math.floor(game_time_limit / 60)
	stat_list.times.game.seconds_left = math.floor(game_time_limit % 60)
	stat_list.human = {}
	stat_list.human.ship = {}
	stat_list.human.ship_score_total = 0
	stat_list.human.npc = {}
	stat_list.human.npc_score_total = 0
	stat_list.human.station_score_total = 0
	stat_list.human.station = {}
	stat_list.kraylor = {}
	stat_list.kraylor.ship = {}
	stat_list.kraylor.ship_score_total = 0	
	stat_list.kraylor.npc = {}
	stat_list.kraylor.npc_score_total = 0
	stat_list.kraylor.station_score_total = 0
	stat_list.kraylor.station = {}
	if exuari_angle ~= nil then
		stat_list.exuari = {}
		stat_list.exuari.ship = {}
		stat_list.exuari.ship_score_total = 0
		stat_list.exuari.npc = {}
		stat_list.exuari.npc_score_total = 0
		stat_list.exuari.station_score_total = 0
		stat_list.exuari.station = {}
	end
	if ktlitan_angle ~= nil then
		stat_list.ktlitan = {}
		stat_list.ktlitan.ship = {}
		stat_list.ktlitan.ship_score_total = 0	
		stat_list.ktlitan.npc = {}
		stat_list.ktlitan.npc_score_total = 0
		stat_list.ktlitan.station_score_total = 0
		stat_list.ktlitan.station = {}
	end
	for pidx=1,32 do
		p = getPlayerShip(pidx)
		if p ~= nil then
			if p:isValid() then
				local faction = p:getFaction()
				if p.shipScore ~= nil then
					stat_list[f2s[faction]].ship_score_total = stat_list[f2s[faction]].ship_score_total + p.shipScore
					stat_list[f2s[faction]].ship[p:getCallSign()] = {template_type = p:getTypeName(), is_alive = true, score_value = p.shipScore}
				else
					print("ship score for " .. p:getCallSign() .. " has not been set")
				end
			end
		end
	end
	if npc_fleet ~= nil then
		for faction, list in pairs(npc_fleet) do
			for _, ship in ipairs(list) do
				if ship:isValid() then
					stat_list[f2s[faction]].npc_score_total = stat_list[f2s[faction]].npc_score_total + ship.score_value
					stat_list[f2s[faction]].npc[ship:getCallSign()] = {template_type = ship:getTypeName(), is_alive = true, score_value = ship.score_value}
				end
			end
		end
	end
	if scientist_list ~= nil then
		for faction, list in pairs(scientist_list) do
			for _, scientist in ipairs(list) do
				if scientist.location:isValid() then
					stat_list[f2s[faction]].npc_score_total = stat_list[f2s[faction]].npc_score_total + scientist.score_value
					stat_list[f2s[faction]].npc[scientist.name] = {topic = scientist.topic, is_alive = true, score_value = scientist.score_value, location_name = scientist.location_name}	
				end
			end
		end
	end
	for faction, list in pairs(station_list) do
		for _, station in ipairs(list) do
			if station:isValid() then
				stat_list[f2s[faction]].station_score_total = stat_list[f2s[faction]].station_score_total + station.score_value
				stat_list[f2s[faction]].station[station:getCallSign()] = {template_type = station:getTypeName(), is_alive = true, score_value = station.score_value}
			end
		end
	end
	local station_weight = .6
	local player_ship_weight = .3
	local npc_ship_weight = .1
	stat_list.weight = {}
	stat_list.weight.station = station_weight
	stat_list.weight.ship = player_ship_weight
	stat_list.weight.npc = npc_ship_weight
	local human_death_penalty = 0
	local kraylor_death_penalty = 0
	local exuari_death_penalty = 0
	local ktlitan_death_penalty = 0
	if respawn_type == "self" then
		human_death_penalty = death_penalty["Human Navy"]
		kraylor_death_penalty = death_penalty["Kraylor"]
		if exuari_angle ~= nil then
			exuari_death_penalty = death_penalty["Exuari"]
		end
		if ktlitan_angle ~= nil then
			ktlitan_death_penalty = death_penalty["Ktlitans"]
		end
	end
	stat_list.human.weighted_score = 
		stat_list.human.station_score_total*station_weight + 
		stat_list.human.ship_score_total*player_ship_weight + 
		stat_list.human.npc_score_total*npc_ship_weight - 
		human_death_penalty
	stat_list.kraylor.weighted_score = 
		stat_list.kraylor.station_score_total*station_weight + 
		stat_list.kraylor.ship_score_total*player_ship_weight + 
		stat_list.kraylor.npc_score_total*npc_ship_weight - 
		kraylor_death_penalty
	if exuari_angle ~= nil then
		stat_list.exuari.weighted_score = 
			stat_list.exuari.station_score_total*station_weight + 
			stat_list.exuari.ship_score_total*player_ship_weight + 
			stat_list.exuari.npc_score_total*npc_ship_weight - 
			exuari_death_penalty
	end
	if ktlitan_angle ~= nil then
		stat_list.ktlitan.weighted_score = 
			stat_list.ktlitan.station_score_total*station_weight + 
			stat_list.ktlitan.ship_score_total*player_ship_weight + 
			stat_list.ktlitan.npc_score_total*npc_ship_weight - 
			ktlitan_death_penalty
	end
	if original_score ~= nil then
		stat_list.human.original_weighted_score = original_score["Human Navy"]
		stat_list.kraylor.original_weighted_score = original_score["Kraylor"]
		if exuari_angle ~= nil then
			stat_list.exuari.original_weighted_score = original_score["Exuari"]
		end
		if ktlitan_angle ~= nil then
			stat_list.ktlitan.original_weighted_score = original_score["Ktlitans"]
		end
	end
	return stat_list
end
function pickWinner(reason)
	local stat_list = gatherStats()
	local sorted_faction = {}
	local tie_breaker = {}
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			tie_breaker[p:getFaction()] = p:getReputationPoints()/10000
		end
	end
	stat_list.human.weighted_score = stat_list.human.weighted_score + tie_breaker["Human Navy"]
	table.insert(sorted_faction,{name="Human Navy",score=stat_list.human.weighted_score})
	stat_list.kraylor.weighted_score = stat_list.kraylor.weighted_score + tie_breaker["Kraylor"]
	table.insert(sorted_faction,{name="Kraylor",score=stat_list.kraylor.weighted_score})
	if exuari_angle ~= nil then
		stat_list.exuari.weighted_score = stat_list.exuari.weighted_score + tie_breaker["Exuari"]
		table.insert(sorted_faction,{name="Exuari",score=stat_list.exuari.weighted_score})
	end
	if ktlitan_angle ~= nil then
		stat_list.ktlitan.weighted_score = stat_list.ktlitan.weighted_score + tie_breaker["Ktlitans"]
		table.insert(sorted_faction,{name="Ktlitans",score=stat_list.ktlitan.weighted_score})
	end
	table.sort(sorted_faction,function(a,b)
		return a.score > b.score
	end)
	local out = string.format("%s wins with a score of %.1f!\n",sorted_faction[1].name,sorted_faction[1].score)
	for i=2,#sorted_faction do
		out = out .. string.format("%s:%.1f ",sorted_faction[i].name,sorted_faction[i].score)
	end
	out = out .. "\n" .. reason
	print(out)
	print("Humans:",stat_list.human.weighted_score)
	print("Kraylor:",stat_list.kraylor.weighted_score)
	if exuari_angle then
		print("Exuari:",stat_list.exuari.weighted_score)
	end
	if ktlitan_angle then
		print("Ktlitans:",stat_list.ktlitan.weighted_score)
	end
	addGMMessage(out)
	globalMessage(out)
	game_state = string.format("victory-%s",f2s[sorted_faction[1].name])
	victory(sorted_faction[1].name)
end
function update(delta)
	if delta == 0 then
		--game paused
		return
	end
	if respawn_countdown ~= nil then
		respawn_countdown = respawn_countdown - delta
		if respawn_countdown < 0 then
			delayedRespawn()
		end
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if not terrain_generated then
		generateTerrain()
	end
	game_state = "running"
	local stat_list = gatherStats()
	if stat_list.human.weighted_score < original_score["Human Navy"]/2 then
		pickWinner("End cause: Human Navy fell below 50% of original strength")
	end
	if stat_list.kraylor.weighted_score < original_score["Kraylor"]/2 then
		pickWinner("End cause: Kraylor fell below 50% of original strength")
	end
	if exuari_angle ~= nil then
		if stat_list.exuari.weighted_score < original_score["Exuari"]/2 then
			pickWinner("End cause: Exuari fell below 50% of original strength")
		end
	end
	if ktlitan_angle ~= nil then
		if stat_list.ktlitan.weighted_score < original_score["Ktlitans"]/2 then
			pickWinner("End cause: Ktlitans fell below 50% of original strength")
		end
	end
	game_time_limit = game_time_limit - delta
	if game_time_limit < 0 then
		pickWinner("End cause: Time ran out")
	end
	local hrs = stat_list.human.weighted_score/original_score["Human Navy"]
	local krs = stat_list.kraylor.weighted_score/original_score["Kraylor"]
	local rel_dif = math.abs(hrs-krs)
	if rel_dif > thresh then
		if exuari_angle ~= nil then
			ers = stat_list.exuari.weighted_score/original_score["Exuari"]
			rel_dif = math.abs(hrs-ers)
			local ref_dif_2 = math.abs(ers-krs)
			if rel_dif > thresh or ref_dif_2 > thresh then
				if ktlitan_angle ~= nil then
					brs = stat_list.ktlitan.weighted_score/original_score["Ktlitans"]
					rel_dif = math.abs(brs-ers)
					ref_dif_2 = math.abs(brs-krs)
					local rel_dif_3 = math.abs(hrs-brs)
					if rel_dif > thresh or ref_dif_2 > thresh or rel_dif_3 > thresh then
						pickWinner(string.format("End cause: score difference exceeded %i%%",thresh*100))
					end
				else
					pickWinner(string.format("End cause: score difference exceeded %i%%",thresh*100))
				end
			end
		else
			pickWinner(string.format("End cause: score difference exceeded %i%%",thresh*100))
		end
	end
	local score_banner = string.format("H:%i K:%i",math.floor(stat_list.human.weighted_score),math.floor(stat_list.kraylor.weighted_score))
	if exuari_angle ~= nil then
		score_banner = string.format("%s E:%i",score_banner,math.floor(stat_list.exuari.weighted_score))
	end
	if ktlitan_angle ~= nil then
		score_banner = string.format("%s B:%i",score_banner,math.floor(stat_list.ktlitan.weighted_score))
	end
	if game_time_limit > 60 then
		score_banner = string.format("%s %i:%.2i",score_banner,stat_list.times.game.minutes_left,stat_list.times.game.seconds_left)
	else
		score_banner = string.format("%s %i",score_banner,stat_list.times.game.seconds_left)
	end
	if scientist_asset_message == nil then
		scientist_asset_message = "sent"
		if scientist_list ~= nil then
			for pidx=1,32 do
				local p = getPlayerShip(pidx)
				if p ~= nil and p:isValid() then
					if scientist_list[p:getFaction()] ~= nil then
						if #scientist_list[p:getFaction()] > 1 then
							p:addToShipLog("In addition to the stations and fleet assets, Command has deemed certain scientists as critical to the war effort. Loss of these scientists will count against you like the loss of stations and fleet assets will. Scientist list:","Magenta")
						else
							p:addToShipLog("In addition to the stations and fleet assets, Command has deemed this scientist as critical to the war effort. Loss of this scientist will count against you like the loss of stations and fleet assets will. Scientist:","Magenta")
						end
						for _, scientist in ipairs(scientist_list[p:getFaction()]) do
							p:addToShipLog(string.format("Value: %i, Name: %s, Specialization: %s, Location: %s",scientist.score_value,scientist.name,scientist.topic,scientist.location_name),"Magenta")
						end
						if #scientist_list[p:getFaction()] > 1 then
							p:addToShipLog("These scientists will be weighted with the other NPC assets","Magenta")
						else
							p:addToShipLog("This scientist will be weighted with the other NPC assets","Magenta")
						end
					end
				end
			end
		end
	end
	healthCheckTimer = healthCheckTimer - delta
	local warning_message = nil
	local warning_station = nil
	local warning_message = {}
	local warning_station = {}
	for stn_faction, stn_list in pairs(station_list) do
		for station_index=1,#stn_list do
			local current_station = stn_list[station_index]
			if current_station ~= nil and current_station:isValid() then
				if current_station.proximity_warning == nil then
					for _, obj in ipairs(current_station:getObjectsInRange(station_sensor_range)) do
						if obj ~= nil and obj:isValid() then
							if obj:isEnemy(current_station) then
								local obj_type_name = obj.typeName
								if obj_type_name ~= nil and string.find(obj_type_name,"PlayerSpaceship") then
									warning_station[stn_faction] = current_station
									warning_message[stn_faction] = string.format("[%s in %s] We detect one or more enemies nearby. At least one is of type %s",current_station:getCallSign(),current_station:getSectorName(),obj:getTypeName())
									current_station.proximity_warning = warning_message[stn_faction]
									current_station.proximity_warning_timer = delta + 300
									break
								end
							end
						end
					end
					if warning_station[stn_faction] ~= nil then	--was originally warning message
						break
					end
				else
					current_station.proximity_warning_timer = current_station.proximity_warning_timer - delta
					if current_station.proximity_warning_timer < 0 then
						current_station.proximity_warning = nil
					end
				end
				if warning_station[stn_faction] == nil then
					--shield damage warning
					if current_station.shield_damage_warning == nil then
						for i=1,current_station:getShieldCount() do
							if current_station:getShieldLevel(i-1) < current_station:getShieldMax(i-1) then
								warning_station[stn_faction] = current_station
								warning_message[stn_faction] = string.format("[%s in %s] Our shields have taken damage",current_station:getCallSign(),current_station:getSectorName())
								current_station.shield_damage_warning = warning_message[stn_faction]
								current_station.shield_damage_warning_timer = delta + 300
								break
							end
						end
						if warning_station[stn_faction] ~= nil then
							break
						end
					else
						current_station.shield_damage_warning_timer = current_station.shield_damage_warning_timer - delta
						if current_station.shield_damage_warning_timer < 0 then
							current_station.shield_damage_warning = nil
						end
					end
				end
				if warning_station[stn_faction] == nil then
					--severe shield damage warning
					if current_station.severe_shield_warning == nil then
						local current_station_shield_count = current_station:getShieldCount()
						for i=1,current_station_shield_count do
							if current_station:getShieldLevel(i-1) < current_station:getShieldMax(i-1)*.1 then
								warning_station[stn_faction] = current_station
								if current_station_shield_count == 1 then
									warning_message[stn_faction] = string.format("[%s in %s] Our shields are nearly gone",current_station:getCallSign(),current_station:getSectorName())
								else
									warning_message[stn_faction] = string.format("[%s in %s] One or more of our shields are nearly gone",current_station:getCallSign(),current_station:getSectorName())
								end
								current_station.severe_shield_warning = warning_message[stn_faction]
								current_station.severe_shield_warning_timer = delta + 300
								break
							end
						end
						if warning_station[stn_faction] ~= nil then
							break
						end
					else
						current_station.severe_shield_warning_timer = current_station.severe_shield_warning_timer - delta
						if current_station.severe_shield_warning_timer < 0 then
							current_station.severe_shield_warning = nil
						end
					end
				end
				if warning_station[stn_faction] == nil then
					--hull damage warning
					if current_station.hull_warning == nil then
						if current_station:getHull() < current_station:getHullMax() then
							warning_station[stn_faction] = current_station
							warning_message[stn_faction] = string.format("[%s in %s] Our hull has been damaged",current_station:getCallSign(),current_station:getSectorName())
							current_station.hull_warning = warning_message[stn_faction]
							break
						end
					end
				end
				if warning_station[stn_faction] == nil then
					--severe hull damage warning
					if current_station.severe_hull_warning == nil then
						if current_station:getHull() < current_station:getHullMax()*.1 then
							warning_station[stn_faction] = current_station
							warning_message[stn_faction] = string.format("[%s in %s] We are on the brink of destruction",current_station:getCallSign(),current_station:getSectorName())
							current_station.severe_hull_warning = warning_message[stn_faction]
						end
					end
				end
			end	--	current station not nil and is valid
		end
	end
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local player_name = p:getCallSign()
			if warning_station["Human Navy"] ~= nil and p:getFaction() == "Human Navy" then
				p:addToShipLog(warning_message["Human Navy"],"Red")
			end
			if warning_station["Kraylor"] ~= nil and p:getFaction() == "Kraylor" then
				p:addToShipLog(warning_message["Kraylor"],"Red")
			end
			if exuari_angle ~= nil then
				if warning_station["Exuari"] ~= nil and p:getFaction() == "Exuari" then
					p:addToShipLog(warning_message["Exuari"],"Red")
				end
			end
			if ktlitan_angle ~= nil then
				if warning_station["Ktlitans"] ~= nil and p:getFaction() == "Ktlitans" then
					p:addToShipLog(warning_message["Ktlitans"],"Red")
				end
			end
			local name_tag_text = string.format("%s in %s",player_name,p:getSectorName())
			if p:hasPlayerAtPosition("Relay") then
				p.name_tag = "name_tag"
				p:addCustomInfo("Relay",p.name_tag,name_tag_text)
				p.score_banner = "score_banner"
				p:addCustomInfo("Relay",p.score_banner,score_banner)
			end
			if p:hasPlayerAtPosition("Operations") then
				p.name_tag_ops = "name_tag_ops"
				p:addCustomInfo("Operations",p.name_tag_ops,name_tag_text)
				p.score_banner_ops = "score_banner_ops"
				p:addCustomInfo("Operations",p.score_banner_ops,score_banner)
			end
			if p:hasPlayerAtPosition("ShipLog") then
				p.name_tag_log = "name_tag_log"
				p:addCustomInfo("ShipLog",p.name_tag_log,name_tag_text)
				p.score_banner_log = "score_banner_log"
				p:addCustomInfo("ShipLog",p.score_banner_log,score_banner)
			end
			if p:hasPlayerAtPosition("Helms") then
				p.name_tag_helm = "name_tag_helm"
				p:addCustomInfo("Helms",p.name_tag_helm,name_tag_text)
			end
			if p:hasPlayerAtPosition("Tactical") then
				p.name_tag_tac = "name_tag_tac"
				p:addCustomInfo("Tactical",p.name_tag_tac,name_tag_text)
			end
			if p.inventoryButton == nil then
				local goodCount = 0
				if p.goods ~= nil then
					for good, goodQuantity in pairs(p.goods) do
						goodCount = goodCount + 1
					end
				end
				if goodCount > 0 then		--add inventory button when cargo acquired
					if p:hasPlayerAtPosition("Relay") then
						if p.inventoryButton == nil then
							local tbi = "inventory" .. player_name
							p:addCustomButton("Relay",tbi,"Inventory",function () playerShipCargoInventory(p) end)
							p.inventoryButton = true
						end
					end
					if p:hasPlayerAtPosition("Operations") then
						if p.inventoryButton == nil then
							local tbi = "inventoryOp" .. player_name
							p:addCustomButton("Operations",tbi,"Inventory", function () playerShipCargoInventory(p) end)
							p.inventoryButton = true
						end
					end
				end
			end
			if healthCheckTimer < 0 then	--check to see if any crew perish (or other consequences) due to excessive damage
				if p:getRepairCrewCount() > 0 then
					local fatalityChance = 0
					local currentShield = 0
					if p:getShieldCount() > 1 then
						currentShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						currentShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - currentShield)
					p.prevShield = currentShield
					local currentReactor = p:getSystemHealth("reactor")
					fatalityChance = fatalityChance + (p.prevReactor - currentReactor)
					p.prevReactor = currentReactor
					local currentManeuver = p:getSystemHealth("maneuver")
					fatalityChance = fatalityChance + (p.prevManeuver - currentManeuver)
					p.prevManeuver = currentManeuver
					local currentImpulse = p:getSystemHealth("impulse")
					fatalityChance = fatalityChance + (p.prevImpulse - currentImpulse)
					p.prevImpulse = currentImpulse
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						local currentBeam = p:getSystemHealth("beamweapons")
						fatalityChance = fatalityChance + (p.prevBeam - currentBeam)
						p.prevBeam = currentBeam
					end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						local currentMissile = p:getSystemHealth("missilesystem")
						fatalityChance = fatalityChance + (p.prevMissile - currentMissile)
						p.prevMissile = currentMissile
					end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						local currentWarp = p:getSystemHealth("warp")
						fatalityChance = fatalityChance + (p.prevWarp - currentWarp)
						p.prevWarp = currentWarp
					end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						local currentJump = p:getSystemHealth("jumpdrive")
						fatalityChance = fatalityChance + (p.prevJump - currentJump)
						p.prevJump = currentJump
					end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase survival chances of last repair crew standing
					end
					if fatalityChance > 0 then
						if math.random() < (fatalityChance) then
							if p.initialCoolant == nil then
								p:setRepairCrewCount(p:getRepairCrewCount() - 1)
								if p:hasPlayerAtPosition("Engineering") then
									local repairCrewFatality = "repairCrewFatality"
									p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
								end
								if p:hasPlayerAtPosition("Engineering+") then
									local repairCrewFatalityPlus = "repairCrewFatalityPlus"
									p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
								end
							else
								local consequence = 0
								local upper_consequence = 2
								local consequence_list = {}
								if p:getCanLaunchProbe() then
									upper_consequence = upper_consequence + 1
									table.insert(consequence_list,"probe")
								end
								if p:getCanHack() then
									upper_consequence = upper_consequence + 1
									table.insert(consequence_list,"hack")
								end
								if p:getCanScan() then
									upper_consequence = upper_consequence + 1
									table.insert(consequence_list,"scan")
								end
								if p:getCanCombatManeuver() then
									upper_consequence = upper_consequence + 1
									table.insert(consequence_list,"combat_maneuver")
								end
								if p:getCanSelfDestruct() then
									upper_consequence = upper_consequence + 1
									table.insert(consequence_list,"self_destruct")
								end
								if p:getWeaponTubeCount() > 0 then
									upper_consequence = upper_consequence + 1
									table.insert(consequence_list,"tube_time")
								end
								consequence = math.random(1,upper_consequence)
								if consequence == 1 then
									p:setRepairCrewCount(p:getRepairCrewCount() - 1)
									if p:hasPlayerAtPosition("Engineering") then
										local repairCrewFatality = "repairCrewFatality"
										p:addCustomMessage("Engineering",repairCrewFatality,"One of your repair crew has perished")
									end
									if p:hasPlayerAtPosition("Engineering+") then
										local repairCrewFatalityPlus = "repairCrewFatalityPlus"
										p:addCustomMessage("Engineering+",repairCrewFatalityPlus,"One of your repair crew has perished")
									end
								elseif consequence == 2 then
									local current_coolant = p:getMaxCoolant()
									local lost_coolant = 0
									if current_coolant >= 10 then
										lost_coolant = current_coolant*random(.25,.5)	--lose between 25 and 50 percent
									else
										lost_coolant = current_coolant*random(.15,.35)	--lose between 15 and 35 percent
									end
									p:setMaxCoolant(current_coolant - lost_coolant)
									if p.reclaimable_coolant == nil then
										p.reclaimable_coolant = 0
									end
									p.reclaimable_coolant = math.min(20,p.reclaimable_coolant + lost_coolant*random(.8,1))
									if p:hasPlayerAtPosition("Engineering") then
										local coolantLoss = "coolantLoss"
										p:addCustomMessage("Engineering",coolantLoss,"Damage has caused a loss of coolant")
									end
									if p:hasPlayerAtPosition("Engineering+") then
										local coolantLossPlus = "coolantLossPlus"
										p:addCustomMessage("Engineering+",coolantLossPlus,"Damage has caused a loss of coolant")
									end
								else
									local named_consequence = consequence_list[consequence-2]
									if named_consequence == "probe" then
										p:setCanLaunchProbe(false)
										if p:hasPlayerAtPosition("Engineering") then
											p:addCustomMessage("Engineering","probe_launch_damage_message","The probe launch system has been damaged")
										end
										if p:hasPlayerAtPosition("Engineering+") then
											p:addCustomMessage("Engineering+","probe_launch_damage_message_plus","The probe launch system has been damaged")
										end
									elseif named_consequence == "hack" then
										p:setCanHack(false)
										if p:hasPlayerAtPosition("Engineering") then
											p:addCustomMessage("Engineering","hack_damage_message","The hacking system has been damaged")
										end
										if p:hasPlayerAtPosition("Engineering+") then
											p:addCustomMessage("Engineering+","hack_damage_message_plus","The hacking system has been damaged")
										end
									elseif named_consequence == "scan" then
										p:setCanScan(false)
										if p:hasPlayerAtPosition("Engineering") then
											p:addCustomMessage("Engineering","scan_damage_message","The scanners have been damaged")
										end
										if p:hasPlayerAtPosition("Engineering+") then
											p:addCustomMessage("Engineering+","scan_damage_message_plus","The scanners have been damaged")
										end
									elseif named_consequence == "combat_maneuver" then
										p:setCanCombatManeuver(false)
										if p:hasPlayerAtPosition("Engineering") then
											p:addCustomMessage("Engineering","combat_maneuver_damage_message","Combat maneuver has been damaged")
										end
										if p:hasPlayerAtPosition("Engineering+") then
											p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus","Combat maneuver has been damaged")
										end
									elseif named_consequence == "self_destruct" then
										p:setCanSelfDestruct(false)
										if p:hasPlayerAtPosition("Engineering") then
											p:addCustomMessage("Engineering","self_destruct_damage_message","Self destruct system has been damaged")
										end
										if p:hasPlayerAtPosition("Engineering+") then
											p:addCustomMessage("Engineering+","self_destruct_damage_message_plus","Self destruct system has been damaged")
										end
									elseif named_consequence == "tube_time" then
										local tube_count = p:getWeaponTubeCount()
										local tube_index = 0
										if p.normal_tube_load_time == nil then
											p.normal_tube_load_time = {}
											repeat
												p.normal_tube_load_time[tube_index] = p:getTubeLoadTime(tube_index)
												tube_index = tube_index + 1
											until(tube_index >= tube_count)
											tube_index = 0
										end
										repeat
											p:setTubeLoadTime(tube_index,p:getTubeLoadTime(tube_index) + 2)
											tube_index = tube_index + 1
										until(tube_index >= tube_count)
										if p:hasPlayerAtPosition("Engineering") then
											p:addCustomMessage("Engineering","tube_slow_down_message","Tube damage has caused tube load time to increase")
										end
										if p:hasPlayerAtPosition("Engineering+") then
											p:addCustomMessage("Engineering+","tube_slow_down_message_plus","Tube damage has caused tube load time to increase")
										end
									end
								end	--coolant loss branch
							end	--could lose coolant branch
						end	--bad consequences of damage branch
					end	--possible chance of bad consequences branch
				else	--no repair crew left
					if random(1,100) <= 4 then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,"Medical team has revived one of your repair crew")
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,"Medical team has revived one of your repair crew")
						end
						resetPreviousSystemHealth(p)
					end	--medical science triumph branch
				end	--no repair crew left
				if p.initialCoolant ~= nil then
					current_coolant = p:getMaxCoolant()
					if current_coolant < 20 then
						if random(1,100) <= 4 then
							local reclaimed_coolant = 0
							if p.reclaimable_coolant ~= nil and p.reclaimable_coolant > 0 then
								reclaimed_coolant = p.reclaimable_coolant*random(.1,.5)	--get back 10 to 50 percent of reclaimable coolant
								p:setMaxCoolant(math.min(20,current_coolant + reclaimed_coolant))
								p.reclaimable_coolant = p.reclaimable_coolant - reclaimed_coolant
							end
							local noticable_reclaimed_coolant = math.floor(reclaimed_coolant)
							if noticable_reclaimed_coolant > 0 then
								if p:hasPlayerAtPosition("Engineering") then
									local coolant_recovery = "coolant_recovery"
									p:addCustomMessage("Engineering",coolant_recovery,"Automated systems have recovered some coolant")
								end
								if p:hasPlayerAtPosition("Engineering+") then
									local coolant_recovery_plus = "coolant_recovery_plus"
									p:addCustomMessage("Engineering+",coolant_recovery_plus,"Automated systems have recovered some coolant")
								end
							end
							resetPreviousSystemHealth(p)
						end
					end
				end
			end	--health check branch
			local secondary_systems_optimal = true
			if not p:getCanLaunchProbe() then
				secondary_systems_optimal = false
			end
			if secondary_systems_optimal and not p:getCanHack() then
				secondary_systems_optimal = false
			end
			if secondary_systems_optimal and not p:getCanScan() then
				secondary_systems_optimal = false
			end
			if secondary_systems_optimal and not p:getCanCombatManeuver() then
				secondary_systems_optimal = false
			end
			if secondary_systems_optimal and not p:getCanSelfDestruct() then
				secondary_systems_optimal = false
			end
			if secondary_systems_optimal then
				local tube_count = p:getWeaponTubeCount()
				if tube_count > 0 and p.normal_tube_load_time ~= nil then
					local tube_index = 0
					repeat
						if p.normal_tube_load_time[tube_index] ~= p:getTubeLoadTime(tube_index) then
							secondary_systems_optimal = false
							break
						end
						tube_index = tube_index + 1
					until(tube_index >= tube_count)
				end
			end
			if secondary_systems_optimal then	--remove damage report button
				if p.damage_report ~= nil then
					p:removeCustom(p.damage_report)
					p.damage_report = nil
				end
				if p.damage_report_plus ~= nil then
					p:removeCustom(p.damage_report_plus)
					p.damage_report_plus = nil
				end
			else	--add damage report button
				if p:hasPlayerAtPosition("Engineering") then
					p.damage_report = "damage_report"
					p:addCustomButton("Engineering",p.damage_report,"Damage Report",function()
						local dmg_msg = "In addition to the primary systems constantly monitored in engineering, the following secondary systems have also been damaged requiring docking repair facilities:"
						if not p:getCanLaunchProbe() then
							dmg_msg = dmg_msg .. "\nProbe launch system"
						end
						if not p:getCanHack() then
							dmg_msg = dmg_msg .. "\nHacking system"
						end
						if not p:getCanScan() then
							dmg_msg = dmg_msg .. "\nScanning system"
						end
						if not p:getCanCombatManeuver() then
							dmg_msg = dmg_msg .. "\nCombat maneuvering system"
						end
						if not p:getCanSelfDestruct() then
							dmg_msg = dmg_msg .. "\nSelf destruct system"
						end
						local tube_count = p:getWeaponTubeCount()
						if tube_count > 0 then
							if tube_count > 0 and p.normal_tube_load_time ~= nil then
								local tube_index = 0
								repeat
									if p.normal_tube_load_time[tube_index] ~= p:getTubeLoadTime(tube_index) then
										dmg_msg = dmg_msg .. "\nWeapon tube load time degraded"
										break
									end
									tube_index = tube_index + 1
								until(tube_index >= tube_count)
							end
						end
						p.dmg_msg = "dmg_msg"
						p:addCustomMessage("Engineering",p.dmg_msg,dmg_msg)
					end)
				end	--engineering damage report button
				if p:hasPlayerAtPosition("Engineering+") then
					p.damage_report_plus = "damage_report_plus"
					p:addCustomButton("Engineering",p.damage_report_plus,"Damage Report",function()
						local dmg_msg = "In addition to the primary systems constantly monitored in engineering, the following secondary systems have also been damaged requiring docking repair facilities:"
						if not p:getCanLaunchProbe() then
							dmg_msg = dmg_msg .. "\nProbe launch system"
						end
						if not p:getCanHack() then
							dmg_msg = dmg_msg .. "\nHacking system"
						end
						if not p:getCanScan() then
							dmg_msg = dmg_msg .. "\nScanning system"
						end
						if not p:getCanCombatManeuver() then
							dmg_msg = dmg_msg .. "\nCombat maneuvering system"
						end
						if not p:getCanSelfDestruct() then
							dmg_msg = dmg_msg .. "\nSelf destruct system"
						end
						local tube_count = p:getWeaponTubeCount()
						if tube_count > 0 then
							if tube_count > 0 and p.normal_tube_load_time ~= nil then
								local tube_index = 0
								repeat
									if p.normal_tube_load_time[tube_index] ~= p:getTubeLoadTime(tube_index) then
										dmg_msg = dmg_msg .. "\nWeapon tube load time degraded"
										break
									end
									tube_index = tube_index + 1
								until(tube_index >= tube_count)
							end
						end
						p.dmg_msg = "dmg_msg"
						p:addCustomMessage("Engineering+",p.dmg_msg,dmg_msg)
					end)
				end	--engineering plus damage report button
			end	--damage report button necessary
			if p.normal_long_range_radar == nil then
				p.normal_long_range_radar = p:getLongRangeRadarRange()
			end
			local sensor_boost_amount = 0
			local sensor_boost_present = false
			if station_primary_human:isValid() then
				if p:isDocked(station_primary_human) then
					sensor_boost_present = true
					sensor_boost_amount = station_primary_human.comms_data.sensor_boost.value
				end
			end
			if station_primary_kraylor:isValid() then
				if p:isDocked(station_primary_kraylor) then
					sensor_boost_present = true
					sensor_boost_amount = station_primary_kraylor.comms_data.sensor_boost.value
				end
			end
			if exuari_angle ~= nil then
				if station_primary_exuari:isValid() then
					if p:isDocked(station_primary_exuari) then
						sensor_boost_present = true
						sensor_boost_amount = station_primary_exuari.comms_data.sensor_boost.value
					end
				end
			end
			if ktlitan_angle ~= nil then
				if station_primary_ktlitan:isValid() then
					if p:isDocked(station_primary_ktlitan) then
						sensor_boost_present = true
						sensor_boost_amount = station_primary_ktlitan.comms_data.sensor_boost.value
					end
				end
			end
			local boosted_range = p.normal_long_range_radar + sensor_boost_amount
			if sensor_boost_present then
				if p:getLongRangeRadarRange() < boosted_range then
					p:setLongRangeRadarRange(boosted_range)
				end
			else
				if p:getLongRangeRadarRange() > p.normal_long_range_radar then
					p:setLongRangeRadarRange(p.normal_long_range_radar)
				end
			end
		end	--p is not nil and is valid
	end	--loop through players
end
