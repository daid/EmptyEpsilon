-- Name: Shipyard Inspection
-- Description: Evaluate the newest ship provided by the shipyard
--- 
--- Designed as an introductory mission for one player ship. The terrain differs each game, though the mission goals are the same.
---
--- Duration: 20 - 50 minutes
---
--- Version 1
---
--- USN Discord: https://discord.gg/PntGG3a where you can join a game online. There's one every Saturday at 1600 UTC (aka GMT or Zulu). All experience levels are welcome. 
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
-- Setting[Reputation]: Amount of reputation to start with
-- Reputation[Unknown|Default]: Zero reputation - nobody knows anything about you
-- Reputation[Nice]: 20 reputation - you've had a small positive influence on the local community
-- Reputation[Hero]: 50 reputation - you helped important people or lots of people
-- Reputation[Major Hero]: 100 reputation - you're well known by nearly everyone as a force for good
-- Reputation[Super Hero]: 200 reputation - everyone knows you and relies on you for help

require("utils.lua")
require("place_station_scenario_utility.lua")
require("generate_call_sign_scenario_utility.lua")
require("cpu_ship_diversification_scenario_utility.lua")
--	also uses supply_drop.lua
--	Relies on changes to corvette.lua in the shipTemplates folder
--	Requires corsair.png in the resources/radar folder

--------------------
-- Initialization --
--------------------
function init()
	scenario_version = "1.0.0"
	print(string.format("     -----     Scenario: Shipyard     -----     Version %s     -----",scenario_version))
	print(_VERSION)
	spawn_enemy_diagnostic = false
	setVariations()	--numeric difficulty, Kraylor fortress size
	setConstants()	--missle type names, template names and scores, deployment directions, player ship names, etc.
	constructEnvironment()
	setGMButtons()
	mainGMButtons()
	onNewPlayerShip(setPlayers)
end
function setVariations()
	if getScenarioSetting == nil then
		enemy_power = 1
		difficulty = 1
		adverseEffect = .995
		coolant_loss = .99995
		coolant_gain = .001
		danger_pace = 300
		reputation_start_amount = 0
		upgrade_price = 1
	else
		local enemy_config = {
			["Easy"] =		{number = .5},
			["Normal"] =	{number = 1},
			["Hard"] =		{number = 2},
			["Extreme"] =	{number = 3},
			["Quixotic"] =	{number = 5},
		}
		enemy_power =	enemy_config[getScenarioSetting("Enemies")].number
		local murphy_config = {
			["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005,	interruption_threshold = 9},
			["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001,	interruption_threshold = 6},
			["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001,	interruption_threshold = 3},
		}
		difficulty =	murphy_config[getScenarioSetting("Murphy")].number
		--	affects:
		--		sensor buoy scan complexity and depth (ads, transport info, station info)
		--		sensor jammer scan complexity and depth
		--		nebula concealment of mine fields
		--		availability of gossip
		--		repair crew availability
		--		coolant availability
		--		named character availability
		--		taunted enemy retaliation choice possibilities
		--		revival of repair crew chance when zero repair crew present
		adverseEffect =				murphy_config[getScenarioSetting("Murphy")].adverse
		coolant_loss =				murphy_config[getScenarioSetting("Murphy")].lose_coolant
		coolant_gain =				murphy_config[getScenarioSetting("Murphy")].gain_coolant
		interruption_threshold =	murphy_config[getScenarioSetting("Murphy")].interruption_threshold
		local reputation_config = {
			["Unknown"] = 		0,
			["Nice"] = 			20,
			["Hero"] = 			50,
			["Major Hero"] =	100,
			["Super Hero"] =	200,
		}
		reputation_start_amount = reputation_config[getScenarioSetting("Reputation")]
		danger_pace = 300
	end
end
function setConstants()
	far_enough_fail = false
	distance_diagnostic = false
	stationCommsDiagnostic = false
	change_enemy_order_diagnostic = false
	healthDiagnostic = false
	sensor_jammer_diagnostic = false
	sj_diagnostic = false	--short sensor jammer diagnostic, once at env create
	player_ship_spawn_count = 0
	player_ship_death_count = 0
	max_repeat_loop = 300
	center_x = 909000 + random(-300000,300000)
	center_y = 211000 + random(-60000,60000)
	primary_orders = _("orders-comms","Survive")
	plotCI = cargoInventory
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimerInterval = 8
	healthCheckTimer = healthCheckTimerInterval
	prefix_length = 0
	suffix_index = 0
	cpu_ships = {}
	star_list = {
		{radius = random(600,1400), distance = random(-2500,-1400), 
			name = {"Gamma Piscium","Beta Lyporis","Sigma Draconis","Iota Carinae","Theta Arietis","Epsilon Indi","Beta Hydri"},
			color = {
				red = random(0.8,1), green = random(0.8,1), blue = random(0.8,1)
			},
			texture = {
				atmosphere = "planets/star-1.png"
			},
		},
	}	
	station_defend_dist = {
		["Small Station"] = 2800,
		["Medium Station"] = 4200,
		["Large Station"] = 4800,
		["Huge Station"] = 5200,
	}
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
	character_names = {
		"Frank Brown",
		"Joyce Miller",
		"Harry Jones",
		"Emma Davis",
		"Zhang Wei Chen",
		"Yu Yan Li",
		"Li Wei Wang",
		"Li Na Zhao",
		"Sai Laghari",
		"Anaya Khatri",
		"Vihaan Reddy",
		"Trisha Varma",
		"Henry Gunawan",
		"Putri Febrian",
		"Stanley Hartono",
		"Citra Mulyadi",
		"Bashir Pitafi",
		"Hania Kohli",
		"Gohar Lehri",
		"Sohelia Lau",
		"Gabriel Santos",
		"Ana Melo",
		"Lucas Barbosa",
		"Juliana Rocha",
		"Habib Oni",
		"Chinara Adebayo",
		"Tanimu Ali",
		"Naija Bello",
		"Shamim Khan",
		"Barsha Tripura",
		"Sumon Das",
		"Farah Munsi",
		"Denis Popov",
		"Pasha Sokolov",
		"Burian Ivanov",
		"Radka Vasiliev",
		"Jose Hernandez",
		"Victoria Garcia",
		"Miguel Lopez",
		"Renata Rodriguez",
	}
	--Player ship name lists to supplant standard randomized call sign generation
	player_ship_names_for = {}
	player_ship_names_for["Amalgam"] = {"Mixer","Igor","Ronco","Ginsu"}
	player_ship_names_for["Atlantis"] = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	player_ship_names_for["Atlantis MK2"] = {"Katana","Forthright","Expedition","Golden Era","Devestator"}
	player_ship_names_for["Atlantis II"] = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	player_ship_names_for["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	player_ship_names_for["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	player_ship_names_for["Corsair"] = {"Vamanos", "Cougar", "Parthos", "Trifecta", "Light Mind"}
	player_ship_names_for["Destroyer III"] = {"Trebuchet", "Pitcher", "Mutant", "Gronk", "Methuselah"}
	player_ship_names_for["Ender"] = {"Mongo","Godzilla","Leviathan","Kraken","Jupiter","Saturn"}
	player_ship_names_for["Flavia P.Falcon"] = {"Ladyhawke","Hunter","Seeker","Gyrefalcon","Kestrel","Magpie","Bandit","Buccaneer"}
	player_ship_names_for["Hathcock"] = {"Hayha", "Waldron", "Plunkett", "Mawhinney", "Furlong", "Zaytsev", "Pavlichenko", "Pegahmagabow", "Fett", "Hawkeye", "Hanzo"}
	player_ship_names_for["Kiriya"] = {"Cavour","Reagan","Gaulle","Paulo","Truman","Stennis","Kuznetsov","Roosevelt","Vinson","Old Salt"}
	player_ship_names_for["MP52 Hornet"] = {"Dragonfly","Scarab","Mantis","Yellow Jacket","Jimminy","Flik","Thorny","Buzz"}
	player_ship_names_for["Maverick"] = {"Angel", "Thunderbird", "Roaster", "Magnifier", "Hedge"}
	player_ship_names_for["Midian"] = {"Flipper", "Feint", "Dolphin", "Joker", "Trickster"}
	player_ship_names_for["Nautilus"] = {"October", "Abdiel", "Manxman", "Newcon", "Nusret", "Pluton", "Amiral", "Amur", "Heinkel", "Dornier"}
	player_ship_names_for["Phobos M3P"] = {"Blinder","Shadow","Distortion","Diemos","Ganymede","Castillo","Thebe","Retrograde"}
	player_ship_names_for["Piranha"] = {"Razor","Biter","Ripper","Voracious","Carnivorous","Characid","Vulture","Predator"}
	player_ship_names_for["Player Cruiser"] = {"Excelsior","Velociraptor","Thunder","Kona","Encounter","Perth","Aspern","Panther"}
	player_ship_names_for["Player Fighter"] = {"Buzzer","Flitter","Zippiticus","Hopper","Molt","Stinger","Stripe"}
	player_ship_names_for["Player Missile Cr."] = {"Projectus","Hurlmeister","Flinger","Ovod","Amatola","Nakhimov","Antigone"}
	player_ship_names_for["Proto-Atlantis"] = {"Narsil", "Blade", "Decapitator", "Trisect", "Sabre"}
	player_ship_names_for["Raven"] = {"Claw", "Bethel", "Cicero", "Da Vinci", "Skaats"}
	player_ship_names_for["Redhook"] = {"Headhunter", "Thud", "Troll", "Scalper", "Shark"}
	player_ship_names_for["Repulse"] = {"Fiddler","Brinks","Loomis","Mowag","Patria","Pandur","Terrex","Komatsu","Eitan"}
	player_ship_names_for["Squid"] = {"Ink", "Tentacle", "Pierce", "Writhe", "Bogey"}
	player_ship_names_for["Stricken"] = {"Blazon", "Streaker", "Pinto", "Spear", "Javelin"}
	player_ship_names_for["Striker"] = {"Sparrow","Sizzle","Squawk","Crow","Phoenix","Snowbird","Hawk"}
	player_ship_names_for["Surkov"] = {"Sting", "Sneak", "Bingo", "Thrill", "Vivisect"}
	player_ship_names_for["ZX-Lindworm"] = {"Seagull","Catapult","Blowhard","Flapper","Nixie","Pixie","Tinkerbell"}
	player_ship_names_for["Leftovers"] = {"Foregone","Righteous","Masher"}
	missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
	pool_selectivity = "full"
	template_pool_size = 15
	ship_template = {	--ordered by relative strength
		["Gnat"] =				{strength = 2,		create = gnat},
		["Lite Drone"] =		{strength = 3,		create = droneLite},
		["Jacket Drone"] =		{strength = 4,		create = droneJacket},
		["Ktlitan Drone"] =		{strength = 4,		create = stockTemplate},
		["Heavy Drone"] =		{strength = 5,		create = droneHeavy},
		["MT52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MU52 Hornet"] =		{strength = 5,		create = stockTemplate},
		["MV52 Hornet"] =		{strength = 6,		create = hornetMV52},
		["Adder MK3"] =			{strength = 5,		create = stockTemplate},
		["Adder MK4"] =			{strength = 6,		create = stockTemplate},
		["Fighter"] =			{strength = 6,		create = stockTemplate},
		["Ktlitan Fighter"] =	{strength = 6,		create = stockTemplate},
		["K2 Fighter"] =		{strength = 7,		create = k2fighter},
		["Adder MK5"] =			{strength = 7,		create = stockTemplate},
		["WX-Lindworm"] =		{strength = 7,		create = stockTemplate},
		["K3 Fighter"] =		{strength = 8,		create = k3fighter},
		["Adder MK6"] =			{strength = 8,		create = stockTemplate},
		["Ktlitan Scout"] =		{strength = 8,		create = stockTemplate},
		["WZ-Lindworm"] =		{strength = 9,		create = wzLindworm},
		["Adder MK7"] =			{strength = 9,		create = stockTemplate},
		["Adder MK8"] =			{strength = 10,		create = stockTemplate},
		["Adder MK9"] =			{strength = 11,		create = stockTemplate},
		["Nirvana R3"] =		{strength = 12,		create = stockTemplate},
		["Phobos R2"] =			{strength = 13,		create = phobosR2},
		["Missile Cruiser"] =	{strength = 14,		create = stockTemplate},
		["Waddle 5"] =			{strength = 15,		create = waddle5},
		["Jade 5"] =			{strength = 15,		create = jade5},
		["Phobos T3"] =			{strength = 15,		create = stockTemplate},
		["Piranha F8"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12"] =		{strength = 15,		create = stockTemplate},
		["Piranha F12.M"] =		{strength = 16,		create = stockTemplate},
		["Phobos M3"] =			{strength = 16,		create = stockTemplate},
		["Farco 3"] =			{strength = 16,		create = farco3},
		["Farco 5"] =			{strength = 16,		create = farco5},
		["Karnack"] =			{strength = 17,		create = stockTemplate},
		["Gunship"] =			{strength = 17,		create = stockTemplate},
		["Phobos T4"] =			{strength = 18,		create = phobosT4},
		["Cruiser"] =			{strength = 18,		create = stockTemplate},
		["Nirvana R5"] =		{strength = 19,		create = stockTemplate},
		["Farco 8"] =			{strength = 19,		create = farco8},
		["Nirvana R5A"] =		{strength = 20,		create = stockTemplate},
		["Adv. Gunship"] =		{strength = 20,		create = stockTemplate},
		["Ktlitan Worker"] =	{strength = 21,		create = stockTemplate},
		["Farco 11"] =			{strength = 21,		create = farco11},
		["Storm"] =				{strength = 22,		create = stockTemplate},
		["Stalker R5"] =		{strength = 22,		create = stockTemplate},
		["Stalker Q5"] =		{strength = 22,		create = stockTemplate},
		["Farco 13"] =			{strength = 24,		create = farco13},
		["Ranus U"] =			{strength = 25,		create = stockTemplate},
		["Stalker Q7"] =		{strength = 25,		create = stockTemplate},
		["Stalker R7"] =		{strength = 25,		create = stockTemplate},
		["Whirlwind"] =			{strength = 26,		create = whirlwind},
		["Adv. Striker"] =		{strength = 27,		create = stockTemplate},
		["Elara P2"] =			{strength = 28,		create = stockTemplate},
		["Tempest"] =			{strength = 30,		create = tempest},
		["Strikeship"] =		{strength = 30,		create = stockTemplate},
		["Fiend G3"] =			{strength = 33,		create = stockTemplate},
		["Maniapak"] =			{strength = 34,		create = maniapak},
		["Fiend G4"] =			{strength = 35,		create = stockTemplate},
		["Cucaracha"] =			{strength = 36,		create = cucaracha},
		["Fiend G5"] =			{strength = 37,		create = stockTemplate},
		["Fiend G6"] =			{strength = 39,		create = stockTemplate},
		["Predator"] =			{strength = 42,		create = predator},
		["Ktlitan Breaker"] =	{strength = 45,		create = stockTemplate},
		["Hurricane"] =			{strength = 46,		create = hurricane},
		["Ktlitan Feeder"] =	{strength = 48,		create = stockTemplate},
		["Atlantis X23"] =		{strength = 50,		create = stockTemplate},
		["K2 Breaker"] =		{strength = 55,		create = k2breaker},
		["Ktlitan Destroyer"] =	{strength = 50,		create = stockTemplate},
		["Atlantis Y42"] =		{strength = 60,		create = atlantisY42},
		["Blockade Runner"] =	{strength = 65,		create = stockTemplate},
		["Starhammer II"] =		{strength = 70,		create = stockTemplate},
		["Enforcer"] =			{strength = 75,		create = enforcer},
		["Dreadnought"] =		{strength = 80,		create = stockTemplate},
		["Starhammer III"] =	{strength = 85,		create = starhammerIII},
		["Starhammer V"] =		{strength = 90,		create = starhammerV},
		["Battlestation"] =		{strength = 100,	create = stockTemplate},
		["Tyr"] =				{strength = 150,	create = tyr},
		["Odin"] =				{strength = 250,	create = stockTemplate},
	}
	shipTemplateDistance = {
		["Adder MK3"] =						100,
		["Adder MK4"] =						100,
		["Adder MK5"] =						100,
		["Adder MK6"] =						100,
		["Adder MK7"] =						100,
		["Adder MK8"] =						100,
		["Adder MK9"] =						100,
		["Adv. Gunship"] =					400,
		["Adv. Striker"] = 					300,
		["Atlantis X23"] =					400,
		["Atlantis Y42"] =					400,
		["Battlestation"] =					2000,
		["Blockade Runner"] =				400,
		["Blade"] =							300,
		["Buster"] =						100,
		["Courier"] =						600,
		["Cruiser"] =						200,
		["Cucaracha"] =						200,
		["Dagger"] =						100,
		["Dash"] =							200,
		["Defense platform"] =				800,
		["Diva"] =							350,
		["Dread No More"] =					400,
		["Dreadnought"] =					400,
		["Elara P2"] =						200,
		["Enforcer"] =						400,
		["Enforcer V2"] =					400,
		["Equipment Freighter 1"] =			600,
		["Equipment Freighter 2"] =			600,
		["Equipment Freighter 3"] =			600,
		["Equipment Freighter 4"] =			800,
		["Equipment Freighter 5"] =			800,
		["Equipment Jump Freighter 3"] =	600,
		["Equipment Jump Freighter 4"] =	800,
		["Equipment Jump Freighter 5"] =	800,
		["Farco 3"] =						200,
		["Farco 5"] =						200,
		["Farco 8"] =						200,
		["Farco 11"] =						200,
		["Farco 13"] =						200,
		["Fiend G3"] =						400,
		["Fiend G4"] =						400,
		["Fiend G5"] =						400,
		["Fiend G6"] =						400,
		["Fighter"] =						100,
		["Flash"] =							100,
		["Flavia"] =						200,
		["Flavia Falcon"] =					200,
		["Fortress"] =						2000,
		["Fuel Freighter 1"] =				600,
		["Fuel Freighter 2"] =				600,
		["Fuel Freighter 3"] =				600,
		["Fuel Freighter 4"] =				800,
		["Fuel Freighter 5"] =				800,
		["Fuel Jump Freighter 3"] =			600,
		["Fuel Jump Freighter 4"] =			800,
		["Fuel Jump Freighter 5"] =			800,
		["Garbage Freighter 1"] =			600,
		["Garbage Freighter 2"] =			600,
		["Garbage Freighter 3"] =			600,
		["Garbage Freighter 4"] =			800,
		["Garbage Freighter 5"] =			800,
		["Garbage Jump Freighter 3"] =		600,
		["Garbage Jump Freighter 4"] =		800,
		["Garbage Jump Freighter 5"] =		800,
		["Gnat"] =							300,
		["Goods Freighter 1"] =				600,
		["Goods Freighter 2"] =				600,
		["Goods Freighter 3"] =				600,
		["Goods Freighter 4"] =				800,
		["Goods Freighter 5"] =				800,
		["Goods Jump Freighter 3"] =		600,
		["Goods Jump Freighter 4"] =		800,
		["Goods Jump Freighter 5"] =		800,
		["Guard"] =							600,	--transport_1_1
		["Gulper"] =						400,
		["Gunner"] =						100,
		["Gunship"] =						400,
		["Heavy Drone"] = 					300,
		["Hunter"] =						200,
		["Jacket Drone"] =					300,
		["Jade 5"] =						100,
		["Jagger"] =						100,
		["Jump Carrier"] =					800,		
		["Karnack"] =						200,
		["K2 Fighter"] =					300,
		["K3 Fighter"] =					300,
		["Ktlitan Breaker"] =				300,
		["Ktlitan Destroyer"] = 			500,
		["Ktlitan Drone"] =					300,
		["Ktlitan Feeder"] =				300,
		["Ktlitan Fighter"] =				300,
		["Ktlitan Queen"] =					500,
		["Ktlitan Scout"] =					300,
		["Ktlitan Worker"] =				300,
		["Laden Lorry"] =					600,
		["Lite Drone"] = 					300,
		["Loki"] =							1500,
		["Maniapak"] =						100,
		["Missile Cruiser"] =				200,
		["MT52 Hornet"] =					100,
		["MT55 Hornet"] =					100,
		["MU52 Hornet"] =					100,
		["MU55 Hornet"] =					100,
		["Munemi"] =						100,
		["MV52 Hornet"] =					100,
		["Nirvana R3"] =					200,
		["Nirvana R5"] =					200,
		["Nirvana R5A"] =					200,
		["Odin"] = 							1500,
		["Omnibus"] = 						800,
		["Personnel Freighter 1"] =			600,
		["Personnel Freighter 2"] =			600,
		["Personnel Freighter 3"] =			600,
		["Personnel Freighter 4"] =			800,
		["Personnel Freighter 5"] =			800,
		["Personnel Jump Freighter 3"] =	600,
		["Personnel Jump Freighter 4"] =	800,
		["Personnel Jump Freighter 5"] =	800,
		["Phobos M3"] =						200,
		["Phobos R2"] =						200,
		["Phobos T3"] =						200,
		["Phobos T4"] =						200,
		["Physics Research"] =				600,
		["Piranha F10"] =					200,
		["Piranha F12"] =					200,
		["Piranha F12.M"] =					200,
		["Piranha F8"] =					200,
		["Prador"] =						2000,
		["Predator"] =						200,
		["Predator V2"] =					200,
		["Racer"] =							200,
		["Ranger"] =						100,
		["Ranus U"] =						200,
		["Roc"] =							200,
		["Ryder"] =							2000,
		["Sentinel"] =						600,
		["Service Jonque"] =				800,
		["Shooter"] =						100,
		["Sloop"] =							200,
		["Space Sedan"] =					600,
		["Stalker Q5"] =					200,
		["Stalker Q7"] =					200,
		["Stalker R5"] =					200,
		["Stalker R7"] =					200,
		["Starhammer II"] =					400,
		["Starhammer V"] =					400,
		["Storm"] =							200,
		["Strike"] =						200,
		["Strikeship"] = 					200,
		["Tempest"] =						200,
		["Transport1x1"] =					600,
		["Transport1x2"] =					600,
		["Transport1x3"] =					600,
		["Transport1x4"] =					800,
		["Transport1x5"] =					800,
		["Transport2x1"] =					600,
		["Transport2x2"] =					600,
		["Transport2x3"] =					600,
		["Transport2x4"] =					800,
		["Transport2x5"] =					800,
		["Transport3x1"] =					600,
		["Transport3x2"] =					600,
		["Transport3x3"] =					600,
		["Transport3x4"] =					800,
		["Transport3x5"] =					800,
		["Transport4x1"] =					600,
		["Transport4x2"] =					600,
		["Transport4x3"] =					600,
		["Transport4x4"] =					800,
		["Transport4x5"] =					800,
		["Transport5x1"] =					600,
		["Transport5x2"] =					600,
		["Transport5x3"] =					600,
		["Transport5x4"] =					800,
		["Transport5x5"] =					800,
		["Tug"] =							200,
		["Tyr"] =							2000,
		["Waddle 5"] =						100,
		["Warden"] =						600,
		["Weapons platform"] =				200,
		["Work Wagon"] =					600,
		["WX-Lindworm"] =					100,
		["WZ-Lindworm"] =					100,
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
	playerShipStats = {	--taken from sandbox. Not all are used. Not all characteristics are used.
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Atlantis MK2"]		= { strength = 55,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Corsair"]				= { strength = 50,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Benedict"]			= { strength = 10,	cargo = 9,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 3,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
		["Crucible"]			= { strength = 45,	cargo = 5,	distance = 200,	long_range_radar = 20000, short_range_radar = 6000, tractor = false,	mining = false,	probes = 9,		pods = 1,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 1,	epjam = 0,	},
		["Ender"]				= { strength = 100,	cargo = 20,	distance = 2000,long_range_radar = 45000, short_range_radar = 7000, tractor = true,		mining = false,	probes = 12,	pods = 6,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 2,	epjam = 0,	},
		["Flavia P.Falcon"]		= { strength = 13,	cargo = 15,	distance = 200,	long_range_radar = 40000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 8,		pods = 4,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
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
		["Repulse"]				= { strength = 14,	cargo = 12,	distance = 200,	long_range_radar = 38000, short_range_radar = 5000, tractor = true,		mining = false,	probes = 8,		pods = 5,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
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
	base_upgrade_cost = 5
	commonGoods = {"food","medicine","nickel","platinum","gold","dilithium","tritanium","luxury","cobalt","impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	componentGoods = {"impulse","warp","shield","tractor","repulsor","beam","optic","robotic","filament","transporter","sensor","communication","autodoc","lifter","android","nanites","software","circuit","battery"}
	mineralGoods = {"nickel","platinum","gold","dilithium","tritanium","cobalt"}
	vapor_goods = {"gold pressed latinum","unobtanium","eludium","impossibrium"}
	artifact_counter = 0
	artifact_number = 0
	sensor_impact = 1	--normal
	sensor_jammer_list = {}
	sensor_jammer_range = 60000
	sensor_jammer_impact = 40000
	sensor_jammer_scan_complexity = 3
	sensor_jammer_scan_depth = 3
	sensor_jammer_power_units = true	--false means percentage, true is units
	may_explain_sensor_jammer = false
	whammy = random(2950,3050)	-- ~50 minutes
	total_whammies = 0
	continuous_spawn_diagnostic = true
	--pace: number of seconds between launching from each station in the pool
	--respite: number of seconds before the next round of launches begins
	spawn_intervals = {	
		{pace = 5,	respite = 150},
		{pace = 12,	respite = 120},
		{pace = 25,	respite = 100},
		{pace = 15,	respite = 250},
		{pace = 35,	respite = 150},
		{pace = 10,	respite = 180},
	}
	spawn_interval_index = 0
	spawn_variance = 10
	spawn_source_pool = {}
	possible_victory_time = 600	--final: 600
	saboteur_idea_time = 1200	--final: 1200
	target_station_pool = {}
	clarifyExistingScience()
--	mainLinearPlot = continuousSpawn
	--checklist items
	--helm
	maneuver_check = "incomplete"			--getAngularVelocity
	impulse_check = "incomplete"			--getVelocity
	jump_drive_check = "incomplete"			--getJumpDriveCharge
	combat_maneuver_check = "incomplete"
	--weapons
	front_shield_check = "incomplete"		--getShieldLevel
	rear_shield_check = "incomplete"		--getShieldLevel
	beam_calibration_check = "incomplete"	--getBeamFrequency
	shield_calibration_check = "incomplete"	--getShieldsFrequency
	beam_check = "incomplete"
	missile_check = "incomplete"			
	--relay & science
	waypoint_check = "incomplete"			--getWaypointCount
	probe_check = "incomplete"				--getScanProbeCount, getMaxScanProbeCount
	probe_link_check = "incomplete"			--onProbeLink, onProbeUnlink
	scanner_check = "incomplete"
	--engineering
	coolant_check = "incomplete"			--getSystemCoolant
	power_check = "incomplete"				--getSystemPower
end
function clarifyExistingScience()
	local weapons_key = _("scienceDB","Weapons")
	local weapons_db = queryScienceDatabase(weapons_key)
	if weapons_db == nil then
		weapons_db = ScienceDatabase():setName(weapons_key)
	end
	weapons_db:setLongDescription(_("scienceDB","This database only covers the basic versions of the missiles used throughout the galaxy.\n\nIt has been reported that some battleships started using larger variations of those missiles. Small fighters and even frigates should not have too much trouble dodging them, but space captains of bigger ships should be wary of their doubled damage potential.\n\nSmaller variations of these missiles have become common in the galaxy, too. Fighter pilots praise their speed and maneuverability, because it gives them an edge against small and fast-moving targets. They only deal half the damage of their basic counterparts, but what good is a missile if it does not hit its target?\n\nSome ships in your fleet have been equipped with these different sized weapons tubes. In some cases, the weapons officer might see a banner on the weapons console describing these tubes using the following shorthand:\n    S = Small\n    M = Medium (the normal sized missile tube)\n    L = Large\nThese letters describe the tube sizes in order from top to bottom."))
end
-- Game Master functions --
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("buttonGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
end
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("buttonGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
	addGMFunction(_("buttonGM","+Difficulty"),setDifficulty)
	addGMFunction(_("buttonGM","+Enemy Power"),setEnemyPower)
	addGMFunction(_("buttonGM","+Reputation"),setInitialReputation)
end
function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("buttonGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
	--[[
	addGMFunction("Complete Checklist",function()
		if player_ship == nil then
			addGMMessage("Need to start inspection first. No action taken")
		else
			maneuver_check = "complete"
			impulse_check = "complete"
			jump_drive_check = "complete"
			combat_maneuver_check = "complete"
			front_shield_check = "complete"
			rear_shield_check = "complete"
			beam_calibration_check = "complete"
			shield_calibration_check = "complete"
			beam_check = "complete"
			missile_check = "complete"
			waypoint_check = "complete"
			probe_check = "complete"
			probe_link_check = "complete"
			scanner_check = "complete"
			coolant_check = "complete"
			power_check = "complete"
		end
	end)
	--]]
end
function setEnemyPower()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Enemy Power"),mainGMButtons)
	local powers = {
		{val = .5,	desc = _("buttonGM","Easy")},
		{val = 1,	desc = _("buttonGM","Normal")},
		{val = 2,	desc = _("buttonGM","Hard")},
		{val = 3,	desc = _("buttonGM","Extreme")},
		{val = 5,	desc = _("buttonGM","Quixotic")},
	}
	for index, power in ipairs(powers) do
		local button_label = string.format("%s %.1f",power.desc,power.val)
		if power.val == enemy_power then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			enemy_power = power.val
			setEnemyPower()
		end)
	end
end
function setDifficulty()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Difficulty"),mainGMButtons)
	local difficulties = {
		{val = .5,	desc = _("buttonGM","Easy")},
		{val = 1,	desc = _("buttonGM","Normal")},
		{val = 2,	desc = _("buttonGM","Hard")},
	}
	for index, diff in ipairs(difficulties) do
		local button_label = string.format("%s %.1f",diff.desc,diff.val)
		if diff.val == difficulty then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label,function()
			difficulty = diff.val
			setDifficulty()
		end)
	end
end
function setInitialReputation()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Reputation"),mainGMButtons)
	local reputation_values = {
		{name = _("buttonGM","Unknown"),		value = 0},
		{name = _("buttonGM","Nice"),			value = 20},
		{name = _("buttonGM","Hero"),			value = 50},
		{name = _("buttonGM","Major Hero"),		value = 100},
		{name = _("buttonGM","Super Hero"),		value = 200},
	}
	for index, rep in ipairs(reputation_values) do
		local button_label = string.format("%s %i",rep.name,rep.value)
		if reputation_start_amount == rep.value then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label, function()
			reputation_start_amount = rep.value
			setInitialReputation()
		end)
	end
end
function stationReports()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	if station_list ~= nil and #station_list > 0 then
		local applicable_station_count = 0
		for index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() and station.comms_data ~= nil then
				local tpa = Artifact():setFaction(player_faction)
				if station:isFriendly(tpa) or not station:isEnemy(tpa) then
					applicable_station_count = applicable_station_count + 1
					addGMFunction(string.format(_("stationReport-buttonGM","%s %s"),station:getCallSign(),station:getSectorName()),function()
						local out = string.format(_("stationReport-buttonGM","%s %s  %s  %s  Friendliness:%s"),station:getSectorName(),station:getCallSign(),station:getTypeName(),station:getFaction(),station.comms_data.friendlyness)
						out = string.format(_("stationReport-buttonGM","%s\nShares Energy: %s,  Repairs Hull: %s,  Restocks Scan Probes: %s"),out,station:getSharesEnergyWithDocked(),station:getRepairDocked(),station:getRestocksScanProbes())
						out = string.format(_("stationReport-buttonGM","%s\nFix Probes: %s,  Fix Hack: %s,  Fix Scan: %s,  Fix Combat Maneuver: %s,  Fix Destruct: %s, Fix Slow Tube: %s"),out,station.comms_data.probe_launch_repair,station.comms_data.hack_repair,station.comms_data.scan_repair,station.comms_data.combat_maneuver_repair,station.comms_data.self_destruct_repair,station.comms_data.self_destruct_repair,station.comms_data.tube_slow_down_repair)
						if station.comms_data.weapon_cost == nil then
							station.comms_data.weapon_cost = {
								Homing = math.random(1,4),
								HVLI = math.random(1,3),
								Mine = math.random(2,5),
								Nuke = math.random(12,18),
								EMP = math.random(7,13)
							}
						else
							if station.comms_data.weapon_cost.Homing == nil then
								station.comms_data.weapon_cost.Homing = math.random(1,4)
							end
							if station.comms_data.weapon_cost.HVLI == nil then
								station.comms_data.weapon_cost.HVLI = math.random(1,3)
							end
							if station.comms_data.weapon_cost.Nuke == nil then
								station.comms_data.weapon_cost.Nuke = math.random(12,18)
							end
							if station.comms_data.weapon_cost.Mine == nil then
								station.comms_data.weapon_cost.Mine = math.random(2,5)
							end
							if station.comms_data.weapon_cost.EMP == nil then
								station.comms_data.weapon_cost.EMP = math.random(7,13)
							end
						end
						out = string.format(_("stationReport-buttonGM","%s\nHoming: %s %s,   Nuke: %s %s,   Mine: %s %s,   EMP: %s %s,   HVLI: %s %s"),out,station.comms_data.weapon_available.Homing,station.comms_data.weapon_cost.Homing,station.comms_data.weapon_available.Nuke,station.comms_data.weapon_cost.Nuke,station.comms_data.weapon_available.Mine,station.comms_data.weapon_cost.Mine,station.comms_data.weapon_available.EMP,station.comms_data.weapon_cost.EMP,station.comms_data.weapon_available.HVLI,station.comms_data.weapon_cost.HVLI)
--							out = string.format("%s\n      Cost multipliers and Max Refill:   Friend: %.1f %.1f,   Neutral: %.1f %.1f",out,station.comms_data.reputation_cost_multipliers.friend,station.comms_data.max_weapon_refill_amount.friend,station.comms_data.reputation_cost_multipliers.neutral,station.comms_data.max_weapon_refill_amount.neutral)
						out = string.format(_("stationReport-buttonGM","%s\nServices and their costs and availability:"),out)
						for service, cost in pairs(station.comms_data.service_cost) do
--							out = string.format("%s\n      %s: %s",out,service,cost)
							out = string.format("%s\n      %s: %s %s",out,service,cost,station.comms_data.service_available[service])
						end
						if station.comms_data.jump_overcharge then
							out = string.format(_("stationReport-buttonGM","%s\n      jump overcharge: 10"),out)
						end
						if station.comms_data.upgrade_path ~= nil then
							out = string.format(_("stationReport-buttonGM","%s\nUpgrade paths for player ship types and their max level:"),out)
							for ship_type, upgrade in pairs(station.comms_data.upgrade_path) do
								out = string.format(_("stationReport-buttonGM","%s\n      Ship template type: %s"),out,ship_type)
								for upgrade_type, max_level in pairs(upgrade) do
									out = string.format("%s\n            %s: %s",out,upgrade_type,max_level)
								end
							end
						end
						if station.comms_data.goods ~= nil or station.comms_data.trade ~= nil or station.comms_data.buy ~= nil then
							out = string.format(_("stationReport-buttonGM","%s\nGoods:"),out)
							if station.comms_data.goods ~= nil then
								out = string.format(_("stationReport-buttonGM","%s\n    Sell:"),out)
								for good, good_detail in pairs(station.comms_data.goods) do
									out = string.format(_("stationReport-buttonGM","%s\n        %s: Cost:%s   Quantity:%s"),out,good,good_detail.cost,good_detail.quantity)
								end
							end
							if station.comms_data.trade ~= nil then
								out = string.format(_("stationReport-buttonGM","%s\n    Trade:"),out)
								for good, trade in pairs(station.comms_data.trade) do
									out = string.format("%s\n        %s: %s",out,good,trade)
								end
							end
							if station.comms_data.buy ~= nil then
								out = string.format(_("stationReport-buttonGM","%s\n    Buy:"),out)
								for good, amount in pairs(station.comms_data.buy) do
									out = string.format("%s\n        %s: %s",out,good,amount)
								end
							end
						end
						addGMMessage(out)
						stationReports()
					end)					
				end
				tpa:destroy()
			end
		end
		if applicable_station_count == 0 then
			addGMMessage(_("stationReport-buttonGM","No applicable stations. Reports useless. No action taken"))
			mainGMButtons()
		end
	else
		addGMMessage(_("stationReport-buttonGM","No applicable stations. Reports useless. No action taken"))
		mainGMButtons()
	end
end
function testNonDBShips()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-Main"),mainGMButtons)
	local non_db_ships = {
		["farco3"] =        	farco3,
		["farco5"] =        	farco5,
		["farco8"] =        	farco8,
		["farco11"] =       	farco11,
		["farco13"] =       	farco13,
		["whirlwind"] =     	whirlwind,
		["phobosR2"] =      	phobosR2,
		["hornetMV52"] =    	hornetMV52,
		["k2fighter"] =     	k2fighter,
		["k3fighter"] =     	k3fighter,
		["waddle5"] =       	waddle5,
		["jade5"] =         	jade5,
		["droneLite"] =     	droneLite,
		["droneHeavy"] =    	droneHeavy,
		["droneJacket"] =   	droneJacket,
		["wzLindworm"] =    	wzLindworm,
		["tempest"] =       	tempest,
		["enforcer"] =      	enforcer,
		["predator"] =      	predator,
		["atlantisY42"] =   	atlantisY42,
		["starhammerV"] =   	starhammerV,
		["tyr"] =          		tyr,
		["gnat"] =          	gnat,
		["cucaracha"] =     	cucaracha,
		["maniapak"] =			maniapak,
		["starhammerIII"] =   	starhammerIII,
		["k2breaker"] =     	k2breaker,
		["hurricane"] =     	hurricane,
		["phobosT4"] =      	phobosT4,
	}
	for index, func in pairs(non_db_ships) do
		addGMFunction(index,function()
			string.format("")
			local ship = func("Exuari")
			ship:setPosition(5000,5000)
		end)
	end
end
--	Player ship functions
function updatePlayerSoftTemplate(p)
	local tempTypeName = p:getTypeName()
	if tempTypeName ~= nil then
		if playerShipStats[tempTypeName] ~= nil then
			--set values from list
			p.shipScore = playerShipStats[tempTypeName].strength
			p.maxCargo = playerShipStats[tempTypeName].cargo
			p.cargo = p.maxCargo
			p:setLongRangeRadarRange(playerShipStats[tempTypeName].long_range_radar)
			p:setShortRangeRadarRange(playerShipStats[tempTypeName].short_range_radar)
			p.tractor = playerShipStats[tempTypeName].tractor
			p.tractor_target_lock = false
			p.mining = playerShipStats[tempTypeName].mining
			p:setMaxScanProbeCount(playerShipStats[tempTypeName].probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p.prox_scan = playerShipStats[tempTypeName].prox_scan
			local player_ship_name_list = player_ship_names_for[tempTypeName]
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
			p.score_settings_source = tempTypeName
		else
			addGMMessage(string.format("Player ship %s's template type (%s) could not be found in table PlayerShipStats",p:getCallSign(),tempTypeName))
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
function setPlayers(p)
	if p == nil then
		return
	end
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p.goods = {}
	p:setFaction(player_faction)
	updatePlayerSoftTemplate(p)
	player_ship_spawn_count = player_ship_spawn_count + 1
--	p:onDestroyed(playerDestroyed)
--	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
	end
end
--	Construct environment and related functions
function environmentObject(ref_x, ref_y, dist, axis)
	if ref_x == nil or ref_y == nil or dist == nil then
		print("function environmentObject expects ref_x, ref_y and dist to be provided")
		return
	end
	if axis == nil then	--circular environment object placement
		local inner_count_repeat_loop = 0
		local outer_count_repeat_loop = 0
		local outer_circle_buffer = 500
		repeat
			repeat
				radius = 90000
--				for i=1,10 do
--					radius = radius + random(500,average_station_circle_distance/10 + outer_circle_buffer)
--				end
				local o_x, o_y = vectorFromAngleNorth(random(0,360),random(10000,radius))
				ref_x = ref_x + o_x
				ref_y = ref_y + o_y
				inner_count_repeat_loop = inner_count_repeat_loop + 1
			until(farEnough(ref_x,ref_y,dist) or inner_count_repeat_loop > max_repeat_loop)
			if inner_count_repeat_loop > max_repeat_loop then
				outer_count_repeat_loop = outer_count_repeat_loop + 1
				outer_circle_buffer = outer_circle_buffer + 1000
				inner_count_repeat_loop = 0
			else
				break
			end
		until(outer_count_repeat_loop > max_repeat_loop)
		if outer_count_repeat_loop > max_repeat_loop then
			print("repeated too many times when trying to get far enough away 1")
			print("last ref_x:",ref_x,"last ref_y:",ref_y)
			far_enough_fail = true
			return nil
		else
			return ref_x, ref_y
		end
	else	--linear environment object placement
		local count_repeat_loop = 0
		if base_point_x == nil then
			base_distance = average_station_circle_distance
			base_point_x, base_point_y = vectorFromAngleNorth(axis,base_distance)
		end
		repeat
			local par_x, par_y = vectorFromAngleNorth(axis,random(0,40000))
			local perp_x, perp_y = vectorFromAngleNorth(axis + 90, random(0, 40000))
			local pos_x, pos_y = vectorFromAngleNorth(axis+270,20000)
			ref_x = ref_x + base_point_x + pos_x + par_x + perp_x
			ref_y = ref_y + base_point_y + pos_y + par_y + perp_y
			base_distance = base_distance + random(20,200)
			if base_distance > average_station_circle_distance + 80000 then
				base_distance = average_station_circle_distance
			end
			base_point_x, base_point_y = vectorFromAngleNorth(axis,base_distance)
			count_repeat_loop = count_repeat_loop + 1
		until(farEnough(ref_x,ref_y,dist) or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when trying to get far enough away 2")
			print("last ref_x:",ref_x,"last ref_y:",ref_y)
			far_enough_fail = true
			return nil
		else
			return ref_x, ref_y
		end
	end
end
function constructEnvironment()
	place_space = {}
	local faction_circle = {
		--	player faction:	Hum	USN	TSN	CUF
		"Exuari",		--	Ene	Ene	Ene	Ene
		"Ghosts",		--	Ene	Ene	Neu	Ene
		"TSN",			--	Frn	Ene	Frn	Neu
		"Independent",	--	Neu	Neu	Neu	Neu
		"Human Navy",	--	Frn	Frn	Frn	Frn
		"Arlenians",	--	Neu	Neu	Ene	Neu
		"Ktlitans",		--	Ene	Ene	Ene	Neu
		"CUF",			--	Frn	Neu	Neu	Frn
		"USN",			--	Frn	Frn	Ene	Neu
		"Kraylor",		--	Ene	Neu	Ene	Ene
		"Ghosts",		--	Ene	Ene	Neu	Ene
--	enemy count:			5	5	5	4
--	neutral/friendly count:	6	6	6	7	
	}
	local faction_letter = {
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
	local station_defend_dist = {
		["Small Station"] = 2800,	--2620
		["Medium Station"] = 4200,	--4000
		["Large Station"] = 4800,	--4590
		["Huge Station"] = 5200,	--4985
	}
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
	station_list = {}
	inner_circle = {}
--	player_factions = {"Human Navy","CUF","USN","TSN"}
--	player_faction = player_factions[math.random(1,#player_factions)]
--	ir_faction = {player_faction,"Human Navy"}	--inner ring faction list
--	if player_faction == "Human Navy" then
--		ir_faction = {"Human Navy","CUF","USN","TSN"}
--	end
	player_faction = "Human Navy"
	station_regional_hq = placeStation(center_x, center_y,"Pop Sci Fi",player_faction,"Large Station")
	if difficulty < 1 then
		station_regional_hq:setRestocksScanProbes(true)
	end
	table.insert(station_list,station_regional_hq)
	table.insert(inner_circle,station_regional_hq)
	table.insert(place_space,{obj=station_regional_hq,dist=1000,shape="circle"})
	local defense_platform_angle = random(0,360)
	local dp_x, dp_y = vectorFromAngleNorth(defense_platform_angle,3000)
	local dp = CpuShip():setTemplate("Defense platform"):setFaction(player_faction):setPosition(center_x + dp_x, center_y + dp_y):setScanState("fullscan"):orderStandGround()
	dp:setCallSign(string.format("%s Protector",station_regional_hq:getCallSign())):setCommsScript(""):setCommsFunction(commsShip)
	table.insert(place_space,{obj=dp,dist=300,shape="circle"})
	initial_player_ship = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(center_x + 900,center_y):commandDock(station_regional_hq)
	initial_player_ship:setCanDock(false):setCallSign(tableRemoveRandom(player_ship_names_for["Atlantis"]))
	allowNewPlayerShips(false)
	local circle_x, circle_y = vectorFromAngleNorth(random(-15,15)+defense_platform_angle+180,random(8000,14500))
	local station_size = szt()
	local circle_station = placeStation(center_x + circle_x, center_y + circle_y,"Spec Sci Fi",player_faction,station_size)
	table.insert(station_list,circle_station)
	table.insert(inner_circle,circle_station)
	table.insert(place_space,{obj=circle_station,dist=station_defend_dist[station_size],shape="circle"})
	circle_x, circle_y = vectorFromAngleNorth(random(-15,15)+defense_platform_angle+60,random(15000,45500))
	station_size = szt()
	circle_station = placeStation(center_x + circle_x, center_y + circle_y,"Science",player_faction,station_size)
	table.insert(station_list,circle_station)
	table.insert(inner_circle,circle_station)
	table.insert(place_space,{obj=circle_station,dist=station_defend_dist[station_size],shape="circle"})
	circle_x, circle_y = vectorFromAngleNorth(random(-15,15)+defense_platform_angle-60,random(21000,50500))
	station_size = szt()
	circle_station = placeStation(center_x + circle_x, center_y + circle_y,"History",player_faction,station_size)
	table.insert(station_list,circle_station)
	table.insert(inner_circle,circle_station)
	table.insert(place_space,{obj=circle_station,dist=station_defend_dist[station_size],shape="circle"})
	for index,station in ipairs(inner_circle) do
		if index > 1 then
			noStationServices(station)
		else
			if station.comms_data.service_available == nil then
				station.comms_data.service_available = {
					supplydrop =			true, 
					reinforcements =		true,
					hornet_reinforcements =	true,
					phobos_reinforcements =	true,
					amk3_reinforcements =	true,
					amk8_reinforcements =	true,
					jump_overcharge =		false,
					shield_overcharge =		false,
					jonque =				true,
				}
			end
			if station.comms_data.system_repair == nil then
				station.comms_data.system_repair = {
					["reactor"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["beamweapons"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["missilesystem"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["maneuver"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["impulse"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["warp"] =			{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["jumpdrive"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["frontshield"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
					["rearshield"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = true},
				}
			end
		end
	end
	local station_service_pool = {
		"energy","hull","restock_probes","homing","nuke","emp","mine","hvli",
		"fix_scan","fix_hack","fix_probe_launch","fix_combat_maneuver","fix_self_destruct","fix_slow_tube",
		"fix_reactor","fix_beam","fix_missile","fix_maneuver","fix_impulse","fix_warp","fix_jump","fix_front_shield","fix_rear_shield",
		"supply_drop","reinforcements","hornet_reinforcements","phobos_reinforcements","amk3_reinforcements","amk8_reinforcements",
		"jump_overcharge","shield_overcharge","jonque"
	}
	local station_pool = {}
	while(#station_service_pool > 0) do
		local service = tableRemoveRandom(station_service_pool)
		if #station_pool < 1 then
			for _,station in ipairs(inner_circle) do
				table.insert(station_pool,station)
			end
		end
		local station_1 = tableRemoveRandom(station_pool)
		if #station_pool < 1 then
			for _,station in ipairs(inner_circle) do
				table.insert(station_pool,station)
			end
		end
		local station_2 = tableRemoveRandom(station_pool)
		if service == "energy" then
			station_1:setSharesEnergyWithDocked(true)
			station_2:setSharesEnergyWithDocked(true)
		elseif service == "hull" then
			station_1:setRepairDocked(true)
			station_2:setRepairDocked(true)
		elseif service == "restock_probes" then
			station_1:setRestocksScanProbes(true)
			station_2:setRestocksScanProbes(true)
		elseif service == "homing" then
			station_1.comms_data.weapon_available.Homing = true
			station_2.comms_data.weapon_available.Homing = true
		elseif service == "nuke" then
			station_1.comms_data.weapon_available.Nuke = true
			station_2.comms_data.weapon_available.Nuke = true
		elseif service == "emp" then
			station_1.comms_data.weapon_available.EMP = true
			station_2.comms_data.weapon_available.EMP = true
		elseif service == "mine" then
			station_1.comms_data.weapon_available.Mine = true
			station_2.comms_data.weapon_available.Mine = true
		elseif service == "hvli" then
			station_1.comms_data.weapon_available.HVLI = true
			station_2.comms_data.weapon_available.HVLI = true
		elseif service == "fix_scan" then
			station_1.comms_data.scan_repair = true
			station_2.comms_data.scan_repair = true
		elseif service == "fix_hack" then
			station_1.comms_data.hack_repair = true
			station_2.comms_data.hack_repair = true
		elseif service == "fix_probe_launch" then
			station_1.comms_data.probe_launch_repair = true
			station_2.comms_data.probe_launch_repair = true
		elseif service == "fix_combat_maneuver" then
			station_1.comms_data.combat_maneuver_repair = true
			station_2.comms_data.combat_maneuver_repair = true
		elseif service == "fix_self_destruct" then
			station_1.comms_data.self_destruct_repair = true
			station_2.comms_data.self_destruct_repair = true
		elseif service == "fix_slow_tube" then
			station_1.comms_data.tube_slow_down_repair = true
			station_2.comms_data.tube_slow_down_repair = true
		elseif service == "fix_reactor" then
			station_1.comms_data.system_repair.reactor.avail = true
			station_2.comms_data.system_repair.reactor.avail = true
		elseif service == "fix_beam" then
			station_1.comms_data.system_repair.beamweapons.avail = true
			station_2.comms_data.system_repair.beamweapons.avail = true
		elseif service == "fix_missile" then
			station_1.comms_data.system_repair.missilesystem.avail = true
			station_2.comms_data.system_repair.missilesystem.avail = true
		elseif service == "fix_maneuver" then
			station_1.comms_data.system_repair.maneuver.avail = true
			station_2.comms_data.system_repair.maneuver.avail = true
		elseif service == "fix_impulse" then
			station_1.comms_data.system_repair.impulse.avail = true
			station_2.comms_data.system_repair.impulse.avail = true
		elseif service == "fix_warp" then
			station_1.comms_data.system_repair.warp.avail = true
			station_2.comms_data.system_repair.warp.avail = true
		elseif service == "fix_jump" then
			station_1.comms_data.system_repair.jumpdrive.avail = true
			station_2.comms_data.system_repair.jumpdrive.avail = true
		elseif service == "fix_front_shield" then
			station_1.comms_data.system_repair.frontshield.avail = true
			station_2.comms_data.system_repair.frontshield.avail = true
		elseif service == "fix_rear_shield" then
			station_1.comms_data.system_repair.rearshield.avail = true
			station_2.comms_data.system_repair.rearshield.avail = true
		elseif service == "supply_drop" then
			station_1.comms_data.service_available.supplydrop = true
			station_2.comms_data.service_available.supplydrop = true
		elseif service == "reinforcements" then
			station_1.comms_data.service_available.reinforcements = true
			station_2.comms_data.service_available.reinforcements = true
		elseif service == "hornet_reinforcements" then
			station_1.comms_data.service_available.hornet_reinforcements = true
			station_2.comms_data.service_available.hornet_reinforcements = true
		elseif service == "phobos_reinforcements" then
			station_1.comms_data.service_available.phobos_reinforcements = true
			station_2.comms_data.service_available.phobos_reinforcements = true
		elseif service == "amk3_reinforcements" then
			station_1.comms_data.service_available.amk3_reinforcements = true
			station_2.comms_data.service_available.amk3_reinforcements = true
		elseif service == "amk8_reinforcements" then
			station_1.comms_data.service_available.amk8_reinforcements = true
			station_2.comms_data.service_available.amk8_reinforcements = true
		elseif service == "jump_overcharge" then
			station_1.comms_data.service_available.jump_overcharge = true
			station_2.comms_data.service_available.jump_overcharge = true
		elseif service == "shield_overcharge" then
			station_1.comms_data.service_available.shield_overcharge = true
			station_2.comms_data.service_available.shield_overcharge = true
		elseif service == "jonque" then
			station_1.comms_data.service_available.jonque = true
			station_2.comms_data.service_available.jonque = true
		end
	end
	--	place some independent stations out there
	local initial_angle = random(0,360)
	for i=1,4 do
		local station_x, station_y = vectorFromAngleNorth(initial_angle + 90*(i-1),random(10000,60000))
		local station_size = szt()
		repeat
			station_x, station_y = vectorFromAngleNorth(initial_angle + 90*(i-1),random(10000,60000))
			station_x = station_x + center_x
			station_y = station_y + center_y
			station_size = szt()
		until(farEnough(station_x, station_y,station_defend_dist[station_size]))
		local station = placeStation(station_x, station_y,"RandomHumanNeutral","Independent",station_size)
		table.insert(station_list,station)
		table.insert(place_space,{obj=station,dist=station_defend_dist[station_size],shape="circle"})
	end
	--	spread services around the independent stations
	for _,station in ipairs(station_list) do
		if station:getFaction() == "Independent" then
			noStationServices(station)
		end
	end
	station_service_pool = {
		"energy","hull","restock_probes","homing","nuke","emp","mine","hvli",
		"fix_scan","fix_hack","fix_probe_launch","fix_combat_maneuver","fix_self_destruct","fix_slow_tube",
		"fix_reactor","fix_beam","fix_missile","fix_maneuver","fix_impulse","fix_warp","fix_jump","fix_front_shield","fix_rear_shield",
		"supply_drop","reinforcements","hornet_reinforcements","phobos_reinforcements","amk3_reinforcements","amk8_reinforcements",
		"jump_overcharge","shield_overcharge","jonque"
	}
	station_pool = {}
	while(#station_service_pool > 0) do
		local service = tableRemoveRandom(station_service_pool)
		if #station_pool < 1 then
			for _,station in ipairs(station_list) do
				if station:getFaction() == "Independent" then
					table.insert(station_pool,station)
				end
			end
		end
		local station_1 = tableRemoveRandom(station_pool)
		if service == "energy" then
			station_1:setSharesEnergyWithDocked(true)
		elseif service == "hull" then
			station_1:setRepairDocked(true)
		elseif service == "restock_probes" then
			station_1:setRestocksScanProbes(true)
		elseif service == "homing" then
			station_1.comms_data.weapon_available.Homing = true
		elseif service == "nuke" then
			station_1.comms_data.weapon_available.Nuke = true
		elseif service == "emp" then
			station_1.comms_data.weapon_available.EMP = true
		elseif service == "mine" then
			station_1.comms_data.weapon_available.Mine = true
		elseif service == "hvli" then
			station_1.comms_data.weapon_available.HVLI = true
		elseif service == "fix_scan" then
			station_1.comms_data.scan_repair = true
		elseif service == "fix_hack" then
			station_1.comms_data.hack_repair = true
		elseif service == "fix_probe_launch" then
			station_1.comms_data.probe_launch_repair = true
		elseif service == "fix_combat_maneuver" then
			station_1.comms_data.combat_maneuver_repair = true
		elseif service == "fix_self_destruct" then
			station_1.comms_data.self_destruct_repair = true
		elseif service == "fix_slow_tube" then
			station_1.comms_data.tube_slow_down_repair = true
		elseif service == "fix_reactor" then
			station_1.comms_data.system_repair.reactor.avail = true
		elseif service == "fix_beam" then
			station_1.comms_data.system_repair.beamweapons.avail = true
		elseif service == "fix_missile" then
			station_1.comms_data.system_repair.missilesystem.avail = true
		elseif service == "fix_maneuver" then
			station_1.comms_data.system_repair.maneuver.avail = true
		elseif service == "fix_impulse" then
			station_1.comms_data.system_repair.impulse.avail = true
		elseif service == "fix_warp" then
			station_1.comms_data.system_repair.warp.avail = true
		elseif service == "fix_jump" then
			station_1.comms_data.system_repair.jumpdrive.avail = true
		elseif service == "fix_front_shield" then
			station_1.comms_data.system_repair.frontshield.avail = true
		elseif service == "fix_rear_shield" then
			station_1.comms_data.system_repair.rearshield.avail = true
		elseif service == "supply_drop" then
			station_1.comms_data.service_available.supplydrop = true
		elseif service == "reinforcements" then
			station_1.comms_data.service_available.reinforcements = true
		elseif service == "hornet_reinforcements" then
			station_1.comms_data.service_available.hornet_reinforcements = true
		elseif service == "phobos_reinforcements" then
			station_1.comms_data.service_available.phobos_reinforcements = true
		elseif service == "amk3_reinforcements" then
			station_1.comms_data.service_available.amk3_reinforcements = true
		elseif service == "amk8_reinforcements" then
			station_1.comms_data.service_available.amk8_reinforcements = true
		elseif service == "jump_overcharge" then
			station_1.comms_data.service_available.jump_overcharge = true
		elseif service == "shield_overcharge" then
			station_1.comms_data.service_available.shield_overcharge = true
		elseif service == "jonque" then
			station_1.comms_data.service_available.jonque = true
		end
	end
	--	place some Kraylor stations out there
	initial_angle = initial_angle + random(30,60)
	for i=1,4 do
		local station_x, station_y = vectorFromAngleNorth(initial_angle + 90*(i-1),random(55000,90000))
		local station_size = szt()
		repeat
			station_x, station_y = vectorFromAngleNorth(initial_angle + 90*(i-1),random(55000,90000))
			station_x = station_x + center_x
			station_y = station_y + center_y
			station_size = szt()
		until(farEnough(station_x, station_y,station_defend_dist[station_size]))
		local station = placeStation(station_x, station_y,"Sinister","Kraylor",station_size)
		table.insert(station_list,station)
		table.insert(place_space,{obj=station,dist=station_defend_dist[station_size],shape="circle"})
	end
	transport_list = {}
	transport_stations = {}
	--fill in roughly circular area with semi-random terrain
	far_enough_fail = false
	local black_hole_chance = 1
	black_hole_count = math.random(2,4)
	local star_chance = 2
	star_count = math.random(1,2)
	local warp_jammer_chance = 2
	warp_jammer_count = math.random(2,4)
	local worm_hole_chance = 2
	worm_hole_count = math.random(2,4)
	local sensor_jammer_chance = 2
	sensor_jammer_count = math.random(2,4)
	local sensor_buoy_chance = 6
	local ad_buoy_chance = 8
	local nebula_chance = 5
	local mine_chance = 4
	local mine_field_chance = 4
	mine_field_count = math.random(3,5)
	local asteroid_field_chance = 4
	asteroid_field_count = math.random(2,9)
	local transport_chance = 4
	repeat
		local current_object_chance = 0
		local object_roll = random(0,100)
		current_object_chance = current_object_chance + black_hole_chance
		if object_roll <= current_object_chance then
			placeBlackHole()
			goto iterate
		end
		current_object_chance = current_object_chance + star_chance
		if object_roll <= current_object_chance then
			placeStar()
			goto iterate
		end
		current_object_chance = current_object_chance + warp_jammer_chance
		if object_roll <= current_object_chance then
			placeWarpJammer()
			goto iterate
		end
		current_object_chance = current_object_chance + worm_hole_chance
		if object_roll <= current_object_chance then
			placeWormHole()
			goto iterate
		end
		current_object_chance = current_object_chance + sensor_jammer_chance
		if object_roll <= current_object_chance then
			placeSensorJammer()
			goto iterate
		end
		current_object_chance = current_object_chance + sensor_buoy_chance
		if object_roll <= current_object_chance then
			placeSensorBuoy()
			goto iterate
		end
		current_object_chance = current_object_chance + ad_buoy_chance
		if object_roll <= current_object_chance then
			placeAdBuoy()
			goto iterate
		end
		current_object_chance = current_object_chance + nebula_chance
		if object_roll <= current_object_chance then
			placeNebula()
			goto iterate
		end
		current_object_chance = current_object_chance + mine_chance
		if object_roll <= current_object_chance then
			placeMine()
			goto iterate
		end
		current_object_chance = current_object_chance + mine_field_chance
		if object_roll <= current_object_chance then
			placeMineField()
			goto iterate
		end
		current_object_chance = current_object_chance + asteroid_field_chance
		if object_roll <= current_object_chance then
			placeAsteroidField()
			goto iterate
		end
		current_object_chance = current_object_chance + transport_chance
		if object_roll <= current_object_chance then
			transport_faction = "Human Navy"
			placeTransport()
			goto iterate
		end
		placeAsteroid()
		::iterate::
	until(#transport_list >= (12) or far_enough_fail)
	maintenancePlot = defenseMaintenance
end
function noStationServices(station)
	station:setSharesEnergyWithDocked(false)
	station:setRepairDocked(false)
	station:setRestocksScanProbes(false)
	station.comms_data.weapon_available.Homing = false
	station.comms_data.weapon_available.Nuke = false
	station.comms_data.weapon_available.EMP = false
	station.comms_data.weapon_available.Mine = false
	station.comms_data.weapon_available.HVLI = false
	station.comms_data.scan_repair = false
	station.comms_data.hack_repair = false
	station.comms_data.probe_launch_repair = false
	station.comms_data.combat_maneuver_repair = false
	station.comms_data.self_destruct_repair = false
	station.comms_data.tube_slow_down_repair = false
	station.comms_data.system_repair = {
		["reactor"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["beamweapons"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["missilesystem"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["maneuver"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["impulse"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["warp"] =			{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["jumpdrive"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["frontshield"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
		["rearshield"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = false},
	}
	station.comms_data.service_available = {
		supplydrop =			false, 
		reinforcements =		false,
		hornet_reinforcements =	false,
		phobos_reinforcements =	false,
		amk3_reinforcements =	false,
		amk8_reinforcements =	false,
		jump_overcharge =		false,
		shield_overcharge =		false,
		jonque =				false,
	}
	station.comms_data.service_cost = {
		supplydrop = math.random(90,110), 
		reinforcements = math.random(140,160),
		hornet_reinforcements =	math.random(75,125),
		phobos_reinforcements =	math.random(175,225),
		amk3_reinforcements = math.random(75,125),
		amk8_reinforcements = math.random(150,200),
		shield_overcharge = math.random(1,5)*5,
		scan_repair = math.random(2,7),
		hack_repair = math.random(2,7),
		probe_launch_repair = math.random(2,7),
		self_destruct_repair = math.random(2,7),
		tube_slow_down_repair = math.random(2,7),
		combat_maneuver_repair = math.random(2,7),
	}
end
function placeStar(axis)
	if star_count > 0 then
		local radius = random(600,1400)
		local eo_x, eo_y = environmentObject(center_x, center_y, radius, axis)
		if eo_x ~= nil then
			local star = Planet():setPosition(eo_x, eo_y):setPlanetRadius(radius):setDistanceFromMovementPlane(-radius*.5)
			star:setCallSign(tableRemoveRandom(star_list[1].name))
			star:setPlanetAtmosphereTexture(star_list[1].texture.atmosphere):setPlanetAtmosphereColor(random(0.8,1),random(0.8,1),random(0.8,1))
			table.insert(place_space,{obj=star,dist=radius,shape="circle"})
			star_count = star_count - 1
		end
	else
		placeAsteroid(axis)
	end
end
function placeBlackHole(axis)
	if black_hole_count > 0 then
		local eo_x, eo_y = environmentObject(center_x, center_y, 6000, axis)
		if eo_x ~= nil then
			local bh = BlackHole():setPosition(eo_x, eo_y)
			table.insert(place_space,{obj=bh,dist=6000,shape="circle"})
			black_hole_count = black_hole_count - 1
		end
	else
		placeAsteroid(axis)
	end
end
function placeProbe(axis)
	if #station_list < 1 then
		placeAsteroid(axis)
	else
		local eo_x, eo_y = environmentObject(center_x, center_y, 200, axis)
		if eo_x ~= nil then
			local sp = ScanProbe():setPosition(eo_x, eo_y)
			local owner = station_list[math.random(1,#station_list)]
			sp:setLifetime(30*60):setOwner(owner):setTarget(eo_x,eo_y)
			table.insert(place_space,{obj=sp,dist=200,shape="circle"})
		end
	end
end
function placeWarpJammer(axis)
	if warp_jammer_count > 0 then
		local eo_x, eo_y = environmentObject(center_x, center_y, 200, axis)
		if eo_x ~= nil then
			local wj = WarpJammer():setPosition(eo_x, eo_y)
			local closest_station_distance = 999999
			local closest_station = nil
			for _, station in ipairs(station_list) do
				local current_distance = distance(station, eo_x, eo_y)
				if current_distance < closest_station_distance then
					closest_station_distance = current_distance
					closest_station = station
				end
			end
			local selected_faction = closest_station:getFaction()
			local warp_jammer_range = 0
			for i=1,5 do
				warp_jammer_range = warp_jammer_range + random(1000,3000)
			end
			wj:setRange(warp_jammer_range):setFaction(selected_faction)
			warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
			wj:setCallSign(string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count))
			wj.range = warp_jammer_range
			table.insert(warp_jammer_list,wj)
			table.insert(place_space,{obj=wj,dist=200,shape="circle"})
			warp_jammer_count = warp_jammer_count - 1
		end
	else
		placeAsteroid(axis)
	end
end
function placeWormHole(axis)
	if worm_hole_count > 0 then
		local eo_x, eo_y = environmentObject(center_x, center_y, 6000, axis)
		if eo_x ~= nil then
			local we_x, we_y = environmentObject(center_x, center_y, 500)
			if we_x ~= nil then
				local count_repeat_loop = 0
				repeat
					we_x, we_y = environmentObject(center_x, center_y, 500)
					count_repeat_loop = count_repeat_loop + 1
					if we_x == nil then
						break
					end
				until(distance(eo_x, eo_y, we_x, we_y) > 50000 or count_repeat_loop > max_repeat_loop)
				if count_repeat_loop > max_repeat_loop then
					print("repeated too many times while placing a wormhole")
					print("eo_x:",eo_x,"eo_y:",eo_y,"we_x:",we_x,"we_y:",we_y)
				end
				if we_x ~= nil and eo_x ~= nil then
					local wh = WormHole():setPosition(eo_x, eo_y):setTargetPosition(we_x, we_y)
					table.insert(place_space,{obj=wh,dist=6000,shape="circle"})
					table.insert(place_space,{dist=500,ps_x=we_x,ps_y=we_y,shape="circle"})
					worm_hole_count = worm_hole_count - 1
				end
			end
		end
	else
		placeAsteroid(axis)
	end
end
function placeSensorJammer(axis)
	if sensor_jammer_count > 0 then
		local lo_range = 10000
		local hi_range = 30000
		local lo_impact = 10000
		local hi_impact = 20000
		local range_increment = (hi_range - lo_range)/8
		local impact_increment = (hi_impact - lo_impact)/4
		local mix = math.random(2,10 - (4 - (2*math.floor(difficulty))))	--2-6, 2-8, 2-10
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
		local eo_x, eo_y = environmentObject(center_x, center_y, 200, axis)
		if eo_x ~= nil then
			local sj = sensorJammer(eo_x, eo_y)
			table.insert(place_space,{obj=sj,dist=200,shape="circle"})
			sensor_jammer_count = sensor_jammer_count - 1
		end
	else
		placeAsteroid(axis)
	end
end
function placeSensorBuoy(axis)
	local out = ""
	local eo_x, eo_y = environmentObject(center_x, center_y, 200, axis)
	if eo_x ~= nil then
		local sb = Artifact():setPosition(eo_x, eo_y):setScanningParameters(math.random(1,difficulty*2),math.random(1,difficulty*2)):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
		local buoy_type_list = {}
		local buoy_type = ""
		if #station_list > 0 then
			table.insert(buoy_type_list,"station")
		end
		if #transport_list > 0 then
			table.insert(buoy_type_list,"transport")
		end
		if #buoy_type_list > 0 then
			buoy_type = tableRemoveRandom(buoy_type_list)
			if buoy_type == "station" then
				local selected_stations = {}
				for _, station in ipairs(station_list) do
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
				for _, transport in ipairs(transport_list) do
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
		table.insert(place_space,{obj=sb,dist=200,shape="circle"})
	end
end
function placeAdBuoy(axis)
	local eo_x, eo_y = environmentObject(center_x, center_y, 200, axis)
	if eo_x ~= nil then
		local ab = Artifact():setPosition(eo_x, eo_y):setScanningParameters(difficulty*2,1):setRadarSignatureInfo(random(0,1),random(0,1),random(0,1)):setModel("SensorBuoyMKIII")
		local billboards = {
			_("scienceDescription-buoy","Come to Billy Bob's for the best food in the sector"),
			_("scienceDescription-buoy","It's never too late to buy life insurance"),
			_("scienceDescription-buoy","You'll feel better in an Adder Mark 9"),
			_("scienceDescription-buoy","Visit Repulse shipyards for the best deals"),
			_("scienceDescription-buoy","Fresh fish! We catch, you buy!"),
			_("scienceDescription-buoy","Get your fuel cells at Melinda's Market"),
			_("scienceDescription-buoy","Find a special companion. All species available"),
			_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
			_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
			_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
			_("scienceDescription-buoy","Best tasting water in the quadrant at Willy's Waterway"),
			_("scienceDescription-buoy","Amazing shows every night at Lenny's Lounge"),
			_("scienceDescription-buoy","Tip: make lemons an integral part of your diet"),
		}
		ab:setDescriptions(_("scienceDescription-buoy","Automated data gathering device"),billboards[math.random(1,#billboards)])
		table.insert(place_space,{obj=ab,dist=200,shape="circle"})
	end
end
function placeNebula(axis)
	local eo_x, eo_y = environmentObject(center_x, center_y, 3000, axis)
	if eo_x ~= nil then
		local neb = Nebula():setPosition(eo_x, eo_y)
		table.insert(place_space,{obj=neb,dist=1500,shape="circle"})
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
	end
end
function placeMine(axis)
	local eo_x, eo_y = environmentObject(center_x, center_y, 1000, axis)
	if eo_x ~= nil then
		local m = Mine():setPosition(eo_x, eo_y)
		table.insert(place_space,{obj=m,dist=1000,shape="circle"})
	end
end
function placeMineField(axis)
	if mine_field_count > 0 then
		local field_size = math.random(1,3)
		local mine_circle = {
			{inner_count = 4,	mid_count = 10,		outer_count = 15},	--1
			{inner_count = 9,	mid_count = 15,		outer_count = 20},	--2
			{inner_count = 15,	mid_count = 20,		outer_count = 25},	--3
		}
		local eo_x, eo_y = environmentObject(center_x, center_y, 4000 + (field_size*1500), axis)
		if eo_x ~= nil then
			local angle = random(0,360)
			local mx = 0
			local my = 0
			for i=1,mine_circle[field_size].inner_count do
				mx, my = vectorFromAngle(angle,field_size*1000)
				Mine():setPosition(eo_x+mx,eo_y+my)
				angle = (angle + (360/mine_circle[field_size].inner_count)) % 360
			end
			for i=1,mine_circle[field_size].mid_count do
				mx, my = vectorFromAngle(angle,field_size*1000 + 1200)
				Mine():setPosition(eo_x+mx,eo_y+my)
				angle = (angle + (360/mine_circle[field_size].mid_count)) % 360
			end
			table.insert(place_space,{dist=3000 + (field_size*1000),ps_x=eo_x,ps_y=eo_y,shape="circle"})
			mine_field_count = mine_field_count - 1
			if random(1,100) < 30 + difficulty*20 then
				local n_x, n_y = vectorFromAngle(random(0,360),random(50,2000))
				Nebula():setPosition(eo_x + n_x, eo_y + n_y)
			end
		end
	else
		placeAsteroid(axis)
	end
end
function placeAsteroidField(axis)
	if asteroid_field_count > 0 then
		local field_size = random(2000,8000)
		local eo_x, eo_y = environmentObject(center_x, center_y, field_size + 400, axis)
		if eo_x ~= nil then
			placeRandomAsteroidsAroundPoint(math.floor(field_size/random(50,100)),100,field_size, eo_x, eo_y)
			asteroid_field_count = asteroid_field_count - 1
		end
	else
		placeAsteroid(axis)
	end
end
function placeTransport(axis)
	local eo_x, eo_y = environmentObject(center_x, center_y, 600, axis)
	if eo_x ~= nil then
		local ship, ship_size = randomTransportType()
		local human_transports = 0
		local independent_transports = 0
		for _,transport in ipairs(transport_list) do
			if transport:isValid() then
				if transport:getFaction() == "Human Navy" then
					human_transports = human_transports + 1
				else
					independent_transports = independent_transports + 1
				end
			end
		end
		local transport_factions = {"Human Navy","Independent"}
		local transport_faction = transport_factions[math.random(1,#transport_factions)]
		if human_transports >= 4 then
			transport_faction = "Independent"
		elseif independent_transports >= 8 then
			transport_faction = "Human Navy"
		end
		ship:setPosition(eo_x, eo_y):setFaction(transport_faction)
		ship:setCallSign(generateCallSign(nil,ship:getFaction()))
		table.insert(place_space,{obj=ship,dist=600,shape="circle"})
		table.insert(transport_list,ship)
	end
end
function placeAsteroid(axis)
	local asteroid_size = random(2,200) + random(2,200) + random(2,200) + random(2,200)
	local eo_x, eo_y = environmentObject(center_x, center_y, asteroid_size, axis)
	if eo_x ~= nil then
		local ta = Asteroid():setPosition(eo_x, eo_y):setSize(asteroid_size)
		table.insert(place_space,{obj=ta,dist=asteroid_size,shape="circle"})
	end
end
function farEnough(o_x,o_y,obj_dist)
	local far_enough = true
	for _, item in ipairs(place_space) do
		if item.shape == "circle" then
			if distanceDiagnostic then
				print("Distance diagnostic 2: item.obj:",item.obj,item.obj:getCallSign(),"o_x:",o_x,"o_y:",o_y)
			end
			if item.obj ~= nil and item.obj:isValid() then
				if distance(item.obj,o_x,o_y) < (obj_dist + item.dist) then
					far_enough = false
					break
				end
			elseif item.ps_x ~= nil then
				if distance(item.ps_x, item.ps_y, o_x, o_y) < (obj_dist + item.dist) then
					far_enough = false
					break
				end
			end
		elseif item.shape == "rectangle" then
			if	o_x > item.lo_x and 
				o_x < item.hi_x and
				o_y > item.lo_y and
				o_y < item.hi_y then
				far_enough = false
				break
			end
		elseif item.shape == "toroid" then
			if item.obj ~= nil and item.obj:isValid() then
				local origin_dist = distance(item.obj,o_x,o_y)
				if origin_dist > item.inner_orbit - obj_dist and
					origin_dist < item.outer_orbit + obj_dist then
					far_enough = false
					break
				end
			end
		elseif item.shape == "zone" then
			local va = VisualAsteroid():setPosition(o_x,o_y)
			if item.zone:isInside(va) then
				far_enough = false
			end
			va:destroy()
			if far_enough then
				for i=1,30 do
					local v_x, v_y = vectorFromAngleNorth(i*12,obj_dist)
					if item.zone:isInside(va) then
						far_enough = false
					end
					va:destroy()
					if not far_enough then
						break
					end
				end
			end
			if not far_enough then
				break
			end
		end
	end
	return far_enough
end
-- Terrain and environment creation functions
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
--	print("input angle to vectorFromAngleNorth:")
--	print(angle)
	angle = (angle + 270) % 360
	local x, y = vectorFromAngle(angle,distance)
	return x, y
end
---------------------------------------
--	Support for constant plot lines  --
---------------------------------------
--	Maintenance functions
function defenseMaintenance(delta)
	if #station_list > 0 then
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				local fleet_count = 0
				local deleted_ship = false
				if station.defense_fleet ~= nil and #station.defense_fleet > 0 then
					for fleet_index, ship in ipairs(station.defense_fleet) do
						if ship ~= nil and ship:isValid() then
							fleet_count = fleet_count + 1
						else
							station.defense_fleet[fleet_index] = station.defense_fleet[#station.defense_fleet]
							station.defense_fleet[#station.defense_fleet] = nil
							deleted_ship = true
							break
						end
					end
				end
				if fleet_count < 1 and not deleted_ship then
					if station.defense_fleet_timer == nil then
						station.defense_fleet_timer = getScenarioTime() + 30
					end
					if station.defense_fleet_timer < getScenarioTime() then
						if station:areEnemiesInRange(10000) then
							station.defense_fleet_timer = nil
							local df_x, df_y = station:getPosition()
							local station_faction = station:getFaction()
							local fleet = spawnEnemies(df_x, df_y, 1, station_faction)
							for _, ship in ipairs(fleet) do
								ship:setFaction("Independent")
								ship:orderDefendTarget(station)
								ship:setFaction(station_faction)
								ship:setCallSign(generateCallSign(nil,ship:getFaction()))
							end
							station.defense_fleet = fleet
						else
							station.defense_fleet_timer = getScenarioTime() + 30
						end
					end
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				break
			end
		end
	end
	maintenancePlot = transportCommerceMaintenance
end
function transportCommerceMaintenance(delta)
	if #transport_list > 0 then
		local s_time = getScenarioTime()
		for transport_index, transport in ipairs(transport_list) do
			if transport ~= nil and transport:isValid() then
				local temp_faction = transport:getFaction()
				local docked_with = transport:getDockedWith()
				local transport_target = nil
				if docked_with ~= nil then
					if transport.undock_timer == nil then
						transport.undock_timer = s_time + random(10,25)
					elseif transport.undock_timer < s_time then
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
			else
				transport_list[transport_index] = transport_list[#transport_list]
				transport_list[#transport_list] = nil
				break
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
	maintenancePlot = defenseMaintenance
end
--	Sensor jammer functions
function sensorJammerPickupProcess(self,retriever)
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
	artifact_counter = artifact_counter + 1
	artifact_number = artifact_number + math.random(1,4)
	local random_suffix = string.char(math.random(65,90))
	local jammer_call_sign = string.format("SJ%i%s",artifact_number,random_suffix)
	local scanned_description = string.format(_("scienceDescription-artifact","Source of emanations interfering with long range sensors. Range:%.1fu Impact:%.1fu"),sensor_jammer_range/1000,sensor_jammer_impact/1000)
	local sensor_jammer = Artifact():setPosition(x,y):setScanningParameters(sensor_jammer_scan_complexity,sensor_jammer_scan_depth):setRadarSignatureInfo(.2,.4,.1):setModel("SensorBuoyMKIII"):setDescriptions(_("scienceDescription-artifact","Source of unusual emanations"),scanned_description):setCallSign(jammer_call_sign)
	if sj_diagnostic then
		print(jammer_call_sign,sensor_jammer:getSectorName(),string.format("Range:%.1fu Impact:%.1fu",sensor_jammer_range/1000,sensor_jammer_impact/1000),"complexity:",sensor_jammer_scan_complexity,"depth:",sensor_jammer_scan_depth)
	end
	sensor_jammer:onPickUp(sensorJammerPickupProcess)
	sensor_jammer_list[jammer_call_sign] = sensor_jammer
	sensor_jammer.jam_range = sensor_jammer_range
	sensor_jammer.jam_impact = sensor_jammer_impact
	sensor_jammer.jam_impact_units = sensor_jammer_power_units
	return sensor_jammer
end
function updatePlayerLongRangeSensors(p)
	if p.normal_long_range_radar == nil then
		p.normal_long_range_radar = p:getLongRangeRadarRange()
	end
	local base_range = p.normal_long_range_radar
	local impact_range = math.max(base_range * sensor_impact,p:getShortRangeRadarRange())
	local sensor_jammer_impact = 0
	if jammer_count == nil then
		jammer_count = 0
	end
	local previous_jammer_count = jammer_count
	jammer_count = 0
	if sensor_jammer_diagnostic then
		local out = "Jammers: name, distance, range, impact, calculated impact"
	end
	for jammer_name, sensor_jammer in pairs(sensor_jammer_list) do
		if sensor_jammer ~= nil and sensor_jammer:isValid() then
			local jammer_distance = distance(p,sensor_jammer)
			if jammer_distance < sensor_jammer.jam_range then
				jammer_count = jammer_count + 1
				if sensor_jammer.jam_impact_units then
					sensor_jammer_impact = math.max(sensor_jammer_impact,sensor_jammer.jam_impact*(1-(jammer_distance/sensor_jammer.jam_range)))
				else
					sensor_jammer_impact = math.max(sensor_jammer_impact,impact_range*sensor_jammer.jam_impact/100000*(1-(jammer_distance/sensor_jammer.jam_range)))
				end
				if sensor_jammer_diagnostic then
					out = string.format("%s\n%s, %.1f, %.1f, %.1f, %.1f",out,jammer_name,jammer_distance,sensor_jammer.jam_range,sensor_jammer.jam_impact,sensor_jammer_impact)
				end
			end
		else
			sensor_jammer_list[jammer_name] = nil
		end
	end
	impact_range = math.max(p:getShortRangeRadarRange(),impact_range - sensor_jammer_impact)
	p:setLongRangeRadarRange(impact_range)
	if sensor_jammer_diagnostic then
		if jammer_count ~= previous_jammer_count then
			print(out)
			print("Selected jammer impact:",sensor_jammer_impact,"Applied:",impact_range,"Normal:",p.normal_long_range_radar)
		end
	end
end
--	Transport selection and direction functions
function pickTransportTarget(transport)
	local transport_target = nil
	if #station_list > 0 then
		local count_repeat_loop = 0
		repeat
	--		transport_target = transport_stations[math.random(1,#transport_stations)]
			transport_target = station_list[math.random(1,#station_list)]
			count_repeat_loop = count_repeat_loop + 1
		until(count_repeat_loop > max_repeat_loop or (transport_target ~= nil and transport_target:isValid() and not transport:isEnemy(transport_target)))
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when picking a transport target")
		end
	end
	return transport_target
end
function randomTransportType()
	local transport_type = {"Personnel","Goods","Garbage","Equipment","Fuel"}
	local freighter_engine = "Freighter"
	local freighter_size = math.random(1,5)
	if random(1,100) < 30 then
		freighter_engine = "Jump Freighter"
		freighter_size = math.random(3,5)
	end
	return CpuShip():setTemplate(string.format("%s %s %i",transport_type[math.random(1,#transport_type)],freighter_engine,freighter_size)):setCommsScript(""):setCommsFunction(commsShip), freighter_size
end
--------------------------------
-- Station creation functions --
--------------------------------
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
---------------------------
-- Station communication --
---------------------------
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
            preorder = "friend",
            activatedefensefleet = "neutral",
        },
        service_cost = {
            supplydrop = math.random(80,120),
            reinforcements = math.random(125,175),
            activatedefensefleet = 20,
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
        setCommsMessage(_("station-comms","We are under attack! No time for chatting!"))
        return true
    end
    if not comms_source:isDocked(comms_target) then
        handleUndockedState()
    else
        handleDockedState()
    end
    return true
end
function commsChecklist()
	if player_ship.checklist_complete == "yes" then
		addCommsReply(string.format(_("station-comms","Return %s to shipyard"),player_ship:getCallSign()),function()
			if player_ship:isDocked(station_regional_hq) then
				setCommsMessage(_("station-comms","Thank you!"))
				local completed_minutes = math.floor(checklist_elapsed_time / 60)
				local completed_seconds = math.floor(checklist_elapsed_time % 60)
				local enemy_station_count = 0
				for _, station in ipairs(station_list) do
					if station ~= nil and station:isValid() and station:isEnemy(player_ship) then
						enemy_station_count = enemy_station_count + 1
					end
				end
				local out_msg = string.format(_("station-comms","Shipyard Inspection checklist completed in %i minutes and %i seconds"),completed_minutes,completed_seconds)
				if enemy_station_count < 4 then
					out_msg = string.format(_("station-comms","%s\nEnemy stations destroyed: %i"),out_msg,4 - enemy_station_count)
				end
				globalMessage(out_msg)
				victory("Human Navy")
			else
				setCommsMessage(string.format(_("station-comms","Your orders are to return %s to regional headquarters, %s. All you need to do is dock with %s, open communications and click the Return %s to shipyard button."),player_ship:getCallSign(),station_regional_hq:getCallSign(),station_regional_hq:getCallSign(),player_ship:getCallSign()))
				addCommsReply(string.format(_("station-comms","Returning %s ends the mission?"),player_ship:getCallSign()),function()
					setCommsMessage(string.format(_("station-comms","Yes. We need you to return %s so we can put the final touches on her before she is deployed to the fleet. I understand there's need for her in the gamma quadrant."),player_ship:getCallSign()))
					addCommsReply(_("station-comms","What about the Kraylor we saw?"),function()
						setCommsMessage(_("station-comms","Technically, we don't care about those Kraylor, even though we do. We just need you to return that ship!"))
						addCommsReply(string.format(_("station-comms","Those Kraylor pose a threat to %s"),station_regional_hq:getCallSign()),function()
							setCommsMessage(_("station-comms","The defense platform protects us. Your concern is touching, but unwarranted. You have your orders."))
							addCommsReply(string.format(_("station-comms","We like %s and don't want to give her up"),player_ship:getCallSign()),function()
								local ship_return_minutes = math.floor(ship_return_timer / 60)
								local ship_return_seconds = math.floor(ship_return_timer % 60)
								setCommsMessage(string.format(_("station-comms","Look, we've seen this happen on multiple occasions. A crew tries out a new ship and they don't want to let her go. This is why we give you such a generous return time. You're free to do whatever you want. Shoot down as many Kraylor as you want. But, you'll all be cashiered if you don't return %s by the time the clock runs down. You've got %i minutes and %i seconds remaining. Got it?"),player_ship:getCallSign(),ship_return_minutes,ship_return_seconds))
								addCommsReply(_("station-comms","Got it"),function()
									setCommsMessage(string.format(_("station-comms","Good. Don't be late. %s out."),station_regional_hq:getCallSign()))
								end)
								addCommsReply(_("Back"), commsStation)
							end)
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	else
		addCommsReply(_("station-comms","Shipyard inspection checklist"),function()
			setCommsMessage(_("station-comms","These are the things that need to be checked (grouped by primary officer responsibility)"))
			local helm_checks = {
				maneuver_check,
				impulse_check,
				jump_drive_check,
				combat_maneuver_check,
			}
			local helm_check_count = 0
			for _, check in ipairs(helm_checks) do
				if check == "complete" then
					helm_check_count = helm_check_count + 1
				end
			end
			local button_label = _("station-comms","Helm")
			if helm_check_count > 0 then
				button_label = _("station-comms","Helm - partially complete")
				if helm_check_count == #helm_checks then
					button_label = _("station-comms","Helm - complete")
				end
			end
			addCommsReply(button_label,function()
				setCommsMessage(_("station-comms","These checklist items directly relate to helm functionality."))
				local button_descriptors = {
					["incomplete"] = _("station-comms","incomplete"),
					["complete"] = _("station-comms","complete"),
					["started"] = _("station-comms","started"),
				}
				addCommsReply(string.format(_("station-comms","Maneuver - %s"),button_descriptors[maneuver_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Helm clicks the button to start the test and the system monitors how fast the ship turns. Once both the low and high targets are met, the checklist item is considered complete. Current state: %s"),button_descriptors[maneuver_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Impulse - %s"),button_descriptors[impulse_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Helm clicks the button to start the test and the system monitors how fast the ship moves. Once both the low and high targets are met, the checklist item is considered complete. Current state: %s"),button_descriptors[impulse_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Jump Drive - %s"),button_descriptors[jump_drive_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Helm clicks the button to start the test and the system monitors how the jump drive performs on a maximum distance jump. Completion of the test requires that the jump drive be fully recharged. Current state: %s"),button_descriptors[jump_drive_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Combat Maneuver - %s"),button_descriptors[combat_maneuver_check]), function()
					setCommsMessage(string.format(_("station-comms","Ask helm whether or not combat maneuver is working properly or not. Current state: %s"),button_descriptors[combat_maneuver_check]))
					addCommsReply(_("station-comms","Helm states combat maneuver works"),function()
						setCommsMessage(_("station-comms","Combat maneuver has been marked as completed on the checklist"))
						combat_maneuver_check = "complete"
						if player_ship.combat_maneuver_award == nil then
							player_ship:addReputationPoints(10)
							player_ship.combat_maneuver_award = "given"
						end
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("station-comms","Helm states combat maneuver does not work"),function()
						setCommsMessage(_("station-comms","Combat maneuver checklist item is pending"))
						combat_maneuver_check = "incomplete"
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			local weapons_checks = {
				front_shield_check,
				rear_shield_check,
				beam_calibration_check,
				shield_calibration_check,
				beam_check,
				missile_check,
			}
			local weapon_check_count = 0
			for _, check in ipairs(weapons_checks) do
				if check == "complete" then
					weapon_check_count = weapon_check_count + 1
				end
			end
			button_label = _("station-comms","Weapons")
			if weapon_check_count > 0 then
				button_label = _("station-comms","Weapons - partially complete")
				if weapon_check_count == #weapons_checks then
					button_label = _("station-comms","Weapons - complete")
				end
			end
			addCommsReply(button_label,function()
				setCommsMessage(_("station-comms","These checklist items directly relate to weapons functionality."))
				local button_descriptors = {
					["incomplete"] = _("station-comms","incomplete"),
					["complete"] = _("station-comms","complete"),
					["started"] = _("station-comms","started"),
				}
				addCommsReply(string.format(_("station-comms","Front Shield - %s"),button_descriptors[front_shield_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Weapons clicks the button to start the test and the system monitors how well the shield handles damage and recharges. Current state: %s"),button_descriptors[front_shield_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Rear Shield - %s"),button_descriptors[rear_shield_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Weapons clicks the button to start the test and the system monitors how well the shield handles damage and recharges. Current state: %s"),button_descriptors[rear_shield_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Beam Calibration - %s"),button_descriptors[beam_calibration_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Weapons clicks the button to start the test and the system monitors the changes in beam frequency. Current state: %s"),button_descriptors[beam_calibration_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Shield Calibration - %s"),button_descriptors[shield_calibration_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Weapons clicks the button to start the test and the system monitors the changes in shield frequency. Final step is to raise shields after calibration. Current state: %s"),button_descriptors[shield_calibration_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Beam Firing - %s"),button_descriptors[beam_check]), function()
					setCommsMessage(string.format(_("station-comms","Ask weapons whether or not beam firing is working properly or not. Current state: %s"),button_descriptors[beam_check]))
					addCommsReply(_("station-comms","Weapons states that beam systems work"),function()
						setCommsMessage(_("station-comms","Beam systems have been marked as completed on the checklist"))
						beam_check = "complete"
						if player_ship.beam_award == nil then
							player_ship:addReputationPoints(10)
							player_ship.beam_award = "given"
						end
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("station-comms","Weapons states that the beams do not work"),function()
						setCommsMessage(_("station-comms","The beam systems checklist item is pending"))
						beam_check = "incomplete"
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Missile Systems - %s"),button_descriptors[missile_check]), function()
					setCommsMessage(string.format(_("station-comms","Ask weapons whether or not missile loading, firing and unloading is working properly or not. Current state: %s"),button_descriptors[missile_check]))
					addCommsReply(_("station-comms","Weapons states that the missile systems work"),function()
						setCommsMessage(_("station-comms","Missile systems have been marked as completed on the checklist"))
						missile_check = "complete"
						if player_ship.missile_award == nil then
							player_ship:addReputationPoints(10)
							player_ship.missile_award = "given"
						end
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("station-comms","Weapons states that the missile systems do not work"),function()
						setCommsMessage(_("station-comms","The missile systems checklist item is pending"))
						missile_check = "incomplete"
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			local relay_and_science_checks = {
				waypoint_check,
				probe_check,
				probe_link_check,
				scanner_check,
			}
			local relay_and_science_check_count = 0
			for _, check in ipairs(relay_and_science_checks) do
				if check == "complete" then
					relay_and_science_check_count = relay_and_science_check_count + 1
				end
			end
			button_label = _("station-comms","Relay and Science")
			if relay_and_science_check_count > 0 then
				button_label = _("station-comms","Relay and Science - partially complete")
				if relay_and_science_check_count == #relay_and_science_checks then
					button_label = _("station-comms","Relay and Science - complete")
				end
			end
			addCommsReply(button_label,function()
				setCommsMessage(_("station-comms","These checklist items directly relate to relay and science functionality."))
				local button_descriptors = {
					["incomplete"] = _("station-comms","incomplete"),
					["complete"] = _("station-comms","complete"),
					["started"] = _("station-comms","started"),
				}
				addCommsReply(string.format(_("station-comms","Waypoint - %s"),button_descriptors[waypoint_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Relay clicks the button to start the test and the system monitors the establishment of a waypoint. Current state: %s"),button_descriptors[waypoint_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Probe - %s"),button_descriptors[probe_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Relay clicks the button to start the test and the system monitors the launch and replishment of probes. Current state: %s"),button_descriptors[probe_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Link/Unlink Probe - %s"),button_descriptors[probe_link_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Relay clicks the button to start the test and the system monitors the linking and unlinking of probes. Current state: %s"),button_descriptors[probe_link_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Scanners - %s"),button_descriptors[scanner_check]), function()
					setCommsMessage(string.format(_("station-comms","Ask science whether or not the scanners are working properly or not. Current state: %s"),button_descriptors[scanner_check]))
					addCommsReply(_("station-comms","Science states that the scanners work"),function()
						setCommsMessage(_("station-comms","Scanners have been marked as completed on the checklist"))
						scanner_check = "complete"
						if player_ship.scanner_award == nil then
							player_ship:addReputationPoints(10)
							player_ship.scanner_award = "given"
						end
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("station-comms","Science states that the scanners do not work"),function()
						setCommsMessage(_("station-comms","The scanners checklist item is pending"))
						scanner_check = "incomplete"
						addCommsReply(_("Back"), commsStation)
					end)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			local engineering_checks = {
				coolant_check,
				power_check,
			}
			local engineering_check_count = 0
			for _, check in ipairs(engineering_checks) do
				if check == "complete" then
					engineering_check_count = engineering_check_count + 1
				end
			end
			button_label = _("station-comms","Engineering")
			if engineering_check_count > 0 then
				button_label = _("station-comms","Engineering - partially complete")
				if engineering_check_count == #engineering_checks then
					button_label = _("station-comms","Engineering - complete")
				end
			end
			addCommsReply(button_label,function()
				setCommsMessage(_("station-comms","These checklist items directly relate to engineering functionality. There are fewer tests, but they take a bit longer."))
				local button_descriptors = {
					["incomplete"] = _("station-comms","incomplete"),
					["complete"] = _("station-comms","complete"),
					["started"] = _("station-comms","started"),
				}
				addCommsReply(string.format(_("station-comms","Coolant - %s"),button_descriptors[coolant_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Engineering clicks the button to start the test and the system monitors the flow of coolant to each system. Current state: %s"),button_descriptors[coolant_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(string.format(_("station-comms","Power - %s"),button_descriptors[power_check]), function()
					setCommsMessage(string.format(_("station-comms","This checklist item is semi-automated. Engineering clicks the button to start the test and the system monitors the flow of coolant to each system. System is checked off once minimum and maximum power observed in all systems. Current state: %s"),button_descriptors[power_check]))
					addCommsReply(_("Back"), commsStation)
				end)
				if comms_source.joke_message == nil then
					addCommsReply(_("station-comms","Self Destruct - incomplete"),function()
						comms_source.joke_message = "sent"
						setCommsMessage(_("station-comms","Just kidding. There's no need to destroy yourselves for the sake of a checklist."))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("station-comms","Alternative consoles"),function()
				setCommsMessage(_("station-comms","Some crews do not divide officer responsibilities into five areas: helm, weapons, engineering, science, relay. If that's the case for your crew, you may use the following consoles:\n    Helm: use Tactical\n    Weapons: use Tactical and/or Engineering+\n    Engineering: use Engineering+\n    Science: use Operations\n    Relay: use Operations\nRunning checks simultaneously on the alternate consoles takes more console screen real estate."))
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function handleDockedState()
	if comms_target == station_regional_hq and comms_source == initial_player_ship then
		if atlantis_2_name == nil then
			atlantis_2_name = tableRemoveRandom(player_ship_names_for["Atlantis MK2"])
			corsair_name = tableRemoveRandom(player_ship_names_for["Corsair"])
		end
		setCommsMessage(string.format(_("station-comms","Greetings %s, welcome to station %s.\nI hope your journey was pleasant. I understand you are here to inspect and evaluate one of the ships just coming out of our shipyard. You may choose between two ships.\n     The first is the %s, an Atlantis MK2.\n     The second is the %s, a Corsair.\nWe will transfer your crew to the ship you choose so that you may begin your inspection immediately. Check back with us any time to ascertain your progress on the checklist."),comms_source:getCallSign(),comms_target:getCallSign(),atlantis_2_name,corsair_name))
		addCommsReply(string.format(_("station-comms","Inspect the %s"),atlantis_2_name),function()
			player_ship = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis MK2"):setPosition(center_x,center_y + 700):setCallSign(atlantis_2_name)
			player_ship:commandTargetRotation(90):setHeading(180):commandDock(station_regional_hq)
			initial_player_ship:transferPlayersToShip(player_ship)
			player_ship.angular_velocity_max = 0
			player_ship.angular_velocity_lo = 10
			player_ship.angular_velocity_hi = 30
			player_ship.velocity_max = 0
			player_ship.velocity_lo = 5.4
			player_ship.velocity_hi = 16.1999
			player_ship.long_jump_made = false
			player_ship.front_shield_hit = false
			player_ship.rear_shield_hit = false
			player_ship.beam_calibrated = false
			player_ship.waypoint_set = false
			player_ship.probe_launched = false
			player_ship.probes_replenished = false
			player_ship.probe_linked = false
			player_ship.probe_unlinked = false
			player_ship:onProbeLink(function(self,linked_probe)
				if probe_link_check == "started" then
					self.probe_linked = true
				end
			end)
			player_ship:onProbeUnlink(function(self,unlinked_probe)
				if probe_link_check == "started" then
					self.probe_unlinked = true
				end
			end)
			player_ship.coolant_completed = {
				["reactor"] = {name = _("station-comms","Reactor"), checked = false},
				["beamweapons"] = {name = _("station-comms","Beam Weapons"), checked = false},
				["missilesystem"] = {name = _("station-comms","Missile System"), checked = false},
				["maneuver"] = {name = _("station-comms","Maneuvering"), checked = false},
				["impulse"] = {name = _("station-comms","Impulse Engines"), checked = false},
				["jumpdrive"] = {name = _("station-comms","Jump Drive"), checked = false},
				["frontshield"] = {name = _("station-comms","Front Shield Generator"), checked = false},
				["rearshield"] = {name = _("station-comms","Rear Shield Generator"), checked = false},
			}
			player_ship.power_completed = {
				["reactor"] = {name = _("station-comms","Reactor"), min = false, max = false},
				["beamweapons"] = {name = _("station-comms","Beam Weapons"), min = false, max = false},
				["missilesystem"] = {name = _("station-comms","Missile System"), min = false, max = false},
				["maneuver"] = {name = "Maneuvering", min = false, max = false},
				["impulse"] = {name = _("station-comms","Impulse Engines"), min = false, max = false},
				["jumpdrive"] = {name = _("station-comms","Jump Drive"), min = false, max = false},
				["frontshield"] = {name = _("station-comms","Front Shield Generator"), min = false, max = false},
				["rearshield"] = {name = _("station-comms","Rear Shield Generator"), min = false, max = false},
			}
			checklist_start_clock = getScenarioTime()
			initial_player_ship:destroy()
		end)
		addCommsReply(string.format(_("station-comms","Inspect the %s"),corsair_name),function()
			player_ship = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Corsair"):setPosition(center_x,center_y - 700):setCallSign(corsair_name)
			player_ship:commandTargetRotation(270):setHeading(0):commandDock(station_regional_hq)
			initial_player_ship:transferPlayersToShip(player_ship)
			player_ship.angular_velocity_max = 0
			player_ship.angular_velocity_lo = 12
			player_ship.angular_velocity_hi = 36
			player_ship.velocity_max = 0
			player_ship.velocity_lo = 5.7
			player_ship.velocity_hi = 17.0999
			player_ship.long_jump_made = false
			player_ship.front_shield_hit = false
			player_ship.rear_shield_hit = false
			player_ship.beam_calibrated = false
			player_ship.waypoint_set = false
			player_ship.probe_launched = false
			player_ship.probes_replenished = false
			player_ship.probe_linked = false
			player_ship.probe_unlinked = false
			player_ship:onProbeLink(function(self,linked_probe)
				if probe_link_check == "started" then
					self.probe_linked = true
				end
			end)
			player_ship:onProbeUnlink(function(self,unlinked_probe)
				if probe_link_check == "started" then
					self.probe_unlinked = true
				end
			end)
			player_ship.coolant_completed = {
				["reactor"] = {name = _("station-comms","Reactor"), checked = false},
				["beamweapons"] = {name = _("station-comms","Beam Weapons"), checked = false},
				["missilesystem"] = {name = _("station-comms","Missile System"), checked = false},
				["maneuver"] = {name = _("station-comms","Maneuvering"), checked = false},
				["impulse"] = {name = _("station-comms","Impulse Engines"), checked = false},
				["jumpdrive"] = {name = _("station-comms","Jump Drive"), checked = false},
				["frontshield"] = {name = _("station-comms","Front Shield Generator"), checked = false},
				["rearshield"] = {name = _("station-comms","Rear Shield Generator"), checked = false},
			}
			player_ship.power_completed = {
				["reactor"] = {name = _("station-comms","Reactor"), min = false, max = false},
				["beamweapons"] = {name = _("station-comms","Beam Weapons"), min = false, max = false},
				["missilesystem"] = {name = _("station-comms","Missile System"), min = false, max = false},
				["maneuver"] = {name = "Maneuvering", min = false, max = false},
				["impulse"] = {name = _("station-comms","Impulse Engines"), min = false, max = false},
				["jumpdrive"] = {name = _("station-comms","Jump Drive"), min = false, max = false},
				["frontshield"] = {name = _("station-comms","Front Shield Generator"), min = false, max = false},
				["rearshield"] = {name = _("station-comms","Rear Shield Generator"), min = false, max = false},
			}
			checklist_start_clock = getScenarioTime()
			initial_player_ship:destroy()
		end)
		addCommsReply(_("Back"), commsStation)
	else
		if comms_source:isFriendly(comms_target) then
			if comms_target.comms_data.friendlyness > 66 then
				oMsg = string.format(_("station-comms","Greetings %s!\nHow may we help you today?"),comms_source:getCallSign())
			elseif comms_target.comms_data.friendlyness > 33 then
				oMsg = _("station-comms","Good day, officer!\nWhat can we do for you today?")
			else
				oMsg = _("station-comms","Hello, may I help you?")
			end
		else
			oMsg = _("station-comms","Welcome to our lovely station.")
		end
		if comms_target:areEnemiesInRange(20000) then
			oMsg = oMsg .. _("station-comms","\nForgive us if we seem a little distracted. We are carefully monitoring the enemies nearby.")
		end
		if comms_target == station_regional_hq then
			if player_ship.checklist_complete == "yes" then
				if player_ship.congratulations_message == nil then
					local completed_minutes = math.floor(checklist_elapsed_time / 60)
					local completed_seconds = math.floor(checklist_elapsed_time % 60)
					oMsg = string.format(_("station-comms","Congratulations captain and crew of the newly built %s, you completed the inspection checklist in %i minutes and %i seconds!"),player_ship:getCallSign(),completed_minutes,completed_seconds)
					player_ship.congratulations_message = "sent"
				end
			end
			commsChecklist()
		end
		setCommsMessage(oMsg)
		addCommsReply(_("station-comms","Station services (restock ordnance, repairs)"),function()
			setCommsMessage(_("station-comms","What station service are you interested in?"))
			local missilePresence = 0
			local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
			for _, missile_type in ipairs(missile_types) do
				missilePresence = missilePresence + comms_source:getWeaponStorageMax(missile_type)
			end
			if missilePresence > 0 then
				if 	(comms_target.comms_data.weapon_available.Nuke   and comms_source:getWeaponStorageMax("Nuke") > 0)   or 
					(comms_target.comms_data.weapon_available.EMP    and comms_source:getWeaponStorageMax("EMP") > 0)    or 
					(comms_target.comms_data.weapon_available.Homing and comms_source:getWeaponStorageMax("Homing") > 0) or 
					(comms_target.comms_data.weapon_available.Mine   and comms_source:getWeaponStorageMax("Mine") > 0)   or 
					(comms_target.comms_data.weapon_available.HVLI   and comms_source:getWeaponStorageMax("HVLI") > 0)   then
					addCommsReply(_("ammo-comms","I need ordnance restocked"), function()
						if stationCommsDiagnostic then print("in restock function") end
						setCommsMessage(string.format(_("ammo-comms","What type of ordnance?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
						if stationCommsDiagnostic then print(string.format("player nuke weapon storage max: %.1f",comms_source:getWeaponStorageMax("Nuke"))) end
						if comms_source:getWeaponStorageMax("Nuke") > 0 then
							if stationCommsDiagnostic then print("player can fire nukes") end
							if comms_target.comms_data.weapon_available.Nuke then
								if stationCommsDiagnostic then print("station has nukes available") end
								if math.random(1,10) <= 5 then
									nukePrompt = _("ammo-comms","Can you supply us with some nukes? (")
								else
									nukePrompt = _("ammo-comms","We really need some nukes (")
								end
								if stationCommsDiagnostic then print("nuke prompt: " .. nukePrompt) end
								addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), nukePrompt, getWeaponCost("Nuke")), function()
									if stationCommsDiagnostic then print("going to handle weapon restock function") end
									handleWeaponRestock("Nuke")
								end)
							end	--end station has nuke available if branch
						end	--end player can accept nuke if branch
						if comms_source:getWeaponStorageMax("EMP") > 0 then
							if comms_target.comms_data.weapon_available.EMP then
								if math.random(1,10) <= 5 then
									empPrompt = _("ammo-comms", "Please re-stock our EMP missiles. (")
								else
									empPrompt = _("ammo-comms", "Got any EMPs? (")
								end
								addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), empPrompt, getWeaponCost("EMP")), function()
									handleWeaponRestock("EMP")
								end)
							end	--end station has EMP available if branch
						end	--end player can accept EMP if branch
						if comms_source:getWeaponStorageMax("Homing") > 0 then
							if comms_target.comms_data.weapon_available.Homing then
								if math.random(1,10) <= 5 then
									homePrompt = _("ammo-comms", "Do you have spare homing missiles for us? (")
								else
									homePrompt = _("ammo-comms", "Do you have extra homing missiles? (")
								end
								addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), homePrompt, getWeaponCost("Homing")), function()
									handleWeaponRestock("Homing")
								end)
							end	--end station has homing for player if branch
						end	--end player can accept homing if branch
						if comms_source:getWeaponStorageMax("Mine") > 0 then
							if comms_target.comms_data.weapon_available.Mine then
								if math.random(1,10) <= 5 then
									minePrompt = _("ammo-comms", "We could use some mines. (")
								else
									minePrompt = _("ammo-comms", "How about mines? (")
								end
								addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), minePrompt, getWeaponCost("Mine")), function()
									handleWeaponRestock("Mine")
								end)
							end	--end station has mine for player if branch
						end	--end player can accept mine if branch
						if comms_source:getWeaponStorageMax("HVLI") > 0 then
							if comms_target.comms_data.weapon_available.HVLI then
								if math.random(1,10) <= 5 then
									hvliPrompt = _("ammo-comms", "What about HVLI? (")
								else
									hvliPrompt = _("ammo-comms", "Could you provide HVLI? (")
								end
								addCommsReply(string.format(_("ammo-comms", "%s%d rep each)"), hvliPrompt, getWeaponCost("HVLI")), function()
									handleWeaponRestock("HVLI")
								end)
							end	--end station has HVLI for player if branch
						end	--end player can accept HVLI if branch
					end)	--end player requests secondary ordnance comms reply branch
				end	--end secondary ordnance available from station if branch
			end	--end missles used on player ship if branch
			addCommsReply(_("dockingServicesStatus-comms", "Docking services status"), function()
				local service_status = string.format(_("dockingServicesStatus-comms", "Station %s docking services status:"),comms_target:getCallSign())
				if comms_target:getRestocksScanProbes() then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nReplenish scan probes."),service_status)
				else
					if comms_target.probe_fail_reason == nil then
						local reason_list = {
							_("dockingServicesStatus-comms", "Cannot replenish scan probes due to fabrication unit failure."),
							_("dockingServicesStatus-comms", "Parts shortage prevents scan probe replenishment."),
							_("dockingServicesStatus-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
						}
						comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
					end
					service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
				end
				if comms_target:getRepairDocked() then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nShip hull repair."),service_status)
				else
					if comms_target.repair_fail_reason == nil then
						reason_list = {
							_("dockingServicesStatus-comms", "We're out of the necessary materials and supplies for hull repair."),
							_("dockingServicesStatus-comms", "Hull repair automation unavailable while it is undergoing maintenance."),
							_("dockingServicesStatus-comms", "All hull repair technicians quarantined to quarters due to illness."),
						}
						comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
					end
					service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
				end
				if comms_target:getSharesEnergyWithDocked() then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nRecharge ship energy stores."),service_status)
				else
					if comms_target.energy_fail_reason == nil then
						reason_list = {
							_("dockingServicesStatus-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
							_("dockingServicesStatus-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
							_("dockingServicesStatus-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
						}
						comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
					end
					service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
				end
				if comms_target.comms_data.jump_overcharge then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay overcharge jump drive"),service_status)
				end
				if comms_target.comms_data.probe_launch_repair then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair probe launch system"),service_status)
				end
				if comms_target.comms_data.hack_repair then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair hacking system"),service_status)
				end
				if comms_target.comms_data.scan_repair then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair scanners"),service_status)
				end
				if comms_target.comms_data.combat_maneuver_repair then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair combat maneuver"),service_status)
				end
				if comms_target.comms_data.self_destruct_repair then
					service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair self destruct system"),service_status)
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
						addCommsReply(_("dockingServicesStatus-comms", "Overcharge Jump Drive (10 Rep)"),function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
							if comms_source:takeReputationPoints(10) then
								comms_source:setJumpDriveCharge(comms_source:getJumpDriveCharge() + max_charge)
								setCommsMessage(string.format(_("dockingServicesStatus-comms", "Your jump drive has been overcharged to %ik"),math.floor(comms_source:getJumpDriveCharge()/1000)))
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
			if not offer_repair and comms_target.comms_data.combat_maneuver_repair and not comms_source:getCanCombatManeuver() and comms_source.combat_maneuver_capable then
				offer_repair = true
			end
			if not offer_repair and comms_target.comms_data.self_destruct_repair and not comms_source:getCanSelfDestruct() then
				offer_repair = true
			end
			if offer_repair then
				addCommsReply(_("dockingServicesStatus-comms", "Repair ship system"),function()
					setCommsMessage(string.format(_("dockingServicesStatus-comms","What system would you like repaired?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
					if comms_target.comms_data.probe_launch_repair then
						if not comms_source:getCanLaunchProbe() then
							addCommsReply(string.format(_("dockingServicesStatus-comms","Repair probe launch system (%s Rep)"),comms_target.comms_data.service_cost.probe_launch_repair),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
									return
								end
								if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.probe_launch_repair) then
									comms_source:setCanLaunchProbe(true)
									setCommsMessage(_("dockingServicesStatus-comms", "Your probe launch system has been repaired"))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation"))
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
					if comms_target.comms_data.hack_repair then
						if not comms_source:getCanHack() then
							addCommsReply(string.format(_("dockingServicesStatus-comms","Repair hacking system (%s Rep)"),comms_target.comms_data.service_cost.hack_repair),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
									return
								end
								if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.hack_repair) then
									comms_source:setCanHack(true)
									setCommsMessage(_("dockingServicesStatus-comms", "Your hack system has been repaired"))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation"))
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
					if comms_target.comms_data.scan_repair then
						if not comms_source:getCanScan() then
							addCommsReply(string.format(_("dockingServicesStatus-comms","Repair scanning system (%s Rep)"),comms_target.comms_data.service_cost.scan_repair),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
									return
								end
								if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.scan_repair) then
									comms_source:setCanScan(true)
									setCommsMessage(_("dockingServicesStatus-comms", "Your scanners have been repaired"))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation"))
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
					if comms_target.comms_data.combat_maneuver_repair then
						if not comms_source:getCanCombatManeuver() then
							if comms_source.combat_maneuver_capable then
								addCommsReply(string.format(_("dockingServicesStatus-comms","Repair combat maneuver (%s Rep)"),comms_target.comms_data.service_cost.combat_maneuver_repair),function()
									if not comms_source:isDocked(comms_target) then 
										setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
										return
									end
									if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.combat_maneuver_repair) then
										comms_source:setCanCombatManeuver(true)
										setCommsMessage(_("dockingServicesStatus-comms", "Your combat maneuver has been repaired"))
									else
										setCommsMessage(_("needRep-comms", "Insufficient reputation"))
									end
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
					end
					if comms_target.comms_data.self_destruct_repair then
						if not comms_source:getCanSelfDestruct() then
							addCommsReply(string.format(_("dockingServicesStatus-comms","Repair self destruct system (%s Rep)"),comms_target.comms_data.service_cost.self_destruct_repair),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
									return
								end
								if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.self_destruct_repair) then
									comms_source:setCanSelfDestruct(true)
									setCommsMessage(_("dockingServicesStatus-comms", "Your self destruct system has been repaired"))
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
		end)
		addCommsReply(_("station-comms","I need information"),function()
			setCommsMessage(_("station-comms","What do you need to know?"))
			addCommsReply(_("station-comms","What's with the warp jammers?"),function()
				setCommsMessage(_("station-comms","When factions in various stations in the area started attacking each other, there was a particularly nasty tactic employed where warp or jump ships would ambush a station. Stations could not maintain defensive patrols indefinitely due to the expense. Putting in a warp jammer gives the station a chance to scramble their defense fleet when an enemy approaches. Of course, it slows friendly traffic, commercial or military, too. So, most warp jammers are controlled by nearby factions to allow them to enable or disable them upon request to facilitate the flow of ships. You can't connect to the warp jammer while docked because you're clearly not yet ready to traverse the controlled area. Destroying a warp jammer may have undesired indirect consequences, but there's no official rule against it."))
				addCommsReply(_("Back"), commsStation)
			end)
			local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
			if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
				(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
				(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
				addCommsReply(_("station-comms", "Tell me more about your station"), function()
					setCommsMessage(_("station-comms", "What would you like to know?"))
					if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
						addCommsReply(_("stationGeneralInfo-comms", "General information"), function()
							setCommsMessage(comms_target.comms_data.general)
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
							if has_gossip then
								addCommsReply(_("gossip-comms", "Gossip"), function()
									setCommsMessage(comms_target.comms_data.gossip)
									addCommsReply(_("Back"), commsStation)
								end)
							end
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)	--end station info comms reply branch
			end
			if comms_source:isFriendly(comms_target) then
				if getScenarioTime() > possible_victory_time or may_explain_sensor_jammer then
					addCommsReply(_("station-comms","Explain sensor jammers"),function()
						setCommsMessage(_("station-comms","You mean those things that have a call sign that starts with SJ?"))
						addCommsReply(_("station-comms","Yes. Why so many?"),function()
							setCommsMessage(_("station-comms","They were made during a big technological arms race. All the factions tried to make them to hinder their enemies as they approached. Most ships have got ways around them now, but nobody has gone out to clean up the leftovers. The closest thing to clean up done by the factions is to give them all SJ call signs to make ships aware of the potential navigation hazard."))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("station-comms","Yes. What do they do?"),function()
							setCommsMessage(_("station-comms","The sensor jammers reduce your long range sensor range. The degree and range of effectiveness varies with each one. They're also designed to be booby traps. If you don't disable the trap, they'll fry your scanners if you pick them up to neutralize them."))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("station-comms","Yes. How do I get rid of them?"),function()
							setCommsMessage(_("station-comms","Just pick them up. You'll want to scan them first if you don't want your scanners fried."))
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				addCommsReply(_("orders-comms", "What are my current orders?"), function()
					setOptionalOrders()
					setSecondaryOrders()
					if comms_source == player_ship then
						primary_orders = string.format(_("orders-comms","Complete the inspection checklist for %s."),player_ship:getCallSign())
						if player_ship.checklist_complete == "yes" then
							primary_orders = _("orders-comms","Return the ship to the shipyard")
						end
					elseif comms_source == initial_player_ship then
						primary_orders = string.format(_("orders-comms","Inspect ship produced by the shipyard at %s."),station_regional_hq:getCallSign())
					else
						primary_orders = string.format(_("orders-comms","Be a shining example of a crewmember of %s."),comms_source:getCallSign())
					end
					ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
					if playWithTimeLimit then
						ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
					end
					setCommsMessage(ordMsg)
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end)
		addCommsReply(_("station-comms","Resources (repair crew, coolant, goods)"),function()
			setCommsMessage(_("station-comms","Which of the following are you interested in?"))
			if comms_source:isFriendly(comms_target) then
				getRepairCrewFromStation("friendly")
				getCoolantFromStation("friendly")
			else
				getRepairCrewFromStation("neutral")
				getCoolantFromStation("neutral")
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
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
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
							if comms_source.goods[good] ~= nil and comms_source.goods[good] > 0 then
								addCommsReply(string.format(_("trade-comms", "Sell one %s for %i reputation"),good,price), function()
									if not comms_source:isDocked(comms_target) then 
										setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
										return
									end
									local goodTransactionMessage = string.format(_("trade-comms", "Type: %s,  Reputation price: %i"),good,price)
									comms_source.goods[good] = comms_source.goods[good] - 1
									comms_source:addReputationPoints(price)
									goodTransactionMessage = goodTransactionMessage .. _("trade-comms", "\nOne sold")
									comms_source.cargo = comms_source.cargo + 1
									setCommsMessage(goodTransactionMessage)
									addCommsReply("Back", commsStation)
								end)
							end
						end
					end
					if comms_target.comms_data.trade.food then
						if comms_source.goods ~= nil then
							if comms_source.goods.food ~= nil then
								if comms_source.goods.food.quantity > 0 then
									for good, goodData in pairs(comms_target.comms_data.goods) do
										addCommsReply(string.format(_("trade-comms", "Trade food for %s"),good), function()
											if not comms_source:isDocked(comms_target) then 
												setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
												return
											end
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
							end
						end
					end
					if comms_target.comms_data.trade.medicine then
						if comms_source.goods ~= nil then
							if comms_source.goods.medicine ~= nil then
								if comms_source.goods.medicine.quantity > 0 then
									for good, goodData in pairs(comms_target.comms_data.goods) do
										addCommsReply(string.format(_("trade-comms", "Trade medicine for %s"),good), function()
											if not comms_source:isDocked(comms_target) then 
												setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
												return
											end
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
							end
						end
					end
					if comms_target.comms_data.trade.luxury then
						if comms_source.goods ~= nil then
							if comms_source.goods.luxury ~= nil then
								if comms_source.goods.luxury.quantity > 0 then
									for good, goodData in pairs(comms_target.comms_data.goods) do
										addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
											if not comms_source:isDocked(comms_target) then 
												setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
												return
											end
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
							end
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
		end)
	end
end	--end of handleDockedState function
function getRepairCrewFromStation(relationship)
	addCommsReply(_("trade-comms","Recruit repair crew member"),function()
		if comms_target.comms_data.available_repair_crew == nil then
			comms_target.comms_data.available_repair_crew = math.random(0,3)
		end
		if comms_target.comms_data.available_repair_crew > 0 then	--station has repair crew available
			if comms_target.comms_data.crew_available_delay == nil then
				comms_target.comms_data.crew_available_delay = 0
			end
			if getScenarioTime() > comms_target.comms_data.crew_available_delay then	--no delay in progress
				if random(1,5) <= (3 - difficulty) then		--repair crew available
					local hire_cost = math.random(45,90)
					if relationship ~= "friendly" then
						hire_cost = math.random(60,120)
					end
					if comms_source:getRepairCrewCount() < comms_source.maxRepairCrew then
						hire_cost = math.random(30,60)
						if relationship ~= "friendly" then
							hire_cost = math.random(45,90)
						end
					end
					setCommsMessage(_("trade-comms","We have a repair crew candidate for you to consider"))
					addCommsReply(string.format(_("trade-comms", "Recruit repair crew member for %i reputation"),hire_cost), function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
							return
						end
						if not comms_source:takeReputationPoints(hire_cost) then
							setCommsMessage(_("needRep-comms", "Insufficient reputation"))
						else
							comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() + 1)
							comms_target.comms_data.available_repair_crew = comms_target.comms_data.available_repair_crew - 1
							if comms_target.comms_data.available_repair_crew <= 0 then
								comms_target.comms_data.new_repair_crew_delay = getScenarioTime() + random(200,500)
							end
							setCommsMessage(_("trade-comms", "Repair crew member hired"))
						end
						addCommsReply(_("Back"), commsStation)
					end)
				else	--repair crew delayed
					local delay_reason = {
						_("trade-comms","A possible repair recruit is awaiting final certification. They should be available in "),
						_("trade-comms","There's one repair crew candidate completing their license application. They should be available in "),
						_("trade-comms","One repair crew should be getting here from their medical checkout in "),
					}
					local delay_seconds = math.random(10,30)
					comms_target.comms_data.crew_available_delay = getScenarioTime() + delay_seconds
					comms_target.comms_data.crew_available_delay_reason = delay_reason[math.random(1,#delay_reason)]
					setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
				end
			else	--delay in progress
				local delay_seconds = math.floor(comms_target.comms_data.crew_available_delay - getScenarioTime())
				if delay_seconds > 1 then
					setCommsMessage(string.format(_("trade-comms","%s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
				else
					setCommsMessage(string.format(_("trade-comms","%s a second"),comms_target.comms_data.crew_available_delay_reason))
				end
			end
		else	--station does not have repair crew available
			if comms_target.comms_data.new_repair_crew_delay == nil then
				comms_target.comms_data.new_repair_crew_delay = 0
			end
			if getScenarioTime() > comms_target.comms_data.new_repair_crew_delay then
				comms_target.comms_data.available_repair_crew = math.random(1,3)
				local delay_reason = {
					_("trade-comms","A possible repair recruit is awaiting final certification. They should be available in "),
					_("trade-comms","There's one repair crew candidate completing their license application. They should be available in "),
					_("trade-comms","One repair crew should be getting here from their medical checkout in "),
				}
				local delay_seconds = math.random(10,30)
				comms_target.comms_data.crew_available_delay = getScenarioTime() + delay_seconds
				comms_target.comms_data.crew_available_delay_reason = delay_reason[math.random(1,#delay_reason)]
				setCommsMessage(string.format(_("trade-comms","Several arrived on station earlier. %s %i seconds"),comms_target.comms_data.crew_available_delay_reason,delay_seconds))
			else
				local delay_time = math.floor(comms_target.comms_data.new_repair_crew_delay - getScenarioTime())
				local delay_minutes = math.floor(delay_time / 60)
				local delay_seconds = math.floor(delay_time % 60)
				local delay_status = string.format(_("trade-comms","%i seconds"),delay_seconds)
				if delay_seconds == 1 then
					delay_status = string.format(_("trade-comms","%i second"),delay_seconds)
				end
				if delay_minutes > 0 then
					if delay_minutes > 1 then
						delay_status = string.format(_("trade-comms","%i minutes and %s"),delay_minutes,delay_status)
					else
						delay_status = string.format(_("trade-comms","%i minute and %s"),delay_minutes,delay_status)
					end							
				end
				setCommsMessage(string.format(_("trade-comms","There are some repair crew recruits in route for %s. Travel time remaining is %s."),comms_target:getCallSign(),delay_status))
			end
		end
		addCommsReply(_("Back"), commsStation)
	end)
end
function getCoolantFromStation(relationship)
	if comms_source.initialCoolant ~= nil then
		addCommsReply(_("trade-comms","Purchase Coolant"),function()
			if comms_target.comms_data.coolant_inventory == nil then
				comms_target.comms_data.coolant_inventory = math.random(0,3)*2
			end
			if comms_target.comms_data.coolant_inventory > 0 then	--station has coolant
				if comms_target.comms_data.coolant_packaging_delay == nil then
					comms_target.comms_data.coolant_packaging_delay = 0
				end
				if getScenarioTime() > comms_target.comms_data.coolant_packaging_delay then		--no delay
					if math.random(1,5) <= (3 - difficulty) then
						local coolantCost = math.random(45,90)
						if relationship ~= "friendly" then
							coolantCost = math.random(60,120)
						end
						if comms_source:getMaxCoolant() < comms_source.initialCoolant then
							coolantCost = math.random(30,60)
							if relationship ~= "friendly" then
								coolantCost = math.random(45,90)
							end
						end
						setCommsMessage(_("trade-comms","We've got some coolant available for you"))
						addCommsReply(string.format(_("trade-comms", "Purchase coolant for %i reputation"),coolantCost), function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
								return
							end
							if not comms_source:takeReputationPoints(coolantCost) then
								setCommsMessage(_("needRep-comms", "Insufficient reputation"))
							else
								comms_source:setMaxCoolant(comms_source:getMaxCoolant() + 2)
								comms_target.comms_data.coolant_inventory = comms_target.comms_data.coolant_inventory - 2
								if comms_target.comms_data.coolant_inventory <= 0 then
									comms_target.comms_data.coolant_inventory_delay = getScenarioTime() + random(60,300)
								end
								setCommsMessage(_("trade-comms", "Additional coolant purchased"))
							end
							addCommsReply(_("Back"), commsStation)
						end)
					else
						local delay_seconds = math.random(3,20)
						comms_target.comms_data.coolant_packaging_delay = getScenarioTime() + delay_seconds
						setCommsMessage(string.format(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transport. They say they should have it working in about %i seconds"),delay_seconds))
					end
				else	--delay in progress
					local delay_seconds = math.floor(comms_target.comms_data.coolant_packaging_delay - getScenarioTime())
					if delay_seconds > 1 then
						setCommsMessage(string.format(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transport. They say they should have it working in about %i seconds"),delay_seconds))
					else
						setCommsMessage(_("trade-comms","The coolant preparation facility is having difficulty packaging the coolant for transportation. They say they should have it working in a second"))
					end
				end
			else	--station is out of coolant
				if comms_target.comms_data.coolant_inventory_delay == nil then
					comms_target.comms_data.coolant_inventory_delay = 0
				end
				if getScenarioTime() > comms_target.comms_data.coolant_inventory_delay then
					comms_target.comms_data.coolant_inventory = math.random(1,3)*2
					local delay_seconds = math.random(3,20)
					comms_target.comms_data.coolant_packaging_delay = getScenarioTime() + delay_seconds
					setCommsMessage(string.format(_("trade-comms","Our coolant production facility just made some, but it's not quite ready to be transported. The preparation facility says it should take about %i seconds"),delay_seconds))
				else
					local delay_time = math.floor(comms_target.comms_data.coolant_inventory_delay - getScenarioTime())
					local delay_minutes = math.floor(delay_time / 60)
					local delay_seconds = math.floor(delay_time % 60)
					local delay_status = string.format(_("trade-comms","%i seconds"),delay_seconds)
					if delay_seconds == 1 then
						delay_status = string.format(_("trade-comms","%i second"),delay_seconds)
					end
					if delay_minutes > 0 then
						if delay_minutes > 1 then
							delay_status = string.format(_("trade-comms","%i minutes and %s"),delay_minutes,delay_status)
						else
							delay_status = string.format(_("trade-comms","%i minute and %s"),delay_minutes,delay_status)
						end							
					end
					setCommsMessage(string.format(_("trade-comms","Our coolant production facility is making more right now. Coolant manufacturing time remaining is %s."),delay_status))
				end
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
end
function setSecondaryOrders()
	secondary_orders = ""
	if getScenarioTime() > possible_victory_time then
		if comms_source.aggressive_enemy ~= nil then
			if comms_source.aggressive_enemy:isValid() then
				secondary_orders = string.format(_("orders-comms","Destroy aggressive enemy bases including %s station %s in %s."),comms_source.aggressive_enemy:getFaction(),comms_source.aggressive_enemy:getCallSign(),comms_source.aggressive_enemy:getSectorName())
			else
				secondary_orders = _("orders-comms","Destroy aggressive enemy bases.")
			end
		end
	end
end
function setOptionalOrders()
	optional_orders = ""
	if comms_source.transport_mission ~= nil or comms_source.cargo_mission ~= nil then
		optional_orders = _("orders-comms","\nOptional:")
	end
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to %s station %s in %s"),optional_orders,comms_source.transport_mission.character,comms_source.transport_mission.destination:getFaction(),comms_source.transport_mission.destination_name,comms_source.transport_mission.destination:getSectorName())
		else
			optional_orders = string.format(_("orders-comms","%s\nTransport %s to station %s (defunct)"),optional_orders,comms_source.transport_mission.character,comms_source.transport_mission.destination_name)
		end
	end
	if comms_source.cargo_mission ~= nil then
		if comms_source.cargo_mission.loaded then
			if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s in %s"),optional_orders,comms_source.cargo_mission.character,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.destination:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nDeliver cargo for %s to station %s (defunct)"),optional_orders,comms_source.cargo_mission.character,comms_source.cargo_mission.destination_name)
			end
		else
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s in %s"),optional_orders,comms_source.cargo_mission.character,comms_source.cargo_mission.origin_name,comms_source.cargo_mission.origin:getSectorName())
			else
				optional_orders = string.format(_("orders-comms","%s\nPick up cargo for %s at station %s (defunct)"),optional_orders,comms_source.cargo_mission.character,comms_source.cargo_mission.origin_name)
			end
		end
	end
	local out1 = "None"
	if comms_source.saboteur_instructions ~= nil then
		out1 = comms_source.saboteur_instructions
	end
	local out2 = "No deployed ship"
	if comms_source.saboteur_deployed ~= nil then
		out2 = comms_source.saboteur_deployed
	end
	local out3 = "None"
	if comms_source.saboteur_ship ~= nil then
		out3 = comms_source.saboteur_ship
	end
	local out4 = "Not successful"
	local out5 = "No target"
	if comms_source.saboteur_ship ~= nil and comms_source.saboteur_ship:isValid() then
		if comms_source.saboteur_ship.sabotage_success ~= nil then
			out4 = comms_source.saboteur_ship.sabotage_success
		end
		if comms_source.saboteur_ship.sabotage_target ~= nil and comms_source.saboteur_ship.sabotage_target:isValid() then
			out5 = comms_source.saboteur_ship.sabotage_target:getCallSign()
		else
			out5 = "Target destroyed"
		end
	end
	print("instructions:",out1,"deployed:",out2,"ship:",out3,"success:",out4,"target:",out5)
	if comms_source.saboteur_instructions ~= nil then
		if comms_source.saboteur_deployed ~= nil then
			if comms_source.saboteur_ship ~= nil and comms_source.saboteur_ship:isValid() then
				if comms_source.saboteur_ship.sabotage_success == nil then
					local docked_station = comms_source.saboteur_ship:getDockedWith()
					if comms_source.saboteur_ship.sabotage_target ~= nil then
						if comms_source.saboteur_ship.sabotage_target:isValid() then
							if docked_station == nil then
								optional_orders = string.format(_("orders-comms","%s\nExplosives planted on aggressive %s station %s. Expect detonation in %s seconds"),optional_orders,comms_source.saboteur_ship.sabotage_target:getFaction(),comms_source.saboteur_ship.sabotage_target:getCallSign(),math.floor(comms_source.saboteur_ship.explode_time - getScenarioTime()))
							else
								optional_orders = string.format(_("orders-comms","%s\nSaboteur's ship, %s, docked with %s station %s in sector %s. %s has been identified as an aggressive station. Explosives have been planted. Expect detonation in %s seconds"),optional_orders,comms_source.saboteur_deployed,docked_station:getFaction(),docked_station:getCallSign(),docked_station:getSectorName(),docked_station:getCallSign(),math.floor(comms_source.saboteur_ship.explode_time - getScenarioTime()))
							end
						else
							optional_orders = string.format(_("orders-comms","%s\nSabotage target station has been destroyed"),optional_orders)
						end
					else
						if docked_station == nil then
							local saboteur_target_aggressive = false
							local saboteur_target = comms_source.saboteur_ship:getOrderTarget()
							local target_station_message = ""
							if saboteur_target ~= nil then
								for _,station in ipairs(circle_stations) do
									if station ~= nil and station:isValid() then
										if station == saboteur_target then
											if comms_source:isEnemy(station) then
												saboteur_target_aggressive = true
											end
											break
										end
									end
								end
								target_station_message = string.format(_("orders-comms","%s's destination station, %s in %s, is not an aggressive enemy station."),comms_source.saboteur_deployed,saboteur_target:getCallSign(),saboteur_target:getSectorName())
								if saboteur_target_aggressive then
									target_station_message = string.format(_("orders-comms","%s's destination station, %s in %s, has been identified as an aggressive enemy station."),comms_source.saboteur_deployed,saboteur_target:getCallSign(),saboteur_target:getSectorName())
								end
							end
							optional_orders = string.format(_("orders-comms","%s\nSaboteur's ship, %s, is in transit in sector %s. %s"),optional_orders,comms_source.saboteur_deployed,comms_source.saboteur_ship:getSectorName(),target_station_message)
						else
							local in_circle = false
							for _, station in ipairs(circle_stations) do
								if docked_station == station then
									in_circle = true
									break
								end
							end
							if docked_station:isEnemy(comms_source) then
								if in_circle then
									optional_orders = string.format(_("orders-comms","%s\nSaboteur's ship, %s, docked with %s station %s in sector %s. %s has been identified as an aggressive station"),optional_orders,comms_source.saboteur_deployed,docked_station:getFaction(),docked_station:getCallSign(),docked_station:getSectorName(),docked_station:getCallSign())
								else
									optional_orders = string.format(_("orders-comms","%s\nSaboteur's ship, %s, docked with %s station %s in sector %s. %s is not an aggressive station"),optional_orders,comms_source.saboteur_deployed,docked_station:getFaction(),docked_station:getCallSign(),docked_station:getSectorName(),docked_station:getCallSign())
								end
							else
								optional_orders = string.format(_("orders-comms","%s\nSaboteur's ship, %s, docked with %s station %s in sector %s."),optional_orders,comms_source.saboteur_deployed,docked_station:getFaction(),docked_station:getCallSign(),docked_station:getSectorName())
							end
						end
					end
				else
					optional_orders = string.format(_("orders-comms","%s\nSaboteur successfully destroyed aggressive enemy station %s"),optional_orders,comms_source.saboteur_ship.sabotage_success)
				end
			else
				optional_orders = string.format(_("orders-comms","%s\nSaboteur's ship, %s, has been destroyed"),optional_orders,comms_source.saboteur_deployed)
			end
		else
			optional_orders = string.format(_("orders-comms","%s\nPlant saboteur on freighter"),optional_orders)
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
		setCommsMessage(_("ammo-comms", "You need to stay docked for that action."))
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
		if comms_source:getReputationPoints() > points_per_item * item_amount then
			if comms_source:takeReputationPoints(points_per_item * item_amount) then
				comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + item_amount)
				if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
		            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
				else
		            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
				end
			else
	            setCommsMessage(_("needRep-comms", "Not enough reputation."))
				return
			end
		else
			if comms_source:getReputationPoints() > points_per_item then
				setCommsMessage(_("ammo-comms","You can't afford as much as I'd like to give you"))
				addCommsReply(_("ammo-comms","Get just one"), function()
					if comms_source:takeReputationPoints(points_per_item) then
						comms_source:setWeaponStorage(weapon, comms_source:getWeaponStorage(weapon) + 1)
						if comms_source:getWeaponStorage(weapon) == comms_source:getWeaponStorageMax(weapon) then
				            setCommsMessage(_("ammo-comms", "You are fully loaded and ready to explode things."))
						else
				            setCommsMessage(_("ammo-comms", "We generously resupplied you with some weapon charges.\nPut them to good use."))
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
    if comms_source:isFriendly(comms_target) then
        oMsg = _("station-comms", "Good day, officer.\nIf you need supplies, please dock with us first.")
    else
        oMsg = _("station-comms", "Greetings.\nIf you want to do business, please dock with us first.")
    end
    if comms_target:areEnemiesInRange(20000) then
		oMsg = oMsg .. _("station-comms", "\nBe aware that if enemies in the area get much closer, we will be too busy to conduct business with you.")
	end
	if comms_target == station_regional_hq then
		if player_ship.checklist_complete == "yes" then
			if player_ship.congratulations_message == nil then
				local completed_minutes = math.floor(checklist_elapsed_time / 60)
				local completed_seconds = math.floor(checklist_elapsed_time % 60)
				oMsg = string.format("Congratulations captain and crew of the newly built %s, you completed the inspection checklist in %i minutes and %i seconds!",player_ship:getCallSign(),completed_minutes,completed_seconds)
				player_ship.congratulations_message = "sent"
			end
		end
		commsChecklist()
	end
	setCommsMessage(oMsg)
	local count_repeat_loop = 0
	if count_repeat_loop > max_repeat_loop then
		print("repeated too many times when cleaning warp jammer list")
	end
	local accessible_warp_jammers = {}
	if comms_target.warp_jammer_list ~= nil then
		for index, wj in ipairs (comms_target.warp_jammer_list) do
			if wj ~= nil and wj:isValid() then
				table.insert(accessible_warp_jammers,wj)
			end
		end
	end
	for _, wj in ipairs(warp_jammer_list) do
		if wj ~= nil and wj:isValid() then
			local already_accessible = false
			for _, awj in ipairs(accessible_warp_jammers) do
				if awj == wj then
					already_accessible = true
				end
			end
			if not already_accessible then
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
						else
							wj_rep = 5
						end
					end
				elseif wj:isEnemy(comms_target) then
					if wj:isFriendly(comms_source) then
						wj_rep = 15
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 100
						else
							wj_rep = 20
						end
					end
				else
					if wj:isFriendly(comms_source) then
						wj_rep = 10
					else
						if wj:isEnemy(comms_source) then
							wj_rep = 25
						else
							wj_rep = 20
						end
					end
				end
				local reputation_prompt = ""
				if wj_rep > 0 then
					reputation_prompt = string.format(_("station-comms","(%i reputation)"),wj_rep)
					pay_rep = true
				end
				addCommsReply(string.format("%s %s",wj:getCallSign(),reputation_prompt),function()
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
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			if comms_source == player_ship then
				primary_orders = string.format(_("orders-comms","Complete the inspection checklist for %s."),player_ship:getCallSign())
				if player_ship.checklist_complete == "yes" then
					primary_orders = _("orders-comms","Return the ship to the shipyard")
				end
			elseif comms_source == initial_player_ship then
				primary_orders = string.format(_("orders-comms","Inspect ship produced by the shipyard at %s."),station_regional_hq:getCallSign())
			else
				primary_orders = string.format(_("orders-comms","Be a shining example of a crewmember of %s."),comms_source:getCallSign())
			end
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		addCommsReply(_("station-comms","Station services (ordnance restock, repair)"),function()
			setCommsMessage(_("station-comms","We offer a variety of services when you dock with us."))
			addCommsReply(_("ammo-comms", "What ordnance do you have available for restock?"), function()
				local missileTypeAvailableCount = 0
				local ordnanceListMsg = ""
				if comms_target.comms_data.weapon_available.Nuke then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Nuke")
				end
				if comms_target.comms_data.weapon_available.EMP then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   EMP")
				end
				if comms_target.comms_data.weapon_available.Homing then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Homing")
				end
				if comms_target.comms_data.weapon_available.Mine then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   Mine")
				end
				if comms_target.comms_data.weapon_available.HVLI then
					missileTypeAvailableCount = missileTypeAvailableCount + 1
					ordnanceListMsg = ordnanceListMsg .. _("ammo-comms", "\n   HVLI")
				end
				if missileTypeAvailableCount == 0 then
					ordnanceListMsg = _("ammo-comms", "We have no ordnance available for restock")
				elseif missileTypeAvailableCount == 1 then
					ordnanceListMsg = string.format(_("ammo-comms", "We have the following type of ordnance available for restock:%s"),ordnanceListMsg)
				else
					ordnanceListMsg = string.format(_("ammo-comms", "We have the following types of ordnance available for restock:%s"),ordnanceListMsg)
				end
				setCommsMessage(ordnanceListMsg)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("dockingServicesStatus-comms", "Docking services status"), function()
				setCommsMessage(_("dockingServicesStatus-comms","Which docking service category do you want a status for?\n    Primary services:\n        Charge battery, repair hull, replenish probes\n    Secondary systems repair:\n        Scanners, hacking, probe launch, combat maneuver, self destruct\n    Upgrade ship systems:\n        Beam, missile, shield, hull, impulse, ftl, sensors"))
				addCommsReply(_("dockingServicesStatus-comms","Primary services"),function()
					local service_status = string.format(_("dockingServicesStatus-comms", "Station %s primary docking services status:"),comms_target:getCallSign())
					if comms_target:getRestocksScanProbes() then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nReplenish scan probes."),service_status)
					else
						if comms_target.probe_fail_reason == nil then
							local reason_list = {
								_("dockingServicesStatus-comms", "Cannot replenish scan probes due to fabrication unit failure."),
								_("dockingServicesStatus-comms", "Parts shortage prevents scan probe replenishment."),
								_("dockingServicesStatus-comms", "Station management has curtailed scan probe replenishment for cost cutting reasons."),
							}
							comms_target.probe_fail_reason = reason_list[math.random(1,#reason_list)]
						end
						service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
					end
					if comms_target:getRepairDocked() then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nShip hull repair."),service_status)
					else
						if comms_target.repair_fail_reason == nil then
							reason_list = {
								_("dockingServicesStatus-comms", "We're out of the necessary materials and supplies for hull repair."),
								_("dockingServicesStatus-comms", "Hull repair automation unavailable whie it is undergoing maintenance."),
								_("dockingServicesStatus-comms", "All hull repair technicians quarantined to quarters due to illness."),
							}
							comms_target.repair_fail_reason = reason_list[math.random(1,#reason_list)]
						end
						service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
					end
					if comms_target:getSharesEnergyWithDocked() then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nRecharge ship energy stores."),service_status)
					else
						if comms_target.energy_fail_reason == nil then
							reason_list = {
								_("dockingServicesStatus-comms", "A recent reactor failure has put us on auxiliary power, so we cannot recharge ships."),
								_("dockingServicesStatus-comms", "A damaged power coupling makes it too dangerous to recharge ships."),
								_("dockingServicesStatus-comms", "An asteroid strike damaged our solar cells and we are short on power, so we can't recharge ships right now."),
							}
							comms_target.energy_fail_reason = reason_list[math.random(1,#reason_list)]
						end
						service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
					end
					setCommsMessage(service_status)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("dockingServicesStatus-comms","Secondary systems repair"),function()
					local service_status = string.format(_("dockingServicesStatus-comms", "Station %s docking repair services status:"),comms_target:getCallSign())
					if comms_target.comms_data.jump_overcharge then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay overcharge jump drive"),service_status)
					end
					if comms_target.comms_data.probe_launch_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair probe launch system"),service_status)
					end
					if comms_target.comms_data.hack_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair hacking system"),service_status)
					end
					if comms_target.comms_data.scan_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair scanners"),service_status)
					end
					if comms_target.comms_data.combat_maneuver_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair combat maneuver"),service_status)
					end
					if comms_target.comms_data.self_destruct_repair then
						service_status = string.format(_("dockingServicesStatus-comms", "%s\nMay repair self destruct system"),service_status)
					end
					setCommsMessage(service_status)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end)
		addCommsReply(string.format(_("station-comms","Goods information at %s or near %s"),comms_target:getCallSign(),comms_target:getCallSign()),function()
			setCommsMessage(_("station-comms","Always good to get some goods"))
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
						goodsAvailableMsg = goodsAvailableMsg .. string.format("\n   %14s: %2i, %3i",good,goodData["quantity"],goodData["cost"])
					end
					setCommsMessage(goodsAvailableMsg)
					addCommsReply(_("Back"), commsStation)
				end)
			end
			addCommsReply(_("trade-comms","Where can I find particular goods?"), function()
				gkMsg = _("trade-comms","Friendly stations often have food or medicine or both. Neutral stations may trade their goods for food, medicine or luxury.")
				if comms_target.comms_data.goodsKnowledge == nil then
					comms_target.comms_data.goodsKnowledge = {}
					local knowledgeCount = 0
					local knowledgeMax = 10
					for i=1,#station_list do
						local station = station_list[i]
						if station ~= nil and station:isValid() then
							if not station:isEnemy(comms_source) then
								local brainCheckChance = 60
								if distance_diagnostic then print("distance_diagnostic 7",comms_target,station) end
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
						setCommsMessage(string.format(_("trade-comms","Station %s in sector %s has %s for %i reputation"),stationName,sectorName,goodName,goodCost))
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if goodsKnowledgeCount > 0 then
					gkMsg = gkMsg .. _("trade-comms","\n\nWhat goods are you interested in?\nI've heard about these:")
				else
					gkMsg = gkMsg .. _("trade-comms"," Beyond that, I have no knowledge of specific stations")
				end
				setCommsMessage(gkMsg)
				addCommsReply(_("Back"), commsStation)
			end)
		end)
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("stationGeneralInfo-comms","Tell me more about your station"), function()
				setCommsMessage(_("stationGeneralInfo-comms","What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("stationGeneralInfo-comms","General information"), function()
						setCommsMessage(comms_target.comms_data.general)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "" then
					addCommsReply(_("stationGeneralInfo-comms","Station history"), function()
						setCommsMessage(comms_target.comms_data.history)
						addCommsReply(_("Back"), commsStation)
					end)
				end
				if comms_source:isFriendly(comms_target) then
					if comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" then
						if has_gossip then
							addCommsReply(_("stationGeneralInfo-comms","Gossip"), function()
								setCommsMessage(comms_target.comms_data.gossip)
								addCommsReply(_("Back"), commsStation)
							end)
						end
					end
				end
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if comms_target.comms_data.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
				addCommsReply(string.format(_("stationGeneralInfo-comms","Tell me about %s"),comms_target.comms_data.character), function()
					if comms_target.comms_data.characterDescription ~= nil then
						setCommsMessage(comms_target.comms_data.characterDescription)
					else
						if comms_target.comms_data.characterDeadEnd == nil then
							local deadEndChoice = math.random(1,5)
							if deadEndChoice == 1 then
								comms_target.comms_data.characterDeadEnd = string.format(_("stationGeneralInfo-comms","Never heard of %s"),comms_target.comms_data.character)
							elseif deadEndChoice == 2 then
								comms_target.comms_data.characterDeadEnd = string.format(_("stationGeneralInfo-comms","%s died last week. The funeral was yesterday"),comms_target.comms_data.character)
							elseif deadEndChoice == 3 then
								comms_target.comms_data.characterDeadEnd = string.format(_("stationGeneralInfo-comms","%s? Who's %s? There's nobody here named %s"),comms_target.comms_data.character,comms_target.comms_data.character,comms_target.comms_data.character)
							elseif deadEndChoice == 4 then
								comms_target.comms_data.characterDeadEnd = string.format(_("stationGeneralInfo-comms","We don't talk about %s. They are gone and good riddance"),comms_target.comms_data.character)
							else
								comms_target.comms_data.characterDeadEnd = string.format(_("stationGeneralInfo-comms","I think %s moved away"),comms_target.comms_data.character)
							end
						end
						setCommsMessage(comms_target.comms_data.characterDeadEnd)
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		addCommsReply(_("situationReport-comms","Report status"), function()
			msg = _("situationReport-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. _("situationReport-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			else
				for n=0,shields-1 do
					msg = msg .. _("situationReport-comms","Shield ") .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
				end
			end			
			setCommsMessage(msg);
			addCommsReply(_("Back"), commsStation)
		end)
	end)
	if isAllowedTo(comms_target.comms_data.services.supplydrop) then
        addCommsReply(string.format(_("stationAssist-comms", "Can you send a supply drop? (%d rep)"), getServiceCost("supplydrop")), function()
            if comms_source:getWaypointCount() < 1 then
                setCommsMessage(_("stationAssist-comms", "You need to set a waypoint before you can request backup."));
            else
                setCommsMessage(_("stationAssist-comms", "To which waypoint should we deliver your supplies?"));
                for n=1,comms_source:getWaypointCount() do
                    addCommsReply("WP" .. n, function()
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
                    addCommsReply("WP" .. n, function()
						if comms_source:takeReputationPoints(getServiceCost("reinforcements")) then
							ship = CpuShip():setPosition(comms_target:getPosition()):setTemplate("Adder MK5"):setCallSign(generateCallSign(nil,"Human Navy")):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship:setFactionId(comms_target:getFactionId())
							ship:setCommsScript(""):setCommsFunction(commsShip):onDestruction(friendlyVesselDestroyed)
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
    if isAllowedTo(comms_target.comms_data.services.servicejonque) then
    	addCommsReply(_("stationAssist-comms","Please send a service jonque for repairs"), function()
    		local out = string.format(_("stationAssist-comms","Would you like the service jonque to come to you directly or would you prefer to set up a rendezvous via a waypoint? Either way, you will need %.1f reputation."),getServiceCost("servicejonque"))
    		addCommsReply("Direct",function()
    			if comms_source:takeReputationPoints(getServiceCost("servicejonque")) then
					ship = serviceJonque(comms_target:getFaction()):setPosition(comms_target:getPosition()):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendTarget(comms_source)
					ship.comms_data = {
						friendlyness = random(0.0, 100.0),
						weapons = {
							Homing = comms_target.comms_data.weapons.Homing,
							HVLI = comms_target.comms_data.weapons.HVLI,
							Mine = comms_target.comms_data.weapons.Mine,
							Nuke = comms_target.comms_data.weapons.Nuke,
							EMP = comms_target.comms_data.weapons.EMP,
						},
						weapon_cost = {
							Homing = comms_target.comms_data.weapon_cost.Homing * 2,
							HVLI = comms_target.comms_data.weapon_cost.HVLI * 2,
							Mine = comms_target.comms_data.weapon_cost.Mine * 2,
							Nuke = comms_target.comms_data.weapon_cost.Nuke * 2,
							EMP = comms_target.comms_data.weapon_cost.EMP * 2,
						},
						weapon_inventory = {
							Homing = 40,
							HVLI = 40,
							Mine = 20,
							Nuke = 10,
							EMP = 10,
						},
						weapon_inventory_max = {
							Homing = 40,
							HVLI = 40,
							Mine = 20,
							Nuke = 10,
							EMP = 10,
						},
						reputation_cost_multipliers = {
							friend = comms_target.comms_data.reputation_cost_multipliers.friend,
							neutral = math.max(comms_target.comms_data.reputation_cost_multipliers.friend,comms_target.comms_data.reputation_cost_multipliers.neutral/2)
						},
					}
					setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to come to you to help with repairs"),ship:getCallSign()))
    			else
					setCommsMessage(_("needRep-comms", "Not enough reputation!"));
    			end
    		end)
    		if comms_source:getWaypointCount() < 1 then
    			out = out .. _("stationAssist-comms","\n\nNote: if you want to use a waypoint, you will have to back out and set one and come back.")
    		else
    			for n=1,comms_source:getWaypointCount() do
    				addCommsReply(string.format(_("stationAssist-comms","Rendezvous at waypoint %i"),n),function()
    					if comms_source:takeReputationPoints(getServiceCost("servicejonque")) then
    						ship = serviceJonque(comms_target:getFaction()):setPosition(comms_target:getPosition()):setCallSign(generateCallSign(nil,comms_target:getFaction())):setScanned(true):orderDefendLocation(comms_source:getWaypoint(n))
							ship.comms_data = {
								friendlyness = random(0.0, 100.0),
								weapons = {
									Homing = comms_target.comms_data.weapons.Homing,
									HVLI = comms_target.comms_data.weapons.HVLI,
									Mine = comms_target.comms_data.weapons.Mine,
									Nuke = comms_target.comms_data.weapons.Nuke,
									EMP = comms_target.comms_data.weapons.EMP,
								},
								weapon_cost = {
									Homing = comms_target.comms_data.weapon_cost.Homing * 2,
									HVLI = comms_target.comms_data.weapon_cost.HVLI * 2,
									Mine = comms_target.comms_data.weapon_cost.Mine * 2,
									Nuke = comms_target.comms_data.weapon_cost.Nuke * 2,
									EMP = comms_target.comms_data.weapon_cost.EMP * 2,
								},
								weapon_inventory = {
									Homing = 40,
									HVLI = 40,
									Mine = 20,
									Nuke = 10,
									EMP = 10,
								},
								weapon_inventory_max = {
									Homing = 40,
									HVLI = 40,
									Mine = 20,
									Nuke = 10,
									EMP = 10,
								},
								reputation_cost_multipliers = {
									friend = comms_target.comms_data.reputation_cost_multipliers.friend,
									neutral = math.max(comms_target.comms_data.reputation_cost_multipliers.friend,comms_target.comms_data.reputation_cost_multipliers.neutral/2)
								},
							}
    						setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to rendezvous at waypoint %i"),ship:getCallSign(),n))
    					else
							setCommsMessage(_("needRep-comms", "Not enough reputation!"));
    					end
			            addCommsReply(_("Back"), commsStation)
    				end)
    			end
    		end
    		setCommsMessage(out)
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

------------------------
-- Ship communication --
------------------------
function commsShip()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_data.goods == nil then
		goodsOnShip(comms_target,comms_data)
	end
	if comms_source:isFriendly(comms_target) then
		return friendlyComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralComms(comms_data)
end
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
function friendlyComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("shipAssist-comms", "What do you want?"));
	else
		setCommsMessage(_("shipAssist-comms", "Sir, how can we assist?"));
	end
	addCommsReply(_("shipAssist-comms", "Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms", "No waypoints set. Please set a waypoint first."));
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
		addCommsReply(_("Back"), commsShip)
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms", "Assist me"), function()
			setCommsMessage(_("shipAssist-comms", "Heading toward you to assist."));
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsShip)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		msg = _("shipAssist-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("shipAssist-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("shipAssist-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("shipAssist-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("shipAssist-comms","Shield ") .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for i, missile_type in ipairs(missile_types) do
			if comms_target:getWeaponStorageMax(missile_type) > 0 then
					msg = msg .. missile_type .. _("shipAssist-comms"," Missiles: ") .. math.floor(comms_target:getWeaponStorage(missile_type)) .. "/" .. math.floor(comms_target:getWeaponStorageMax(missile_type)) .. "\n"
			end
		end
		local docked_with = comms_target:getDockedWith()
		if docked_with ~= nil then
			msg = string.format(_("shipAssist-comms","%s\nDocked with %s"),msg,docked_with:getCallSign())
		else
			if string.find("Dock",comms_target:getOrder()) then
				local transport_target = comms_target:getOrderTarget()
				if transport_target ~= nil and transport_target:isValid() then
					msg = string.format(_("shipAssist-comms","%s\nHeading for %s"),msg,transport_target:getCallSign())
				end
			end
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsShip)
	end)
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			if comms_target:getTypeName() ~= "Defense platform" then
				addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
					setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
					comms_target:orderDock(obj)
					addCommsReply(_("Back"), commsShip)
				end)
			end
		end
	end
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		if distance(comms_source, comms_target) < 5000 then
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
								addCommsReply("Back", commsShip)
							end)
						end
					end
					addCommsReply(_("Back"), commsShip)
				end)
			end
			if comms_data.friendlyness > 66 then
				if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
					if comms_source.goods ~= nil and comms_source.goods.luxury ~= nil and comms_source.goods.luxury > 0 then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 and good ~= "luxury" then
								addCommsReply(string.format(_("trade-comms", "Trade luxury for %s"),good), function()
									goodData.quantity = goodData.quantity - 1
									if comms_source.goods == nil then
										comms_source.goods = {}
									end
									if comms_source.goods[good] == nil then
										comms_source.goods[good] = 0
									end
									comms_source.goods[good] = comms_source.goods[good] + 1
									comms_source.goods.luxury = comms_source.goods.luxury - 1
									setCommsMessage(string.format(_("trade-comms", "Traded luxury for %s"),good))
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end	--player has luxury branch
				end	--goods or equipment freighter
				if comms_source.cargo > 0 then
					for good, goodData in pairs(comms_data.goods) do
						if goodData.quantity > 0 then
							addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
								if comms_source:takeReputationPoints(goodData.cost) then
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
								addCommsReply(_("Back"), commsShip)
							end)
						end
					end	--freighter goods loop
				end	--player has cargo space branch
			elseif comms_data.friendlyness > 33 then
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					else	--not goods or equipment freighter
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end
				end	--player has room for cargo branch
			else	--least friendly
				if comms_source.cargo > 0 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end	--freighter has something to sell branch
						end	--freighter goods loop
					end	--goods or equipment freighter
				end	--player has room to get goods
			end	--various friendliness choices
		else	--not close enough to sell
			addCommsReply(_("trade-comms","Do you have cargo you might sell?"), function()
				local goodCount = 0
				local cargoMsg = _("trade-comms","We've got ")
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
					cargoMsg = cargoMsg .. _("trade-comms","nothing")
				end
				setCommsMessage(cargoMsg)
				addCommsReply(_("Back"), commsShip)
			end)
		end
	end
	return true
end
function enemyComms(comms_data)
	local faction = comms_target:getFaction()
	local tauntable = false
	local amenable = false
	if comms_data.friendlyness >= 33 then	--final: 33
		--taunt logic
		local taunt_option = _("shipEnemy-comms", "We will see to your destruction!")
		local taunt_success_reply = _("shipEnemy-comms", "Your bloodline will end here!")
		local taunt_failed_reply = _("shipEnemy-comms", "Your feeble threats are meaningless.")
		local taunt_threshold = 30		--base chance of being taunted
		local immolation_threshold = 5	--base chance that taunting will enrage to the point of revenge immolation
		if faction == "Kraylor" then
			taunt_threshold = 35
			immolation_threshold = 6
			setCommsMessage(_("shipEnemy-comms", "Ktzzzsss.\nYou will DIEEee weaklingsss!"));
			local kraylorTauntChoice = math.random(1,3)
			if kraylorTauntChoice == 1 then
				taunt_option = _("shipEnemy-comms","We will destroy you")
				taunt_success_reply = _("shipEnemy-comms","We think not. It is you who will experience destruction!")
			elseif kraylorTauntChoice == 2 then
				taunt_option = _("shipEnemy-comms","You have no honor")
				taunt_success_reply = _("shipEnemy-comms","Your insult has brought our wrath upon you. Prepare to die.")
				taunt_failed_reply = _("shipEnemy-comms","Your comments about honor have no meaning to us")
			else
				taunt_option = _("shipEnemy-comms","We pity your pathetic race")
				taunt_success_reply = _("shipEnemy-comms","Pathetic? You will regret your disparagement!")
				taunt_failed_reply = _("shipEnemy-comms","We don't care what you think of us")
			end
		elseif faction == "Arlenians" then
			taunt_threshold = 25
			immolation_threshold = 4
			setCommsMessage(_("shipEnemy-comms","We wish you no harm, but will harm you if we must.\nEnd of transmission."))
		elseif faction == "Exuari" then
			taunt_threshold = 40
			immolation_threshold = 7
			setCommsMessage(_("shipEnemy-comms","Stay out of our way, or your death will amuse us extremely!"))
		elseif faction == "Ghosts" then
			taunt_threshold = 20
			immolation_threshold = 3
			setCommsMessage(_("shipEnemy-comms","One zero one.\nNo binary communication detected.\nSwitching to universal speech.\nGenerating appropriate response for target from human language archives.\n:Do not cross us:\nCommunication halted."))
			taunt_option = _("shipEnemy-comms","EXECUTE: SELFDESTRUCT")
			taunt_success_reply = _("shipEnemy-comms","Rogue command received. Targeting source.")
			taunt_failed_reply = _("shipEnemy-comms","External command ignored.")
		elseif faction == "Ktlitans" then
			setCommsMessage(_("shipEnemy-comms","The hive suffers no threats. Opposition to any of us is opposition to us all.\nStand down or prepare to donate your corpses toward our nutrition."))
			taunt_option = _("shipEnemy-comms","<Transmit 'The Itsy-Bitsy Spider' on all wavelengths>")
			taunt_success_reply = _("shipEnemy-comms","We do not need permission to pluck apart such an insignificant threat.")
			taunt_failed_reply = _("shipEnemy-comms","The hive has greater priorities than exterminating pests.")
		elseif faction == "TSN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms","State your business"))
		elseif faction == "USN" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms","What do you want? (not that we care)"))
		elseif faction == "CUF" then
			taunt_threshold = 15
			immolation_threshold = 2
			setCommsMessage(_("shipEnemy-comms","Don't waste our time"))
		else
			setCommsMessage(_("shipEnemy-comms","Mind your own business!"))
		end
		comms_data.friendlyness = comms_data.friendlyness - random(0, 10)	--reduce friendlyness after each interaction
		addCommsReply(taunt_option, function()
			if random(0, 100) <= taunt_threshold then
				local current_order = comms_target:getOrder()
--				print("order: " .. current_order)
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
				--possible alternative consequences when taunt fails
				if random(1,100) < (immolation_threshold + difficulty) then	--final: immolation_threshold (set to 100 for testing)
					setCommsMessage(_("shipEnemy-comms","Subspace and time continuum disruption authorized"))
					comms_source.continuum_target = true
					comms_source.continuum_initiator = comms_target
					plotContinuum = checkContinuum
				else
					setCommsMessage(taunt_failed_reply);
				end
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
		addCommsReply(_("shipEnemy-comms","Stop your actions"),function()
			local amenable_roll = random(1,100)
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
				comms_target.amenability_may_expire = true		--set up conditional in future refactoring
				comms_target:orderIdle()
				comms_target:setFaction("Independent")
				setCommsMessage(_("shipEnemy-comms","Just this once, we'll take your advice"))
			else
				setCommsMessage(_("shipEnemy-comms","No"))
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
function getEnemyHealth(enemy)
	local enemy_health = 0
	local enemy_shield = 0
	local enemy_shield_count = enemy:getShieldCount()
	local faction = enemy:getFaction()
	if change_enemy_order_diagnostic then print(string.format("%s statistics:",enemy:getCallSign())) end
	if change_enemy_order_diagnostic then print(string.format("   shield count:    %i",enemy_shield_count)) end
	if enemy_shield_count > 0 then
		local total_shield_level = 0
		local max_shield_level = 0
		for i=1,enemy_shield_count do
			total_shield_level = total_shield_level + enemy:getShieldLevel(i-1)
			max_shield_level = max_shield_level + enemy:getShieldMax(i-1)
		end
		enemy_shield = total_shield_level/max_shield_level
	else
		enemy_shield = 1
	end
	if change_enemy_order_diagnostic then print(string.format("   shield health:   %.1f",enemy_shield)) end
	local enemy_hull = enemy:getHull()/enemy:getHullMax()
	if change_enemy_order_diagnostic then print(string.format("   hull health:     %.1f",enemy_hull)) end
	local enemy_reactor = enemy:getSystemHealth("reactor")
	if change_enemy_order_diagnostic then print(string.format("   reactor health:  %.1f",enemy_reactor)) end
	local enemy_maneuver = enemy:getSystemHealth("maneuver")
	if change_enemy_order_diagnostic then print(string.format("   maneuver health: %.1f",enemy_maneuver)) end
	local enemy_impulse = enemy:getSystemHealth("impulse")
	if change_enemy_order_diagnostic then print(string.format("   impulse health:  %.1f",enemy_impulse)) end
	local enemy_beam = 0
	if enemy:getBeamWeaponRange(0) > 0 then
		enemy_beam = enemy:getSystemHealth("beamweapons")
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f",enemy_beam)) end
	else
		enemy_beam = 1
		if change_enemy_order_diagnostic then print(string.format("   beam health:     %.1f (no beams)",enemy_beam)) end
	end
	local enemy_missile = 0
	if enemy:getWeaponTubeCount() > 0 then
		enemy_missile = enemy:getSystemHealth("missilesystem")
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f",enemy_missile)) end
	else
		enemy_missile = 1
		if change_enemy_order_diagnostic then print(string.format("   missile health:  %.1f (no missile system)",enemy_missile)) end
	end
	local enemy_warp = 0
	if enemy:hasWarpDrive() then
		enemy_warp = enemy:getSystemHealth("warp")
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f",enemy_warp)) end
	else
		enemy_warp = 1
		if change_enemy_order_diagnostic then print(string.format("   warp health:     %.1f (no warp drive)",enemy_warp)) end
	end
	local enemy_jump = 0
	if enemy:hasJumpDrive() then
		enemy_jump = enemy:getSystemHealth("jumpdrive")
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f",enemy_jump)) end
	else
		enemy_jump = 1
		if change_enemy_order_diagnostic then print(string.format("   jump health:     %.1f (no jump drive)",enemy_jump)) end
	end
	if change_enemy_order_diagnostic then print(string.format("   faction:         %s",faction)) end
	if faction == "Kraylor" then
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .03	+
			enemy_jump		* .03
	elseif faction == "Arlenians" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .45	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .04	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .02	+
			enemy_jump		* .02	
	elseif faction == "Exuari" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .2 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "Ghosts" then
		enemy_health = 
			enemy_shield 	* .25	+
			enemy_hull		* .25	+
			enemy_reactor	* .25 	+
			enemy_maneuver	* .04	+
			enemy_impulse	* .05	+
			enemy_beam		* .04	+
			enemy_missile	* .04	+
			enemy_warp		* .04	+
			enemy_jump		* .04	
	elseif faction == "Ktlitans" then
		enemy_health = 
			enemy_shield 	* .2	+
			enemy_hull		* .3	+
			enemy_reactor	* .1 	+
			enemy_maneuver	* .05	+
			enemy_impulse	* .05	+
			enemy_beam		* .05	+
			enemy_missile	* .05	+
			enemy_warp		* .1	+
			enemy_jump		* .1	
	elseif faction == "TSN" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .35	+
			enemy_reactor	* .08 	+
			enemy_maneuver	* .01	+
			enemy_impulse	* .02	+
			enemy_beam		* .02	+
			enemy_missile	* .01	+
			enemy_warp		* .08	+
			enemy_jump		* .08	
	elseif faction == "USN" then
		enemy_health = 
			enemy_shield 	* .38	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .02	+
			enemy_impulse	* .03	+
			enemy_beam		* .02	+
			enemy_missile	* .02	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	elseif faction == "CUF" then
		enemy_health = 
			enemy_shield 	* .35	+
			enemy_hull		* .38	+
			enemy_reactor	* .05 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .03	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .06	+
			enemy_jump		* .04	
	else
		enemy_health = 
			enemy_shield 	* .3	+
			enemy_hull		* .4	+
			enemy_reactor	* .06 	+
			enemy_maneuver	* .03	+
			enemy_impulse	* .05	+
			enemy_beam		* .03	+
			enemy_missile	* .03	+
			enemy_warp		* .05	+
			enemy_jump		* .05	
	end
	return enemy_health
end
function revertWait(delta)
	revert_timer = revert_timer - delta
	if revert_timer < 0 then
		revert_timer = delta + revert_timer_interval
		plotRevert = revertCheck
	end
end
function revertCheck(delta)
	if enemy_reverts ~= nil then
		for _, enemy in ipairs(enemy_reverts) do
			if enemy ~= nil and enemy:isValid() then
				local expiration_chance = 0
				local enemy_faction = enemy:getFaction()
				if enemy.taunt_may_expire then
					if enemy_faction == "Kraylor" then
						expiration_chance = 4.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 7
					elseif enemy_faction == "Exuari" then
						expiration_chance = 2.5
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 8.5
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 5.5
					elseif enemy_faction == "TSN" then
						expiration_chance = 3
					elseif enemy_faction == "USN" then
						expiration_chance = 3.5
					elseif enemy_faction == "CUF" then
						expiration_chance = 4
					else
						expiration_chance = 6
					end
				elseif enemy.amenability_may_expire then
					local enemy_health = getEnemyHealth(enemy)
					if enemy_faction == "Kraylor" then
						expiration_chance = 2.5
					elseif enemy_faction == "Arlenians" then
						expiration_chance = 3.25
					elseif enemy_faction == "Exuari" then
						expiration_chance = 6.6
					elseif enemy_faction == "Ghosts" then
						expiration_chance = 3.2
					elseif enemy_faction == "Ktlitans" then
						expiration_chance = 4.8
					elseif enemy_faction == "TSN" then
						expiration_chance = 3.5
					elseif enemy_faction == "USN" then
						expiration_chance = 2.8
					elseif enemy_faction == "CUF" then
						expiration_chance = 3
					else
						expiration_chance = 4
					end
					expiration_chance = expiration_chance + enemy_health*5
				end
				local expiration_roll = random(1,100)
				if expiration_roll < expiration_chance then
					local oo = enemy.original_order
					local otx = enemy.original_target_x
					local oty = enemy.original_target_y
					local ot = enemy.original_target
					if oo ~= nil then
						if oo == "Attack" then
							if ot ~= nil and ot:isValid() then
								enemy:orderAttack(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Dock" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDock(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Target" then
							if ot ~= nil and ot:isValid() then
								enemy:orderDefendTarget(ot)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowards(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Defend Location" then
							if otx ~= nil and oty ~= nil then
								enemy:orderDefendLocation(otx,oty)
							else
								enemy:orderRoaming()
							end
						elseif oo == "Fly towards (ignore all)" then
							if otx ~= nil and oty ~= nil then
								enemy:orderFlyTowardsBlind(otx,oty)
							else
								enemy:orderRoaming()
							end
						else
							enemy:orderRoaming()
						end
					else
						enemy:orderRoaming()
					end
					if enemy.original_faction ~= nil then
						enemy:setFaction(enemy.original_faction)
					end
					enemy.taunt_may_expire = false
					enemy.amenability_may_expire = false
				end
			end
		end
	end
	plotRevert = revertWait
end
function checkContinuum(delta)
	local continuum_count = 0
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			if p.continuum_target then
				continuum_count = continuum_count + 1
				if p.continuum_timer == nil then
					p.continuum_timer = delta + 30
				end
				p.continuum_timer = p.continuum_timer - delta
				if p.continuum_timer < 0 then
					if p.continuum_initiator ~= nil and p.continuum_initiator:isValid() then
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("frontshield",(p:getSystemHealth("frontshield") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("rearshield",(p:getSystemHealth("rearshield") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("reactor",(p:getSystemHealth("reactor") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("maneuver",(p:getSystemHealth("maneuver") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("impulse",(p:getSystemHealth("impulse") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("beamweapons",(p:getSystemHealth("beamweapons") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("missilesystem",(p:getSystemHealth("missilesystem") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("warp",(p:getSystemHealth("warp") - 1)/2) end
						if random(1,100) < (30 + (difficulty*4)) then p:setSystemHealth("jumpdrive",(p:getSystemHealth("jumpdrive") - 1)/2) end
						local ex, ey = p.continuum_initiator:getPosition()
						p.continuum_initiator:destroy()
						ExplosionEffect():setPosition(ex,ey):setSize(3000)
						resetContinuum(p)
					else
						resetContinuum(p)
					end
				else
					local timer_display = string.format(_("tabRelay","Disruption %i"),math.floor(p.continuum_timer))
					if p:hasPlayerAtPosition("Relay") then
						p.continuum_timer_display = "continuum_timer_display"
						p:addCustomInfo("Relay",p.continuum_timer_display,timer_display,1)
					end
					if p:hasPlayerAtPosition("Operations") then
						p.continuum_timer_display_ops = "continuum_timer_display_ops"
						p:addCustomInfo("Operations",p.continuum_timer_display_ops,timer_display,1)
					end
				end
			else
				resetContinuum(p)
			end
		end
	end
end
function resetContinuum(p)
	p.continuum_target = nil
	p.continuum_timer = nil
	p.continuum_initiator = nil
	if p.continuum_timer_display ~= nil then
		p:removeCustom("Relay",p.continuum_timer_display)
		p.continuum_timer_display = nil
	end
	if p.continuum_timer_display_ops ~= nil then
		p:removeCustom("Operations",p.continuum_timer_display_ops)
		p.continuum_timer_display_ops = nil
	end
end
function neutralComms(comms_data)
	local shipType = comms_target:getTypeName()
	if shipType:find("Freighter") ~= nil then
		setCommsMessage(_("trade-comms","Yes?"))
		addCommsReply(_("trade-comms","Do you have cargo you might sell?"), function()
			local goodCount = 0
			local cargoMsg = _("trade-comms","We've got ")
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
				cargoMsg = cargoMsg .. _("trade-comms","nothing")
			end
			setCommsMessage(cargoMsg)
		end)
		if distance_diagnostic then print("distance_diagnostic 9",comms_source,comms_target) end
		if distance(comms_source,comms_target) < 5000 then
			addCommsReply(_("shipAssist-comms","Where are you going?"),function()
				local docked_with = comms_target:getDockedWith()
				local msg = string.format(_("shipAssist-comms","Hi %s,"),comms_source:getCallSign())
				if docked_with ~= nil then
					msg = string.format(_("shipAssist-comms","%s\nDocked with %s"),msg,docked_with:getCallSign())
				else
					if string.find("Dock",comms_target:getOrder()) then
						local transport_target = comms_target:getOrderTarget()
						if transport_target ~= nil and transport_target:isValid() then
							msg = string.format(_("shipAssist-comms","%s\nHeading for %s"),msg,transport_target:getCallSign())
						end
					end
				end
				setCommsMessage(msg)
				addCommsReply(_("Back"), commsShip)
			end)
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
			if comms_source.cargo > 0 then
				if comms_data.friendlyness > 66 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(goodData.cost)), function()
									if comms_source:takeReputationPoints(goodData.cost) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end
				elseif comms_data.friendlyness > 33 then
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*2)), function()
									if comms_source:takeReputationPoints(goodData.cost*2) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					else
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end
				else	--least friendly
					if shipType:find("Goods") ~= nil or shipType:find("Equipment") ~= nil then
						for good, goodData in pairs(comms_data.goods) do
							if goodData.quantity > 0 then
								addCommsReply(string.format(_("trade-comms","Buy one %s for %i reputation"),good,math.floor(goodData.cost*3)), function()
									if comms_source:takeReputationPoints(goodData.cost*3) then
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
									addCommsReply(_("Back"), commsShip)
								end)
							end
						end	--freighter goods loop
					end
				end	--end friendly branches
			end	--player has room for cargo
		end	--close enough to sell
	else	--not a freighter
		if comms_data.friendlyness > 50 then
			setCommsMessage(_("ship-comms", "Sorry, we have no time to chat with you.\nWe are on an important mission."));
		else
			setCommsMessage(_("ship-comms", "We have nothing for you.\nGood day."));
		end
	end	--end non-freighter communications else branch
	return true
end	--end neutral communications function
function commsServiceJonque()
	if comms_target.comms_data == nil then
		comms_target.comms_data = {friendlyness = random(0.0, 100.0)}
	end
	comms_data = comms_target.comms_data
	if comms_source:isFriendly(comms_target) then
		return friendlyServiceJonqueComms(comms_data)
	end
	if comms_source:isEnemy(comms_target) and comms_target:isFriendOrFoeIdentifiedBy(comms_source) then
		return enemyComms(comms_data)
	end
	return neutralServiceJonqueComms(comms_data)
end
function friendlyServiceJonqueComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("ship-comms","What do you want?"))
	else
		setCommsMessage(_("ship-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("ship-comms","Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("ship-comms","No waypoints set. Please set a waypoint first."))
		else
			setCommsMessage(_("ship-comms","Which waypoint should we defend?"))
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("ship-comms","Defend WP %i"),n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("ship-comms","We are heading to assist at WP %i."),n))
					addCommsReply(_("Back"), commsServiceJonque)
				end)
			end
		end
		addCommsReply("Back", commsServiceJonque)
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("ship-comms","Assist me"), function()
			setCommsMessage(_("ship-comms","Heading toward you to assist."))
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsServiceJonque)
		end)
	end
	addCommsReply(_("ship-comms","Report status"), function()
		msg = _("ship-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("ship-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("ship-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("ship-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("ship-comms","Shield ") .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		setCommsMessage(msg);
			addCommsReply(_("Back"), commsServiceJonque)
	end)
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			if comms_target:getTypeName() ~= "Defense platform" then
				addCommsReply(string.format(_("ship-comms","Dock at %s"),obj:getCallSign()), function()
					setCommsMessage(string.format(_("ship-comms","Docking at %s."),obj:getCallSign()))
					comms_target:orderDock(obj)
					addCommsReply(_("Back"), commsServiceJonque)
				end)
			end
		end
	end
	if distance(comms_source,comms_target) < 5000 then
		commonServiceOptions()
	end
end
function neutralServiceJonqueComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("ship-comms","What do you want?"))
	else
		setCommsMessage(_("ship-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("ship-comms","How are you doing?"), function()
		msg = _("ship-comms","Hull: ") .. math.floor(comms_target:getHull() / comms_target:getHullMax() * 100) .. "%\n"
		local shields = comms_target:getShieldCount()
		if shields == 1 then
			msg = msg .. _("ship-comms","Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
		elseif shields == 2 then
			msg = msg .. _("ship-comms","Front Shield: ") .. math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100) .. "%\n"
			msg = msg .. _("ship-comms","Rear Shield: ") .. math.floor(comms_target:getShieldLevel(1) / comms_target:getShieldMax(1) * 100) .. "%\n"
		else
			for n=0,shields-1 do
				msg = msg .. _("ship-comms","Shield ") .. n .. ": " .. math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100) .. "%\n"
			end
		end
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsServiceJonque)
	end)
	commonServiceOptions()
end
function commonServiceOptions()
	addCommsReply(_("ship-comms","Service options"),function()
		local offer_repair = false
		if not comms_source:getCanLaunchProbe() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanHack() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanScan() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanCombatManeuver() then
			offer_repair = true
		end
		if not offer_repair and not comms_source:getCanSelfDestruct() then
			offer_repair = true
		end
		if offer_repair then
			addCommsReply(_("ship-comms","Repair ship system"),function()
				setCommsMessage(_("ship-comms","What system would you like repaired?"))
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(_("ship-comms","Repair probe launch system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage(_("ship-comms","Your probe launch system has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanHack() then
					addCommsReply(_("ship-comms","Repair hacking system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanHack(true)
							setCommsMessage(_("ship-comms","Your hack system has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanScan() then
					addCommsReply(_("ship-comms","Repair scanning system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanScan(true)
							setCommsMessage(_("ship-comms","Your scanners have been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(_("ship-comms","Repair combat maneuver"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage(_("ship-comms","Your combat maneuver has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(_("ship-comms","Repair self destruct system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage(_("ship-comms","Your self destruct system has been repaired"))
						else
							setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_hull_repair = false
		if comms_source:getHull() < comms_source:getHullMax() then
			offer_hull_repair = true
		end
		if offer_hull_repair then
			local full_repair = comms_source:getHullMax() - comms_source:getHull()
			local premium = 30
			if full_repair > 100 then
				premium = 100
			elseif full_repair > 50 then
				premium = 60
			end
			addCommsReply(string.format(_("ship-comms","Full hull repair (%i reputation)"),math.floor(full_repair + premium)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair + premium)) then
						comms_source:setHull(comms_source:getHullMax())
						setCommsMessage(_("ship-comms","All fixed up and ready to go"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("ship-comms","Add %i%% to hull (%i reputation)"),math.floor(full_repair/2/comms_source:getHullMax()*100),math.floor(full_repair/2 + premium/2)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/2 + premium/2)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/2))
						setCommsMessage(_("ship-comms","Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("ship-comms","Add %i%% to hull (%i reputation)"),math.floor(full_repair/3/comms_source:getHullMax()*100),math.floor(full_repair/3)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/3)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/3))
						setCommsMessage(_("ship-comms","Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_ordnance = false
		local ordnance_inventory = 0
		for ordnance_type, count in pairs(comms_target.comms_data.weapon_inventory) do
			ordnance_inventory = ordnance_inventory + count
		end
		local player_missile_types = {
			["Homing"] = {shoots = false, max = 0, current = 0, need=0},
			["Nuke"] = {shoots = false, max = 0, current = 0, need=0},
			["Mine"] = {shoots = false, max = 0, current = 0, need=0},
			["EMP"] = {shoots = false, max = 0, current = 0, need=0},
			["HVLI"] = {shoots = false, max = 0, current = 0, need=0},
		}
		if ordnance_inventory > 0 then
			for missile_type, ord in pairs(player_missile_types) do
				ord.max = comms_source:getWeaponStorageMax(missile_type)
				if ord.max ~= nil and ord.max > 0 then
					ord.shoots = true
					ord.current = comms_source:getWeaponStorage(missile_type)
					if ord.current < ord.max then
						ord.need = ord.max - ord.current
						if comms_target.comms_data.weapon_inventory[missile_type] > 0 then
							offer_ordnance = true
						end
					end
				end
			end
		end
		if offer_ordnance then
			addCommsReply(_("ship-comms","Restock ordnance"),function()
				for missile_type, ord in pairs(player_missile_types) do
					if ord.current < ord.max and comms_target.comms_data.weapon_inventory[missile_type] > 0 then
						comms_data = comms_target.comms_data
						setCommsMessage(_("ship-comms","What kind of ordnance?"))
						addCommsReply(string.format(_("ship-comms","%s (%i reputation each)"),missile_type,getWeaponCost(missile_type)),function()
							if distance(comms_source,comms_target) < 5000 then
								if comms_target.comms_data.weapon_inventory[missile_type] >= ord.need then
									if comms_source:takeReputationPoints(getWeaponCost(missile_type)*ord.need) then
										comms_source:setWeaponStorage(missile_type,ord.max)
										comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - ord.need
										setCommsMessage(string.format(_("ship-comms","Restocked your %s type ordnance"),missile_type))
									else
										if comms_source:getReputationPoints() > getWeaponCost(missile_type) then
											setCommsMessage(string.format(_("needRep-comms","You don't have enough reputation to fully replenish your %s type ordnance. You need %i and you only have %i. How would you like to proceed?"),missile_type,getWeaponCost(missile_type)*ord.need,math.floor(comms_source:getReputationPoints())))
											addCommsReply(string.format(_("ship-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
												if distance(comms_source,comms_target) < 5000 then
													if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
														comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
														comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
														setCommsMessage(string.format("One %s provided",missile_type))
													else
														setCommsMessage(_("needRep-comms","Insufficient reputation"))
													end
												else
													setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
												end
												addCommsReply(_("Back"), commsServiceJonque)
											end)
											if comms_source:getReputationPoints() > getWeaponCost(missile_type)*2 then
												local max_afford = 0
												local missile_count = 0
												repeat
													max_afford = max_afford + getWeaponCost(missile_type)
													missile_count = missile_count + 1
												until(max_afford + getWeaponCost(missile_type) > comms_source:getReputationPoints())
												addCommsReply(string.format(_("ship-comms","Get %i (%i reputation)"),missile_count,max_afford),function()
													if distance(comms_source,comms_target) < 5000 then
														if comms_source:takeReputationPoints(getWeaponCost(missile_type)*missile_count) then
															comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + missile_count)
															comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - missile_count
															setCommsMessage(string.format(_("ship-comms","%i %ss provided"),missile_count,missile_type))
														else
															setCommsMessage(_("needRep-comms","Insufficient reputation"))
														end
													else
														setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
													end
													addCommsReply(_("Back"), commsServiceJonque)
												end)
											end
										else
											setCommsMessage(_("needRep-comms","Insufficient reputation"))
										end
									end
								else
									setCommsMessage(string.format(_("ship-comms","I don't have enough %s type ordnance to fully restock you. How would you like to proceed?"),missile_type))
									addCommsReply(_("ship-comms","We'll take all you've got"),function()
										if comms_source:takeReputationPoints(getWeaponCost(missile_type)*comms_target.comms_data.weapon_inventory[missile_type]) then
											comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + comms_target.comms_data.weapon_inventory[missile_type])
											if comms_target.comms_data.weapon_inventory[missile_type] > 1 then
												setCommsMessage(string.format(_("ship-comms","%i %ss provided"),missile_count,missile_type))
											else
												setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
											end
											comms_target.comms_data.weapon_inventory[missile_type] = 0
										else
											setCommsMessage(string.format(_("needRep-comms","You don't have enough reputation to get all of our %s type ordnance. You need %i and you only have %i. How would you like to proceed?"),missile_type,getWeaponCost(missile_type)*comms_target.comms_data.weapon_inventory[missile_type],math.floor(comms_source:getReputationPoints())))
											addCommsReply(string.format(_("ship-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
												if distance(comms_source,comms_target) < 5000 then
													if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
														comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
														comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
														setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
													else
														setCommsMessage(_("needRep-comms","Insufficient reputation"))
													end
												else
													setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
												end
												addCommsReply(_("Back"), commsServiceJonque)
											end)
											if comms_source:getReputationPoints() > getWeaponCost(missile_type)*2 then
												local max_afford = 0
												local missile_count = 0
												repeat
													max_afford = max_afford + getWeaponCost(missile_type)
													missile_count = missile_count + 1
												until(max_afford + getWeaponCost(missile_type) > comms_source:getReputationPoints())
												addCommsReply(string.format(_("ship-comms","Get %i (%i reputation)"),missile_count,max_afford),function()
													if distance(comms_source,comms_target) < 5000 then
														if comms_source:takeReputationPoints(getWeaponCost(missile_type)*missile_count) then
															comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + missile_count)
															comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] + missile_count
															setCommsMessage(string.format(_("ship-comms","%i %ss provided"),missile_count,missile_type))
														else
															setCommsMessage(_("needRep-comms","Insufficient reputation"))
														end
													else
														setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
													end
													addCommsReply(_("Back"), commsServiceJonque)
												end)
											end
										end
									end)
									addCommsReply(string.format(_("ship-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
										if distance(comms_source,comms_target) < 5000 then
											if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
												comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
												comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
												setCommsMessage(string.format(_("ship-comms","One %s provided"),missile_type))
											else
												setCommsMessage(_("needRep-comms","Insufficient reputation"))
											end
										else
											setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
										end
										addCommsReply(_("Back"), commsServiceJonque)
									end)
								end
							else
								setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your ordnance"))
							end
							addCommsReply(_("Back"), commsServiceJonque)
						end)
					end
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_probes = false
		if comms_source:getScanProbeCount() < comms_source:getMaxScanProbeCount() then
			offer_probes = true
		end
		if offer_probes then
			addCommsReply(_("ship-comms","Restock scan probes (5 reputation)"),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(5) then
						comms_source:setScanProbeCount(comms_source:getMaxScanProbeCount())
						setCommsMessage(_("ship-comms","I replenished your probes for you."))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want me to restock your probes"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		local offer_power = false
		if comms_source:getEnergyLevel() < comms_source:getEnergyLevelMax()/2 then
			offer_power = true
		end
		if offer_power then
			local power_charge = math.floor((comms_source:getEnergyLevelMax() - comms_source:getEnergyLevel())/3)
			addCommsReply(string.format(_("ship-comms","Quick charge the main batteries (%i reputation)"),power_charge),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(power_charge) then
						comms_source:setEnergyLevel(comms_source:getEnergyLevelMax())
						comms_source:commandSetSystemPowerRequest("reactor",1)
						comms_source:setSystemPower("reactor",1)
						comms_source:setSystemHeat("reactor",2)
						setCommsMessage(_("ship-comms","Your batteries have been charged"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("ship-comms","You need to stay close if you want your batteries charged quickly"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		if offer_hull_repair or offer_repair or offer_ordnance or offer_probes or offer_power then
			setCommsMessage(_("ship-comms","How can I help you get your ship in good running order?"))
		else
			setCommsMessage(_("ship-comms","There's nothing on your ship that I can help you fix. Sorry."))
		end
	end)
end
-----------------------
-- Utility functions --
-----------------------
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
function placeRandomAsteroidsAroundPoint(amount, dist_min, dist_max, x0, y0)
-- create amount of asteroid, at a distance between dist_min and dist_max around the point (x0, y0)
    for n=1,amount do
        local r = random(0, 360)
        local distance = random(dist_min, dist_max)
        local x = x0 + math.cos(r / 180 * math.pi) * distance
        local y = y0 + math.sin(r / 180 * math.pi) * distance
        local asteroid_size = 0
        for s=1,4 do
        	asteroid_size = asteroid_size + random(2,200)
        end
        if farEnough(x, y, asteroid_size) then
	        local ta = Asteroid():setPosition(x, y):setSize(asteroid_size)
	        table.insert(place_space,{obj=ta,dist=asteroid_size,shape="circle"})
	    end
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
	startArc = (startArc + 270) % 360
	endArcClockwise = (endArcClockwise + 270) % 360
	local object_list = {}
	local arcLen = endArcClockwise - startArc
	if startArc > endArcClockwise then
		endArcClockwise = endArcClockwise + 360
		arcLen = arcLen + 360
	end
	if amount > arcLen then
		for ndex=1,arcLen do
			local radialPoint = startArc+ndex
			local pointDist = distance + random(-randomize,randomize)
			table.insert(object_list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			table.insert(object_list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
			table.insert(object_list,object_type():setPosition(x + math.cos(radialPoint / 180 * math.pi) * pointDist, y + math.sin(radialPoint / 180 * math.pi) * pointDist))
		end
	end
	return object_list
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
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
			end
		end
		for ndex=1,amount-arcLen do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
			end
		end
	else
		for ndex=1,amount do
			radialPoint = random(startArc,endArcClockwise)
			pointDist = distance + random(-randomize,randomize)
		    asteroid_size = random(1,100) + random(1,75) + random(1,75) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20) + random(1,20)
			local ax = x + math.cos(radialPoint / 180 * math.pi) * pointDist
			local ay = y + math.sin(radialPoint / 180 * math.pi) * pointDist
			if farEnough(ax, ay, asteroid_size) then
				local ta = Asteroid():setPosition(ax, ay):setSize(asteroid_size)
		        table.insert(place_space,{obj=ta,dist=asteroid_size})
			end
		end
	end
end
function spawnSingleEnemy(xOrigin, yOrigin, danger, enemyFaction, enemyStrength, template_pool)
	if enemyFaction == nil then
		enemyFaction = "Kraylor"
	end
	if danger == nil then 
		danger = 1
	end
	if enemyStrength == nil then
		enemyStrength = math.max(danger * enemy_power * playerPower(),5)
	end
	if template_pool == nil then
		template_pool_size = 15
		pool_selectivity = "less/heavy"
		template_pool = getTemplatePool(enemyStrength)
		pool_selectivity = "full"
	end
	if #template_pool < 1 then
		print("Empty Template pool: fix excludes or other criteria")
		return
	end
	local selected_template = template_pool[math.random(1,#template_pool)]
	local ship = ship_template[selected_template].create(enemyFaction,selected_template)
	ship:setCallSign(generateCallSign(nil,enemyFaction)):orderRoaming()
	ship:setPosition(xOrigin,yOrigin)
	ship:setCommsScript(""):setCommsFunction(commsShip)
	return ship
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
	local original_enemy_strength = enemyStrength
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
		template_pool_size = 15
		template_pool = getTemplatePool(enemyStrength)
	end
	if #template_pool < 1 then
		addGMMessage("Empty Template pool: fix excludes or other criteria")
		return enemyList, original_enemy_strength
	end
	while enemyStrength > 0 do
		local selected_template = template_pool[math.random(1,#template_pool)]
		if spawn_enemy_diagnostic then print("Spawn Enemies selected template:",selected_template,"template pool:",template_pool,"ship template:",ship_template,"Enemy faction:",enemyFaction) end
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
	if shape == "pyramid" then
		if spawn_distance == nil then
			spawn_distance = 30
		end
		if spawn_angle == nil then
			spawn_angle = random(0,360)
		end
		if px == nil then
			px = 0
		end
		if py == nil then
			py = 0
		end
		local pyramid_tier = math.min(#enemyList,max_pyramid_tier)
		for index, ship in ipairs(enemyList) do
			if index <= max_pyramid_tier then
				local pyramid_angle = spawn_angle + formation_delta.pyramid[pyramid_tier][index].angle
				if pyramid_angle < 0 then 
					pyramid_angle = pyramid_angle + 360
				end
				pyramid_angle = pyramid_angle % 360
				rx, ry = vectorFromAngle(pyramid_angle,spawn_distance*1000 + formation_delta.pyramid[pyramid_tier][index].distance * 800)
				ship:setPosition(px+rx,py+ry)
			else
				ship:setPosition(px+vx,py+vy)
			end
			ship:setHeading((spawn_angle + 270) % 360)
			ship:orderFlyTowards(px,py)
		end
	end
	if shape == "ambush" then
		if spawn_distance == nil then
			spawn_distance = 5
		end
		if spawn_angle == nil then
			spawn_angle = random(0,360)
		end
		local circle_increment = 360/#enemyList
		for _, enemy in ipairs(enemyList) do
			local dex, dey = vectorFromAngle(spawn_angle,spawn_distance*1000)
			enemy:setPosition(xOrigin+dex,yOrigin+dey):setRotation(spawn_angle+180)
			spawn_angle = spawn_angle + circle_increment
		end
	end
	return enemyList, original_enemy_strength
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
	else	--full
		for current_ship_template, details in pairs(ship_template) do
--			print("current ship template",current_ship_template,"details",details,"max strength:",max_strength)
			if details.strength <= max_strength then
				table.insert(template_pool,current_ship_template)
			end
		end
	end
	return template_pool
end
function playerPower()
--evaluate the players for enemy strength and size spawning purposes
	local playerShipScore = 0
	for p5idx=1,32 do
		local p5obj = getPlayerShip(p5idx)
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
function friendlyVesselDestroyed(self, instigator)
	string.format("")
	--[[
	tempShipType = self:getTypeName()
	table.insert(friendlyVesselDestroyedNameList,self:getCallSign())
	table.insert(friendlyVesselDestroyedType,tempShipType)
	table.insert(friendlyVesselDestroyedValue,ship_template[tempShipType].strength)
	--]]
end

------------------------
--	Update functions  --
------------------------
--	Update loop related functions
function continuousSpawn(delta)
	if #spawn_source_pool < 1 then
		for _,station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				if player_ship ~= nil and player_ship:isEnemy(station) then
					table.insert(spawn_source_pool,station)
				end
			end
		end
		spawn_interval_index = spawn_interval_index + 1
		if spawn_interval_index > #spawn_intervals then
			spawn_interval_index = 1
		end
		spawn_interval = spawn_intervals[spawn_interval_index].pace
		spawn_respite_interval = spawn_intervals[spawn_interval_index].respite
		spawn_timer = spawn_interval + random(1,spawn_variance)
		if continuous_spawn_diagnostic then print("spawn timer:",spawn_timer,"pace:",spawn_interval,"respite:",spawn_respite_interval) end
	end
	spawn_timer = spawn_timer - delta
	if spawn_timer < 0 then
		local origin_station = tableRemoveRandom(spawn_source_pool)
		if origin_station ~= nil and origin_station:isValid() then
--			if #target_station_pool < 1 then
--				for _,station in ipairs(inner_circle) do
--					if station ~= nil and station:isValid() then
--						table.insert(target_station_pool,station)
--					end
--				end
--				if continuous_spawn_diagnostic then print("Inner circle target station pool rebuilt. Size:",#target_station_pool) end
--			end
--			local spawn_target = tableRemoveRandom(target_station_pool)
			spawn_target = station_regional_hq
			if spawn_target == nil or not spawn_target:isValid() then
				local player_pool = getActivePlayerShips()
				spawn_target = tableRemoveRandom(player_pool)
			end
			if spawn_target ~= nil and spawn_target:isValid() then
				local ox, oy = origin_station:getPosition()
				local fleet = {}
				local fleet_strength = 0
				local ship_removed = false
				repeat
					ship_removed = false
					for i,ship in ipairs(cpu_ships) do
						if ship == nil then
							cpu_ships[i] = cpu_ships[#cpu_ships]
							cpu_ships[#cpu_ships] = nil
							ship_removed = true
							break
						else
							if not ship:isValid() then
								cpu_ships[i] = cpu_ships[#cpu_ships]
								cpu_ships[#cpu_ships] = nil
								ship_removed = true
								break
							end
						end
					end
				until(not ship_removed)
				local active_enemy_strength = 0
				local active_friendly_strength = 0
				local active_neutral_strength = 0
				for i,ship in ipairs(cpu_ships) do
					local p = getPlayerShip(-1)
					if p~= nil then
						local current_ship_template = ship:getTypeName()
						if ship:isEnemy(p) then
							if ship_template[current_ship_template] == nil then
								print("Missing enemy ship from strength evaluation. Ship template list does not contain:",current_ship_template)
							else
								active_enemy_strength = active_enemy_strength + ship_template[current_ship_template].strength
							end
						elseif ship:isFriendly(p) then
							if ship_template[current_ship_template] == nil then
								print("Missing friendly ship from strength evaluation. Ship template list does not contain:",current_ship_template)
							else
								active_friendly_strength = active_friendly_strength + ship_template[current_ship_template].strength
							end
						else
							if ship_template[current_ship_template] == nil then
								print("Missing neutral ship from strength evaluation. Ship template list does not contain:",current_ship_template)
							else
								active_neutral_strength = active_neutral_strength + ship_template[current_ship_template].strength
							end
						end
					else
						print("no player ship")
					end
				end
				local balance_factor = 0
				if (active_friendly_strength + active_neutral_strength) >= active_enemy_strength then
					if (active_friendly_strength + active_neutral_strength) > 0 then
						balance_factor = 1 - (active_enemy_strength/(active_friendly_strength + active_neutral_strength))
					end
				else
					if active_enemy_strength > 0 then
						balance_factor = (active_friendly_strength + active_neutral_strength)/active_enemy_strength
					end
				end
				local pace_factor = getScenarioTime()/danger_pace
				local danger_value = 1 + (pace_factor*balance_factor)
				if continuous_spawn_diagnostic then print("pace factor:",pace_factor,"balance factor:",balance_factor,"Ene:",active_enemy_strength,"Frn:",active_friendly_strength,"Neu:",active_neutral_strength) end
				if origin_station:isEnemy(spawn_target) then
					fleet, fleet_strength = spawnEnemies(ox, oy,danger_value,origin_station:getFaction())
					for _, ship in ipairs(fleet) do
						table.insert(cpu_ships,ship)
					end
					if random(1,100) < 30 then
						for _,ship in ipairs(fleet) do
							ship:orderAttack(spawn_target)
						end
						if continuous_spawn_diagnostic then print("Enemy fleet from:",origin_station:getCallSign(),"attacking:",spawn_target:getCallSign(),"danger:",danger_value,"strength:",fleet_strength) end
					else
						for _,ship in ipairs(fleet) do
							local tx, ty = spawn_target:getPosition()
							ship:orderFlyTowards(tx, ty)
						end
						if continuous_spawn_diagnostic then print("Enemy fleet from:",origin_station:getCallSign(),"flying to:",spawn_target:getCallSign(),"danger:",danger_value,"strength:",fleet_strength) end
					end
				else
					if origin_station.help_requested then
						fleet, fleet_strength = spawnEnemies(ox, oy,danger_value,origin_station:getFaction())
						for _,ship in ipairs(fleet) do
							ship:orderDefendTarget(spawn_target)
						end
						if origin_station:isFriendly(spawn_target) then
							if continuous_spawn_diagnostic then print("Friendly fleet from:",origin_station:getCallSign(),"defending:",spawn_target:getCallSign(),"danger:",danger_value,"strength:",fleet_strength) end
						else
							if continuous_spawn_diagnostic then print("Neutral fleet from:",origin_station:getCallSign(),"defending:",spawn_target:getCallSign(),"danger:",danger_value,"strength:",fleet_strength) end
						end
					else
						if continuous_spawn_diagnostic then print("No neutral/friendly fleet spawned from:",origin_station:getCallSign(),"(not requested)") end
					end
				end
			end
		end
--		if #spawn_source_pool > 0 then
--			spawn_timer = spawn_interval + random(1,spawn_variance)
--		else
			spawn_timer = spawn_respite_interval + random(1,spawn_variance)
--		end
		if continuous_spawn_diagnostic then print("spawn timer:",spawn_timer) end
	end
end
function moonCollisionCheck()
	if moon_barrier == nil then
		return
	end
	local moon_x, moon_y = moon_barrier:getPosition()
	collision_list = moon_barrier:getObjectsInRange(moon_barrier.moon_radius + 600)
	local obj_dist = 0
	local ship_distance = 0
	local obj_type_name = ""
	for _, obj in ipairs(collision_list) do
		if obj:isValid() then
			obj_dist = distance(obj,moon_barrier)
			if obj.typeName == "CpuShip" then
				obj_type_name = obj:getTypeName()
				if obj_type_name ~= nil then
					ship_distance = shipTemplateDistance[obj:getTypeName()]
					if ship_distance == nil then
						ship_distance = 400
						print("Table ship template distance did not have an entry for",obj:getTypeName())
					end
				else
					ship_distance = 400
				end
--				print("CPU ship object distance:",obj_dist,"ship distance:",ship_distance,"moon radius:",moon_barrier.moon_radius)
				if obj_dist <= moon_barrier.moon_radius + ship_distance + 200 then
					obj:takeDamage(100,"kinetic",moon_x,moon_y)
				end
			elseif obj.typeName == "PlayerSpaceship" then
				obj_type_name = obj:getTypeName()
				if obj_type_name ~= nil then
					ship_distance = playerShipStats[obj:getTypeName()].distance
					if ship_distance == nil then
						ship_distance = 400
						print("Player ship stats did not have a distance entry for",obj:getTypeName())
					end
				else
					ship_distance = 400
				end
--				print("Player ship object distance:",obj_dist,"ship distance:",ship_distance,"moon radius:",moon_barrier.moon_radius)
				if obj_dist <= moon_barrier.moon_radius + ship_distance + 200 then
					obj:takeDamage(100,"kinetic",moon_x,moon_y)
				end
			end
		end
	end
end
function updatePlayerTubeSizeBanner(p)
	if p.tube_size ~= nil then
		local tube_size_banner = string.format(_("tabWeapons","%s tubes: %s"),p:getCallSign(),p.tube_size)
		if #p.tube_size == 1 then
			tube_size_banner = string.format(_("tabWeapons","%s tube: %s"),p:getCallSign(),p.tube_size)
		end
		p.tube_sizes_wea = "tube_sizes_wea"
		p:addCustomInfo("Weapons",p.tube_sizes_wea,tube_size_banner,5)
		p.tube_sizes_tac = "tube_sizes_tac"
		p:addCustomInfo("Tactical",p.tube_sizes_tac,tube_size_banner,5)
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
function automatedCheckList(delta)
	local list_complete = true
	local checklist_completed_count = 16
	if maneuver_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if maneuver_check == "started" then
			--current
			local current_angular_velocity = math.abs(player_ship:getAngularVelocity())
			local angular_velocity_message = string.format(_("tabHelm&Tactical","Angular Velocity: %.1f"),current_angular_velocity)
			player_ship.angular_velocity_hlm = "angular_velocity_hlm"
			player_ship:addCustomInfo("Helms",player_ship.angular_velocity_hlm,angular_velocity_message,50)
			player_ship.angular_velocity_tac = "angular_velocity_tac"
			player_ship:addCustomInfo("Tactical",player_ship.angular_velocity_tac,angular_velocity_message,50)
			--max
			if player_ship.angular_velocity_max < current_angular_velocity then
				player_ship.angular_velocity_max = current_angular_velocity
			end
			local angular_velocity_max_message = string.format(_("tabHelm&Tactical","AV Max: %.1f"),player_ship.angular_velocity_max)
			player_ship.angular_velocity_max_hlm = "angular_velocity_max_hlm"
			player_ship:addCustomInfo("Helms",player_ship.angular_velocity_max_hlm,angular_velocity_max_message,51)
			player_ship.angular_velocity_max_tac = "angular_velocity_max_tac"
			player_ship:addCustomInfo("Tactical",player_ship.angular_velocity_max_tac,angular_velocity_max_message,51)
			--lo target
			local angular_velocity_lo_target_msg = string.format(_("tabHelm&Tactical","AV Lo Target: %.1f"),player_ship.angular_velocity_lo)
			if player_ship.angular_velocity_max >= player_ship.angular_velocity_lo then
				angular_velocity_lo_target_msg = string.format(_("tabHelm&Tactical","%s Met"),angular_velocity_lo_target_msg)
			end
			player_ship.angular_velocity_lo_target_hlm = "angular_velocity_lo_target_hlm"
			player_ship:addCustomInfo("Helms",player_ship.angular_velocity_lo_target_hlm,angular_velocity_lo_target_msg,52)
			player_ship.angular_velocity_lo_target_tac = "angular_velocity_lo_target_tac"
			player_ship:addCustomInfo("Tactical",player_ship.angular_velocity_lo_target_tac,angular_velocity_lo_target_msg,52)
			--hi target
			local angular_velocity_hi_target_msg = string.format(_("tabHelm&Tactical","AV Hi Target: %.1f"),player_ship.angular_velocity_hi)
			if player_ship.angular_velocity_max >= player_ship.angular_velocity_hi then
				angular_velocity_hi_target_msg = string.format(_("tabHelm&Tactical","%s Met"),angular_velocity_hi_target_msg)
			end
			player_ship.angular_velocity_hi_target_hlm = "angular_velocity_hi_target_hlm"
			player_ship:addCustomInfo("Helms",player_ship.angular_velocity_hi_target_hlm,angular_velocity_hi_target_msg,53)
			player_ship.angular_velocity_hi_target_tac = "angular_velocity_hi_target_tac"
			player_ship:addCustomInfo("Tactical",player_ship.angular_velocity_hi_target_tac,angular_velocity_hi_target_msg,53)
			--check for test completion here
			if player_ship.angular_velocity_max >= player_ship.angular_velocity_hi then
				if player_ship.angular_velocity_delay == nil then
					player_ship.angular_velocity_delay = getScenarioTime() + 5
				end
				if getScenarioTime() > player_ship.angular_velocity_delay then
					player_ship:removeCustom(player_ship.angular_velocity_hi_target_tac)
					player_ship:removeCustom(player_ship.angular_velocity_hi_target_hlm)
					player_ship:removeCustom(player_ship.angular_velocity_lo_target_tac)
					player_ship:removeCustom(player_ship.angular_velocity_lo_target_hlm)
					player_ship:removeCustom(player_ship.angular_velocity_max_tac)
					player_ship:removeCustom(player_ship.angular_velocity_max_hlm)
					player_ship:removeCustom(player_ship.angular_velocity_tac)
					player_ship:removeCustom(player_ship.angular_velocity_hlm)
					player_ship.maneuver_check_complete_msg_hlm = "maneuver_check_complete_msg_hlm"
					player_ship:addCustomMessage("Helms",player_ship.maneuver_check_complete_msg_hlm,_("msgHelms","Maneuver check has been completed.\nStatus: passed"))
					player_ship.maneuver_check_complete_msg_tac = "maneuver_check_complete_msg_tac"
					player_ship:addCustomMessage("Tactical",player_ship.maneuver_check_complete_msg_tac,_("msgTactical","Maneuver check has been completed.\nStatus: passed"))
					maneuver_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_maneuver_button_hlm == nil then
				player_ship.check_maneuver_button_hlm = "check_maneuver_button_hlm"
				player_ship.check_maneuver_button_tac = "check_maneuver_button_tac"
				player_ship:addCustomButton("Helms",player_ship.check_maneuver_button_hlm,_("buttonHelm","Check Maneuver"),function()
					player_ship:removeCustom(player_ship.check_maneuver_button_hlm)
					player_ship:removeCustom(player_ship.check_maneuver_button_tac)
					maneuver_check = "started"
				end,40)
				player_ship:addCustomButton("Tactical",player_ship.check_maneuver_button_tac,_("buttonTactical","Check Maneuver"),function()
					player_ship:removeCustom(player_ship.check_maneuver_button_hlm)
					player_ship:removeCustom(player_ship.check_maneuver_button_tac)				
					maneuver_check = "started"
				end,40)
			end
		end
	end
	if impulse_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if impulse_check == "started" then
			local vx, vy = player_ship:getVelocity()
			local player_velocity = math.sqrt((math.abs(vx)*math.abs(vx))+(math.abs(vy)*math.abs(vy)))*60/1000
			--max
			if player_ship.velocity_max < player_velocity then
				player_ship.velocity_max = player_velocity
			end
			local velocity_max_message = string.format(_("tabHelm&Tactical","Velocity Max: %.1f"),player_ship.velocity_max)
			player_ship.velocity_max_hlm = "velocity_max_hlm"
			player_ship:addCustomInfo("Helms",player_ship.velocity_max_hlm,velocity_max_message,54)
			player_ship.velocity_max_tac = "velocity_max_tac"
			player_ship:addCustomInfo("Tactical",player_ship.velocity_max_tac,velocity_max_message,54)
			--lo target
			local velocity_lo_target_msg = string.format(_("tabHelm&Tactical","Velocity Lo Target: %.1f"),player_ship.velocity_lo)
			if player_ship.velocity_max >= player_ship.velocity_lo then
				velocity_lo_target_msg = string.format(_("tabHelm&Tactical","%s Met"),velocity_lo_target_msg)
			end
			player_ship.velocity_lo_target_hlm = "velocity_lo_target_hlm"
			player_ship:addCustomInfo("Helms",player_ship.velocity_lo_target_hlm,velocity_lo_target_msg,55)
			player_ship.velocity_lo_target_tac = "velocity_lo_target_tac"
			player_ship:addCustomInfo("Tactical",player_ship.velocity_lo_target_tac,velocity_lo_target_msg,55)
			--hi target
			local velocity_hi_target_msg = string.format(_("tabHelm&Tactical","Velocity Hi Target: %.1f"),player_ship.velocity_hi)
			if player_ship.velocity_max >= player_ship.velocity_hi then
				velocity_hi_target_msg = string.format(_("tabHelm&Tactical","%s Met"),velocity_hi_target_msg)
			end
			player_ship.velocity_hi_target_hlm = "velocity_hi_target_hlm"
			player_ship:addCustomInfo("Helms",player_ship.velocity_hi_target_hlm,velocity_hi_target_msg,56)
			player_ship.velocity_hi_target_tac = "velocity_hi_target_tac"
			player_ship:addCustomInfo("Tactical",player_ship.velocity_hi_target_tac,velocity_hi_target_msg,56)
			--check for test completion here
			if player_ship.velocity_max >= player_ship.velocity_hi then
				if player_ship.velocity_delay == nil then
					player_ship.velocity_delay = getScenarioTime() + 5
				end
				if getScenarioTime() > player_ship.velocity_delay then
					player_ship:removeCustom(player_ship.velocity_hi_target_tac)
					player_ship:removeCustom(player_ship.velocity_hi_target_hlm)
					player_ship:removeCustom(player_ship.velocity_lo_target_tac)
					player_ship:removeCustom(player_ship.velocity_lo_target_hlm)
					player_ship:removeCustom(player_ship.velocity_max_tac)
					player_ship:removeCustom(player_ship.velocity_max_hlm)
					player_ship.impulse_check_complete_msg_hlm = "impulse_check_complete_msg_hlm"
					player_ship:addCustomMessage("Helms",player_ship.impulse_check_complete_msg_hlm,_("msgHelms","Impulse check has been completed.\nStatus: passed"))
					player_ship.impulse_check_complete_msg_tac = "impulse_check_complete_msg_tac"
					player_ship:addCustomMessage("Tactical",player_ship.impulse_check_complete_msg_tac,_("msgTactical","Impulse check has been completed.\nStatus: passed"))
					impulse_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_impulse_button_hlm == nil then
				player_ship.check_impulse_button_hlm = "check_impulse_button_hlm"
				player_ship.check_impulse_button_tac = "check_impulse_button_tac"
				player_ship:addCustomButton("Helms",player_ship.check_impulse_button_hlm,_("buttonHelm","Check Impulse"),function()
					player_ship:removeCustom(player_ship.check_impulse_button_hlm)
					player_ship:removeCustom(player_ship.check_impulse_button_tac)
					impulse_check = "started"
				end,41)
				player_ship:addCustomButton("Tactical",player_ship.check_impulse_button_tac,_("buttonTactical","Check Impulse"),function()
					player_ship:removeCustom(player_ship.check_impulse_button_hlm)
					player_ship:removeCustom(player_ship.check_impulse_button_tac)
					impulse_check = "started"
				end,41)
			end
		end
	end
	if jump_drive_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if jump_drive_check == "started" then
			--current
			prev_jump_charge = jump_charge
			jump_charge = player_ship:getJumpDriveCharge()
			local jump_charge_message = string.format(_("tabHelm&Tactical","Jump Charge: %.1fK"),jump_charge/1000)
			player_ship.jump_charge_hlm = "jump_charge_hlm"
			player_ship:addCustomInfo("Helms",player_ship.jump_charge_hlm,jump_charge_message,57)
			player_ship.jump_charge_tac = "jump_charge_tac"
			player_ship:addCustomInfo("Tactical",player_ship.jump_charge_tac,jump_charge_message,57)
			local charge_states = {
				["charged"] = _("tabHelm&Tactical","charged"),
				["undercharged"] = _("tabHelm&Tactical","under charged"),
				["overcharged"] = _("tabHelm&Tactical","overcharged")
			}
			local charge_state = "charged"
			if jump_charge > 50000 then
				charge_state = "overcharged"
			elseif jump_charge < 50000 then
				charge_state = "undercharged"
			end
			local jump_state_message = string.format(_("tabHelm&Tactical","Charge state: %s"),charge_states[charge_state])
			player_ship.charge_state_hlm = "charge_state_hlm"
			player_ship:addCustomInfo("Helms",player_ship.charge_state_hlm,jump_state_message,58)
			player_ship.charge_state_tac = "charge_state_tac"
			player_ship:addCustomInfo("Tactical",player_ship.charge_state_tac,jump_state_message,58)
			if not player_ship.long_jump_made then
				if jump_charge == 0 and prev_jump_charge == 50000 then
					player_ship.long_jump_made = true
				end
			end
			local jump_wait_message = nil
			if player_ship.long_jump_made then
				if charge_state == "undercharged" then
					jump_wait_message = _("tabHelm&Tactical","Waiting for recharge")
				else
					jump_wait_message = _("tabHelm&Tactical","Jump check complete")
					if player_ship.jump_delay == nil then
						player_ship.jump_delay = getScenarioTime() + 5
					end
				end
			else
				if charge_state == "charged" then
					jump_wait_message = _("tabHelm&Tactical","Waiting for jump")
				else 
					jump_wait_message = _("tabHelm&Tactical","Waiting for 50K charge")
				end
			end
			if jump_wait_message ~= nil then
				player_ship.jump_wait_hlm = "jump_wait_hlm"
				player_ship:addCustomInfo("Helms",player_ship.jump_wait_hlm,jump_wait_message,59)
				player_ship.jump_wait_tac = "jump_wait_tac"
				player_ship:addCustomInfo("Tactical",player_ship.jump_wait_tac,jump_wait_message,59)
			end
			if player_ship.jump_delay ~= nil then
				if getScenarioTime() > player_ship.jump_delay then
					player_ship:removeCustom(player_ship.jump_wait_tac)
					player_ship:removeCustom(player_ship.jump_wait_hlm)
					player_ship:removeCustom(player_ship.charge_state_tac)
					player_ship:removeCustom(player_ship.charge_state_hlm)
					player_ship:removeCustom(player_ship.jump_charge_tac)
					player_ship:removeCustom(player_ship.jump_charge_hlm)
					player_ship.jump_check_complete_msg_hlm = "jump_check_complete_msg_hlm"
					player_ship:addCustomMessage("Helms",player_ship.jump_check_complete_msg_hlm,_("msgHelms","Jump drive check has been completed.\nStatus: passed"))
					player_ship.jump_check_complete_msg_tac = "jump_check_complete_msg_tac"
					player_ship:addCustomMessage("Tactical",player_ship.jump_check_complete_msg_tac,_("msgTactical","Jump drive check has been completed.\nStatus: passed"))
					jump_drive_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_jump_button_hlm == nil then
				player_ship.check_jump_button_hlm = "check_jump_button_hlm"
				player_ship.check_jump_button_tac = "check_jump_button_tac"
				player_ship:addCustomButton("Helms",player_ship.check_jump_button_hlm,_("buttonHelm","Check Jump Drive"),function()
					player_ship:removeCustom(player_ship.check_jump_button_hlm)
					player_ship:removeCustom(player_ship.check_jump_button_tac)
					jump_drive_check = "started"
				end,42)
				player_ship:addCustomButton("Tactical",player_ship.check_jump_button_tac,_("buttonTactical","Check Jump Drive"),function()
					player_ship:removeCustom(player_ship.check_jump_button_hlm)
					player_ship:removeCustom(player_ship.check_jump_button_tac)
					jump_drive_check = "started"
				end,42)
			end
		end
	end
	if front_shield_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if front_shield_check == "started" then
			prev_front_charge = front_charge
			front_charge = player_ship:getShieldLevel(0)
			local shield_max = player_ship:getShieldMax(0)
			local charge_states = {
				["charged"] = _("tabWeapons&Tactical","charged"),
				["undercharged"] = _("tabWeapons&Tactical","under charged"),
				["overcharged"] = _("tabWeapons&Tactical","overcharged")
			}
			local charge_state = "charged"
			if front_charge > shield_max then
				charge_state = "overcharged"
			elseif front_charge < shield_max then
				charge_state = "undercharged"
			end
			local front_shield_state_message = string.format(_("tabWeapons&Tactical","Front shield: %s"),charge_states[charge_state])
			player_ship.front_shield_charge_state_wea = "front_shield_charge_state_wea"
			player_ship:addCustomInfo("Weapons",player_ship.front_shield_charge_state_wea,front_shield_state_message,60)
			player_ship.front_shield_charge_state_tac = "front_shield_charge_state_tac"
			player_ship:addCustomInfo("Tactical",player_ship.front_shield_charge_state_tac,front_shield_state_message,60)
			if not player_ship.front_shield_hit then
				if front_charge < shield_max and prev_front_charge == shield_max then
					player_ship.front_shield_hit = true
				end
			end
			local front_wait_message = nil
			if player_ship.front_shield_hit then
				if charge_state == "undercharged" then
					front_wait_message = _("tabWeapons&Tactical","Waiting for recharge")
				else
					front_wait_message = _("tabWeapons&Tactical","Front Shield Ck complete")
					if player_ship.front_shield_delay == nil then
						player_ship.front_shield_delay = getScenarioTime() + 5
					end
				end
			else
				if charge_state == "charged" then
					front_wait_message = _("tabWeapons&Tactical","Waiting for hit")
				else 
					front_wait_message = _("tabWeapons&Tactical","Waiting for 100% charge")
				end
			end
			if front_wait_message ~= nil then
				player_ship.front_wait_wea = "front_wait_wea"
				player_ship:addCustomInfo("Weapons",player_ship.front_wait_wea,front_wait_message,61)
				player_ship.front_wait_tac = "front_wait_tac"
				player_ship:addCustomInfo("Tactical",player_ship.front_wait_tac,front_wait_message,61)
			end
			if player_ship.front_shield_delay ~= nil then
				if getScenarioTime() > player_ship.front_shield_delay then
					player_ship:removeCustom(player_ship.front_wait_tac)
					player_ship:removeCustom(player_ship.front_wait_wea)
					player_ship:removeCustom(player_ship.front_shield_charge_state_tac)
					player_ship:removeCustom(player_ship.front_shield_charge_state_wea)
					player_ship.front_shield_check_complete_msg_wea = "front_shield_check_complete_msg_wea"
					player_ship:addCustomMessage("Weapons",player_ship.front_shield_check_complete_msg_wea,_("msgWeapons","Front shield check has been completed.\nStatus: passed"))
					player_ship.front_shield_check_complete_msg_tac = "front_shield_check_complete_msg_tac"
					player_ship:addCustomMessage("Tactical",player_ship.front_shield_check_complete_msg_tac,_("msgTactical","Front shield check has been completed.\nStatus: passed"))
					front_shield_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_front_shield_button_wea == nil then
				player_ship.check_front_shield_button_wea = "check_front_shield_button_wea"
				player_ship.check_front_shield_button_tac = "check_front_shield_button_tac"
				player_ship:addCustomButton("Weapons",player_ship.check_front_shield_button_wea,_("buttonWeapons","Check Front Shield"),function()
					player_ship:removeCustom(player_ship.check_front_shield_button_wea)
					player_ship:removeCustom(player_ship.check_front_shield_button_tac)
					front_shield_check = "started"
				end,43)
				player_ship:addCustomButton("Tactical",player_ship.check_front_shield_button_tac,_("buttonTactical","Check Front Shield"),function()
					player_ship:removeCustom(player_ship.check_front_shield_button_wea)
					player_ship:removeCustom(player_ship.check_front_shield_button_tac)
					front_shield_check = "started"
				end,43)
			end
		end
	end
	if rear_shield_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if rear_shield_check == "started" then
			prev_rear_charge = rear_charge
			rear_charge = player_ship:getShieldLevel(1)
			local shield_max = player_ship:getShieldMax(1)
			local charge_states = {
				["charged"] = _("tabWeapons&Tactical","charged"),
				["undercharged"] = _("tabWeapons&Tactical","under charged"),
				["overcharged"] = _("tabWeapons&Tactical","overcharged")
			}
			local charge_state = "charged"
			if rear_charge > shield_max then
				charge_state = "overcharged"
			elseif rear_charge < shield_max then
				charge_state = "undercharged"
			end
			local rear_shield_state_message = string.format(_("tabWeapons&Tactical","Rear shield: %s"),charge_states[charge_state])
			player_ship.rear_shield_charge_state_wea = "rear_shield_charge_state_wea"
			player_ship:addCustomInfo("Weapons",player_ship.rear_shield_charge_state_wea,rear_shield_state_message,62)
			player_ship.rear_shield_charge_state_tac = "rear_shield_charge_state_tac"
			player_ship:addCustomInfo("Tactical",player_ship.rear_shield_charge_state_tac,rear_shield_state_message,62)
			if not player_ship.rear_shield_hit then
				if rear_charge < shield_max and prev_rear_charge == shield_max then
					player_ship.rear_shield_hit = true
				end
			end
			local rear_wait_message = nil
			if player_ship.rear_shield_hit then
				if charge_state == "undercharged" then
					rear_wait_message = _("tabWeapons&Tactical","Waiting for recharge")
				else
					rear_wait_message = _("tabWeapons&Tactical","Rear Shield Ck complete")
					if player_ship.rear_shield_delay == nil then
						player_ship.rear_shield_delay = getScenarioTime() + 5
					end
				end
			else
				if charge_state == "charged" then
					rear_wait_message = _("tabWeapons&Tactical","Waiting for hit")
				else 
					rear_wait_message = _("tabWeapons&Tactical","Waiting for 100% charge")
				end
			end
			if rear_wait_message ~= nil then
				player_ship.rear_wait_wea = "rear_wait_wea"
				player_ship:addCustomInfo("Weapons",player_ship.rear_wait_wea,rear_wait_message,63)
				player_ship.rear_wait_tac = "rear_wait_tac"
				player_ship:addCustomInfo("Tactical",player_ship.rear_wait_tac,rear_wait_message,63)
			end
			if player_ship.rear_shield_delay ~= nil then
				if getScenarioTime() > player_ship.rear_shield_delay then
					player_ship:removeCustom(player_ship.rear_wait_tac)
					player_ship:removeCustom(player_ship.rear_wait_wea)
					player_ship:removeCustom(player_ship.rear_shield_charge_state_tac)
					player_ship:removeCustom(player_ship.rear_shield_charge_state_wea)
					player_ship.rear_shield_check_complete_msg_wea = "rear_shield_check_complete_msg_wea"
					player_ship:addCustomMessage("Weapons",player_ship.rear_shield_check_complete_msg_wea,_("msgWeapons","Rear shield check has been completed.\nStatus: passed"))
					player_ship.rear_shield_check_complete_msg_tac = "rear_shield_check_complete_msg_tac"
					player_ship:addCustomMessage("Tactical",player_ship.rear_shield_check_complete_msg_tac,_("msgTactical","Rear shield check has been completed.\nStatus: passed"))
					rear_shield_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_rear_shield_button_wea == nil then
				player_ship.check_rear_shield_button_wea = "check_rear_shield_button_wea"
				player_ship.check_rear_shield_button_tac = "check_rear_shield_button_tac"
				player_ship:addCustomButton("Weapons",player_ship.check_rear_shield_button_wea,_("buttonWeapons","Check Rear Shield"),function()
					player_ship:removeCustom(player_ship.check_rear_shield_button_wea)
					player_ship:removeCustom(player_ship.check_rear_shield_button_tac)
					rear_shield_check = "started"
				end,44)
				player_ship:addCustomButton("Tactical",player_ship.check_rear_shield_button_tac,_("buttonTactical","Check Rear Shield"),function()
					player_ship:removeCustom(player_ship.check_rear_shield_button_wea)
					player_ship:removeCustom(player_ship.check_rear_shield_button_tac)
					rear_shield_check = "started"
				end,44)
			end
		end
	end
	if beam_calibration_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if beam_calibration_check == "started" then
			beam_calibration = player_ship:getBeamFrequency()
			if not player_ship.beam_calibrated then
				if beam_calibration ~= prev_beam_calibration then
					player_ship.beam_calibrated = true
					if player_ship.beam_calibrate_delay == nil then
						player_ship.beam_calibrate_delay = getScenarioTime() + 5
					end
				end
			end
			local beam_wait_message = _("tabWeapons&Tactical","Waiting for beam calibration")
			if player_ship.beam_calibrated then
				beam_wait_message = _("tabWeapons&Tactical","Beam calibrate ck complete")
			end
			player_ship.beam_calibrate_wait_wea = "beam_calibrate_wait_wea"
			player_ship:addCustomInfo("Weapons",player_ship.beam_calibrate_wait_wea,beam_wait_message,64)
			player_ship.beam_calibrate_wait_tac = "beam_calibrate_wait_tac"
			player_ship:addCustomInfo("Tactical",player_ship.beam_calibrate_wait_tac,beam_wait_message,64)
			if player_ship.beam_calibrate_delay ~= nil then
				if getScenarioTime() > player_ship.beam_calibrate_delay then
					player_ship:removeCustom(player_ship.beam_calibrate_wait_tac)
					player_ship:removeCustom(player_ship.beam_calibrate_wait_wea)
					player_ship.beam_calibrate_complete_msg_wea = "beam_calibrate_complete_msg_wea"
					player_ship:addCustomMessage("Weapons",player_ship.beam_calibrate_complete_msg_wea,_("msgWeapons","beam weapon calibration check has been completed.\nStatus: passed"))
					player_ship.beam_calibrate_complete_msg_tac = "beam_calibrate_complete_msg_tac"
					player_ship:addCustomMessage("Tactical",player_ship.beam_calibrate_complete_msg_tac,_("msgTactical","beam weapon calibration check has been completed.\nStatus: passed"))
					beam_calibration_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_beam_calibration_button_wea == nil then
				player_ship.check_beam_calibration_button_wea = "check_beam_calibration_button_wea"
				player_ship.check_beam_calibration_button_tac = "check_beam_calibration_button_tac"
				player_ship:addCustomButton("Weapons",player_ship.check_beam_calibration_button_wea,_("buttonWeapons","Check Beam Calibration"),function()
					player_ship:removeCustom(player_ship.check_beam_calibration_button_wea)
					player_ship:removeCustom(player_ship.check_beam_calibration_button_tac)
					beam_calibration_check = "started"
				end,45)
				player_ship:addCustomButton("Tactical",player_ship.check_beam_calibration_button_tac,_("buttonTactical","Check Beam Calibration"),function()
					player_ship:removeCustom(player_ship.check_beam_calibration_button_wea)
					player_ship:removeCustom(player_ship.check_beam_calibration_button_tac)
					beam_calibration_check = "started"
				end,45)
			end
		end	
		prev_beam_calibration = player_ship:getBeamFrequency()
	end
	if shield_calibration_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if shield_calibration_check == "started" then
			shield_calibration = player_ship:getShieldsFrequency()
			if not player_ship.shield_calibrated then
				if shield_calibration ~= prev_shield_calibration then
					player_ship.shield_calibrated = true
				end
			end
			local shield_wait_message = _("tabWeapons&Engineering+","Waiting for shield calibration")
			if player_ship.shield_calibrated then
				if player_ship:getShieldsActive() then
					shield_wait_message = _("tabWeapons&Engineering+","Shield calibrate ck complete")
					if player_ship.shield_calibrate_delay == nil then
						player_ship.shield_calibrate_delay = getScenarioTime() + 5
					end
				else
					if player_ship.shield_calibrate_delay == nil then
						shield_wait_message = _("tabWeapons&Engineering+","Wating for shield activation")
					else
						shield_wait_message = _("tabWeapons&Engineering+","Shield calibrate ck complete")
					end
				end
			end
			player_ship.shield_calibrate_wait_wea = "shield_calibrate_wait_wea"
			player_ship:addCustomInfo("Weapons",player_ship.shield_calibrate_wait_wea,shield_wait_message,65)
			player_ship.shield_calibrate_wait_epl = "shield_calibrate_wait_epl"
			player_ship:addCustomInfo("Engineering+",player_ship.shield_calibrate_wait_epl,shield_wait_message,65)
			if player_ship.shield_calibrate_delay ~= nil then
				if getScenarioTime() > player_ship.shield_calibrate_delay then
					player_ship:removeCustom(player_ship.shield_calibrate_wait_epl)
					player_ship:removeCustom(player_ship.shield_calibrate_wait_wea)
					player_ship.shield_calibrate_complete_msg_wea = "shield_calibrate_complete_msg_wea"
					player_ship:addCustomMessage("Weapons",player_ship.shield_calibrate_complete_msg_wea,_("msgWeapons","shield calibration check has been completed.\nStatus: passed"))
					player_ship.shield_calibrate_complete_msg_epl = "shield_calibrate_complete_msg_epl"
					player_ship:addCustomMessage("Engineering+",player_ship.shield_calibrate_complete_msg_epl,_("msgEngineering+","shield calibration check has been completed.\nStatus: passed"))
					shield_calibration_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_shield_calibration_button_wea == nil then
				player_ship.check_shield_calibration_button_wea = "check_shield_calibration_button_wea"
				player_ship.check_shield_calibration_button_epl = "check_shield_calibration_button_epl"
				player_ship:addCustomButton("Weapons",player_ship.check_shield_calibration_button_wea,_("buttonWeapons","Check Shield Calibration"),function()
					player_ship:removeCustom(player_ship.check_shield_calibration_button_wea)
					player_ship:removeCustom(player_ship.check_shield_calibration_button_epl)
					shield_calibration_check = "started"
				end,46)
				player_ship:addCustomButton("Engineering+",player_ship.check_shield_calibration_button_epl,_("buttonEngineering+","Check Shield Calibration"),function()
					player_ship:removeCustom(player_ship.check_shield_calibration_button_wea)
					player_ship:removeCustom(player_ship.check_shield_calibration_button_epl)
					shield_calibration_check = "started"
				end,46)
			end
		end
		prev_shield_calibration = player_ship:getShieldsFrequency()
	end
	if waypoint_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if waypoint_check == "started" then
			waypoint_count = player_ship:getWaypointCount()
			if not player_ship.waypoint_set then
				if waypoint_count ~= prev_waypoint_count or waypoint_count >= 9 then
					player_ship.waypoint_set = true
					if player_ship.waypoint_count_delay == nil then
						player_ship.waypoint_count_delay = getScenarioTime() + 5
					end
				end
			end
			local waypoint_wait_message = _("tabRelay&Operations","Waiting for waypoint")
			if player_ship.waypoint_set then
				waypoint_wait_message = _("tabRelay&Operations","Waypoint check complete")
			end
			player_ship.waypoint_wait_rel = "waypoint_wait_rel"
			player_ship:addCustomInfo("Relay",player_ship.waypoint_wait_rel,waypoint_wait_message,66)
			player_ship.waypoint_wait_ops = "waypoint_wait_ops"
			player_ship:addCustomInfo("Operations",player_ship.waypoint_wait_ops,waypoint_wait_message,66)
			if player_ship.waypoint_count_delay ~= nil then
				if getScenarioTime() > player_ship.waypoint_count_delay then
					player_ship:removeCustom(player_ship.waypoint_wait_ops)
					player_ship:removeCustom(player_ship.waypoint_wait_rel)
					player_ship.waypoint_check_complete_msg_rel = "waypoint_check_complete_msg_rel"
					player_ship:addCustomMessage("Relay",player_ship.waypoint_check_complete_msg_rel,_("msgRelay","Waypoint system check has been completed.\nStatus: passed"))
					player_ship.waypoint_check_complete_msg_ops = "waypoint_check_complete_msg_ops"
					player_ship:addCustomMessage("Operations",player_ship.waypoint_check_complete_msg_ops,_("msgOperations","Waypoint system check has been completed.\nStatus: passed"))
					waypoint_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_waypoint_button_rel == nil then
				player_ship.check_waypoint_button_rel = "check_waypoint_button_rel"
				player_ship.check_waypoint_button_ops = "check_waypoint_button_ops"
				player_ship:addCustomButton("Relay",player_ship.check_waypoint_button_rel,_("buttonRelay","Check Waypoint"),function()
					player_ship:removeCustom(player_ship.check_waypoint_button_rel)
					player_ship:removeCustom(player_ship.check_waypoint_button_ops)
					waypoint_check = "started"
				end,47)
				player_ship:addCustomButton("Operations",player_ship.check_waypoint_button_ops,_("buttonOperations","Check Waypoint"),function()
					player_ship:removeCustom(player_ship.check_waypoint_button_rel)
					player_ship:removeCustom(player_ship.check_waypoint_button_ops)
					waypoint_check = "started"
				end,47)
			end
		end
		prev_waypoint_count = player_ship:getWaypointCount()
	end
	if probe_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if probe_check == "started" then
			probe_count = player_ship:getScanProbeCount()
			if player_ship.probe_launched then
				if probe_count >= player_ship:getMaxScanProbeCount() then
					player_ship.probes_replenished = true
					if player_ship.probe_replenished_delay == nil then
						player_ship.probe_replenished_delay = getScenarioTime() + 5
					end
				end
			else
				if probe_count ~= prev_probe_count or probe_count <= 1 then
					player_ship.probe_launched = true
				end				
			end
			local probe_wait_message = _("tabRelay&Operations","Waiting for probe launch")
			if player_ship.probe_launched then
				probe_wait_message = _("tabRelay&Operations","Restock probes")
				if player_ship.probes_replenished then
					probe_wait_message = _("tabRelay&Operations","Probe check complete")
				end
			end
			player_ship.probe_check_wait_msg_rel = "probe_check_wait_msg_rel"
			player_ship:addCustomInfo("Relay",player_ship.probe_check_wait_msg_rel,probe_wait_message,67)
			player_ship.probe_check_wait_msg_ops = "probe_check_wait_msg_ops"
			player_ship:addCustomInfo("Operations",player_ship.probe_check_wait_msg_ops,probe_wait_message,67)
			if player_ship.probe_replenished_delay ~= nil then
				if getScenarioTime() > player_ship.probe_replenished_delay then
					player_ship:removeCustom(player_ship.probe_check_wait_msg_ops)
					player_ship:removeCustom(player_ship.probe_check_wait_msg_rel)
					player_ship.probe_check_complete_msg_rel = "probe_check_complete_msg_rel"
					player_ship:addCustomMessage("Relay",player_ship.probe_check_complete_msg_rel,_("msgRelay","Scan probe system check has been completed.\nStatus: passed"))
					player_ship.probe_check_complete_msg_ops = "probe_check_complete_msg_ops"
					player_ship:addCustomMessage("Operations",player_ship.probe_check_complete_msg_ops,_("msgOperations","Scan probe system check has been completed.\nStatus: passed"))
					probe_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_probe_button_rel == nil then
				player_ship.check_probe_button_rel = "check_probe_button_rel"
				player_ship.check_probe_button_ops = "check_probe_button_ops"
				player_ship:addCustomButton("Relay",player_ship.check_probe_button_rel,_("buttonRelay","Check Probes"),function()
					player_ship:removeCustom(player_ship.check_probe_button_rel)
					player_ship:removeCustom(player_ship.check_probe_button_ops)
					probe_check = "started"
				end,48)
				player_ship:addCustomButton("Operations",player_ship.check_probe_button_ops,_("buttonOperations","Check Probes"),function()
					player_ship:removeCustom(player_ship.check_probe_button_rel)
					player_ship:removeCustom(player_ship.check_probe_button_ops)
					probe_check = "started"
				end,48)
			end
		end
		prev_probe_count = player_ship:getScanProbeCount()
	end
	if probe_link_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if probe_link_check == "started" then
			if player_ship.probe_linked then
				if player_ship.probe_unlinked then
					if player_ship.probe_link_delay == nil then
						player_ship.probe_link_delay = getScenarioTime() + 5
					end
				end
			end
			local probe_link_wait_message = _("tabRelay&Operations","Waiting for link")
			if player_ship.probe_linked then
				probe_link_wait_message = _("tabRelay&Operations","Waiting for unlink")
				if player_ship.probe_unlinked then
					probe_link_wait_message = _("tabRelay&Operations","Link check complete")
				end
			end
			player_ship.probe_link_check_wait_msg_rel = "probe_link_check_wait_msg_rel"
			player_ship:addCustomInfo("Relay",player_ship.probe_link_check_wait_msg_rel,probe_link_wait_message,68)
			player_ship.probe_link_check_wait_msg_ops = "probe_link_check_wait_msg_ops"
			player_ship:addCustomInfo("Operations",player_ship.probe_link_check_wait_msg_ops,probe_link_wait_message,68)
			if player_ship.probe_link_delay ~= nil then
				if getScenarioTime() > player_ship.probe_link_delay then
					player_ship:removeCustom(player_ship.probe_link_check_wait_msg_ops)
					player_ship:removeCustom(player_ship.probe_link_check_wait_msg_rel)
					player_ship.probe_link_complete_msg_rel = "probe_link_complete_msg_rel"
					player_ship:addCustomMessage("Relay",player_ship.probe_link_complete_msg_rel,_("msgRelay","Probe link system check has been completed.\nStatus: passed"))
					player_ship.probe_link_complete_msg_ops = "probe_link_complete_msg_ops"
					player_ship:addCustomMessage("Operations",player_ship.probe_link_complete_msg_ops,_("msgOperations","Probe link system check has been completed.\nStatus: passed"))
					probe_link_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_probe_link_button_rel == nil then
				player_ship.check_probe_link_button_rel = "check_probe_link_button_rel"
				player_ship.check_probe_link_button_ops = "check_probe_link_button_ops"
				player_ship:addCustomButton("Relay",player_ship.check_probe_link_button_rel,_("buttonRelay","Check Probe Link"),function()
					player_ship:removeCustom(player_ship.check_probe_link_button_rel)
					player_ship:removeCustom(player_ship.check_probe_link_button_ops)
					probe_link_check = "started"
				end,49)
				player_ship:addCustomButton("Operations",player_ship.check_probe_link_button_ops,_("buttonOperations","Check Probe Link"),function()
					player_ship:removeCustom(player_ship.check_probe_link_button_rel)
					player_ship:removeCustom(player_ship.check_probe_link_button_ops)
					probe_link_check = "started"
				end,49)
			end
		end
	end
	if coolant_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if coolant_check == "started" then
			local coolant_systems_checked_count = 0
			local index = 0
--			player_ship.coolant_value = {}
			for system, details in pairs(player_ship.coolant_completed) do
				if details.checked then
					coolant_systems_checked_count = coolant_systems_checked_count + 1
				elseif player_ship:getSystemCoolant(system) > 9.9999 then
					details.checked = true
					coolant_systems_checked_count = coolant_systems_checked_count + 1
				end
--				player_ship.coolant_value[system] = string.format("coolant_value %s",system)
--				player_ship:addCustomInfo("Engineering",player_ship.coolant_value[system],string.format("%s: %.1f",details.name,player_ship:getSystemCoolant(system)),index + 70)
				index = index + 1
			end
			if coolant_systems_checked_count >= 8 then
				if player_ship.coolant_check_delay == nil then
					player_ship.coolant_check_delay = getScenarioTime() + 5
				end
			end
			local coolant_wait_message = string.format(_("tabEngineering&Engineering+","Coolant Count: %i"),coolant_systems_checked_count)
			if coolant_systems_checked_count >= 8 then
				coolant_wait_message = _("tabEngineering&Engineering+","Coolant checks completed")
			end
			player_ship.coolant_check_wait_msg_eng = "coolant_check_wait_msg_eng"
			player_ship:addCustomInfo("Engineering",player_ship.coolant_check_wait_msg_eng,coolant_wait_message,69)
			player_ship.coolant_check_wait_msg_epl = "coolant_check_wait_msg_epl"
			player_ship:addCustomInfo("Engineering+",player_ship.coolant_check_wait_msg_epl,coolant_wait_message,69)
			if player_ship.coolant_check_delay ~= nil then
				if getScenarioTime() > player_ship.coolant_check_delay then
					player_ship:removeCustom(player_ship.coolant_check_wait_msg_epl)
					player_ship:removeCustom(player_ship.coolant_check_wait_msg_eng)
					if player_ship.check_coolant_status_button_eng ~= nil then
						player_ship:removeCustom(player_ship.check_coolant_status_button_eng)
					end
					if player_ship.check_coolant_status_button_epl ~= nil then
						player_ship:removeCustom(player_ship.check_coolant_status_button_epl)
					end
					player_ship.coolant_complete_msg_eng = "coolant_complete_msg_eng"
					player_ship:addCustomMessage("Engineering",player_ship.coolant_complete_msg_eng,_("msgEngineering","Coolant flow checks completed.\nStatus: passed"))
					player_ship.coolant_complete_msg_epl = "coolant_complete_msg_epl"
					player_ship:addCustomMessage("Engineering+",player_ship.coolant_complete_msg_epl,_("msgEngineering+","Coolant flow checks completed.\nStatus: passed"))
					coolant_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_coolant_button_eng == nil then
				player_ship.check_coolant_button_eng = "check_coolant_button_eng"
				player_ship.check_coolant_button_epl = "check_coolant_button_epl"
				player_ship:addCustomButton("Engineering",player_ship.check_coolant_button_eng,_("buttonEngineering","Check Coolant"),function()
					player_ship:removeCustom(player_ship.check_coolant_button_eng)
					player_ship:removeCustom(player_ship.check_coolant_button_epl)
					coolant_check = "started"
					player_ship.check_coolant_status_button_eng = "check_coolant_status_button_eng"
					player_ship:addCustomButton("Engineering",player_ship.check_coolant_status_button_eng,_("buttonEngineering","Coolant Check Status"),function()
						local status_message = _("msgEngineering","Coolant flow check status by system:")
						local completed_count = 0
						for system, details in pairs(player_ship.coolant_completed) do
							if details.checked then
								status_message = string.format(_("msgEngineering","%s\n%s: complete"),status_message,details.name)
								completed_count = completed_count + 1
							else
								status_message = string.format(_("msgEngineering","%s\n%s: %.1f (need to reach 10)"),status_message,details.name,player_ship:getSystemCoolant(system))
							end
						end
						status_message = string.format(_("msgEngineering","%s\nCount of systems checked: %i"),status_message,completed_count)
						player_ship.coolant_status_message_eng = "coolant_status_message_eng"
						player_ship:addCustomMessage("Engineering",player_ship.coolant_status_message_eng,status_message)
					end,38)
				end,39)
				player_ship:addCustomButton("Engineering+",player_ship.check_coolant_button_epl,_("buttonEngineering+","Check Coolant"),function()
					player_ship:removeCustom(player_ship.check_coolant_button_eng)
					player_ship:removeCustom(player_ship.check_coolant_button_epl)
					coolant_check = "started"
					player_ship.check_coolant_status_button_epl = "check_coolant_status_button_epl"
					player_ship:addCustomButton("Engineering+",player_ship.check_coolant_status_button_epl,_("buttonEngineering+","Coolant Check Status"),function()
						local status_message = _("msgEngineering+","Coolant flow check status by system:")
						local completed_count = 0
						for system, details in pairs(player_ship.coolant_completed) do
							if details.checked then
								status_message = string.format(_("msgEngineering+","%s\n%s: complete"),status_message,details.name)
								completed_count = completed_count + 1
							else
								status_message = string.format(_("msgEngineering+","%s\n%s: %.1f (need to reach 10)"),status_message,details.name,player_ship:getSystemCoolant(system))
							end
						end
						status_message = string.format(_("msgEngineering+","%s\nCount of systems checked: %i"),status_message,completed_count)
						player_ship.coolant_status_message_epl = "coolant_status_message_epl"
						player_ship:addCustomMessage("Engineering+",player_ship.coolant_status_message_epl,status_message)
					end,38)
				end,39)
			end
		end
	end
	if power_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
		if power_check == "started" then
			local power_max_count = 0
			local power_min_count = 0
			local index = 0
--			player_ship.power_value = {}
			for system, details in pairs(player_ship.power_completed) do
				if details.min then
					power_min_count = power_min_count + 1
				elseif player_ship:getSystemPower(system) <= 0.0001 then
					details.min = true
					power_min_count = power_min_count + 1
				end
				if details.max then
					power_max_count = power_max_count + 1
				elseif player_ship:getSystemPower(system) >= 2.9999 then
					details.max = true
					power_max_count = power_max_count + 1
				end
--				player_ship.power_value[system] = string.format("power_value %s",system)
--				player_ship:addCustomInfo("Engineering",player_ship.power_value[system],string.format("%s: %.1f",details.name,player_ship:getSystemPower(system)),index + 70)
				index = index + 1
			end
			if power_max_count >= 8 and power_min_count >= 8 then
				if player_ship.power_check_delay == nil then
					player_ship.power_check_delay = getScenarioTime() + 5
				end
			end
			local power_max_wait_message = string.format(_("tabEngineering&Engineering+","Power Max Count: %i"),power_max_count)
			if power_max_count >= 8 then
				power_max_wait_message = _("tabEngineering&Engineering+","Power max ck completed")
			end
			local power_min_wait_message = string.format(_("tabEngineering&Engineering+","Power Min Count: %i"),power_min_count)
			if power_min_count >= 8 then
				power_min_wait_message = _("tabEngineering&Engineering+","Power min ck completed")
			end
			player_ship.power_max_check_wait_msg_eng = "power_max_check_wait_msg_eng"
			player_ship:addCustomInfo("Engineering",player_ship.power_max_check_wait_msg_eng,power_max_wait_message,70)
			player_ship.power_max_check_wait_msg_epl = "power_max_check_wait_msg_epl"
			player_ship:addCustomInfo("Engineering+",player_ship.power_max_check_wait_msg_epl,power_max_wait_message,70)
			player_ship.power_min_check_wait_msg_eng = "power_min_check_wait_msg_eng"
			player_ship:addCustomInfo("Engineering",player_ship.power_min_check_wait_msg_eng,power_min_wait_message,71)
			player_ship.power_min_check_wait_msg_epl = "power_min_check_wait_msg_epl"
			player_ship:addCustomInfo("Engineering+",player_ship.power_min_check_wait_msg_epl,power_min_wait_message,71)
			if player_ship.power_check_delay ~= nil then
				if getScenarioTime() > player_ship.power_check_delay then
					player_ship:removeCustom(player_ship.power_max_check_wait_msg_eng)
					player_ship:removeCustom(player_ship.power_max_check_wait_msg_epl)
					player_ship:removeCustom(player_ship.power_min_check_wait_msg_eng)
					player_ship:removeCustom(player_ship.power_min_check_wait_msg_epl)
					if player_ship.check_power_status_button_eng ~= nil then
						player_ship:removeCustom(player_ship.check_power_status_button_eng)
					end
					if player_ship.check_power_status_button_epl ~= nil then
						player_ship:removeCustom(player_ship.check_power_status_button_epl)
					end
					player_ship.power_complete_msg_eng = "power_complete_msg_eng"
					player_ship:addCustomMessage("Engineering",player_ship.power_complete_msg_eng,_("msgEngineering","Power flow checks completed.\nStatus: passed"))
					player_ship.power_complete_msg_epl = "power_complete_msg_epl"
					player_ship:addCustomMessage("Engineering+",player_ship.power_complete_msg_epl,_("msgEngineering+","Power flow checks completed.\nStatus: passed"))
					power_check = "complete"
					player_ship:addReputationPoints(10)
				end
			end
		else
			if player_ship.check_power_button_eng == nil then
				player_ship.check_power_button_eng = "check_power_button_eng"
				player_ship.check_power_button_epl = "check_power_button_epl"
				player_ship:addCustomButton("Engineering",player_ship.check_power_button_eng,_("buttonEngineering","Check Power"),function()
					player_ship:removeCustom(player_ship.check_power_button_eng)
					player_ship:removeCustom(player_ship.check_power_button_epl)
					power_check = "started"
					player_ship.check_power_status_button_eng = "check_power_status_button_eng"
					player_ship:addCustomButton("Engineering",player_ship.check_power_status_button_eng,_("buttonEngineering","Power Check Status"),function()
						local status_message = _("msgEngineering","Power flow check status by system. Must go up to 3 for max check and down to zero for min check:")
						local min_completed_count = 0
						local max_completed_count = 0
						for system, details in pairs(player_ship.power_completed) do
							if details.min then
								min_completed_count = min_completed_count + 1
							end
							if details.max then
								max_completed_count = max_completed_count + 1
							end
							if details.min and details.max then
								status_message = string.format(_("msgEngineering","%s\n%s: completed"),status_message,details.name)
							else
								status_message = string.format("%s\n%s: %.1f",status_message,details.name,player_ship:getSystemPower(system))
							end
						end
						status_message = string.format(_("msgEngineering","%s\nSystems that have reached minimum power level: %i\nSystems that have reached maximum power level: %i"),status_message,min_completed_count,max_completed_count)
						player_ship.power_status_message_eng = "power_status_message_eng"
						player_ship:addCustomMessage("Engineering",player_ship.power_status_message_eng,status_message)
					end,36)
				end,37)
				player_ship:addCustomButton("Engineering+",player_ship.check_power_button_epl,_("buttonEngineering+","Check Power"),function()
					player_ship:removeCustom(player_ship.check_power_button_eng)
					player_ship:removeCustom(player_ship.check_power_button_epl)
					power_check = "started"
					player_ship.check_power_status_button_epl = "check_power_status_button_epl"
					player_ship:addCustomButton("Engineering",player_ship.check_power_status_button_epl,_("buttonEngineering+","Power Check Status"),function()
						local status_message = _("msgEngineering+","Power flow check status by system. Must go up to 3 for max check and down to zero for min check:")
						local min_completed_count = 0
						local max_completed_count = 0
						for system, details in pairs(player_ship.power_completed) do
							if details.min then
								min_completed_count = min_completed_count + 1
							end
							if details.max then
								max_completed_count = max_completed_count + 1
							end
							if details.min and details.max then
								status_message = string.format(_("msgEngineering+","%s\n%s: completed"),status_message,details.name)
							else
								status_message = string.format("%s\n%s: %.1f",status_message,details.name,player_ship:getSystemPower(system))
							end
						end
						status_message = string.format(_("msgEngineering+","%s\nSystems that have reached minimum power level: %i\nSystems that have reached maximum power level: %i"),min_completed_count,max_completed_count)
						player_ship.power_status_message_epl = "power_status_message_epl"
						player_ship:addCustomMessage("Engineering+",player_ship.power_status_message_epl,status_message)
					end,36)
				end,37)
			end
		end
	end
	if combat_maneuver_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
	elseif beam_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
	elseif missile_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
	elseif scanner_check ~= "complete" then
		list_complete = false
		checklist_completed_count = checklist_completed_count - 1
	end
	if list_complete then
		player_ship.checklist_complete = "yes"
		if checklist_end_clock == nil then
			checklist_end_clock = getScenarioTime()
			checklist_elapsed_time = checklist_end_clock - checklist_start_clock
		end
		if player_ship.congratulations_message == nil then
			if availableForComms(player_ship) then
				station_regional_hq:openCommsTo(player_ship)
			end
		end
		if ship_return_timer == nil then
			ship_return_timer = 30*60
		else
			ship_return_timer = ship_return_timer - delta
			if ship_return_timer < 0 then
				globalMessage(string.format("You failed to return %s within the time allowed",player_ship:getCallSign()))
				victory("Kraylor")
			end
			local ship_return_minutes = math.floor(ship_return_timer / 60)
			local ship_return_seconds = math.floor(ship_return_timer % 60)
			local ship_return_status = string.format("Return: %s:%.2i",ship_return_minutes,ship_return_seconds)
			player_ship.ship_return_timer_rel = "ship_return_timer_rel"
			player_ship:addCustomInfo("Relay",player_ship.ship_return_timer_rel,ship_return_status,99)
			player_ship.ship_return_timer_ops = "ship_return_timer_ops"
			player_ship:addCustomInfo("Operations",player_ship.ship_return_timer_ops,ship_return_status,99)
		end
	end
	if checklist_completed_count >= interruption_threshold then
		mainLinearPlot = continuousSpawn
	end
	local shipyard_alive = true
	if station_regional_hq == nil then
		shipyard_alive = false
	else
		if not station_regional_hq:isValid() then
			shipyard_alive = false
		end
	end
	if not shipyard_alive then
		globalMessage("The shipyard has been destroyed")
		victory("Kraylor")
	end
end
--		Mortal repair crew functions. Includes coolant loss as option to losing repair crew
function healthCheck(delta)
	healthCheckTimer = healthCheckTimer - delta
	if healthCheckTimer < 0 then
		if healthDiagnostic then print("health check timer expired") end
		for pidx=1,32 do
			if healthDiagnostic then print("in player loop") end
			local p = getPlayerShip(pidx)
			if healthDiagnostic then print("got player ship") end
			if p ~= nil and p:isValid() then
				if healthDiagnostic then print("valid ship") end
				if p:getRepairCrewCount() > 0 then
					if healthDiagnostic then print("crew on valid ship") end
					local fatalityChance = 0
					if healthDiagnostic then print("shields") end
					sc = p:getShieldCount()
					if healthDiagnostic then print("sc: " .. sc) end
					if p:getShieldCount() > 1 then
						cShield = (p:getSystemHealth("frontshield") + p:getSystemHealth("rearshield"))/2
					else
						cShield = p:getSystemHealth("frontshield")
					end
					fatalityChance = fatalityChance + (p.prevShield - cShield)
					p.prevShield = cShield
					if healthDiagnostic then print("reactor") end
					fatalityChance = fatalityChance + (p.prevReactor - p:getSystemHealth("reactor"))
					p.prevReactor = p:getSystemHealth("reactor")
					if healthDiagnostic then print("maneuver") end
					fatalityChance = fatalityChance + (p.prevManeuver - p:getSystemHealth("maneuver"))
					p.prevManeuver = p:getSystemHealth("maneuver")
					if healthDiagnostic then print("impulse") end
					fatalityChance = fatalityChance + (p.prevImpulse - p:getSystemHealth("impulse"))
					p.prevImpulse = p:getSystemHealth("impulse")
					if healthDiagnostic then print("beamweapons") end
					if p:getBeamWeaponRange(0) > 0 then
						if p.healthyBeam == nil then
							p.healthyBeam = 1.0
							p.prevBeam = 1.0
						end
						fatalityChance = fatalityChance + (p.prevBeam - p:getSystemHealth("beamweapons"))
						p.prevBeam = p:getSystemHealth("beamweapons")
					end
					if healthDiagnostic then print("missilesystem") end
					if p:getWeaponTubeCount() > 0 then
						if p.healthyMissile == nil then
							p.healthyMissile = 1.0
							p.prevMissile = 1.0
						end
						fatalityChance = fatalityChance + (p.prevMissile - p:getSystemHealth("missilesystem"))
						p.prevMissile = p:getSystemHealth("missilesystem")
					end
					if healthDiagnostic then print("warp") end
					if p:hasWarpDrive() then
						if p.healthyWarp == nil then
							p.healthyWarp = 1.0
							p.prevWarp = 1.0
						end
						fatalityChance = fatalityChance + (p.prevWarp - p:getSystemHealth("warp"))
						p.prevWarp = p:getSystemHealth("warp")
					end
					if healthDiagnostic then print("jumpdrive") end
					if p:hasJumpDrive() then
						if p.healthyJump == nil then
							p.healthyJump = 1.0
							p.prevJump = 1.0
						end
						fatalityChance = fatalityChance + (p.prevJump - p:getSystemHealth("jumpdrive"))
						p.prevJump = p:getSystemHealth("jumpdrive")
					end
					if healthDiagnostic then print("adjust") end
					if p:getRepairCrewCount() == 1 then
						fatalityChance = fatalityChance/2	-- increase chances of last repair crew standing
					end
					if healthDiagnostic then print("check") end
					if fatalityChance > 0 then
						crewFate(p,fatalityChance)
					end
				else	--no repair crew left
					if random(1,100) <= (4 - difficulty) then
						p:setRepairCrewCount(1)
						if p:hasPlayerAtPosition("Engineering") then
							local repairCrewRecovery = "repairCrewRecovery"
							p:addCustomMessage("Engineering",repairCrewRecovery,_("msgEngineer","Medical team has revived one of your repair crew"))
						end
						if p:hasPlayerAtPosition("Engineering+") then
							local repairCrewRecoveryPlus = "repairCrewRecoveryPlus"
							p:addCustomMessage("Engineering+",repairCrewRecoveryPlus,_("msgEngineer+","Medical team has revived one of your repair crew"))
						end
						resetPreviousSystemHealth(p)
					end
				end
				if p.initialCoolant ~= nil then
					local current_coolant = p:getMaxCoolant()
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
									p:addCustomMessage("Engineering","coolant_recovery",_("msgEngineer","Automated systems have recovered some coolant"))
								end
								if p:hasPlayerAtPosition("Engineering+") then
									p:addCustomMessage("Engineering+","coolant_recovery_plus",_("msgEngineer+","Automated systems have recovered some coolant"))
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
		if p.initialCoolant == nil then
			p:setRepairCrewCount(p:getRepairCrewCount() - 1)
			if p:hasPlayerAtPosition("Engineering") then
				local repairCrewFatality = "repairCrewFatality"
				p:addCustomMessage("Engineering",repairCrewFatality,_("msgEngineer","One of your repair crew has perished"))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("msgEngineer+","One of your repair crew has perished"))
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
			consequence = math.random(1,upper_consequence)
			if consequence == 1 then
				p:setRepairCrewCount(p:getRepairCrewCount() - 1)
				if p:hasPlayerAtPosition("Engineering") then
					local repairCrewFatality = "repairCrewFatality"
					p:addCustomMessage("Engineering",repairCrewFatality,_("msgEngineer","One of your repair crew has perished"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local repairCrewFatalityPlus = "repairCrewFatalityPlus"
					p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("msgEngineer+","One of your repair crew has perished"))
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
					p:addCustomMessage("Engineering",coolantLoss,_("msgEngineer","Damage has caused a loss of coolant"))
				end
				if p:hasPlayerAtPosition("Engineering+") then
					local coolantLossPlus = "coolantLossPlus"
					p:addCustomMessage("Engineering+",coolantLossPlus,_("msgEngineer+","Damage has caused a loss of coolant"))
				end
			else
				local named_consequence = consequence_list[consequence-2]
				if named_consequence == "probe" then
					p:setCanLaunchProbe(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","probe_launch_damage_message",_("msgEngineer","The probe launch system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus",_("msgEngineer+","The probe launch system has been damaged"))
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message",_("msgEngineer","The hacking system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus",_("msgEngineer+","The hacking system has been damaged"))
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message",_("msgEngineer","The scanners have been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus",_("msgEngineer+","The scanners have been damaged"))
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message",_("msgEngineer","Combat maneuver has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus",_("msgEngineer+","Combat maneuver has been damaged"))
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message",_("msgEngineer","Self destruct system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus",_("msgEngineer+","Self destruct system has been damaged"))
					end
				end
			end	--coolant loss branch
		end
	end
end
--      Inventory button and functions for relay/operations 
function cargoInventory(delta)
	for pidx=1,32 do
		local p = getPlayerShip(pidx)
		if p ~= nil and p:isValid() then
			local cargoHoldEmpty = true
			if p.goods ~= nil then
				for good, quantity in pairs(p.goods) do
					if quantity ~= nil and quantity > 0 then
						cargoHoldEmpty = false
						break
					end
				end
			end
			if not cargoHoldEmpty then
				if p:hasPlayerAtPosition("Relay") then
					if p.inventoryButton == nil then
						local tbi = "inventory" .. p:getCallSign()
						p:addCustomButton("Relay",tbi,_("tabRelay","Inventory"),function() playerShipCargoInventory(p) end,2)
						p.inventoryButton = true
					end
				end
				if p:hasPlayerAtPosition("Operations") then
					if p.inventoryButton == nil then
						local tbi = "inventoryOp" .. p:getCallSign()
						p:addCustomButton("Operations",tbi,_("tabRelay","Inventory"),function() playerShipCargoInventory(p) end,2)
						p.inventoryButton = true
					end
				end
			end
		end
	end
end
function playerShipCargoInventory(p)
	p:addToShipLog(string.format(_("inventory-shipLog","%s Current cargo:"),p:getCallSign()),"Yellow")
	local goodCount = 0
	if p.goods ~= nil then
		for good, goodQuantity in pairs(p.goods) do
			goodCount = goodCount + 1
			p:addToShipLog(string.format("     %s: %i",good,goodQuantity),"Yellow")
		end
	end
	if goodCount < 1 then
		p:addToShipLog(_("inventory-shipLog","     Empty"),"Yellow")
	end
	p:addToShipLog(string.format(_("inventory-shipLog","Available space: %i"),p.cargo),"Yellow")
end

function updateInner(delta)
	if delta == 0 then
		--game paused
		for pidx, p in ipairs(getActivePlayerShips()) do
			if p.pidx == nil then
				p.pidx = pidx
				setPlayers(p)
			end
		end
		return
	end
	if not isPerSystemDamageUsed() then
		reason = _("msgMainscreen","Scenario needs the 'Per-system damage' option under 'Extra settings'")
		globalMessage(reason)
		setBanner(reason)
		victory("Kraylor")
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if mainLinearPlot ~= nil then
		mainLinearPlot(delta)
	end
	if initial_player_ship ~= nil and initial_player_ship.opening_message == nil and station_regional_hq ~= nil then
		initial_player_ship:addToShipLog(string.format("From: Central Headquarters Command\nTo: Captain and crew of %s\nGreetings %s. You have completed your journey from central headquarters to regional headquarters, %s. You are here to inspect a ship produced by the shipyard here. Contact %s for details on starting your inspection.",initial_player_ship:getCallSign(),initial_player_ship:getCallSign(),station_regional_hq:getCallSign(),station_regional_hq:getCallSign()),"Magenta")
		initial_player_ship.opening_message = "sent"
	end
	if player_ship ~= nil then
		automatedCheckList(delta)
	end
	if player_ship ~= nil and player_ship:isValid() then
		updatePlayerLongRangeSensors(player_ship)
		updatePlayerTubeSizeBanner(player_ship)
		player_ship.name_tag_hlm = "name_tag_hlm"
		player_ship:addCustomInfo("Helms",player_ship.name_tag_hlm,string.format("%s %s in %s",player_ship:getFaction(),player_ship:getCallSign(),player_ship:getSectorName()),3)
		player_ship.name_tag_tac = "name_tag_tac"
		player_ship:addCustomInfo("Tactical",player_ship.name_tag_tac,string.format("%s %s in %s",player_ship:getFaction(),player_ship:getCallSign(),player_ship:getSectorName()),3)
	end
	moonCollisionCheck()
	if maintenancePlot ~= nil then
		maintenancePlot(delta)
	end
	if plotCI ~= nil then	--cargo inventory
		plotCI(delta)
	end
	if plotH ~= nil then	--health
		plotH(delta)
	end
	if plotRevert ~= nil then
		plotRevert(delta)
	end
	if plotContinuum ~= nil then
		plotContinuum(delta)
	end
end
function update(delta)
    local status,error=pcall(updateInner,delta)
    if not status then
		print("script error : - ")
		print(error)
		if popupGMDebug == "once" or popupGMDebug == "always" then
			if popupGMDebug == "once" then
				popupGMDebug = "never"
			end
			addGMMessage("script error - \n"..error)
		end
    end
end
