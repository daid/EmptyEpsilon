-- Name: The Omicron Plague
-- Description: A routine patrol mission turns into a desperate attempt to save humanity from an Exuari biological weapon
--- 
--- Designed to run in a limited time with different terrain each time. Multiple player ships may join
---
--- Duration: approximately 45 minutes depending on the configuration options chosen
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
-- Setting[Rescue]: Number of minutes given to rescue an ailing ensign. Grant more time to make it easier, less time to make it harder.
-- Rescue[15]: Fifteen minutes to help ensign
-- Rescue[20|Default]: Twenty minutes to help ensign
-- Rescue[25]: Twenty-five minutes to help ensign
-- Rescue[30]: Thirty minutes to help ensign
-- Setting[Destroy]: Number of minutes given to destroy designated enemy base. Grant more time to make it easier, less time to make it harder.
-- Destroy[15]: Fifteen minutes to destroy base
-- Destroy[20|Default]: Twenty minutes to destroy base
-- Destroy[25]: Twenty-five minutes to destroy base
-- Destroy[30]: Thirty minutes to destroy base
-- Setting[Reputation]: Amount of reputation to start with
-- Reputation[Unknown|Default]: Zero reputation - nobody knows anything about you
-- Reputation[Nice]: 20 reputation - you've had a small positive influence on the local community
-- Reputation[Hero]: 50 reputation - you helped important people or lots of people
-- Reputation[Major Hero]: 100 reputation - you're well known by nearly everyone as a force for good
-- Reputation[Super Hero]: 200 reputation - everyone knows you and relies on you for help
-- Setting[Unique Ship]: Choose player ship outside of standard player ship list
-- Unique Ship[None|Default]: None: just use standard player ship list on spawn screen
-- Unique Ship[Amalgam]: Based on Atlantis, 4 beams (vs 2), single broadside tube on each side for large homing missiles only, 2 mining tubes, weaker defenses and engines 
-- Unique Ship[Midian]: Based on missile cruiser, reduced tubes, missiles and base warp speed to get beam weapons and HVLI
-- Unique Ship[Raven]: Based on Cruiser, stronger shields, weaker hull, broadside beams, tweaked tubes and missiles, low powered warp drive, tweaked sensor ranges
-- Unique Ship[Squid]: Based on Piranha, stronger defenses, added a beam weapon, reduced missile load, large homing missiles, reconfigured tubes, shorter jump and sensor ranges


require("utils.lua")
require("place_station_scenario_utility.lua")
--	also uses supply_drop.lua

--------------------
-- Initialization --
--------------------
function init()
	scenario_version = "0.0.1"
	print(string.format("     -----     Scenario: Omicron     -----     Version %s     -----",scenario_version))
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
		difficulty = 1
		adverseEffect = .995
		coolant_loss = .99995
		coolant_gain = .001
		starting_rep = 20
		enemy_power = 1
		rescue_time_limit = 20
		destroy_time_limit = 20
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
			["Easy"] =		{number = .5,	rep = 70,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005},
			["Normal"] =	{number = 1,	rep = 50,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001},
			["Hard"] =		{number = 2,	rep = 30,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001},
		}
		difficulty =	murphy_config[getScenarioSetting("Murphy")].number
		adverseEffect =	murphy_config[getScenarioSetting("Murphy")].adverse
		coolant_loss =	murphy_config[getScenarioSetting("Murphy")].lose_coolant
		coolant_gain =	murphy_config[getScenarioSetting("Murphy")].gain_coolant
		starting_rep =	murphy_config[getScenarioSetting("Murphy")].rep
		local rescue_config = {
			["10"] = 10,
			["15"] = 15,
			["20"] = 20,
			["25"] = 25,
			["30"] = 30,
		}
		rescue_time_limit = rescue_config[getScenarioSetting("Rescue")]
		local destroy_config = {
			["10"] = 10,
			["15"] = 15,
			["20"] = 20,
			["25"] = 25,
			["30"] = 30,
		}
		destroy_time_limit = destroy_config[getScenarioSetting("Destroy")]
		local reputation_config = {
			["Unknown"] = 		0,
			["Nice"] = 			20,
			["Hero"] = 			50,
			["Major Hero"] =	100,
			["Super Hero"] =	200,
		}
		reputation_start_amount = reputation_config[getScenarioSetting("Reputation")]
		local player_ship_config = {
			["Amalgam"] =	createPlayerShipMixer,
			["Midian"] =	createPlayerShipFlipper,
			["Raven"] =		createPlayerShipClaw,
			["Squid"] =		createPlayerShipInk,
		}
		if getScenarioSetting("Unique Ship") ~= "None" then
			player_ship_config[getScenarioSetting("Unique Ship")]()
		end
	end
end
function setConstants()
	far_enough_fail = false
	medical_research_obtained = false
	distance_diagnostic = false
	stationCommsDiagnostic = false
	change_enemy_order_diagnostic = false
	healthDiagnostic = false
	sensor_jammer_diagnostic = false
	sj_diagnostic = false	--short sensor jammer diagnostic, once at env create
	guaranteed_comms_diagnostic = false
	medical_message_diagnostic = false
	all_players_hailed_by_medical_research_station = false
	player_ship_spawn_count = 0
	player_ship_death_count = 0
	expedition_count = 5 + (difficulty * 2)
	task_force_count = 5 + (difficulty * 2)
	max_repeat_loop = 300
	local c_x, c_y = vectorFromAngleNorth(random(0,360),random(0,60000))
	center_x = 909000 + c_x
	center_y = 151000 + c_y
	primary_orders = _("orders-comms","Contact regional headquarters")
	plotCI = cargoInventory
	plotH = healthCheck				--Damage to ship can kill repair crew members
	healthCheckTimerInterval = 8
	healthCheckTimer = healthCheckTimerInterval
	prefix_length = 0
	suffix_index = 0
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
	--Player ship name lists to supplant standard randomized call sign generation
	player_ship_names_for = {}
	player_ship_names_for["Amalgam"] = {"Mixer","Igor","Ronco","Ginsu"}
	player_ship_names_for["Atlantis"] = {"Excaliber","Thrasher","Punisher","Vorpal","Protang","Drummond","Parchim","Coronado"}
	player_ship_names_for["Atlantis II"] = {"Spyder", "Shelob", "Tarantula", "Aragog", "Charlotte"}
	player_ship_names_for["Benedict"] = {"Elizabeth","Ford","Vikramaditya","Liaoning","Avenger","Naruebet","Washington","Lincoln","Garibaldi","Eisenhower"}
	player_ship_names_for["Crucible"] = {"Sling", "Stark", "Torrid", "Kicker", "Flummox"}
	player_ship_names_for["Cruzeiro"] = {"Vamanos", "Cougar", "Parthos", "Trifecta", "Light Mind"}
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
	template_pool_size = 5
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
		["Roc"] =						200,
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
	fly_formation = {
		["V"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
					},
		["Vac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
					},
		["V4"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
					},
		["Vac4"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
					},
		["A"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["Aac"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["A4"] =	{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
					},
		["Aac4"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
					},
		["/"] =		{
						{angle = 60	, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["-"] =		{
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["-4"] =		{
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 90	, dist = 2	},
						{angle = 270, dist = 2	},
					},
		["\\"] =	{
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
					},
		["|"] =		{
						{angle = 0	, dist = 1	},
						{angle = 180, dist = 1	},
					},
		["|4"] =	{
						{angle = 0	, dist = 1	},
						{angle = 180, dist = 1	},
						{angle = 0	, dist = 2	},
						{angle = 180, dist = 2	},
					},
		["/ac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["\\ac"] =	{
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
					},
		["M"] =		{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Mac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["M6"] =	{
						{angle = 60	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 120, dist = 1.3},
						{angle = 240, dist = 1.3},
					},
		["Mac6"] =	{
						{angle = 30	, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 125, dist = 1.7},
						{angle = 235, dist = 1.7},
					},
		["W"] =		{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["Wac"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
					},
		["W6"] =	{
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 60	, dist = 1.3},
						{angle = 300, dist = 1.3},
					},
		["Wac6"] =	{
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 90	, dist = 1	},
						{angle = 270, dist = 1	},
						{angle = 55	, dist = 1.7},
						{angle = 295, dist = 1.7},
					},
		["X"] =		{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
					},
		["Xac"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
					},
		["X8"] =	{
						{angle = 60	, dist = 1	},
						{angle = 300, dist = 1	},
						{angle = 120, dist = 1	},
						{angle = 240, dist = 1	},
						{angle = 60	, dist = 2	},
						{angle = 300, dist = 2	},
						{angle = 120, dist = 2	},
						{angle = 240, dist = 2	},
					},
		["Xac8"] =	{
						{angle = 30	, dist = 1	},
						{angle = 330, dist = 1	},
						{angle = 150, dist = 1	},
						{angle = 210, dist = 1	},
						{angle = 30	, dist = 2	},
						{angle = 330, dist = 2	},
						{angle = 150, dist = 2	},
						{angle = 210, dist = 2	},
					},
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
--	patrol_probe value should be between 0 and 5 not inclusive (0 = no patrol probes). The higher the value, the faster the patrol probe and the fewer patrol probes available 
	playerShipStats = {	
		["Atlantis"]			= { strength = 52,	cargo = 6,	distance = 400,	long_range_radar = 30000, short_range_radar = 5000, tractor = true,		mining = true,	probes = 10,	pods = 2,	turbo_torp = false,	patrol_probe = 0,	prox_scan = 0,	epjam = 0,	},
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
end
-- Game Master functions --
function setGMButtons()
	mainGMButtons = mainGMButtonsDuringPause
	mainGMButtons()
end
function mainGMButtons()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
end
function mainGMButtonsDuringPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
	addGMFunction(_("buttonGM","+Rescue Time"),setRescueTime)
	addGMFunction(_("buttonGM","+Destroy Time"),setDestroyTime)
	addGMFunction(_("buttonGM","+Difficulty"),setDifficulty)
	addGMFunction(_("buttonGM","+Enemy Power"),setEnemyPower)
	addGMFunction(_("buttonGM","+Reputation"),setInitialReputation)
end
function mainGMButtonsAfterPause()
	clearGMFunctions()
	addGMFunction(string.format(_("buttonGM","Version %s"),scenario_version),function()
		local version_message = string.format(_("msgGM","Scenario version %s\n LUA version %s"),scenario_version,_VERSION)
		addGMMessage(version_message)
		print(version_message)
	end)
	addGMFunction(_("buttonGM","+Station Reports"),stationReports)
	addGMFunction(_("buttonGM","Mission Stations"),function()
		addGMMessage(string.format(_("msgGM","This is spoiler information. Consider carefully before you reveal this to the rest of the players. If you feel you have to reveal this information, I suggest you select the player ship using the widget to the right of the 'Global message' button, then click the 'Hail ship' button, identify yourself as a character in game like the regional headquarters stellar cartography technician, then type the information as if you were that character helping them out on their mission.\n\nMedical research station: %s in sector %s\nPlague station %s in %s"),station_medical_research:getCallSign(),station_medical_research:getSectorName(),station_plague:getCallSign(),station_plague:getSectorName()))
	end)
	addGMFunction(_("buttonGM","+Test Non-DB Ships"),testNonDBShips)
end
function setEnemyPower()
    clearGMFunctions()
    addGMFunction(_("buttonGM","-From Enemy Power"),mainGMButtons)
    local powers = {
        {val = .5,    desc = _("buttonGM","Easy")},
        {val = 1,    desc = _("buttonGM","Normal")},
        {val = 2,    desc = _("buttonGM","Hard")},
        {val = 3,    desc = _("buttonGM","Extreme")},
        {val = 5,    desc = _("buttonGM","Quixotic")},
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
        {val = .5,    desc = _("buttonGM","Easy")},
        {val = 1,    desc = _("buttonGM","Normal")},
        {val = 2,    desc = _("buttonGM","Hard")},
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
function setDestroyTime()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Destroy Time"),mainGMButtons)
	local destroy_times = {15,20,25,30}
	for index, time in ipairs(destroy_times) do
		local button_label = string.format(_("buttonGM","%i minutes"),time)
		if time == destroy_time_limit then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label, function()
			destroy_time_limit = time
			setDestroyTime()
		end)
	end
end
function setRescueTime()
	clearGMFunctions()
	addGMFunction(_("buttonGM","-From Rescue Time"),mainGMButtons)
	local rescue_times = {15,20,25,30}
	for index, time in ipairs(rescue_times) do
		local button_label = string.format(_("buttonGM","%i minutes"),time)
		if time == rescue_time_limit then
			button_label = button_label .. "*"
		end
		addGMFunction(button_label, function()
			rescue_time_limit = time
			setRescueTime()
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
						out = string.format(_("stationReport-buttonGM","%s\nServices and their costs:"),out)
						for service, cost in pairs(station.comms_data.service_cost) do
							out = string.format("%s\n      %s: %s",out,service,cost)
						end
						if station.comms_data.jump_overcharge then
							out = string.format(_("stationReport-buttonGM","%s\n      jump overcharge: 10"),out)
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
			addGMMessage(_("stationReport-msgGM","No applicable stations. Reports useless. No action taken"))
			mainGMButtons()
		end
	else
		addGMMessage(_("stationReport-msgGM","No applicable stations. Reports useless. No action taken"))
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
			p:setMaxScanProbeCount(playerShipStats[tempTypeName].probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p.tractor = playerShipStats[tempTypeName].tractor
			p.tractor_target_lock = false
			p.mining = playerShipStats[tempTypeName].mining
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
			addGMMessage(string.format(_("msgGM", "Player ship %s's template type (%s) could not be found in table PlayerShipStats"),p:getCallSign(),tempTypeName))
		end
	end
	p.impulse_upgrade = 0
	p.shield_upgrade = 0
	p.tube_speed_upgrade = 0
	if not p:hasJumpDrive() and not p:hasWarpDrive() then
		if random(1,100) <= 50 then
			p:setJumpDrive(true)
			local jump_range = {20,25,30,35}
			p.max_jump_range = jump_range[math.random(1,#jump_range)]*1000
			p.min_jump_range = p.max_jump_range/10
			p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
			p:setJumpDriveCharge(p.max_jump_range)
		else
			p:setWarpDrive(true)
			p:setWarpSpeed(450 + (math.random(1,10)*50))
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
	p:setPosition(player_spawn_x, player_spawn_y)
	--set defaults for those ships not found in the list
	p.shipScore = 24
	p.maxCargo = 5
	p.cargo = p.maxCargo
	p.tractor = false
	p.tractor_target_lock = false
	p.mining = false
	p:setFaction(player_faction)
	updatePlayerSoftTemplate(p)
	player_ship_spawn_count = player_ship_spawn_count + 1
	p:onDestroyed(playerDestroyed)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
	end
end
function playerDestroyed(self,instigator)
	player_ship_death_count = player_ship_death_count + 1
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
				radius = 0
				for i=1,10 do
					radius = radius + random(500,average_station_circle_distance/10 + outer_circle_buffer)
				end
				local o_x, o_y = vectorFromAngleNorth(random(0,360),radius)
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
		"Exuari",
		"Ghosts",
		"TSN",
		"Independent",
		"Human Navy",
		"Arlenians",
		"Ktlitans",
		"CUF",
		"USN",
		"Kraylor",
		"Ghosts",
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
	station_list = {}
	local inner_circle = {}
	player_factions = {"Human Navy","CUF","USN","TSN"}
	player_faction = player_factions[math.random(1,#player_factions)]
	station_regional_hq = placeStation(center_x, center_y,"Pop Sci Fi",player_faction,"Large Station")
	table.insert(station_list,station_regional_hq)
	table.insert(place_space,{obj=station_regional_hq,dist=1000,shape="circle"})
	hq_medical_message = Artifact():setCallSign(station_regional_hq:getCallSign()):setCommsScript(""):setCommsFunction(medicalAttentionComms)
	hq_plague_message = Artifact():setCallSign(station_regional_hq:getCallSign()):setCommsScript(""):setCommsFunction(destroyPlagueComms)
	local defense_platform_angle = random(0,360)
	for i=1,6 do
		local dp_x, dp_y = vectorFromAngle(defense_platform_angle,4000)
		local dp = CpuShip():setTemplate("Defense platform"):setFaction(player_faction):setPosition(center_x + dp_x, center_y + dp_y):setScanState("fullscan"):orderStandGround()
		dp:setCallSign(string.format("%sDP%i%s",faction_letter[player_faction],i,string.char(96+math.random(1,26))))
		table.insert(place_space,{obj=dp,dist=1000,shape="circle"})
		defense_platform_angle = (defense_platform_angle + 60) % 360
	end
	initial_angle = random(0,360)
	player_spawn_x, player_spawn_y = vectorFromAngleNorth(initial_angle,10000 + difficulty*5000)
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	local defense_platforms = {
		["Small Station"] =	{count = 3, dist = 2000},
		["Medium Station"] ={count = 4, dist = 3300},
		["Large Station"] =	{count = 5, dist = 4000},
		["Huge Station"] =	{count = 6, dist = 4500}, 
	}
	circle_stations = {}
	local station_circle_distance_base = 30000
	local total_station_circle_distance = 0
	--create station circle stations
	for i=1,#faction_circle do
		local station_circle_distance = station_circle_distance_base + random(0,40000)
		total_station_circle_distance = total_station_circle_distance + station_circle_distance
		local ps_x, ps_y = vectorFromAngleNorth(initial_angle + (i - 1)*(360/#faction_circle),station_circle_distance)
		local station_size = szt()
		local station = placeStation(center_x + ps_x, center_y + ps_y,nil,faction_circle[i],station_size)
		table.insert(station_list,station)
		table.insert(place_space,{obj=station,dist=station_defend_dist[station_size],shape="circle"})
		table.insert(circle_stations,station)
		local dp_angle = random(0,360)
		for j=1,defense_platforms[station_size].count do
			local dp_x, dp_y = vectorFromAngle(dp_angle,defense_platforms[station_size].dist)
			local dp = CpuShip():setTemplate("Defense platform"):setFaction(faction_circle[i]):setPosition(center_x + ps_x + dp_x, center_y + ps_y + dp_y):orderStandGround()
			dp:setCallSign(string.format("%sDP%i%s",faction_letter[faction_circle[i]],j,string.char(96+math.random(1,26))))
			table.insert(place_space,{obj=dp,dist=1000,shape="circle"})
			dp_angle = (dp_angle + (360/defense_platforms[station_size].count)) % 360
		end
	end
	average_station_circle_distance = total_station_circle_distance / #faction_circle
	local greatest_distance = 0
	local greatest_distance_index = 0
	--create station circle protective warp jammers
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
	}
	for index, station in ipairs(circle_stations) do
		local higher_index = index + 1
		if higher_index > #circle_stations then
			higher_index = 1
		end
		local lower_index = index - 1
		if lower_index < 1 then
			lower_index = #circle_stations
		end
		local higher_distance = distance(station,circle_stations[higher_index])
		if higher_distance >= greatest_distance then
			greatest_distance = higher_distance
			greatest_distance_index = index
		end
		local lower_distance = distance(station,circle_stations[lower_index])
		local jammer_range = (higher_distance / 3 + lower_distance / 3) / 2
		local j_x, j_y = vectorFromAngle(random(0,360),1500)
		local sp_x, sp_y = station:getPosition()
		local warp_jammer = WarpJammer():setPosition(sp_x + j_x, sp_y + j_y):setRange(jammer_range):setFaction(station:getFaction())
		warp_jammer.range = jammer_range
		station.warp_jammer_list = {}
		table.insert(station.warp_jammer_list,warp_jammer)
		warp_jammer_info[station:getFaction()].count = warp_jammer_info[station:getFaction()].count + 1
		warp_jammer:setCallSign(string.format("L%sWJ%i",warp_jammer_info[station:getFaction()].id,warp_jammer_info[station:getFaction()].count))
		table.insert(warp_jammer_list,warp_jammer)
		station.higher_distance = higher_distance
		station.lower_distance = lower_distance
		station.higher_neighbor = circle_stations[higher_index]
		station.lower_neighbor = circle_stations[lower_index]
	end
	local planet_threshold = 30000
	--add planet with orbiting moon in largest gap if it's big enough
	if greatest_distance > planet_threshold then
		local station_a = circle_stations[greatest_distance_index]
		local station_b = circle_stations[greatest_distance_index].higher_neighbor
		local warp_jammer_a = station_a.warp_jammer_list[1]
		local warp_jammer_b = station_b.warp_jammer_list[1]
		local gap_size = distance(warp_jammer_a,warp_jammer_b) - warp_jammer_a.range - warp_jammer_b.range
		local planet_radius = gap_size*.8/2
		local wja_x, wja_y = warp_jammer_a:getPosition()
		local wjb_x, wjb_y = warp_jammer_b:getPosition()
		local planet_barrier = Planet():setPlanetRadius(planet_radius)
		planet_barrier:setPosition((wja_x + wjb_x)/2, (wja_y + wjb_y)/2)
		planet_barrier:setDistanceFromMovementPlane(-planet_radius*.2)
		local planet_list = {
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
		local selected_planet = math.random(1,#planet_list)
		planet_barrier:setCallSign(planet_list[selected_planet].name[math.random(1,#planet_list[selected_planet].name)])
		planet_barrier:setPlanetSurfaceTexture(planet_list[selected_planet].texture.surface)
		if planet_list[selected_planet].texture.atmosphere ~= nil then
			planet_barrier:setPlanetAtmosphereTexture(planet_list[selected_planet].texture.atmosphere)
		end
		if planet_list[selected_planet].texture.cloud ~= nil then
			planet_barrier:setPlanetCloudTexture(planet_list[selected_planet].texture.cloud)
		end
		if planet_list[selected_planet].color ~= nil then
			planet_barrier:setPlanetAtmosphereColor(planet_list[selected_planet].color.red, planet_list[selected_planet].color.green, planet_list[selected_planet].color.blue)
		end
		planet_barrier:setAxialRotationTime(random(350,500))
		table.insert(place_space,{obj=planet_barrier,dist=planet_radius,shape="circle"})
		local moon_list = {
			{
				name = {"Ganymede", "Europa", "Deimos", "Tango", "Gavotte"},
				texture = {
					surface = "planets/moon-1.png"
				}
			},
			{
				name = {"Myopia", "Zapata", "Lichen", "Fandango", "Boogie"},
				texture = {
					surface = "planets/moon-2.png"
				}
			},
			{
				name = {"Scratmat", "Tipple", "Dranken", "Calypso", "Hustle"},
				texture = {
					surface = "planets/moon-3.png"
				}
			},
		}
		local selected_moon = math.random(1,#moon_list)
		local moon_radius = planet_radius*.2
		moon_barrier = Planet():setPlanetRadius(moon_radius)
		moon_barrier.moon_radius = moon_radius
		moon_barrier:setPosition((wja_x + wjb_x)/2, (wja_y + wjb_y)/2 + (gap_size/2)*1.2)
--		moon_barrier:setDistanceFromMovementPlane(-planet_radius*.08*.2)
		moon_barrier:setCallSign(moon_list[selected_moon].name[math.random(1,#moon_list[selected_moon].name)])
		moon_barrier:setPlanetSurfaceTexture(moon_list[selected_moon].texture.surface)
		moon_barrier:setAxialRotationTime(random(500,900))
		moon_barrier:setOrbit(planet_barrier,random(10,40))
		table.insert(place_space,{obj=planet_barrier,inner_orbit = ((gap_size/2) * 1.2) - moon_radius, outer_orbit = ((gap_size/2) * 1.2) + moon_radius, shape="toroid"})
		station_a.barrier = "planet"
	end
	--set barriers between protective warp jammer bubbles
	for index, station in ipairs(circle_stations) do
		if station.barrier == nil then
			local station_b = station.higher_neighbor
			local warp_jammer_a = station.warp_jammer_list[1]
			local warp_jammer_b = station_b.warp_jammer_list[1]
			local gap_size = distance(warp_jammer_a,warp_jammer_b) - warp_jammer_a.range - warp_jammer_b.range
			local wja_x, wja_y = warp_jammer_a:getPosition()
			local wjb_x, wjb_y = warp_jammer_b:getPosition()
			local barrier_center_x = (wja_x + wjb_x)/2
			local barrier_center_y = (wja_y + wjb_y)/2
			local aj_angle = angleFromVectorNorth(wja_x,wja_y,wjb_x,wjb_y)	--barrier to warp jammer a angle
			local bj_angle = angleFromVectorNorth(wjb_x,wjb_y,wja_x,wja_y)	--barrier to warp jammer b angle
			local mine_space = 1200
			local start_point_x, start_point_y = vectorFromAngleNorth(bj_angle,warp_jammer_a.range)
			start_point_x = start_point_x + wja_x
			start_point_y = start_point_y + wja_y
			local line_angle = (bj_angle + 90) % 360
			local m_x, m_y = vectorFromAngleNorth(line_angle,mine_space)
			local start_point_right_x = start_point_x + m_x
			local start_point_right_y = start_point_y + m_y
			line_angle = (bj_angle + 270) % 360
			m_x, m_y = vectorFromAngleNorth(line_angle,mine_space)
			local start_point_left_x = start_point_x + m_x
			local start_point_left_y = start_point_y + m_y
			local finish_point_x, finish_point_y = vectorFromAngleNorth(bj_angle,gap_size)
			local finish_point_left_x = start_point_left_x + finish_point_x
			local finish_point_left_y = start_point_left_y + finish_point_y
			local finish_point_right_x = start_point_right_x + finish_point_x
			local finish_point_right_y = start_point_right_y + finish_point_y
			local barrier_choices = {"Warp Jammer","Mines","Danger Zone","Patrol","Asteroids" }
			if station.higher_distance > 18000 then
				barrier_choices = {"Warp Jammer","Mines","Danger Zone","Patrol","Asteroids", "Black Hole"}
			end
			local barrier_choice = barrier_choices[math.random(1,#barrier_choices)]
--			local barrier_choice = "Asteroids"
			if barrier_choice == "Black Hole" then
				local bh = BlackHole():setPosition(barrier_center_x, barrier_center_y)
				table.insert(place_space,{obj=bh,dist=6000,shape="circle"})
				station.barrier = "black hole"
				local a_to_bh = distance(warp_jammer_a,bh)
				local b_to_bh = distance(warp_jammer_b,bh)
--				print("a to bh:",a_to_bh,"b to bh:",b_to_bh,"a range:",warp_jammer_a.range,"b range:",warp_jammer_b.range)
--				print("a and b:",warp_jammer_a,warp_jammer_b)
--				print(station:getCallSign(),station_b:getCallSign())
				if a_to_bh > warp_jammer_a.range + 5000 and b_to_bh > warp_jammer_b.range + 5000 then
--				   	print("met")
					local aj_x, aj_y = vectorFromAngleNorth(aj_angle,6000)
					local ncj_x = 0
					local ncj_y = 0
					local bhwj = WarpJammer():setPosition(barrier_center_x + aj_x, barrier_center_y + aj_y):setRange(6000):setFaction(station:getFaction())
					bhwj.range = 6000
					table.insert(station.warp_jammer_list,bhwj)
					warp_jammer_info[station:getFaction()].count = warp_jammer_info[station:getFaction()].count + 1
					bhwj:setCallSign(string.format("L%sWJ%i",warp_jammer_info[station:getFaction()].id,warp_jammer_info[station:getFaction()].count))
					table.insert(warp_jammer_list,bhwj)
					if random(1,100) < 30 + difficulty * 20 then
						ncj_x, ncj_y = vectorFromAngleNorth(aj_angle + random(-90,90),random(1000,4000))
						Nebula():setPosition(barrier_center_x + aj_x + ncj_x, barrier_center_y + aj_y + ncj_y)
					end
					aj_x, aj_y = vectorFromAngleNorth((aj_angle + 180) % 360,6000)
					bhwj = WarpJammer():setPosition(barrier_center_x + aj_x, barrier_center_y + aj_y):setRange(6000):setFaction(station_b:getFaction())
					bhwj.range = 6000
					table.insert(station.warp_jammer_list,bhwj)
					warp_jammer_info[station:getFaction()].count = warp_jammer_info[station:getFaction()].count + 1
					bhwj:setCallSign(string.format("L%sWJ%i",warp_jammer_info[station:getFaction()].id,warp_jammer_info[station:getFaction()].count))
					table.insert(warp_jammer_list,bhwj)
					if random(1,100) < 30 + difficulty * 20 then
						ncj_x, ncj_y = vectorFromAngleNorth(aj_angle + 180 + random(-90,90),random(1000,4000))
						Nebula():setPosition(barrier_center_x + aj_x + ncj_x, barrier_center_y + aj_y + ncj_y)
					end
				end
			elseif barrier_choice == "Warp Jammer" then
				local wj = WarpJammer():setPosition(barrier_center_x, barrier_center_y):setFaction(station:getFaction())
				local wj_range = math.min(warp_jammer_a.range,warp_jammer_b.range)
				wj_range = distance(warp_jammer_a,wj) - wj_range
--				print("range:",wj_range)
				wj:setRange(wj_range)
				wj.range = wj_range
				table.insert(station.warp_jammer_list,wj)
				warp_jammer_info[station:getFaction()].count = warp_jammer_info[station:getFaction()].count + 1
				wj:setCallSign(string.format("L%sWJ%i",warp_jammer_info[station:getFaction()].id,warp_jammer_info[station:getFaction()].count))
				table.insert(warp_jammer_list,wj)
				station.barrier = "warp jammer"
			elseif barrier_choice == "Mines" then
				local mine_count = 0
				repeat
					m_x, m_y = vectorFromAngleNorth(bj_angle,mine_count*mine_space)
					local placed_mine_center = Mine():setPosition(start_point_x + m_x, start_point_y + m_y)
					local placed_mine_right = Mine():setPosition(start_point_right_x + m_x, start_point_right_y + m_y)
					local placed_mine_left = Mine():setPosition(start_point_left_x + m_x, start_point_left_y + m_y)
					table.insert(place_space,{obj=placed_mine_center,dist=800,shape="circle"})
					table.insert(place_space,{obj=placed_mine_right,dist=800,shape="circle"})
					table.insert(place_space,{obj=placed_mine_left,dist=800,shape="circle"})
					mine_count = mine_count + 1
				until(distance(placed_mine_center,warp_jammer_b) < warp_jammer_b.range or mine_count > 20)
				if random(1,100) < 30 + difficulty * 20 then
					local mwj_x, mwj_y = vectorFromAngleNorth(aj_angle + 270,warp_jammer_a.range)
					if random(1,50) < 50 then
						mwj_x, mwj_y = vectorFromAngleNorth(aj_angle + 90,warp_jammer_a.range)
					end
					local mwj = WarpJammer():setPosition(barrier_center_x + mwj_x, barrier_center_y + mwj_y):setRange(warp_jammer_a.range + 1200):setFaction(station:getFaction())
					warp_jammer_info[station:getFaction()].count = warp_jammer_info[station:getFaction()].count + 1
					mwj:setCallSign(string.format("%sWJ%i",warp_jammer_info[station:getFaction()].id,warp_jammer_info[station:getFaction()].count))
					table.insert(warp_jammer_list,mwj)
					local nd_angle = random(0,360)
					local bn_x, bn_y = vectorFromAngle(nd_angle,random(1000,4000))
					Nebula():setPosition(barrier_center_x + mwj_x + bn_x, barrier_center_y + mwj_y + bn_y)
					if random(1,100) < 50 then
						nd_angle = nd_angle + random(-60,60)
						bn_x, bn_y = vectorFromAngle(nd_angle,random(2000,4500))
						Nebula():setPosition(barrier_center_x + mwj_x + bn_x, barrier_center_y + mwj_y + bn_y)
						if random(1,100) < 50 then
							nd_angle = nd_angle + random(-60,60)
							bn_x, bn_y = vectorFromAngle(nd_angle,random(2000,4500))
							Nebula():setPosition(barrier_center_x + mwj_x + bn_x, barrier_center_y + mwj_y + bn_y)
						end
					end
				end
				station.barrier = "mines"
			elseif barrier_choice == "Danger Zone" then
				if danger_zones == nil then
					danger_zones = {}
				end
				local dz = Zone():setPoints(
					start_point_right_x,	start_point_right_y,
					start_point_left_x,		start_point_left_y,
					finish_point_left_x,	finish_point_left_y,
					finish_point_right_x,	finish_point_right_y
				)
				table.insert(danger_zones,dz)
				station.barrier = "danger zone"
			elseif barrier_choice == "Patrol" then
				if barrier_patrols == nil then
					barrier_patrols = {}
				end
				local ship = CpuShip():setTemplate("Phobos T3"):setPosition(start_point_right_x,start_point_right_y):setFaction(station:getFaction())
				ship:setCallSign(generateCallSign(nil,station:getFaction()))
				ship:orderFlyTowards(start_point_right_x,start_point_right_y)
				ship.patrol_points = {
					{x = start_point_right_x,	y = start_point_right_y},
					{x = finish_point_left_x,	y = finish_point_left_y},
				}
				ship.patrol_base_station = station
				ship.patrol_point_index = 1
				ship.patrol_check_timer_interval = 5
				ship.patrol_check_timer = ship.patrol_check_timer_interval
				ship:onDestruction(refreshBarrierPatrol)
				table.insert(barrier_patrols,ship)
				ship = CpuShip():setTemplate("Phobos T3"):setPosition(finish_point_right_x,finish_point_right_y):setFaction(station_b:getFaction())
				ship:setCallSign(generateCallSign(nil,station_b:getFaction()))
				ship:orderFlyTowards(finish_point_right_x,finish_point_right_y)
				ship.patrol_points = {
					{x = finish_point_right_x,	y = finish_point_right_y},
					{x = start_point_left_x, 	y = start_point_left_y},
				}
				ship.patrol_base_station = station_b
				ship.patrol_point_index = 1
				ship.patrol_check_timer_interval = 5
				ship.patrol_check_timer = ship.patrol_check_timer_interval
				table.insert(barrier_patrols,ship)
				station.barrier = "patrol"
			elseif barrier_choice == "Asteroids" then
				local asteroid_count = math.floor((gap_size * 3600 / (250 * 250))/random(9,17))
				for i=1,asteroid_count do
					local lax_x, lax_y = vectorFromAngleNorth(bj_angle,random(0,gap_size))
					local sax_x, sax_y = vectorFromAngleNorth(bj_angle + 90,random(0,3600))
					local ba = Asteroid():setPosition(start_point_left_x + lax_x + sax_x, start_point_left_y + lax_y + sax_y)
					local size = 0
					for j=1,5 do
						size = size + random(4,100)
					end
					ba:setSize(size)
					table.insert(place_space,{obj=ba,dist=size*.1,shape="circle"})
				end
				if random(1,100) < 30 + difficulty * 20 then
					local mwj_x, mwj_y = vectorFromAngleNorth(aj_angle + 270,warp_jammer_a.range)
					if random(1,50) < 50 then
						mwj_x, mwj_y = vectorFromAngleNorth(aj_angle + 90,warp_jammer_a.range)
					end
					local mwj = WarpJammer():setPosition(barrier_center_x + mwj_x, barrier_center_y + mwj_y):setRange(warp_jammer_a.range + 1200):setFaction(station:getFaction())
					warp_jammer_info[station:getFaction()].count = warp_jammer_info[station:getFaction()].count + 1
					mwj:setCallSign(string.format("%sWJ%i",warp_jammer_info[station:getFaction()].id,warp_jammer_info[station:getFaction()].count))
					table.insert(warp_jammer_list,mwj)
					local nd_angle = random(0,360)
					local bn_x, bn_y = vectorFromAngle(nd_angle,random(1000,4000))
					Nebula():setPosition(barrier_center_x + mwj_x + bn_x, barrier_center_y + mwj_y + bn_y)
					if random(1,100) < 50 then
						nd_angle = nd_angle + random(-60,60)
						bn_x, bn_y = vectorFromAngle(nd_angle,random(2000,4500))
						Nebula():setPosition(barrier_center_x + mwj_x + bn_x, barrier_center_y + mwj_y + bn_y)
						if random(1,100) < 50 then
							nd_angle = nd_angle + random(-60,60)
							bn_x, bn_y = vectorFromAngle(nd_angle,random(2000,4500))
							Nebula():setPosition(barrier_center_x + mwj_x + bn_x, barrier_center_y + mwj_y + bn_y)
						end
					end
				end
				station.barrier = "asteroids"
			end
		end
	end
	--	set up for protect the freighter plot
	local t_x, t_y = vectorFromAngleNorth(initial_angle, 6000 + difficulty*5000)
	critical_transport = randomTransportType()
	critical_transport:setPosition(center_x + t_x, center_y + t_y)
	critical_transport:setCallSign(generateCallSign(nil,player_faction))
	critical_transport:setFaction("Independent")
	critical_transport:orderDock(station_regional_hq)
	critical_transport:setFaction(player_faction):setCommsScript(""):setCommsFunction(commsShip)
	table.insert(place_space,{obj=critical_transport,dist=600,shape="circle"})
	primary_orders = string.format(_("orders-comms","Protect freighter %s until they dock at %s"),critical_transport:getCallSign(),station_regional_hq:getCallSign())
	--	freighter attackers
	local attack_angle = initial_angle + 180
	local l1_x, l1_y = vectorFromAngleNorth(initial_angle, 25000)
	local leader_1 = CpuShip():setTemplate("Adder MK5"):setPosition(center_x + l1_x, center_y + l1_y):setFaction("Exuari"):setHeading(attack_angle)
	leader_1:setCallSign(generateCallSign(nil,"Exuari"))
	table.insert(place_space,{obj=leader_1,dist=200,shape="circle"})
	local l2_x, l2_y = vectorFromAngleNorth(initial_angle + 90, 5000)
	local leader_2 = CpuShip():setTemplate("Adder MK5"):setPosition(center_x + l1_x + l2_x, center_y + l1_y + l2_y):setFaction("Exuari"):setHeading(attack_angle)
	leader_2:setCallSign(generateCallSign(nil,"Exuari"))
	table.insert(place_space,{obj=leader_2,dist=200,shape="circle"})
	local l3_x, l3_y = vectorFromAngleNorth(initial_angle + 270, 5000)
	local leader_3 = CpuShip():setTemplate("Adder MK5"):setPosition(center_x + l1_x + l3_x, center_y + l1_y + l3_y):setFaction("Exuari"):setHeading(attack_angle)
	leader_3:setCallSign(generateCallSign(nil,"Exuari"))
	table.insert(place_space,{obj=leader_3,dist=200,shape="circle"})
	local form_choice = {
		[.5] = 	"V",
		[1] =	"V4",
		[2] =	"W6",
	}
	local template = "MT52 Hornet"
	local formation_spacing = 1000
	local selected_faction = "Exuari"
	local lx = {center_x + l1_x, center_x + l1_x + l2_x, center_x + l1_x + l3_x}
	local ly = {center_y + l1_y, center_y + l1_y + l2_y, center_y + l1_y + l3_y}
	local leader = {leader_1, leader_2, leader_3}
	for i=1,3 do
		for _, form in ipairs(fly_formation[form_choice[difficulty]]) do
			local ship = ship_template[template].create(selected_faction,template)
			local form_x, form_y = vectorFromAngleNorth(attack_angle + form.angle, form.dist * formation_spacing)
			local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
			ship:setFaction("Independent")
			ship:setPosition(lx[i] + form_x, ly[i] + form_y):setHeading(attack_angle):orderFlyFormation(leader[i],form_prime_x,form_prime_y)
			ship:setFaction(selected_faction)
			ship:setCallSign(generateCallSign(nil,selected_faction))
			ship.home_station = circle_stations[1]
			ship.home_station_name = circle_stations[1]:getCallSign()
			ship:setCommsScript(""):setCommsFunction(commsShip)
			table.insert(place_space,{obj=ship,dist=200,shape="circle"})
		end
	end
	local ship = tableRemoveRandom(leader)
	ship:orderFlyTowards(center_x, center_y)
	ship = tableRemoveRandom(leader)
	ship:orderAttack(critical_transport)
	leader[1]:orderRoaming()
	mainLinearPlot = freighterMessage
	transport_list = {}
	transport_stations = {}
	--fill in roughly circular area with semi-random terrain
	local black_hole_chance = 1
	black_hole_count = math.random(1,6)
	local star_chance = 3
	star_count = math.random(1,2)
	local probe_chance = 6
	local warp_jammer_chance = 3
	local worm_hole_chance = 2
	worm_hole_count = math.random(1,4)
	local sensor_jammer_chance = 6
	local sensor_buoy_chance = 6
	local ad_buoy_chance = 8
	local nebula_chance = 5
	local mine_chance = 4
	local station_chance = 3
	local mine_field_chance = 4
	mine_field_count = math.random(3,8)
	local asteroid_field_chance = 4
	asteroid_field_count = math.random(2,6)
	local transport_chance = 5
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
		current_object_chance = current_object_chance + probe_chance
		if object_roll <= current_object_chance then
			placeProbe()
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
		current_object_chance = current_object_chance + station_chance
		if object_roll <= current_object_chance then
			placeEnvironmentStation()
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
			placeTransport()
			goto iterate
		end
		placeAsteroid()
		::iterate::
	until(#transport_list >= #circle_stations or far_enough_fail)
	far_enough_fail = false
	--create an axis off the circle for a medical research station
	research_axis = random(0,360)
	local research_axis_stations = {}
	transport_chance = 3
	station_chance = 5
	repeat
		local current_object_chance = 0
		local object_roll = random(0,100)
		current_object_chance = current_object_chance + black_hole_chance
		if object_roll <= current_object_chance then
			placeBlackHole(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + star_chance
		if object_roll <= current_object_chance then
			placeStar(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + probe_chance
		if object_roll <= current_object_chance then
			placeProbe(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + warp_jammer_chance
		if object_roll <= current_object_chance then
			placeWarpJammer(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + worm_hole_chance
		if object_roll <= current_object_chance then
			placeWormHole(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + sensor_jammer_chance
		if object_roll <= current_object_chance then
			placeSensorJammer(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + sensor_buoy_chance
		if object_roll <= current_object_chance then
			placeSensorBuoy(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + ad_buoy_chance
		if object_roll <= current_object_chance then
			placeAdBuoy(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + nebula_chance
		if object_roll <= current_object_chance then
			placeNebula(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + mine_chance
		if object_roll <= current_object_chance then
			placeMine(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + station_chance
		if object_roll <= current_object_chance then
			local placed_station = placeEnvironmentStation(research_axis)
			if placed_station ~= nil then
				table.insert(research_axis_stations,placed_station)
			end
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + mine_field_chance
		if object_roll <= current_object_chance then
			placeMineField(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + asteroid_field_chance
		if object_roll <= current_object_chance then
			placeAsteroidField(research_axis)
			goto iterate_research_axis
		end
		current_object_chance = current_object_chance + transport_chance
		if object_roll <= current_object_chance then
			placeTransport(research_axis)
			goto iterate_research_axis
		end
		placeAsteroid()
		::iterate_research_axis::
	until(#research_axis_stations >= 5 or far_enough_fail)
	if far_enough_fail then
		if #research_axis_stations > 0 then
			local independent_found = false
			for index, station in ipairs(research_axis_stations) do
				if station:getFaction() == "Independent" then
					independent_found = true
					station_medical_research = station
					break
				end
			end
			if not independent_found then
				local tpa = Artifact():setFaction(player_faction)
				local neutral_friendly_found = false
				for index, station in ipairs(research_axis_stations) do
					if not station:isEnemy(tpa) then
						neutral_friendly_found = true
						station_medical_research = station
						station:setFaction("Independent")
						for _, ship in ipairs(station.defense_fleet) do
							ship:setFaction("Independent")
						end
						break
					end
				end
				tpa:destroy()
				if not neutral_friendly_found then
					local bd_x, bd_y = vectorFromAngleNorth(research_axis,average_station_circle_distance + 80000)
					local station = placeStation(center_x + bd_x, center_y + bd_y, "RandomHumanNeutral", "Independent")
					table.insert(station_list,station)
					--defense fleet
					local fleet = spawnEnemies(center_x + bd_x, center_y + bd_y, 1, "Independent", 45)
					for _, ship in ipairs(fleet) do
						ship:orderDefendTarget(station)
						ship:setCallSign(generateCallSign(nil,"Independent"))
					end
					station.defense_fleet = fleet
					table.insert(station_list,station)
					station_medical_research = station
				end
			end
		else
			local bd_x, bd_y = vectorFromAngleNorth(research_axis,average_station_circle_distance + 80000)
			local station = placeStation(center_x + bd_x, center_y + bd_y, "RandomHumanNeutral", "Independent")
			table.insert(station_list,station)
			--defense fleet
			local fleet = spawnEnemies(center_x + bd_x, center_y + bd_y, 1, "Independent", 45)
			for _, ship in ipairs(fleet) do
				ship:orderDefendTarget(station)
				ship:setCallSign(generateCallSign(nil,"Independent"))
			end
			station.defense_fleet = fleet
			table.insert(station_list,station)
			station_medical_research = station
		end
	else
		local independent_found = false
		for index, station in ipairs(research_axis_stations) do
			if station:getFaction() == "Independent" then
				independent_found = true
				station_medical_research = station
				break
			end
		end
		if not independent_found then
			local tpa = Artifact():setFaction(player_faction)
			local neutral_friendly_found = false
			for index, station in ipairs(research_axis_stations) do
				if not station:isEnemy(tpa) then
					neutral_friendly_found = true
					station_medical_research = station
					station:setFaction("Independent")
					for _, ship in ipairs(station.defense_fleet) do
						ship:setFaction("Independent")
					end
					break
				end
			end
			tpa:destroy()
			if not neutral_friendly_found then
				local bd_x, bd_y = vectorFromAngleNorth(research_axis,average_station_circle_distance + 80000)
				local station = placeStation(center_x + bd_x, center_y + bd_y, "RandomHumanNeutral", "Independent")
				table.insert(station_list,station)
				--defense fleet
				local fleet = spawnEnemies(center_x + bd_x, center_y + bd_y, 1, "Independent", 45)
				for _, ship in ipairs(fleet) do
					ship:orderDefendTarget(station)
					ship:setCallSign(generateCallSign(nil,"Independent"))
				end
				station.defense_fleet = fleet
				table.insert(station_list,station)
				station_medical_research = station
			end
		end
	end
	medical_station_query_message = Artifact():setCallSign(station_medical_research:getCallSign()):setCommsScript(""):setCommsFunction(medicalBaseLocationAssistanceComms)
	far_enough_fail = false
	plague_axis = (research_axis + random(120,240)) % 360
	local plague_axis_stations = {}
	repeat
		local current_object_chance = 0
		local object_roll = random(0,100)
		current_object_chance = current_object_chance + black_hole_chance
		if object_roll <= current_object_chance then
			placeBlackHole(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + star_chance
		if object_roll <= current_object_chance then
			placeStar(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + probe_chance
		if object_roll <= current_object_chance then
			placeProbe(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + warp_jammer_chance
		if object_roll <= current_object_chance then
			placeWarpJammer(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + worm_hole_chance
		if object_roll <= current_object_chance then
			placeWormHole(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + sensor_jammer_chance
		if object_roll <= current_object_chance then
			placeSensorJammer(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + sensor_buoy_chance
		if object_roll <= current_object_chance then
			placeSensorBuoy(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + ad_buoy_chance
		if object_roll <= current_object_chance then
			placeAdBuoy(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + nebula_chance
		if object_roll <= current_object_chance then
			placeNebula(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + mine_chance
		if object_roll <= current_object_chance then
			placeMine(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + station_chance
		if object_roll <= current_object_chance then
			local placed_station = placeEnvironmentStation(plague_axis)
			if placed_station ~= nil then
				placed_station:setFaction("Exuari")
				for _, ship in ipairs(placed_station.defense_fleet) do
					ship:setFaction("Exuari")
				end
				table.insert(plague_axis_stations,placed_station)
			end
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + mine_field_chance
		if object_roll <= current_object_chance then
			placeMineField(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + asteroid_field_chance
		if object_roll <= current_object_chance then
			placeAsteroidField(plague_axis)
			goto iterate_plague_axis
		end
		current_object_chance = current_object_chance + transport_chance
		if object_roll <= current_object_chance then
			placeTransport(plague_axis)
			goto iterate_plague_axis
		end
		placeAsteroid()
		::iterate_plague_axis::
	until(#plague_axis_stations >= 5 or far_enough_fail)
	if far_enough_fail then
		if #plague_axis_stations > 0 then
			station_plague = plague_axis_stations[math.random(1,#plague_axis_stations)]
		else
			local bd_x, bd_y = vectorFromAngleNorth(plague_axis,average_station_circle_distance + 80000)
			local station = placeStation(center_x + bd_x, center_y + bd_y, "Sinister", "Exuari")
			table.insert(station_list,station)
			--defense fleet
			local fleet = spawnEnemies(center_x + bd_x, center_y + bd_y, 1, "Exuari", 65)
			for _, ship in ipairs(fleet) do
				ship:orderDefendTarget(station)
				ship:setCallSign(generateCallSign(nil,"Exuari"))
			end
			station.defense_fleet = fleet
			table.insert(station_list,station)
			station_plague = station
		end
	else
		station_plague = plague_axis_stations[math.random(1,#plague_axis_stations)]
	end
	maintenancePlot = defenseMaintenance
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
			warp_jammer_range = warp_jammer_range + random(1000,4000)
		end
		wj:setRange(warp_jammer_range):setFaction(selected_faction)
		warp_jammer_info[selected_faction].count = warp_jammer_info[selected_faction].count + 1
		wj:setCallSign(string.format("%sWJ%i",warp_jammer_info[selected_faction].id,warp_jammer_info[selected_faction].count))
		wj.range = warp_jammer_range
		table.insert(warp_jammer_list,wj)
		table.insert(place_space,{obj=wj,dist=200,shape="circle"})
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
			_("scienceDescription-buoy","Find a companion. All species available"),
			_("scienceDescription-buoy","Feeling down? Robotherapist is there for you"),
			_("scienceDescription-buoy","30 days, 30 kilograms, guaranteed"),
			_("scienceDescription-buoy","Try our asteroid dust diet weight loss program"),
			_("scienceDescription-buoy","Best tasting water in the quadrant"),
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
function placeEnvironmentStation(axis)
	local station_defend_dist = {
		["Small Station"] = 2800,	--2620
		["Medium Station"] = 4200,	--4000
		["Large Station"] = 4800,	--4590
		["Huge Station"] = 5200,	--4985
	}
	local s_size = szt()
	local eo_x, eo_y = environmentObject(center_x, center_y, station_defend_dist[s_size], axis)
	if eo_x ~= nil then
		--check station distance to other stations
		local spaced_station = true
		local closest_station_distance = 999999
		local closest_station = nil
		for _, station in ipairs(station_list) do
			local current_distance = distance(station, eo_x, eo_y)
			if current_distance < closest_station_distance then
				closest_station_distance = current_distance
				closest_station = station
			end
			if current_distance < 16000 then
				spaced_station = false
				break
			end
		end
		if not spaced_station then
			placeAsteroid()
			return
		end
		for index, station in ipairs(circle_stations) do
			if closest_station:getFaction() == station:getFaction() then
				match_index = index
				break
			end
		end
		local hi_neighbor = match_index + 1
		if hi_neighbor > #circle_stations then
			hi_neighbor = 1
		end
		local lo_neighbor = match_index - 1
		if lo_neighbor < 1 then
			lo_neighbor = #circle_stations
		end
		local faction_choices = {
			circle_stations[match_index]:getFaction(),
			circle_stations[hi_neighbor]:getFaction(),
			circle_stations[lo_neighbor]:getFaction(),		
		}
		local selected_faction = faction_choices[math.random(1,3)]
		local name_group = "RandomHumanNeutral"
		local tsa = Artifact():setFaction(selected_faction)
		local tpa = Artifact():setFaction(player_faction)
		if tsa:isEnemy(tpa) then
			name_group = "Sinister"
		end
		tsa:destroy()
		tpa:destroy()
	local station = placeStation(eo_x, eo_y, name_group, selected_faction, s_size)
	if station ~= nil then
		table.insert(place_space,{obj=station,dist=station_defend_dist[s_size],shape="circle"})
		table.insert(station_list,station)
		--defense fleet
		local fleet = spawnEnemies(eo_x, eo_y, 1, selected_faction, 35)
		for _, ship in ipairs(fleet) do
			ship:setFaction("Independent")
			ship:orderDefendTarget(station)
			ship:setFaction(selected_faction)
			ship:setCallSign(generateCallSign(nil,selected_faction))
		end
		station.defense_fleet = fleet
	end
	return station
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
		local faction_list = {"Human Navy","Independent","Kraylor","Arlenians","Exuari","Ghosts","Ktlitans","TSN","USN","CUF"}
		ship:setPosition(eo_x, eo_y):setFaction(faction_list[math.random(1,#faction_list)])
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
---------------------------------------
--	Support for constant plot lines  --
---------------------------------------
function refreshBarrierPatrol(self,instigator)
	if self.patrol_base_station ~= nil and self.patrol_base_station:isValid() then
		local bs_x, bs_y = self.patrol_base_station:getPosition()
		local ship = spawnSingleEnemy(bs_x, bs_y, 1, self.patrol_base_station:getFaction())
		ship.patrol_points = self.patrol_points
		ship:orderFlyTowards(ship.patrol_points[1].x,ship.patrol_points[1].y)
		ship.patrol_base_station = self.patrol_base_station
		ship.patrol_point_index = 1
		ship.patrol_check_timer_interval = 5
		ship.patrol_check_timer = ship.patrol_check_timer_interval
		ship:onDestruction(refreshBarrierPatrol)
		table.insert(barrier_patrols,ship)
	end
end
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
	maintenancePlot = patrolMaintenance
end
function patrolMaintenance(delta)
	maintenancePlot = expeditionMaintenance
end
function expeditionMaintenance(delta)
	if #station_list > 0 then
		local fleet_count = 0
		local deleted_station = false
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				if station.expedition_fleet ~= nil and #station.expedition_fleet > 0 then
					fleet_count = fleet_count + 1
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				deleted_station = true
				break
			end
		end
		if not deleted_station then
			if fleet_count < expedition_count then
				if #station_list > expedition_count then
					local avail_station = {}
					for _, station in ipairs(station_list) do
						if station.expedition_fleet == nil or #station.expedition_fleet < 1 then
							table.insert(avail_station,station)
						end
					end
					local station = avail_station[math.random(1,#avail_station)]
					local selected_faction = station:getFaction()
					local expedition_templates = {"Phobos T3","Karnack","Cruiser","Gunship","Adv. Gunship","Phobos R2","Farco 3","Farco 5","Farco 8","Farco 11","Farco 13","Phobos T4"}
					local template = expedition_templates[math.random(1,#expedition_templates)]
					local pf_x, pf_y = station:getPosition()
					local expedition_angle = angleFromVectorNorth(center_x, center_y, pf_x, pf_y)
					local pd_x, pd_y = vectorFromAngleNorth(expedition_angle,2000)
					pd_x = pd_x + pf_x
					pd_y = pd_y + pf_y
					if expedition_maintenance_diagnostic then print("expedition template:",template,"faction:",selected_faction) end
					local leader_ship = ship_template[template].create(selected_faction,template)
					leader_ship:setPosition(pd_x, pd_y)
					leader_ship:setHeading(expedition_angle)
					leader_ship:setCallSign(generateCallSign(nil,leader_ship:getFaction()))
					leader_ship:orderRoaming()
					local formation_spacing = 800
					station.expedition_fleet = {}
					leader_ship.home_station = station
					leader_ship.home_station_name = station:getCallSign()
					leader_ship:setCommsScript(""):setCommsFunction(commsShip)
					table.insert(station.expedition_fleet,leader_ship)
					local expedition_follower_templates = {"MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"}
					template =  expedition_follower_templates[math.random(1,#expedition_follower_templates)]
					local formation_list = {"Vac","V","V4","A","-","X"}
					local selected_formation = formation_list[math.random(1,#formation_list)]
					for _, form in ipairs(fly_formation[selected_formation]) do
						local ship = ship_template[template].create(selected_faction,template)
						local form_x, form_y = vectorFromAngleNorth(expedition_angle + form.angle, form.dist * formation_spacing)
						local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
						ship:setFaction("Independent")
						ship:setPosition(pd_x + form_x, pd_y + form_y):setHeading(expedition_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
						ship:setFaction(selected_faction)
						ship:setCallSign(generateCallSign(nil,ship:getFaction()))
--						ship:setAcceleration(ship:getAcceleration()*1.1)
--						ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*1.1)
						ship.home_station = station
						ship.home_station_name = station:getCallSign()
						ship:setCommsScript(""):setCommsFunction(commsShip)
						table.insert(station.expedition_fleet,ship)
					end
				end
			else
				for station_index, station in ipairs(station_list) do
					fleet_count = 0
					local deleted_ship = false
					if station.expedition_fleet ~= nil and #station.expedition_fleet > 0 then
						for fleet_index, ship in ipairs(station.expedition_fleet) do
							if ship ~= nil and ship:isValid() then
								fleet_count = fleet_count + 1
							else
								station.expedition_fleet[fleet_index] = station.expedition_fleet[#station.expedition_fleet]
								station.expedition_fleet[#station.expedition_fleet] = nil
								deleted_ship = true
								break
							end
						end
					end
					if not deleted_ship then
						if fleet_count < 1 then
							station.expedition_fleet = nil
						end
					end
				end
			end
		end
	end
	maintenancePlot = taskMaintenance
end
function taskMaintenance(delta)
	if #station_list > 0 then
		local fleet_count = 0
		local deleted_station = false
		for station_index, station in ipairs(station_list) do
			if station ~= nil and station:isValid() then
				if station.task_fleet ~= nil and #station.task_fleet > 0 then
					fleet_count = fleet_count + 1
				end
			else
				station_list[station_index] = station_list[#station_list]
				station_list[#station_list] = nil
				deleted_station = true
				break
			end
		end
		if not deleted_station then
			if fleet_count < task_force_count then
				if #station_list > task_force_count then
					local avail_station = {}
					for _, station in ipairs(station_list) do
						if station.task_fleet == nil or #station.task_fleet < 1 then
							for tsi, station_target in ipairs(station_list) do
								if station:isEnemy(station_target) then
									table.insert(avail_station,station)
								end
							end
						end
					end
					if #avail_station > 0 then
						local station = avail_station[math.random(1,#avail_station)]
						local selected_faction = station:getFaction()
						local task_templates = {"Phobos T3","Karnack","Cruiser","Gunship","Adv. Gunship","Phobos R2","Farco 3","Farco 5","Farco 8","Farco 11","Farco 13","Phobos T4"}
						local template = task_templates[math.random(1,#task_templates)]
						local pf_x, pf_y = station:getPosition()
						local target_station_list = {}
						for _, target_station in ipairs(station_list) do
							if station:isEnemy(target_station) then
								table.insert(target_station_list,target_station)
							end
						end
						local target_station = target_station_list[math.random(1,#target_station_list)]
						local ts_x, ts_y = target_station:getPosition()
						local task_angle = angleFromVectorNorth(ts_x, ts_y, pf_x, pf_y)
						local pd_x, pd_y = vectorFromAngleNorth(task_angle,2000)
						pd_x = pd_x + pf_x
						pd_y = pd_y + pf_y
						if task_maintenance_diagnostic then print("task template:",template,"faction:",selected_faction) end
						local leader_ship = ship_template[template].create(selected_faction,template)
						leader_ship:setPosition(pd_x, pd_y)
						leader_ship:setHeading(task_angle)
						leader_ship:setCallSign(generateCallSign(nil,leader_ship:getFaction()))
						leader_ship:orderAttack(target_station)
						local formation_spacing = 800
						station.task_fleet = {}
						table.insert(station.task_fleet,leader_ship)
						local expedition_follower_templates = {"MT52 Hornet","MU52 Hornet","Fighter","Ktlitan Fighter","K2 Fighter","K3 Fighter","Ktlitan Scout","Cucaracha"}
						template =  expedition_follower_templates[math.random(1,#expedition_follower_templates)]
						local formation_list = {"Vac","V","V4","A","-","X"}
						local selected_formation = formation_list[math.random(1,#formation_list)]
						for _, form in ipairs(fly_formation[selected_formation]) do
							local ship = ship_template[template].create(selected_faction,template)
							local form_x, form_y = vectorFromAngleNorth(task_angle + form.angle, form.dist * formation_spacing)
							local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist * formation_spacing)
							ship:setFaction("Independent")
							ship:setPosition(pd_x + form_x, pd_y + form_y):setHeading(task_angle):orderFlyFormation(leader_ship,form_prime_x,form_prime_y)
							ship:setFaction(selected_faction)
							ship:setCallSign(generateCallSign(nil,ship:getFaction()))
--							ship:setAcceleration(ship:getAcceleration()*1.1)
--							ship:setImpulseMaxSpeed(ship:getImpulseMaxSpeed()*1.1)
							table.insert(station.task_fleet,ship)
						end
					end
				end
			else
				for station_index, station in ipairs(station_list) do
					fleet_count = 0
					local deleted_ship = false
					if station.task_fleet ~= nil and #station.task_fleet > 0 then
						for fleet_index, ship in ipairs(station.task_fleet) do
							if ship ~= nil and ship:isValid() then
								fleet_count = fleet_count + 1
							else
								station.task_fleet[fleet_index] = station.task_fleet[#station.task_fleet]
								station.task_fleet[#station.task_fleet] = nil
								deleted_ship = true
								break
							end
						end
					end
					if not deleted_ship then
						if fleet_count < 1 then
							station.task_fleet = nil
						end
					end
				end
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
function updatePlayerUpgradeMission(p)
	if p.impulse_upgrade == 1 then
		if p.goods ~= nil then
			for good, good_quantity in pairs(p.goods) do
				if good == p.impulse_upgrade_part and good_quantity > 0 then
					p:setImpulseMaxSpeed(85)	--faster vs base 70 and upgraded 75
					good_quantity = good_quantity - 1
					p.impulse_upgrade = 2
					local final_impulse_upgrade_msg = string.format(_("msgEngineer","With the %s just acquired, you improve your impulse engine top speed by 13%%"),good)
					p.final_impulse_upgrade_msg_eng = "final_impulse_upgrade_msg_eng"
					p.final_impulse_upgrade_msg_plus = "final_impulse_upgrade_msg_plus"
					p:addCustomMessage("Engineering",p.final_impulse_upgrade_msg_eng,final_impulse_upgrade_msg)
					p:addCustomMessage("Engineering+",p.final_impulse_upgrade_msg_plus,final_impulse_upgrade_msg)
				end
			end
		end
	end
	if p.shield_upgrade == 1 then
		if p.goods ~= nil then
			for good, good_quantity in pairs(p.goods) do
				if good == p.shield_upgrade_part and good_quantity > 0 then
					p:setShieldsMax(100,100)	--stronger vs base 80,80 and upgraded 90,90
					good_quantity = good_quantity - 1
					p.shield_upgrade = 2
					local final_shield_upgrade_msg = string.format(_("msgEngineer","With the %s just acquired, you improve your shield charge capacity top speed by 11%%"),good)
					p.final_shield_upgrade_msg_eng = "final_shield_upgrade_msg_eng"
					p.final_shield_upgrade_msg_plus = "final_shield_upgrade_msg_plus"
					p:addCustomMessage("Engineering",p.final_shield_upgrade_msg_eng,final_shield_upgrade_msg)
					p:addCustomMessage("Engineering+",p.final_shield_upgrade_msg_plus,final_shield_upgrade_msg)
				end
			end
		end
	end
	if p.tube_speed_upgrade == 1 then
		if p.goods ~= nil then
			for good, good_quantity in pairs(p.goods) do
				if good == p.tube_speed_upgrade_part and good_quantity > 0 then
					p:setTubeLoadTime(0,10)		--faster vs base 20 and upgraded 15
					p:setTubeLoadTime(1,10)		--faster vs base 20 and upgraded 15
					good_quantity = good_quantity - 1
					p.tube_speed_upgrade = 2
					local final_tube_speed_upgrade_msg = string.format(_("msgEngineer","With the %s just acquired, you improve your weapon tube load time by 33%%"),good)
					p.final_tube_speed_upgrade_msg_eng = "final_tube_speed_upgrade_msg_eng"
					p.final_tube_speed_upgrade_msg_plus = "final_tube_speed_upgrade_msg_plus"
					p:addCustomMessage("Engineering",p.final_tube_speed_upgrade_msg_eng,final_tube_speed_upgrade_msg)
					p:addCustomMessage("Engineering+",p.final_tube_speed_upgrade_msg_plus,final_tube_speed_upgrade_msg)
				end
			end
		end
	end
end
function updatePlayerDangerZone(p)
	if danger_zones ~= nil then
		for index, zone in ipairs(danger_zones) do
			if zone:isInside(p) then
				if p.danger_zone == nil then
					p.danger_zone = {}
				end
				if p.danger_zone[zone] == nil then
					p.danger_zone[zone] = 0
				end
				p.danger_zone[zone] = p.danger_zone[zone] + 1
				if p.danger_zone[zone] > 3 then
					p.danger_zone["verified"] = true
					local hit_list = {}
					if p:hasSystem("beamweapons") then
						table.insert(hit_list,"beamweapons")
					end
					if p:hasSystem("missilesystem") then
						table.insert(hit_list,"missilesystem")
					end
					if p:hasSystem("frontshield") then
						table.insert(hit_list,"frontshield")
					end
					if p:hasSystem("rearshield") then
						table.insert(hit_list,"rearshield")
					end
					local hit_system = hit_list[math.random(1,#hit_list)]
					if zone.player_message_list == nil then
						zone.player_message_list = {}
					end
					local long_system = {
						["beamweapons"] =	_("msgScience","beam weapons"),
						["missilesystem"] =	_("msgScience","missile weapons system"),
						["frontshield"] =	_("msgScience","front shield"),
						["rearshield"] =	_("msgScience","rear shield"),
					}
					if zone.player_message_list[p] == nil then
						local hit_msg = string.format(_("msgScience","Sensors just picked up an energy field. The ship must have triggered it. It seems to impact our %s and possibly other ship systems. The ship computers have plotted it on Science and Relay."),long_system[hit_system])
						p.hit_msg_science = "hit_msg_science"
						p:addCustomMessage("Science",p.hit_msg_science,hit_msg)
						p.hit_msg_ops = "hit_msg_ops"
						p:addCustomMessage("Operations",p.hit_msg_ops,hit_msg)
						zone.player_message_list[p] = "sent"
					end
					if p:getSystemHealth(hit_system) < p:getSystemHealthMax(hit_system) then
						if random(1,100) < 20 then
							p:setSystemHealthMax(hit_system,p:getSystemHealthMax(hit_system)*adverseEffect)
						else
							p:setSystemHealth(hit_system,p:getSystemHealth(hit_system)*adverseEffect)
						end
					else
						p:setSystemHealth(hit_system,p:getSystemHealth(hit_system)*adverseEffect)
					end
					zone:setColor(128,0,0)
				end
			else
				if p.danger_zone ~= nil then
					if p.danger_zone[zone] ~= nil then
						if not p.danger_zone["verified"] then
							print(p:getCallSign(),"did not reach verification threshold. Count:",p.danger_zone[zone],"zone:",zone)
						end
						p.danger_zone[zone] = 0
					end
				end
			end
		end
	end
end
function updateBarrierPatrols(delta)
	if barrier_patrols ~= nil then
		for index, ship in ipairs(barrier_patrols) do
			if ship:isValid() then
				ship.patrol_check_timer = ship.patrol_check_timer - delta
				if ship.patrol_check_timer < 0 then
					if string.find(ship:getOrder(),"Defend") then
						ship.patrol_point_index = ship.patrol_point_index + 1
						if ship.patrol_point_index > #ship.patrol_points then
							ship.patrol_point_index = 1
						end
						ship:orderFlyTowards(ship.patrol_points[ship.patrol_point_index].x,ship.patrol_points[ship.patrol_point_index].y)
					end
					ship.patrol_check_timer = ship.patrol_check_timer_interval
				end
			else
				barrier_patrols[index] = barrier_patrols[#barrier_patrols]
				barrier_patrols[#barrier_patrols] = nil
				break
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
		p:addCustomInfo("Weapons",p.tube_sizes_wea,tube_size_banner,1)
		p.tube_sizes_tac = "tube_sizes_tac"
		p:addCustomInfo("Tactical",p.tube_sizes_tac,tube_size_banner,1)
	end
end

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
function randomMineral(exclude)
	local good = mineralGoods[math.random(1,#mineralGoods)]
	if exclude == nil then
		return good
	else
		local count_repeat_loop = 0
		repeat
			good = mineralGoods[math.random(1,#mineralGoods)]
			count_repeat_loop = count_repeat_loop + 1
		until(good ~= exclude or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when trying to find a mineral good")
			print("good:",good,"exclude good:",exclude)
		end
		return good
	end
end
function randomComponent(exclude)
	local good = componentGoods[math.random(1,#componentGoods)]
	if exclude == nil then
		return good
	else
		local count_repeat_loop = 0
		repeat
			good = componentGoods[math.random(1,#componentGoods)]
			count_repeat_loop = count_repeat_loop + 1
		until(good ~= exclude or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when trying to find a component good")
			print("good:",good,"exclude good:",exclude)
		end
		return good
	end
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
            probe_launch_repair = math.random(5,10),
            hack_repair = math.random(5,10),
            scan_repair = math.random(5,10),
            combat_maneuver_repair = math.random(5,10),
            self_destruct_repair = 1
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
function handleDockedState()
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
	oMsg = string.format(_("station-comms","%s\n\nReputation: %i"),oMsg,math.floor(comms_source:getReputationPoints()))
	setCommsMessage(oMsg)
	if comms_target == station_medical_research and comms_source.medical_research == nil then
		addCommsReply(_("mission2ndBis-comms","Request medical research for Fargalli"), function()
			comms_source.medical_research = true
			medical_research_obtained = true
			local upgrade_msg = ""
			if medical_message_diagnostic then print("original upgrade message (blank):",upgrade_msg) end
			if comms_source.medical_station_upgrade ~= nil then
				local fleet_count = 0
				if pre_med_fleet ~= nil and #pre_med_fleet > 0 then
					for _, ship in ipairs(pre_med_fleet) do
						if ship ~= nil and ship:isValid() then
							fleet_count = fleet_count + 1
						end
					end
				end
				if fleet_count < 1 then
					if comms_source.medical_station_upgrade ~= "done" then
						if comms_source.medical_station_upgrade == "impulse" then
							comms_source:setImpulseMaxSpeed(comms_source:getImpulseMaxSpeed()*1.25)
							comms_source.medical_station_upgrade = "done"
							upgrade_msg = _("mission3th-comms","We also upgraded your impulse engines.")
							if medical_message_diagnostic then print("impulse upgrade message:",upgrade_msg) end
						end
						if comms_source.medical_station_upgrade == "transit" then
							comms_source.rapid_return_transit = "ready"
							comms_source.medical_station_upgrade = "done"
							upgrade_msg = string.format(_("mission3th-comms","The technicians are standing by to transport you back to %s."),station_regional_hq:getCallSign())
							if medical_message_diagnostic then print("transit upgrade message:",upgrade_msg) end
						end
						if comms_source.medical_station_upgrade == "beam" then
							local bi = 0
							repeat
								local arc = comms_source:getBeamWeaponArc(bi)
								local dir = comms_source:getBeamWeaponDirection(bi)
								local rng = comms_source:getBeamWeaponRange(bi)
								local cyc = comms_source:getBeamWeaponCycleTime(bi)
								local dmg = comms_source:getBeamWeaponDamage(bi)
								comms_source:setBeamWeapon(bi,arc,dir,rng,cyc,dmg*1.25)
								bi = bi + 1
							until(comms_source:getBeamWeaponRange(bi) < 1)
							comms_source.medical_station_upgrade = "done"
							upgrade_msg = _("mission3th-comms","We also upgrded the damage your beams inflict.")
							if medical_message_diagnostic then print("beam upgrade message:",upgrade_msg) end
						end
						if comms_source.medical_station_upgrade == "missile" then
							comms_source:setWeaponStorage("Homing",comms_source:getWeaponStorageMax("Homing"))
							comms_source:setWeaponStorage("Nuke",comms_source:getWeaponStorageMax("Nuke"))
							comms_source:setWeaponStorage("EMP",comms_source:getWeaponStorageMax("EMP"))
							comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorageMax("Mine"))
							comms_source:setWeaponStorage("HVLI",comms_source:getWeaponStorageMax("HVLI"))
							comms_source.medical_station_upgrade = "done"
							upgrade_msg = _("mission3th-comms","We also replenished your ordnance.")
							if medical_message_diagnostic then print("ordnance upgrade message:",upgrade_msg) end
						end
						if comms_source.medical_station_upgrade == "shield" then
							if comms_source:hasSystem("frontshield") then
								local front_shield_max = comms_source:getShieldMax(0)
								if comms_source:hasSystem("rearshield") then
									local rear_shield_max = comms_source:getShieldMax(1)
									comms_source:setShieldsMax(front_shield_max*1.25,rear_shield_max*1.25)
								else
									comms_source:setShieldsMax(front_shield_max*1.25)
								end
								upgrade_msg = _("mission3th-comms","We also increased your shield charge capacity.")
								if medical_message_diagnostic then print("shield upgrade message:",upgrade_msg) end
							else
								comms_source:addReputationPoints(50)
							end
							comms_source.medical_station_upgrade = "done"
						end
						if comms_source.medical_station_upgrade == "maneuver" then
							comms_source:setRotationMaxSpeed(comms_source:getRotationMaxSpeed()*1.25)
							comms_source.medical_station_upgrade = "done"
							upgrade_msg = _("mission3th-comms","We also upgraded your maneuvering system.")
							if medical_message_diagnostic then print("maneuver upgrade message:",upgrade_msg) end
						end
						if comms_source.medical_station_upgrade == "ftl" then
							if comms_source:hasSystem("warp") then
								comms_source:setWarpSpeed(comms_source:getWarpSpeed()*1.25)
								upgrade_msg = _("mission3th-comms","We also upgraded your base warp speed.")
								if medical_message_diagnostic then print("warp ftl upgrade message:",upgrade_msg) end
							elseif comms_source:hasSystem("jumpdrive") then
								local max_charge = comms_source.max_jump_range
								if max_charge == nil then
									max_charge = 50000
								end
								comms_source:setJumpDriveCharge(max_charge*3)
								upgrade_msg = _("mission3th-comms","We also overcharged your jump drive to three times your maximum range.")
								if medical_message_diagnostic then print("jump ftl upgrade message:",upgrade_msg) end
							else
								comms_source:addReputationPoints(50)
							end
							comms_source.medical_station_upgrade = "done"
						end
						if medical_message_diagnostic then print("upgrade message after completing the applicable upgrade:",upgrade_msg) end
					end
					if medical_message_diagnostic then print("upgrade message after medical station upgrade not done check and process:",upgrade_msg) end
				end
				if medical_message_diagnostic then print("upgrade message after fleet count check and process:",upgrade_msg) end
			end
			if medical_message_diagnostic then print("upgrade message outside of medical station upgrade available check and process:",upgrade_msg) end
			setCommsMessage(string.format(_("mission2ndBis-comms","We have transmitted all of our current research on the Omicron plague including treatment fabrication instructions. We have also transported what we believe will cure any victims of the plague along with unique raw materials required to manufacture more of the treatment. I hope you are able get this to Ensign Fargalli in time. %s"),upgrade_msg))
			if comms_source.rapid_return_transit ~= nil then
				addCommsReply(string.format(_("mission3th-comms","Take return transit from %s to %s"),station_medical_research:getCallSign(),station_regional_hq:getCallSign()),function()
					comms_source:commandUndock()
					local s_x, s_y = station_regional_hq:getPosition()
					comms_source:setPosition(s_x, s_y)
					setCommsMessage(_("mission3th-comms","Thanks for your help"))
				end)
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end 
	if comms_target == station_regional_hq and medical_research_obtained and not plague_victim_treated then
		addCommsReply(_("mission2ndBis-comms","Give medical treatment and research to sickbay"), function()
			if comms_source.medical_research then
				setCommsMessage(_("mission2ndBis-comms","Treatment received. Fargalli is expected to live. We are beginning to conduct in depth analysis of the research material with an eye to prevention of future infection."))
				plague_victim_treated = true
			else
				setCommsMessage(_("mission2ndBis-comms","The medical research and treatment is not aboard your ship"))
			end
			addCommsReply(_("Back"), commsStation)
		end)
	end
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
			service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
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
			service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
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
			setCommsMessage(string.format(_("stationServices-comms","What system would you like repaired?\n\nReputation: %i"),math.floor(comms_source:getReputationPoints())))
			if comms_target.comms_data.probe_launch_repair then
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(string.format(_("stationServices-comms","Repair probe launch system (%s Rep)"),comms_target.comms_data.service_cost.probe_launch_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.probe_launch_repair) then
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
					addCommsReply(string.format(_("stationServices-comms","Repair hacking system (%s Rep)"),comms_target.comms_data.service_cost.hack_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.hack_repair) then
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
					addCommsReply(string.format(_("stationServices-comms","Repair scanning system (%s Rep)"),comms_target.comms_data.service_cost.scan_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.scan_repair) then
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
					addCommsReply(string.format(_("stationServices-comms","Repair combat maneuver (%s Rep)"),comms_target.comms_data.service_cost.combat_maneuver_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.combat_maneuver_repair) then
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
					addCommsReply(string.format(_("stationServices-comms","Repair self destruct system (%s Rep)"),comms_target.comms_data.service_cost.self_destruct_repair),function()
						if comms_source:takeReputationPoints(comms_target.comms_data.service_cost.self_destruct_repair) then
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
					if random(1,100) < (100 - (30 * (difficulty - .5))) then
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
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
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
			if comms_target.comms_data.trade.food then
				if comms_source.goods ~= nil then
					if comms_source.goods.food ~= nil then
						if comms_source.goods.food.quantity > 0 then
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
					end
				end
			end
			if comms_target.comms_data.trade.medicine then
				if comms_source.goods ~= nil then
					if comms_source.goods.medicine ~= nil then
						if comms_source.goods.medicine.quantity > 0 then
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
					end
				end
			end
			if comms_target.comms_data.trade.luxury then
				if comms_source.goods ~= nil then
					if comms_source.goods.luxury ~= nil then
						if comms_source.goods.luxury.quantity > 0 then
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
end
function setOptionalOrders()
	optional_orders = ""
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
	setCommsMessage(oMsg)
	local count_repeat_loop = 0
	repeat
		local wj_deleted = false
		if #warp_jammer_list > 0 then
			for wj_index, wj in ipairs(warp_jammer_list) do
				if wj == nil then
					warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
					warp_jammer_list[#warp_jammer_list] = nil
					wj_deleted = true
					break
				elseif not wj:isValid() then
					warp_jammer_list[wj_index] = warp_jammer_list[#warp_jammer_list]
					warp_jammer_list[#warp_jammer_list] = nil
					wj_deleted = true
					break
				end
			end
		end
		count_repeat_loop = count_repeat_loop + 1
	until(not wj_deleted or count_repeat_loop > max_repeat_loop)
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
 	addCommsReply(_("station-comms", "I need information"), function()
		setCommsMessage(_("station-comms", "What kind of information do you need?"))
		addCommsReply(_("orders-comms", "What are my current orders?"), function()
			setOptionalOrders()
			setSecondaryOrders()
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			addCommsReply(_("Back"), commsStation)
		end)
		local comms_distance = distance(comms_target,comms_source)
		if comms_distance > average_station_circle_distance then
			addCommsReply(_("station-comms", "Where am I?"),function()
				local s_x, s_y = comms_target:getPosition()
				local p_x, p_y = comms_source:getPosition()
				local comms_bearing = angleFromVectorNorth(p_x, p_y, s_x, s_y)
				setCommsMessage(string.format(_("station-comms", "Based on triangulation and signal strength, our communications software says you're on a bearing of %.1f from us at a distance of %.1f units",comms_bearing,comms_distance/1000)))
				addCommsReply(_("Back"), commsStation)
			end)
		end
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
				service_status = string.format("%s\n%s",service_status,comms_target.probe_fail_reason)
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
				service_status = string.format("%s\n%s",service_status,comms_target.repair_fail_reason)
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
				service_status = string.format("%s\n%s",service_status,comms_target.energy_fail_reason)
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
		local has_gossip = random(1,100) < (100 - (30 * (difficulty - .5)))
		if (comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "") or
			(comms_target.comms_data.history ~= nil and comms_target.comms_data.history ~= "") or
			(comms_source:isFriendly(comms_target) and comms_target.comms_data.gossip ~= nil and comms_target.comms_data.gossip ~= "" and has_gossip) then
			addCommsReply(_("station-comms", "Tell me more about your station"), function()
				setCommsMessage(_("station-comms", "What would you like to know?"))
				if comms_target.comms_data.general ~= nil and comms_target.comms_data.general ~= "" then
					addCommsReply(_("stationGeneralInfo-comms","General information"), function()
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
						if random(1,100) < 50 then
							addCommsReply(_("gossip-comms", "Gossip"), function()
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
		addCommsReply(_("stationAssist-comms", "Report status"), function()
			msg = string.format(_("stationAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
			local shields = comms_target:getShieldCount()
			if shields == 1 then
				msg = msg .. string.format(_("stationAssist-comms", "Shield: %d%%\n"), math.floor(comms_target:getShieldLevel(0) / comms_target:getShieldMax(0) * 100))
			else
				for n=0,shields-1 do
					msg = msg .. string.format(_("stationAssist-comms", "Shield %s: %d%%\n"), n, math.floor(comms_target:getShieldLevel(n) / comms_target:getShieldMax(n) * 100))
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
    		local out = string.format(_("stationAssist-comms","Would you like the service jonque to come to you directly or would you prefer to set up a rendez-vous via a waypoint? Either way, you will need %.1f reputation."),getServiceCost("servicejonque"))
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
    				addCommsReply(string.format(_("stationAssist-comms","Rendez-vous at waypoint %d"),n),function()
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
    						setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to rendez-vous at waypoint %d"),ship:getCallSign(),n))
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
function destroyPlagueComms()
	setCommsMessage(string.format(_("mission4th-comms","To: %s\nFrom: %s\n\nAfter treating Ensign Fargalli, we took a closer look at the accompanying research. Analysis of the research material, the telemetry from your ship, and recent reports from intelligence brings us to an ominous conclusion."),comms_source:getCallSign(),comms_target:getCallSign()))
	addCommsReply(_("mission4th-comms","What have you concluded?"), function()
		setCommsMessage(_("mission4th-comms","Fargalli's illness and the previous similar cases experienced were not accidental. They were deliberately infected."))
		addCommsReply(_("mission4th-comms","What? Who infected them?"), function()
			setCommsMessage(_("mission4th-comms","The Exuari. Fargalli and others are apparently the victims of a preliminary experimental biological attack. The Exuari have code named this biological agent Omicron after the early 21st century pandemic virus variant on Earth which was highly contagious."))
			addCommsReply(_("mission4th-comms","That's sobering. Do we have more information?"),function()
				setCommsMessage(_("mission4th-comms","Indeed we do. It looks like Omicron might be transmitted via subspace. We believe the Exuari plan to 'broadcast' Omicron to every known human location. Needless to say, this would have extinction level consequences."))
				addCommsReply(_("mission4th-comms","Ouch. Is there a planned response?"), function()
					setCommsMessage(_("mission4th-comms","Destruction of the Exuari Omicron production and broadcast facility is the best thing we can think of."))
					addCommsReply(_("mission4th-comms","Can we help?"),function()
						setCommsMessage(_("mission4th-comms","We hope that you can. We don't know the precise location of the Exuari facility, just a general direction. However, when we examined the telemetry from your science officer's console when you were near the independent medical research facility, we noticed something interesting."))
						addCommsReply(_("mission4th-comms","What did you notice?"),function()
							setCommsMessage(_("mission4th-comms","The entity used to produce the treatment is also likely to be used to create Omicron. It gives off a powerful bio-signature that is periodic in nature, vaguely resembling a heartbeat."))
							addCommsReply(_("mission4th-comms","This signature can identify the Exuari Omicron facility?"), function()
								setCommsMessage(string.format(_("mission4th-comms","Yes, but if you're unsure, you are authorized to destroy every Exuari facility. You will need to travel into Exuari infested space along bearing %i from station %s to find the Omicron facility and destroy it. Our best intelligence estimates that deployment will occur within the next %i minutes. Happy hunting!"),math.floor(plague_axis),station_regional_hq:getCallSign(),destroy_time_limit))
							end)
						end)
					end)
				end)
			end)
		end)
	end)
end
function medicalAttentionComms()
	setCommsMessage(string.format(_("mission2nd-comms","To %s\nFrom: %s\n\nEnsign Fargalli, one of the maintenance engineers aboard the freighter %s, just reported to sickbay here on %s. We can treat his symptoms, but don't have a treatment for the root cause of his illness. This is the third case of this type we've seen in the last week. The last two ended up being fatal."),comms_source:getCallSign(),comms_target:getCallSign(),critical_transport:getCallSign(),station_regional_hq:getCallSign()))
	addCommsReply(_("mission2nd-comms","Why are you telling me this?"),function()
		setCommsMessage(string.format(_("mission2nd-comms","We've received word that Independent station %s is conducting ongoing research into this malady and may have more information, maybe even a remedy."),station_medical_research:getCallSign()))
		addCommsReply(string.format(_("mission2nd-comms","Then you should get that treatment from %s to save Fargalli"),station_medical_research:getCallSign()), function()
			setCommsMessage(string.format(_("mission2nd-comms","We can't contact %s directly since they are not on our communications network."),station_medical_research:getCallSign()))
			addCommsReply(_("mission2nd-comms","A courier could get it"), function()
				setCommsMessage(string.format(_("mission2nd-comms","We tried sending couriers. All of our couriers were shot down. We are telling you all this because we need you to go to %s and bring back any medical research or treatment or medicine they may have"),station_medical_research:getCallSign()))
				addCommsReply(_("mission2nd-comms","Now I understand"),function()
					setCommsMessage(string.format(_("mission2nd-comms","There is some urgency. Based on the previous cases, Fargalli has about %i minutes to live"),rescue_time_limit))
					addCommsReply(string.format(_("mission2nd-comms","Where is station %s?"),station_medical_research:getCallSign()), function()
						if difficulty < 1 then
							setCommsMessage(string.format(_("mission2nd-comms","%s is in sector %s. Good luck"),station_medical_research:getCallSign(),station_medical_research:getSectorName()))
						elseif difficulty > 1 then
							setCommsMessage(string.format(_("mission2nd-comms","%s is on an approximate bearing of %i from %s. Distance is greater than %.1f units."),station_medical_research:getCallSign(),math.floor(research_axis),station_regional_hq:getCallSign(),average_station_circle_distance/1000))
						else
							local med_x, med_y = station_medical_research:getPosition()
							local precise_bearing = angleFromVectorNorth(med_x, med_y, center_x, center_y)
							setCommsMessage(string.format(_("mission2nd-comms","%s is on a precise bearing of %.1f from %s. Distance is greater than %.1f units."),station_medical_research:getCallSign(),precise_bearing,station_regional_hq:getCallSign(),average_station_circle_distance/1000))
						end
					end)
				end)
			end)
		end)
	end)
end
function medicalBaseLocationAssistanceComms()
	setCommsMessage(string.format(_("mission3th-comms","To: %s\nFrom: %s\n\nHello, %s"),comms_source:getCallSign(),station_medical_research:getCallSign(),comms_source:getCallSign()))
	addCommsReply(string.format(_("mission3th-comms","Hello, %s"),comms_target:getCallSign()),function()
		setCommsMessage(_("mission3th-comms","One of the commercial freighters just docked up and their personnel inferred that you might be traveling in our direction."))
		addCommsReply(_("mission3th-comms","Those are well informed personnel"), function()
			setCommsMessage(_("mission3th-comms","It's amazing what commercial freighters learn and how quickly they learn it."))
			addCommsReply(_("mission3th-comms","Indeed. Why are you contacting us?"), function()
				setCommsMessage(_("mission3th-comms","We were wondering how soon you might get here. You see, there's this group of Exuari approaching and they don't look terribly friendly."))
				addCommsReply(_("mission3th-comms","We intend to get medical research, not necessarily engage Exuari"),function()
					setCommsMessage(_("mission3th-comms","We could make it worth your while if you were to protect our station from these Exuari."))
					addCommsReply(_("mission3th-comms","How so?"),function()
						setCommsMessage(_("mission3th-comms","If you were to destroy the attacking Exuari, we could offer you one of these:"))
						addCommsReply(_("mission3th-comms","25% faster impulse speed"), function()
							comms_source.medical_station_upgrade = "impulse"
							setCommsMessage(string.format(_("mission3th-comms","You got it. We're in sector %s"),station_medical_research:getSectorName()))
						end)
						addCommsReply(string.format(_("mission3th-comms","Rapid transit back to %s"),station_regional_hq:getCallSign()), function()
							comms_source.medical_station_upgrade = "transit"
							setCommsMessage(string.format(_("mission3th-comms","You got it. We're in sector %s"),station_medical_research:getSectorName()))
						end)
						if comms_source:hasSystem("beamweapons") then
							addCommsReply(_("mission3th-comms","25% stronger beam weapons"),function()
								comms_source.medical_station_upgrade = "beam"
								setCommsMessage(string.format(_("mission3th-comms","You got it. We're in sector %s"),station_medical_research:getSectorName()))
							end)
						end
						if comms_source:hasSystem("missilesystem") then
							addCommsReply(_("mission3th-comms","Replenish all your ordnance"), function()
								comms_source.medical_station_upgrade = "missile"
								setCommsMessage(string.format(_("mission3th-comms","You got it. We're in sector %s"),station_medical_research:getSectorName()))
							end)
						end
					end)
					addCommsReply(_("mission3th-comms","We just need to know where you are located"),function()
						if difficulty < 1 then
							local dsx, dsy = station_medical_research:getPosition()
							comms_source:commandAddWaypoint(dsx,dsy)
							setCommsMessage(string.format(_("mission3th-comms","We added paypoint %i to your system which identifies our station. We may or may not be able to provide what you request depending on how busy we are fighting off Exuari."),comms_source:getWaypointCount()))
						else
							setCommsMessage(string.format(_("mission3th-comms","We are in sector %s. We may or may not be able to provide what you request depending on how busy we are fighting off Exuari."),station_medical_research:getSectorName()))
						end
					end)
				end)
				addCommsReply(_("mission3th-comms","Sounds bad. Do you need help?"), function()
					setCommsMessage(_("mission3th-comms","We welcome any help you might provide. It would facilitate our survival."))
					addCommsReply(_("mission3th-comms","Could you provide us with your location?"), function()
						setCommsMessage(string.format(_("mission3th-comms","You mean %s did not tell you where to find us?"),station_regional_hq:getCallSign()))
						if difficulty < 1 then
							addCommsReply(_("mission3th-comms","They did, but we prefer greater precision"),function()
								local dsx, dsy = station_medical_research:getPosition()
								comms_source:commandAddWaypoint(dsx,dsy)
								setCommsMessage(string.format(_("mission3th-comms","We added waypoint %i to your system for our station. Your timely arrival would be greatly appreciated."),comms_source:getWaypointCount()))
							end)
						else
							addCommsReply(string.format(_("mission3th-comms","%s provided a bearing, but we prefer greater precision"),station_regional_hq:getCallSign()),function()
								setCommsMessage(string.format(_("mission3th-comms","We are in sector %s. Your timely arrival would be greatly appreciated."),station_medical_research:getSectorName()))
							end)
						end
					end)
				end)
			end)
		end)
		addCommsReply(_("mission3th-comms","Your information is correct"), function()
			setCommsMessage(_("mission3th-comms","That's great news. We've got some pesky Exuari in the area."))
			addCommsReply(_("mission3th-comms","Let me guess, you want our help with the Exuari?"), function()
				setCommsMessage(string.format(_("mission3th-comms","Got it in one. We're in sector %s. Please don't dawdle"),station_medical_research:getSectorName()))
			end)
			addCommsReply(_("mission3th-comms","They're everywhere"), function()
				setCommsMessage(_("mission3th-comms","This batch is in our back yard. If you're going to be in the neighborhood already, could you help us out?"))
				addCommsReply(_("mission3th-comms","Sure"), function()
					setCommsMessage(string.format(_("mission3th-comms","Great. We're in sector %s"),station_medical_research:getSectorName()))
					comms_source.medical_station_upgrade = "shield"
				end)
				addCommsReply(_("mission3th-comms","We're really only coming to get medical research"), function()
					setCommsMessage(_("mission3th-comms","Understood."))
				end)
			end)
			addCommsReply(_("mission3th-comms","Identify your sector and we'll help"), function()
				setCommsMessage(string.format(_("mission3th-comms","Fair enough. We're in sector %s"),station_medical_research:getSectorName()))
				comms_source.medical_station_upgrade = "maneuver"
			end)
		end)
		addCommsReply(_("mission3th-comms","We might be. Why do you ask?"), function()
			setCommsMessage(_("mission3th-comms","Well, we've observed some Exuari headed our way. We don't think they're making a courtesy call"))
			addCommsReply(_("mission3th-comms","They never do. Would you like our help?"),function()
				setCommsMessage(string.format(_("mission3th-comms","Yes, please. We're in sector %s"),station_medical_research:getSectorName()))
				comms_source.medical_station_upgrade = "ftl"
			end)
			addCommsReply(_("mission3th-comms","Where exactly is 'your way?'"),function()
				setCommsMessage(string.format(_("mission3th-comms","Our station is located in sector %s. We hope to see you soon."),station_medical_research:getSectorName()))
			end)
			addCommsReply(_("mission3th-comms","We'd like to help, but we're having a hard time finding you"), function()
				setCommsMessage(string.format(_("mission3th-comms","We're in sector %s. Please hurry, the Exuari look dangerous."),station_medical_research:getSectorName()))
				comms_source.medical_station_upgrade = "impulse"
			end)
			addCommsReply(_("mission3th-comms","Technically, our mission does not cover protection from Exuari"), function()
				setCommsMessage(_("mission3th-comms","Drat"))
			end)
		end)
	end)
	addCommsReply(_("mission3th-comms","Where are you located?"),function()
		setCommsMessage(string.format(_("mission3th-comms","We are in sector %s. Please hurry, the Exuari are approaching."),station_medical_research:getSectorName()))
	end)
	addCommsReply(_("mission3th-comms","We are glad you contacted us"),function()
		setCommsMessage(_("mission3th-comms","Coincidentally, we are glad to be in contact with you, too."))
		addCommsReply(_("mission3th-comms","Why is that?"),function()
			setCommsMessage(string.format(_("mission3th-comms","We are in need of some assistance with Exuari that are approaching our station, %s."),station_medical_research:getCallSign()))
			addCommsReply(_("mission3th-comms","We can help"),function()
				setCommsMessage(_("mission3th-comms","That's so good to hear. You may want to hurry, though."))
				addCommsReply(_("mission3th-comms","Why the rush?"),function()
					if comms_source:getWaypointCount() >= 9 then
						setCommsMessage(string.format(_("mission3th-comms","The Exuari! They're getting closer! Please come to us in sector %s as soon as you can."),station_medical_research:getSectorName()))
					else
						local dsx, dsy = station_medical_research:getPosition()
						comms_source:commandAddWaypoint(dsx,dsy)								
						setCommsMessage(string.format(_("mission3th-comms","The Exuari! They're getting closer! I'm adding waypoint %i into your system for our station. Please get here as soon as you can."),comms_source:getWaypointCount()))
					end
				end)
				if random(1,100) < 50 then
					addCommsReply(string.format(_("mission3th-comms","In what sector is %s located?"),station_medical_research:getCallSign()), function()
						setCommsMessage(string.format(_("mission3th-comms","%s is located in sector %s."),station_medical_research:getCallSign(),station_medical_research:getSectorName()))
					end)
					addCommsReply(string.format(_("mission3th-comms","In what sector is %s located?"),station_regional_hq:getCallSign()), function()
						setCommsMessage(string.format(_("mission3th-comms","%s is located in sector %s."),station_regional_hq:getCallSign(),station_regional_hq:getSectorName()))
					end)
				else
					addCommsReply(string.format(_("mission3th-comms","In what sector is %s located?"),station_regional_hq:getCallSign()), function()
						setCommsMessage(string.format("%s is located in sector %s.",station_regional_hq:getCallSign(),station_regional_hq:getSectorName()))
					end)
					addCommsReply(string.format(_("mission3th-comms","In what sector is %s located?"),station_medical_research:getCallSign()), function()
						setCommsMessage(string.format(_("mission3th-comms","%s is located in sector %s."),station_medical_research:getCallSign(),station_medical_research:getSectorName()))
					end)
				end
			end)
		end)
	end)
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
		msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
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
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms", "Dock at %s"), obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms", "Docking at %s."), obj:getCallSign()));
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsShip)
			end)
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
								addCommsReply(_("Back"), commsShip)
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
							addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(good_data.cost)), function()
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
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(good_data.cost)), function()
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
							cargoMsg = cargoMsg .. _("trade-comms",", ") .. good
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
						cargoMsg = cargoMsg .. _("trade-comms",", ") .. good
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
								addCommsReply(string.format(_("trade-comms", "Buy one %s for %i reputation"),good,math.floor(good_data.cost)), function()
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
		setCommsMessage(_("shipAssist-comms","What do you want?"))
	else
		setCommsMessage(_("shipAssist-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("shipAssist-comms","Defend a waypoint"), function()
		if comms_source:getWaypointCount() == 0 then
			setCommsMessage(_("shipAssist-comms","No waypoints set. Please set a waypoint first."))
		else
			setCommsMessage(_("shipAssist-comms","Which waypoint should we defend?"))
			for n=1,comms_source:getWaypointCount() do
				addCommsReply(string.format(_("shipAssist-comms","Defend WP %i"),n), function()
					comms_target:orderDefendLocation(comms_source:getWaypoint(n))
					setCommsMessage(string.format(_("shipAssist-comms","We are heading to assist at WP %i."),n))
					addCommsReply(_("Back"), commsServiceJonque)
				end)
			end
		end
		addCommsReply(_("Back"), commsServiceJonque)
	end)
	if comms_data.friendlyness > 0.2 then
		addCommsReply(_("shipAssist-comms","Assist me"), function()
			setCommsMessage(_("shipAssist-comms","Heading toward you to assist."))
			comms_target:orderDefendTarget(comms_source)
			addCommsReply(_("Back"), commsServiceJonque)
		end)
	end
	addCommsReply(_("shipAssist-comms", "Report status"), function()
		msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
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
		setCommsMessage(msg);
			addCommsReply(_("Back"), commsServiceJonque)
	end)
	for index, obj in ipairs(comms_target:getObjectsInRange(5000)) do
		if obj.typeName == "SpaceStation" and not comms_target:isEnemy(obj) then
			addCommsReply(string.format(_("shipAssist-comms","Dock at %s"),obj:getCallSign()), function()
				setCommsMessage(string.format(_("shipAssist-comms","Docking at %s."),obj:getCallSign()))
				comms_target:orderDock(obj)
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
	end
	if distance(comms_source,comms_target) < 5000 then
		commonServiceOptions()
	end
end
function neutralServiceJonqueComms(comms_data)
	if comms_data.friendlyness < 20 then
		setCommsMessage(_("shipAssist-comms","What do you want?"))
	else
		setCommsMessage(_("shipAssist-comms","Sir, how can we assist?"))
	end
	addCommsReply(_("shipAssist-comms","How are you doing?"), function()
		msg = string.format(_("shipAssist-comms", "Hull: %d%%\n"), math.floor(comms_target:getHull() / comms_target:getHullMax() * 100))
		local shields = comms_target:getShieldCount()
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
		setCommsMessage(msg);
		addCommsReply(_("Back"), commsServiceJonque)
	end)
	commonServiceOptions()
end
function commonServiceOptions()
	addCommsReply(_("shipServices-comms","Service options"),function()
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
			addCommsReply(_("shipServices-comms", "Repair ship system"),function()
				setCommsMessage(_("shipServices-comms", "What system would you like repaired?"))
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(_("shipServices-comms", "Repair probe launch system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage(_("shipServices-comms", "Your probe launch system has been repaired"))
						else
							setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanHack() then
					addCommsReply(_("shipServices-comms", "Repair hacking system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanHack(true)
							setCommsMessage(_("shipServices-comms", "Your hack system has been repaired"))
						else
							setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanScan() then
					addCommsReply(_("shipServices-comms", "Repair scanning system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanScan(true)
							setCommsMessage(_("shipServices-comms", "Your scanners have been repaired"))
						else
							setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(_("shipServices-comms", "Repair combat maneuver"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage(_("shipServices-comms", "Your combat maneuver has been repaired"))
						else
							setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(_("shipServices-comms", "Repair self destruct system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage(_("shipServices-comms", "Your self destruct system has been repaired"))
						else
							setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
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
			addCommsReply(string.format(_("shipServices-comms", "Full hull repair (%i reputation)"),math.floor(full_repair + premium)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair + premium)) then
						comms_source:setHull(comms_source:getHullMax())
						setCommsMessage(_("shipServices-comms", "All fixed up and ready to go"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("shipServices-comms", "Add %i%% to hull (%i reputation)"),math.floor(full_repair/2/comms_source:getHullMax()*100),math.floor(full_repair/2 + premium/2)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/2 + premium/2)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/2))
						setCommsMessage(_("shipServices-comms", "Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("shipServices-comms", "Add %i%% to hull (%i reputation)"),math.floor(full_repair/3/comms_source:getHullMax()*100),math.floor(full_repair/3)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/3)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/3))
						setCommsMessage(_("shipServices-comms", "Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms", "You need to stay close if you want me to fix your ship"))
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
			addCommsReply(_("ammo-comms","Restock ordnance"),function()
				for missile_type, ord in pairs(player_missile_types) do
					if ord.current < ord.max and comms_target.comms_data.weapon_inventory[missile_type] > 0 then
						comms_data = comms_target.comms_data
						setCommsMessage(_("ammo-comms","What kind of ordnance?"))
						addCommsReply(string.format(_("ammo-comms","%s (%i reputation each)"),missile_type,getWeaponCost(missile_type)),function()
							if distance(comms_source,comms_target) < 5000 then
								if comms_target.comms_data.weapon_inventory[missile_type] >= ord.need then
									if comms_source:takeReputationPoints(getWeaponCost(missile_type)*ord.need) then
										comms_source:setWeaponStorage(missile_type,ord.max)
										comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - ord.need
										setCommsMessage(string.format(_("ammo-comms","Restocked your %s type ordnance"),missile_type))
									else
										if comms_source:getReputationPoints() > getWeaponCost(missile_type) then
											setCommsMessage(string.format(_("needRep-comms","You don't have enough reputation to fully replenish your %s type ordnance. You need %i and you only have %i. How would you like to proceed?"),missile_type,getWeaponCost(missile_type)*ord.need,math.floor(comms_source:getReputationPoints())))
											addCommsReply(string.format(_("ammo-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
												if distance(comms_source,comms_target) < 5000 then
													if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
														comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
														comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
														setCommsMessage(string.format(_("ammo-comms","One %s provided"),missile_type))
													else
														setCommsMessage(_("needRep-comms","Insufficient reputation"))
													end
												else
													setCommsMessage(_("ammo-comms","You need to stay close if you want me to restock your ordnance"))
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
												addCommsReply(string.format(_("ammo-comms","Get %i (%i reputation)"),missile_count,max_afford),function()
													if distance(comms_source,comms_target) < 5000 then
														if comms_source:takeReputationPoints(getWeaponCost(missile_type)*missile_count) then
															comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + missile_count)
															comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - missile_count
															setCommsMessage(string.format(_("ammo-comms","%i %ss provided"),missile_count,missile_type))
														else
															setCommsMessage(_("needRep-comms","Insufficient reputation"))
														end
													else
														setCommsMessage(_("ammo-comms","You need to stay close if you want me to restock your ordnance"))
													end
													addCommsReply(_("Back"), commsServiceJonque)
												end)
											end
										else
											setCommsMessage(_("needRep-comms","Insufficient reputation"))
										end
									end
								else
									setCommsMessage(string.format(_("ammo-comms","I don't have enough %s type ordnance to fully restock you. How would you like to proceed?"),missile_type))
									addCommsReply(_("ammo-comms","We'll take all you've got"),function()
										if comms_source:takeReputationPoints(getWeaponCost(missile_type)*comms_target.comms_data.weapon_inventory[missile_type]) then
											comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + comms_target.comms_data.weapon_inventory[missile_type])
											if comms_target.comms_data.weapon_inventory[missile_type] > 1 then
												setCommsMessage(string.format(_("ammo-comms","%i %ss provided"),missile_count,missile_type))
											else
												setCommsMessage(string.format(_("ammo-comms","One %s provided"),missile_type))
											end
											comms_target.comms_data.weapon_inventory[missile_type] = 0
										else
											setCommsMessage(string.format(_("needRep-comms","You don't have enough reputation to get all of our %s type ordnance. You need %i and you only have %i. How would you like to proceed?"),missile_type,getWeaponCost(missile_type)*comms_target.comms_data.weapon_inventory[missile_type],math.floor(comms_source:getReputationPoints())))
											addCommsReply(string.format(_("ammo-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
												if distance(comms_source,comms_target) < 5000 then
													if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
														comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
														comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
														setCommsMessage(string.format(_("ammo-comms","One %s provided"),missile_type))
													else
														setCommsMessage(_("needRep-comms","Insufficient reputation"))
													end
												else
													setCommsMessage(_("ammo-comms","You need to stay close if you want me to restock your ordnance"))
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
												addCommsReply(string.format(_("ammo-comms","Get %i (%i reputation)"),missile_count,max_afford),function()
													if distance(comms_source,comms_target) < 5000 then
														if comms_source:takeReputationPoints(getWeaponCost(missile_type)*missile_count) then
															comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + missile_count)
															comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] + missile_count
															setCommsMessage(string.format(_("ammo-comms","%i %ss provided"),missile_count,missile_type))
														else
															setCommsMessage(_("needRep-comms","Insufficient reputation"))
														end
													else
														setCommsMessage(_("ammo-comms","You need to stay close if you want me to restock your ordnance"))
													end
													addCommsReply(_("Back"), commsServiceJonque)
												end)
											end
										end
									end)
									addCommsReply(string.format(_("ammo-comms","Get one (%i reputation)"),getWeaponCost(missile_type)), function()
										if distance(comms_source,comms_target) < 5000 then
											if comms_source:takeReputationPoints(getWeaponCost(missile_type)) then
												comms_source:setWeaponStorage(missile_type,comms_source:getWeaponStorage(missile_type) + 1)
												comms_target.comms_data.weapon_inventory[missile_type] = comms_target.comms_data.weapon_inventory[missile_type] - 1
												setCommsMessage(string.format(_("ammo-comms","One %s provided"),missile_type))
											else
												setCommsMessage(_("needRep-comms","Insufficient reputation"))
											end
										else
											setCommsMessage(_("ammo-comms","You need to stay close if you want me to restock your ordnance"))
										end
										addCommsReply(_("Back"), commsServiceJonque)
									end)
								end
							else
								setCommsMessage(_("ammo-comms","You need to stay close if you want me to restock your ordnance"))
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
			addCommsReply(_("shipServices-comms", "Restock scan probes (5 reputation)"),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(5) then
						comms_source:setScanProbeCount(comms_source:getMaxScanProbeCount())
						setCommsMessage(_("shipServices-comms", "I replenished your probes for you."))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms","You need to stay close if you want me to restock your probes"))
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
			addCommsReply(string.format(_("shipServices-comms", "Quick charge the main batteries (%i reputation)"),power_charge),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(power_charge) then
						comms_source:setEnergyLevel(comms_source:getEnergyLevelMax())
						comms_source:commandSetSystemPowerRequest("reactor",1)
						comms_source:setSystemPower("reactor",1)
						comms_source:setSystemHeat("reactor",2)
						setCommsMessage(_("shipServices-comms", "Your batteries have been charged"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms", "You need to stay close if you want your batteries charged quickly"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		if offer_hull_repair or offer_repair or offer_ordnance or offer_probes or offer_power then
			setCommsMessage(_("shipServices-comms", "How can I help you get your ship in good running order?"))
		else
			setCommsMessage(_("shipServices-comms", "There's nothing on your ship that I can help you fix. Sorry."))
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
		template_pool_size = 5
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
		enemyStrength = math.max(danger * difficulty * playerPower(),5)
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
		template_pool_size = 15
		template_pool = getTemplatePool(enemyStrength)
	end
	if #template_pool < 1 then
		addGMMessage(_("msgGM", "Empty Template pool: fix excludes or other criteria"))
		return enemyList
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
	if suffix_index > 999 then 
		suffix_index = 1
	end
	return string.format("%s%i",prefix,suffix_index)
end
function generateCallSignPrefix(length)
	if call_sign_prefix_pool == nil then
		call_sign_prefix_pool = {}
		prefix_length = prefix_length + 1
		if prefix_length > 3 then
			prefix_length = 1
		end
		fillPrefixPool()
	end
	if length == nil then
		length = prefix_length
	end
	local prefix_index = 0
	local prefix = ""
	for i=1,length do
		if #call_sign_prefix_pool < 1 then
			fillPrefixPool()
		end
		prefix_index = math.random(1,#call_sign_prefix_pool)
		prefix = prefix .. call_sign_prefix_pool[prefix_index]
		table.remove(call_sign_prefix_pool,prefix_index)
	end
	return prefix
end
function fillPrefixPool()
	for i=1,26 do
		table.insert(call_sign_prefix_pool,string.char(i+64))
	end
end
function getFactionPrefix(faction)
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
	if faction == "Arlenians" then
		if arlenian_names == nil then
			setArlenianNames()
		else
			if #arlenian_names < 1 then
				setArlenianNames()
			end
		end
		local arlenian_name_choice = math.random(1,#arlenian_names)
		faction_prefix = arlenian_names[arlenian_name_choice]
		table.remove(arlenian_names,arlenian_name_choice)
	end
	if faction == "USN" then
		if usn_names == nil then
			setUsnNames()
		else
			if #usn_names < 1 then
				setUsnNames()
			end
		end
		local usn_name_choice = math.random(1,#usn_names)
		faction_prefix = usn_names[usn_name_choice]
		table.remove(usn_names,usn_name_choice)
	end
	if faction == "TSN" then
		if tsn_names == nil then
			setTsnNames()
		else
			if #tsn_names < 1 then
				setTsnNames()
			end
		end
		local tsn_name_choice = math.random(1,#tsn_names)
		faction_prefix = tsn_names[tsn_name_choice]
		table.remove(tsn_names,tsn_name_choice)
	end
	if faction == "CUF" then
		if cuf_names == nil then
			setCufNames()
		else
			if #cuf_names < 1 then
				setCufNames()
			end
		end
		local cuf_name_choice = math.random(1,#cuf_names)
		faction_prefix = cuf_names[cuf_name_choice]
		table.remove(cuf_names,cuf_name_choice)
	end
	if faction == "Ktlitans" then
		if ktlitan_names == nil then
			setKtlitanNames()
		else
			if #ktlitan_names < 1 then
				setKtlitanNames()
			end
		end
		local ktlitan_name_choice = math.random(1,#ktlitan_names)
		faction_prefix = ktlitan_names[ktlitan_name_choice]
		table.remove(ktlitan_names,ktlitan_name_choice)
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
	table.insert(independent_names,"Chakak")		--faux Ktlitans
	table.insert(independent_names,"Chakik")		--faux Ktlitans
	table.insert(independent_names,"Chaklik")		--faux Ktlitans
	table.insert(independent_names,"Kaklak")		--faux Ktlitans
	table.insert(independent_names,"Kiklak")		--faux Ktlitans
	table.insert(independent_names,"Kitpak")		--faux Ktlitans
	table.insert(independent_names,"Kitplak")		--faux Ktlitans
	table.insert(independent_names,"Pipklat")		--faux Ktlitans
	table.insert(independent_names,"Piptik")		--faux Ktlitans
end
function setCufNames()
	cuf_names = {}
	table.insert(cuf_names,"Allegro")
	table.insert(cuf_names,"Bonafide")
	table.insert(cuf_names,"Brief Blur")
	table.insert(cuf_names,"Byzantine Born")
	table.insert(cuf_names,"Celeste")
	table.insert(cuf_names,"Chosen Charter")
	table.insert(cuf_names,"Conundrum")
	table.insert(cuf_names,"Crazy Clef")
	table.insert(cuf_names,"Curtail")
	table.insert(cuf_names,"Dark Demesne")
	table.insert(cuf_names,"Diminutive Drama")
	table.insert(cuf_names,"Draconian Destiny")
	table.insert(cuf_names,"Fickle Frown")
	table.insert(cuf_names,"Final Freeze")
	table.insert(cuf_names,"Fried Feather")
	table.insert(cuf_names,"Frozen Flare")
	table.insert(cuf_names,"Gaunt Gator")
	table.insert(cuf_names,"Hidden Harpoon")
	table.insert(cuf_names,"Intense Interest")
	table.insert(cuf_names,"Lackadaisical")
	table.insert(cuf_names,"Largess")
	table.insert(cuf_names,"Ointment")
	table.insert(cuf_names,"Plush Puzzle")
	table.insert(cuf_names,"Slick")
	table.insert(cuf_names,"Thumper")
	table.insert(cuf_names,"Torpid")
	table.insert(cuf_names,"Triple Take")
end
function setUsnNames()
	usn_names = {}
	table.insert(usn_names,"Belladonna")
	table.insert(usn_names,"Broken Dragon")
	table.insert(usn_names,"Burning Knave")
	table.insert(usn_names,"Corona Flare")
	table.insert(usn_names,"Daring the Deep")
	table.insert(usn_names,"Dragon's Cutlass")
	table.insert(usn_names,"Dragon's Sadness")
	table.insert(usn_names,"Elusive Doom")
	table.insert(usn_names,"Fast Flare")
	table.insert(usn_names,"Flying Flare")
	table.insert(usn_names,"Fulminate")
	table.insert(usn_names,"Gaseous Gale")
	table.insert(usn_names,"Golden Anger")
	table.insert(usn_names,"Greedy Promethean")
	table.insert(usn_names,"Happy Mynock")
	table.insert(usn_names,"Jimi Saru")
	table.insert(usn_names,"Jolly Roger")
	table.insert(usn_names,"Killer's Grief")
	table.insert(usn_names,"Mad Delight")
	table.insert(usn_names,"Nocturnal Neptune")
	table.insert(usn_names,"Obscure Orbiter")
	table.insert(usn_names,"Red Rift")
	table.insert(usn_names,"Rusty Belle")
	table.insert(usn_names,"Silver Pearl")
	table.insert(usn_names,"Sodden Corsair")
	table.insert(usn_names,"Solar Sailor")
	table.insert(usn_names,"Solar Secret")
	table.insert(usn_names,"Sun's Grief")
	table.insert(usn_names,"Tortuga Shadows")
	table.insert(usn_names,"Trinity")
	table.insert(usn_names,"Wayfaring Wind")
end
function setTsnNames()
	tsn_names = {}
	table.insert(tsn_names,"Aegis")
	table.insert(tsn_names,"Allegiance")
	table.insert(tsn_names,"Apollo")
	table.insert(tsn_names,"Ares")
	table.insert(tsn_names,"Casper")
	table.insert(tsn_names,"Charger")
	table.insert(tsn_names,"Dauntless")
	table.insert(tsn_names,"Demeter")
	table.insert(tsn_names,"Eagle")
	table.insert(tsn_names,"Excalibur")
	table.insert(tsn_names,"Falcon")
	table.insert(tsn_names,"Guardian")
	table.insert(tsn_names,"Hawk")
	table.insert(tsn_names,"Hera")
	table.insert(tsn_names,"Horizon")
	table.insert(tsn_names,"Hunter")
	table.insert(tsn_names,"Hydra")
	table.insert(tsn_names,"Intrepid")
	table.insert(tsn_names,"Lancer")
	table.insert(tsn_names,"Montgomery")
	table.insert(tsn_names,"Nemesis")
	table.insert(tsn_names,"Osiris")
	table.insert(tsn_names,"Pegasus")
	table.insert(tsn_names,"Phoenix")
	table.insert(tsn_names,"Poseidon")
	table.insert(tsn_names,"Raven")
	table.insert(tsn_names,"Sabre")
	table.insert(tsn_names,"Stalker")
	table.insert(tsn_names,"Valkyrie")
	table.insert(tsn_names,"Viper")
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
function setKtlitanNames()
	ktlitan_names = {}
	table.insert(ktlitan_names,"Chaklak")
	table.insert(ktlitan_names,"Chaklit")
	table.insert(ktlitan_names,"Chitlat")
	table.insert(ktlitan_names,"Chitlit")
	table.insert(ktlitan_names,"Chitpik")
	table.insert(ktlitan_names,"Chokpit")
	table.insert(ktlitan_names,"Choktip")
	table.insert(ktlitan_names,"Choktot")
	table.insert(ktlitan_names,"Chotlap")
	table.insert(ktlitan_names,"Chotlat")
	table.insert(ktlitan_names,"Chotlot")
	table.insert(ktlitan_names,"Kaftlit")
	table.insert(ktlitan_names,"Kaplak")
	table.insert(ktlitan_names,"Kaplat")
	table.insert(ktlitan_names,"Kichpak")
	table.insert(ktlitan_names,"Kichpik")
	table.insert(ktlitan_names,"Kichtak")
	table.insert(ktlitan_names,"Kiftlat")
	table.insert(ktlitan_names,"Kiftak")
	table.insert(ktlitan_names,"Kiftakt")
	table.insert(ktlitan_names,"Kiftlikt")
	table.insert(ktlitan_names,"Kiftlit")
	table.insert(ktlitan_names,"Kiklat")
	table.insert(ktlitan_names,"Kiklik")
	table.insert(ktlitan_names,"Kiklit")
	table.insert(ktlitan_names,"Kiplit")
	table.insert(ktlitan_names,"Kiptot")
	table.insert(ktlitan_names,"Kitchip")
	table.insert(ktlitan_names,"Kitchit")
	table.insert(ktlitan_names,"Kitlaft")
	table.insert(ktlitan_names,"Kitlak")
	table.insert(ktlitan_names,"Kitlakt")
	table.insert(ktlitan_names,"Kitlich")
	table.insert(ktlitan_names,"Kitlik")
	table.insert(ktlitan_names,"Kitpok")
	table.insert(ktlitan_names,"Koptich")
	table.insert(ktlitan_names,"Koptlik")
	table.insert(ktlitan_names,"Kotplat")
	table.insert(ktlitan_names,"Pachtik")
	table.insert(ktlitan_names,"Paflak")
	table.insert(ktlitan_names,"Paftak")
	table.insert(ktlitan_names,"Paftik")
	table.insert(ktlitan_names,"Pakchit")
	table.insert(ktlitan_names,"Pakchok")
	table.insert(ktlitan_names,"Paktok")
	table.insert(ktlitan_names,"Piklit")
	table.insert(ktlitan_names,"Piflit")
	table.insert(ktlitan_names,"Piftik")
	table.insert(ktlitan_names,"Pitlak")
	table.insert(ktlitan_names,"Pochkik")
	table.insert(ktlitan_names,"Pochkit")
	table.insert(ktlitan_names,"Poftlit")
	table.insert(ktlitan_names,"Pokchap")
	table.insert(ktlitan_names,"Pokchat")
	table.insert(ktlitan_names,"Poktat")
	table.insert(ktlitan_names,"Poklit")
	table.insert(ktlitan_names,"Potlak")
	table.insert(ktlitan_names,"Tachpik")
	table.insert(ktlitan_names,"Tachpit")
	table.insert(ktlitan_names,"Taklit")
	table.insert(ktlitan_names,"Talkip")
	table.insert(ktlitan_names,"Talpik")
	table.insert(ktlitan_names,"Taltkip")
	table.insert(ktlitan_names,"Taltkit")
	table.insert(ktlitan_names,"Tichpik")
	table.insert(ktlitan_names,"Tikplit")
	table.insert(ktlitan_names,"Tiklich")
	table.insert(ktlitan_names,"Tiklip")
	table.insert(ktlitan_names,"Tiklip")
	table.insert(ktlitan_names,"Tilpit")
	table.insert(ktlitan_names,"Tiltlit")
	table.insert(ktlitan_names,"Tochtik")
	table.insert(ktlitan_names,"Tochkap")
	table.insert(ktlitan_names,"Tochpik")
	table.insert(ktlitan_names,"Tochpit")
	table.insert(ktlitan_names,"Tochkit")
	table.insert(ktlitan_names,"Totlop")
	table.insert(ktlitan_names,"Totlot")
end
function setArlenianNames()
	arlenian_names = {}
	table.insert(arlenian_names,"Balura")
	table.insert(arlenian_names,"Baminda")
	table.insert(arlenian_names,"Belarne")
	table.insert(arlenian_names,"Bilanna")
	table.insert(arlenian_names,"Calonda")
	table.insert(arlenian_names,"Carila")
	table.insert(arlenian_names,"Carulda")
	table.insert(arlenian_names,"Charma")
	table.insert(arlenian_names,"Choralle")
	table.insert(arlenian_names,"Corlune")
	table.insert(arlenian_names,"Damilda")
	table.insert(arlenian_names,"Dilenda")
	table.insert(arlenian_names,"Dorla")
	table.insert(arlenian_names,"Elena")
	table.insert(arlenian_names,"Emerla")
	table.insert(arlenian_names,"Famelda")
	table.insert(arlenian_names,"Finelle")
	table.insert(arlenian_names,"Fontaine")
	table.insert(arlenian_names,"Forlanne")
	table.insert(arlenian_names,"Gendura")
	table.insert(arlenian_names,"Gilarne")
	table.insert(arlenian_names,"Grizelle")
	table.insert(arlenian_names,"Hilerna")
	table.insert(arlenian_names,"Homella")
	table.insert(arlenian_names,"Jarille")
	table.insert(arlenian_names,"Jindarre")
	table.insert(arlenian_names,"Juminde")
	table.insert(arlenian_names,"Kalena")
	table.insert(arlenian_names,"Kimarna")
	table.insert(arlenian_names,"Kolira")
	table.insert(arlenian_names,"Lanerra")
	table.insert(arlenian_names,"Lamura")
	table.insert(arlenian_names,"Lavila")
	table.insert(arlenian_names,"Lavorna")
	table.insert(arlenian_names,"Lendura")
	table.insert(arlenian_names,"Limala")
	table.insert(arlenian_names,"Lorelle")
	table.insert(arlenian_names,"Mavelle")
	table.insert(arlenian_names,"Menola")
	table.insert(arlenian_names,"Merla")
	table.insert(arlenian_names,"Mitelle")
	table.insert(arlenian_names,"Mivelda")
	table.insert(arlenian_names,"Morainne")
	table.insert(arlenian_names,"Morda")
	table.insert(arlenian_names,"Morlena")
	table.insert(arlenian_names,"Nadela")
	table.insert(arlenian_names,"Naminda")
	table.insert(arlenian_names,"Nilana")
	table.insert(arlenian_names,"Nurelle")
	table.insert(arlenian_names,"Panela")
	table.insert(arlenian_names,"Pelnare")
	table.insert(arlenian_names,"Pilera")
	table.insert(arlenian_names,"Povelle")
	table.insert(arlenian_names,"Quilarre")
	table.insert(arlenian_names,"Ramila")
	table.insert(arlenian_names,"Renatha")
	table.insert(arlenian_names,"Rendelle")
	table.insert(arlenian_names,"Rinalda")
	table.insert(arlenian_names,"Riderla")
	table.insert(arlenian_names,"Rifalle")
	table.insert(arlenian_names,"Samila")
	table.insert(arlenian_names,"Salura")
	table.insert(arlenian_names,"Selinda")
	table.insert(arlenian_names,"Simanda")
	table.insert(arlenian_names,"Sodila")
	table.insert(arlenian_names,"Talinda")
	table.insert(arlenian_names,"Tamierre")
	table.insert(arlenian_names,"Telorre")
	table.insert(arlenian_names,"Terila")
	table.insert(arlenian_names,"Turalla")
	table.insert(arlenian_names,"Valerna")
	table.insert(arlenian_names,"Vilanda")
	table.insert(arlenian_names,"Vomera")
	table.insert(arlenian_names,"Wanelle")
	table.insert(arlenian_names,"Warenda")
	table.insert(arlenian_names,"Wilena")
	table.insert(arlenian_names,"Wodarla")
	table.insert(arlenian_names,"Yamelda")
	table.insert(arlenian_names,"Yelanda")
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
--------------------------------------------------------------------------------------------
--	Additional enemy ships with some modifications from the original template parameters  --
--------------------------------------------------------------------------------------------
function farco3(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 3")
			farco_3_db = queryScienceDatabase("Ships","Frigate","Farco 3")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_3_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 3, the beams are longer and faster and the shields are slightly stronger."),
				{
					{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 5")
			farco_5_db = queryScienceDatabase("Ships","Frigate","Farco 5")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_5_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 5, the tubes load faster and the shields are slightly stronger."),
				{
					{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco8(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 8")
			farco_8_db = queryScienceDatabase("Ships","Frigate","Farco 8")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_8_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 8, the beams are longer and faster, the tubes load faster and the shields are stronger."),
				{
					{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco11(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 11")
			farco_11_db = queryScienceDatabase("Ships","Frigate","Farco 11")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_11_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 11, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam and the shields are stronger."),
				{
					{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function farco13(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Farco 13")
			farco_13_db = queryScienceDatabase("Ships","Frigate","Farco 13")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				farco_13_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 13, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam, the tubes load faster, there are more missiles and the shields are stronger."),
				{
					{key = "Tube -1", value = "30 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "30 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function whirlwind(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Storm")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Whirlwind")
			whirlwind_db = queryScienceDatabase("Ships","Frigate","Whirlwind")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Storm"),	--base ship database entry
				whirlwind_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Whirlwind, another heavy artillery cruiser, takes the Storm and adds tubes and missiles. It's as if the Storm swallowed a Pirahna and grew gills. Expect to see missiles, lots of missiles"),
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
	end
	return ship
end
function phobosR2(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Phobos R2")
			phobos_r2_db = queryScienceDatabase("Ships","Frigate","Phobos R2")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				phobos_r2_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube"),
				{
					{key = "Tube 0", value = "60 sec"},	--torpedo tube direction and load speed
				},
				nil
			)
		end
	end
	return ship
end
function hornetMV52(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("MT52 Hornet")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("MV52 Hornet")
			hornet_mv52_db = queryScienceDatabase("Ships","Starfighter","MV52 Hornet")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","MT52 Hornet"),	--base ship database entry
				hornet_mv52_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The MV52 Hornet is very similar to the MT52 and MU52 models. The beam does more damage than both of the other Hornet models, it's max impulse speed is faster than both of the other Hornet models, it turns faster than the MT52, but slower than the MU52"),
				nil,
				nil
			)
		end
	end
	return ship
end
function k2fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName("K2 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	local k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
	if k2_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("K2 Fighter")
			k2_fighter_db = queryScienceDatabase("Ships","No Class","K2 Fighter")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
				k2_fighter_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that cycle faster, but the hull is a bit weaker."),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end	
function k3fighter(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName("K3 Fighter")
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 9)	--beams cycle faster and damage more (vs 4.0 & 6)
	ship:setHullMax(60)								--weaker hull (vs 70)
	ship:setHull(60)
	local k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
	if k3_fighter_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("K3 Fighter")
			k3_fighter_db = queryScienceDatabase("Ships","No Class","K3 Fighter")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Fighter"),	--base ship database entry
				k3_fighter_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Enterprising designers published this design specification based on salvaged Ktlitan Fighters. Comparatively, it's got beams that are stronger and that cycle faster, but the hull is weaker."),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end	
function waddle5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("Waddle 5")
			waddle_5_db = queryScienceDatabase("Ships","Starfighter","Waddle 5")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
				waddle_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5"),
				{
					{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function jade5(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("Jade 5")
			jade_5_db = queryScienceDatabase("Ships","Starfighter","Jade 5")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","Adder MK5"),	--base ship database entry
				jade_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5"),
				{
					{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
				},
				"5 - 35 U"		--jump range
			)
		end
	end
	return ship
end
function droneLite(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Lite Drone")
	ship:setHullMax(20)					--weaker hull (vs 30)
	ship:setHull(20)
	ship:setImpulseMaxSpeed(130)		--faster impulse (vs 120)
	ship:setRotationMaxSpeed(20)		--faster maneuver (vs 10)
	ship:setBeamWeapon(0,40,0,600,4,4)	--weaker (vs 6) beam
	local drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
	if drone_lite_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Lite Drone")
			drone_lite_db = queryScienceDatabase("Ships","No Class","Lite Drone")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
				drone_lite_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The light drone was pieced together from scavenged parts of various damaged Ktlitan drones. Compared to the Ktlitan drone, the lite drone has a weaker hull, and a weaker beam, but a faster turn and impulse speed"),
				nil,
				nil
			)
		end
	end
	return ship
end
function droneHeavy(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
	ship:setTypeName("Heavy Drone")
	ship:setHullMax(40)					--stronger hull (vs 30)
	ship:setHull(40)
	ship:setImpulseMaxSpeed(110)		--slower impulse (vs 120)
	ship:setBeamWeapon(0,40,0,600,4,8)	--stronger (vs 6) beam
	local drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
	if drone_heavy_db == nil then
		local no_class_db = queryScienceDatabase("Ships","No Class")
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Heavy Drone")
			drone_heavy_db = queryScienceDatabase("Ships","No Class","Heavy Drone")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
				drone_heavy_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The heavy drone has a stronger hull and a stronger beam than the normal Ktlitan Drone, but it also moves slower"),
				nil,
				nil
			)
		end
	end
	return ship
end
function droneJacket(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Jacket Drone")
			drone_jacket_db = queryScienceDatabase("Ships","No Class","Jacket Drone")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Ktlitan Drone"),	--base ship database entry
				drone_jacket_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Jacket Drone is a Ktlitan Drone with a shield. It's also slightly slower and has a slightly weaker beam due to the energy requirements of the added shield"),
				nil,
				nil
			)
		end
	end
	return ship
end
function wzLindworm(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("WX-Lindworm")
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
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry("WZ-Lindworm")
			wz_lindworm_db = queryScienceDatabase("Ships","Starfighter","WZ-Lindworm")
			addShipToDatabase(
				queryScienceDatabase("Ships","Starfighter","WX-Lindworm"),	--base ship database entry
				wz_lindworm_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop."),
				{
					{key = "Small tube 0", value = "15 sec"},	--torpedo tube direction and load speed
					{key = "Small tube 1", value = "15 sec"},	--torpedo tube direction and load speed
					{key = "Small tube -1", value = "15 sec"},	--torpedo tube direction and load speed
				},
				nil
			)
		end
	end
	return ship
end
function tempest(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F12")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Tempest")
			tempest_db = queryScienceDatabase("Ships","Frigate","Tempest")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Piranha F12"),	--base ship database entry
				tempest_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!"),
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
	end
	return ship
end
function enforcer(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Blockade Runner")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Enforcer")
	ship:setRadarTrace("ktlitan_destroyer.png")			--different radar trace
	ship:setWarpDrive(true)										--warp (vs none)
	ship:setWarpSpeed(600)
	ship:setImpulseMaxSpeed(100)								--faster impulse (vs 60)
	ship:setRotationMaxSpeed(20)								--faster maneuver (vs 15)
	ship:setShieldsMax(200,100,100)								--stronger shields (vs 100,150)
	ship:setShields(200,100,100)					
	ship:setHullMax(100)										--stronger hull (vs 70)
	ship:setHull(100)
--				   Index,  Arc,	  Dir, Range,	Cycle,	Damage
	ship:setBeamWeapon(0,	30,	    5,	1500,		6,		10)	--narrower (vs 60), longer (vs 1000), stronger (vs 8)
	ship:setBeamWeapon(1,	30,	   -5,	1500,		6,		10)
	ship:setBeamWeapon(2,	 0,	    0,	   0,		0,		 0)	--fewer (vs 4)
	ship:setBeamWeapon(3,	 0,	    0,	   0,		0,		 0)
	ship:setWeaponTubeCount(3)									--more (vs 0)
	ship:setTubeSize(0,"large")									--large (vs normal)
	ship:setWeaponTubeDirection(1,-15)				
	ship:setWeaponTubeDirection(2, 15)				
	ship:setTubeLoadTime(0,18)
	ship:setTubeLoadTime(1,12)
	ship:setTubeLoadTime(2,12)			
	ship:setWeaponStorageMax("Homing",18)						--more (vs 0)
	ship:setWeaponStorage("Homing", 18)
	local enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
	if enforcer_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Enforcer")
			enforcer_db = queryScienceDatabase("Ships","Frigate","Enforcer")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Blockade Runner"),	--base ship database entry
				enforcer_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and strengthened front beams."),
				{
					{key = "Large tube 0", value = "18 sec"},	--torpedo tube direction and load speed
					{key = "Tube -15", value = "12 sec"},		--torpedo tube direction and load speed
					{key = "Tube 15", value = "12 sec"},		--torpedo tube direction and load speed
				},
				nil
			)
			enforcer_db:setImage("radar/ktlitan_destroyer.png")		--override default radar image
		end
	end
	return ship		
end
function predator(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8")
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
	ship:setRadarTrace("missile_cruiser.png")				--different radar trace
	local predator_db = queryScienceDatabase("Ships","Frigate","Predator")
	if predator_db == nil then
		local frigate_db = queryScienceDatabase("Ships","Frigate")
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Predator")
			predator_db = queryScienceDatabase("Ships","Frigate","Predator")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Piranha F8"),	--base ship database entry
				predator_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot."),
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
			predator_db:setImage("radar/missile_cruiser.png")		--override default radar image
			predator_db:setModelDataName("HeavyCorvetteRed")
		end
	end
	return ship		
end
function atlantisY42(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Atlantis X23")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Atlantis Y42")
			atlantis_y42_db = queryScienceDatabase("Ships","Corvette","Atlantis Y42")
			addShipToDatabase(
				queryScienceDatabase("Ships","Corvette","Atlantis X23"),	--base ship database entry
				atlantis_y42_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock"),
				{
					{key = "Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
					{key = " Tube -90", value = "10 sec"},	--torpedo tube direction and load speed
					{key = "Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
					{key = " Tube 90", value = "10 sec"},	--torpedo tube direction and load speed
				},
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship		
end
function starhammerV(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Starhammer V")
			starhammer_v_db = queryScienceDatabase("Ships","Corvette","Starhammer V")
			addShipToDatabase(
				queryScienceDatabase("Ships","Corvette","Starhammer II"),	--base ship database entry
				starhammer_v_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with."),
				{
					{key = "Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
					{key = " Tube 0", value = "10 sec"},	--torpedo tube direction and load speed
				},
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship		
end
function tyr(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Battlestation")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Tyr")
			tyr_db = queryScienceDatabase("Ships","Dreadnought","Tyr")
			addShipToDatabase(
				queryScienceDatabase("Ships","Dreadnought","Battlestation"),	--base ship database entry
				tyr_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Tyr is the shipyard's answer to admiral Konstatz' casual statement that the Battlestation model was too slow to be effective. The shipyards improved on the Battlestation by fitting the Tyr with more than twice the impulse speed and more than six times the turn speed. They threw in stronger shields and hull and wider beam coverage just to show that they could"),
				nil,
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship
end
function gnat(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Drone")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Gnat")
			gnat_db = queryScienceDatabase("Ships","No Class","Gnat")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Gnat"),	--base ship database entry
				gnat_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Gnat is a nimbler version of the Ktlitan Drone. It's got half the hull, but it moves and turns faster"),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end
function cucaracha(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Tug")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("Cucaracha")
			cucaracha_db = queryScienceDatabase("Ships","No Class","Cucaracha")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","Cucaracha"),	--base ship database entry
				cucaracha_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Cucaracha is a quick ship built around the Tug model with heavy shields and a heavy beam designed to be difficult to squash"),
				nil,
				nil		--jump range
			)
		end
	end
	return ship
end
function starhammerIII(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Starhammer II")
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
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry("Starhammer III")
			starhammer_iii_db = queryScienceDatabase("Ships","Corvette","Starhammer III")
			addShipToDatabase(
				queryScienceDatabase("Ships","Corvette","Starhammer III"),	--base ship database entry
				starhammer_iii_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The designers of the Starhammer III took the Starhammer II and added a rear facing beam, enlarged one of the missile tubes and added more missiles to fire"),
				{
					{key = "Large tube 0", value = "10 sec"},	--torpedo tube direction and load speed
					{key = "Tube 0", value = "10 sec"},			--torpedo tube direction and load speed
				},
				"5 - 50 U"		--jump range
			)
		end
	end
	return ship
end
function k2breaker(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Breaker")
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
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry("K2 Breaker")
			k2_breaker_db = queryScienceDatabase("Ships","No Class","K2 Breaker")
			addShipToDatabase(
				queryScienceDatabase("Ships","No Class","K2 Breaker"),	--base ship database entry
				k2_breaker_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The K2 Breaker designers took the Ktlitan Breaker and beefed up the hull, added two bracketing tubes, enlarged the center tube and added more missiles to shoot. Should be good for a couple of enemy ships"),
				{
					{key = "Large tube 0", value = "13 sec"},	--torpedo tube direction and load speed
					{key = "Tube -30", value = "13 sec"},		--torpedo tube direction and load speed
					{key = "Tube 30", value = "13 sec"},		--torpedo tube direction and load speed
				},
				nil
			)
		end
	end
	return ship
end
function hurricane(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Piranha F8")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Hurricane")
			hurricane_db = queryScienceDatabase("Ships","Frigate","Hurricane")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Hurricane"),	--base ship database entry
				hurricane_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Hurricane is designed to jump in and shower the target with missiles. It is based on the Piranha F8, but with a jump drive, five more tubes in various directions and sizes and lots more missiles to shoot"),
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
	end
	return ship
end
function phobosT4(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Phobos T3")
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
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry("Phobos T4")
			phobos_t4_db = queryScienceDatabase("Ships","Frigate","Phobos T4")
			addShipToDatabase(
				queryScienceDatabase("Ships","Frigate","Phobos T3"),	--base ship database entry
				phobos_t4_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Phobos T4 makes some simple improvements on the Phobos T3: faster maneuver, stronger front shields, though weaker rear shields and longer and faster beam weapons"),
				{
					{key = "Tube -1", value = "60 sec"},	--torpedo tube direction and load speed
					{key = "Tube 1", value = "60 sec"},		--torpedo tube direction and load speed
				},
				nil		--jump range
			)
		end
	end
	return ship
end
function serviceJonque(enemyFaction)
	local ship = CpuShip():setTemplate("Garbage Jump Freighter 4")
	if enemyFaction ~= nil then
		ship:setFaction(enemyFaction)
	end
	ship:setTypeName("Service Jonque"):setCommsScript(""):setCommsFunction(commsServiceJonque)
	addFreighter("Service Jonque",ship)	--update science database if applicable
	return ship
end
function genericFreighterScienceInfo(specific_freighter_db,base_db,ship)
	specific_freighter_db:setImage("radar/transport.png")
	specific_freighter_db:setKeyValue("Sub-class","Freighter")
	specific_freighter_db:setKeyValue("Size",base_db:getKeyValue("Size"))
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
		specific_freighter_db:setKeyValue("Shield",shield_string)
	end
	specific_freighter_db:setKeyValue("Hull",string.format("%i",math.floor(ship:getHullMax())))
	specific_freighter_db:setKeyValue("Move speed",string.format("%.1f u/min",ship:getImpulseMaxSpeed()*60/1000))
	specific_freighter_db:setKeyValue("Turn speed",string.format("%.1f deg/sec",ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		local base_jump_range = base_db:getKeyValue("Jump range")
		if base_jump_range ~= nil and base_jump_range ~= "" then
			specific_freighter_db:setKeyValue("Jump range",base_jump_range)
		else
			specific_freighter_db:setKeyValue("Jump range","5 - 50 u")
		end
	end
	if ship:hasWarpDrive() then
		specific_freighter_db:setKeyValue("Warp Speed",string.format("%.1f u/min",ship:getWarpSpeed()*60/1000))
	end
end
function addFreighters()
	local freighter_db = queryScienceDatabase("Ships","Freighter")
	if freighter_db == nil then
		local ship_db = queryScienceDatabase("Ships")
		ship_db:addEntry("Freighter")
		freighter_db = queryScienceDatabase("Ships","Freighter")
		freighter_db:setImage("radar/transport.png")
		freighter_db:setLongDescription(_("scienceDB","Small, medium and large scale transport ships. These are the working ships that keep commerce going in any sector. They may carry personnel, goods, cargo, equipment, garbage, fuel, research material, etc."))
	end
	return freighter_db
end
function addFreighter(freighter_type,ship)
	local freighter_db = addFreighters()
	if freighter_type ~= nil then
		if freighter_type == "Space Sedan" then
			local space_sedan_db = queryScienceDatabase("Ships","Freighter","Space Sedan")
			if space_sedan_db == nil then
				freighter_db:addEntry("Space Sedan")
				space_sedan_db = queryScienceDatabase("Ships","Freighter","Space Sedan")
				genericFreighterScienceInfo(space_sedan_db,queryScienceDatabase("Ships","Corvette","Personnel Jump Freighter 3"),ship)
				space_sedan_db:setModelDataName("transport_1_3")
				space_sedan_db:setLongDescription("The Space Sedan was built around a surplus Personnel Jump Freighter 3. It's designed to provide relatively low cost transportation primarily for people, but there is also a limited amount of cargo space available")
			end
		elseif freighter_type == "Omnibus" then
			local omnibus_db = queryScienceDatabase("Ships","Freighter","Omnibus")
			if omnibus_db == nil then
				freighter_db:addEntry("Omnibus")
				omnibus_db = queryScienceDatabase("Ships","Freighter","Omnibus")
				genericFreighterScienceInfo(omnibus_db,queryScienceDatabase("Ships","Corvette","Personnel Jump Freighter 5"),ship)
				omnibus_db:setModelDataName("transport_1_5")
				omnibus_db:setLongDescription("The Omnibus was designed from the Personnel Jump Freighter 5. It's made to transport large numbers of passengers of various types along with their luggage and any associated cargo")
			end
		elseif freighter_type == "Service Jonque" then
			local service_jonque_db = queryScienceDatabase("Ships","Freighter","Service Jonque")
			if service_jonque_db == nil then
				freighter_db:addEntry("Service Jonque")
				service_jonque_db = queryScienceDatabase("Ships","Freighter","Service Jonque")
				genericFreighterScienceInfo(service_jonque_db,queryScienceDatabase("Ships","Corvette","Equipment Jump Freighter 4"),ship)
				service_jonque_db:setModelDataName("transport_4_4")
				service_jonque_db:setLongDescription(_("scienceDB","The Service Jonque is a modified Equipment Jump Freighter 4. It's designed to carry spare parts and equipment as well as the necessary repair personnel to where it's needed to repair stations and ships"))
			end
		elseif freighter_type == "Courier" then
			local courier_db = queryScienceDatabase("Ships","Freighter","Courier")
			if courier_db == nil then
				freighter_db:addEntry("Courier")
				courier_db = queryScienceDatabase("Ships","Freighter","Courier")
				genericFreighterScienceInfo(courier_db,queryScienceDatabase("Ships","Corvette","Personnel Freighter 1"),ship)
				courier_db:setModelDataName("transport_1_1")
				courier_db:setLongDescription("The Courier is a souped up Personnel Freighter 1. It's made to deliver people and messages fast. Very fast")
			end
		elseif freighter_type == "Work Wagon" then
			local work_wagon_db = queryScienceDatabase("Ships","Freighter","Work Wagon")
			if work_wagon_db == nil then
				freighter_db:addEntry("Work Wagon")
				work_wagon_db = queryScienceDatabase("Ships","Freighter","Work Wagon")
				genericFreighterScienceInfo(work_wagon_db,queryScienceDatabase("Ships","Corvette","Equipment Freighter 2"),ship)
				work_wagon_db:setModelDataName("transport_4_2")
				work_wagon_db:setLongDescription("The Work Wagon is a conversion of an Equipment Freighter 2 designed to carry equipment and parts where they are needed for repair or construction.")
			end
		elseif freighter_type == "Laden Lorry" then
			local laden_lorry_db = queryScienceDatabase("Ships","Freighter","Laden Lorry")
			if laden_lorry_db == nil then
				freighter_db:addEntry("Laden Lorry")
				laden_lorry_db = queryScienceDatabase("Ships","Freighter","Laden Lorry")
				genericFreighterScienceInfo(laden_lorry_db,queryScienceDatabase("Ships","Corvette","Goods Freighter 3"),ship)
				laden_lorry_db:setModelDataName("transport_2_3")
				laden_lorry_db:setLongDescription("As a side contract, Conversion R Us put together the Laden Lorry from some recently acquired Goods Freighter 3 hulls. The added warp drive makes for a more versatile goods carrying vessel.")
			end
		elseif freighter_type == "Physics Research" then
			local physics_research_db = queryScienceDatabase("Ships","Freighter","Physics Research")
			if physics_research_db == nil then
				freighter_db:addEntry("Physics Research")
				physics_research_db = queryScienceDatabase("Ships","Freighter","Physics Research")
				genericFreighterScienceInfo(physics_research_db,queryScienceDatabase("Ships","Corvette","Garbage Freighter 3"),ship)
				physics_research_db:setModelDataName("transport_3_3")
				physics_research_db:setLongDescription("Conversion R Us cleaned up and converted excess freighter hulls into Physics Research vessels. The reduced weight improved the impulse speed and maneuverability.")
			end
		end
	end
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
		local count_repeat_loop = 0
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
			count_repeat_loop = count_repeat_loop + 1
		until(ship:getBeamWeaponRange(bi) < 1 or count_repeat_loop > max_repeat_loop)
		if count_repeat_loop > max_repeat_loop then
			print("repeated too many times when going through beams")
		end
	end
	local tubes = ship:getWeaponTubeCount()
	if tubes > 0 then
		if tube_directions ~= nil then
			for i=1,#tube_directions do
				modified_db:setKeyValue(tube_directions[i].key,tube_directions[i].value)
			end
		end
		local missile_types = {'Homing', 'Nuke', 'Mine', 'EMP', 'HVLI'}
		for index, missile_type in ipairs(missile_types) do
			local max_storage = ship:getWeaponStorageMax(missile_type)
			if max_storage > 0 then
				modified_db:setKeyValue(string.format("Storage %s",missile_type),string.format("%i",max_storage))
			end
		end
	end
end
----------------------------------------------------------------------------------------
--	Additional player ships with modifications from the original template parameters  --
----------------------------------------------------------------------------------------
function createPlayerShipMixer()
	playerAmalgam = PlayerSpaceship():setTemplate("Atlantis"):setFaction("Human Navy"):setCallSign("Mixer")
	playerAmalgam:setTypeName("Amalgam")
	playerAmalgam:setRepairCrewCount(5)					--more repair crew (vs 3)
	playerAmalgam.max_jump_range = 40000				--shorter (vs 50)
	playerAmalgam.min_jump_range = 4000					--shorter (vs 5)
	playerAmalgam:setJumpDriveRange(playerAmalgam.min_jump_range,playerAmalgam.max_jump_range)
	playerAmalgam:setJumpDriveCharge(playerAmalgam.max_jump_range)
	playerAmalgam:setImpulseMaxSpeed(80)				--slower (vs 90)
	playerAmalgam:setRotationMaxSpeed(8)				--slower (vs 10)
	playerAmalgam:setShieldsMax(150,150)				--weaker shields (vs 200)
	playerAmalgam:setShields(150,150)
--								  Arc, Dir, Range, CycleTime, Dmg
	playerAmalgam:setBeamWeapon(0, 90, -20,  1200,         6, 8)	--narrower (vs 100), shorter (vs 1500)
	playerAmalgam:setBeamWeapon(1, 90,  20,  1200,         6, 8)	--narrower (vs 100), shorter (vs 1500)
	playerAmalgam:setBeamWeapon(2, 10, -60,  1000,         4, 6)	--additional beam
	playerAmalgam:setBeamWeapon(3, 10,  60,  1000,         4, 6)	--additional beam
--											Arc,  Dir, Rotate speed
	playerAmalgam:setBeamWeaponTurret(2,	 60,  -60,			.6)
	playerAmalgam:setBeamWeaponTurret(3,	 60,   60,			.6)
	playerAmalgam:setWeaponTubeCount(4)					--2 fewer broadside, 1 extra mine (vs 5)
	playerAmalgam:setWeaponTubeDirection(1, 90)			--mine tube points right (vs left)
	playerAmalgam:setWeaponTubeDirection(2, 180)		--mine tube points back (vs right)
	playerAmalgam:setWeaponTubeDirection(3, 180)		--mine tube points back (vs right)
	playerAmalgam:setWeaponTubeExclusiveFor(0,"Homing")	--homing only (vs any)
	playerAmalgam:setWeaponTubeExclusiveFor(1,"Homing")	--homing only (vs any)
	playerAmalgam:setWeaponTubeExclusiveFor(2,"Mine")	--mine only (vs any)
	playerAmalgam:setWeaponTubeExclusiveFor(3,"Mine")	--mine only (vs any)
	playerAmalgam:setTubeLoadTime(2,16)					--rear tube slower (vs 8)
	playerAmalgam:setTubeLoadTime(3,16)					--rear tube slower (vs 8)
	playerAmalgam:setTubeSize(0,"large")				--left tube large (vs normal)
	playerAmalgam:setTubeSize(1,"large")				--right tube large (vs normal)
	playerAmalgam:setWeaponStorageMax("Homing", 16)		--more (vs 12)
	playerAmalgam:setWeaponStorage("Homing", 16)				
	playerAmalgam:setWeaponStorageMax("Nuke", 0)		--less (vs 4)
	playerAmalgam:setWeaponStorage("Nuke", 0)				
	playerAmalgam:setWeaponStorageMax("Mine", 10)		--more (vs 8)
	playerAmalgam:setWeaponStorage("Mine", 10)				
	playerAmalgam:setWeaponStorageMax("EMP", 0)			--less (vs 6)
	playerAmalgam:setWeaponStorage("EMP", 0)				
	playerAmalgam:setWeaponStorageMax("HVLI", 0)		--less (vs 20)
	playerAmalgam:setWeaponStorage("HVLI", 0)
	return playerAmalgam
end
function createPlayerShipFlipper()
	playerFlipper = PlayerSpaceship():setTemplate("Player Missile Cr."):setFaction("Human Navy"):setCallSign("Flipper")
	playerFlipper:setTypeName("Midian")
	playerFlipper:setRadarTrace("cruiser.png")	--different radar trace
	playerFlipper:setWarpSpeed(320)
--                  				Arc, Dir, Range, CycleTime, Dmg
	playerFlipper:setBeamWeapon(0,   50, -20,  1000, 	     6, 4)	--beams (vs none)
	playerFlipper:setBeamWeapon(1,   50,  20,  1000, 	     6, 4)
	playerFlipper:setBeamWeapon(2,   10, 180,  1000, 	     6, 2)
--									     Arc, Dir, Rotate speed
	playerFlipper:setBeamWeaponTurret(2, 220, 180, .3)
	playerFlipper:setWeaponTubeCount(5)					--fewer (vs 7)
	playerFlipper:setWeaponTubeDirection(0,-2)			--angled (vs front)
	playerFlipper:setWeaponTubeDirection(1, 2)			--angled (vs front)
	playerFlipper:setWeaponTubeDirection(2,-90)			--left (vs right)
	playerFlipper:setWeaponTubeDirection(4,180)			--rear (vs left)
	playerFlipper:setTubeSize(0,"small")				--small vs medium
	playerFlipper:setTubeSize(1,"small")				--small vs medium
	playerFlipper:setWeaponTubeExclusiveFor(0,"Homing")	--homing only
	playerFlipper:setWeaponTubeExclusiveFor(1,"Homing")	--homing only
	playerFlipper:setWeaponTubeExclusiveFor(2,"HVLI")
	playerFlipper:setWeaponTubeExclusiveFor(3,"HVLI")
	playerFlipper:setWeaponTubeExclusiveFor(4,"Mine")
	playerFlipper:weaponTubeAllowMissle(2,"EMP")
	playerFlipper:weaponTubeAllowMissle(3,"EMP")
	playerFlipper:weaponTubeAllowMissle(2,"Nuke")
	playerFlipper:weaponTubeAllowMissle(3,"Nuke")
	playerFlipper:setTubeLoadTime(2,12)
	playerFlipper:setTubeLoadTime(3,12)
	playerFlipper:setTubeLoadTime(4,15)
	playerFlipper:setWeaponStorageMax("Homing",16)		--less (vs 30)
	playerFlipper:setWeaponStorage("Homing",   16)				
	playerFlipper:setWeaponStorageMax("Nuke",   2)		--less (vs 8)
	playerFlipper:setWeaponStorage("Nuke",      2)				
	playerFlipper:setWeaponStorageMax("EMP",    5)		--less (vs 10)
	playerFlipper:setWeaponStorage("EMP",       5)				
	playerFlipper:setWeaponStorageMax("Mine",   5)		--less (vs 12)
	playerFlipper:setWeaponStorage("Mine",      5)				
	playerFlipper:setWeaponStorageMax("HVLI",  16)		--more (vs 0)
	playerFlipper:setWeaponStorage("HVLI",     16)
	playerFlipper.smallHomingOnly = true
	return playerFlipper
end
function createPlayerShipInk()
	playerInk = PlayerSpaceship():setTemplate("Piranha"):setFaction("Human Navy"):setCallSign("Ink")
	playerInk:setTypeName("Squid")
	playerInk:setRepairCrewCount(5)					--more repair crew (vs 2)
	playerInk:setShieldsMax(100, 100)				--stronger shields (vs 70, 70)
	playerInk:setShields(100, 100)
	playerInk:setHullMax(130)						--stronger (vs 120)
	playerInk:setHull(130)							
	playerInk.max_jump_range = 20000				--shorter than typical (vs 50)
	playerInk.min_jump_range = 2000					--shorter than typical (vs 5)
	playerInk:setJumpDriveRange(playerInk.min_jump_range,playerInk.max_jump_range)
	playerInk:setJumpDriveCharge(playerInk.max_jump_range)
--                 				 Arc, Dir, Range, CycleTime, Damage
	playerInk:setBeamWeapon(0, 10,	0,	1000,		4,		4)		--one beam (vs 0)
--									   Arc,	  Dir, Rotate speed
	playerInk:setBeamWeaponTurret(0,	80,		0,		1)			--slow turret 
	playerInk:setWeaponTubeDirection(0,0)					--forward facing (vs left)
	playerInk:setWeaponTubeDirection(3,0)					--forward facing (vs right)
	playerInk:setTubeLoadTime(0,12)							--slower (vs 8)
	playerInk:setTubeLoadTime(3,12)							--slower (vs 8)
	playerInk:setWeaponTubeExclusiveFor(2,"Homing")			--homing only (vs HVLI)
	playerInk:setWeaponTubeExclusiveFor(5,"Homing")			--homing only (vs HVLI)
	playerInk:setTubeLoadTime(2,10)							--slower (vs 8)
	playerInk:setTubeLoadTime(5,10)							--slower (vs 8)
	playerInk:setTubeLoadTime(6,15)							--slower (vs 8)
	playerInk:setTubeLoadTime(7,15)							--slower (vs 8)
	playerInk:setWeaponTubeExclusiveFor(0,"HVLI")			--HVLI only (vs Homing + HVLI)
	playerInk:setWeaponTubeExclusiveFor(3,"HVLI")			--HVLI only (vs Homing + HVLI)
	playerInk:weaponTubeDisallowMissle(1,"Mine")			--no sideways mines
	playerInk:weaponTubeDisallowMissle(4,"Mine")			--no sideways mines
	playerInk:setWeaponStorageMax("HVLI",10)				--fewer HVLI (vs 20)
	playerInk:setWeaponStorage("HVLI", 10)				
	playerInk:setWeaponStorageMax("Homing",10)				--fewer Homing (vs 12)
	playerInk:setWeaponStorage("Homing", 10)				
	playerInk:setWeaponStorageMax("Mine",6)					--fewer mines (vs 8)
	playerInk:setWeaponStorage("Mine", 6)				
	playerInk:setWeaponStorageMax("EMP",4)					--more EMPs (vs 0)
	playerInk:setWeaponStorage("EMP", 4)					
	playerInk:setWeaponStorageMax("Nuke",4)					--fewer Nukes (vs 6)
	playerInk:setWeaponStorage("Nuke", 4)				
	playerInk:setLongRangeRadarRange(25000)					--shorter long range sensors (vs 30000)
	playerInk.normal_long_range_radar = 25000
	return playerInk
end
function createPlayerShipClaw()
	playerRaven = PlayerSpaceship():setTemplate("Player Cruiser"):setFaction("Human Navy"):setCallSign("Claw")
	playerRaven:setTypeName("Raven")
	playerRaven:setJumpDrive(false)						
	playerRaven:setWarpDrive(true)						--warp drive (vs jump)
	playerRaven:setWarpSpeed(300)
	playerRaven:setShieldsMax(100, 100)					--stronger shields (vs 80, 80)
	playerRaven:setShields(100, 100)
	playerRaven:setHullMax(150)							--weaker hull (vs 200)
	playerRaven:setHull(150)
--                 				 Arc, Dir, Range,   CycleTime,  Damage
	playerRaven:setBeamWeapon(0,  10, -90,	 900, 			6,	10)	--left (vs front) shorter (vs 1000)
	playerRaven:setBeamWeapon(1,  10,  90,	 900, 			6,	10)	--right (vs front) shorter (vs 1000)
--										Arc,  Dir, Rotate speed
	playerRaven:setBeamWeaponTurret(0,	 90,  -90,			1)	
	playerRaven:setBeamWeaponTurret(1,	 90,   90,			1)	
	playerRaven:setWeaponTubeCount(6)					--more (vs 3)
	playerRaven:setWeaponTubeDirection(0, -30)			--more angled (vs -5)
	playerRaven:setWeaponTubeDirection(1,  30)			--more angled (vs 5)
	playerRaven:setTubeSize(0,"small")					--small (vs medium)
	playerRaven:setTubeSize(1,"small")					--small (vs medium)
	playerRaven:setWeaponTubeExclusiveFor(0,"Nuke")		--Nuke only (vs all but mine)
	playerRaven:setWeaponTubeExclusiveFor(1,"Nuke")		--Nuke only (vs all but mine)
	playerRaven:setWeaponTubeDirection(2, -60)			
	playerRaven:setWeaponTubeDirection(3,  60)
	playerRaven:setTubeSize(2,"small")
	playerRaven:setTubeSize(3,"small")
	playerRaven:setWeaponTubeExclusiveFor(2,"EMP")
	playerRaven:setWeaponTubeExclusiveFor(3,"EMP")
	playerRaven:setTubeLoadTime(4, 12)					--slower (vs 8)
	playerRaven:setTubeSize(4,"large")
	playerRaven:setWeaponTubeExclusiveFor(4,"Homing")
	playerRaven:setWeaponTubeDirection(5, 180)
	playerRaven:setTubeLoadTime(5, 10)					--slower (vs 8)
	playerRaven:setWeaponTubeExclusiveFor(5,"Mine")
	playerRaven:setWeaponStorageMax("Homing",4)			--less (vs 12)
	playerRaven:setWeaponStorage("Homing",4)
	playerRaven:setWeaponStorageMax("EMP",4)			--less (vs 6)
	playerRaven:setWeaponStorage("EMP",4)
	playerRaven:setWeaponStorageMax("Mine",4)			--less (vs 8)
	playerRaven:setWeaponStorage("Mine",4)
	return playerRaven
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
function freighterMessage()
	if getScenarioTime() > 5 then
		local player_list = getActivePlayerShips()
		for index, p in ipairs(player_list) do
			if p.protect_freighter_message == nil then
				station_regional_hq:sendCommsMessage(p,string.format(_("mission1st-incCall","To: %s\nFrom: %s\n\nGreetings %s,\n\nPlease ensure the safe arrival of freighter %s at %s. Looks like the Exuari might attack them."),p:getCallSign(),station_regional_hq:getCallSign(),p:getCallSign(),critical_transport:getCallSign(),station_regional_hq:getCallSign()))
				p.protect_freighter_message = "sent"
			end
		end
		mainLinearPlot = checkFreighter
	end
end
function checkFreighter()
	if critical_transport == nil then
		loseGame(_("msgMainscreen","The freighter blew up"))
	else
		if critical_transport:isValid() then
			if station_regional_hq == nil then
				loseGame(_("msgMainscreen","Regional headquarters blew up"))
			else
				if station_regional_hq:isValid() then
					if critical_transport:isDocked(station_regional_hq) then
						local p = getPlayerShip(-1)
						p:addReputationPoints(20)
						freighter_saved = true
						mainLinearPlot = freighterSafeMessage
					end
					if critical_transport.engine_trouble == nil then
						if distance(critical_transport,station_regional_hq) < (5000 + (2500 * difficulty)) then
							for pidx, p in ipairs(getActivePlayerShips()) do
								critical_transport:sendCommsMessage(p,string.format(_("incCall","To: %s\nFrom: %s\n\n%s,\n\nOur engines just conked out and the only person we have that can fix them is too sick to work on them. Can you send over one of you repair crew to help us, please?"),p:getCallSign(),critical_transport:getCallSign(),p:getCallSign()))
								p.send_repair_crew_to_freighter_eng = "send_repair_crew_to_freighter_eng"
								p:addCustomButton("Engineering",p.send_repair_crew_to_freighter_eng,_("buttonEngineer","Send Repair Crew"),function()
									string.format("")
									sendRepairCrewToFreighter(p)
								end)
								p.send_repair_crew_to_freighter_plus = "send_repair_crew_to_freighter_plus"
								p:addCustomButton("Engineering+",p.send_repair_crew_to_freighter_plus,_("buttonEngineer+","Send Repair Crew"),function()
									string.format("")
									sendRepairCrewToFreighter(p)
								end)
							end
							critical_transport:setSystemHealthMax("impulse",.01)
							critical_transport:setSystemHealthMax("jumpdrive",.01)
							critical_transport.engine_trouble = "disabled"
						end
					elseif critical_transport.engine_trouble == "in work" then
						if getScenarioTime() > critical_transport.engine_repair_complete_timer then
							critical_transport:setSystemHealthMax("impulse",1)
							critical_transport:setSystemHealthMax("jumpdrive",1)
							critical_transport:setSystemHealth("impulse",1)
							critical_transport:setSystemHealth("jumpdrive",1)
							critical_transport.engine_trouble = "fixed"
							getPlayerShip(-1):addReputationPoints(20)
							for pidx, p in ipairs(getActivePlayerShips()) do
								p:addToShipLog(string.format(_("shipLog","The engines on %s have been repaired"),critical_transport:getCallSign()),"Magenta")
							end
						end
					end
				else
					loseGame(_("msgMainscreen","Regional headquarters blew up"))
				end
			end
		else
			loseGame(_("msgMainscreen","The freighter blew up"))
		end
	end
end
function getRepairCrewFromFreighter(p)
	if critical_transport:isValid() then
		if getScenarioTime() > critical_transport.engine_repair_complete_timer then
			if distance(critical_transport,p) < 3000 then
				if p:getShieldsActive() then
					p.no_transport_through_shields_eng = "no_transport_through_shields_eng"
					p:addCustomMessage("Engineering",p.no_transport_through_shields_eng,string.format(_("msgEngineer","We cannot transport a repair crew member from %s while the shields are up."),critical_transport:getCallSign()))
					p.no_transport_through_shields_plus = "no_transport_through_shields_plus"
					p:addCustomMessage("Engineering+",p.no_transport_through_shields_plus,string.format(_("msgEngineer+","We cannot transport a repair crew member from %s while the shields are up."),critical_transport:getCallSign()))
				else
					local vx, vy = p:getVelocity()
					local player_velocity = math.sqrt((math.abs(vx)*math.abs(vx))+(math.abs(vy)*math.abs(vy)))
					if player_velocity > 1 then
						p.too_fast_to_transport_eng = "too_fast_to_transport_eng"
						p:addCustomMessage("Engineering",p.too_fast_to_transport_eng,string.format(_("msgEngineer","%s is moving too fast to transport a repair crew member from %s."),p:getCallSign(),critical_transport:getCallSign()))
						p.too_fast_to_transport_plus = "too_fast_to_transport_plus"
						p:addCustomMessage("Engineering+",p.too_fast_to_transport_plus,string.format(_("msgEngineer+","%s is moving too fast to transport a repair crew member from %s."),p:getCallSign(),critical_transport:getCallSign()))
					else
						p:setRepairCrewCount(p:getRepairCrewCount() + 1)
						p.repair_crew_returned_eng = "repair_crew_returned_eng"
						p:addCustomMessage("Engineering",p.repair_crew_returned_eng,string.format(_("msgEngineer","Repair crew member retrieved from %s"),critical_transport:getCallSign()))
						p.repair_crew_returned_plus = "repair_crew_returned_plus"
						p:addCustomMessage("Engineering+",p.repair_crew_returned_plus,string.format(_("msgEngineer+","Repair crew member retrieved from %s"),critical_transport:getCallSign()))
						for pidx2, p2 in ipairs(getActivePlayerShips()) do
							p2:removeCustom(p2.get_repair_crew_from_freighter_eng)
							p2:removeCustom(p2.get_repair_crew_from_freighter_plus)
						end
					end
				end
			else
				p.too_far_from_transport_eng = "too_far_from_transport_eng"
				p:addCustomMessage("Engineering",p.too_far_from_transport_eng,string.format(_("msgEngineer","%s is too far from %s to transport a repair crew member. Functional transport may occur at or under 3 units"),p:getCallSign(),critical_transport:getCallSign()))
				p.too_far_from_transport_plus = "too_far_from_transport_plus"
				p:addCustomMessage("Engineering+",p.too_far_from_transport_plus,string.format(_("msgEngineer+","%s is too far from %s to transport a repair crew member. Functional transport may occur at or under 3 units"),p:getCallSign(),critical_transport:getCallSign()))
			end
		else
			critical_transport.engine_repair_complete_timer = critical_transport.engine_repair_complete_timer + 10
			local estimated_time_remaining = critical_transport.engine_repair_complete_timer - getScenarioTime()
			local minutes_remain = math.floor(estimated_time_remaining / 60)
			local seconds_remain = math.floor(estimated_time_remaining % 60)
			local remain_status = _("msgEngineer","Estimated time remaining on repairs: ")
			if minutes_remain < 1 then
				remain_status = string.format(_("msgEngineer","%s %i seconds"),remain_status,seconds_remain)
			else
				if minutes_remain > 1 then
					remain_status = string.format(_("msgEngineer","%s %i minutes and %i seconds"),remain_status,minutes_remain,seconds_remain)
				else
					remain_status = string.format(_("msgEngineer","%s %i minute and %i seconds"),remain_status,minutes_remain,seconds_remain)
				end
			end
			p.not_done_yet_eng = "not_done_yet_eng"
			p:addCustomMessage("Engineering",p.not_done_yet_eng,string.format(_("msgEngineer","[Repair Crewmember on %s]\nWe're not done with engine repairs on %s yet.\n%s."),critical_transport:getCallSign(),critical_transport:getCallSign(),remain_status))
			p.not_done_yet_plus = "not_done_yet_plus"
			p:addCustomMessage("Engineering+",p.not_done_yet_plus,string.format(_("msgEngineer","[Repair Crewmember on %s]\nWe're not done with engine repairs on %s yet.\n%s."),critical_transport:getCallSign(),critical_transport:getCallSign(),remain_status))
		end
	end
end
function sendRepairCrewToFreighter(p)
	if critical_transport:isValid() then
		if distance(critical_transport,p) < 3000 then
			if p:getShieldsActive() then
				p.no_transport_through_shields_eng = "no_transport_through_shields_eng"
				p:addCustomMessage("Engineering",p.no_transport_through_shields_eng,string.format(_("msgEngineer","We cannot transport a repair crew member to %s while the shields are up."),critical_transport:getCallSign()))
				p.no_transport_through_shields_plus = "no_transport_through_shields_plus"
				p:addCustomMessage("Engineering+",p.no_transport_through_shields_plus,string.format(_("msgEngineer+","We cannot transport a repair crew member to %s while the shields are up."),critical_transport:getCallSign()))
			else
				local vx, vy = p:getVelocity()
				local player_velocity = math.sqrt((math.abs(vx)*math.abs(vx))+(math.abs(vy)*math.abs(vy)))
				if player_velocity > 1 then
					p.too_fast_to_transport_eng = "too_fast_to_transport_eng"
					p:addCustomMessage("Engineering",p.too_fast_to_transport_eng,string.format(_("msgEngineer","%s is moving too fast to transport a repair crew member to %s."),p:getCallSign(),critical_transport:getCallSign()))
					p.too_fast_to_transport_plus = "too_fast_to_transport_plus"
					p:addCustomMessage("Engineering+",p.too_fast_to_transport_plus,string.format(_("msgEngineer+","%s is moving too fast to transport a repair crew member to %s."),p:getCallSign(),critical_transport:getCallSign()))
				else
					if p:getRepairCrewCount() > 0 then
						p:setRepairCrewCount(p:getRepairCrewCount() - 1)
						critical_transport.engine_repair_complete_timer = getScenarioTime() + 90
						critical_transport.engine_trouble = "in work"
						for pidx, p2 in ipairs(getActivePlayerShips()) do
							p2:addToShipLog(string.format(_("shipLog","%s has transported one of her repair crew to %s. They report that the engines should be fixed in a minute or two."),p:getCallSign(),critical_transport:getCallSign()),"Magenta")
							p2:removeCustom(p2.send_repair_crew_to_freighter_eng)
							p2:removeCustom(p2.send_repair_crew_to_freighter_plus)
							p2.get_repair_crew_from_freighter_eng = "get_repair_crew_from_freighter_eng"
							p2:addCustomButton("Engineering",p2.get_repair_crew_from_freighter_eng,_("buttonEngineer","Get Repair Crew"),function()
								string.format("")
								getRepairCrewFromFreighter(p2)
							end)
							p2.get_repair_crew_from_freighter_plus = "get_repair_crew_from_freighter_plus"
							p2:addCustomButton("Engineering+",p2.get_repair_crew_from_freighter_plus,_("buttonEngineer+","Get Repair Crew"),function()
								string.format("")
								getRepairCrewFromFreighter(p2)
							end)
						end
					else
						p.not_enough_repair_crew_eng = "not_enough_repair_crew_eng"
						p:addCustomMessage("Engineering",p.not_enough_repair_crew_eng,string.format(_("msgEngineer","We don't have any repair crew to send over to %s. We might get one from %s"),critical_transport:getCallSign(),station_regional_hq:getCallSign()))
						p.not_enough_repair_crew_plus = "not_enough_repair_crew_plus"
						p:addCustomMessage("Engineering+",p.not_enough_repair_crew_plus,string.format(_("msgEngineer+","We don't have any repair crew to send over to %s. We might get one from %s"),critical_transport:getCallSign(),station_regional_hq:getCallSign()))
					end
				end
			end
		else
			p.too_far_from_transport_eng = "too_far_from_transport_eng"
			p:addCustomMessage("Engineering",p.too_far_from_transport_eng,string.format(_("msgEngineer","%s is too far from %s to transport a repair crew member. Functional transport may occur at or under 3 units"),p:getCallSign(),critical_transport:getCallSign()))
			p.too_far_from_transport_plus = "too_far_from_transport_plus"
			p:addCustomMessage("Engineering+",p.too_far_from_transport_plus,string.format(_("msgEngineer+","%s is too far from %s to transport a repair crew member. Functional transport may occur at or under 3 units"),p:getCallSign(),critical_transport:getCallSign()))
		end
	end
end
function freighterSafeMessage()
	local player_list = getActivePlayerShips()
	local ship_type = critical_transport:getTypeName()
	local activity = _("mission1st-comms","unloading cargo")
	if ship_type:find("Garbage") ~= nil then
		activity = _("mission1st-comms","picking up cargo")
	elseif ship_type:find("Personnel") ~= nil then
		activity = _("mission1st-comms","disembarking passengers")
	end
	for index, p in ipairs(player_list) do
		if p.freighter_safe_message == nil then
			station_regional_hq:sendCommsMessage(p,string.format(_("mission1st-incCall","To: %s\nFrom: %s\n\nHello %s,\n\nFreighter %s has safely docked and is %s. Thanks for your assistance."),p:getCallSign(),station_regional_hq:getCallSign(),p:getCallSign(),critical_transport:getCallSign(),activity))
			p.freighter_safe_message = "sent"
		end
	end
	medical_message_milestone = getScenarioTime() + 30
	primary_orders = string.format(_("orders-comms","Protect station %s and other friendly stations and ships"),station_regional_hq:getCallSign())
	mainLinearPlot = medicalAttention
end
function medicalAttention(delta)
	if getScenarioTime() > medical_message_milestone then
		local all_hailed = true
		if guaranteed_comms_diagnostic then print("met medical milestone. all hailed above loop:",all_hailed) end
		for index, p in ipairs(getActivePlayerShips()) do
			if p.medical_attention_message == nil then
				if guaranteed_comms_diagnostic then print("medical attention message nil for",p:getCallSign()) end
				all_hailed = false
				if availableForComms(p) then
					hq_medical_message:openCommsTo(p)
					p.medical_attention_message = "sent"
					if guaranteed_comms_diagnostic then print("message sent to",p:getCallSign()) end
				else
					all_hailed = false
				end
			end
		end
		if guaranteed_comms_diagnostic then print("all hailed below loop:",all_hailed) end
		if all_hailed then
			primary_orders = string.format(_("orders-comms","Gather medical details and possible treatment from %s in roughly direction %i and return to %s"),station_medical_research:getCallSign(),math.floor(research_axis),station_regional_hq:getCallSign())
			ensign_death_timer = rescue_time_limit * 60
			mainLinearPlot = saveEnsign
		end
	end
	if getScenarioTime() > (medical_message_milestone + 90) then
		if guaranteed_comms_diagnostic then print("met medical milestone + 60") end
		for index, p in ipairs(getActivePlayerShips()) do
			if p.medical_attention_message == nil then
				p:commandCloseTextComm()
				if guaranteed_comms_diagnostic then print("closed text comms for",p:getCallSign()) end
			end
		end
	end
end
function saveEnsign(delta)
	ensign_death_timer = ensign_death_timer - delta
	if ensign_death_timer < 0 then
		loseGame(_("msgMainscreen","Fargalli died. Omicron plague destroyed humanity"))
	else
		local timer_minutes = math.floor(ensign_death_timer / 60)
		local timer_seconds = math.floor(ensign_death_timer % 60)
		local timer_status = _("tabRelay&Operations","Ensign Death")
		if timer_minutes <= 0 then
			timer_status = string.format("%s %i",timer_status,timer_seconds)
		else
			timer_status = string.format("%s %i:%.2i",timer_status,timer_minutes,timer_seconds)
		end
		for index, p in ipairs(getActivePlayerShips()) do
			p.ensign_death_timer_relay = "ensign_death_timer_relay"
			p:addCustomInfo("Relay",p.ensign_death_timer_relay,timer_status,3)
			p.ensign_death_timer_ops = "ensign_death_timer_ops"
			p:addCustomInfo("Operations",p.ensign_death_timer_ops,timer_status,3)
		end
		if medical_research_obtained then
			if station_regional_hq == nil then
				loseGame(_("msgMainscreen","HQ destroyed. Omicron plague destroyed humanity"))
			else
				if plague_victim_treated then
					for index, p in ipairs(getActivePlayerShips()) do
						p:removeCustom(p.ensign_death_timer_relay)
						p:removeCustom(p.ensign_death_timer_ops)
					end
					plague_message_milestone = getScenarioTime() + 30
					primary_orders = string.format(_("orders-comms","Protect station %s and other friendly stations and ships"),station_regional_hq:getCallSign())
					mainLinearPlot = destroyExuariMessage
					local p = getPlayerShip(-1)
					p:addReputationPoints(30)
				end
			end
		else
			if station_medical_research == nil then
				loseGame(_("msgMainscreen","Station destroyed. Omicron plague destroyed humanity"))
			elseif station_regional_hq == nil then
				loseGame(_("msgMainscreen","HQ destroyed. Omicron plague destroyed humanity"))
			end
		end
		if not all_players_hailed_by_medical_research_station then
			if ensign_death_timer < ((rescue_time_limit * 60) / 2) then
				all_players_hailed_by_medical_research_station = true
				for index, p in ipairs(getActivePlayerShips()) do
					if p.medical_station_query == nil then
						all_players_hailed_by_medical_research_station = false
						if availableForComms(p) then
							medical_station_query_message:openCommsTo(p)
							p.medical_station_query = "sent"
							preMedStrike()
						else
							all_players_hailed_by_medical_research_station = false
						end
					end
				end
			end
			if not all_players_hailed_by_medical_research_station then
				all_players_hailed_by_medical_research_station = true
				for index, p in ipairs(getActivePlayerShips()) do
					local player_to_med = distance(p,station_medical_research)
					local half_hq_to_med = distance(station_medical_research,station_regional_hq) / 2
					if player_to_med < half_hq_to_med then
						if p.medical_station_query == nil then
							all_players_hailed_by_medical_research_station = false
							if availableForComms(p) then
								medical_station_query_message:openCommsTo(p)
								p.medical_station_query = "sent"
								preMedStrike()
							else
								all_players_hailed_by_medical_research_station = false
							end
						end
					else
						all_players_hailed_by_medical_research_station = false
					end
				end
			end
		end
	end
end
function preMedStrike()
	if pre_med_fleet ~= nil then
		return
	end
	pre_med_fleet = {}
	local m_x, m_y = station_medical_research:getPosition()
	local count_repeat_loop = 0
	local ref_x = 0
	local ref_y = 0
	local outer_limit = 25000
	repeat
		local o_x, o_y = vectorFromAngleNorth(random(0,360),random(18000,outer_limit))
		ref_x = m_x + o_x
		ref_y = m_y + o_y
		count_repeat_loop = count_repeat_loop + 1
		outer_limit = outer_limit + 100
	until(farEnough(ref_x,ref_y,2000) or count_repeat_loop > max_repeat_loop)
	if count_repeat_loop > max_repeat_loop then
		print("tried too many times to place first enemy fleet")
	else
		local fleet = spawnEnemies(ref_x, ref_y, 2, "Exuari")
		for _, ship in ipairs(fleet) do
			ship:orderFlyTowards(m_x, m_y)
			table.insert(pre_med_fleet,ship)
		end
	end
	outer_limit = 25000
	count_repeat_loop = 0
	repeat
		local o_x, o_y = vectorFromAngleNorth(random(0,360),random(18000,outer_limit))
		ref_x = m_x + o_x
		ref_y = m_y + o_y
		count_repeat_loop = count_repeat_loop + 1
		outer_limit = outer_limit + 100
	until(farEnough(ref_x,ref_y,2000) or count_repeat_loop > max_repeat_loop)
	if count_repeat_loop > max_repeat_loop then
		print("tried too many times to place second enemy fleet")
	else
		local fleet = spawnEnemies(ref_x, ref_y, 1, "Exuari")
		for _, ship in ipairs(fleet) do
			ship:orderAttack(station_medical_research)
			table.insert(pre_med_fleet,ship)
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
function destroyExuariMessage(delta)
	if getScenarioTime() > plague_message_milestone then
		local all_hailed = true
		for index, p in ipairs(getActivePlayerShips()) do
			if p.destroy_exuari_message == nil then
				all_hailed = false
				if availableForComms(p) then
					hq_plague_message:openCommsTo(p)
					p.destroy_exuari_message = "sent"
				else
					all_hailed = false
				end
			end
		end
		if all_hailed then
			primary_orders = string.format(_("orders-comms","Destroy Exuari Omicron plague research station in roughly direction %i"),math.floor(plague_axis))
			plague_spread_timer = destroy_time_limit * 60
			mainLinearPlot = eliminatePlague
			
		end
	end
	if getScenarioTime() > plague_message_milestone + 90 then
		for index, p in ipairs(getActivePlayerShips()) do
			if p.destroy_exuari_message == nil then
				p:commandCloseTextComm()
			end
		end
	end
end
function eliminatePlague(delta)
	plague_spread_timer = plague_spread_timer - delta
	if plague_spread_timer < 0 then
		loseGame(_("msgMainscreen","The Exuari deployed the Omicron plague. Humanity destroyed"))
	else
		local timer_minutes = math.floor(plague_spread_timer / 60)
		local timer_seconds = math.floor(plague_spread_timer % 60)
		local timer_status = _("tabRelay&Operations","Omicron Broadcast")
		if timer_minutes <= 0 then
			timer_status = string.format("%s %i",timer_status,timer_seconds)
		else
			timer_status = string.format("%s %i:%.2i",timer_status,timer_minutes,timer_seconds)
		end
		for index, p in ipairs(getActivePlayerShips()) do
			p.omicron_broadcast_timer_relay = "omicron_broadcast_timer_relay"
			p:addCustomInfo("Relay",p.omicron_broadcast_timer_relay,timer_status,4)
			p.omicron_broadcast_timer_ops = "omicron_broadcast_timer_ops"
			p:addCustomInfo("Operations",p.omicron_broadcast_timer_ops,timer_status,4)
		end
		if station_plague ~= nil and station_plague:isValid() then
    if difficulty < 2 then    --hint if science heartbeat masked
        for pidx,p in ipairs(getActivePlayerShips()) do
            if p.plague_station_hint == nil then
                local current_approach = distance(p,station_plague)
                if p.proximity_hint_timer ~= nil then
                    if p.proximity_hint_timer > getScenarioTime() then
                        if current_approach > (p:getShortRangeRadarRange() * 3) then
                            p:addToShipLog(string.format(_("shipLog","[%s] Our analysis of your routine ship telemetry indicates that you passed the Exuari plague station, %s."),station_regional_hq:getCallSign(),station_plague:getCallSign()),"Magenta")
                            p.plague_station_hint = "sent"
                        end
                    end
                else
                    if p.closest_approach == nil then
                        p.closest_approach = current_approach
                    end
                    p.closest_approach = math.min(p.closest_approach,current_approach)
                    if p.closest_approach < p:getShortRangeRadarRange() then
                        p.proximity_hint_timer = getScenarioTime() + 60
                    end
                end
            end
        end
    end
end
		if station_plague == nil then
			winGame(_("msgMainscreen","Exuari Omicron plague station destroyed. Humanity saved"))
		elseif not station_plague:isValid() then
			winGame(_("msgMainscreen","Exuari Omicron plague station destroyed. Humanity saved"))
		end
	end
end
function winGame(reason)
	local score = getScore()
	local timer_minutes = math.floor(getScenarioTime() / 60)
	local timer_seconds = math.floor(getScenarioTime() % 60)
	local timer_hours = math.floor(timer_minutes / 60)
	local timer_minutes_after_hour = (timer_minutes % 60)
	local duration = _("msgMainscreen","Duration")
	if timer_minutes <= 0 then
		duration = string.format("%s: %i",duration,timer_seconds)
	else
		if timer_minutes >= 60 then
			duration = string.format("%s: %i:%.2i:%.2i",duration,timer_hours,timer_minutes_after_hour,timer_seconds)
		else
			duration = string.format("%s: %i:%.2i",duration,timer_minutes,timer_seconds)
		end
	end
	reason = string.format(_("msgMainscreen","%s.\nScore: %i. %s"),reason,math.floor(score*100),duration)
	local banner_reason = string.format(_("msgMainscreen","%s. Score: %i. %s"),reason,math.floor(score*100),duration)
	globalMessage(reason)
	setBanner(banner_reason)
	victory(player_faction)
end
function loseGame(reason)
	local score = getScore()
	local timer_minutes = math.floor(getScenarioTime() / 60)
	local timer_seconds = math.floor(getScenarioTime() % 60)
	local timer_hours = math.floor(timer_minutes / 60)
	local timer_minutes_after_hour = (timer_minutes % 60)
	local duration = _("msgMainscreen","Duration")
	if timer_minutes <= 0 then
		duration = string.format("%s: %i",duration,timer_seconds)
	else
		if timer_minutes >= 60 then
			duration = string.format("%s: %i:%.2i:%.2i",duration,timer_hours,timer_minutes_after_hour,timer_seconds)
		else
			duration = string.format("%s: %i:%.2i",duration,timer_minutes,timer_seconds)
		end
	end
	reason = string.format(_("msgMainscreen","%s.\nScore: %i. %s"),reason,100 - math.floor(score*100), duration)
	local banner_reason = string.format(_("msgMainscreen","%s. Score: %i. %s"),reason,100 - math.floor(score*100), duration)
	globalMessage(reason)
	setBanner(banner_reason)
	victory("Exuari")
end
function getScore()
	local freighter_mission = 0
	if freighter_saved then
		freighter_mission = 1
	end
	local ensign_saved = 0
	local rapid_cure = 0
	if plague_victim_treated then
		ensign_saved = 1
		local rescue_duration = rescue_time_limit * 60 - ensign_death_timer
		if rescue_duration < 900 then
			rapid_cure = 1 - (rescue_duration/900)
		end
	end
	local plage_stopped = 0
	local rapid_destruction = 0
	if station_plague == nil or not station_plague:isValid() then
		plage_stopped = 1
		local plague_prep_duration = destroy_time_limit * 60 - plague_spread_timer
		if plague_prep_duration < 900 then
			rapid_destruction = 1 - (plague_prep_duration/900)
		end
	end
	local positive_reputation = 0
	local players = getActivePlayerShips()
	if #players > 0 then
		local final_reputation = players[1]:getReputationPoints()
		if final_reputation > reputation_start_amount then
			local positive_rep_amount = final_reputation - reputation_start_amount
			if difficulty < 1 then
				if positive_rep_amount > 400 then
					positive_reputation = 1
				else
					positive_reputation = 1 - (positive_rep_amount/400)
				end
			elseif difficulty > 1 then
				if positive_rep_amount > 100 then
					positive_reputation = 1
				else
					positive_reputation = 1 - (positive_rep_amount/100)
				end
			else
				if positive_rep_amount > 200 then
					positive_reputation = 1
				else
					positive_reputation = 1 - (positive_rep_amount/200)
				end
			end
		end
	end
	local player_survival = 0
	if player_ship_death_count == 0 then
		player_survival = 1
	else
		player_survival = 1 - (player_ship_death_count/player_ship_spawn_count)
	end
	local score = 
		(freighter_mission *	.1) +
		(ensign_saved *			.1) +
		(rapid_cure *			.1) +
		(plage_stopped *		.1) +
		(rapid_destruction *	.3) +
		(positive_reputation *	.2) +
		(player_survival *		.1)
	return score
end
function bioSignatureCycle(obj,delta)
	local bio = obj:getRadarSignatureBiological()
	local ele = obj:getRadarSignatureElectrical()
	local grv = obj:getRadarSignatureGravity()
	bio = bio - delta
	if bio < 0 then
		bio = 1
	end
--	bio = random(0,1)
	obj:setRadarSignatureInfo(grv,ele,bio)
--	obj:setCallSign(string.format("%f",obj:getRadarSignatureBiological()))
end

------------------------
--	Update functions  --
------------------------
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
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if mainLinearPlot ~= nil then
		mainLinearPlot(delta)
	end
	if station_medical_research ~= nil and station_medical_research:isValid() then
		bioSignatureCycle(station_medical_research,delta)
	end
	if station_plague ~= nil and station_plague:isValid() then
		bioSignatureCycle(station_plague,delta)
	end
	local s_time = getScenarioTime()
	for pidx, p in ipairs(getActivePlayerShips()) do
		if p.pidx == nil then
			p.pidx = pidx
			setPlayers(p)
		end
		updatePlayerLongRangeSensors(p)
		updatePlayerUpgradeMission(p)
		updatePlayerDangerZone(p)
		updatePlayerTubeSizeBanner(p)
	end
	moonCollisionCheck()
	updateBarrierPatrols(delta)
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

