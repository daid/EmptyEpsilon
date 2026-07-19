-- Name: Defender Hunter
-- Description: Defend home station and hunt down enemies
--- 
--- Initially, you're tasked with defending your home base.  Over time, you'll discover more about the enemies harassing you and you'll be ordered to find and destroy the enemies responsible.  There may be various missions given along the way, but the enemy harassment will continue.  You must balance your two missions.
---
--- Designed for any number of cooperating player ships. Randomization makes many details different for each game, but the primary goals remain the same. Untimed variations can take an hour or longer for full mission completion. Different sub-missions may be chosen by the players or will be chosen at random. Achieving victory in a timed hunter variation is quite a challenge. Like the Waves scenario, the enemies get harder over time.
---
--- Version 11
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one almost every weekend. All experience levels are welcome. 
-- Type: Replayable Mission
-- Setting[Enemies]: Configures the number and type of enemies
-- Enemies[Easy]: Fewer and/or weaker enemy ships
-- Enemies[Normal|Default]: Normal difficulty
-- Enemies[Hard]: More and/or stronger enemy ships
-- Enemies[Extreme]: Many more or much stronger enemy ships
-- Enemies[Quixotic]: Enemies likely to overwhelm you
-- Setting[Time]: Sets the length of time for the scenario
-- Time[Unlimited|Default]: No time limit. Protect home station and hunt and destroy designated enemy station.
-- Time[30min]: Scenario ends in 30 minutes
-- Time[35min]: Scenario ends in 35 minutes
-- Time[40min]: Scenario ends in 40 minutes
-- Time[45min]: Scenario ends in 45 minutes
-- Time[50min]: Scenario ends in 50 minutes
-- Time[55min]: Scenario ends in 55 minutes
-- Time[60min]: Scenario ends in 60 minutes
-- Setting[Goal]: Sets primary goal. Pertinent to timed scenario
-- Goal[Defender|Default]: Protect home station. If timed scenario, victory after time runs out if home station survives.
-- Goal[Hunter]: Protect home station and hunt down designated enemy station. If timed scenario, defeat after time runs out if designated enemy station survives.
-- Setting[Murphy]: Configures the perversity of the universe according to Murphy's law
-- Murphy[Easy]: Random factors are more in your favor
-- Murphy[Normal|Default]: Random factors are normal
-- Murphy[Hard]: Random factors are more against you

-- typical colors used in ship log
-- 	"Red"			Red									Enemies spotted
--	"Blue"			Blue
--	"Yellow"		Yellow								Maria Shrivner
--	"Magenta"		Magenta								Headquarters
--	"Green"			Green
--	"Cyan"			Cyan
--	"Black"			Black
--	"#555555"		Dark gray			"55,55,55"
--	"#ff4500"		Orange red			"255,69,0"		HMS Bounty
--	"#ff7f50"		Coral				"255,127,80"
--	"#5f9ea0"		Cadet blue			"95,158,160"	Paul Straight
--	"#4169e1"		Royal blue			"65,105,225"
--	"#8a2be2"		Blue violet			"138,43,226"
--	"#ba55d3"		Medium orchid		"186,85,211"	Maria's station
--	"#a0522d"		Sienna				"160,82,45"
--	"#b29650"		Arbitrary			"178,150,80"
--	"#556b2f"		Dark olive green	"85,107,47"		Home station
--	"#228b22"		Forest green		"34,139,34"
--	"#b22222"		Firebrick			"178,34,34"

require("utils.lua")
require("generate_call_sign_scenario_utility.lua")
require("place_station_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
-------------------------------
--	Initialization routines  --
-------------------------------
function init()
	wfv = "nowhere"		--wolf fence value - used for debugging
	scenario_version = "11.0.2"
	ee_version = "2024.12.08"
	print(string.format("   ---   Scenario: Defender Hunter   ---   Version %s   ---   EE version: %s   ---   Tested with EE version %s   ---",scenario_version,getEEVersion(),ee_version))
	if _VERSION ~= nil then
		print("Lua version:",_VERSION)
	end
	ECS = false
	if createEntity then
		ECS = true
	end
	plot_1_diagnostic = false
	plot_2_diagnostic = false
	setVariations()
	setConstants()
	setGlobals()
	diagnostic = false		
	helpfulWarningDiagnostic = false
	constructEnvironment()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
	wfv = "end of init"
end
function setVariations()
--translate variations into a numeric difficulty value
	local enemy_config = {
		["Easy"] =		{number = .5},
		["Normal"] =	{number = 1},
		["Hard"] =		{number = 2},
		["Extreme"] =	{number = 3},
		["Quixotic"] =	{number = 5},
	}
	enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
	local murphy_config = {
		["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005},
		["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001},
		["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001},
	}
	difficulty =	murphy_config[getScenarioSetting("Murphy")].number
	adverseEffect =	murphy_config[getScenarioSetting("Murphy")].adverse
	coolant_loss =	murphy_config[getScenarioSetting("Murphy")].lose_coolant
	coolant_gain =	murphy_config[getScenarioSetting("Murphy")].gain_coolant
	local time_config = {
		["Unlimited"] = {interval = 300,	limit = false,	time = 0,		plot = nil			},
		["30min"] =		{interval = 200,	limit = true,	time = 30 * 60,	plot = timedGame	},
		["35min"] =		{interval = 215,	limit = true,	time = 35 * 60,	plot = timedGame	},
		["40min"] =		{interval = 230,	limit = true,	time = 40 * 60,	plot = timedGame	},
		["45min"] =		{interval = 245,	limit = true,	time = 45 * 60,	plot = timedGame	},
		["50min"] =		{interval = 260,	limit = true,	time = 50 * 60,	plot = timedGame	},
		["55min"] =		{interval = 275,	limit = true,	time = 55 * 60,	plot = timedGame	},
		["60min"] =		{interval = 290,	limit = true,	time = 60 * 60,	plot = timedGame	},
	}
	timedIntelligenceInterval =	time_config[getScenarioSetting("Time")].interval
	playWithTimeLimit =			time_config[getScenarioSetting("Time")].limit
	gameTimeLimit =				time_config[getScenarioSetting("Time")].time
	plot6 =						time_config[getScenarioSetting("Time")].plot
end
function setGlobals()
	--list of goods available to buy, sell or trade (sell still under development)
	goodsList = {	
		{"food",0},
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
		{"battery",0}	
	}
	jump_start = true
	recurring_prods = {
		{time = 30*60,	used = false},
		{time = 60*60,	used = false},
		{time = 90*60,	used = false},
	}
	interWave = 280
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
	--gossip will have meaning for a future mission addition. Right now, it's just color
	gossipSnippets = {}
	table.insert(gossipSnippets,_("gossip-comms", "I hear the head of operations has a thing for his administrative assistant"))	--1
	table.insert(gossipSnippets,_("gossip-comms", "My mining friends tell me Krak or Kruk is about to strike it rich"))			--2
	table.insert(gossipSnippets,_("gossip-comms", "Did you know you can usually hire replacement repair crew cheaper at friendly stations?"))		--3
	table.insert(gossipSnippets,_("gossip-comms", "Under their uniforms, the Kraylors have an extra appendage. I wonder what they use it for"))	--4
	table.insert(gossipSnippets,_("gossip-comms", "The Kraylors may be human navy enemies, but they make some mighty fine BBQ Mynock"))			--5
	table.insert(gossipSnippets,_("gossip-comms", "The Kraylors and the Ktlitans may be nearing a cease fire from what I hear. That'd be bad news for us"))		--6
	table.insert(gossipSnippets,_("gossip-comms", "Docking bay 7 has interesting mind altering substances for sale, but they're monitored between 1900 and 2300"))	--7
	table.insert(gossipSnippets,_("gossip-comms", "Watch the sky tonight in quadrant J around 2243. It should be spectacular"))					--8
	table.insert(gossipSnippets,_("gossip-comms", "I think the shuttle pilot has a tame miniature Ktlitan caged in his quarters. Sometimes I hear it at night"))	--9
	table.insert(gossipSnippets,_("gossip-comms", "Did you hear the screaming chase in the corridors on level 4 last night? Three Kraylors were captured and put in the brig"))	--10
	table.insert(gossipSnippets,_("gossip-comms", "Rumor has it that the two Lichten brothers are on the verge of a new discovery. And it's not another wine flavor either"))		--11
	--Player ship name lists to supplant standard randomized call sign generation
	player_ship_names = {
		["Atlantis"] =			{"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"},
		["Benedict"] =			{"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"},
		["Crucible"] =			{"Sling", "Stark", "Torrid", "Kicker", "Flummox"},
		["Ender"] =				{"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"},
		["Flavia P.Falcon"] =	{"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"},
		["Hathcock"] =			{"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"},
		["Kiriya"] =			{"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"},
		["MP52 Hornet"] =		{"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"},
		["Maverick"] =			{"Festoon", "Earp", "Schwartz", "Tentacular", "Prickly", "Thunderbird", "Hickok", "Clifton", "Fett", "Holliday", "Sundance"},
		["Nautilus"] =			{"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"},
		["Phobos M3P"] =		{"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"},
		["Piranha"] =			{"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"},
		["Repulse"] =			{"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"},
		["Saipan"] =			{"Atlas", "Bernard", "Alexander", "Retribution", "Sulaco", "Conestoga", "Saratoga", "Pegasus"},
		["Striker"] =			{"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"},
		["ZX-Lindworm"] =		{"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"},
		["Player Cruiser"] =	{"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"},
		["Player Missile Cr."] ={"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"},
		["Player Fighter"] =	{"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"},
		["Leftovers"] =			{"Foregone","Righteous","Masher"},
	}
	highestConcurrentPlayerCount = 0
	setConcurrentPlayerCount = 0
	primaryOrders = ""
	secondaryOrders = ""
	optionalOrders = ""
	transportList = {}
	homeDelivery = false
	infoPromised = false
	baseIntelligenceAvailable = false
	spinUpgradeAvailable = false
	hullUpgradeAvailable = false
	rotateUpgradeAvailable = false
	beamTimeUpgradeAvailable = false
	missionLength = 1
	initialOrderTimer = 3
	plot1 = initialOrders
	transportSpawnDelay = 10
	healthCheckTimer = 5
	healthCheckTimerInterval = 5
	healthCheckCount = 0
	plot4choices = {}
	table.insert(plot4choices,stationShieldDelay)
	table.insert(plot4choices,repairBountyDelay)
	table.insert(plot4choices,insertAgentDelay)
end
function setConstants()
	player_ship_stats = {	--ordered by name
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000},
		["Hathcock"]			= { strength = 30,	cargo = 6,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000},
		["Kiriya"]				= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 35000, short_range_radar = 5000},
		["Maverick"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 4000},
		["MP52 Hornet"] 		= { strength = 7, 	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 4000},
		["Nautilus"]			= { strength = 12,	cargo = 7,	distance = 200,	long_range_radar = 22000, short_range_radar = 4000},
		["Phobos M3P"]			= { strength = 19,	cargo = 10,	distance = 200,	long_range_radar = 25000, short_range_radar = 5000},
		["Piranha"]				= { strength = 16,	cargo = 8,	distance = 200,	long_range_radar = 25000, short_range_radar = 6000},
		["Player Cruiser"]		= { strength = 40,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000},
		["Player Fighter"]		= { strength = 7,	cargo = 3,	distance = 100,	long_range_radar = 15000, short_range_radar = 4500},
		["Player Missile Cr."]	= { strength = 45,	cargo = 8,	distance = 200,	long_range_radar = 35000, short_range_radar = 6000},
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000},
		["Striker"]				= { strength = 8,	cargo = 4,	distance = 200,	long_range_radar = 35000, short_range_radar = 5000},
		["ZX-Lindworm"]			= { strength = 8,	cargo = 3,	distance = 100,	long_range_radar = 18000, short_range_radar = 5500},
	}	
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,	create = gnat},
		["Lite Drone"] =		{strength = 3,	create = droneLite},
		["Jacket Drone"] =		{strength = 4,	create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,	create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,	create = droneHeavy},
		["Adder MK3"] =			{strength = 5,	create = stockTemplate},
		["MT52 Hornet"] =		{strength = 5,	create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,	create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,	create = hornetMV52},
		["Adder MK4"] =			{strength = 6,	create = stockTemplate},
		["Fighter"] =			{strength = 6,	create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,	create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,	create = k2fighter},
		["Adder MK5"] =			{strength = 7,	create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,	create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,	create = k3fighter},
		["Adder MK6"] =			{strength = 8,	create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,	create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,	create = wzLindworm},
		["Adder MK7"] =			{strength = 9,	create = stockTemplate},
		["Adder MK8"] =			{strength = 10,	create = stockTemplate},
		["Adder MK9"] =			{strength = 11,	create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,	create = stockTemplate},
		["Phobos R2"] =			{strength = 13,	create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,	create = stockTemplate},
		["Waddle 5"] =			{strength = 15,	create = waddle5},
		["Jade 5"] =			{strength = 15,	create = jade5},
		["Phobos T3"] =			{strength = 15,	create = stockTemplate},
		["Piranha F8"] =		{strength = 15,	create = stockTemplate},
		["Piranha F12"] =		{strength = 15,	create = stockTemplate},
		["Phobos M3"] =			{strength = 16,	create = stockTemplate},
		["Cruiser"] =			{strength = 18,	create = stockTemplate},
		["Nirvana R5A"] =		{strength = 20,	create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 21,	create = stockTemplate},
		["Storm"] =				{strength = 22,	create = stockTemplate},
		["Stalker R5"] =		{strength = 22,	create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,	create = stockTemplate},
		["Ranus U"] =			{strength = 25,	create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,	create = stockTemplate},
		["Stalker R7"] =		{strength = 25,	create = stockTemplate},
		["Adv. Striker"] =		{strength = 27,	create = stockTemplate},
		["Elara P2"] =			{strength = 28,	create = stockTemplate},
		["Tempest"] =			{strength = 30,	create = tempest},
		["Strikeship"] =		{strength = 30,	create = stockTemplate},
		["Fiend G3"] =			{strength = 33,	create = stockTemplate},
		["Fiend G4"] =			{strength = 35,	create = stockTemplate},
		["Fiend G5"] =			{strength = 37,	create = stockTemplate},
		["Fiend G6"] =			{strength = 39,	create = stockTemplate},
		["Predator"] =			{strength = 42,	create = predator},
		["Ktlitan Breaker"] =	{strength = 45,	create = stockTemplate},
		["Ktlitan Feeder"] =	{strength = 48,	create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,	create = stockTemplate},
		["Ktlitan Destroyer"] =	{strength = 50,	create = stockTemplate},
		["Atlantis Y42"] =		{strength = 60,	create = atlantisY42},
		["Blockade Runner"] =	{strength = 65,	create = stockTemplate},
		["Starhammer II"] =		{strength = 70,	create = stockTemplate},
		["Enforcer"] =			{strength = 75,	create = enforcer},
		["Dreadnought"] =		{strength = 80,	create = stockTemplate},
		["Starhammer V"] =		{strength = 90,	create = starhammerV},
		["Battlestation"] =		{strength = 100,create = stockTemplate},
		["Tyr"] =				{strength = 150,create = tyr},
		["Odin"] =				{strength = 250,create = stockTemplate},
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
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
end
function constructEnvironment()
	setWormArt()
	setMovingNebulae()
	setMovingAsteroids()
	buildStations()
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
	button_label = _("buttonGM", "Delay normal to slow")
	if interWave == 600 then
		button_label = _("buttonGM", "Delay slow to fast")
	elseif interWave == 20 then
		button_label = _("buttonGM", "Delay fast to normal")
	end
	addGMFunction(button_label,function()
		if interWave == 280 then
			interWave = 600
		elseif interWave == 600 then
			interWave = 20
		else
			interWave = 280
		end
		mainGMButtons()
	end)
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
	button_label = _("buttonGM", "Delay normal to slow")
	if interWave == 600 then
		button_label = _("buttonGM", "Delay slow to fast")
	elseif interWave == 20 then
		button_label = _("buttonGM", "Delay fast to normal")
	end
	addGMFunction(button_label,function()
		if interWave == 280 then
			interWave = 600
		elseif interWave == 600 then
			interWave = 20
		else
			interWave = 280
		end
		mainGMButtons()
	end)
	button_label = _("buttonGM", "Spawn Enemies")
	addGMFunction(button_label,GMSpawnsEnemies)
end
function GMSpawnsEnemies()
--	Let the GM spawn a random group of enemies to attack a player
	local gmPlayer = nil
	local gmSelect = getGMSelection()
	for idx, obj in ipairs(gmSelect) do
		if isObjectType(obj,"PlayerSpaceship") then
			gmPlayer = obj
			break
		end
	end
	if gmPlayer == nil then
		gmPlayer = closestPlayerTo(targetEnemyStation)
	end
	local px, py = gmPlayer:getPosition()
	local sx, sy = vectorFromAngle(random(0,360),random(20000,30000))
	ntf = spawnEnemies(px+sx,py+sy,dangerValue,targetEnemyStation:getFaction())
	for idx, enemy in ipairs(ntf) do
		enemy:orderAttack(gmPlayer)
	end
end
-- dynamic universe functions: asteroids and nebulae in motion
function setMovingNebulae()
	movingNebulae = {}
	local upperNeb = math.random(5,10)
	for nidx=1,upperNeb do
		local xNeb = random(-100000,100000)
		local yNeb = random(-100000,100000)
		local mNeb = Nebula():setPosition(xNeb, yNeb)
		mNeb.angle = random(0,360)
		mNeb.travel = random(1,100)
		table.insert(movingNebulae,mNeb)
	end
end
function moveNebulae()
	if movingNebulae == nil or #movingNebulae < 1 then
		setMovingNebulae()
	end
	for nidx=1,#movingNebulae do
		local mnx, mny = movingNebulae[nidx]:getPosition()
		if mnx ~= nil and mny ~= nil then
			local angleChange = false
			if mnx < -100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(0,180) + 270
			end
			if mnx > 100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(90,270)
			end
			if mny < -100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(0,180)
			end
			if mny > 100000 then
				angleChange = true
				movingNebulae[nidx].angle = random(180,360)
			end
			local deltaNebx, deltaNeby = vectorFromAngle(movingNebulae[nidx].angle, movingNebulae[nidx].travel/10)
			if angleChange then
				deltaNebx, deltaNeby = vectorFromAngle(movingNebulae[nidx].angle, movingNebulae[nidx].travel/10+20)
				movingNebulae.travel = random(1,100)
			end
			movingNebulae[nidx]:setPosition(mnx+deltaNebx, mny+deltaNeby)
		end
	end
end
function setMovingAsteroids()
	movingAsteroidList = {}
	for aidx=1,30 do
		local xAst = random(-100000,100000)
		local yAst = random(-100000,100000)
		local outRange = true
		local players = getActivePlayerShips()
		for pidx, p2obj in ipairs(players) do
			if p2obj ~= nil and p2obj:isValid() then
				if distance(p2obj,xAst,yAst) < 30000 then
					outRange = false
				end
			end
		end
		if outRange then
	        local asteroid_size = random(1,75) + random(1,50) + random(1,50) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			local mAst = Asteroid():setPosition(xAst,yAst):setSize(asteroid_size)
			mAst.angle = random(0,360)
			mAst.travel = random(40,220)
			if random(1,100) < 50 then
				mAst.curve = 0
			else
				mAst.curve = math.random()*.16 - .08
			end
			table.insert(movingAsteroidList,mAst)
		end
	end
end
function moveAsteroids()
	if movingAsteroidList == nil or #movingAsteroidList < 1 then
		setMovingAsteroids()
	end
	local movingAsteroidCount = 0
	for aidx, aObj in ipairs(movingAsteroidList) do
		if aObj:isValid() then
			movingAsteroidCount = movingAsteroidCount + 1
			local mAstx, mAsty = aObj:getPosition()
			if mAstx < -150000 or mAstx > 150000 or mAsty < -150000 or mAsty > 150000 then
				aObj.angle = random(0,360)
				if random(1,100) < 50 then
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
				local deltaAstx, deltaAsty = vectorFromAngle(aObj.angle,aObj.travel)
				aObj:setPosition(mAstx+deltaAstx,mAsty+deltaAsty)
				aObj.angle = aObj.angle + aObj.curve
			end
		end
	end
end
-- Organically (simulated asymetrically) grow stations from a central grid location
-- Order of creation: friendlies, planet, neutrals, black hole, generic enemies, leading enemies
-- Statistically, the enemy stations typically end up on the edge, a fair distance away, but not always
function buildStations()
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
	for j=1,12 do
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
		pStation = placeDHStation(psx,psy,"RandomHumanNeutral","Human Navy")
		pStation.comms_data.goods.food = {quantity = math.random(5,10), cost = 1}
		if random(1,10) <= 9 then pStation.comms_data.goods.medicine = {quantity = math.random(5,10), cost = 5} end
		table.insert(stationList,pStation)			--save station in general station list
		table.insert(friendlyStationList,pStation)	--save station in friendly station list
		if j == 1 then								--identify first station as home station
			homeStation = pStation
			homeStation.comms_data.probe_launch_repair =	true
			homeStation.comms_data.scan_repair =			true
			homeStation.comms_data.hack_repair =			true
			homeStation.comms_data.combat_maneuver_repair =	true
			homeStation:setRestocksScanProbes(true)
			homeStation:setRepairDocked(true)
			homeStation:setSharesEnergyWithDocked(true)
		end
		if #gossipSnippets > 0 then
			if gp % 2 == 0 then
				ni = math.random(1,#gossipSnippets)
				pStation.gossip = gossipSnippets[ni]
				table.remove(gossipSnippets,ni)
			end
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--insert a planet
	tSize = 7
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
		if random(1,5) >= 2 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	aldx = (gRegion[sri][1] - (gbHigh/2))*gSize
	aldy = (gRegion[sri][2] - (gbHigh/2))*gSize
	alderaan= Planet():setPosition(aldx,aldy):setPlanetRadius(3000):setDistanceFromMovementPlane(-2000):setCallSign("Alderaan")
	alderaan:setPlanetSurfaceTexture("planets/planet-1.png"):setPlanetCloudTexture("planets/clouds-1.png")
	alderaan:setPlanetAtmosphereTexture("planets/atmosphere.png"):setPlanetAtmosphereColor(0.2,0.2,1.0)
	alderaan:setAxialRotationTime(400.0):setDescription(_("scienceDescription-planet", "Lush planet with only mild seasonal variations"))
	stationAnet = SpaceStation():setTemplate("Small Station"):setFaction("Independent")
	stationAnet:setPosition(aldx,aldy+3000):setCallSign("ANet"):setDescription(_("scienceDescription-station", "Alderaan communications network hub"))
	stationAnet.angle = 90
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	--place independent stations
	stationFaction = "Independent"
	fb = gp	--set faction boundary (between friendly and neutral)
	for j=1,30 do
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
		pStation = placeDHStation(psx,psy,"RandomHumanNeutral","Independent")
		table.insert(stationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--insert a black hole
	tSize = 7
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
		if random(1,5) >= 2 then
			adjList = getAllAdjacentGridLocations(gx,gy)
		end
	end
	sri = math.random(1,#gRegion)
	bhx = (gRegion[sri][1] - (gbHigh/2))*gSize
	bhy = (gRegion[sri][2] - (gbHigh/2))*gSize
	BlackHole():setPosition(bhx,bhy)
	gp = gp + 1
	rn = math.random(1,#adjList)
	gx = adjList[rn][1]
	gy = adjList[rn][2]
	--place enemy stations (from generic pool)
	stationFaction = "Kraylor"
	fb = gp	--set faction boundary (between neutral and enemy)
	for j=1,5 do
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
		pStation = placeDHStation(psx,psy,"RandomGenericSinister","Kraylor")
		if diagnostic then
			pStation:setCallSign(pStation:getCallSign() .. string.format(" %i",j))
		end
		table.insert(enemyStationList,pStation)
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--place enemy stations (from enemy pool)
	stationFaction = "Kraylor"
	fb = gp	--set faction boundary (between enemy and enemy leadership)
	for j=1,2 do
		tSize = math.random(4,6)	--tack on to region size
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
		pStation = placeDHStation(psx,psy,"Sinister","Kraylor")
		table.insert(enemyStationList,pStation)
		if j == 2 then					--identify last placed enemy station as target enemy station
			targetEnemyStation = pStation
			if diagnostic then
				pStation:setCallSign(pStation:getCallSign() .. " Target")
			end
		end
		gp = gp + 1						--set next station number
		rn = math.random(1,#adjList)	--random next station start location
		gx = adjList[rn][1]
		gy = adjList[rn][2]
	end
	--show adjacent list with a bunch of small stations for testing result purposes
	--[[--
	if #adjList >= 1 then
		for i=1,#adjList do
			tsix = adjList[i][1]
			tsiy = adjList[i][2]
			tsx = (tsix - 250)*gSize
			tsy = (tsiy - 250)*gSize
			SpaceStation():setTemplate("Small Station"):setCallSign(string.format("%i i:%i x:%i y:%i",sPool,i,tsix,tsiy)):setPosition(tsx,tsy)
		end
	end
	--]]--
	if not diagnostic then
		--placeRandomAroundPoint(Nebula,math.random(10,30),1,150000,0,0)
		local nebula_count = math.random(10,30)
		local nebula_list = placeRandomListAroundPoint(Nebula,nebula_count,1,150000,0,0)
		local nebula_index = 0
		for i=1,#nebula_list do
			nebula_list[i].lose = false
			nebula_list[i].gain = false
		end
		coolant_nebula = {}
		for i=1,math.random(math.floor(nebula_count/2)) do
			nebula_index = math.random(1,#nebula_list)
			table.insert(coolant_nebula,nebula_list[nebula_index])
			table.remove(nebula_list,nebula_index)
			if math.random(1,100) < 50 then
				coolant_nebula[#coolant_nebula].lose = true
			else
				coolant_nebula[#coolant_nebula].gain = true
			end
		end
		nebula_list = {}
		for i=1,#movingNebulae do
			movingNebulae[i].lose = false
			movingNebulae[i].gain = false
			table.insert(nebula_list,movingNebulae[i])
		end
		for i=1,math.random(math.floor(#nebula_list/2)) do
			nebula_index = math.random(1,#nebula_list)
			table.insert(coolant_nebula,nebula_list[nebula_index])
			table.remove(nebula_list,nebula_index)
			if math.random(1,100) < 50 then
				coolant_nebula[#coolant_nebula].lose = true
			else
				coolant_nebula[#coolant_nebula].gain = true
			end
		end
	end
	fx, fy = homeStation:getPosition()
	ex, ey = targetEnemyStation:getPosition()
	mid_neb_x = (fx+ex)/2	--midpoint between home station and target enemy station x coordinate
	mid_neb_y = (fy+ey)/2	--midpoint between home station and target enemy station y coordinate
	Nebula():setPosition(mid_neb_x,mid_neb_y)
	startingFriendlyStations = #friendlyStationList
	startingNeutralStations = #stationList - #friendlyStationList
	startingEnemyStations = #enemyStationList
	originalStationList = stationList	--save for statistics
end
function placeDHStation(x,y,name,faction,size)
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
	station.comms_data.system_repair = {}
	station.comms_data.coolant_pump_repair = {}
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
----------------------------------------------
--	Transport ship generation and handling  --
----------------------------------------------
function randomStation()
	local clean_list = true
	repeat
		clean_list = true
		for i,station in ipairs(stationList) do
			if station == nil or not station:isValid() then
				stationList[i] = stationList[#stationList]
				stationList[#stationList] = nil
				clean_list = false
				break
			end
		end
	until(clean_list)
	sidx = math.random(1,#stationList)
	return stationList[sidx]
end
function nearStations(station, compareStationList)
	local remainingStations = {}
	local closest = nil
	if station:isValid() then
		if compareStationList[1]:isValid() then
			if station:getCallSign() ~= compareStationList[1]:getCallSign() then
				closest = compareStationList[1]
			else
				if compareStationList[2]:isValid() then
					closest = compareStationList[2]
				end
			end
		end
		for ri, obj in ipairs(compareStationList) do
			if obj:isValid() then
				if station:getCallSign() ~= obj:getCallSign() then
					table.insert(remainingStations,obj)
					if closest ~= nil and closest:isValid() then
						if distance(station,obj) < distance(station,closest) then
							closest = obj
						end
					end
				end
			else
				table.remove(compareStationList,ri)
			end
		end
		for ri, obj in ipairs(remainingStations) do
			if obj:getCallSign() == closest:getCallSign() then
				table.remove(remainingStations,ri)
			end
		end
	end
	return closest, remainingStations
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
	return distanceStations[irandom(1,5)]
end
function transportPlot(delta)
	if transportSpawnDelay > 0 then
		transportSpawnDelay = transportSpawnDelay - delta
	end
	if transportSpawnDelay < 0 then
		transportSpawnDelay = delta + random(5,15) + missionLength
		transportCount = 0
		for tidx, obj in ipairs(transportList) do
			if obj:isValid() then
				if obj:isDocked(obj.target) then
					if obj.undock_delay > 0 then
						obj.undock_delay = obj.undock_delay - 1
					else
						obj.target = randomNearStation5(obj)
						obj.undock_delay = irandom(1,4)
						obj:orderDock(obj.target)
					end
				end
				transportCount = transportCount + 1
			end
		end
		lastTransportCount = transportCount
		if transportCount < #transportList then
			tempTransportList = {}
			for _, obj in ipairs(transportList) do
				if obj:isValid() then
					table.insert(tempTransportList,obj)
				end
			end
			transportList = tempTransportList
		end
		if #transportList < #stationList then
			repeat
				target = randomStation()				
			until(target ~= nil)
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
			obj:setCallSign(generateCallSign(nil,"Independent"))
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
			table.insert(transportList, obj)
		end
	end
end
-----------------------------
--  Station communication  --
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
            preorder = "friend"
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
	local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
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
						if math.random(1,10) <= 5 then
							minePrompt = _("ammo-comms", "We could use some mines. (")
						else
							minePrompt = _("ammo-comms", "How about mines? (")
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
	addCommsReply(_("stationServices-comms", "Docking services status"), function()
		local service_status = string.format(_("stationServices-comms", "Station %s docking services status:"),comms_target:getCallSign())
		if comms_target:getRestocksScanProbes() then
			service_status = string.format(_("stationServices-comms", "%s\nReplenish scan probes."),service_status)
		else
			if comms_target.probe_fail_reason == nil then
				local reason_list = {
					_("stationServices-comms", "Cannot replenish scan probes due to fabrication unit failure."),
					_("stationServices-comms", "Parts shortage prevents scan probe replenishment."),
					_("stationServices-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
				}
				comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format(_("stationServices-comms", "%s\n%s"),service_status,comms_target.probe_fail_reason)
		end
		if comms_target:getRepairDocked() then
			service_status = string.format(_("stationServices-comms", "%s\nShip hull repair."),service_status)
		else
			if comms_target.repair_fail_reason == nil then
				reason_list = {
					_("stationServices-comms", "We're out of the necessary materials and supplies for hull repair."),
					_("stationServices-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
					_("stationServices-comms", "All hull repair technicians quarantined to quarters due to illness."),
				}
				comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format(_("stationServices-comms", "%s\n%s"),service_status,comms_target.repair_fail_reason)
		end
		if comms_target:getSharesEnergyWithDocked() then
			service_status = string.format(_("stationServices-comms", "%s\nRecharge ship energy stores."),service_status)
		else
			if comms_target.energy_fail_reason == nil then
				reason_list = {
					_("stationServices-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
					_("stationServices-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
					_("stationServices-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
				}
				comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
			end
			service_status = string.format(_("stationServices-comms", "%s\n%s"),service_status,comms_target.energy_fail_reason)
		end
		if comms_target.comms_data.jump_overcharge then
			service_status = string.format(_("stationServices-comms", "%s\nMay overcharge jump drive"),service_status)
		end
		if comms_target.comms_data.probe_launch_repair then
			service_status = string.format(_("stationServices-comms", "%s\nMay repair probe launch system"),service_status)
		end
		if comms_target.comms_data.hack_repair then
			service_status = string.format(_("stationServices-comms", "%s\nMay repair hacking system"),service_status)
		end
		if comms_target.comms_data.scan_repair then
			service_status = string.format(_("stationServices-comms", "%s\nMay repair scanners"),service_status)
		end
		if comms_target.comms_data.combat_maneuver_repair then
			service_status = string.format(_("stationServices-comms", "%s\nMay repair combat maneuver"),service_status)
		end
		if comms_target.comms_data.self_destruct_repair then
			service_status = string.format(_("stationServices-comms", "%s\nMay repair self destruct system"),service_status)
		end
		setCommsMessage(service_status)
		addCommsReply(_("Back"), commsStation)
	end)
	if comms_target.comms_data.jump_overcharge then
		if comms_source:hasJumpDrive() then
			local max_charge = comms_source.max_jump_range
			if max_charge == nil then
				max_charge = 50000
			end
			if comms_source:getJumpDriveCharge() >= max_charge then
				addCommsReply(_("stationServices-comms", "Overcharge Jump Drive (10 Rep)"),function()
					if comms_source:takeReputationPoints(10) then
						comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
						setCommsMessage(string.format(_("stationServices-comms", "Your jump drive has been overcharged to %ik"),math.floor(comms_source:getJumpDriveCharge()/1000)))
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
	end
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
	if offer_repair then
		addCommsReply(_("stationServices-comms", "Repair ship system"),function()
			setCommsMessage(_("stationServices-comms", "What system would you like repaired?"))
			if comms_target.comms_data.probe_launch_repair then
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(_("stationServices-comms", "Repair probe launch system (5 Rep)"),function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage(_("stationServices-comms", "Your probe launch system has been repaired"))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.hack_repair then
				if not comms_source:getCanHack() then
					addCommsReply(_("stationServices-comms", "Repair hacking system (5 Rep)"),function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanHack(true)
							setCommsMessage(_("stationServices-comms", "Your hack system has been repaired"))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.scan_repair then
				if not comms_source:getCanScan() then
					addCommsReply(_("stationServices-comms", "Repair scanners (5 Rep)"),function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanScan(true)
							setCommsMessage(_("stationServices-comms", "Your scanners have been repaired"))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.combat_maneuver_repair then
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(_("stationServices-comms", "Repair combat maneuver (5 Rep)"),function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage(_("stationServices-comms", "Your combat maneuver has been repaired"))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			if comms_target.comms_data.self_destruct_repair then
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(_("stationServices-comms", "Repair self destruct system (5 Rep)"),function()
						if comms_source:takeReputationPoints(5) then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage(_("stationServices-comms", "Your self destruct system has been repaired"))
						else
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
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
		if math.random(1,5) <= (3 - difficulty) then
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
		if comms_source.initialCoolant ~= nil then
			if math.random(1,5) <= (3 - difficulty) then
				local coolantCost = math.random(45,90)
				if comms_source:getMaxCoolant() < comms_source.initialCoolant then
					coolantCost = math.random(30,60)
				end
				addCommsReply(string.format(_("trade-comms", "Purchase coolant for %i reputation"),coolantCost), function()
					if not comms_source:takeReputationPoints(coolantCost) then
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					else
						comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
						setCommsMessage(_("trade-comms", "Additional coolant purchased"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
	else
		if math.random(1,5) <= (3 - difficulty) then
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
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	if comms_target == homeStation then
		if homeStation.telemetry == nil then
			if math.random(1,10) <= (5 - difficulty) then
				addCommsReply(string.format(_("defTelemetry-comms", "Establish defensive system telemetry (%i rep)"),difficulty*10), function()
					if comms_source:takeReputationPoints(difficulty*10) then
						setCommsMessage(string.format(_("defTelemetry-comms", "Defensive telemetry established with station %s.\nDamage should show on Relay when it occurs"),homeStation:getCallSign()))
						homeStation.telemetry = true
					else
						setCommsMessage(_("needRep-comms", "Insufficient reputation"))
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		if homeDelivery then
			if plot2name == "easyDelivery" or plot4name == "randomDelivery" then
				local easyCargoAboard = false
				local randomCargoAboard = false
				if comms_source.goods ~= nil and comms_source.goods[easyDeliverGood] ~= nil and comms_source.goods[easyDeliverGood] > 0 then
					easyCargoAboard = true
				end
				if comms_source.goods ~= nil and comms_source.goods[randomDeliverGood] ~= nil and comms_source.goods[randomDeliverGood] > 0 then
					randomCargoAboard = true
				end
				if easyCargoAboard or randomCargoAboard then
					addCommsReply(_("-comms", "Provide cargo"), function()
						setCommsMessage(_("-comms", "Do you have something for us?"))
						if easyCargoAboard then
							homeStationEasyDelivery()					
						end
						if randomCargoAboard then
							homeStationRandomDelivery()
						end
					end)
				end
			end
		end
		if infoPromised then
			if spinUpgradeAvailable or beamTimeUpgradeAvailable or rotateUpgradeAvailable or baseIntelligenceAvailable or hullUpgradeAvailable then
				addCommsReply(_("upgrade-comms", "Request promised information"), function()
					setCommsMessage(_("upgrade-comms", "Remind me what information I promised"))
					if spinUpgradeAvailable then
						homeStationSpinUpgrade()
					end
					if beamTimeUpgradeAvailable then
						homeStationBeamTimeUpgrade()
					end
					if rotateUpgradeAvailable then
						homeStationRotateUpgrade()
					end
					if baseIntelligenceAvailable then
						homeStationBaseIntelligence()
					end
					if hullUpgradeAvailable then
						homeStationHullUpgrade()
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
	end
	if comms_target == spinBase then
		spinStation()
	end
	if comms_target == beamTimeBase then
		beamTimeStation()
	end
	if comms_target == rotateBase then
		rotateStation()
	end
	if comms_target == baseInt1 then
		intelligenceStation()
	end
	if comms_target == baseInt2 then
		secondIntelligenceStation()
	end
	if comms_target == hullBase then
		hullStation()
	end
	if comms_target == shieldExpertStation then
		shieldExpertBase()
	end
	local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
	if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
		(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
		(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
		addCommsReply(_("station-comms", "Tell me more about your station"), function()
			setCommsMessage(_("station-comms", "What would you like to know?"))
			if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
				addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
					setCommsMessage(comms_target.comms_data.general_information)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
				addCommsReply(_("stationStory-comms", "Station history"), function()
					setCommsMessage(comms_target.comms_data.history)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			if comms_source:isFriendly(comms_target) then
				if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
					if random(1,100) < 50 then
						addCommsReply(_("gossip-comms", "Gossip"), function()
							setCommsMessage(comms_target.comms_data.gossip)
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
		end)
	end
	local goodCount = 0
	for good, goodData in pairs(comms_target.comms_data.goods) do
		goodCount = goodCount + 1
	end
	if goodCount > 0 then
		addCommsReply(_("trade-comms", "Buy, sell, trade"), function()
			local goodsReport = string.format(_("trade-comms", "Station %s:\nGoods or components available for sale: quantity, cost in reputation\n"),comms_target:getCallSign())
			for good, goodData in pairs(comms_target.comms_data.goods) do
				goodsReport = goodsReport .. string.format(_("trade-comms", "     %s: %i, %i\n"),good,goodData["quantity"],goodData["cost"])
			end
			if comms_target.comms_data.buy ~= nil then
				goodsReport = goodsReport .. _("trade-comms", "Goods or components station will buy: price in reputation\n")
				for good, price in pairs(comms_target.comms_data.buy) do
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
			for good, goodData in pairs(comms_target.comms_data.goods) do
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
			if comms_target.comms_data.buy ~= nil then
				for good, price in pairs(comms_target.comms_data.buy) do
					if comms_source.goods ~= nil and comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
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
			if comms_target.comms_data.trade ~= nil and
				comms_target.comms_data.trade.food ~= nil and
				comms_target.comms_data.trade.food and 
				comms_source.goods ~= nil and 
				comms_source.goods.food ~= nil and 
				comms_source.goods.food > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
			if comms_target.comms_data.trade ~= nil and 
				comms_target.comms_data.trade.medicine ~= nil and 
				comms_target.comms_data.trade.medicine and 
				comms_source.goods ~= nil and 
				comms_source.goods.medicine ~= nil and 
				comms_source.goods.medicine > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
			if comms_target.comms_data.trade ~= nil and
				comms_target.comms_data.trade.luxury ~= nil and
				comms_target.comms_data.trade.luxury and 
				comms_source.goods ~= nil and 
				comms_source.goods.luxury ~= nil and 
				comms_source.goods.luxury > 0 then
				for good, goodData in pairs(comms_target.comms_data.goods) do
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
function homeStationEasyDelivery()
	addCommsReply(string.format(_("trade-comms", "Provide %s as requested"),easyDeliverGood), function()
		comms_source.goods[easyDeliverGood] = comms_source.goods[easyDeliverGood] - 1
		comms_source.cargo = comms_source.cargo + 1
		comms_source:addReputationPoints(30)
		setCommsMessage(_("trade-comms", "Thanks, we really needed that.\n\nI have some information for you. Decide which one you want"))
		addCommsReply(_("upgrade-comms", "Ship maneuver upgrade"), function()
			plot2 = spinUpgradeStart
			setCommsMessage(_("upgrade-comms", "Check back shortly and I'll tell you all about it"))
		end)
		addCommsReply(_("intelligence-comms", "Intelligence"), function()
			plot2 = enemyBaseInfoStart
			setCommsMessage(_("upgrade-comms", "Check back shortly and I'll tell you all about it"))
		end)
	end)
end
function homeStationRandomDelivery()
	addCommsReply(string.format(_("upgrade-comms", "Give %s as requested"),randomDeliverGood), function()
		comms_source.goods[randomDeliverGood] = comms_source.goods[randomDeliverGood] - 1
		comms_source.cargo = comms_source.cargo + 1
		comms_source:addReputationPoints(35)
		setCommsMessage(string.format(_("upgrade-comms", "Thanks, we needed that %s.\n\nI have information for you. Decide which one you want"),randomDeliverGood))
		addCommsReply(string.format(_("upgrade-comms", "Upgrade %s to auto-rotate"),homeStation:getCallSign()), function()
			plot4 = rotateUpgradeStart
			setCommsMessage(_("upgrade-comms", "Check back in a bit and I'll tell you all about it"))
		end)
		addCommsReply(_("upgrade-comms", "Upgrade beam weapon cycle time"), function()
			plot4 = beamTimeUpgradeStart
			setCommsMessage(_("upgrade-comms", "Check back in a bit and I'll tell you all about it"))
		end)
		addCommsReply(_("upgrade-comms", "Upgrade hull damage capacity"), function()
			plot4 = hullUpgradeStart
			setCommsMessage(_("upgrade-comms", "Check back in a bit and I'll tell you all about it"))
		end)
	end)
end
function homeStationSpinUpgrade()
	addCommsReply(_("upgrade-comms", "What about that maneuver upgrade information you promised?"), function()
		setCommsMessage(string.format(_("upgrade-comms", "I hear %s can upgrade your maneuverability, but they need %s to do the job"),spinBase:getCallSign(),spinGood))
		if spinReveal < 1 then spinReveal = 1 end
		addCommsReply(string.format(_("upgrade-comms", "Where is %s?"),spinBase:getCallSign()), function()
			setCommsMessage(string.format(_("upgrade-comms", "%s is in sector %s"),spinBase:getCallSign(),spinBase:getSectorName()))
			if spinReveal < 2 then spinReveal = 2 end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(string.format(_("upgrade-comms", "Where might I find some %s?"),spinGood), function()
			setCommsMessage(string.format(_("upgrade-comms", "I think %s might have some"),spinGoodBase:getCallSign()))
			if spinReveal < 3 then spinReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format(_("upgrade-comms", "And where the heck is %s?"),spinGoodBase:getCallSign()), function()
					setCommsMessage(string.format(_("upgrade-comms", "My, my, you're quite inquisitive.\n%s is in sector %s"),spinGoodBase:getCallSign(),spinGoodBase:getSectorName()))
					if spinReveal < 4 then spinReveal = 4 end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)
end
function homeStationBeamTimeUpgrade()
	addCommsReply(_("upgrade-comms", "You mentioned a beam weapon cycle time upgrade..."), function()
		setCommsMessage(string.format(_("upgrade-comms", "Station %s can do that for %s"),beamTimeBase:getCallSign(),beamTimeGood))
		if beamTimeReveal < 1 then beamTimeReveal = 1 end
		addCommsReply(string.format(_("upgrade-comms", "I've never heard of %s. Where is %s?"),beamTimeBase:getCallSign(),beamTimeBase:getCallSign()), function()
			setCommsMessage(string.format(_("upgrade-comms", "You haven't? I'm surprised. %s is in %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName()))
			if beamTimeReveal < 2 then beamTimeReveal = 2 end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(string.format(_("upgrade-comms", "Can you direct me to a station with %s?"),beamTimeGood), function()
			setCommsMessage(string.format(_("upgrade-comms", "%s has %s *and* they have the best indigenous Kraylor honey you've ever tasted"),beamTimeGoodBase:getCallSign(),beamTimeGood))
			if beamTimeReveal < 3 then beamTimeReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format(_("upgrade-comms", "Sounds tasty. Where is %s?"),beamTimeGoodBase:getCallSign()), function()
					setCommsMessage(string.format(_("upgrade-comms", "It's in %s"),beamTimeGoodBase:getSectorName()))
					if beamTimeReveal < 4 then beamTimeReveal = 4 end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)
end
function homeStationRotateUpgrade()
	addCommsReply(_("upgrade-comms", "Where's that station rotation upgrade information?"), function()
		setCommsMessage(string.format(_("upgrade-comms", "station %s has the technical knowledge but lacks the %s"),rotateBase:getCallSign(),rotateGood))
		if rotateReveal < 1 then rotateReveal = 1 end
		addCommsReply(string.format(_("upgrade-comms", "Where is station %s?"),rotateBase:getCallSign()), function()
			setCommsMessage(string.format(_("upgrade-comms", "%s is in %s"),rotateBase:getCallSign(),rotateBase:getSectorName()))
			if rotateReveal < 2 then rotateReveal = 2 end
			addCommsReply(_("Back"), commsStation)
		end)
		if difficulty < 2 then
			addCommsReply(string.format(_("upgrade-comms", "Where could I get %s?"),rotateGood), function()
				setCommsMessage(string.format(_("upgrade-comms", "%s should have %s"),rotateGoodBase:getCallSign(),rotateGood))
				if rotateReveal < 3 then rotateReveal = 3 end
				if difficulty < 1 then
					addCommsReply(string.format(_("upgrade-comms", "Do you know where %s is located?"),rotateGoodBase:getCallSign()), function()
						setCommsMessage(string.format(_("upgrade-comms", "Yes, it's in %s"),rotateGoodBase:getSectorName()))
						if rotateReveal < 4 then rotateReveal = 4 end
						addCommsReply(_("Back"), commsStation)
					end)
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function homeStationBaseIntelligence()
	addCommsReply(_("intelligence-comms", "What about that intelligence information you promised?"), function()
		setCommsMessage(string.format(_("intelligence-comms", "I hear Marcy Sorenson just got back from an enemy scouting expedition. She was talking about enemy bases. She can probably tell you where some of these bases are located. She's based on %s"),baseInt1:getCallSign()))
		plot2reminder = string.format(_("intelligence-comms", "Talk with Marcy Sorenson on %s"),baseInt1:getCallSign())
		addCommsReply(_("Back"), commsStation)
	end)
end
function homeStationHullUpgrade()
	addCommsReply(_("upgrade-comms", "Remember, you promised some ship hull upgrade information?"), function()
		setCommsMessage(string.format(_("upgrade-comms", "Oh yes, %s can upgrade your hull, but they want %s to do the job"),hullBase:getCallSign(),hullGood))
		if hullReveal < 1 then hullReveal = 1 end
		addCommsReply(string.format(_("upgrade-comms", "So, where is %s?"),hullBase:getCallSign()), function()
			setCommsMessage(string.format(_("upgrade-comms", "%s is in sector %s"),hullBase:getCallSign(),hullBase:getSectorName()))
			if hullReveal < 2 then hullReveal = 2 end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(string.format(_("upgrade-comms", "Where could I find some %s?"),hullGood), function()
			setCommsMessage(string.format(_("upgrade-comms", "I think %s may have some"),hullGoodBase:getCallSign()))
			if hullReveal < 3 then hullReveal = 3 end
			if difficulty < 2 then
				addCommsReply(string.format(_("upgrade-comms", "And just where is %s?"),hullGoodBase:getCallSign()), function()
					setCommsMessage(string.format(_("upgrade-comms", "If you must know, %s is in sector %s"),hullGoodBase:getCallSign(),hullGoodBase:getSectorName()))
					if hullReveal < 4 then hullReveal = 4 end
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("Back"), commsStation)
	end)
end
function spinStation()
	if spinUpgradeAvailable then
		if not comms_source.spinUpgrade then
			addCommsReply(_("upgrade-comms", "Upgrade maneuverability"), function()
				local spinUpgradePartQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[spinGood] ~= nil and comms_source.goods[spinGood] > 0 then
					spinUpgradePartQuantity = comms_source.goods[spinGood]
				end
				if spinUpgradePartQuantity > 0 then
					comms_source.spinUpgrade = true
					comms_source.goods[spinGood] = comms_source.goods[spinGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.5)
					setCommsMessage(_("upgrade-comms", "Upgraded maneuverability"))
				else
					setCommsMessage(string.format(_("upgrade-comms", "You need to bring some %s for the upgrade"),spinGood))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
end
function beamTimeStation()
	if beamTimeUpgradeAvailable then
		if not comms_source.beamTimeUpgrade then
			addCommsReply(_("upgrade-comms", "Upgrade beam cycle time"), function()
				if comms_source:getBeamWeaponRange(0) < 1 then
					setCommsMessage(_("upgrade-comms", "Your ship type does not support a beam weapon upgrade."))
				else
					local beamTimeUpgradePartQuantity = 0
					if comms_source.goods ~= nil and comms_source.goods[beamTimeGood] ~= nil and comms_source.goods[beamTimeGood] > 0 then
						beamTimeUpgradePartQuantity = comms_source.goods[beamTimeGood]
					end
					if beamTimeUpgradePartQuantity > 0 then
						comms_source.beamTimeUpgrade = true
						comms_source.goods[beamTimeGood] = comms_source.goods[beamTimeGood] - 1
						comms_source.cargo = comms_source.cargo + 1
						local bi = 0
						repeat
							local tempArc = comms_source:getBeamWeaponArc(bi)
							local tempDir = comms_source:getBeamWeaponDirection(bi)
							local tempRng = comms_source:getBeamWeaponRange(bi)
							local tempCyc = comms_source:getBeamWeaponCycleTime(bi)
							local tempDmg = comms_source:getBeamWeaponDamage(bi)
							comms_source:setBeamWeapon(bi,tempArc,tempDir,tempRng,tempCyc * .8,tempDmg)
							bi = bi + 1
						until(comms_source:getBeamWeaponRange(bi) < 1)
						setCommsMessage(_("upgrade-comms", "Beam cycle time reduced by 20%"))
					else
						setCommsMessage(string.format(_("upgrade-comms", "We require %s before we can upgrade your beam weapons"),beamTimeGood))
					end
				end
			end)
		end
	end
end
function rotateStation()
	if rotateUpgradeAvailable then
		if not homeStationRotationEnabled then
			addCommsReply(string.format(_("upgrade-comms", "Upgrade %s to auto-rotate"),homeStation:getCallSign()), function()
				local rotateUpgradePartQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[rotateGood] ~= nil and comms_source.goods[rotateGood] > 0 then
					rotateUpgradePartQuantity = comms_source.goods[rotateGood]
				end
				if rotateUpgradePartQuantity > 0 then
					homeStationRotationEnabled = true
					comms_source.goods[rotateGood] = comms_source.goods[rotateGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					setCommsMessage(string.format(_("upgrade-comms", "%s was just what we needed. The technical details have been transmitted to %s. The auto-rotation has begun"),rotateGood,homeStation:getCallSign()))
					plot4reminder = nil
				else
					setCommsMessage(string.format(_("upgrade-comms", "You need to bring some %s for the upgrade"),rotateGood))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
end
function intelligenceStation()
	addCommsReply(_("intelligence-comms", "May I speak with Marcy Sorenson?"), function()
		baseInt1Visit = true
		if baseInt2 ~= nil then
			setCommsMessage(string.format(_("intelligence-comms", "She transferred to %s"),baseInt2:getCallSign()))
			plot2reminder = string.format(_("intelligence-comms", "Talk with Marcy Sorenson on %s"),baseInt2:getCallSign())
			addCommsReply(string.format(_("intelligence-comms", "Where exactly is %s?"),baseInt2:getCallSign()), function()
				setCommsMessage(string.format(_("intelligence-comms", "%s is in %s"),baseInt2:getCallSign(),baseInt2:getSectorName()))
				plot2reminder = string.format(_("intelligence-comms", "Talk with Marcy Sorenson on %s in %s"),baseInt2:getCallSign(),baseInt2:getSectorName())
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		else
			setCommsMessage(_("intelligence-comms", "This is Marcy. Whatcha want?"))
			addCommsReply(_("intelligence-comms", "Please tell me about the enemy bases found"), function()
				for i=1,#enemyStationList do
					if enemyStationList[i]:isValid() then
						if enemyInt1 == nil then
							enemyInt1 = enemyStationList[i]
						elseif enemyInt2 == nil then
							enemyInt2 = enemyStationList[i]
							break
						end
					end
				end
				setCommsMessage(string.format(_("intelligence-comms", "Sure. We found a couple of enemy stations in %s and %s"),enemyInt1:getSectorName(),enemyInt2:getSectorName()))
				plot2reminder = string.format(_("intelligence-comms", "Investigate enemy bases in %s and %s"),enemyInt1:getSectorName(),enemyInt2:getSectorName())
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end
	end)
end
function secondIntelligenceStation()
	if baseInt1Visit then
		addCommsReply(_("intelligence-comms", "May I speak with Marcy Sorenson, please?"), function()
			setCommsMessage(_("intelligence-comms", "This is Marcy. Whatcha want?"))
			addCommsReply(_("intelligence-comms", "Please tell me about the enemy bases found"), function()
				for i=1,#enemyStationList do
					if enemyStationList[i]:isValid() then
						if enemyInt1 == nil then
							enemyInt1 = enemyStationList[i]
						elseif enemyInt2 == nil then
							enemyInt2 = enemyStationList[i]
						elseif enemyInt3 == nil then
							enemyInt3 = enemyStationList[i]
						end
					end
				end
				setCommsMessage(string.format(_("intelligence-comms", "Sure. We found some enemy stations in %s, %s and %s"),enemyInt1:getSectorName(),enemyInt2:getSectorName(),enemyInt3:getSectorName()))
				plot2reminder = string.format(_("intelligence-comms", "Investigate enemy bases in %s, %s and %s"),enemyInt1:getSectorName(),enemyInt2:getSectorName(),enemyInt3:getSectorName())
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)				
		end)
	end
end
function hullStation()
	if hullUpgradeAvailable then
		if not comms_source.hullUpgrade then
			addCommsReply(_("upgrade-comms", "Upgrade hull damage capacity"), function()
				local hullUpgradePartQuantity = 0
				if comms_source.goods ~= nil and comms_source.goods[hullGood] ~= nil and comms_source.goods[hullGood] > 0 then
					hullUpgradePartQuantity = comms_source.goods[hullGood]
				end
				if hullUpgradePartQuantity > 0 then
					comms_source.hullUpgrade = true
					comms_source.goods[hullGood] = comms_source.goods[hullGood] - 1
					comms_source.cargo = comms_source.cargo + 1
					comms_source:setHullMax(comms_source:getHullMax() * 1.2)
					setCommsMessage(_("upgrade-comms", "Upgraded hull capacity for damage by 20%"))
				else
					setCommsMessage(string.format(_("upgrade-comms", "We won't upgrade your hull until we have %s"),hullGood))
				end
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
end
function shieldExpertBase()
	if plot4 == giftForBeau then
		addCommsReply(_("Maria-comms", "Offer gift on behalf of Maria Shrivner"), function()
			local giftQuantity = 0
			local giftList = {}
			if comms_source.goods ~= nil then
				if comms_source.goods["gold"] ~= nil and comms_source.goods["gold"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["gold"]
					table.insert(giftList,"gold")
				end
				if comms_source.goods["platinum"] ~= nil and comms_source.goods["platinum"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["platinum"]
					table.insert(giftList,"platinum")
				end
				if comms_source.goods["dilithium"] ~= nil and comms_source.goods["dilithium"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["dilithium"]
					table.insert(giftList,"dilithium")
				end
				if comms_source.goods["tritanium"] ~= nil and comms_source.goods["tritanium"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["tritanium"]
					table.insert(giftList,"tritanium")
				end
				if comms_source.goods["cobalt"] ~= nil and comms_source.goods["cobalt"] > 0 then
					giftQuantity = giftQuantity + comms_source.goods["cobalt"]
					table.insert(giftList,"cobalt")
				end
			end
			if giftQuantity > 0 then
				beauGift = true
				local gifti = math.random(1,#giftList)
				comms_source.goods[giftList[gifti]] = comms_source.goods[giftList[gifti]] - 1
				comms_source.cargo = comms_source.cargo + 1
				setCommsMessage(_("Maria-comms", "Thanks. He's impressed with the gift to such a degree that he's speechless"))
			else
				setCommsMessage(_("Maria-comms", "I know this couple (or former couple). Only gold, platinum, dilithium, tritanium or cobolt will work as a gift"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function setOptionalOrders()
	optionalOrders = ""
	optionalOrdersPresent = false
	if plot2reminder ~= nil then
		if plot2reminder == _("upgradeOrders-comms", "Get ship maneuver upgrade") then
			if spinReveal == 0 then
				optionalOrders = _("upgradeOrders-comms", "\nOptional:\n") .. plot2reminder
			elseif spinReveal == 1 then
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s for %s"),spinBase:getCallSign(),spinGood)
			elseif spinReveal == 2 then
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s"),spinBase:getCallSign(),spinBase:getSectorName(),spinGood)
			elseif spinReveal == 3 then
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s"),spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign())
			else
				optionalOrders = string.format(_("upgradeOrders-comms", "\nOptional:\nGet ship maneuver upgrade from %s in sector %s for %s.\n    You might find %s at %s in sector %s"),spinBase:getCallSign(),spinBase:getSectorName(),spinGood,spinGood,spinGoodBase:getCallSign(),spinGoodBase:getSectorName())
			end
		else
			optionalOrders = _("upgradeOrders-comms", "\nOptional:\n") .. plot2reminder
		end
		optionalOrdersPresent = true
	end
	if plot4reminder ~= nil then
		if optionalOrdersPresent then
			ifs = "\n"
		else
			ifs = _("upgradeOrders-comms", "\nOptional:\n")
			optionalOrdersPresent = true
		end
		if plot4reminder == string.format(_("upgradeOrders-comms", "Upgrade %s to rotate"),homeStation:getCallSign()) then
			if rotateReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif rotateReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign())
			elseif rotateReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s in %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName()) 
			elseif rotateReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s may have %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Upgrade %s to auto-rotate by taking %s to %s in %s.\n    %s in %s may have %s"),homeStation:getCallSign(),rotateGood,rotateBase:getCallSign(),rotateBase:getSectorName(),rotateGoodBase:getCallSign(),rotateGoodBase:getSectorName(),rotateGood)
			end
		elseif plot4reminder == _("upgradeOrders-comms", "Get beam cycle time upgrade") then
			if beamTimeReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif beamTimeReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s for %s"),beamTimeBase:getCallSign(),beamTimeGood)
			elseif beamTimeReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s in %s for %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood)
			elseif beamTimeReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign())
			else
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get beam cycle time upgrade from %s in %s for %s\n    You might find %s at %s in %s"),beamTimeBase:getCallSign(),beamTimeBase:getSectorName(),beamTimeGood,beamTimeGood,beamTimeGoodBase:getCallSign(),beamTimeGoodBase:getSectorName())
			end
		elseif plot4reminder == _("upgradeOrders-comms", "Get hull upgrade") then
			if hullReveal == 0 then
				optionalOrders = optionalOrders .. ifs .. plot4reminder
			elseif hullReveal == 1 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s to upgrade hull for %s"),hullBase:getCallSign(),hullGood)
			elseif hullReveal == 2 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s in %s to upgrade hull for %s"),hullBase:getCallSign(),hullBase:getSectorName(),hullGood)
			elseif hullReveal == 3 then
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s in %s to upgrade hull for %s\n    %s might have %s"),hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGood)
			else
				optionalOrders = optionalOrders .. ifs .. string.format(_("upgradeOrders-comms", "Get %s in %s to upgrade hull for %s\n    %s in %s might have %s"),hullBase:getCallSign(),hullBase:getSectorName(),hullGood,hullGoodBase:getCallSign(),hullGoodBase:getSectorName(),hullGood)
			end
		else
			optionalOrders = optionalOrders .. ifs .. plot4reminder
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
		local goodsAvailable = false
		if comms_target.comms_data.goods ~= nil then
			for good, goodData in pairs(comms_target.comms_data.goods) do
				if goodData["quantity"] > 0 then
					goodsAvailable = true
				end
			end
		end
		if goodsAvailable then
			addCommsReply(_("trade-comms", "What goods do you have available for sale or trade?"), function()
				local goodsAvailableMsg = string.format(_("trade-comms", "Station %s:\nGoods or components available: quantity, cost in reputation"),comms_target:getCallSign())
				for good, goodData in pairs(comms_target.comms_data.goods) do
					goodsAvailableMsg = goodsAvailableMsg .. string.format(_("trade-comms", "\n   %14s: %2i, %3i"),good,goodData["quantity"],goodData["cost"])
				end
				setCommsMessage(goodsAvailableMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("stationServices-comms", "Docking services status"), function()
	 		local ctd = comms_target.comms_data
			local service_status = string.format(_("stationServices-comms", "Station %s docking services status:"),comms_target:getCallSign())
			if comms_target:getRestocksScanProbes() then
				service_status = string.format(_("stationServices-comms", "%s\nReplenish scan probes."),service_status)
			else
				if comms_target.probe_fail_reason == nil then
					local reason_list = {
						_("stationServices-comms", "Cannot replenish scan probes due to fabrication unit failure."),
						_("stationServices-comms", "Parts shortage prevents scan probe replenishment."),
						_("stationServices-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
					}
					comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format(_("stationServices-comms", "%s\n%s"),service_status,comms_target.probe_fail_reason)
			end
			if comms_target:getRepairDocked() then
				service_status = string.format(_("stationServices-comms", "%s\nShip hull repair."),service_status)
			else
				if comms_target.repair_fail_reason == nil then
					reason_list = {
						_("stationServices-comms", "We're out of the necessary materials and supplies for hull repair."),
						_("stationServices-comms", "Hull repair automation unavailable whie it is undergoing maintenance."),
						_("stationServices-comms", "All hull repair technicians quarantined to quarters due to illness."),
					}
					comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format(_("stationServices-comms", "%s\n%s"),service_status,comms_target.repair_fail_reason)
			end
			if comms_target:getSharesEnergyWithDocked() then
				service_status = string.format(_("stationServices-comms", "%s\nRecharge ship energy stores."),service_status)
			else
				if comms_target.energy_fail_reason == nil then
					reason_list = {
						_("stationServices-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
						_("stationServices-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
						_("stationServices-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
					}
					comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
				end
				service_status = string.format(_("stationServices-comms", "%s\n%s"),service_status,comms_target.energy_fail_reason)
			end
			if comms_target.comms_data.jump_overcharge then
				service_status = string.format(_("stationServices-comms", "%s\nMay overcharge jump drive"),service_status)
			end
			if comms_target.comms_data.probe_launch_repair then
				service_status = string.format(_("stationServices-comms", "%s\nMay repair probe launch system"),service_status)
			end
			if comms_target.comms_data.hack_repair then
				service_status = string.format(_("stationServices-comms", "%s\nMay repair hacking system"),service_status)
			end
			if comms_target.comms_data.scan_repair then
				service_status = string.format(_("stationServices-comms", "%s\nMay repair scanners"),service_status)
			end
			if comms_target.comms_data.combat_maneuver_repair then
				service_status = string.format(_("stationServices-comms", "%s\nMay repair combat maneuver"),service_status)
			end
			if comms_target.comms_data.self_destruct_repair then
				service_status = string.format(_("stationServices-comms", "%s\nMay repair self destruct system"),service_status)
			end
			setCommsMessage(service_status)
			addCommsReply(_("Back"), commsStation)
		end)
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
			gkMsg = _("trade-comms", "Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
			if comms_target.comms_data.goodsKnowledge == nil then
				comms_target.comms_data.goodsKnowledge = {}
				local knowledgeCount = 0
				local knowledgeMax = 10
				for i=1,#stationList do
					local station = stationList[i]
					if station ~= nil and station:isValid() then
						local brainCheckChance = 60
						if distance(comms_target,station) > 75000 then
							brainCheckChance = 20
						end
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
					if knowledgeCount >= knowledgeMax then
						break
					end
				end
			end
			local goodsKnowledgeCount = 0
			for good, goodKnowledge in pairs(comms_target.comms_data.goodsKnowledge) do
				goodsKnowledgeCount = goodsKnowledgeCount + 1
				addCommsReply(good, function()
					local stationName = comms_target.comms_data.goodsKnowledge[good]["station"]
					local sectorName = comms_target.comms_data.goodsKnowledge[good]["sector"]
					local goodName = good
					local goodCost = comms_target.comms_data.goodsKnowledge[good]["cost"]
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
		if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
			addCommsReply(_("stationGeneralInfo-comms", "General station information"), function()
				setCommsMessage(comms_target.comms_data.general)
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
	--Diagnostic data is used to help test and debug the script while it is under construction
	if diagnostic then
		addCommsReply("Diagnostic data", function()
			oMsg = string.format("Difficulty: %.1f",difficulty)
			if playWithTimeLimit then
				oMsg = oMsg .. string.format(" Time remaining: %.2f",gameTimeLimit)
			else
				oMsg = oMsg .. " no time limit"
			end
			if plot1name == nil or plot1 == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplot1: " .. plot1name
				oMsg = oMsg .. string.format(" wavetimer: %.2f danger value: %.1f",waveTimer,dangerValue)
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
				oMsg = oMsg .. string.format(" helpful warning timer: %.2f",helpfulWarningTimer)
			end
			if plotWname == nil or plotW == nil then
				oMsg = oMsg .. ""
			else
				oMsg = oMsg .. "\nplotw: " .. plotWname
			end
			if infoPromised then
				oMsg = oMsg .. "\nInfo promised"
				if spinUpgradeAvailable then
					oMsg = oMsg .. ", spin upgrade available"
				end
				if baseIntelligenceAvailable then
					oMsg = oMsg .. ", base intelligence available"
				end
				if hullUpgradeAvailable then
					oMsg = oMsg .. ", hull upgrade available"
				end
				if rotateUpgradeAvailable then
					oMsg = oMsg .. ", rotate upgrade available"
				end
				if beamTimeUpgradeAvailable then
					oMsg = oMsg .. ", beam time upgrade available"
				end
			end
			oMsg = oMsg .. "\nwfv: " .. wfv
			oMsg = oMsg .. string.format("\nSupply drop: %s",comms_target.comms_data.services.supplydrop)
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
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"), comms_source:getWaypointID(n)), function()
                        if comms_source:takeReputationPoints(getServiceCost("supplydrop")) then
                            local position_x, position_y = comms_target:getPosition()
                            local target_x, target_y = comms_source:getWaypoint(n)
                            local script = Script()
                            script:setVariable("position_x", position_x):setVariable("position_y", position_y)
                            script:setVariable("target_x", target_x):setVariable("target_y", target_y)
                            script:setVariable("faction_id", comms_target:getFactionId()):run("supply_drop.lua")
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched a supply ship toward WP %d"), comms_source:getWaypointID(n)));
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
                    addCommsReply(string.format(_("stationAssist-comms", "WP %d"), comms_source:getWaypointID(n)), function()
                        if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
                            ship = CpuShip():setFactionId(comms_target:getFactionId()):setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
                            setCommsMessage(string.format(_("stationAssist-comms", "We have dispatched %s to assist at WP %d"), ship:getCallSign(), comms_source:getWaypointID(n)));
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
function getFriendStatus()
    if comms_source:isFriendly(comms_target) then
        return "friend"
    else
        return "neutral"
    end
end
--------------------------
--  Ship communication  --
--------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	if goods[comms_target] == nil then
		goods[comms_target] = {goodsList[irandom(1,#goodsList)][1], 1, random(20,80)}
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
				addCommsReply(string.format(_("shipAssist-comms", "Defend WP %d"), comms_source:getWaypointID(n)), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms", "We are heading to assist at WP %d."), comms_source:getWaypointID(n)));
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
		if isObjectType(obj,"SpaceStation") and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
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
function neutralComms()
	shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
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
					if comms_source.goods ~= nil and comms_source.goods["luxury"] ~= nil and comms_source.goods["luxury"] > 0 then
						for good, goodData in pairs(comms_target.comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
									goodData.quantity = goodData.quantity - 1
									comms_source.goods["luxury"] = comms_source.goods["luxury"] - 1
									comms_source.goods[good] = comms_source.goods[good] + 1
									setCommsMessage(string.format(_("trade-comms", "Traded luxury for %s"),good))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	
					end
				end
				-- Offer to sell goods
				if comms_source.cargo > 0 then
					if comms_target.comms_data ~= nil and comms_target.comms_data.goods ~= nil then
						for good, good_data in pairs(comms_target.comms_data.goods) do
							if good_data.quantity > 0 then
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(good_data.cost)), function()
									if comms_source:takeReputationPoints(good_data.cost) then
										good_data.quantity = good_data.quantity - 1
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
									addCommsReply(_("Back"), commsShip)
								end)
							end	--some on freighter
						end	--freighter good loop
					end
				end	--room on player ship
			end	--within 5 units
		elseif comms_target.comms_data.friendlyness > 33 then
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
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				else
					-- Offer to sell goods double price
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		else
			setCommsMessage(_("trade-comms", "Why are you bothering me?"))
			-- Offer to sell goods if goods or equipment freighter double price
			if distance(comms_source,comms_target) < 5000 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					gi = 1
					repeat
						local goodsType = goods[comms_target][gi][1]
						local goodsQuantity = goods[comms_target][gi][2]
						local goodsRep = goods[comms_target][gi][3]*2
						addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),goods[comms_target][gi][1],goods[comms_target][gi][3]*2), function()
							if comms_source.cargo < 1 then
								setCommsMessage(_("trade-comms", "Insufficient cargo space for purchase"))
							elseif goodsQuantity < 1 then
								setCommsMessage(_("trade-comms", "Insufficient inventory on freighter"))
							else
								if not comms_source:takeReputationPoints(goodsRep) then
									setCommsMessage(_("needRep-comms", "Insufficient reputation for purchase"))
								else
									comms_source.cargo = comms_source.cargo - 1
									decrementShipGoods(goodsType)
									incrementPlayerGoods(goodsType)
									setCommsMessage(_("trade-comms", "Purchased"))
								end
							end
							addCommsReply(_("Back"), commsShip)
						end)
						gi = gi + 1
					until(gi > #goods[comms_target])
				end
			end
		end
	else
		if comms_target.comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
		else
			setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
		end
	end
	return true
end
------------------------
--  Cargo management  --
------------------------
function incrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_source][gi][1] == goodsType then
			goods[comms_source][gi][2] = goods[comms_source][gi][2] + 1
		end
		gi = gi + 1
	until(gi > #goods[comms_source])
end
function decrementPlayerGoods(goodsType)
	local gi = 1
	repeat
		if goods[comms_source][gi][1] == goodsType then
			goods[comms_source][gi][2] = goods[comms_source][gi][2] - 1
		end
		gi = gi + 1
	until(gi > #goods[comms_source])
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
-----------------------
--  First plot line  --
-----------------------
function initialOrders(delta)
	plot1name = "initialOrders"
	if plot_1_diagnostic then print("plot 1 initial orders") end
	initialOrderTimer = initialOrderTimer - delta
	if initialOrderTimer < 0 then
		if initialOrdersMsg == nil then
			local foundPlayer = false
			local players = getActivePlayerShips()
			for pidx, p in ipairs(players) do
				if p ~= nil and p:isValid() then
					foundPlayer = true
					p:addToShipLog(string.format(_("goalAudio-shipLog", "You are to protect your home base, %s, against enemy attack. Respond to other requests as you see fit"),homeStation:getCallSign()),"Magenta")
					primaryOrders = string.format(_("goal-comms", "Protect %s"),homeStation:getCallSign())
					playSoundFile("audio/scenario/55/sa_55_Commander1.ogg")
				end
			end
			if foundPlayer then
				initialOrdersMsg = "sent"
				plot1 = setEnemyDefenseFleet
			end
		end
	end
end
function setEnemyDefenseFleet(delta)
	plot1name = "setEnemyDefenseFleet"
	if plot_1_diagnostic then print("plot 1 set enemy defense fleet") end
	if enemyDefenseFleets == nil then
		enemyDefenseFleets = "set"
		for i=1,#enemyStationList do
			local defx, defy = enemyStationList[i]:getPosition()
			local ntf = spawnEnemies(defx,defy,1.5,enemyStationList[i]:getFaction())
			for _, enemy in ipairs(ntf) do
				enemy:orderDefendTarget(enemyStationList[i])
			end
		end
		plot1 = threadedPursuit
	end
end
function threadedPursuit(delta)
	plot1name = "threadedPursuit"
	if plot_1_diagnostic then print("plot 1 threaded pursuit") end
	local p = closestPlayerTo(targetEnemyStation)
	if ef2 == nil then
		if p == nil then
			return
		end
		local scx, scy = p:getPosition()
		local cpx, cpy = vectorFromAngle(random(0,360),random(20000,30000))
		ef2 = spawnEnemies(scx+cpx,scy+cpy,.8)
		for _, enemy in ipairs(ef2) do
			if diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef2")
			end
			enemy:orderFlyTowards(scx,scy)
		end
		plot2 = destroyef2
	end
	if ef3 == nil then
		ef3 = vectorOn(homeStation,.8,random(30000,40000))
		local avg_impulse = 0
		for _, enemy in ipairs(ef3) do
			avg_impulse = avg_impulse + enemy:getImpulseMaxSpeed()
			if plot_1_diagnostic then
				enemy:setCallSign(enemy:getCallSign() .. "ef3")
			end
		end
		avg_impulse = avg_impulse/#ef3
		for _, enemy in ipairs(ef3) do
			enemy:setImpulseMaxSpeed(avg_impulse)
		end
		plot3 = destroyef3
	end
	if ef4 == nil then
		if p == nil then
			return
		end
		scx, scy = p:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(40000,50000))
		ef4 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef4) do
			enemy:orderAttack(p)
		end
		plot4 = destroyef4
	end
	helpfulWarningTimer = 90
	plot5 = helpfulWarning
	waveTimer = interWave
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
	plot1 = pressureWaves
end
function pressureWaves(delta)
	plot1name = "pressureWaves"
	if plot_1_diagnostic then print("plot 1 pressure waves") end
	if not homeStation:isValid() then
		missionVictory = false
		endStatistics()
		victory("Kraylor")
		return
	end
	if not targetEnemyStation:isValid() then
		missionVictory = true
		endStatistics()
		victory("Human Navy")
		return
	end
	waveTimer = waveTimer - delta
	if waveTimer < 0 then
		local esx = nil	--enemy station x coordinate
		local esy = nil	--enemy station y coordinate
		local ntf = nil	--next task fleet
		local p = nil	--player ship
		local px = nil	--player ship x coordinate
		local py = nil	--player ship y coordinate
		local spx = nil	--spawn from player x delta coordinate
		local spy = nil	--spawn from player y delta coordinate
		local hsx = nil	--home station x coordinate
		local hsy = nil	--home station y coordinate
		for i,prod in ipairs(recurring_prods) do
			if getScenarioTime() > prod.time and not prod.used then
				jump_start = true
				prod.used = true
				break
			end
		end
		local lo = 5 + difficulty * 4
		local hi = 500 - difficulty * 100
		local chance = math.max(lo,getPlayerShip(-1):getReputationPoints()/hi*100)
		if jump_start then 
			chance = math.max(chance,50)
		end
		waveSpawned = false
		dangerValue = dangerValue + dangerIncrement
		for i=1,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if random(1,5) <= 2 then
					esx, esy = enemyStationList[i]:getPosition()
					ntf = spawnEnemies(esx,esy,dangerValue,enemyStationList[i]:getFaction())
					waveSpawned = true
					if random(1,5) <= 3 then
						if random(1,100) < chance then
							p = closestPlayerTo(enemyStationList[i])
							if p ~= nil then
								for _, enemy in ipairs(ntf) do
									enemy:orderAttack(p)
								end
							end
						end
					else
						for _, enemy in ipairs(ntf) do
							enemy:orderDefendTarget(enemyStationList[i])
						end
					end
				end
			end
		end
		if random(1,5) <= 2 then
			if random(1,100) < chance then
				ntf = spawnEnemies(mid_neb_x,mid_neb_y,dangerValue,targetEnemyStation:getFaction())
				waveSpawned = true
				if random(1,5) >= 4 then
					for _, enemy in ipairs(ntf) do
						enemy:orderAttack(homeStation)
					end
				end
			end
		end
		if random(1,5) <= 3 then
			if random(1,100) < chance then
				p = closestPlayerTo(targetEnemyStation)
				esx, esy = targetEnemyStation:getPosition()
				px, py = p:getPosition()
				ntf = spawnEnemies((esx+px)/2,(esy+py)/2,dangerValue/2,targetEnemyStation:getFaction())
				waveSpawned = true
				if random(1,5) <= 2 then
					for _, enemy in ipairs(ntf) do
						enemy:orderAttack(p)
					end
				end
			end
		end
		if random(1,5) <= 2 then
			if random(1,100) < chance then
				p = closestPlayerTo(targetEnemyStation)
				px, py = p:getPosition()
				spx, spy = vectorFromAngle(random(0,360), random(30000, 40000))
				ntf = spawnEnemies(px+spx, py+spy, dangerValue/2, targetEnemyStation:getFaction())
				waveSpawned = true
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		if random(1,5) <= 1 then
			if random(1,100) < chance then
				if random(1,5) <= 3 then
					ntf = vectorOn(homeStation,dangerValue,random(30000,40000))
					local avg_impulse = 0
					for _, enemy in ipairs(ntf) do
						avg_impulse = avg_impulse + enemy:getImpulseMaxSpeed()
					end
					avg_impulse = avg_impulse/#ntf
					for _, enemy in ipairs(ntf) do
						enemy:setImpulseMaxSpeed(avg_impulse)
					end
				else
					hsx, hsy = homeStation:getPosition()
					spx, spy = vectorFromAngle(random(0,360),random(30000,40000))
					ntf = spawnEnemies(hsx+spx,hsy+spy,dangerValue,targetEnemyStation:getFaction())
				end
				waveSpawned = true
			end
		end
		if random(1,5) <= 1 then
			if random(1,100) < chance then
				p = closestPlayerTo(targetEnemyStation)
				px, py = p:getPosition()
				local nol = getObjectsInRadius(px, py, 30000)
				local nearbyNebulae = {}
				for _, obj in ipairs(nol) do
					if string.find(obj:getTypeName(),"Nebula") then
						table.insert(nearbyNebulae,obj)
					end
				end
				if #nearbyNebulae > 0 then
					local nx, ny = nearbyNebulae[math.random(1,#nearbyNebulae)]:getPosition()
					ntf = spawnEnemies(nx,ny,dangerValue,targetEnemyStation:getFaction())
					waveSpawned = true
					for _, enemy in ipairs(ntf) do
						enemy:orderAttack(p)
					end
				end
			end
		end
		if waveSpawned then
			jump_start = false
		else
			if random(1,100) < chance then
				p = closestPlayerTo(targetEnemyStation)
				px, py = p:getPosition()
				local spawnAngle = random(0,360)
				spx, spy = vectorFromAngle(spawnAngle, random(15000,20000))
				ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
				spawnAngle = spawnAngle + random(60,180)
				spx, spy = vectorFromAngle(spawnAngle, random(20000,25000))
				ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
				for _, enemy in ipairs(ntf) do
					enemy:orderFlyTowards(px, py)
				end
				spawnAngle = spawnAngle + random(60,120)
				spx, spy = vectorFromAngle(spawnAngle, random(25000,30000))
				ntf = spawnEnemies(px+spx, py+spy, dangerValue, targetEnemyStation:getFaction())
				for _, enemy in ipairs(ntf) do
					enemy:orderAttack(p)
				end
			end
		end
		waveTimer = delta + interWave + dangerValue*10 + random(1,60)
	end
end
-----------------------------------------------------------------------------
--  Plot 2 Easy delivery, improve maneuverability or get base intelligence --
-----------------------------------------------------------------------------
function destroyef2(delta)
	plot2name = "destroyef2"
	local ef2Count = 0
	for _, enemy in ipairs(ef2) do
		if enemy:isValid() then
			ef2Count = ef2Count + 1
		end
	end
	if plot_2_diagnostic then print(string.format("plot 2 destroy enemy fleet (ef) 2. Count: %i",ef2Count)) end
	if ef2Count == 0 then
		easyDeliveryTimer = 15
		plot2 = easyDelivery
		homeDelivery = true
		local p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end
function easyDelivery(delta)
	--required cargo should be easy to find, if expensive in reputation to get
	plot2name = "easyDelivery"
	if plot_2_diagnostic then print("plot 2 easy delivery") end
	easyDeliveryTimer = easyDeliveryTimer - delta
	if easyDeliveryTimer < 0 then
		if easyDeliveryMsg == nil then
			local p = closestPlayerTo(homeStation)
			local home_station_goods_type_count = 0
			for home_good, home_good_details in pairs(homeStation.comms_data.goods) do
				home_station_goods_type_count = home_station_goods_type_count + 1
			end
			for i=2,#stationList do
				easyStation = stationList[i]
				for good, details in pairs(easyStation.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						if home_station_goods_type_count > 0 then
							if homeStation.comms_data.goods[good] == nil then
								easyDeliverGood = good
								break
							end
						else
							easyDeliverGood = good
							break
						end
					end
				end
				if easyDeliverGood ~= nil then
					break
				end
			end
			if easyDeliverGood == nil then
				plot2 = nil
				plot2reminder = nil
			else
				p:addToShipLog(string.format(_("intelligenceOrdersAudio-shipLog", "[%s] We need some goods of type %s. Can you help? I hear %s has some"),homeStation:getCallSign(),easyDeliverGood,easyStation:getCallSign()),"85,107,47")
				plot2reminder = string.format(_("intelligenceOrders-comms", "Bring %s to %s. Possible source: %s"),easyDeliverGood,homeStation:getCallSign(),easyStation:getCallSign())
				playSoundFile("audio/scenario/55/sa_55_Manager1.ogg")
			end
			easyDeliveryMsg = "sent"
		end
	end
end
function spinUpgradeStart(delta)
	plot2name = "spinUpgradeStart"
	if plot_2_diagnostic then print("plot 2 spin upgrade start") end
	infoPromised = true
	spinUpgradeAvailable = false
	plot2reminder = _("upgrade-comms", "Get ship maneuver upgrade")
	local candidate = nil
	if pickSpinBase == nil then
		p = closestPlayerTo(homeStation)
		for i=13,#stationList do
			candidate = stationList[i]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_details in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" then
						spinBase = candidate	--last valid station in list without food or medicine
					end
				end
			end
		end
		if diagnostic then
			p:addToShipLog(string.format("Final choice: %s previous: %s",spinBase:getCallSign(),candidate:getCallSign()),"Blue")
		end
		pickSpinBase = "done"
		plot2 = pickSpinGood
	end
end
function pickSpinGood(delta)
	plot2name = "pickSpinGood"
	if pickSpinGoodBase == nil then
		p = closestPlayerTo(homeStation)
		local candidate = nil
		for i=13,#stationList do
			candidate = stationList[i]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_details in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" then
						local match_away = false
						for spin_good, spin_good_details in pairs(spinBase.comms_data.goods) do
							if spin_good ~= "food" and spin_good ~= "medicine" then
								if spin_good == good then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							spinGood = good
							spinGoodBase = candidate
							break
						end
					end
				end
			end
		end
		if diagnostic then
			p:addToShipLog(string.format("spin base: %s spin good base: %s spin good: %s",spinBase:getCallSign(),spinGoodBase:getCallSign(),spinGood),"Blue")
		end
		plot2 = cleanupSpinners
		spinReveal = 0
		spinUpgradeAvailable = true
		pickSpinGoodBase = "done"
	end
end
function cleanupSpinners(delta)
	plot2name = "cleanupSpinners"
	noSpinCount = 0
	local players = getActivePlayerShips()
	for pidx, pc in ipairs(players) do
		if pc ~= nil and pc:isValid() then
			if not pc.spinUpgrade then
				noSpinCount = noSpinCount + 1
			end
		end
	end
	if noSpinCount == 0 then
		plot2reminder = nil
		plot2 = warpJamLineStart
		warpJamLineTimer = 300
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end
function enemyBaseInfoStart(delta)
	plot2name = "enemyBaseInfoStart"
	baseIntelligenceAvailable = true
	infoPromised = true
	rvfCount = 0
	rvnCount = 0
	baseInt1Visit = false
	for i=4,12 do
		if stationList[i]:isValid() then
			rvfCount = rvfCount + 1
		end
	end
	for i=13,30 do
		if stationList[i]:isValid() then
			rvnCount = rvnCount + 1
		end
	end
	if rvfCount > 0 then
		repeat
			baseInt1 = stationList[math.random(4,12)]
		until(baseInt1:isValid())
		if rvnCount > 1 then
			repeat
				baseInt2 = stationList[math.random(13,30)]
			until(baseInt2:isValid())
		end
	end
	plot2reminder = nil
	plot2 = warpJamLineStart
	warpJamLineTimer = 300
end
function warpJamLineStart(delta)
	plot2name = "warpJamLineStart"
	warpJamLineTimer = warpJamLineTimer - delta
	if warpJamLineTimer < 0 then
		p = closestPlayerTo(targetEnemyStation)
		esx, esy = targetEnemyStation:getPosition()
		cpx, cpy = p:getPosition()
		wjCenter = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderFlyTowardsBlind(cpx,cpy)
		wjP1 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderFlyTowardsBlind(cpx+20000,cpy+20000)
		wjP2 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderFlyTowardsBlind(cpx-20000,cpy-20000)
		wjP3 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderFlyTowardsBlind(cpx+20000,cpy-20000)
		wjP4 = CpuShip():setFaction("Kraylor"):setTemplate("Phobos M3"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderFlyTowardsBlind(cpx-20000,cpy+20000)
		wjCenterE1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjCenterE4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2,(esy+cpy)/2):orderDefendTarget(wjCenter)
		wjP1E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP1E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2+20000):orderDefendTarget(wjP1)
		wjP2E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP2E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2-20000):orderDefendTarget(wjP2)
		wjP3E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP3E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2+20000,(esy+cpy)/2-20000):orderDefendTarget(wjP3)
		wjP4E1 = CpuShip():setFaction("Kraylor"):setTemplate("MT52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E2 = CpuShip():setFaction("Kraylor"):setTemplate("MU52 Hornet"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E3 = CpuShip():setFaction("Kraylor"):setTemplate("Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		wjP4E4 = CpuShip():setFaction("Kraylor"):setTemplate("Ktlitan Fighter"):setPosition((esx+cpx)/2-20000,(esy+cpy)/2+20000):orderDefendTarget(wjP4)
		plot2 = warpJamLineSpring
	end
end
function warpJamLineSpring(delta)
	plot2name = "warpJamLineSpring"
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() and wjCenter:isValid() then
			if distance(p,wjCenter) < 10000 then
				plot2 = warpJamLineRelease
				break
			end
		end
	end
	if wjCenter:isValid() and homeStation:isValid() then
		if distance(wjCenter,homeStation) < 10000 then
			plot2 = warpJamLineRelease
		end
	else
		plot2 = warpJamLineRelease
	end
end
function warpJamLineRelease(delta)
	plot2name = "warpJamLineRelease"
	if wjCenter:isValid() then
		wx, wy = wjCenter:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjCenter:orderStandGround()
	end
	if wjP1:isValid() then
		wx, wy = wjP1:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP1:orderStandGround()
	end
	if wjP2:isValid() then
		wx, wy = wjP2:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP2:orderStandGround()
	end
	if wjP3:isValid() then
		wx, wy = wjP3:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP3:orderStandGround()
	end
	if wjP4:isValid() then
		wx, wy = wjP4:getPosition()
		WarpJammer():setFaction("Kraylor"):setRange(20000):setPosition(wx,wy)
		wjP4:orderStandGround()
	end
	startAngle = random(0,360)
	hsx, hsy = homeStation:getPosition()
	wjAdvx, wjAdvy = vectorFromAngle(startAngle,random(25000,30000))
	wjAdv1ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	angle2 = startAngle + random(60,120)
	wjAdvx, wjAdvy = vectorFromAngle(angle2,random(30000,35000))
	wjAdv2ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	angle3 = angle2 + random(60,120)
	wjAdvx, wjAdvy = vectorFromAngle(angle3,random(35000,40000))
	wjAdv3ef = spawnEnemies(hsx+wjAdvx,hsy+wjAdvy,1)
	for _, enemy in ipairs(wjAdv2ef) do
		enemy:orderAttack(homeStation)
	end
	for _, enemy in ipairs(wjAdv3ef) do
		enemy:orderFlyTowards(hsx, hsy)
	end
	plot2name = nil
	plot2 = nil
end
----------------------------------------------------
--  Plot 3 Development of intelligence over time  --
----------------------------------------------------
function destroyef3(delta)
	plot3name = "destroyef3"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition1Timer = timedIntelligenceInterval
		plot3 = hunterTransition1
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end
function hunterTransition1(delta)
	plot3name = "hunterTransition1"
	hunterTransition1Timer = hunterTransition1Timer - delta
	if hunterTransition1Timer < 0 then
		iuMsg = string.format(_("intelligenceOrders-comms", "The enemy activity has been traced back to enemy bases nearby. Find these bases and stop these incursions. Threat Assessment: %.1f"),dangerValue)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("intelligenceOrders-comms", "Find enemy bases. Stop enemy incursions. TA:%.1f"),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v2
	end
end
function destroyef3v2(delta)
	plot3name = "destroyef3v2"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition2Timer = timedIntelligenceInterval
		plot3 = hunterTransition2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end
function hunterTransition2(delta)
	plot3name = "hunterTransition2"
	hunterTransition2Timer = hunterTransition2Timer - delta
	if hunterTransition2Timer < 0 then
		iuMsg = string.format(_("intelligenceOrdersAudio-shipLog", "Kraylor prefect Ghalontor has moved to one of the enemy stations. Destroy that station and the Kraylor incursion will crumble. Threat Assessment: %.1f"),dangerValue)
		playSoundFile("audio/scenario/55/sa_55_Commander2.ogg")
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("intelligenceOrders-comms", "Destroy enemy base with Prefect Ghalontor aboard. TA:%.1f"),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v3
	end
end
function destroyef3v3(delta)
	plot3name = "destroyef3v3"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition3Timer = timedIntelligenceInterval
		plot3 = hunterTransition3
	end
end
function hunterTransition3(delta)
	plot3name = "hunterTransition3"
	hunterTransition3Timer = hunterTransition3Timer - delta
	if hunterTransition3Timer < 0 then
		for i=4,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt4 == nil then
					enemyInt4 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt4 == nil then
			enemyInt4 = targetEnemyStation
		end
		iuMsg = string.format(_("intelligenceOrders-comms", "Enemy base located in %s. Others expected nearby. Threat Assessment: %.1f"),enemyInt4:getSectorName(),dangerValue)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("intelligenceOrders-comms", "Destroy enemy base possibly near %s with Prefect Ghalontor aboard. TA:%.1f"),enemyInt4:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v4
	end
end
function destroyef3v4(delta)
	plot3name = "destroyef3v4"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition4Timer = timedIntelligenceInterval
		plot3 = hunterTransition4
	end
end
function hunterTransition4(delta)
	plot3name = "hunterTransition4"
	hunterTransition4Timer = hunterTransition4Timer - delta
	if hunterTransition4Timer < 0 then
		for i=5,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt5 == nil then
					enemyInt5 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt5 == nil then
			enemyInt5 = targetEnemyStation
		end
		iuMsg = string.format(_("intelligenceOrders-comms", "Another enemy base located in %s. Others expected nearby. Threat Assessment: %.1f"),enemyInt5:getSectorName(),dangerValue)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("intelligenceOrders-comms", "Destroy enemy base possibly near %s or %s with Prefect Ghalontor aboard. TA:%.1f"),enemyInt4:getSectorName(),enemyInt5:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v5
	end
end
function destroyef3v5(delta)
	plot3name = "destroyef3v5"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition5Timer = timedIntelligenceInterval
		plot3 = hunterTransition5
	end
end
function hunterTransition5(delta)
	plot3name = "hunterTransition5"
	hunterTransition5Timer = hunterTransition5Timer - delta
	if hunterTransition5Timer < 0 then
		for i=6,#enemyStationList do
			if enemyStationList[i]:isValid() then
				if enemyInt6 == nil then
					enemyInt6 = enemyStationList[i]
					break
				end
			end
		end
		if enemyInt6 == nil then
			enemyInt6 = targetEnemyStation
		end
		iuMsg = string.format(_("intelligenceOrders-comms", "Another enemy base located in %s. Others expected nearby. Threat Assessment: %.1f"),enemyInt6:getSectorName(),dangerValue)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("IntelligenceOrders-comms", "Destroy enemy base possibly near %s, %s or %s with Prefect Ghalontor aboard. TA:%.1f"),enemyInt4:getSectorName(),enemyInt5:getSectorName(),enemyInt6:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v6
	end
end
function destroyef3v6(delta)
	plot3name = "destroyef3v6"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition6Timer = timedIntelligenceInterval
		plot3 = hunterTransition6
	end
end
function hunterTransition6(delta)
	plot3name = "hunterTransition6"
	hunterTransition6Timer = hunterTransition6Timer - delta
	if hunterTransition6Timer < 0 then
		iuMsg = string.format(_("intelligenceOrders-comms", "Another enemy base located in %s. Others expected nearby: Threat Assessment: %.1f"),targetEnemyStation:getSectorName(),dangerValue)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("intelligenceOrders-comms", "Destroy enemy base possibly near %s, %s, %s or %s with Prefect Ghalontor aboard. TA:%.1f"),targetEnemyStation:getSectorName(),enemyInt4:getSectorName(),enemyInt5:getSectorName(),enemyInt6:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v7
	end
end
function destroyef3v7(delta)
	plot3name = "destroyef3v7"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		hunterTransition7Timer = timedIntelligenceInterval
		plot3 = hunterTransition7
	end
end
function hunterTransition7(delta)
	plot3name = "hunterTransition7"
	hunterTransition7Timer = hunterTransition7Timer - delta
	if hunterTransition7Timer < 0 then
		iuMsg = string.format(_("intelligenceOrders-comms", "We confirmed Prefect Ghalontor is aboard enemy station %s in %s. Threat Assessment: %.1f"),targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName(),dangerValue)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(iuMsg,"Magenta")
			end
		end
		secondaryOrders = string.format(_("intelligenceOrders-comms", "Destroy enemy base %s in %s. TA:%.1f"),targetEnemyStation:getCallSign(),targetEnemyStation:getSectorName(),dangerValue)
		scx, scy = homeStation:getPosition()
		cpx, cpy = vectorFromAngle(random(0,360),random(30000,40000))
		ef3 = spawnEnemies(scx+cpx,scy+cpy,1)
		for _, enemy in ipairs(ef3) do
			enemy:orderFlyTowards(scx,scy)
		end
		plot3 = destroyef3v8
	end
end
function destroyef3v8(delta)
	plot3namename = "destroyef3v8"
	ef3Count = 0
	for _, enemy in ipairs(ef3) do
		if enemy:isValid() then
			ef3Count = ef3Count + 1
		end
	end
	if ef3Count == 0 then
		plot3 = nil
	end
end
--------------------------------------------------------------------------
--  Plot 4 station rotate upgrade or beam time upgrade or hull upgrade  --
--------------------------------------------------------------------------
function destroyef4(delta)
	plot4name = "destroyef4"
	ef4Count = 0
	for _, enemy in ipairs(ef4) do
		if enemy:isValid() then
			ef4Count = ef4Count + 1
		end
	end
	if ef4Count == 0 then
		randomDeliveryTimer = 45
		plot4 = randomDelivery
		homeDelivery = true
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end
end
function randomDelivery(delta)
	plot4name = "randomDelivery"
	randomDeliveryTimer = randomDeliveryTimer - delta
	if randomDeliveryTimer < 0 then
		if randomDeliveryMsg == nil then
			p = closestPlayerTo(homeStation)
			local home_station_good_count = 0
			if homeStation.comms_data.goods ~= nil then
				for good, good_detail in pairs(homeStation.comms_data.goods) do
					home_station_good_count = home_station_good_count + 1
				end
			end
			if home_station_good_count > 0 then
				local attempt_count = 0
				repeat
					attempt_count = attempt_count + 1
					randomDeliverStation = stationList[math.random(6,#stationList)]
					if randomDeliverStation ~= nil and randomDeliverStation:isValid() and randomDeliverStation.comms_data.goods ~= nil then
						for good, good_detail in pairs(randomDeliverStation.comms_data.goods) do
							if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
								local match_away = false
								for home_good, home_good_detail in pairs(homeStation.comms_data.goods) do
									if home_good ~= "food" and home_good ~= "medicine" and home_good ~= "luxury" then
										if home_good == good then
											match_away = true
											break
										end
									end
								end
								if not match_away then
									randomDeliverGood = good
									break
								end
							end
						end
					end 
				until(randomDeliverGood ~= nil or attempt_count > 50)
			end
			if randomDeliverGood == nil then
				plot4reminder = nil
				plot4delay = 100
				plot4 = delayef4v2
			else
				p:addToShipLog(string.format(_("upgradeOrdersAudio-shipLog", "[%s] We are running low on goods of type %s. Can you help? %s in %s should have some"),homeStation:getCallSign(),randomDeliverGood,randomDeliverStation:getCallSign(),randomDeliverStation:getSectorName()),"85,107,47")
				plot4reminder = string.format(_("upgradeOrders-comms", "Bring %s to %s. Possible source: %s in %s"),randomDeliverGood,homeStation:getCallSign(),randomDeliverStation:getCallSign(),randomDeliverStation:getSectorName())
				playSoundFile("audio/scenario/55/sa_55_Manager2.ogg")
			end
			randomDeliveryMsg = "sent"
		end
	end
end
function rotateUpgradeStart(delta)
	plot4name = "rotateUpgradeStart"
	infoPromised = true
	homeStationRotationEnabled = false
	rotateUpgradeAvailable = false
	plot4reminder = string.format(_("upgrade-comms", "Upgrade %s to rotate"),homeStation:getCallSign())
	if pickRotateBase == nil then
		repeat
			local candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				if candidate.comms_data.goods ~= nil then
					for good, good_detail in pairs(candidate.comms_data.goods) do
						if good ~= "food" and good ~= "medicine" then
							rotateBase = candidate
						end
					end
				end
			end
		until(rotateBase ~= nil)
		pickRotateBase = "done"
		plot4 = pickRotateGood
	end
end
function pickRotateGood(delta)
	plot4name = "pickRotateGood"
	if pickRotateGoodBase == nil then
		repeat
			local candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= rotateBase and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						local match_away = false
						for good_rotate, good_rotate_detail in pairs(rotateBase.comms_data.goods) do
							if good_rotate ~= "food" and good_rotate ~= "medicine" and good_rotate ~= "luxury" then
								if good_rotate == good then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							rotateGood = good
							rotateGoodBase = candidate
							break
						end
					end
				end
			end
		until(rotateGood ~= nil)
		plot4delay = 100
		plot4 = delayef4v2
		rotateReveal = 0
		rotateUpgradeAvailable = true
		pickRotateGoodBase = "done"
	end
end
function beamTimeUpgradeStart(delta)
	plot4name = "beamTimeUpgradeStart"
	infoPromised = true
	beamTimeUpgradeAvailable = false
	plot4reminder = _("upgrade-comms", "Get beam cycle time upgrade")
	if pickBeamTimeBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						beamTimeBase = candidate
					end
				end		
			end
		until(beamTimeBase ~= nil)
		pickBeamTimeBase = "done"
		plot4 = pickBeamTimeGood
	end
end
function pickBeamTimeGood(delta)
	plot4name = "pickBeamTimeGood"
	if pickBeamTimeGoodBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= beamTimeBase and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						local match_away = false
						for good_beam, good_beam_detail in pairs(beamTimeBase.comms_data.goods) do
							if good_beam ~= "food" and good_beam ~= "medicine" and good_beam ~= "luxury" then
								if good == good_beam then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							beamTimeGood = good
							beamTimeGoodBase = candidate
							break
						end
					end
				end
			end
		until(beamTimeGood ~= nil)
		plot4 = cleanUpBeamTimers
		beamTimeReveal = 0
		beamTimeUpgradeAvailable = true
		pickBeamTimeGoodBase = "done"
	end
end
function cleanUpBeamTimers(delta)
	plot4name = "cleanUpBeamTimers"
	noBeamTimeCount = 0
	local players = getActivePlayerShips()
	for pidx, pc in ipairs(players) do
		if pc ~= nil and pc:isValid() then
			if not pc.beamTimeUpgrade then
				noBeamTimeCount = noBeamTimeCount + 1
			end
		end
	end
	if noBeamTimeCount == 0 then
		plot4reminder = nil
		plot4name = nil
		plot4delay = 100
		plot4 = delayef4v2
		p = closestPlayerTo(targetEnemyStation)
		p:addReputationPoints(20)
	end	
end
function hullUpgradeStart(delta)
	plot4name = "hullUpgradeStart"
	infoPromised = true
	hullUpgradeAvailable = false
	plot4reminder = _("upgrade-comms", "Get hull upgrade")
	if pickHullBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						hullBase = candidate
					end
				end
			end
		until(hullBase ~= nil)
		pickHullBase = "done"
		plot4 = pickHullGood
	end
end
function pickHullGood(delta)
	plot4name = "pickHullGood"
	if pickHullGoodBase == nil then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() and candidate ~= hullBase and candidate.comms_data.goods ~= nil then
				for good, good_detail in pairs(candidate.comms_data.goods) do
					if good ~= "food" and good ~= "medicine" and good ~= "luxury" then
						local match_away = false
						for good_hull, good_hull_detail in pairs(hullBase.comms_data.goods) do
							if good_hull ~= "food" and good_hull ~= "medicine" and good_hull ~= "luxury" then
								if good == good_hull then
									match_away = true
									break
								end
							end
						end
						if not match_away then
							hullGood = good
							hullGoodBase = candidate
							break
						end
					end
				end
			end
		until(hullGood ~= nill)
		plot4 = cleanUpHullers
		hullReveal = 0
		hullUpgradeAvailable = true
		pickhullGoodBase = "done"
	end
end
function cleanUpHullers(delta)
	plot4name = "cleanUpHullers"
	noHullCount = 0
	local players = getActivePlayerShips()
	for pidx, pc in ipairs(players) do
		if pc ~= nil and pc:isValid() then
			if not pc.hullUpgrade then
				noHullCount = noHullCount + 1
			end
		end
	end
	if noHullCount == 0 then
		plot4reminder = nil
		plot4delay = 100
		plot4 = delayef4v2
		p = closestPlayerTo(targetEnemyStation)
		if p ~= nil and p:isValid() then
			p:addReputationPoints(20)
		end
	end	
end
function delayef4v2(delta)
	plot4name = "delayef4v2"
	plot4delay = plot4delay - delta
	if plot4delay < 0 then
		p = closestPlayerTo(targetEnemyStation)
		px, py = p:getPosition()
		ambushAngle = random(0,360)
		a1x, a1y = vectorFromAngle(ambushAngle,random(30000,40000))
		ef4v2 = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ef4v2) do
			enemy:orderAttack(p)
		end
		a1x, a1y = vectorFromAngle(ambushAngle+random(60,120),random(30000,40000))
		ntf = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(p)
			table.insert(ef4v2,enemy)
		end
		a1x, a1y = vectorFromAngle(ambushAngle+random(180,300),random(30000,40000))
		ntf = spawnEnemies(px+a1x,py+a1y,dangerValue/2,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(p)
			table.insert(ef4v2,enemy)
		end
		plot4 = destroyef4v2
	end
end
-- random plot 4 development after enemy fleet for plot 4 version 2 is destroyed
function destroyef4v2(delta)
	plot4name = "destroyef4v2"
	ef4Count = 0
	for _, enemy in ipairs(ef4v2) do
		if enemy:isValid() then
			ef4Count = ef4Count + 1
		end
	end
	if ef4Count == 0 then
		choooseNextPlot4line()
	end
end
function choooseNextPlot4line()
	plot4reminder = nil
	if #plot4choices > 0 then
		p4c = math.random(1,#plot4choices)
		plot4 = plot4choices[p4c]
		table.remove(plot4choices,p4c)
		plot4delayTimer = random(40,120)
	else
		plot4 = nil
	end
end
function insertAgentDelay(delta)
	plot4name = "insertAgentDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format(_("PaulOrders-shiplog", "Agent Paul Straight has information on enemies in the area and a proposal. Pick him and his equipment up at station %s"),homeStation:getCallSign()),"Magenta")
				plot4reminder = string.format(_("PaulOrders-comms", "Get Paul Straight at station %s"),homeStation:getCallSign())
			end
		end
		plot4 = getAgentStraight
	end
end
function getAgentStraight(delta)
	plot4name = "getAgentStraight"
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() and p:isDocked(homeStation) then
			p.straight = true
			if #enemyStationList > 0 then
				for eidx=1,#enemyStationList do
					if enemyStationList[eidx]:isValid() then
						insertEnemyStation = enemyStationList[eidx]
						break
					end
				end
			end
			p:addToShipLog(string.format(_("PaulOrders-shiplog", "[Paul Straight] I've been studying enemy station %s in %s: traffic patterns, communication traffic, energy signature, etc. I've built a specialized short range transporter that should be able to beam me onto the station through their shields. I need to get refined readings from 20 units or closer for final calibration. Please take me to within 20 units of %s"),insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName(),insertEnemyStation:getCallSign()),"95,158,160")
			plot4reminder = string.format(_("PaulOrders-comms", "Take Paul Straight to within 20U of %s in %s"),insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName())
			plot4 = scanEnemyStation
			break
		end
	end
end
function scanEnemyStation(delta)
	plot4name = "scanEnemyStation"
	if insertEnemyStation:isValid() then
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				if distance(p,insertEnemyStation) <= 20000 then
					insertRunDelayTimer = 15
					p:addToShipLog(_("Paul-shiplog", "[Paul Straight] I've got my readings. Let me calibrate the transporter"),"95,158,160")
					if p:hasPlayerAtPosition("Helms") then
						inRangeMsg = "inRangeMsg"
						p:addCustomMessage("Helms",inRangeMsg,_("Paul-msgHelms", "[Paul Straight] The ship is in range. I completed my scans. Thank you"))
					end
					if p:hasPlayerAtPosition("Tactical") then
						inRangeMsgTactical = "inRangeMsgTactical"
						p:addCustomMessage("Tactical",inRangeMsgTactical,_("Paul-msgTactical", "[Paul Straight] The ship is in range. I completed my scans. Thank you"))
					end
					plot4 = insertRunDelay
				end
			end
		end
	else
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				p:addToShipLog(_("Paul-shiplog", "[Paul Straight] It's too bad the station was destroyed"),"95,158,160")
				choooseNextPlot4line()
				break
			end
		end
	end
end
function insertRunDelay(delta)
	plot4name = "insertRunDelay"
	insertRunDelayTimer = insertRunDelayTimer - delta
	if insertRunDelayTimer < 0 then
		if insertEnemyStation:isValid() then
			local players = getActivePlayerShips()
			for pidx, p in ipairs(players) do
				if p ~= nil and p:isValid() and p.straight then
					p:addToShipLog(string.format(_("PaulOrders-shiplog", "[Paul Straight] My transporter is ready. I've disguised myself as a Kraylor technician. I need you to take the ship within 2.5U of %s. You don't need to defeat any patrols, but there might be some enemy interest in your ship flying so close to the station. After I am aboard %s, I will gether intelligence and transmit it back. I'm ready to proceed"),insertEnemyStation:getCallSign(),insertEnemyStation:getCallSign()),"95,158,160")
					plot4reminder = string.format(_("PaulOrders-comms", "Get ship within 2.5U of %s in %s to secretly transport Paul Straight"),insertEnemyStation:getCallSign(),insertEnemyStation:getSectorName())
					plot4 = insertRun
					break
				end
			end
		else
			local players = getActivePlayerShips()
			for pidx, p in ipairs(players) do
				if p ~= nil and p:isValid() and p.straight then
					p:addToShipLog(_("Paul-shiplog", "[Paul Straight] It's too bad the station was destroyed"),"95,158,160")
					choooseNextPlot4line()
					break
				end
			end
		end
	end
end
function insertRun(delta)
	plot4name = "insertRun"
	if insertEnemyStation:isValid() then
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				if distance(p,insertEnemyStation) <= 2500 then
					if p:hasPlayerAtPosition("Science") then
						straightTransportedMsg = "straightTransportedMsg"
						p:addCustomMessage("Science",straightTransportedMsg,string.format(_("Paul-msgScience", "Paul Straight has transported aboard %s"),insertEnemyStation:getCallSign()))
					end
					if p:hasPlayerAtPosition("Operations") then
						straightTransportedMsgOps = "straightTransportedMsgOps"
						p:addCustomMessage("Operations",straightTransportedMsgOps,string.format(_("Paul-msgOperations", "Paul Straight has transported aboard %s"),insertEnemyStation:getCallSign()))
					end
					plot4 = resultDelay
					plot4reminder = string.format(_("Paul-comms", "Await intelligence results from Paul Straight on %s"),insertEnemyStation:getCallSign())
					resultDelayTimer = random(30,60)
				end
			end
		end
	else
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				p:addToShipLog(_("Paul-shiplog", "[Paul Straight] It's too bad the station was destroyed"),"95,158,160")
				choooseNextPlot4line()
				break
			end
		end
	end
end
function resultDelay(delta)
	plot4name = "resultDelay"
	if insertEnemyStation:isValid() then
		resultDelayTimer = resultDelayTimer - delta
		if resultDelayTimer < 0 then
			locationResultMsg = _("Paul-comms", "[Paul Straight] I discovered the location of the enemy bases in the area:")
			for eidx=1,#enemyStationList do
				if enemyStationList[eidx]:isValid() then
					locationResultMsg = locationResultMsg .. string.format(_("Paul-comms", "\n%s in %s"),enemyStationList[eidx]:getCallSign(),enemyStationList[eidx]:getSectorName())
				end
			end
			p = closestPlayerTo(insertEnemyStation)
			p:addToShipLog(locationResultMsg,"95,158,160")
			resultDelay2Timer = random(120,240)
			plot4 = resultDelay2
		end
	else
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,_("Paul-msgScience", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,_("Paul-msgOperations", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
			end
		end
		choooseNextPlot4line()
	end
end
function resultDelay2(delta)
	plot4name = "resultDelay2"
	if insertEnemyStation:isValid() then
		resultDelay2Timer = resultDelay2Timer - delta
		if resultDelay2Timer < 0 then
			p = closestPlayerTo(insertEnemyStation)
			p:addToShipLog(string.format(_("Paul-shipLog", "[Paul Straight] Prefect Ghalantor is on station %s. Wait, someone is coming..."),targetEnemyStation:getCallSign()),"95,158,160")
			straightExecutionTimer = random(40,80)
			plot4 = straightExecution
		end
	else
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,_("Paul-msgScience", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,_("Paul-msgOperations", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
			end
		end
		choooseNextPlot4line()
	end
end
function straightExecution(delta)
	plot4name = "straightExecution"
	if insertEnemyStation:isValid() then
		straightExecutionTimer = straightExecutionTimer - delta
		if straightExecutionTimer < 0 then
			p = closestPlayerTo(insertEnemyStation)
			insertEnemyStation:sendCommsMessage(p,_("Paul-incCall", "We discovered your perfidious spy aboard our station. He will be executed for his treasonous activities"))
			plot4 = agentDemise
			agentDemiseTimer = random (40,80)
		end
	else
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,_("Paul-msgScience", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,_("Paul-msgOperations", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
			end
		end
		choooseNextPlot4line()
	end
end
function agentDemise(delta)
	plot4name = "agentDemise"
	if insertEnemyStation:isValid() then
		agentDemiseTimer = agentDemiseTimer - delta
		if agentDemiseTimer < 0 then
			local players = getActivePlayerShips()
			for pidx, p in ipairs(players) do
				if p ~= nil and p:isValid() and p.straight then
					if p:hasPlayerAtPosition("Science") then
						fatalMsg = "fatalMsg"
						p:addCustomMessage("Science",fatalMsg,_("Paul-msgScience", "Lifesign telemetry from Paul Straight's equipment has ceased"))
					end
					if p:hasPlayerAtPosition("Operations") then
						fatalMsgOps = "fatalMsgOps"
						p:addCustomMessage("Operations",fatalMsgOps,_("Paul-msgOperations", "Lifesign telemetry from Paul Straight's equipment has ceased"))
					end
				end
			end
			choooseNextPlot4line()
		end
	else
local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() and p.straight then
				if p:hasPlayerAtPosition("Science") then
					fatalMsg = "fatalMsg"
					p:addCustomMessage("Science",fatalMsg,_("Paul-msgScience", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
				if p:hasPlayerAtPosition("Operations") then
					fatalMsgOps = "fatalMsgOps"
					p:addCustomMessage("Operations",fatalMsgOps,_("Paul-msgOperations", "Lifesign telemetry from Paul Straight's equipment has ceased"))
				end
			end
		end
		choooseNextPlot4line()
	end
end
function repairBountyDelay(delta)
	plot4name = "repairBountyDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		hx, hy = homeStation:getPosition()
		ex, ey = targetEnemyStation:getPosition()
		bx, by = vectorFromAngle(random(0,360),6000)
		hmsBounty = CpuShip():setFaction("Human Navy"):setTemplate("Stalker Q7"):setScanned(true)
		hmsBounty:setSystemHealth("warp", -0.5):setCommsScript(""):setCommsFunction(commsShip)
		hmsBounty:setSystemHealth("impulse", 0.5):setCallSign("HMS Bounty"):orderStandGround()
		hmsBounty:setSystemHealth("jumpdrive", -0.5):setPosition(((hx+ex)/2)+bx,((hy+ey)/2)+by)
		hmsBounty.repaired = false
		p = closestPlayerTo(hmsBounty)
		p:addToShipLog(string.format(_("HMSBounty-shipLog", "[HMS Bounty] We stole a Kraylor ship, but were damaged during the escape. Can you help? We are in %s"),hmsBounty:getSectorName()),"#ff4500")
		plot4reminder = string.format(_("HMSBounty-comms", "Help HMS Bounty in %s"),hmsBounty:getSectorName())
		ntf = spawnEnemies((hx+ex)/2,(hy+ey)/2,dangerValue,targetEnemyStation:getFaction())
		for _, enemy in ipairs(ntf) do
			enemy:orderAttack(hmsBounty)
		end
		plot4 = repairBounty
	end
end
function repairBounty(delta)
	p = closestPlayerTo(hmsBounty)
	if p:isValid() then
		if hmsBounty:isValid() then
			if distance(p,hmsBounty) < 2500 then
				p:addToShipLog(_("HMSBounty-shipLog", "[HMS Bounty] Please ask your engineer to transport a spare repair technician to help with repairs"),"#ff4500")
				if p:hasPlayerAtPosition("Engineering") then
					transportRepairTechnicianButton = "transportRepairTechnicianButton"
					p:addCustomButton("Engineering",transportRepairTechnicianButton,_("crewTransfer-buttonEngineer", "Transport technician"),transportRepairTechnician)
				end
				if p:hasPlayerAtPosition("Engineering+") then
					transportRepairTechnicianButtonPlus = "transportRepairTechnicianButtonPlus"
					p:addCustomButton("Engineering+",transportRepairTechnicianButtonPlus,_("crewTransfer-buttonEngineer+", "Transport technician"),transportRepairTechnician)
				end
				p.transportButton = true
				plot4 = nil
			end
		else
			p:addToShipLog(_("HMSBounty-shipLog", "HMS Bounty has been destroyed"),"Magenta")
			plot4 = nil
			plot4reminder = nil
		end
	end
end
function transportRepairTechnician()
	hmsBounty:setSystemHealth("warp",1)
	hmsBounty:setSystemHealth("impulse",1)
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() then
			if p.transportButton then
				if transportRepairTechnicianButton ~= nil then
					p:removeCustom(transportRepairTechnicianButton)
				end
				if transportRepairTechnicianButtonPlus ~= nil then
					p:removeCustom(transportRepairTechnicianButtonPlus)
				end
				p:addToShipLog(_("HMSBounty-shipLog", "[HMS Bounty] Our engines have been repaired. We stand ready to assist"),"#ff4500")
			end
		end
	end
	choooseNextPlot4line()
end
function stationShieldDelay(delta)
	plot4name = "stationShieldDelay"
	plot4delayTimer = plot4delayTimer - delta
	if plot4delayTimer < 0 then
		repeat
			candidate = stationList[math.random(13,#stationList)]
			if candidate ~= nil and candidate:isValid() then
				shieldExpertStation = candidate
			end
		until(shieldExpertStation ~= nil)
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format(_("MariaOrdersAudio-shipLog", "Intelligence analysis shows research on the network that could double the shield strength of station %s. The analysis shows that the technical expert can be found on station %s in sector %s"),homeStation:getCallSign(),shieldExpertStation:getCallSign(),shieldExpertStation:getSectorName()),"Magenta")
			end
		end
		playSoundFile("audio/scenario/55/sa_55_Commander3.ogg")
		plot4reminder = string.format(_("MariaOrders-comms", "Find shield expert at station %s in %s"),shieldExpertStation:getCallSign(),shieldExpertStation:getSectorName())
		plot4 = visitShieldExpertStation
	end
end
function visitShieldExpertStation(delta)
	plot4name = "visitShieldExpertStation"
	if shieldExpertTransport == nil then
		repeat
			candidate = transportList[math.random(1,#transportList)]
			if candidate ~= nil and candidate:isValid() then
				shieldExpertTransport = candidate
			end
		until(shieldExpertTransport ~= nil)
	end
	if shieldExpertStation:isValid() then
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				if p:isDocked(shieldExpertStation) then
					p:addToShipLog(string.format(_("MariaOrdersAudio-shipLog", "We heard you were looking for our former shield maintenance technician, Maria Shrivner who's been publishing hints about advances in shield technology. We've been looking for her. We only just found out that she left the station after a severe romantic breakup with her supervisor. She took a job on a freighter %s which was last reported in %s"),shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName()),"186,85,211")
					plot4 = meetShieldExportTransportHeartbroken
					plot4reminder = string.format(_("MariaOrders-comms", "Meet transport %s last reported in %s to find Maria Shrivner"),shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName())
					playSoundFile("audio/scenario/55/sa_55_BaseChief.ogg")
				end
			end
		end
	else
		if shieldExpertTransport:isValid() then
			local players = getActivePlayerShips()
			for pidx, p in ipairs(players) do
				if p ~= nil and p:isValid() then
					p:addToShipLog(string.format(_("Maria-shipLog", "We received word that station %s has been destroyed. However, in some of their final records we see that Maria Shrivner left the station to take a job on freighter %s which was last reported in %s"),shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName()),"Magenta")
					plot4 = meetShieldExportTransport
					plot4reminder = stringFormat(_("MariaOrders-comms", "Meet transport %s last reported in %s to find Maria Shrivner"),shieldExpertTransport:getCallSign(),shieldExpertTransport:getSectorName())
				end
			end
		else
			local players = getActivePlayerShips()
			for pidx, p in ipairs(players) do
				if p ~= nil and p:isValid() then
					p:addToShipLog(_("Maria-shipLog", "Station %s has been destroyed leaving no hints for shield upgrade followup"),"Magenta")
				end
			end
			choooseNextPlot4line()
		end
	end
end
function meetShieldExportTransport(delta)
	plot4name = "meetShieldExportTransport"
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() then
			if shieldExpertTransport:isValid() then
				if distance(p,shieldExpertTransport) < 500 then
					p.shieldExpert = true
					p:addToShipLog(string.format(_("MariaOrdersAudio-shipLog", "[Maria Shrivner] It was tragic that %s was destroyed. Bring me to %s and I'll double %s's shield effectiveness"),shieldExpertStation:getCallSign(),homeStation:getCallSign(),homeStation:getCallSign()),"Yellow")
					playSoundFile("audio/scenario/55/sa_55_Maria1.ogg")
					plot4 = returnHomeForShields
					plot4reminder = _("MariaOrders-comms", "Return to home base with Maria Shrivner to double shield capacity")
					break
				end
			end
		end
	end
end
function meetShieldExportTransportHeartbroken(delta)
	plot4name = "meetShieldExportTransportHeartbroken"
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() then
			if shieldExpertTransport:isValid() then
				if distance(p,shieldExpertTransport) < 500 then
					p.shieldExpert = true
					p:addToShipLog(string.format(_("MariaOrdersAudio-shipLog", "[Maria Shrivner] I should not have broken up with him, it was all a misunderstanding. Help me get him some rare material as a gift and I'll double %s's shield effectiveness"),homeStation:getCallSign()),"Yellow")
					playSoundFile("audio/scenario/55/sa_55_Maria2.ogg")
					plot4 = giftForBeau
					beauGift = false
					plot4reminder = string.format(_("MariaOrders-comms", "Get gold, platinum, dilithium, tritanium or cobalt and bring it and Maria Shrivner to %s"),shieldExpertStation:getCallSign())
					break
				end
			end
		end
	end
end
function giftForBeau(delta)
	plot4name = "giftForBeau"
	if shieldExpertStation:isValid() then
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				if p:isDocked(shieldExpertStation) then
					if p.shieldExpert then
						if beauGift then
							p:addToShipLog(string.format(_("MariaOrdersAudio-shipLog", "[Maria Shrivner] Well, he's at least thinking about it. He liked the gift. Take me to %s and let's get those shields upgraded"),homeStation:getCallSign()),"Yellow")
							playSoundFile("audio/scenario/55/sa_55_Maria3.ogg")
							plot4 = returnHomeForShields
							plot4reminder = _("MariaOrders-comms", "Return to home base with Maria Shrivner to double shield capacity")
						end
					end
				end
			end
		end
	else
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				p:addToShipLog(string.format(_("Maria-shipLog", "We were just notified that station %s has been destroyed"),shieldExpertStation:getCallSign()),"Magenta")
				if p.shieldExpert then
					p:addToShipLog(string.format(_("MariaOrdersAudio-shipLog", "[Maria Shrivner] Oh no! I'm too late! Now we'll never be reconciled. *sniff* Well, the least I can do is upgrade %s's shields. Take me there and I'll double %s's shield capacity"),homeStation:getCallSign(),homeStation:getCallSign()),"Yellow")
					playSoundFile("audio/scenario/55/sa_55_Maria4.ogg")
					plot4 = returnHomeForShields
					plot4reminder = _("MariaOrders-comms", "Return to home base with Maria Shrivner to double shield capacity")
				end
			end
		end
	end
end
function returnHomeForShields(delta)
	plot4name = "returnHomeForShields"
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() then
			if p:isDocked(homeStation) then
				if homeStation.shieldUpgrade == nil then
					if p.shieldExpert then
						newMax = homeStation:getShieldMax(0)*2
						if homeStation:getShieldCount() == 1 then
							homeStation:setShieldsMax(newMax)
						end
						if homeStation:getShieldCount() == 3 then
							homeStation:setShieldsMax(newMax,newMax,newMax)
						end
						if homeStation:getShieldCount() == 4 then
							homeStation:setShieldsMax(newMax,newMax,newMax,newMax)
						end
					end
					p:addToShipLog(string.format(_("MariaAudio-shipLog", "[Maria Shrivner] %s's shield capacity has been doubled. They should charge up to their new capacity eventually"),homeStation:getCallSign()),"Yellow")
					playSoundFile("audio/scenario/55/sa_55_Maria5.ogg")
					choooseNextPlot4line()
					homeStation.shieldUpgrade = true
				end
			end
		end
	end
end
-------------------------------
--  Plot 5 Helpful warnings  --
-------------------------------
function helpfulWarning(delta)
	plot5name = "helpfulWarning"
	helpfulWarningTimer = helpfulWarningTimer - delta
	if helpfulWarningTimer < 0 then
		warningProvided = false
		for i=1,#stationList do
			if stationList[i]:isValid() then
				p = closestPlayerTo(stationList[i])
				if p ~= nil then
					for index, obj in ipairs(stationList[i]:getObjectsInRange(30000)) do
						if obj:isEnemy(p) then
							local detected_enemy_ship = false
							if isObjectType(obj,"CpuShip") then
								detected_enemy_ship = true
							end
							--tempObjType = obj:getTypeName()
							--if not string.find(tempObjType,"Station") then
							if detected_enemy_ship then
								wMsg = string.format(_("helpfullWarning-shipLog", "[%s] Our sensors detect enemies nearby"),stationList[i]:getCallSign())
								if diagnostic or difficulty < 1 then
									wMsg = wMsg .. string.format(_("helpfullWarning-shipLog", " - Type: %s"),obj:getTypeName())
								end
								p:addToShipLog(wMsg,"Red")
								if i == 1 then
									if helpfulWarningDiagnostic then print("home station warning details") end
									local stationShields = homeStation:getShieldCount()
									if helpfulWarningDiagnostic then print("number of shields around home station: " .. stationShields) end
									local shieldsDamaged = false
									if stationShields == 1 then
										if helpfulWarningDiagnostic then print("station has only one shield") end
										local sLevel = homeStation:getShieldLevel(0)
										if helpfulWarningDiagnostic then print("shield level for the one shield: " .. sLevel) end
										local sMax = homeStation:getShieldMax(0)
										if helpfulWarningDiagnostic then print("shield maximum for the one shield: " .. sMax) end
										if sLevel < sMax then
											if helpfulWarningDiagnostic then print("shield not fully charged") end
											sLine = string.format(_("helpfullWarning-shipLog", "   Shield: %.1f%% (%.1f/%.1f) "),sLevel/sMax*100,sLevel,sMax)
											shieldsDamaged = true
										end
									else
										if helpfulWarningDiagnostic then print("station has multiple shields") end
										sdMsg = string.format(_("helpfullWarning-shipLog", "   Shield count: %i "),stationShields)
										if helpfulWarningDiagnostic then print("about to start shield loop") end
										shieldStatusLines = {}
										for j=1,stationShields do
											if helpfulWarningDiagnostic then print(string.format("loop index: %i, shield number: %i",j,j-1)) end
											sLevel = homeStation:getShieldLevel(j-1)
											if helpfulWarningDiagnostic then print("shield level: " .. sLevel) end
											sMax = homeStation:getShieldMax(j-1)
											if helpfulWarningDiagnostic then print("max: " .. sMax) end
											if sLevel < sMax then
												if helpfulWarningDiagnostic then print("shield not fully charged") end
												sLine = string.format(_("helpfullWarning-shipLog", "      Shield %i: %i%% (%.1f/%i) "),j,math.floor(sLevel/sMax*100),sLevel,sMax)
												table.insert(shieldStatusLines,sLine)
												shieldsDamaged = true
											end
										end
									end
									if shieldsDamaged then
										p:addToShipLog(_("helpfullWarning-shipLog", "Station Status:"),"Red")
										if stationShields == 1 then
											p:addToShipLog(sLine,"Red")
										else
											for k=1,#shieldStatusLines do
												p:addToShipLog(shieldStatusLines[k],"Red")
											end
										end
									end
									if helpfulWarningDiagnostic then print("Done with shield status, check hull status") end
									hl = homeStation:getHull()
									if helpfulWarningDiagnostic then print("current hull: " .. hl) end
									hm = homeStation:getHullMax()
									if helpfulWarningDiagnostic then print("max hull: " .. hm) end
									if hl < hm then
										if helpfulWarningDiagnostic then print("hull not fully repaired") end
										if not shieldsDamaged then
											p:addToShipLog(_("helpfullWarning-shipLog", "Station Status:"),"Red")										
										end
										local hLine = string.format(_("helpfullWarning-shipLog", "   Hull: %i%% (%.1f/%i)"),math.floor(hl/hm*100),hl,hm)
										p:addToShipLog(hLine,"Red")
									end
								end
								warningProvided = true
								break
							end
						end
					end
				end
			end
			if warningProvided then
				break
			end
		end
		helpfulWarningTimer = delta + random(90,200)
	end
end
-------------------------
--  Plot 6 Timed Game  --
-------------------------
function timedGame(delta)
	gameTimeLimit = gameTimeLimit - delta
	if gameTimeLimit < 0 then
		if getScenarioSetting("Goal") == "Defender" then
			missionVictory = true
			endStatistics()
			victory("Human Navy")
		else
			missionVictory = false
			endStatistics()
			victory("Kraylor")
		end
	end
end
-----------------------------------------------------------------
--  Plot W - wormhole starts as an artifact in unusual motion  --
-----------------------------------------------------------------
function setWormArt()
	wormArt = Artifact():setPosition(random(-90000,90000),random(-90000,90000)):setModel("artifact4"):allowPickup(false):setScanningParameters(2,5)
	wormArt:setDescriptions(_("scienceDescription-artifact", "sprightly unassuming object"),_("scienceDescription-artifact", "Object shows rapidly building energy")):setRadarSignatureInfo(50,10,5)
	wormArt.travelAngle = random(0,360)
	wormArt.tempAngle = -90
	wormArt.travel = 5
	plotW = moveWormArt
end
function moveWormArt(delta)
	plotWname = "moveWormArt"
	if wormart ~= nil and wormart:isValid() then
		if wormArt:isScannedByFaction("Human Navy") then
			wormDelayTimer = 5
			plotW = wormBirth
		end
		p = closestPlayerTo(wormArt)
		if p ~= nil and p:isValid() then
			if distance(p,wormArt) > 5000 then
				wax, way = wormArt:getPosition()
				angleChange = false
				if wax < -100000 then
					angleChange = true
					wormArt.travelAngle = random(0,180) + 270
				end
				if wax > 100000 then
					angleChange = true
					wormArt.travelAngle = random(90,270)
				end
				if way < -100000 then
					angleChange = true
					wormArt.travelAngle = random(0,180)
				end
				if way > 100000 then
					angleChange = true
					wormArt.travelAngle = random(180,360)
				end
				if angleChange then
					wadx, wady = vectorFromAngle(wormArt.travelAngle,wormArt.travel+20)
					wormArt:setPosition(wax+wadx,way+wady)
				else
					wadx, wady = vectorFromAngle(wormArt.travelAngle + wormArt.tempAngle,wormArt.travel)
					wormArt:setPosition(wax+wadx,way+wady)
					wormArt.tempAngle = wormArt.tempAngle + 1
					if wormArt.tempAngle > 90 then
						wormArt.tempAngle = -90
					end
				end
			end
		end
	end
end
function wormBirth(delta)
	plotWname = "wormBirth"
	wormDelayTimer = wormDelayTimer - delta
	if wormDelayTimer < 0 then
		wax, way = wormArt:getPosition()
		wormArt:explode()
		plotW = wormBirth2
		wormDelayTimer2 = 5
	end
end
function wormBirth2(delta)
	plotWname = "wormBirth2"
	wormDelayTimer2 = wormDelayTimer2 - delta
	if wormDelayTimer2 < 0 then
		ElectricExplosionEffect():setPosition(wax,way):setSize(5000)
		wormDelayTimer3 = 5
		plotW = wormBirth3
	end
end
function wormBirth3(delta)
	plotWname = "wormBirth3"
	wormDelayTimer3 = wormDelayTimer3 - delta
	if wormDelayTimer3 < 0 then
		wdx, wdy = vectorFromAngle(random(0,360),random(200000,300000))
		WormHole():setPosition(wax,way):setTargetPosition(wax+wdx,way+wdy)
		plotW = nil
	end
end
------------------------------------
--	Generic or utility functions  --
------------------------------------
function tableRemoveRandom(array)
    local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
    local selected_item = math.random(array_item_count)
    array[selected_item], array[array_item_count] = array[array_item_count], array[selected_item]
    return table.remove(array)
end
function tableSelectRandom(array)
	local array_item_count = #array
    if array_item_count == 0 then
        return nil
    end
	return array[math.random(1,#array)]	
end
function vectorOn(obj,danger,radius,angle,list)
	if obj == nil then
		return
	end
	if danger == nil then
		danger = 1
	end
	if radius == nil then
		if isObjectType(obj,"PlayerSpaceship") then
			radius = obj:getLongRangeRadarRange()
		else
			radius = 30000
		end
	end
	if angle == nil then
		angle = random(0,360)
	end
	local enemy_list = {}
	local vx, vy = vectorFromAngle(angle,radius)
	local px, py = obj:getPosition()
	if list == nil then
		enemy_list = spawnEnemies(px+vx,py+vy,danger,"Kraylor",nil,10,"none")
	else
		enemy_list = list
	end
	local tier_max = 15
	local pyramid_tier = math.min(#enemy_list,tier_max)
	for index, ship in ipairs(enemy_list) do
		if index <= tier_max then
			local pyramid_angle = angle + formation_delta.pyramid[pyramid_tier][index].angle
			if pyramid_angle < 0 then 
				pyramid_angle = pyramid_angle + 360
			end
			pyramid_angle = pyramid_angle % 360
			rx, ry = vectorFromAngle(pyramid_angle,radius + formation_delta.pyramid[pyramid_tier][index].distance * 800)
			ship:setPosition(px+rx,py+ry)
		else
			ship:setPosition(px+vx,py+vy)
		end
		ship:setHeading((angle + 270) % 360)
		ship:orderFlyTowards(px,py)
	end
	return enemy_list
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
        VisualAsteroid():setPosition(x + random(-500,500),y + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
        VisualAsteroid():setPosition(x + random(-500,500),y + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
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
	        VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist + random(-500,500),y + math.sin(radialPoint / 180 * math.pi) * pointDist + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
	        VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist + random(-500,500),y + math.sin(radialPoint / 180 * math.pi) * pointDist + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
	        VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist + random(-500,500),y + math.sin(radialPoint / 180 * math.pi) * pointDist + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
	        VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist + random(-500,500),y + math.sin(radialPoint / 180 * math.pi) * pointDist + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			Asteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist):setSize(asteroid_size)
	        VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist + random(-500,500),y + math.sin(radialPoint / 180 * math.pi) * pointDist + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
	        VisualAsteroid():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist + random(-500,500),y + math.sin(radialPoint / 180 * math.pi) * pointDist + random(-500,500)):setSize(asteroid_size * random(.5,1.2))
		end
	end
end
function closestPlayerTo(obj)
-- Return the player ship closest to passed object parameter
-- Return nil if no valid result
-- Assumes a maximum of 8 player ships

	if obj ~= nil and obj:isValid() then
		local closestDistance = 9999999
		closestPlayer = nil
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance < closestDistance then
					closestPlayer = p
					closestDistance = currentDistance
				end
			end
		end
		return closestPlayer
	else
		return nil
	end
end
function farthestPlayerFrom(obj)
-- Return the player ship farthest from the passed object parameter
	if obj ~= nil and obj:isValid() then
		local farthestDistance = 0
		farthestPlayer = nil
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
			if p ~= nil and p:isValid() then
				local currentDistance = distance(p,obj)
				if currentDistance > farthestDistance then
					farthestPlayer = p
					farthestDistance = currentDistance
				end
			end
		end
		return farthestPlayer
	else
		return nil
	end
end
function closestStationTo(obj)
-- Return station closest to object
	if obj ~= nil and obj :isValid() then
		local closestDistance = 9999999
		closestStation = nil
		for sidx=1,#stationList do
			s = stationList[sidx]
			if s ~= nil and s:isValid() and s ~= obj then
				local currentDistance = distance(s,obj)
				if currentDistance < closestDistance then
					closestStation = s
					closestDistance = currentDistance
				end
			end
		end
		return closestStation
	else
		return nil
	end
end
function farthestStationTo(obj)
-- Return the station farthest from object
	if obj ~= nil and obj :isValid() then
		local farthestDistance = 0
		farthestStation = nil
		for sidx=1,#stationList do
			s = stationList[sidx]
			if s ~= nil and s:isValid() and s ~= obj then
				local currentDistance = distance(s,obj)
				if currentDistance > farthestDistance then
					farthestStation = s
					farthestDistance = currentDistance
				end
			end
		end
		return farthestStation
	else
		return nil
	end
end
function maintainStationLists()
	for i,station in ipairs(stationList) do
		if station == nil or not station:isValid() then
			stationList[i] = stationList[#stationList]
			stationList[#stationList] = nil
			break
		end
	end
	for i,station in ipairs(friendlyStationList) do
		if station == nil or not station:isValid() then
			friendlyStationList[i] = friendlyStationList[#friendlyStationList]
			friendlyStationList[#friendlyStationList] = nil
			break
		end
	end
	for i,station in ipairs(enemyStationList) do
		if station == nil or not station:isValid() then
			enemyStationList[i] = enemyStationList[#enemyStationList]
			enemyStationList[#enemyStationList] = nil
			break
		end
	end
end
--evaluate the players for enemy strength and size spawning purposes
function playerPower()
	playerShipScore = 0
	local players = getActivePlayerShips()
	for pidx, p5obj in ipairs(players) do
		if p5obj ~= nil and p5obj:isValid() then
			if p5obj.shipScore == nil then
				playerShipScore = playerShipScore + 24
			else
				playerShipScore = playerShipScore + p5obj.shipScore
			end
		end
	end
	return playerShipScore
end
function setPlayers()
--set up players with name, goods, cargo space, reputation and either a warp drive or a jump drive if applicable
	concurrentPlayerCount = 0
	local players = getActivePlayerShips()
	for pidx, pobj in ipairs(players) do
		if pobj ~= nil and pobj:isValid() then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if goods[pobj] == nil then
				goods[pobj] = goodsList
			end
			if pobj.initialRep == nil then
				pobj:addReputationPoints(180-(difficulty*6))
				pobj.initialRep = true
			end
			if not pobj.nameAssigned then
				pobj.nameAssigned = true
				pobj.spinUpgrade = false
				pobj.beamTimeUpgrade = false
				pobj.hullUpgrade = false
				local tempPlayerType = pobj:getTypeName()
				pobj.shipScore = player_ship_stats[tempPlayerType].strength
				pobj.maxCargo = player_ship_stats[tempPlayerType].cargo
				pobj:setLongRangeRadarRange(player_ship_stats[tempPlayerType].long_range_radar)
				pobj:setShortRangeRadarRange(player_ship_stats[tempPlayerType].short_range_radar)
				if #player_ship_names[tempPlayerType] > 0 then
					pobj:setCallSign(tableRemoveRandom(player_ship_names[tempPlayerType]))
				end
				if tempPlayerType == "MP52 Hornet" then
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Phobos M3P" then
					pobj:setWarpDrive(true)
				elseif tempPlayerType == "Player Fighter" then
					pobj.autoCoolant = false
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
					--            		  Arc, Dir,Range, Cyc,Dmg
					pobj:setBeamWeapon(0,  20,   0,	1200,	6,	8):setBeamWeaponDamageType(0,"emp"):setBeamWeaponArcColor(0,0,0,0.5,0,0,1.0)
					pobj:setBeamWeapon(1,  30,   0,	1000,	6,	8)
				elseif tempPlayerType == "Striker" then
					pobj:setJumpDrive(true)
					pobj:setJumpDriveRange(3000,40000)
					pobj:setImpulseMaxSpeed(90)
				elseif tempPlayerType == "ZX-Lindworm" then
					pobj.autoCoolant = false
					pobj:setWarpDrive(true)
				else
					if pobj.shipScore == nil then
						pobj:setCallSign(tableSelectRandom(player_ship_names["Leftovers"]))
						pobj.shipScore = 24
						pobj.maxCargo = 5
						pobj:setWarpDrive(true)
					end
				end
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
				end
			end
			pobj.initialCoolant = pobj:getMaxCoolant()
		end
	end
	setConcurrentPlayerCount = concurrentPlayerCount
end
function spawnEnemies(origin_x, origin_y, danger, faction, strength, pool_size, shape)
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
	if danger == nil then 
		danger = 1
	end
	if faction == nil then
		faction = "Exuari"
	end
--	print("danger in spawnEnemies: " .. danger)
	if strength == nil then
		strength = math.max(danger * enemy_power * playerPower(), 5)
	end
	if pool_size == nil then
		pool_size = 5
	end
	if shape == nil then
		shape = "square"
		if random(1,100) < 50 then
			shape = "hexagonal"
		end
	end
--	print("shape: " .. shape)
	local enemy_position = 0
	local sp = irandom(500,1000)			--random spacing of spawned group
	local enemy_list = {}
	while strength > 0 do
		local template_pool = {}
		for _, current_ship_template in ipairs(ship_template_by_strength) do
			if ship_template[current_ship_template].strength <= strength then
				table.insert(template_pool,current_ship_template)
			end
			if #template_pool >= pool_size then
				break
			end
		end
		if #template_pool > 0 then
			local selected_template = template_pool[math.random(1,#template_pool)]
			if ship_template[selected_template].create == nil then
				print("Selected ship template:",selected_template,"has no create function")
			end
			local ship = ship_template[selected_template].create(faction,selected_template)
			enemy_position = enemy_position + 1
			if shape == "none" then
				ship:setPosition(origin_x,origin_y)
			else
				ship:setPosition(origin_x + formation_delta[shape].x[enemy_position] * sp, origin_y + formation_delta[shape].y[enemy_position] * sp)
			end
			ship:setCommsScript(""):setCommsFunction(commsShip)
			table.insert(enemy_list, ship)
			ship:setCallSign(generateCallSign(nil,faction))
			strength = strength - ship_template[selected_template].strength
		else
			break
		end
	end
	return enemy_list
end
--Player ship health related functions
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		healthCheckCount = healthCheckCount + 1
		local players = getActivePlayerShips()
		for pidx, p in ipairs(players) do
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
					if random(1,100) <= (4 - difficulty) then
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
									p:addCustomMessage("Engineering",coolant_recovery,_("coolant-msgEngineer", "Automated systems have recovered some coolant"))
								end
								if p:hasPlayerAtPosition("Engineering+") then
									local coolant_recovery_plus = "coolant_recovery_plus"
									p:addCustomMessage("Engineering+",coolant_recovery_plus,_("coolant-msgEngineer+", "Automated systems have recovered some coolant"))
								end
							end
							resetPreviousSystemHealth(p)
						end
					end
				end
			end
		end
		healthCheckTimer = delta + healthCheckTimerInterval
	end
end
function resetPreviousSystemHealth(p)
	if p:getShieldCount() > 1 then
		p.prevShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
	else
		p.prevShield = p:getSystemHealth("frontshield")
	end
	p.prevReactor = p:getSystemHealth("reactor")
	p.prevManeuver = p:getSystemHealth("maneuver")
	p.prevImpulse = p:getSystemHealth("impulse")
	if p:getBeamWeaponRange(0) > 0 then
		p.prevBeam = p:getSystemHealth("beamweapons")
	end
	if p:getWeaponTubeCount() > 0 then
		p.prevMissile = p:getSystemHealth("missilesystem")
	end
	if p:hasWarpDrive() then
		p.prevWarp = p:getSystemHealth("warp")
	end
	if p:hasJumpDrive() then
		p.prevJump = p:getSystemHealth("jumpdrive")
	end
end
function crewFate(p, fatalityChance)
	if math.random() < (fatalityChance) then
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
		consequence = math.random(1,upper_consequence)
		if consequence == 1 then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,_("repairCrew-msgEngineer", "One of your repair crew has perished"))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("repairCrew-msgEngineer+", "One of your repair crew has perished"))
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
				p:addCustomMessage("Engineering",coolantLoss,_("coolant-msgEngineer", "Damage has caused a loss of coolant"))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local coolantLossPlus = "coolantLossPlus"
				p:addCustomMessage("Engineering+",coolantLossPlus,_("coolant-msgEngineer+", "Damage has caused a loss of coolant"))
			end
		else
			local named_consequence = consequence_list[consequence-2]
			if named_consequence == "probe" then
				p:setCanLaunchProbe(false)
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","probe_launch_damage_message",_("damage-msgEngineer", "The probe launch system has been damaged"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p:addCustomMessage("Engineering+","probe_launch_damage_message_plus",_("damage-msgEngineer+", "The probe launch system has been damaged"))
				end
				if p:hasPlayerAtPosition("Relay") then
					p:addCustomMessage("Relay","probe_launch_damage_message_relay",_("damage-msgRelay", "The probe launch system has been damaged"))
				end
				if p:hasPlayerAtPosition("Operations") then
					p:addCustomMessage("Operations","probe_launch_damage_message_ops",_("damage-msgOperations", "The probe launch system has been damaged"))
				end
			elseif named_consequence == "hack" then
				p:setCanHack(false)
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","hack_damage_message",_("damage-msgEngineer", "The hacking system has been damaged"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p:addCustomMessage("Engineering+","hack_damage_message_plus",_("damage-msgEngineer+", "The hacking system has been damaged"))
				end
				if p:hasPlayerAtPosition("Relay") then
					p:addCustomMessage("Relay","hack_damage_message_relay",_("damage-msgRelay", "The hacking system has been damaged"))
				end
				if p:hasPlayerAtPosition("Operations") then
					p:addCustomMessage("Operations","hack_damage_message_ops",_("damage-msgOperations", "The hacking system has been damaged"))
				end
			elseif named_consequence == "scan" then
				p:setCanScan(false)
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","scan_damage_message",_("damage-msgEngineer", "The scanners have been damaged"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p:addCustomMessage("Engineering+","scan_damage_message_plus",_("damage-msgEngineer+", "The scanners have been damaged"))
				end
				if p:hasPlayerAtPosition("Science") then
					p:addCustomMessage("Science","scan_damage_message_science",_("damage-msgScience", "The scanners have been damaged"))
				end
				if p:hasPlayerAtPosition("Operations") then
					p:addCustomMessage("Operations","scan_damage_message_ops",_("damage-msgOperations", "The scanners have been damaged"))
				end
			elseif named_consequence == "combat_maneuver" then
				p:setCanCombatManeuver(false)
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","combat_maneuver_damage_message",_("damage-msgEngineer", "Combat maneuver has been damaged"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus",_("damage-msgEngineer+", "Combat maneuver has been damaged"))
				end
				if p:hasPlayerAtPosition("Helms") then
					p:addCustomMessage("Helms","combat_maneuver_damage_message_helm",_("damage-msgHelms", "Combat maneuver has been damaged"))
				end
				if p:hasPlayerAtPosition("Tactical") then
					p:addCustomMessage("Tactical","combat_maneuver_damage_message_tac",_("damage-msgTactical", "Combat maneuver has been damaged"))
				end
			elseif named_consequence == "self_destruct" then
				p:setCanSelfDestruct(false)
				if p:hasPlayerAtPosition("Engineering") then
					p:addCustomMessage("Engineering","self_destruct_damage_message",_("damage-msgEngineer", "Self destruct system has been damaged"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					p:addCustomMessage("Engineering+","self_destruct_damage_message_plus",_("damage-msgEngineer+", "Self destruct system has been damaged"))
				end
			end
		end	--coolant loss branch
	end	--bad consequences of damage branch
end
function autoCoolant(delta)
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil and p:isValid() then
			if p.autoCoolant ~= nil then
				if p:hasPlayerAtPosition("Engineering") then
					if p.autoCoolButton == nil then
						tbi = "enableAutoCool" .. p:getCallSign()
						p:addCustomButton("Engineering",tbi,_("coolant-buttonEngineer", "Auto cool"),function()
							string.format("")
							p:setAutoCoolant(true)
							p:commandSetAutoRepair(true)
							p.autoCoolant = true
						end)
						tbi = "disableAutoCool" .. p:getCallSign()
						p:addCustomButton("Engineering",tbi,_("coolant-buttonEngineer", "Manual cool"),function()
							string.format("")
							p:setAutoCoolant(false)
							p:commandSetAutoRepair(false)
							p.autoCoolant = false
						end)
						p.autoCoolButton = true
					end
				end
				if p:hasPlayerAtPosition("Engineering+") then
					if p.autoCoolButton == nil then
						tbi = "enableAutoCoolPlus" .. p:getCallSign()
						p:addCustomButton("Engineering+",tbi,_("coolant-buttonEngineer+", "Auto cool"),function()
							string.format("")
							p:setAutoCoolant(true)
							p:commandSetAutoRepair(true)
							p.autoCoolant = true
						end)
						tbi = "disableAutoCoolPlus" .. p:getCallSign()
						p:addCustomButton("Engineering+",tbi,_("coolant-buttonEngineer+", "Manual cool"),function()
							string.format("")
							p:setAutoCoolant(false)
							p:commandSetAutoRepair(false)
							p.autoCoolant = false
						end)
						p.autoCoolButton = true
					end
				end
			end
		end
	end
end
--gain/lose coolant from nebula functions
function updateCoolantGivenPlayer(p, delta)
	if p.configure_coolant_timer == nil then
		p.configure_coolant_timer = delta + 5
	end
	p.configure_coolant_timer = p.configure_coolant_timer - delta
	if p.configure_coolant_timer < 0 then
		if p.deploy_coolant_timer == nil then
			p.deploy_coolant_timer = delta + 5
		end
		p.deploy_coolant_timer = p.deploy_coolant_timer - delta
		if p.deploy_coolant_timer < 0 then
			gather_coolant_status = _("coolant-tabEngineer", "Gathering Coolant")
			p:setMaxCoolant(p:getMaxCoolant() + coolant_gain)
			if p:getMaxCoolant() > 50 and random(1,100) <= 13 then
				local engine_choice = math.random(1,3)
				if engine_choice == 1 then
					p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverseEffect)
				elseif engine_choice == 2 then
					if p:hasWarpDrive() then
						p:setSystemHealth("warp",p:getSystemHealth("warp")*adverseEffect)
					end
				else
					if p:hasJumpDrive() then
						p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverseEffect)
					end
				end
			end
		else
			gather_coolant_status = string.format(_("coolant-tabEngineer", "Deploying Collectors %i"),math.ceil(p.deploy_coolant_timer - delta))
		end
	else
		gather_coolant_status = string.format(_("coolant-tabEngineer", "Configuring Collectors %i"),math.ceil(p.configure_coolant_timer - delta))
	end
	if p:hasPlayerAtPosition("Engineering") then
		p.gather_coolant = "gather_coolant"
		p:addCustomInfo("Engineering",p.gather_coolant,gather_coolant_status)
	end
	if p:hasPlayerAtPosition("Engineering+") then
		p.gather_coolant_plus = "gather_coolant_plus"
		p:addCustomInfo("Engineering",p.gather_coolant_plus,gather_coolant_status)
	end
end
function getCoolantGivenPlayer(p)
	if p:hasPlayerAtPosition("Engineering") then
		if p.get_coolant_button ~= nil then
			p:removeCustom(p.get_coolant_button)
			p.get_coolant_button = nil
		end
	end
	if p:hasPlayerAtPosition("Engineering+") then
		if p.get_coolant_button_plus ~= nil then
			p:removeCustom(p.get_coolant_button_plus)
			p.get_coolant_button_plus = nil
		end
	end
	p.coolant_trigger = true
end
--final page for victory or defeat on main streen. Station stats only for now
function endStatistics()
	destroyedStations = 0
	survivedStations = 0
	destroyedFriendlyStations = 0
	survivedFriendlyStations = 0
	destroyedNeutralStations = 0
	survivedNeutralStations = 0
	for idx, station in pairs(originalStationList) do
		tp = getPlayerShip(-1)
		if tp ~= nil and tp:isValid() then
			if station:isFriendly(tp) then
				if station:isValid() then
					survivedStations = survivedStations + 1
					survivedFriendlyStations = survivedFriendlyStations + 1
				end
			else
				if station:isValid() then
					survivedStations = survivedStations + 1
					survivedNeutralStations = survivedNeutralStations + 1
				end
			end
		end
	end
	destroyedStations = (startingFriendlyStations + startingNeutralStations) - survivedStations
	destroyedFriendlyStations = startingFriendlyStations - survivedFriendlyStations
	destroyedNeutralStations = startingNeutralStations - survivedNeutralStations
	enemyStationsSurvived = 0
	for idx, station in pairs(enemyStationList) do
		if station:isValid() then
			enemyStationsSurvived = enemyStationsSurvived + 1
		end
	end
	destroyedEnemyStations = startingEnemyStations - enemyStationsSurvived
	gMsg = string.format(_("msgMainscreen", "Stations: %i\t survived: %i\t destroyed: %i"),(startingFriendlyStations + startingNeutralStations),survivedStations,destroyedStations)
	gMsg = gMsg .. string.format(_("msgMainscreen", "\nFriendly Stations: %i\t survived: %i\t destroyed: %i"),startingFriendlyStations,survivedFriendlyStations,destroyedFriendlyStations)
	gMsg = gMsg .. string.format(_("msgMainscreen", "\nNeutral Stations: %i\t survived: %i\t destroyed: %i"),startingNeutralStations,survivedNeutralStations,destroyedNeutralStations)
	gMsg = gMsg .. string.format(_("msgMainscreen", "\n\n\n\nEnemy Stations: %i\t survived: %i\t destroyed: %i"),startingEnemyStations,enemyStationsSurvived,destroyedEnemyStations)
--	gMsg = gMsg .. string.format(_("msgMainscreen", "\n\n\n\nRequired missions completed: %i"),requiredMissionCount)
	rankVal = survivedFriendlyStations/startingFriendlyStations*.6 + survivedNeutralStations/startingNeutralStations*.2 + (1-enemyStationsSurvived/startingEnemyStations)*.2
	if missionVictory then
		if rankVal < .7 then
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
		gMsg = gMsg .. string.format(_("msgMainscreen", "\nEarned rank:  %s"), rank)
	else
		if rankVal < .6 then
			rank = _("msgMainscreen", "Ensign")
		elseif rankVal < .7 then
			rank = _("msgMainscreen", "Lieutenant")
		elseif rankVal < .8 then
			rank = _("msgMainscreen", "Commander")
		elseif rankVal < .9 then
			rank = _("msgMainscreen", "Captain")
		else
			rank = _("msgMainscreen", "Admiral")
		end
		if getScenarioSetting("Goal") == "Hunter" then
			gMsg = gMsg .. string.format(_("msgMainscreen", "\nPost Target Enemy Base Survival Rank: %s"), rank)
		else
			gMsg = gMsg .. string.format(_("msgMainscreen", "\nPost Home Base Destruction Rank: %s"), rank)
		end
		-- Yes, the ranking is more forgiving when defeated for these reasons:
		-- 1) With so many deaths on the station, leadership roles have opened up
		--    1a) Reciprocal: Harder to get promoted when you succeed with so many surviving competing officers
		-- 2) Simulation of whacky military promotion politics
		-- 3) Incentive to play the mission again
	end
	globalMessage(gMsg)
end

function update(delta)
	concurrentPlayerCount = 0
	if homeStation ~= nil and homeStation:isValid() and homeStation.telemetry ~= nil and homeStation.telemetry then
		local shield_count = homeStation:getShieldCount()
		local shield_index = 0
		local shield_max = homeStation:getShieldMax(0)
		local lowest_shield = shield_max
		repeat
			local current_shield_level = homeStation:getShieldLevel(shield_index)
			if current_shield_level < lowest_shield then
				lowest_shield = current_shield_level
			end
			shield_index = shield_index + 1
		until(shield_index >= shield_count)
		if lowest_shield < shield_max then
			local shield_label = "S"
			if shield_count > 1 then
				shield_label = "WS"
			end
			home_station_health = string.format(_("homeStationHealth-tabRelay&Operations", "%s %s:%i%% H:%i%%"),homeStation:getCallSign(),shield_label,math.floor(lowest_shield/shield_max*100),math.floor(homeStation:getHull()/homeStation:getHullMax()*100))
		else
			home_station_health = nil
		end
	end
	local players = getActivePlayerShips()
	for pidx, p in ipairs(players) do
		if p ~= nil then
			concurrentPlayerCount = concurrentPlayerCount + 1
			if p:isValid() then
				--home station telemetry
				if home_station_health ~= nil then
					if p:hasPlayerAtPosition("Relay") then
						p.home_station_status = "home_station_status"
						p:addCustomInfo("Relay",p.home_station_status,home_station_health)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.home_station_status_ops = "home_station_status_ops"
						p:addCustomInfo("Operations",p.home_station_status_ops,home_station_health)
					end
				else
					if p.home_station_status ~= nil then
						p:removeCustom(p.home_station_status)
						p.home_station_status = nil
					end
					if p.home_station_status_ops ~= nil then
						p:removeCustom(p.home_station_status_ops)
						p.home_station_status_ops = nil
					end
				end
				--nebula/coolant interaction
				local inside_gain_coolant_nebula = false
				for i=1,#coolant_nebula do
					if coolant_nebula[i]:isValid() then
						if distance(p,coolant_nebula[i]) < 5000 then
							if coolant_nebula[i].lose then
								p:setMaxCoolant(p:getMaxCoolant()*coolant_loss)
								if p:getMaxCoolant() > 50 and random(1,100) <= 13 then
									local engine_choice = math.random(1,3)
									if engine_choice == 1 then
										p:setSystemHealth("impulse",p:getSystemHealth("impulse")*adverseEffect)
									elseif engine_choice == 2 then
										if p:hasWarpDrive() then
											p:setSystemHealth("warp",p:getSystemHealth("warp")*adverseEffect)
										end
									else
										if p:hasJumpDrive() then
											p:setSystemHealth("jumpdrive",p:getSystemHealth("jumpdrive")*adverseEffect)
										end
									end
								end
							end
							if coolant_nebula[i].gain then
								inside_gain_coolant_nebula = true
							end
						end
					end
				end
				if inside_gain_coolant_nebula then
					if p.get_coolant then
						if p.coolant_trigger then
							updateCoolantGivenPlayer(p, delta)
						end
					else
						if p:hasPlayerAtPosition("Engineering") then
							p.get_coolant_button = "get_coolant_button"
							p:addCustomButton("Engineering",p.get_coolant_button,_("coolant-buttonEngineer", "Get Coolant"),function()
								string.format("")
								getCoolantGivenPlayer(p)
							end)
							p.get_coolant = true
						end
						if p:hasPlayerAtPosition("Engineering+") then
							p.get_coolant_button_plus = "get_coolant_button_plus"
							p:addCustomButton("Engineering+",p.get_coolant_button_plus,_("coolant-buttonEngineer+", "Get Coolant"),function()
								string.format("")
								getCoolantGivenPlayer(p)
							end)
							p.get_coolant = true
						end
					end
				else
					p.get_coolant = false
					p.coolant_trigger = false
					p.configure_coolant_timer = nil
					p.deploy_coolant_timer = nil
					if p:hasPlayerAtPosition("Engineering") then
						if p.get_coolant_button ~= nil then
							p:removeCustom(p.get_coolant_button)
							p.get_coolant_button = nil
						end
						if p.gather_coolant ~= nil then
							p:removeCustom(p.gather_coolant)
							p.gather_coolant = nil
						end
					end
					if p:hasPlayerAtPosition("Engineering+") then
						if p.get_coolant_button_plus ~= nil then
							p:removeCustom(p.get_coolant_button_plus)
							p.get_coolant_button_plus = nil
						end
						if p.gather_coolant_plus ~= nil then
							p:removeCustom(p.gather_coolant_plus)
							p.gather_coolant_plus = nil
						end
					end
				end
				
				
			end
		end
	end
	if concurrentPlayerCount > highestConcurrentPlayerCount then
		highestConcurrentPlayerCount = concurrentPlayerCount
	end
	if setConcurrentPlayerCount ~= highestConcurrentPlayerCount then
		setPlayers()
	end
	if delta == 0 then
		--game paused
		setPlayers()
		return
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if difficultySpecificSetup == nil then
		difficultySpecificSetup = "done"
		if difficulty >= 1 then
			tesx, tesy = targetEnemyStation:getPosition()
			wpRadius = 3000
			wpAngle = random(0,360)
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp9 = CpuShip():setCallSign("WP-9"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp15 = CpuShip():setCallSign("WP-15"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp46 = CpuShip():setCallSign("WP-46"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
			wpAngle = wpAngle + 90
			rx, ry = vectorFromAngle(wpAngle,wpRadius)
			wp20 = CpuShip():setCallSign("WP-20"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
		end
		if difficulty > 1 then
			tesx, tesy = targetEnemyStation:getPosition()
			wp66cpos = 0
			rx, ry = vectorFromAngle(wp66cpos,6000)
			wp66 = CpuShip():setCallSign("WP-66"):setFaction(stationFaction):setPosition(tesx+rx,tesy+ry):setTemplate("Defense platform"):orderRoaming()
		end		
	end
	if difficulty > 1 then
		if wp66:isValid() then
			wp66cpos = wp66cpos + .1
			if wp66cpos >= 360 then
				wp66cpos = 0
			end
			rx, ry = vectorFromAngle(wp66cpos, 6000)
			wp66:setPosition(tesx+rx,tesy+ry)
		end
	end
	if homeStation:isValid() then
		if homeStationRotationEnabled then
			homeStation:setRotation(homeStation:getRotation()+.1)
			if homeStation:getRotation() >= 360 then
				homeStation:setRotation(0)
			end
		end
	end
	anetx, anety = vectorFromAngle(stationAnet.angle,3000)
	stationAnet:setPosition(aldx+anetx,aldy+anety):setRotation(stationAnet.angle)
	stationAnet.angle = stationAnet.angle + .05
	if stationAnet.angle >= 360 then
		stationAnet.angle = 0
	end
	if plot6 ~= nil then	--timed game
		plot6(delta)
	end
	if plot1 ~= nil then	--initial and primary plot
		plot1(delta)
	end
	if plot2 ~= nil then	--delivery, spin upgrade, base intelligence, warp jam
		plot2(delta)
	end
	if plot4 ~= nil then	--deliver, base rotate, beam time/hull upgrades
		plot4(delta)
	end
	healthCheck(delta)
	moveAsteroids()
	moveNebulae()
	transportPlot(delta)
	if plot3 ~= nil then	--intelligence over time
		plot3(delta)
	end
	if plotW ~= nil then	--worm artifact
		plotW(delta)
	end
	autoCoolant(delta)
	if plot5 ~= nil then	--helpful warning
		plot5(delta)
	end
end