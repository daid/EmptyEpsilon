-- Name: Doomed Outpost
-- Description: Far from home, an isolated outpost tries to survive a hostile environment. This scenario starts off simply enough, but the challenges are significant. It's not recommended for those players that want to reach victory nearly every game or feel claustrophobic starting in a starship with limited capabilities.
--- 
--- Designed to run with one or more player ships with different terrain each time. Player ships start off with more limited capabilities than usual, but can easily be upgraded beyond the normal player ship capabilities.
--- Rank awarded at the end of the mission from lowest to highest: Cadet, Acting Ensign, Ensign, Lieutenant, Commander, Captain, Admiral
---
--- Duration: About an hour if you play to the first major attack. If you survive the first major attack and wish to attempt a victory, it could take five hours or more. Know your real life time constraints before you start.
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
-- Setting[Pace]: How slow or fast do the enemies get more powerful
-- Pace[Snail]: Slower than slow pacing
-- Pace[Slow]: Slower than normal pacing
-- Pace[Normal|Default]: Normal pacing
-- Pace[Fast]: Faster than normal pacing
-- Pace[Impatient]: Faster than fast pacing
-- Pace[Blitz]: Fastest pace
-- Setting[Reputation]: Amount of reputation to start with
-- Reputation[Unknown|Default]: Zero reputation - nobody knows anything about you
-- Reputation[Nice]: 20 reputation - you've had a small positive influence on the local community
-- Reputation[Hero]: 50 reputation - you helped important people or lots of people
-- Reputation[Major Hero]: 100 reputation - you're well known by nearly everyone as a force for good
-- Reputation[Super Hero]: 200 reputation - everyone knows you and relies on you for help
-- Setting[Upgrade]: General price of upgrades to player ships
-- Upgrade[Cheap]: Lower priced player ship upgrades
-- Upgrade[Normal|Default]: Normal price for player ship upgrades
-- Upgrade[Expensive]: Higher priced player ship upgrades
-- Upgrade[Luxurious]: Very high prices for player ship upgrades
-- Upgrade[Monopolistic]: Extremely high prices for player ship upgrades
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
	scenario_version = "1.0.9"
	print(string.format("     -----     Scenario: Outpost     -----     Version %s     -----",scenario_version))
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
			["Easy"] =		{number = .5,	adverse = .999,	lose_coolant = .99999,	gain_coolant = .005},
			["Normal"] =	{number = 1,	adverse = .995,	lose_coolant = .99995,	gain_coolant = .001},
			["Hard"] =		{number = 2,	adverse = .99,	lose_coolant = .9999,	gain_coolant = .0001},
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
		adverseEffect =	murphy_config[getScenarioSetting("Murphy")].adverse
		coolant_loss =	murphy_config[getScenarioSetting("Murphy")].lose_coolant
		coolant_gain =	murphy_config[getScenarioSetting("Murphy")].gain_coolant
		local pacing_config = {
			["Snail"] =		600,
			["Slow"] =		450,
			["Normal"] =	300,
			["Fast"] =		250, 
			["Impatient"] = 200,
			["Blitz"] = 	150,
		}
		danger_pace = pacing_config[getScenarioSetting("Pace")]
		local reputation_config = {
			["Unknown"] = 		0,
			["Nice"] = 			20,
			["Hero"] = 			50,
			["Major Hero"] =	100,
			["Super Hero"] =	200,
		}
		reputation_start_amount = reputation_config[getScenarioSetting("Reputation")]
		local upgrade_config = {
			["Cheap"] = .5,
			["Normal"] = 1,
			["Expensive"] = 1.5,
			["Luxurious"] = 2,
			["Monopolistic"] = 3,
		}
		upgrade_price = upgrade_config[getScenarioSetting("Upgrade")]
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
	upgrade_path = {	--one path per player ship
		["Atlantis"] = {	--10 + beam(7) + missile(10) + shield(9) + hull(8) + impulse(16) + ftl(10) + sensors(10) = 80
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 6, dmg = 6},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 6, dmg = 6},
				},
				{	--2
					{idx = 0, arc = 60, dir = -20, rng = 1250, cyc = 6, dmg = 6},
					{idx = 1, arc = 60, dir =  20, rng = 1250, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 80, dir = -20, rng = 1250, cyc = 6, dmg = 6},
					{idx = 1, arc = 80, dir =  20, rng = 1250, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc by 1/3")
				},
				{	--4
					{idx = 0, arc = 80, dir = -20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 1, arc = 80, dir =  20, rng = 1250, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage by 1/3")
				},
				{	--5
					{idx = 0, arc = 80, dir = -20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 1, arc = 80, dir =  20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 2, arc = 80, dir = -40, rng = 1250, cyc = 6, dmg = 8},
					{idx = 3, arc = 80, dir =  40, rng = 1250, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--6
					{idx = 0, arc = 100, dir = -20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1250, cyc = 6, dmg = 8},
					{idx = 2, arc = 100, dir = -40, rng = 1250, cyc = 6, dmg = 8},
					{idx = 3, arc = 100, dir =  40, rng = 1250, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase arc by 25%")
				},
				{	--7
					{idx = 0, arc = 100, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 100, dir = -40, rng = 1500, cyc = 6, dmg = 8},
					{idx = 3, arc = 100, dir =  40, rng = 1500, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase range by 20%")
				},
				{	--8
					{idx = 0, arc = 100, dir = -20, rng = 1500, cyc = 5, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1500, cyc = 5, dmg = 8},
					{idx = 2, arc = 100, dir = -40, rng = 1500, cyc = 5, dmg = 8},
					{idx = 3, arc = 100, dir =  40, rng = 1500, cyc = 5, dmg = 8},
					["desc"] = _("upgrade-comms","decrease cycle time by 1/6")
				},
				["stock"] = {
					{idx = 0, arc = 100, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 100, dir =  20, rng = 1500, cyc = 6, dmg = 8},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase missile stock capacity")},			--2  
				{tube = 1,	ord = 3, desc = _("upgrade-comms","increase homing missile capacity")},			--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","add a mine tube")},							--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","decrease tube load times")},					--5
				{tube = 3,	ord = 5, desc = _("upgrade-comms","add mines, emps and nukes")},				--6
				{tube = 4,	ord = 5, desc = _("upgrade-comms","add two medium sized side tubes")},			--7
				{tube = 4,	ord = 6, desc = _("upgrade-comms","increase EMP capacity")},					--8
				{tube = 4,	ord = 7, desc = _("upgrade-comms","increase nuke capacity")},					--9
				{tube = 5,	ord = 7, desc = _("upgrade-comms","increase tube sizes")},						--10
				{tube = 6,	ord = 7, desc = _("upgrade-comms","decrease mine load speed, add front tube")},	--11
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 8, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 10},	--1
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 20},	--2		
				{hom = 12, nuk = 0, emp = 0, min = 0, hvl = 20},	--3		
				{hom = 12, nuk = 0, emp = 0, min = 4, hvl = 20},	--4		
				{hom = 12, nuk = 2, emp = 4, min = 8, hvl = 20},	--5		
				{hom = 12, nuk = 2, emp = 6, min = 8, hvl = 20},	--6		
				{hom = 12, nuk = 4, emp = 6, min = 8, hvl = 20},	--7		
				["stock"] = {hom = 12, nuk = 4, emp = 6, min = 8, hvl = 20},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--8
					{idx = 0, max = 200},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--9
					{idx = 0, max = 230},
					{idx = 1, max = 230},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 15%"),
				},
				{	--10
					{idx = 0, max = 250},
					{idx = 1, max = 250},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~13%"),
				},
				["stock"] = {
					{idx = 0, max = 200},
					{idx = 1, max = 200},
				},
			},
			["hull"] = {
				{max = 100},											--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by ~29%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--6
				{max = 300, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--7
				["stock"] = {max = 250},
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~14%"),
				},
				{	--3
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
				},
				{	--5
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			200,	strafe =		125,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			200,	strafe =		125,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--7
					max_front =		90,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			200,	strafe =		125,
					desc = _("upgrade-comms","increase max forward impulse speed by 12.5%"),
				},
				{	--8
					max_front =		90,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		125,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 50%"),
				},
				{	--9
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		125,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--10
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver strafe by 60%"),
				},
				{	--11
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		90,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 1/3"),
				},
				{	--13
					max_front =		100,	max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase max forward impulse speed by ~11%"),
				},
				{	--14
					max_front =		100,	max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25%"),
				},
				{	--14
					max_front =		100,	max_back =		90,
					accel_front =	25,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase max reverse impulse speed by 12.5%"),
				},
				{	--15
					max_front =		100,	max_back =		90,
					accel_front =	30,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--16
					max_front =		100,	max_back =		90,
					accel_front =	30,		accel_back = 	20,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--17
					max_front =		100,	max_back =		90,
					accel_front =	30,		accel_back = 	20,
					turn = 			20,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				["stock"] = {
					{max_front = 90, turn = 10, accel_front = 20, max_back = 90, accel_back = 20, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 55000, jump_short = 5500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 10%"),
				},
				{	--8
					jump_long = 55000, jump_short = 5500, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 55000, jump_short = 5500, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--10
					jump_long = 60000, jump_short = 6000, warp = 500,
					desc = _("upgrade-comms","increase jump range by ~9%"),
				},
				{	--11
					jump_long = 60000, jump_short = 6000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 3,
					desc = _("upgrade-comms","increase automated proximity scanner by 50%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 10,
		},
		["Crucible"] = {	--9 + beam(7) + missile(10) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(11) = 79
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -20, rng = 900, cyc = 7, dmg = 4},
					{idx = 1, arc = 60, dir =  20, rng = 900, cyc = 7, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 60, dir = -20, rng = 950, cyc = 7, dmg = 4},
					{idx = 1, arc = 60, dir =  20, rng = 950, cyc = 7, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by ~6%")
				},
				{	--3
					{idx = 0, arc = 60, dir = -20, rng = 950, cyc = 6.5, dmg = 4},
					{idx = 1, arc = 60, dir =  20, rng = 950, cyc = 6.5, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by ~7%")
				},
				{	--4
					{idx = 0, arc = 60, dir = -20, rng = 950, cyc = 6.5, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 950, cyc = 6.5, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%")
				},
				{	--5
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 6.5, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 6.5, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~5%"),
				},
				{	--6
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~8%"),
				},
				{	--7
					{idx = 0, arc = 60, dir = -20, rng = 1100, cyc = 6, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1100, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 10%"),
				},
				{	--8
					{idx = 0, arc = 60, dir = -20, rng = 1100, cyc = 6, dmg = 6},
					{idx = 1, arc = 60, dir =  20, rng = 1100, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				["stock"] = {
					{idx = 0, arc = 70, dir = -30, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 70, dir =  30, rng = 1000, cyc = 6, dmg = 5},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																			--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","add medium tube")},								--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","increase HVLI missile capacity")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add large tube and increase HVLI capacity")},	--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","decrease tube load times")},						--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add broadside tubes and homing missiles")},		--6
				{tube = 6,	ord = 5, desc = _("upgrade-comms","add mining tube")},								--7
				{tube = 7,	ord = 6, desc = _("upgrade-comms","add nukes and EMPs to broadside tubes")},		--8
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase heavy missile capacity")},				--9
				{tube = 8,	ord = 7, desc = _("upgrade-comms","decrease tube load times")},						--10
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase missile capacity")},					--11
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 14, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "S", spd = 6,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "S", spd = 8, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =   0, siz = "L", spd = 8, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 8, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 12},	--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 18},	--2
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 24},	--3
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 24},	--4		
				{hom = 6,  nuk = 0, emp = 0, min = 4, hvl = 24},	--5		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 24},	--6		
				{hom = 8,  nuk = 4, emp = 6, min = 6, hvl = 24},	--7	
				{hom = 12, nuk = 6, emp = 9, min = 8, hvl = 30},	--8		
				["stock"] = {hom = 8, nuk = 4, emp = 6, min = 6, hvl = 24},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--9
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 200},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 160},
					{idx = 1, max = 160},
				},
			},	
			["hull"] = {
				{max = 100},																--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},		--3
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},		--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 12.5%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},		--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 160},
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
				},
				{	--3
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
				},
				{	--5
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--7
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
				},
				{	--8
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
				},
				{	--9
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase impulse forward acceleration by 6.25%"),
				},
				{	--10
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver strafe by 1/3"),
				},
				{	--11
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 60%"),
				},
				{	--13
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--14
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25% and boost by ~14%"),
				},
				{	--15
					max_front =		85,		max_back =		90,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase max reverse impulse speed by 12.5%"),
				},
				{	--16
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by ~17%"),
				},
				{	--17
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--18
					max_front =		90,		max_back =		100,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase max impulse forward by ~6% and reverse by ~11%"),
				},
				["stock"] = {
					{max_front = 80, turn = 15, accel_front = 40, max_back = 80, accel_back = 40, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 750,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add jump drive"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 800,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--11
					jump_long = 30000, jump_short = 3000, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 15000, prox_scan = 1,
					desc = _("upgrade-comms","add a one unit automated proximity scanner")
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--12
					short = 5500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 9,
		},
		["Maverick"] = {	--9 + beam(11) + missile(12) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(11) = 85
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -20, rng = 1000, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1000, cyc = 7, dmg = 5},
				},
				{	--2
					{idx = 0, arc = 60, dir = -20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =  20, rng = 1500, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 50%")
				},
				{	--3
					{idx = 0, arc = 75, dir = -20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 1, arc = 75, dir =  20, rng = 1500, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase arc by 25%")
				},
				{	--4
					{idx = 0, arc = 75, dir = -20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 1, arc = 75, dir =  20, rng = 1500, cyc = 7, dmg = 5},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 7, dmg = 5},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--5
					{idx = 0, arc = 75, dir = -20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 1, arc = 75, dir =  20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 5},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 5},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 5},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 5},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","add sniping beam, increase primary arcs by 20%")
				},
				{	--7
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 20%")
				},
				{	--8
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 6},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","add rear turret"),
				},
				{	--9
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 6, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","increase primary damage by 1/3"),
				},
				{	--10
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","decrease secondary cycle time by 1/3"),
				},
				{	--11
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 7},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 5, tar = 180, tdr = 180, trt = .5},
					["desc"] = _("upgrade-comms","increase damage by ~17%"),
				},
				{	--12
					{idx = 0, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 1, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 9},
					{idx = 2, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 3, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 7},
					{idx = 4, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 7},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 5, tar = 180, tdr = 180, trt = 1},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =   0, rng = 2000, cyc = 6, dmg = 6},
					{idx = 1, arc = 90, dir = -20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 2, arc = 90, dir =  20, rng = 1500, cyc = 6, dmg = 8},
					{idx = 3, arc = 40, dir = -70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 4, arc = 40, dir =  70, rng = 1000, cyc = 4, dmg = 6},
					{idx = 5, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 4, tar = 180, tdr = 180, trt = .5},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add homing")},									--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","double homing missile capacity")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","decrease tube load speed by 20%")},				--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 25%")},				--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","add mining tube")},					--6
				{tube = 5,	ord = 6, desc = _("upgrade-comms","add EMPs")},									--7
				{tube = 6,	ord = 7, desc = _("upgrade-comms","add nuke capability")},							--8
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase tube size")},							--9
				{tube = 7,	ord = 8, desc = _("upgrade-comms","more homing, nuke and EMP missiles")},			--10
				{tube = 8,	ord = 8, desc = _("upgrade-comms","25% faster mine loading")},						--11
				{tube = 8,	ord = 9, desc = _("upgrade-comms","more homing, mine and HVLI missiles")},			--12
				{tube = 8,	ord = 10,desc = _("upgrade-comms","more mine and HVLI missiles")},					--13
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 8},		--1
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 8},		--2
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 8},		--3
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 10},	--4		
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 10},	--5		
				{hom = 4,  nuk = 0, emp = 2, min = 2, hvl = 10},	--6		
				{hom = 4,  nuk = 1, emp = 2, min = 2, hvl = 10},	--7		
				{hom = 6,  nuk = 2, emp = 4, min = 2, hvl = 10},	--8	
				{hom = 8,  nuk = 2, emp = 4, min = 3, hvl = 12},	--9		
				{hom = 8,  nuk = 2, emp = 4, min = 5, hvl = 14},	--10		
				["stock"] = {hom = 6, nuk = 2, emp = 4, min = 2, hvl = 10},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--9
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 200},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 160},
					{idx = 1, max = 160},
				},
			},	
			["hull"] = {
				{max = 100},											--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--3
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 12.5%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 160},
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
				},
				{	--3
					max_front =		75,		max_back =		70,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
				},
				{	--5
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		75,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--7
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse speed by ~7%"),
				},
				{	--8
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
				},
				{	--9
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase impulse forward acceleration by 6.25%"),
				},
				{	--10
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			20,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver strafe by 1/3"),
				},
				{	--11
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			250,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		85,		max_back =		80,
					accel_front =	25,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 60%"),
				},
				{	--13
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			350,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--14
					max_front =		85,		max_back =		80,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25% and boost by ~14%"),
				},
				{	--15
					max_front =		85,		max_back =		90,
					accel_front =	30,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase max reverse impulse speed by 12.5%"),
				},
				{	--16
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by ~17%"),
				},
				{	--17
					max_front =		85,		max_back =		90,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--18
					max_front =		90,		max_back =		100,
					accel_front =	35,		accel_back = 	25,
					turn = 			25,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase max impulse forward by ~6% and reverse by ~11%"),
				},
				["stock"] = {
					{max_front = 80, turn = 15, accel_front = 40, max_back = 80, accel_back = 40, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 750,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add jump drive"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 800,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--11
					jump_long = 30000, jump_short = 3000, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 15000, prox_scan = 1,
					desc = _("upgrade-comms","add a one unit automated proximity scanner")
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--12
					short = 5500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 9,
		},
		["Benedict"] = {	--7 + beam(9) + missile(13) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(9) = 81
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr = 180, trt = 4},
				},
				{	--2
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 4},
					["desc"] = _("upgrade-comms","double arc width")
				},
				{	--3
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase turret speed by 25%")
				},
				{	--4
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--5
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--7
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","increase range by 50%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","overlap arcs"),
				},
				{	--9
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase turret speed by 20%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add mines")},								--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","speed up tube load speed by 25%")},			--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase mine capacity by 50%")},			--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","speed up tube load speed by 1/3")},			--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","increase mine capacity by 1/3")},			--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","speed up mine load speed by ~17%")},			--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase mine capacity by 25%")},			--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add homing missiles")},						--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double homing missile capacity")},			--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","speed up mine loading speed by 20%")},		--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase homing missile capacity by 50%")},	--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","medium sized homing misile tubes")},			--13
				{tube = 8,	ord = 9, desc = _("upgrade-comms","increase mine capacity by 20%")},			--14
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 2, hvl = 0},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 0},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 4, hvl = 0},		--4		
				{hom = 0,  nuk = 0, emp = 0, min = 5, hvl = 0},		--5		
				{hom = 5,  nuk = 0, emp = 0, min = 5, hvl = 0},		--6		
				{hom = 10, nuk = 0, emp = 0, min = 5, hvl = 0},		--7		
				{hom = 15, nuk = 0, emp = 0, min = 5, hvl = 0},		--8		
				{hom = 15, nuk = 0, emp = 0, min = 6, hvl = 0},		--9		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 70},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~17%"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 50%"),
				},
				{	--9
					{idx = 0, max = 100},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 100},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--6
				{max = 240, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--7
				["stock"] = {max = 200},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","increase max forward acceleration by 1/3"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 60%"),
				},
				{	--7
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max forward impulse speed by ~17%"),
				},
				{	--8
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 1/3"),
				},
				{	--9
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--10
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25%"),
				},
				{	--11
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
				},
				{	--13
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--14
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--15
					max_front =		77,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max forward impulse speed by 10%"),
				},
				{	--16
					max_front =		77,		max_back =		50,
					accel_front =	15,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--17
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max reverse impulse by 20% and reverse acceleration by 1/3"),
				},
				{	--18
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			11,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 10%"),
				},
				["stock"] = {
					{max_front = 60, turn = 6, accel_front = 8, max_back = 60, accel_back = 8, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","add 40k jump drive"),
				},
				{	--3
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 60000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 70000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--6
					jump_long = 80000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~14%"),
				},
				{	--7
					jump_long = 90000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 12.5%"),
				},
				{	--8
					jump_long = 90000, jump_short = 5000, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 90000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--10
					jump_long = 100000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","increase jump range by ~11%"),
				},
				{	--11
					jump_long = 100000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				["stock"] = {
					{jump_long = 90000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--3
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--4
					short = 4500, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--6
					short = 4500, long = 40000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--8
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 45000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--10
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 7,
		},
		["Kiriya"] = {	--7 + beam(9) + missile(13) + shield(9) + hull(6) + impulse(17) + ftl(10) + sensors(9) = 81
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 30, tdr = 180, trt = 4},
				},
				{	--2
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 4},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 4},
					["desc"] = _("upgrade-comms","double arc width")
				},
				{	--3
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 60, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase turret speed by 25%")
				},
				{	--4
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 7, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--5
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1000, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1000, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--7
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 40, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","increase range by 50%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 5},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 5},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 5},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 5},
					["desc"] = _("upgrade-comms","overlap arcs"),
				},
				{	--9
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 4, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase turret speed by 20%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = 180, trt = 6},
					{idx = 2, arc = 10, dir = -90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr = -90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 6, dmg = 5, tar = 110, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =   0, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr =   0, trt = 6},
					{idx = 1, arc = 10, dir = 180, rng = 1500, cyc = 6, dmg = 4, tar = 90, tdr = 180, trt = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add mines")},									--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","speed up tube load speed by 25%")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase mine capacity by 50%")},				--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","speed up tube load speed by 1/3")},				--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","increase mine capacity by 1/3")},				--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","speed up mine load speed by ~17%")},			--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase mine capacity by 25%")},				--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add homing missiles")},							--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double homing missile capacity")},				--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","speed up mine loading speed by 20%")},			--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase homing missile capacity by 50%")},		--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","medium sized homing misile tubes")},			--13
				{tube = 8,	ord = 9, desc = _("upgrade-comms","increase mine capacity by 20%")},				--14
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  60, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 120, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir = 300, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = 240, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 2, hvl = 0},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 0},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 4, hvl = 0},		--4		
				{hom = 0,  nuk = 0, emp = 0, min = 5, hvl = 0},		--5		
				{hom = 5,  nuk = 0, emp = 0, min = 5, hvl = 0},		--6		
				{hom = 10, nuk = 0, emp = 0, min = 5, hvl = 0},		--7		
				{hom = 15, nuk = 0, emp = 0, min = 5, hvl = 0},		--8		
				{hom = 15, nuk = 0, emp = 0, min = 6, hvl = 0},		--9		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 70},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~17%"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 50%"),
				},
				{	--9
					{idx = 0, max = 100},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 100},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~11%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--6
				{max = 240, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--7
				["stock"] = {max = 200},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by ~20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver forward boost"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","increase max forward acceleration by 1/3"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			5,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--6
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 60%"),
				},
				{	--7
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max forward impulse speed by ~17%"),
				},
				{	--8
					max_front =		70,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 1/3"),
				},
				{	--9
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--10
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			8,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver strafe by 25%"),
				},
				{	--11
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			400,	strafe =		250,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--12
					max_front =		70,		max_back =		50,
					accel_front =	10,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase combat maneuver forward boost by 25%"),
				},
				{	--13
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		250,
					desc = _("upgrade-comms","increase impulse forward acceleration by 20%"),
				},
				{	--14
					max_front =		70,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 20%"),
				},
				{	--15
					max_front =		77,		max_back =		50,
					accel_front =	12,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max forward impulse speed by 10%"),
				},
				{	--16
					max_front =		77,		max_back =		50,
					accel_front =	15,		accel_back = 	6,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase impulse forward acceleration by 25%"),
				},
				{	--17
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max reverse impulse by 20% and reverse acceleration by 1/3"),
				},
				{	--18
					max_front =		77,		max_back =		60,
					accel_front =	15,		accel_back = 	8,
					turn = 			11,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 10%"),
				},
				["stock"] = {
					{max_front = 60, turn = 6, accel_front = 8, max_back = 60, accel_back = 8, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 800,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--11
					jump_long = 30000, jump_short = 3000, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--3
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--4
					short = 4500, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--6
					short = 4500, long = 40000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--8
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 45000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--10
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 7,
		},
		["Phobos M3P"] = {	--8 + beam(9) + missile(12) + shield(9) + hull(6) + impulse(13) + ftl(9) + sensors(12) = 78
			["beam"] = {
				{	--1
					{idx = 0, arc = 40, dir = -15, rng = 1000, cyc = 10, dmg = 5},
					{idx = 1, arc = 40, dir =  15, rng = 1000, cyc = 10, dmg = 5},
				},
				{	--2
					{idx = 0, arc = 40, dir = -15, rng = 1000, cyc = 9, dmg = 5},
					{idx = 1, arc = 40, dir =  15, rng = 1000, cyc = 9, dmg = 5},
					["desc"] = _("upgrade-comms","reduce cycle time by 10%")
				},
				{	--3
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 9, dmg = 5},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 9, dmg = 5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--4
					{idx = 0, arc = 60, dir = -15, rng = 1100, cyc = 9, dmg = 5},
					{idx = 1, arc = 60, dir =  15, rng = 1100, cyc = 9, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 10%")
				},
				{	--5
					{idx = 0, arc = 60, dir = -15, rng = 1100, cyc = 9, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1100, cyc = 9, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				{	--6
					{idx = 0, arc = 60, dir = -15, rng = 1100, cyc = 8, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1100, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by ~11%"),
				},
				{	--7
					{idx = 0, arc = 90, dir = -15, rng = 1100, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1100, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--8
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by ~9%"),
				},
				{	--9
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 2, arc = 30, dir =   0, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--10
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 2, arc = 30, dir =   0, rng = 1500, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase center beam range by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 8, dmg = 6},
					{idx = 0, arc = 90, dir =  15, rng = 1200, cyc = 8, dmg = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","increase tube load speed by ~17%")},			--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","add homing missiles")},						--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase homing missile capacity by 50%")},	--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 60%")},			--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","add mining tube")},							--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","speed up forward tube load time by 20%")},	--7
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add EMPs")},									--8
				{tube = 7,	ord = 6, desc = _("upgrade-comms","increase tube size")},						--9
				{tube = 8,	ord = 7, desc = _("upgrade-comms","add nukes, more EMPs")},						--10
				{tube = 8,	ord = 8, desc = _("upgrade-comms","1/3 more homing capacity")},					--11
				{tube = 8,	ord = 9, desc = _("upgrade-comms","more homing and HVLI missiles")},			--12
				{tube = 8,	ord = 10,desc = _("upgrade-comms","more homing, nuke, EMP and mine missiles")},	--13
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   1, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "S", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   1, siz = "M", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "M", spd = 8,  hom = true,  nuk = false, emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   1, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  -1, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =  -1, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   1, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 10},	--1
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 10},	--2
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 10},	--3
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 16},	--4		
				{hom = 6,  nuk = 0, emp = 0, min = 2, hvl = 16},	--5		
				{hom = 6,  nuk = 0, emp = 2, min = 2, hvl = 16},	--6		
				{hom = 6,  nuk = 2, emp = 4, min = 2, hvl = 16},	--7		
				{hom = 8,  nuk = 2, emp = 4, min = 2, hvl = 16},	--8	
				{hom = 10, nuk = 2, emp = 4, min = 2, hvl = 20},	--9		
				{hom = 12, nuk = 3, emp = 5, min = 4, hvl = 20},	--10		
				["stock"] = {hom = 10, nuk = 2, emp = 3, min = 4, hvl = 20},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 12.5%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 120},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 120},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 150},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--10
					{idx = 0, max = 150},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 100},
					{idx = 1, max = 100},
				},
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--6
				{max = 240, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--7
				["stock"] = {max = 200},
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		70,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 12.5%"),
				},
				{	--3
					max_front =		75,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse by ~7%"),
				},
				{	--4
					max_front =		75,		max_back =		60,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--5
					max_front =		75,		max_back =		70,
					accel_front =	16,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse by ~17%"),
				},
				{	--6
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase forward impulse speed and acceleration"),
				},
				{	--7
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			9,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--7
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by ~11%"),
				},
				{	--8
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	14,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","double combat maneuverability"),
				},
				{	--9
					max_front =		80,		max_back =		80,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse speed and acceleration"),
				},
				{	--10
					max_front =		80,		max_back =		80,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--11
					max_front =		80,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse max speed by 10%"),
				},
				{	--12
					max_front =		80,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver boost by 25%"),
				},
				{	--13
					max_front =		80,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--14
					max_front =		88,		max_back =		88,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase max forward impulse speed by 10%"),
				},
				["stock"] = {
					{max_front = 80, turn = 10, accel_front = 20, max_back = 80, accel_back = 20, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 300,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 400,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 500,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 600,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","add 1 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","triple automated proximity scanner range"),
				},
				{	--10
					short = 5000, long = 35000,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--11
					short = 5500, long = 35000,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--12
					short = 5500, long = 40000,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--13
					short = 6000, long = 40000,
					desc = _("upgrade-comms","increase short range sensors by ~9%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
		["Hathcock"] = {	--8 + beam(9) + missile(13) + shield(9) + hull(6) + impulse(14) + ftl(8) + sensors(11) = 78
			["beam"] = {
				{	--1
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 8,  dmg = 4},
					{idx = 1, arc = 40, dir =   0, rng = 1000, cyc = 8,  dmg = 4},
				},
				{	--2
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 7,  dmg = 4},
					{idx = 1, arc = 40, dir =   0, rng = 1000, cyc = 7,  dmg = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by 12.5%")
				},
				{	--3
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 7,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 7,  dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--4
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 7,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 7,  dmg = 4},
					{idx = 2, arc = 80, dir =   0, rng =  800, cyc = 7,  dmg = 4},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--5
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 4},
					{idx = 2, arc = 80, dir =   0, rng =  800, cyc = 6,  dmg = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by ~14%"),
				},
				{	--6
					{idx = 0, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 4},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 4},
					{idx = 2, arc = 90, dir =   0, rng =  800, cyc = 6,  dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 12.5%"),
				},
				{	--7
					{idx = 0, arc =  4, dir =   0, rng = 1400, cyc = 6,  dmg = 4},
					{idx = 1, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 4},
					{idx = 2, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 4},
					{idx = 3, arc = 90, dir =   0, rng =  800, cyc = 6,  dmg = 4},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc =  4, dir =   0, rng = 1400, cyc = 6,  dmg = 5},
					{idx = 1, arc = 20, dir =   0, rng = 1200, cyc = 6,  dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1000, cyc = 6,  dmg = 5},
					{idx = 3, arc = 90, dir =   0, rng =  800, cyc = 6,  dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--9
					{idx = 0, arc =  4, dir =   0, rng = 1500, cyc = 6,  dmg = 5},
					{idx = 1, arc = 20, dir =   0, rng = 1300, cyc = 6,  dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1100, cyc = 6,  dmg = 5},
					{idx = 3, arc = 90, dir =   0, rng =  900, cyc = 6,  dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~9.5%"),
				},
				{	--10
					{idx = 0, arc =  4, dir =   0, rng = 1500, cyc = 5,  dmg = 5},
					{idx = 1, arc = 20, dir =   0, rng = 1300, cyc = 5,  dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1100, cyc = 5,  dmg = 5},
					{idx = 3, arc = 90, dir =   0, rng =  900, cyc = 5,  dmg = 5},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				["stock"] = {
					{idx = 0, arc =  4, dir =   0, rng = 1400, cyc = 6, dmg = 4},
					{idx = 1, arc = 20, dir =   0, rng = 1200, cyc = 6, dmg = 4},
					{idx = 2, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 4},
					{idx = 3, arc = 90, dir =   0, rng =  800, cyc = 6, dmg = 4},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																	--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add homing")},							--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","increase tube size")},					--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase HVLI capacity by 50%")},		--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","double homing capacity")},				--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","speed up missile load time by 10%")},	--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","add nukes and EMPs")},					--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase HVLI capacity by 1/3")},		--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","speed up load time by ~17%")},			--9
				{tube = 7,	ord = 7, desc = _("upgrade-comms","add mine tube")},						--10
				{tube = 8,	ord = 7, desc = _("upgrade-comms","20% faster broadside loading")},			--11
				{tube = 8,	ord = 8, desc = _("upgrade-comms","more homing, mine and HVLI missiles")},	--12
				{tube = 8,	ord = 9, desc = _("upgrade-comms","more nuke and EMP missiles")},			--13
				{tube = 8,	ord = 10,desc = _("upgrade-comms","more homing and mine missiles")},		--14
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = -90, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = -90, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir = -90, siz = "M", spd = 18, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 18, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir = -90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir = -90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 15, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--2
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 6},		--3
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 6},		--4		
				{hom = 4,  nuk = 1, emp = 2, min = 0, hvl = 6},		--5		
				{hom = 4,  nuk = 1, emp = 2, min = 0, hvl = 8},		--6		
				{hom = 4,  nuk = 1, emp = 2, min = 2, hvl = 8},		--7		
				{hom = 6,  nuk = 1, emp = 2, min = 3, hvl = 10},	--8	
				{hom = 6,  nuk = 2, emp = 4, min = 3, hvl = 10},	--9		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 10},	--10		
				["stock"] = {hom = 4, nuk = 1, emp = 2, min = 0, hvl = 8},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
				},
				{	--9
					{idx = 0, max = 120},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 20%"),
				},
				{	--10
					{idx = 0, max = 150},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
			},	
			["hull"] = {
				{max = 80},												--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 175, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 120},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	10,
					turn = 			10,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	10,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by 20%"),
				},
				{	--3
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase reverse acceleration by 50%"),
				},
				{	--4
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 50%"),
				},
				{	--5
					max_front =		50,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		60,		max_back =		60,
					accel_front =	6,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse speed by 20%"),
				},
				{	--7
					max_front =		60,		max_back =		60,
					accel_front =	9,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse acceleration by 50%"),
				},
				{	--8
					max_front =		60,		max_back =		80,
					accel_front =	9,		accel_back = 	15,
					turn = 			15,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase reverse impulse speed by 1/3"),
				},
				{	--9
					max_front =		60,		max_back =		80,
					accel_front =	9,		accel_back = 	15,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","double combat maneuverability"),
				},
				{	--10
					max_front =		60,		max_back =		80,
					accel_front =	9,		accel_back = 	18,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse acceleration by 20%"),
				},
				{	--11
					max_front =		60,		max_back =		80,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase forward acceleration by 1/3"),
				},
				{	--12
					max_front =		66,		max_back =		80,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase forward impulse speed by 10%"),
				},
				{	--13
					max_front =		66,		max_back =		80,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver boost by 25%"),
				},
				{	--14
					max_front =		66,		max_back =		88,
					accel_front =	12,		accel_back = 	18,
					turn = 			15,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase reverse impulse speed by 10%"),
				},
				{	--15
					max_front =		66,		max_back =		88,
					accel_front =	12,		accel_back = 	18,
					turn = 			18,
					boost =			500,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				["stock"] = {
					{max_front = 50, turn = 15, accel_front = 8, max_back = 50, accel_back = 8, boost = 200, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 50000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--8
					jump_long = 50000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--9
					jump_long = 50000, jump_short = 5000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--4
					short = 4500, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--11
					short = 5000, long = 45000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--12
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
		["Piranha"] = {		--9 + beam(8) + missile(15) + shield(8) + hull(6) + impulse(9) + ftl(8) + sensors(11) = 74
			["beam"] = {
				{	--1
					{idx = 0, arc = 30, dir =   0, rng = 800, cyc = 8, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 30, dir =   0, rng = 900, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 12.5%")
				},
				{	--3
					{idx = 0, arc = 45, dir =   0, rng = 900, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc by 50%")
				},
				{	--4
					{idx = 0, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by 12.5%")
				},
				{	--5
					{idx = 0, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--6
					{idx = 0, arc = 45, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~11%"),
				},
				{	--7
					{idx = 0, arc = 45, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					{idx = 1, arc = 30, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc = 45, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 30, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--9
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","double arc width"),
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																							--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","large tubes")},													--2  
				{tube = 3,	ord = 1, desc = _("upgrade-comms","decrease load time by 25%")},									--3  
				{tube = 4,	ord = 2, desc = _("upgrade-comms","add mining tube")},												--4
				{tube = 5,	ord = 3, desc = _("upgrade-comms","add medium homing tubes and homing missiles")},					--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","increase homing missile capacity by 50%")},						--6
				{tube = 6,	ord = 4, desc = _("upgrade-comms","add homing capability to large tubes")},							--7
				{tube = 7,	ord = 4, desc = _("upgrade-comms","increase tube load speed by 20%")},								--8
				{tube = 8,	ord = 5, desc = _("upgrade-comms","add nukes and EMPs, increase homing and HVLI capacity")},		--9
				{tube = 8,	ord = 6, desc = _("upgrade-comms","increase EMP and mine capacity")},								--10
				{tube = 9,	ord = 6, desc = _("upgrade-comms","add a second mine tube")},										--11
				{tube = 10,	ord = 7, desc = _("upgrade-comms","add large tubes, increase homing capacity")},					--12
				{tube = 11,	ord = 7, desc = _("upgrade-comms","increase tube load speed by 25%")},								--13
				{tube = 12,	ord = 8, desc = _("upgrade-comms","add 3rd mining tube, increase mine, EMP and nuke capacity")},	--14
				{tube = 13,	ord = 9, desc = _("upgrade-comms","increase tube load speeds, increase nuke and HVLI capacity")},	--15
				{tube = 13,	ord = 10,desc = _("upgrade-comms","increase homing, EMP, mine and HVLI capacity")},					--16
			},		
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "L", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 170, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 5, dir = 190, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--11
					{idx = 0, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--12
					{idx = 0, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 180, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 9,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--13
					{idx = 0, dir = -90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = true,  hvl = true },
					{idx = 2, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = true,  hvl = true },
					{idx = 5, dir = -90, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 170, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 10},	--1
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 10},	--2
				{hom = 4,  nuk = 0, emp = 0, min = 3, hvl = 10},	--3
				{hom = 6,  nuk = 0, emp = 0, min = 3, hvl = 10},	--4		
				{hom = 8,  nuk = 2, emp = 2, min = 3, hvl = 16},	--5		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 16},	--6		
				{hom = 12, nuk = 2, emp = 4, min = 4, hvl = 16},	--7		
				{hom = 12, nuk = 4, emp = 6, min = 6, hvl = 16},	--8	
				{hom = 12, nuk = 6, emp = 6, min = 6, hvl = 20},	--9		
				{hom = 16, nuk = 6, emp = 8, min = 9, hvl = 24},	--10		
				["stock"] = {hom = 12, nuk = 6, emp = 0, min = 8, hvl = 20},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 50},
				},
				{	--2
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--3
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 132},
					{idx = 1, max = 132},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
			},	
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--4
				{max = 175, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--6
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 120},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	6,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 1/3"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		72,		max_back =		60,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--7
					max_front =		72,		max_back =		60,
					accel_front =	8,		accel_back = 	6,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		72,		max_back =		60,
					accel_front =	16,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","double impulse acceleration"),
				},
				{	--9
					max_front =		72,		max_back =		60,
					accel_front =	16,		accel_back = 	12,
					turn = 			12,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--10
					max_front =		72,		max_back =		60,
					accel_front =	16,		accel_back = 	12,
					turn = 			12,
					boost =			300,	strafe =		225,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				["stock"] = {
					{max_front = 60, turn = 10, accel_front = 8, max_back = 60, accel_back = 8, boost = 200, strafe = 150},
				},
			},		
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 50000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--8
					jump_long = 50000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--9
					jump_long = 50000, jump_short = 5000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--4
					short = 4500, long = 22000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--5
					short = 4500, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--6
					short = 4500, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--7
					short = 5000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--8
					short = 5000, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--10
					short = 5500, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--11
					short = 5500, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--12
					short = 6000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~9%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 9,
		},
		["Flavia P.Falcon"] = {	--7 + beam(9) + missile(14) + shield(9) + hull(6) + impulse(10) + ftl(9) + sensors(11) = 77
			["beam"] = {
				{	--1
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 30, dir = 180, rng = 1000, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 40, dir = 180, rng = 1000, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc by 1/3")
				},
				{	--4
					{idx = 0, arc = 40, dir = 180, rng = 1000, cyc = 6, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--5
					{idx = 0, arc = 40, dir = 180, rng = 1000, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--6
					{idx = 0, arc = 40, dir = 180, rng = 1200, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by 20%"),
				},
				{	--7
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 5},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 5},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 5},
					{idx = 2, arc = 60, dir =   0, rng = 1200, cyc = 6, dmg = 5},
					["desc"] = _("upgrade-comms","add front beam"),
				},
				{	--9
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 8},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 8},
					{idx = 2, arc = 60, dir =   0, rng = 1200, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage by 60%"),
				},
				{	--10
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 4, dmg = 8},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 4, dmg = 8},
					{idx = 2, arc = 60, dir =   0, rng = 1200, cyc = 4, dmg = 8},
					["desc"] = _("upgrade-comms","decrease cycle time by 1/3"),
				},
				["stock"] = {
					{idx = 0, arc = 40, dir = 170, rng = 1200, cyc = 6, dmg = 6},
					{idx = 1, arc = 40, dir = 190, rng = 1200, cyc = 6, dmg = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																				--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add homing")},										--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","speed up tube load time by 25%")},					--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase missile capacity: homing: 50%, HVLI: 25%")},--4
				{tube = 4,	ord = 4, desc = _("upgrade-comms","add nuke")},											--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 2/3")},					--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","add medium sized homing and mine tube")},			--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase HVLI capacity by 40%")},					--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add HVLI to medium sized tube")},					--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double nuke and mine capacity")},					--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","add large tube for HVLIs and mines")},				--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase homing capacity by 20%")},					--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","reduce tube loading time by 25%")},					--13
				{tube = 9,	ord = 9, desc = _("upgrade-comms","add EMP to medium tube and homing to large tube")},	--14
				{tube = 9,	ord = 10,desc = _("upgrade-comms","increase homing, mine and HVLI capacity")},			--15
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = 180, siz = "S", spd = 25, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--2
					{idx = 0, dir = 180, siz = "S", spd = 25, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--3
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--4
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
				},
				{	--5
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--7
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--8
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--9
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = true,  min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = true },
				},
				{	--10
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = true,  min = true,  hvl = true },
					{idx = 2, dir = 180, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = true,  hvl = true },
				},
				["stock"] = {
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = true,  nuk = true,  emp = false, min = true,  hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 1, hvl = 4},		--1
				{hom = 2,  nuk = 0, emp = 0, min = 1, hvl = 4},		--2
				{hom = 3,  nuk = 0, emp = 0, min = 1, hvl = 5},		--3
				{hom = 3,  nuk = 1, emp = 0, min = 1, hvl = 5},		--4		
				{hom = 5,  nuk = 1, emp = 0, min = 1, hvl = 5},		--5		
				{hom = 5,  nuk = 1, emp = 0, min = 1, hvl = 7},		--6		
				{hom = 5,  nuk = 2, emp = 0, min = 2, hvl = 7},		--7		
				{hom = 6,  nuk = 2, emp = 0, min = 2, hvl = 7},		--8	
				{hom = 6,  nuk = 2, emp = 4, min = 2, hvl = 7},		--9		
				{hom = 7,  nuk = 2, emp = 4, min = 4, hvl = 9},		--10		
				["stock"] = {hom = 4, nuk = 1, emp = 2, min = 0, hvl = 8},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 60},
				},
				{	--2
					{idx = 0, max = 75},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 110},
					{idx = 1, max = 165},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				{	--10
					{idx = 0, max = 110},
					{idx = 1, max = 200},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~21%"),
				},
				["stock"] = {
					{idx = 0, max = 70},
					{idx = 1, max = 70},
				},
			},	
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--4
				{max = 165, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--5
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},	--6
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--7
				["stock"] = {max = 100},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		50,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--5
					max_front =		60,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--6
					max_front =		80,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		150,
					desc = _("upgrade-comms","increase max impulse speed by 1/3"),
				},
				{	--7
					max_front =		80,		max_back =		50,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--8
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase rear impulse max speed by 20%"),
				},
				{	--9
					max_front =		80,		max_back =		60,
					accel_front =	13,		accel_back = 	8,
					turn = 			10,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse acceleration by 30%"),
				},
				{	--10
					max_front =		80,		max_back =		60,
					accel_front =	13,		accel_back = 	8,
					turn = 			12,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--11
					max_front =		80,		max_back =		60,
					accel_front =	13,		accel_back = 	10,
					turn = 			12,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase reverse impulse acceleration by 25%"),
				},
				["stock"] = {
					{max_front = 60, turn = 10, accel_front = 10, max_back = 60, accel_back = 10, boost = 250, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 350,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 650,
					desc = _("upgrade-comms","increase warp speed by ~8%"),
				},
				{	--7
					jump_long = 20000, jump_short = 2000, warp = 650,
					desc = _("upgrade-comms","add 20U jump drive"),
				},
				{	--8
					jump_long = 25000, jump_short = 2500, warp = 650,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--9
					jump_long = 25000, jump_short = 2500, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~8%"),
				},
				{	--10
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 500},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 3,
					desc = _("upgrade-comms","add 3 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5500, long = 35000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--11
					short = 5500, long = 40000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--12
					short = 6000, long = 40000, prox_scan = 3,
					desc = "increase short range sensors by ~9%",
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 7,
		},
		["Repulse"] = {		--8 + beam(10) + missile(13) + shield(9) + hull(6) + impulse(10) + ftl(9) + sensors(10) = 75
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =  90, rng = 1000, cyc = 8, dmg = 4, tar =  90, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1000, cyc = 8, dmg = 4, tar =  90, tdr = -90, trt = 1},
				},
				{	--2
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 8, dmg = 4, tar =  90, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 8, dmg = 4, tar =  90, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","increase range by 20%")
				},
				{	--3
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 8, dmg = 4, tar = 120, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 8, dmg = 4, tar = 120, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","increase arc by 1/3")
				},
				{	--4
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 4, tar = 120, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 4, tar = 120, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--5
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr =  90, trt = 1},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr = -90, trt = 1},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr =  90, trt = 2},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 120, tdr = -90, trt = 2},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--7
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr =  90, trt = 2},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr = -90, trt = 2},
					["desc"] = _("upgrade-comms","increase arc size by 25%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 150, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--9
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 7, tar = 150, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 7, tar = 150, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","increase damage by 40%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 7, tar = 200, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 7, tar = 200, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","overlap arcs"),
				},
				{	--11
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 5, dmg = 7, tar = 200, tdr =  90, trt = 4},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 5, dmg = 7, tar = 200, tdr = -90, trt = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =  90, rng = 1200, cyc = 6, dmg = 5, tar = 200, tdr =  90, trt = 5},
					{idx = 1, arc = 10, dir = -90, rng = 1200, cyc = 6, dmg = 5, tar = 200, tdr = -90, trt = 5},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																			--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","decrease tube load time by 20%")},				--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","increase capacity: homing: 100%, HVLI: 50%")},	--3  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","increase tube size to medium")},					--4
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase capacity: homing: 50%, HVLI: 1/3")},	--5
				{tube = 4,	ord = 3, desc = _("upgrade-comms","speed up missile load time by 25%")},			--6
				{tube = 4,	ord = 4, desc = _("upgrade-comms","increase capacity: homing: 1/3, HVLI: 25%")},	--7
				{tube = 5,	ord = 4, desc = _("upgrade-comms","speed up load time by 20%")},					--8
				{tube = 6,	ord = 4, desc = _("upgrade-comms","increase tube size to large")},					--9
				{tube = 7,	ord = 5, desc = _("upgrade-comms","add mine tube")},								--10
				{tube = 7,	ord = 6, desc = _("upgrade-comms","double mine capacity")},							--11
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase mine capacity by 50%")},				--12
				{tube = 8,	ord = 7, desc = _("upgrade-comms","decrease tube load speed by 25%")},				--13
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase homing mine and HVLI capacity")},		--14
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 25, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "S", spd = 25, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "S", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "L", spd =  9, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "L", spd =  9, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 6},		--2
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 8},		--3
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 10},	--4		
				{hom = 8,  nuk = 0, emp = 0, min = 1, hvl = 10},	--5		
				{hom = 8,  nuk = 0, emp = 0, min = 2, hvl = 10},	--6		
				{hom = 8,  nuk = 0, emp = 0, min = 3, hvl = 10},	--7		
				{hom = 10, nuk = 0, emp = 0, min = 4, hvl = 12},	--8	
				["stock"] = {hom = 4, nuk = 0, emp = 0, min = 0, hvl = 6},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 60},
				},
				{	--2
					{idx = 0, max = 75},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 80},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 110},
					{idx = 1, max = 132},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				{	--10
					{idx = 0, max = 110},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~14%"),
				},
				["stock"] = {
					{idx = 0, max = 80},
					{idx = 1, max = 80},
				},
			},	
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--5
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--6
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~19%")},	--7
				["stock"] = {max = 120},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		60,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 1/3"),
				},
				{	--7
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	10,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase rear impulse acceleration by 25%"),
				},
				{	--9
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	10,
					turn = 			10,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--10
					max_front =		80,		max_back =		60,
					accel_front =	10,		accel_back = 	10,
					turn = 			12,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--11
					max_front =		80,		max_back =		60,
					accel_front =	15,		accel_back = 	10,
					turn = 			12,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase forward impulse acceleration by 50%"),
				},
				["stock"] = {
					{max_front = 55, turn = 9, accel_front = 10, max_back = 55, accel_back = 10, boost = 250, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","add 25u jump drive"),
				},
				{	--3
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--4
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--5
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 60000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--7
					jump_long = 60000, jump_short = 5000, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--8
					jump_long = 60000, jump_short = 5000, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--9
					jump_long = 60000, jump_short = 5000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--10
					jump_long = 60000, jump_short = 5000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
		["Player Cruiser"] = {	--10 + beam(8) + missile(12) + shield(8) + hull(6) + impulse(10) + ftl(10) + sensors(10) = 74
			["beam"] = {
				{	--1
					{idx = 0, arc = 60, dir = -15, rng = 800, cyc = 8, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 800, cyc = 8, dmg = 6},
				},
				{	--2
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 8, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 75, dir = -15, rng = 1000, cyc = 8, dmg = 6},
					{idx = 1, arc = 75, dir =  15, rng = 1000, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc by 25%")
				},
				{	--4
					{idx = 0, arc = 75, dir = -15, rng = 1000, cyc = 8, dmg = 8},
					{idx = 1, arc = 75, dir =  15, rng = 1000, cyc = 8, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage by 1/3")
				},
				{	--5
					{idx = 0, arc = 75, dir = -15, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 75, dir =  15, rng = 1000, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--6
					{idx = 0, arc = 90, dir = -15, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 90, dir =  15, rng = 1000, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase arc by 20%")
				},
				{	--7
					{idx = 0, arc = 90, dir = -15, rng = 1000, cyc = 6, dmg = 10},
					{idx = 1, arc = 90, dir =  15, rng = 1000, cyc = 6, dmg = 10},
					["desc"] = _("upgrade-comms","increase damage by 25%")
				},
				{	--8
					{idx = 0, arc = 90, dir = -15, rng = 1000, cyc = 4, dmg = 10},
					{idx = 1, arc = 90, dir =  15, rng = 1000, cyc = 4, dmg = 10},
					["desc"] = _("upgrade-comms","decrease cycle time by 1/3")
				},
				{	--9
					{idx = 0, arc = 90, dir = -15, rng = 1200, cyc = 4, dmg = 10},
					{idx = 1, arc = 90, dir =  15, rng = 1200, cyc = 4, dmg = 10},
					["desc"] = _("upgrade-comms","increase range by 20%")
				},
				["stock"] = {
					{idx = 0, arc =  90, dir = -15, rng = 1000, cyc = 6, dmg = 10},
					{idx = 1, arc =  90, dir =  15, rng = 1000, cyc = 6, dmg = 10},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																				--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","double HVLI capacity")},								--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","add mining tube")},									--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","triple mine capacity")},								--4
				{tube = 3,	ord = 5, desc = _("upgrade-comms","add homing missiles")},								--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","increase tube size to medium")},						--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase load speed by 25%")},						--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase homing capacity by 50%")},					--8
				{tube = 6,	ord = 7, desc = _("upgrade-comms","add nuke and EMPs")},								--9
				{tube = 6,	ord = 8, desc = _("upgrade-comms","increase HVLI capacity by 25%")},					--10
				{tube = 7,	ord = 8, desc = _("upgrade-comms","decrease load speed by 1/3")},						--11
				{tube = 7,	ord = 9, desc = _("upgrade-comms","increase homing capacity by 1/3")},					--12
				{tube = 7,	ord = 10,desc = _("upgrade-comms","increase capacity: nuke:100%, EMP:100%, mine:1/3")},	--13
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir = -90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = -90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = -90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = -90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =  90, siz = "M", spd = 6,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 8},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 1, hvl = 8},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 8},		--4		
				{hom = 4,  nuk = 0, emp = 0, min = 3, hvl = 8},		--5		
				{hom = 6,  nuk = 0, emp = 0, min = 3, hvl = 8},		--6		
				{hom = 6,  nuk = 1, emp = 2, min = 3, hvl = 8},		--7		
				{hom = 6,  nuk = 1, emp = 2, min = 3, hvl = 10},	--8	
				{hom = 8,  nuk = 1, emp = 2, min = 3, hvl = 10},	--9		
				{hom = 8,  nuk = 2, emp = 4, min = 4, hvl = 10},	--10		
				["stock"] = {hom = 4, nuk = 1, emp = 2, min = 0, hvl = 8},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 60},
				},
				{	--2
					{idx = 0, max = 75},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 120},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 132},
					{idx = 1, max = 110},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				{	--9
					{idx = 0, max = 150},
					{idx = 1, max = 110},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by ~14%"),
				},
				["stock"] = {
					{idx = 0, max = 80},
					{idx = 1, max = 80},
				},
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~19%")},	--6
				{max = 275, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 200},
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		80,		max_back =		80,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~14%"),
				},
				{	--3
					max_front =		80,		max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		80,		max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		80,		max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		90,		max_back =		90,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			300,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 12.5%"),
				},
				{	--7
					max_front =		90,		max_back =		90,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase impulse acceleration by 1/3"),
				},
				{	--9
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			10,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--10
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			12,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--11
					max_front =		100,	max_back =		90,
					accel_front =	20,		accel_back = 	16,
					turn = 			12,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase forward max impulse speed by ~11%"),
				},
				["stock"] = {
					{max_front = 90, turn = 10, accel_front = 20, max_back = 90, accel_back = 20, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 55000, jump_short = 5500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 10%"),
				},
				{	--8
					jump_long = 55000, jump_short = 5500, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 55000, jump_short = 5500, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--10
					jump_long = 60000, jump_short = 6000, warp = 500,
					desc = _("upgrade-comms","increase jump range by ~9%"),
				},
				{	--11
					jump_long = 60000, jump_short = 6000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 10%"),
				},
				{	--5
					short = 4500, long = 22000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 12.5%"),
				},
				{	--6
					short = 4500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--7
					short = 4500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 10,
		},
		["Player Missile Cr."] = {	--10 + beam(9) + missile(17) + shield(8) + hull(6) + impulse(10) + ftl(9) + sensors(10) = 79
			["beam"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--3
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =   0, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--4
					{idx = 0, arc = 30, dir = 180, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =   0, rng = 800, cyc = 8, dmg = 4},
					{idx = 2, arc = 30, dir = -90, rng = 800, cyc = 8, dmg = 4},
					{idx = 3, arc = 30, dir =  90, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--5
					{idx = 0, arc = 45, dir = 180, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 45, dir =   0, rng = 800, cyc = 8, dmg = 4},
					{idx = 2, arc = 45, dir = -90, rng = 800, cyc = 8, dmg = 4},
					{idx = 3, arc = 45, dir =  90, rng = 800, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--6
					{idx = 0, arc = 45, dir = 180, rng = 900, cyc = 8, dmg = 4},
					{idx = 1, arc = 45, dir =   0, rng = 900, cyc = 8, dmg = 4},
					{idx = 2, arc = 45, dir = -90, rng = 900, cyc = 8, dmg = 4},
					{idx = 3, arc = 45, dir =  90, rng = 900, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 12.5%"),
				},
				{	--7
					{idx = 0, arc = 45, dir = 180, rng = 900, cyc = 7, dmg = 4},
					{idx = 1, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 4},
					{idx = 2, arc = 45, dir = -90, rng = 900, cyc = 7, dmg = 4},
					{idx = 3, arc = 45, dir =  90, rng = 900, cyc = 7, dmg = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by 12.5%"),
				},
				{	--8
					{idx = 0, arc = 45, dir = 180, rng = 900, cyc = 7, dmg = 5},
					{idx = 1, arc = 45, dir =   0, rng = 900, cyc = 7, dmg = 5},
					{idx = 2, arc = 45, dir = -90, rng = 900, cyc = 7, dmg = 5},
					{idx = 3, arc = 45, dir =  90, rng = 900, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--9
					{idx = 0, arc = 60, dir = 180, rng = 900, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =   0, rng = 900, cyc = 7, dmg = 5},
					{idx = 2, arc = 60, dir = -90, rng = 900, cyc = 7, dmg = 5},
					{idx = 3, arc = 60, dir =  90, rng = 900, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase arc width by 1/3"),
				},
				{	--10
					{idx = 0, arc = 60, dir = 180, rng = 1000, cyc = 7, dmg = 5},
					{idx = 1, arc = 60, dir =   0, rng = 1000, cyc = 7, dmg = 5},
					{idx = 2, arc = 60, dir = -90, rng = 1000, cyc = 7, dmg = 5},
					{idx = 3, arc = 60, dir =  90, rng = 1000, cyc = 7, dmg = 5},
					["desc"] = _("upgrade-comms","increase range by ~11%"),
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																							--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","mining tube")},													--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","increase homing and HVLI capacity by 25%")},						--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add broadside tubes")},											--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","switch to medium sized tubes")},									--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add nukes and EMPs to front tubes")},							--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase hpoming capacity by 60%")},								--7
				{tube = 6,	ord = 5, desc = _("upgrade-comms","add more broadside tubes")},										--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","triple mine capacity")},											--9
				{tube = 7,	ord = 6, desc = _("upgrade-comms","make second broadside tubes large")},							--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase homing capacity by 25%")},								--11
				{tube = 7,	ord = 8, desc = _("upgrade-comms","increase capacity: nuke: 100%, EMP: 50%, mine: 100%")},			--12
				{tube = 7,	ord = 9, desc = _("upgrade-comms","increase homing capacity by 50%")},								--13
				{tube = 8,	ord = 9, desc = _("upgrade-comms","increase front and broadside tubes' load time by 20%")},			--14
				{tube = 9,	ord = 9, desc = _("upgrade-comms","add two more mining tubes")},									--15
				{tube = 9,	ord = 10,desc = _("upgrade-comms","increase capacity: nuke:100%, EMP:2/3, mine:100%, HVLI:20%")},	--16
				{tube = 10,	ord = 10,desc = _("upgrade-comms","increase load speed of medium tubes ~16%")},						--17
				{tube = 10,	ord = 11,desc = _("upgrade-comms","increase capacity by ~14% on average")},							--18
			},	
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 170, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir =   0, siz = "M", spd = 7,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 7,  hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 7,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir = -90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 170, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 8, dir = 190, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 1, dir =   0, siz = "M", spd = 8,  hom = true,  nuk = true,  emp = true,  min = false, hvl = false},
					{idx = 2, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =  90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = -90, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 7, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 8},		--1
				{hom = 8,  nuk = 0, emp = 0, min = 1, hvl = 8},		--2
				{hom = 10, nuk = 0, emp = 0, min = 1, hvl = 10},	--3
				{hom = 10, nuk = 2, emp = 4, min = 1, hvl = 10},	--4
				{hom = 16, nuk = 2, emp = 4, min = 1, hvl = 10},	--5
				{hom = 16, nuk = 2, emp = 4, min = 3, hvl = 10},	--6
				{hom = 20, nuk = 2, emp = 4, min = 3, hvl = 10},	--7
				{hom = 20, nuk = 4, emp = 6, min = 6, hvl = 10},	--8
				{hom = 30, nuk = 4, emp = 6, min = 6, hvl = 10},	--9
				{hom = 30, nuk = 8, emp = 10,min = 12,hvl = 12},	--10
				{hom = 36, nuk = 10,emp = 16,min = 18,hvl = 16},	--11
				["stock"] = {hom = 30, nuk = 8, emp = 10, min = 12, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 90},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by ~11%"),
				},
				{	--6
					{idx = 0, max = 100},
					{idx = 1, max = 70},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~17%"),
				},
				{	--7
					{idx = 0, max = 110},
					{idx = 1, max = 70},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 10%"),
				},
				{	--8
					{idx = 0, max = 121},
					{idx = 1, max = 70},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 10%"),
				},
				{	--9
					{idx = 0, max = 121},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by ~14%"),
				},
				["stock"] = {
					{idx = 0, max = 110},
					{idx = 1, max = 70},
				},
			},	
			["hull"] = {
				{max = 100},															--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--2
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~19%")},	--6
				{max = 275, ["desc"] = _("upgrade-comms","increase hull max by 10%")},	--7
				["stock"] = {max = 200},
			},
			["impulse"] = {
				{	--1
					max_front =		50,		max_back =		50,
					accel_front =	12,		accel_back = 	12,
					turn = 			7,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	12,		accel_back = 	12,
					turn = 			7,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	12,
					turn = 			7,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by ~14%"),
				},
				{	--5
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		70,		max_back =		70,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~17%"),
				},
				{	--7
					max_front =		70,		max_back =		70,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase impulse acceleration by 1/3"),
				},
				{	--9
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			8,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase combat maneuver by 20%"),
				},
				{	--10
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			10,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--11
					max_front =		80,		max_back =		70,
					accel_front =	20,		accel_back = 	12,
					turn = 			10,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase forward max impulse speed by ~14%"),
				},
				["stock"] = {
					{max_front = 60, turn = 8, accel_front = 15, max_back = 60, accel_back = 15, boost = 450, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--6
					jump_long = 0, jump_short = 0, warp = 750,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--7
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~7%"),
				},
				{	--8
					jump_long = 20000, jump_short = 2000, warp = 800,
					desc = _("upgrade-comms","add jump drive"),
				},
				{	--9
					jump_long = 20000, jump_short = 2000, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--10
					jump_long = 25000, jump_short = 2500, warp = 900,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 750},
				},
			},
			["sensors"] = {
				{	--1
					short = 4500, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4500, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4500, long = 20000, prox_scan = 1,
					desc = _("upgrade-comms","add 1 unit automated proximity scanner"),
				},
				{	--4
					short = 4500, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--5
					short = 5000, long = 25000, prox_scan = 1,
					desc = _("upgrade-comms","increase short range sensors by ~11%"),
				},
				{	--6
					short = 5000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase automated proximity scan range by 100%"),
				},
				{	--7
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--8
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase automated proximity scan range by 50%"),
				},
				{	--9
					short = 5000, long = 35000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--10
					short = 5000, long = 35000, prox_scan = 4,
					desc = _("upgrade-comms","increase automated proximity scan range by 1/3"),
				},
				{	--11
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 10,
		},
		["Player Fighter"] = {	--5 + beam(11) + missile(10) + shield(7) + hull(5) + impulse(8) + ftl(9) + sensors(7) = 62
			["beam"] = {
				{	--1
					{idx = 0, arc = 40, dir =   0, rng = 800, cyc = 8, dmg = 6},
				},
				{	--2
					{idx = 0, arc = 40, dir =   0, rng = 1000, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 40, dir =   0, rng = 1000, cyc = 7, dmg = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by 12.5%")
				},
				{	--4
					{idx = 0, arc = 40, dir =   0, rng = 1000, cyc = 7, dmg = 6},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 7, dmg = 6},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--5
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 7, dmg = 6},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 7, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc width of long beam by 50%")
				},
				{	--6
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 7, dmg = 7},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 7, dmg = 7},
					["desc"] = _("upgrade-comms","increase damage by ~17%"),
				},
				{	--7
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 7},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--8
					{idx = 0, arc = 60, dir =   0, rng = 1000, cyc = 6, dmg = 7},
					{idx = 1, arc = 40, dir =   0, rng =  800, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase damage of short beam by ~14%"),
				},
				{	--9
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 6, dmg = 7},
					{idx = 1, arc = 60, dir =   0, rng =  800, cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--10
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 60, dir =   0, rng =  800, cyc = 6, dmg = 10},
					["desc"] = _("upgrade-comms","increase damage by ~18%"),
				},
				{	--11
					{idx = 0, arc = 90, dir =   0, rng = 1000, cyc = 5, dmg = 8},
					{idx = 1, arc = 60, dir =   0, rng =  800, cyc = 5, dmg = 10},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--12
					{idx = 0, arc = 90, dir =   0, rng = 1100, cyc = 5, dmg = 8},
					{idx = 1, arc = 60, dir =   0, rng =  880, cyc = 5, dmg = 10},
					["desc"] = _("upgrade-comms","increase range by 10%"),
				},
				["stock"] = {
					{idx = 0, arc = 40, dir = -10, rng = 1000, cyc = 6, dmg = 8},
					{idx = 1, arc = 40, dir =  10, rng = 1000, cyc = 6, dmg = 8},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																						--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","reduce tube load speed by 1/3")},							--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","double HVLI capacity")},										--3  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","make tube medium sized")},									--4
				{tube = 4,	ord = 2, desc = _("upgrade-comms","add a small tube")},											--5
				{tube = 5,	ord = 3, desc = _("upgrade-comms","add homing capability to small tube")},						--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 25%")},							--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 50%")},							--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add a mining tube")},										--9
				{tube = 6,	ord = 7, desc = _("upgrade-comms","increase capacity: homing: 1/3, mining: 100%, HVLI: 20%")},	--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","reduce mine tube load time by 1/3")},						--11
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "S", spd = 8,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 2},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--2
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--3
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 5},		--4		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 5},		--5		
				{hom = 3,  nuk = 0, emp = 0, min = 1, hvl = 5},		--6		
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 6},		--7		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 4},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 30},
				},
				{	--2
					{idx = 0, max = 40},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--3
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--5
					{idx = 0, max = 40},
					{idx = 1, max = 40},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--6
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 66},
					{idx = 1, max = 66},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				["stock"] = {
					{idx = 0, max = 40},
				},
			},
			["hull"] = {
				{max =  40},															--1
				{max =  50, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max =  60, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},	--4
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--5
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--6
				["stock"] = {max = 60},
			},
			["impulse"] = {
				{	--1
					max_front =		90,		max_back =		90,
					accel_front =	36,		accel_back = 	30,
					turn = 			16,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		100,	max_back =		100,
					accel_front =	36,		accel_back = 	30,
					turn = 			16,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~11%"),
				},
				{	--3
					max_front =		100,	max_back =		100,
					accel_front =	45,		accel_back = 	30,
					turn = 			16,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		100,	max_back =		100,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		100,	max_back =		100,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			600,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			600,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--7
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	30,
					turn = 			20,
					boost =			700,	strafe =		0,
					desc = _("upgrade-comms","increase combat maneuver by ~17%"),
				},
				{	--8
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	30,
					turn = 			25,
					boost =			700,	strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--9
					max_front =		120,	max_back =		120,
					accel_front =	45,		accel_back = 	36,
					turn = 			25,
					boost =			700,	strafe =		0,
					desc = _("upgrade-comms","increase reverse impulse acceleration by 20%"),
				},
				["stock"] = {
					{max_front = 110, turn = 20, accel_front = 40, max_back = 110, accel_back = 40, boost = 600, strafe = 0},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--5
					short = 5000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--6
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--7
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--8
					short = 5000, long = 35000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 5,
		},
		["Nautilus"] = {	--8 + beam(11) + missile(13) + shield(7) + hull(5) + impulse(9) + ftl(10) + sensors(9) = 72
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir =   0, rng =  800, cyc = 8, dmg = 5, tar =  60, tdr = 0, trt = 2},
				},
				{	--2
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 8, dmg = 5, tar =  60, tdr = 0, trt = 2},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 10, dir =   0, rng = 1000, cyc = 7, dmg = 5, tar =  60, tdr = 0, trt = 2},
					["desc"] = _("upgrade-comms","reduce cycle time by 12.5%")
				},
				{	--4
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 5, tar =  60, tdr =  35, trt = 2},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 5, tar =  60, tdr = -35, trt = 2},
					["desc"] = _("upgrade-comms","add beam")
				},
				{	--5
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 5, tar =  90, tdr =  35, trt = 2},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 5, tar =  90, tdr = -35, trt = 2},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--6
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr =  35, trt = 2},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr = -35, trt = 2},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				{	--7
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr =  35, trt = 4},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 7, dmg = 6, tar =  90, tdr = -35, trt = 4},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--8
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 4},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 4},
					["desc"] = _("upgrade-comms","decrease cycle time by ~14%"),
				},
				{	--9
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 4},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 4},
					["desc"] = _("upgrade-comms","increase range by 20%"),
				},
				{	--10
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 6},
					["desc"] = _("upgrade-comms","increase turret speed by 50%"),
				},
				{	--11
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 6, dmg = 8, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 6, dmg = 8, tar =  90, tdr = -35, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 1/3"),
				},
				{	--12
					{idx = 0, arc = 10, dir =  35, rng = 1200, cyc = 5, dmg = 8, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1200, cyc = 5, dmg = 8, tar =  90, tdr = -35, trt = 6},
					["desc"] = _("upgrade-comms","decrease cycle time by ~17%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir =  35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr =  35, trt = 6},
					{idx = 1, arc = 10, dir = -35, rng = 1000, cyc = 6, dmg = 6, tar =  90, tdr = -35, trt = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																					--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase mine capacity by 1/3")},						--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add another mining tube")},								--3  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","reduce tube load time by 25%")},							--4
				{tube = 3,	ord = 3, desc = _("upgrade-comms","increase mine capacity by 50%")},						--5
				{tube = 4,	ord = 3, desc = _("upgrade-comms","reduce load speed by 1/3")},								--6
				{tube = 5,	ord = 3, desc = _("upgrade-comms","add another mining tube")},								--7
				{tube = 6,	ord = 4, desc = _("upgrade-comms","add HVLI capability to first mining tube")},				--8
				{tube = 7,	ord = 5, desc = _("upgrade-comms","add homing capability to second mining tube")},			--9
				{tube = 8,	ord = 6, desc = _("upgrade-comms","make first tube a large tube")},							--10
				{tube = 8,	ord = 7, desc = _("upgrade-comms","increase HVLI capacity by 25%")},						--11
				{tube = 9,	ord = 7, desc = _("upgrade-comms","reduce tube load speed time by 20%")},					--12
				{tube = 9,	ord = 8, desc = _("upgrade-comms","increase capacity: homing:100%, mine:1/3, HVLI:20%")},	--13
				{tube = 10,	ord = 8, desc = _("upgrade-comms","make second tube a large tube")},						--14
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--2
					{idx = 0, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir = 180, siz = "L", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir = 180, siz = "L", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 8,  hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir = 180, siz = "L", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = true },
					{idx = 1, dir = 180, siz = "L", spd = 8,  hom = true,  nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 8,  hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 10, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 3, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 4, hvl = 0},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 6, hvl = 0},		--3
				{hom = 0,  nuk = 0, emp = 0, min = 6, hvl = 4},		--4		
				{hom = 2,  nuk = 0, emp = 0, min = 6, hvl = 4},		--5		
				{hom = 2,  nuk = 0, emp = 0, min = 9, hvl = 4},		--6		
				{hom = 2,  nuk = 0, emp = 0, min = 9, hvl = 5},		--7		
				{hom = 4,  nuk = 0, emp = 0, min = 12,hvl = 6},		--8	
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 12, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 40},
				},
				{	--2
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--5
					{idx = 0, max = 50},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				{	--6
					{idx = 0, max = 60},
					{idx = 1, max = 72},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 60},
					{idx = 1, max = 96},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 75},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				["stock"] = {
					{idx = 0, max = 60},
					{idx = 1, max = 60},
				},
			},
			["hull"] = {
				{max = 60},												--1
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},		--2
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--3
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--4
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--5
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--6
				["stock"] = {max = 100},
			},
			["impulse"] = {
				{	--1
					max_front =		80,		max_back =		80,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		100,	max_back =		80,
					accel_front =	12,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--3
					max_front =		100,	max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		100,	max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		100,	max_back =		80,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		110,	max_back =		88,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 10%"),
				},
				{	--7
					max_front =		110,	max_back =		88,
					accel_front =	15,		accel_back = 	12,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver strafe"),
				},
				{	--8
					max_front =		110,	max_back =		88,
					accel_front =	20,		accel_back = 	15,
					turn = 			10,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase impulse acceleration by 1/3"),
				},
				{	--9
					max_front =		110,	max_back =		88,
					accel_front =	20,		accel_back = 	15,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--10
					max_front =		110,	max_back =		88,
					accel_front =	20,		accel_back = 	15,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				["stock"] = {
					{max_front = 100, turn = 10, accel_front = 15, max_back = 100, accel_back = 15, boost = 250, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 55000, jump_short = 5500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 10%"),
				},
				{	--8
					jump_long = 55000, jump_short = 5500, warp = 300,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--9
					jump_long = 55000, jump_short = 5500, warp = 400,
					desc = _("upgrade-comms","increase warp speed by 1/3"),
				},
				{	--10
					jump_long = 60000, jump_short = 6000, warp = 400,
					desc = _("upgrade-comms","increase jump range by ~9%"),
				},
				{	--11
					jump_long = 60000, jump_short = 6000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 4000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--5
					short = 5000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--6
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				{	--7
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--8
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--9
					short = 5000, long = 50000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--10
					short = 5000, long = 60000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
		["Striker"] = {		--6 + beam(8) + missile(11) + shield(8) + hull(5) + impulse(8) + ftl(6) + sensors(5) = 57
			["beam"] = {
				{	--1
					{idx = 0, arc = 30, dir = -15, rng = 800, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =  15, rng = 800, cyc = 8, dmg = 4},
				},
				{	--2
					{idx = 0, arc = 30, dir = -15, rng = 1000, cyc = 8, dmg = 4},
					{idx = 1, arc = 30, dir =  15, rng = 1000, cyc = 8, dmg = 4},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 30, dir = -15, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc = 30, dir =  15, rng = 1000, cyc = 6, dmg = 4},
					["desc"] = _("upgrade-comms","reduce cycle time by 25%")
				},
				{	--4
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 6, dmg = 4},
					["desc"] = _("upgrade-comms","increase arc width by 2/3")
				},
				{	--5
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 6, dmg = 6},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by 50%")
				},
				{	--6
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 5, dmg = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--7
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 5, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc width by 20%"),
				},
				{	--8
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 5, dmg = 6},
					{idx = 2, arc = 20, dir =   0, rng = 1500, cyc = 5, dmg = 5},
					["desc"] = _("upgrade-comms","add sniping beam"),
				},
				{	--9
					{idx = 0, arc = 60, dir = -15, rng = 1000, cyc = 5, dmg = 7},
					{idx = 1, arc = 60, dir =  15, rng = 1000, cyc = 5, dmg = 7},
					{idx = 2, arc = 20, dir =   0, rng = 1500, cyc = 5, dmg = 6},
					["desc"] = _("upgrade-comms","increase damage by ~18%"),
				},
				["stock"] = {
					{idx = 0, arc = 50, dir = -15, rng = 1000, cyc = 6, dmg = 6},
					{idx = 1, arc = 50, dir =  15, rng = 1000, cyc = 6, dmg = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																		--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add small HVLI broadsides")},				--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","reduce tube load time by 10%")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","double HVLI capacity")},						--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 1/3")},				--5
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add homing capability to tubes")},			--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase capacity: homing:100%, HVLI:50%")},	--7
				{tube = 6,	ord = 6, desc = _("upgrade-comms","add a mining tube")},						--8
				{tube = 6,	ord = 7, desc = _("upgrade-comms","double mine capacity")},						--9
				{tube = 7,	ord = 7, desc = _("upgrade-comms","reduce tube load speed by 25%")},			--10
				{tube = 8,	ord = 7, desc = _("upgrade-comms","make broadside tubes medium size")},			--11
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase HVLI capacity by 1/3")},			--12
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir =  90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =  90, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =  90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =  90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =  90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =  90, siz = "S", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "S", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =  90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 2},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--3
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--4
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 6},		--5
				{hom = 4,  nuk = 0, emp = 0, min = 1, hvl = 6},		--6
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 6},		--7
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 8},		--8
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 40},
				},
				{	--2
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 40},
					{idx = 1, max = 40},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--5
					{idx = 0, max = 50},
					{idx = 1, max = 40},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 60},
					{idx = 1, max = 48},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 80},
					{idx = 1, max = 48},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 100},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--9
					{idx = 0, max = 100},
					{idx = 1, max = 72},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 50},
					{idx = 1, max = 30},
				},
			},
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--5
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--6
				["stock"] = {max = 120},
			},
			["impulse"] = {
				{	--1
					max_front =		45,		max_back =		45,
					accel_front =	24,		accel_back = 	24,
					turn = 			12,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	24,		accel_back = 	24,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 1/3"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		72,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			15,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward max impulse by 20%"),
				},
				{	--6
					max_front =		72,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			15,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--7
					max_front =		72,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			20,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--8
					max_front =		90,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			20,
					boost =			200,	strafe =		100,
					desc = _("upgrade-comms","increase max impulse speed by 25%"),
				},
				{	--9
					max_front =		90,		max_back =		60,
					accel_front =	30,		accel_back = 	24,
					turn = 			20,
					boost =			300,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				["stock"] = {
					{max_front = 45, turn = 15, accel_front = 30, max_back = 45, accel_back = 15, boost = 250, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 50%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 500,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--5
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--6
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--7
					jump_long = 40000, jump_short = 4000, warp = 700,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--3
					short = 4000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--5
					short = 5000, long = 35000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--6
					short = 5000, long = 40000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 6,
		},
		["Ender"] = {		--25 + beam(11) + missile(11) + shield(8) + hull(5) + impulse(14) + ftl(8) + sensors(11) = 93
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
				},
				{	--2
					{idx = 0, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--3
					{idx = 0, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 1500, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 1500, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","add beams")
				},
				{	--4
					{idx = 0, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 60, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 60, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase range by 1/3"),
				},
				{	--5
					{idx = 0, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2000, cyc = 8.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2000, cyc = 8.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--6
					{idx = 0, arc = 10, dir = -90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2000, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2000, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","decrease cycle time by 25%")
				},
				{	--7
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 4, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 4, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--8
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 90, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 90, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--9
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","increase arc width by 1/3"),
				},
				{	--10
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  90, trt = 6},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--11
					{idx = 0, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  -80, trt = 6},
					{idx = 1, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -100, trt = 6},
					{idx = 2, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =   80, trt = 6},
					{idx = 3, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  100, trt = 6},
					{idx = 4, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  -80, trt = 6},
					{idx = 5, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -100, trt = 6},
					{idx = 6, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =   80, trt = 6},
					{idx = 7, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  100, trt = 6},
					{idx = 8, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =  -80, trt = 6},
					{idx = 9, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr = -100, trt = 6},
					{idx = 10,arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 120, tdr =   80, trt = 6},
					{idx = 11,arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 120, tdr =  100, trt = 6},
					["desc"] = _("upgrade-comms","adjust beam angles for more coverage"),
				},
				{	--12
					{idx = 0, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =  -80, trt = 6},
					{idx = 1, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr = -100, trt = 6},
					{idx = 2, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =   80, trt = 6},
					{idx = 3, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr =  100, trt = 6},
					{idx = 4, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =  -80, trt = 6},
					{idx = 5, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr = -100, trt = 6},
					{idx = 6, arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =   80, trt = 6},
					{idx = 7, arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr =  100, trt = 6},
					{idx = 8, arc = 10, dir =  -80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =  -80, trt = 6},
					{idx = 9, arc = 10, dir = -100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr = -100, trt = 6},
					{idx = 10,arc = 10, dir =   80, rng = 2500, cyc = 5.1, dmg = 5, tar = 150, tdr =   80, trt = 6},
					{idx = 11,arc = 10, dir =  100, rng = 2500, cyc = 5.0, dmg = 5, tar = 150, tdr =  100, trt = 6},
					["desc"] = _("upgrade-comms","increase beam arc by 25%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir = -90, rng = 2500, cyc = 6.1, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 1, arc = 10, dir = -90, rng = 2500, cyc = 6.0, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 2, arc = 10, dir =  90, rng = 2500, cyc = 5.8, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 3, arc = 10, dir =  90, rng = 2500, cyc = 6.3, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 4, arc = 10, dir = -90, rng = 2500, cyc = 5.9, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 5, arc = 10, dir = -90, rng = 2500, cyc = 6.4, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 6, arc = 10, dir =  90, rng = 2500, cyc = 5.7, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 7, arc = 10, dir =  90, rng = 2500, cyc = 5.6, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 8, arc = 10, dir = -90, rng = 2500, cyc = 6.6, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 9, arc = 10, dir = -90, rng = 2500, cyc = 5.5, dmg = 4, tar = 120, tdr = -90, trt = 6},
					{idx = 10,arc = 10, dir =  90, rng = 2500, cyc = 6.5, dmg = 4, tar = 120, tdr =  90, trt = 6},
					{idx = 11,arc = 10, dir =  90, rng = 2500, cyc = 6.2, dmg = 4, tar = 120, tdr =  90, trt = 6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																	--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add medium homing tubes")},				--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","double capacity")},						--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 10%")},			--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","increase capacity by 50%")},				--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","add more tubes")},						--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","reduce tube load time by ~17%")},		--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase capacity by 1/3")},				--8
				{tube = 6,	ord = 5, desc = _("upgrade-comms","make two lower tubes large")},			--9
				{tube = 6,	ord = 6, desc = _("upgrade-comms","increase capacity by 25%")},				--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","reduce tube load times by 20%")},		--11
				{tube = 8,	ord = 7, desc = _("upgrade-comms","reduce medium tube load times by 25%")},	--12
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir =   0, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 20, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "L", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 9,  hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 0, dir =   0, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "L", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 0},		--2
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 0},		--3
				{hom = 12, nuk = 0, emp = 0, min = 0, hvl = 0},		--4
				{hom = 16, nuk = 0, emp = 0, min = 0, hvl = 0},		--5
				{hom = 20, nuk = 0, emp = 0, min = 0, hvl = 0},		--6
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 400},
				},
				{	--2
					{idx = 0, max = 600},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--3
					{idx = 0, max = 800},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 600},
					{idx = 1, max = 600},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--5
					{idx = 0, max = 800},
					{idx = 1, max = 800},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 1000},
					{idx = 1, max = 1000},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 1200},
					{idx = 1, max = 1200},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--8
					{idx = 0, max = 1500},
					{idx = 1, max = 1500},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--9
					{idx = 0, max = 1800},
					{idx = 1, max = 1800},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 1200},
					{idx = 1, max = 1200},
				},
			},
			["hull"] = {
				{max = 80},																--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--3
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},	--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 25%")},	--5
				{max = 210, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--6
				["stock"] = {max = 100},
			},
			["impulse"] = {
				{	--1
					max_front =		15,		max_back =		15,
					accel_front =	2,		accel_back = 	2,
					turn = 			1,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		18,		max_back =		18,
					accel_front =	2,		accel_back = 	2,
					turn = 			1,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		18,		max_back =		18,
					accel_front =	3,		accel_back = 	2,
					turn = 			1,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by 50%"),
				},
				{	--4
					max_front =		18,		max_back =		18,
					accel_front =	3,		accel_back = 	2,
					turn = 			1.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 50%"),
				},
				{	--5
					max_front =		20,		max_back =		20,
					accel_front =	3,		accel_back = 	2,
					turn = 			1.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse by ~11%"),
				},
				{	--6
					max_front =		20,		max_back =		20,
					accel_front =	4,		accel_back = 	2,
					turn = 			1.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleratione by 1/3"),
				},
				{	--7
					max_front =		20,		max_back =		20,
					accel_front =	4,		accel_back = 	2,
					turn = 			2,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--8
					max_front =		24,		max_back =		24,
					accel_front =	4,		accel_back = 	2,
					turn = 			2,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--9
					max_front =		24,		max_back =		24,
					accel_front =	6,		accel_back = 	3,
					turn = 			2,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by 50%"),
				},
				{	--10
					max_front =		24,		max_back =		24,
					accel_front =	6,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--11
					max_front =		30,		max_back =		30,
					accel_front =	6,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 25%"),
				},
				{	--12
					max_front =		30,		max_back =		30,
					accel_front =	7,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by ~17%"),
				},
				{	--13
					max_front =		36,		max_back =		30,
					accel_front =	7,		accel_back = 	3,
					turn = 			2.5,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max forward impulse speed by 20%"),
				},
				{	--14
					max_front =		36,		max_back =		30,
					accel_front =	7,		accel_back = 	3,
					turn = 			3,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--15
					max_front =		36,		max_back =		30,
					accel_front =	8,		accel_back = 	4,
					turn = 			3,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by ~24%"),
				},
				["stock"] = {
					{max_front = 20, turn = 1.5, accel_front = 3, max_back = 20, accel_back = 1.5, boost = 0, strafe = 0},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 35000, jump_short = 3500, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~16%"),
				},
				{	--6
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~14%"),
				},
				{	--7
					jump_long = 45000, jump_short = 4500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 12.5%"),
				},
				{	--8
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by ~11%"),
				},
				{	--9
					jump_long = 50000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","cut minimum jump range to 2 units"),
				},
				["stock"] = {
					{jump_long = 50000, jump_short = 5000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--3
					short = 5000, long = 30000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--4
					short = 5000, long = 35000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~17%"),
				},
				{	--5
					short = 5000, long = 40000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~14%"),
				},
				{	--6
					short = 5000, long = 45000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 12.5%"),
				},
				{	--7
					short = 5000, long = 50000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by ~11%"),
				},
				{	--8
					short = 6000, long = 50000, prox_scan = 0,
					desc = _("upgrade-comms","increase short range sensors by 20%"),
				},
				{	--9
					short = 6000, long = 50000, prox_scan = 4,
					desc = _("upgrade-comms","add 4 unit automated proximity scanner"),
				},
				{	--10
					short = 6000, long = 60000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range scan by 20%"),
				},
				{	--11
					short = 6000, long = 70000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range scan by ~17%"),
				},
				{	--12
					short = 6000, long = 80000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range scan by ~14%"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 25,
		},
		["MP52 Hornet"] = {	--5 + beam(11) + missile(12) + shield(7) + hull(5) + impulse(6) + ftl(9) + sensors(4) = 59
			["beam"] = {
				{	--1
					{idx = 0, arc = 20, dir =   5, rng = 800, cyc = 5, dmg = 2},
					{idx = 1, arc = 20, dir =  -5, rng = 800, cyc = 5, dmg = 2},
				},
				{	--2
					{idx = 0, arc = 20, dir =   5, rng = 900, cyc = 5, dmg = 2},
					{idx = 1, arc = 20, dir =  -5, rng = 900, cyc = 5, dmg = 2},
					["desc"] = _("upgrade-comms","increase range by 25%")
				},
				{	--3
					{idx = 0, arc = 20, dir =   5, rng = 900, cyc = 4, dmg = 2},
					{idx = 1, arc = 20, dir =  -5, rng = 900, cyc = 4, dmg = 2},
					["desc"] = _("upgrade-comms","reduce cycle time by 20%")
				},
				{	--4
					{idx = 0, arc = 20, dir =   5, rng = 900, cyc = 4, dmg = 2.5},
					{idx = 1, arc = 20, dir =  -5, rng = 900, cyc = 4, dmg = 2.5},
					["desc"] = _("upgrade-comms","increase damage by 25%")
				},
				{	--5
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 2.5},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 2.5},
					["desc"] = _("upgrade-comms","increase arc width by 50%")
				},
				{	--6
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					["desc"] = _("upgrade-comms","increase damage by 20%"),
				},
				{	--7
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					{idx = 2, arc = 20, dir =   0, rng = 800, cyc = 6, dmg = 6},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--8
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					{idx = 2, arc = 20, dir =   0, rng = 800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase damage of short beam by ~17%"),
				},
				{	--9
					{idx = 0, arc = 36, dir =   5, rng = 900, cyc = 4, dmg = 3},
					{idx = 1, arc = 36, dir =  -5, rng = 900, cyc = 4, dmg = 3},
					{idx = 2, arc = 24, dir =   0, rng = 800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase arc width by 20%"),
				},
				{	--10
					{idx = 0, arc = 36, dir =   5, rng = 900, cyc = 4, dmg = 4},
					{idx = 1, arc = 36, dir =  -5, rng = 900, cyc = 4, dmg = 4},
					{idx = 2, arc = 24, dir =   0, rng = 800, cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase long beam damage by 1/3"),
				},
				{	--11
					{idx = 0, arc = 36, dir =   5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 1, arc = 36, dir =  -5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 2, arc = 24, dir =   0, rng = 800,  cyc = 6, dmg = 7},
					["desc"] = _("upgrade-comms","increase long beam range by ~11%"),
				},
				{	--12
					{idx = 0, arc = 36, dir =   5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 1, arc = 36, dir =  -5, rng = 1000, cyc = 4, dmg = 4},
					{idx = 2, arc = 24, dir =   0, rng = 800,  cyc = 6, dmg = 8},
					["desc"] = _("upgrade-comms","increase short beam damage by ~14%"),
				},
				["stock"] = {
					{idx = 0, arc = 30, dir =   5, rng = 900, cyc = 4, dmg = 2.5},
					{idx = 1, arc = 30, dir =  -5, rng = 900, cyc = 4, dmg = 2.5},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},																					--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add rear HVLI tube")},									--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","double HVLI capacity")},									--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 25%")},							--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","make small tube medium sized")},							--5
				{tube = 5,	ord = 3, desc = _("upgrade-comms","reduce tube load time by 20%")},							--6
				{tube = 6,	ord = 3, desc = _("upgrade-comms","add small tube")},										--7
				{tube = 7,	ord = 4, desc = _("upgrade-comms","add homing capability to small tube")},					--8
				{tube = 7,	ord = 5, desc = _("upgrade-comms","double capacity")},										--9
				{tube = 8,	ord = 5, desc = _("upgrade-comms","reduce small tube load time by ~17%")},					--10
				{tube = 8,	ord = 6, desc = _("upgrade-comms","increase homing capacity by 50%")},						--11
				{tube = 9,	ord = 7, desc = _("upgrade-comms","add a mining tube")},									--12
				{tube = 9,	ord = 8, desc = _("upgrade-comms","increase capacity: homing:1/3, mine:100%, HVLI:50%")},	--13
			},
			["tube"] = {
				{	--1
					{idx = -1},
				},
				{	--2
					{idx = 0, dir = 180, siz = "S", spd = 20, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir = 180, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir = 180, siz = "M", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir = 180, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir = 180, siz = "S", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--8
					{idx = 0, dir = 180, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--9
					{idx = 0, dir = 180, siz = "S", spd = 10, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = 180, siz = "M", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = 180, siz = "M", spd = 20, hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = -1},
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 1},		--2
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 2},		--3
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 2},		--4
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 4},		--5		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 4},		--6		
				{hom = 3,  nuk = 0, emp = 0, min = 1, hvl = 4},		--7		
				{hom = 4,  nuk = 0, emp = 0, min = 2, hvl = 6},		--8		
				["stock"] = {hom = 0, nuk = 0, emp = 0, min = 0, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 40},
				},
				{	--2
					{idx = 0, max = 50},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--4
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--5
					{idx = 0, max = 50},
					{idx = 1, max = 50},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--6
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 80},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 1/3"),
				},
				{	--8
					{idx = 0, max = 96},
					{idx = 1, max = 72},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 60},
				},
			},
			["hull"] = {
				{max = 50},												--1
				{max =  60, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},		--3
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--5
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--6
				["stock"] = {max = 70},
			},
			["impulse"] = {
				{	--1
					max_front =		100,	max_back =		100,
					accel_front =	36,		accel_back = 	36,
					turn = 			24,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		120,	max_back =		120,
					accel_front =	36,		accel_back = 	36,
					turn = 			24,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by 20%"),
				},
				{	--3
					max_front =		120,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			24,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase forward acceleration by ~17%"),
				},
				{	--4
					max_front =		120,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			30,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		120,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			30,
					boost =			600,		strafe =		0,
					desc = _("upgrade-comms","add combat maneuver boost"),
				},
				{	--6
					max_front =		132,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			30,
					boost =			600,		strafe =		0,
					desc = _("upgrade-comms","increase forward max impulse speed by 10%"),
				},
				{	--7
					max_front =		132,	max_back =		120,
					accel_front =	42,		accel_back = 	36,
					turn = 			33,
					boost =			600,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 10%"),
				},
				["stock"] = {
					{max_front = 125, turn = 32, accel_front = 40, max_back = 125, accel_back = 40, boost = 600, strafe = 0},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--5
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 5,
		},
		["ZX-Lindworm"] = {	--5 + beam(8) + missile(16) + shield(5) + hull(5) + impulse(9) + ftl(9) + sensors(5) = 62
			["beam"] = {
				{	--1
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar =  90, tdr = 180, trt = 1},
				},
				{	--2
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar = 180, tdr = 180, trt = 1},
					["desc"] = _("upgrade-comms","double arc width"),
				},
				{	--3
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar = 180, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--4
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 8, dmg = 2, tar = 270, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","increase arc width by 50%"),
				},
				{	--5
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","reduce cycle time by 25%"),
				},
				{	--6
					{idx = 0, arc = 10, dir =   0, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr =   0, trt = 2},
					{idx = 1, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 2},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--7
					{idx = 0, arc = 10, dir =   0, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr =   0, trt = 3},
					{idx = 1, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 3},
					["desc"] = _("upgrade-comms","increase turret speed by 50%"),
				},
				{	--8
					{idx = 0, arc = 10, dir =   0, rng =  800, cyc = 6, dmg = 2, tar = 200, tdr =   0, trt = 3},
					{idx = 1, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 2, tar = 200, tdr = 180, trt = 3},
					["desc"] = _("upgrade-comms","increase range by ~14%, decrease arc width by ~26%"),
				},
				{	--9
					{idx = 0, arc = 10, dir =   0, rng =  800, cyc = 6, dmg = 3, tar = 200, tdr =   0, trt = 3},
					{idx = 1, arc = 10, dir = 180, rng =  800, cyc = 6, dmg = 3, tar = 200, tdr = 180, trt = 3},
					["desc"] = _("upgrade-comms","increase damage by 50%"),
				},
				["stock"] = {
					{idx = 0, arc = 10, dir = 180, rng =  700, cyc = 6, dmg = 2, tar = 270, tdr = 180, trt = 2},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase HVLI capacity by 25%")},				--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","add homing capability")},						--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","increase HVLI capacity by 20%")},				--4
				{tube = 3,	ord = 5, desc = _("upgrade-comms","add two small HVLI tubes, increase HVLI capacity by 1/3")},	--5
				{tube = 4,	ord = 5, desc = _("upgrade-comms","reduce tube load speed by ~17%")},				--6
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase HVLI capacity by 25%")},				--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","add two more small HVLI tubes")},				--8
				{tube = 5,	ord = 6, desc = _("upgrade-comms","increase capacity: homing:100%, HVLI:25%")},	--9
				{tube = 6,	ord = 6, desc = _("upgrade-comms","make central tube medium sized")},				--10
				{tube = 7,	ord = 6, desc = _("upgrade-comms","reduce small tube load time by 20%")},			--11
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase capacity: homing:50%, HVLI:20%")},		--12
				{tube = 8,	ord = 7, desc = _("upgrade-comms","reduce tube load time by ~23%")},				--13
				{tube = 8,	ord = 8, desc = _("upgrade-comms","increase HVLI capacity by ~17%")},				--14
				{tube = 9,	ord = 8, desc = _("upgrade-comms","add two more small HVLI tubes")},				--15
				{tube = 9,	ord = 9, desc = _("upgrade-comms","increase HVLI capacity by ~14%")},				--16
				{tube = 9,	ord = 10,desc = _("upgrade-comms","increase capacity: homing:1/3, HVLI:25%")},		--17
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 18, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 18, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =   0, siz = "S", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 15, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--7
					{idx = 0, dir =   0, siz = "M", spd = 15, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 12, hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--8
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				{	--9
					{idx = 0, dir =   0, siz = "M", spd = 12, hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 3, dir =   2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  -2, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir =   3, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 6, dir =  -3, siz = "S", spd = 9,  hom = false, nuk = false, emp = false, min = false, hvl = true },
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "S", spd = 10, hom = true, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   1, siz = "S", spd = 10, hom = false,nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir =  -1, siz = "S", spd = 10, hom = false,nuk = false, emp = false, min = false, hvl = true },
				},
			},
			["ordnance"] = {
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 4},		--1
				{hom = 0,  nuk = 0, emp = 0, min = 0, hvl = 5},		--2
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 5},		--3
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 6},		--4		
				{hom = 1,  nuk = 0, emp = 0, min = 0, hvl = 8},		--5		
				{hom = 2,  nuk = 0, emp = 0, min = 0, hvl = 10},	--6		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 12},	--7		
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 14},	--8	
				{hom = 3,  nuk = 0, emp = 0, min = 0, hvl = 16},	--9
				{hom = 4,  nuk = 0, emp = 0, min = 0, hvl = 20},	--10	
				["stock"] = {hom = 1, nuk = 0, emp = 0, min = 0, hvl = 4},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 30},
				},
				{	--2
					{idx = 0, max = 40},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--3
					{idx = 0, max = 60},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 50%"),
				},
				{	--4
					{idx = 0, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--5
					{idx = 0, max = 60},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear arc"),
				},
				{	--6
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				["stock"] = {
					{idx = 0, max = 40},
				},
			},
			["hull"] = {
				{max = 50},												--1
				{max =  60, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--2
				{max =  80, ["desc"] = _("upgrade-comms","increase hull max by 1/3")},		--3
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--5
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--6
				["stock"] = {max = 75},
			},
			["impulse"] = {
				{	--1
					max_front =		60,		max_back =		60,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	20,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max impulse speed by ~17%"),
				},
				{	--3
					max_front =		70,		max_back =		70,
					accel_front =	20,		accel_back = 	25,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase rear acceleration by 25%"),
				},
				{	--4
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			12,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max rear impulse by ~15%"),
				},
				{	--5
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			12,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			15,
					boost =			250,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--7
					max_front =		70,		max_back =		80,
					accel_front =	20,		accel_back = 	25,
					turn = 			15,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase combat maneuver by 20%"),
				},
				{	--8
					max_front =		84,		max_back =		96,
					accel_front =	20,		accel_back = 	25,
					turn = 			15,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase max impulse by 20%"),
				},
				{	--9
					max_front =		84,		max_back =		96,
					accel_front =	24,		accel_back = 	30,
					turn = 			15,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase acceleration by 20%"),
				},
				{	--10
					max_front =		84,		max_back =		96,
					accel_front =	24,		accel_back = 	30,
					turn = 			20,
					boost =			300,	strafe =		180,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				["stock"] = {
					{max_front = 70, turn = 15, accel_front = 25, max_back = 70, accel_back = 25, boost = 250, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 400,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 400,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--4
					jump_long = 20000, jump_short = 2000, warp = 500,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				{	--5
					jump_long = 25000, jump_short = 2500, warp = 500,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--6
					jump_long = 25000, jump_short = 2500, warp = 600,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--7
					jump_long = 30000, jump_short = 3000, warp = 600,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--8
					jump_long = 30000, jump_short = 3000, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--9
					jump_long = 35000, jump_short = 3500, warp = 700,
					desc = _("upgrade-comms","increase jump range by ~17%"),
				},
				{	--10
					jump_long = 35000, jump_short = 3500, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 4000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 4000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 25%"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--5
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--6
					short = 5000, long = 40000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
				},
				["stock"] = {
					{short = 5000, long = 30000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 5,
		},
		["Amalgam"] = {		--9 + beam(7) + missile(10) + shield(7) + hull(6) + impulse(8) + ftl(6) + sensors(4) = 57
			["beam"] = {
				{	--1
					{idx = 0, arc =  60, dir = -20, rng = 1000, cyc = 8, dmg = 6},
					{idx = 1, arc =  60, dir =  20, rng = 1000, cyc = 8, dmg = 6},
				},
				{	--2
					{idx = 0, arc =  60, dir = -20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc =  60, dir =  20, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 6},
					["desc"] = _("upgrade-comms","increase arc by 50%"),
				},
				{	--4
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 6},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 4, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 4, tar =  60, tdr =  60, trt = .6},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--5
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr =  60, trt = .6},
					["desc"] = _("upgrade-comms","increase damage by ~42%"),
				},
				{	--6
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr =  60, trt = .6},
					{idx = 4, arc =  10, dir =   0, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr =   0, trt = .6},
					{idx = 5, arc =  10, dir = 120, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 120, trt = .6},
					{idx = 6, arc =  10, dir = 240, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 240, trt = .6},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--7
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 8, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr = -60, trt = 1},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 6, dmg = 6, tar =  60, tdr =  60, trt = 1},
					{idx = 4, arc =  10, dir =   0, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr =   0, trt = 1},
					{idx = 5, arc =  10, dir = 120, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 120, trt = 1},
					{idx = 6, arc =  10, dir = 240, rng =  800, cyc = 8, dmg = 4, tar = 130, tdr = 240, trt = 1},
					["desc"] = _("upgrade-comms","increase turret speed by 2/3"),
				},
				{	--8
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr = -60, trt = 1},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr =  60, trt = 1},
					{idx = 4, arc =  10, dir =   0, rng =  800, cyc = 6, dmg = 4, tar = 130, tdr =   0, trt = 1},
					{idx = 5, arc =  10, dir = 120, rng =  800, cyc = 6, dmg = 4, tar = 130, tdr = 120, trt = 1},
					{idx = 6, arc =  10, dir = 240, rng =  800, cyc = 6, dmg = 4, tar = 130, tdr = 240, trt = 1},
					["desc"] = _("upgrade-comms","decrease cycle time by ~24%"),
				},
				["stock"] = {
					{idx = 0, arc =  90, dir = -20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 1, arc =  90, dir =  20, rng = 1200, cyc = 6, dmg = 8},
					{idx = 2, arc =  10, dir = -60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr = -60, trt = .6},
					{idx = 3, arc =  10, dir =  60, rng = 1000, cyc = 4, dmg = 6, tar =  60, tdr =  60, trt = .6},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 1, desc = _("upgrade-comms","make broadside tubes medium sized")},			--2  
				{tube = 2,	ord = 2, desc = _("upgrade-comms","increase homing capacity by 50%")},				--3  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add a mine tube and mine")},					--4
				{tube = 4,	ord = 3, desc = _("upgrade-comms","decrease broadside load times by ~17%")},		--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","double missile capacity")},						--6
				{tube = 5,	ord = 4, desc = _("upgrade-comms","make broadside tubes large sized")},			--7
				{tube = 5,	ord = 5, desc = _("upgrade-comms","increase mine capacity by 50%")},				--8
				{tube = 6,	ord = 5, desc = _("upgrade-comms","decrease broadside load time by 20%")},			--9
				{tube = 6,	ord = 6, desc = _("upgrade-comms","increase missile capacity by 1/3")},			--10
				{tube = 6,	ord = 7, desc = _("upgrade-comms","increase missile capacity by 25%")},			--11
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--2
					{idx = 0, dir = -90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir = -90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir = -90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "L", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 16,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 4,  nuk = 0, emp = 0, min = 1, hvl = 0},		--1
				{hom = 6,  nuk = 0, emp = 0, min = 1, hvl = 0},		--2
				{hom = 6,  nuk = 0, emp = 0, min = 2, hvl = 0},		--3
				{hom = 12, nuk = 0, emp = 0, min = 4, hvl = 0},		--4
				{hom = 12, nuk = 0, emp = 0, min = 6, hvl = 0},		--5
				{hom = 16, nuk = 0, emp = 0, min = 8, hvl = 0},		--6
				{hom = 20, nuk = 0, emp = 0, min = 10,hvl = 0},		--7
				["stock"] = {hom = 16, nuk = 0, emp = 0, min = 10, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 70},
				},
				{	--2
					{idx = 0, max = 90},
					["desc"] = _("upgrade-comms","increase shield charge capacity by ~28%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 150},
					{idx = 1, max = 150},
				},
			},
			["hull"] = {
				{max = 80},												--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--3
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--4
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--5
				{max = 250, ["desc"] = _("upgrade-comms","increase hull max by ~39%")},	--6
				{max = 275, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 250},
			},
			["impulse"] = {
				{	--1
					max_front =		70,		max_back =		70,
					accel_front =	15,		accel_back = 	15,
					turn = 			6,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	15,
					turn = 			6,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase max reverse impulse speed by ~14%"),
				},
				{	--3
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	20,
					turn = 			6,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase rear acceleration by 1/3"),
				},
				{	--4
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--5
					max_front =		70,		max_back =		80,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		77,		max_back =		88,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max impulse speed by 10%"),
				},
				{	--7
					max_front =		77,		max_back =		88,
					accel_front =	15,		accel_back = 	20,
					turn = 			8,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--8
					max_front =		77,		max_back =		88,
					accel_front =	18,		accel_back = 	24,
					turn = 			8,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase acceleration by 20%"),
				},
				{	--9
					max_front =		77,		max_back =		88,
					accel_front =	18,		accel_back = 	24,
					turn = 			10,
					boost =			450,	strafe =		300,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				["stock"] = {
					{max_front = 80, turn = 8, accel_front = 20, max_back = 80, accel_back = 20, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","add 20u jump drive"),
				},
				{	--3
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--4
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--5
					jump_long = 40000, jump_short = 4000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--6
					jump_long = 50000, jump_short = 5000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--7
					jump_long = 50000, jump_short = 5000, warp = 450,
					desc = _("upgrade-comms","add warp drive"),
				},
				["stock"] = {
					{jump_long = 40000, jump_short = 4000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 50%"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 4,
					desc = _("upgrade-comms","double automated proximity scanner range"),
				},
				{	--5
					short = 5000, long = 36000, prox_scan = 4,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 5000, long = 36000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 9,
		},
		["Midian"] = {		--8 + beam(10) + missile(16) + shield(8) + hull(6) + impulse(8) + ftl(5) + sensors(5) = 66
			["beam"] = {
				{	--1
					{idx = 0, arc =  10, dir = 180, rng =  800, cyc = 6, dmg = 2, tar =  90, tdr = 180, trt = .2},
				},
				{	--2
					{idx = 0, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar =  90, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
				},
				{	--4
					{idx = 0, arc =  40, dir = -20, rng =  800, cyc = 6, dmg = 2},
					{idx = 1, arc =  40, dir =  20, rng =  800, cyc = 6, dmg = 2},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","add beams"),
				},
				{	--5
					{idx = 0, arc =  40, dir = -20, rng =  800, cyc = 6, dmg = 4},
					{idx = 1, arc =  40, dir =  20, rng =  800, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase front damage by 50%"),
				},
				{	--6
					{idx = 0, arc =  40, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  40, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 120, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase front range by 25%"),
				},
				{	--7
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 150, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase arc by 25%"),
				},
				{	--8
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 200, tdr = 180, trt = .2},
					["desc"] = _("upgrade-comms","increase rear arc by 1/3"),
				},
				{	--9
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 200, tdr = 180, trt = .3},
					["desc"] = _("upgrade-comms","increase turret speed by 50%"),
				},
				{	--10
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 5, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 5, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 5, dmg = 2, tar = 200, tdr = 180, trt = .3},
					["desc"] = _("upgrade-comms","reduce cycle time by ~17%"),
				},
				{	--11
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 5, dmg = 8},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 5, dmg = 8},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 5, dmg = 4, tar = 200, tdr = 180, trt = .3},
					["desc"] = _("upgrade-comms","double damage"),
				},
				["stock"] = {
					{idx = 0, arc =  50, dir = -20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 1, arc =  50, dir =  20, rng = 1000, cyc = 6, dmg = 4},
					{idx = 2, arc =  10, dir = 180, rng = 1000, cyc = 6, dmg = 2, tar = 220, tdr = 180, trt = .3},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 1,	ord = 2, desc = _("upgrade-comms","increase homing capacity by 1/3")},				--2  
				{tube = 2,	ord = 3, desc = _("upgrade-comms","add broadsides for nukes, EMPs and HVLIs")},	--3  
				{tube = 2,	ord = 4, desc = _("upgrade-comms","increase EMP capacity by 25%")},				--4
				{tube = 3,	ord = 4, desc = _("upgrade-comms","make broadside tubes medium sized")},			--5
				{tube = 4,	ord = 4, desc = _("upgrade-comms","reduce front tubes' load time by 20%")},		--6
				{tube = 4,	ord = 5, desc = _("upgrade-comms","increase homing capacity by 50%")},				--7
				{tube = 5,	ord = 6, desc = _("upgrade-comms","add mining tube and mines")},					--8
				{tube = 6,	ord = 6, desc = _("upgrade-comms","reduce mine load time by ~17%")},				--9
				{tube = 7,	ord = 6, desc = _("upgrade-comms","add rear homing tube")},						--10
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase capacity: homing:1/3, HVLI:50%")},		--11
				{tube = 8,	ord = 7, desc = _("upgrade-comms","make forward tubes medium sized")},				--12
				{tube = 8,	ord = 8, desc = _("upgrade-comms","double mine capacity")},						--13
				{tube = 9,	ord = 8, desc = _("upgrade-comms","make rear mine tube large sized")},				--14
				{tube = 9,	ord = 9, desc = _("upgrade-comms","increase capacity: nuke:50%, EMP:20%, HVLI:1/3")},	--15
				{tube = 10,	ord = 9, desc = _("upgrade-comms","reduce load time on broadside and rear tubes by ~18%")},	--16
				{tube = 11,	ord = 9, desc = _("upgrade-comms","Add HVLI capability to rear tube")},			--17
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =  -2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--2
					{idx = 0, dir =  -2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "S", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "S", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--3
					{idx = 0, dir =  -2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--4
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
				},
				{	--5
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 18,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--9
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--10
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--11
					{idx = 0, dir =  -2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "M", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 5, dir = 180, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =  -2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =   2, siz = "S", spd = 8, hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir = -90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir =  90, siz = "M", spd = 12,hom = false, nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 8,  nuk = 0, emp = 0, min = 0, hvl = 0},		--2
				{hom = 8,  nuk = 2, emp = 4, min = 0, hvl = 8},		--3
				{hom = 8,  nuk = 2, emp = 5, min = 0, hvl = 8},		--4
				{hom = 12, nuk = 2, emp = 5, min = 0, hvl = 8},		--5
				{hom = 12, nuk = 2, emp = 5, min = 3, hvl = 8},		--6
				{hom = 16, nuk = 2, emp = 5, min = 3, hvl = 12},	--7
				{hom = 16, nuk = 2, emp = 5, min = 6, hvl = 12},	--8
				{hom = 16, nuk = 3, emp = 6, min = 6, hvl = 16},	--9
				["stock"] = {hom = 16, nuk = 2, emp = 5, min = 5, hvl = 16},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 90},
					{idx = 1, max = 60},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 120},
					{idx = 1, max =  80},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 1/3"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase rear shield charge capacity by 25%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase front shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 180},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--9
					{idx = 0, max = 198},
					{idx = 1, max = 132},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 10%"),
				},
				["stock"] = {
					{idx = 0, max = 110},
					{idx = 1, max = 70},
				},
			},
			["hull"] = {
				{max = 120},											--1
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--2
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--3
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 12.5%")},	--4
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--5
				{max = 220, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--6
				{max = 242, ["desc"] = _("upgrade-comms","increase hull max by 10%")},		--7
				["stock"] = {max = 200},
			},
			["impulse"] = {
				{	--1
					max_front =		60,		max_back =		60,
					accel_front =	12,		accel_back = 	12,
					turn = 			6,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	12,		accel_back = 	12,
					turn = 			6,
					boost =			300,	strafe =		100,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	15,
					turn = 			6,
					boost =			300,	strafe =		100,
					desc = _("upgrade-comms","increase acceleration by 1/3"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			300,	strafe =		100,
					desc = _("upgrade-comms","increase maneuverability by 1/3"),
				},
				{	--5
					max_front =		60,		max_back =		60,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--6
					max_front =		75,		max_back =		75,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase max impulse speed by 25%"),
				},
				{	--7
					max_front =		75,		max_back =		75,
					accel_front =	20,		accel_back = 	15,
					turn = 			8,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase forward acceleration by 1/3"),
				},
				{	--8
					max_front =		75,		max_back =		75,
					accel_front =	20,		accel_back = 	15,
					turn = 			12,
					boost =			450,	strafe =		150,
					desc = _("upgrade-comms","increase maneuverability by 50%"),
				},
				{	--9
					max_front =		75,		max_back =		75,
					accel_front =	20,		accel_back = 	15,
					turn = 			12,
					boost =			540,	strafe =		180,
					desc = _("upgrade-comms","increase combat maneuver by 20%"),
				},
				["stock"] = {
					{max_front = 60, turn = 8, accel_front = 15, max_back = 60, accel_back = 15, boost = 450, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 600,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 700,
					desc = _("upgrade-comms","increase warp speed by ~17%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 800,
					desc = _("upgrade-comms","increase warp speed by ~14%"),
				},
				{	--5
					jump_long = 0, jump_short = 0, warp = 900,
					desc = _("upgrade-comms","increase warp speed by 12.5%"),
				},
				{	--6
					jump_long = 20000, jump_short = 2000, warp = 900,
					desc = _("upgrade-comms","add jump drive"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 800},
				},
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 15000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
				},
				{	--4
					short = 5500, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				{	--5
					short = 5500, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--6
					short = 5500, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 5500, long = 25000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
		["Raven"] = {		--8 + beam(8) + missile(9) + shield(7) + hull(6) + impulse(9) + ftl(5) + sensors(5) = 57
			["beam"] = {
				{	--1
					{idx = 0, arc =  10, dir = -90, rng =  800, cyc = 6, dmg = 8, tar =  60, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  800, cyc = 6, dmg = 8, tar =  60, tdr =  90, trt = 1},
				},
				{	--2
					{idx = 0, arc =  10, dir = -90, rng =  900, cyc = 6, dmg = 8, tar =  60, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  900, cyc = 6, dmg = 8, tar =  60, tdr =  90, trt = 1},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  10, dir = -90, rng =  900, cyc = 6, dmg = 10, tar =  60, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  900, cyc = 6, dmg = 10, tar =  60, tdr =  90, trt = 1},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--4
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase arc by 50%"),
				},
				{	--5
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 5, dmg = 10, tar =  90, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 5, dmg = 10, tar =  90, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","decrease cycle time by ~17%"),
				},
				{	--6
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase arc by 50%"),
				},
				{	--7
					{idx = 0, arc =  10, dir = -60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng =  900, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase damage by 25%"),
				},
				{	--8
					{idx = 0, arc =  10, dir = -60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 1},
					{idx = 1, arc =  10, dir =  60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 1},
					["desc"] = _("upgrade-comms","increase range by ~11%"),
				},
				{	--9
					{idx = 0, arc =  10, dir = -60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr = -60, trt = 2},
					{idx = 1, arc =  10, dir =  60, rng = 1000, cyc = 5, dmg = 10, tar = 135, tdr =  60, trt = 2},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--10
					{idx = 0, arc =  10, dir = -60, rng = 1000, cyc = 5, dmg = 10, tar = 180, tdr = -60, trt = 2},
					{idx = 1, arc =  10, dir =  60, rng = 1000, cyc = 5, dmg = 10, tar = 180, tdr =  60, trt = 2},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
				},
				["stock"] = {
					{idx = 0, arc =  10, dir = -90, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr = -90, trt = 1},
					{idx = 1, arc =  10, dir =  90, rng =  900, cyc = 6, dmg = 10, tar =  90, tdr =  90, trt = 1},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add mining tube and mines")},					--2  
				{tube = 3,	ord = 2, desc = _("upgrade-comms","increase tube load speed by ~23%")},			--3  
				{tube = 4,	ord = 3, desc = _("upgrade-comms","add small nuke tubes and nukes")},				--4
				{tube = 5,	ord = 3, desc = _("upgrade-comms","make homing tube medium sized")},				--5
				{tube = 6,	ord = 4, desc = _("upgrade-comms","add small EMP tubes and EMPs")},				--6
				{tube = 6,	ord = 5, desc = _("upgrade-comms","increase capacity: nuke:50%, EMP:1/3, mine:50%")},	--7
				{tube = 7,	ord = 5, desc = _("upgrade-comms","make homing tube large sized")},				--8
				{tube = 8,	ord = 6, desc = _("upgrade-comms","add HVLI capability to large tube and HVLIs")},	--9
				{tube = 8,	ord = 7, desc = _("upgrade-comms","increase capacity: nuke:1/3, mine:1/3, HVLI:25%")},		--10
			},
			["tube"] = {
				{	--1
					{idx = 0, dir =   0, siz = "S", spd = 16,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--2
					{idx = 0, dir =   0, siz = "S", spd = 16,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "S", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--8
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 3, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir = -30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 1, dir =  30, siz = "S", spd = 8, hom = false, nuk = true,  emp = false, min = false, hvl = false},
					{idx = 2, dir = -60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 3, dir =  60, siz = "S", spd = 8, hom = false, nuk = false, emp = true,  min = false, hvl = false},
					{idx = 4, dir =   0, siz = "L", spd = 12,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 10,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 6,  nuk = 0, emp = 0, min = 2, hvl = 0},		--2
				{hom = 6,  nuk = 2, emp = 0, min = 2, hvl = 0},		--3
				{hom = 6,  nuk = 2, emp = 3, min = 2, hvl = 0},		--4
				{hom = 6,  nuk = 3, emp = 4, min = 3, hvl = 0},		--5
				{hom = 6,  nuk = 3, emp = 4, min = 3, hvl = 4},		--6
				{hom = 6,  nuk = 4, emp = 4, min = 4, hvl = 5},		--7
				["stock"] = {hom = 4, nuk = 4, emp = 4, min = 4, hvl = 0},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--8
					{idx = 0, max = 180},
					{idx = 1, max = 180},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				["stock"] = {
					{idx = 0, max = 100},
					{idx = 1, max = 100},
				},
			},
			["hull"] = {
				{max = 90},												--1
				{max = 100, ["desc"] = _("upgrade-comms","increase hull max by ~11%")},	--2
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--3
				{max = 144, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--4
				{max = 150, ["desc"] = _("upgrade-comms","increase hull max by ~4%")},		--5
				{max = 180, ["desc"] = _("upgrade-comms","increase hull max by 20%")},		--6
				{max = 200, ["desc"] = _("upgrade-comms","increase hull max by ~17%")},	--7
				["stock"] = {max = 150},
			},
			["impulse"] = {
				{	--1
					max_front =		75,		max_back =		75,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		90,		max_back =		90,
					accel_front =	15,		accel_back = 	15,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase impulse max speed by 20%"),
				},
				{	--3
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	20,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by 1/3"),
				},
				{	--4
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--5
					max_front =		90,		max_back =		90,
					accel_front =	20,		accel_back = 	20,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--6
					max_front =		90,		max_back =		90,
					accel_front =	25,		accel_back = 	20,
					turn = 			10,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--7
					max_front =		90,		max_back =		90,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase maneuverability by 20%"),
				},
				{	--8
					max_front =		90,		max_back =		100,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			300,	strafe =		200,
					desc = _("upgrade-comms","increase max rear impulse speed by ~11%"),
				},
				{	--9
					max_front =		90,		max_back =		100,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			400,	strafe =		200,
					desc = _("upgrade-comms","increase combat maneuver boost by 1/3"),
				},
				{	--10
					max_front =		90,		max_back =		100,
					accel_front =	25,		accel_back = 	20,
					turn = 			12,
					boost =			400,	strafe =		300,
					desc = _("upgrade-comms","increase combat maneuver strafe by 50%"),
				},
				["stock"] = {
					{max_front = 90, turn = 10, accel_front = 20, max_back = 90, accel_back = 20, boost = 400, strafe = 250},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 0, jump_short = 0, warp = 250,
					desc = _("upgrade-comms","add warp drive"),
				},
				{	--3
					jump_long = 0, jump_short = 0, warp = 300,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--4
					jump_long = 0, jump_short = 0, warp = 360,
					desc = _("upgrade-comms","increase warp speed by 20%"),
				},
				{	--5
					jump_long = 20000, jump_short = 2000, warp = 360,
					desc = _("upgrade-comms","add jump drive"),
				},
				{	--6
					jump_long = 20000, jump_short = 2000, warp = 450,
					desc = _("upgrade-comms","increase warp speed by 25%"),
				},
				["stock"] = {
					{jump_long = 0, jump_short = 0, warp = 300},
				},
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 15000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 15000, prox_scan = 2,
					desc = _("upgrade-comms","add 2 unit automated proximity scanner"),
				},
				{	--3
					short = 5000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 1/3"),
				},
				{	--4
					short = 6000, long = 20000, prox_scan = 2,
					desc = _("upgrade-comms","increase short range sensors by 20%"),
				},
				{	--5
					short = 6000, long = 25000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--6
					short = 6000, long = 30000, prox_scan = 2,
					desc = _("upgrade-comms","increase long range sensors by 20%"),
				},
				["stock"] = {
					{short = 6000, long = 25000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
		["Squid"] = {		--8 + beam(6) + missile(9) + shield(6) + hull(4) + impulse(7) + ftl(5) + sensors(4) = 49
			["beam"] = {
				{	--1
					{idx = 0, arc =  10, dir =   0, rng =  800, cyc = 6, dmg =  4, tar =  60, tdr =   0, trt = .5},
				},
				{	--2
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 6, dmg =  4, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","increase range by 25%"),
				},
				{	--3
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","reduce cycle time by 1/3"),
				},
				{	--4
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","increase arc by 1/3"),
				},
				{	--5
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = 1},
					["desc"] = _("upgrade-comms","double turret speed"),
				},
				{	--6
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = 1},
					{idx = 1, arc =  10, dir =   0, rng =  800, cyc = 6, dmg =  6, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","add beam"),
				},
				{	--7
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  6, tar =  80, tdr =   0, trt = 1},
					{idx = 1, arc =  10, dir =   0, rng =  800, cyc = 6, dmg =  9, tar =  60, tdr =   0, trt = .5},
					["desc"] = _("upgrade-comms","increase damage by 50%"),
				},
				["stock"] = {
					{idx = 0, arc =  10, dir =   0, rng = 1000, cyc = 4, dmg =  4, tar =  80, tdr =   0, trt = 1},
				},
			},
			["missiles"] = {
				{tube = 1,	ord = 1},														--1
				{tube = 2,	ord = 2, desc = _("upgrade-comms","add forward HVLI tube and HVLIs")},				--2  
				{tube = 3,	ord = 3, desc = _("upgrade-comms","add heavy broadsides and missiles")},			--3  
				{tube = 4,	ord = 4, desc = _("upgrade-comms","add mining tube and mines")},					--4
				{tube = 5,	ord = 4, desc = _("upgrade-comms","add another forward tube and mining tube")},	--5
				{tube = 5,	ord = 5, desc = _("upgrade-comms","double capacity: nuke, EMP, mine")},			--6
				{tube = 6,	ord = 5, desc = _("upgrade-comms","make front and broadside homing tubes large")},	--7
				{tube = 6,	ord = 6, desc = _("upgrade-comms","increase capacity: homing:2/3, mine:50%, HVLI:2/3")},	--8
				{tube = 7,	ord = 6, desc = _("upgrade-comms","decrease tube load time for heavy broadsides")},	--9
				{tube = 7,	ord = 7, desc = _("upgrade-comms","increase capacity: homing:20% HVLI:60%")},		--10
			},
			["tube"] = {
				{	--1
					{idx = 0, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 1, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--2
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 2, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--3
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
				},
				{	--4
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 5, dir = 180, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--5
					{idx = 0, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "M", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "M", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--6
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir =  90, siz = "M", spd = 10,hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				{	--7
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 2, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 3, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 4, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
				["stock"] = {
					{idx = 0, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 1, dir = -90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 2, dir = -90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 3, dir =   0, siz = "L", spd = 12,hom = false, nuk = false, emp = false, min = false, hvl = true },
					{idx = 4, dir =  90, siz = "M", spd = 8, hom = true,  nuk = true,  emp = true,  min = false, hvl = true },
					{idx = 5, dir =  90, siz = "L", spd = 10,hom = true,  nuk = false, emp = false, min = false, hvl = false},
					{idx = 6, dir = 170, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
					{idx = 7, dir = 190, siz = "M", spd = 15,hom = false, nuk = false, emp = false, min = true,  hvl = false},
				},
			},
			["ordnance"] = {
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 0},		--1
				{hom = 6,  nuk = 0, emp = 0, min = 0, hvl = 6},		--2
				{hom = 6,  nuk = 2, emp = 2, min = 0, hvl = 6},		--3
				{hom = 6,  nuk = 2, emp = 2, min = 2, hvl = 6},		--4
				{hom = 6,  nuk = 4, emp = 4, min = 4, hvl = 6},		--5
				{hom = 10, nuk = 4, emp = 4, min = 6, hvl = 10},	--6
				{hom = 12, nuk = 4, emp = 4, min = 6, hvl = 16},	--7
				["stock"] = {hom = 10, nuk = 4, emp = 4, min = 6, hvl = 10},
			},
			["shield"] = {
				{	--1
					{idx = 0, max = 80},
				},
				{	--2
					{idx = 0, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--3
					{idx = 0, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--4
					{idx = 0, max = 80},
					{idx = 1, max = 80},
					["desc"] = _("upgrade-comms","add rear shield arc"),
				},
				{	--5
					{idx = 0, max = 100},
					{idx = 1, max = 100},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				{	--6
					{idx = 0, max = 120},
					{idx = 1, max = 120},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 20%"),
				},
				{	--7
					{idx = 0, max = 150},
					{idx = 1, max = 150},
					["desc"] = _("upgrade-comms","increase shield charge capacity by 25%"),
				},
				["stock"] = {
					{idx = 0, max = 100},
					{idx = 1, max = 100},
				},
			},
			["hull"] = {
				{max = 100},											--1
				{max = 120, ["desc"] = _("upgrade-comms","increase hull max by 25%")},		--2
				{max = 130, ["desc"] = _("upgrade-comms","increase hull max by ~9%")},		--3
				{max = 140, ["desc"] = _("upgrade-comms","increase hull max by ~8%")},		--4
				{max = 160, ["desc"] = _("upgrade-comms","increase hull max by ~14%")},	--5
				["stock"] = {max = 130},
			},
			["impulse"] = {
				{	--1
					max_front =		60,		max_back =		60,
					accel_front =	6,		accel_back = 	6,
					turn = 			8,
					boost =			0,		strafe =		0,
				},
				{	--2
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			8,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase acceleration by 1/3"),
				},
				{	--3
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			10,
					boost =			0,		strafe =		0,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				{	--4
					max_front =		60,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","add combat maneuver"),
				},
				{	--5
					max_front =		75,		max_back =		60,
					accel_front =	8,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase max forward impulse by 25%"),
				},
				{	--6
					max_front =		75,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			200,	strafe =		150,
					desc = _("upgrade-comms","increase forward acceleration by 25%"),
				},
				{	--7
					max_front =		75,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			10,
					boost =			300,	strafe =		225,
					desc = _("upgrade-comms","increase combat maneuver by 50%"),
				},
				{	--8
					max_front =		75,		max_back =		60,
					accel_front =	10,		accel_back = 	8,
					turn = 			12,
					boost =			300,	strafe =		225,
					desc = _("upgrade-comms","increase maneuverability by 25%"),
				},
				["stock"] = {
					{max_front = 60, turn = 10, accel_front = 8, max_back = 60, accel_back = 8, boost = 200, strafe = 150},
				},
			},
			["ftl"] = {
				{	--1
					jump_long = 0, jump_short = 0, warp = 0,
				},
				{	--2
					jump_long = 15000, jump_short = 1500, warp = 0,
					desc = _("upgrade-comms","add 15k jump drive"),
				},
				{	--3
					jump_long = 20000, jump_short = 2000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 1/3"),
				},
				{	--4
					jump_long = 25000, jump_short = 2500, warp = 0,
					desc = _("upgrade-comms","increase jump range by 25%"),
				},
				{	--5
					jump_long = 30000, jump_short = 3000, warp = 0,
					desc = _("upgrade-comms","increase jump range by 20%"),
				},
				{	--6
					jump_long = 30000, jump_short = 3000, warp = 250,
					desc = _("upgrade-comms","add warp drive"),
				},
				["stock"] = {
					{jump_long = 20000, jump_short = 2000, warp = 0},
				},
			},
			["sensors"] = {
				{	--1
					short = 5000, long = 20000, prox_scan = 0,
				},
				{	--2
					short = 5000, long = 25000, prox_scan = 0,
					desc = _("upgrade-comms","increase long range sensors by 25%"),
				},
				{	--3
					short = 5000, long = 25000, prox_scan = 3,
					desc = _("upgrade-comms","add 3 unit automated proximity scanner"),
				},
				{	--4
					short = 5000, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase long range scan range by 20%"),
				},
				{	--5
					short = 5500, long = 30000, prox_scan = 3,
					desc = _("upgrade-comms","increase short range sensors by 10%"),
				},
				["stock"] = {
					{short = 5000, long = 25000}, prox_scan = 0,
				},
			},
			["providers"] = false,
			["score"] = 8,
		},
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
	may_explain_sensor_jammer = false
	whammy = random(2950,3050)	-- ~50 minutes
	total_whammies = 0
	continuous_spawn_diagnostic = false
	spawn_intervals = {
		{pace = 5,	respite = 150},
		{pace = 20,	respite = 120},
		{pace = 30,	respite = 100},
		{pace = 20,	respite = 300},
		{pace = 40,	respite = 150},
		{pace = 10,	respite = 180},
	}
	spawn_interval_index = 0
	spawn_variance = 10
	spawn_source_pool = {}
	possible_victory_time = 600	--final: 600
	saboteur_idea_time = 1200	--final: 1200
	target_station_pool = {}
	clarifyExistingScience()
	mainLinearPlot = continuousSpawn
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
	if whammy > getScenarioTime() then
		addGMFunction(string.format(_("buttonGM", "Whammy %s"),math.floor(whammy)),function()
			whammy = getScenarioTime()
			mainGMButtonsAfterPause()
		end)
	end
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
		local button_label = string.format(_("buttonGM","%s %.1f"),power.desc,power.val)
		if power.val == enemy_power then
			button_label = button_label .. _("buttonGM","*")
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
		local button_label = string.format(_("buttonGM","%s %.1f"),diff.desc,diff.val)
		if diff.val == difficulty then
			button_label = button_label .. _("buttonGM","*")
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
		local button_label = string.format(_("buttonGM", "%s %i"),rep.name,rep.value)
		if reputation_start_amount == rep.value then
			button_label = button_label .. _("buttonGM", "*")
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
					addGMFunction(string.format(_("stationReport-msgGM","%s %s"),station:getCallSign(),station:getSectorName()),function()
						local out = string.format(_("stationReport-msgGM","%s %s  %s  %s  Friendliness:%s"),station:getSectorName(),station:getCallSign(),station:getTypeName(),station:getFaction(),station.comms_data.friendlyness)
						out = string.format(_("stationReport-msgGM","%s\nShares Energy: %s,  Repairs Hull: %s,  Restocks Scan Probes: %s"),out,station:getSharesEnergyWithDocked(),station:getRepairDocked(),station:getRestocksScanProbes())
						out = string.format(_("stationReport-msgGM","%s\nFix Probes: %s,  Fix Hack: %s,  Fix Scan: %s,  Fix Combat Maneuver: %s,  Fix Destruct: %s, Fix Slow Tube: %s"),out,station.comms_data.probe_launch_repair,station.comms_data.hack_repair,station.comms_data.scan_repair,station.comms_data.combat_maneuver_repair,station.comms_data.self_destruct_repair,station.comms_data.self_destruct_repair,station.comms_data.tube_slow_down_repair)
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
						out = string.format(_("stationReport-msgGM","%s\nHoming: %s %s,   Nuke: %s %s,   Mine: %s %s,   EMP: %s %s,   HVLI: %s %s"),out,station.comms_data.weapon_available.Homing,station.comms_data.weapon_cost.Homing,station.comms_data.weapon_available.Nuke,station.comms_data.weapon_cost.Nuke,station.comms_data.weapon_available.Mine,station.comms_data.weapon_cost.Mine,station.comms_data.weapon_available.EMP,station.comms_data.weapon_cost.EMP,station.comms_data.weapon_available.HVLI,station.comms_data.weapon_cost.HVLI)
--							out = string.format(_("stationReport-msgGM", "%s\n      Cost multipliers and Max Refill:   Friend: %.1f %.1f,   Neutral: %.1f %.1f"),out,station.comms_data.reputation_cost_multipliers.friend,station.comms_data.max_weapon_refill_amount.friend,station.comms_data.reputation_cost_multipliers.neutral,station.comms_data.max_weapon_refill_amount.neutral)
						out = string.format(_("stationReport-msgGM","%s\nServices and their costs and availability:"),out)
						for service, cost in pairs(station.comms_data.service_cost) do
--							out = string.format(_("stationReport-msgGM", "%s\n      %s: %s"),out,service,cost)
							out = string.format(_("stationReport-msgGM", "%s\n      %s: %s %s"),out,service,cost,station.comms_data.service_available[service])
						end
						if station.comms_data.jump_overcharge then
							out = string.format(_("stationReport-msgGM", "%s\n      jump overcharge: 10"),out)
						end
						if station.comms_data.upgrade_path ~= nil then
							out = string.format(_("stationReport-msgGM", "%s\nUpgrade paths for player ship types and their max level:"),out)
							for ship_type, upgrade in pairs(station.comms_data.upgrade_path) do
								out = string.format(_("stationReport-msgGM", "%s\n      Ship template type: %s"),out,ship_type)
								for upgrade_type, max_level in pairs(upgrade) do
									out = string.format(_("stationReport-msgGM", "%s\n            %s: %s"),out,upgrade_type,max_level)
								end
							end
						end
						if station.comms_data.goods ~= nil or station.comms_data.trade ~= nil or station.comms_data.buy ~= nil then
							out = string.format(_("stationReport-msgGM","%s\nGoods:"),out)
							if station.comms_data.goods ~= nil then
								out = string.format(_("stationReport-msgGM","%s\n    Sell:"),out)
								for good, good_detail in pairs(station.comms_data.goods) do
									out = string.format(_("stationReport-msgGM","%s\n        %s: Cost:%s   Quantity:%s"),out,good,good_detail.cost,good_detail.quantity)
								end
							end
							if station.comms_data.trade ~= nil then
								out = string.format(_("stationReport-msgGM","%s\n    Trade:"),out)
								for good, trade in pairs(station.comms_data.trade) do
									out = string.format(_("stationReport-msgGM", "%s\n        %s: %s"),out,good,trade)
								end
							end
							if station.comms_data.buy ~= nil then
								out = string.format(_("stationReport-msgGM","%s\n    Buy:"),out)
								for good, amount in pairs(station.comms_data.buy) do
									out = string.format(_("stationReport-msgGM","%s\n        %s: %s"),out,good,amount)
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
			p.upgrade_path = {
				["beam"] = 1,
				["missiles"] = 1,
				["shield"] = 1,
				["hull"] = 1,
				["impulse"] = 1,
				["ftl"] = 1,
				["sensors"] = 1,
			}
			for i=0,15 do
				p:setBeamWeapon(i,0,0,0,0,0)
			end
			for i,b in ipairs(upgrade_path[tempTypeName].beam[1]) do
				p:setBeamWeapon(b.idx,b.arc,b.dir,b.rng,b.cyc,b.dmg)
				if b.tar ~= nil then
					p:setBeamWeaponTurret(b.idx,b.tar,b.tdr,b.trt)
				end
			end
			p:setWeaponTubeCount(0)
			local missile_trans = {
				{typ = "Homing", short_type = "hom"},
				{typ = "Nuke", short_type = "nuk"},
				{typ = "EMP", short_type = "emp"},
				{typ = "Mine", short_type = "min"},
				{typ = "HVLI", short_type = "hvl"},
			}
			if upgrade_path[tempTypeName].tube[1][1].idx >= 0 then
				p:setWeaponTubeCount(#upgrade_path[tempTypeName].tube[1])
				local size_trans = {
					["S"] = "small",
					["M"] = "medium",
					["L"] = "large",
				}
				for i,m in ipairs(upgrade_path[tempTypeName].tube[1]) do
					p:setWeaponTubeDirection(m.idx,m.dir)
					p:setTubeSize(m.idx,size_trans[m.siz])
					p:setTubeLoadTime(m.idx,m.spd)
					local exclusive = false
					for j,lm in ipairs(missile_trans) do
						if m[lm.short_type] then
							if exclusive then
								p:weaponTubeAllowMissle(m.idx,lm.typ)
							else
								p:setWeaponTubeExclusiveFor(m.idx,lm.typ)
								exclusive = true
							end
						end
					end
				end
			end
			for i,o in ipairs(missile_trans) do
--				print("type:",o.typ,"amount:",upgrade_path[tempTypeName].ordnance[1][o.short_type])
				p:setWeaponStorageMax(o.typ,upgrade_path[tempTypeName].ordnance[1][o.short_type])
				p:setWeaponStorage(o.typ,upgrade_path[tempTypeName].ordnance[1][o.short_type])
			end
			if p:getWeaponTubeCount() > 0 then
				local size_letter = {
					["small"] = 	"S",
					["medium"] =	"M",
					["large"] =		"L",
				}
				p.tube_size = ""
				for i=1,p:getWeaponTubeCount() do
					p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
				end
			end
			p:setShieldsMax(upgrade_path[tempTypeName].shield[1][1].max)
			p:setShields(upgrade_path[tempTypeName].shield[1][1].max)
			p:setHullMax(upgrade_path[tempTypeName].hull[1].max)
			p:setHull(upgrade_path[tempTypeName].hull[1].max)
			p:setImpulseMaxSpeed(upgrade_path[tempTypeName].impulse[1].max_front,upgrade_path[tempTypeName].impulse[1].max_back)
			p:setAcceleration(upgrade_path[tempTypeName].impulse[1].accel_front,upgrade_path[tempTypeName].impulse[1].accel_back)
			p:setRotationMaxSpeed(upgrade_path[tempTypeName].impulse[1].turn)
			p:setCanCombatManeuver(false)
			p:setCombatManeuver(0,0)
			p.combat_maneuver_capable = false
			p:setJumpDrive(false)
			p:setWarpDrive(false)
			p:setLongRangeRadarRange(upgrade_path[tempTypeName].sensors[1].long)
			p.normal_long_range_radar = upgrade_path[tempTypeName].sensors[1].long
			p:setShortRangeRadarRange(upgrade_path[tempTypeName].sensors[1].short)
			p.prox_scan = upgrade_path[tempTypeName].sensors[1].prox_scan
			p.shipScore = upgrade_path[tempTypeName].score
			if not upgrade_path[tempTypeName].providers then
				local station_service_pool = {
					"beam","missiles","shield","hull","impulse","ftl","sensors",
				}
				local station_pool = {}
				while(#station_service_pool > 0) do
					local service = tableRemoveRandom(station_service_pool)
					if #station_pool < 1 then
						for _,station in ipairs(inner_circle) do
							if station ~= nil and station:isValid() then
								table.insert(station_pool,station)
							end
						end
					end
					local station_1 = tableRemoveRandom(station_pool)
					if #station_pool < 1 then
						for _,station in ipairs(inner_circle) do
							if station ~= nil and station:isValid() then
								table.insert(station_pool,station)
							end
						end
					end
					local station_2 = tableRemoveRandom(station_pool)
					if station_1.comms_data.upgrade_path == nil then
						station_1.comms_data.upgrade_path = {}
					end
					if station_1.comms_data.upgrade_path[tempTypeName] == nil then
						station_1.comms_data.upgrade_path[tempTypeName] = {}
					end
					if station_2.comms_data.upgrade_path == nil then
						station_2.comms_data.upgrade_path = {}
					end
					if station_2.comms_data.upgrade_path[tempTypeName] == nil then
						station_2.comms_data.upgrade_path[tempTypeName] = {}
					end
					station_1.comms_data.upgrade_path[tempTypeName][service] = math.floor(#upgrade_path[tempTypeName][service] / 2)
					station_2.comms_data.upgrade_path[tempTypeName][service] = math.floor(#upgrade_path[tempTypeName][service] / 2)
				end
				station_service_pool = {
					"beam","missiles","shield","hull","impulse","ftl","sensors",
				}
				station_pool = {}
				while(#station_service_pool > 0) do
					local service = tableRemoveRandom(station_service_pool)
					if #station_pool < 1 then
						for _,station in ipairs(circle_stations) do
							if station ~= nil and station:isValid() then
								if not station:isEnemy(p) then
									table.insert(station_pool,station)
								end
							end
						end
					end
					local station_1 = tableRemoveRandom(station_pool)
					if station_1.comms_data.upgrade_path == nil then
						station_1.comms_data.upgrade_path = {}
					end
					if station_1.comms_data.upgrade_path[tempTypeName] == nil then
						station_1.comms_data.upgrade_path[tempTypeName] = {}
					end
					station_1.comms_data.upgrade_path[tempTypeName][service] = #upgrade_path[tempTypeName][service]
				end
				station_service_pool = {
					"beam","missiles","shield","hull","impulse","ftl","sensors",
				}
				station_pool = {}
				while(#station_service_pool > 0) do
					local service = tableRemoveRandom(station_service_pool)
					if #station_pool < 1 then
						for _,station in ipairs(env_stations) do
							if station ~= nil and station:isValid() then
								if not station:isEnemy(p) then
									table.insert(station_pool,station)
								end
							end
						end
					end
					local station_1 = tableRemoveRandom(station_pool)
					if station_1 ~= nil then
						if station_1.comms_data.upgrade_path == nil then
							station_1.comms_data.upgrade_path = {}
						end
						if station_1.comms_data.upgrade_path[tempTypeName] == nil then
							station_1.comms_data.upgrade_path[tempTypeName] = {}
						end
						station_1.comms_data.upgrade_path[tempTypeName][service] = #upgrade_path[tempTypeName][service]
					end
				end
				upgrade_path[tempTypeName].providers = true
			end
			--set values from list
			p.maxCargo = playerShipStats[tempTypeName].cargo
			p.cargo = p.maxCargo
			p:setMaxScanProbeCount(playerShipStats[tempTypeName].probes)
			p:setScanProbeCount(p:getMaxScanProbeCount())
			p.tractor = playerShipStats[tempTypeName].tractor
			p.tractor_target_lock = false
			p.mining = playerShipStats[tempTypeName].mining
--			p.prox_scan = playerShipStats[tempTypeName].prox_scan
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
			addGMMessage(string.format(_("stationReport-msgGM","Player ship %s's template type (%s) could not be found in table PlayerShipStats"),p:getCallSign(),tempTypeName))
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
	p.goods = {}
	p:setFaction(player_faction)
	updatePlayerSoftTemplate(p)
	player_ship_spawn_count = player_ship_spawn_count + 1
	p:onDestroyed(playerDestroyed)
	p:onDestruction(playerDestruction)
	if p:getReputationPoints() == 0 then
		p:setReputationPoints(reputation_start_amount)
	end
end
function playerDestruction(self,instigator)
	--	Note: invoked by destruction by damage
	local players = getActivePlayerShips()
	if #players <= 1 then	--last player ship destroyed
		local outpost_count = 0
		for _,station in ipairs(inner_circle) do
			if station ~= nil and station:isValid() then
				outpost_count = outpost_count + 1
			end
		end
		local rank = getTripleFactorRank()
		local duration_string = getDuration()
		local reason = ""
		if outpost_count > 1 then
			reason = string.format(_("msgMainscreen","Outpost stations surrendered without you.\nOutpost resisted for %s.\nPosthumous rank: %s"),duration_string,rank)
		else
			reason = string.format(_("msgMainscreen","Last outpost station surrendered without you.\nOutpost resisted for %s.\nPosthumous rank: %s"),duration_string,rank)
		end
		globalMessage(reason)
		setBanner(reason)
		victory("Exuari")
	end
end
function playerDestroyed(self,instigator)
	player_ship_death_count = player_ship_death_count + 1
end
--	End of game messaging functions
function getTripleFactorRank()
	local outpost_count = 0
	for _,station in ipairs(inner_circle) do
		if station ~= nil and station:isValid() then
			outpost_count = outpost_count + 1
		end
	end
	local duration_string = getDuration()
	local duration = getScenarioTime()
	local rank = _("msgMainscreen","Cadet")
	local posthumous_rank = {
		{whammy = 0, stations = 4, duration = 1.0, rank = _("msgMainscreen","Admiral")},
		{whammy = 0, stations = 3, duration = 1.0, rank = _("msgMainscreen","Captain")},
		{whammy = 0, stations = 2, duration = 1.0, rank = _("msgMainscreen","Commander")},
		{whammy = 0, stations = 1, duration = 1.0, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 1, stations = 4, duration = 1.0, rank = _("msgMainscreen","Admiral")},
		{whammy = 1, stations = 4, duration = 1.5, rank = _("msgMainscreen","Captain")},
		{whammy = 1, stations = 3, duration = 1.0, rank = _("msgMainscreen","Captain")},
		{whammy = 1, stations = 3, duration = 1.5, rank = _("msgMainscreen","Commander")},
		{whammy = 1, stations = 2, duration = 1.0, rank = _("msgMainscreen","Commander")},
		{whammy = 1, stations = 2, duration = 1.5, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 1, stations = 1, duration = 1.0, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 1, stations = 1, duration = 1.5, rank = _("msgMainscreen","Ensign")},
		{whammy = 2, stations = 4, duration = 2.0, rank = _("msgMainscreen","Admiral")},
		{whammy = 2, stations = 4, duration = 2.5, rank = _("msgMainscreen","Captain")},
		{whammy = 2, stations = 3, duration = 2.0, rank = _("msgMainscreen","Commander")},
		{whammy = 2, stations = 3, duration = 2.5, rank = _("msgMainscreen","Commander")},
		{whammy = 2, stations = 2, duration = 2.0, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 2, stations = 2, duration = 2.5, rank = _("msgMainscreen","Ensign")},
		{whammy = 2, stations = 1, duration = 2.0, rank = _("msgMainscreen","Ensign")},
		{whammy = 2, stations = 1, duration = 2.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 3, stations = 4, duration = 3.0, rank = _("msgMainscreen","Admiral")},
		{whammy = 3, stations = 4, duration = 3.5, rank = _("msgMainscreen","Captain")},
		{whammy = 3, stations = 3, duration = 3.0, rank = _("msgMainscreen","Commander")},
		{whammy = 3, stations = 3, duration = 3.5, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 3, stations = 2, duration = 3.0, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 3, stations = 2, duration = 3.5, rank = _("msgMainscreen","Ensign")},
		{whammy = 3, stations = 1, duration = 3.0, rank = _("msgMainscreen","Ensign")},
		{whammy = 3, stations = 1, duration = 3.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 4, stations = 4, duration = 4.0, rank = _("msgMainscreen","Admiral")},
		{whammy = 4, stations = 4, duration = 4.5, rank = _("msgMainscreen","Captain")},
		{whammy = 4, stations = 3, duration = 4.0, rank = _("msgMainscreen","Commander")},
		{whammy = 4, stations = 3, duration = 4.5, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 4, stations = 2, duration = 4.0, rank = _("msgMainscreen","Ensign")},
		{whammy = 4, stations = 2, duration = 4.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 4, stations = 1, duration = 4.0, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 4, stations = 1, duration = 4.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 5, stations = 4, duration = 5.0, rank = _("msgMainscreen","Captain")},
		{whammy = 5, stations = 4, duration = 5.5, rank = _("msgMainscreen","Commander")},
		{whammy = 5, stations = 3, duration = 5.0, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 5, stations = 3, duration = 5.5, rank = _("msgMainscreen","Ensign")},
		{whammy = 5, stations = 2, duration = 5.0, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 6, stations = 4, duration = 6.0, rank = _("msgMainscreen","Commander")},
		{whammy = 6, stations = 4, duration = 6.5, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 6, stations = 3, duration = 6.0, rank = _("msgMainscreen","Ensign")},
		{whammy = 6, stations = 3, duration = 6.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 7, stations = 4, duration = 7.0, rank = _("msgMainscreen","Lieutenant")},
		{whammy = 7, stations = 4, duration = 7.5, rank = _("msgMainscreen","Ensign")},
		{whammy = 7, stations = 3, duration = 7.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 8, stations = 4, duration = 8.0, rank = _("msgMainscreen","Ensign")},
		{whammy = 8, stations = 4, duration = 8.5, rank = _("msgMainscreen","Acting Ensign")},
		{whammy = 9, stations = 4, duration = 9.0, rank = _("msgMainscreen","Acting Ensign")},
	}
	for i,pr in ipairs(posthumous_rank) do
		if total_whammies == pr.whammy then
			if stations == outpost_count then
				if duration < (60*60*pr.duration) then
					rank = pr.rank
					break
				end
			end
		end
	end
	return rank
end
function getDuration()
	local duration = getScenarioTime()
	local duration_string = math.floor(duration)
	if duration > 60 then
		if duration > 3600 then
		else
			local minutes = math.floor(duration / 60)
			local seconds = math.floor(duration % 60)
			if minutes > 1 then
				if minutes > 60 then
					local hours = math.floor(minutes / 60)
					minutes = math.floor(minutes % 60)
					if hours > 1 then
						if minutes > 1 then
							if seconds > 1 then
								duration_string = string.format(_("msgMainscreen","%s hours, %s minutes and %s seconds"),hours,minutes,seconds)
							else
								duration_string = string.format(_("msgMainscreen","%s hours, %s minutes and %s second"),hours,minutes,seconds)
							end
						else
							if seconds > 1 then
								duration_string = string.format(_("msgMainscreen","%s hours, %s minute and %s seconds"),hours,minutes,seconds)
							else
								duration_string = string.format(_("msgMainscreen","%s hours, %s minute and %s second"),hours,minutes,seconds)
							end
						end
					else
						if minutes > 1 then
							if seconds > 1 then
								duration_string = string.format(_("msgMainscreen","%s hour, %s minutes and %s seconds"),hours,minutes,seconds)
							else
								duration_string = string.format(_("msgMainscreen","%s hour, %s minutes and %s second"),hours,minutes,seconds)
							end
						else
							if seconds > 1 then
								duration_string = string.format(_("msgMainscreen","%s hour, %s minute and %s seconds"),hours,minutes,seconds)
							else
								duration_string = string.format(_("msgMainscreen","%s hour, %s minute and %s second"),hours,minutes,seconds)									
							end
						end
					end
				else
					if seconds > 1 then
						duration_string = string.format(_("msgMainscreen","%s minutes and %s seconds"),minutes,seconds)
					else
						duration_string = string.format(_("msgMainscreen","%s minutes and %s second"),minutes,seconds)
					end
				end
			else
				duration_string = string.format("%s minute and %s seconds",minutes,seconds)
			end
		end
	else
		duration_string = string.format("%s seconds",duration_string)
	end
	return duration_string
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
	station_list = {}
	inner_circle = {}
	player_factions = {"Human Navy","CUF","USN","TSN"}
	player_faction = player_factions[math.random(1,#player_factions)]
	ir_faction = {player_faction,"Human Navy"}
	if player_faction == "Human Navy" then
		ir_faction = {"Human Navy","CUF","USN","TSN"}
	end
	station_regional_hq = placeStation(center_x, center_y,"Pop Sci Fi",player_faction,"Medium Station")
	table.insert(station_list,station_regional_hq)
	table.insert(inner_circle,station_regional_hq)
	table.insert(place_space,{obj=station_regional_hq,dist=1000,shape="circle"})
	local defense_platform_angle = random(0,360)
	local dp_x, dp_y = vectorFromAngle(defense_platform_angle,3000)
	local dp = CpuShip():setTemplate("Defense platform"):setFaction(player_faction):setPosition(center_x + dp_x, center_y + dp_y):setScanState("fullscan"):orderStandGround()
	player_spawn_x, player_spawn_y = vectorFromAngleNorth(random(-20,20)+defense_platform_angle,random(-300,300)+1500)
	player_spawn_x = player_spawn_x + center_x
	player_spawn_y = player_spawn_y + center_y
	local circle_x, circle_y = vectorFromAngleNorth(random(-15,15)+defense_platform_angle+180,random(8000,14500))
	local station_size = szt()
	local circle_station = placeStation(center_x + circle_x, center_y + circle_y,"Spec Sci Fi",ir_faction[math.random(1,#ir_faction)],station_size)
	table.insert(station_list,circle_station)
	table.insert(inner_circle,circle_station)
	table.insert(place_space,{obj=circle_station,dist=station_defend_dist[station_size],shape="circle"})
	circle_x, circle_y = vectorFromAngleNorth(random(-15,15)+defense_platform_angle+60,random(8000,14500))
	station_size = szt()
	circle_station = placeStation(center_x + circle_x, center_y + circle_y,"Science",ir_faction[math.random(1,#ir_faction)],station_size)
	table.insert(station_list,circle_station)
	table.insert(inner_circle,circle_station)
	table.insert(place_space,{obj=circle_station,dist=station_defend_dist[station_size],shape="circle"})
	circle_x, circle_y = vectorFromAngleNorth(random(-15,15)+defense_platform_angle-60,random(8000,14500))
	station_size = szt()
	circle_station = placeStation(center_x + circle_x, center_y + circle_y,"History",ir_faction[math.random(1,#ir_faction)],station_size)
	table.insert(station_list,circle_station)
	table.insert(inner_circle,circle_station)
	table.insert(place_space,{obj=circle_station,dist=station_defend_dist[station_size],shape="circle"})
	--energy, hull, probe, 
	--homing, nuke, emp, mine, hvli, 
	--scan, hack, launch probe, combat maneuver, self destruct
	--reactor, beam, missile, maneuver, impulse, warp, jump, front shield, rear shield
	--supply drop, reinforcements, jump overcharge, shield overcharge, 
	for _,station in ipairs(inner_circle) do
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
	initial_angle = random(0,360)
	local defense_platforms = {
		["Small Station"] =	{count = 3, dist = 2000},
		["Medium Station"] ={count = 4, dist = 3300},
		["Large Station"] =	{count = 5, dist = 4000},
		["Huge Station"] =	{count = 6, dist = 4500}, 
	}
	circle_stations = {}
	local station_circle_distance_base = 25000
	local total_station_circle_distance = 0
	--create station circle stations
	for i=1,#faction_circle do
		local station_circle_distance = station_circle_distance_base + random(0,30000)
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
	for _,station in ipairs(circle_stations) do
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
			for _,station in ipairs(circle_stations) do
				if not station:isEnemy(station_regional_hq) then
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
	local planet_threshold = 20000
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
	transport_list = {}
	transport_stations = {}
	env_stations = {}
	--fill in roughly circular area with semi-random terrain
	far_enough_fail = false
	local black_hole_chance = 1
	black_hole_count = math.random(1,6)
	local star_chance = 3
	star_count = math.random(1,2)
	local probe_chance = 6
	local warp_jammer_chance = 3
	warp_jammer_count = math.random(7,12)
	local worm_hole_chance = 2
	worm_hole_count = math.random(1,4)
	local sensor_jammer_chance = 6
	sensor_jammer_count = math.random(7,12)
	local sensor_buoy_chance = 6
	local ad_buoy_chance = 8
	local nebula_chance = 5
	local mine_chance = 4
	local station_chance = 3
	local mine_field_chance = 4
	mine_field_count = math.random(3,8)
	local asteroid_field_chance = 4
	asteroid_field_count = math.random(2,6)
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
	for _,station in ipairs(env_stations) do
		station:setSharesEnergyWithDocked(false)
		station:setRepairDocked(false)
		station:setRestocksScanProbes(false)
		if station.comms_data == nil then
			station.comms_data = {}
		end
		if station.comms_data.weapon_available == nil then
			station.comms_data.weapon_available = {}
		end
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
        }
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
			for _,station in ipairs(env_stations) do
				if not station:isEnemy(station_regional_hq) then
					table.insert(station_pool,station)
				end
			end
		end
		local station_1 = tableRemoveRandom(station_pool)
		if station_1 ~= nil then
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
				warp_jammer_range = warp_jammer_range + random(1000,4000)
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
		local tfa = {true,false}
		station:setSharesEnergyWithDocked(tfa[math.random(1,2)])
		station:setRepairDocked(tfa[math.random(1,2)])
		station:setRestocksScanProbes(tfa[math.random(1,2)])
		station.comms_data.weapon_available = {}
		station.comms_data.weapon_available.Homing = tfa[math.random(1,2)]
		station.comms_data.weapon_available.Nuke = tfa[math.random(1,2)]
		station.comms_data.weapon_available.EMP = tfa[math.random(1,2)]
		station.comms_data.weapon_available.Mine = tfa[math.random(1,2)]
		station.comms_data.weapon_available.HVLI = tfa[math.random(1,2)]
		station.comms_data.scan_repair = tfa[math.random(1,2)]
		station.comms_data.hack_repair = tfa[math.random(1,2)]
		station.comms_data.probe_launch_repair = tfa[math.random(1,2)]
		station.comms_data.combat_maneuver_repair = tfa[math.random(1,2)]
		station.comms_data.self_destruct_repair = tfa[math.random(1,2)]
		station.comms_data.tube_slow_down_repair = tfa[math.random(1,2)]
		station.comms_data.system_repair = {
        	["reactor"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["beamweapons"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["missilesystem"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["maneuver"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["impulse"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["warp"] =			{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["jumpdrive"] =		{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["frontshield"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        	["rearshield"] =	{cost = math.random(1,9),	max = random(.7, .99),	avail = tfa[math.random(1,2)]},
        }
        station.comms_data.service_available = {
        	supplydrop =			tfa[math.random(1,2)], 
        	reinforcements =		tfa[math.random(1,2)],
   			hornet_reinforcements =	tfa[math.random(1,2)],
			phobos_reinforcements =	tfa[math.random(1,2)],
			amk3_reinforcements =	tfa[math.random(1,2)],
			amk8_reinforcements =	tfa[math.random(1,2)],
 			jump_overcharge =		tfa[math.random(1,2)],
	        shield_overcharge =		tfa[math.random(1,2)],
	        jonque =				tfa[math.random(1,2)],
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
		table.insert(place_space,{obj=station,dist=station_defend_dist[s_size],shape="circle"})
		table.insert(station_list,station)
		table.insert(env_stations,station)
		--defense fleet
		local fleet = spawnEnemies(eo_x, eo_y, 1, selected_faction, 35)
		for _, ship in ipairs(fleet) do
			ship:setFaction("Independent")
			ship:orderDefendTarget(station)
			ship:setFaction(selected_faction)
			ship:setCallSign(generateCallSign(nil,selected_faction))
		end
		station.defense_fleet = fleet
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
		retriever:addCustomMessage("Science",retriever.scanner_dead,_("damage-msgScience","The unscanned artifact we just picked up has fried our scanners"))
		retriever.scanner_dead_ops = "scanner_dead_ops"
		retriever:addCustomMessage("Operations",retriever.scanner_dead_ops,_("damage-msgOperations","The unscanned artifact we just picked up has fried our scanners"))
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
	oMsg = string.format(_("station-comms", "%s\n\nReputation: %i"),oMsg,math.floor(comms_source:getReputationPoints()))
	setCommsMessage(oMsg)
	local mission_character = nil
	local mission_type = nil
	if comms_source.transport_mission ~= nil then
		if comms_source.transport_mission.destination ~= nil and comms_source.transport_mission.destination:isValid() then
			if comms_source.transport_mission.destination == comms_target then
				addCommsReply(string.format(_("station-comms","Deliver %s to %s"),comms_source.transport_mission.character,comms_target:getCallSign()),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("station-comms", "You need to stay docked for that action."))
						return
					end
					setCommsMessage(string.format(_("station-comms","%s disembarks at %s and thanks you"),comms_source.transport_mission.character,comms_target:getCallSign()))
					comms_source:addReputationPoints(comms_source.transport_mission.reward)
					if comms_target.residents == nil then
						comms_target.residents = {}
					end
					table.insert(comms_target.residents,comms_source.transport_mission.character)
					comms_source.transport_mission = nil
					addCommsReply(_("Back"), commsStation)
				end)
			end
		else
			comms_source:addToShipLog(string.format(_("shipLog","%s disembarks at %s because %s has been destroyed. You receive %s reputation for your efforts"),comms_source.transport_mission.character,comms_target:getCallSign(),comms_source.transport_mission.destination_name,comms_source.transport_mission.reward/2),"Yellow")
			comms_source:addReputationPoints(comms_source.transport_mission.reward/2)
			if comms_target.residents == nil then
				comms_target.residents = {}
			end
			table.insert(comms_target.residents,comms_source.transport_mission.character)
			comms_source.transport_mission = nil
		end
	else
		if comms_target.transport_mission == nil then
			mission_character = tableRemoveRandom(character_names)
			local mission_target = nil
			if mission_character ~= nil then
				mission_type = random(1,100)
				local destination_pool = {}
				if mission_type < 20 then
					for _, station in ipairs(circle_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 40,
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(circle_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = 30,
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(inner_circle) do
								if station ~= nil and station:isValid() and station ~= comms_target then
									table.insert(destination_pool,station)
								end
							end
							mission_target = tableRemoveRandom(destination_pool)
							if mission_target ~= nil then
								comms_target.transport_mission = {
									["destination"] = mission_target,
									["destination_name"] = mission_target:getCallSign(),
									["reward"] = 20,
									["character"] = mission_character,
								}
							end
						end
					end
				elseif mission_type < 50 then
					for _, station in ipairs(circle_stations) do
						if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 30,
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(inner_circle) do
							if station ~= nil and station:isValid() and station ~= comms_target then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = 20,
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(circle_stations) do
								if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
									table.insert(destination_pool,station)
								end
							end
							mission_target = tableRemoveRandom(destination_pool)
							if mission_target ~= nil then
								comms_target.transport_mission = {
									["destination"] = mission_target,
									["destination_name"] = mission_target:getCallSign(),
									["reward"] = 40,
									["character"] = mission_character,
								}
							end
						end
					end
				else
					for _, station in ipairs(inner_circle) do
						if station ~= nil and station:isValid() and station ~= comms_target then
							table.insert(destination_pool,station)
						end
					end
					mission_target = tableRemoveRandom(destination_pool)
					if mission_target ~= nil then
						comms_target.transport_mission = {
							["destination"] = mission_target,
							["destination_name"] = mission_target:getCallSign(),
							["reward"] = 20,
							["character"] = mission_character,
						}
					else
						for _, station in ipairs(circle_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
								table.insert(destination_pool,station)
							end
						end
						mission_target = tableRemoveRandom(destination_pool)
						if mission_target ~= nil then
							local reward = 40
							if mission_target:isFriendly(comms_source) then
								reward = 30
							end
							comms_target.transport_mission = {
								["destination"] = mission_target,
								["destination_name"] = mission_target:getCallSign(),
								["reward"] = reward,
								["character"] = mission_character,
							}
						end
					end
				end
			end
		else
			if not comms_target.transport_mission.destination:isValid() then
				if comms_target.residents == nil then
					comms_target.residents = {}
				end
				table.insert(comms_target.residents,comms_target.transport_mission.character)
				comms_target.transport_mission = nil
			end
		end
		if comms_target.transport_mission ~= nil then
--			print("comms target transport mission",comms_target.transport_mission)
--			print("comms target transport mission character",comms_target.transport_mission.character)
--			print("comms target transport mission destination",comms_target.transport_mission.destination,"name:",comms_target.transport_mission.destination_name)
			addCommsReply(_("station-comms","Transport Passenger"),function()
--				local out = string.format("%s",comms_target.transport_mission.character)
--				out = string.format(_("station-comms","%s wishes to be transported to %s"),out,comms_target.transport_mission.destination:getFaction())
--				out = string.format(_("station-comms","%s station %s"),out,comms_target.transport_mission.destination_name)
--				local sector_name = comms_target.transport_mission.destination:getSectorName()
--				out = string.format(_("station-comms","%s in sector %s"),out,comms_target.transport_mission.destination:getSectorName())
--				out = string.format(_("station-comms","%s. Your reputation would increase by %s"),out,comms_target.transport_mission.reward)
--				out = string.format(_("station-comms","%s if you agree to transport %s."),out,comms_target.transport_mission.character)
				local out = string.format(_("station-comms","%s wishes to be transported to %s station %s in sector %s."),comms_target.transport_mission.character,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName())
				out = string.format(_("station-comms","%s Transporting %s would increase your reputation by %s."),out,comms_target.transport_mission.character,comms_target.transport_mission.reward)
				setCommsMessage(out)
--				setCommsMessage(string.format("%s wishes to be transported to %s station %s in sector %s. Your reputation would go up by %s if you agree to transport %s.",comms_target.transport_mission.character,comms_target.transport_mission.destination:getFaction().comms_target.transport_mission.destination_name,comms_target.transport_mission.destination:getSectorName(),comms_target.transport_mission.reward,comms_target.transport_mission.character))
				addCommsReply(string.format(_("station-comms","Agree to transport %s to %s station %s"),comms_target.transport_mission.character,comms_target.transport_mission.destination:getFaction(),comms_target.transport_mission.destination_name),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("station-comms", "You need to stay docked for that action."))
						return
					end
					comms_source.transport_mission = comms_target.transport_mission
					comms_target.transport_mission = nil
					setCommsMessage(string.format(_("station-comms","You direct %s to guest quarters and say, 'Welcome aboard the %s'"),comms_source.transport_mission.character,comms_source:getCallSign()))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("station-comms","Decline transportation request"),function()
					if random(1,5) <= 1 then
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time. The offer disappears from the message board."),comms_target.transport_mission.character))
						comms_target.transport_mission = nil
					else
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time."),comms_target.transport_mission.character))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	mission_character = nil
	if comms_source.cargo_mission ~= nil then
		if comms_source.cargo_mission.loaded then
			if comms_source.cargo_mission.destination ~= nil and comms_source.cargo_mission.destination:isValid() then
				if comms_source.cargo_mission.destination == comms_target then
					addCommsReply(string.format(_("station-comms","Deliver cargo to %s on %s"),comms_source.cargo_mission.character,comms_target:getCallSign()),function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("station-comms", "You need to stay docked for that action."))
							return
						end
						setCommsMessage(string.format(_("station-comms","%s thanks you for retrieving the cargo"),comms_source.cargo_mission.character))
						comms_source:addReputationPoints(comms_source.cargo_mission.reward)
						comms_source.cargo_mission = nil
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				comms_source:addToShipLog(string.format(_("shipLog","Automated systems on %s have informed you of the destruction of station %s. Your mission to deliver cargo for %s to %s is no longer valid. You unloaded the cargo and requested the station authorities handle it for the family of %s. You received %s reputation for your efforts. The mission has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character,comms_source.cargo_mission.destination_name,comms_source.cargo_mission.character,comms_source.cargo_mission.reward/2),"Yellow")
				comms_source:addReputationPoints(comms_source.cargo_mission.reward/2)
				comms_source.cargo_mission = nil
			end
		else
			if comms_source.cargo_mission.origin ~= nil and comms_source.cargo_mission.origin:isValid() then
				if comms_source.cargo_mission.origin == comms_target then
					addCommsReply(string.format(_("station-comms","Pick up cargo for %s"),comms_source.cargo_mission.character),function()
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("station-comms", "You need to stay docked for that action."))
							return
						end
						setCommsMessage(string.format(_("station-comms","The cargo for %s has been loaded on %s"),comms_source.cargo_mission.character,comms_source:getCallSign()))
						comms_source.cargo_mission.loaded = true
						addCommsReply(_("Back"), commsStation)
					end)
				end
			else
				comms_source:addToShipLog(string.format(_("shipLog","Automated systems on %s have informed you of the destruction of station %s. Your mission to retrieve cargo for %s from %s is no longer valid and has been removed from your mission log."),comms_target:getCallSign(),comms_source.cargo_mission.origin_name,comms_source.cargo_mission.character,comms_source.cargo_mission.origin_name),"Yellow")
				if comms_source.cargo_mission.destination:isValid() then
					table.insert(comms_source.cargo_mission.destination.residents,comms_source.cargo_mission.character)
				end
				comms_source.cargo_mission = nil
			end
		end
	else
		if comms_target.cargo_mission == nil then
			if comms_target.residents ~= nil then
				mission_character = tableRemoveRandom(comms_target.residents)
				local mission_origin = nil
				if mission_character ~= nil then
					mission_type = random(1,100)
					local origin_pool = {}
					if mission_type < 20 then
						for _, station in ipairs(circle_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
								table.insert(origin_pool,station)
							end
						end
						mission_origin = tableRemoveRandom(origin_pool)
						if mission_origin ~= nil then
							comms_target.cargo_mission = {
								["origin"] = mission_origin,
								["origin_name"] = mission_origin:getCallSign(),
								["destination"] = comms_target,
								["destination_name"] = comms_target:getCallSign(),
								["reward"] = 50,
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(circle_stations) do
								if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
									table.insert(origin_pool,station)
								end
							end
							mission_origin = tableRemoveRandom(origin_pool)
							if mission_origin ~= nil then
								comms_target.cargo_mission = {
									["origin"] = mission_origin,
									["origin_name"] = mission_origin:getCallSign(),
									["destination"] = comms_target,
									["destination_name"] = comms_target:getCallSign(),
									["reward"] = 40,
									["character"] = mission_character,
								}
							else
								for _, station in ipairs(inner_circle) do
									if station ~= nil and station:isValid() and station ~= comms_target then
										table.insert(origin_pool,station)
									end
								end
								mission_origin = tableRemoveRandom(origin_pool)
								if mission_origin ~= nil then
									comms_target.cargo_mission = {
										["origin"] = mission_origin,
										["origin_name"] = mission_origin:getCallSign(),
										["destination"] = comms_target,
										["destination_name"] = comms_target:getCallSign(),
										["reward"] = 30,
										["character"] = mission_character,
									}
								end
							end
						end
					elseif mission_type < 50 then
						for _, station in ipairs(circle_stations) do
							if station ~= nil and station:isValid() and station ~= comms_target and comms_source:isFriendly(station) then
								table.insert(origin_pool,station)
							end
						end
						mission_origin = tableRemoveRandom(origin_pool)
						if mission_origin ~= nil then
							comms_target.cargo_mission = {
								["origin"] = mission_origin,
								["origin_name"] = mission_origin:getCallSign(),
								["destination"] = comms_target,
								["destination_name"] = comms_target:getCallSign(),
								["reward"] = 40,
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(inner_circle) do
								if station ~= nil and station:isValid() and station ~= comms_target then
									table.insert(origin_pool,station)
								end
							end
							mission_origin = tableRemoveRandom(origin_pool)
							if mission_origin ~= nil then
								comms_target.cargo_mission = {
									["origin"] = mission_origin,
									["origin_name"] = mission_origin:getCallSign(),
									["destination"] = comms_target,
									["destination_name"] = comms_target:getCallSign(),
									["reward"] = 30,
									["character"] = mission_character,
								}
							else
								for _, station in ipairs(circle_stations) do
									if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) and not comms_source:isFriendly(station) then
										table.insert(origin_pool,station)
									end
								end
								mission_origin = tableRemoveRandom(origin_pool)
								if mission_origin ~= nil then
									comms_target.cargo_mission = {
										["origin"] = mission_origin,
										["origin_name"] = mission_origin:getCallSign(),
										["destination"] = comms_target,
										["destination_name"] = comms_target:getCallSign(),
										["reward"] = 50,
										["character"] = mission_character,
									}
								end
							end
						end
					else
						for _, station in ipairs(inner_circle) do
							if station ~= nil and station:isValid() and station ~= comms_target then
								table.insert(origin_pool,station)
							end
						end
						mission_origin = tableRemoveRandom(origin_pool)
						if mission_origin ~= nil then
							comms_target.cargo_mission = {
								["origin"] = mission_origin,
								["origin_name"] = mission_origin:getCallSign(),
								["destination"] = comms_target,
								["destination_name"] = comms_target:getCallSign(),
								["reward"] = 30,
								["character"] = mission_character,
							}
						else
							for _, station in ipairs(circle_stations) do
								if station ~= nil and station:isValid() and station ~= comms_target and not comms_source:isEnemy(station) then
									table.insert(origin_pool,station)
								end
							end
							mission_origin = tableRemoveRandom(origin_pool)
							if mission_origin ~= nil then
								local reward = 50
								if mission_origin:isFriendly(comms_source) then
									reward = 40
								end
								comms_target.cargo_mission = {
									["origin"] = mission_origin,
									["origin_name"] = mission_origin:getCallSign(),
									["destination"] = comms_target,
									["destination_name"] = comms_target:getCallSign(),
									["reward"] = reward,
									["character"] = mission_character,
								}
							end
						end
					end
				end
			end
		else
			if not comms_target.cargo_mission.origin:isValid() then
				table.insert(comms_target.residents,comms_target.cargo_mission.character)
				comms_target.cargo_mission = nil
			end
		end
		if comms_target.cargo_mission ~= nil then
			addCommsReply(_("station-comms","Retrieve Cargo"),function()
--				local out = string.format("%s",comms_target.cargo_mission.character)
--				out = string.format(_("station-comms","%s wishes you to pick up cargo from %s"),out,comms_target.cargo_mission.origin:getFaction())
--				out = string.format(_("station-comms","%s station %s"),out,comms_target.cargo_mission.origin_name)
--				local sector_name = comms_target.cargo_mission.destination:getSectorName()
--				out = string.format(_("station-comms","%s in sector %s and deliver it here"),out,comms_target.cargo_mission.origin:getSectorName())
--				out = string.format(_("station-comms","%s. Your reputation would increase by %s"),out,comms_target.cargo_mission.reward)
--				out = string.format(_("station-comms","%s if you agree to retrieve this cargo for %s."),out,comms_target.cargo_mission.character)
				local out = string.format(_("station-comms","%s wishes you to pick up cargo from %s station %s in sector %s and deliver it here."),comms_target.cargo_mission.character,comms_target.cargo_mission.origin:getFaction(),comms_target.cargo_mission.origin_name,comms_target.cargo_mission.origin:getSectorName())
				out = string.format(_("station-comms","%s Retrieving and delivering this cargo for %s would increase your reputation by %s."),out,comms_target.cargo_mission.character,comms_target.cargo_mission.reward)
				setCommsMessage(out)
				addCommsReply(string.format(_("station-comms","Agree to retrieve cargo for %s"),comms_target.cargo_mission.character),function()
					if not comms_source:isDocked(comms_target) then 
						setCommsMessage(_("station-comms", "You need to stay docked for that action."))
						return
					end
					comms_source.cargo_mission = comms_target.cargo_mission
					comms_source.cargo_mission.loaded = false
					comms_target.cargo_mission = nil
					setCommsMessage(string.format(_("station-comms","%s thanks you and contacts station %s to let them know that %s will be picking up the cargo."),comms_source.cargo_mission.character,comms_source.cargo_mission.origin_name,comms_source:getCallSign()))
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("station-comms","Decline cargo retrieval request"),function()
					if random(1,5) <= 1 then
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any cargo retrieval missions at this time. The offer disappears from the message board."),comms_target.cargo_mission.character))
						comms_target.cargo_mission = nil
					else
						setCommsMessage(string.format(_("station-comms","You tell %s that you cannot take on any transportation missions at this time."),comms_target.transport_mission.character))
					end
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end
	end
	addCommsReply(_("station-comms","Station services (restock ordnance, upgrades, repairs)"),function()
		setCommsMessage(_("station-comms","What station service are you interested in?"))
		if comms_target.comms_data.upgrade_path ~= nil then
			local p_ship_type = comms_source:getTypeName()
			if comms_target.comms_data.upgrade_path[p_ship_type] ~= nil then
				addCommsReply(_("upgrade-comms","Upgrade ship"),function()
					local upgrade_count = 0
					for u_type, u_max in pairs(comms_target.comms_data.upgrade_path[p_ship_type]) do
						local p_upgrade_level = comms_source.upgrade_path[u_type]
						if u_max > p_upgrade_level then
							upgrade_count = upgrade_count + 1
							addCommsReply(string.format(_("upgrade-comms","%s: %s (%s)"),u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,math.ceil(base_upgrade_cost+((p_upgrade_level+1)*upgrade_price))),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("station-comms", "You need to stay docked for that action."))
									return
								end
								if comms_source:takeReputationPoints(math.ceil(base_upgrade_cost+((p_upgrade_level+1)*upgrade_price))) then
									upgradePlayerShip(comms_source,u_type)
									setCommsMessage(_("upgrade-comms","Upgrade complete"))
								else
									setCommsMessage(_("needRep-comms", "Insufficient reputation"))
								end
								addCommsReply(_("Back"), commsStation)
							end)
						end
						if upgrade_count > 0 then
							setCommsMessage(_("upgrade-comms","What kind of upgrade are you interested in? We can provide the following upgrades\nsystem: description (reputation cost)"))
						else
							setCommsMessage(_("upgrade-comms","Alas, we cannot upgrade any of your systems"))
						end
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
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
						if not comms_source:isDocked(comms_target) then 
							setCommsMessage(_("station-comms", "You need to stay docked for that action."))
							return
						end
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
		if not offer_repair and comms_target.comms_data.combat_maneuver_repair and not comms_source:getCanCombatManeuver() and comms_source.combat_maneuver_capable then
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
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("station-comms", "You need to stay docked for that action."))
								return
							end
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
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("station-comms", "You need to stay docked for that action."))
								return
							end
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
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("station-comms", "You need to stay docked for that action."))
								return
							end
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
						if comms_source.combat_maneuver_capable then
							addCommsReply(string.format(_("stationServices-comms","Repair combat maneuver (%s Rep)"),comms_target.comms_data.service_cost.combat_maneuver_repair),function()
								if not comms_source:isDocked(comms_target) then 
									setCommsMessage(_("station-comms", "You need to stay docked for that action."))
									return
								end
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
				end
				if comms_target.comms_data.self_destruct_repair then
					if not comms_source:getCanSelfDestruct() then
						addCommsReply(string.format(_("stationServices-comms","Repair self destruct system (%s Rep)"),comms_target.comms_data.service_cost.self_destruct_repair),function()
							if not comms_source:isDocked(comms_target) then 
								setCommsMessage(_("station-comms", "You need to stay docked for that action."))
								return
							end
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
	end)
	addCommsReply(_("station-comms","I need information"),function()
		setCommsMessage(_("station-comms","What do you need to know?"))
		addCommsReply(_("station-comms","What's with all the warp jammers?"),function()
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
				local station_count = 0
				for i,station in ipairs(inner_circle) do
					if station ~= nil and station:isValid() then
						station_count = station_count + 1
					end
				end
				if station_count > 1 then
					primary_orders = _("orders-comms","Survive. Protect the outpost which includes the following stations:")
				else
					primary_orders = _("orders-comms","Survive. Protect the outpost which consists of the following station:")
				end
				station_count = 0
				for i,station in ipairs(inner_circle) do
					if station ~= nil and station:isValid() then
						station_count = station_count + 1
						if station_count > 1 then
							primary_orders = string.format("%s, %s (%s)",primary_orders,station:getCallSign(),station:getFaction())
						else
							primary_orders = string.format("%s %s (%s)",primary_orders,station:getCallSign(),station:getFaction())
						end
					end
				end
				primary_orders = primary_orders .. "."
				ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
				if playWithTimeLimit then
					ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
				end
				setCommsMessage(ordMsg)
				if getScenarioTime() > possible_victory_time then
					saboteurOption()
				end
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
							setCommsMessage(_("station-comms", "You need to stay docked for that action."))
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
									setCommsMessage(_("station-comms", "You need to stay docked for that action."))
									return
								end
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
										if not comms_source:isDocked(comms_target) then 
											setCommsMessage(_("station-comms", "You need to stay docked for that action."))
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
											setCommsMessage(_("station-comms", "You need to stay docked for that action."))
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
											setCommsMessage(_("station-comms", "You need to stay docked for that action."))
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
							setCommsMessage(_("station-comms", "You need to stay docked for that action."))
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
								setCommsMessage(_("station-comms", "You need to stay docked for that action."))
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
			if pay_rep then
				addCommsReply(_("station_comms","Why do I have to pay reputation to log in to some of these warp jammers?"),function()
					setCommsMessage(string.format(_("It's complicated. It depends on the relationships between the warp jammer owner, us, station %s and you, %s. The farther apart the relationship, the more reputation it costs to gain access. Do you want more details?"),comms_target:getCallSign(),comms_source:getCallSign()))
					addCommsReply(_("station-comms","Yes, please provide more details"),function()
						local out = _("station-comms","These are the cases and their reputation costs:")
						out = string.format(_("station-comms","%s\n    WJ friendly to %s and WJ is friendly to %s = no reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ friendly to %s and WJ is enemy to %s = 10 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ friendly to %s and WJ is neutral to %s = 5 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ enemy to %s and WJ is friendly to %s = 15 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ enemy to %s and WJ is enemy to %s = 100 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ enemy to %s and WJ is neutral to %s = 20 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ neutral to %s and WJ is friendly to %s = 10 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ neutral to %s and WJ is enemy to %s = 25 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
						out = string.format(_("station-comms","%s\n    WJ neutral to %s and WJ is neutral to %s = 20 reputation."),out,comms_target:getCallSign(),comms_source:getCallSign())
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
			primary_orders = _("orders-comms","Survive. Protect the outpost which includes the following stations:")
			for i,station in ipairs(inner_circle) do
				if station ~= nil and station:isValid() then
					primary_orders = string.format("%s\n%s (%s)",primary_orders,station:getCallSign(),station:getFaction())
				end
			end
			ordMsg = primary_orders .. "\n" .. secondary_orders .. optional_orders
			if playWithTimeLimit then
				ordMsg = ordMsg .. string.format(_("orders-comms", "\n   %i Minutes remain in game"),math.floor(gameTimeLimit/60))
			end
			setCommsMessage(ordMsg)
			if getScenarioTime() > possible_victory_time then
				saboteurOption()
			end
			addCommsReply(_("Back"), commsStation)
		end)
		local comms_distance = distance(comms_target,comms_source)
		if comms_distance > average_station_circle_distance then
			addCommsReply(_("station-comms","Where am I?"),function()
				local s_x, s_y = comms_target:getPosition()
				local p_x, p_y = comms_source:getPosition()
				local comms_bearing = angleFromVectorNorth(p_x, p_y, s_x, s_y)
				setCommsMessage(string.format(_("station-comms","Based on triangulation and signal strength, our communications software says you're on a bearing of %.1f from us at a distance of %.1f units"),comms_bearing,comms_distance/1000))
				addCommsReply(_("Back"), commsStation)
			end)
		end
		addCommsReply(_("station-comms","Station services (ordnance restock, repair, upgrade)"),function()
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
			addCommsReply(_("stationServices-comms", "Docking services status"), function()
				setCommsMessage(_("stationServices-comms","Which docking service category do you want a status for?\n    Primary services:\n        Charge battery, repair hull, replenish probes\n    Secondary systems repair:\n        Scanners, hacking, probe launch, combat maneuver, self destruct\n    Upgrade ship systems:\n        Beam, missile, shield, hull, impulse, ftl, sensors"))
				addCommsReply(_("stationServices-comms","Primary services"),function()
					local service_status = string.format(_("stationServices-comms", "Station %s primary docking services status:"),comms_target:getCallSign())
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
					setCommsMessage(service_status)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("stationServices-comms","Secondary systems repair"),function()
					local service_status = string.format(_("stationServices-comms", "Station %s docking repair services status:"),comms_target:getCallSign())
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
				addCommsReply(_("upgrade-comms","Upgrade ship systems"),function()
					local service_status = string.format(_("upgrade-comms", "Station %s docking upgrade services:"),comms_target:getCallSign())
					if comms_target.comms_data.upgrade_path ~= nil then
						local p_ship_type = comms_source:getTypeName()
						if comms_target.comms_data.upgrade_path[p_ship_type] ~= nil then
							local upgrade_count = 0
							local out = _(_("upgrade-comms","We can provide the following upgrades:\n    system: description (reputation cost)"))
							for u_type, u_max in pairs(comms_target.comms_data.upgrade_path[p_ship_type]) do
								local p_upgrade_level = comms_source.upgrade_path[u_type]
								if u_max > p_upgrade_level then
									upgrade_count = upgrade_count + 1
									out = string.format(_("upgrade-comms", "%s\n        %s: %s (%s)"),out,u_type,upgrade_path[p_ship_type][u_type][p_upgrade_level + 1].desc,math.ceil(base_upgrade_cost+((p_upgrade_level+1)*upgrade_price)))
								end
							end
							if upgrade_count > 0 then
								setCommsMessage(out)
							else
								setCommsMessage(_("upgrade-comms","No more ship upgrades available for your ship"))
							end
						else
							setCommsMessage(_("upgrade-comms","No ship upgrades available for your ship"))
						end
					else
						setCommsMessage(_("upgrade-comms","No ship upgrades available"))
					end
					addCommsReply(_("upgrade-comms","Explain ship upgrade categories"),explainShipUpgrades)
					addCommsReply(_("Back"), commsStation)
				end)
				addCommsReply(_("Back"), commsStation)
			end)
		end)
		local c_station = false
		for _, station in ipairs(circle_stations) do
			if station == comms_target then
				c_station = true
				break
			end
		end
		if c_station and not comms_target.help_requested then
			addCommsReply(_("station-comms","Could you help defend our stations with some ships?"), function()
				setCommsMessage(_("station-comms","We are also experiencing attacks. However, we will do what we can to help."))
				comms_target.help_requested = true
				addCommsReply(_("Back"), commsStation)
			end)
		end
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
						goodsAvailableMsg = goodsAvailableMsg .. string.format(_("trade-comms", "\n   %14s: %2i, %3i"),good,goodData["quantity"],goodData["cost"])
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
			end)	--end station info comms reply branch
		end	--end public relations if branch
		if comms_target.comms_data.character ~= nil then
			if random(1,100) < (70 - (20 * difficulty)) then
				addCommsReply(string.format(_("characterInfo-comms",  "Tell me about %s"),comms_target.comms_data.character), function()
					if comms_target.comms_data.characterDescription ~= nil then
						setCommsMessage(comms_target.comms_data.characterDescription)
					else
						if comms_target.comms_data.characterDeadEnd == nil then
							local deadEndChoice = math.random(1,5)
							if deadEndChoice == 1 then
								comms_target.comms_data.characterDeadEnd = string.format(_("characterInfo-comms", "Never heard of %s"),comms_target.comms_data.character)
							elseif deadEndChoice == 2 then
								comms_target.comms_data.characterDeadEnd = string.format(_("characterInfo-comms", "%s died last week. The funeral was yesterday"),comms_target.comms_data.character)
							elseif deadEndChoice == 3 then
								comms_target.comms_data.characterDeadEnd = string.format(_("characterInfo-comms", "%s? Who's %s? There's nobody here named %s"),comms_target.comms_data.character,comms_target.comms_data.character,comms_target.comms_data.character)
							elseif deadEndChoice == 4 then
								comms_target.comms_data.characterDeadEnd = string.format(_("characterInfo-comms", "We don't talk about %s. They are gone and good riddance"),comms_target.comms_data.character)
							else
								comms_target.comms_data.characterDeadEnd = string.format(_("characterInfo-comms", "I think %s moved away"),comms_target.comms_data.character)
							end
						end
						setCommsMessage(comms_target.comms_data.characterDeadEnd)
					end
					addCommsReply(_("Back"), commsStation)
				end)
			end
		end
		addCommsReply(_("stationAssist-comms","Report status"), function()
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
    				addCommsReply(string.format(_("stationAssist-comms","Rendezvous at waypoint %d"),n),function()
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
    						setCommsMessage(string.format(_("stationAssist-comms","We have dispatched %s to rendezvous at waypoint %d"),ship:getCallSign(),n))
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
--	Non-standard communications functions
function upgradePlayerShip(p,u_type)
	local tempTypeName = p:getTypeName()
	local current_level = p.upgrade_path[u_type]
	if u_type == "beam" then
		for i,b in ipairs(upgrade_path[tempTypeName].beam[current_level+1]) do
			p:setBeamWeapon(b.idx,b.arc,b.dir,b.rng,b.cyc,b.dmg)
			p:setBeamWeaponTurret(b.idx,0,0,0)
			if b.tar ~= nil then
				p:setBeamWeaponTurret(b.idx,b.tar,b.tdr,b.trt)
			end
		end
	elseif u_type == "missiles" then
		for i=1,p:getWeaponTubeCount() do
			local tube_speed = p:getTubeLoadTime(i-1)
			p:setTubeLoadTime(i+1,.000001)
			p:commandUnloadTube(i-1)
			p:setTubeLoadTime(i+1,tube_speed)
		end
		local tube_level = upgrade_path[tempTypeName].missiles[current_level+1].tube
		local ordnance_level = upgrade_path[tempTypeName].missiles[current_level+1].ord
		p:setWeaponTubeCount(#upgrade_path[tempTypeName].tube[tube_level])
		local size_trans = {
			["S"] = "small",
			["M"] = "medium",
			["L"] = "large",
		}
		local missile_trans = {
			{typ = "Homing", short_type = "hom"},
			{typ = "Nuke", short_type = "nuk"},
			{typ = "EMP", short_type = "emp"},
			{typ = "Mine", short_type = "min"},
			{typ = "HVLI", short_type = "hvl"},
		}
		for i,m in ipairs(upgrade_path[tempTypeName].tube[tube_level]) do
			p:setWeaponTubeDirection(m.idx,m.dir)
			p:setTubeSize(m.idx,size_trans[m.siz])
			p:setTubeLoadTime(m.idx,m.spd)
			local exclusive = false
			for j,lm in ipairs(missile_trans) do
				if m[lm.short_type] then
					if exclusive then
						p:weaponTubeAllowMissle(m.idx,lm.typ)
					else
						p:setWeaponTubeExclusiveFor(m.idx,lm.typ)
						exclusive = true
					end
				end
			end
		end
		for i,o in ipairs(missile_trans) do
--			print("upgrade ship missiles: o typ:",o.typ,"template:",tempTypeName,"ordnance level:",ordnance_level,"o short type:",o.short_type)
			p:setWeaponStorageMax(o.typ,upgrade_path[tempTypeName].ordnance[ordnance_level][o.short_type])
		end
		if p:getWeaponTubeCount() > 0 then
			local size_letter = {
				["small"] = 	"S",
				["medium"] =	"M",
				["large"] =		"L",
			}
			p.tube_size = ""
			for i=1,p:getWeaponTubeCount() do
				p.tube_size = p.tube_size .. size_letter[p:getTubeSize(i-1)]
			end
		end
	elseif u_type == "shield" then
		if #upgrade_path[tempTypeName].shield[current_level+1] > 1 then
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level+1][1].max,upgrade_path[tempTypeName].shield[current_level+1][2].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level+1][1].max,upgrade_path[tempTypeName].shield[current_level+1][2].max)
		else
			p:setShieldsMax(upgrade_path[tempTypeName].shield[current_level+1][1].max)
			p:setShields(upgrade_path[tempTypeName].shield[current_level+1][1].max)
		end
	elseif u_type == "hull" then
		p:setHullMax(upgrade_path[tempTypeName].hull[current_level+1].max)
		p:setHull(upgrade_path[tempTypeName].hull[current_level+1].max)
	elseif u_type == "impulse" then
		p:setImpulseMaxSpeed(upgrade_path[tempTypeName].impulse[current_level+1].max_front,upgrade_path[tempTypeName].impulse[current_level+1].max_back)
		p:setAcceleration(upgrade_path[tempTypeName].impulse[current_level+1].accel_front,upgrade_path[tempTypeName].impulse[current_level+1].accel_back)
		p:setRotationMaxSpeed(upgrade_path[tempTypeName].impulse[current_level+1].turn)
		if upgrade_path[tempTypeName].impulse[current_level+1].boost > 0 or upgrade_path[tempTypeName].impulse[current_level+1].strafe > 0 then
			p:setCanCombatManeuver(true)
			p:setCombatManeuver(upgrade_path[tempTypeName].impulse[current_level+1].boost,upgrade_path[tempTypeName].impulse[current_level+1].strafe)
			p.combat_maneuver_capable = true
		end
	elseif u_type == "ftl" then
		if upgrade_path[tempTypeName].ftl[current_level+1].jump_long > 0 then
			p:setJumpDrive(true)
			p.max_jump_range = upgrade_path[tempTypeName].ftl[current_level+1].jump_long
			p.min_jump_range = upgrade_path[tempTypeName].ftl[current_level+1].jump_short
			p:setJumpDriveRange(p.min_jump_range,p.max_jump_range)
			p:setJumpDriveCharge(p.max_jump_range)
		end
		if upgrade_path[tempTypeName].ftl[current_level+1].warp > 0 then
			p:setWarpDrive(true)
			p:setWarpSpeed(upgrade_path[tempTypeName].ftl[current_level+1].warp)
		end
	elseif u_type == "sensors" then		
		p:setLongRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level+1].long)
		p.normal_long_range_radar = upgrade_path[tempTypeName].sensors[current_level+1].long
		p:setShortRangeRadarRange(upgrade_path[tempTypeName].sensors[current_level+1].short)
		p.prox_scan = upgrade_path[tempTypeName].sensors[current_level+1].prox_scan
	end
	p.upgrade_path[u_type] = current_level+1
	p.shipScore = p.shipScore + 1
end
function explainShipUpgrades()
	setCommsMessage(_("upgrade-comms","Which ship system upgrade category are you wondering about?"))
	--upgrade_path explained
	addCommsReply(_("upgrade-comms","beam"),function()
		setCommsMessage(_("upgrade-comms","Beam upgrades refer to the beam weapons systems. They might include additional beam mounts, longer range, faster recharge or cycle times, increased damage, wider beam firing arcs or faster beam turret rotation speed."))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("upgrade-comms","missiles"),function()
		setCommsMessage(_("upgrade-comms","Missile upgrades refer to aspects of the missile weapons systems. They might include additional tubes, faster tube load times, increased tube size, additional missile types or additional missile storage capacity."))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("upgrade-comms","shield"),function()
		setCommsMessage(_("upgrade-comms","Shield upgrades refer to the protective energy shields around your ship. They might include increased charge capacity (overall strength) for the front, rear or both shield arcs or the addition of a shield arc."))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("upgrade-comms","hull"),function()
		setCommsMessage(_("upgrade-comms","Hull upgrades refer to strengthening the ship hull to withstand more damage in the form of armor plating or structural bolstering."))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("upgrade-comms","impulse"),function()
		setCommsMessage(_("upgrade-comms","Impulse upgrades refer to changes related to the impulse engines. They might include improving the top speed or acceleration (forward, reverse or both), maneuvering speed or combat maneuver (boost, which is moving forward, or strafe, which is sideways motion or both)."))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("upgrade-comms","ftl"),function()
		setCommsMessage(_("upgrade-comms","FTL (short for faster than light) upgrades refer to warp drive or jump drive enhancements. They might include the addition of an ftl drive, a change in the range of the jump drive or an increase in the top speed of the warp drive"))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("upgrade-comms","sensors"),function()
		setCommsMessage(_("upgrade-comms","Sensor upgrades refer to the ship's ability to detect other objects. They might include increased long range sensors, increased short range sensors, automated proximity scanners for ships or improved range for automated proximity scanners."))
		addCommsReply(_("upgrade-comms","Back to ship upgrade category explanation list"), explainShipUpgrades)
		addCommsReply(_("Back"), commsStation)
	end)
	addCommsReply(_("Back"), commsStation)
end
function saboteurOption()
	if comms_source.aggressive_enemy == nil then
		addCommsReply(_("orders-comms","Is there any chance at victory for this outpost?"),function()
			setCommsMessage(_("orders-comms","The outpost leadership have been bemoaning their fate and discussing various options. They think there's an off chance for long term viability for the outpost."))
			addCommsReply(_("orders-comms","Don't keep me in suspense"),function()
				setCommsMessage(_("orders-comms","It's a low probability scenario, but if we destroyed the most aggressive enemy stations in the area, we might get the rest to agree to a truce."))
				addCommsReply(_("orders-comms","Which ones are the aggressive ones?"),function()
					if comms_source.aggressive_enemy == nil then
						setCommsMessage(_("orders-comms","The ones that keep sending attacking ships. You can just track back along the attacking ships' approach vector to find their home base."))
						addCommsReply(_("orders-comms","Have you tracked any based on approach vector?"),function()
							local aggressive_enemies = {}
							for i,station in ipairs(circle_stations) do
								if station ~= nil and station:isValid() and station:isEnemy(comms_source) then
									table.insert(aggressive_enemies,station)
								end
							end
							comms_source.aggressive_enemy = tableRemoveRandom(aggressive_enemies)
							setCommsMessage(string.format(_("orders-comms","From our observations, %s station %s in %s is one of them.\n\nOne more thing about this plan..."),comms_source.aggressive_enemy:getFaction(),comms_source.aggressive_enemy:getCallSign(),comms_source.aggressive_enemy:getSectorName()))
							addCommsReply(_("orders-comms","Just one? What is it?"),function()
								setCommsMessage(_("orders-comms","If there are any friendly or neutral stations you haven't contacted yet to ask for their help, you should contact them at your earliest opportunity. A truce benefits them, too, assuming you succeed. The help they provide in protecting the outpost can free you up to destroy the aggressive stations."))
								addCommsReply(_("Back"), commsStation)					
							end)
							addCommsReply(_("Back"), commsStation)					
						end)
					else
						if comms_source.aggressive_enemy:isValid() then
							setCommsMessage(string.format(_("orders-comms","%s station %s in %s"),comms_source.aggressive_enemy:getFaction(),comms_source.aggressive_enemy:getCallSign(),comms_source.aggressive_enemy:getSectorName()))
						else
							local aggressive_enemies = {}
							for i,station in ipairs(circle_stations) do
								if station ~= nil and station:isValid() and station:isEnemy(comms_source) then
									table.insert(aggressive_enemies,station)
								end
							end
							comms_source.aggressive_enemy = tableRemoveRandom(aggressive_enemies)
							setCommsMessage(string.format(_("orders-comms","%s station %s in %s is probably another aggressive station"),comms_source.aggressive_enemy:getFaction(),comms_source.aggressive_enemy:getCallSign(),comms_source.aggressive_enemy:getSectorName()))
						end
					end						
					addCommsReply(_("Back"), commsStation)					
				end)
				addCommsReply(_("Back"), commsStation)
			end)
			addCommsReply(_("Back"), commsStation)
		end)
	else		
		addCommsReply(_("orders-comms","Any better chance at victory for this outpost?"),function()
			local out = ""
			if comms_source.aggressive_enemy:isValid() then
				out = string.format(_("orders-comms","%s station %s in %s is still the one station we've been able to track the attacking ships back to."),comms_source.aggressive_enemy:getFaction(),comms_source.aggressive_enemy:getCallSign(),comms_source.aggressive_enemy:getSectorName())
			else
				local aggressive_enemies = {}
				for i,station in ipairs(circle_stations) do
					if station ~= nil and station:isValid() and station:isEnemy(comms_source) then
						table.insert(aggressive_enemies,station)
					end
				end
				comms_source.aggressive_enemy = tableRemoveRandom(aggressive_enemies)
				out = string.format(_("orders-comms","%s station %s in %s is probably another aggressive station."),comms_source.aggressive_enemy:getFaction(),comms_source.aggressive_enemy:getCallSign(),comms_source.aggressive_enemy:getSectorName())
			end
			if getScenarioTime() > saboteur_idea_time then
				if comms_source.saboteur_instructions then
					addCommsReply(_("orders-comms","Remind me about the saboteur plan"),function()
						local out = _("orders-comms","Summary: Be sure you have at least one mine aboard. Find a neutral freighter. Convince them to take on a new crewmember. From there it's up to the saboteur.")
						if comms_source.saboteur_deployed ~= nil then
							out = string.format(_("orders-comms","%s\nYou have already planted the saboteur on %s"),out,comms_source.saboteur_deployed)
						else
							if comms_source:getRepairCrewCount() < 1 then
								out = string.format(_("orders-comms","%s\nYou need to replace one or more of your repair crew. We'll be sure the first one you get also has saboteur training."),out)
							end
							if comms_source:getWeaponStorage("Mine") < 1 then
								out = string.format(_("orders-comms","%s\nYou need a mine to give to the saboteur."),out)
							end
						end
						setCommsMessage(out)
						addCommsReply(_("Back"), commsStation)
					end)
				else
					if comms_source:getRepairCrewCount() > 0 and comms_source:getWeaponStorage("Mine") > 0 then
						out = string.format(_("orders-comms","%s The outpost leadership have an idea about how an aggressive enemy station might be destroyed. It differs from the confrontational solution of attacking an aggressive enemy station directly. Interested?"),out)
						addCommsReply(_("orders-comms","Yes, tell me about this idea"),function()
							setCommsMessage(_("orders-comms","The idea is to sneak a saboteur aboard an aggressive enemy station."))
							addCommsReply(_("orders-comms","We can't dock with an enemy station"),function()
								setCommsMessage(_("orders-comms","That's true. However, commercial freighters dock with those stations all the time. Commerce must go on despite the hostilities."))
								addCommsReply(_("orders-comms","Put a saboteur on a freighter?"),function()
									setCommsMessage(_("orders-comms","Right. The saboteur stays on the freighter until the freighter docks with an aggressive enemy station. The saboteur then plants explosives on the station at a vulnerable point."))
									addCommsReply(_("orders-comms","I see problems with this idea"),function()
										setCommsMessage(_("orders-comms","Oh yes, there are several critical points where the plan could fail. The freighter you choose might not accept the saboteur. The freighter might get destroyed before they dock at an aggressive enemy station. The security measures on the station may prevent the saboteur from planting the explosives."))
										addCommsReply(_("orders-comms","Another point: we don't have a saboteur"),function()
											setCommsMessage(_("orders-comms","Actually, that's not true. One of your repair crew recently completed a correspondence course in espionage and sabotage and thus could be deployed as the saboteur for this plan."))
											addCommsReply(_("orders-comms","Does graduation come with complimentary explosives?"),function()
												setCommsMessage(_("orders-comms","No. We did away with an actual graduation ceremony because too many of our graduates wanted to test their new sabotage skills as a prank at graduation causing distressful mayhem. However, your repair crew now has the training to adapt one of your mines into the appropriate explosives for the plan."))
												addCommsReply(_("orders-comms","Isn't it illegal?"),function()
													setCommsMessage(string.format(_("orders-comms","Your repair crew saboteur has the full backing and approval of the outpost leadership. The sabotage is sanctioned under the rules outlined in the %s charter assuming the saboteur knows the risks and volunteers. We've taken the liberty of providing an outline of the plan to the repair crew saboteur and secured their agreement to conduct the mission in writing. Copies of this and the formal sanctioning of the action by the outpost leadership are in your secure databanks."),comms_source:getFaction()))
													addCommsReply(_("orders-comms","How do we know if this plan succeeds or fails?"),function()
														setCommsMessage(_("orders-comms","Every saboteur is trained to send simple status reports through the microscopic subspace transmitter surgically implanted in them during their training. When you check on your orders, updates will be shown on the plan progress in that report."))
														addCommsReply(_("orders-comms","That's a convoluted plan. Can you summarize what we need to do?"),function()
															setCommsMessage(_("orders-comms","Be sure you have at least one mine aboard. Find a neutral freighter. Convince them to take on a new crewmember. From there it's up to the saboteur."))
															comms_source.saboteur_instructions = true
															addCommsReply(_("Back"), commsStation)
														end)
														addCommsReply(_("Back"), commsStation)
													end)
													addCommsReply(_("Back"), commsStation)
												end)
												addCommsReply(_("Back"), commsStation)
											end)
											addCommsReply(_("Back"), commsStation)
										end)
										addCommsReply(_("Back"), commsStation)
									end)
									addCommsReply(_("Back"), commsStation)
								end)
								addCommsReply(_("Back"), commsStation)
							end)
							addCommsReply(_("Back"), commsStation)
						end)
						addCommsReply(_("orders-comms","No, we're having enough trouble as it is"),function()
							setCommsMessage(_("orders-comms","Suit yourself"))
							addCommsReply(_("Back"), commsStation)
						end)
					end
				end
			end
			setCommsMessage(out)
			addCommsReply(_("Back"), commsStation)
		end)
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
function deploySaboteur()
	if comms_source.saboteur_instructions then
		if comms_source.saboteur_deployed == nil then
			if comms_source:getRepairCrewCount() > 0 then
				if comms_source:getWeaponStorage("Mine") > 0 then
					if not comms_target.saboteur_process_complete then
						addCommsReply(_("ship-comms","Would you like another crewmember?"),function()
							setCommsMessage(_("ship-comms","We don't really need one"))
							addCommsReply(_("ship-comms","This one's got repair crew experience"),function()
								local convincing_avenue = false
								if comms_source:getReputationPoints() >= 50 then
									convincing_avenue = true
									addCommsReply(_("ship-comms","Take on crewmember as a favor (50 reputation)?"),function()
										if comms_source:getRepairCrewCount() > 0 then
											if comms_source:getWeaponStorage("Mine") > 0 then
												if comms_source:takeReputationPoints(50) then
													comms_target.saboteur_process_complete = true
													comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() - 1)
													comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorage("Mine") - 1)
													comms_source.saboteur_deployed = comms_target:getCallSign()
													comms_source.saboteur_ship = comms_target
													if saboteur_freighters == nil then
														saboteur_freighters = {}
													end
													table.insert(saboteur_freighters,comms_target)
													setCommsMessage(_("ship-comms","We have taken on your repair crewmember as a new crewmember on our ship."))
												else
													setCommsMessage(_("needRep-comms","Insufficient reputation"))
													comms_target.saboteur_process_complete = true
												end
											else
												setCommsMessage(_("ship-comms","No mine to send with saboteur"))
												comms_target.saboteur_process_complete = true
											end
										else
											setCommsMessage(_("ship-comms","No repair crew to send"))
											comms_target.saboteur_process_complete = true
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
								local player_good_count = 0
								if comms_source.goods ~= nil then
									for good, goodQuantity in pairs(comms_source.goods) do
										player_good_count = player_good_count + goodQuantity
									end
								end
								if player_good_count > 0 then
									convincing_avenue = true
									for good, goodQuantity in pairs(comms_source.goods) do
										if goodQuantity > 0 then
											addCommsReply(string.format(_("ship-comms","Offer %s to take on crewmember"),good),function()
												if comms_source:getRepairCrewCount() > 0 then
													if comms_source:getWeaponStorage("Mine") > 0 then
														comms_source.goods[good] = comms_source.goods[good] - 1
														comms_target.saboteur_process_complete = true
														comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() - 1)
														comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorage("Mine") - 1)
														comms_source.saboteur_deployed = comms_target:getCallSign()
														comms_source.saboteur_ship = comms_target
														if saboteur_freighters == nil then
															saboteur_freighters = {}
														end
														table.insert(saboteur_freighters,comms_target)
														setCommsMessage(string.format(_("ship-comms","Thanks for the %s. We have taken on your repair crewmember as a new crewmember on our ship."),good))
													else
														setCommsMessage(_("ship-comms","No mine to send with saboteur"))
														comms_target.saboteur_process_complete = true
													end
												else
													setCommsMessage(_("ship-comms","No repair crew to send"))
													comms_target.saboteur_process_complete = true
												end
												addCommsReply(_("Back"), commsShip)
											end)
										end
									end
								end
								if convincing_avenue then
									setCommsMessage(_("ship-comms","I talked to the captain, but he still needs convincing."))
								else
									setCommsMessage(string.format(_("ship-comms","Not interested.\n\n[Outpost Leadership] We were monitoring your exchange with %s. Next time, try convincing the captain using 50 or more reputation or with some cargo aboard your ship."),comms_target:getCallSign()))
									comms_target.saboteur_process_complete = true
								end
								addCommsReply(_("Back"), commsShip)
							end)
							addCommsReply(_("ship-comms","This one can upgrade your impulse engines"),function()
								local convincing_avenue = false
								if comms_source:getReputationPoints() >= 25 then
									convincing_avenue = true
									addCommsReply(_("ship-comms","Take on crewmember as a favor (25 reputation)?"),function()
										if comms_source:getRepairCrewCount() > 0 then
											if comms_source:getWeaponStorage("Mine") > 0 then
												if comms_source:takeReputationPoints(25) then
													comms_target.saboteur_process_complete = true
													comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() - 1)
													comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorage("Mine") - 1)
													comms_source.saboteur_deployed = comms_target:getCallSign()
													comms_source.saboteur_ship = comms_target
													comms_target:setImpulseMaxSpeed(comms_target:getImpulseMaxSpeed()*2)
													if saboteur_freighters == nil then
														saboteur_freighters = {}
													end
													table.insert(saboteur_freighters,comms_target)
													setCommsMessage(_("ship-comms","We have taken on your repair crewmember as a new crewmember on our ship. The increased impulse speed is greatly appreciated."))
												else
													setCommsMessage(_("needRep-comms","Insufficient reputation"))
													comms_target.saboteur_process_complete = true
												end
											else
												setCommsMessage(_("ship-comms","No mine to send with saboteur"))
												comms_target.saboteur_process_complete = true
											end
										else
											setCommsMessage(_("ship-comms","No repair crew to send"))
											comms_target.saboteur_process_complete = true
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
								local player_good_count = 0
								if comms_source.goods ~= nil then
									for good, goodQuantity in pairs(comms_source.goods) do
										player_good_count = player_good_count + goodQuantity
									end
								end
								if player_good_count > 0 then
									convincing_avenue = true
									for good, goodQuantity in pairs(comms_source.goods) do
										if goodQuantity > 0 then
											addCommsReply(string.format(_("ship-comms","Offer %s to take on crewmember"),good),function()
												if comms_source:getRepairCrewCount() > 0 then
													if comms_source:getWeaponStorage("Mine") > 0 then
														comms_source.goods[good] = comms_source.goods[good] - 1
														comms_target.saboteur_process_complete = true
														comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() - 1)
														comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorage("Mine") - 1)
														comms_source.saboteur_deployed = comms_target:getCallSign()
														comms_source.saboteur_ship = comms_target
														comms_target:setImpulseMaxSpeed(comms_target:getImpulseMaxSpeed()*2)
														if saboteur_freighters == nil then
															saboteur_freighters = {}
														end
														table.insert(saboteur_freighters,comms_target)
														setCommsMessage(string.format(_("ship-comms","Thanks for the %s. We have taken on your repair crewmember as a new crewmember on our ship. The increased impulse speed is greatly appreciated."),good))
													else
														setCommsMessage(_("ship-comms","No mine to send with saboteur"))
														comms_target.saboteur_process_complete = true
													end
												else
													setCommsMessage(_("ship-comms","No repair crew to send"))
													comms_target.saboteur_process_complete = true
												end
												addCommsReply(_("Back"), commsShip)
											end)
										end
									end
								end
								if convincing_avenue then
									setCommsMessage(_("ship-comms","I talked to the captain, but he still needs convincing."))
								else
									setCommsMessage(string.format(_("ship-comms","Not interested.\n\n[Outpost Leadership] We were monitoring your exchange with %s. Next time, try convincing the captain using 25 or more reputation or with some cargo aboard your ship."),comms_target:getCallSign()))
									comms_target.saboteur_process_complete = true
								end
								addCommsReply(_("Back"), commsShip)
							end)
							addCommsReply(_("ship-comms","This one wants civilian experience"),function()
								local convincing_avenue = false
								local saboteur_reputation = math.random(40,90)
								if comms_source:getReputationPoints() >= saboteur_reputation then
									convincing_avenue = true
									addCommsReply(string.format(_("ship-comms","Take on crewmember as a favor (%i reputation)?"),saboteur_reputation),function()
										if comms_source:getRepairCrewCount() > 0 then
											if comms_source:getWeaponStorage("Mine") > 0 then
												if comms_source:takeReputationPoints(saboteur_reputation) then
													comms_target.saboteur_process_complete = true
													comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() - 1)
													comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorage("Mine") - 1)
													comms_source.saboteur_deployed = comms_target:getCallSign()
													comms_source.saboteur_ship = comms_target
													if saboteur_freighters == nil then
														saboteur_freighters = {}
													end
													table.insert(saboteur_freighters,comms_target)
													setCommsMessage(_("ship-comms","We have taken on your repair crewmember as a new crewmember on our ship."))
												else
													setCommsMessage(_("needRep-comms","Insufficient reputation"))
													comms_target.saboteur_process_complete = true
												end
											else
												setCommsMessage(_("ship-comms","No mine to send with saboteur"))
												comms_target.saboteur_process_complete = true
											end
										else
											setCommsMessage(_("ship-comms","No repair crew to send"))
											comms_target.saboteur_process_complete = true
										end
										addCommsReply(_("Back"), commsShip)
									end)
								end
								local player_good_count = 0
								if comms_source.goods ~= nil then
									for good, goodQuantity in pairs(comms_source.goods) do
										player_good_count = player_good_count + goodQuantity
									end
								end
								if player_good_count > 0 then
									convincing_avenue = true
									for good, goodQuantity in pairs(comms_source.goods) do
										if goodQuantity > 0 then
											addCommsReply(string.format(_("ship-comms","Offer %s to take on crewmember"),good),function()
												if comms_source:getRepairCrewCount() > 0 then
													if comms_source:getWeaponStorage("Mine") > 0 then
														comms_source.goods[good] = comms_source.goods[good] - 1
														comms_target.saboteur_process_complete = true
														comms_source:setRepairCrewCount(comms_source:getRepairCrewCount() - 1)
														comms_source:setWeaponStorage("Mine",comms_source:getWeaponStorage("Mine") - 1)
														comms_source.saboteur_deployed = comms_target:getCallSign()
														comms_source.saboteur_ship = comms_target
														if saboteur_freighters == nil then
															saboteur_freighters = {}
														end
														table.insert(saboteur_freighters,comms_target)
														setCommsMessage(string.format(_("ship-comms","Thanks for the %s. We have taken on your repair crewmember as a new crewmember on our ship."),good))
													else
														setCommsMessage(_("ship-comms","No mine to send with saboteur"))
														comms_target.saboteur_process_complete = true
													end
												else
													setCommsMessage(_("ship-comms","No repair crew to send"))
													comms_target.saboteur_process_complete = true
												end
												addCommsReply(_("Back"), commsShip)
											end)
										end
									end
								end
								if convincing_avenue then
									setCommsMessage(_("ship-comms","I talked to the captain, but he still needs convincing."))
								else
									setCommsMessage(string.format(_("ship-comms","Not interested.\n\n[Outpost Leadership] We were monitoring your exchange with %s. Next time, try convincing the captain using 40 to 90 reputation or with some cargo aboard your ship."),comms_target:getCallSign()))
									comms_target.saboteur_process_complete = true
								end
								addCommsReply(_("Back"), commsShip)
							end)
							addCommsReply(_("Back"), commsShip)
						end)
					end
				end
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
			deploySaboteur()
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
					local timer_display = string.format(_("-tabRelay&Operations", "Disruption %i"),math.floor(p.continuum_timer))
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
			deploySaboteur()
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
				addCommsReply(string.format(_("shipAssist-comms","Defend WP %d"),n), function()
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
	addCommsReply(_("shipAssist-comms","Report status"), function()
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
	addCommsReply(_("shipServices-comms", "Service options"),function()
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
			addCommsReply(_("shipServices-comms","Repair ship system"),function()
				setCommsMessage(_("shipServices-comms","What system would you like repaired?"))
				if not comms_source:getCanLaunchProbe() then
					addCommsReply(_("shipServices-comms","Repair probe launch system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanLaunchProbe(true)
							setCommsMessage(_("shipServices-comms","Your probe launch system has been repaired"))
						else
							setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanHack() then
					addCommsReply(_("shipServices-comms","Repair hacking system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanHack(true)
							setCommsMessage(_("shipServices-comms","Your hack system has been repaired"))
						else
							setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanScan() then
					addCommsReply(_("shipServices-comms","Repair scanning system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanScan(true)
							setCommsMessage(_("shipServices-comms","Your scanners have been repaired"))
						else
							setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanCombatManeuver() then
					addCommsReply(_("shipServices-comms","Repair combat maneuver"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanCombatManeuver(true)
							setCommsMessage(_("shipServices-comms","Your combat maneuver has been repaired"))
						else
							setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
						end
						addCommsReply(_("Back"), commsServiceJonque)
					end)
				end
				if not comms_source:getCanSelfDestruct() then
					addCommsReply(_("shipServices-comms","Repair self destruct system"),function()
						if distance(comms_source,comms_target) < 5000 then
							comms_source:setCanSelfDestruct(true)
							setCommsMessage(_("shipServices-comms","Your self destruct system has been repaired"))
						else
							setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
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
			addCommsReply(string.format(_("shipServices-comms","Full hull repair (%i reputation)"),math.floor(full_repair + premium)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair + premium)) then
						comms_source:setHull(comms_source:getHullMax())
						setCommsMessage(_("shipServices-comms","All fixed up and ready to go"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("shipServices-comms","Add %i%% to hull (%i reputation)"),math.floor(full_repair/2/comms_source:getHullMax()*100),math.floor(full_repair/2 + premium/2)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/2 + premium/2)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/2))
						setCommsMessage(_("shipServices-comms","Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
			addCommsReply(string.format(_("shipServices-comms","Add %i%% to hull (%i reputation)"),math.floor(full_repair/3/comms_source:getHullMax()*100),math.floor(full_repair/3)),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(math.floor(full_repair/3)) then
						comms_source:setHull(comms_source:getHull() + (full_repair/3))
						setCommsMessage(_("shipServices-comms","Repairs completed as requested"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms","You need to stay close if you want me to fix your ship"))
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
														setCommsMessage(string.format(_("ammo-comms", "One %s provided"),missile_type))
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
			addCommsReply(_("shipServices-comms","Restock scan probes (5 reputation)"),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(5) then
						comms_source:setScanProbeCount(comms_source:getMaxScanProbeCount())
						setCommsMessage(_("shipServices-comms","I replenished your probes for you."))
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
			addCommsReply(string.format(_("shipServices-comms","Quick charge the main batteries (%i reputation)"),power_charge),function()
				if distance(comms_source,comms_target) < 5000 then
					if comms_source:takeReputationPoints(power_charge) then
						comms_source:setEnergyLevel(comms_source:getEnergyLevelMax())
						comms_source:commandSetSystemPowerRequest("reactor",1)
						comms_source:setSystemPower("reactor",1)
						comms_source:setSystemHeat("reactor",2)
						setCommsMessage(_("shipServices-comms","Your batteries have been charged"))
					else
						setCommsMessage(_("needRep-comms","Insufficient reputation"))
					end
				else
					setCommsMessage(_("shipServices-comms","You need to stay close if you want your batteries charged quickly"))
				end
				addCommsReply(_("Back"), commsServiceJonque)
			end)
		end
		if offer_hull_repair or offer_repair or offer_ordnance or offer_probes or offer_power then
			setCommsMessage(_("shipServices-comms","How can I help you get your ship in good running order?"))
		else
			setCommsMessage(_("shipServices-comms","There's nothing on your ship that I can help you fix. Sorry."))
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
		addGMMessage(_("msgGM","Empty Template pool: fix excludes or other criteria"))
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 3")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_3_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_3_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_3_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_3_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 3, the beams are longer and faster and the shields are slightly stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 5")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_5_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_5_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_5_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","30 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_5_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 5, the tubes load faster and the shields are slightly stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 8")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_8_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_8_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_8_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","30 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_8_db,		--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 8, the beams are longer and faster, the tubes load faster and the shields are stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 11")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_11_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_11_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_11_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_11_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 11, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam and the shields are stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local farco_key = _("scienceDB","Farco 13")
	local phobos_key = _("scienceDB","Phobos T3")
	local farco_13_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
	if farco_13_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(farco_key)
			farco_13_db = queryScienceDatabase(ships_key,frigate_key,farco_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","30 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				farco_13_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Farco models are evolutionary changes to the Phobos T3. In the case of the Farco 13, the maneuver speed is faster, the beams are longer and faster, there's an added longer sniping beam, the tubes load faster, there are more missiles and the shields are stronger."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local whirlwind_key = _("scienceDB","Whirlwind")
	local storm_key = _("scienceDB","Storm")
	local whirlwind_db = queryScienceDatabase(ships_key,frigate_key,whirlwind_key)
	if whirlwind_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(whirlwind_key)
			whirlwind_db = queryScienceDatabase(ships_key,frigate_key,whirlwind_key)
			local tube_key = _("scienceDB","Tube -90")
			local tube2_key = _("scienceDB","Tube -92")
			local tube3_key = _("scienceDB","Tube -88")
			local tube4_key = _("scienceDB","Tube  90")
			local tube5_key = _("scienceDB","Tube  92")
			local tube6_key = _("scienceDB","Tube  88")
			local tube7_key = _("scienceDB","Tube   0")
			local tube8_key = _("scienceDB","Tube   2")
			local tube9_key = _("scienceDB","Tube  -2")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,storm_key),	--base ship database entry
				whirlwind_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Whirlwind, another heavy artillery cruiser, takes the Storm and adds tubes and missiles. It's as if the Storm swallowed a Pirahna and grew gills. Expect to see missiles, lots of missiles"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube9_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local phobos_r2_key = _("scienceDB","Phobos R2")
	local phobos_key = _("scienceDB","Phobos T3")
	local phobos_r2_db = queryScienceDatabase(ships_key,frigate_key,phobos_r2_key)
	if phobos_r2_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(phobos_r2_key)
			phobos_r2_db = queryScienceDatabase(ships_key,frigate_key,phobos_r2_key)
			local tube_key = _("scienceDB","Tube 0")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				phobos_r2_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Phobos R2 model is very similar to the Phobos T3. It's got a faster turn speed, but only one missile tube"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local mv52_hornet_key = _("scienceDB","MV52 Hornet")
	local hornet_key = _("scienceDB","MT52 Hornet")
	local hornet_mv52_db = queryScienceDatabase(ships_key,starfighter_key,mv52_hornet_key)
	if hornet_mv52_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(mv52_hornet_key)
			hornet_mv52_db = queryScienceDatabase(ships_key,starfighter_key,mv52_hornet_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,hornet_key),	--base ship database entry
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
	local k2_key = _("scienceDB","K2 Fighter")
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Ktlitan Fighter")
	ship:setTypeName(k2_key)
	ship:setBeamWeapon(0, 60, 0, 1200.0, 2.5, 6)	--beams cycle faster (vs 4.0)
	ship:setHullMax(65)								--weaker hull (vs 70)
	ship:setHull(65)
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local ktlitan_key = _("scienceDB","Ktlitan Fighter")
	local k2_fighter_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
	if k2_fighter_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(k2_key)
			k2_fighter_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local k3_key = _("scienceDB","K3 Fighter")
	local ktlitan_key = _("scienceDB","Ktlitan Fighter")
	local k3_fighter_db = queryScienceDatabase(ships_key,no_class_key,k3_key)
	if k3_fighter_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(k3_key)
			k3_fighter_db = queryScienceDatabase(ships_key,no_class_key,k3_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local waddle5_key = _("scienceDB","Waddle 5")
	local adder_key = _("scienceDB","Adder MK5")
	local waddle_5_db = queryScienceDatabase(ships_key,starfighter_key,waddle5_key)
	if waddle_5_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(waddle5_key)
			waddle_5_db = queryScienceDatabase(ships_key,starfighter_key,waddle5_key)
			local tube_key = _("scienceDB","Small tube 0")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,adder_key),	--base ship database entry
				waddle_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Conversions R Us purchased a number of Adder MK 5 ships at auction and added warp drives to them to produce the Waddle 5"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local jade5_key = _("scienceDB","Jade 5")
	local adder_key = _("scienceDB","Adder MK5")
	local jade_5_db = queryScienceDatabase(ships_key,starfighter_key,jade5_key)
	if jade_5_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(jade5_key)
			jade_5_db = queryScienceDatabase(ships_key,starfighter_key,jade5_key)
			local tube_key = _("scienceDB","Small tube 0")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,adder_key),	--base ship database entry
				jade_5_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Conversions R Us purchased a number of Adder MK 5 ships at auction and added jump drives to them to produce the Jade 5"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local lite_drone_key = _("scienceDB","Lite Drone")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local drone_lite_db = queryScienceDatabase(ships_key,no_class_key,lite_drone_key)
	if drone_lite_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(lite_drone_key)
			drone_lite_db = queryScienceDatabase(ships_key,no_class_key,lite_drone_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local heavy_drone_key = _("scienceDB","Heavy Drone")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local drone_heavy_db = queryScienceDatabase(ships_key,no_class_key,heavy_drone_key)
	if drone_heavy_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(heavy_drone_key)
			drone_heavy_db = queryScienceDatabase(ships_key,no_class_key,heavy_drone_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local jacket_drone_key = _("scienceDB","Jacket Drone")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local drone_jacket_db = queryScienceDatabase(ships_key,no_class_key,jacket_drone_key)
	if drone_jacket_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(jacket_drone_key)
			drone_jacket_db = queryScienceDatabase(ships_key,no_class_key,jacket_drone_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local wzlindworm_key = _("scienceDB","WZ-Lindworm")
	local worm_key = _("scienceDB","WX-Lindworm")
	local wz_lindworm_db = queryScienceDatabase(ships_key,starfighter_key,wzlindworm_key)
	if wz_lindworm_db == nil then
		local starfighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if starfighter_db ~= nil then	--added for translation issues
			starfighter_db:addEntry(wzlindworm_key)
			wz_lindworm_db = queryScienceDatabase(ships_key,starfighter_key,wzlindworm_key)
			local tube_key = _("scienceDB","Small tube 0")
			local tube2_key = _("scienceDB","Small tube 1")
			local tube3_key = _("scienceDB","Small tube -1")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,worm_key),	--base ship database entry
				wz_lindworm_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The WZ-Lindworm is essentially the stock WX-Lindworm with more HVLIs, more homing missiles and added nukes. They had to remove some of the armor to get the additional missiles to fit, so the hull is weaker. Also, the WZ turns a little more slowly than the WX. This little bomber packs quite a whallop."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local tempest_key = _("scienceDB","Tempest")
	local pirahna_key = _("scienceDB","Piranha F12")
	local tempest_db = queryScienceDatabase(ships_key,frigate_key,tempest_key)
	if tempest_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(tempest_key)
			tempest_db = queryScienceDatabase(ships_key,frigate_key,tempest_key)
			local tube_key = _("scienceDB","Large tube -88")
			local tube2_key = _("scienceDB","Tube -89")
			local tube3_key = _("scienceDB","Large tube -90")
			local tube4_key = _("scienceDB","Large tube 88")
			local tube5_key = _("scienceDB","Tube 89")
			local tube6_key = _("scienceDB","Large tube 90")
			local tube7_key = _("scienceDB","Tube -91")
			local tube8_key = _("scienceDB","Tube -92")
			local tube9_key = _("scienceDB","Tube 91")
			local tube10_key = _("scienceDB","Tube 92")
			local load_val = _("scienceDB","15 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,pirahna_key),	--base ship database entry
				tempest_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","Loosely based on the Piranha F12 model, the Tempest adds four more broadside tubes (two on each side), more HVLIs, more Homing missiles and 8 Nukes. The Tempest can strike fear into the hearts of your enemies. Get yourself one today!"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube9_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube10_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local enforcer_key = _("scienceDB","Enforcer")
	local blockade_runner_key = _("scienceDB","Blockade Runner")
	local enforcer_db = queryScienceDatabase(ships_key,frigate_key,enforcer_key)
	if enforcer_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(enforcer_key)
			enforcer_db = queryScienceDatabase(ships_key,frigate_key,enforcer_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube -15")
			local tube3_key = _("scienceDB","Tube 15")
			local load_val = _("scienceDB","18 sec")
			local load2_val = _("scienceDB","12 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,blockade_runner_key),	--base ship database entry
				enforcer_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Enforcer is a highly modified Blockade Runner. A warp drive was added and impulse engines boosted along with turning speed. Three missile tubes were added to shoot homing missiles, large ones straight ahead. Stronger shields and hull. Removed rear facing beams and strengthened front beams."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load2_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load2_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local predator_key = _("scienceDB","Predator")
	local pirahna_key = _("scienceDB","Piranha F8")
	local predator_db = queryScienceDatabase(ships_key,frigate_key,predator_key)
	if predator_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(predator_key)
			predator_db = queryScienceDatabase(ships_key,frigate_key,predator_key)
			local tube_key = _("scienceDB","Large tube -60")
			local tube2_key = _("scienceDB","Tube -90")
			local tube3_key = _("scienceDB","Large tube -90")
			local tube4_key = _("scienceDB","Large tube 60")
			local tube5_key = _("scienceDB","Tube 90")
			local tube6_key = _("scienceDB","Large tube 90")
			local tube7_key = _("scienceDB","Tube -120")
			local tube8_key = _("scienceDB","Tube 120")
			local load_val = _("scienceDB","12 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,pirahna_key),	--base ship database entry
				predator_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Predator is a significantly improved Piranha F8. Stronger shields and hull, faster impulse and turning speeds, a jump drive, beam weapons, eight missile tubes pointing in six directions and a large number of homing missiles to shoot."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local corvette_key = _("scienceDB","Corvette")
	local y42_key = _("scienceDB","Atlantis Y42")
	local atlantis_key = _("scienceDB","Atlantis X23")
	local atlantis_y42_db = queryScienceDatabase(ships_key,corvette_key,y42_key)
	if atlantis_y42_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,corvette_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(y42_key)
			atlantis_y42_db = queryScienceDatabase(ships_key,corvette_key,y42_key)
			local tube_key = _("scienceDB","Tube -90")
			local tube2_key = _("scienceDB"," Tube -90")
			local tube3_key = _("scienceDB","Tube 90")
			local tube4_key = _("scienceDB"," Tube 90")
			local load_val = _("scienceDB","10 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,corvette_key,atlantis_key),	--base ship database entry
				atlantis_y42_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Atlantis Y42 improves on the Atlantis X23 with stronger shields, faster impulse and turn speeds, an extra beam in back and a larger missile stock"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local corvette_key = _("scienceDB","Corvette")
	local starhammerV_key = _("scienceDB","Starhammer V")
	local starhammer2_key = _("scienceDB","Starhammer II")
	local starhammer_v_db = queryScienceDatabase(ships_key,corvette_key,starhammerV_key)
	if starhammer_v_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,corvette_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(starhammerV_key)
			starhammer_v_db = queryScienceDatabase(ships_key,corvette_key,starhammerV_key)
			local tube_key = _("scienceDB","Tube 0")
			local tube2_key = _("scienceDB"," Tube 0")
			local load_val = _("scienceDB","10 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,corvette_key,starhammer2_key),	--base ship database entry
				starhammer_v_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Starhammer V recognizes common modifications made in the field to the Starhammer II: stronger shields, faster impulse and turning speeds, additional rear beam and more missiles to shoot. These changes make the Starhammer V a force to be reckoned with."),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},	--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local dreadnought_key = _("scienceDB","Dreadnought")
	local tyr_key = _("scienceDB","Tyr")
	local battlestation_key = _("scienceDB","Battlestation")
	local tyr_db = queryScienceDatabase(ships_key,dreadnought_key,tyr_key)
	if tyr_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,dreadnought_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(tyr_key)
			tyr_db = queryScienceDatabase(ships_key,dreadnought_key,tyr_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,dreadnought_key,battlestation_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local gnat_key = _("scienceDB","Gnat")
	local ktlitan_key = _("scienceDB","Ktlitan Drone")
	local gnat_db = queryScienceDatabase(ships_key,no_class_key,gnat_key)
	if gnat_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(gnat_key)
			gnat_db = queryScienceDatabase(ships_key,no_class_key,gnat_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local cucaracha_key = _("scienceDB","Cucaracha")
	local tug_key = _("scienceDB","Tug")
	local cucaracha_db = queryScienceDatabase(ships_key,no_class_key,cucaracha_key)
	if cucaracha_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(cucaracha_key)
			cucaracha_db = queryScienceDatabase(ships_key,no_class_key,cucaracha_key)
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,tug_key),	--base ship database entry
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
function maniapak(enemyFaction)
	local ship = CpuShip():setFaction(enemyFaction):setTemplate("Adder MK5")
	ship:onTakingDamage(function(self,instigator)
		string.format("")	--serious proton needs a global context
		if instigator ~= nil then
			self.damage_instigator = instigator
		end
	end)
	ship:setTypeName("Maniapak")
	ship:setRadarTrace("exuari_fighter.png")			--different radar trace
	ship:setImpulseMaxSpeed(70)					--slower impulse (vs 80)
	ship:setWeaponTubeCount(9)					--more (vs 1)
	ship:setWeaponTubeDirection(0,  0)				
	ship:setWeaponTubeDirection(1,-10)				
	ship:setWeaponTubeDirection(2, 10)				
	ship:setWeaponTubeDirection(3,  0)				
	ship:setWeaponTubeDirection(4,-12)				
	ship:setWeaponTubeDirection(5, 12)				
	ship:setWeaponTubeDirection(6,  0)				
	ship:setWeaponTubeDirection(7,-15)				
	ship:setWeaponTubeDirection(8, 15)				
	ship:setTubeSize(0,"small")
	ship:setTubeSize(1,"small")
	ship:setTubeSize(2,"small")
	ship:setTubeSize(6,"large")
	ship:setTubeSize(7,"large")
	ship:setTubeSize(8,"large")
	ship:setTubeLoadTime(0,15)
	ship:setTubeLoadTime(1,16)
	ship:setTubeLoadTime(2,17)
	ship:setTubeLoadTime(3,18)
	ship:setTubeLoadTime(4,19)
	ship:setTubeLoadTime(5,20)
	ship:setTubeLoadTime(6,21)
	ship:setTubeLoadTime(7,22)
	ship:setTubeLoadTime(8,23)
	ship:setWeaponStorageMax("Homing", 27)		--more (vs 0)
	ship:setWeaponStorage("Homing",    27)
	ship:setWeaponStorageMax("EMP",    18)		--more (vs 0)
	ship:setWeaponStorage("EMP",       18)
	ship:setWeaponStorageMax("Nuke",   27)		--more (vs 0)
	ship:setWeaponStorage("Nuke",      27)
	ship:setWeaponStorageMax("HVLI",   36)		--more (vs 4)
	ship:setWeaponStorage("HVLI",      36)
	local ships_key = _("scienceDB","Ships")
	local starfighter_key = _("scienceDB","Starfighter")
	local maniapak_key = _("scienceDB","Maniapak")
	local adder_key = _("scienceDB","Adder MK5")
	local maniapak_db = queryScienceDatabase(ships_key,starfighter_key,maniapak_key)
	if maniapak_db == nil then
		local fighter_db = queryScienceDatabase(ships_key,starfighter_key)
		if fighter_db ~= nil then
			fighter_db:addEntry(maniapak_key)
			maniapak_db = queryScienceDatabase(ships_key,starfighter_key,maniapak_key)
			local tube_key = _("scienceDB","Small tube 0")
			local tube2_key = _("scienceDB","Small tube -10")
			local tube3_key = _("scienceDB","Small tube 10")
			local tube4_key = _("scienceDB","Tube 0")
			local tube5_key = _("scienceDB","Tube -12")
			local tube6_key = _("scienceDB","Tube 12")
			local tube7_key = _("scienceDB","Large tube 0")
			local tube8_key = _("scienceDB","Large tube -15")
			local tube9_key = _("scienceDB","Large tube 15")
			local load_val = _("scienceDB","15 sec")
			local load2_val = _("scienceDB","16 sec")
			local load3_val = _("scienceDB","17 sec")
			local load4_val = _("scienceDB","18 sec")
			local load5_val = _("scienceDB","19 sec")
			local load6_val = _("scienceDB","20 sec")
			local load7_val = _("scienceDB","21 sec")
			local load8_val = _("scienceDB","22 sec")
			local load9_val = _("scienceDB","23 sec")
			local storage_key = _("scienceDB","Missile Storage")
			local storage_val = _("scienceDB","H:27 E:18 N:27 L:36")
			addShipToDatabase(
				queryScienceDatabase(ships_key,starfighter_key,adder_key),	--base ship database entry
				maniapak_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Maniapak is an extreme modification of an Adder MK5 and a Blade. A maniacal designer was tasked with packing as many missiles as possible in this tiny starfighter frame. This record has yet to be beaten. Unfortunately, this ship is often a danger to friends as well as foes."),
				{
					{key = tube_key, value = load_val},		--torpedo tube size, direction and load speed
					{key = tube2_key, value = load2_val},		--torpedo tube size, direction and load speed
					{key = tube3_key, value = load3_val},		--torpedo tube size, direction and load speed
					{key = tube4_key, value = load4_val},
					{key = tube5_key, value = load5_val},
					{key = tube6_key, value = load6_val},
					{key = tube7_key, value = load7_val},
					{key = tube8_key, value = load8_val},
					{key = tube9_key, value = load9_val},
					{key = storage_key, value = storage_val},
				},
				nil,
				"AdlerLongRangeScoutYellow"
			)
			maniapak_db:setImage("radar/exuari_fighter.png")		--override default radar image
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
	local ships_key = _("scienceDB","Ships")
	local corvette_key = _("scienceDB","Corvette")
	local starhammer3_key = _("scienceDB","Starhammer III")
	local starhammer2_key = _("scienceDB","Starhammer II")
	local starhammer_iii_db = queryScienceDatabase(ships_key,corvette_key,starhammer3_key)
	if starhammer_iii_db == nil then
		local corvette_db = queryScienceDatabase(ships_key,corvette_key)
		if corvette_db ~= nil then	--added for translation issues
			corvette_db:addEntry(starhammer3_key)
			starhammer_iii_db = queryScienceDatabase(ships_key,corvette_key,starhammer3_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube 0")
			local load_val = _("scienceDB","10 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,corvette_key,starhammer2_key),	--base ship database entry
				starhammer_iii_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The designers of the Starhammer III took the Starhammer II and added a rear facing beam, enlarged one of the missile tubes and added more missiles to fire"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},			--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local no_class_key = _("scienceDB","No Class")
	local k2_key = _("scienceDB","K2 Breaker")
	local ktlitan_key = _("scienceDB","Ktlitan Breaker")
	local k2_breaker_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
	if k2_breaker_db == nil then
		local no_class_db = queryScienceDatabase(ships_key,no_class_key)
		if no_class_db ~= nil then	--added for translation issues
			no_class_db:addEntry(k2_key)
			k2_breaker_db = queryScienceDatabase(ships_key,no_class_key,k2_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube -30")
			local tube3_key = _("scienceDB","Tube 30")
			local load_val = _("scienceDB","13 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,no_class_key,ktlitan_key),	--base ship database entry
				k2_breaker_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The K2 Breaker designers took the Ktlitan Breaker and beefed up the hull, added two bracketing tubes, enlarged the center tube and added more missiles to shoot. Should be good for a couple of enemy ships"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local hurricane_key = _("scienceDB","Hurricane")
	local pirahna_key = _("scienceDB","Piranha F8")
	local hurricane_db = queryScienceDatabase(ships_key,frigate_key,hurricane_key)
	if hurricane_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(hurricane_key)
			hurricane_db = queryScienceDatabase(ships_key,frigate_key,hurricane_key)
			local tube_key = _("scienceDB","Large tube 0")
			local tube2_key = _("scienceDB","Tube 0")
			local tube3_key = _("scienceDB","Large tube 90")
			local tube4_key = _("scienceDB","Large tube -90")
			local tube5_key = _("scienceDB","Small tube -15")
			local tube6_key = _("scienceDB","Small tube 15")
			local tube7_key = _("scienceDB","Tube -30")
			local tube8_key = _("scienceDB","Tube 30")
			local load_val = _("scienceDB","12 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,pirahna_key),	--base ship database entry
				hurricane_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Hurricane is designed to jump in and shower the target with missiles. It is based on the Piranha F8, but with a jump drive, five more tubes in various directions and sizes and lots more missiles to shoot"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},			--torpedo tube direction and load speed
					{key = tube3_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube4_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube5_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube6_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube7_key, value = load_val},		--torpedo tube direction and load speed
					{key = tube8_key, value = load_val},		--torpedo tube direction and load speed
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
	local ships_key = _("scienceDB","Ships")
	local frigate_key = _("scienceDB","Frigate")
	local t4_key = _("scienceDB","Phobos T4")
	local phobos_key = _("scienceDB","Phobos T3")
	local phobos_t4_db = queryScienceDatabase(ships_key,frigate_key,t4_key)
	if phobos_t4_db == nil then
		local frigate_db = queryScienceDatabase(ships_key,frigate_key)
		if frigate_db ~= nil then	--added for translation issues
			frigate_db:addEntry(t4_key)
			phobos_t4_db = queryScienceDatabase(ships_key,frigate_key,t4_key)
			local tube_key = _("scienceDB","Tube -1")
			local tube2_key = _("scienceDB","Tube 1")
			local load_val = _("scienceDB","60 sec")
			addShipToDatabase(
				queryScienceDatabase(ships_key,frigate_key,phobos_key),	--base ship database entry
				phobos_t4_db,	--modified ship database entry
				ship,			--ship just created, long description on the next line
				_("scienceDB","The Phobos T4 makes some simple improvements on the Phobos T3: faster maneuver, stronger front shields, though weaker rear shields and longer and faster beam weapons"),
				{
					{key = tube_key, value = load_val},	--torpedo tube direction and load speed
					{key = tube2_key, value = load_val},		--torpedo tube direction and load speed
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
	local jonque_key = _("scienceDB","Service Jonque")
	ship:setTypeName(jonque_key):setCommsScript(""):setCommsFunction(commsServiceJonque)
	addFreighter(jonque_key,ship)	--update science database if applicable
	return ship
end

function genericFreighterScienceInfo(specific_freighter_db,base_db,ship)
	local freighter_key = _("scienceDB","Freighter")
	specific_freighter_db:setImage("radar/transport.png")
	specific_freighter_db:setKeyValue("Sub-class",freighter_key)
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
	local ships_key = _("scienceDB","Ships")
	local freighter_key = _("scienceDB","Freighter")
	local freighter_db = queryScienceDatabase(ships_key,freighter_key)
	if freighter_db == nil then
		local ship_db = queryScienceDatabase(ships_key)
		ship_db:addEntry(freighter_key)
		freighter_db = queryScienceDatabase(ships_key,freighter_key)
		freighter_db:setImage("radar/transport.png")
		freighter_db:setLongDescription(_("scienceDB","Small, medium and large scale transport ships. These are the working ships that keep commerce going in any sector. They may carry personnel, goods, cargo, equipment, garbage, fuel, research material, etc."))
	end
	return freighter_db
end
function addFreighter(freighter_type,ship)
	local ships_key = _("scienceDB","Ships")
	local freighter_key = _("scienceDB","Freighter")
	local corvette_key = _("scienceDB","Corvette")
	local sedan_key = _("scienceDB","Space Sedan")
	local omnibus_key = _("scienceDB","Omnibus")
	local jonque_key = _("scienceDB","Service Jonque")
	local courier_key = _("scienceDB","Courier")
	local wagon_key = _("scienceDB","Work Wagon")
	local lorry_key = _("scienceDB","Laden Lorry")
	local physics_key = _("scienceDB","Physics Research")
	local freighter_db = addFreighters()
	if freighter_type ~= nil then
		if freighter_type == sedan_key then
			local space_sedan_db = queryScienceDatabase(ships_key,freighter_key,sedan_key)
			if space_sedan_db == nil then
				local pjf3_key = _("scienceDB","Personnel Jump Freighter 3")
				freighter_db:addEntry(sedan_key)
				space_sedan_db = queryScienceDatabase(ships_key,freighter_key,sedan_key)
				genericFreighterScienceInfo(space_sedan_db,queryScienceDatabase(ships_key,corvette_key,pjf3_key),ship)
				space_sedan_db:setModelDataName("transport_1_3")
				space_sedan_db:setLongDescription(_("scienceDB","The Space Sedan was built around a surplus Personnel Jump Freighter 3. It's designed to provide relatively low cost transportation primarily for people, but there is also a limited amount of cargo space available"))
			end
		elseif freighter_type == omnibus_key then
			local omnibus_db = queryScienceDatabase(ships_key,freighter_key,omnibus_key)
			if omnibus_db == nil then
				local pjf5_key = _("scienceDB","Personnel Jump Freighter 5")
				freighter_db:addEntry(omnibus_key)
				omnibus_db = queryScienceDatabase(ships_key,freighter_key,omnibus_key)
				genericFreighterScienceInfo(omnibus_db,queryScienceDatabase(ships_key,corvette_key,pjf5_key),ship)
				omnibus_db:setModelDataName("transport_1_5")
				omnibus_db:setLongDescription(_("scienceDB","The Omnibus was designed from the Personnel Jump Freighter 5. It's made to transport large numbers of passengers of various types along with their luggage and any associated cargo"))
			end
		elseif freighter_type == jonque_key then
			local service_jonque_db = queryScienceDatabase(ships_key,freighter_key,jonque_key)
			if service_jonque_db == nil then
				local ejf4_key = _("scienceDB","Equipment Jump Freighter 4")
				freighter_db:addEntry(jonque_key)
				service_jonque_db = queryScienceDatabase(ships_key,freighter_key,jonque_key)
				genericFreighterScienceInfo(service_jonque_db,queryScienceDatabase(ships_key,corvette_key,"Equipment Jump Freighter 4"),ship)
				service_jonque_db:setModelDataName("transport_4_4")
				service_jonque_db:setLongDescription(_("scienceDB","The Service Jonque is a modified Equipment Jump Freighter 4. It's designed to carry spare parts and equipment as well as the necessary repair personnel to where it's needed to repair stations and ships"))
			end
		elseif freighter_type == courier_key then
			local courier_db = queryScienceDatabase(ships_key,freighter_key,courier_key)
			if courier_db == nil then
				local pf1_key = _("scienceDB","Personnel Freighter 1")
				freighter_db:addEntry(courier_key)
				courier_db = queryScienceDatabase(ships_key,freighter_key,courier_key)
				genericFreighterScienceInfo(courier_db,queryScienceDatabase(ships_key,corvette_key,pf1_key),ship)
				courier_db:setModelDataName("transport_1_1")
				courier_db:setLongDescription(_("scienceDB","The Courier is a souped up Personnel Freighter 1. It's made to deliver people and messages fast. Very fast"))
			end
		elseif freighter_type == wagon_key then
			local work_wagon_db = queryScienceDatabase(ships_key,freighter_key,wagon_key)
			if work_wagon_db == nil then
				local ef2_key = _("scienceDB","Equipment Freighter 2")
				freighter_db:addEntry(wagon_key)
				work_wagon_db = queryScienceDatabase(ships_key,freighter_key,wagon_key)
				genericFreighterScienceInfo(work_wagon_db,queryScienceDatabase(ships_key,corvette_key,ef2_key),ship)
				work_wagon_db:setModelDataName("transport_4_2")
				work_wagon_db:setLongDescription(_("scienceDB","The Work Wagon is a conversion of an Equipment Freighter 2 designed to carry equipment and parts where they are needed for repair or construction."))
			end
		elseif freighter_type == lorry_key then
			local laden_lorry_db = queryScienceDatabase(ships_key,freighter_key,lorry_key)
			if laden_lorry_db == nil then
				local gf3_key = _("scienceDB","Goods Freighter 3")
				freighter_db:addEntry(lorry_key)
				laden_lorry_db = queryScienceDatabase(ships_key,freighter_key,lorry_key)
				genericFreighterScienceInfo(laden_lorry_db,queryScienceDatabase(ships_key,corvette_key,gf3_key),ship)
				laden_lorry_db:setModelDataName("transport_2_3")
				laden_lorry_db:setLongDescription(_("scienceDB","As a side contract, Conversion R Us put together the Laden Lorry from some recently acquired Goods Freighter 3 hulls. The added warp drive makes for a more versatile goods carrying vessel."))
			end
		elseif freighter_type == physics_key then
			local physics_research_db = queryScienceDatabase(ships_key,freighter_key,physics_key)
			if physics_research_db == nil then
				local garf3_key = _("scienceDB","Garbage Freighter 3")
				freighter_db:addEntry(physics_key)
				physics_research_db = queryScienceDatabase(ships_key,freighter_key,physics_key)
				genericFreighterScienceInfo(physics_research_db,queryScienceDatabase(ships_key,corvette_key,garf3_key),ship)
				physics_research_db:setModelDataName("transport_3_3")
				physics_research_db:setLongDescription(_("scienceDB","Conversion R Us cleaned up and converted excess freighter hulls into Physics Research vessels. The reduced weight improved the impulse speed and maneuverability."))
			end
		end
	end
end
function addShipToDatabase(base_db,modified_db,ship,description,tube_directions,jump_range,model_name)
	modified_db:setLongDescription(description)
	if base_db ~= nil then
		modified_db:setImage(base_db:getImage())
		local class_key = _("scienceDB","Class")
		local subclass_key = _("scienceDB","Sub-class")
		local size_key = _("scienceDB","Size")
		modified_db:setKeyValue(class_key,base_db:getKeyValue(class_key))
		modified_db:setKeyValue(subclass_key,base_db:getKeyValue(subclass_key))
		modified_db:setKeyValue(size_key,base_db:getKeyValue(size_key))
	end
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
		local shield_key = _("scienceDB","Shield")
		modified_db:setKeyValue(shield_key,shield_string)
	end
	local hull_key = _("scienceDB","Hull")
	local move_speed_key = _("scienceDB","Move speed")
	local reverse_move_speed_key = _("scienceDB","Reverse move speed")
	local turn_speed_key = _("scienceDB","Turn speed")
	local impulse_forward, impulse_reverse = ship:getImpulseMaxSpeed()
	modified_db:setKeyValue(hull_key,string.format("%i",math.floor(ship:getHullMax())))
	modified_db:setKeyValue(move_speed_key,string.format(_("scienceDB","%.1f u/min"),impulse_forward*60/1000))
	modified_db:setKeyValue(reverse_move_speed_key,string.format(_("scienceDB","%.1f u/min"),impulse_reverse*60/1000))
	modified_db:setKeyValue(turn_speed_key,string.format(_("scienceDB","%.1f deg/sec"),ship:getRotationMaxSpeed()))
	if ship:hasJumpDrive() then
		local jump_range_key = _("scienceDB","Jump range")
		if jump_range == nil then
			local base_jump_range = nil
			if base_db ~= nil then
				base_jump_range = base_db:getKeyValue(jump_range_key)
			end
			if base_jump_range ~= nil and base_jump_range ~= "" then
				modified_db:setKeyValue(jump_range_key,base_jump_range)
			else
				modified_db:setKeyValue(jump_range_key,"5 - 50 u")
			end
		else
			modified_db:setKeyValue(jump_range_key,jump_range)
		end
	end
	if ship:hasWarpDrive() then
		local ward_speed_key = _("scienceDB", "Warp Speed")
		modified_db:setKeyValue(ward_speed_key,string.format(_("scienceDB", "%.1f u/min"),ship:getWarpSpeed()*60/1000))
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
			key = string.format(_("scienceDB", "Beam weapon %i:%i"),ship:getBeamWeaponDirection(bi),ship:getBeamWeaponArc(bi))
			while(modified_db:getKeyValue(key) ~= "") do
				key = " " .. key
			end
			modified_db:setKeyValue(key,string.format(_("scienceDB", "%.1f Dmg / %.1f sec"),ship:getBeamWeaponDamage(bi),ship:getBeamWeaponCycleTime(bi)))
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
				modified_db:setKeyValue(string.format(_("scienceDB", "Storage %s"),missile_type),string.format("%i",max_storage))
			end
		end
	end
	if model_name ~= nil then
		modified_db:setModelDataName(model_name)
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
------------------------
--	Update functions  --
------------------------
--	Update loop related functions
function continuousSpawn(delta)
	if #spawn_source_pool < 1 then
		for _,station in ipairs(circle_stations) do
			if station ~= nil and station:isValid() then
				table.insert(spawn_source_pool,station)
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
			if #target_station_pool < 1 then
				for _,station in ipairs(inner_circle) do
					if station ~= nil and station:isValid() then
						table.insert(target_station_pool,station)
					end
				end
				if continuous_spawn_diagnostic then print("Inner circle target station pool rebuilt. Size:",#target_station_pool) end
			end
			local spawn_target = tableRemoveRandom(target_station_pool)
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
		if #spawn_source_pool > 0 then
			spawn_timer = spawn_interval + random(1,spawn_variance)
		else
			spawn_timer = spawn_respite_interval + random(1,spawn_variance)
		end
		if continuous_spawn_diagnostic then print("spawn timer:",spawn_timer) end
	end
	mainLinearPlot = outpostSurvival
end
function outpostSurvival(delta)
	local outpost_count = 0
	for _,station in ipairs(inner_circle) do
		if station ~= nil and station:isValid() then
			outpost_count = outpost_count + 1
		end
	end
	if outpost_count < 1 then
		local duration_string = getDuration()
		local duration = getScenarioTime()
		local rank = _("msgMainscreen","Cadet")
		local posthumous_rank = {
			{whammy = 0, duration =	0.5,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 1, duration =	1.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 1, duration =	1.0,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 2, duration =	2.5,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 2, duration =	2.0,	rank = _("msgMainscreen","Ensign")},
			{whammy = 2, duration =	1.5,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 3, duration =	3.5,	rank = _("msgMainscreen","Commander")},
			{whammy = 3, duration =	3.0,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 3, duration =	2.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 3, duration =	2.0,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 4, duration =	4.5,	rank = _("msgMainscreen","Captain")},
			{whammy = 4, duration =	4.0,	rank = _("msgMainscreen","Commander")},
			{whammy = 4, duration =	3.5,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 4, duration =	3.0,	rank = _("msgMainscreen","Ensign")},
			{whammy = 4, duration =	2.5,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 5, duration =	5.5,	rank = _("msgMainscreen","Admiral")},
			{whammy = 5, duration =	5.0,	rank = _("msgMainscreen","Captain")},
			{whammy = 5, duration =	4.5,	rank = _("msgMainscreen","Commander")},
			{whammy = 5, duration =	4.0,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 5, duration =	3.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 5, duration =	3.0,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 6, duration =	6.5,	rank = _("msgMainscreen","Admiral")},
			{whammy = 6, duration =	6.0,	rank = _("msgMainscreen","Captain")},
			{whammy = 6, duration =	5.5,	rank = _("msgMainscreen","Commander")},
			{whammy = 6, duration =	5.0,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 6, duration =	4.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 6, duration =	4.0,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 7, duration =	7.5,	rank = _("msgMainscreen","Admiral")},
			{whammy = 7, duration =	7.0,	rank = _("msgMainscreen","Captain")},
			{whammy = 7, duration =	6.5,	rank = _("msgMainscreen","Commander")},
			{whammy = 7, duration =	6.0,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 7, duration =	5.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 7, duration =	5.0,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 8, duration =	8.5,	rank = _("msgMainscreen","Admiral")},
			{whammy = 8, duration =	8.0,	rank = _("msgMainscreen","Captain")},
			{whammy = 8, duration =	7.5,	rank = _("msgMainscreen","Commander")},
			{whammy = 8, duration =	7.0,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 8, duration =	6.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 8, duration =	6.0,	rank = _("msgMainscreen","Acting Ensign")},
			{whammy = 9, duration =	9.5,	rank = _("msgMainscreen","Admiral")},
			{whammy = 9, duration =	9.0,	rank = _("msgMainscreen","Captain")},
			{whammy = 9, duration =	8.5,	rank = _("msgMainscreen","Commander")},
			{whammy = 9, duration =	8.0,	rank = _("msgMainscreen","Lieutenant")},
			{whammy = 9, duration =	7.5,	rank = _("msgMainscreen","Ensign")},
			{whammy = 9, duration =	7.0,	rank = _("msgMainscreen","Acting Ensign")},
		}
		for i,pr in ipairs(posthumous_rank) do
			if total_whammies == pr.whammy then
				if duration > (60*60*pr.duration) then
					rank = pr.rank
					break
				end
			end
		end
		local reason = string.format(_("msgMainscreen","All outpost stations destroyed.\nOutpost survived for %s. Posthumous rank: %s"),duration_string,rank)
		globalMessage(reason)
		setBanner(reason)
		victory("Exuari")
	end
	mainLinearPlot = continuousSpawn
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
function sabotageCheck(p)
	for index, ship in ipairs(saboteur_freighters) do
		if ship:isValid() then
			if ship.sabotage_target == nil then
				if ship.sabotage_success == nil then
					local docked_station = ship:getDockedWith()
					if docked_station ~= nil then
						local failed_station = false
						if ship.failed_stations ~= nil then
							for _, f_station in ipairs(ship.failed_stations) do
								if docked_station == f_station then
									failed_station = true
									break
								end
							end
						end
						if not failed_station then
							for _, station in ipairs(circle_stations) do
								if station == docked_station then
									if station:isEnemy(p) then
										local success_roll = random(1,100)
										if success_roll < 50 then
											ship.sabotage_target = station
											ship.explode_time = getScenarioTime() + 180
										elseif success_roll > 80 then
											local ex, ey = ship:getPosition()
											ExplosionEffect():setPosition(ex,ey):setSize(3000)
											saboteur_freighters[index] = saboteur_freighters[#saboteur_freighters]
											saboteur_freighters[#saboteur_freighters] = nil
											ship:destroy()
										else
											if ship.failed_stations == nil then
												ship.failed_stations = {}
											end
											table.insert(ship.failed_stations,station)
										end
									end
								end
							end
						end
					end
				end
			else
				if getScenarioTime() > ship.explode_time then
					if ship.sabotage_target ~= nil and ship.sabotage_target:isValid() then
						local ex, ey = ship.sabotage_target:getPosition()
						ExplosionEffect():setPosition(ex,ey):setSize(3000)
						ship.sabotage_success = ship.sabotage_target:getCallSign()
						ship.sabotage_target:destroy()
					end
					ship.sabotage_target = nil
					ship.explode_time = nil
				end
			end
		else
			saboteur_freighters[index] = saboteur_freighters[#saboteur_freighters]
			saboteur_freighters[#saboteur_freighters] = nil
		end
	end
end
function updatePlayerProximityScan(p)
	local obj_list = p:getObjectsInRange(p.prox_scan*1000)
	if obj_list ~= nil and #obj_list > 0 then
		for _, obj in ipairs(obj_list) do
			if obj:isValid() and obj.typeName == "CpuShip" and not obj:isFullyScannedBy(p) then
				obj:setScanState("simplescan")
			end
		end
	end
end
function updatePlayerTubeSizeBanner(p)
	if p.tube_size ~= nil then
		local tube_size_banner = string.format(_("-tabWeapons&Tactical", "%s tubes: %s"),p:getCallSign(),p.tube_size)
		if #p.tube_size == 1 then
			tube_size_banner = string.format(_("-tabWeapons&Tactical", "%s tube: %s"),p:getCallSign(),p.tube_size)
		end
		p.tube_sizes_wea = "tube_sizes_wea"
		p:addCustomInfo("Weapons",p.tube_sizes_wea,tube_size_banner,1)
		p.tube_sizes_tac = "tube_sizes_tac"
		p:addCustomInfo("Tactical",p.tube_sizes_tac,tube_size_banner,1)
	end
end
function whammyTime(p)
	local p_x, p_y = p:getPosition()
	local objs = getObjectsInRadius(p_x,p_y,10000)
	local nebulae = {}
	for i,obj in ipairs(objs) do
		if obj.typeName == "Nebula" then
			table.insert(nebulae,obj)
		end
	end
	if #nebulae > 0 then
		local neb = tableRemoveRandom(nebulae)
		local neb_x, neb_y = neb:getPosition()
		local attack_angle = angleFromVectorNorth(p_x,p_y,neb_x,neb_y)
		local base_distance = distance(neb,p)
		local poa_x, poa_y = vectorFromAngle(attack_angle,4000)
		poa_x = poa_x + neb_x
		poa_y = poa_y + neb_y
		WarpJammer():setPosition(poa_x,poa_y):setRange(math.max(4000,base_distance*2)):setFaction("Exuari")
		local fleet_prefix = generateCallSignPrefix()
		local lead_ship = starhammerV("Exuari")
		lead_ship:setPosition(poa_x,poa_y):setHeading(attack_angle):orderFlyTowards(p_x,p_y):setCallSign(generateCallSign(fleet_prefix))
		lead_ship.formation_ships = {}
		local forward_formation = {
			{angle = 10,	dist = 2500},
			{angle = 30,	dist = 2700},
			{angle = 350,	dist = 2500},
			{angle = 330,	dist = 2700},
		}
		for _, form in ipairs(forward_formation) do
			local ship = ship_template["Adder MK9"].create("Exuari","Adder MK9")
			local form_x, form_y = vectorFromAngleNorth(attack_angle + form.angle,form.dist)
			local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist)
			ship:setPosition(poa_x + form_x, poa_y + form_y):setHeading(attack_angle):orderFlyFormation(lead_ship,form_prime_x,form_prime_y):setCallSign(generateCallSign(fleet_prefix))
			table.insert(lead_ship.formation_ships,ship)
		end
		local rear_formation = {
			{angle = 120,	dist = 2500},
			{angle = 240,	dist = 2500},
			{angle = 180,	dist = 2500},
		}
		for _, form in ipairs(rear_formation) do
			local ship = ship_template["Maniapak"].create("Exuari","Maniapak")
			local form_x, form_y = vectorFromAngleNorth(attack_angle + form.angle,form.dist)
			local form_prime_x, form_prime_y = vectorFromAngle(form.angle, form.dist)
			ship:setPosition(poa_x + form_x, poa_y + form_y):setHeading(attack_angle):orderFlyFormation(lead_ship,form_prime_x,form_prime_y):setCallSign(generateCallSign(fleet_prefix))
			table.insert(lead_ship.formation_ships,ship)
		end
		p:addToShipLog(_("shipLog","Encrypted Exuari communications traffic observed"),"Magenta")
		return true
	else
		return false
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
									p:addCustomMessage("Engineering","coolant_recovery",_("coolant-msgEngineer", "Automated systems have recovered some coolant"))
								end
								if p:hasPlayerAtPosition("Engineering+") then
									p:addCustomMessage("Engineering+","coolant_recovery_plus",_("coolant-msgEngineer+", "Automated systems have recovered some coolant"))
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
				p:addCustomMessage("Engineering",repairCrewFatality,_("repairCrew-msgEngineer", "One of your repair crew has perished"))
			end
			if p:hasPlayerAtPosition("Engineering+") then
				local repairCrewFatalityPlus = "repairCrewFatalityPlus"
				p:addCustomMessage("Engineering+",repairCrewFatalityPlus,_("repairCrew-msgEngineer+", "One of your repair crew has perished"))
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
						p:addCustomMessage("Engineering","probe_launch_damage_message",_("damage-msgEngineer","The probe launch system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","probe_launch_damage_message_plus",_("damage-msgEngineer+","The probe launch system has been damaged"))
					end
				elseif named_consequence == "hack" then
					p:setCanHack(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","hack_damage_message",_("damage-msgEngineer","The hacking system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","hack_damage_message_plus",_("damage-msgEngineer+","The hacking system has been damaged"))
					end
				elseif named_consequence == "scan" then
					p:setCanScan(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","scan_damage_message",_("damage-msgEngineer","The scanners have been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","scan_damage_message_plus",_("damage-msgEngineer+","The scanners have been damaged"))
					end
				elseif named_consequence == "combat_maneuver" then
					p:setCanCombatManeuver(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","combat_maneuver_damage_message",_("damage-msgEngineer","Combat maneuver has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","combat_maneuver_damage_message_plus",_("damage-msgEngineer+","Combat maneuver has been damaged"))
					end
				elseif named_consequence == "self_destruct" then
					p:setCanSelfDestruct(false)
					if p:hasPlayerAtPosition("Engineering") then
						p:addCustomMessage("Engineering","self_destruct_damage_message",_("damage-msgEngineer","Self destruct system has been damaged"))
					end
					if p:hasPlayerAtPosition("Engineering+") then
						p:addCustomMessage("Engineering+","self_destruct_damage_message_plus",_("damage-msgEngineer+","Self destruct system has been damaged"))
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
						p:addCustomButton("Relay",tbi,_("inventory-buttonRelay", "Inventory"),function() playerShipCargoInventory(p) end,2)
						p.inventoryButton = true
					end
				end
				if p:hasPlayerAtPosition("Operations") then
					if p.inventoryButton == nil then
						local tbi = "inventoryOp" .. p:getCallSign()
						p:addCustomButton("Operations",tbi,_("inventory-buttonOperations", "Inventory"),function() playerShipCargoInventory(p) end,2)
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
		victory("Exuari")
	end
	if mainGMButtons == mainGMButtonsDuringPause then
		mainGMButtons = mainGMButtonsAfterPause
		mainGMButtons()
	end
	if mainLinearPlot ~= nil then
		mainLinearPlot(delta)
	end
	local s_time = getScenarioTime()
	local whammy_count = 0
	local active_player_count = 0
	for pidx, p in ipairs(getActivePlayerShips()) do
		active_player_count = active_player_count + 1
		if p.pidx == nil then
			p.pidx = pidx
			setPlayers(p)
		end
		updatePlayerLongRangeSensors(p)
		updatePlayerTubeSizeBanner(p)
		if s_time > whammy then
			if whammyTime(p) then
				whammy_count = whammy_count + 1
			end
		end
		if p.prox_scan ~= nil and p.prox_scan > 0 then
			updatePlayerProximityScan(p)
		end
		if p.briefing_time == nil then
			p.briefing_time = getScenarioTime() + 8
		elseif p.briefing_time < getScenarioTime() then
			if p.briefing_sent == nil then
				p.briefing_sent = "done"
				p:addToShipLog(_("shipLog","You've been assigned to this outpost for what seems like an eternity. Hostile forces in the area have attacked in wave after wave. Only one defense platform remains. The more powerful ships assigned to protect this outpost have been destroyed. Using salvaged ships, the internal ship maintenance facilities have cobbled together a ship for you. With enough reputation, you can get ship upgrades from friendly and neutral stations. These stations might help defend the outpost if asked, but they've been hit hard, too. Do your best to protect this remote outpost consisting of the following stations:"),"Magenta")
				for i,station in ipairs(inner_circle) do
					if station ~= nil and station:isValid() then
						p:addToShipLog(string.format(_("shipLog","%s (%s) in sector %s"),station:getCallSign(),station:getFaction(),station:getSectorName()),"Magenta")
					end
				end
			end
		end
		if p.briefing_2_time == nil then
			p.briefing_2_time = getScenarioTime() + 150
		elseif p.briefing_2_time < getScenarioTime() then
			if p.briefing_2_sent == nil then
				p.briefing_2_sent = "done"
				p:addToShipLog(_("shipLog","Intelligence operatives tell us they monitored Exuari communication traffic pertinent to the outpost. The Exuari monitor our traffic, too. They know you plan to protect the outpost, so they have some kind of big attack planned. Intelligence is still trying to figure out when. Best estimate they have is 'between 15 minutes and 2 hours.' That's intelligence for you. Keep a sharp eye out."),"Magenta")
			end
		end
	end
	if whammy_count >= active_player_count then
		whammy = whammy*.8 + getScenarioTime() + random(30,90)
		total_whammies = total_whammies + 1
--		whammy = 3000 + getScenarioTime()
	end
	if s_time > possible_victory_time then
		local p = getPlayerShip(-1)
		if p ~= nil then
			local aggressive_station = false
			for i,station in ipairs(circle_stations) do
				if station ~= nil and station:isValid() and station:isEnemy(p) then
					aggressive_station = true
					break
				end
			end
			if not aggressive_station then
				local duration_string = getDuration()
				local rank = getTripleFactorRank()
				local reason = string.format(_("msgMainscreen","Aggressive enemy stations destroyed. Remaining stations agree to a truce.\nConflict lasted %s. Rank: %s"),duration_string,rank)
				globalMessage(reason)
				setBanner(reason)
				victory(player_faction)
			end
		end
		if s_time > saboteur_idea_time and saboteur_freighters ~= nil then
			sabotageCheck(p)
		end
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
			addGMMessage(_("stationReport-msgGM", "script error - \n")..error)
		end
    end
end

